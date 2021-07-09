capt program drop cmi_test
program define cmi_test, rclass

version 11.1

// Programmed by Wooyoung Kim (University of Wisconsin-Madison, wkim68@wisc.edu) 
// This is the command implementing "Inference Based on Conditional Moment Inequalities" (Donald W.K. Andrews and Xiaoxia Shi, 2013). 


/*
<OUTPUT LIST>

r(x)      : varlist for regressors 
r(m_eq)   : varlist for conditional moment equalities, if any
r(m_ineq) : varlist for conditional moment inequalities, if any
r(title)  : "Conditional Moment Inequalities Test" 
r(cmd)    : "cmi_test"

r(N)      : number of observations 
r(stat)   : test statistic 
r(pval)   : p-value
r(ncube)  : number of cubes 
r(kappa)  : tuning parameter kappa_n for the data-dependent GMS function phi(theta,g) (see (4.9) of Andrews and Shi(2013))
r(B)      : tuning parameter B_n for the data-dependent GMS function phi(theta,g) (see (4.10) of Andrews and Shi(2013))
r(epsilon): tuning parameter for the sample variance-covariance matrix (see (3.5) of Andrews and Shi(2013))
r(rep_cv) : repetitions for critical values
r(a_obs)  : average number of observations in smallest cubes 
r(r_n)    : index for minimum side-edge lengths 

r(cv01)   : 1% significance level critical value
r(cv05)   : 5% significance level critical value
r(cv10)   : 10% significance level critical value 

*/ 


/*
m_ineq : varlist for conditional moment inequalities
m_eq   : varlist for conditional moment equalities
nineq  : 0 if no conditional moment inequalities, 1 otherwise 
neq    : 0 if no conditional moment equalities, 1 otherwise
*/

local mineq ` '
local meq ` ' 

gettoken mineq 0: 0, match(leftover)
gettoken meq 0: 0, match(leftover)

if "`mineq'" == "" {
	local nineq 0
}
else{
	local nineq 1 
}


if "`meq'" == "" {
	local neq 0
}
else{
	local neq 1
}

/*
varlist : varlist for regressors 

<OPTIONS> 
RNUM    : index for minimum side-edge lengths 
HD      : use alternative methods for high dimension  
BOOT    : use bootstrap critical value (default : use asymptotic critical value) 
KS      : use Kolmogorov-Smirnov type statistic (default : Cramer-von Mises-type statistic) 
SFUNC    : function S (1 : SUM 2 : QLR 3 : MAX), default is 1 
EPSilon : tuning parameter for the sample variance-covariance matrix (see (3.5) of Andrews and Shi(2013)), default is 0.05
KAP     : tuning parameter kappa_n for the data-dependent GMS function phi(theta,g) (see (4.9) of Andrews and Shi(2013))
Bn      : tuning parameter B_n for the data-dependent GMS function phi(theta,g) (see (4.10) of Andrews and Shi(2013))
REP     : repetitions for critical values, default is 5001 
SEED    : seed number for randomization, default is 10000 
SIMUL   : do not reset the seed number (for simulation purpose)

*/

syntax varlist [if] [in] [, SIMUL RNUM(integer 0) HD BOOT KS SFUNC(integer 1) EPSilon(real 0.05) KAP(real 0) Bn(real 0) REP(integer 5001) SEED(integer 10000) *]
marksample touse, nov

// check method for critical value
if "`boot'" == "boot"{
	local boots 1 
} 
else {
	local boots 0 
}

// set seed for randomization 
if "`simul'" != "simul"{
	set seed `seed'
}
// High Dimension option

if "`hd'" == "hd" {
	if wordcount("`varlist'") == 1 { 
		local hdindex 0 
		display as text "Warning: Indep. vars is not high-dimentional. The 'high-dimension' option is ignored."
	}
	else {
		local hdindex 1 
	}
}
else {
	local hdindex 0 
}

// Determine the statistic 

if "`ks'" == "ks" {
	local kss 1
}
else {
	local kss 0 
}

// obtain the test statistic and critical values 

mata: cmi("`mineq'","`meq'","`varlist'",`nineq',`neq',`boots',`kss',`rnum',`hdindex',`sfunc',`epsilon',`kap',`bn',`rep',"`touse'")

// return list 
return clear 

return local x = "`varlist'"
return local m_eq = "`meq'"
return local m_ineq = "`mineq'"
return local title = "Conditional Moment Inequalities Test"
return local cmd = "cmi_test"

return scalar N = r(N) 

return scalar stat = r(stat)
return scalar pval = r(pval)
return scalar ncube = r(ncube)
return scalar kappa = r(kappa)
return scalar B = r(B)
return scalar epsilon = r(epsilon)
return scalar rep_cv = r(rep_cv)
return scalar a_obs = r(a_obs) 
return scalar r_n = r(r_n)
return scalar cv01 = r(cv01)
return scalar cv05 = r(cv05)
return scalar cv10 = r(cv10)

// display outputs 

display as text _newline "Conditional Moment Inequalities Test" _col(59) "Number of obs : " as result r(N) 
display as text "{hline 80}"
display as text "<Variables>"
if "`mineq'" != "" {
	display as text "Conditional Moment Inequalities : " as result "`mineq'"
}
else{
	display as text "No Conditional Moment Inequality"
}
if "`meq'" != "" {
	display as text "Conditional Moment Equalities : " as result "`meq'"
} 
else{
	display as text "No Conditional Moment Equality" 
}
display as text "Instruments : " as result "`varlist'"
display as text "{hline 80}"
display as text "<Methods>"
if `hdindex' == 1 {
	return local method = "High Dimension Alternative"
	display as text "High Dimension Alternative" 
}
else {
	return local method = "Countable Hyper Cubes"
	display as text "Countable Hyper Cubes" 
}

if `boots' == 1 {
	return local method_CV = "Bootstrap Critical Value" 
	display as text "Bootstrap Critical Value" 
}
else {
	return local method_CV = "Asymptotic Critical Value" 
	display as text "Asymptotic Critical Value" 
}

if `kss' == 1 & `sfunc' == 1{
	return local method_FUN = "Kolmogorov-Smirnov-type statistic / Sum function"
	display as text "Kolmogorov-Smirnov-type statistic / Sum function"
}
else if `kss' == 1 & `sfunc' == 3{
	return local method_FUN = "Kolmogorov-Smirnov-type statistic / Max function"
	display as text "Kolmogorov-Smirnov-type statistic / Max function"
}
else if `kss' != 1 & `sfunc' == 1{
	return local method_FUN = "Cramer-von Mises-type statistic / Sum function"
	display as text "Cramer-von Mises-type statistic / Sum function"
}
else {
	return local method_FUN = "Cramer-von Mises-type statistic / Max function"
	display as text "Cramer-von Mises-type statistic / Max function"
}


display as text "{hline 80}"
display as text "<Results>"
display as text "Test Statistic " _col(20)" : " as result %5.4f r(stat)
display as text "Critical Value (1%)" _col(20)" : " as result %5.4f r(cv01)
display as text "               (5%)" _col(20)" : " as result %5.4f r(cv05)
display as text "              (10%)" _col(20)" : " as result %5.4f r(cv10)
display as text "p-value " _col(20)" : " as result %5.4f r(pval)

end

 
/*
mata function cmi 

<INPUTS>
m_ineq : varlist for conditional moment inequalities 
m_eq   : varlist for conditional moment equalities 
x      : varlist for regressors   
nineq  : 0 if no conditional moment inequalities, 1 otherwise 
neq    : 0 if no conditional moment equalities, 1 otherwise
r_n    : index for minimum side-edge lengths
s_index: function S (1 : CvM/SUM 2 : CvM/QLR 3 : CvM/MAX)
epsil  : tuning parameter for the sample variance-covariance matrix (see (3.5) of Andrews and Shi(2013))
kap_n  : tuning parameter kappa_n for the data-dependent GMS function phi(theta,g) (see (4.9) of Andrews and Shi(2013))
B_n    : tuning parameter B_n for the data-dependent GMS function phi(theta,g) (see (4.10) of Andrews and Shi(2013))
tau_rep: repetitions for critical values, default is 5001 
touse  : 0/1 to-use variable that records which observations are to be used 


<OUTPUTS> 
r(N)      : number of observations
r(cv)     : #(level) x 1 vector of critical values for given confidence levels  
r(stat)   : test statistic  
r(ncube)  : number of cubes
r(kappa)  : tuning parameter kappa_n for the data-dependent GMS function phi(theta,g) (see (4.9) of Andrews and Shi(2013))
r(B)      : tuning parameter B_n for the data-dependent GMS function phi(theta,g) (see (4.10) of Andrews and Shi(2013))
r(epsilon): tuning parameter for the sample variance-covariance matrix (see (3.5) of Andrews and Shi(2013))
r(rep_cv) : number of repetitions for critical values
r(a_obs)  : average number of observations smallest boxes 
r(r_n)    : index for minimum side-edge lengths 
r(pval)   : p-value 

*/

version 11.1
mata: mata clear
mata: 
void cmi(string vector m_ineq, string vector m_eq, string vector x, real scalar nineq, real scalar neq, real scalar boots, real scalar ks, real scalar r_n, real scalar hd, real scalar s_index, real scalar epsil, real scalar kap_n, real scalar B_n, real scalar tau_rep, string scalar touse){


	// Import Data from STATA, clean data by deleting missing values 
	
	M_ineq = M_eq = X =. 
	X = st_data(.,x,touse)
	nonmissingrow = .
	x_missing = rowmissing(X)
	
	// Import conditional moment inequalities only if we have at least one  
	
	if (nineq != 0){
		M_ineq = st_data(.,m_ineq,touse)
		miq_missing = rowmissing(M_ineq)
	}
	
	// Import conditional moment equalities only if we have at least one  
	
	if (neq != 0){
		M_eq = st_data(.,m_eq,touse)
		meq_missing = rowmissing(M_eq)
	}
	
	if (nineq == 0){
		for (i_count = 1; i_count <= rows(X); i_count++){
			if (meq_missing[i_count] + x_missing[i_count] == 0) {
				nonmissingrow = nonmissingrow\i_count 
			}
		}
	}	
	else if (neq == 0){
		for (i_count = 1; i_count <= rows(X); i_count++){
			if (miq_missing[i_count] + x_missing[i_count] == 0) {
				nonmissingrow = nonmissingrow\i_count 
			}
		}
	}
	else {
		for (i_count = 1; i_count <= rows(X); i_count++){
			if (miq_missing[i_count] + meq_missing[i_count] + x_missing[i_count] == 0) {
				nonmissingrow = nonmissingrow\i_count 
			}
		}
	}
	
	X = X[nonmissingrow[2::rows(nonmissingrow)],.]
	
	if (nineq != 0){
		M_ineq = M_ineq[nonmissingrow[2::rows(nonmissingrow)],.]
	}
	
	if (neq != 0){
		M_eq = M_eq[nonmissingrow[2::rows(nonmissingrow)],.]
	}
	
	// set basic parameters 
	
	N = rows(X)			// # of sample
	DX = cols(X) 		// dimension of regressors 
	
	M1 = 0
	if (nineq !=0){
		M1 = cols(M_ineq) 	// # of conditional moment inequalities 
	}
	M2 = 0 
	if (neq != 0){
		M2 = cols(M_eq)		// # of conditional moment equalities 
	}
	
	// calculate kap_n and B_n if unspecified 
	if (kap_n == 0){
		kap_n = sqrt(0.3*log(N))
	}
	if (B_n == 0){
		B_n = sqrt(0.4*log(N)/log(log(N)))
	}
	
	// return parameters 
	
	st_numscalar("r(N)",N) 
	st_numscalar("r(kappa)",kap_n) 
	st_numscalar("r(B)",B_n)
	st_numscalar("r(epsilon)",epsil)
	st_numscalar("r(rep_cv)",tau_rep)
	
	/* 
	(STEP 1.(a)) Transform each regressors to lie in [0,1] 
	<Variables> 
	X_mean    : 1 x DX matrix of average of X 
	Sigma_hat : DX x DX variance-covariance matrix of X  
	X_adj     : N X DX matrix of transformed X  
	*/
	
	X_mean = mean(X)
	Sigma_hat = variance(X)
	X_adj = normal((X:-X_mean)*sqrt(invsym(diag(diagonal(Sigma_hat)))')) 
	
	// (STEP 1.(b)) Specify the functions g - countable cubes
	// and (STEP 1.(c)) Specify the weight function Q_AR
	
	// Check whether r_n is specified 
	
	if (r_n == 0){
		if (hd == 1){
			r_n = ceil(N^(1/4)/2)
		}
		else{
			r_n = ceil((N)^(1/2/DX)/2)
		}
	}
	
	// High dimension alternative 
	
	if (hd == 1){
		HD_cube(X_adj, N, DX, r_n, g_col, Q_AR, G_X)
	}
	else {
		// g_col : the number of cubes for each r (r_n x 1 vector) 
		// G_X   : function g for countable cubes (N x sum(g_col) matrix)  
		// Q_AR  : weight function (1 x sum(g_col) vector) 
		c_cube(X_adj, N, DX, r_n, g_col, Q_AR, G_X)
	}
	
	
	st_numscalar("r(r_n)", r_n)
	st_numscalar("r(a_obs)", N/g_col[r_n] )
	st_numscalar("r(ncube)",sum(g_col))
	
	// (STEP 1.(d)) Compute the CvM test statistic 
	/*
	N_g : number of index of side-edge lengths 
	N_k : number of conditional moment inequalities and equalities  
	
	m_n : N x N_k matrix of conditional moment inequalities and equalities
	S_m : 
	
	M_g : 
	M_bar : 
	
	sigma_1_hat : 
	Sigma_bar : 
	*/
	
	N_g = cols(G_X)
	
	if(nineq != 0){
		if (neq != 0){
			m_n = M_ineq,M_eq
		}
		else{
			m_n = M_ineq
		}
	}
	else{
		m_n = M_eq
	}
	
	
	N_k = cols(m_n)
	sigma_1_hat = variance(m_n)
	sigma_1_hat = diag(diagonal(sigma_1_hat))
	S_m = J(N_g,1,0)
	M_g = J(N,N_g * N_k,0)
	M_bar = J(N_k*N_g,1,0)
	Sigma_bar = J(N_k*N_g,N_k*N_g,0)
	
	//!!!!!!!!!*** S1, S2 and S3
	
	for (index=1; index<=N_g;index++){
		/*
		M_temp : 
		sigma_n_hat : 
		sigma_n_bar : 
		*/
		
		M_temp = m_n :* G_X[.,index]
		M_g[.,(index-1)*N_k+1::index*N_k] = M_temp
		M_bar[N_k*(index-1)+1::N_k*index,1] = sqrt(N)*mean(M_temp)'
		sigma_n_hat = variance(M_temp)
		sigma_n_bar = diag(diagonal(sigma_n_hat)) + epsil * sigma_1_hat
		Sigma_bar[N_k*(index-1)+1::N_k*index,N_k*(index-1)+1::N_k*index] = sigma_n_bar
		if (s_index == 1){
			S_m[index,1] = S1(sqrt(N)*mean(M_temp),sigma_n_bar,M1)
		}
		else if (s_index == 2){
			S_m[index,1] = S2(sqrt(N)*mean(M_temp),sigma_n_bar,M1,N_k)
		}
		else {
			S_m[index,1] = S3(sqrt(N)*mean(M_temp),sigma_n_bar,M1)
		}
	}
	// compute and return test statistic 
	
	if (ks == 1){
		T_n = max(S_m) // KS statistic 
	}
	else{
		T_n = Q_AR*S_m // CvM statistic 
	}
	st_numscalar("r(stat)",T_n)
	
	// (STEP 2.(a))
	/* 
	D_n : 
	si_n : 
	phi_n : 
	*/
	
	D_n = J(N_g,1,diagonal(sigma_1_hat))
	si_1 = 1 :/ sqrt(diagonal(Sigma_bar))
	si_n = (M_bar :* si_1) / kap_n 
	phi_n = (si_n :>= 1) :* sqrt(D_n) * B_n 
	
	if (neq != 0) {
		for (index = 1; index <= N_g; index++) {
			phi_n[(index-1)*N_k+1+M1::index*N_k,.] = J(M2,1,0)
		}
	}
	
	
	if (boots != 1) {
	
		// Using Asympototic Distribution 
		
		// (STEP 2.(b))
		// Z_n : 
		
		Z_n = rnormal(N_k*N_g,tau_rep,0,1)
		
		// (STEP 2.(c))
		/*
		mg : 
		sig_mg : 
		h_2nmat : 
		*/
		
		mg = J(N,N_g*N_k,0)
		for (g_index =1; g_index <= N_g; g_index++){
			mg_index = m_n :* G_X[.,g_index] 
			mg[.,N_k*(g_index-1)+1::N_k*g_index] = mg_index
		}
		
		
		//sig_mg = crossdev(mg,mean(mg),mg,mean(mg))/N
		sig_mg = variance(mg)
		
		h_2nmat = cholesky(sig_mg + 10^(-10) :* I(N_k*N_g))
		
		// (STEP 2.(d))
		// nu_hat : 
		
		nu_hat = h_2nmat * Z_n
		// (STEP 2.(e))
		// T_reps : 
		
		T_reps = J(1,tau_rep,0)
		for (rep = 1; rep <= tau_rep; rep++){
			T_reps[1,rep] = T_stat(nu_hat[.,rep]+phi_n,Sigma_bar,Q_AR,ks,N_g,N_k,M1,s_index)
		}
		
	}
	
	else {
		
		// Using Bootstrap ctirical value 
		
		b_num = tau_rep // number of bootstrap samples  
		T_reps = J(1,tau_rep,0)
		
		
		for (b_rep = 1; b_rep <= b_num; b_rep++){
		
			// (Step 2.(b)) Generate Bootstrap Samples 
			
			b_sample = ceil( N * uniform(N,1))
			
			if (nineq != 0) {
				M_ineq_b = M_ineq[b_sample,.]
			}
			if (neq != 0){
				M_eq_b = M_eq[b_sample,.]
			}
			
			X_b = X[b_sample,.] 
			
			// (Step 2.(c)) 
			
			X_mean_b = mean(X_b)
			Sigma_hat_b = variance(X_b)
			X_adj_b = normal((X_b:-X_mean_b)*cholesky(invsym(diag(diagonal(Sigma_hat_b)))')) 
			
			if (hd == 1){
				HD_cube(X_adj_b, N, DX, r_n, g_col_b, Q_AR_b, G_X_b)
			}
			else{
				c_cube(X_adj_b, N, DX, r_n, g_col_b, Q_AR_b, G_X_b)
			}
			
			// (Step 2.(d))
			
			N_g_b = cols(G_X_b)
			
			if(ineq != 0){
				if (neq != 0){
					m_n_b = M_ineq_b,M_eq_b
				}
				else{
					m_n_b = M_ineq_b
				}
			}
			else{
				m_n_b = M_eq_b
			}
			
			N_k_b = cols(m_n_b)
			sigma_1_hat_b = variance(m_n_b)
			S_m_b = J(N_g_b,1,0)
			M_g_b = J(N,N_g_b * N_k_b,0)
			M_bar_b = J(N_k_b*N_g_b,1,0)
			Sigma_bar_b = J(N_k_b*N_g_b,N_k_b*N_g_b,0)
			
			//!!!!!!!!!*** S1, S2 and S3
			
			for (index=1; index<=N_g_b;index++){
				/*
				M_temp : 
				sigma_n_hat : 
				sigma_n_bar : 
				*/
				
				M_temp_b = m_n_b :* G_X_b[.,index]
				M_g_b[.,(index-1)*N_k_b+1::index*N_k_b] = M_temp_b
				M_bar_b[N_k*(index-1)+1::N_k_b*index,1] = sqrt(N)*mean(M_temp_b)'
				sigma_n_hat_b = variance(M_temp_b)
				sigma_n_bar_b = diag(diagonal(sigma_n_hat_b)) + epsil * diag(diagonal(sigma_1_hat_b))
				Sigma_bar_b[N_k_b*(index-1)+1::N_k_b*index,N_k_b*(index-1)+1::N_k_b*index] = sigma_n_bar_b
			}
			/*
			M_boot = invsym(sqrt(diag(D_n)))*(M_bar_b-M_bar) + phi_n 
			Sigma_bar_b = invsym(sqrt(diag(D_n))) * Sigma_bar_b * invsym(sqrt(diag(D_n)))
			*/
		
			M_boot = (M_bar_b-M_bar) + phi_n 
			T_reps[1,b_rep] = T_stat(M_boot,Sigma_bar_b,Q_AR,ks,N_g,N_k,M1,s_index)
			
		}
			
	}
	
	// (STEP 2.(f))
	T_reps = sort(T_reps',1)
	p_index = 0
	for (p_rep = 1; p_rep <= tau_rep; p_rep++){
		if (T_reps[p_rep] < T_n) {
			p_index = p_index + 1
		}
	}
	if(p_index == 0){
		p_index = 1
	}
	p_value = 1-(p_index - 1) / (tau_rep - 1)
	
	cv01 = T_reps[0.99*(tau_rep-1)+1]
	cv05 = T_reps[0.95*(tau_rep-1)+1]
	cv10 = T_reps[0.90*(tau_rep-1)+1]
	
	
	st_numscalar("r(pval)",p_value)
	st_numscalar("r(cv01)",cv01)
	st_numscalar("r(cv05)",cv05)
	st_numscalar("r(cv10)",cv10) 
	
}
end


// begin of c_cube.mata
version 11.1
mata:
void c_cube(real matrix X_adj, real scalar N, real scalar DX, real scalar r_n, g_col, Q_AR, G_X){

		g_col = J(r_n,1,0)
		for (i=1; i<=r_n; i++) {
			g_col[i,1] = (2*i)^(DX) 
		}
		
		G_X = J(N,sum(g_col),0)		 
		Q_AR = J(1,sum(g_col),0)	
		for (r=1; r<=r_n; r++) {
			X_index_dim = ceil(X_adj*2*r)
			X_index = J(N,1,1)
			for(d=1; d<=DX; d++) {
				X_index_temp = X_index_dim[.,DX-d+1] :-1
				_editvalue(X_index_temp,-1,0)
				X_index = X_index + ((2*r)^(d-1))*X_index_temp 
			}
			for(g_index=1;g_index<=(2*r)^(DX);g_index++){
				G_X[.,sum(g_col[1::r])-g_col[r]+g_index] = (X_index :== g_index)
			}
			/*for (j=1; j <= 2*r; j++){
				G_X[.,sum(g_col[1::r])-g_col[r]+j] = (X_adj :> (j-1)/(2*r)) :* (X_adj :<= (j/(2*r)))
			}*/
			Q_AR[.,sum(g_col[1::r])-g_col[r]+1::sum(g_col[1::r])] = 1/g_col[r]/(r^2+100) :* J(1,g_col[r],1)
		}
		
		Q_AR = Q_AR / sum(Q_AR) // Adjust the weight function
}
end
		

// begin of HD_cube.mata
version 11.1
mata: 
void HD_cube(real matrix X_adj, real scalar N, real scalar DX, real scalar r_n, g_col, Q_AR, G_X){

		dx_com = comb(DX,2)
		g_col = J(r_n,1,0)
		for (i=1;i<=r_n;i++){
			g_col[i,1] = ((2*i)^2) * dx_com
		}
		
		G_X = J(N,sum(g_col),0)		 
		Q_AR = J(1,sum(g_col),0)	
		
		g_index = 1 
		
		for (r=1; r<=r_n; r++) {
			c_index = 0 
			for(dim=1; dim<=DX-1; dim++) {
				for(dim2=dim+1; dim2<=DX; dim2++){
					y_temp = dim,dim2
					X_temp = X_adj[.,y_temp] 
					X_index_dim = ceil(X_temp*2*r)
					X_index = J(N,1,1)
					for(d=1; d<=2; d++) {
						X_index_temp = X_index_dim[.,DX-d+1] :-1
						_editvalue(X_index_temp,-1,0)
						X_index = X_index + ((2*r)^(d-1))* X_index_temp 
					}
					for(g_index=1;g_index<=(2*r)^2;g_index++){
						G_X[.,sum(g_col[1::r])-g_col[r]+c_index+g_index] = (X_index :== g_index)
					}
				}
				c_index = c_index + (2*r)^2
			}	
			
			Q_AR[.,sum(g_col[1::r])-g_col[r]+1::sum(g_col[1::r])] = 1/(g_col[r]*(r^2+100):*J(1,g_col[r],1))
				
		
		}
		Q_AR = Q_AR / sum(Q_AR) // Adjust the weight function
		
}
end



// begin of T_stat.mata
version 11.1
mata:
real scalar T_stat(real matrix m_bar, real matrix Sigma_bar, real matrix prob_weight, real scalar ks, real scalar N_g, real scalar N_k, real scalar M1, real scalar s_index){
	
	T_vec = J(N_g,1,0)
	
	for (i = 1; i <= N_g; i++){
		m_temp = m_bar[N_k*(i-1)+1::N_k*i,.]
		sigma_temp = Sigma_bar[N_k*(i-1)+1::N_k*i,N_k*(i-1)+1::N_k*i]
		
		if (s_index == 1){
			T_vec[i,1] = S1(m_temp',sigma_temp,M1)
		}
		else if (s_index == 2){
			T_vec[i,1] = S2(m_temp',sigma_temp,M1,N_k)
		}
		else {
			T_vec[i,1] = S3(m_temp',sigma_temp,M1)
		}
	}
	
	if (ks == 1) {
		statistic = max(T_vec) // KS statistic 
	}
	else {
		statistic = prob_weight * T_vec // CvM statistic 
	}
	return(statistic)
}
end


// begin of S1.mata
version 11.1
mata: 
real scalar S1(real matrix m_bar, real matrix sigma_bar, real scalar M1){
	S1_temp = m_bar:/sqrt(diagonal(sigma_bar))'
	if (M1 != 0) {
		S1_temp[1::M1] = S1_temp[1::M1] :* (S1_temp[1::M1] :<= 0 )  
	}
	return(sum(S1_temp:^2))
}
end

// begin of S2.mata
version 11.1
mata: 
void S2_opti(todo,t,crit,g,H)
{
	external m_opti,sigma_opti,N_opti,M_opti
	s = J(1,N_opti,0)
	q = J(1,N_opti,0)
	s[1,1::M_opti] = t
	temp = m_opti - s
	for (i = 1; i<=N_opti; i++) {
	
	}
	
	crit = temp * sigma_opti * temp'
}
real scalar S2(real matrix m_bar, real matrix sigma_bar, real scalar M1, real scalar N_k){
	
	temp_ans = m_bar
	
	if (M1 != 0) {
		external m_opti, sigma_opti, N_opti, M_opti
		m_opti = m_bar
		sigma_opti = sigma_bar
		M_opti = M1
		N_opti = N_k
		
		init = J(1,M1,0)
		
		S2_argmin = optimize_init()
		optimize_init_evaluator(S2_argmin,&S2_opti())
		optimize_init_which(S2_argmin,"min")
		optimize_init_params(S2_argmin,init)
		optimize_init_tracelevel(S2_argmin, "none")
		ans = optimize(S2_argmin) 
		
		s_ans = J(1,N_k,0)
		s_ans[1,1::M1] = ans
		temp_ans = m_bar - s_ans
		
	}
	
	return(temp_ans * sigma_bar * temp_ans')
} 


//begin of S3.mata
version 11.1
mata:
real scalar S3(real matrix m_bar, real matrix sigma_bar, real scalar M1){
	S3_temp = m_bar:/sqrt(diagonal(sigma_bar))' 
	if (M1 != 0) {
		S3_temp[1::M1] = S3_temp[1::M1] :* (S3_temp[1::M1] :<= 0 )  
	}
	return(max(S3_temp:^2))	
}
end

//begin of sqrtm.mata
version 11.1
mata: 
real matrix sqrtm(real matrix M){
	c = cols(M)
	V = J(1,c,0)
	Q = J(c,c,0)
	symeigensystem(M, Q, V)
	V2 = sqrt(diag(V))
	_editvalue(V2,.,0)
	SqM = Q * V2 * Q'
	return(SqM)

}
end

