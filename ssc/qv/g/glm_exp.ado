*! version 1.0.1  26Jan2014
program glm_exp				/* exponential */
	version 11
	args todo eta mu return

    if `todo' == -1 {                       /* Title */
        global SGLM_lt "exponential"
		global SGLM_lf "exp(u)"
		
		exit
        }
	if `todo' == 0 {			/* eta = g(mu) */
		gen double `eta' = exp(`mu')
		exit 
	}
	if `todo' == 1 {			/* mu = g^-1(eta) */
		gen double `mu' = ln(`eta')
		exit 
	}
	if `todo' == 2 {			/* (d mu)/(d eta) */
		gen double `return' = 1/(`eta')
		exit 
	}
	if `todo' == 3 {			/* (d^2 mu)(d eta^2) */
		gen double `return' = -1/(`eta'^2)
		exit
	}
	noi di as err "Unknown call to glim link function"
	exit 198
end
