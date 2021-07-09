capt program drop clr_s
program define clr_s, eclass

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

syntax [if] [in] [,LOWer LEVel(numlist >0 <1 sort) noAIS MINSmooth(integer 5) MAXSmooth(integer 20) noUNDERSmooth RND(integer 10000) *]

marksample touse, nov

if "`level'" == "" {
	local level 0.5 0.9 0.95 0.99
}


local nlevel = wordcount("`level'")

mat level_vector = J(`nlevel',1,0)

forval i = 1/`nlevel' {
	mat level_vector[`i',1] = real(word("`level'",`i'))
}

if `minsmooth' > `maxsmooth' {
	display as error "minsmooth should be equal or samller than maxsmooth" 
	error 198
}

if "`ais'" != "noais" {
	local vsemtd 1
}
else { 
	local vsemtd 0
}

if "`undersmooth'" != "noundersmooth" {
	local smooth 1
	local txt_smooth "Undersmoothed"
}
else {
	local smooth 0 
	local txt_smooth "Not Undersmoothed"
}


if "`lower'" != "lower" {
	local upp 1
}
else {
	local upp 0
}

mata: bsp("`y'","`x'", "`v'",`vsemtd',`minsmooth',`maxsmooth',`smooth',`rnd',`upp',"`touse'")

tempname theta se V omega ai_selection bounds cl grid nf_x

mat `se' = r(se)
mat `theta' = r(theta)
mat `omega' = r(omega)
mat `bounds' = r(bounds)
mat `cl' = r(cvls)
mat `grid' = r(grid)
mat `nf_x' = r(nf_x)

ereturn clear

if "`ais'" != "noais" {
	mat `ai_selection' = r(ais) 
}

local N = r(N)

ereturn local cmd = "clr_s"
ereturn local level = "`level'"
ereturn local depvar = "`y'"
ereturn local smoothing = "`txt_smooth'"

if "`lower'" != "lower" {
	ereturn local title  = "CLR Intersection Upper Bounds (Series)"
}
else {
	ereturn local title  = "CLR Intersection Lower Bounds (Series)"
}

ereturn scalar N = r(N)
ereturn scalar n_ineq = `numeq'
ereturn matrix omega = `omega'

display as text _newline e(title) _col(59) "Number of obs : " as result e(N)
display as text "Estimation Method : Cubic B-Spline (" e(smoothing) ")" 

local grid_count = 0
tokenize `x'

forval i = 1/`numeq' {
	
	tempname ais`i' se`i' theta`i' 
	ereturn scalar grid`i' = `grid'[`i',1]
	ereturn scalar nf_x`i' = `nf_x'[`i',1]
	
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
	display as text "{hline 81}"
	display as text "Inequality #`i' : " word(e(depvar),`i') " (# of Grid Points : " as result e(grid`i') as text ", Independent Variable : " e(indep`i') " )"
	display as text "Numbers of Approximating Functions : " as result e(nf_x`i') 	
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

display as text "{hline 81}" 


if "`ais'" != "noais" {
	display as text _newline "AIS(adaptive inequality selection) is applied" 
}
else { 
	display as text _newline "AIS(adaptive inequality selection) is not applied" 
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
void bsp(string vector y, string vector x, string vector v, real scalar vsemtd, real scalar minsmooth, real scalar maxsmooth, real scalar smooth, real scalar rnd_num, real scalar upp, string scalar touse){
	
	
	Y = X = V =.
	Y = st_data(.,y,touse)
	X = st_data(.,x,touse)
	V = st_data(.,v)
	
	Y = Y[order(X,1),.]
	X = sort(X,1) 
	
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
	
	y_adj = vec(Y) 
	
	
	// Calculate psi_x which is obtained by B-Splines 
	
	nf_x_set = minsmooth::maxsmooth
	nf_vector = J(j,1,0)
	
	for (i_ineq = 1; i_ineq <= j; i_ineq++){

		cvmat = J(length(nf_x_set),1,0)
	
		for (i_nf_x=1; i_nf_x<= length(nf_x_set); i_nf_x++){
			
			nf_x_i = nf_x_set[i_nf_x]
		
			// B-Splines 
			
			x_set = X[.,i_ineq]
			y_set = Y[.,i_ineq]
			
			intercept = 1
			xmin = colmin(x_set)
			xmax = colmax(x_set)
			knstep = nf_x_i - 4
			
			knq_x = 1/(knstep+1)
			for (temp = 2; temp <= knstep; temp++){ 
				knq_x = knq_x \ temp/(knstep+1)
			}
			
			kt_x = mm_quantile(x_set,1,knq_x);
			st_matrix("kt_x",kt_x)
			psi_x = B_splines(x_set,3,kt_x,xmin,xmax,intercept)
			
			// Sieve Estimation
		
			inv_x = pinv(psi_x' * psi_x)
			bhat = inv_x * psi_x' * y_set
			uhat = y_set - psi_x * bhat 
			L_mat = psi_x * inv_x * psi_x'
			rhat = uhat :/(1 :- diagonal(L_mat))
			cvmat[i_nf_x] = rhat' * rhat / rows(rhat)
			
			
		}
		
		cv_index = 0
		dummy_w = 0
		minindex(cvmat,1,cv_index,dummy_w)
		nf_x = nf_x_set[cv_index]
		
		if (smooth == 1) {
			nf_x = nf_x * nn^(-1/5) * nn^(2/7)
			nf_x = floor(nf_x)
		}
		
		nf_vector[i_ineq] = nf_x
	
	}
	
	st_matrix("r(nf_x)",nf_vector)
	
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
	rnd_MAT = rnd_R(sum(grid_vector),j,rnd_num)
	
	if (vsemtd == 1) {
		gamma_n = 1-0.1/log(nn)
		
		sieve_est(Y,X,argminset,grid_vector,nf_vector,gamma_n,rnd_MAT,j,ml,sel,cvl)
		
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
		
		sieve_est(Y,X,argminset2,ais_vector,nf_vector,level,rnd_MAT,j,ml2,sel2,cvl2)
	
	}
	
	else {
		sieve_est(Y,X,argminset,grid_vector,nf_vector,level,rnd_MAT,j,ml2,sel2,cvl2)
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
	
	if (vsemtd == 0) {
		st_matrix("r(se)", sel2)
		st_matrix("r(theta)",ml2)
	}	
	
}
end

// begin of rnd_R.mata
version 11.2
mata: 
// rnd_R 1.0.0 Wooyoung Kim 8July2012
real matrix rnd_R(real scalar vseq, real scalar J,real scalar rnd_num){
	rnd_MAT = rnormal(((vseq+1)*J),rnd_num,0,1)
	return(rnd_MAT)
}
end

// begin of sieve_est.mata
version 11.2 
mata: 
// sieve_est 1.0.0 Wooyoung Kim 12July2012
void sieve_est(real matrix y, real matrix x, real matrix z, real matrix grid, real matrix nf_x, real matrix level, real matrix rnd_MAT, real scalar j,fe,se,cv){ 
// y = inequality
// x = data 
// z = points at which a function is estimated
// grid = number of grid per each inequality
// kt_x = numbers of approximating functions
// level = level of the confidence set
// rnd_MAT = randomly generated normal dist. 
// j = number of inequalities
// Output : function estimates, their standard errors, uniform critical values 

    
	// B-splines
	
	z_rows = 0
	x_rows = 0 
	x_cols = 0
	y_count = . 
	
	for(i_count = 1; i_count <= j; i_count++) {
		
		if (grid[i_count] != 0) {
			z_rows = z_rows + grid[i_count] 
			x_rows = x_rows + rows(x)
			x_cols = x_cols + nf_x[i_count] 
			y_count = y_count\i_count
		}
	}
	
	y_count = y_count[2::rows(y_count)] 
	
	y = y[.,y_count]
	y_adj = vec(y)
	
	
	psi_x = J(x_rows,x_cols,0)
	psi_z = J(z_rows,x_cols,0)
	
	v_index = 0 
	nf_index = 0 
	valid_count = 1
	
	for (i_count = 1; i_count <= j; i_count++) {
		
		if (grid[i_count] != 0) {
		
			x_set = x[.,i_count]
			z_set = z[v_index+1::v_index+grid[i_count]] 
			
			knstep = nf_x[i_count] - 4;
			intercept = 1
			xmin = colmin(x_set)
			xmax = colmax(x_set)
			
			knq_x = 1/(knstep+1)
			
			for (temp = 2; temp <= knstep; temp++){ 
				knq_x = knq_x \ temp/(knstep+1)
			}
			
			kt_x = mm_quantile(x_set,1,knq_x)
			x_adj = B_splines(x_set,3,kt_x,xmin,xmax,intercept)
			z_adj = B_splines(z_set,3,kt_x,xmin,xmax,intercept)
			
			psi_x[rows(x)*(valid_count-1)+1::rows(x)*valid_count,nf_index+1::nf_index+nf_x[i_count]] = x_adj
			psi_z[v_index+1::v_index+grid[i_count],nf_index+1::nf_index+nf_x[i_count]]= z_adj
		
			valid_count++
			v_index = v_index + grid[i_count]
			nf_index = nf_index + nf_x[i_count]
		}
	}
	
	// Sieve Estimation
	
	tmp1 = pinv(psi_x' * psi_x)
	tmp2 = psi_x'
	bhat = tmp1 * (tmp2 * y_adj)
	uhat = y_adj - psi_x * bhat
	tmp3 = tmp2 * diag(uhat :^ 2) * tmp2'
	var = tmp1 * tmp3 * tmp1 
	
	ghat = psi_z * bhat
	varhat = psi_z * var * psi_z'
	
	sehat = sqrt(diagonal(varhat))
	
	Sigmahat = diag(1:/sehat)*varhat*diag(1:/sehat)
	
	rnd_RR = cholesky(Sigmahat + (0.00000001)*I(rows(Sigmahat)))* rnd_MAT[(1::rows(psi_z)),.]
	tmp_RR = colmax(rnd_RR)'
	
	
	acv = mm_quantile(tmp_RR,1,level)
	
	fe = ghat
	se = sehat
	cv = acv
	
	st_matrix("r(omega)",var)

}  
end

//begin of B_splines.mata
version 11.2
mata: 
// B_splines 1.0.0 Wooyoung Kim 8July2012
real matrix B_splines(real vector x, real scalar deg,real vector knots, real scalar xmin, real scalar xmax, real scalar intercept){
	k = deg + 1
	t = xmin \ knots \ xmax
	l_t = length(t)
	l_x = length(x)
	tr1 = t[1::(l_t-1)]
	tr2 = t[2::l_t]
	m1tmp = J(l_x,length(tr1),0)
	for (i=1;i<=l_x;i++) {
		m1tmp[i,.] = (x[i] :>= tr1') :* (x[i] :< tr2')
		if (x[i] == xmax) {
			m1tmp[i,length(tr1)] = 1
		}
	}
	
	if (k > 1) {
		for (i_k=2;i_k<=k;i_k++){
			t = xmin * J(i_k,1,1) \ knots \ xmax * J(i_k,1,1) 
			m1tmp = J(rows(m1tmp),1,0), m1tmp, J(rows(m1tmp),i_k,0)
			l_t = length(t)
			tr1 = t[1::(l_t-i_k)]
			tr2 = t[i_k::l_t-1]
			m11 = m1tmp'
			m11 = m11[(1::(rows(m11)-i_k)),.]
			m11 = m11'
			
			den1 = (tr2 - tr1)'
			den1 = (1:-(den1 :== 0)) :/ (den1 + (den1 :== 0))
			term1 = J(l_x,length(tr1),0)
			for (i=1;i<=l_x;i++){
				term1[i,.] = x[i] :- tr1'	
			}
			
			term1 = term1 :* m11
			for (i=1;i<=l_x;i++){
				term1[i,.] = term1[i,.] :* den1
			}
			
			tr3 = t[i_k+1::l_t]
			tr4 = t[2::l_t-i_k+1]
			m12 = m1tmp'
			m12 = m12[(2::(rows(m12)-i_k+1)),.]
			m12 = m12'
			den2 = (tr3 - tr4)'
			den2 = (1:-(den2 :== 0)) :/ (den2 + (den2 :== 0))
			term2 = J(l_x,length(tr2),0)
			
			for (i=1;i<=l_x;i++){
				term2[i,.] = tr3' :- x[i] 	
			}
			term2 = term2 :* m12
			for (i=1;i<=l_x;i++){
				term2[i,.] = term2[i,.] :* den2
			}
			
			m1tmp = term1 + term2
			
			 
		}
	}
	
	if (intercept == 0){
		m1tmp = m1tmp[|1,2\.,.|]
	}
	

	return(m1tmp)
 
}
end   
	
