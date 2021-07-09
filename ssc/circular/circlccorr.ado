*! 2.0.0 NJC 30 March 2004
* 1.2.0 NJC 15 December 1998
* 1.1.1 NJC 26 October 1996
* correlation for linear-circular data
program circlccorr, rclass 
        version 8.0
        syntax varlist(min=2 max=2) [if] [in]  

	marksample touse 

        qui {
                count if `touse'
		if r(N) == 0 error 2000
		else local N = r(N) 
		
	        tempvar cosx sinx
	        tempname r12 r13 r23 r_sq P_val
		tokenize `varlist' 
		args y x 
		
	        gen `cosx' = cos(`x' * _pi / 180) if `touse'
                gen `sinx' = sin(`x' * _pi / 180) if `touse'
                corr `y' `cosx'
                scalar `r12' = r(rho)
                corr `y' `sinx'
                scalar `r13' = r(rho) 
                corr `cosx' `sinx'
                scalar `r23' = r(rho)
                scalar `r_sq' = `r12'^2 + `r13'^2 - 2 * `r12' * `r13' * `r23'
                scalar `r_sq' = `r_sq' / (1 - `r23'^2)
                scalar `P_val' = chiprob(2, `N' * `r_sq')
        }

        di as txt "(`y' taken to be linear, `x' taken to be circular)"
        di as txt "Number of data     " as res %9.0f `N'
        di as txt "r-square           " as res %9.3f `r_sq'
        di as txt "r (positive root)  " as res %9.3f sqrt(`r_sq')
        di as txt "P-value (n large)  " as res %9.3f `P_val'

        return scalar N = `N'
        return scalar rsq = `r_sq'
        return scalar Pval = `P_val'
end
