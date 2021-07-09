program define choi_lr_hyperg_prob, rclass
version 14

* This program calculates the probability mass function defined by 
* equation 7 of Choi et al. 2015. 
* This is the probability of observing y1 successes
* given n1 and n2 patients on treatments 1 and 2, respectively, and
* is conditioned on the marginal number of successes yplus = y1 + y2.

* Input:
*	n1 = patients on treatment 1
*	n2 = patients on treatment 2
*	y1 = successes on treatment 1
*	y2 = successes on treatment 2
*	psi = log odds ratio for success in Rx 1 vs Rx 2

* Output: 
*	lnf = log(f), where f = pmf = equation 7 in Choi et al. 2015

* Equation 7 is of the form f = M/C where M and C can both overflow 
* for large tables. We manipulate this formula to avoid overflow errors. 
* Let k = log(M). Then log(f) = k - log(C) = -log(C*exp(-k)) where
* C*exp(-k) can be written in such a way to avoid overflow errors 
* when n1 and/or n2 are large. For details see CalculatingEq7.pdf in
* \\biostat1158a\Users\dupontwd.VANDERBILT\Documents\Dropbox\OFFICE_desktop
* \ChoiFisherTest\Stata Program\ado\withZeros

    args n1 n2 y1 y2 psi
    local yplus = `y1' + `y2'
    local start = max(0,`yplus' - `n2')
    local end = min(`n1', `yplus')
    
* Calculate k = log(M), where f =M/C in equation 7

    local k = lnfactorial(`n1') - lnfactorial(`y1') - lnfactorial(`n1'-`y1') ///
            + lnfactorial(`n2') - lnfactorial(`yplus'-`y1')                  ///
            - lnfactorial(`n2' - `yplus' +`y1') + `psi'*`y1'
            
    local emkc = 0
    forvalues u = `start'/`end' {
	local emkc = `emkc' + exp(lnfactorial(`n1') -lnfactorial(`u')       ///
	           -lnfactorial(`n1'-`u') + lnfactorial(`n2')               ///
	           -lnfactorial(`yplus'-`u')-lnfactorial(`n2'-`yplus'+`u')  ///
	           + `psi'*`u' - `k')
	}
* emkc = C*exp(-k) where C is defined in equation 7   

    local lnf = -log(`emkc') // = 0 -log(C*exp(-k)) = log(f) 
    
    return scalar lnf = `lnf'
                        
end // **************************************************************
