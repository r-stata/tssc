*! version 1.0.0 07jan2014

vers 12.1
m :

// mata clear

void mPwmc(real matrix stats, 
		string rowvector prc, 
		real scalar cilev,
		real colvector lvls,
		| string scalar over)
{	
	real colvector n, mu, sd, df
	real scalar k, kstar, alpha, col, c
	real rowvector diff, Var, nuhat, pvals
	real matrix A, CI
	
	string colvector olvls
	string matrix vsnams, prcnams, cinams
	string scalar onam

	n = stats[., 1]
	mu = stats[., 2]
	sd = stats[., 3]	
	
	k = rows(mu)
	kstar = k * (k - 1)/2
	df = (n :- 1)
	alpha = cilev/100
	
	diff = J(1, kstar, .)
	nuhat = J(1, kstar, .)
	Var = J(1, kstar, .)
	A = J(kstar, cols(prc), .)
	CI = J((cols(prc)*kstar), 2, .)
	pvals = J(kstar, cols(prc), .)
	
	vsnams = J(kstar, 2, "")
	prcnams = J(cols(prc), 1, ""), prc'
	olvls = strofreal(lvls)
	if (over != "") onam = "." + over
	
	// Dunnett's C
	if (anyof(prc, "c")) {
		sr = invtukeyprob(k, df, alpha) :* (sd :^ 2 :/ n)
	}
	
	// calculate diff, Var, nuhat and A
	c = 0
	for (j = 1; j <= kstar; ++j) {
		for (i = (j + 1); i <= k; ++i) {
			++c
			
			diff[1, c] = mu[i, 1] - mu[j, 1]
			
			Var[1, c] = (sd[i, 1]^2/n[i, 1]) + (sd[j, 1]^2/n[j, 1])
			
			nuhat[1, c] = Var[1, c]^2 / ///
			((sd[i, 1]^4/(n[i, 1]^2 * df[i, 1])) ///
			+ (sd[j, 1]^4/(n[j, 1]^2 * df[j, 1])))
			
			vsnams[c, 2] = olvls[i, 1] + "vs" + olvls[j, 1] + onam
			
			// Dunnett's C
			if (anyof(prc, "c")) {
				col = select(J(1, 1, (1..cols(prc))), (prc :== "c"))
				A[c, col] = ((sr[i, 1] + sr[j, 1])/Var[1, c]) / sqrt(2)
			}
		}
	}	
	
	// Games and Howell
	if (anyof(prc, "gh")) {
		col = select(J(1, 1, (1..cols(prc))), (prc :== "gh"))
		A[., col] = (invtukeyprob(k, nuhat, alpha) :/ sqrt(2))'
		pvals[., col] = ///
		(1 :- tukeyprob(k, nuhat, abs(diff :/ sqrt(Var)) * sqrt(2)))'
	}
	
	// Tamhane's T2
	if (anyof(prc, "t2")) {
		col = select(J(1, 1, (1..cols(prc))), (prc :== "t2"))
		A[., col] = (invttail(nuhat, (1 - alpha^(1/kstar)) / 2))'
		pvals[., col] = ///
		(1 :- (1 :- 2*ttail(nuhat, abs(diff :/ sqrt(Var)))) :^ kstar)'
	}

	// calculate CI
	cinams = vec(J(kstar, 1, prc)), J(cols(prc), 1, vsnams[., 2])
	CI = vec(J(1, cols(prc), diff') :- A :* sqrt(Var')), ///
	vec(J(1, cols(prc), diff') :+ A :* sqrt(Var'))

	// return in r()
	st_rclear()
	
	st_numscalar("r(k)", k)
	st_numscalar("r(ks)", kstar)
	st_numscalar("r(level)", cilev)
	
	st_global("r(procedure)", st_local("procedure"))
	st_global("r(over)", over)
	st_global("r(depvar)", st_local("varlist"))
	st_global("r(cmd)", "pwmc")
	
	st_matrix("r(A)", A)
	st_matrixcolstripe("r(A)", prcnams)
	st_matrixrowstripe("r(A)", vsnams)
	
	st_matrix("r(p_adj)", pvals)
	st_matrixcolstripe("r(p_adj)", prcnams)
	st_matrixrowstripe("r(p_adj)", vsnams)
	
	st_matrix("r(t)", diff :/ sqrt(Var))
	st_matrixcolstripe("r(t)", vsnams)
	
	st_matrix("r(ci)", CI)
	st_matrixcolstripe("r(ci)", ((""\ ""), ("ll"\ "ul")))
	st_matrixrowstripe("r(ci)", cinams)
	
	st_matrix("r(nuhat)", nuhat)
	st_matrixcolstripe("r(nuhat)", vsnams)
	
	st_matrix("r(Var)", Var)
	st_matrixcolstripe("r(Var)", vsnams)
	
	st_matrix("r(diff)", diff)
	st_matrixcolstripe("r(diff)", vsnams)
	
	st_matrix("r(levels_over)", lvls, "hidden")
	
	// return old results
	for (i = 1; i <= cols(A); ++i) {
		onam = "r(A_" + prc[1, i] + ")"
		st_matrix(onam, A[., i]', "hidden")
		st_matrixcolstripe(onam, vsnams)
	}
	
	for (i = 1; i <= rows(CI); i = i + kstar) {
		onam = "r(ll_" + cinams[i, 1] + ")"		
		st_matrix(onam, CI[(i::i + kstar - 1), 1]', "hidden")
		st_matrixcolstripe(onam, vsnams)
		
		onam = "r(ul_" + cinams[i, 1] + ")"		
		st_matrix(onam, CI[(i::i + kstar - 1), 2]', "hidden")
		st_matrixcolstripe(onam, vsnams)
	}
}

// mata mosave mPwmc() ,dir(PERSONAL) replace

end
