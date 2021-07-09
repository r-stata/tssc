*! usewsz.ado, Chris Charlton and George Leckie, 23May2019
program usewsz,
	version 9.0
	syntax [anything(equalok everything)] [, batch plugin Clear noLabel mlwinpath(string) VIEWMacro]

	local part namelist
	foreach current of local anything {
		if "`current'" == "if" {
			local part if
		}
		else if  "`current'" == "in" {
			local part in
		}
		else if "`current'" == "using" {
			local part using
		} 
		else {
			local `part' ``part'' `current'
		}
	}
	
	if "`if'" ~= "" {
		local if if `if'
	}
	if "`in'" ~= "" {
		local in in `in'
	}	
	if "`using'" == "" {
		local filename `anything'
	}
	else {
		local filename `using'
	}
	
	if "`filename'" == "" {
		display as error "invalid file specification"
		exit 198
	}
	
	if c(changed) == 1 & "`clear'" == "" {
		display as error "no; data in memory would be lost"
		exit 4
	}
	
	capture confirm file "`filename'"
	if _rc {
		display as error "file `filename' not found"
		exit 601
	}
	
	if "`mlwinpath'" == "" & "$MLwiNScript_path" ~= "" & "`batch'" ~= "" local mlwinpath $MLwiNScript_path	
	if "`mlwinpath'" == "" & "$MLwiN_path" ~= "" local mlwinpath $MLwiN_path	
	
	if "`mlwinpath'" ~= "" {
		capture confirm file "`mlwinpath'"
		if _rc == 601 {
			display as error "`mlwinpath' does not exist." _n
			exit 198
		}
		local versionok = 1
		quietly capture runmlwin_verinfo `mlwinpath'
		if _rc == 198 {
			display as error "`mlwinpath' is not a valid version of MLwiN"
			exit 198
		}
		if (`r(ver1)' < 2) | (`r(ver1)' == 2 & `r(ver2)' < 27) local versionok = 0

		if `versionok' == 0 {
			display as error "savewsz requires MLwiN version 2.27 or higher. You can download the latest version of MLwiN at: http://www.bristol.ac.uk/cmm/software/mlwin/download/upgrades.html"
			exit 198
		}
		local mlwinversion `r(ver1)'.`r(ver2)'
	}		
	
	tempfile filedata
	
	tempname macro1
	qui file open `macro1' using "`macro1'", write replace
		file write `macro1' "LOAD '`filename''" _n
		file write `macro1' "PSTA '`filedata''" _n
		file write `macro1' "EXIT" _n
	file close `macro1'
	
	if "`viewmacro'" ~= "" {
		view "`macro1'"
	}
		
	* Call either MLwiN.exe or MLwiN.plugin
	if "`plugin'"~="" quietly mlncommand OBEY '`macro1''
	else {
		if "`mlwinpath'"=="" {
			di as error "You must specify the file address for MLwiN.exe using either:" _n(2)
			di as error "(1) the mlwinpath() option; for example mlwinpath(C:\Program Files (x86)\MLwiN v2.31\i386\mlwin.exe)" _n
			di as error "(2) a global called MLwiN_path; for example: . global MLwiN_path C:\Program Files (x86)\MLwiN v2.31\i386\mlwin.exe" _n(2) 
			di as error "We recommend (2) and that the user places this global macro command in profile.do, see help profile." _n(2)
			di as error "IMPORTANT: Make sure that you are using the latest version of MLwiN. This is available at: http://www.bristol.ac.uk/cmm/MLwiN/index.shtml" _n

			exit 198
		}
		if "`batch'" == "" {
			quietly runmlwin_qshell "`mlwinpath'" /nowarn /run `macro1'
		}
		else {
			quietly runmlwin_qshell "`mlwinpath'" /nowarn /nogui /run `macro1'
		}
	}
	
	capture confirm file "`filedata'"
	if _rc == 601 {
		display as error "file `filename' could not be opened" _n
		exit 603
	}
	
	mata: checknames("`filedata'")

	use `varlist' `if' `in' using "`filedata'", `clear' `label'
	
end

mata:
	void checknames(string scalar filename) {
		colvector C;
		real scalar fh;
		real scalar ver;
		real scalar byteorder;
		real scalar filetype;
		real scalar reserved;
		real scalar nvar;
		real scalar nobs;
		real scalar varlablen;
		real scalar colnamelen;
		real scalar recsize;
		real scalar fmtlen;
		string scalar data_label;
		string scalar time_stamp;
		real matrix typlist;
		string matrix varlist;
		real matrix srtlist;
		real scalar pos;
		pointer(function) fixname;
		
		fixname = NULL
		if (callersversion() >= 11) {
			fixname = &fixname_11_12()
		} else {
			fixname = &fixname_9_10()
		}
	
		C = bufio();
		fh = fopen(filename, "rw");

		ver = fbufget(C, fh, "%1bu");
		byteorder = fbufget(C, fh, "%1bu");
		filetype = fbufget(C, fh, "%1bu");
		reserved = fbufget(C, fh, "%1bu");
		bufbyteorder(C, byteorder);

		if (filetype != 1)
		{
			display("Invalid file");
			exit();
		}

		nvar = fbufget(C, fh, "%2bu");
		nobs = fbufget(C, fh, "%4bu");

		if (ver == 105) {
			varlablen = 32;
			colnamelen = 9;
			recsize = 16;
			fmtlen = 12;
		}
		else if (ver == 108) {
			varlablen = 81;
			colnamelen = 9;
			recsize = 16;
			fmtlen = 12;
		}
		else if (ver == 110 || ver == 111 || ver == 113) {
			varlablen = 81;
			colnamelen = 33;
			recsize = 32;
			fmtlen = 12;
		}
		else if (ver == 114 || ver == 115) {
			varlablen = 81;
			colnamelen = 33;
			recsize = 32;
			fmtlen = 49;
		}
		else {
			printf("unrecognised version: %f", ver);
			exit(error(198));
		}

		data_label = fbufget(C, fh, "%" + strofreal(varlablen) + "s");
		time_stamp = fbufget(C, fh, "%18s");

		typlist = J(1, nvar, .);
		for (i = 1; i <= nvar; i++) {
			typlist[1, i] = fbufget(C, fh, "%1bu");
		}
		pos = ftell(fh);
		varlist = J(1, nvar, "");
		for (i = 1; i <= nvar; i++) {
			varlist[1, i] = fbufget(C, fh, "%" + strofreal(colnamelen) + "s");
		}
		fseek(fh, pos, -1);
		
		for (i = 1; i <= nvar; i++) {
			varlist[1, i] = (*fixname)(varlist[1, i], colnamelen);
		}
		varlist = fixduplicate(varlist, colnamelen);
		for (i = 1; i <= nvar; i++) {			
			fbufput(C, fh, "%" + strofreal(colnamelen) + "s", varlist[1, i]);
		}		
		
		srtlist = J(1, nvar + 1, 0);
		for (i = 1; i <= nvar + 1; i++) {
			srtlist[1, i] = fbufget(C, fh, "%2bu");
		}
		
		fclose(fh);
	}
	
	string scalar fixname_11_12(string scalar filename, real scalar colnamelength) {
		return(strtoname(filename));
	}	
	
	string scalar fixname_9_10(string scalar name, real scalar colnamelength) {	
		real rowvector codes;
		real rowvector valid;
		
		// Convert string to a characters list
		codes = ascii(name);
		
		// If the name starts with a number append an underscore
		if (codes[1] >=48 && codes[1] <= 57) {
			codes = 95,codes;
		}
		
		// Tag non A-Z, a-z, 0-9
		valid = ((codes:<65 :| codes:>90) :& (codes:<97 :| codes:>122) :& (codes:<48 :| codes:>57))
		
		// Replace tagged characters with an underscore
		for (i = 1; i <= length(codes); i++) {
			if (valid[i] == 1) {
				codes[i] = 95;
			}
		}
		// Truncate to colnamelength characters
		if (length(codes) > colnamelength) {
			codes = codes[|1\colnamelength|];
		}

		// Convert character list back to a string
		name = char(codes);
		
		return(name);
	}
	
	string matrix fixduplicate(string matrix names, real scalar colnamelength) {
		real scalar i;
		real scalar j;
		real scalar counter;
		real matrix dupnames;
		string scalar suffix;
		string scalar newname;
		
		for (i = 1; i <= cols(names); i++) {
			dupnames = names[1,.]:==names[i];
			if (sum(dupnames) > 1) {
				errprintf("duplicate versions of %s, renaming:\n", names[1, i]);
				counter = 1;
				for (j = 2; j <= cols(dupnames); j++) {
					if (dupnames[1, j] == 1) {
						newname = names[1, j];
						
						while (sum(names[1,.]:==newname) > 0) {
							suffix = strofreal(counter);
							if (strlen(names[1, j]) + strlen(suffix) > colnamelength) {
								newname = substr(names[1, j], 1, colnamelength-length(suffix));
							}
							newname = newname + suffix;
							counter = counter + 1;
						}
						
						errprintf("-> %s\n", newname);
						names[1, j] = newname;
					}
				}
			}
		}
		return(names);
	}
	

end
