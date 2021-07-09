*! 1.0.0 MLB 13Okt2010
program define scenreg_lf
	if "$S_family" == "gaussian" {
		local sigma sigma
	}
	args lnf xb `sigma'
	
	mata comp_ll("$ML_y1", "`xb'", "`sigma'", "`lnf'", "$ML_samp" , ///
				 &mk_mu0_$S_link(), &mk_mu1_$S_link(), &mk_ll_$S_family())
end

mata:

void comp_ll(string  scalar                yname, 
             string  scalar                xbname, 
			 string  scalar                ln_sigma,
			 string  scalar                lnfname, 
			 string  scalar                mlsamp,
			 pointer(real matrix function) mk_mu0,
			 pointer(real matrix function) mk_mu1,
			 pointer(real matrix function) mk_ll) {
	real matrix lnf, mu0, mu1
	st_view(lnf, ., lnfname, mlsamp)
	mu0 = (*mk_mu0)(xbname, mlsamp)
	mu1 = (*mk_mu1)(xbname, mlsamp)
	lnf[.,.] = (*mk_ll)(yname, mlsamp, mu0, mu1, ln_sigma)
}


// link functions
real matrix mk_mu0_logit( string scalar xbname,
                         string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }

	real matrix xb, mu0					 
	st_view(xb,  ., xbname , mlsamp)
	mu0 = invlogit(-1:*(xb :+ (*e)))
	return(mu0)
}
real matrix mk_mu1_logit( string scalar xbname,
                         string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }

	real matrix xb, mu1					 
	st_view(xb,  ., xbname , mlsamp)
	mu1 = invlogit(xb :+ (*e))
	return(mu1)
}
real matrix mk_mu0_log( string scalar xbname,
                       string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }				   
	real matrix xb, mu0					 
	st_view(xb,  ., xbname , mlsamp)
	mu0 = 1 :- exp(xb :+ (*e))
	return(mu0)
}
real matrix mk_mu1_log( string scalar xbname,
                       string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }				   
	real matrix xb, mu1					 
	st_view(xb,  ., xbname , mlsamp)
	mu1 = exp(xb :+ (*e))
	return(mu1)
}

real matrix mk_mu0_identity( string scalar xbname,
                            string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }						
	real matrix xb, mu0					 
	st_view(xb,  ., xbname , mlsamp)
	mu0 = 1:-(xb :+ (*e))
	return(mu0)
}

real matrix mk_mu1_identity( string scalar xbname,
                            string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }						
	real matrix xb, mu1				 
	st_view(xb,  ., xbname , mlsamp)
	mu1 = xb :+ (*e)
	return(mu1)
}

real matrix mk_mu0_probit( string scalar xbname,
                          string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }						  
	real matrix xb, mu0					 
	st_view(xb,  ., xbname , mlsamp)
	mu0 = normal(-1:*(xb :+ (*e)))
	return(mu0)
}
real matrix mk_mu1_probit( string scalar xbname,
                          string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }						  
	real matrix xb, mu1					 
	st_view(xb,  ., xbname , mlsamp)
	mu1 = normal(xb :+ (*e))
	return(mu1)
}

real matrix mk_mu0_cloglog( string scalar xbname,
                           string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }
	real matrix xb, mu0					 
	st_view(xb,  ., xbname , mlsamp)
	mu0 = exp(-1:*exp(xb :+ (*e)))
	return(mu0)
}
real matrix mk_mu1_cloglog( string scalar xbname,
                           string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }
	real matrix xb, mu1					 
	st_view(xb,  ., xbname , mlsamp)
	mu1 = invcloglog(xb :+ (*e))
	return(mu1)
}

real matrix mk_mu0_loglog( string scalar xbname,
                          string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }
	real matrix xb, mu0					 
	st_view(xb,  ., xbname , mlsamp)
	mu0 = invcloglog(-1:*(xb :+ (*e)))
	return(mu0)
}
real matrix mk_mu1_loglog( string scalar xbname,
                          string scalar mlsamp) {
	pointer(real matrix) scalar e 
    if ( (e = findexternal("S_unobserved_variable")) == NULL) {
        _error(" S_unobserved_variable could not be found")
    }
	real matrix xb, mu1					 
	st_view(xb,  ., xbname , mlsamp)
	mu1 = exp(-1:*exp(-1:*(xb :+ (*e))))
	return(mu1)
}

// distributions
real matrix mk_ll_binomial ( string scalar yname,
                             string scalar mlsamp,
						     real   matrix mu0,
							 real   matrix mu1,
							 string scalar sigma) {
	real matrix y, lnf
	st_view(y,   ., yname  , mlsamp)
	lnf = y:*ln(mu1) :+ (1:-y):*ln(mu0)
	lnf = ln(mean(exp(lnf)')')
	return(lnf)
}
real matrix mk_ll_poisson ( string scalar yname,
                            string scalar mlsamp,
						    real   matrix mu0,
							real   matrix mu1,
							string scalar sigma) {
	real matrix y, lnf
	st_view(y,   ., yname  , mlsamp)
	lnf = y:*ln(mu1) :- mu1 :- lngamma(y :+ 1)
	lnf = ln(mean(exp(lnf)')')
	return(lnf)
}
real matrix mk_ll_gaussian ( string scalar yname,
                            string scalar mlsamp,
						    real   matrix mu0,
							real   matrix mu1,
							string scalar ln_sigmaname) {
	real matrix y, lnf, ln_sigma, sigma
	st_view(y,   ., yname  , mlsamp)
	st_view(ln_sigma, .,ln_sigmaname, mlsamp)
	lnf = lnnormalden(y, mu1,  exp(ln_sigma))
	lnf = ln(mean(exp(lnf)')')
	return(lnf)
}

end

exit
