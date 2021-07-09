*! lmose 1.0.0 NJC 13 April 2010 
* lmoments 4.0.1 NJC 16 October 2006 
* lmoments 1.0.0 NJC 17 September 1997
* lshape 2.0.1 PR 6 October 1995
program lmose, rclass byable(recall)   
        version 10 
        syntax varname(numeric) [if] [in] [, Format(passthru) * ]

	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000
 	if r(N) < 8 { 
		di as txt "sample size too small for standard errors"
		exit 0 
	} 
			
	tempname V SE 

	mata: _lmose("`varlist'", "`touse'", "`V'", "`SE'")

	if "`format'" == "" local format "format(%9.3f)" 
	mat rownames `V' = l_1 l_2 l_3 l_4
	mat colnames `V' = l_1 l_2 l_3 l_4
	mat rownames `SE' = l_1 l_2 l_3 l_4 t t_3 t_4 
	mat colnames `SE' = "  "

	di as txt _n "Variance matrix of sample L-moments" _c 
	mat li `V', noheader `format' `options' 
	di as txt _n "Standard errors of sample L-moments and ratios" _c 
	mat li `SE', noheader `format' `options' 
		
	ret matrix V = `V' 
	ret matrix SE = `SE'
end

mata:

void _lmose(string scalar varname, string scalar usename, 
string scalar Vname, string scalar SEname)
{
	real colvector x, i, b, work, IK, IL, JL, JK, prod, xixj, range, L, SE  
	real scalar n, d, j, k, l, ikl, nn 
	real matrix kl, V, C  

	x = st_data(., varname, usename)
	x = select(x, x :< .) 
	_sort(x, 1)
	n = length(x) 
	i = (1..n)'
	b = J(4,1,0) 
 	b[1] = mean(x) 
	d = n
	work = x 

	for (j = 1; j <= 3; j++) {
		d = d * (n - j)
		work = work :* (i :- j)  
		b[j+1] = sum(work) / d
	}

	kl = J(0, 2, .)
	for (k = 0; k <= 3; k++) {
		for (l = k; l <= 3; l++) { 
			kl = kl \ (k,l)
		}
	}

	V = J(4,4,0)

	for (ikl = 1; ikl <= rows(kl); ikl++) {
		k = kl[ikl, 1]
		l = kl[ikl, 2]

		JK = JL = IL = IK = J(n, 1, 1)
		for (j = 1; j <= k; j++) {
			IK = IK :* (i :- j)
			JK = JK :* (i :- (l+j+1))
		}

		for (j = 1; j <= l; j++) {
			IL = IL :* (i :- j)
			JL = JL :* (i :- (k+j+1))
		}

		nn = exp(lnfactorial(n) - lnfactorial(n-k-l-2))

		// want to work with pairs of order statistics x_(i) <= x_(j), 
		// but we can avoid looping over both i and j 

		prod = J(n, 1, 0)
		for (j = 1; j < n /* NB */; j++) {
			range = (j+1) \ n  
			xixj = (x[j] / nn) * x[|range|]
			prod[|range|] = prod[|range|] + 
			(IK[j] * JL[|range|] + IL[j] * JK[|range|]) :* xixj
		}
		V[k+1, l+1] = V[l+1, k+1] = sum(prod)
	}

	V = b * b' - V 
	C = (1, 0, 0, 0\-1, 2, 0, 0\1, -6, 6, 0\-1, 12, -30, 20) 
	L = C * b
 	V = C * V * C'

	SE = J(7,1,0) 
	SE[|1\4|] = sqrt(diagonal(V[|(1,1)\(4,4)|])) 
	SE[5] = V[2,2]/(L[2] * L[2]) + V[1,1]/(L[1] * L[1]) - 2 * V[1,2]/(L[1] * L[2])
	SE[5] = sqrt(SE[5] * (L[2]/L[1])^2)
	SE[6] = V[3,3]/(L[3] * L[3]) + V[2,2]/(L[2] * L[2]) - 2 * V[2,3]/(L[2] * L[3])
	SE[6] = sqrt(SE[6] * (L[3]/L[2])^2) 
	SE[7] = V[4,4]/(L[4] * L[4]) + V[2,2]/(L[2] * L[2]) - 2 * V[2,4]/(L[2] * L[4])
	SE[7] = sqrt(SE[7] * (L[4]/L[2])^2) 

	st_matrix(Vname, V)
	st_matrix(SEname, SE)
}

end

