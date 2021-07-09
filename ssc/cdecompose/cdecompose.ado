////////////////////////////////////////////////////////////////////////////////
// STATA FOR  Hu, Y., Moffitt, R., & Sasaki, Y. (2019): Semiparametric 
//            Estimation of the Canonical Permanent‐Transitory Model of Earnings 
//            Dynamics. Quantitative Economics 10 (4), 1495-1536.
//
// Use it when you consider a state space model where the observed process is an
// sum of permanent and transitory components. The command draws the densities
// of the perment and transitory components .
////////////////////////////////////////////////////////////////////////////////
program define cdecompose, eclass
    version 14.2
 
    syntax varlist(min=2 numeric) [if] [in] [, p(real 1) q(real 1) delta(real 5) nboot(real 1000)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname N b V

	mata: estimate_moments("`depvar'", "`cnames'", ///
						   `p', `q', ///
						   `delta', `nboot', ///
				           "`touse'", "`N'", ///
						   "`b'", "`V'") 
						   
	mata: bootstrap_moments("`depvar'", "`cnames'", ///
						    `p', `q', ///
						    `delta', `nboot', ///
				            "`touse'", "`N'", ///
						    "`b'", "`V'") 

	local cnames U_Mean U_Std_Dev U_Skewness U_Kurtosis V_Mean V_Std_Dev V_Skewness V_Kurtosis
 	matrix colnames `b' = `cnames'
	matrix colnames `V' = `cnames'
	matrix rownames `V' = `cnames'
	
	

    ereturn post `b' `V', esample(`touse') buildfvinfo
    ereturn scalar N    = `N'
    ereturn local  cmd  "cdecompose"
 
    ereturn display
end

		
		
		
		
mata:
//////////////////////////////////////////////////////////////////////////////// 
// Estimation
void estimate_moments( string scalar y1v,    		  string scalar y2v,	
					   real scalar p,	  	  		  real scalar q,	
					   real scalar delta,	  	  	  real scalar num_boot,	
					   string scalar touse,   		  string scalar nname,
					   string scalar bname,   		  string scalar vname) 
{
	printf("\n{hline 78}\n")
	printf("Executing: Hu, Y., Moffitt, R., & Sasaki, Y. (2019): Semiparametric Estimation\n")
	printf("           of the Canonical Permanent‐Transitory Model of Earnings Dynamics.  \n")	
	printf("           Quantitative Economics 10 (4), 1495-1536.                          \n")
	printf("{hline 78}\n")
 
    y = st_data(., y1v, touse), st_data(., y2v, touse)
    n  = rows(y)
	// Set main index (t)
	tdx = p+q+1
	//tdx
	// Check the following is true
	if( cols(y) < p+q+2+q ){
		printf("Error: The number of variables must be at least p+2q+2=%f.\n", p+2*q+2)	
	}
	// Demean y
	mean_y = mean(y[.,tdx])
	y = y :- mean_y
	// Set the 100 times the precision of numerical derivative in the frequency domain
	//delta = 100
	// Set slist
	slist = (-trunc(5*delta)..trunc(5*delta)) / 100
	slist_interval = slist[2] - slist[1]
	
	printf("Estimating the moments\n")
	////////////////////////////////////////////////////////////////////////////
	// Estimate rho	
	if( p > 0 ){
		pprime = 0
		Delta0 = y[.,tdx+1-pprime]:-y[.,tdx-q]:-y[.,tdx-pprime]:+y[.,tdx-q-1]:+y[.,tdx-q]:-y[.,tdx-q-1]
		pprime = 1
		Delta = y[.,tdx+1-pprime]:-y[.,tdx-q]:-y[.,tdx-pprime]:+y[.,tdx-q-1]:+y[.,tdx-q]:-y[.,tdx-q-1]
		if( p > 1 ){
			for( pprime = 2 ; pprime <= p ; pprime++ ){
				 Delta = Delta, y[.,tdx+1-pprime]:-y[.,tdx-q]:-y[.,tdx-pprime]:+y[.,tdx-q-1]:+y[.,tdx-q]:-y[.,tdx-q-1]
			}
		}
		rho = luinv( (y[.,tdx :- ((q+1)..(p+q))])' * Delta :+ 0.05:*diag(J(p,1,n)) ) * (y[.,tdx :- ((q+1)..(p+q))])' * Delta0
	//	rho
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate mu	
	mu = y[.,tdx+q+1] - y[.,tdx]
	if( p > 0 ){
		for( pprime = 1 ; pprime <= p ; pprime++ ){
			mu = mu :- rho[pprime] :* ( y[.,tdx+q+1-pprime] - y[.,tdx] )
		}
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate kappa	
	kappa = -1
	if( p > 0 ){
		for( pprime = 1 ; pprime <= p ; pprime++ ){
			kappa = kappa + rho[pprime]
		}
	}
	//kappa 
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate phi_v
	phi_v_integrand = slist :* (0+0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
	s = slist[idx]
	phi_v_integrand[idx] = sum( (0+1i) :* mu :* exp( (0+1i):*s:*y[.,tdx] ) ) / sum( kappa :* exp( (0+1i):*s:*y[.,tdx] ) )
	}
	//phi_v_integrand'
	
	phi_v = slist :* (0+0i)
	middle = trunc(length(slist) / 2) + 1
	for( idx = middle + 1 ; idx <= length(slist) ; idx++ ){
		phi_v[idx] = phi_v[idx-1] + phi_v_integrand[idx] * slist_interval
	}
	for( idx = middle - 1 ; idx >= 1 ; idx-- ){
		phi_v[idx] = phi_v[idx+1] - phi_v_integrand[idx] * slist_interval
	}
	phi_v = exp( phi_v )
	//phi_v'
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate phi_u
	phi_y = slist :* (0+0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_y[idx] = sum( exp( (0+1i):*s:*y[.,tdx] ) ) / n
	}
	phi_u = phi_y :/ phi_v
	//phi_u'
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate derivatives of the characteristic functions
	phi_u_d1 = slist :* (0+0i)
	phi_v_d1 = slist :* (0+0i)
	phi_u_d2 = slist :* (0+0i)
	phi_v_d2 = slist :* (0+0i)
	phi_u_d3 = slist :* (0+0i)
	phi_v_d3 = slist :* (0+0i)
	phi_u_d4 = slist :* (0+0i)
	phi_v_d4 = slist :* (0+0i)
	
	for( idx = delta+1 ; idx <= length(slist)-delta ; idx++ ){
		phi_u_d1[idx] = (phi_u[idx+delta]-phi_u[idx-delta])/(slist[idx+delta]-slist[idx-delta])
		phi_v_d1[idx] = (phi_v[idx+delta]-phi_v[idx-delta])/(slist[idx+delta]-slist[idx-delta])
	}
	//phi_u_d1', phi_v_d1'
	
	for( idx = 2*delta+1 ; idx <= length(slist)-2*delta ; idx++ ){
		phi_u_d2[idx] = (phi_u_d1[idx+delta]-phi_u_d1[idx-delta])/(slist[idx+delta]-slist[idx-delta])
		phi_v_d2[idx] = (phi_v_d1[idx+delta]-phi_v_d1[idx-delta])/(slist[idx+delta]-slist[idx-delta])
	}
	//phi_u_d2', phi_v_d2'
	
	for( idx = 3*delta+1 ; idx <= length(slist)-3*delta ; idx++ ){
		phi_u_d3[idx] = (phi_u_d2[idx+delta]-phi_u_d2[idx-delta])/(slist[idx+delta]-slist[idx-delta])
		phi_v_d3[idx] = (phi_v_d2[idx+delta]-phi_v_d2[idx-delta])/(slist[idx+delta]-slist[idx-delta])
	}
	//phi_u_d3', phi_v_d3'
	
	for( idx = 4*delta+1 ; idx <= length(slist)-4*delta ; idx++ ){
		phi_u_d4[idx] = (phi_u_d3[idx+delta]-phi_u_d3[idx-delta])/(slist[idx+delta]-slist[idx-delta])
		phi_v_d4[idx] = (phi_v_d3[idx+delta]-phi_v_d3[idx-delta])/(slist[idx+delta]-slist[idx-delta])
	}
	//phi_u_d4', phi_v_d4'
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate moments
	u_m1 = sum( phi_u_d1[((middle-delta)..(middle+delta))] ) / (0+1i) / (2*delta+1)
	u_m2 = sum( phi_u_d2[((middle-delta)..(middle+delta))] ) / (-1+0i) / (2*delta+1)
	u_m3 = sum( phi_u_d3[((middle-delta)..(middle+delta))] ) / (0-1i) / (2*delta+1)
	u_m4 = sum( phi_u_d4[((middle-delta)..(middle+delta))] ) / (1+0i) / (2*delta+1)
	
	v_m1 = sum( phi_v_d1[((middle-delta)..(middle+delta))] ) / (0+1i) / (2*delta+1)
	v_m2 = sum( phi_v_d2[((middle-delta)..(middle+delta))] ) / (-1+0i) / (2*delta+1)
	v_m3 = sum( phi_v_d3[((middle-delta)..(middle+delta))] ) / (0-1i) / (2*delta+1)
	v_m4 = sum( phi_v_d4[((middle-delta)..(middle+delta))] ) / (1+0i) / (2*delta+1)
	
	//u_m1, u_m2, u_m3, u_m4
	//v_m1, v_m2, v_m3, v_m4
	
	mean_u = u_m1
	sd_u = ( u_m2 - u_m1^2 )^0.5
	skew_u = ( u_m3 - 3*u_m2*mean_u + 3*u_m1*mean_u^2 - mean_u^3 ) / sd_u^3
	kurt_u = ( u_m4 - 4*u_m3*mean_u + 6*u_m2*mean_u^2 - 4*u_m1*mean_u^3 + mean_u^4 ) / sd_u^4
	
	mean_v = v_m1
	sd_v = ( v_m2 - v_m1^2 )^0.5
	skew_v = ( v_m3 - 3*v_m2*mean_v + 3*v_m1*mean_v^2 - mean_v^3 ) / sd_v^3
	kurt_v = ( v_m4 - 4*v_m3*mean_v + 6*v_m2*mean_v^2 - 4*v_m1*mean_v^3 + mean_v^4 ) / sd_v^4
	
	//mean_u, sd_u, skew_u, kurt_u
	//mean_v, sd_v, skew_v, kurt_v
	
	b = mean_u, abs(sd_u), skew_u, abs(kurt_u), mean_v, abs(sd_v), skew_v, abs(kurt_v)
	b = Re(b)
	
	////////////////////////////////////////////////////////////////////////////
	// Set
    st_numscalar(nname, n)
    st_matrix(bname, b)
}

//////////////////////////////////////////////////////////////////////////////// 
// Bootstrap
void bootstrap_moments( string scalar y1v,    		  string scalar y2v,	
						real scalar p,	  	  		  real scalar q,	   
					    real scalar delta,	  	  	  real scalar num_boot,	
						string scalar touse,   		  string scalar nname,
						string scalar bname,   		  string scalar vname) 
{
    yy = st_data(., y1v, touse), st_data(., y2v, touse)
    n  = rows(yy)
	// Set main index (t)
	tdx = p+q+1
	//tdx
	// Demean y
	mean_yy = mean(yy[.,tdx])
	yy = yy :- mean_yy
	// Set the 100 times the precision of numerical derivative in the frequency domain
	//delta = 100
	// Set slist
	slist = (-trunc(5*delta)..trunc(5*delta)) / 100
	slist_interval = slist[2] - slist[1]
	
	printf("Estimating the variances of the moment estimates\n")
	//num_boot = 10
	blist = J(num_boot,8,0)
	for( boot_idx = 1 ; boot_idx <= num_boot ; boot_idx++ ){
		if( trunc(boot_idx/trunc(num_boot/10)) == boot_idx/trunc(num_boot/10) ){
			printf("                     %f%%\n",boot_idx/num_boot*100)			
		}
		indices = trunc(uniform(n,1):*n):+1
		y = yy[indices,.]
		////////////////////////////////////////////////////////////////////////////
		// Estimate rho	
		if( p > 0 ){
			pprime = 0
			Delta0 = y[.,tdx+1-pprime]:-y[.,tdx-q]:-y[.,tdx-pprime]:+y[.,tdx-q-1]:+y[.,tdx-q]:-y[.,tdx-q-1]
			pprime = 1
			Delta = y[.,tdx+1-pprime]:-y[.,tdx-q]:-y[.,tdx-pprime]:+y[.,tdx-q-1]:+y[.,tdx-q]:-y[.,tdx-q-1]
			if( p > 1 ){
				for( pprime = 2 ; pprime <= p ; pprime++ ){
					 Delta = Delta, y[.,tdx+1-pprime]:-y[.,tdx-q]:-y[.,tdx-pprime]:+y[.,tdx-q-1]:+y[.,tdx-q]:-y[.,tdx-q-1]
				}
			}
			rho = luinv( (y[.,tdx :- ((q+1)..(p+q))])' * Delta :+ 0.05:*diag(J(p,1,n)) ) * (y[.,tdx :- ((q+1)..(p+q))])' * Delta0
		//	rho
		}

		////////////////////////////////////////////////////////////////////////////
		// Estimate mu	
		mu = y[.,tdx+q+1] - y[.,tdx]
		if( p > 0 ){
			for( pprime = 1 ; pprime <= p ; pprime++ ){
				mu = mu :- rho[pprime] :* ( y[.,tdx+q+1-pprime] - y[.,tdx] )
			}
		}
		
		////////////////////////////////////////////////////////////////////////////
		// Estimate kappa	
		kappa = -1
		if( p > 0 ){
			for( pprime = 1 ; pprime <= p ; pprime++ ){
				kappa = kappa + rho[pprime]
			}
		}
		//kappa 
		
		////////////////////////////////////////////////////////////////////////////
		// Estimate phi_v
		phi_v_integrand = slist :* (0+0i)
		for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_v_integrand[idx] = sum( (0+1i) :* mu :* exp( (0+1i):*s:*y[.,tdx] ) ) / sum( kappa :* exp( (0+1i):*s:*y[.,tdx] ) )
		}
		//phi_v_integrand'
		
		phi_v = slist :* (0+0i)
		middle = trunc(length(slist) / 2) + 1
		for( idx = middle + 1 ; idx <= length(slist) ; idx++ ){
			phi_v[idx] = phi_v[idx-1] + phi_v_integrand[idx] * slist_interval
		}
		for( idx = middle - 1 ; idx >= 1 ; idx-- ){
			phi_v[idx] = phi_v[idx+1] - phi_v_integrand[idx] * slist_interval
		}
		phi_v = exp( phi_v )
		//phi_v'
		
		////////////////////////////////////////////////////////////////////////////
		// Estimate phi_u
		phi_y = slist :* (0+0i)
		for( idx = 1 ; idx <= length(slist) ; idx++ ){
			s = slist[idx]
			phi_y[idx] = sum( exp( (0+1i):*s:*y[.,tdx] ) ) / n
		}
		phi_u = phi_y :/ phi_v
		//phi_u'
		
		////////////////////////////////////////////////////////////////////////////
		// Estimate derivatives of the characteristic functions
		phi_u_d1 = slist :* (0+0i)
		phi_v_d1 = slist :* (0+0i)
		phi_u_d2 = slist :* (0+0i)
		phi_v_d2 = slist :* (0+0i)
		phi_u_d3 = slist :* (0+0i)
		phi_v_d3 = slist :* (0+0i)
		phi_u_d4 = slist :* (0+0i)
		phi_v_d4 = slist :* (0+0i)
		
		for( idx = delta+1 ; idx <= length(slist)-delta ; idx++ ){
			phi_u_d1[idx] = (phi_u[idx+delta]-phi_u[idx-delta])/(slist[idx+delta]-slist[idx-delta])
			phi_v_d1[idx] = (phi_v[idx+delta]-phi_v[idx-delta])/(slist[idx+delta]-slist[idx-delta])
		}
		//phi_u_d1', phi_v_d1'
		
		for( idx = 2*delta+1 ; idx <= length(slist)-2*delta ; idx++ ){
			phi_u_d2[idx] = (phi_u_d1[idx+delta]-phi_u_d1[idx-delta])/(slist[idx+delta]-slist[idx-delta])
			phi_v_d2[idx] = (phi_v_d1[idx+delta]-phi_v_d1[idx-delta])/(slist[idx+delta]-slist[idx-delta])
		}
		//phi_u_d2', phi_v_d2'
		
		for( idx = 3*delta+1 ; idx <= length(slist)-3*delta ; idx++ ){
			phi_u_d3[idx] = (phi_u_d2[idx+delta]-phi_u_d2[idx-delta])/(slist[idx+delta]-slist[idx-delta])
			phi_v_d3[idx] = (phi_v_d2[idx+delta]-phi_v_d2[idx-delta])/(slist[idx+delta]-slist[idx-delta])
		}
		//phi_u_d3', phi_v_d3'
		
		for( idx = 4*delta+1 ; idx <= length(slist)-4*delta ; idx++ ){
			phi_u_d4[idx] = (phi_u_d3[idx+delta]-phi_u_d3[idx-delta])/(slist[idx+delta]-slist[idx-delta])
			phi_v_d4[idx] = (phi_v_d3[idx+delta]-phi_v_d3[idx-delta])/(slist[idx+delta]-slist[idx-delta])
		}
		//phi_u_d4', phi_v_d4'
		
		////////////////////////////////////////////////////////////////////////////
		// Estimate moments
		u_m1 = sum( phi_u_d1[((middle-delta)..(middle+delta))] ) / (0+1i) / (2*delta+1)
		u_m2 = sum( phi_u_d2[((middle-delta)..(middle+delta))] ) / (-1+0i) / (2*delta+1)
		u_m3 = sum( phi_u_d3[((middle-delta)..(middle+delta))] ) / (0-1i) / (2*delta+1)
		u_m4 = sum( phi_u_d4[((middle-delta)..(middle+delta))] ) / (1+0i) / (2*delta+1)
		
		v_m1 = sum( phi_v_d1[((middle-delta)..(middle+delta))] ) / (0+1i) / (2*delta+1)
		v_m2 = sum( phi_v_d2[((middle-delta)..(middle+delta))] ) / (-1+0i) / (2*delta+1)
		v_m3 = sum( phi_v_d3[((middle-delta)..(middle+delta))] ) / (0-1i) / (2*delta+1)
		v_m4 = sum( phi_v_d4[((middle-delta)..(middle+delta))] ) / (1+0i) / (2*delta+1)
		
		//u_m1, u_m2, u_m3, u_m4
		//v_m1, v_m2, v_m3, v_m4
		
		mean_u = u_m1
		sd_u = ( u_m2 - u_m1^2 )^0.5
		skew_u = ( u_m3 - 3*u_m2*mean_u + 3*u_m1*mean_u^2 - mean_u^3 ) / sd_u^3
		kurt_u = ( u_m4 - 4*u_m3*mean_u + 6*u_m2*mean_u^2 - 4*u_m1*mean_u^3 + mean_u^4 ) / sd_u^4
		
		mean_v = v_m1
		sd_v = ( v_m2 - v_m1^2 )^0.5
		skew_v = ( v_m3 - 3*v_m2*mean_v + 3*v_m1*mean_v^2 - mean_v^3 ) / sd_v^3
		kurt_v = ( v_m4 - 4*v_m3*mean_v + 6*v_m2*mean_v^2 - 4*v_m1*mean_v^3 + mean_v^4 ) / sd_v^4
		
		//mean_u, sd_u, skew_u, kurt_u
		//mean_v, sd_v, skew_v, kurt_v
		
		b = mean_u, abs(sd_u), skew_u, abs(kurt_u), mean_v, abs(sd_v), skew_v, abs(kurt_v)
		b = Re(b)
		blist[boot_idx,.] = b
	}
	
	//sort(colshape(abs(blist),1),1)
	for( idx = 1 ; idx <= 8 ; idx++ ){
		large = blist[.,idx] :>= sort(blist[.,idx],1)[trunc(num_boot*0.995)+1]
		small = blist[.,idx] :<= sort(blist[.,idx],1)[trunc(num_boot*0.005)+1]
		blist[.,idx] = (!small :& !large) :* blist[.,idx] :+ small :* sort(blist[.,idx],1)[trunc(num_boot*0.005)+1] + large :* sort(blist[.,idx],1)[trunc(num_boot*0.995)+1]
	}
	V = ( ( blist' * blist ) :/ num_boot :- ( J(1,num_boot,1) * blist :/ num_boot)' * ( J(1,num_boot,1) * blist :/ num_boot) )
	
	////////////////////////////////////////////////////////////////////////////
	// Set
    st_numscalar(nname, n)
    st_matrix(vname, V)
	
	printf("\n{hline 78}\n")
	printf("ARMA(%f,%f) process - p=%f & q=%f                                         \n",p,q,p,q)
	printf("Number of cross-sectional observations:                               N=%f\n",n)
	printf("Number of time periods of input variables:                            T=%f\n",cols(yy))
	printf("Number of minimum time periods required for identification:           p+2q+2=%f\n",p+2*q+2)
	printf("{hline 78}\n")
	printf("Displayed are moments in the time period corresponding to the %f-th input var.\n",tdx)
	printf("U = Permanent Component\n")
	printf("V = Transitory Component\n")
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
