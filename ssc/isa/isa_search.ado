capture program drop isa_search

/* History

1.0.0	First release.
1.0.1	Unnecessary vars dropped
1.0.2	Minor updates
1.0.3	Bug fixed

*/

program define isa_search
	version 9
	syntax varlist [if] [in], ///
	[vce(passthru)] [TAU(numlist >0)] [TSTAT(numlist >0)] [INCRement(real .5)] ///
	[MAXAlpha(real 10)] [MAXDelta(real 5)] [MINAlpha(real 0)] [MINDelta(real 0)] ///
	[ml_iterate(passthru)]

	if "`tau'" == "" & "`tstat'" == "" {
		display ""
		display as error "Error: either tau( ) or tstat( ) needs to be specified."
		error 121
	}
	
	marksample touse
	
	foreach scl in delta alpha tstat se tau converged {
		capture scalar drop `scl'
	}
	foreach mat in matV matB {
		capture matrix drop `mat'
	}
	foreach var in ur ll {
		capture drop isas_`var'
	}
	qui foreach var in converged tau tstat alpha delta plus minus ur ll{
		capture drop old_isas_`var'
		capture rename isas_`var' old_isas_`var'
		gen isas_`var' = .
	}
	

	local i = 0
	forvalues alpha = `minalpha'(`increment')`maxalpha' {
		forvalues delta = `mindelta'(`increment')`maxdelta' {
			
			local i = `i'+1

			*	MAIN ITERATION
			capture isa_est_woinit `varlist' `if' `in' [`weight'`exp'], `vce' alpha(`alpha') delta(`delta') `ml_iterate'
			scalar converged = e(converged)
			matrix matB = e(b)
			matrix matV = e(V)
			scalar tau = matB[1,1]
			scalar se = sqrt(matV[1,1])
			scalar tstat = scalar(tau)/scalar(se)
			scalar alpha = `alpha'
			scalar delta = `delta'
			
			*	CREATING TEMPNAME & RECORDING QOI
			foreach var in converged tau tstat alpha delta {
				tempname `var'`i'
				scalar ``var'`i'' = `var'
				capture drop scalar `var'
			}
			
			noisily if "`dots'" != "nodots" {
				display as txt "." _continue
			}
		}
	}

	local N_iter_search = ceil(((`maxalpha'-`minalpha')/`increment'+1)*((`maxdelta'-`mindelta')/`increment'+1))
	if `N_iter_search'>_N {
		set obs `N_iter_search'
	}
	
	qui foreach var in converged tau tstat alpha delta {
		forvalues j = 1/`N_iter_search'{
			capture replace isas_`var' = ``var'`j'' if _n==`j'
		}
	}

	if "`tau'" != "" {
		qui forvalues i = 1/`N_iter_search' {
			capture replace isas_ur = isas_tau[`i'] if isas_tau[`i'] != . & isas_converged[`i'] == 1 & isas_alpha[`i'] == isas_alpha[_n]+`increment' & isas_delta[`i'] == isas_delta[_n]+`increment'
			capture replace isas_ll = isas_tau[`i'] if isas_tau[`i'] != . & isas_converged[`i'] == 1 & isas_alpha[`i'] == isas_alpha[_n]-`increment' & isas_delta[`i'] == isas_delta[_n]-`increment'
		}
		
		capture replace isas_plus = 1  if (mi(isas_tau,isas_ll,isas_ur)!=1 | (isas_alpha==`minalpha'&mi(isas_tau,isas_ur)!=1) | (isas_delta==`mindelta'&mi(isas_tau,isas_ur)!=1)) & isas_tau>`tau' & isas_ll>`tau' & isas_ur<`tau'
		capture replace isas_minus = 1 if mi(isas_tau,isas_ll,isas_ur)!=1 & isas_tau<`tau' & isas_ur<`tau' & isas_ll>`tau'	
		}
	else {
		qui forvalues i = 1/`N_iter_search' {
			capture replace isas_ur = isas_tstat[`i'] if isas_tstat[`i'] != . & isas_converged[`i'] == 1 & isas_alpha[`i'] == isas_alpha[_n]+`increment' & isas_delta[`i'] == isas_delta[_n]+`increment'
			capture replace isas_ll = isas_tstat[`i'] if isas_tstat[`i'] != . & isas_converged[`i'] == 1 & isas_alpha[`i'] == isas_alpha[_n]-`increment' & isas_delta[`i'] == isas_delta[_n]-`increment'
		}	
		capture replace isas_plus = 1  if (mi(isas_tstat,isas_ll,isas_ur)!=1 | (isas_alpha==`minalpha'&mi(isas_tstat,isas_ur)!=1) | (isas_delta==`mindelta'&mi(isas_tstat,isas_ur)!=1)) & isas_tstat>`tstat' & isas_ll>`tstat' & isas_ur<`tstat'
		capture replace isas_minus = 1 if mi(isas_tau,isas_ll,isas_ur)!=1 & isas_tstat<`tstat' & isas_ur<`tstat' & isas_ll>`tstat'	
	}
	
	twoway (scatter isas_delta isas_alpha if (isas_tau !=.|isas_tstat !=.) & isas_converged==1 & isas_plus==1, mcolor(midblue) msize(medlarge) msymbol(+)) ///
	(scatter isas_delta isas_alpha if (isas_tau !=.|isas_tstat !=.) & isas_converged==1 & isas_minus==1, mcolor(cranberry) msize(medlarge) msymbol(T)) ///
	(scatter isas_delta isas_alpha if isas_tau ==. | isas_tstat ==. | isas_converged!=1, mcolor(red) msize(medlarge) msymbol(X)) ///
	(scatter isas_delta isas_alpha if (isas_tau !=.|isas_tstat !=.) & isas_converged==1 & isas_plus!=1 & isas_minus!=1, mcolor(black) msize(medium) msymbol(o)), ///
	legend(order(1 "marginally below contour" 2 "marginally above contour" 3 "not converged"))

	foreach scl in delta alpha tstat se tau converged {
		capture scalar drop `scl'
	}
	foreach mat in matV matB {
		capture matrix drop `mat'
	}
	foreach var in ur ll {
		capture drop isas_`var'
	}	
end
