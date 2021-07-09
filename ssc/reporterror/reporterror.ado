////////////////////////////////////////////////////////////////////////////////
// STATA FOR  Hu, Y. & Sasaki, Y. (2019): Identification of Paired Nonseparable
//            Measurement Error Models. Econometric Theory 33 (4), 955-979.
//
// Use it when you have two measurements (survey reports) of a variable and you
// want to estimate the true mass function of the variable as well as the
// conditional probabilities of mis-reporting.
////////////////////////////////////////////////////////////////////////////////
program define reporterror, eclass
    version 14.2
 
    syntax varlist(numeric) [if] [in] [, minu(real -999999) maxu(real -999999) nounderreport(real 1) boot(real 2500)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname b V N

	mata: estimate_nounder("`depvar'", "`cnames'", ///
						   "`touse'", `boot', ///
						   `minu', `maxu', `nounderreport', ///
						   "`b'", "`V'", "`N'") 

	matrix colnames `b' = fU
	matrix colnames `V' = fU
	matrix rownames `V' = fU
	
    ereturn post `b' `V', esample(`touse') buildfvinfo
    ereturn scalar N    = `N'
    ereturn local  cmd  "reporterror"
 
    //ereturn display
end

		
		
		
		
mata:
rseed(1)
//////////////////////////////////////////////////////////////////////////////// 
// Estimation of QRKD
void estimate_nounder( string scalar xv,      string scalar yv,
					   string scalar touse,   real scalar num_boot,
					   real scalar min_u, 	  real scalar max_u,	   real scalar nounder, 
					   string scalar bname,   string scalar Vname,     string scalar nname) 
{
	printf("\n\n{hline 78}\n")
	printf("Executing:  Hu, Y. & Sasaki, Y. (2019): Identification of Paired Nonseparable \n")
	printf("            Measurement Error Models. Econometric Theory 33 (4), 955-979.     \n")
	printf("{hline 78}\n")
 
    x      = st_data(., xv, touse)
    y      = st_data(., yv, touse)
    n      = rows(y)
	
	////////////////////////////////////////////////////////////////////////////
	// Get the support
	supp_min = min( select(x, x:==y) )
	if( min_u != -999999 ){
		supp_min = min_u
	}
	supp_max = max( select( x, x:==y) )
	if( max_u != -999999 ){
		supp_max = max_u
	}
	support = supp_min .. supp_max
	
	if( nounder == 0 ){
		support = (-1*supp_max)..(-1*supp_min)
		support = -1 :* support
	}

	////////////////////////////////////////////////////////////////////////////
	// Empirical mass
	fXY = J( length(support), length(support), 0)
	fX  = J( 1, length(support), 0)
	fY  = J( 1, length(support), 0)

	for( xdx = 1 ; xdx <= length(support) ; xdx++ ){
		fX[xdx] = sum( (x :== support[xdx]) ) / n
	}
	for( ydx = 1 ; ydx <= length(support) ; ydx++ ){
		fY[ydx] = sum( (y :== support[ydx]) ) / n
	}
	for( xdx = 1 ; xdx <= length(support) ; xdx++ ){
		for( ydx = 1 ; ydx <= length(support) ; ydx++ ){
			fXY[xdx,ydx] = sum( (x :== support[xdx]) :* (y :== support[ydx]) ) / n
		}
	}
	
	est_fX = fX'
	est_fY = fY'
	
	////////////////////////////////////////////////////////////////////////////
	// Make placeholders of estimates
	fXU = J( length(support), length(support), 0)
	fYU = J( length(support), length(support), 0)
	fU  = J( 1, length(support), 0)

	////////////////////////////////////////////////////////////////////////////
	// First iteration
	jdx = 1
	
	for( xdx = 1 ; xdx <= length(support) ; xdx++ ){
	fXU[xdx,jdx] = fXY[xdx,jdx] / fY[jdx]
	}
	
	for( ydx = 1 ; ydx <= length(support) ; ydx++ ){
	fYU[ydx,jdx] = fXY[jdx,ydx] / fX[jdx]
	}
	
	fU[jdx] = fX[jdx] * fY[jdx] / fXY[jdx,jdx]

	////////////////////////////////////////////////////////////////////////////
	// Subsequent iterations
	for( jdx = 2 ; jdx <= length(support) ; jdx++ ){
		for( xdx = 1 ; xdx <= length(support) ; xdx++ ){
			numerator_sum = 0
			denominator_sum = 0
			for( kdx = 1 ; kdx < jdx ; kdx++ ){
				numerator_sum = numerator_sum + fXU[xdx,kdx] * fYU[jdx,kdx] * fU[kdx]
				denominator_sum = denominator_sum + fYU[jdx,kdx] * fU[kdx]
			}
			fXU[xdx,jdx] = ( fXY[xdx,jdx] - numerator_sum ) / ( fY[jdx] - denominator_sum )
		}
		
		for( ydx = 1 ; ydx <= length(support) ; ydx++ ){
			numerator_sum = 0
			denominator_sum = 0
			for( kdx = 1 ; kdx < jdx ; kdx++ ){
				numerator_sum = numerator_sum + fXU[jdx,kdx] * fYU[ydx,kdx] * fU[kdx]
				denominator_sum = denominator_sum + fXU[jdx,kdx] * fU[kdx]
			}
			fYU[ydx,jdx] = ( fXY[jdx,ydx] - numerator_sum ) / ( fX[jdx] - denominator_sum )
		}	
		
		numerator_sum1 = 0
		numerator_sum2 = 0
		denominator_sum = 0
		for( kdx = 1 ; kdx < jdx ; kdx++ ){
			numerator_sum1 = numerator_sum1 + fXU[jdx,kdx] * fU[kdx]
			numerator_sum2 = numerator_sum2 + fYU[jdx,kdx] * fU[kdx]
			denominator_sum = denominator_sum + fXU[jdx,kdx] * fYU[jdx,kdx] * fU[kdx]
		}
		fU[jdx] = ( fX[jdx] - numerator_sum1 ) * ( fY[jdx] - numerator_sum2 ) / ( fXY[jdx,jdx] - denominator_sum )
	}
	
	est_prob_correct_x = diagonal(fXU)
	est_prob_correct_y = diagonal(fYU)
	est_true_fU = fU'
	
	////////////////////////////////////////////////////////////////////////////
	// Bootstrap
	xx = x
	yy = y
	
	list_est_fX = J(length(support), num_boot, 0)
	list_est_fY = J(length(support), num_boot, 0)
	list_est_prob_correct_x = J(length(support), num_boot, 0)
	list_est_prob_correct_y = J(length(support), num_boot, 0)
	list_est_true_fU = J(length(support), num_boot, 0)
	
	for( boot_iter = 1 ; boot_iter <= num_boot ; boot_iter++ ){
		indices = trunc(uniform(n,1):*n):+1
		x = xx[indices]
		y = yy[indices]
		
		////////////////////////////////////////////////////////////////////////////
		// Empirical mass
		for( xdx = 1 ; xdx <= length(support) ; xdx++ ){
			fX[xdx] = sum( (x :== support[xdx]) ) / n
		}
		for( ydx = 1 ; ydx <= length(support) ; ydx++ ){
			fY[ydx] = sum( (y :== support[ydx]) ) / n
		}
		for( xdx = 1 ; xdx <= length(support) ; xdx++ ){
			for( ydx = 1 ; ydx <= length(support) ; ydx++ ){
				fXY[xdx,ydx] = sum( (x :== support[xdx]) :* (y :== support[ydx]) ) / n
			}
		}
		
		////////////////////////////////////////////////////////////////////////////
		// First iteration
		jdx = 1
		
		for( xdx = 1 ; xdx <= length(support) ; xdx++ ){
		fXU[xdx,jdx] = fXY[xdx,jdx] / fY[jdx]
		}
		
		for( ydx = 1 ; ydx <= length(support) ; ydx++ ){
		fYU[ydx,jdx] = fXY[jdx,ydx] / fX[jdx]
		}
		
		fU[jdx] = fX[jdx] * fY[jdx] / fXY[jdx,jdx]

		////////////////////////////////////////////////////////////////////////////
		// Subsequent iterations
		for( jdx = 2 ; jdx <= length(support) ; jdx++ ){
			for( xdx = 1 ; xdx <= length(support) ; xdx++ ){
				numerator_sum = 0
				denominator_sum = 0
				for( kdx = 1 ; kdx < jdx ; kdx++ ){
					numerator_sum = numerator_sum + fXU[xdx,kdx] * fYU[jdx,kdx] * fU[kdx]
					denominator_sum = denominator_sum + fYU[jdx,kdx] * fU[kdx]
				}
				fXU[xdx,jdx] = ( fXY[xdx,jdx] - numerator_sum ) / ( fY[jdx] - denominator_sum )
			}
			
			for( ydx = 1 ; ydx <= length(support) ; ydx++ ){
				numerator_sum = 0
				denominator_sum = 0
				for( kdx = 1 ; kdx < jdx ; kdx++ ){
					numerator_sum = numerator_sum + fXU[jdx,kdx] * fYU[ydx,kdx] * fU[kdx]
					denominator_sum = denominator_sum + fXU[jdx,kdx] * fU[kdx]
				}
				fYU[ydx,jdx] = ( fXY[jdx,ydx] - numerator_sum ) / ( fX[jdx] - denominator_sum )
			}	
			
			numerator_sum1 = 0
			numerator_sum2 = 0
			denominator_sum = 0
			for( kdx = 1 ; kdx < jdx ; kdx++ ){
				numerator_sum1 = numerator_sum1 + fXU[jdx,kdx] * fU[kdx]
				numerator_sum2 = numerator_sum2 + fYU[jdx,kdx] * fU[kdx]
				denominator_sum = denominator_sum + fXU[jdx,kdx] * fYU[jdx,kdx] * fU[kdx]
			}
			fU[jdx] = ( fX[jdx] - numerator_sum1 ) * ( fY[jdx] - numerator_sum2 ) / ( fXY[jdx,jdx] - denominator_sum )
		}
		
		list_est_fX[.,boot_iter] = fX'
		list_est_fY[.,boot_iter] = fY'
		list_est_prob_correct_x[.,boot_iter] = diagonal(fXU)
		list_est_prob_correct_y[.,boot_iter] = diagonal(fYU)
		list_est_true_fU[.,boot_iter] = fU'
	}
	////////////////////////////////////////////////////////////////////////////
	// End of bootstrap - compute variances
	var_est_true_fU = list_est_true_fU * list_est_true_fU' :/ num_boot :- (list_est_true_fU * J(num_boot,1,1) :/ num_boot) * (list_est_true_fU * J(num_boot,1,1) :/ num_boot)'
	var_est_fX = list_est_fX * list_est_fX' :/ num_boot :- (list_est_fX * J(num_boot,1,1) :/ num_boot) * (list_est_fX * J(num_boot,1,1) :/ num_boot)'
	var_est_fY = list_est_fY * list_est_fY' :/ num_boot :- (list_est_fY * J(num_boot,1,1) :/ num_boot) * (list_est_fY * J(num_boot,1,1) :/ num_boot)'
	var_est_prob_correct_x = list_est_prob_correct_x * list_est_prob_correct_x' :/ num_boot :- (list_est_prob_correct_x * J(num_boot,1,1) :/ num_boot) * (list_est_prob_correct_x * J(num_boot,1,1) :/ num_boot)'
	var_est_prob_correct_y = list_est_prob_correct_y * list_est_prob_correct_y' :/ num_boot :- (list_est_prob_correct_y * J(num_boot,1,1) :/ num_boot) * (list_est_prob_correct_y * J(num_boot,1,1) :/ num_boot)'
	
	se_true_fU = diagonal(var_est_true_fU):^0.5
	se_fX = diagonal(var_est_fX):^0.5
	se_fY = diagonal(var_est_fY):^0.5
	se_prob_correct_x = diagonal(var_est_prob_correct_x):^0.5
	se_prob_correct_y = diagonal(var_est_prob_correct_y):^0.5
	
	printf("\n")
	printf("       Obs: %f\n\n",n)
	printf("{hline 78}\n")
	printf("         U      Mass of U    Mass of X    Mass of Y    Pr(U=X|U)    Pr(U=Y|U)\n")
	printf("{hline 78}\n")
	for( idx = 1 ; idx <= length(support) ; idx++ ){
		printf("%10.5f      %8.7f    %8.7f    %8.7f    %8.7f    %8.7f\n", support[idx], est_true_fU[idx], est_fX[idx], est_fY[idx], est_prob_correct_x[idx], est_prob_correct_y[idx])
		printf("               (%8.7f)  (%8.7f)  (%8.7f)  (%8.7f)  (%8.7f)\n", se_true_fU[idx], se_fX[idx], se_fY[idx], se_prob_correct_x[idx], se_prob_correct_y[idx])
	}
	printf("{hline 78}\n")
	printf("\n")
	////////////////////////////////////////////////////////////////////////////
	// Set b, V, n and cb
	b = est_true_fU'
	V = var_est_true_fU
	
    st_matrix(bname, b)
    st_matrix(Vname, V)
    st_numscalar(nname, n)
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
