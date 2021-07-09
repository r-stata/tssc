*! 0.1 HS, Dec 21, 2017
* Predicted probability of treatment based on last fitted WTD

pr define wtdtttpredprob, rclass
version 14.0

syntax newvarlist(max=1) [if] [in], ///
                distrx(varname)
	qui {
		tokenize `varlist'
		local prttt `1'

		local disttype = r(disttype)

		if "`disttype'" == "exp" {
			tempname lnbeta
			predict `lnbeta', eq(lnbeta)
			
			gen `prttt' = exp(- exp(`lnbeta') * `distrx')
			}
		
		if "`disttype'" == "lnorm" {
			tempname mu lnsigma
			predict `mu', eq(mu)
			predict `lnsigma', eq(lnsigma)
			
			gen `prttt' = normal(- (log(`distrx') - `mu') / exp(`lnsigma'))
			}
		
		
		if "`disttype'" == "wei" {
			tempname lnbeta lnalpha
			predict `lnbeta', eq(lnbeta)
			predict `lnalpha', eq(lnalpha)
			
			gen `prttt' = exp(- ((`distrx' * exp(`lnbeta') )^exp(`lnalpha')))
			}
		}	
end

