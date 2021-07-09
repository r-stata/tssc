*! stpepemori 1.0.3 EC 02 OCT 2010
*! Testing Cumulative Incidence and Conditional Probability

program define stpepemori, sortpreserve rclass
	version 9.0
	st_is 2 analysis
	syntax varname [if] [in] , COMPET(numlist missingokay) [ CONDitional ]
	marksample touse
	qui replace `touse' = 0 if _st==0
		/* it will need to restore existing if expression */
	local if_st "`_dta[st_ifexp]'" /* it will need to restore existing if expression */
	preserve
	qui keep if `touse'
	
*** 1 - Checks
		/* previous stset statement must be as required by stcompet */
	if "`_dta[st_bd]'"=="" | "`_dta[st_ev]'"=="" {   
	    di as err  "{p}failure variable must have been specified as failure(varname==numlist) " /*
        */ _n "on the stset command prior to using this command.{p_end}"
		exit 198
        }
	if `"`_dta[st_id]'"' != "" {
		cap bysort `_dta[st_id]' : assert _N==1
		if _rc {
			di as err  "stpepemori requires that the data are stset with only one observation per individual"
			exit 198
		}   
	}
		/* Test compares just two groups */
	tempvar bybin
	qui bysort `varlist' : g byte `bybin' = _n==1
	qui replace `bybin' = sum(`bybin') - 1
	if `bybin'[_N] != 1 {
		di as err "Pepe and Mori test compares the cumulative incidence of just two groups."
		exit 459
	}
		/* Competing and interest events must be different */
	local compet0 "`_dta[st_ev]'"   /* main event */ 
	local intlist : list compet0 & compet
	if "`intlist'" != "" {
		di as err "You specify `intlist' as codes for two competing events"
                  	exit 459
        }

	local orev "`_dta[st_bd]'"
	tempvar cens w_1 w_2 S_1 S_2 S_3 sigma1 sigma2 n0 n1 byuse 
	quietly {
*** 2 - Create -the appropriate censoring variable : 0 = Alive, 1 = Main event, 2 = Competing event -n_risk
*		g byte `cens' = (`_dta[st_bd]'==`compet0') + 2*(`_dta[st_bd]'==`compet')
		recode `_dta[st_bd]' (`compet0' = 1) (`compet' = 2), gen(`cens')
		streset, f(`cens' == 0 1 2)
		sts gen `n0' = n , by(`bybin')
		g long `n1' = `n0' if `bybin'==1
		replace `n0' = .   if `bybin'==1

*** 3 - Cumulative Incidence estimate and censoring distribution for event 1 and 2
		g byte `byuse' = 0 
		forval X = 0/1 {
			replace `byuse' = (`bybin'==`X')
			tempvar s_all`X' d`X' I`X'_1 I`X'_2 C`X'_1 C`X'_2 d`X'_1 d`X'_2
			streset if `byuse', f(`cens'== 1 2)
			sts gen `s_all`X'' = s  
			g byte  `d`X''   = _d
			replace `d`X''   = 0 if `d`X''==.
			g  double `I`X'_1' = .
			g  double `I`X'_2' = .
			g byte `d`X'_1' = .
			g byte `d`X'_2' = .
			/* compet compute cumulative incidence - It resets the code 
			   of the events in failvar */
			compet `byuse' `s_all`X'' `d`X'_1' `I`X'_1' , fail(1) 
			replace `d`X'_1'   = 0 if `d`X'_1'==.
			compet `byuse' `s_all`X'' `d`X'_2' `I`X'_2' , fail(2) 
			replace `d`X'_2'   = 0 if `d`X'_2'==.
			streset if `byuse', f(`cens'== 0 2)
			sts gen `C`X'_1' = s
			streset if `byuse', f(`cens'== 0 1)
			sts gen `C`X'_2' = s
			count if `byuse'
			local N`X' = `r(N)'
		}
*** 4 - Adapting basic quantities : Cum. Inc. , Cond. Prob. and Censoring Distrbution
		char _dta[st_ifexp] `if_st'
		streset, f(`cens'== 1 2)
		foreach var of varlist `I0_1' `I1_1' `I0_2' `I1_2' {
			sort _t `var'
			replace `var' = 0 if _n == 1  & `var'== .
			replace `var' = `var'[_n-1] if `var'== . & _n > 1 
		}	
		foreach var of varlist `C0_1' `C1_1' `C0_2' `C1_2' `s_all0' `s_all1' {
			sort _t `var'
			replace `var' = 1 if _n == 1  & `var'== .
			replace `var' = `var'[_n-1] if `var'== . & _n > 1 
		}
		if "`conditional'" != "" {
			tempvar CP0_1 CP0_2 CP1_1 CP1_2
			g  double `CP0_1' = `I0_1' / (1 - `I0_2') 
			g  double `CP0_2' = `I0_2' / (1 - `I0_1') 
			g  double `CP1_1' = `I1_1' / (1 - `I1_2') 
			g  double `CP1_2' = `I1_2' / (1 - `I1_1') 
		}

		/* Max time at the minimun last time between groups */
		su _t if !`bybin', meanonly
		local tau = `r(max)'
		su _t if `bybin', meanonly
		local tau = min(`r(max)',`tau')
		keep if _t <= `tau'
					
		collapse `I0_1' `I1_1' `I0_2' `I1_2' `C0_1' `C1_1' `C0_2' `C1_2' `CP0_1' `CP0_2' `CP1_1' `CP1_2' `s_all0' `s_all1'  ///
			`n0' `n1' (sum) `d0' `d0_1' `d0_2' `d1' `d1_1' `d1_2', by(_t) fast

*** 5 - Weights and cumulative weighted differences
		g `w_1' = cond(_n>1,((`N0'+`N1')*`C0_1'[_n-1]*`C1_1'[_n-1]) / (`N0'*`C0_1'[_n-1] + `N1'*`C1_1'[_n-1]),1) 
		g `w_2' = cond(_n>1,((`N0'+`N1')*`C0_2'[_n-1]*`C1_2'[_n-1]) / (`N0'*`C0_2'[_n-1] + `N1'*`C1_2'[_n-1]),1) 
		if "`conditional'" == "" {
			g `S_1' = sum((`I0_1'-`I1_1') * `w_1' * (_t[_n+1] - _t[_n]) ) 
			g `S_2' = sum((`I0_2'-`I1_2') * `w_2' * (_t[_n+1] - _t[_n]) ) 
		}
		else {
			g `S_1' = sum((`CP0_1'-`CP1_1') * `w_1' * (_t[_n+1] - _t[_n]) ) 
			g `S_2' = sum((`CP0_2'-`CP1_2') * `w_2' * (_t[_n+1] - _t[_n]) ) 
		}
		local s1 = (sqrt(`N0'*`N1'/(`N0'+`N1')) * `S_1'[_N] )^2
		local s2 = (sqrt(`N0'*`N1'/(`N0'+`N1')) * `S_2'[_N] )^2
		sort _t 
		replace `n0' = `n0'[_n-1] - `d0'[_n-1] if `n0'==. 
		replace `n1' = `n1'[_n-1] - `d1'[_n-1] if `n1'==. 
*** 6 - Variance
		forval i = 1/2 {
* Group 1
			if `i' == 1 local cmp = 2
			else        local cmp = 1
			if "`conditional'" == "" {
				replace `S_1' = sum(`w_`i''*(_t[_n+1] - _t[_n])*(1-`I0_`i''))  
				su `S_1' , meanonly
				replace `S_1' = `r(max)' - `S_1' +  `w_`i''*(_t[_n+1] - _t[_n])*(1-`I0_`i'')	// nu_1
				replace `S_2' = sum(`w_`i''*(_t[_n+1] - _t[_n]))  
				su `S_2' , meanonly
				replace `S_2' = `r(max)' - `S_2' +  `w_`i''*(_t[_n+1] - _t[_n])			// nu_2
				g `S_3' = sum(`w_`i''*(_t[_n+1] - _t[_n])*`I0_`i'')
				su `S_3' , meanonly
				replace `S_3' = `r(max)' - `S_3' +  `w_`i''*(_t[_n+1] - _t[_n])*`I0_`i''	
				g `sigma1'    = ((`S_1' - `I0_`cmp''*`S_2')^2 * `d0_`i'' + `S_3'^2*(`d0' - `d0_`i'')) / (`n0'*(`n0'-1))
				su `sigma1',meanonly
			}
			else {
				replace `S_1' = sum(`w_`i''*(_t[_n+1]-_t[_n])*`s_all0'/(1-`I0_`cmp'')^2)  
				su `S_1' , meanonly
				replace `S_1' = `r(max)' - `S_1' +  `w_`i''*(_t[_n+1]-_t[_n])*`s_all0'/(1-`I0_`cmp'')^2	
				g `sigma1' = `S_1'^2*((1-`I0_`cmp'')^2 *`d0_`i''+(`d0'-`d0_`i'')*`I0_`i''^2) / (`n0'*(`n0'-1))
				su `sigma1',meanonly
			}
			local var1_1 = `r(sum)'
* Group 2
			if "`conditional'" == "" {
				replace `S_1' = sum(`w_`i''*(_t[_n+1] - _t[_n])*(1-`I1_`i''))     		
				su `S_1' , meanonly
				replace `S_1' = `r(max)' - `S_1' +  `w_`i''*(_t[_n+1] - _t[_n])*(1-`I1_`i'')	
				replace `S_2' = sum(`w_`i''*(_t[_n+1] - _t[_n]))	 	
				su `S_2' , meanonly
				replace `S_2' = `r(max)' - `S_2' +  `w_`i''*(_t[_n+1] - _t[_n])			
				replace `S_3' = sum(`w_`i''*(_t[_n+1] - _t[_n])*`I1_`i'') 
				su `S_3' , meanonly
				replace `S_3' = `r(max)' - `S_3' +  `w_`i''*(_t[_n+1] - _t[_n])*`I1_`i''	
				g `sigma2'    = ((`S_1' - `I1_`cmp''*`S_2')^2 * `d1_`i'' + `S_3'^2*(`d1' - `d1_`i'')) / (`n1'*(`n1'-1))    
				su `sigma2',meanonly
				drop `S_3' 
			}
			else {
				replace `S_1' = sum(`w_`i''*(_t[_n+1]-_t[_n])*`s_all1'/(1-`I1_`cmp'')^2)  
				su `S_1' , meanonly
				replace `S_1' = `r(max)' - `S_1' +  `w_`i''*(_t[_n+1]-_t[_n])*`s_all1'/(1-`I1_`cmp'')^2	
				g `sigma2' = `S_1'^2*((1-`I1_`cmp'')^2 *`d1_`i''+(`d1'-`d1_`i'')*`I1_`i''^2) / (`n1'*(`n1'-1))  
				su `sigma2',meanonly
			}
			local var1_2 = `r(sum)'
			local var1 = (`N0'*`N1'*(`var1_1' + `var1_2')) / (`N0' + `N1')
			local z`i' = `s`i'' / `var1'
			local p`i' = chiprob(1,`z`i'')
			drop `sigma1' `sigma2'
		}
	}
*** 7 - Show and return results for two types of event
	local tst "cumulative incidence"
	if "`conditional'" != "" local tst "conditional probability"
	ret scalar r1    = `z1'
	ret scalar r2    = `z2'
	ret scalar p1    = `p1'
	ret scalar p2    = `p2'
	local rnd1 "0000"
	local rnd2 "0000"

	foreach i of numlist 1 10 100 1000 10000{
		if `z1' > `i' local rnd1 = substr("`rnd1'",2,.)
		if `z2' > `i' local rnd2 = substr("`rnd2'",2,.)
	}
	foreach i in p1 p2 {
		local eq`i' "= "
		if ``i'' < 0.00001 {
			local `i' ".00001"
			local eq`i' "< "
		}
		else	local `i' = round(``i'',.00001)
	}
	di _n(2) in smcl in gr `"{title:Pepe and Mori test comparing the `tst' of two groups of `varlist'}"'
*	di as res "Pepe and Mori test comparing the `tst' of two groups of `varlist' "
	di _n in gr "     Main event failure:  " in ye "`orev' == `compet0'"
	di in gr "Chi2(1) = " in ye round(`z1',.`rnd1'1)  in gr "  -  p `eqp1' "  in ye "0" `p1'
	di
	di in gr "Competing event failure:  " in ye "`orev' == `compet'"
	di in gr "Chi2(1) = " in ye round(`z2',.`rnd2'1)  in gr "  -  p `eqp2' "  in ye "0" `p2'
end


program define compet    /* Compute Crude Cumulative Incidence */ 
	version 9
	syntax varlist, fail(numlist missingokay) 
	gettoken byuse varlist : varlist
	gettoken all_surv varlist : varlist
	gettoken d varlist : varlist
	tempvar h_comp is_even all_comp
        gen byte `is_even' = 0
        replace `is_even' = 1 if `_dta[st_bd]'==`fail' 
	if "`_dta[st_exit]'" != "" {
		replace `is_even'=0 if `_dta[st_bt]' > `_dta[st_exexp]' & `byuse'
	}
	count if `is_even'
	if `r(N)'== 0 {
		exit
	}
	streset if `byuse', f(`_dta[st_bd]'==`fail')
	replace `d' = _d 
	sts gen `h_comp' = h
	bysort `all_surv' (`is_even') : gen double `all_comp' = `all_surv' if _n==_N 
	replace `h_comp' = . if `all_comp' == .
	gsort -`all_comp'
	replace `varlist' = cond(_n!=1,`h_comp' * `all_comp'[_n-1],`h_comp')
        gsort -`byuse' _t `varlist'
	replace `varlist' = sum(`varlist') if `is_even' & `byuse'
end
