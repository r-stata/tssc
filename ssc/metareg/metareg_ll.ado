*! v 1.1 26Oct2004
*! Roger Harbord
/*
log-likelihood evaluator (method d0) for metareg v2.
Estimates tau2 by REML.
Variables :
$ML_y1 holds the y-vector of study estimates,
$ML_y2 holds the within-study variances
$REML_x holds the covariates
$REML_nocons is flag "" or "noconstant"
*/

program define metareg_ll
version 7
	args todo b lnf
	tempvar  lnfj v r
	tempname  R tau2 
	mleval `tau2' = `b', scalar
	quietly {
		gen double `v' = $ML_y2 +`tau2' /* v_i = sigma_i^2 + tau^2 */
		capture regress $ML_y1 $REML_x [iw=1/`v'] if $ML_samp, $REML_nocons
		if _rc == 0 {
			predict double `r' if $ML_samp, resid 
			gen double `lnfj' =  `r'^2/`v' +log(`v')
			mlsum `lnf' = `lnfj'
			matrix accum R = $REML_x [iw=1/`v'] if $ML_samp, $REML_nocons
			/* R = X'V^-1X is reml correction to -2logL */
			scalar `lnf' = -0.5 * ( `lnf' +log( det(R) ) )
			}
		else {
			scalar `lnf' = .
			}
		}
	
end
