*! version 1.2.5    25jun2006       C F Baum/V Wiggins
*  Implement Robinson Log-Periodogram Regression, Annals of Statistics 1995
*  for univariate and multivariate cases
*  1.2.0: modified output, handles multiple powers for single var, constraints
*  1.2.1: published STB-57
*  1.2.2: trap j<1, add varname to output
*  1.2.3: observations miscounted when variables started at different periods
*  1.2.4: L option did not work with multiple variables
*  1.2.5: Stata 8 syntax, make byable(recall) and onepanel

program define roblpr, rclass  byable(recall) 
	version 8.2

	syntax varlist(ts) [if] [in] [ , Constraints(string) J(integer 1) /*
		*/ L(integer 0) Powers(string) REGRESSONLY ]  

	_rmcoll `varlist' `if'
	local varlist `r(varlist)'
	local orgvlst `varlist'
	tsrevar `varlist'
	local varlist `r(varlist)'

	local nrvars : word count `varlist'
	if `nrvars' == 1 & "`powers'" != "" {
		numlist "`powers'", range(>0 < 1)
		local powers `r(numlist)'
	}
	else if `nrvars' > 1 & "`powers'" != "" {
		capture numlist "`powers'", range(>0 < 1) min(1) max(1)
		if _rc {
			di in red "with multiple variables option "	/*
				*/ "powers(#) accepts only a single # and it"
			di in red "must be between 0 and 1"
			exit 198
		}
		local powers `r(numlist)'
	}
	else {
		local powers .9
	}
	if `j' < 1 {
		di in red "Error: j must be at least 1"
		exit 198
		}
	local powct : word count `powers'
	
   	marksample touse
   				/* get time variables; enable onepanel */
   	_ts timevar panelvar if `touse', sort onepanel
//	_ts timevar, sort
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}

	tempname xr xi n pg lpg ok vok vcv bs
	tempvar var vecy 
			 
	if `nrvars' != 1 | "`regressonly'" != "" {
		preserve
// for onepanel logic, drop unneeded obs.
		qui drop if `touse'==0		
		gen long `n' = sum(`touse')-1
		tokenize `varlist'
		local i 1
		local last 0
	 	/* ensure even number of ordinates */
		qui count if `touse'
		local em=int(r(N)^`powers')+1
		if mod(`em',2)!=0 {
			local em=`em'+1
		}
		/* calculate number of obs needed, adjust if necessary */
		local newobs = `em'*`nrvars'
		if `nrvars' > 1  {
			qui count
			if `newobs' > r(N) { 
				qui set obs `newobs' 
			} 
		}
		qui replace `touse'=0 if `touse'==.
		qui gen double `vecy' =.
		qui gen double `var'=.
		qui gen `ok'=_n
		local xlist "`vecy'"
* 1.2.4
		local sofar 1
		while `i'<=`nrvars' {
			local last=`last'+`em'
			local first=`last'-`em'+1
			local offset=(`i'-1)*`em'
			capt drop `xr' `xi' `lpg' 
			qui replace `var'=``i''
			fft `var' if `touse', gen(`xr' `xi') 
			if `j'==1 {
				qui gen double `lpg' = log((`xr'^2+`xi'^2)) if `touse'
			} 
			else {
				/* moving sum of periodogram over J elements */
				qui gen double `pg' = (`xr'^2+`xi'^2) if `touse'
				local ii=1
				qui gen double `lpg' = `pg'
				while `ii'<`j' {
					qui replace `lpg'=`lpg'+`pg'[_n-`ii']
					local ii=`ii'+1
					}
				qui replace `lpg'=log(`lpg')
				qui gen `vok'=(mod(_n,`j')==0)
				drop `pg'
			}
//          end else
			qui replace `vecy'=`lpg'[_n-`offset'] in `first'/`last'
			if `j'>1 {
				qui replace `ok'=`vok'[_n-`offset'] in `first'/`last'
				drop `vok'
				}
			tempvar llam iota
			qui gen double `llam'=0 in 1/`newobs'
			qui gen double `iota'=0 in 1/`newobs'
			qui replace `llam' = 2.0 * 			   /*
				*/ log( 2.0 * _pi*(`n'[_n-`offset'])/`em') /*
				*/ in `first'/`last'
			qui replace `iota' = 1.0 in `first'/`last'
			/* implement L option via iota; adjust by one 
			 * for zero freq, interact with J */
			if `l'>0 {
* 1.2.4
				local hi =`l'*`j'+`sofar'
				local lo = `sofar'+1
				qui replace `iota'=. in `lo'/`hi'
				local sofar = `sofar' + `em'
***				local hi =`l'*`j'+1
***				qui replace `iota'=. in 2/`hi'
			}

//		noi di in r "sofar, lo, hi `sofar' `lo' `hi'"
			drop ``i''
			rename `llam' ``i''
			local llam "``i''"
			local xlist `xlist' ``i'' `iota'
			local blist `blist' ``i''
			local i=`i'+1
		}
//      end while
			/* log periodogram regression: use noc to get indiv constant terms */
		if "`constraints'" != "" {
			cons def 988 _cons = 0
			qui cnsreg `xlist' if `ok'>0, constraint(`constraints' 988)
		}
		else {
// l `xlist' if `ok'>0
			qui regress `xlist' if `ok'>0, noc
		}
		if "`regressonly'" != "" {
			return local depvar = "`orgvlst'"
			return scalar nord = e(N)
			return scalar rob = -_b[`llam']
			mat `vcv'=e(V)
			return scalar se = sqrt(`vcv'[1,1])
			return scalar t = return(rob)/return(se)
			return scalar p = tprob(`em',return(t))
			return scalar power = `powers'
			exit 0
		}
	}
//  end mult vars | regressonly logic
	
	if `nrvars'==1 {
		di in gr _n "Robinson estimates of fractional differencing parameter for " /*
		*/ in ye "`orgvlst'"
		if `l' != 0 {
			di in gr _col(35) "Skipped ords" _col(48) "="	/*
				*/ in ye %7.0f `l'
		}
		if `j' != 1 {
		   di in gr _col(35) "Averaging" _col(48) "=" in ye %7.0f `j'
		}
		
		di in gr _dup(55) "-"
		di in gr "Power   Ords      Est d    Std Err  "		/*
			*/ "t(H0: d=0)    P>|t|"
		di in gr _dup(55) "-"

		if "`l'" != "" { 
			local optbase l(`l') 
		}
		if "`j'" != "" { 
			local optbase `optbase' j(`j') 
		}
		tokenize `powers'
		local i 1

		while "``i''" != "" {
			/* noi capture */ roblpr `varlist' if `touse', regressonly `optbase' power(``i'')
//			if _rc {
//				di in blue _rc "  roblpr could not be calculated for power = ``i''"
//			}
//			else {
				di in gr   " "    %4.2g ``i'' in ye  	/*
					*/ " "    %6.0f r(nord)		/*
					*/ "  "   %9.0g r(rob)		/*
					*/ "  "   %9.0g r(se) 		/*
					*/ "  "   %9.4f r(t)		/*
					*/ "  "   %8.3f r(p)
//			}
			local i = `i' + 1
		}

		di in gr _dup(55) "-"
		return local depvar = "`orgvlst'"
		return scalar p = r(p)
		return scalar se = r(se)
		return scalar t = r(t)
		return scalar rob = r(rob)
		return scalar nord = r(nord)
		return scalar power = r(power)
	}
	else /* if "`regressonly'" == "" */ {
		return scalar nord = e(N)/`nrvars'
		di in gr _n "Robinson estimates of fractional differencing parameters"
		di in gr "Power = " %4.3g `powers'			/*
		   */ _col(41) "Ords" _col(54) "=" in ye %7.0f return(nord)
		if `l' != 0 {
			di in gr _col(41) "Skipped ords" _col(54) "="	/*
				*/ in ye %7.0f `l'
		}
		if `j' != 1 {
		   di in gr _col(41) "Averaging" _col(54) "=" in ye %7.0f `j'
		}
		di in gr _dup(61) "-"
		di in gr "Variable         |     Est d       Std Err      " /*
			*/ "t       P>|t|"
		di in gr "-----------------+-------------------------"	/*
			*/ "------------------"
		local i=1
		local j=1
		mat `bs'=e(b)
		mat `vcv'=e(V)
		tokenize `orgvlst'
		return local depvar = "`orgvlst'"
		while `i'<=`nrvars' {
			return scalar rob`i' = -`bs'[1,`j']
			return scalar se`i' = sqrt(`vcv'[`j',`j'])
			return scalar t`i' = return(rob`i')/return(se`i')
			return scalar p`i' = tprob(`em',return(t`i'))
			di in gr "``i''" _column(18) "|" in ye	 	/*
				*/ _column(20)  %9.0g -`bs'[1,`j']	/*
				*/ _column(34) %9.0g return(se`i') 	/*
				*/ _column(42) %9.4f return(t`i') 	/*
				*/ _column(56) %6.3f return(p`i')
			local i=`i'+1
			local j=`j'+2
			}
* logic from testparm v3.1
		tokenize `blist'
		local lhs "`1'"
        	quietly {
                	mac shift
                	test `1'=`lhs', notest
                	mac shift
                	while ("`1'"!="") { 
                        	test `1'=`lhs', accum notest
                        	macro shift
                		}
        		test
        		}
		return scalar F = r(F)
		return scalar df = r(df)
		return scalar df_r = r(df_r)
		return scalar pF = r(p)
		di in gr _dup(61) "-"
		if r(df) > 0 {
		   di in gr "Test for equality of d coefficients:" _continue
		   di in gr "   F(" in ye r(df) in gr "," in ye r(df_r)	/*
			*/ in gr  ") = " in ye %7.0g r(F)		/*
			*/ in gr "   Prob > F = " in ye %6.4f r(p)
		}

	}
end
	
exit
