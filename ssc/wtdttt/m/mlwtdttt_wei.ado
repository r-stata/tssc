* Parametric likelihood definition for Waiting Time Distribution
* with Weibull FRD and Uniform h, no censoring
* Henrik Støvring, Dec 2001
* Henrik Støvring, 11 Nov 2015 - switched parameter order to match with lnorm
* Updated and simplified with invlogit, HS Aug 30, 2016
* Name changed to avoid conflict with -wtd-package, HS Sep 09, 2018

program define mlwtdttt_wei
        version 14.0
	args lnf logitp lnbeta lnalpha 

qui{
	
        replace `lnf' = ln(invlogit(`logitp')                   /*
                        */ * exp(- (($ML_y1 * exp(`lnbeta') )^exp(`lnalpha')) /*
                        */ - lngamma(1 + 1/exp(`lnalpha'))) * exp(`lnbeta') +  /*
                        */ invlogit(- `logitp') / $wtddelta )
      }
end
