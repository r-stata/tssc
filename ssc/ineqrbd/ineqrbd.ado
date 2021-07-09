*! version 2.2.0 CV Fiorio and SPJenkins, 02April2010
*! 	fix bug in -noconstant- case (thanks to A. Peichl & N. Pestel)
*! version 2.1.0 CV Fiorio and SPJenkins, 07december2008
*! 	fix minor bug in marking missing obs (thanks to A. Peichl)
*! version 2.0.0 CV Fiorio and SPJenkins, 28august2007
*!	rewrite/update code to version 8.2
*! version 1.0.0 CVFiorio
*! Built on ineqfac (by Stephen P. Jenkins) 
*! Regression-based inequality decomposition method by Gary Fields (2003) 
*!  based on decomposition of inequality methods of Shorrocks (1982)

program define ineqrbd, sortpreserve rclass

    version 8.2

    syntax varlist(min=2 numeric) [aweight fweight] [if] [in] ///
	[, i2 Stats noCONStant noREGression Fields ]

    return local varlist "`varlist'"

    tempvar wi touse total

    if "`weight'" == ""  qui ge `wi' = 1
    else qui ge `wi' `exp'

    mark `touse' `if' `in'
    markout `touse' `varlist'
    tokenize `varlist'
    local yvar `1'
    return local yvar "`yvar'"
    mac shift
    local xvars `*'
    return local xvars "`xvars'"

    set more off
   
quietly {

    if "`fields'" == ""  gen double `total' = `yvar' if `touse'

    count if `touse'
    if r(N) == 0 error 2000

    tempvar x0 yhat
    tempname B

    if "`regression'" == "" local show "noisily "

    `show' di " "
    `show' di as txt "Regression of " as res "`yvar'" as txt " on RHS variables"
    `show' di " "
    `show' regress `yvar' `xvars' [w = `wi'] if `touse',  `constant'

    matrix `B' = e(b) 
    local s = colsof(`B')
    predict double `x0' if `touse', res
    lab var `x0' "residual"
    
    if "`fields'" != "" predict double `total' if `touse', xb 
    
	// multiply the dependent variable(s) by the estimated coefficient(s)
   
   if "`constant'"=="noconstant" local end = `s' 
   else local end = (`s'-1)
   forvalues j = 1/`end' {
		tempvar x`j'
        gen double `x`j'' = ``j'' * `B'[1,`j']  
    }

    su `total' [w = `wi'] if `touse'
    local meantot = r(mean)
    local sdtot = r(sd)
    local cvtot = `sdtot'/`meantot'

    if "`fields'" != "" local pred "predicted"
    
    return local total "`pred' `yvar'"
    return local mean_tot = `meantot'
    return local sd_tot = `sdtot'
    return local cv_tot = `cvtot'
    

    
    noisily {	
    	di " "
    	di as txt "Regression-based decomposition of inequality in " as res "`pred' `yvar'"
    	di as txt in smcl "{hline 9}{c TT}{hline 65}"
    	di as txt "Decomp." _col(10) in smcl "{c |}" _c
    	di as txt _skip(3) "  100*s_f        S_f" _c
    }

    if "`i2'" == "" {
        noi di as txt _skip(3) "  100*m_f/m      CV_f" _c
        noi di as txt _skip(3) "CV_f/CV(total)"
    }
    else if "`i2'" != "" {
        noi di as txt _skip(3) "  100*m_f/m      I2_f" _c
        noi di as txt _skip(3) "I2_f/I2(total)"
    }

    noi di as txt in smcl "{hline 9}{c +}{hline 65}"

   if "`constant'"=="noconstant" local end = `s' 
   else local end = (`s'-1)
   forvalues i = 0/`end' {
		
        su `x`i'' [w = `wi'] if `touse'
        local mean`i' = r(mean)
        local sd`i' = r(sd)
        local cv`i' = `sd`i''/`mean`i''

       	regress `x`i'' `total'  [w = `wi'] if `touse'
       	local sf`i' = _b[`total']

        return local mean_Z`i' = `mean`i''
        return local sd_Z`i' = `sd`i''
        return local cv_Z`i' = `cv`i''
        return local sf_Z`i' = `sf`i''

	if `i' == 0  & "`fields'" == "" {
		noi di as txt "residual" _col(10) in smcl "{c |}" _c
		noi di _skip(3) as res %9.4f 100*`sf`i'' _c
		if "`i2'" == "" {
        		noi di _skip(3) as res %9.4f `sf`i''*`cvtot' _c
        		noi di _skip(3) as res %9.4f 100*`mean`i''/`meantot' _c
        		noi di _skip(3) as res %9.4f `cv`i'' _c
        		noi di _skip(3) as res %9.4f `cv`i''/`cvtot'
        	}
        	if "`i2'" != "" {
        		noi di _skip(3) as res %9.4f `sf`i''*.5*(`cvtot')^2 _c
        		noi di _skip(3) as res %9.4f 100*`mean`i''/`meantot' _c
        		noi di _skip(3) as res %9.4f .5*(`cv`i'')^2 _c
        		noi di _skip(3) as res %9.4f (`cv`i''/`cvtot')^2
        	}
	}

        if `i' > 0   {
		noi di as txt "``i''" _col(10) in smcl "{c |}" _c
		label var `x`i'' "b_`i'*X_`i'"
		noi di _skip(3) as res %9.4f 100*`sf`i'' _c
		if "`i2'" == "" {
        		noi di _skip(3) as res %9.4f `sf`i''*`cvtot' _c
        		noi di _skip(3) as res %9.4f 100*`mean`i''/`meantot' _c
        		noi di _skip(3) as res %9.4f `cv`i'' _c
        		noi di _skip(3) as res %9.4f `cv`i''/`cvtot'
        	}
        	if "`i2'" != "" {
        		noi di _skip(3) as res %9.4f `sf`i''*.5*(`cvtot')^2 _c
        		noi di _skip(3) as res %9.4f 100*`mean`i''/`meantot' _c
        		noi di _skip(3) as res %9.4f .5*(`cv`i'')^2 _c
        		noi di _skip(3) as res %9.4f (`cv`i''/`cvtot')^2
        	}	
        }     

    }

        noi di as txt in smcl "{hline 9}{c +}{hline 65}"

	noi di as txt "Total" _col(10) in smcl "{c |}" _c
        noi di _skip(3) as res %9.4f " 100.0000" _c

        if "`i2'" == "" {
	        noi di _skip(3) as res %9.4f `cvtot' _c
	        noi di _skip(3) as res %9.4f " 100.0000" _c
	        noi di _skip(3) as res %9.4f `cvtot' _c
        }
        if "`i2'" != "" {
	        noi di _skip(3) as res %9.4f .5*(`cvtot')^2 _c
	        noi di _skip(3) as res %9.4f " 100.0000" _c
	        noi di _skip(3) as res %9.4f .5*(`cvtot')^2 _c
        }
        noi di _skip(3) as res %9.4f "   1.0000"
        noi di as txt in smcl "{hline 9}{c BT}{hline 65}"
        noi di as txt "Note: proportionate contribution of composite var" _c
        noi di as txt _skip(1) "f to inequality of Total,"
        noi di as txt "      s_f = rho_f*sd(f)/sd(Total)." _c
        
	if "`i2'" == "" {
        	noi di as txt _skip(1) "S_f = s_f*CV(Total)."
        	noi di as txt "      m_f = mean(f). sd(f) = std.dev. of f." _c
        	noi di as txt _skip(1) "CV_f = sd(f)/m_f."
        }
        if "`i2'" != "" {
        	noi di as txt _skip(1) "S_f = s_f*I2(Total)."
        	noi di as txt "      m_f = mean(f). sd(f) = std.dev. of f." _c
        	noi di as txt _skip(1) "I2_f = .5*[sd(f)/m_f]^2."
        }
	if "`fields'" == ""  noi di as txt "      Total = " as res "`yvar'"
	if "`fields'" != ""  noi di as txt "      Total = " as res "`pred' `yvar'"

    * Optionally produce correlations, means, and std deviations

    if "`stats'" != "" {
    	
	nobreak {

	    if "`fields'" == ""   {
		clonevar __resid = `x0'
		rename `total' __Y
	    }
	    if "`fields'" != ""   {
		rename `total' __Yhat
	    }
	    forvalues i = 1/`=`s'-1' {
		clonevar __b`i'xZ`i' = `x`i''		
        	local compvars `compvars' __b`i'xZ`i'
	    }
       	    noi di " "
       	    noi di as txt "Summary statistics: Total, residual, and composite RHS variables"
	    noi di " "
       	    
	    if "`fields'" == "" {
		noi corr __Y __resid `compvars'  [w = `wi'] if `touse', means
		rename __Y `total'
	    }
	    if "`fields'" != "" {
		noi corr __Yhat `compvars'  [w = `wi'] if `touse', means
		rename __Yhat `total'
	    }
	    capture drop __resid 
 	    capture drop `compvars'

       }
    }


}  /* end of quietly block */


end
