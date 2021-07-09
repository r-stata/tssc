*! version 1.1.7    12feb2006       C F Baum/V Wiggins  SSC distribution
*! Phillips Modified Log Periodogram estimator 
*  from gphudak 1.1.0 9826
*  1.0.1 add return of e(depvar)
*  1.0.2 correct xn to ignore missing values at end of series
*  1.0.3 add trend removal option
*  1.1.3 modified output -- vlw
*  1.1.4 corrected z pvalue; published STB-57
*  1.1.5 rev for variable name, trend on output
*  1.1.6 corrections for Stata 8 syntax
*  1.1.7 make byable(recall) and onepanel

program define modlpr, eclass byable(recall)
	version 8.2

	syntax varlist(ts max=1) [if] [in] [ , Powers(numlist >0 <1) noTrend]  

	if "`powers'" == "" { 
		local powers=0.5 
	}
   	marksample touse

			/* get time variables; enable onepanel */
*	_ts timevar, sort
	_ts timevar panelvar if `touse', sort onepanel
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}
	tempvar lhs
	if "`trend'"=="notrend" {
		qui gen `lhs'=`varlist'
		local notr ", notrend"
		}
	else {
		qui regress `varlist' `timevar' if `touse'
		qui predict `lhs',r
		}
	local N_power : word count `powers'
	tempname lpr
	mat `lpr' = J(`N_power', 8, 0)
	mat colnames `lpr'  = power nord d se t p0 zd p 

	di in gr _n "Modified LPR estimate of fractional differencing parameter for " /*
	*/ in ye "`varlist'" in gr "`notr'"
	di in gr _dup(78) "-"
	di in gr "Power   Ords      Est d    Std Err  t(H0: d=0)    "	/*
		*/ "P>|t|    z(H0: d=1)    P>|z|"
	di in gr _dup(78) "-"

	tokenize `powers'
	local i 1
	while "``i''" != "" {
*		capture noisily LPREst1 ``i'' `varlist' `touse'
		capture noisily LPREst1 ``i'' `lhs' `touse'
		if !_rc {
			capture mat `lpr'[`i',1] = r(power), r(nord),   /*
				*/ r(lpr), r(se), r(t), r(p0), r(zd),   /*
				*/ r(p)
		}
		else    di in blue "  modlpr could not be calculated "   /*
			*/ " for power = ``i''"
		local i = `i' + 1
	}
	di in gr _dup(78) "-"

	mat `lpr' = `lpr''
*        estimates clear
	ereturn scalar N_powers = `N_power'
	ereturn local depvar `varlist'
	ereturn local power `power'
	ereturn matrix modlpr `lpr'

end

program define LPREst1, rclass
	args power varlist touse
	tempname xr xi n lpg re im tcos tsin ahat bhat lpgcorr lsin matt vcv var obs
			/* generate fft */
	quietly {
		gen double `var'=`varlist' if `touse'
		gen `obs' = _n if `touse'
		sum `obs',meanonly
		local lastobs = r(max)
		fft `var' if `touse', gen(`xr' `xi') 

			/* generate log periodogram */
		gen long `n' = sum(`touse')-1
		count if `touse'
		replace `xr'=`xr'/sqrt(2.0*_pi*r(N)) if `touse'
		replace `xi'=-`xi'/sqrt(2.0*_pi*r(N)) if `touse'
*gph	gen double `lpg' = log(`xr'^2+`xi'^2)  if `touse' 
* 
* PCB Phillips ModLPR code (Discrete FTs of Fractional Processes, Nov 1999)
* Derivation of Re,Im parts of adjustment factors from Mathematica 
* 1.0.2 corr: r(N), not _N, in case series ends with missing values

* must pick up last defined element of var under touse

//		local xn = `var'[r(N)]
		local xn = `var'[`lastobs']
		gen double `tcos' = cos(2.0*_pi*(`n')/r(N)) if `touse' 
		gen double `tsin' = sin(2.0*_pi*(`n')/r(N)) if `touse'  
		gen double `re' = ((1.0-`tcos')*`tcos'-`tsin'^2)/((1-`tcos')^2+`tsin'^2) if `touse' 
		gen double `im' = ((1.0-`tcos')*`tsin'+`tsin'*`tcos')/((1-`tcos')^2+`tsin'^2) if `touse' 
		gen double `ahat' = `xr'+`re'*`xn'/sqrt(2.0*_pi*r(N)) if `touse' 
		gen double `bhat' = `xi'+`im'*`xn'/sqrt(2.0*_pi*r(N)) if `touse' 
		gen double `lpgcorr' = log(`ahat'^2+`bhat'^2) if `touse'	
		gen double `lsin' = log( 4.0 * sin(_pi*(`n')/r(N))^2 ) if `touse' 
		
			/* log periodogram regression  */
		local enn=int(r(N)^`power')+1
		regress `lpgcorr' `lsin' if `touse' & `n' < `enn'
		local enn=e(N)
		return scalar lpr = -_b[`lsin']
		mat `vcv'=e(V)
		return scalar se = sqrt(`vcv'[1,1])
		return scalar t = return(lpr)/return(se)
		return scalar p0 = tprob(`enn',return(t))
		return scalar zd = sqrt(`enn')*(return(lpr)-1.0)/(_pi/sqrt(24.0))
		return scalar p = 2 * normprob(-abs(return(zd)))
		return scalar nord = `enn'
		return scalar power = `power'
	} 
	
	di in gr   " "   %4.2g `power' in ye  " "  %6.0f return(nord)	/*
		*/ "  "  %9.0g return(lpr)    "  " %9.0g return(se) 	/*
		*/ "  "  %9.4f return(t)      "  " %8.3f return(p0)	/*
		*/ "    " %9.4f return(zd)    "  " %8.3f return(p)

end
	
exit

LPR estimate of fractional differences
------------------------------------------------------------------------------
Power   Ords      Est d    Std Err  t(H0: d=0)    P>|t|    z(H0: d=1)    P>|z|
------------------------------------------------------------------------------
  .50     19   .0231191   .1399000     0.1653     0.870      -6.6401     0.000
  .60     34   .2450011   .1360000     1.8020     0.080      -6.8650     0.805
------------------------------------------------------------------------------
