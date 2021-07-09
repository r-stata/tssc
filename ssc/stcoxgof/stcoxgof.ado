*! version 2.0.1  17jul2008 
*! Goodness of Fit tests and Arjas plots after proportional hazards model
*! Syntax: . [, GRoup(integer 4-10) MOL(integer 2-10) MOLAT(numlist) MOM(2-10)
*!		MOMAT(numlist) POIdis ALTdef ARjas(integer 2-10) SEParate graph-options ]
program define stcoxgof, rclass
version 10
        syntax [, GRoup(numlist max=1 integer) POIdis MOL(integer 0) MOLAT(numlist ascending) ///
			MOM(integer 0) MOMAT(numlist ascending) ALTdef ARjas(integer 0) SEParate * ]
        st_is 2 analysis
        if "`e(cmd2)'" != "stcox"  error 301
	if `mol' != 0 | "`molat'" != "" | `mom' != 0 | "`momat'"!=""  local molm MOLM
	if "`molm'"=="" {
		if "`e(cmd2)'" == "stcox" & "`e(mgale)'" == ""  {
			display in smcl as err "{p}Martingale residuals must be saved in stcox " ///
				"to compute the added variable version of the Gronnesby and Borgan test or Arjas like plots.{p_end}"
			exit 198
		}
	}
	if "`molm'"!="" & `arjas' != 0 {
                 di in smcl as err "{p} options arjas() and mol(), molat(), mom(), momat() may not be combined.{p_end}"
                  exit  184
        }
	if "`group'" != "" & `arjas' != 0 {
                 di in smcl as err "{p}options arjas() and group() may not be combined.{p_end}"
                  exit 184
        }
	if `arjas' == 0 & "`group'" == ""{
                 local group = 	int(max(2,min(10,`e(N_fail)'/40))) /* optimal number of groups */
        }
	if `mol' > 10 {
                        di as err "mol() invalid"
                        exit 198
        }
	if `mom' > 10 {
                        di as err "mom() invalid"
                        exit 198
        }
	if `arjas'==0 {
		if "`options'" != "" { 
			di in smcl as err "{p}`options' invalid or you need to specify arjas(#) option, too.{p_end}"
			exit 198
		}
	}
	if "`molm'"!="" {
		if `mol'>0 local i = 1
		if `mom'>0 local i = `i' + 1
		if "`molat'"!="" local i = `i' + 1
		if "`momat'"!="" local i = `i' + 1
		if `i' > 1 {
			di in smcl as err "{p}Just one of the options mol(), molat(), mom() and momat() can be specified.{p_end}"
			exit 184
		}
	}
	preserve
	local id : char _dta[st_id]
*** Models for which added variables GOF tests are not allowed :
	* 1 Models with time-varying covariates
	if "`id'"!="" {
		cap bysort `_dta[st_id]' : assert _N==1
		if _rc {
			di in smcl as err "{p}Multiple records per subjects recognized. " ///
				"GOF tests are allowed for data with one record per subject.{p_end}"
			exit 321 
		}
	}
	* 2 Models with time-varying effects
	if "`e(texp)'"!=""{
			di in smcl as err "{p}GOF tests are allowed for model with no time-varying effects.{p_end}"
			exit 321
	}
	* 3 Models with frailty term
	if "`e(shared)'"!=""{
			di in smcl as err "{p}Previous model contains a frailty term." ///
				" GOF tests not allowed.{p_end}"
			exit 321
	}
	if "`molm'" != "" {
		if `"`_dta[st_id]'"' == "" {
*			di in smcl as err "{p}mol(), molat(), mom() and momat() option require that you have previously stset an id() variable.{p_end}"
*			exit 
			tempvar id
			g long `id' = _n
			qui streset, id(`id')
		}
	}
	local var  : colnames e(b)
	local nvar : word count `var'
	qui keep if e(sample)
	tempvar H d xb
	predict `xb',xb
	gen `d' = _d
	if "`molm'"==""	 predict `H',csn
	if "`_dta[__xi__Vars__To__Drop__]'"!="" {
		foreach i in `_dta[__xi__Vars__To__Drop__]' {
			cap rename `i' _`i'
			if !_rc local var :  subinstr local var `"`i'"' `"_`i'"' , word
		}
	}
        if `arjas'==0 {
		if `mom'==0  & "`momat'"=="" {
			qui inspect `xb'
			if `group'>`r(N_unique)' {
				di in smcl as txt _n "{p}(There are only 8 distinct quantiles of risk because of number of covariate patterns).{p_end}"
				local group = `r(N_unique)'
			}
		}
		if `group' > 10 {
                        di in re "group() invalid"
                        exit 198
		}
		tempvar dec z p num pp dc
/*		
		if "`altdef'" != "" {
			sort `xb' _t
			g `dec' = group(`group')
		}
		else ...
*/
		xtile `dec' = `xb' , nq(`group') 
		if "`e(strata)'" != "" {
			local strata strata(`e(strata)')
		}
		if "`e(offset)'" != "" {
			local offset offset(`e(offset)')
		}
		tempname lik0 est
		scalar `lik0' = `e(ll)'
		_estimates hold `est'
**********MOL test
		if "`molat'" != "" | `mol'>0 	tempvar mol_gr timsp
		if "`molat'" != ""	qui stsplit `timsp', at(`molat')
		if `mol' > 0 {
			qui {
				xtile `mol_gr' = _t , nq(`mol') // if _d==1 
				local i = 1
				while `i'<`mol'{
					g `timsp'=_t if `mol_gr'==`i'
					gsort -`timsp'
					local sp = `timsp'[1]
					local split "`split' `sp'"
					drop `timsp'
					local i = `i' + 1
				}
				drop `mol_gr'
				local split : list uniq split
				stsplit `timsp', at(`split')
			}
		}
		if "`molat'" != "" | `mol'>0 {
			qui {
				tab `timsp', gen(`mol_gr')
				g `mol_gr'=.
				forval i = 1/`r(r)' {
					replace `mol_gr'=`i' if `mol_gr'`i'==1
				}
				if "`molat'" != "" {
					su `mol_gr', meanonly
					local mol = `r(max)'
				}
				forval i = 2/`group' {
					forval m = 2/`mol'{
						tempvar k`m'j`i'
						g byte `k`m'j`i'' = `mol_gr'==`m' & `dec'==`i'
						local intvar `"`intvar' `k`m'j`i''"'
					}
				}
				xi: stcox `var' i.`dec' `intvar', `strata' `offset' 
				xi: scoretest_cox i.`dec' `intvar'
				return scalar df   = `r(df)'
				return scalar p    = `r(p)'
				return scalar chi2 = `r(chi2)'
				local molvar  : colnames e(b)
				local mvar : word count `molvar'
			}
			if `nvar' + return(df) != `mvar' {
				di in smcl as err "{p}Cannot fit a Cox model with `var' + `return(df)' cross-product variables of" /// 
				" quantiles of risk and time intervals.{p_end}"
				_estimates unhold `est'
				exit 198
			}
			ret scalar lrchi2 = 2*(`e(ll)' - `lik0')
			ret scalar lrp    = chiprob(return(df), return(lrchi2))
			di in gr _n "Goodness-of-fit test for the inclusion of design" /*
				*/ " variables" _n "based on " in ye return(df) in gr " cross-products of" /*
                                */ " quantiles of risk and time intervals"
			di in gr "(Added variables version of the Moreau, O'Quigley and Lellouch test)"	_n		
			di in gr "Score test" _col(56)  /*
			*/ "chi2(" in ye return(df) in gr ")" /*
				*/ _col(68) "=" in ye %10.3f return(chi2)
			di _col(56) in gr "Prob > chi2 = " in ye %9.4f r(p) _n
	      		drop `_dta[__xi__Vars__To__Drop__]'
			di in gr _n "Likelihood-ratio test" _col(56)  /*
				*/ "LR chi2(" in ye return(df) in gr ")" /*
				*/ _col(68) "=" in ye %10.3f return(lrchi2)
			di _col(56) in gr "Prob > chi2 = " in ye %9.4f return(lrp) _n
			_estimates unhold `est'
			exit
		}
**********MOM test
		if "`momat'"!="" | `mom'>0  	tempvar mom_gr timsp
		if "`momat'" !=""		qui stsplit `timsp', at(`momat')
		if `mom' > 0 {
			qui {
				xtile `mom_gr' = _t if _d==1, nq(`mom') 
				local i = 1
				while `i'<`mom'{
					g `timsp'=_t if `mom_gr'==`i'
					gsort -`timsp'
					local sp = `timsp'[1]
					local split "`split' `sp'"
					drop `timsp'
					local i = `i' + 1
				}
				drop `mom_gr'
				local split : list uniq split
				stsplit `timsp', at(`split')
			}
		}
		if "`momat'"!="" | `mom'>0 {
			qui {
				tab `timsp', gen(`mom_gr')
				g `mom_gr'=.
				forval i = 1/`r(r)' {
					replace `mom_gr'=`i' if `mom_gr'`i'==1
				}
				if "`momat'" != "" {
					su `mom_gr',meanonly
					local mom = `r(max)'
				}	
				foreach tvar of varlist `var'{
					capture assert `tvar' == int(`tvar')  
					if _rc { 
						di as err "`tvar' contains non-integer values. MOM test is appropriate for categorical variables" 
					exit 459
					} 
					local i = 1
					forval m = 2/`mom'{
						tempvar k`m'j`i'
						g byte `k`m'j`i'' = `mom_gr'==`m' * `tvar'
						local intvar `"`intvar' `k`m'j`i''"'
						local i = `i' + 1
					}
				}
				xi: stcox `var' `intvar',  `strata' `offset' 
				scoretest_cox `intvar'
				return scalar df   = `r(df)'
				return scalar p    = `r(p)'
				return scalar chi2 = `r(chi2)'
				local molvar  : colnames e(b)
				local mvar : word count `molvar'
			}
			if `nvar' + return(df) != `mvar' {
				di in smcl as err "{p}Cannot fit a Cox model with `var' + `return(df)' cross-product variables of"  /// 
					" quantiles of risk and time intervals.{p_end}"
				_estimates unhold `est'
				exit 198
			}
			ret scalar lrchi2 = 2*(`e(ll)' - `lik0')
			ret scalar lrp    = chiprob(return(df), return(lrchi2))
			di in gr _n "Goodness-of-fit test for the inclusion of design" /*
				*/ " variables" _n "based on " in ye return(df) in gr " cross-products of" /*
					*/ " cavariates and time intervals"
			di in gr "(Added variables version of the Moreau, O'Quigley and Mesbah test)" _n			
			di in gr "Score test" _col(56)  /*
			*/ "chi2(" in ye return(df) in gr ")" /*
				*/ _col(68) "=" in ye %10.3f return(chi2)
			di _col(56) in gr "Prob > chi2 = " in ye %9.4f r(p) _n
			di in gr _n "Likelihood-ratio test" _col(56)  /*
				*/ "LR chi2(" in ye return(df) in gr ")" /*
				*/ _col(68) "=" in ye %10.3f return(lrchi2)
			di _col(56) in gr "Prob > chi2 = " in ye %9.4f return(lrp) _n
      			_estimates unhold `est'
			exit
		}
**********GB test
		qui xi: stcox `var' i.`dec',  `strata' `offset'
		qui xi: scoretest_cox i.`dec'
		return scalar df   = `r(df)'
		return scalar p    = `r(p)'
		return scalar chi2 = `r(chi2)'
		local molvar  : colnames e(b)
		local mvar : word count `molvar'
		if `nvar' + return(df) != `mvar' {
                        di as err "Cannot fit a Cox model with `var' + `group' variables of" _n /// 
                                "quantiles of risk"
			exit 198
		}
		ret scalar lrchi2 = 2*(`e(ll)' - `lik0')
		ret scalar lrp    = chiprob(return(df), return(lrchi2))
		di in gr _n "Goodness-of-fit test for the inclusion of design" /*
			*/ " variables based on " in ye `group' in gr " quantiles of risk" 
		di in gr "(Added variables version of the Groennesby and Borgan test)"	_n		
		di in gr "Score test" _col(56)  /*
			*/ "chi2(" in ye return(df) in gr ")" /*
				*/ _col(68) "=" in ye %10.3f return(chi2)
			di _col(56) in gr "Prob > chi2 = " in ye %9.4f r(p) _n
	      		drop `_dta[__xi__Vars__To__Drop__]'
		di in gr _n "Likelihood-ratio test" _col(56)  /*
			*/ "LR chi2(" in ye return(df) in gr ")" /*
			*/ _col(68) "=" in ye %10.3f return(lrchi2)
		di _col(56) in gr "Prob > chi2 = " in ye %9.4f return(lrp) _n
		_estimates unhold `est'
		qui {
			collapse (sum) `H' `d' (count) `num'=`d', by(`dec')
			gen `z' = (`d' - `H')/sqrt(`H')
			gen `p' = (1 - normprob(abs(`z')))*2
			if "`poidis'"!=""{
				/* Cumulative Poisson evaluated by the cumulative Gamma function (observed, expected)
				   Note that two tails probabilities are obtained by adding the probability to observe 
				   (observed-1,expected) if d<H and (observed+1,expected) if d>H */
				g `pp' =	min(1,(1-gammap(`d'+1,`H')) + (1-gammap(`d',`H'))) if `d'<`H' & `d'!=0
* If 0 events in risk group :   replace `pp' =  min(1,(1-gammap(`d'+1,`H')) + exp(-`H')) if `d'==0
				replace `pp' =  min(1,gammap(`d',`H') + gammap(`d'+1,`H')) if `d'>=`H'
			}
			tot `d' `H' `num'
			replace `H' = round(`H',.001)
			count
		}
		di as res `"(Table  collapsed on quantiles of linear predictor)"'
		if r(N) < `group' + 1 {
			        di as text _n "Note: Because of ties, there " /*
				*/ "are only " `r(N)'-1 " distinct quantiles."
				local group = `r(N)' - 1
		}
		label var `dec' "Quantile of Risk"
		label var `d' "Observed"
		label var `H' "Expected"
		label var `z' "z"
		label var `p' " p-Norm"
		label var `num' "Observations"
		if "`poidis'"!=""{
			label var `pp' "p-Poisson"
			qui{
				replace `p'=round(`p',.001)
				replace `pp'=round(`pp',.001)
			}
			tabdisp `dec',cell(`d' `H' `p' `pp' `num') total center
		}
		else {
			qui {
				replace `p'=round(`p',.001)
				replace `z'=round(`z',.001)
			}
			tabdisp `dec',cell(`d' `H' `z' `p' `num') total /*
				*/ format(%9.0g) center
		}
		exit
         }

*****Arjas like plots
	  if `arjas'<2 | `arjas'>10 {
                di in red "arjas() invalid"
                    exit 198
         }
	 tempvar quant H_qu def_qu up_sc
         xtile `quant' = `xb',nq(`arjas')
	 label var `quant' "`arjas' quantiles of linear predictor" 
         sort `quant' `xb'
         qui {
              by `quant': gen double `H_qu' = sum(`H')
              by `quant': gen `def_qu' = sum(`d')
              keep if `d'==1
	      format `H_qu' %7.1f
	      inspect `quant'
         }
         if r(N_unique) < `arjas'{
                     di in red _n "Because of ties, there aren't " /*
                    */ `arjas' " quantiles of risk."
                  exit
         }
         label var `def_qu' "Observed counts"
         label var `H_qu'   "Expected counts"

	 _get_gropts , graphopts(`options') getallowed(SAving scheme legend)
	 
	local options `"`s(graphopts)'"'
	local saving `"`s(saving)'"'
	local scheme `"`s(scheme)'"'
	local legend `"`s(legend)'"'
	if "`scheme'" != "" local scheme `"scheme(`scheme')"'
	if `"`legend'"' != "" local legend `"legend(`legend')"'
        if "`separate'" != "" {
		if "`saving'" != "" {
			local j = index("`saving'",",")
			if `j' {
				local filnam = substr("`saving'",1,`j'-1)
				local rest = substr("`saving'",`j',8)
			}
			else {
				local filnam `saving'
				local rest 
			}
		}
                forval i = 1(1)`arjas' {
                        if "`saving'" != "" {
                                local sav saving(`filnam'`i'`rest')
                        }
			if "`options'" == ""  {
				local opt `"t1ti("Arjas like Plots" "`i' Quantile of Risk")"'
				local opt `"`opt' yla(,angle(0)) yvarformat(%8.1f) lp(l dash) lw(medthick medium)"'
			}
			version 8: graph twoway		///
			(line `H_qu' `def_qu' `def_qu'  ///
				if `quant'==`i',        ///
				`legend' `opt' `sav' `scheme')	
			if `i' < `arjas' more
                }
                if "`saving'" != "" {
                        di _n as res "{p 4}Plots have been saved as `filnam'1 - `filnam'`arjas' .gph files.{p_end}"
                }
         }

         else {
 		if "`options'" ==""  {
			local options `"yla(,angle(0)) yvarformat(%8.1f) lp(l dash) lw(medthick medium)"'
		}
		if "`saving'" != "" local saving `"saving(`saving')"'
		version 8: graph twoway			///
		(line `H_qu' `def_qu' `def_qu',		///
			by(`quant', t1ti("Arjas like Plots") rescale )	`legend' /// 
				 `options' `saving' `scheme')	
         }
end

program define tot
                tempvar tot
                gen `tot' = 0
                local nm = _N + 1
                set obs `nm'
                while "`1'"!=""{
                        replace `tot'=sum(`1')
                        replace `1' = `tot' if _n==_N
                        macro shift
                }
end

exit

