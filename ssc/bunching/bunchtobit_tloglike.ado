capture program drop bunchtobit_tloglike
program bunchtobit_tloglike
/*truncated mid-censored normal log-likelihood:
  delta_l normalized slope + intercept coefficients of model censored on the *right*, that uses data on the LEFT of the kink
  delta_r normalized slope + intercept coefficients of model censored on the *left*, that uses data on the RIGHT of the kink
   normalization of deltas is as follows: delta_k = eta_k*W/sigma, where eta_k is the vector of slope + intercept coefficients 
   of side k={l,r} of the model, sigma is standard deviation 
  lngamma normalized std deviation parameter: lngamma = -ln(sigma), where sigma is the standard deviation
*/
	version 14
	args lnf delta_l delta_r lngamma

	qui replace `lnf' = 0
	qui replace `lnf' = (1 / $obs_num_g ) * ln(   ///
									exp(`lngamma') * normalden(exp(`lngamma')*$ML_y1 - `delta_l', 1) ///
									/ ( normal(exp(`lngamma')*(___kink + ___h) - `delta_r') - normal(exp(`lngamma')*(___kink - ___h) - `delta_l') )  ///
									) /// 
						if $ML_y1 < ___kink & $ML_y1 > ___kink - ___h
	qui replace `lnf' = (1 / $obs_num_g ) * ln(  ///
									(normal((exp(`lngamma')*___kink  - `delta_r')) - normal((exp(`lngamma')*___kink  - `delta_l'))) ///
									/ ( normal(exp(`lngamma')*(___kink + ___h) - `delta_r') - normal(exp(`lngamma')*(___kink - ___h) - `delta_l') ) ///
									) ///
						if $ML_y1 == ___kink
	qui replace `lnf' = (1 / $obs_num_g ) * ln( /// 
									exp(`lngamma') * normalden(exp(`lngamma')*$ML_y1 - `delta_r', 1 ) /// 
									/ ( normal(exp(`lngamma')*(___kink + ___h) - `delta_r') - normal(exp(`lngamma')*(___kink - ___h) - `delta_l') )   ///
									)  ///
						if $ML_y1 < ___kink + ___h & $ML_y1 > ___kink
end


