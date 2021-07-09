capt program drop clr_k
program define clr_k, eclass

version 11.2


local x ` '
local v ` '

local numeq = 1
gettoken eqn`numeq' 0: 0, match(leftover)

tokenize `eqn`numeq'' 	
local y `1'
macro shift

local nindep`numeq' = wordcount("`*'")/2
		
if int(`nindep`numeq'') != `nindep`numeq'' {
	display as error "syntax error" 
	error 198
}

forvalues j = 1/`nindep`numeq'' {
		local x `x' `1'
		macro shift
}
	
forvalues j = 1/`nindep`numeq'' {
		local v `v' `1'
		macro shift
}

mat indep_vector = `nindep`numeq''

while "`leftover'" == "(" {
		
		local check word("`0'",1)
		
		if `check' ==  "," | `check' == "if" |`check' == "in" | `check' == ""{
			continue, break
		}
		
		local numeq = `numeq' + 1
		gettoken eqn`numeq' 0: 0 , match(leftover)
		
		tokenize `eqn`numeq''
		
		local y `y' `1'
		macro shift
		
		local nindep`numeq' = wordcount("`*'")/2
		
		if int(`nindep`numeq'') != `nindep`numeq'' {
			display as error "syntax error" 
			error 198
		}
		
		forvalues j = 1/`nindep`numeq'' {
			local x `x' `1'
			macro shift
		}
	
		forvalues j = 1/`nindep`numeq'' {
			local v `v' `1'
			macro shift
		}
		
		mat indep_vector = indep_vector \ `nindep`numeq''
		
}


syntax [if] [in] [, LOWer LEVel(numlist >0 <1 sort) noAIS noUNDERSmooth BANDwidth(real 0) RND(integer 10000) *]

marksample touse, nov

if "`level'" == "" {
	local level 0.5 0.9 0.95 0.99
}


local nlevel = wordcount("`level'")

mat level_vector = J(`nlevel',1,0)

forval i = 1/`nlevel' {
	mat level_vector[`i',1] = real(word("`level'",`i'))
}

if "`ais'" != "noais" {
	local vsemtd 1
}
else { 
	local vsemtd 0
}

if "`lower'" != "lower" {
	local upp 1
}
else {
	local upp 0
}

if "`undersmooth'" != "noundersmooth" {
	local smooth 1
	local txt_smooth "Undersmoothed"
}
else {
	local smooth 0 
	local txt_smooth "Not Undersmoothed"
}

mata: bsp("`y'","`x'", "`v'",`vsemtd',`rnd',`upp',"`touse'",`smooth',`bandwidth')

tempname theta se V ai_selection bounds cl grid bdwh 

mat `se' = r(se)
mat `theta' = r(theta)
mat `bounds' = r(bounds)
mat `cl' = r(cvls)
mat `grid' = r(grid)
mat `bdwh' = r(bdwh)

ereturn clear

if "`ais'" != "noais" {
	mat `ai_selection' = r(ais) 
}

local N = r(N)

ereturn local cmd = "clr_k"
ereturn local level = "`level'"
ereturn local depvar = "`y'"

if "`lower'" != "lower" {
	ereturn local title  = "CLR Intersection Upper Bounds (Local Linear)"
}
else {
	ereturn local title  = "CLR Intersection Lower Bounds (Local Linear)"
}

ereturn scalar N = r(N)
ereturn scalar n_ineq = `numeq'


display as text _newline e(title) _col(59) "Number of obs : " as result e(N)

local grid_count = 0
tokenize `x'

forval i = 1/`numeq' {
	
	tempname ais`i' se`i' theta`i' 
	ereturn scalar grid`i' = `grid'[`i',1]
	ereturn scalar bdwh`i' = `bdwh'[`i',1]
	
	local num_indep`i' = indep_vector[`i',1]
	
	forval j = 1/`num_indep`i'' {
		local indeplist`i' `indeplist`i'' `1' 
		macro shift
	}
	
	ereturn local indep`i' "`indeplist`i''"
	
	if "`ais'" != "noais" {
		mat `ais`i'' = `ai_selection'[`grid_count'+1..`grid_count'+e(grid`i'),1]
		ereturn matrix ais`i' = `ais`i''
	}
	mat `se`i'' = `se'[`grid_count'+1..`grid_count'+e(grid`i'),1]
	mat `theta`i'' = `theta'[`grid_count'+1..`grid_count'+e(grid`i'),1]
	
	ereturn matrix se`i' = `se`i''
	ereturn matrix theta`i' = `theta`i''
	display as text "Inequality #`i' : " word(e(depvar),`i') " (# of Grid Points : " as result e(grid`i') as text ", Independent Variable : " e(indep`i') " )"
	local grid_count = `grid_count' + e(grid`i')
}

tokenize `v'
forval i = 1/`numeq' {
	forval j = 1/`num_indep`i'' {
		local range`i' `range`i'' `1' 
		macro shift
	}
	ereturn local range`i' "`range`i''"
}



if "`ais'" != "noais" {
	display as text _newline "AIS(adaptive inequality selection) is applied" 
}
else { 
	display as text _newline "AIS(adaptive inequality selection) is not applied" 
}

if "`undersmooth'" != "noundersmooth" {
	display as text "Bandwidths are undersmoothed" 
}
else { 
	display as text "Bandwidths are not undersmoothed" 
}
	
display as text _newline _col(38) "{c |}" _col(55) "Value"
display as text "{hline 37}{c +}{hline 43}"

forval i = 1/`nlevel' {
	local bd_level = level_vector[`i',1]
	local bd_name = 100 * `bd_level'
	while (int(`bd_name') != `bd_name') {
		local bd_name = `bd_name' * 10 
	}
	ereturn scalar bd`bd_name' = `bounds'[`i',1]
	ereturn scalar cl`bd_name' = `cl'[`i',1]

	if `bd_level' == 0.5 {
		display as text "half-median-unbiased estimator" _col(38)"{c |}" _col(53) as result %9.7f e(bd`bd_name')
	}
	else {
		if "`lower'" == "lower" {
			display as text 100*`bd_level' "% one-sided confidence interval" _col(38)"{c |}" _col(48) "[ " as result %9.7f e(bd`bd_name') as text ", inf)"
		}
		else {
			display as text 100*`bd_level' "% one-sided confidence interval" _col(38)"{c |}" _col(48) "( -inf, " as result %9.7f e(bd`bd_name') as text " ]"
		}
	}

}

display as text "{hline 37}{c BT}{hline 43}"

return clear
mat drop level_vector
mat drop indep_vector
	
end


version 11.2
mata: mata clear
mata:
void bsp(string vector y, string vector x, string vector v, real scalar vsemtd, real scalar rnd_num, real scalar upp, string scalar touse, real scalar smooth, real scalar bandwidth){
	
	
	Y = X = V =.
	Y = st_data(.,y,touse)
	X = st_data(.,x,touse)
	V = st_data(.,v)
	
	level = st_matrix("level_vector")
	
	if (upp == 1) {
		Y = -Y
	}
	
	// Check missing values and rearrange x,y matrices
	
	nonmissingrow = . 
	
	y_missing = rowmissing(Y)
	x_missing = rowmissing(X)
	
	for (i_count = 1; i_count <= rows(Y); i_count++){
		if (y_missing[i_count] + x_missing[i_count] == 0) {
			nonmissingrow = nonmissingrow\i_count 
		}
	}
	
	X = X[nonmissingrow[2::rows(nonmissingrow)],.]
	Y = Y[nonmissingrow[2::rows(nonmissingrow)],.]
	
	nn = rows(Y)
	j = cols(Y)
	st_numscalar("r(N)",nn)
	
	
	
	if (bandwidth == 0) {
	
		h_vec = J(j,1,0)
	
		for (ineq = 1; ineq <= j; ineq++) {
		
			// Bandwidth Selection 
		
			xx = (X[.,ineq] :- mean(X[.,ineq]))/ sqrt(variance(X[.,ineq])) // X should be vector, not matrix  
			
			xreg = J(nn,1,1), xx, xx:^2, xx:^3, xx:^4
			para = pinv(xreg'* xreg) * xreg' * Y[.,ineq]
			resi = Y[.,ineq] - xreg * para
			sig2 = mean(resi:^2)
			drv2 = 2* para[3,1] * J(nn,1,1) + 6 * para[4,1] * xx + 12 * para[5,1] * (xx:^2)
			
			w0h = ( xx :>= mm_quantile(xx, 1, 0.1)) :* ( xx :<= mm_quantile(xx,1,0.9)) // This would return error if X is matrix not vector
			den = colsum((drv2:^2) :* w0h)
			num = sig2 * (colmax(w0h) - colmin(w0h)) // density weight between 0.1 and 0.9 quantiles 
			
			h = 2.036 * sqrt(variance(X[.,ineq]))*((num:/den'):^(1/5)) // bandwidth for bound estimation
			
			if (smooth == 1) {
				h = h * (nn^(1/5)) * (nn^(-1/3.5))
			}
			
			h_vec[ineq,1] = h // bandwidth for standard error estimation
			
		
		}
	
	}
	
	else {
		h_vec = J(j,1,bandwidth)
		
	}
	
	st_matrix("r(bdwh)",h_vec)
	
	// Select argminset
	
	// sp_large = J(j,2,0)
	
	
	/*
	vs_large = J(vseq+1,j,0)
	
	vmax = colmax(V)
	vmin = colmin(V)
	
	for (i_set=1;i_set<=j;i_set++){
		vs_large[1,i_set] = vmin
		for (temp = 2; temp <= vseq+1; temp++){
			vs_large[temp,i_set] =vs_large[temp-1,i_set]+(vmax - vmin)/vseq
		}
	}
	*/
	
	/*
	for (i_set=1;i_set<=j;i_set++){
		
		if (cutpoint[i_set] == 0){
			sp_large[i_set,.] = mm_quantile(V,1,(0.05,0.95))
		}
		else if (cutpoint[i_set] == 1){
			sp_large[i_set,.] = (mm_quantile(V,1,0.05),v0[i_set])
		}
		else if (cutpoint[i_set] == 2){
			sp_large[i_set,.] = (v0[i_set],mm_quantile(V,1,0.95))
		}
	
		vs_large[1,i_set] = sp_large[i_set,1]
		for (temp = 2; temp <= vseq+1; temp++){
			vs_large[temp,i_set] =vs_large[temp-1,i_set]+(sp_large[i_set,2] - sp_large[i_set,1])/vseq
		}
	}
	*/
	
	grid_vector = J(j,1,0)
	argminset = .
	
	// caculate the row size of v 
	
	for(i_indep = 1; i_indep <=j; i_indep++){
		grid_mat = V[.,i_indep] 
		grid_missing = rowmissing(grid_mat) 
		grid_count = 0 
		for (i_count = 1; i_count <= rows(grid_mat); i_count++) {
			if (grid_missing[i_count] == 0) {
				grid_count++
				argminset = argminset\grid_mat[i_count] 
			}
		}
		grid_vector[i_indep] = grid_count 
	}
	
	st_matrix("r(grid)",grid_vector)
	argminset = argminset[2::rows(argminset)]
	

	// Random Number Generating Process
	
	
	
	rnd_MAT = .
	rnd_MAT = rnd_R(nn-1,rnd_num)
	
	if (vsemtd == 1) {
		gamma_n = 1-0.1/log(nn)
		
		kernel_est(Y,X,argminset,grid_vector,gamma_n,h_vec,rnd_MAT,j,ml,sel,cvl)
		
		cutoff = colmax(ml - sel:*cvl) :- 2*sel:*cvl
		setindex = (ml :>= cutoff)
		
		ais_vector = J(j,1,0)
		argminset2 = .
		
		grid_index = 1
		
		for (i_count = 1; i_count <= j; i_count++) {
			n_grid = 0
			for(grid_count = 1; grid_count <= grid_vector[i_count]; grid_count++){
				if (setindex[grid_index] == 1) {
					argminset2 = argminset2\argminset[grid_index] 
					n_grid++
					
				}
				grid_index++
			}
			ais_vector[i_count] = n_grid
		}
		
		argminset2 = argminset2[2::rows(argminset2)]
		
		
		if (upp == 1) {
			ml = -ml
		}
		
		st_matrix("r(ais)", setindex)
		st_matrix("r(se)", sel)
		st_matrix("r(theta)",ml)
		
		kernel_est(Y,X,argminset2,ais_vector,level,h_vec,rnd_MAT,j,ml2,sel2,cvl2)
	
	}
	else {
		
		kernel_est(Y,X,argminset,grid_vector,level,h_vec,rnd_MAT,j,ml2,sel2,cvl2)
	}	
	
	l_bj = J(rows(level),1,0)
	
	for (i = 1; i <= rows(level) ; i++) {
		l_bj[i] = colmax(ml2 :- sel2 :* cvl2[i])
	}	
	
	if (upp == 1) {
		l_bj = -l_bj
		ml2 = -ml2 
	}
	
	st_matrix("r(bounds)",l_bj)
	st_matrix("r(cvls)",cvl2) 
	
	
	if (vsemtd == 0){
		
		st_matrix("r(se)", sel2)
		st_matrix("r(theta)",ml2)
	}	
}	
	
end

// begin of rnd_R.mata
version 11.2
mata: 
// rnd_R 1.0.0 Wooyoung Kim 8July2012
real matrix rnd_R(real scalar vseq,real scalar rnd_num){
	rnd_MAT = rnormal(vseq+1,rnd_num,0,1)
	return(rnd_MAT)
}
end

// begin of sieve_est.mata
version 11.2 
mata: 
// sieve_est 1.0.0 Wooyoung Kim 12July2012
void kernel_est(real matrix y_all, real matrix x_all, real matrix z_all, real matrix grid, real matrix level, real matrix h_vec, real matrix rnd_MAT, real scalar j,fe,se,cv){ 
// y = inequality
// x = data 
// z = points at which a function is estimated
// grid = number of grid per each inequality
// level = level of the confidence set
// h = bandwidth 
// rnd_MAT = randomly generated normal dist. 
// j = number of inequalities
// Output : function estimates, their standard errors, uniform critical values 


	nn = rows(y_all)
	grid_c = rows(z_all)
	R = cols(rnd_MAT)
	
	ghat_vec = J(grid_c,1,0)
	se_vec = J(grid_c,1,0)
	tmp_RR_final = J(j,R,0)
	
	grid_start = 1
	grid_end = 0
	
	for (i = 1; i <= j; i++) {
		
		if (grid[i] == 0) {
		
		}
		else {
		
			grid_end = grid_end + grid[i]
			
			y = y_all[.,i]
			x = x_all[.,i]
			h = h_vec[i,1]
			
			z = z_all[grid_start::grid_end,1]
			
			ghat = llre(y,x,z,h) // local linear estimation
			ghat_vec[grid_start::grid_end,1] = ghat 
			
			// Pointwise standard error estimation 
			
			fhat = kde(x,z,h) // kernel density estimation
			m = llre(y,x,x,h)
			v = y :- m
			
			exp_z = J(nn,rows(z),0)
			for(row_i = 1; row_i <= nn; row_i++){
				exp_z[row_i,.] = z'
			}
			s = kl((exp_z:-x)/h)
			
			tmp = mean((s:*v):^2)/h
			tmp = sqrt(tmp')
			
			norm = tmp:/fhat
			sehat = norm/sqrt(nn*h)
			se_vec[grid_start::grid_end,1] = sehat
			
			// Critical Values 
			wn_x = ((s':/fhat):*v')*rnd_MAT/sqrt(nn*h)
			
			tmp_RR_i = colmax(wn_x:/norm)
			tmp_RR_final[i,.] = tmp_RR_i
			
			grid_start = grid_start + grid[i]
		}
		
	}
	
	tmp_RR = colmax(tmp_RR_final)
	
	acv = mm_quantile(tmp_RR',1,level)
	
	fe = ghat_vec
	se = se_vec
	cv = acv
	
}  
end

// begin of kde.mata
version 11.2
mata: 
real matrix kde(x,z,h) {
// ------inputs------
// x = n*d vector of observations
// z = k*d vector of arguments of density
// h = d*1 vector of bandwidths
// ------Output------
// k*1 vector of kernel density estimates

	n = rows(x)
	d = cols(x)
	k = rows(z)

	tmp = J(k,n,1)
	for(i = 1; i<= d; i++){
		exp_z = J(k,n,0)
		for(col_i = 1; col_i <= n; col_i++){
			exp_z[.,col_i] = z[.,i]
		}
		arg = (exp_z :- x[.,i]')/h[i]
		tmp = tmp:*(kl(arg)/h[i])	
	}

	fhat = mean(tmp')
	return(fhat')

}
end

// *** Local Linear Regression Estimator ***
// begin of llre.mata
version 11.2
mata: 
real matrix llre(y,x,x0,h){
//------Inputs------ 
// y = n*1 vector of dependent variable
// x = n*1 vector of observations of independent variables
// x0 = a vector of points where a regression function is evaluated
// h = a bandwidth
//------Output------
// local linear regression estimate (evaluated at x0) 

	n = rows(x)
	exp_x0 = J(n,rows(x0),0)
	for(col_i = 1; col_i <= n; col_i++){
			exp_x0[col_i,.] = x0'
		}
	arg = x:-exp_x0
	w0 = kl(arg/h)
	w1 = w0:*arg
	w2 = w0:*(arg:^2)
	
	Sn0 = mean(w0)
	Sn1 = mean(w1)
	Sn2 = mean(w2)
	
	v0 = w0:*y
	v1 = w1:*y
	
	Tn0 = mean(v0)
	Tn1 = mean(v1)
	
	tmp0 = Sn2 :* Sn0 - Sn1:^2
	tmp0 = tmp0 + (1e-8)*(tmp0 :== 0)
	tmp1 = Sn2 :* Tn0 - Sn1 :* Tn1
	tmp2 = Sn0 :* Tn1 - Sn1 :* Tn0 
	mhat = tmp1:/tmp0
	dmhat = tmp2:/tmp0
	
	return(mhat')


}
end


// *** 2nd order kernel function *** 
// begin of kl.mata
version 11.2
mata:
real matrix kl(v_mat){
	term = (15/16)*((1:-v_mat:^2):^2)
	term = term:*(abs(v_mat):<=1)
	return(term)
}
end
