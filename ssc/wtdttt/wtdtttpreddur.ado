*! 0.1 HS, Feb 22, 2017
*! 0.2 HS, Oct 5, 2017


pr define wtdtttpreddur, rclass
version 14.0

syntax newvarlist(max=1) [if] [in], ///
                [ IADPercentile(real 0.8) iadmean]
	qui {
		tokenize `varlist'
		local rxdur `1'
		local disttype = r(disttype)
 		if "`disttype'" == "" {
			error 301
			}

		if "`disttype'" == "exp" {
			tempname lnbeta
			predict `lnbeta', eq(lnbeta)

			if "`iadmean'" == "" {
				gen `rxdur' = - log(1 - `iadpercentile') / exp(`lnbeta')
				}
			else {
				gen `rxdur' = exp(- `lnbeta')
				}
			}
		
		if "`disttype'" == "lnorm" {
			tempname mu lnsigma
			predict `mu', eq(mu)
			predict `lnsigma', eq(lnsigma)
			
			if "`iadmean'" == "" {
				gen `rxdur' = exp(invnormal(`iadpercentile') * ///
				  exp(`lnsigma') + `mu')
				}
			else {
				gen `rxdur' = exp(`mu' + .5 * exp(`lnsigma')^2)
				}
			}
		
		
		if "`disttype'" == "wei" {
			tempname lnbeta lnalpha
			predict `lnbeta', eq(lnbeta)
			predict `lnalpha', eq(lnalpha)
			
			if "`iadmean'" == "" {
				gen `rxdur' = (- log(1 - `iadpercentile'))^(1 / exp(`lnalpha')) ///
				  / exp(`lnbeta')
				}
			else {
				gen `rxdur' = exp(- `lnbeta')^exp(- `lnalpha') * ///
				  exp(lngamma(1 + exp(- `lnalpha')))
				}
			}
		}
end

