////////////////////////////////////////////////////////////////////////////////
// STATA FOR  Kato, K. & Sasaki, Y. (2018): Uniform Confidence Bands in 
//            Deconvolution with Unknown Error Distribution. Journal of 
//            Econometrics 207 (1), 129-161.
//
// Use it when you consider repeated measurements x1 and x2 for the true latent
// variable x with measurement errors e1 = x1 - x and e2 = x2 - x. The command
// draws a uniform confidence band for the density function fx of x.
////////////////////////////////////////////////////////////////////////////////
program define npeivreg, rclass
    version 14.2
 
    syntax varlist(min=2 numeric) [if] [in] [, numx(real 20), domain(real 2) cover(real 0.95), tp(real 0.2)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname N CB

		mata: estimate("`depvar'", "`cnames'", `numx', `domain', ///
					   `tp', `cover', "`touse'", "`N'", "`CB'") 

	_matplot `CB', connect(1) noname ytitle("f{sub:X}(x)") xtitle("x") recast(line) name(UCB, replace)		

end

		
		
		
		
mata:
//////////////////////////////////////////////////////////////////////////////// 
// Flat Top Kernel (Politis and Romano, 1999)
void phi_k(u, kout){
	k_b = 1.00
	k_c = 0.05
	abs_u = abs(u)
	kout = exp( -1 :* k_b :* exp(-1 :* k_b :/ ((abs_u :- k_c):^2 + 0.000001)) :/ ((abs_u :- 1):^2 + 0.000001) )
	kout = 1 :* (abs_u :<= k_c) :+ kout :* (k_c :< abs_u)
	kout = kout :* (abs_u :< 1) :+ 0 :* (1 :<= abs_u)
}
//////////////////////////////////////////////////////////////////////////////// 
// Estimation of QRKD
void estimate( string scalar yv,     string scalar x12v,	 	
			   real scalar numx,      real scalar domain,
			   real scalar tuning,	  real scalar cover,
			   string scalar touse,   string scalar nname, 
			   string scalar cbname) 
{
	printf("\n{hline 78}\n")
	printf("Executing:          Kato, K. & Sasaki, Y. (2018): Uniform Confidence Bands in \n")
	printf("                    Deconvolution with Unknown Error Distribution. Journal of \n")
    printf("                    Econometrics 207 (1), 129-161. \n")
	printf("{hline 78}\n")

    y      = st_data(., yv, touse)
    x12    = st_data(., x12v, touse)
	x1 	   = x12[.,1]
	x2 	   = x12[.,2]
    n      = length(y)

	// Normalize the Location of x1 to zero
	mean_x1 = mean(x1)
	sd_x1 = ( mean( x1 :* x2 ) :- mean(x1):*mean(x2) )^0.5 // variance(x1)^0.5
	x1 = ( x1:-mean_x1 ) :/ sd_x1
	x2 = ( x2:-mean_x1 ) :/ sd_x1
	
	// Define y and eta
	xx = ( x1 :+ x2 ) :/ 2
	eta = ( x1 :- x2 ) :/ 2
	
	// xlist
	xlist = ( ( (1..numx) :- ( (1+numx)/2 ) ) :/ ( (numx-1)/2 ) ) :* domain
	
	// tlist
	tlist = (-20..20) / 10
	tlist_interval = tlist[2] - tlist[1]
	
	// Bandwidth
	h = tuning
	
	////////////////////////////////////////////////////////////////////////////
	// Compute the Fourie Transforms
	phi_K = tlist :* (0+0i)
	for( idx = 1 ; idx <= length(tlist) ; idx++ ){
		t = tlist[idx]
		phi_k(t, phi_k_val)
		phi_K[idx] = phi_k_val
	}
	
	phi_e = tlist :* (0+0i)
	for( idx = 1 ; idx <= length(tlist) ; idx++ ){
		t = tlist[idx]
		phi_e[idx] = sum( exp( (0+1i) :* t :/ h :* eta ) ) / n
	}
	//phi_K',phi_e'
	
	////////////////////////////////////////////////////////////////////////////
	// Compute Density, Mu, and Variance
	fx = xlist :* 0
	mu = xlist :* 0
	g = xlist :* 0
	s2 = xlist :* 0
	K_hat = J(n,length(xlist),0+0i)
	YK_hat = J(n,length(xlist),0+0i)
	Y_gK_hat = J(n,length(xlist),0+0i)
	
	for( idx = 1 ; idx <= length(xlist) ; idx++ ){
		x = xlist[idx]

		for( jdx = 1 ; jdx <= n ; jdx++ ){
			K_hat[jdx,idx] = sum( exp( (0-1i) :* tlist :* (x :- xx[jdx]):/h ) :* phi_K :/ phi_e ) :* tlist_interval :/ (2 * 3.14159265359)
			YK_hat[jdx,idx] = y[jdx] * K_hat[jdx,idx]
		}
		sum_k_hat = sum( K_hat[.,idx] )
		sum_k_hat_sq = sum( K_hat[.,idx]:^2 )
		sum_yk_hat = sum( YK_hat[.,idx] )
		
		fx[idx] = Re( sum_k_hat / (n*h) )
		mu[idx] = Re( sum_yk_hat / (n*h) )
		g[idx] = mu[idx] / fx[idx]
		
		for( jdx = 1 ; jdx <= n ; jdx++ ){
			Y_gK_hat[jdx,idx] = (y[jdx] - g[idx]) * K_hat[jdx,idx]
		}
		sum_y_gk_hat_sq = sum( Y_gK_hat[.,idx]:^2 )
		
		s2[idx] = Re( sum_y_gk_hat_sq / n )
	}
	//xlist', g', (s2'):^0.5
	
	////////////////////////////////////////////////////////////////////////////
	// Multiplier Bootstrap
	num_boot = 1000
	supnormZxi = J(1,num_boot,0)
	
	for( jdx = 1 ; jdx <= num_boot ; jdx++ ){
		xi = invnormal(uniform(n,1))
		Zxi = xlist * 0
		for( idx = 1 ; idx <= length(xlist) ; idx++ ){		
			Zxi[idx] = Re( sum( xi :* Y_gK_hat[.,idx] ) / ( s2[idx]:^0.5 * n^0.5 ) )
		}
		supnormZxi[jdx] = max(abs(Zxi))
	}
	critical_value = supnormZxi[trunc(cover*num_boot)]
	//critical_value
	
	////////////////////////////////////////////////////////////////////////////
	// Confidence Bands
	CBl = g :- s2:^0.5 :/ fx :/ ( n^0.5 * h ) :* critical_value
	CBu = g :+ s2:^0.5 :/ fx :/ ( n^0.5 * h ) :* critical_value
	//CBl', fx', CBu'
	
	////////////////////////////////////////////////////////////////////////////
	// Final Output
	final_xlist = xlist' :* sd_x1 :+ mean_x1
	final_g = g' // :* sd_x1
	final_CBl = CBl' // :* sd_x1
	final_CBu = CBu' // :* sd_x1
	
	//final_xlist, final_fx, final_CBl, final_CBu
	
	////////////////////////////////////////////////////////////////////////////
	// Display Results
	for( idx = 1 ; idx <= length(xlist) ; idx++ ){
	if( trunc((idx-1)/10) == (idx-1)/10 ){
		printf("{hline 64}\n")
		printf("         x           g(x)     [%2.0f%% Uniform Confidence Band]\n", 100*cover)
		printf("{hline 64}\n")
	}
	printf("%10.3f     %10.3f     %10.3f     %10.3f\n", final_xlist[idx], final_g[idx], final_CBl[idx], final_CBu[idx])
	}
	printf("{hline 64}\n")
	
	////////////////////////////////////////////////////////////////////////////
	// Set
	rev_final_g = J(length(xlist),1,1)
	rev_final_xlist = J(length(xlist),1,1)
	for( idx = 1 ; idx <= length(xlist); idx++ ){
	    rev_final_g[idx] = final_g[length(xlist)+1-idx]
	    rev_final_xlist[idx] = final_xlist[length(xlist)+1-idx]
	}
	BBB = final_g[1] \ final_CBu \ rev_final_g \ final_CBl \ final_g[length(xlist)]
	XXX = final_xlist[1] \ final_xlist \ rev_final_xlist \ final_xlist \ final_xlist[length(xlist)]
    st_matrix(cbname, (BBB,XXX))
	
    st_numscalar(nname, n)
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
