*! combomarginsplot.ado - Nicholas Winter
*! version 0.1.5 21nov2017

* Changes
* 0.1.3: downgraded to require Stata 12 r/t 13
* 0.1.5: added -restore- to allow addplot() optoin to work
program combomarginsplot
	version 12
	
	#delimit ;
	syntax anything(name=flist id="List of saved margins files") 
	, [ 
		Labels(string asis) 
		savefile(string)			// the combined margins file
		FILEVarname(string)
		mpsaving(passthru)			// [undocumented] the margins file as modified by -ncmarginsplot- 
		debug					// [undocumented]
		level(string)				// catch here -- needs to be specified in margins..., saving call
		* 
	]
	;
	#delimit cr
	
	if !mi("`level'") {
		di as error "Must specify level() option when creating margins files"
		exit 198
	}
	
	if !mi("`debug'") 	local debug 
	else 			local debug *
	
	if mi("`filevarname'") local filevarname _filenumber

	confirm name `filevarname'
	foreach file of local flist {
		capture describe `filevarname' using "`file'"
		if !_rc {
			di as error "variable `filevarname' exists in file `file'; specify different variable name with filevarname() option"
			exit 111
		}
	}
	
	preserve
	clear


	/************************************************************
	*	Cycle through files to coordinate _at, _m, _by variables & save as tempfiles
	*	This accomplishes two things:
	*	
	*		(1) any _at, _m, and _by variables that don't exist in a file are created and set to .o (asobserved)
	*		(2) mappings between _at/_m/_by and real underlying varnames are made consistent across files
	*		(3) char _dta[_atopt#] are coordinated with new mapping
	*		(4) _atopt and _term variables are coordinated across datasets
	*	
	*		Locals used:
	*	
	*		oldnames			file's existing _`type'# variables  (e.g., _at1 _at2 ...)
	*		f_`type'_vars		file's existing varnames associated with _`type'# (e.g., mpg price ...)
	*
	*		newnames			new _`type'# that match across files (e.g., _at2 _at1 ...)
	*		m_`type'_vars		varnames associated with newnames (e.g., price mpg ...)
	*	
	************************************************************/
	
	local typelist at m by		// _at# _m# _by#

	local filenum 0
	foreach file of local flist {
		local ++filenum

		qui use "`file'"
		`debug' di "{txt}Using {res}`file'"
		`debug' di "{txt}***************************************"

		foreach type in `typelist' {		

			`debug' di "{txt}type: {res}`type'"
			local oldnames									// file's existing _`type'# variables
			local newnames									// list of corresponding new _`type'# variables from combined, consistent list

			// get list of this file's `type' variables
			if "`type'"=="m" 	local ttype margin				// named inconsistently
			else 			local ttype `type'
			local f_`type'_vars : char _dta[`ttype'_vars]
			
			/*
				f_`type'_vars			-- original list of vars 
				m_`type'_vars			-- reordered/expanded list of vars ... this is accumulated across all files
			*/

			local i 0
			foreach var of local f_`type'_vars {					
				local ++i										// i indexes position in current file varlist, i.e. old position
				local newpos : list posof "`var'" in m_`type'_vars	// have we already mapped this varname?
				if `newpos'==0 {								// haven't seen it before
					local m_`type'_vars `m_`type'_vars' `var'		// add this variable to master list
					local newpos : list sizeof m_`type'_vars		// update newpos
				}
				`debug' di "   {txt}var:[{res}`var'{txt}] newpos:[{res}`newpos'{txt}] m_`type'_vars:[{res}`m_`type'_vars'{txt}]" 

				// add old and new varnames to respective lists
				local oldnames `oldnames' _`type'`i'
				local newnames `newnames' _`type'`newpos'
			}

			// deal with atstats#
			if "`type'"=="at" {
				// cycle through each set of atstats#
				forval j=1/`: char _dta[k_at]' {
					local statlist
					foreach atvar of local m_at_vars {					// this is the full list of at vars, whether or not they appear in this file
						local oldpos : list posof "`atvar'" in f_at_vars	// position of this one in THIS FILE's original ordering
						if `oldpos'==0 {
							local stat asobserved					// this one wasn't here; go with asobserved
						}
						else {
							local stat `: word `oldpos' of `: char _dta[atstats`j']''
						}
						local statlist `statlist' `stat'
					}

					`debug' di " ATSTATS`j':"
					`debug' di "   varlist (old): `f_at_vars'"
					`debug' di "   varlist (new): `m_at_vars'"
					`debug' di ""
					`debug' di "   stats (old)  : `: char _dta[atstats`j']'"
					`debug' di "   stats (new)  : `statlist'"

					`debug' di 
					`debug' di "   SET: atstats_`filenum'_`j' [`statlist']"

					char _dta[atstats`j'] `statlist'
					local atstats_`filenum'_`j' `statlist'

				}
			}
					

			// rename variables to updated names
			if !mi("`oldnames'`newnames'") {							// if there are any variables to process
				local rcmd rename (`oldnames') (`newnames')
				`debug' di `"{txt}`rcmd'"'		
				qui `rcmd'										// note that rename moves the characteristics ... nice
			}

			`debug' di "       m_`type'_vars: [`m_`type'_vars']"

		}

		* deal with _term and _atopt variables
		* list of labels accumulated in m_`type'_labels
		* creates:		newtermlab`type' -- the value labels for the combined file
		*				recodestring`type' -- the recode string for this file to renumber the values into consistent coding across files
		foreach type in _term _atopt {
			local recodestring`type'				// will contain recoding from this file's `type' list to master `type' list
			`debug' di "getting `type' label"

			// if _atopt is missing, then label won't exist
			capture label list `type'
			if !_rc {
				local lmin = r(min)
				local lmax = r(max)

				// make master list of all values of _term/_atopt
				forval ll = `lmin'/`lmax' {
					local curlabel `: label (`type') `ll''
					local newpos : list posof "`curlabel'" in m`type'_labels			// have we seen this label before?

					if `newpos'==0 {											// haven't seen it before
						local m`type'_labels `"`m`type'_labels' "`curlabel'""'			// append this label
						local newpos : list sizeof m`type'_labels					// update newpos
						local newtermlab`type' `newtermlab`type'' `newpos' "`curlabel'"	// add new label to label string (accumulated across all files)
					}

					`debug' di `"{txt}term:[{res}`curlabel'{txt}] newpos:[{res}`newpos'{txt}] m`type'_labels:[{res}`m`type'_labels'{txt}]"'

					local recodestring`type' `recodestring`type'' (`ll'=`newpos')		// add old and new levels to recode string (for this file only)

				}
				`debug' di `"m`type'_labels: [`m`type'_labels']"'
				`debug' di `"recodestring:  [`recodestring`type'']"'
				`debug' di `"newtermlab:    [`newtermlab`type'']"'

				`debug' di `"===> [recode `type' `recodestring`type'']"'				// recode `type' to new values
				qui recode `type' `recodestring`type''								// recode `type' to new values
				la drop `type'													// drop now-incorrect label string 
																			// new value labels get applied after files are appended
			}
		}
		
		// predict_label, margin_label, title
		if `filenum'==1 {
			local predict_label 	`: char _dta[predict_label]'
			local expression_label 	`: char _dta[expression]'
			local margin_label  	`: variable label _margin'
			local title_label   	`: char _dta[title]'
		}
		else {
			local predict_label = 		cond("`predict_label'"=="`: char _dta[predict_label]'","`predict_label'","Predictions")
			local expression_label = 	cond("`expression_label'"=="`: char _dta[expression]'","`expression_label'","Predictions")
			local margin_label  = 		cond("`margin_label'"=="`: variable label _margin'","`margin_label'","Prediction")
			local title_label   = 		cond("`title_label'"=="`: char _dta[title]'","`title_label'","Combined margins results")

			// if one file has prediction and another has expression, reset both to generic
			if !mi(`"`predict_label'"') & !mi(`"`expression_label'"') {
				local predict_label		Predictions
				local expression_label	Predictions
			}

		}		
						

		// save modified file
		tempfile workingfile
		qui save `workingfile', replace
		local workingflist `workingflist' `workingfile'
	}

	// redundant
	local nfiles : word count `workingflist'
************
* Reconcile atstats# across files
* Inconsistencies should be OK except that 'values' should override
************
	forval i=`nfiles'(-1)1 {											// last file will be comprehensive, so start there
		local j 1
		while !mi(`"`atstats_`i'_`j''"') {								// file _ #
			local nstats : word count `atstats_`i'_`j''
			
			forval k = 1/`=`i'-1' {									// check against all prior files
				forval word = 1/`nstats' {
					local curstat : word `word' of `atstats_`i'_`j''
					local othstat : word `word' of `atstats_`k'_`j''		// same position, same atstat#, different file
					
					if ("`curstat'"!="`othstat'") & "`othstat'"!="" {
						// curstat is the one from the higher file, so it should override if it is 'values'
						local varname : word `word' of `m_at_vars'
						di "{txt}Warning: statistics differ for {res}`varname'{txt}: file {res}`k'{txt}={res}`othstat'{txt}, file {res}`i'{txt}={res}`curstat'{txt};  " _c
						if "`curstat'"=="values" {
							local thefile : word `k' of `workingflist'
							qui use `thefile'
							local oldchar : char _dta[atstats`j']
							forval z = 1/`=`word'-1' {
								local newchar `newchar' `: word `z' of `oldchar''
							}
							local newchar `newchar' values
							forval z = `=`word'+1'/`: word count `oldchar'' {
								local newchar `newchar' `: word `z' of `oldchar''
							}
							char _dta[atstats`j'] `newchar'
							qui save, replace
							local newchar
							di "using {res}values{txt}"
						}
						else {
							di "using first ({res}`othstat'{txt})"
						}
					}
					else {
						`debug' di "   match stats: file `i' stat `word' [`curstat'] " _col(50) "VS. file `k' stat `word' [`othstat']"
					}

				}
			}
			local ++j
		}
	}
	
			
*******************************************
* append modified datasets together
*******************************************
	drop _all
	*clear

	forval i=1/`nfiles' {
		local lab  : word `i' of `labels'							// user-specified labels for files
		local file : word `i' of `workingflist'
		qui {
			append using `file'

			if `i'==1 {
				local num = `: word count `m_m_vars'' + 1
				gen _m`num' = `i' 
				local m_m_vars `m_m_vars' `filevarname'				// append to m varlist
				local m_at_vars `m_at_vars' `filevarname'			// aapend to at varlist
				
				// Grab list of u_at_vars
				// & construct list of _u_at_vars from positions in m_at_vars
				local master_u_at_vars : char _dta[u_at_vars]				// real varnames
				foreach var of local master_u_at_vars {
					local newpos : list posof "`var'" in m_at_vars
					if `newpos'==0 {
						di as error "`var' in u_at_vars doesn't appear in m_at_vars??"
						exit 198
					}
					local master__u_at_vars `master__u_at_vars' _at`newpos'
				}
				//char _dta[_u_at_vars] `master__u_at_vars'
				// blank out so we get next files' when appended
				char _dta[_u_at_vars] 
				char _dta[u_at_vars] 
				
			}
			else {
				replace _m`num' = `i' if mi(_m`num')
				
				// Deal with u_at_vars
				local local_u_at_vars : char _dta[u_at_vars]				// real varnames
				
				local diff : list this_u_at_vars - master_u_at_vars
				if !mi("`diff'") {
					di as error "File `i' has u_at_vars that don't appear in file 1"
					exit 198
				}
				
				local local__u_at_vars
				foreach var of local local_u_at_vars {
					local newpos : list posof "`var'" in m_at_vars
					if `newpos'==0 {
						di as error "`var' in u_at_vars doesn't appear in m_at_vars??"
						exit 198
					}
					local local__u_at_vars `local__u_at_vars' _at`newpos'
				}
				if "`local__u_at_vars'"!="`master__u_at_vars'" {
					noi di "local: `local__u_at_vars' master: `master__u_at_vars'"
					di as error "file `i' _u_at_vars don't match file 1"
					di "local: `local__u_at_vars' `master__u_at_vars'"
					exit 198
				}
				//char _dta[_u_at_vars] `local__u_at_vars'

			}
			
			if !mi(`"`labels'"') 	label define _m`num' `i' `"`lab'"', add
			else					label define _m`num' `i' `"File `i'"', add
		}
	}

	label values _m`num' _m`num'
	label variable _m`num' "File Number"
	char _m`num'[varname] `filevarname'
	char _dta[u_at_vars] `master_u_at_vars'
	char _dta[_u_at_vars] `master__u_at_vars'
	

**********************
* FIX UP CHARACTERISTICS, LABELS, ETC
*******************
	// label _term & _atopt variables
	foreach type in _term _atopt {
		if !mi(`"`newtermlab`type''"') {
			label define `type' `newtermlab`type''
			label values `type' `type'
		}
	}

	// reconstitute characteristics atopt#
	tokenize `"`newtermlab_atopt'"'
	while !mi("`1'") {
		local num `1'
		local lab `2'
		confirm integer number `1'
		char _dta[atopt`1'] "`2'"
		mac shift
		mac shift
	}


	// set _dta characteristics & labels, titles
	foreach type in `typelist' {		// at m by
		char _dta[`type'_vars] "`m_`type'_vars'"
	}
	// named inconsistently
	char _dta[margin_vars] "`m_m_vars'"


	char _dta[predict_label] `"`predict_label'"'
	char _dta[expression]	`"`expression_label'"'
	char _dta[title]		`"`title_label'"'

	label variable _margin `"`margin_label'"'

	// create _at variable
	rename _at _oldat
	foreach var of varlist _at* {
		qui replace `var' = .o if `var'==.
	}
	egen _at = group(_at*), missing		// _at* includes _atopt as well as all _at? variables
	la var _at `"`: variable label _oldat'"'

	//hold options
	local mpopts `options'

	// parse savefile -- the combine margins file
	local 0 `"`savefile'"'
	syntax [ anything(name=savefile id="File name") ] , [ replace ]
	if mi("`savefile'") {
		local qui qui
		tempfile savefile
	}
	else {
		local qui
		di "{txt}Saving combined margins file `savefile'"
	}
	`qui' save "`savefile'" , `replace'


//RUN -marginsplot-
	restore
	local cmd cmp_marginsplot using "`savefile'" , filevarname(`filevarname') `mpopts' `mpsaving' 
	`debug' di `"[`cmd']"'

	`cmd'



end

exit

