* Parametric likelihood definition for Waiting Time Distribution
* with Weibull FRD and Uniform h, no censoring
* Henrik Støvring, Dec 2001

program define mlwtd_wei
        version 7.0
	args lnf transp lnalpha lnbeta 

        tempname p alpha beta
qui{
        scalar `p' = exp(`transp')/(1+exp(`transp'))
	scalar `alpha' = exp(`lnalpha')
	scalar `beta' = exp(`lnbeta')
	
        replace `lnf' = ln( `p'                   /*
                        */ * exp(- (($ML_y1 * `beta' )^`alpha') /*
                        */ - lngamma(1 + 1/`alpha')) * `beta' +  /*
                        */ (1 - `p') )
      }
end
