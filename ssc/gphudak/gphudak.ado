*! version 1.1.2   25jun2006      C F Baum/VWiggins   SSC distribution
*  rev 1.1.1 0421 correction to pval of asy z
*  rev 1.1.2 Stata 8 syntax, make byable(recall) and onepanel

program define gphudak, eclass byable(recall)
	version 8.2

	syntax varlist(ts max=1) [if] [in] [ , Powers(numlist >0 <1) ]  

	if "`powers'" == "" { 
		local powers=0.5 
	}
   	marksample touse
			/* get time variables; enable onepanel */
//	_ts timevar, sort
	_ts timevar panelvar if `touse', sort onepanel
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}

	local N_power : word count `powers'
	tempname gph
	mat `gph' = J(`N_power', 9, 0)
	mat colnames `gph'  = power nord d se t p ase tasy pasy

	di in gr _n "GPH estimate of fractional differencing parameter"
	di in gr _dup(78) "-"
	di in gr _col(55) "Asy."
	di in gr "Power   Ords    Est d   StdErr  t(H0: d=0)  P>|t|"	/*
		*/ "    StdErr  z(H0: d=0)  P>|z|"
	di in gr _dup(78) "-"

	tokenize `powers'
	local i 1
	while "``i''" != "" {
		capture noisily GPHEst1 ``i'' `varlist' `touse'
		if !_rc {
			capture mat `gph'[`i',1] = r(power), r(nord),   /*
				*/ r(gph), r(se), r(t), r(p), r(ase),   /*
				*/ r(tasy), r(pasy)		
		}
		else {
		   di in blue "  gphudak could not be calculated "   /*
			*/ " for power = ``i''"
		}
		local i = `i' + 1
	}
	di _dup(78) in gr "-"

	mat `gph' = `gph''
//	estimates clear
	ereturn local depvar `varlist'
	ereturn scalar N_powers = `N_power'
	ereturn local power `power'
	ereturn matrix gph `gph'
	
end

	
program define GPHEst1, rclass
	args power varlist touse
	tempname xr xi n lpg lsin matt vcv 
	tempvar var
			/* generate fft */
	quietly {
		gen double `var'=`varlist'
		fft `var' if `touse', gen(`xr' `xi') 

			/* generate log periodogram */
		gen long `n' = sum(`touse')-1
		count if `touse'
		gen double `lpg' = log( (`xr'^2+`xi'^2) )  if `touse'  
		gen double `lsin' = log( 4.0 * sin(_pi*(`n')/r(N))^2 ) if `touse' 
	
			/* log periodogram regression  */
		local enn=int(r(N)^`power')+1
		regress `lpg' `lsin' if `touse' & `n' < `enn'

		return scalar gph = -_b[`lsin']
		mat `vcv'=e(V)
		return scalar se = _se[`lsin']
		return scalar t = return(gph)/return(se)
		return scalar p = tprob(e(df_r),return(t))
		return scalar ase = _pi*sqrt(`vcv'[1,1]/(6.0*e(rmse)^2))
		return scalar tasy = return(gph)/return(ase)
		return scalar pasy = 2*normprob(-abs(return(tasy)))
		return scalar nord = `enn'
		return scalar power = `power'
	} 
	
	di in gr " " %4.2g `power' in ye  " "  %6.0f return(nord)	/*
		*/ " "  %8.0g return(gph) " "  %8.4g return(se) 	/*
		*/ "  " %9.4f return(t)   "  " %6.3f return(p)	/*
		*/ "  " %8.4g return(ase) "  " %9.4f return(tasy) 	/*
		*/ "  " %6.3f return(pasy)

end
	
exit

----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

GPH estimate of fractional differences
------------------------------------------------------------------------------
                                                      Asy.
Power   Ords     Est d  StdErr  t(H0: d=0)  P>|t|    StdErr  z(H0: d=0)  P>|z|
------------------------------------------------------------------------------
  .50     19  .0231191   .1399     0.1653   0.870     .1875    -6.6401   0.000
  .60     34  .2450011   .1360     1.8020   0.081     .1987    -6.8650   0.805
------------------------------------------------------------------------------
