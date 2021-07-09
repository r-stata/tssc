*!!! 1.1.0 Ariel Linden 26Oct2016 // added masd and mvr as return scalars
*!!! NJC 3 June 2016 
*!!! 1.0.0 Ariel Linden 23May2016

program define covbal, rclass byable(recall) sort

    version 11.0

    /* obtain settings */
    syntax varlist(min=2 numeric) [if] [in] [,	///
    Wt(varlist min=1 max=1)						/// weight e.g. IPTW, MMMS   
    ABsolute									/// report absolute std diff
    Format(string)								/// formatting numeric values 
    Saving(string asis) * ]						//  save output as .dta 

    quietly {
        marksample touse 
        count if `touse' 
        if r(N) <= 1 error 2000
        local N = r(N) 

        /* parse treatment and varlist */
        gettoken treat varlist: varlist
        local varcnt : word count `varlist'

        /* verification that treatment is binary and coded as 0 or 1 */
        capture assert inlist(`treat', 0, 1) if `touse' 
        if _rc { 
            di as err "`treat' must be coded as either 0 or 1"
            exit 450 
        }

        tabulate `treat' if `touse' 
        if r(r) != 2 { 
            di as err "`treat' must have two distinct values"
            exit 420  
        } 

        /* ensure weight is properly handled */
        if "`wt'" == "" {
            tempvar wt
            gen byte `wt' = `touse'
        }
        replace `touse' = -`touse'

        /* format numeric values */
        if "`format'" != "" { 
            confirm numeric format `format' 
            local fmt "`format'" 
        } 
        else local fmt "%9.0g" 

        /* get basic stats: mean, variance, skewness */
        tabstat `varlist' [aweight=`wt'] if `touse', col(stat) by(`treat') ///
        stat(mean variance skewness) nototal longstub save 

    }  // close quietly

		/* generate matrices for std-diff and var-ratio */
		tempname A B C X 
		mat `A' = r(Stat1)
		mat `B' = r(Stat2)
		mat `C' = J(2,`varcnt',0)

		if "`absolute'" != "" local abs "abs" 
		forvalues i = 1/`varcnt' {
			matrix `C'[1,`i']= `abs'((`B'[1,`i'] - `A'[1,`i']) / sqrt((`B'[2,`i'] + `A'[2,`i'])/2))
			matrix `C'[2,`i']= `B'[2,`i'] / `A'[2,`i']
		}

		/* combine matrices to generate final table */
		mat `X' = `B'', `A'', `C''

		mat colnames `X' = Mean Variance Skewness Mean Variance Skewness ///
		Std-diff Var-ratio
		mat coleq `X' = Treated Treated Treated Control Control Control Balance
		mat rownames `X' = `varlist' 

		di _newline(1)
		matlist `X', tw(12) lines(eq) border(bottom) showcoleq(comb) ///
		format(`fmt') `options' 
		di _newline(1)
   
		
		if `"`saving'"' == "" { 
        /* store results */ 
		mata : X = st_matrix("`X'")
		mata : st_local("masd", strofreal(abs(mean(X[,7])))) 	// mean of the absolute standardized diffs
		mata : st_local("mvr", strofreal(abs(mean(X[,8]))))		// mean of the variance ratios
		return scalar masd = `masd'
		return scalar mvr = `mvr'
		return matrix table = `X'
        return scalar varcnt = `varcnt'
		exit 0 
		}

		/* optional saving */
    quietly {
        svmat double `X'
        preserve
 
        local newvars tr_mean tr_var tr_skew con_mean con_var con_skew stdiff varratio

        foreach v of local newvars { 
            capture drop `v' 
        } 

        gen varname = ""

        forval i = 1/`varcnt' { 
            gettoken v varlist: varlist
            replace varname = "`v'" in `i'
        } 

*		mat dir  

        rename `X'1 tr_mean
        rename `X'2 tr_var
        rename `X'3 tr_skew
        rename `X'4 con_mean
        rename `X'5 con_var
        rename `X'6 con_skew
        rename `X'7 stdiff
        rename `X'8 varratio

        label var varname  "variables"
        label var tr_mean  "treated mean"
        label var tr_var   "treated variance"
        label var tr_skew  "treated skewness" 
        label var con_mean "control mean"
        label var con_var  "control variance"
        label var con_skew "control skewness"   

		if "`abs'" == "abs" label var stdiff "absolute standardized difference" 
			else label var stdiff "standardized difference"

        label var varratio "variance ratio"

        keep `newvars' 
        drop if tr_mean == .
        label data ""
    
	} // end quietly
	
		/* user should see message */  
		save `saving'

		/* store results */ 
		mata : X = st_matrix("`X'")
		mata : st_local("masd", strofreal(abs(mean(X[,7]))))	// mean of the absolute standardized diffs
		mata : st_local("mvr", strofreal(abs(mean(X[,8]))))		// mean of the variance ratios
		return scalar masd = `masd'
		return scalar mvr = `mvr'
		return matrix table = `X'
		return scalar varcnt = `varcnt'
end

