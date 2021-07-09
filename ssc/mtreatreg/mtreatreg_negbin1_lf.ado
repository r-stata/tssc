*! version 2.0.0 09jul2009
*! author: Partha Deb
* version 1.1.0 25feb2009
* version 1.0.0 04feb2009

************************************************
*** ml for joint mmlogit and negbin1         ***
************************************************

program mtreatreg_negbin1_lf
	version 10.1

	scalar neqall = 2*neq + 2
	forvalues i=1/`=neqall' {
		local L_g `"`L_g' g`i'"'
	}

	args todo b lnf g negH `L_g'

	forvalues i=1/`=neq' {
		local L_xbT `"`L_xbT' xbT`i'"'
		local L_lam `"`L_lam' lam`i'"'
	}

	forvalues j=1/`=neqall' {
		forvalues i=`j'/`=neqall' {
			local L_h `"`L_h' h`i'`j'"'
			local L_nH `"`L_nH' nH`i'`j'"'
		}
	}

	tempvar lnL gi `L_xbT' xbO `L_lam' lndelta delta `L_h' `L_nH'

	qui gen double `lnL'=.

	forvalues j=1/`=neqall' {
		forvalues i=`j'/`=neqall' {
			qui gen double `h`i'`j'' = .
		}
	}

	forvalues i=1/`=neq' {
		mleval `xbT`i'' = `b', eq(`i')
		mleval `lam`i'' = `b', eq(`=neq+2+`i'')
		local xbTnames `xbTnames' `xbT`i''
		local lamnames `lamnames' `lam`i''
	}

	forvalues i=1/`=neqall' {
		local G `G' `g`i''
	}

	forvalues j=1/`=neqall' {
		forvalues i=`j'/`=neqall' {
			local H `H' `h`i'`j''
		}
	}

	mleval `xbO' = `b', eq(`=neq+1')
	mleval `lndelta' = `b', eq(`=neq+2')

	qui gen double `delta' = exp(`lndelta')

	mata: mtreatreg_negbin1_lf("`lnL'","`G'","`H'" ///
		,"`xbTnames'","`xbO'","`delta'","`lamnames'" ///
		,"neq","neqall","nobs","sim",yT,yO,_mtreatreg_rmat)

	mlsum `lnf' = `lnL'

	local k = colsof(`b')
	local c 1
	matrix `g' = J(1,`k',0)

	forvalues i = 1/`=neqall' {
		mlvecsum `lnf' `gi' = `g`i'', eq(`i')
		matrix `g'[1,`c'] = `gi'
		local c = `c' + colsof(`gi')
	}

	forvalues j = 1/`=neqall' {
		forvalues i = `j'/`=neqall' {
			mlmatsum `lnf' `nH`i'`j'' = -`h`i'`j'', eq(`i',`j')
		}
	}

	// collect hessian terms into matrix
	local np = colsof(`b')
	local c 1
	matrix `negH' = J(`np',`np',.)
	
	forvalues j = 1/`=neqall' {
		local r = `c'
		forvalues i = `j'/`=neqall' {
			matrix `negH'[`r',`c'] = `nH`i'`j''
			if (`i'>`j') {
				matrix `negH'[`c',`r'] = `nH`i'`j'''
			}
			local r = `r' + rowsof(`nH`i'`j'')
		}
		local c = `c' + colsof(`nH`j'`j'')
	}

end
