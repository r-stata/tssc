*! evaldes 1.2.1  18Aug2017
*! author arh

program define evaldes, rclass sortpreserve
	version 11.1
	syntax varlist(fv), Bmat(name) [Vmat(name) NREP(integer 50) BURN(integer 15)]

	quietly { 

	sort choice_set alt
	
	fvexpand `varlist'
	local explist `r(varlist)'

	tempname noomit
	local kexp : word count `explist'
	matrix `noomit' = J(1,`kexp',1)

	local k = 1
	foreach var of local explist {
		_ms_parse_parts `var'
		matrix `noomit'[1,`k'] = `r(omit)'!=1
		local k = `k' + 1
	}	
	
	local nobs = _N
	local ncoef = colsof(`bmat')
	sum alt
	local nalt = r(max)
	local nset = `nobs' / `nalt'
		
	mata: dcreate_DESMAT = select(st_data(.,st_local("explist")),st_matrix(st_local("noomit")))
	mata: dcreate_DEVMAT = J(strtoreal(st_local("nobs")),strtoreal(st_local("ncoef")),0)
	mata: dcreate_nalt = strtoreal(st_local("nalt"))
	mata: dcreate_nobs = strtoreal(st_local("nobs"))
	mata: dcreate_ncoef = strtoreal(st_local("ncoef"))

	if ("`vmat'" != "") {
		mata: dcreate_HASV = 1
		mata: dcreate_B = st_matrix(st_local("bmat"))'
		mata: dcreate_nrep = strtoreal(st_local("nrep"))
		mata: dcreate_burn = strtoreal(st_local("burn"))
		mata: dcreate_B = dcreate_B :+ cholesky(st_matrix(st_local("vmat")))*invnormal(halton(dcreate_nrep,rows(dcreate_B),(1+dcreate_burn))')		
	}	
	else {
		mata: dcreate_HASV = 0	
		mata: dcreate_B = st_matrix(st_local("bmat"))
	}
	
	mata: st_local("colsdesmat",strofreal(cols(dcreate_DESMAT)))
	if (`ncoef' != `colsdesmat') {
		di in r "There are `colsdesmat' effects in the design and `ncoef' coefficients in `bmat'"
		exit 498			
	}

	local minset = `ncoef'/(`nalt'-1)
	if (`nset' < `minset') {
		di in r "The design does not identify all of the effects to be estimated"
		exit 498			
	}							
	
	mata: d = deffi(dcreate_DESMAT, dcreate_DEVMAT, dcreate_B, dcreate_nalt, dcreate_ncoef)	
	mata: st_numscalar("r(d_eff)", d)

	if (r(d_eff) == 0) | (r(d_eff) >= .) {
		di in r "The design does not identify all of the effects to be estimated"
		exit 498			
	}
	
	tempname d
	scalar `d' = r(d_eff)

	** Compare with clogit results - will be identical if design is identified **	
	local i = 1
	local estvars
	foreach var of local explist {
		tempvar x`i'
		if `noomit'[1,`i']==1 {
			gen `x`i'' = `var' if `noomit'[1,`i']==1
			local estvars `estvars' `x`i''
		}	 
		local i = `i'+1
	}

	tempvar y
	gen `y' = 0
	replace `y' = 1 if alt==1

	if ("`vmat'" != "") {
		tempname deff
		matrix `deff' = 0

		forvalues r = 1(1)`nrep' {
			tempname breps
			mata: st_matrix("`breps'",dcreate_B[.,`r'])		
			clogit `y' `estvars', group(choice_set) iter(0) from(`breps', copy)
			matrix `deff' = `deff' + det(e(V))^(1/e(df_m))
		}
		matrix `deff' = 1/(`deff'[1,1]/`nrep')
		
		if float(`deff'[1,1])==float(`d') {	
			n di
			n di in g "The D-efficiency of the design is: "   /*
				*/ _col(40) in y %13.10f `d'
		}
		else {
			di in r "The design does not identify all of the effects to be estimated"
			exit 498				
		}
	}
	else {
		clogit `y' `estvars', group(choice_set) iter(0) from(`bmat', copy)
		tempname deff
		matrix `deff' = det(e(V))^(-1/e(df_m))
	
		if float(`deff'[1,1])==float(`d') {	
			n di
			n di in g "The D-efficiency of the design is: "   /*
				*/ _col(40) in y %13.10f `d'
		}
		else {
			di in r "The design does not identify all of the effects to be estimated"
			exit 498				
		}
	}
	
	return scalar d_eff = `d'	
	
	} // end quietly
end	

version 9.2
mata: 
function deffi(matrix XMAT, matrix DEVMAT, matrix B, real scalar nalt, real scalar nvars)
{
	external dcreate_HASV

	if (dcreate_HASV == 1) {
		external dcreate_nrep

		EV = exp(XMAT*B)
		V = 0

		for (r=1; r<=dcreate_nrep; r++) {
			P = colshape(EV[.,r],nalt)'
			P = P :/ colsum(P,1)
			P = colshape(P',1)
			for (k=1; k<=nvars; k++) {
				XP = XMAT[.,k] :* P
				XP = colshape(XP,nalt)'
				XP = colshape(XMAT[.,k],nalt)' :- colsum(XP,1)
				XP = colshape(XP',1)
				DEVMAT[.,k] = XP
			}
			V = V :+ det(cross(DEVMAT, P, DEVMAT))^(-1/nvars)	
		}
		return(1/(V:/dcreate_nrep))
	}
	else {
		EV = exp(XMAT*B')
		P = colshape(EV,nalt)'
		P = P :/ colsum(P,1)
		P = colshape(P',1)
		for (k=1; k<=nvars; k++) {
			XP = XMAT[.,k] :* P
			XP = colshape(XP,nalt)'
			XP = colshape(XMAT[.,k],nalt)' :- colsum(XP,1)
			XP = colshape(XP',1)
			DEVMAT[.,k] = XP
		}
		V = cross(DEVMAT, P, DEVMAT)
		return(det(V)^(1/nvars))
	}
}
end

