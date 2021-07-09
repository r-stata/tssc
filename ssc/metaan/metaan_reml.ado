//needs to be in a separate file otherwise cannot call ml
/* log-likelihood evaluator (method d0) for metaan.
Estimates tau2 by REML.
Variables :
$ML_y1 holds the y-vector of study estimates,
$ML_y2 holds the within-study variances
pretty much copied from metareg by Roger Harbord, thank you Roger! */
program define metaan_reml
    /*d0 evaluator standards*/
    args todo b lnf
	tempvar lnfj v r
	tempname R tau2
    mleval `tau2' = `b', scalar
    local mu "$ML_y1"
    local sig2 "$ML_y2"
    /*compute*/
    qui {
        /* overall variance = sigma_i^2 + tau^2 */
    	gen double `v' = `sig2' +`tau2'
    	capture regress `mu' [iw=1/`v'] if $ML_samp
  		if _rc == 0 {
  			predict double `r' if $ML_samp, resid
  			gen double `lnfj' =  `r'^2/`v' +log(`v')
  			mlsum `lnf' = `lnfj'
  			matrix accum R = [iw=1/`v'] if $ML_samp
  			/* R = X'V^-1X is reml correction to -2logL */
  			scalar `lnf' = -0.5 * ( `lnf' +log( det(R) ) )
  		}
  		else  {
              scalar `lnf' = .
  		}
    }
end
