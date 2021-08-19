////////////////////////////////////////////////////////////////////////////////
// STATA FOR  Kato, K., Sasaki, Y., Ura, T. (2021): Robust Inference in 
//            Deconvolution. Quantitative Economics, 12 (1), 109-142.
//
// Use it when you consider repeated measurements x1 and x2 for the true latent
// variable x with measurement errors e1 = x1 - x and e2 = x2 - x. The command
// draws a uniform confidence band for the density function fx of x.
////////////////////////////////////////////////////////////////////////////////
program define kotlarski, rclass
    version 14.2
 
    syntax varlist(min=2 numeric) [if] [in] [, numx(real 20), domain(real 2) cover(real 0.95), tp(real -1), order(real 2), grid(real 50)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname N CB

		mata: estimate("`depvar'", "`cnames'", `numx', `domain', ///
					   `tp', `cover', `order', `grid', "`touse'", "`N'", "`CB'") 

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
// Bandwidth Choice
real scalar Delaigle_Gijbels(x_list,n,Y1,Y2){
//////////////////////////////////////////////////////////////////////////////// 
// C.H. Estimation (USE x_list, n, Y1, and Y2 - RETURNS f_list)
	T_LIST = (-1000..1000)/100
	MID_IDX = (length(T_LIST)+1)/2
	MAT_Y1 = J(1,length(T_LIST),Y1)
	MAT_EITY1 = exp( (0+1i) * Y1 * T_LIST )
	MAT_EITY2 = exp( (0+1i) * Y2 * T_LIST )
	E_Y1EITY2 = colsum( MAT_Y1 :* MAT_EITY2 ) / n
	E_EITY1 = colsum( MAT_EITY1 ) / n
	E_EITY2 = colsum( MAT_EITY2 ) / n
	PHI_X = J(1,length(T_LIST),0+0i)
	for( idx=1 ; idx <=(length(T_LIST)-MID_IDX) ; idx++ ){
		PHI_X[MID_IDX+idx] = PHI_X[MID_IDX+idx-1] + (0+1i)*E_Y1EITY2[MID_IDX+idx]/E_EITY2[MID_IDX+idx] * (T_LIST[MID_IDX+idx]-T_LIST[MID_IDX+idx-1])
		PHI_X[MID_IDX-idx] = PHI_X[MID_IDX-idx+1] + (0+1i)*E_Y1EITY2[MID_IDX-idx]/E_EITY2[MID_IDX-idx] * (T_LIST[MID_IDX-idx]-T_LIST[MID_IDX-idx+1])
	}
	PHI_X = exp(PHI_X)
	PHI_U1 = E_EITY1 :/ exp(PHI_X)

//////////////////////////////////////////////////////////////////////////////// 
// Delaigle-Gijbels Bandwidth Choice by Normal Reference (NR)
	h_list = (1..1000)/1000
	AMISE_list = J(1,length(h_list),0)
	for( hdx=1 ; hdx<=length(h_list) ; hdx++ ){
		h = h_list[hdx]
		Phi_K = J(1,length(T_LIST),0)
		for( tdx=1 ; tdx<=length(T_LIST) ; tdx++ ){
			T = T_LIST[1,tdx]
			phi_k(T*h,phi_k_val)
			Phi_K[tdx] = phi_k_val
		}
		AMISE = sum( abs( Phi_K:/PHI_U1 ):^2 ) * h * (T_LIST[2]-T_LIST[1]) / (2 * 3.14159 * n * h)
		MU2=1
		AMISE = AMISE + MU2 * 0.375 / 3.14159^0.5 * (sum(Y1:*Y2)/n - sum(Y1/n)*sum(Y2/n))^(-5/2) * h^4 / 4
		AMISE_list[hdx] = AMISE
	}
	min_AMISE = 999999999
	min_hdx = 0
	for( hdx=1 ; hdx<=length(h_list) ; hdx++ ){
		if(AMISE_list[hdx]<min_AMISE){
			min_AMISE=AMISE_list[hdx]
			min_hdx=hdx
		}
	}
	h = h_list[min_hdx]

	return( h )
}
//////////////////////////////////////////////////////////////////////////////// 
// Estimation of Deconvolution Kernel Density
real matrix estimation(x_list,n,Y1,Y2){
//////////////////////////////////////////////////////////////////////////////// 
// C.H. Estimation (USE x_list, n, Y1, and Y2 - RETURNS f_list)
	T_LIST = (-1000..1000)/100
	MID_IDX = (length(T_LIST)+1)/2
	MAT_Y1 = J(1,length(T_LIST),Y1)
	MAT_EITY1 = exp( (0+1i) * Y1 * T_LIST )
	MAT_EITY2 = exp( (0+1i) * Y2 * T_LIST )
	E_Y1EITY2 = colsum( MAT_Y1 :* MAT_EITY2 ) / n
	E_EITY1 = colsum( MAT_EITY1 ) / n
	E_EITY2 = colsum( MAT_EITY2 ) / n
	PHI_X = J(1,length(T_LIST),0+0i)
	for( idx=1 ; idx <=(length(T_LIST)-MID_IDX) ; idx++ ){
		PHI_X[MID_IDX+idx] = PHI_X[MID_IDX+idx-1] + (0+1i)*E_Y1EITY2[MID_IDX+idx]/E_EITY2[MID_IDX+idx] * (T_LIST[MID_IDX+idx]-T_LIST[MID_IDX+idx-1])
		PHI_X[MID_IDX-idx] = PHI_X[MID_IDX-idx+1] + (0+1i)*E_Y1EITY2[MID_IDX-idx]/E_EITY2[MID_IDX-idx] * (T_LIST[MID_IDX-idx]-T_LIST[MID_IDX-idx+1])
	}
	PHI_X = exp(PHI_X)
	PHI_U1 = E_EITY1 :/ exp(PHI_X)

//////////////////////////////////////////////////////////////////////////////// 
// Delaigle-Gijbels Bandwidth Choice by Normal Reference (NR)
	h_list = (1..1000)/1000
	AMISE_list = J(1,length(h_list),0)
	for( hdx=1 ; hdx<=length(h_list) ; hdx++ ){
		h = h_list[hdx]
		Phi_K = J(1,length(T_LIST),0)
		for( tdx=1 ; tdx<=length(T_LIST) ; tdx++ ){
			T = T_LIST[1,tdx]
			phi_k(T*h,phi_k_val)
			Phi_K[tdx] = phi_k_val
		}
		AMISE = sum( abs( Phi_K:/PHI_U1 ):^2 ) * h * (T_LIST[2]-T_LIST[1]) / (2 * 3.14159 * n * h)
		MU2=1
		AMISE = AMISE + MU2 * 0.375 / 3.14159^0.5 * (sum(Y1:*Y2)/n - sum(Y1/n)*sum(Y2/n))^(-5/2) * h^4 / 4
		AMISE_list[hdx] = AMISE
	}
	min_AMISE = 999999999
	min_hdx = 0
	for( hdx=1 ; hdx<=length(h_list) ; hdx++ ){
		if(AMISE_list[hdx]<min_AMISE){
			min_AMISE=AMISE_list[hdx]
			min_hdx=hdx
		}
	}
	h = h_list[min_hdx]
	
	Phi_K = J(1,length(T_LIST),0)
	for( tdx=1 ; tdx<=length(T_LIST) ; tdx++ ){
		T = T_LIST[1,tdx]
		phi_k(T*h,phi_k_val)
		Phi_K[tdx] = phi_k_val
	}
//////////////////////////////////////////////////////////////////////////////// 
// Li-Vuong Density Estimation
	f_list = J(1,length(x_list),0)
	for( xdx=1 ; xdx<=length(x_list) ; xdx++ ){
		x = x_list[xdx] 
		f_list[xdx] = Re( sum( exp(-1i*T_LIST*x) :* Phi_K :* PHI_X ) * (T_LIST[2]-T_LIST[1]) / (2 * 3.14159) )
	}

	return( f_list )
}
//////////////////////////////////////////////////////////////////////////////// 
// Hermite Polynomial
real matrix fH( x, j ){
 m = J(1,length(x),(0..floor(j/2))')'
 X = J(1,floor(j/2)+1,x)
 H = factorial(j) :* (-1):^m :/ factorial(m) :/ factorial(j:-2:*m) :* (2:*X):^(j:-2:*m)
 H = H,J(length(x),1,0)
 H = rowsum(H[,1..(2+floor(j/2))])
 return(H)
}
//////////////////////////////////////////////////////////////////////////////// 
// Hermite Function
real matrix fpsi( x, j ){
 return( (2:^j :* factorial(j) :* 1.772454):^(-0.5) :* exp(-x:^2:/2) :* fH( x, j ) )
}
//////////////////////////////////////////////////////////////////////////////// 
// Hermite Function - 1st Derivative
real matrix fpsi_prime( x, j ){
 return( x:*fpsi( x, j ) :- (2:*(j:+1)):^0.5 :* fpsi( x, j+1) ) 
}
////////////////////////////////////////////////////////////////////////////////
// Objective Function for Min
void minObjective(todo, theta, x_idx,mat_E_R,mat_E_I,mat_V_R,mat_V_I,n_alpha_eta_delta_L_q,psi_list,phi_list, crit, g, H){
	n = n_alpha_eta_delta_L_q[1,1]
	alpha = n_alpha_eta_delta_L_q[1,2]
	eta = n_alpha_eta_delta_L_q[1,3]
	delta = n_alpha_eta_delta_L_q[1,4]
	L = n_alpha_eta_delta_L_q[1,5]
	q = n_alpha_eta_delta_L_q[1,6]
	

////////////////////////////////////////////////////////////////////////////////
// Compute the Test Statistic T_theta
	E_R_theta = mat_E_R * theta'
	E_I_theta = mat_E_I * theta'
	theta_V_R_theta = J(L,1,0)
	theta_V_I_theta = J(L,1,0)
	for( l=1 ; l<=L ; l++ ){
		theta_V_R_theta_l = theta * mat_V_R[( (q+1)*(l-1)+1 )..( (q+1)*l ),] * theta'
		theta_V_I_theta_l = theta * mat_V_I[( (q+1)*(l-1)+1 )..( (q+1)*l ),] * theta'
		theta_V_R_theta[l,] = theta_V_R_theta_l
		theta_V_I_theta[l,] = theta_V_I_theta_l
	}

	T_theta = n^0.5 * ( (E_R_theta :- delta) \ (-1*E_R_theta :- delta) \ (E_I_theta :- delta) \ (-1*E_I_theta :- delta) ) :/ ( theta_V_R_theta:^0.5 \ theta_V_R_theta:^0.5 \ theta_V_I_theta:^0.5 \ theta_V_I_theta:^0.5 )

////////////////////////////////////////////////////////////////////////////////
// Compute the Critical Value c_alpha
	c_alpha = invnormal( 1 - alpha/(4*L) ) / ( 1 - invnormal( 1 - alpha/(4*L) )^2/n )
 
////////////////////////////////////////////////////////////////////////////////
// Compute the Density Estimate as length(x_list) by 1 Matrix psiT_theta
	psiT_theta = psi_list * theta'
	max_psiT_theta = sum(abs(psi_list)) * 1.086435*3.14159^(-0.25)

////////////////////////////////////////////////////////////////////////////////
// Compute the C.F at 0 as phiT_theta
	mat_I = diag( Re( (0+1i):^(0..q) ) )
	phiT_theta = (2*3.14159)^0.5 * phi_list * mat_I * theta'

////////////////////////////////////////////////////////////////////////////////
// Compute the Objective and Constraint Penalties
	objective = (psiT_theta[x_idx]^2)^1
	
	penalty = ( 0*(max(T_theta :- c_alpha)<=0) + max(T_theta :- c_alpha)^2*(max(T_theta :- c_alpha)>0) )/c_alpha 
    penalty = penalty + ( 0*( phiT_theta - 1 + (2*3.14159)^0.5 * eta <=0 ) + ( phiT_theta - 1 + (2*3.14159)^0.5 * eta )^2*(( phiT_theta - 1 + (2*3.14159)^0.5 * eta )>0))/2 
	penalty = penalty + ( 0*( -phiT_theta + 1 - (2*3.14159)^0.5 * eta <=0 ) + ( -phiT_theta + 1 - (2*3.14159)^0.5 * eta )^2*( -phiT_theta + 1 - (2*3.14159)^0.5 * eta >0))/2

////////////////////////////////////////////////////////////////////////////////
// Penalization Parameter
	PPara = 1000
	
	crit = objective + PPara*penalty
}
////////////////////////////////////////////////////////////////////////////////
// Objective Function for Max
void maxObjective(todo, theta, x_idx,mat_E_R,mat_E_I,mat_V_R,mat_V_I,n_alpha_eta_delta_L_q,psi_list,phi_list, crit, g, H){
	n = n_alpha_eta_delta_L_q[1,1]
	alpha = n_alpha_eta_delta_L_q[1,2]
	eta = n_alpha_eta_delta_L_q[1,3]
	delta = n_alpha_eta_delta_L_q[1,4]
	L = n_alpha_eta_delta_L_q[1,5]
	q = n_alpha_eta_delta_L_q[1,6]
	

////////////////////////////////////////////////////////////////////////////////
// Compute the Test Statistic T_theta
	E_R_theta = mat_E_R * theta'
	E_I_theta = mat_E_I * theta'
	theta_V_R_theta = J(L,1,0)
	theta_V_I_theta = J(L,1,0)
	for( l=1 ; l<=L ; l++ ){
		theta_V_R_theta_l = theta * mat_V_R[( (q+1)*(l-1)+1 )..( (q+1)*l ),] * theta'
		theta_V_I_theta_l = theta * mat_V_I[( (q+1)*(l-1)+1 )..( (q+1)*l ),] * theta'
		theta_V_R_theta[l,] = theta_V_R_theta_l
		theta_V_I_theta[l,] = theta_V_I_theta_l
	}

	T_theta = n^0.5 * ( (E_R_theta :- delta) \ (-1*E_R_theta :- delta) \ (E_I_theta :- delta) \ (-1*E_I_theta :- delta) ) :/ ( theta_V_R_theta:^0.5 \ theta_V_R_theta:^0.5 \ theta_V_I_theta:^0.5 \ theta_V_I_theta:^0.5 )

////////////////////////////////////////////////////////////////////////////////
// Compute the Critical Value c_alpha
	c_alpha = invnormal( 1 - alpha/(4*L) ) / ( 1 - invnormal( 1 - alpha/(4*L) )^2/n )
 
////////////////////////////////////////////////////////////////////////////////
// Compute the Density Estimate as length(x_list) by 1 Matrix psiT_theta
	psiT_theta = psi_list * theta'
	max_psiT_theta = sum(abs(psi_list)) * 1.086435*3.14159^(-0.25)

////////////////////////////////////////////////////////////////////////////////
// Compute the C.F at 0 as phiT_theta
	mat_I = diag( Re( (0+1i):^(0..q) ) )
	phiT_theta = (2*3.14159)^0.5 * phi_list * mat_I * theta'

////////////////////////////////////////////////////////////////////////////////
// Compute the Objective and Constraint Penalties
	objective = -1*((psiT_theta[x_idx])^2)^0.25
	
	penalty = ( 0*(max(T_theta :- c_alpha)<=0) + max(T_theta :- c_alpha)^2*(max(T_theta :- c_alpha)>0) )/c_alpha 
    penalty = penalty + ( 0*( phiT_theta - 1 + (2*3.14159)^0.5 * eta <=0 ) + ( phiT_theta - 1 + (2*3.14159)^0.5 * eta )^2*(( phiT_theta - 1 + (2*3.14159)^0.5 * eta )>0))/2 
	penalty = penalty + ( 0*( -phiT_theta + 1 - (2*3.14159)^0.5 * eta <=0 ) + ( -phiT_theta + 1 - (2*3.14159)^0.5 * eta )^2*( -phiT_theta + 1 - (2*3.14159)^0.5 * eta >0))/2

////////////////////////////////////////////////////////////////////////////////
// Penalization Parameter
	PPara = 1000
	
	crit = objective + PPara*penalty
}

////////////////////////////////////////////////////////////////////////////////
// Tuning Parameter eta
real scalar get_eta( q ){
	XLIST = (-100..100):/100
	ser1 = 0
	ser2 = 0
	for( j=(q+1) ; j<=100 ; j++ ){
		curr_fpsi = fpsi(XLIST',j)
		ser1 = ser1 + j^(-3) * max( abs( curr_fpsi ) )
		ser2 = ser2 + j^(-3) * sum( abs( curr_fpsi ) * (XLIST[2]-XLIST[1]) )
	}
	
 	eta = max( ser1 \ ser2 )

	return( eta )
}

////////////////////////////////////////////////////////////////////////////////
// Tuning Parameter delta
real scalar get_delta( q, Y1 ){
	XLIST = (-100..100):/100
	ser = 0
	for( j = (q+1) ; j<=100 ; j++ ){
		curr_fpsi = fpsi(XLIST',j)
		curr_fpsi_prime = fpsi_prime(XLIST',j)
		ser = ser + j^(-3) * mean(Y1) * max( abs( curr_fpsi ) )
		ser = ser + j^(-3) * max( abs( curr_fpsi_prime ) )
	}

	delta = ser;

	return( delta )
}



//////////////////////////////////////////////////////////////////////////////// 
// Estimation
void estimate( string scalar x1v,     string scalar x2v,	 	
			   real scalar numx,      real scalar domain,
			   real scalar tuning,	  real scalar cover,
			   real scalar q,   	  real scalar L,
			   string scalar touse,   string scalar nname, 
			   string scalar cbname) 
{
	printf("\n{hline 78}\n")
	printf("Executing:          Kato, K., Sasaki, Y., & Ura, T. (2021): Robust Inference \n")
	printf("                    in Deconvolution. Quantitative Economics, 12 (1), 109-142.\n")
	printf("{hline 78}\n")

    x1      = st_data(., x1v, touse)
    x2      = st_data(., x2v, touse)
    n       = length(x1)

	// Normalize the Location of x1 to zero
	mean_x1 = mean(x1)
	sd_x1 = ( mean( x1 :* x2 ) :- mean(x1):*mean(x2) )^0.5 // variance(x1)^0.5
	x1 = ( x1:-mean_x1 ) :/ sd_x1
	x2 = ( x2:-mean_x1 ) :/ sd_x1
	
	// Define y and eta
	y = ( x1 :+ x2 ) :/ 2
	eta = ( x1 :- x2 ) :/ 2
	
	// xlist
	xlist = ( ( (1..numx) :- ( (1+numx)/2 ) ) :/ ( (numx-1)/2 ) ) :* domain
	
	// Bandwidth
	h = tuning
	if( tuning <= 0 ){
		h = Delaigle_Gijbels(xlist,n,x1,x2)
	}
		
	// Grid of frequencies
	T = 1/h
	list_t = -1:*T:^(1:/3):-2:*T:^(1:/3):/(L:-1) :+ 2:*T:^(1:/3):/(L:-1):*(1..L)
	list_t = list_t:^3
	
	// Other parameters
	alpha = 1 - cover
	eta = get_eta(q)
	delta = get_delta( q, x1 )
//////////////////////////////////////////////////////////////////////////////// 
// Construct L*(q+1) by n Matrices mat_R And mat_I 
//////////////////////////////////////////////////////////////////////////////// 
	mat_R = J(L*(q+1),n,0)
	mat_I = J(L*(q+1),n,0)
	
	for( j=0 ; j<=q; j++ ){
	mat_cos_tY2 = cos( list_t' * x2' )
	mat_sin_tY2 = sin( list_t' * x2' )
	mat_Y1 = J(L,1,1) * x1'
	psij = fpsi( list_t', j )
	psij_prime = fpsi_prime( list_t', j )

	mat_Im_psij = Im( (0+1i)^j ) :* J(1,n,psij)
	mat_Re_psij_prime = Re( (0+1i)^j ) :* J(1,n,psij_prime)
	mat_Re_psij = Re( (0+1i)^j ) :* J(1,n,psij)
	mat_Im_psij_prime = Im( (0+1i)^j ) :* J(1,n,psij_prime)

	mat_Rj = (2:*3.141593):^0.5 :* ( -mat_cos_tY2 :* ( mat_Y1:*mat_Im_psij :+ mat_Re_psij_prime ) :- mat_sin_tY2 :* ( mat_Y1:*mat_Re_psij :- mat_Im_psij_prime ) )
	mat_Ij = (2:*3.141593):^0.5 :* (  mat_cos_tY2 :* ( mat_Y1:*mat_Re_psij :+ mat_Im_psij_prime ) :- mat_sin_tY2 :* ( mat_Y1:*mat_Im_psij :- mat_Re_psij_prime ) )
	
	mat_R[(j*L+1)..((j+1)*L),] = mat_Rj
	mat_I[(j*L+1)..((j+1)*L),] = mat_Ij
	}
	
//////////////////////////////////////////////////////////////////////////////// 
// Construct L by (q+1) Matrices mat_E_R And mat_E_I
// Construct L*(q+1) by (q+1) Matrices mat_V_R And mat_V_I
//////////////////////////////////////////////////////////////////////////////// 
	mat_E_R = J(L,q+1,0)
	mat_E_I = J(L,q+1,0)
	mat_V_R = J(L*(q+1),q+1,0)
	mat_V_I = J(L*(q+1),q+1,0)

	for ( l=1; l<=L ; l++ ){
	indices = (0..q):*L :+ l
	mat_R_l = mat_R[indices,]
	mat_I_l = mat_I[indices,]
	E_R_l = mean( mat_R_l' )
	E_I_l = mean( mat_I_l' )
	
	V_R_l = mat_R_l * mat_R_l' / n - E_R_l' * E_R_l
	V_I_l = mat_I_l * mat_I_l' / n - E_I_l' * E_I_l
	
	mat_E_R[l,] = E_R_l
	mat_E_I[l,] = E_I_l
	mat_V_R[((l-1)*(q+1)+1)..(l*(q+1)),] = V_R_l
	mat_V_I[((l-1)*(q+1)+1)..(l*(q+1)),] = V_I_l
	}

////////////////////////////////////////////////////////////////////////////////
// Compute the Psi as length(x_list) by (q+1) Matrix psi_list
////////////////////////////////////////////////////////////////////////////////
	psi_list = J(length(xlist),q+1,0)
	for( j=0 ; j<=q ; j++ ){
		psi_list[,j+1] = fpsi( -1*xlist', j )
	}

////////////////////////////////////////////////////////////////////////////////
// Compute the Phi at 0 as 1 by (q+1) Matrix phi_list
////////////////////////////////////////////////////////////////////////////////
	phi_list = J(2,q+1,0)
	for( j=0 ; j<=q ; j++ ){
		phi_list[,j+1] = fpsi(J(2,1,0),j)
	}
	phi_list = phi_list[1,]

////////////////////////////////////////////////////////////////////////////////
// Initial Value of Sieve Coefficients theta by Fourier Coefficients
////////////////////////////////////////////////////////////////////////////////
	theta = J(1,q+1,0) :+ 0.000001

////////////////////////////////////////////////////////////////////////////////
// Initial Value of Sieve Coefficients theta by Fourier Coefficients
////////////////////////////////////////////////////////////////////////////////
	theta = J(1,q+1,0) :+ 0.000001

LVf = estimation((-100..100)/100,n,x1,x2)
LVf = (LVf:>0):*LVf :+ (LVf:<0):*0
for( j=0 ; j<=q ; j++ ){ 
	theta[j+1] = sum( fpsi( -1*(-100..100)'/100, j ) :* LVf' ) * 0.01
}

////////////////////////////////////////////////////////////////////////////////
// Constrained Optimization for Confidence Band
////////////////////////////////////////////////////////////////////////////////
	Conf_Band = J(length(xlist),2,0)
	
	perc = 10
	for( x_idx=1 ; x_idx<=length(xlist) ; x_idx++ ){
		S = optimize_init()
		optimize_init_evaluator(S,&minObjective())
		optimize_init_which(S,"min")
		optimize_init_evaluatortype(S, "d0")
		optimize_init_technique(S,"nr")
		optimize_init_singularHmethod(S,"hybrid") 
		optimize_init_argument(S,1,x_idx)
		optimize_init_argument(S,2,mat_E_R)
		optimize_init_argument(S,3,mat_E_I)
		optimize_init_argument(S,4,mat_V_R)
		optimize_init_argument(S,5,mat_V_I)
		optimize_init_argument(S,6,(n,alpha,eta,delta,L,q))
		optimize_init_argument(S,7,psi_list)
		optimize_init_argument(S,8,phi_list)
		optimize_init_params(S, theta)
		optimize_init_conv_maxiter(S, 100)
		optimize_init_tracelevel(S,"none")
		min_theta_estimate=optimize(S)
		min_estimate = psi_list[x_idx,] * min_theta_estimate' :- eta
			
		S = optimize_init()
		optimize_init_evaluator(S,&maxObjective())
		optimize_init_which(S,"min")
		optimize_init_evaluatortype(S, "d0")
		optimize_init_technique(S,"nr")
		optimize_init_singularHmethod(S,"hybrid")
		optimize_init_argument(S,1,x_idx)
		optimize_init_argument(S,2,mat_E_R)
		optimize_init_argument(S,3,mat_E_I)
		optimize_init_argument(S,4,mat_V_R)
		optimize_init_argument(S,5,mat_V_I)
		optimize_init_argument(S,6,(n,alpha,eta,delta,L,q))
		optimize_init_argument(S,7,psi_list)
		optimize_init_argument(S,8,phi_list)
		optimize_init_conv_maxiter(S, 100)
		optimize_init_tracelevel(S,"none")
		optimize_init_params(S, theta)
		max_theta_estimate=optimize(S)
		max_estimate = psi_list[x_idx,] * max_theta_estimate' :+ eta
		
		Conf_Band[x_idx,] = (min_estimate,max_estimate)
	
		if( 100*x_idx/length(xlist)>=perc ){
			printf("%10.0f%% done.\n", perc)
			perc = perc + 10
		}
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Confidence Bands
	CBl = Conf_Band[,1]
	CBu = Conf_Band[,2]
	//fx = (CBl+CBu):/2
	fx = estimation(xlist,n,x1,x2)'

	////////////////////////////////////////////////////////////////////////////
	// Final Output
	final_xlist = xlist' :* sd_x1 :+ mean_x1
	final_fx = fx' :/ sd_x1
	final_CBl = CBl' :/ sd_x1
	final_CBu = CBu' :/ sd_x1
	
	////////////////////////////////////////////////////////////////////////////
	// Display Results
	printf("\n{hline 64}\n")
	printf("                                Selected Tuning Parameter Values\n")
	printf("                                {hline 32}\n")
	printf("                                                  h = %10.3f\n",h)
	printf("                                                  q = %10.3f\n",q)
	printf("                                                  L = %10.3f\n",L)
	printf("                                                eta = %10.3f\n",eta)
	printf("                                              delta = %10.3f\n",delta)
	for( idx = 1 ; idx <= length(xlist) ; idx++ ){
	if( trunc((idx-1)/10) == (idx-1)/10 ){
		printf("{hline 64}\n")
		printf("         x           f(x)     [%2.0f%% Uniform Confidence Band]\n", 100*cover)
		printf("{hline 64}\n")
	}
	printf("%10.3f     %10.3f     %10.3f     %10.3f\n", final_xlist[idx], final_fx[idx], final_CBl[idx], final_CBu[idx])
	}
	printf("{hline 64}\n")
	
	////////////////////////////////////////////////////////////////////////////
	// Set
	rev_final_fx = J(length(xlist),1,1)
	rev_final_xlist = J(length(xlist),1,1)
	for( idx = 1 ; idx <= length(xlist); idx++ ){
	    rev_final_fx[idx] = final_fx[length(xlist)+1-idx]
	    rev_final_xlist[idx] = final_xlist[length(xlist)+1-idx]
	}
	BBB = final_fx[1] \ final_CBu' \ rev_final_fx \ final_CBl' \ final_fx[length(xlist)]
	XXX = final_xlist[1] \ final_xlist \ rev_final_xlist \ final_xlist \ final_xlist[length(xlist)]
    st_matrix(cbname, (BBB,XXX))
	
    st_numscalar(nname, n)
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
