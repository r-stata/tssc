program define cdfquantreg_p
version 13.0
		   /* I have to include xb and stdp because _pred_se does only equation(1) */
        local myopts "Xb Stdp Qtile Pctle(real -1)"
        _pred_se "`myopts'" `0'
        if `s(done)'  exit 
        local vtyp `s(typ)'
        local varn `s(varn)'
        local 0    `"`s(rest)'"'
		
		syntax [if] [in] [, `myopts']
		marksample touse, novarlist  
		
		  /* concatenate switch options together */
        local type "`xb'`stdp'`qtile'`pctle(real -1)'"
		
		  /* Estimate quantiles if qtile is requested */
quietly {
_predict xb if `touse', equation(#1)
_predict xd if `touse', equation(#2)
if "`qtile'" != "" {
	tempvar qtile  w  reptile
    gen `qtile' = .  
if `pctle'==-1 {
	cumul `e(depvar)', gen(`reptile') 
	replace `qtile' =  (`reptile'*(_N-1))*((0.999999 - 1e-06)/(_N-1)) + 1e-06 if `touse'
      }
else {
      replace `qtile' = `pctle' if `touse'
	  if `pctle' <= 0|`pctle' >= 1 {
	display as error `"Argument out of (0,1) range"'
	exit 198
		}
	  }
	}
}
	
quietly {
if `"`e(user)'"'=="asinhasinh" {
	gen fitted = 1/(1 + exp(-asinh(((1 - 2*`qtile')/(2*(-1 + `qtile')*`qtile') ///
	+ xb/exp(xd))/(1/exp(xd)))))
	}
if `"`e(user)'"'=="asinhburr7" {
	gen fitted = (1/2)*(1 + tanh(xb + (exp(xd) ///
- 2*`qtile'*exp(xd))/(2*(-1 + `qtile')*`qtile')))
	}
if `"`e(user)'"'=="asinhburr8" {
	gen fitted = 2*(atan( exp(xb + (exp(xd) ///
- 2*`qtile'*exp(xd))/(2*(-1 + `qtile')*`qtile')))/(_pi))
	}
if `"`e(user)'"'=="asinhcauchy" {
	gen fitted = 1/2 + atan(xb + (exp(xd) ///
- 2*`qtile'*exp(xd))/(2*(-1 + `qtile')*`qtile'))/(_pi)
	}
if `"`e(user)'"'=="asinhlogistic" {
	gen fitted = exp(xb)/(exp(xb) + exp((exp(xd) ///
	- 2*`qtile'*exp(xd))/(2*`qtile' - 2*(`qtile'^2))))
	}
if `"`e(user)'"'=="asinht2" {
	gen fitted = 1/2 + (((1 - 2*`qtile')/(2*(-1 + `qtile')*`qtile') ///
+ xb/exp(xd))*exp(xd))/(2*sqrt(2 + (((1 ///
- 2*`qtile')/( 2*(-1 + `qtile')*`qtile') + xb/exp(xd))*exp(xd))^2))
	}
if `"`e(user)'"'=="burr7asinh" {
	gen fitted = (-1 + xb - exp(xd) *atanh(1 - 2* `qtile') ///
	+ sqrt(1 + xb^2 -2* xb *exp(xd)* atanh(1 - 2* `qtile') ///
	+ exp(xd)^2 *atanh( 1 - 2* `qtile')^2))/( 2 *xb ///
	- 2 *exp(xd)* atanh(1 - 2* `qtile'))
	}
if `"`e(user)'"'=="burr7burr7" {
	gen fitted = (1/2 )*(1 + tanh(xb - exp(xd)*atanh(1 - 2*`qtile')))
	}
if `"`e(user)'"'=="burr7cauchy" {
	gen fitted = (1/2) + (atan(xb - (exp(xd)*atanh(1 - (2*`qtile'))))/_pi)
	}
if `"`e(user)'"'=="burr7logistic" {
	gen fitted = exp(xb)/(exp(xb) + exp(exp(xd)*atanh(1 - 2*`qtile')))
	}
if `"`e(user)'"'=="burr7t2" {
	gen fitted = 1/2 + ((-atanh(1 - 2*`qtile') + xb/exp(xd))*exp(xd))/( 2*sqrt(2 ///
+ ((-atanh(1 - 2*`qtile') + xb/exp(xd))*exp(xd))^2))
	}
if `"`e(user)'"'=="burr8asinh" {
	gen fitted = 1/(1 - xb + exp(xd)*log(1/tan(((_pi)*`qtile')/2)) ///
+ sqrt( 1 + xb^2 - 2*xb*exp(xd)*(log(1/tan(((_pi)*`qtile')/2))) ///
+ exp(xd)^2*(log( 1/tan(((_pi)*`qtile')/2)))^2))
	}
if `"`e(user)'"'=="burr8burr7" {
	gen fitted = (1/2)*(1 + tanh(xb-exp(xd)*log(1/tan(_pi*`qtile'/2))))
	}
if `"`e(user)'"'=="burr8burr8" {
	gen fitted = (2*(atan( exp(xb - exp(xd)*(log(1/tan(((_pi)*`qtile')/2)))))))/(_pi)
	}
if `"`e(user)'"'=="burr8cauchy" {
	gen fitted = 1/2 + atan(xb - exp(xd)*(log(1/tan((_pi *`qtile')/2))))/_pi
	}
if `"`e(user)'"'=="burr8logistic" {
	gen fitted = exp(xb)/(exp(xb)+ 1/tan(((_pi)*`qtile')/2)^ exp(xd))
	}
if `"`e(user)'"'=="burr8t2" {
	gen fitted = 1/2 + (xb + exp(xd)*log(tan(((_pi)*`qtile')/2)))/( 2*sqrt(2 ///
+ (xb + exp(xd)*log(tan(((_pi)*`qtile')/2)))^2))
	}
if `"`e(user)'"'=="cauchitasinh" {
	gen fitted = (-1 + xb - exp(xd)*1/tan((_pi)*`qtile') + sqrt( 1 ///
+ xb^2 - 2*xb*exp(xd)*1/tan((_pi)*`qtile') ///
+ exp(xd)^2*1/tan((_pi)*`qtile')^2))/(2* xb - 2*exp(xd)*1/tan((_pi)*`qtile'))
	}
if `"`e(user)'"'=="cauchitburr7" {
	gen fitted = (1/2)*(1 + tanh(xb - exp(xd)*(1/tan(_pi*`qtile'))))
	}
if `"`e(user)'"'=="cauchitburr8" {
	gen fitted = (2* (atan(exp(xb - exp(xd)* 1/tan((_pi)* `qtile')))))/(_pi)
	}
if `"`e(user)'"'=="cauchitcauchy" {
	gen fitted = 1/2 + atan((-(1/tan(_pi*`qtile')) + xb/ exp(xd))* exp(xd))/_pi
	}
if `"`e(user)'"'=="cauchitlogistic" {
	gen fitted = 1/(1 + exp(-xb + exp(xd)*tan(0.5*_pi - _pi*`qtile')))
	}
if `"`e(user)'"'=="cauchitt2" {
	gen fitted = 1/2 + ((-1/tan(_pi*`qtile') + (xb/exp(xd)))*exp(xd))/(2*sqrt(2 ///
+ ((-1/tan(_pi*`qtile') + (xb/exp(xd)))*exp(xd))^2))
	}
if `"`e(user)'"'=="logitasinh" {
	gen fitted = 1/(1 + exp(-asinh((-log(-1 + 1/`qtile') ///
+ xb/ exp(xd))* exp(xd))))
	}
if `"`e(user)'"'=="logitburr7" {
	gen fitted = (1/2 )*(1 + tanh(xb - exp(xd)*(log(-1 + 1/`qtile'))))
	}
if `"`e(user)'"'=="logitburr8" {
	gen fitted = (2* (atan(exp(xb - exp(xd)* (log(-1 + 1/`qtile'))))))/(_pi)
	}
if `"`e(user)'"'=="logitcauchy" {
	gen fitted = 1/2 + atan((-log(-1 + 1/`qtile') + xb/exp(xd))*exp(xd))/_pi
	}
if `"`e(user)'"'=="logitlogistic" {
	gen fitted = 1/(1 + exp((log(1/`qtile' - 1) - xb/exp(xd)) * exp(xd)))
	}
if `"`e(user)'"'=="logitt2" {
	gen fitted = 1/2 + ((log(`qtile'/(1 - `qtile')) ///
+ (xb)/exp(xd))*exp(xd))/(2*sqrt(2 ///
+ ((log(`qtile'/(1 - `qtile')) + (xb)/exp(xd))*exp(xd))^2))
	}
if `"`e(user)'"'=="t2asinh" {
	gen `w' = sign(2*`qtile'-1)*(sqrt((1 - 2 * `qtile')^2/(2 * (1 - `qtile') *`qtile')))
	gen fitted = 1/(1 + exp(-asinh(xb + exp(xd)*`w')))
	}
if `"`e(user)'"'=="t2burr7" {
	gen `w' = sign(2*`qtile'-1)*(sqrt((1 - 2 * `qtile')^2/(2 * (1 - `qtile') *`qtile')))
	gen fitted = (tanh((`w' + xb/exp(xd))*exp(xd)) + 1)/2
	}
if `"`e(user)'"'=="t2burr8" {
	gen `w' = sign(2*`qtile'-1)*(sqrt((1 - 2 * `qtile')^2/(2 * (1 - `qtile') *`qtile')))
	gen fitted = 2*(atan(exp((`w' + xb/exp(xd))*exp(xd)))/_pi)
	}
if `"`e(user)'"'=="t2cauchy" {
	gen `w' = sign(2*`qtile'-1)*(sqrt((1 - 2 * `qtile')^2/(2 * (1 - `qtile') *`qtile')))
	gen fitted = 1/2 + atan((`w' + xb/exp(xd))*exp(xd))/_pi
	}
if `"`e(user)'"'=="t2logistic" {
	gen `w' = sign(2*`qtile'-1)*(sqrt((1 - 2 * `qtile')^2/(2 * (1 - `qtile') *`qtile')))
	gen fitted = 1/(1 + exp(-xb - exp(xd)*`w'))
	}
if `"`e(user)'"'=="t2t2" {
	gen `w' = sign(2*`qtile'-1)*(sqrt((1 - 2 * `qtile')^2/(2 * (1 - `qtile') *`qtile')))
	gen fitted = 1/2 + ((`w' + xb/exp(xd))*exp(xd))/(2*sqrt(2 ///
+ ((`w' + xb/exp(xd))*exp(xd))^2))
	}
}
			  /* Generate residuals only if estimating casewise quantiles */
quietly {
if `pctle'==-1 {
    gen residuals = fitted - `e(depvar)' if `touse'
	}
}
			  /* Get rid of the fitted and residuals if not requested */
if "`qtile'" == "" {
	drop fitted
	drop residuals
}
		  /* Get the standard errors of predictions if stdp requested */
if "`stdp'" != "" {
_predict seb if `touse', stdp equation(#1) 
_predict sed if `touse', stdp equation(#2) 
}
end

