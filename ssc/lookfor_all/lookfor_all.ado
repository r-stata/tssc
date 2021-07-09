*! version 4.00  06Oct2010 M. Lokshin, Z. Sajaia, D. Blanchette
# delimit ;

program define lookfor_all;
	version 9.0;

	syntax [anything] [, SUBdir DIRectory(string) VLabs NOTES DNotes VNotes Describe CODEbook MAXDepth(integer 1) 
                                DIRFilter(string) MAXVar(integer 4000) Filter(string) *];

	preserve;

	drop _all; // important
					
	local maxvaro = `c(max_k_current)';
	if ( c(SE) == 1 | c(MP) == 1 ) & (`maxvar' > `maxvaro')  {;
  		quietly set maxvar `maxvar';
	};

	if `maxdepth' > 800 {;
		display as error "maxdepth is 800" ;
	};
	if ((!missing(`"`dirfilter'"')) | (!missing("`subdir'"))) & `maxdepth' == 1 {;
  		local maxdepth = 800;
	};
	local matsizeo = `c(matsize)';
	if `maxdepth' > `matsizeo' & `maxdepth' <= 800 {;
		set matsize `maxdepth';
	};
	if (!missing(`"`dirfilter'"'))  & (missing("`subdir'")) {;
		local subdir = "subdir";
	};
	if `maxdepth' > 1  & (missing("`subdir'")) {;
		local subdir = "subdir";
	};

	tempname D;
	matrix `D'=J(1,`maxdepth',1);

	if !missing("`notes'") local vnotes= "vnotes";
	if !missing("`notes'") local dnotes= "dnotes";
	if !missing("`dnotes'") & !missing("`vnotes'") local notes= "notes";

	local i=1;
	local cur_dir `c(pwd)';

	if (!missing(`"`directory'"')) {;
		local cwd `""`c(pwd)'""';
		if `"`c(os)'"' == "Windows" {;
			local cwd `""`c(pwd)'`c(dirsep)'""';
  		};
		capture cd `"`directory'"';
		quietly cd `cwd';
		if _rc != 0 {;
			display as error `"directory "`directory'" not found"';
			exit 601;
		};
		quietly cd `"`directory'"';
	};
	
	tempfile resultsf;
	tempname lfar_ ;
	file open `lfar_' using `"`resultsf'"', text write;

	_lookforall  `anything', `describe' `vlabs' `notes' `dnotes' `vnotes' `options' `codebook' 
                                 maxvar(`maxvar') lfar_(`lfar_') filter(`"`filter'"');  // search in the root directory

	if (!missing(`"`subdir'"')) {;  // case when subdirectory option specified
		while (1) {;
			capture display ""; ** need to reset _rc when it is not == 0 **; 
			local dirs : dir . dirs "*";
			local j=`D'[1,`i'];
			local dirname : word `j' of `dirs';
			if ((!missing("`dirname'")) & _rc == 0) & `i' < `maxdepth' {;
				capture cd "`dirname'";                        // in case we found system folder
				if (_rc == 0) {;
					if regexm(`"`dirname'"',`"`dirfilter'"') {;
						_lookforall `anything', `describe' `vlabs' `notes' `dnotes' `vnotes' `options' 
                                                                `codebook' maxvar(`maxvar') lfar_(`lfar_') filter(`"`filter'"');
					};
					local ++i;
				};
				else matrix `D'[1,`i']=`D'[1,`i']+1;
			};
			else {;
				matrix `D'[1,`i']=1;
				local i=`i'-1;
				quietly cd ..;
				if (`i'==0)  continue, break;
				matrix `D'[1,`i']=`D'[1,`i']+1;
			};
		};
		quietly cd "`cur_dir'";
	};

	file close `lfar_' ;

	drop _all;

	if ( c(SE) == 1 | c(MP) == 1 ) & (`maxvar' > `maxvaro') {;
		matrix drop `D';
  		quietly set maxvar `maxvaro';
	};
	if `maxdepth' > `matsizeo' & `maxdepth' <= 800 {;
		quietly set matsize `matsizeo';
 	};

	restore;
	quietly cd "`cur_dir'";


	capture confirm file `"`resultsf'"';
	if _rc == 0 {;
		file open `lfar_' using `"`resultsf'"', read;
		file read `lfar_' line;
		#delimit cr
		while r(eof) == 0 {
			`line'
			file read `lfar_' line	
		}
		#delimit ;
		file close `lfar_';
	};
end;

/*******************************************************************/
/*******************************************************************/

program define _lookforall;
	version 9.0;
	syntax  [anything] [, Describe CODEbook vlabs NOTES DNotes VNotes MAXVar(integer 4000) lfar_(string) Filter(string) *];
	local all_files : dir . files "*.dta";
	local n_files   : word count `all_files';
	local c_files = 0;
	foreach file of local all_files {;
		local something_found= 0 ;
		local vlist "";
		local notes_vlist "";
		if regexm(`"`file'"',`"`filter'"') == 0 {;
			local n_files = `n_files' - 1;
		};
		else {;
			if missing("`codebook'")  local instr "in 1";
			quietly capture use `"`file'"' `instr';
			if (_rc == 459) | (_rc == 610)  {;
				file write `lfar_' _newline `"display as error  _newline "File "
									as result `""`c(pwd)'`c(dirsep)'`file'""'
									as error  " cannot be open in current version of Stata" "';
				local c_files=`c_files'+1;
			};
			else if (_rc == 900) & "`c(SE)'" == "0" & "`c(MP)'" == "0"  {;
				file write `lfar_' _newline `"display as error  _newline "File "
									as result `""`c(pwd)'`c(dirsep)'`file'""'
									as error  " has more variables than Stata Intercooled can handle " "';
				local c_files=`c_files'+1;
			};
			else if (_rc == 0) {;
				local c_files=`c_files'+(_rc==0);
				local cmd `""`c(pwd)'`c(dirsep)'`file'""';
				if !missing(`"`anything'"') & !missing("`dnotes'") {;
					local nnotes : char _dta[note0] ;
					if !missing("`nnotes'") {;
						local n= 0;
						forvalues x= 1/`nnotes' {;
							foreach a of local anything {;
								local a= lower(`"`a'"');
								local note : char _dta[note`x'];
								mata: long_lower(`"`note'"');
								local lnote : length local note;
								local found : subinstr local note "`a'" "" ;
								local lfound : length local found;
								if `lfound' < `lnote' {;
									local n= `n' + 1;
									local dnote_list`n' `"notes list _dta in `x'"' ;
								};
							};
						};
						local something_found= `n' ;
						forvalues x= 1/`n' {;
							if `x' == 1 {;
								file write `lfar_' _newline
			 					`"display as result _newline `"Dataset {helpb notes:notes} in: "' "'
			 					`"_newline `"{ stata `"use `cmd'"' : use `cmd' }"' _c _newline "then:" _newline "';
							};
							file write `lfar_' _newline
						        `" display as result "{ stata `dnote_list`x'' : `dnote_list`x''}" "';
						};
					};
				};
				if `"`anything'"' != `""'  quietly lookfor `anything';
				if (!missing(r(varlist))) {;
					local something_found= 1 ;
					local vlist `r(varlist)';
					file write `lfar_' _newline
					`"display as result "Variables in:" "' ;
					if (missing("`codebook'") & missing("`describe'")) {;
						file write `lfar_' _newline
					 	`"display `"{ stata `"use `cmd'"' : use `cmd' }"' "'
						`" _newline as result " variables: " as text "`vlist'" "';
					};
					else {;
						file write `lfar_' _newline
					 	`"display `"{ stata `"use `cmd'"' : use `cmd' }"' "'
						`" _newline as result " variables: " as text "`vlist'" "';
	
						if !missing("`describe'") {;
						 	file write `lfar_' _newline `"describe `vlist' using `cmd' , `options' "';
						};
						if !missing("`codebook'") {;
						 	file write `lfar_' _newline `"preserve"' ;
						 	file write `lfar_' _newline `"use `vlist' using `cmd' , clear"';
							if missing(`"`options'"') {;
						 	  file write `lfar_' _newline `"codebook ,  compact "';
							};
							else {;
						 	  file write `lfar_' _newline `"codebook , `options' "';
							};
						 	file write `lfar_' _newline `"restore"';
						};
					};
				};
				if `"`anything'"' != `""' & (!missing("`vlabs'")) {;
					preserve;
					capture uselabel;
					if c(N) > 0 {;
						local n = 1;
						local cond ;
						foreach a of local anything {;
							local a= lower(`"`a'"');
							if `n++' == 1 {;
								local cond `"strpos(lower(lname),"`a'") | strpos(lower(label),"`a'")"';
							};
							else {;
								local cond `"`cond' | strpos(lower(lname),"`a'") | strpos(lower(label),"`a'")"';
							};
						};
						quietly keep if `cond';
						if c(N) > 0 {;
							local something_found= 1 ;
							file write `lfar_' _newline
							`"display "{helpb label:Value labels} in:" "';
							file write `lfar_' _newline
							`"display `"{ stata `"use `cmd'"' : use `cmd' }"' _c _newline "then:""';
							quietly bysort lname: keep if _n == 1;
							forvalues n = 1/`c(N)' {;
								file write `lfar_' _newline
								`"display _newline `"{ stata label list `= lname[`n']' : label list `= lname[`n']' }"' "';
							};
						};
					};
					restore;
				};
				if `"`anything'"' != `""' & (!missing("`vnotes'")) {;
					local n= 0;
					foreach var of varlist _all {;
						local nnotes : char `var'[note0];
						if !missing("`nnotes'") {;
							forvalues x= 1/`nnotes' {;
								foreach a of local anything {;
									local a= lower(`"`a'"');
									local note : char `var'[note`x'];
									mata: long_lower(`"`note'"');
									local lnote : length local note;
									local found : subinstr local note "`a'" "" ;
									local lfound : length local found;
									if `lfound' < `lnote' {;
										local n= `n' + 1;
										local notes_vlist "`notes_vlist' `var'"; 
										local vnote_list`n' `"notes list `var' in `x'"' ;
									};
								};
							};
						};
					};
					if !missing("`notes_vlist'") {;
						local something_found= 1 ;
						local notes_vlist : list uniq notes_vlist;
						file write `lfar_' _newline
						`"display as result "Variable {helpb notes} in:" "' ;
						file write `lfar_' _newline
						`"display `"{ stata `"use `cmd'"' : use `cmd' }"' _c _newline "then:" _newline"';
						forvalues x= 1/`n' {;
							file write `lfar_' _newline
							`" display as result "{ stata `vnote_list`x'' : `vnote_list`x''}" "';
						};
					};
				};
			};
		};
		if `something_found' > 0 {; ** add a blank line to delimit results from each file: **;
			file write `lfar_' _newline `" display "" "'; 
		};
	};
	file write `lfar_' _newline `"display _newline as text " Total " as result `c_files'
					 as text " out of " as result `n_files' as text " files checked in " _c "';

			** since the directory name could have spaces in it, adding *.dta at the end will mess -dir- up  **;
	file write `lfar_' _newline `"display `"{stata `"dir "`c(pwd)'`c(dirsep)'""' : "`c(pwd)'`c(dirsep)'}""' "';
	if (`c_files' < `n_files') {;
		file write `lfar_' _newline `"display _newline as text "(In order to check all `n_files' files in the folder, " _c "';
		if ( c(SE) == 1 | c(MP) == 1 ) {;
			file write `lfar_' _newline `"display "set {helpb maxvar} higher than `maxvar' (max is 32767) and/or" "';
		};
		file write `lfar_' _newline `"display "increase {help memory} allocated to the data area)" "';
	};

end;


mata:;
void long_lower(string scalar lstring)
{
	string scalar m_var ;
	m_var= strlower(lstring) ;
	st_local("note",m_var) ;
}
end;

