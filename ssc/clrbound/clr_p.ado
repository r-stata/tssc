capt program drop clr_p
program define clr_p, eclass

version 11.2

// extract first inequality from the syntax 

local x ` '
local v ` '

local numeq = 1
gettoken eqn`numeq' 0: 0, match(leftover)

tokenize `eqn`numeq'' 	
local y `1'
macro shift

local nindep`numeq' = wordcount("`*'")/2

// Note that the number of independent variable and corresponding range variable should be the same
// If the number of input is not even, the procedure returns error 

if int(`nindep`numeq'') != `nindep`numeq'' {
	display as error "syntax error" 
	error 198
}

// get independent variables x and corresponding range variables v 		

forvalues j = 1/`nindep`numeq'' {
		local x `x' `1'
		macro shift
}
	
forvalues j = 1/`nindep`numeq'' {
		local v `v' `1'
		macro shift
}

// "indep_vector" records the number of indep. variables for each inequality.  

mat indep_vector = `nindep`numeq''

while "`leftover'" == "(" {
		
		local check word("`0'",1)
		
		if `check' ==  "," | `check' == "if" |`check' == "in"|`check' == "" {
			continue, break
		}
		
		// extract `numeq'-th ineqaulity from the syntax 
		
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
		
		// get independent variables x and corresponding range variables v 		
		
		forvalues j = 1/`nindep`numeq'' {
			local x `x' `1'
			macro shift
		}
	
		forvalues j = 1/`nindep`numeq'' {
			local v `v' `1'
			macro shift
		}
		
		// "indep_vector" records the number of indep. variables for each inequality.  
		
		mat indep_vector = indep_vector \ `nindep`numeq''
		
}

// adjusting options

syntax [if] [in] [,LOWer LEVel(numlist >0 <1 sort) noAIS RND(integer 10000) *]
marksample touse, nov

// set confidence level vector

if "`level'" == "" {
	local level 0.5 0.9 0.95 0.99
}

local nlevel = wordcount("`level'")

mat level_vector = J(`nlevel',1,0)

forval i = 1/`nlevel' {
	mat level_vector[`i',1] = real(word("`level'",`i'))
}


// AIS option

if "`ais'" != "noais" {
	local vsemtd 1
}
else { 
	local vsemtd 0
}

// give random seed 

// determine lower or upper bound 

if "`lower'" != "lower" {
	local upp 1
}
else {
	local upp 0
}

// obtain estimator 

mata: bsp("`y'","`x'", "`v'",`vsemtd',`rnd',`upp',"`touse'")

// make ereturn list and display output 

tempname theta se V omega ai_selection bounds cl grid

mat `se' = r(se)
mat `theta' = r(theta)
mat `omega' = r(omega)
mat `bounds' = r(bounds)
mat `cl' = r(cvls)
mat `grid' = r(grid)

ereturn clear

local N = r(N)

ereturn local cmd = "clr_p"

if "`lower'" != "lower" {
	ereturn local title  = "CLR Intersection Upper Bounds (Parametric)"
}
else {
	ereturn local title  = "CLR Intersection Lower Bounds (Parametric)"	
}

if "`ais'" != "noais" {
	mat `ai_selection' = r(ais) 
}

ereturn local level = "`level'"
ereturn local depvar = "`y'"

ereturn scalar N = r(N)
ereturn scalar n_ineq = `numeq'
ereturn matrix omega = `omega'

display as text _newline e(title) _col(59) "Number of obs : " as result e(N)


// display grid and independent variables for each inequality 

local grid_count = 0
tokenize `x'

forval i = 1/`numeq' {
	
	tempname ais`i' se`i' theta`i'
	ereturn scalar grid`i' = `grid'[`i',1]
	
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

	display as text "Inequality #`i' : " word(e(depvar),`i') " (# of Grid Points : " as result e(grid`i') as text ", Independent Variables : " e(indep`i') " )"
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


// display result 
	
display as text _newline _col(38) "{c |}" _col(55) "Value"
display as text "{hline 37}{c +}{hline 45}"

forval i = 1/`nlevel' {
	local bd_level = level_vector[`i',1]
	local bd_name = 100 * `bd_level'
	while (int(`bd_name') != `bd_name') {
		local bd_name = `bd_name' * 10 
	}
	
	ereturn scalar bd`bd_name' = `bounds'[`i',1]
	ereturn scalar cl`bd_name' = `cl'[`i',1]

	if `bd_level' == 0.5 {
		display as text "half-median-unbiased est." _col(38)"{c |}" _col(53) as result %9.7f e(bd`bd_name')
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

display as text "{hline 37}{c BT}{hline 45}"

return clear
mat drop level_vector
mat drop indep_vector
	
end


version 11.2
mata: mata clear
mata:
void bsp(string vector y, string vector x, string scalar v, real scalar vsemtd, real scalar rnd_num, real scalar upp, string scalar touse){
	
	
	// Import Data from Stata
	
	Y = X = V =.
	Y = st_data(.,y,touse)
	X = st_data(.,x,touse)
	V = st_data(.,v)
	
	
	level = st_matrix("level_vector")
	indep = st_matrix("indep_vector")
	
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
	nindep = cols(X) 
	st_numscalar("r(N)",nn)
	
	// Construct large y_adj and x_adj 
	
	y_adj = vec(Y) 
	x_adj = J(nn*j,nindep+j,0)
	inter = J(nn,1,1)
	
	
	// caculate the size of v 
	
	grid_vector = J(j,1,0)
	
	acc_indep = 1
	x_colcount = 0 
	
	for(i_indep = 1; i_indep <=j; i_indep++){
		c_indep = indep[i_indep]
		grid_mat = V[.,x_colcount+1::x_colcount+c_indep] 
		grid_missing = rowmissing(grid_mat) 
		grid_count = 0 
		for (i_count = 1; i_count <= rows(grid_mat); i_count++) {
			if (grid_missing[i_count] == 0) {
				grid_count++
			}
		}
		grid_vector[i_indep] = grid_count 
	}
	
	
	
	st_matrix("r(grid)",grid_vector)
	v_adj = J(sum(grid_vector),nindep+j,0)
	
	acc_indep = 1
	x_colcount = 0 
	v_index = 0 
	
	// maka pseudo kronecker product x_adj, v_adj   
	
	
	for (i_indep = 1; i_indep <= j; i_indep++){
		c_indep = indep[i_indep]
		x_adj[nn*(i_indep-1)+1::nn*i_indep,acc_indep] = inter
		x_adj[nn*(i_indep-1)+1::nn*i_indep,acc_indep+1::acc_indep+c_indep] = X[.,x_colcount+1::x_colcount+c_indep] 
		
		grid_mat = V[.,x_colcount+1::x_colcount+c_indep] 
		grid_missing = rowmissing(grid_mat) 
		grid_row = . 
		for (i_count = 1; i_count <= rows(grid_mat); i_count++) {
			if (grid_missing[i_count] == 0) {
				grid_row = grid_row\i_count
			}
		}
		
		grid_row = grid_row[2::rows(grid_row)]
		
		v_input = grid_mat[grid_row,.]
		v_inter = J(rows(v_input),1,1)
		
		v_adj[v_index+1::v_index+grid_vector[i_indep],acc_indep] = v_inter
		v_adj[v_index+1::v_index+grid_vector[i_indep],acc_indep+1::acc_indep+c_indep] = v_input 
		
		v_index = v_index + grid_vector[i_indep]
		x_colcount = x_colcount + c_indep 
		acc_indep = acc_indep + c_indep + 1 
	}
	
	st_matrix("r(grid)",grid_vector)
	
	// Random Number Generating Process
	
	
	argminset = v_adj
	
	rnd_MAT = .
	rnd_MAT = rnd_R(rows(argminset),rnd_num)
	
	if (vsemtd == 1) {
		gamma_n = 1-0.1/log(nn)
		
		para_est(y_adj,x_adj,argminset,gamma_n,rnd_MAT,j,ml,sel,cvl)
		
		cutoff = colmax(ml - sel:*cvl) :- 2*sel:*cvl
		setindex = (ml :>= cutoff)
		argindex = .
		
		for (i = 1; i <= rows(argminset); i++) {
			if (setindex[i] > 0) {
				argindex = argindex \ i 
			}
		}
		
		argminset = argminset[argindex[2::rows(argindex)],.]
		
		if (upp == 1) {
			ml = -ml
		}
		
		st_matrix("r(ais)", setindex)
		st_matrix("r(se)", sel)
		st_matrix("r(theta)",ml)
	
	}

	para_est(y_adj,x_adj,argminset,level,rnd_MAT,j,ml2,sel2,cvl2)

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
	rnd_MAT = rnormal(vseq,rnd_num,0,1)
	return(rnd_MAT)
}
end

// begin of sieve_est.mata
version 11.2 
mata: 
// sieve_est 1.0.0 Wooyoung Kim 12July2012
void para_est(real matrix y, real matrix x, real matrix z, real matrix level, real matrix rnd_MAT, real scalar j,fe,se,cv){ 
// x = data 
// z = points at which a function is estimated
// kt_x = numbers of approximating functions
// level = level of the confidence set
// rnd_MAT = randomly generated normal dist. 
// j = number of inequalities
// Output : function estimates, their standard errors, uniform critical values 

	tmp1 = pinv(x' * x)
	tmp2 = x'
	bhat = tmp1 * (tmp2 * y)
	uhat = y - x * bhat
	tmp3 = tmp2 * diag(uhat :^ 2) * tmp2'
	var = tmp1 * tmp3 * tmp1 
	
	ghat = z * bhat
	varhat = z * var * z'
	sehat = sqrt(diagonal(varhat))
	
	Sigmahat = diag(1:/sehat)*varhat*diag(1:/sehat)
	
	rnd_RR = cholesky(Sigmahat + (0.00000001)*I(rows(Sigmahat)))* rnd_MAT[(1::rows(z)),.]
	tmp_RR = colmax(rnd_RR)'
	
	
	acv = mm_quantile(tmp_RR,1,level)
	
	fe = ghat
	se = sehat
	cv = acv
	
	st_matrix("r(omega)",var)

}  
end
 
	
