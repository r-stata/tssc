*! mvdom version 1.1 3/11/2015 Joseph N. Luchman

version 12.1

program define mvdom, eclass

syntax varlist(min = 2) if [aw fw], dvs(varlist min=1) [noConstant epsilon pxy] //epsilon is a hidden option

tempname canonmat 

tempvar touse

gettoken dv ivs: varlist

if strlen("`epsilon'") {

	quietly generate byte `touse' = 1 `if'
	
	quietly replace `touse' = 0 if missing(`touse')

	mata: eps_ri_mv("`dv' `dvs'", "`ivs'", "`touse'")
	
}

else {

	if strlen("`pxy'") {
	
		quietly correlate `dv' `dvs' `ivs' [`weight'`exp'] `if'
		
		local dvnum: word count `dv' `dvs'
		
		matrix `canonmat' = r(C)
		
		matrix `canonmat' = trace( ///
		invsym(`canonmat'[1..`:word count `dv' `dvs'', 1..`:word count `dv' `dvs''])* ///
		`canonmat'[`=`:word count `dv' `dvs''+1'..., 1..`:word count `dv' `dvs'']'* ///
		invsym(`canonmat'[`=`:word count `dv' `dvs''+1'..., `=`:word count `dv' `dvs''+1'...])* ///
		`canonmat'[`=`:word count `dv' `dvs''+1'..., 1..`:word count `dv' `dvs''] ///
		)
		
		ereturn scalar r2 = `canonmat'[1, 1]/`:word count `dv' `dvs''
		
	}

	else {

		quietly _canon (`dv' `dvs') (`ivs') [`weight'`exp'] `if', `constant'

		matrix `canonmat' = e(ccorr)

		ereturn scalar r2 = `canonmat'[1, 1]^2

	}
	
	ereturn local title "Multivariate regression"
	
}

end

/*Mata function to execute epsilon-based relative importance with mvdom*/
version 12.1

mata: 

mata set matastrict on

void eps_ri_mv(string scalar dvlist, string scalar ivlist, string scalar touse) 
{
	/*object declarations*/
	real matrix X, Y, L, R, Lm, L2, R2, Lm2, Rxy

	real rowvector V, Bt, V2, Bt2
	
	/*begin processing*/
	Y = correlation(st_data(., tokens(dvlist), st_varindex(touse))) //obtain DV correlations
	
	X = correlation(st_data(., tokens(ivlist), st_varindex(touse))) //obtain IV correlations
	
	L = R = X //set-up for svd(); IV side
	
	L2 = R2 = Y //set-up for svd(); DV side
	
	V = J(1, cols(X), .) //placeholder for eigenvalues; IV side
	
	V2 = J(1, cols(Y), .) //placeholder for eigenvalues; DV side
	
	svd(X, L, V, R) //conduct singular value decomposition; IV side
	
	svd(Y, L2, V2, R2) //conduct singular value decomposition; DV side
	
	Lm = (L*diag(sqrt(V))*R) //process orthogonalized IVs
	
	Lm2 = (L2*diag(sqrt(V2))*R2) //process orthogonalized DVs
	
	Rxy = correlation((st_data(., tokens(ivlist), st_varindex(touse)), ///
	st_data(., tokens(dvlist), st_varindex(touse)))) //correlation between original IVs and DVs
	
	Rxy = Rxy[rows(X)+1..rows(Rxy), 1..cols(X)] //take only IV-DV correlations
	
	Bt2 = Rxy'*invsym(Lm2)	//obtain adjusted DV interrelations
	
	Bt = invsym(Lm)*Bt2 //obtain adjusted regression weights
	
	Bt = Bt:^2 //square values of regression weights
	
	Lm = Lm:^2 //square values of orthogonalized predictors

	st_matrix("r(domwgts)", mean((Lm*Bt)'))	//produce proportion of variance explained and put into Stata
	
	st_numscalar("r(fs)", sum(mean((Lm*Bt)')))	//sum relative weights to obtain R2
	
}

end

/* programming notes and history

- mvdom version 1.0 - date - Jan 15, 2014

Basic version

-----

- mvdom version 1.1 - date - March 11, 2015

//notable changes\\
- added version statement (12.1)
- added the Pxy metric 
- added the epsilon-based function
- changed canon to _canon; canon had odd behavior when called from mvdom
