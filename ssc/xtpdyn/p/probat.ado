*! probat 2.0.0 28may2018  Raffaele Grotti & Giorgio Cutuli

program probat, rclass sortpreserve
	version 13
	syntax, [stats STATS2(string) | PRDistr] [MArgins(string)] ///
		[Nq(numlist integer max=1)] [SHOWFreq] [plot] [keep]
qui {
	
	local permanent "`keep'"
	
	if "`e(uh)'"=="" {
		dis as error "last estimates not found"
		exit 301
	}

	if "`stats'`stats2'`prdistr'" == "" {
		noi display "{err} either stats[(atspec)] or prdistr must be specified"
		exit 1003
	}
		
	if "`prdistr'"!="" & "`stats'`stats2'"!="" {
		noi display "{err} either stats() or prdistr can be specified"
		exit 1003
	}

	if "`prdistr'"=="" {
		if "`nq'"!="" | "`plot'"!="" | "`showfreq'"!="" | "`permanent'"!="" {
			noi display "{err} you have specified one or more options that are not allowed with stats()"
			exit 198
		}
	}
	else {	
		if "`nq'"!="" {
			if !inlist(`nq', 2, 3, 4, 5, 10) {
				noi display "{err} nq() must be one of the list 2, 3, 4, 5, 10"
				exit 198
			}
		}
		if "`permanent'"!="" {
			capture sum uh_q, meanonly
			if _rc==0 {
				dis as error "variables uhi and/or uh_q already define"
				exit 110
			}
		}
	}
	
		xtset
		local panelvar `r(panelvar)'
		local timevar `r(timevar)'
		local if `e(if)'
		local vt "`e(varlist)'"
		local avg "`e(uh)'"

		tempvar touse
		mark `touse' `if'
		markout `touse' `vt'

		fvrevar `avg' if `touse', list
		local nfi "`r(varlist)'"
		local fvni : list nfi - avg			
		local nfv : list nfi - fvni	

		fvexpand `avg' if `touse'
		local fv  "`r(varlist)'"
		local fv :  list fv - nfv

		foreach wrd of local fv {
			if strpos("`wrd'", "b.") != 0 local vlbase `vlbase' `wrd'
			if strpos("`wrd'", "b.") == 0 local vlrest `vlrest' `wrd'
		}

		local var_to_mean "`vlrest' `nfv'"
		local var_to_initial "`vlbase' `nfv'"

		local dv "`e(depvar)'"
		capture sum `dv'__0, meanonly
		local perm = _rc

		foreach var of local vlrest {
			tokenize "`var'", parse(".")
			if `perm'!=0 {
				bys `touse' `panelvar': gen m`1'__`3' = sum(`var')/sum((`var'<.)) if `touse'
				bys `touse' `panelvar': replace m`1'__`3' = m`1'__`3'[_N] if `touse'
				lab var m`1'__`3' "Time average of `3'=`1'"
			}
			local meantv `meantv' m`1'__`3'
		}
		foreach var of local nfv {
			if `perm'!=0 {
				bys `touse' `panelvar': gen m__`var' = sum(`var')/sum((`var'<.)) if `touse'
				bys `touse' `panelvar': replace m__`var' = m__`var'[_N] if `touse'
				lab var m__`var' "Time average of `var'"
			}
			local meantv `meantv' m__`var'
		}
		
		local bl "`vlbase'"
		foreach var of local fvni {
			if `perm'!=0 {
				bys `touse' `panelvar' (`timevar'): gen byte `var'__0 = `var'[1] if `touse' & `touse'[1]==1	
			}
			local initialv `initialv' `var'__0	
			
			gettoken bc bl : bl 
			gettoken bc : bc ,parse("b.")
			dis "`bc'"
			local initial `initial' ib`bc'.`var'__0
			capture lab var `var'__0 "Initial period of `var'"
		}
		
		foreach var of local nfv {
			if `perm'!=0 {
				bys `touse' `panelvar' (`timevar'): gen `var'__0 = `var'[1] if `touse'
				lab var `var'__0 "Initial period of `var'"
			}
			local initial `initial' `var'__0
			local initialv `initialv' `var'__0
		}
		
		local depvar `e(depvar)'
		if `perm'!=0 {
			bys `touse' `panelvar' (`timevar'): gen byte `depvar'__0 = `depvar'[1] if `touse'
			lab var `depvar'__0 "Initial condition. `depvar' at time 0"
		}		
		
		local force "force"
		foreach mopti of local margins {
			if "`mopti'"=="nose" local nose "nose"
			if "`mopti'"=="force" local force ""
		}
		
		capture sum uh_q, meanonly
		if _rc==0 {
			drop uhi uh_q
			local permanent "permanent"
		}
		
		levelsof `depvar', local(depcat)
		
		if "`prdistr'"!="" & "`stats'`stats2'"=="" {
			
			bys `touse' `panelvar' (`timevar'): gen byte l__`depvar' = `depvar'[_n-1] if `timevar'==`timevar'[_n-1]+1 & `touse'
			lab var l__`depvar' "`depvar' at time t-1"
		
			xtset `panelvar' `timevar'

			fvexpand `e(initial)'
			local ini "`r(varlist)'"
			gen uhi = 0
			foreach var in `ini' `meantv' {
				replace  uhi = uhi + _b[`var']*`var'
			}
			replace uhi = . if !e(sample)
			lab var uhi "Unobserved Heterogeneity UHz"
			
			if "`nq'" == "" {
				local nq = 5
			}
			
			xtile byte uh_q = uhi, n(`nq')
			
			if "`showfreq'" != "" {
				noi dis "-> `depvar'__0 = 0"
				noi table l__`depvar' `depvar' uh_q if e(sample) & `depvar'__0==0, c(freq)
				noi dis ""
				noi dis "-> `depvar'__0 = 1"
				noi table l__`depvar' `depvar' uh_q if e(sample) & `depvar'__0==1, c(freq)
			}
			drop l__`depvar' 

			capture qui margins, at(L.`depvar'=(`depcat')) expression(normal(predict(xb))) ///
				over(`depvar'__0 uh_q) `force' `margins'
			
			if _rc!=0 {
				drop `meantv' `depvar'__0  `initialv'
				exit _rc
			}
			local proldrc = _rc
			
			if "`plot'"!="" {
				 capture marginsplot, xdim(uh_q) bydim(`depvar'__0) ///
					byopt(tit("Predicted probabilities of `depvar'")) ytit("Pr(`depvar' = 1)")
			}
			
			capture {
				mat rt = r(table)'
				local rd = `=rowsof(rt)'
				
				if "`nose'"=="" mat p = rt[1..`rd', 1..6 ]
				if "`nose'"=="nose" mat p = rt[1..`rd', 1]
				
				tempvar eslab proba
				gen `eslab' = . 
				gen `proba' = . 
				replace `eslab' = _n in 1/`rd'
				lab var `eslab' "L.`depvar'#`depvar'__0#uh_q"
				lab var `proba' "Prob."
				
				if "`nose'"=="" {
					tempvar ste z pvalue ll ul
					gen `ste' = .
					gen `z' = . 
					gen `pvalue' = . 
					gen `ll' = . 
					gen `ul' = . 
					lab var `ste' "Std. Err."
					lab var `ll' "Lower CI"
					lab var `ul' "Upper CI"
					lab var `pvalue' "P>|z|"
					lab var `z' "z"
				}
				
				forval nr = 1/`rd' {
					replace `proba' = p[`nr',1] in `nr'
					if "`nose'"=="" {
						replace `ste' = p[`nr',2] in `nr'
						replace `z' = p[`nr',3] in `nr'
						replace `pvalue' = p[`nr',4] in `nr'
						replace `ll' = p[`nr',5] in `nr'
						replace `ul' = p[`nr',6] in `nr'
					}
				}
				
				format %5.4f `proba'

				if "`nose'"=="" {
					format %5.4f `ll' `ul'
					format %7.6f `ste'
					format %5.2f `z' 
					format %4.3f `pvalue'
				}
				
				local l = 1
				foreach c1 of local depcat {
					foreach c2 of local depcat {
						forval c3 = 1/`nq' {
							lab def eslab `l' "`c1' `c2' `c3'", modify
							local ++l
						}
					}
				}
				
				lab val `eslab' eslab
				local sl `=strlen("L.`depvar'#`depvar'__0#uh_q")'
				if `sl'>25 local sl = 25 
				noi tabdisp `eslab' in 1/`rd', c(`proba' `ste' `pvalue' `ll' `ul') center stubwidth(`sl')
					
				tempvar eslabs
				decode `eslab' in 1/`rd', gen(`eslabs')
				mkmat `proba' `ste' `z' `pvalue' `ll' `ul' in 1/`rd', matrix(rt) rown(`eslabs')		
				label drop eslab
				
				if "`nose'"=="" matrix colnames rt = prob se z p-value ll ul 
				if "`nose'"=="nose" matrix colnames rt = prob
			
				return matrix probest rt

				if "`permanent'"=="" drop uh_q uhi 
				if `perm'!=0 drop `meantv' `depvar'__0  `initialv'
			}

			if "`proldrc'"!="" {
				exit `proldrc'
			}
		}
		else if "`prdistr'"=="" {
			xtset `panelvar' `timevar'
			if "`stats'"!=""  {
				
				capture margins, at(L.`depvar'=(`depcat')) expression(normal(predict(xb))) `force' `margins'
				if `perm'!=0 drop `meantv' `depvar'__0  `initialv' 
				
				if _rc!=0 {
					local oldrc = _rc
					exit `oldrc'
				}
			}
			else if "`stats2'"!="" {
			
				capture margins, ///
					at(L.`depvar'=(`depcat') `stats2') expression(normal(predict(xb))) `force' `margins'

				if `perm'!=0 drop `meantv' `depvar'__0  `initialv' 
				
				if _rc!=0 {
					local oldrc = _rc
					exit `oldrc'
				}
			}

			if "`nose'"=="nose" {
				
				mat p = r(table)'
				matrix rownames p = L.`depvar'=0 L.`depvar'=1 
				tempvar proba dip
				gen `dip' = 0 in 1
				replace `dip' = 1 in 2
				gen `proba' = .
				replace `proba' = p[1,1] in 1
				replace `proba' = p[2,1] in 2
			}
			else {
			
				mat rt = r(table)'
				mat p = rt[1..2, 1..6 ]

				tempvar proba ste z pvalue ll ul dip
				gen `dip' = 0 in 1
				replace `dip' = 1 in 2
				gen `proba' = .
				replace `proba' = p[1,1] in 1
				replace `proba' = p[2,1] in 2
				gen `ste' = .
				replace `ste' = p[1,2] in 1
				replace `ste' = p[2,2] in 2
				gen `z' = .
				replace `z' = p[1,3] in 1
				replace `z' = p[2,3] in 2
				gen `pvalue' = .		
				replace `pvalue' = p[1,4] in 1
				replace `pvalue' = p[2,4] in 2
				gen `ll' = .
				replace `ll' = p[1,5] in 1
				replace `ll' = p[2,5] in 2
				gen `ul' = .
				replace `ul' = p[1,6] in 1
				replace `ul' = p[2,6] in 2
				lab var `ste' "Std. Err."
				lab var `ll' "Lower CI"
				lab var `ul' "Upper CI"
				lab var `pvalue' "P>|z|"
				lab var `z' "z"
			}
			
			lab var `proba' "Prob."
			lab var `dip' "`depvar'"
			lab def dip 0"Pr(1|0)" 1"Pr(1|1)"
			lab val `dip' dip
			noi di as text "Probability for the profile chosen"
			local sl `=strlen("`depvar'")'
			if `sl'<10 local sl = 10
			noi tabdisp `dip' in 1/2, c(`proba' `ste' `pvalue' `ll' `ul')  f(%9.5f) center stubwidth(`sl')
			lab drop dip
			
			local probov = p[1,1]/[p[1,1]+(1-p[2,1])]
			local meandur = 1/(1-p[2,1])
			local exitprob = 1-p[2,1]
				
			tempvar addstat statsadd
			gen `addstat' = _n in 1/5
			lab var `addstat' "Additional statistics"
			lab def addstat_l 1"Entry probability P(1|0)" 2"Exit probability P(0|1)" ///
				3"Proportion of T in y=1/Steady state Pr." 4"Mean duration"
			lab val `addstat' addstat_l
			gen `statsadd' = p[1,1] in 1
			replace `statsadd' = `exitprob' in 2
			replace `statsadd' = `probov' in 3
			replace `statsadd' = `meandur' in 4
			lab var `statsadd' "   "
			noi tabdisp `addstat' in 1/4, c(`statsadd') f(%9.5f) center
			lab drop addstat_l
			
			return scalar meandur = `meandur'
			return scalar prop_t = `probov'
			return scalar exit_pr = `exitprob'
			return scalar entry_pr = p[1,1]
			return matrix probest p 
		}
}
end

