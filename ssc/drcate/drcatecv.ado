/* Stata function for 
Sokbae Lee, Ryo Okui, and Yoon-Jae Whang. "Doubly robust uniform band 
for the conditional average treatment effect function," (2017) Journal of Applied Econometrics
*/

capture prog drop drcateCV
program define drcateCV, eclass
    
	version 15.0
	syntax varlist(min=4 numeric)[, alpha(real 0.05) bwidth(real 0) graph(string) ci(string) ps(string) ate(string)]
	
	capture drop ghat
	capture drop x_axis
	capture drop cblower
	capture drop cbupper
	capture drop ATE
	capture drop psi
	capture drop pi_hat
	capture graph drop CATE
	
	if (("`ps'"!= "logit")&("`ps'"!= "probit")) {
		display as error "error: ps should be specified as 'logit' or 'probit'"
	    exit
	}
    mata: alpha = `alpha'
	
	// sample size
	local n = _N  
	// number of variables 
	local k = 0  
	// dependent variable 
	local Y "Y"
	// treatment variable 
	local D "D"
	// covariate of interest 
	local X "X"
	// all covariates 
	local Z "Z"
	// remaining covariates
	local V "V"
	// confidence
	local conf = 100 * (1 - `alpha')
	                                                  
	foreach var in `varlist'{
		local k = `k'+1
		if (`k' == 1) {
			local Y "`var'"                            
		}
		if (`k' == 2) {
		    local D "`var'"                           
		}
		if (`k' == 3) {
		    local X "`var'"                            
		    local Z "`var'"                            
		}
		if (`k' == 4) {
			local V "`var'"                            
		    local Z "`Z' `var'"                            
		}
		if (`k' > 4) {
		    local V "`V' `var'"
			local Z "`Z' `var'" 
		}
	}
	mata: n = `n'
	mata: k = `k'
	mata: Y = st_data(.,"`Y'")
	mata: D = st_data(.,"`D'")
	mata: X = st_data(.,"`X'")
	mata: V = st_data(.,"`V'")
	mata: Z = st_data(.,"`Z'")
    
	// propensity score
	if ("`ps'" == "logit"){                           
		qui logistic `D' `Z'
		predict pi_hat, pr
	}	

	if ("`ps'" == "probit"){
		qui probit `D' `Z'
		predict pi_hat, pr
	}	
	mata: pi_hat = st_data(.,"pi_hat")
	
	// regression
	qui reg `Y' `Z' if `D' == 1                       
	mata: coef_1 = st_matrix("e(b)")'
	qui reg `Y' `Z' if `D' == 0
	mata: coef_0 = st_matrix("e(b)")'
	
	************
	*** MATA ***
	************
	mata{
		* fitted value of regression
		Z_const = (Z, J(rows(Z),1,1))
	    mu_1 = Z_const * coef_1
		mu_0 = Z_const * coef_0
		
		* conditional ATE given all Zs
		psi_1 = D :* Y :/ pi_hat - (D - pi_hat) :* mu_1 :/ pi_hat                   
		psi_0 = (1 :- D) :* Y :/ (1 :- pi_hat) + (D - pi_hat) :* mu_0 :/ (1 :- pi_hat)  
		psi = psi_1 - psi_0  
		temp = st_addvar("double", "psi")
		st_store(.,"psi", psi)
		
		* unconditional ATE
		ate = mean(psi)
	}	
	
	// bandwidth selection
	if (`bwidth'==0){
		qui npregress kernel psi `X', kernel(gaussian)
		mata: h = st_matrix("e(meanbwidth)")* n^(1/5) * n^(-2/7)
	}
	else{
		mata: h = `bwidth'
	}
	mata: temp = st_local("bwidth", strofreal(h))
	
	
	// local linear regression
	mata{
		N = 100
		x_min = sort(X, 1)[floor(0.1 * n)]
		x_max = sort(X, 1)[ceil(0.9 * n)]
		x_axis = rangen(x_min, x_max, N)
		
		temp = st_addvar("double", "x_axis")
		st_addobs(max((0,N  - st_nobs())))
		st_store(.,"x_axis", x_axis\J(st_nobs()-rows(x_axis),1,.))
	}
	
	qui lpoly psi `X', ker(gaussian) bwidth(`bwidth') degree(1) at(x_axis) gen(ghat) nogr 
	mata{
		ghat = st_data(.,"ghat")
		
		*** Standard Errors
		rk = 0.2820948
		lambda = 0.5
		fX_hat = J(N, 1, 0)
		sigmasq_hat = J(N, 1, 0)
		s_hat = J(N, 1, 0)
		for (i=1; i <= N; i++){
			fX_hat[i] = mean(normalden((x_axis[i] :- X):/h))/h
			sigmasq_hat[i] = mean((psi :- ghat[i]):^2 :* normalden((X :- x_axis[i])/h))/(fX_hat[i] * h)
			sigmasq_hat[i] = sigmasq_hat[i] * n / (n - 3 * (k - 2) - 3)
			s_hat[i] = sqrt(rk * sigmasq_hat[i] / fX_hat[i])
		}
		
		*** level alpha critical value
		a2 = 2*log(h^(-1)*(x_max-x_min))+2*log(lambda^(1/2)/(2*`c(pi)'))
		if (a2 >= 0){
			a = sqrt(a2)
		}else{
			a = 0
		}
		critical = sqrt(a^2 - 2*log(log((1 - alpha)^(-1/2))))
		
		*** confidence interval
		sg_hat = s_hat/sqrt(n*h)
		cblower = J(N, 1, 0)
		cbupper = J(N, 1, 0)
		cblower = ghat[1::N] - critical * sg_hat
		cbupper = ghat[1::N] + critical * sg_hat

		y_max = max(cbupper)
		y_min = min(cblower)
		y_max = (y_max - y_min) / 2 + y_max
		y_min = y_min - (y_max - y_min) / 3 
		
		temp = st_addvar("double", "cblower")
		temp = st_addvar("double", "cbupper")
		temp = st_addvar("double", "ATE")
		st_store(.,"cblower", cblower\J(st_nobs()-rows(x_axis),1,.))
		st_store(.,"cbupper", cbupper\J(st_nobs()-rows(x_axis),1,.))
		st_store(.,"ATE", J(N, 1, ate)\J(st_nobs()-rows(x_axis),1,.))
	}
	
	// Plotting
	if !("`graph'" == "off"){
		if( "`ci'"=="off"){
			if ("`ate'" == "off"){
				line ghat x_axis, ytitle("`Y'") ///
									xtitle("`X'") xlabel(minmax)  ///
									legend(cols(1) order(1 "CATE"))
				graph rename CATE
			}
			else{
				line ghat ATE x_axis, lpattern(3 dash) ytitle("`Y'") ///
									xtitle("`X'") xlabel(minmax)  ///
									legend(cols(2) order(2 "ATE" 1 "CATE"))
				graph rename CATE
			}
		}
		else{
			if ("`ate'"=="off"){
				graph twoway rarea cbupper cblower x_axis, color(gs14) || line ghat x_axis, ytitle("`Y'") ///
									xtitle("`X'") xlabel(minmax)  ///
									legend(cols(2) order(2 "CATE" 1 "`conf'% C.I." ))
				graph rename CATE
			}
			else{
				graph twoway rarea cbupper cblower x_axis, color(gs14) || line ghat ATE x_axis, ytitle("`Y'") ///
									lpattern(3 dash) xtitle("`X'") xlabel(minmax)  ///
									legend(cols(2) order(3 "ATE" 2 "CATE" 1 "`conf'% C.I." ))
				graph rename CATE
			}
		}
	}
	
	// Data Management
	drop cbupper cblower psi ghat x_axis ATE pi_hat
	qui keep in 1/`n'
	
	// ereturn
	ereturn clear
	ereturn scalar bwidth = `bwidth'
	ereturn local depvar `"`Y'"'
	ereturn local treatment `"`D'"'
	ereturn local covint `"`X'"'
	ereturn local remainings `"`V'"'
	
end
