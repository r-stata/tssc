*! wtp 1.0.2  01Oct2007
*! author arh

*  1.0.1:  krinsky function has been rewritten to use local matrices only 
*          in order to avoid name conflicts with existing external matrices 	

*  1.0.2:  reference in help file updated 

program wtp, rclass
	version 9.2

	syntax namelist(min=2) [, DElta FIeller KRinsky REPS(integer 1000) ///
	SEED(integer 5426) Level(integer `c(level)') EQuation(string)]

	tempname V b z

	matrix `V' = e(V)
	matrix `b' = e(b)

	scalar `z' = (`level' + (100-`level')/2) / 100

	gettoken num att : namelist

	local k: word count `att'

	/* If there are multiple-equations use first unless equation is specified */

	if "`equation'" == "" {
		matrix rownames `V' = :
		matrix colnames `V' = :
		matrix colnames `b' = :
	}
	if "`equation'" != "" {
		matrix `V' = `V'["`equation':","`equation':"]
		matrix rownames `V' = :
		matrix colnames `V' = :
		matrix `b' = `b'[1,"`equation':"]
		matrix colnames `b' = :
	}

	if "`krinsky'" == "" { 

		tempname wtp bnm bvm vvar vnum cov lim

		matrix `wtp' = J(3,`k',0)

		matrix `bnm' = `b'[1,"`num'"]

		scalar `z' = invnormal(`z')

		local i = 1
		foreach var in `att' {

			matrix `bvm' = `b'[1,"`var'"]

			matrix `wtp'[1,`i'] = -`bvm'[1,1]/`bnm'[1,1]

			matrix `vvar' = `V'["`var'","`var'"] 	/* Get variance for numerator coefficient */
			matrix `vnum' = `V'["`num'","`num'"] 	/* Get variance for denominator coefficient */
			matrix `cov'  = `V'["`num'","`var'"]	/* Get covariance between numerator and denominator */

			if "`fieller'" == "" { 

				matrix `lim'  = (-1/`bnm'[1,1])^2*`vvar'[1,1] + ///
							(`bvm'[1,1]/`bnm'[1,1]^2)^2*`vnum'[1,1] + ///
							2*(-1/`bnm'[1,1])*(`bvm'[1,1]/`bnm'[1,1]^2)*`cov'[1,1]			

				matrix `wtp'[2,`i'] = `wtp'[1,`i'] - `z'*sqrt(`lim'[1,1])			
				matrix `wtp'[3,`i'] = `wtp'[1,`i'] + `z'*sqrt(`lim'[1,1])		
			}

			if "`fieller'" != "" { 

				tempname den mid

				matrix `den'  = (-`bnm'[1,1] + `z'^2*`vnum'[1,1]/`bnm'[1,1])

				matrix `mid'  = (`bvm'[1,1] - `z'^2*`cov'[1,1]/`bnm'[1,1]) 			
				matrix `mid'  =  `mid'[1,1] / `den'[1,1]  

				matrix `lim'  = (`bvm'[1,1] - `z'^2*`cov'[1,1]/`bnm'[1,1])^2 - ///
							(1/`bnm'[1,1])^2 * (`bvm'[1,1]^2 - `z'^2*`vvar'[1,1]) * /// 
							(`bnm'[1,1]^2 - `z'^2*`vnum'[1,1])

				if `lim'[1,1] < 0 {
					di in red "Fieller confidence limits for variable `var' are imaginary" 
					matrix `wtp'[2,`i'] = .			
					matrix `wtp'[3,`i'] = .		
					local i = `i' + 1		
					exit
				} 

				matrix `lim' = sqrt(`lim'[1,1]) / `den'[1,1]			

				/* Calculate Fieller confidence interval - depends on sign of numerator */

				if `bnm'[1,1] < 0 {
					matrix `wtp'[2,`i'] = `mid'[1,1] - `lim'[1,1]			
					matrix `wtp'[3,`i'] = `mid'[1,1] + `lim'[1,1]		
				}
				else {
					matrix `wtp'[2,`i'] = `mid'[1,1] + `lim'[1,1]			
					matrix `wtp'[3,`i'] = `mid'[1,1] - `lim'[1,1]		
				}
			}

			local i = `i' + 1		
		}
	}

	if "`krinsky'" != "" {

		set seed `seed'

		tempname wtp

		local cl = round((1-`z')*`reps') + 1
		local cu = round(`z'*`reps')

		/* Extract relevant elements of b and V matrices */

		tempname bmat Vmat

		matrix `bmat' = J(1,(`k'+1),0)
		matrix `Vmat' = J((`k'+1),(`k'+1),0)

		local i = 1
		foreach var in `namelist' {
			matrix `bmat'[1,`i'] = `b'[1,"`var'"] 
			local i = `i' + 1 
		}

		local i = 1
		foreach cvar in `namelist' {
			local j = 1
			foreach rvar in `namelist' {
				matrix `Vmat'[`j',`i'] = `V'["`rvar'","`cvar'"] 
				local j = `j' + 1 
			}
			local i = `i' + 1
		}
		mata: krinsky()	
	}
 
	matrix colnames `wtp' = `att'
	matrix rownames `wtp' = wtp ll ul
	matrix list `wtp', noheader
	return matrix wtp = `wtp'

	if "`fieller'" != "" & "`krinsky'" == "" { 
		if (`bnm'[1,1]^2/`vnum'[1,1]) < (`z'^2) {
			di in red "The numerator coefficient is not significant -" 
			di in red "The confidence intervals are the union of (-inf,ul) and (ll,+inf)"
		} 
	}
end

version 9.2
mata: 
void krinsky()
{
	real scalar reps, cl, cu
	real matrix b, V, WTP, FI
	
	reps = strtoreal(st_local("reps")) 
	cl = strtoreal(st_local("cl")) 
	cu = strtoreal(st_local("cu"))
	
	b = st_matrix(st_local("bmat"))
	V = st_matrix(st_local("Vmat"))

	WTP = J(3,(cols(b)-1),0)

	WTP[1,.] = -1 :* (b[1,2..cols(b)] :/ b[1,1]) 

	FI = (b' :+ cholesky(V)*invnormal(uniform(cols(b),reps)))'
	FI = -1 :* (FI[.,2..cols(FI)] :/ FI[.,1])

	for (n=1; n<=cols(FI); n++) {
		_sort(FI,n)
		WTP[2,n] = FI[cl,n]
		WTP[3,n] = FI[cu,n]
	}
	st_matrix(st_local("wtp"),WTP)
}
end



