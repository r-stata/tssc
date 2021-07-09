////////////////////////////////////////////////////////////////////////////////
// STATA FOR Sasaki, Y. & Xin, Y. (2017): Unequal Spacing in Dynamic Panel Data:
// Identification and Estimation. Journal of Econometrics 196 (2), pp. 320-330.
//
// Use this code for estimation of dynamic panel model when the panel data are
// unequally spaced (or when variables of interest are available in unequally 
// spaced time intervals).
////////////////////////////////////////////////////////////////////////////////
 program define xtusreg, eclass
    version 14.2
 
    syntax varlist(numeric) [if] [in]
    marksample touse
 
	qui xtset
	local panelid   = r(panelvar)
	local timeid  = r(timevar)

    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname b V N

	// The following part focuses on the case of having X
	if "`cnames'" != "" {
	        mata: gmm_estimation("`depvar'", "`cnames'", ///
						 "`panelid'", "`timeid'", ///
						 "`touse'", "`b'", "`V'", "`N'") 
 
			local cnames L1 `cnames'
 
			matrix colnames `b' = `cnames'
			matrix colnames `V' = `cnames'
			matrix rownames `V' = `cnames'
	}
	// The following part focuses on the case of having no X
	if "`cnames'" == "" {
			mata: gmm_estimation_noX("`depvar'", ///
							 "`panelid'", "`timeid'", ///
							 "`touse'", "`b'", "`V'", "`N'") 
 
			local cnames L1 
 
			matrix colnames `b' = `cnames'
			matrix colnames `V' = `cnames'
			matrix rownames `V' = `cnames'
	}

    ereturn post `b' `V', esample(`touse') buildfvinfo
    ereturn scalar N    = `N'
    ereturn local  cmd  "xtusreg"
 
    ereturn display
end
////////////////////////////////////////////////////////////////////////////////
 
mata:
//////////////////////////////////////////////////////////////////////////////// 
// Function for the GMM Criterion
void GMMc(todo, para, tauDeltat, yX, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, W, crit, g, H){
	tau = tauDeltat[1]
	Deltat = tauDeltat[2]
	y = yX[.,1]
	X = yX[.,2..cols(yX)]
	p = cols(X)-1
	gamma = para[1]
	beta = ( para[2..length(para)] )'
	beta = (beta \ 1)
	
	Eg = J((1+p)*length(t0primeYears)*length(t1primeYears)*length(t2primeYears)*length(t3primeYears),1,0)
	index = 1
	for( idx0 = 1 ; idx0 <= length(t0primeYears) ; idx0++ ){
		if( length(t0primeYears) == 1 ){
			t0primeYear = t0primeYears
		}else{
			t0primeYear = t0primeYears[idx0]
		}
		for( idx1 = 1 ; idx1 <= length(t1primeYears) ; idx1++ ){
			if( length(t1primeYears) == 1 ){
				t1primeYear = t1primeYears
			}else{
				t1primeYear = t1primeYears[idx1]
			}
			for( idx2 = 1 ; idx2 <= length(t2primeYears) ; idx2++ ){
				if( length(t2primeYears) == 1 ){
					t2primeYear = t2primeYears
				}else{
					t2primeYear = t2primeYears[idx2]
				}
				for( idx3 = 1 ; idx3 <= length(t3primeYears) ; idx3++ ){
					if( length(t3primeYears) == 1 ){
						t3primeYear = t3primeYears
					}else{
						t3primeYear = t3primeYears[idx3]
					}
					//Begin the Looping Contents////////////////////////////////
					Eg[index,1] = Eg[index,1] + mean ( 
					( select(y, year :== t3primeYear) :* select(y, year :== t3primeYear+Deltat+tau+1) - select(y, year :== t1primeYear) :* select(y, year :== t1primeYear+tau+1) ) -
					( select(y, year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(y, year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) :* gamma -
					( select(y, year :== t3primeYear) :* select(X, year :== t3primeYear+Deltat+tau+1) - select(y, year :== t1primeYear) :* select(X, year :== t1primeYear+tau+1) ) * beta
					)
					index++
					for( jdx = 1 ; jdx <= p ; jdx++ ){
						Eg[index,1] = Eg[index,1] + mean ( 
						( select(X[.,jdx], year :== t3primeYear) :* select(y, year :== t3primeYear+Deltat+tau+1) - select(X[.,jdx], year :== t1primeYear) :* select(y, year :== t1primeYear+tau+1) ) -
						( select(X[.,jdx], year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(X[.,jdx], year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) :* gamma -
						( select(X[.,jdx], year :== t3primeYear) :* select(X, year :== t3primeYear+Deltat+tau+1) - select(X[.,jdx], year :== t1primeYear) :* select(X, year :== t1primeYear+tau+1) ) * beta
						)
						index++
					}
					////////////////////////////////////////////////////////////					
				}
			}
		}
	}

	// Criterion 
	crit = Eg' * W * Eg
}
//////////////////////////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////////////////////////// 
// Function for the GMM Criterion (NO X)
void GMMc_noX(todo, para, tauDeltat, y, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, W, crit, g, H){
	tau = tauDeltat[1]
	Deltat = tauDeltat[2]
	gamma = para
	
	Eg = J(length(t0primeYears)*length(t1primeYears)*length(t2primeYears)*length(t3primeYears),1,0)
	index = 1
	for( idx0 = 1 ; idx0 <= length(t0primeYears) ; idx0++ ){
		if( length(t0primeYears) == 1 ){
			t0primeYear = t0primeYears
		}else{
			t0primeYear = t0primeYears[idx0]
		}
		for( idx1 = 1 ; idx1 <= length(t1primeYears) ; idx1++ ){
			if( length(t1primeYears) == 1 ){
				t1primeYear = t1primeYears
			}else{
				t1primeYear = t1primeYears[idx1]
			}
			for( idx2 = 1 ; idx2 <= length(t2primeYears) ; idx2++ ){
				if( length(t2primeYears) == 1 ){
					t2primeYear = t2primeYears
				}else{
					t2primeYear = t2primeYears[idx2]
				}
				for( idx3 = 1 ; idx3 <= length(t3primeYears) ; idx3++ ){
					if( length(t3primeYears) == 1 ){
						t3primeYear = t3primeYears
					}else{
						t3primeYear = t3primeYears[idx3]
					}
					//Begin the Looping Contents////////////////////////////////
					Eg[index,1] = Eg[index,1] + mean ( 
					( select(y, year :== t3primeYear) :* select(y, year :== t3primeYear+Deltat+tau+1) - select(y, year :== t1primeYear) :* select(y, year :== t1primeYear+tau+1) ) -
					( select(y, year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(y, year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) :* gamma
					)
					index++
					////////////////////////////////////////////////////////////					
				}
			}
		}
	}

	// Criterion 
	crit = Eg' * W * Eg
}
//////////////////////////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////////////////////////// 
// Function to Estimate the Variance Matrix S
void GMMs(para, tauDeltat, yX, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Smatrix){
	tau = tauDeltat[1]
	Deltat = tauDeltat[2]
	y = yX[.,1]
	X = yX[.,2..cols(yX)]
	p = cols(X)-1
	gamma = para[1]
	beta = ( para[2..length(para)] )'
	beta = (beta \ 1)
	
	Eg = J((1+p)*length(t0primeYears)*length(t1primeYears)*length(t2primeYears)*length(t3primeYears),Ni,0)
	index = 1
	for( idx0 = 1 ; idx0 <= length(t0primeYears) ; idx0++ ){
		if( length(t0primeYears) == 1 ){
			t0primeYear = t0primeYears
		}else{
			t0primeYear = t0primeYears[idx0]
		}
		for( idx1 = 1 ; idx1 <= length(t1primeYears) ; idx1++ ){
			if( length(t1primeYears) == 1 ){
				t1primeYear = t1primeYears
			}else{
				t1primeYear = t1primeYears[idx1]
			}
			for( idx2 = 1 ; idx2 <= length(t2primeYears) ; idx2++ ){
				if( length(t2primeYears) == 1 ){
					t2primeYear = t2primeYears
				}else{
					t2primeYear = t2primeYears[idx2]
				}
				for( idx3 = 1 ; idx3 <= length(t3primeYears) ; idx3++ ){
					if( length(t3primeYears) == 1 ){
						t3primeYear = t3primeYears
					}else{
						t3primeYear = t3primeYears[idx3]
					}
					//Begin the Looping Contents////////////////////////////////
					Eg[index,.] = Eg[index,.] + ( 
					( select(y, year :== t3primeYear) :* select(y, year :== t3primeYear+Deltat+tau+1) - select(y, year :== t1primeYear) :* select(y, year :== t1primeYear+tau+1) ) -
					( select(y, year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(y, year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) :* gamma -
					( select(y, year :== t3primeYear) :* select(X, year :== t3primeYear+Deltat+tau+1) - select(y, year :== t1primeYear) :* select(X, year :== t1primeYear+tau+1) ) * beta
					)'
					index++
					for( jdx = 1 ; jdx <= p ; jdx++ ){
						Eg[index,.] = Eg[index,.] + ( 
						( select(X[.,jdx], year :== t3primeYear) :* select(y, year :== t3primeYear+Deltat+tau+1) - select(X[.,jdx], year :== t1primeYear) :* select(y, year :== t1primeYear+tau+1) ) -
						( select(X[.,jdx], year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(X[.,jdx], year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) :* gamma -
						( select(X[.,jdx], year :== t3primeYear) :* select(X, year :== t3primeYear+Deltat+tau+1) - select(X[.,jdx], year :== t1primeYear) :* select(X, year :== t1primeYear+tau+1) ) * beta
						)'
						index++
					}
					////////////////////////////////////////////////////////////					
				}
			}
		}
	}
	Smatrix = Eg * Eg' / Ni - ( Eg * J(Ni,1,1/Ni) ) * ( Eg * J(Ni,1,1/Ni) )'	
}
//////////////////////////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////////////////////////// 
// Function to Estimate the Variance Matrix S (NO X)
void GMMs_noX(para, tauDeltat, y, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Smatrix){
	tau = tauDeltat[1]
	Deltat = tauDeltat[2]
	gamma = para
	
	Eg = J(length(t0primeYears)*length(t1primeYears)*length(t2primeYears)*length(t3primeYears),Ni,0)
	index = 1
	for( idx0 = 1 ; idx0 <= length(t0primeYears) ; idx0++ ){
		if( length(t0primeYears) == 1 ){
			t0primeYear = t0primeYears
		}else{
			t0primeYear = t0primeYears[idx0]
		}
		for( idx1 = 1 ; idx1 <= length(t1primeYears) ; idx1++ ){
			if( length(t1primeYears) == 1 ){
				t1primeYear = t1primeYears
			}else{
				t1primeYear = t1primeYears[idx1]
			}
			for( idx2 = 1 ; idx2 <= length(t2primeYears) ; idx2++ ){
				if( length(t2primeYears) == 1 ){
					t2primeYear = t2primeYears
				}else{
					t2primeYear = t2primeYears[idx2]
				}
				for( idx3 = 1 ; idx3 <= length(t3primeYears) ; idx3++ ){
					if( length(t3primeYears) == 1 ){
						t3primeYear = t3primeYears
					}else{
						t3primeYear = t3primeYears[idx3]
					}
					//Begin the Looping Contents////////////////////////////////
					Eg[index,.] = Eg[index,.] + ( 
					( select(y, year :== t3primeYear) :* select(y, year :== t3primeYear+Deltat+tau+1) - select(y, year :== t1primeYear) :* select(y, year :== t1primeYear+tau+1) ) -
					( select(y, year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(y, year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) :* gamma 					)'
					index++
					////////////////////////////////////////////////////////////					
				}
			}
		}
	}
	Smatrix = Eg * Eg' / Ni - ( Eg * J(Ni,1,1/Ni) ) * ( Eg * J(Ni,1,1/Ni) )'	
}
//////////////////////////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////////////////////////// 
// Function to Estimate the Gradient Matrix G
void GMMg(para, tauDeltat, yX, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Gmatrix){
	tau = tauDeltat[1]
	Deltat = tauDeltat[2]
	y = yX[.,1]
	X = yX[.,2..cols(yX)]
	p = cols(X)-1
	gamma = para[1]
	beta = ( para[2..length(para)] )'
	beta = (beta \ 1)
	
	Eg = J((1+p)*length(t0primeYears)*length(t1primeYears)*length(t2primeYears)*length(t3primeYears),1+p,0)
	index = 1
	for( idx0 = 1 ; idx0 <= length(t0primeYears) ; idx0++ ){
		if( length(t0primeYears) == 1 ){
			t0primeYear = t0primeYears
		}else{
			t0primeYear = t0primeYears[idx0]
		}
		for( idx1 = 1 ; idx1 <= length(t1primeYears) ; idx1++ ){
			if( length(t1primeYears) == 1 ){
				t1primeYear = t1primeYears
			}else{
				t1primeYear = t1primeYears[idx1]
			}
			for( idx2 = 1 ; idx2 <= length(t2primeYears) ; idx2++ ){
				if( length(t2primeYears) == 1 ){
					t2primeYear = t2primeYears
				}else{
					t2primeYear = t2primeYears[idx2]
				}
				for( idx3 = 1 ; idx3 <= length(t3primeYears) ; idx3++ ){
					if( length(t3primeYears) == 1 ){
						t3primeYear = t3primeYears
					}else{
						t3primeYear = t3primeYears[idx3]
					}
					//Begin the Looping Contents////////////////////////////////
					Eg[index,1] = Eg[index,1] + mean( 
					- ( select(y, year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(y, year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) 
					)
					for( kdx = 1 ; kdx <= p ; kdx++ ){
						Eg[index,kdx+1] = Eg[index,kdx+1] + mean( 
						- ( select(y, year :== t3primeYear) :* select(X[.,kdx], year :== t3primeYear+Deltat+tau+1) - select(y, year :== t1primeYear) :* select(X[.,kdx], year :== t1primeYear+tau+1) )
						)
					}
					index++
					for( jdx = 1 ; jdx <= p ; jdx++ ){
						Eg[index,1] = Eg[index,1] + mean( 
						- ( select(X[.,jdx], year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(X[.,jdx], year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) 
						)
						for( kdx = 1 ; kdx <= p ; kdx++ ){
							Eg[index,kdx+1] = Eg[index,kdx+1] + mean( 
							- ( select(X[.,jdx], year :== t3primeYear) :* select(X[.,kdx], year :== t3primeYear+Deltat+tau+1) - select(X[.,jdx], year :== t1primeYear) :* select(X[.,kdx], year :== t1primeYear+tau+1) )
							)
						}
						index++
					}
					////////////////////////////////////////////////////////////					
				}
			}
		}
	}
	Gmatrix = Eg	
}
//////////////////////////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////////////////////////// 
// Function to Estimate the Gradient Matrix G (NO X)
void GMMg_noX(para, tauDeltat, y, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Gmatrix){
	tau = tauDeltat[1]
	Deltat = tauDeltat[2]
	gamma = para
	
	Eg = J(length(t0primeYears)*length(t1primeYears)*length(t2primeYears)*length(t3primeYears),1,0)
	index = 1
	for( idx0 = 1 ; idx0 <= length(t0primeYears) ; idx0++ ){
		if( length(t0primeYears) == 1 ){
			t0primeYear = t0primeYears
		}else{
			t0primeYear = t0primeYears[idx0]
		}
		for( idx1 = 1 ; idx1 <= length(t1primeYears) ; idx1++ ){
			if( length(t1primeYears) == 1 ){
				t1primeYear = t1primeYears
			}else{
				t1primeYear = t1primeYears[idx1]
			}
			for( idx2 = 1 ; idx2 <= length(t2primeYears) ; idx2++ ){
				if( length(t2primeYears) == 1 ){
					t2primeYear = t2primeYears
				}else{
					t2primeYear = t2primeYears[idx2]
				}
				for( idx3 = 1 ; idx3 <= length(t3primeYears) ; idx3++ ){
					if( length(t3primeYears) == 1 ){
						t3primeYear = t3primeYears
					}else{
						t3primeYear = t3primeYears[idx3]
					}
					//Begin the Looping Contents////////////////////////////////
					Eg[index,1] = Eg[index,1] + mean( 
					- ( select(y, year :== t2primeYear) :* select(y, year :== t2primeYear+Deltat+tau) - select(y, year :== t0primeYear) :* select(y, year :== t0primeYear+tau) ) 
					)
					index++
					////////////////////////////////////////////////////////////					
				}
			}
		}
	}
	Gmatrix = Eg	
}
//////////////////////////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////////////////////////// 
// GMM Estimation with X
void gmm_estimation( string scalar depvar,  string scalar indepvars, 
					 string scalar panelid, string scalar timeid,  
					 string scalar touse,   string scalar bname,   
					 string scalar Vname,   string scalar nname) 
{
	printf("\n{hline 78}\n")
	printf("Executing: Sasaki, Y. & Xin, Y. (2017): Unequal Spacing in Dynamic Panel Data:\n")
	printf("Identification and Estimation. Journal of Econometrics 196 (2), pp. 320-330.\n")
	printf("{hline 78}\n")
    real vector y, year
    real matrix X
    real scalar n
 
    y    = st_data(., depvar, touse)
    X    = st_data(., indepvars, touse)
    year = st_data(., timeid, touse)
	id   = st_data(., panelid, touse)
    n    = rows(X)
    // Include constant for the moment //
    X    = X,J(n,1,1)

	////////////////////////////////////////////////////////////////////////////
	// Get Survey Gaps and T(tau)
	////////////////////////////////////////////////////////////////////////////
	maxGap = max(year)-min(year)
	listYears = min(year)..max(year)
	listGaps = 0..maxGap
	Ttau = J(length(listYears), length(listGaps), 0)
	// Make the matrix Ttau (rows are time indices) (columns are gap indices)
	for( idx = 1 ; idx <=length(listYears) ; idx++ ){
		for( jdx = 1 ; jdx <= length(listGaps) ; jdx++ ){
			Ttau[idx,jdx] = max( year :== listYears[idx] ) * max( year :== listYears[idx] + listGaps[jdx] )
		}
	}
	// Look for the first consecutive time gap index
	for( jdx = 1 ; jdx < length(listGaps) ; jdx++ ){
		if( max( Ttau[.,jdx] ) * max( Ttau[.,jdx+1] ) ){
			firxtConsecutiveGapIndex = jdx
			jdx = length(listGaps)
		}
	}
	// Look for the second consecutive time gap index
	for( jdx = firxtConsecutiveGapIndex+1 ; jdx < length(listGaps) ; jdx++ ){
		if( max( Ttau[.,jdx] ) * max( Ttau[.,jdx+1] ) ){
			secondConsecutiveGapIndex = jdx
			jdx = length(listGaps)
		}
	}

	////////////////////////////////////////////////////////////////////////////
	// Get t, t', t'', t'''
	////////////////////////////////////////////////////////////////////////////
	tau0primeIndex = firxtConsecutiveGapIndex
	t0primeYears = select( listYears', Ttau[.,tau0primeIndex] )	
	tau1primeIndex = firxtConsecutiveGapIndex + 1
	t1primeYears = select( listYears', Ttau[.,tau1primeIndex] )	
	tau2primeIndex = secondConsecutiveGapIndex
	t2primeYears = select( listYears', Ttau[.,tau2primeIndex] )	
	tau3primeIndex = secondConsecutiveGapIndex + 1
	t3primeYears = select( listYears', Ttau[.,tau3primeIndex] )	
	////////////////////////////////////////////////////////////////////////////
	// Get Balanced Panel in (t, t', t'', t''')
	////////////////////////////////////////////////////////////////////////////
	listIndividuals = 1..n
	NTmatrix = J( length(listIndividuals), length(t0primeYears), 0 )
	for( idx = 1 ; idx <= length(listIndividuals) ; idx++ ){
		for( jdx = 1 ; jdx <= length(t0primeYears) ; jdx++ ){
			 NTmatrix[idx,jdx] = max( (id :== id[idx]) :* (year :== t0primeYears[jdx]) )
		}
	}
	y = select( y, rowsum(NTmatrix) :== length(t0primeYears) )
	X = select( X, rowsum(NTmatrix) :== length(t0primeYears) )
    year = select( year, rowsum(NTmatrix) :== length(t0primeYears) )
	id = select( id, rowsum(NTmatrix) :== length(t0primeYears) )
	BalancedPanel = (id, year, y, X )
	BalancedPanel = sort(BalancedPanel, 2)
	BalancedPanel = sort(BalancedPanel, 1)
    n = rows(BalancedPanel)      // Number of pooled observations
	Nt = length(t0primeYears)    // Number of individuals in the balanced panel
	Ni = n/Nt                    // Number of time periods in the balanced panel 
	id = BalancedPanel[.,1]
	year = BalancedPanel[.,2]
	y = BalancedPanel[.,3]
	X = BalancedPanel[.,4..cols(BalancedPanel)]
	
	////////////////////////////////////////////////////////////////////////////
	// Location-Scale Normalization as in Appendix C.1
	////////////////////////////////////////////////////////////////////////////
	for( idx = 1 ; idx <= length(listYears) ; idx++ ){
		avg = mean( select(y, year :== year[idx]) )
		var = mean( select(y:^2, year :== year[idx]) ) :- (avg^2)
		y = (year :== year[idx]) :* (y :- avg) :/ var:^0.5 + (year :~= year[idx]) :* y
		
		for( jdx = 1 ; jdx <= cols(x) ; jdx++ ){
			avg = mean( select(X[,jdx], year :== year[idx]) )
			var = mean( select(X[,jdx]:^2, year :== year[idx]) ) :- (avg^2)
			X[,jdx] = (year :== year[idx]) :* (X[,jdx] :- avg) :/ var:^0.5 + (year :~= year[idx]) :* X[,jdx]			
		}
	}

	t0primeYears = t0primeYears[1]
	////////////////////////////////////////////////////////////////////////////
	// GMM 1st Step
	////////////////////////////////////////////////////////////////////////////
	p = cols(X)-1
	tau = 0
	Deltat = secondConsecutiveGapIndex - firxtConsecutiveGapIndex
	W = diag(J((1+p)*length(t0primeYears)*length(t1primeYears)*length(t2primeYears)*length(t3primeYears),1,1))

	printf("{hline 32}\nGMM: 1st Step Estimation\n{hline 32}\n")
	init_gamma = 0
	init_beta = J(1, cols(X)-1, 0)
	init = ( init_gamma, init_beta )
	S = optimize_init()
	optimize_init_evaluator(S,&GMMc())
	optimize_init_which(S,"min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_technique(S,"nr")
	optimize_init_singularHmethod(S,"hybrid") 
	optimize_init_argument(S,1,(tau,Deltat))
	optimize_init_argument(S,2,(y,X))
	optimize_init_argument(S,3,year)
	optimize_init_argument(S,4,t0primeYears)
	optimize_init_argument(S,5,t1primeYears)
	optimize_init_argument(S,6,t2primeYears)
	optimize_init_argument(S,7,t3primeYears)
	optimize_init_argument(S,8,W)
	optimize_init_params(S, init)
	est=optimize(S)	
	
	////////////////////////////////////////////////////////////////////////////
	// Variance Estimation (Estimation of S)
	////////////////////////////////////////////////////////////////////////////
	real matrix Smatrix
	GMMs(est, (tau,Deltat), (y,X), year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Smatrix)
	W = luinv(Smatrix)
	
	////////////////////////////////////////////////////////////////////////////
	// GMM 2nd Step
	////////////////////////////////////////////////////////////////////////////
	printf("{hline 32}\nGMM: 2nd Step Estimation\n{hline 32}\n")
	init_gamma = 1
	init_beta = J(1, cols(X)-1, 2)
	init = ( init_gamma, init_beta )
	S = optimize_init()
	optimize_init_evaluator(S,&GMMc())
	optimize_init_which(S,"min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_technique(S,"nr")
	optimize_init_singularHmethod(S,"hybrid") 
	optimize_init_argument(S,1,(tau,Deltat))
	optimize_init_argument(S,2,(y,X))
	optimize_init_argument(S,3,year)
	optimize_init_argument(S,4,t0primeYears)
	optimize_init_argument(S,5,t1primeYears)
	optimize_init_argument(S,6,t2primeYears)
	optimize_init_argument(S,7,t3primeYears)
	optimize_init_argument(S,8,W)
	optimize_init_params(S, init)
	est=optimize(S)
	
	////////////////////////////////////////////////////////////////////////////
	// Variance Estimation (Estimation of S)
	////////////////////////////////////////////////////////////////////////////
	GMMs(est, (tau,Deltat), (y,X), year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Smatrix)
	W = luinv(Smatrix)
	
	////////////////////////////////////////////////////////////////////////////
	// Gradient Estimation (Estimation of G)
	////////////////////////////////////////////////////////////////////////////
	real matrix Gmatrix
	GMMg(est, (tau,Deltat), (y,X), year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Gmatrix)

	b = est'
	V = luinv(Gmatrix'*W*Gmatrix) / Ni 

    st_matrix(bname, b')
    st_matrix(Vname, V)
    st_numscalar(nname, n)
	
	printf("\nBalanced Portion of Panel Data")
	printf("\n{hline 78}")
	printf("\nNumber of observations:          %f ", n)
	printf("\nNumber of cross-section units:   %f ", Ni)
	printf("\nNumber of time periods:          %f ", Nt)
	printf("\n{hline 78}")
	printf("\nL1 = Autoregressive Coefficient (rho)\n")
}

//////////////////////////////////////////////////////////////////////////////// 
// GMM Estimation with NO X
void gmm_estimation_noX( string scalar depvar,  
						 string scalar panelid, string scalar timeid,  
						 string scalar touse,   string scalar bname,   
						 string scalar Vname,   string scalar nname) 
{
	printf("\n{hline 78}\n")
	printf("Executing: Sasaki, Y. & Xin, Y. (2017): Unequal Spacing in Dynamic Panel Data:\n")
	printf("Identification and Estimation. Journal of Econometrics 196 (2), pp. 320-330.\n")
	printf("{hline 78}\n")
    real vector y, year
    real scalar n
 
    y    = st_data(., depvar, touse)
    year = st_data(., timeid, touse)
	id   = st_data(., panelid, touse)
    n    = rows(y)

	////////////////////////////////////////////////////////////////////////////
	// Get Survey Gaps and T(tau)
	////////////////////////////////////////////////////////////////////////////
	maxGap = max(year)-min(year)
	listYears = min(year)..max(year)
	listGaps = 0..maxGap
	Ttau = J(length(listYears), length(listGaps), 0)
	// Make the matrix Ttau (rows are time indices) (columns are gap indices)
	for( idx = 1 ; idx <=length(listYears) ; idx++ ){
		for( jdx = 1 ; jdx <= length(listGaps) ; jdx++ ){
			Ttau[idx,jdx] = max( year :== listYears[idx] ) * max( year :== listYears[idx] + listGaps[jdx] )
		}
	}
	// Look for the first consecutive time gap index
	for( jdx = 1 ; jdx < length(listGaps) ; jdx++ ){
		if( max( Ttau[.,jdx] ) * max( Ttau[.,jdx+1] ) ){
			firxtConsecutiveGapIndex = jdx
			jdx = length(listGaps)
		}
	}
	// Look for the second consecutive time gap index
	for( jdx = firxtConsecutiveGapIndex+1 ; jdx < length(listGaps) ; jdx++ ){
		if( max( Ttau[.,jdx] ) * max( Ttau[.,jdx+1] ) ){
			secondConsecutiveGapIndex = jdx
			jdx = length(listGaps)
		}
	}

	////////////////////////////////////////////////////////////////////////////
	// Get t, t', t'', t'''
	////////////////////////////////////////////////////////////////////////////
	tau0primeIndex = firxtConsecutiveGapIndex
	t0primeYears = select( listYears', Ttau[.,tau0primeIndex] )	
	tau1primeIndex = firxtConsecutiveGapIndex + 1
	t1primeYears = select( listYears', Ttau[.,tau1primeIndex] )	
	tau2primeIndex = secondConsecutiveGapIndex
	t2primeYears = select( listYears', Ttau[.,tau2primeIndex] )	
	tau3primeIndex = secondConsecutiveGapIndex + 1
	t3primeYears = select( listYears', Ttau[.,tau3primeIndex] )	

	////////////////////////////////////////////////////////////////////////////
	// Get Balanced Panel in (t, t', t'', t''')
	////////////////////////////////////////////////////////////////////////////
	listIndividuals = 1..n
	NTmatrix = J( length(listIndividuals), length(t0primeYears), 0 )
	for( idx = 1 ; idx <= length(listIndividuals) ; idx++ ){
		for( jdx = 1 ; jdx <= length(t0primeYears) ; jdx++ ){
			 NTmatrix[idx,jdx] = max( (id :== id[idx]) :* (year :== t0primeYears[jdx]) )
		}
	}
	y = select( y, rowsum(NTmatrix) :== length(t0primeYears) )
	
    year = select( year, rowsum(NTmatrix) :== length(t0primeYears) )
	id = select( id, rowsum(NTmatrix) :== length(t0primeYears) )
	BalancedPanel = (id, year, y)
	BalancedPanel = sort(BalancedPanel, 2)
	BalancedPanel = sort(BalancedPanel, 1)
    n = rows(BalancedPanel)      // Number of pooled observations
	Nt = length(t0primeYears)    // Number of individuals in the balanced panel
	Ni = n/Nt                    // Number of time periods in the balanced panel 
	id = BalancedPanel[.,1]
	year = BalancedPanel[.,2]
	y = BalancedPanel[.,3]
	
	////////////////////////////////////////////////////////////////////////////
	// Location-Scale Normalization as in Appendix C.1
	////////////////////////////////////////////////////////////////////////////
	for( idx = 1 ; idx <= length(listYears) ; idx++ ){
		avg = mean( select(y, year :== year[idx]) )
		var = mean( select(y:^2, year :== year[idx]) ) :- (avg^2)
		y = (year :== year[idx]) :* (y :- avg) :/ var:^0.5 + (year :~= year[idx]) :* y
	}

	t0primeYears = t0primeYears[1]
	////////////////////////////////////////////////////////////////////////////
	// GMM 1st Step
	////////////////////////////////////////////////////////////////////////////
	tau = 0
	Deltat = secondConsecutiveGapIndex - firxtConsecutiveGapIndex
	W = diag(J(length(t0primeYears)*length(t1primeYears)*length(t2primeYears)*length(t3primeYears),1,1))
	
	printf("{hline 32}\nGMM: 1st Step Estimation\n{hline 32}\n")
	init_gamma = 0
	init = J(1,1, init_gamma )
	S = optimize_init()
	optimize_init_evaluator(S,&GMMc_noX())
	optimize_init_which(S,"min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_technique(S,"nr")
	optimize_init_singularHmethod(S,"hybrid") 
	optimize_init_argument(S,1,(tau,Deltat))
	optimize_init_argument(S,2,y)
	optimize_init_argument(S,3,year)
	optimize_init_argument(S,4,t0primeYears)
	optimize_init_argument(S,5,t1primeYears)
	optimize_init_argument(S,6,t2primeYears)
	optimize_init_argument(S,7,t3primeYears)
	optimize_init_argument(S,8,W)
	optimize_init_params(S, init)
	est=optimize(S)	

	////////////////////////////////////////////////////////////////////////////
	// Variance Estimation (Estimation of S)
	////////////////////////////////////////////////////////////////////////////
	real matrix Smatrix
	GMMs_noX(est, (tau,Deltat), y, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Smatrix)
	W = luinv(Smatrix)
	
	////////////////////////////////////////////////////////////////////////////
	// GMM 2nd Step
	////////////////////////////////////////////////////////////////////////////
	printf("{hline 32}\nGMM: 2nd Step Estimation\n{hline 32}\n")
	init_gamma = 1
	init = ( init_gamma )
	S = optimize_init()
	optimize_init_evaluator(S,&GMMc_noX())
	optimize_init_which(S,"min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_technique(S,"nr")
	optimize_init_singularHmethod(S,"hybrid") 
	optimize_init_argument(S,1,(tau,Deltat))
	optimize_init_argument(S,2,y)
	optimize_init_argument(S,3,year)
	optimize_init_argument(S,4,t0primeYears)
	optimize_init_argument(S,5,t1primeYears)
	optimize_init_argument(S,6,t2primeYears)
	optimize_init_argument(S,7,t3primeYears)
	optimize_init_argument(S,8,W)
	optimize_init_params(S, init)
	est=optimize(S)
	
	////////////////////////////////////////////////////////////////////////////
	// Variance Estimation (Estimation of S)
	////////////////////////////////////////////////////////////////////////////
	GMMs_noX(est, (tau,Deltat), y, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Smatrix)
	W = luinv(Smatrix)
	
	////////////////////////////////////////////////////////////////////////////
	// Gradient Estimation (Estimation of G)
	////////////////////////////////////////////////////////////////////////////
	real matrix Gmatrix
	GMMg_noX(est, (tau,Deltat), y, year, t0primeYears, t1primeYears, t2primeYears, t3primeYears, Ni, Gmatrix)

	b = est'
	V = luinv(Gmatrix'*W*Gmatrix) / Ni 

    st_matrix(bname, b')
    st_matrix(Vname, V)
    st_numscalar(nname, n)

	////////////////////////////////////////////////////////////////////////////
	// Compute list of years
	////////////////////////////////////////////////////////////////////////////
	listyears = year
	index = 1
	for( idx = 2 ; idx <= n ; idx++ ){
		if( sum( year[idx] :== listyears[1..index] ) == 0 ){
			listyears[index++] = year[idx]
		}
	}
	listyears = listyears[1..(index-1)]
	listyears = sort(listyears, 1)
	
	printf("\nBalanced Portion of Panel Data")
	printf("\n{hline 78}")
	printf("\nNumber of observations:          %f ", n)
	printf("\nNumber of cross-section units:   %f ", Ni)
	printf("\nNumber of time periods:          %f ", Nt)
	printf("\nList of time periods:            %f", listyears[1])
	for( idx = 2 ; idx <= length(listyears) ; idx++ ){
	    printf(", %f", listyears[idx])
	}
	printf("\n{hline 78}")
	printf("\nL1 = Autoregressive Coefficient (rho)\n")
}

end
////////////////////////////////////////////////////////////////////////////////

