*! version 1.1.4  6oct02 arb
*! Reformats the output from regression commands
*! (c) Sealed Envelope Ltd, 2002
program define reformat, sortpreserve
	version 7

	#delimit ;
	syntax [varlist (default=none)] [, OUTput(string) cw(int 22) noCONS sd
	 iqr EForm DPCoef(int 3) dpp(int 3) noBRACkets to(string) DELimit(string)
	 sort LRtest NOISily NFmt(string) PREfix(string)];
	#delimit cr

	/*
		These variable characteristics are created (and destroyed at the end):
		vstub		varname1[varname2]	Note: varname2 only present for interaction terms
		varlab		variable description
		vallab		value label
		[var2]		varname2 for interaction terms only
		[cat]		value of this category for _I categorical terms only
		[bascat]	value of baseline category for _I categorical terms only
		[basvl]		baseline value label for _I categorical terms only
		[nobs]		N for this term if n output option chosen
		[mlt]		Multiplier for continuous terms (e.g. SD or IQR)
		[lrpval]	LR test P-value
		type		type of varname1 - str or num
	*/

	if `dpcoef' > 8 | `dpp' > 8 {
		disp "{error}Maximum of 8 decimal places allowed"
		exit
	}
	if missing("`output'") {
		local output espc	/* default output */
	}
	else {
		* Check output options are valid
		local i=length("`output'")
		while `i'>0 {
			if index("neszpc",substr("`output'",`i',1))==0 {
				disp "{error}" substr("`output'",`i',1) " is not a valid output option (valid options are n, e, s, z, p, and c)"
				exit
			}
			local i=`i'-1
		}
	}
	if !missing("`prefix'") {
		if length("`prefix'") > 4 {
			disp "{error}invalid prefix stub name, name too long ( >4 )"
			exit 198
		}
	}
	else {
		if _caller() <=6 {
			local prefix I
		}
		else {
			local prefix _I
		}
	}
	if missing("`brackets'") {
		global RE_opbrack (
		global RE_clbrack )
	}
	if missing("`to'") {
		global RE_to " to "
	}
	else if "`to'" == "no" {
		global RE_to
	}
	else {
		global RE_to `"`to'"'
	}
	local cmd = e(cmd)
	if "`cmd'" == "mlogit" {
		disp "{error}not possible after mlogit"
		exit
	}
	else if "`cmd'" == "cox" & "`e(cmd2)'"!="stcox" & !missing("`lrtest'") {
		disp "{error}lrtest option not available after cox - use stcox instead"
		exit
	}
	else if "`cmd'" == "cox" & "`e(cmd2)'"=="stcox" {
		local cmd stcox
	}
	if !missing("`sd'") & !missing("`iqr'") {
		disp "{error}Cannot specify both sd and iqr options"
		exit
	}
	if missing("`nfmt'") {
		local nfmt %7.0f
	}
	else {
		* check format is valid
		qui disp `nfmt' 1
	}

	global RE_dlen `cw'	/* space allocated to covariate labels */
	global RE_dpp `dpp'	/* decimal places for p-values */
	global RE_dpco `dpcoef' /* decimal places for coefs */

	qui `cmd'				/* refresh _results */
	if "`cmd'" == "logistic" | "`cmd'" == "stcox" { local eform eform }	/* turn on eform option automatically */
	if "`cmd'" == "regress" {
		local ztitle "t"
		local ptitle "P>|t|"
		local df = e(df_r)
		local zval = invttail(`df',(100-$S_level)/200)
	}
	else {
		local ztitle "z"
		local ptitle "P>|z|"
		local df 100000000		/* makes t-distribution normal */
		local zval = -invnorm((100-$S_level)/200)
	}
	if missing("`eform'") {
		local estitle "Coef."
		local estbase 0
	}
	else {
		local estbase 1
		local estfn exp
		if index("`cmd'","logi")>0 | "`e(fam)'" == "bin" {
			local estitle "Odds Ratio"
		}
		else if "`cmd'" == "poisson" | "`cmd'" == "nbreg" | "`e(fam)'" == "poi" | "`e(fam)'" == "nb" {
			local estitle "IRR"
		}
		else if "`cmd'" == "cox" | "`cmd'" == "stcox" {
			local estitle "Haz. Ratio"
		}
		else {
			local estitle "exp(coef.)"
		}
		local cons nocons
	}
	tempname Cstar names
	matrix `Cstar' = get(VCE)
	local coln = colsof(`Cstar')
	matrix `names' = `Cstar'[1..`coln',1]
	local covl : rownames(`names')
	* Put full equation:varname terms into local rn (so correct _b[]'s are used later for multi eq models)
	local rn : rowfullnames(`names')
	if index("`rn'",":") {
		* multiple equation model detected
		local meq yes
	}
	if missing("`varlist'") {
		local varlist `covl'
	}
	else {
		if "`meq'"=="yes" {
			disp "{error}varlist not allowed with multiple-equation models"
			exit 101
		}
		* Check user varlist is valid
		foreach 1 of local varlist {
			local fnd 0
			foreach 2 of local covl {
				if "`1'"=="`2'" | "`1'"=="_cons" {
					local fnd 1
				}
			}	/* end foreach 2*/
			if !`fnd' {
				disp "{error}`1' not found in model"
				exit 111
			}
		}    /* end foreach 1 */
	}
	if !missing("`sort'") {
		if "`meq'"=="yes" {
			disp "{error}sort not allowed with multiple-equation models"
			exit 498
		}
		/* sort terms into alphabetical order */
		tokenize `varlist'
		local nvar : word count `varlist'
		local swap 1
		while `swap' {
			local i 1
			local ip1 2
			local swap 0
			while `i'<`nvar' {
				if lower("``i''") > lower("``ip1''") & "``i''"!="_cons" & "``ip1''"!="_cons" {
					* Swap element i and i+1
					local hold ``i''
					local `i' ``ip1''
					local `ip1' `hold'
					local swap 1
				}
				local i = `i'+1
				local ip1 = `ip1'+1
			}
		}
		local i 1
		local varlist
		while `i'<=`nvar' {
			local varlist "`varlist'``i'' "
			local i=`i'+1
		}
	}
	* Process labels and define categorical variables of all terms in model
	foreach term of local covl {
		cap confirm variable `term'	/* don't process cut points, _cons etc. */
		if _rc == 0 {
			* Stub, variable heading, and value label
			local varlab : variable label `term'
			if substr("`term'",1,length("`prefix'"))=="`prefix'" {
				/* Categorical variable */
				local p : char _dta[omit]
				if "`p'"=="prevalent" {
					disp "{error}reformat does not support _dta[omit] prevalent characteristic"
					error 498
				}
				local i 1
				local varnme2
				local varlp2
				local var2
				local link
				local inter
				tokenize "`varlab'", parse("()==&*")
				while !missing("`1'") {
					cap confirm variable `1'
					if _rc == 0 {				/* a variable */
						local varnme`i' `1'
						local var`i' `1'		/* this will be over-written if categorical variable */
						local varlp`i' : variable label `varnme`i''
						if missing("`varlp`i''") {
							local varlp`i' `varnme`i''
						}
						cap typeof `1' str
						if _rc {
							* Not string
							local type`i' num
						}
						else {
							* string
							local type`i' str
							* add quotes to var label
						}
					}
					else {
						cap confirm integer number `1'
						if _rc == 0 & "`type`i''"=="num" {			/* a number */
							local varval`i' `1'
							local vallab`i': value label `varnme`i''
							if !missing("`vallab`i''") {
								local var`i': label `vallab`i'' `varval`i''
							}
							else {
								local var`i' `varval`i''
							}
							local i = `i' + 1
						}
						else if "`1'" == "&" | "`1'" == "*" {
							local link " `1' "
							local inter " interaction"
						}
						else if !inlist("`1'","==","(",")")  & "`type`i''"=="str" {
							* a category from a string variable
							local varval`i' `1'
							local vallab`i' '1'
							local var`i' `1'
							local i = `i' + 1
						}
					}
					mac shift
				}
				char `term'[vstub] `varnme1'`varnme2'			/* cat variable id */
				char `term'[var2] `varnme2'				/* interaction variable (needed for mult) */
				char `term'[varlab] `varlp1'`link'`varlp2'`inter'	/* variable description */
				char `term'[vallab] `var1'`link'`var2'			/* value label */
				char `term'[type] `type1'				/* str or num */
				* Baseline group for this term (except interactions)
				if missing("`inter'") {
					char `term'[cat] `varval1'	/* category */
					local basel : char `varnme1'[omit]
					if missing("`basel'") {
						if "`type1'"=="num" {
							* baseline for numeric variable
							qui summ `varnme1'
							local basel = r(min)
						}
						else {
							* baseline for string variable
							preserve
							qui keep if e(sample)
							sort `varnme1'
							local basel = `varnme1'[1]
							restore
						}
					}
					* Value label
					if !missing("`vallab1'") & "`type1'"=="num" {
						local bvl: label `vallab1' `basel'
					}
					else {
						local bvl `basel'
					}
					char `term'[bascat] `basel'	/* baseline category */
					char `term'[basvl] `bvl'	/* baseline value label */
				}
				* N for this term
				if index("`output'","n") {
					if index("`varlab'","*") {
						local varlab = substr("`varlab'",1,index("`varlab'","*")-1)
					}
					if "`type1'"=="str" {
						local varlab : subinstr local varlab "(" "", all
						local varlab : subinstr local varlab ")" "", all
						gettoken v1 varlab:varlab, parse("==")
						gettoken v2 varlab:varlab, parse("==")
						gettoken v3 varlab:varlab, parse("&")
						local v3 : subinstr local v3 " " "", all
						local varlab `v1'=="`v3'" `varlab'
					}
					if "`type2'"=="str" {
						local varlab : subinstr local varlab "(" "", all
						local varlab : subinstr local varlab ")" "", all
						gettoken v1 varlab:varlab, parse("&")
						gettoken v2 varlab:varlab, parse("==")
						gettoken v3 varlab:varlab, parse("==")
						local v3 : subinstr local v3 " " "", all
						local varlab `v1'`v2'=="`varlab'"
					}
					qui count if `varlab' & e(sample)
					char `term'[nobs] `r(N)'	/* N */
				}
			}
			else {
				/* Continuous variable */
				char `term'[vstub] `term'
				if missing("`varlab'") {
				    local varlab `term'
				}
				char `term'[varlab] `varlab'
				/* [units] char is dominant if present */
				local var : char `term'[units]
				local mult : char `term'[mult]
				if !missing("`sd'") & missing("`mult'") {
					qui summ `term'
					local mult=r(sd)
					local stdev : display %5.3f `r(sd)'
					if !missing("`var'") {
						local var "per S.D. (=`stdev' `var')"
					}
					else {
						local var "per S.D. (=`stdev')"
					}
				}
				else if !missing("`iqr'") & missing("`mult'") {
					qui summ `term', detail
					local mult = r(p75)-r(p25)
					local iqr : display %5.3f `mult'
					if !missing("`var'") {
						local var "per IQR (=`iqr' `var')"
					}
					else {
						local var "per IQR (=`iqr')"
					}
				}
				else if !missing("`var'") {
					if !missing("`mult'") {
						local var "per `mult' `var'"
					}
					else {
						local var "per `var'"
					}
				}
				else {
					if !missing("`mult'") {
						local var "per `mult' units"
					}
					else {
						local var "per unit"
					}
				}
				if missing("`mult'") {
					local mult 1
				}
				char `term'[vallab] `var'
				char `term'[mlt] `mult'		/* Beta multiplier */
				char `term'[nobs] `e(N)'
			}	/* end if */
		}	/* end if */
	}	/* end foreach */

	local lrc 0	/* no. of commas between description and LR p-val */
	if !missing("`lrtest'") & missing("`meq'") {
		/* do likelihood ratio tests */
		local lrc = index("`output'","p")
		local ptitle "P^"
		tempvar es
		gen byte `es'=e(sample)
		disp "{txt}Performing likelihood-ratio tests" _c
		local dpv `e(depvar)'
		lrtest, saving(0)
		cap estimates unhold orig
		estimates hold orig
		local ovstub
		foreach 1 of local varlist {
			if "`1'"!="_cons" {
				local vstub: char `1'[vstub]
				if "`vstub'"!="`ovstub'" {
					local ovstub `vstub'
					local fitl
					foreach cov of local covl {
						if "`cov'"!="_cons" {
							local covst: char `cov'[vstub]
							if "`vstub'"!="`covst'" {
								local fitl "`fitl' `cov'"
							}
						}
					}
					if missing("`noisily'") {
						disp "{txt}." _c
					}
					qui {
					if "`cmd'"=="stcox" {
						stcox `fitl' if `es'
					}
					else {
						`cmd' `dpv' `fitl' if `es'
					}
					`noisily' disp _n "{txt}`vstub'"
					`noisily' lrtest
					}	/* end quietly */
					char `1'[lrpval] `r(p)'		/* Likelihood ratio P-value */
				}	/* end if */
			}	/* end if */
		}	/* end foreach */
		estimates unhold orig
		disp
	}
	else if !missing("`lrtest'") {
		local lrtest
		disp "{txt}Warning: likelihood ratio tests not supported for multiple-equation models"
	}

	* Output header
	disp _n "{txt}" upper("`cmd'") _c
	if !missing("`e(title_fl)'") {
		disp " `e(title_fl)'" _c
	}
	disp " formatted output"
	if "`cmd'"=="stcox" | "`e(cmd2)'"=="streg" {
		local stvar : char _dta[st_bt]
		local sdvar : char _dta[st_bd]
		local varlabt: variable label `stvar'
		if !missing("`varlabt'") { local varlabt " (`varlabt')" }
		local varlabd: variable label `sdvar'
		if !missing("`varlabd'") { local varlabd " (`varlabd')" }
		disp _n "{txt}Survival time: {res}`stvar'{txt}`varlabt'"
		disp "{txt} failure indicator: {res}`sdvar'{txt}`varlabd', n={res}`e(N)'"
	}
	else if inlist("`cmd'","blogit","bprobit","glogit","gprobit") {
		local depvar: word 1 of `e(depvar)'
		local denom: word 2 of `e(depvar)'
		local varlab1: variable label `depvar'
		local varlab2: variable label `denom'
		if !missing("`varlab1'") { local varlab1 " (`varlab1')" }
		if !missing("`varlab2'") { local varlab2 " (`varlab2')" }
		disp _n "{txt}Outcome variable: {res}`depvar'{txt}`varlab1'"
		disp "{txt} denominator: {res}`denom'{txt}`varlab2', n={res}`e(N)'"
	}
	else {
		local varlab: variable label `e(depvar)'
		if !missing("`varlab'") { local varlab "(`varlab')" }
		disp _n "{txt}Outcome variable: {res}`e(depvar)'{txt} `varlab', n={res}`e(N)'"
	}
	if missing("`delimit'") {
		global RE_delim "  "
	}
	else {
		global RE_delim "`delimit'"
	}
	local dl = !missing(trim("$RE_delim"))  /* delim flag */
	local i=1
	if `dl' {
		local titl Covariate
	}
	else {
		local titl "{txt}{lalign $RE_dlen:Covariate}"	       /* title text */
	}
	local wdt=$RE_dlen	/* width of title */
	local lrp 0	/* column in which LR P-value to appear */
	while `i'<=length("`output'") {
		local titl "`titl'$RE_delim"
		local wdt=`wdt'+length("$RE_delim")
		local outp=substr("`output'",`i',1)
		if "`outp'"=="n" {
			if `dl' {
				local titl "`titl'N"
			}
			else {
				local titl "`titl'{ralign 8:N}"
			}
			local wdt=`wdt'+8
		}
		else if "`outp'"=="e" {
			if `dl' {
				local titl "`titl'`estitle'"
			}
			else {
				local titl "`titl'{ralign 10:`estitle'}"
			}
			local wdt=`wdt'+10
		}
		else if "`outp'"=="s" {
			if `dl' {
				local titl "`titl'Std. Err."
			}
			else {
				local titl "`titl'{ralign 9:Std. Err.}"
			}
			local wdt=`wdt'+9
		}
		else if "`outp'"=="z" {
			if `dl' {
				local titl "`titl'`ztitle'"
			}
			else {
				local titl "`titl'{ralign 6:`ztitle'}"
			}
			local wdt=`wdt'+6
		}
		else if "`outp'"=="p" {
			if `dl' {
				local titl "`titl'`ptitle'"
			}
			else {
				local titl "`titl'{ralign 8:`ptitle'}"
			}
			local lrp=`wdt'+1
			local wdt=`wdt'+8
		}
		else if "`outp'"=="c" {
			if `dl' {
				local titl "`titl'`opbrack'$S_level% Conf. Interval`clbrack'"
			}
			else {
				local titl "`titl'{ralign 20:`opbrack'$S_level% Conf. Interval`clbrack'}"
			}
			local wdt=`wdt'+20
		}
		local i=`i'+1
	}
	if missing("`delimit'") {
		disp "{txt}{hline `wdt'}"
		disp "`titl'"
		disp "{txt}{hline `wdt'}"
	}
	else {
		disp "`titl'"
	}

	************************************************************
	***			 MAIN LOOP			 ***
	************************************************************
	local ovstub				/* remember last vstub processed */
	local basedi 0
	tokenize `varlist'
	while !missing("`1'") {
		local mult 1
		cap confirm variable `1'	/* don't report cut points etc. */
		if _rc == 0 | ("`1'" == "_cons" & "`cons'"!="nocons") {
			* Variable description for _I type categorical variables
			if substr("`1'",1,length("`prefix'"))=="`prefix'" {
				local vstub: char `1'[vstub]
				cap local vstub2: char `2'[vstub]
				if "`vstub'"!="`ovstub'" {			/* first time round for this vstub */
					* Display variable description [& LR p-val]
					dispvd `1' `lrp' `lrc' `lrtest' `output'
					local ovstub `vstub'
					local basedi 0			/* Reset 'displayed baseline group?' flag */
				}
				* Need beta multiplier for interaction term?
				cap local var2: char `1'[var2]
				cap local mult: char `var2'[mlt]
				if missing("`mult'") { local mult 1 }
				* Display baseline group?
				* Yes if baseline is less than current group or at last group in current variable
				cap local basel : char `1'[bascat]
				if !missing("`basel'") & !`basedi' {
					local varval : char `1'[cat]
					local vtype : char `1'[type]
					if "`vtype'"=="str" {
						* string term
						if "`basel'"<"`varval'" {
							local basedi 1		/* print baseline immediately */
						}
						else if "`vstub'" != "`vstub2'" {
							local basedi 2		/* print baseline straight after this one */
						}
						if `basedi' {
							/* prepare baseline group data */
							local bdesc: char `1'[basvl]
							if index("`output'","n") {
								qui count if `vstub'=="`basel'" & e(sample)
								local bnval = r(N)
							}
							else {
								local bnval -1
							}
							* Display baseline before current term?
							if `basedi'==1 {
								displi "  `bdesc'" `bnval' `nfmt' `estbase' . . . . . `output' 1
								local basedi 4  	/* baseline has been displayed */
							}
						}
					}
					else {
						* numeric term
						if `basel'<`varval' {
							local basedi 1		/* print baseline immediately */
						}
						else if "`vstub'" != "`vstub2'" {
							local basedi 2		/* print baseline straight after this one */
						}
						if `basedi' {
							/* prepare baseline group data */
							local bdesc: char `1'[basvl]
							if index("`output'","n") {
								qui count if `vstub'==`basel' & e(sample)
								local bnval = r(N)
							}
							else {
								local bnval -1
							}
							* Display baseline before current term?
							if `basedi'==1 {
								displi "  `bdesc'" `bnval' `nfmt' `estbase' . . . . . `output' 1
								local basedi 4  	/* baseline has been displayed */
							}
						}
					}
				}
			}	/* end variable description for _I type variable */
			else if "`1'" != "_cons" {
				* Variable description for non _I (usually continuous) variables
				dispvd `1' `lrp' `lrc' `lrtest' `output'
				local mult: char `1'[mlt]
			}
			* Description of term
			if "`1'" == "_cons" {
				local desc "Constant"
			}
			else {
				local desc: char `1'[vallab]
				local desc "  `desc'"
			}
			* Coefficients, standard errors, Z-vals and CIs
			if !missing("`meq'") {
				gettoken eqn rn:rn
			}
			else {
				local eqn `1'
			}
			cap disp _b[`eqn']			/* check estimate exists */
			if _rc | _b[`eqn'] == 0 {
				displi "`desc'" . . (dropped) . . . . . `output' 2
			}
			else {
				/* estimate does exist */
				if index("`output'","n") {
					if "`1'"=="_cons" {
						local nval `e(N)'
					}
					else {
						local nval: char `1'[nobs]
					}
				}
				else {
					local nval .
				}
				local coef = `estfn'(_b[`eqn']*`mult')
				if _se[`eqn']==0 {
					local stderr .
				}
				else {
					if !missing("`eform'") {
						local stderr = exp(_b[`eqn']*`mult')*_se[`eqn']*`mult'
					}
					else {
						local stderr = _se[`eqn']*`mult'
					}
				}
				local z = _b[`eqn']/_se[`eqn']
				local pval = tprob(`df',abs(_b[`eqn']/_se[`eqn']))
				if _se[`eqn']==0 {
					local cilo .
					local cihi .
				}
				else {
					local cilo = `estfn'(_b[`eqn']*`mult'-`zval'*_se[`eqn']*`mult')
					local cihi = `estfn'(_b[`eqn']*`mult'+`zval'*_se[`eqn']*`mult')
				}
				displi "`desc'" `nval' `nfmt' `coef' `stderr' `z' `pval' `cilo' `cihi' `output' 0 `lrtest'
			}	/* end if */
			if `basedi'==2 {
				* Display baseline group
				displi "  `bdesc'" `bnval' `nfmt' `estbase' . . . . . `output' 1
				local basedi 4
			}
		}    /* end if */
		mac shift
	}    /* end while */
	if missing("`delimit'") {
		disp "{txt}{hline `wdt'}"
	}
	if !missing("`ovstub'") {
		disp "{txt}* Baseline category"
	}
	if !missing("`lrtest'") {
		disp "{txt}^ From likelihood ratio test"
	}
	* Tidy up
	global RE_delim
	global RE_dlen
	global RE_dpp
	global RE_dpco
	global RE_to
	global RE_opbrack
	global RE_clbrack
	foreach term of local covl {
		cap confirm variable `term'
		if _rc == 0 {
			char `term'[vstub]
			char `term'[varlab]
			char `term'[vallab]
			char `term'[var2]
			char `term'[cat]
			char `term'[bascat]
			char `term'[basvl]
			char `term'[nobs]
			char `term'[mlt]
			char `term'[lrpval]
			char `term'[type]
		}
	}
end

program define dispvd		/* display variable description label */
	version 7
	args 1 lrp lrc lrtest output
	local varlab: char `1'[varlab]
	local vd = upper(substr("`varlab'",1,1))+substr("`varlab'",2,.)
	local dl = !missing(trim("$RE_delim"))  /* delim flag */
	if !`dl' {
		disp "{txt}`vd'{col `lrp'}" _c
	}
	else {
		disp "`vd'" _c
		if !missing("`lrtest'") & index("`output'","p") {
			disp "{dup `lrc':$RE_delim}" _c
		}
	}
	if !missing("`lrtest'") & index("`output'","p") {
		local p : char `1'[lrpval]
		local dppp1 = $RE_dpp + 1
		local ndi: display %`dppp1'.${RE_dpp}f `p'
		if real("`ndi'") == 0 {
			local ndi = "<" + substr(trim("`ndi'"),1,length(trim("`ndi'"))-1) + "1"
		}
		if `dl' {
			disp "`ndi'" _c
		}
		else {
			disp "{res}{ralign 8:`ndi'}" _c
		}
	}
	disp
end

* Display line of regression output
program define displi
	version 7
	args desc nval nfmt coef stderr z pval cilo cihi output basel lrtest
	* First show description
	local dppp1 = $RE_dpp + 1
	local dpcop1 = $RE_dpco + 1
	local dl = !missing(trim("$RE_delim"))  /* delim flag */
	if `basel'==1 {
		/* baseline group */
		local desc `"`desc'*"'
	}
	if `dl' {
		disp "`desc'" _c
	}
	else {
		disp "{txt}{lalign $RE_dlen:`desc'}" _c
	}
	local i 1
	while `i'<=length("`output'") {
		disp "$RE_delim" _c
		local outp=substr("`output'",`i',1)
		if "`outp'"=="n" {
			cap local ndi : display `nfmt' `nval'
			if `dl' {
				disp "`ndi'" _c
			}
			else {
				disp "{res}{ralign 8:`ndi'}" _c
			}
		}
		else if "`outp'"=="e" {
			cap local ndi : display %`dpcop1'.${RE_dpco}f `coef'
			if _rc { local ndi `coef' }
			if `basel' {
				local ndi `coef'
			}
			if `dl' {
				disp "`ndi'" _c
			}
			else {
				disp "{res}{ralign 10:`ndi'}" _c
			}
		}
		else if "`outp'"=="s" {
			if `basel' {
				local ndi
			}
			else {
				local ndi : display %`dpcop1'.${RE_dpco}f `stderr'
			}
			if `dl' {
				disp "`ndi'" _c
			}
			else {
				disp "{res}{ralign 9:`ndi'}" _c
			}
		}
		else if "`outp'"=="z" {
			if `basel' {
				local ndi
			}
			else {
				local ndi : display %`dpcop1'.${RE_dpco}f `z'
			}
			if `dl' {
				disp "`ndi'" _c
			}
			else {
				disp "{res}{ralign 6:`ndi'}" _c
			}
		}
		else if "`outp'"=="p" {
			if missing("`lrtest'") & !`basel' {
				local ndi : display %`dppp1'.${RE_dpp}f `pval'
				if real("`ndi'") == 0 {
					local ndi = "<" + substr(trim("`ndi'"),1,length(trim("`ndi'"))-1) + "1"
				}
			}
			else {
				local ndi
			}
			if `dl' {
				disp "`ndi'" _c
			}
			else {
				disp "{res}{ralign 8:`ndi'}" _c
			}
		}
		else if "`outp'"=="c" {
			if `basel' {
				local ndi
			}
			else {
				local chdi : display %`dpcop1'.${RE_dpco}f `cihi'
				local cldi : display %`dpcop1'.${RE_dpco}f `cilo'
				local ndi "$RE_opbrack`cldi'$RE_to`chdi'$RE_clbrack"
			}
			if `dl' {
				disp "`ndi'" _c
			}
			else {
				disp "{res}{ralign 20:`ndi'}" _c
			}
		}
		local i=`i'+1
	}
	disp
end
