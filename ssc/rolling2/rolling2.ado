*! version 1.0.9  27feb2007
*! cfb hack 15nov2006 for onepanel option
*  mod 27feb2007 to bring into line with rolling.ado 1.0.9

program rolling2
	capture noisily Rolling2 `0'
	_prefix_clear, e r
	exit c(rc)
end

program Rolling2
	version 9
	local version : di "version " string(_caller()) ":"

	// <my_stuff> : <command>
	_on_colon_parse `0'
	local command `"`s(after)'"'
	local 0 `"`s(before)'"'

	// Make sure data is tsset
	marksample touse
	_ts timevar panvar if `touse', sort panel
	local tfmt : format `timevar'
	qui tsset

	syntax [anything(name=exp_list equalok)]	///
		[aw] [if] [in],				///
		Window(numlist >0 max=1 integer)	///
		[					///
			Recursive			///
			RRecursive			///
			STart(string asis)		///
			End(string asis)		///
			Keep(string asis)		///
			STEPsize(integer 1)		///
			REJECT(string asis)		///
			noDOTS				///
			SAving(string asis)		///
			CLEAR				///
			NOIsily				///
			TRace				///
			ONEpanel            ///
		]

	if "`weight'" != "" {
		local wgt [`weight'`exp']
	}

	// parse the command and check for conflicts
	`version' _prefix_command rolling `wgt' `if' `in' : `command'

	local command   `"`s(command)'"'
	local version   `"`s(version)'"'
	local cmdname   `"`s(cmdname)'"'
	local cmdargs   `"`s(anything)'"'
	local wgt       `"`s(wgt)'"'
	local wtype     `"`s(wtype)'"'
	local wexp      `"`s(wexp)'"'
	local cmdif     `"`s(if)'"'
	local cmdin     `"`s(in)'"'
	local cmdopts   `"`s(options)'"'
	local rest      `"`s(rest)'"'

	if `"`s(level)'"' != "" {
		local level     level(`s(level)')
	}

	// ignore s(efopt)
	local command   `"`s(command)'"'
	local command1 `"`version' `cmdname' `cmdargs' `wgt'"'
	local command2 `"`cmdopts' `rest'"'
	local command2 : list retok command2

	local exclude bootstrap jknife statsby
	if `:list cmdname in exclude' | substr("`cmdname'",1,3) == "svy" {
		di as error "`cmdname' is not supported by rolling"
		exit 199
	}

	local leads = `window' - 1

	local keepstart 0
	if "`keep'" != "" {
		gettoken keep startdate : keep, parse(,)
		capture confirm variable `keep'
		if c(rc) {
			di as error "keep() invalid:  `keep' does not exist"
			exit 198
		}
		gettoken comma startdate : startdate, parse(,)
		if "`startdate'" != "" {
			gettoken startdate : startdate, parse(,)
			capture assert "`startdate'" == "start"
			if c(rc) {
				di as error "`startdate' invalid in keep()"
				exit 198
			} 
			local keepstart 1
		}
		capture confirm numeric variable `keep'
		if c(rc) {
			local keeppost "str18 date"
		}
		else {
			local keeppost "date"
			local keepfmt : format `keep'
		}
	}

	if "`trace'" != "" {
		local noisily   noisily
		local traceon   set trace on
		local traceoff  set trace off
	}
	if "`noisily'" != "" {
		local dots nodots
	}
	local nodots `dots'
	local dots = cond("`dots'" != "" | "`noisily'" != "", "*", "_dots")
	local noi = cond("`noisily'"=="", "*", "noisily")

	// preliminary parse of <exp_list>
	_prefix_explist `exp_list', stub(_stat_)
	local eqlist    `"`s(eqlist)'"'
	local idlist    `"`s(idlist)'"'
	local explist   `"`s(explist)'"'
	local eexplist  `"`s(eexplist)'"'

	_prefix_note `cmdname', `nodots'
	if "`noisily'" != "" {
		di "rolling: First call to `cmdname' with data as is:" _n
		di as inp `". `command'"'
	}

	// run the command using the entire dataset
	_prefix_clear, e r
	`traceon'
	preserve
	capture noisily quietly `noisily' `version' `command'
	restore
	`traceoff'
	local rc = c(rc)
	// error occurred while running on entire dataset
	if `rc' {
		_prefix_run_error `rc' rolling `cmdname'
	}
	// check for rejection of results from entire dataset
	if `"`reject'"' != "" {
		_prefix_reject rolling `cmdname' : `reject'
		local reject `"`s(reject)'"'
	}

	// determine default <exp_list>, or generate an error message
	if `"`exp_list'"' == "" {
		_prefix_explist, stub(_stat_) default
		local eqlist    `"`s(eqlist)'"'
		local idlist    `"`s(idlist)'"'
		local explist   `"`s(explist)'"'
		local eexplist  `"`s(eexplist)'"'
	}
	// expand eexp's that may be in eexplist, and build a matrix of the
	// computed values from all expressions
	tempname b
	_prefix_expand `b' `explist',	///
		stub(_stat_)		///
		eexp(`eexplist')	///
		colna(`idlist')		///
		coleq(`eqlist')		///
		// blank
	local k_eq      `s(k_eq)'
	local k_exp     `s(k_exp)'
	local k_eexp    `s(k_eexp)'
	local K = `k_exp' + `k_eexp'
	local k_extra   `s(k_extra)'
	local names     `"`s(enames)' `s(names)'"'
	local legnames  `"`names'"'
	local express   `"`s(explist)'"'
	// temp scalars for post and list of missings
	forval i = 1/`K' {
		local exp`i' `"`s(exp`i')'"'
		local exps `exps' (`exp`i'')
		tempname x`i'
		local postvals `postvals' (`x`i'')
		local postmiss `postmiss' (.)
	}
	forval i = 1/`k_eexp' {
		gettoken ename legnames : legnames
		local elegnames `elegnames' `ename'
	}

	local legopts   command(`command')      ///
			enames(`elegnames)')    ///
			names(`legnames)')      ///
			express(`express')      ///
			`noisily'
	// check options
	if `"`recursive'"' != "" & `"`rrecursive'"' != "" {
		di as error ///
		  "recursive and rrecursive are mutually exclusive options"
		exit 198
	}

	if `"`saving'"' == "" {
		if `"`clear'"' == "" {
			if c(changed) {
				di as error "no; data in memory would be lost"
				exit 4
			}
		}
		tempfile saving
		local filetmp "yes"
	}
	else {
		if `"`clear'"' != "" {
			di as error ///
			  "clear and saving() are mutually exclusive options"
			exit 198
		}
		_prefix_saving `saving'
		local saving    `"`s(filename)'"'
		if "`double'" == "" {
			local double    `"`s(double)'"'
		}
		local every     `"`s(every)'"'
		local replace   `"`s(replace)'"'
	}

	// otouse is for the outer loop over panels
	tempvar touse otouse
	mark `touse' `cmdif' `cmdin'
	markout `touse' `timevar'
// cfb hack	  if `"`panvar'"' != "" {
	if `"`panvar'"' != "" & "`onepanel'" == "" {
		// orig_touse is an original copy of touse.  This is so that
		// touse can be marked out for each panel and then reset to
		// the original values.
		tempvar orig_touse
		gen `orig_touse' = `touse'

		// Get all levels of the panel variable so we can loop
		qui levelsof `panvar' if `touse'
		local panlevels `"`r(levels)'"'

		// Set otouse to missing so markout works properly
		qui gen `otouse' = .
	}
	else {
		local panlevels "1"
		qui gen `otouse' = 1 if !missing(`touse')
	}

	tempname postname
// cfb hack
	local pv `panvar'
	if "`onepanel'" != "" {
		local pv 
	}
//	postfile `postname' `panvar' start end `keeppost' `names' using ///
	postfile `postname' `pv' start end `keeppost' `names' using ///
		`"`saving'"', `double' `replace' `every'

	// Loop over each panel
	foreach curpanel in `panlevels' {
// cfb hack	 		if `"`panvar'"' != "" {
			if `"`panvar'"' != "" & "`onepanel'" == "" {
			qui replace `touse' = `orig_touse'
			qui replace `otouse' = cond(`panvar' == `curpanel',1,.)
			markout `touse' `otouse'
			local panval = `curpanel'
		}
		// find the start and end of the time to roll over
		if `"`start'"' == "" {
			qui count if sum(`touse') == 0
			local first = `timevar'[r(N) + 1]
		}
		else {
			// check if it is integer or string
			capture confirm integer number `start'
			if c(rc) == 7 {
				capture _confirm_date `"`tfmt'"' `"`start'"'
				if c(rc) {
					di as error ///
"option start() incorrectly specified"
				}
			}
			local first = `ff'(`start')
		}
		if `"`end'"' == "" {
			qui count if sum(`touse'[_N-_n+1]) == 0
			local finish = `timevar'[_N - r(N)]
		}
		else {
			// check if it is integer or string
			capture confirm integer number `end'
			if c(rc) == 7 {
				capture _confirm_date `"`tfmt'"' `"`end'"'
				if c(rc) {
					di as error ///
"option end() incorrectly specified"
				}
			}
			local finish = `ff'(`end')
		}

		if `"`start'"' != "" & `"`end'"' != "" {
			if `ff'(`start') > `ff'(`end') {
				di as err ///
"option start() cannot be greater than option end()"
				exit 198
			}
			if `ff'(`start') == `ff'(`end') {
				di as err ///
"option start() cannot be equal to option end()"
				exit 198
			}
		}

	local reps = ceil( (`finish'+1-`first'-(`window'-1))/`stepsize' )
		// forvalue range
		local fvrange "`first'(`stepsize')`finish'"

		if "`dots'" == "*" {
			local noiqui noisily quietly
		}

		if "`nodots'" == "" | "`noisily'" != "" {
// cfb hack	 			if `"`panvar'"' != "" {
			if `"`panvar'"' != "" & "`onepanel'" == "" {
				di
				di as text "-> `panvar' = `curpanel'"
			}

			di
			_dots 0, title(Rolling replications) reps(`reps') ///
				`nodots'
		}

		local iter 0
		local rejected 0

		if `"`recursive'"' != "" {
			local d1 = string(`first',"`tfmt'")
			local startpost = `first'
		}

		if `"`rrecursive'"' != "" {
			local d2 = string(`finish',"`tfmt'")
			local endpost = `finish'
		}

		forvalues i = `fvrange' {
			local ++iter
			local next = `i' + `leads'

			if (`next' > `finish') {
				continue, break
			}

			if `"`recursive'"' == "" {
				local d1 = string(`i',"`tfmt'")
				local startpost = `i'
			}

			if `"`rrecursive'"' == "" {
				local d2 = string(`next',"`tfmt'")
				local endpost = `next'
			}

			if "`keep'" != "" {
				if `keepstart' {
					local keepval = `keep'[`i']
				}
				else {
					local keepval = `keep'[`next']
				}
				capture confirm numeric variable `keep'
				if c(rc) {
					local keepval `""`keepval'""'
				}
			}

// cfb hack	 		if `"`panvar'"' != "" {
			if `"`panvar'"' != "" & "`onepanel'" == "" {
				if "`keep'" != "" {
			  local post ///
				"post \`postname' (\`panval') (\`startpost') (\`endpost') (\`keepval')"
				}
				else {
			  local post ///
				"post \`postname' (\`panval') (\`startpost') (\`endpost')"
				}
			}
			else {
				if "`keep'" != "" {
			  local post "post \`postname' (\`startpost') (\`endpost') (\`keepval')"
				}
				else {
			  local post "post \`postname' (\`startpost') (\`endpost')"
				}
			}
			if "`cmdopts'`level'`rest'" == "" {
				`traceon'
				preserve
				capture qui `noisily' `version'		    ///
					`cmdname' `cmdargs'		    ///
					`wgt' if tin(`d1', `d2') & `touse'  
				restore
				`traceoff'			
			}
			else {
				`traceon'
				preserve
				capture qui `noisily' `version'		    ///
					`cmdname' `cmdargs'		    ///
					`wgt' if tin(`d1', `d2') & `touse', ///
					`cmdopts' `level' `rest'
				restore
				`traceoff'
			}
			if (c(rc) == 1) error 1
			local bad = c(rc) != 0
			if c(rc) {
				`noi' di as error ///
`"{p 0 0 2}an error occurred when rolling executed `cmdname', "' ///
`"posting missing values{p_end}"'
				`post' `postmiss'
			}
			else {
				if `"`reject'"' != "" {
					capture local rejected = `reject'
					if c(rc) {
						local rejected 1
					}
				}
				if `rejected' {
					local bad 1
					`noi' di as error ///
`"{p 0 0 2}rejected results from `cmdname', "' ///
`"posting missing values{p_end}"'
				}
				else {
					forvalues j = 1/`K' {
						capture scalar `x`j'' = `exp`j''
						if (c(rc) == 1)	error 1
						if c(rc) {
							scalar `x`j'' = .
						}
						if missing(`x`j'') {
							local bad 2
							`noi' di as error ///
`"{p 0 0 2}captured error in `exp`j'', posting missing value{p_end}"'
						}
					}
				}
			}
			if `bad' == 1 {
				`post' `postmiss'
			}
			else {
				`post' `postvals'
			}
			`dots' `iter' `bad'
		}
		`dots' `reps'
	}
	postclose `postname'

	local K = `k_exp' + `k_eexp'

// cfb hack	 		if `"`panvar'"' != "" {
		if `"`panvar'"' != "" & "`onepanel'" == "" {
		local panvarlbl : variable label `panvar'
		local panvallbl : value label `panvar'
		local panfmt : format `panvar'

		if `"`panvallbl'"' != "" {
			tempfile pan_val_lbl
			qui label save `panvallbl' using `"`pan_val_lbl'"'
		}
	}

	if `"`filetmp'"' == "yes" | `"`clear'"' != "" {
		capture use `"`saving'"', clear
		if c(rc) {
			if inrange(c(rc),900,903) {
				di as error ///
			"insufficient memory to load file with rolling results"
			}
			error c(rc)
		}
// cfb pass pv here and below
		ModifyResultsDTA using `"`saving'"', tfmt(`"`tfmt'"')	///
			cmd(`cmdname') panvar(`pv')			///
			panfmt(`panfmt') panvarlbl(`panvarlbl')		///
			panvallbl(`panvallbl')				///
			panvalfile(`pan_val_lbl') names(`names')	///
			exps(`exps') keepfmt(`keepfmt') onepanel(`onepanel')
		if `"`filetmp'"' == "yes" {
			// make c(changed) != 0
			tempname changed
			scalar `changed' = start[1]
			quietly replace start = . in 1
			quietly replace start = `changed' in 1
		}
	}
	else {
		preserve
			use `"`saving'"', clear
			ModifyResultsDTA using `"`saving'"',		///
				tfmt(`"`tfmt'"') cmd(`cmdname')		///
				panvar(`pv') panfmt(`panfmt')	///
				panvarlbl(`panvarlbl')			///
				panvallbl(`panvallbl')			///
				panvalfile(`pan_val_lbl')		///
				names(`names') exps(`exps')		///
				keepfmt(`keepfmt') save onepanel(`onepanel')
		restore
	}
end

program ModifyResultsDTA
	syntax using/ , 		///
		[			///
		tfmt(string)		///
		cmd(string asis)	///
		panvar(varname numeric)	///
		panfmt(string)		///
		panvarlbl(string asis)	///
		panvallbl(string)	///
		panvalfile(string asis)	///
		names(string asis)	///
		exps(string asis)	///
		keepfmt(string asis)	///
		save			///
		onepanel(string asis) ///
		]

	local saving `"`using'"'
	format `tfmt' start end

// cfb hack	 		if `"`panvar'"' != "" {
		if `"`panvar'"' != "" & "`onepanel'" == "" {
		if `"`panfmt'"' != "" {
			format `panfmt' `panvar'
		}

		if `"`panvarlbl'"' != "" {
			label variable `panvar' `"`panvarlbl'"'
		}

		if `"`panvalfile'"' != "" {
			run `"`panvalfile'"'
			label values `panvar' `panvallbl'
		}
	}

	// save labels for the generated vars
	forval i = 1/`: word count  `names'' {
		local name : word `i' of `names'
		local exp`i' : word `i' of `exps'
		local exp`i' = substr("`exp`i''",2,length("`exp`i''")-2)
		local label = substr(`"`exp`i''"',1,80)
		label variable `name' `"`label'"'
	}
	label data `"rolling: `cmd'"'

	if "`keepfmt'" != "" {
		format `keepfmt' date
		qui compress date
	}

	if `"`save'"' != "" {
		save `"`saving'"', replace
	}

end

