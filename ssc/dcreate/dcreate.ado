*! dcreate 1.4.1  18Aug2017
*! author arh

*  1.3.0:	a minor bug has been fixed
*  1.4.0:	Bayesian designs supported
*  1.4.1:	a bug preventing the use of evaldes with Bayesian designs has been fixed

program define dcreate, rclass
	version 11.1
	syntax varlist(fv), NALT(integer) NSET(integer) Bmat(name) [Vmat(name) ///
	ASC(numlist) FIXedalt(name) MAXiter(integer 10) CRIterion(real 0.00001) ///
	NREP(integer 50) BURN(integer 15) SEED(integer 435)]	
	
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

	quietly { 

	** Add fixed alternative to nalt if specified**
	if ("`fixedalt'" != "") {
		local nalt = `nalt' + 1
	}
	
	count
	local ntot = r(N)
	local nobs = `nset'*`nalt'

	desc
	local nvars = r(k)
	
	tempname d dif

	set seed `seed'
	
	** Create matrix containing alternative-specific constants **
	mata: dcreate_HASASC = 0
	if ("`asc'" != "") {
		mata: dcreate_HASASC = 1
		local k = 1
		foreach alt of numlist `asc' {
			if (`alt' < 1) | (round(`alt') != `alt') | (`alt' > `nalt') {
				di in r "The elements in the list of alternative-specific constants must be integers greater than zero"
				di in r "and not higher than the number of alternatives"
				exit 498			
			}
			if (`k' >= `nalt') {
				di in r "At most nalt-1 alternative-specific constants can be specified"
				exit 498			
			}						
			if `k'==1 {
				mata: dcreate_ASCMAT = J(strtoreal(st_local("nalt")),1,0)
				mata: dcreate_ASCMAT[strtoreal(st_local("alt")),1] = 1
				mata: dcreate_ASCMAT = J(strtoreal(st_local("nset")),1,dcreate_ASCMAT)
			}
			else {
				mata: dcreate_TEMPMAT = J(strtoreal(st_local("nalt")),1,0)
				mata: dcreate_TEMPMAT[strtoreal(st_local("alt")),1] = 1
				mata: dcreate_TEMPMAT = J(strtoreal(st_local("nset")),1,dcreate_TEMPMAT)
				mata: dcreate_ASCMAT = dcreate_ASCMAT,dcreate_TEMPMAT
			}
			local k = `k' + 1
		}
	}

	mata: dcreate_CANDMAT = select(st_data(.,st_local("explist")),st_matrix(st_local("noomit")))
	mata: dcreate_ORIGMAT = st_data(.,.)
	
	if ("`fixedalt'" != "") {
		local nobsnofix = `nobs'-`nset'
		mata: dcreate_MAXMAT = J(strtoreal(st_local("nobsnofix")),1,0)
	}	
	else mata: dcreate_MAXMAT = J(strtoreal(st_local("nobs")),1,0) 
	
	** Check that the number of specified coefficients is equal to the number of effects in the design **
	if ("`asc'" != "") mata: st_local("colscandmat",strofreal(cols((dcreate_CANDMAT[1,.],dcreate_ASCMAT[1,.]))))
	else mata: st_local("colscandmat",strofreal(cols(dcreate_CANDMAT)))
	local ncoef = colsof(`bmat')	
	if (`ncoef' != `colscandmat') {
		di in r "There are `colscandmat' effects in the design and `ncoef' coefficients in `bmat'"
		exit 498			
	}

	** Check that there is a sufficent number of choice sets in the design **
	local minset = `ncoef'/(`nalt'-1)
	if (`nset' < `minset') {
		di in r "There are too few choice sets in the design relative to the number of effects to be estimated"
		exit 498			
	}							
	
	** Create DEVMAT matrix used to calculate the D-efficiency **
	mata: dcreate_DEVMAT = J(strtoreal(st_local("nobs")),strtoreal(st_local("ncoef")),0)
	
	keep in 1

	** Check that fixedalt has the correct number of elements if specified **
	mata: dcreate_HASFIX = 0
	if ("`fixedalt'" != "") {
		mata: st_local("colsorigmat",strofreal(cols(dcreate_ORIGMAT)))
		local colsfix = colsof(`fixedalt')
		if (`colsfix' != `colsorigmat') {
			mata: st_local("nobs_restore", strofreal(rows(dcreate_ORIGMAT)))
			set obs `nobs_restore'
			mata: st_view(dcreate_RESTORE=.,.,.)
			mata: dcreate_RESTORE[.,.] = dcreate_ORIGMAT		
			di in r "There are `colsorigmat' attributes in the design and `colsfix' attribute levels in `fixedalt'"
			exit 498			
		}
		mata: st_view(dcreate_FIX=.,.,.) 
		mata: dcreate_FIX[.,.] = st_matrix("`fixedalt'")
		mata: dcreate_FIXORIG = dcreate_FIX
		mata: dcreate_FIX = select(st_data(.,st_local("explist")),st_matrix(st_local("noomit")))
		mata: dcreate_HASFIX = 1
	}

	set obs `nobs'

	** Deal with inputs relating to Bayesian designs **
	if ("`vmat'" != "") {
		mata: dcreate_HASV = 1
		mata: dcreate_B = st_matrix(st_local("bmat"))'
		mata: dcreate_nrep = strtoreal(st_local("nrep"))
		mata: dcreate_B = dcreate_B :+ cholesky(st_matrix(st_local("vmat")))*invnormal(halton(dcreate_nrep,rows(dcreate_B),(1+strtoreal(st_local("burn"))))')
	}	
	else {
		mata: dcreate_HASV = 0	
		mata: dcreate_B = st_matrix(st_local("bmat")) 
	}
	
	** Evaluate efficiency of random starting design **
	mata: dcreate_DESMAT = startdes(dcreate_CANDMAT)
	scalar `d' = r(d_eff)
	if (r(d_eff) == 0) | (r(d_eff) >= .) {
		mata: st_local("nobs_restore", strofreal(rows(dcreate_ORIGMAT)))
		set obs `nobs_restore'
		mata: st_view(dcreate_RESTORE=.,.,.)
		mata: dcreate_RESTORE[.,.] = dcreate_ORIGMAT
		di in r "The random starting design does not identify all of the effects to be estimated."
		di in r "Possible options include:"
		di in r "- Simplify the model"
		di in r "- Increase the number of choice sets in the design"
		di in r "- Run dcreate again specifying a different random number seed"		
		exit 498			
	}							
	n di
	n di in g "The D-efficiency of the random starting design is: "   /*
			*/ _col(50) in y %13.10f r(d_eff)

	** Modified Fedorov algorithm **
	local k = 1
	while `k' <= `maxiter' {

		mata: dcreate_DESMAT = fedorov(dcreate_CANDMAT, dcreate_DESMAT)
		scalar `dif' = r(d_eff) - `d' 
		scalar `d' = r(d_eff)

		n di
		n di in g "D-efficiency after iteration " `k' ":"  /*
			*/ _col(35) in y %13.10f r(d_eff)
		n di in g "Difference:"  /*
			*/ _col(35) in y %13.10f `dif'

		if `dif' < `criterion' {
			n di
			n di in g "The algorithm has converged."
			local k = `maxiter'
		}

		local k = `k' + 1
		if (`k' > `maxiter') & (`dif' >= `criterion') {
			n di
			n di in r "The algorithm did not converge. Try increasing the maximum number of iterations."
		}
	}

	mata: st_view(dcreate_FINDESMAT=.,.,.)

	if ("`fixedalt'" != "") {
		mata: dcreate_nalt = strtoreal(st_local("nalt"))
		mata: dcreate_nset = strtoreal(st_local("nset"))	
		mata: dcreate_DESMAT = dcreate_ORIGMAT[dcreate_MAXMAT,.]
		mata: dcreate_FINDESMAT[.,.] = colshape((colshape(dcreate_DESMAT,cols(dcreate_DESMAT)*(dcreate_nalt-1)),J(dcreate_nset,1,dcreate_FIXORIG)),cols(dcreate_DESMAT))
	}
	else mata: dcreate_FINDESMAT[.,.] = dcreate_ORIGMAT[dcreate_MAXMAT,.]
	
	** Generate variable identifying groups/ choice sets **
	gen choice_set = 0
	local k = 1
	forvalues j = 1(`nalt')`nobs' {
		forvalues i = 1(1)`nalt' {
			local num = `j' + `i' - 1
			qui replace choice_set   = cond(_n==`num',`k',choice_set)
		}	
		local k = `k' + 1
	 }

	** Generate variable identifying choices within groups **
	sort choice_set, stable
	by choice_set: gen alt = _n

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
	if ("`asc'" != "") {
		foreach alt of numlist `asc' {
			tempvar asc`alt' 
			gen `asc`alt'' = alt==`alt'	
			local estvars `estvars' `asc`alt''
		}
	}
	
	tempvar y
	gen `y' = 0
	replace `y' = 1 if alt==1
		
	if ("`vmat'" != "") {	
		tempname deff
		matrix `deff' = 0
		
		* Note that dcreate calculates the simulated D-error to be consistent with Sandor and Wedel
		* The simulated D-error is then inverted to calculate the simulated D-efficiency
		forvalues r = 1(1)`nrep' {
			tempname breps
			mata: st_matrix("`breps'",dcreate_B[.,`r'])		
			clogit `y' `estvars', group(choice_set) iter(0) from(`breps', copy)
			matrix `deff' = `deff' + det(e(V))^(1/e(df_m))
		}
		matrix `deff' = 1/(`deff'[1,1]/`nrep')
		
		if (`d'==0 | `d'>=.) | (float(`deff'[1,1])!=float(`d')) {	
			n di
			di in r "The generated design does not identify all of the effects to be estimated."
			di in r "Possible options include:"
			di in r "- Simplify the model"
			di in r "- Increase the number of choice sets in the design"
			di in r "- Run dcreate again specifying a different random number seed"		
			exit 498		
		}
	}
	else {
		clogit `y' `estvars', group(choice_set) iter(0) from(`bmat', copy)
		tempname deff
		matrix `deff' = det(e(V))^(-1/e(df_m))
	
		if (`d'==0 | `d'>=.) | (float(`deff'[1,1])!=float(`d')) {	
			n di
			di in r "The generated design does not identify all of the effects to be estimated."
			di in r "Possible options include:"
			di in r "- Simplify the model"
			di in r "- Increase the number of choice sets in the design"
			di in r "- Run dcreate again specifying a different random number seed"		
			exit 498		
		}
	}
	
	return scalar d_eff = `d'
	
	} // end quietly
end

version 9.2
mata: 
function startdes(matrix CANDMAT)
{
	external dcreate_DEVMAT
	external dcreate_HASASC
	external dcreate_HASFIX	
	external dcreate_HASV
	external dcreate_B
	if (dcreate_HASASC == 1) external dcreate_ASCMAT
	if (dcreate_HASFIX == 1) external dcreate_FIX
	
	nalt = strtoreal(st_local("nalt"))
	nset = strtoreal(st_local("nset"))	
	ntot = strtoreal(st_local("ntot"))
	nobs = strtoreal(st_local("nobs"))
	nvars = strtoreal(st_local("nvars"))
	ncoef = strtoreal(st_local("ncoef"))
	
	if (dcreate_HASFIX == 1) nobs = nobs-nset
		
	RND = floor(rows(CANDMAT) :* uniform(nobs,1)) :+ 1

	DESMAT = CANDMAT[RND,.]

	if (dcreate_HASASC == 1) {
		if (dcreate_HASFIX == 1) {
			EVALMAT = colshape((colshape(DESMAT,cols(DESMAT)*(nalt-1)),J(nset,1,dcreate_FIX)),cols(DESMAT))
			d = deffi((EVALMAT,dcreate_ASCMAT), dcreate_DEVMAT, dcreate_B, nalt, ncoef)
		}
		else d = deffi((DESMAT,dcreate_ASCMAT), dcreate_DEVMAT, dcreate_B, nalt, ncoef)
	}
	else {
		if (dcreate_HASFIX == 1) {
			TEMPMAT = colshape((colshape(DESMAT,cols(DESMAT)*(nalt-1)),J(nset,1,dcreate_FIX)),cols(DESMAT))
			d = deffi(TEMPMAT, dcreate_DEVMAT, dcreate_B, nalt, ncoef)
		}
		else d = deffi(DESMAT, dcreate_DEVMAT, dcreate_B, nalt, ncoef)
	}
	st_numscalar("r(d_eff)", d)
	
	return(DESMAT)
}
end

version 9.2
mata: 
function fedorov(matrix CANDMAT, matrix DESMAT)
{
	external dcreate_MAXMAT
	external dcreate_DEVMAT	
	external dcreate_HASASC
	external dcreate_HASFIX	
	external dcreate_HASV
	external dcreate_B	
	if (dcreate_HASASC == 1) external dcreate_ASCMAT
	if (dcreate_HASFIX == 1) external dcreate_FIX
	
	nalt = strtoreal(st_local("nalt"))
	nset = strtoreal(st_local("nset"))	
	ntot = strtoreal(st_local("ntot"))
	nobs = strtoreal(st_local("nobs"))
	dmax = st_numscalar("r(d_eff)") 
	nvars = strtoreal(st_local("nvars"))
	ncoef = strtoreal(st_local("ncoef"))

	if (dcreate_HASFIX == 1) nobs = nobs-nset

	TEMPMAT = DESMAT

	for (j=1; j<=nobs; j++) {
		maxrow = 1		
		for (i=1; i<=ntot; i++) {
			TEMPMAT[j,.] = CANDMAT[i,.]

			if (dcreate_HASASC == 1) {
				if (dcreate_HASFIX == 1) {
					EVALMAT = colshape((colshape(TEMPMAT,cols(TEMPMAT)*(nalt-1)),J(nset,1,dcreate_FIX)),cols(TEMPMAT))
					d = deffi((EVALMAT,dcreate_ASCMAT), dcreate_DEVMAT, dcreate_B, nalt, ncoef)
				}
				else d = deffi((TEMPMAT,dcreate_ASCMAT), dcreate_DEVMAT, dcreate_B, nalt, ncoef)
			}
			else {
				if (dcreate_HASFIX == 1) {
					EVALMAT = colshape((colshape(TEMPMAT,cols(TEMPMAT)*(nalt-1)),J(nset,1,dcreate_FIX)),cols(TEMPMAT))
					d = deffi(EVALMAT, dcreate_DEVMAT, dcreate_B, nalt, ncoef)
				}
				else d = deffi(TEMPMAT, dcreate_DEVMAT, dcreate_B, nalt, ncoef)
			}

			if ((d >= dmax) & (d < .)) {
				maxrow = i
				dmax = d
			}		
		}
		DESMAT[j,.] = CANDMAT[maxrow,.]
		TEMPMAT = DESMAT
		dcreate_MAXMAT[j,.] = maxrow
	}

	if (dcreate_HASASC == 1) {
		if (dcreate_HASFIX == 1) {
			EVALMAT = colshape((colshape(DESMAT,cols(DESMAT)*(nalt-1)),J(nset,1,dcreate_FIX)),cols(DESMAT))
			d = deffi((EVALMAT,dcreate_ASCMAT), dcreate_DEVMAT, dcreate_B, nalt, ncoef)
		}
		else d = deffi((DESMAT,dcreate_ASCMAT), dcreate_DEVMAT, dcreate_B, nalt, ncoef)
	}
	else {
		if (dcreate_HASFIX == 1) {
			EVALMAT = colshape((colshape(DESMAT,cols(DESMAT)*(nalt-1)),J(nset,1,dcreate_FIX)),cols(DESMAT))
			d = deffi(EVALMAT, dcreate_DEVMAT, dcreate_B, nalt, ncoef)
		}
		else d = deffi(DESMAT, dcreate_DEVMAT, dcreate_B, nalt, ncoef)
	}
	st_numscalar("r(d_eff)", d)

	return(DESMAT)
}
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

