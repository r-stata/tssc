////////////////////////////////////////////////////////////////////////////////
// STATA FOR  Botosaru, I. & Sasaki, Y. (2018): Nonparametric Heteroskedasticity
//            in Persistent Panel Processes: An Application to Earnings Dynamics
//            Journal of Econometrics 203 (2), 283-296.
//
// Use it when you consider a state space model where the observed process is an
// sum of permanent and transitory components. The command draws the densities
// of the perment and transitory components as well as the conditional skedastic
// function of the permanent shock. Relevant to earnings dynamics models.
////////////////////////////////////////////////////////////////////////////////
program define npss, rclass
    version 14.2
 
    syntax varlist(min=2 numeric) [if] [in] [, skedastic(varname numeric) tp1(real 4) tp2(real 2)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname N estU estV estS maxfufv

	if "`skedastic'" == "" {
		mata: estimate("`depvar'", "`cnames'", ///
					   `tp1', "`touse'", "`N'", "`estU'", ///
					   "`estV'", "`maxfufv'", "`estS'") 
		
		di "  Producing a deconvolution density graph for U"
		_matplot `estU', noname ytitle("f{sub:Ut}(U{sub:t})") xtitle("U{sub:t}") title("Deconvolution Density of U{sub:t}") recast(line) name(FU, replace)
		
		di "  Producing a deconvolution density graph for V"
		_matplot `estV', noname ytitle("f{sub:Vt}(V{sub:t})") xtitle("V{sub:t}") title("Deconvolution Density of V{sub:t}") recast(line) name(FV, replace)
		
		di "  Combining the two graphs together"
		graph combine FU FV, name(Combined, replace)
	}
	 
	if "`skedastic'" != "" {
		mata: estimate("`depvar'", "`cnames'", ///
					   `tp1', "`touse'", "`N'", "`estU'", ///
					   "`estV'", "`maxfufv'", "`estS'") 
		
		di "  Producing a deconvolution density graph for U"
		_matplot `estU', noname ytitle("f{sub:Ut}(U{sub:t})") xtitle("U{sub:t}") title("Deconvolution Density of U{sub:t}") recast(line) name(FU, replace)
		
		di "  Producing a deconvolution density graph for V"
		_matplot `estV', noname ytitle("f{sub:Vt}(V{sub:t})") xtitle("V{sub:t}") title("Deconvolution Density of V{sub:t}") recast(line) name(FV, replace)

		tempvar y3name
		gen `y3name' = `skedastic'
		mata: estimate_skedastic("`depvar'", "`cnames'", "`y3name'", ///
								 `tp2', "`touse'", "`N'", "`estU'", ///
								 "`estV'", "`maxfufv'", "`estS'") 
								 
		di "  Producing a graph for the conditional skedastic function"
		_matplot `estS', noname ytitle("{&sigma}{sub:t+1}(U{sub:t})") xtitle("U{sub:t}") title("Conditional Skedastic Function") recast(line) name(SKED, replace)
		
		di "  Combining the three graphs together"
		graph combine FU FV SKED, name(Combined, replace)
	}

    ereturn scalar N    = `N'
    ereturn local  cmd  "npss"
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
// Estimation
void estimate( string scalar y1v,     string scalar y2v,	 	
			   real scalar tuning,	   
			   string scalar touse,   string scalar nname,   	string scalar uname,
			   string scalar vname,	  string scalar maxname,	string scalar sname) 
{
	printf("\n{hline 78}\n")
	printf("Executing: Botosaru, I. & Sasaki, Y. (2018): Nonparametric Heteroskedasticity\n")
	printf("           in Persistent Panel Processes: An Application to Earnings Dynamics.\n")
    printf("           Journal of Econometrics 203 (2), 283-296.\n")
	printf("{hline 78}\n")
 
    y1      = st_data(., y1v, touse)
    y2      = st_data(., y2v, touse)
    n      = rows(y1)
	// Normalize the Location of y1 to zero
	mean_y1 = mean(y1)
	sd_y1 = variance(y1)^0.5
	y1 = ( y1:-mean_y1 ) :/ sd_y1
	y2 = ( y2:-mean_y1 ) :/ sd_y1
	// Grid for U and V
	ulist = (-15..15) :/ 10
	vlist = (-15..15) :/ 10
	// Bandwidth
	h = tuning

	////////////////////////////////////////////////////////////////////////////
	// Estimate Characteristic Functions
	slist = (-500..500)/100
	slist_interval = slist[2] - slist[1]
	// First, integrand for phi_u1
	phi_u1_integrand = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_u1_integrand[idx] = sum( (0 + 1i) :* y2 :* exp( (0 + 1i) :* s :* y1 ) ) / sum( exp( (0 + 1i) :* s :* y1 ) )
	}
	// Second, phi_u1
	phi_u1 = slist :* (0 + 0i)
	middle_idx = trunc(length(slist)/2)+1
	for( idx = middle_idx+1 ; idx <= length(slist) ; idx++ ){
		phi_u1[idx] = phi_u1[idx-1] + phi_u1_integrand[idx] * (slist[idx]-slist[idx-1])
	}
	for( idx = middle_idx-1 ; idx >= 1 ; idx-- ){
		phi_u1[idx] = phi_u1[idx+1] + phi_u1_integrand[idx] * (slist[idx]-slist[idx+1])
	}
	phi_u1 = exp( phi_u1 )
	// Third, phi_v1
	phi_v1 = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_v1[idx] = sum( exp( (0 + 1i) :* s :* y1 ) ) :/ n :/ phi_u1[idx]
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Compute Deconvolution Kernel
	complex scalar kout
	phi_K_val = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_k(s/h, kout)
		phi_K_val[idx] = kout
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Density Estimates
	fu1 = ulist :* 0
	for( idx = 1 ; idx <= length(ulist) ; idx++ ){
		u = ulist[idx]
		fu1[idx] = Re( sum( exp( ( 0 - 1i ) :* slist :* u ) :* phi_u1 :* phi_K_val :* slist_interval ) :/ ( 2 * 3.1415926535 ) )
		fu1[idx] = ( fu1[idx] < 0 ) * 0 + ( fu1[idx] >= 0) * fu1[idx]
	}
	
	fv1 = vlist :* 0
	for( idx = 1 ; idx <= length(vlist) ; idx++ ){
		v = vlist[idx]
		fv1[idx] = Re( sum( exp( ( 0 - 1i ) :* slist :* v ) :* phi_v1 :* phi_K_val :* slist_interval ) :/ ( 2 * 3.1415926535 ) )
		fv1[idx] = ( fv1[idx] < 0 ) * 0 + ( fv1[idx] >= 0) * fv1[idx]	
	}
	
	finalulist = ulist' :* sd_y1 :+ mean_y1
	finalfu1 = fu1' :/ sd_y1
	finalvlist = vlist' :* sd_y1
	finalfv1 = fv1' :/ sd_y1

	////////////////////////////////////////////////////////////////////////////
	// Set n
    st_numscalar(nname, n)
    st_matrix(uname, (finalfu1,finalulist))
    st_matrix(vname, (finalfv1,finalvlist))
}

//////////////////////////////////////////////////////////////////////////////// 
// Estimation
void estimate_skedastic( string scalar y1v,     string scalar y2v,			string scalar y3v,
						 real scalar tuning,	   
						 string scalar touse,   string scalar nname,   		string scalar uname,
						 string scalar vname,	  string scalar maxname,	string scalar sname) 
{
    y1      = st_data(., y1v, touse)
    y2      = st_data(., y2v, touse)
	y3      = st_data(., y3v, touse)
    n      = rows(y1)
	
	// Normalize the Location of y2 to zero
	mean_y2 = mean(y2)
	sd_y2 = variance(y2)^0.5
	y2 = ( y2:-mean_y2 ) :/ sd_y2
	y3 = ( y3:-mean_y2 ) :/ sd_y2

	////////////////////////////////////////////////////////////////////////////
	// Estimate Characteristic Functions
	slist = (-10..10)/100
	slist_interval = slist[2] - slist[1]
	// First, integrand for phi_u2
	phi_u2_integrand = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_u2_integrand[idx] = sum( (0 + 1i) :* y3 :* exp( (0 + 1i) :* s :* y2 ) ) / sum( exp( (0 + 1i) :* s :* y2 ) )
	}
	// Second, phi_u2
	phi_u2 = slist :* (0 + 0i)
	middle_idx = trunc(length(slist)/2)+1
	for( idx = middle_idx+1 ; idx <= length(slist) ; idx++ ){
		phi_u2[idx] = phi_u2[idx-1] + phi_u2_integrand[idx] * (slist[idx]-slist[idx-1])
	}
	for( idx = middle_idx-1 ; idx >= 1 ; idx-- ){
		phi_u2[idx] = phi_u2[idx+1] + phi_u2_integrand[idx] * (slist[idx]-slist[idx+1])
	}
	phi_u2 = exp( phi_u2 )
	// Third, phi_v2
	phi_v2 = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_v2[idx] = sum( exp( (0 + 1i) :* s :* y2 ) ) :/ n :/ phi_u2[idx]
	}
	slist_middle_index = trunc(length(slist)/2)+1
	phi_v2_pp = ( ( ( phi_v2[slist_middle_index+1] - phi_v2[slist_middle_index] ) / slist_interval ) - ( ( phi_v2[slist_middle_index] - phi_v2[slist_middle_index-1] ) / slist_interval ) ) / slist_interval
	
	// Bring Back the Normalization of y2
	y2 = y2 :* sd_y2 :+ mean_y2
	y3 = y3 :* sd_y2 :+ mean_y2
	
	// Normalize the Location of y1 to zero
	mean_y1 = mean(y1)
	sd_y1 = variance(y1)^0.5
	y1 = ( y1:-mean_y1 ) :/ sd_y1
	y2 = ( y2:-mean_y1 ) :/ sd_y1
	// Grid for U and V
	ulist = (-15..15) :/ 10
	vlist = (-15..15) :/ 10
	// Bandwidth
	h = tuning

	////////////////////////////////////////////////////////////////////////////
	// Estimate Characteristic Functions
	slist = (-500..500)/100
	slist_interval = slist[2] - slist[1]
	// First, integrand for phi_u1
	phi_u1_integrand = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_u1_integrand[idx] = sum( (0 + 1i) :* y2 :* exp( (0 + 1i) :* s :* y1 ) ) / sum( exp( (0 + 1i) :* s :* y1 ) )
	}
	// Second, phi_u1
	phi_u1 = slist :* (0 + 0i)
	middle_idx = trunc(length(slist)/2)+1
	for( idx = middle_idx+1 ; idx <= length(slist) ; idx++ ){
		phi_u1[idx] = phi_u1[idx-1] + phi_u1_integrand[idx] * (slist[idx]-slist[idx-1])
	}
	for( idx = middle_idx-1 ; idx >= 1 ; idx-- ){
		phi_u1[idx] = phi_u1[idx+1] + phi_u1_integrand[idx] * (slist[idx]-slist[idx+1])
	}
	phi_u1 = exp( phi_u1 )
	// Third, phi_v1
	phi_v1 = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_v1[idx] = sum( exp( (0 + 1i) :* s :* y1 ) ) :/ n :/ phi_u1[idx]
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Compute Deconvolution Kernel
	complex scalar kout
	phi_K_val = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		phi_k(s/h, kout)
		phi_K_val[idx] = kout
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Density Estimates
	fu1 = ulist :* 0
	for( idx = 1 ; idx <= length(ulist) ; idx++ ){
		u = ulist[idx]
		fu1[idx] = Re( sum( exp( ( 0 - 1i ) :* slist :* u ) :* phi_u1 :* phi_K_val :* slist_interval ) :/ ( 2 * 3.1415926535 ) )
		fu1[idx] = ( fu1[idx] < 0 ) * 0 + ( fu1[idx] >= 0) * fu1[idx]
	}
	
	fv1 = vlist :* 0
	for( idx = 1 ; idx <= length(vlist) ; idx++ ){
		v = vlist[idx]
		fv1[idx] = Re( sum( exp( ( 0 - 1i ) :* slist :* v ) :* phi_v1 :* phi_K_val :* slist_interval ) :/ ( 2 * 3.1415926535 ) )
		fv1[idx] = ( fv1[idx] < 0 ) * 0 + ( fv1[idx] >= 0) * fv1[idx]	
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Compute K Function for Skedastic Function
	Khat = slist :* (0 + 0i)
	for( idx = 1 ; idx <= length(slist) ; idx++ ){
		s = slist[idx]
		Khat[idx] = sum( y2:^2 :* exp( (0 + 1i) :* s :* y1 ) ) / sum( exp( (0 + 1i) :* s :* y1 ) )
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Skedastic Function
	sked = ulist :* 0
	for( idx = 1 ; idx <= length(ulist) ; idx++ ){
		u = ulist[idx]
		sked[idx] = Re( sum( exp( (0 - 1i) :* slist :* u ) :* Khat :* phi_u1 :* phi_K_val ) * slist_interval / fu1[idx] - phi_v2_pp - u^2 )
		sked[idx] = 0 * (sked[idx] < 0) + sked[idx] * (sked[idx] >= 0)
	}
	
	finalulist = ulist' :* sd_y1 :+ mean_y1
	finalfu1 = fu1' :/ sd_y1
	finalvlist = vlist' :* sd_y1
	finalfv1 = fv1' :/ sd_y1
	finalsked = ( sked' :* (sd_y1^2) ):^0.5
	
	////////////////////////////////////////////////////////////////////////////
	// Set n
    st_numscalar(nname, n)
    st_matrix(uname, (finalfu1,finalulist))
    st_matrix(vname, (finalfv1,finalvlist))
    st_matrix(sname, (finalsked,finalulist))
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
