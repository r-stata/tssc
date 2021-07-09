*! version 1.0.4 10aug2011 Daniel Klein

prog txtlabdef ,rclass
	vers 9.2

	syntax [anything(name = do)] using/ /*
	*/ [ , /*
	*/ Pchars(str asis) Missing Quotes REMove(string asis) /*
	*/ START(integer 0) STOP(integer 0) /*
	*/ SKIP(numlist int > 0 max = 249) /*
	*/ REPLACE APPEND noDEFine /*
	*/ ]
	
	/*fix filenames and check existence
	------------------------------------*/
	if !`= strmatch(`"`using'"', "*.*")' loc using `"`using'.txt"'
	conf f `"`using'"'
	
	if `"`do'"' != "" {
		loc do : subinstr loc do `"""' "" ,all
		if !`= strmatch("`do'", "*.*")' loc do "`do'.do"
		
		/*extract directory from file
		------------------------------*/
		loc _tmp = reverse("`do'")
		gettoken df pth : _tmp ,p(/\)
		if "`pth'" != "" {
			loc pth = reverse("`pth'")
			loc pwd `"`c(pwd)'"'
			cap cd "`pth'"
			if _rc {
				di `"{err}`pth' not found"'
				exit 601
			}
			else qui cd `"`pwd'"'
		}
		if `= length("`df'")' == 3 {
			di `"{err}{it:dofile} name expected"'
			exit 198
		}
		cap conf f "`do'"
		if !_rc & "`replace'" == "" & "`append'" == "" {
			di `"{err}file `do' already exists; "' /*
			*/ "specify replace} or append"
			exit 198			
		}
	}

	/*check options
	----------------*/
	foreach x in replace append define {
		if "``x''" != "" & "`do'" == "" {
				di "{err}option ``x'' not allowed; specify {it:dofile}"
			exit 198
		}
	}
	if "`replace'" != "" & "`append'" != "" {
		di "{err}options replace and append not both allowed"
		exit 198
	}	
	if "`quotes'" == "" local chg `"" ""'
	else local chg \064d
	
	foreach x in start stop {
		if ``x'' < 0 {
			di "{err}option `x'() must be positive"
			exit 198
		}
	}
	if `start' != 0 & `stop' != 0 {
		cap ass `start' < `stop'
		if _rc {
			di "{err}start(`start') must be lower than stop(`stop')"
			exit 198
		}
	}
	if ("`missing'" == "") loc dot .
	if (`"`pchars'"' == "") loc pchars `"":=-`dot',; ""'
	if ("`skip'" != "") {
		foreach s of loc skip {
			loc skl `skl', `s'
		}
	}
	else loc skl ,0
	
	/*remove tab stop and quotes (leave original file unchanged)
	-------------------------------------------------------------*/
	tempfile tmp_file_0 tmp_file_1
	tempname fh dfh

	filefilter `"`using'"' `tmp_file_1' ,f(\t) t(" ")
	filefilter `tmp_file_1' `tmp_file_0' ,f(\034d) t(`chg') replace
	erase `tmp_file_1'
	
	/*remove user specified strings
	--------------------------------*/
	local m 0
	if `"`remove'"' != "" {
		local n 1
		foreach str of local remove {
			local m2 `m'
			filefilter `tmp_file_`m'' `tmp_file_`n'' /*
			*/ ,f(`"`str'"') t(" ")
			erase `tmp_file_`m''
			local m `n'
			local n `m2'
		}
	}
	
	/*open do-file
	---------------*/
	if `"`do'"' != "" {
		qui file open `dfh' using `do' ,w `replace' `append' all
		if "`append'" != "" file w `dfh' _n
		file w `dfh' `"/*value labels from `using'"' _n
		file w `dfh' /*
		*/ `"created `c(current_date)' `c(current_time)'*/"' _n
	}
	
	/*open using
	-------------*/
	local ln 0
	file open `fh' using `tmp_file_`m'' ,r

	/*skip to start()
	------------------*/
	if `start' != 0 {
		forval j = 2/`start' {
			local ++ln
			file r `fh' empty
			if r(eof) {
				di "{err}invalid option start() : "	/*
				*/ `"`using' only has `j' lines"'
				exit 698
			}
		}
	}
	
	local ++ln
	file r `fh' content
	while !r(eof) {
		if !inlist(`ln'`skl') {
			token "`content'" ,p(`pchars')
			if "`1'" != "" {
				cap conf name `1'
				if _rc {
					cap conf e `lbl_nam'
					if _rc {
						di `"{err}`using' : error in line `ln'; "' /*
						*/ `"value label name expected"'
						exit 698
					}
					cap ass `1' == int(`1')
					if _rc {
						di `"{err}`using' : error in line `ln'; "' /*
						*/ `"'`1'' invalid name or integer"'
						exit 698
					}
					if "`1'" != "." {
						if `"`do'"' != "" & `insertline' {
							file w `dfh' _n
						}
						local insertline 0
						local lbl_txt ""
						local sep ""
						if inlist("`2'" ,":" ,"=" ,"-" ,"." ,",") {
							loc strt 3
						}
						else local strt 2
						while "``strt''" != "" {
							if "`quotes'" != "" local `strt' /*
					*/ = subinstr("``strt''" ,"`= char(64)'" ,`"""' ,.)
							local lbl_txt "`lbl_txt'`sep'``strt''"
							local ++strt
							local sep " "
						}
						if "`define'" == ""	/*
						*/ la de `lbl_nam' `1' `"`lbl_txt'"' ,modify
						if `"`do'"' != ""  {
							if "`quotes'" == "" file w `dfh' /*
			*/ `"label define `lbl_nam' `1' "`lbl_txt'" ,modify"' _n
							else file w `dfh' /*
			*/ `"label define `lbl_nam' `1' `"`lbl_txt'"' ,modify"' _n
						}
						if !(`: list posof "`lbl_nam'" in labelnames') /*
							*/ local labelnames `"`labelnames' `lbl_nam'"'
					}
					else {
						di as txt /*
						*/ `"(note : line `ln' -- may not label `1')"'
					}
				}
				else {
					if "`1'" != "`lbl_nam'" local insertline 1
					local lbl_nam `1'
				}
			}
		}
		local ++ln
		if `stop' != 0 & `ln' > `stop' continue ,br
		file r `fh' content
	}
	file close `fh'
	if `"`do'"' != "" {
		file close `dfh'
		di `"{txt}file `do' saved"'
	}
	ret local labelnames `labelnames'
end
e

History

1.0.4	10aug2011	compatibility with Stata version 9.2
					part of -labutil2- package
1.0.3	07may2011	file extensions need not be specified
					option -save- no longer needed 
					message "file dofile saved" aded
