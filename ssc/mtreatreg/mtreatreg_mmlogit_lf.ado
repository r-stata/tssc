*! version 2.0.0 09jul2009
*! author: Partha Deb
* version 1.1.0 25feb2009
* version 1.0.0 04feb2009

************************************************
*** ml for mixed logit                       ***
************************************************

program mtreatreg_mmlogit_lf
	version 10.1

	forvalues i=1/`=neq' {
		local L_g `"`L_g' g`i'"'
		local L_xbT `"`L_xbT' xbT`i'"'
	}

	forvalues j=1/`=neq' {
		forvalues i=`j'/`=neq' {
			local L_h `"`L_h' h`i'`j'"'
			local L_nH `"`L_nH' nH`i'`j'"'
		}
	}

	args todo b lnf g negH `L_g'

	tempvar lnL gi `L_xbT' `L_h' `L_nH'

	qui gen double `lnL'=.

	forvalues j=1/`=neq' {
		forvalues i=`j'/`=neq' {
			qui gen double `h`i'`j'' = .
		}
	}

	forvalues i=1/`=neq' {
		mleval `xbT`i'' = `b', eq(`i')
		local xbTnames `xbTnames' `xbT`i''
		local G `G' `g`i''
	}

	forvalues j=1/`=neq' {
		forvalues i=`j'/`=neq' {
			local H `H' `h`i'`j''
		}
	}

	mata: mtreatreg_mmlogit_lf("`lnL'","`G'","`H'" ///
		,"`xbTnames'","neq","nobs","sim",yT,_mtreatreg_rmat)

	mlsum `lnf' = `lnL'

	local k = colsof(`b')
	local c 1
	matrix `g' = J(1,`k',0)

	forvalues i = 1/`=neq' {
		mlvecsum `lnf' `gi' = `g`i'', eq(`i')
		matrix `g'[1,`c'] = `gi'
		local c = `c' + colsof(`gi')
	}

	forvalues j = 1/`=neq' {
		forvalues i = `j'/`=neq' {
			mlmatsum `lnf' `nH`i'`j'' = -`h`i'`j'', eq(`i',`j')
		}
	}

	// collect hessian terms into matrix
	local np = colsof(`b')
	local c 1
	matrix `negH' = J(`np',`np',.)
	
	forvalues j = 1/`=neq' {
		local r = `c'
		forvalues i = `j'/`=neq' {
			matrix `negH'[`r',`c'] = `nH`i'`j''
			if (`i'>`j') {
				matrix `negH'[`c',`r'] = `nH`i'`j'''
			}
			local r = `r' + rowsof(`nH`i'`j'')
		}
		local c = `c' + colsof(`nH`j'`j'')
	}

end

