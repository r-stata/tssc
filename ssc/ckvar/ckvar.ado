*! version 3.2.1 September 20, 2007 @ 08:35:00
*! runs error checking on a list of variables
program define ckvar , rclass
version 8
	/* 3.2.1 - changed prefix of output variable to `stub' if stub is non-blank */
	/* 3.2.0 - made ckvar use tmpfile option always (most error checkers are non-complex)
              and added note for deprecated -slow- option
            - fixed up output from validation routine
            - now drop the -total- variable when there are no errors */
	/* 3.1.0 - on advice from Stata folks, made -total- non-optional */
	/* 3.0.4 - made the total into a standard thing w/ standardized name */
	/* 3.0.3 - caught some bugs related to ``slow'' */
	/* 3.0.2 - added the slow option from dochar */
	/* 3.0.1 - changed name from checkvar to ckvar b/c there is already another checkvar */
	/* 3.0.0 - changed to run on validation rules rather than error rules */
	/*         direct error checking can be done ONLY by scoring (if wanted) or by using */
	/*         `error' as a temp variable when writing characteristic code */
	/* 2.2.1 - various bug fixes  */
	/* 2.2.0 - added ability to score a variable (as in grading a test) */
	/*       - scoring: missing values are assumed to have a score of 0 */
	/*       - for weights - scoring multiplies the marker by the weight, errors are still just 0,1,2 etc. */
	/* version 2.1.0 - split out the dochar program as separate */
	/* version 2.0.0 - uses characteristics to keep the error checking attached to variables */
	/* have checked the part which checks for missing values */
	/* have checked using another variable to check for missing values */
	/* have checked use of different missing value tags */
	/* have partially checked the use of labels */
	/*  - fix needed: need to figure smart way to drop existing value labels */

	local myname "ckvar"
	set more 1
	syntax [varlist] [, KEY(varlist) MARKDup(namelist) NOVars DROPLABELS STUB(str) SCore VALid keepgoing nopreserve progress slow loud brief]

	if "`slow'"!="" {
		display as result "The -slow- option is now obsolete and will be ignored."
		}
		
	unab allvars : * , min(0)
	local fulllist : list allvars === varlist

	/* choice between valid and score---should be valid alone; left for backward compatibility */
	if "`valid'"!="" {
		if "`score'"!="" {
			display as error "`myname': Please specify either Score or Valid, but not both!"
			exit 198
			}
		}
	else {
		if "`score'"=="" {
			local valid "valid"
			}
		}

	if "`valid'"=="" {
		local output "score"
		}
	else {
		local output "error"
		}
	
	if "`key'"!="" {
		if "`markdup'"=="" {
			_ckdupl `key'
			}
		else {
			confirm new var `markdup'
			_ckdupl `key', gen(`markdup')
			}
		return scalar dups = r(dups)
		}

	if "`loud'"!="" {
		local noisily "noisily"
		}
	
	if "`keepgoing'"!="" {
		local preserve "nopreserve"
		local keepgoing "_continue"
		}
	
	if "`novars'"=="" {
		if "`preserve'"=="" {
			preserve
			}
		capture n {
			if "`stub'"=="" {
				local varstub "`output'"
				local charstub "`output'"
				if "`valid'"!="" {
					local charstub "valid"
					}
				local total `output'__total
				}
			else {
				local varstub "`stub'"
				local charstub "`stub'"
				local total `varstub'__total
				}

			/* double underscore to reduce naming conflict probability */
			capture confirm new var `total'
			if _rc {
				if _rc==110 {
					disp as error "`myname': The variable needed to hold totals: " as result "`total'" as error " already exists!"
					exit 110
					}
				error _rc
				}
			tempvar allmark
			if "`output'"=="error" {
				local byte "byte"
				}
			gen `byte' `allmark' = 0
			if "`output'"=="error" {
				local s "s"							 /* s for stupid */
				}
			label var `allmark' "Total `output'`s' across the observations"
			
			local cnt 1
			/* this makes the tempvars -error- and -valid- if error checking and -score- if scoring */
			tempvar `output' `valid'

			local maxScore 0
			local vcnt 1
			local anychecked 0
			foreach self of local varlist {
				if "`progress'"!="" {
					display as text "Checking `self'..."
					}
				if "`valid'"!="" {
					local tempnames "valid:`valid' error:`error'"
					}
				else {
					local tempnames "score:`score'"
					}
				
				local everythingOK 1
				local misval
				local checked 0
				local failreason

				/* dig through other like variables to find what vars are needed and what other vars are used */
				/*  this should help because it'll pick up required variables anywhere on the like chain */
/* 				dolikedig `self', evalchar(`charstub'_rule) datachar(`charstub'_other_vars_needed) accum */
/* 				local otherVarsNeeded "`r(contents)' `r(visits)'" */
/* 				local otherVarsNeeded: list uniq otherVarsNeeded */
				/* 				local otherVarsNeeded: list otherVarsNeeded - self */

				capture _ckneeded `self', stubs(`charstub') nolikeerror
				if _rc {
					if _rc == 111 {
						display as error "The variable(s) needed to check " as input "`self'" as error " for `output's are: " as input "`r(extras)'"
						local numvar : word count `r(extras)'
						display as error "Please make sure that " plural(`numvar',"this variable is","these variables are") " available!"
						}
					if "`keepgoing'"=="" {
						exit _rc
						}
					display as error "Did not check variable " as result "`self'"
					local failreason "needed other vars"
					local everythingOK 0
					} /* end check for other vars */

				/* figure out the name of the score-holding variable */
				/* if scoring an exam, this would be used for question by question analysis - want for all variables checked */
				if `everythingOK' {
					/* find name to hold the scoring/errors for the variable in question */
					/* can have trouble if there are multiple extremely long names */
					/*   which would have the same abbreviations */
					local scoreVar : char `self'[`varstub'_varname]
					if "`scoreVar'"=="" {
						local scoreVar = "`varstub'_" + substr("`self'",1,31-length("`varstub'")-1)
						}
					capture confirm new var `scoreVar'
					if _rc {
						display as error "The variable for holding `output's from `self': " as result "`scoreVar'"
						display as error "  already exists!"
						if "`keepgoing'"=="" {
							exit _rc
							}
						local everythingOK 0
						local failreason "`scoreVar' exists"
						}	/* end check of new scoring variable */
					}	/* end check if all ok */

				if `everythingOK' {
					/* run the validation/error check/scoring */
					/* using only the tmpfile option, because 99% of all rules do not use complex checking */
					local tempnames `"`tempnames' self:`self'"'
					capture n dochar `self'[`charstub'_rule], tempnames(`tempnames') tmpfile `loud' quiet
					if _rc {
						display as error "Could not evaluate rule `self'[`charstub'_rule]"
						local failreason "bad rule in `charstub'_rule"
						if "`keepgoing'"=="" {
							exit _rc
							}
						else {
							local everythingOK 0
							}
						}
					}

				if `everythingOK' {
					local checked = r(havechar) == "yes"
					local anychecked = `anychecked' | `checked'
					/* negate valid values to get errors */
					if "`valid'"!="" & `checked' {
						capture confirm var `error'
						if _rc {
							gen byte `error' = !`valid'
							drop `valid'
							}
						}
				
					/* use the checking from the deepest variable visited */
					local ckVar : word 1 of `r(likeVarlist)'
					if "`ckVar'"=="" {
						local ckVar "`self'"
						}

					/* when scoring, a missing value most likely would be a 0 */
					local req : char `ckVar'[`charstub'_required]

					if "`req'"!="" & (("`req'" == "1") | strpos("true",lower("`req'")) | strpos("yes",lower("`req'"))) {
						local misval: char `ckVar'[`charstub'_missing_value]
					
						if "`misval'"=="" {
							if "`output'"=="error" {
								local misval -1
								}
							else {
								local misval 0
								}
							}

						/* because missing values could have the same errors as others: */
						quietly count if missing(`self')
						local misscount = r(N)
						if `misscount' { 
							capture confirm new variable ``output''
							if _rc {
								quietly replace ``output'' = `misval' if missing(`self')
								}
							else {
								gen byte ``output'' = cond(missing(`self'),`misval',0)
								}
							local checked 1
							}	/* end of check of whether there were any missing values  */
						}		/* end of check for missing values important */
					else {
						capture confirm new variable ``output''
						if _rc {
							quietly replace ``output'' = 0 if missing(`self')
							}
						local misscount "N/A"
						} /* end check for separate missing */

					/* check to see if the scoreVar variable is even needed */
					/* --- will be kept if scoring, might be dropped when looking for errors */
			
					if `checked' {
						/* for error checking, drop temp var when all OK */
						if "`output'"=="error" {
							quietly count if ``output'' & (``output'' < .)
							local errcount = r(N)
							if `errcount'==0 {
								drop ``output''
								}
							}
						}	/* end of messages for checked variables */
					else {
						local misscount "N/A"
						local errcount "N/A"
						}

					/* now working with both scores and errors, but only if the variable will be kept */
					capture confirm var ``output''
					if !_rc {
										
						local theWt : char `ckVar'[`charstub'_wt]
						if "`theWt'"!="" {
							if `theWt'!=1 {
								if "`output'"=="score" {
									quietly replace ``output'' = ``output'' * `theWt'
									}
								else {
									local wtmod "weight of "
									}
								}
							}
						else {
							local theWt 1
							}

						local theLab : char `ckVar'[`charstub'_vlabel_name]
						if `"`theLab'"'=="" {
							local theLab "`scoreVar'"
							if "`droplabels'"!="" {
								capture label drop `theLab'
								}
							}
					
						/* capture in place in case of overwriting another label */
						local theLabVals : char `ckVar'[`charstub'_vlabel]
						if `"`theLabVals'"'!="" {
							capture label define `theLab' `theLabVals'
							if _rc {
								if _rc != 110 {
									display as error "`myname': There was a problem creating the value label " as result "`theLab'" as error "!"
									if "`keepgoing'"=="" {
										exit _rc
										}
									local everythingOK 0
									local failreason "value label failed"
									}
								}
							}	/* end check for labelling errors */

						if `everythingOK' {
					
							/* now split off errors and scores, again */
							if "`output'"=="error" {
								/* at least need items for 0, and 1 (and -1 if need be) */
								local curlabval : label `theLab' 0
								if `"`curlabval'"' == "0" {
									label define `theLab' 0 "No errors", modify
									}
								if "`misval'"!="" {
									local curlabval : label `theLab' `misval'
									if `"`curlabval'"'=="`misval'" {
										label define `theLab' `misval' "Missing", modify
										}
									}
								local curlabval : label `theLab' 1
								if `"`curlabval'"' == "1" {
									label defin `theLab' 1 "Some error(s)", modify
									}
								}
					
							if ("`output'"=="error") | (`"`theLabVals'"'!="") {
								label values ``output'' `theLab'
								}
							}

						capture confirm new var `scoreVar'
						if !_rc {
							rename ``output'' `scoreVar'
							local now "$S_DATE at $S_TIME"
							label var `scoreVar' "`output' for `self' generated on `now'"
							if "`total'"!="" {
								if "`output'"=="error" {
									quietly replace `allmark' = `allmark' + `theWt'*(`scoreVar' & !missing(`scoreVar'))
									}
								else {
									quietly replace `allmark' = `allmark' + `theWt'*`scoreVar' if !missing(`scoreVar')
									}
								}
							}

						if "`output'"=="score" {
							local maxScore = `maxScore' + `theWt'
							return scalar maxScore = `maxScore'
							}
						}	/* end check for need for the new variable */
					}	/* end of check that things are OK */

				/* this comes first to have blanket for lack of scoreVar */
				capture confirm var `scoreVar'
				if _rc {
					local scoreVar "none"
					}
				local failreason`vcnt' "`failreason'"
				/* this comes second to be sure that all info is blank in case of error */
				if "`failreason'"!="" {
					local failreasons "`failreasons' `self':`failreason';"
					local scoreVar
					local errcount
					local misscount
					}
				local errcount`vcnt' "`errcount'"
				local misscount`vcnt' "`misscount'"
				local scoreVar`vcnt' "`scoreVar'"
				local ++vcnt
				}	/* end of loop over varlist */
			if "`total'"!="" {
				rename `allmark' `total'
				local now =trim("$S_DATE at $S_TIME")
				label var `total' "The total `wtmod'`output'`s' found on `now'"
				}

			if "`output'"=="error" {
				display as text _new "Checking $S_FN on `c(current_date)' at `c(current_time)':" _newline
				if !`fulllist' {
					display as text "Checked a partial variable list: " _newline `"`varlist'"' _newline
					}

				/* display a table only if error totals are non-zero */
				quietly sum `total'
				return scalar totalerrors=`r(sum)'
				if `r(sum)' {
					local varwid 14
					local errwid 6
					local miswid 7
					local evarwid 17
					local failwid 23
					display as text "{ralign `varwid':Variable name}" ///
					  " {c |} {ralign `errwid':Errors}" ///
					  " {c |} {ralign `miswid':Missing}" ///
					  " {c |} {ralign `evarwid':Error-marker name}" `keepgoing'
					if "`keepgoing'"!="" {
						display " {c |} {ralign `failwid':Failure reason}"
						}
					display "{hline `varwid'}{c -}{c +}{c -}{hline `errwid'}{c -}{c +}{c -}{hline `miswid'}{c -}{c +}{c -}{hline `evarwid'}" `keepgoing'
					if "`keepgoing'"!="" {
						display "{c -}{c +}{c -}{hline `failwid'}"
						}
					local vcnt 1

					foreach self of local varlist {
						local showAs "result"
						if "`scoreVar`vcnt''"=="none" {
							local showAs "text"
							}
						if "`failreason`vcnt''"!="" {
							local showAs "error"
							}
						if `"`brief'"'=="" | (real("`errcount`vcnt''")>0 & real("`errcount`vcnt''")<.) | (real("`misscount`vcnt''")>0 & real("`misscount`vcnt''")<.) {
							display as `showAs' %`varwid's abbrev("`self'",`varwid') ///
							  as text " {c |} " as `showAs' "{ralign `errwid':`errcount`vcnt''}" ///
							  as text " {c |} " as `showAs' "{ralign `miswid':`misscount`vcnt''}" ///
							  as text " {c |} " as `showAs' %`evarwid's abbrev("`scoreVar`vcnt''",`evarwid') `keepgoing'
							if "`keepgoing'"!="" {
								display as text " {c |} " as error "{ralign `failwid':`failreason`vcnt''}"
								}
							}
						local ++vcnt
						}
					if "`brief'"!="" {
						display _new as text "All other variables had no errors or missing values of importance."
						}
					}	/* end of check for any errors */
				else {
					if `anychecked' {
						display as result "There were no errors or missing required values!"
						}
					else {
						display as result "No variables were checked---all rules seem to be missing!"
						}
					drop `total'
					}
				}	/* end of printing for error checking */

			return local failreasons "`failreasons'"
			if "`failreasons'"!="" {
				display
				ckfail `"`failreasons'"'
				}
			}	/* end main capture block */
		local rc = _rc
		if `rc' {
			if "`preserve'"=="" {
				if "`failreason'"!="" {
					display as result "ckvar failed because `failreason'"
					}
				if "`failreason'"=="dochar failed" {
					display as result "  try using the tmpfile option..."
					}
				display as text "Data restored..."
				}
			exit `rc'
			}
		else {
			if "`preserve'"=="" {
				restore, not
				}
			}
		}
end
			

program define _ckdupl, rclass
	syntax varlist [, gen(str)]

	tempvar dup
	quietly by `varlist', sort: gen byte `dup' = _n-1
	quietly count if `dup'
	local num=r(N)
	if `num' {
		disp as result  "`num' duplicate" plural(`num'," was","s were") " found based upon matching values of " as input "`varlist'" as result "."
		if "`gen'"!="" {
			quietly {
				by `varlist':  gen long `gen'=_n==1 & _N>1
				replace `gen'=sum(`gen') if `gen' | `dup'
				compress `gen'
				local now "$S_DATE at $S_TIME"
				label var `gen' "Duplicate group number generated on `now' based on key `varlist'"
				}
			}
		}
	else {
		disp as text "There were no duplicates based on matching values of `varlist'."
		}
	return scalar dups = `num'
end

program define ckfail, rclass
	syntax anything
	tokenize `anything', parse(":;")
	local cnt 1
	local maxlen = length("Variable name") + 1
	while `"``cnt''"'!="" {
		local var "``cnt''"
		if `cnt'==1 {
			local vars "`var'"
			}
		else {
			local vars "`vars' `var'"
			}
		local maxlen = max(`maxlen',length("`var'"))
		local cnt = `cnt' + 4
		}
	local col2 = `maxlen' + 1
	if `cnt' > 1 {
		display as result "Fatal Errors"
		display as text "Variable name" _column(`col2') " {c |} Errors"
		display as text "{hline `col2'}{c +}{c -}{hline 53}"
		local cnt 1
		while `"``cnt''"''!="" {
			local reasoncnt = `cnt' + 2
			local reason "``reasoncnt''"
			display as result "``cnt''" _column(`col2') as text " {c |} " as result "``reasoncnt''"
			local cnt = `cnt' + 4
			}
		}
	else {
		display as text "All OK"
		}
	return local failvars "`vars'"
end
