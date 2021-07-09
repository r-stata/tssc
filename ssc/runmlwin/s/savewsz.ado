*! savewsz.ado, Chris Charlton and George Leckie, 19May2016
program savewsz,
	version 9.0
	syntax [anything(equalok everything)] [, FORCERecast batch plugin noLabel VERsion(integer 4) noCOMPress mlwinpath VIEWMacro replace]

	local filename `anything'
	if "`filename'" == "" {
		// use current file name and strip off .dta
		local filename `=reverse(substr(reverse("`c(filename)'"), 5, .))'
	}
	
	if "`compress'" == "" {
		if "`substr("`filename'", -4, .)'" ~= ".wsz" {
			local filename `filename'.wsz
		}
	}
	else {
		if "`substr("`filename'", -3, .)'" ~= ".ws" {
			local filename `filename'.ws
		}
	}
	
	if `version' < 0 | `version' > 4 {
		display as error "Invalid version selected"
		exit 198
	}
	
	capture confirm file "`filename'"
	if !_rc & "`replace'"=="" {
		display as error "file `filename' already exists"
		exit 602
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
		if (`r(ver1)' < 2) | (`r(ver1)' == 2 & `r(ver2)' < 20) local versionok = 0

		if `versionok' == 0 {
			display as error "savewsz requires MLwiN version 2.20 or higher. You can download the latest version of MLwiN at: http://www.bristol.ac.uk/cmm/software/mlwin/download/upgrades.html"
			exit 198
		}
		local mlwinversion `r(ver1)'.`r(ver2)'
	}		
	
	unab vars: *
	compress
	
	foreach var of varlist `vars' {
		if "`:type `var''" == "double" {
			if "`forcerecast'" ~= "" {
				recast float `var', force
				display as error "Warning: `var' has been recast to float, this has reduced precision"
			}
			else {
				display as error in smcl "`var' is held to more precision than MLwiN can handle, to reduce the precision use {stata recast float `var', force}"
				exit 198
			}
		}
		if "`:type `var''" == "long" {
			capture recast float `var'
			if `r(N)' > 0 {
				if "`forcerecast'" ~= "" {
					recast float `var', force
					display as error "Warning: `var' has been recast to float, if this is an ID variable its meaning may have changed"
				}
				else {
					display as error "`var' is held to more precision than MLwiN can handle, it must be recoded so that values lie in the range +/- 16,777,215"
					exit 198
				}
			}
		}
	}
	
	tempfile filedata
	qui saveold "`filedata'", `label' replace	
	
	tempname macro1
	qui file open `macro1' using "`macro1'", write replace
		file write `macro1' "RSTA '`filedata''" _n
		file write `macro1' "WVER `version'" _n
		if "`compress'" == "" {
			file write `macro1' "ZSAV '`filename''" _n
		}
		else {
			file write `macro1' "SAVE '`filename''" _n
		}
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
			quietly runmlwin_qshell "`mlwinpath'" /run `macro1'
		}
		else {
			quietly runmlwin_qshell "`mlwinpath'" /nogui /run `macro1'
		}
	}
	
	capture confirm file "`filename'"
	if _rc == 601 {
		display as error "file `filename' could not be opened" _n
		exit 603
	}	
	
end
