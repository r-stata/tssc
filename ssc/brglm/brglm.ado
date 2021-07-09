* Version 1.0.0 - 14 November 2017

* By Johannes S. Kunz, Kevin E. Staub & Rainer Winkelmann
* See helpfile for explanations. 
* Please email kevin.staub@unimelb.edu.au for help or support.

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

cap program drop brglm
	program brglm, eclass sortpreserve
	version 14.0
	syntax varlist(numeric ts fv) [if] [in]  [ , MODEL(string) ITERate(integer 5000) ///
										 TOLerance(real 1.000e-6) *] 
	tempvar nobs depn eta mu dmudeta v w z xb qi hi touse
	tempname b V bold tol maxiter val VAL iter bold ystar converged logl ll
	
	if "`model'" == "" local model "probit"

	else if !inlist("`model'", "probit", "logit", "cloglog")  {
	    di as err "must choose model probit, logit, or cloglog"
	    exit 198
	    }

	gettoken lhs rhs : varlist
	_fv_check_depvar `lhs'				//check for factor variables 
	_rmcoll `rhs', expand				//check and not collinearities 
	marksample touse    				// if  `touse' `in' used to drop missings in covariate, does not work yet
	
	* Initial values for eta from OLS
	qui reg `lhs' `rhs' if `touse', `options'
	qui predict `eta' if `touse' , xb
	mat `bold' = e(b)
	
	sca `tol' = `tolerance' 	// tolerance level for convergence
	sca `maxiter' = `iterate'	// maximum number of iterations

	* Entering WLS loop
	sca `val' = 1			// initialising convergence value
	local iter = 0			// initialising iteration number
	while `val'>`tol' & `iter'<`maxiter' {
		
		if "`model'"=="probit" {
			qui g double `mu'  		= normal(`eta')		
			qui g double `dmudeta' 	= normalden(`eta')	
			qui g double `v' 		= `mu'*(1-`mu')
			}

		if "`model'"=="cloglog" {
			qui g double `mu'  		= 1 - exp( -exp(`eta') )	//pi
			qui g double `dmudeta' 	= (1-`mu')*exp(`eta')		//d
			qui g double `v' 		= (1-`mu')*`mu'
			}	

		if "`model'"=="logit" {
			qui g double `mu'  		= 1/(1+exp(-`eta'))	
			qui g double `dmudeta' 	= `mu'*(1-`mu')	
			qui g double `v' 		= `mu'*(1-`mu')
			}
			
			
		qui g double `w' 		= `dmudeta'^2 / `v'	// weight for IWLS
			
		mata: W=X=.
		mata: st_view(X,.,"`rhs'")
		mata: X = X, J(rows(X), 1, 1)
		mata: st_view(W,.,"`w'")
		mata: Q = diagonal( X * invsym( cross(X,W,X) ) * X' ) // Q is the diagonal of the matrix Q = X (X'WX) X' in McCullagh & Nelder
		getmata `qi' = Q						
		qui g double `hi' = `qi'*`w' 							  // H = W^{1/2} X (X'WX)^{-1} X' W^{1/2}	

		if "`model'"=="probit" { // pseudo-responses for probit
			qui g double `ystar' = `lhs' - `hi'*`v'*`eta'/(2*`dmudeta') 
			}
		if "`model'"=="cloglog" { // pseudo-responses for logit
			qui g double `ystar' = `lhs' + `hi'*`mu' * (1-exp(`eta'))/(2*exp(`eta')) 
			}
		if "`model'"=="logit" { // pseudo-responses for logit
			qui g double `ystar' = `lhs' + `hi'*(1/2-`mu') 
			}
			
		qui g double `z'   		= `eta' + (`ystar' - `mu') * (1/`dmudeta') // dep. var. for IWLS

		qui reg `z' `rhs' [aweight=`w'] if `touse'	, `options' // WLS 
		qui predict `xb' if `touse' , xb
		mat `VAL' = ( e(b)-`bold' )' * ( e(b)-`bold' ) // updating convergence value
		sca `val' = `VAL'[1,1]
		qui replace `eta' = `xb'				// updating eta=x'b
		mat `bold' = e(b)						// updating betas
		mat `b' = e(b)							// store betas
		*mata:  V = (150/(150-2)):*Q						// store VCOV Matrix 
		*getmata `V'=V , replace
		mat `V' = e(V)							// store betas		
		local iter = `iter' + 1					// updating iteration number
		di in green "Iteration `iter'" in green "    tol = " in yellow `val'
		
		local converged=1
		if `val'<=`tol' | `iter'==`maxiter' {			
			if `iter'==`maxiter' {
				di in red "Warning: Convergence not achieved."
					local converged=0								//Convergence achived, store
				}
			}
		if "`model'"=="probit" { 									//calc loglikelihood values
			qui g double `logl'= `lhs'*ln(`mu')+(1-`lhs')*ln(1-`mu')
			}
		if "`model'"=="cloglog" {  
			qui g double `logl'= `lhs'*ln(`mu')+(1-`lhs')*ln(1-`mu')
			}	
		if "`model'"=="logit" {
			qui g double `logl'= `lhs'*ln(`mu')+(1-`lhs')*ln(1-`mu')
			}	
		qui su `logl'
		local ll=r(sum)									//Store ll-values
		drop `mu' `dmudeta' `v' `w' `z' `xb' `qi' `hi' `ystar' `logl'
		}
	
	di "" 	// Example in PPML; display options in gml; 
	di as txt "Biased-reduced `model' glm regression" /*   // Estimation name and number of parameters
		*/ _col(51) "No. of obs"        _col(67) "=" /*
		*/ _col(69) as res %10.0gc e(N)
	di ""												   //add pseudo R^2?
	di ""
	di as text  "Log-likelihood: " as result e(ll)        // Display log-likelihood
	di ""												  //add if robust/cluster notification
	local depn "`lhs'"
	local N=e(N)
	ereturn local depvar "`lhs'"
	ereturn post `b' `V' ,  depname("`depn'") esample(`touse') 
	ereturn display
	ereturn scalar converged=`converged'
	ereturn scalar ll = `ll'
	ereturn scalar N = `N'
	ereturn local model "`model'" // set e(cmd) last		
	ereturn local cmd "brglm" // set e(cmd) last		
end
