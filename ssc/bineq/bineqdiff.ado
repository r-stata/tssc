// Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
// HIY 1.0.0 08 April 2016
program define bineqdiff, rclass
	version 12.1
	syntax namelist(min=2 max=2) [, Restrict(string) Null(string)]  
	//define temporary variables and matrices
	tempname est_0 b_a V_a type_a b_b V_b type_b dim_A dim_eta	
	tempname A eta chi2 pval df 	
	//hold current estimates
	capture _estimates hold `est_0', restore
	
	//parse two estimates in namelist  (est_a est_b)
	gettoken est_a est_b: namelist	
	
	//define macros and check for the compatibility of estimates
	qui est restore `est_a'
	if (`"`e(cmd)'"' != "bineq") error 301
	matrix `b_a' = e(b)
	matrix `V_a' = e(V)	
	local type_a `e(type)'
	local alphavar_a `e(alphavar)'
	local betavar_a `e(betavar)'	
	
	qui est restore `est_b' 
	if (`"`e(cmd)'"' != "bineq") error 301	
	matrix `b_b' = e(b)
	matrix `V_b' = e(V) 
	local type_b `e(type)'
	local alphavar_b `e(alphavar)'
	local betavar_b `e(betavar)'
	
	if ("`type_a'" != "`type_b'") {
		di as error "estimation results `est_a' and`est_b' must be the same type of index."
		exit 197
	}
	
	if ("`alphavar_a'" != "`alphavar_b'") | ("`betavar_a'" != "`betavar_b'") {
		di as error "estimation results `est_a' and`est_b' seem to measure inequality in different sets of variables. double-check comparability."			
	}
	
	//check dimensions of linear restriction & null matrices
	if ("`e(type)'" == "aks") local k = 3
	if ("`e(type)'" == "mld") local k = 2
	
	if ("`restrict'" == "") & ("`null'" == "") {
		matrix `A' = I(`k')
		matrix `eta' = J(1,`k',0)
	}
	
	if ("`restrict'" != "") { 	
		matrix `A' = `restrict'
		matrix `dim_A' = colsof(`A')
		if (`dim_A'[1,1] != `k') {
			di as error "matrix `restrict' must have `k' columns."
			exit 197
		}		
		matrix `dim_A' = rowsof(`A')
		if (`dim_A'[1,1] > `k') {
			di as error "matrix `restrict' specifies more than `k' restrictions."
			exit 197
		}
		if ("`null'" == "") {
			matrix `eta' = J(1,`=`dim_A'[1,1]',0)
		}
	}

	if ("`null'" != "") {
		if ("`restrict'" == "") {
			di as error "matrix restrict() must be specified when null(`null') is specified."
		    exit 197
		}	
		matrix `eta' = `null'
		matrix `dim_eta' = rowsof(`eta')
		if (`dim_eta'[1,1] > 1) {
			di as error "matrix `null' must be a row vector."
			exit 197
		}
		matrix `dim_eta' = colsof(`eta')
		if (`dim_eta'[1,1] > `k') {
			di as error "matrix `null' must have at most `k' columns."
			exit 197
		}
	}
	
	//carry out tests
	mata: chi2_diff()
	
	//report & return computational results
	di as text "A test of differences in equality structure between two independent populations"
	di as text "chi2(" as result scalar(`df') ") = " as result round(scalar(`chi2'),0.0001) 
	di as text "Prorb>chi2) = " as result %5.4f round(scalar(`pval'),0.0001) 
	return scalar chi2 = `chi2'
	return scalar df = `df'
	return scalar p = `pval'
	return matrix restrict = `A'
	return matrix null = `eta'
end

//AKS test program
version 11.1
mata: 
function chi2_diff()
{
//read things from Stata
b_a = st_matrix(st_local("b_a"))
V_a = st_matrix(st_local("V_a"))
b_b = st_matrix(st_local("b_b"))
V_b = st_matrix(st_local("V_b"))
eta = st_matrix(st_local("eta"))
A = st_matrix(st_local("A"))

//transform inequality indices into equality indices
if (cols(b_a) == 3) {
	d_a = (1 :- b_a)[1,1..2], b_a[1,3]
	d_b = (1 :- b_b)[1,1..2], b_b[1,3]
}
else {
	d_a = 1 :- b_a
	d_b = 1 :- b_b
}

//compute test statistic and pvalue
CHI2 = ((d_a - d_b) * A' - eta) * invsym(A*(V_a + V_b)*A') * (A * (d_a - d_b)' - eta')   
PVAL = 1-chi2(rank(A),CHI2)
DF = rank(A)

//report results as Stata scalars
st_numscalar(st_local("chi2"),CHI2)
st_numscalar(st_local("pval"),PVAL)
st_numscalar(st_local("df"),DF)
} 
end 

exit 
