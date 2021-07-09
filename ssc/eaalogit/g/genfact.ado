*! genfact 1.0.0 15Dec2010
*! author arh

program genfact, rclass
	version 10.1
	syntax, LEVels(name)

	qui describe
	if (r(k) != 0) | (r(N) != 0) {
		di in r "You need to start with an empty dataset"
		exit 498
	}

	confirm matrix `levels'
	if (rowsof(`levels') > 1) {
		di in r "`levels' is not a row matrix"
		exit 498
	} 

	local k = colsof(`levels')
	local nobs = 1
	forvalues i = 1(1)`k' {
		if (`levels'[1,`i'] <= 1) | (round(`levels'[1,`i']) != `levels'[1,`i']) {
			di in r "Some elements in `levels' are not integers greater than one"
			exit 498			
		}
		local nobs = `nobs'*`levels'[1,`i']
	}

	qui set obs `nobs'
	forvalues i = 1(1)`k' {
		qui gen double x`i' = .
	}

	mata: st_view(gfact_design=.,.,.)
	mata: gfact_nobs = strtoreal(st_local("nobs"))
	mata: genfact("`levels'")
end

version 10.1
mata: 
void genfact(string scalar lev_s)
{
	external gfact_design
	external gfact_nobs

	levels = st_matrix(lev_s)
	nobs = gfact_nobs
	nrepl = nobs
	for (k=1; k<=cols(gfact_design); k++) {
		nrepl = nrepl :/ levels[k]
		nblock = nobs :/ (nrepl*levels[k])
		gfact_design[.,k] = colshape(J(nblock,nrepl,(1::levels[k])),1)
	}
}
end
