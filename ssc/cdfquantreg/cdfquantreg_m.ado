program define cdfquantreg_m, eclass
version 13.0

syntax varlist [, pctle(real 0.5)]

if `pctle' <= 0|`pctle' >= 1 {
	display as error `"Argument out of (0,1) range"'
	exit 198
	}
estimates store modresults
margins `varlist', predict(equation(#1)) post
mat m1 = e(b)

local col_names : colfullnames e(b)
   tokenize "`col_names'"
   local i = 0
   local j = 0
   while "``++j''" != "" {
       local blist`++i' `"``j''"'
       if "`char'" == "nochar" {
           local ++j
           }
       }

estimates restore modresults
margins `varlist', predict(equation(#2)) post
mat m2 = e(b)
estimates restore modresults
di ""
di "`varlist'"
di "`pctle' quantile  factor level"
di "--------------------------"

local mcol = `=colsof(m1)'  /* I can use this for the loop for both m1 and m2*/

/* Compute the relevant quantile function */

if `"`e(user)'"'=="t2t2" {
if (`pctle' < 0.5) {
 local w = -sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
 else {
 local w = sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + ((`w' + m1[1,`j']/exp(m2[1,`j']))*exp(m2[1,`j']))/(2*sqrt(2 + ((`w' + m1[1,`j']/exp(m2[1,`j']))*exp(m2[1,`j']))^2))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="t2logistic" {
if (`pctle' < 0.5) {
 local w = -sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
 else {
 local w = sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/(1 + exp(-m1[1,`j'] - exp(m2[1,`j'])*`w'))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="t2cauchy" {
if (`pctle' < 0.5) {
 local w = -sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
 else {
 local w = sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + atan((`w' + m1[1,`j']/exp(m2[1,`j']))* exp(m2[1,`j']))/_pi
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="t2burr8" {
if (`pctle' < 0.5) {
 local w = -sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
 else {
 local w = sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 2*(atan(exp((`w' + m1[1,`j']/ exp(m2[1,`j']))* exp(m2[1,`j'])))/_pi)
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="t2burr7" {
if (`pctle' < 0.5) {
 local w = -sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
 else {
 local w = sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (tanh((`w' + m1[1,`j']/exp(m2[1,`j']))* exp(m2[1,`j'])) + 1)/2
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="t2asinh" {
if (`pctle' < 0.5) {
 local w = -sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
 else {
 local w = sqrt((1 - 2 * `pctle')^2/(2 * (1 - `pctle') *`pctle')) 
 }
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/(1 + exp(-asinh(m1[1,`j'] + exp(m2[1,`j'])*`w')))
        di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="logitt2" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + ((log(`pctle'/(1 - `pctle')) + (m1[1,`j'])/exp(m2[1,`j']))*exp(m2[1,`j']))/(2*sqrt(2 + ((log(`pctle'/(1 - `pctle')) + (m1[1,`j'])/exp(m2[1,`j']))*exp(m2[1,`j']))^2))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="logitlogistic" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/(1 + exp((log(1/`pctle' - 1) - m1[1,`j']/exp(m2[1,`j'])) * exp(m2[1,`j'])))
       di `ypred' "     `blist`j''" 
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="logitcauchy" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + atan((-log(-1 + 1/`pctle') + m1[1,`j']/exp(m2[1,`j']))*exp(m2[1,`j']))/_pi
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="logitburr8" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (2* (atan(exp(m1[1,`j'] - exp(m2[1,`j'])* (log(-1 + 1/`pctle'))))))/(_pi)
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="logitburr7" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (1/2 )*(1 + tanh(m1[1,`j'] - exp(m2[1,`j'])*(log(-1 + 1/`pctle'))))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="logitasinh" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/(1 + exp(-asinh((-log(-1 + 1/`pctle') + m1[1,`j']/ exp(m2[1,`j']))* exp(m2[1,`j']))))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="cauchitt2" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + ((-1/tan(_pi*`pctle') + (m1[1,`j']/exp(m2[1,`j'])))*exp(m2[1,`j']))/(2*sqrt(2 + ((-1/tan(_pi*`pctle') + (m1[1,`j']/exp(m2[1,`j'])))*exp(m2[1,`j']))^2))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="cauchitlogistic" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/(1 + exp(-m1[1,`j'] + exp(m2[1,`j'])*tan(0.5*_pi - _pi*`pctle')))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="cauchitcauchy" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + atan((-(1/tan(_pi*`pctle')) + m1[1,`j']/ exp(m2[1,`j']))* exp(m2[1,`j']))/_pi
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="cauchitburr8" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (2* (atan(exp(m1[1,`j'] - exp(m2[1,`j'])* 1/tan((_pi)* `pctle')))))/(_pi)
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="cauchitburr7" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (1/2)*(1 + tanh(m1[1,`j'] - exp(m2[1,`j'])*(1/tan(_pi*`pctle'))))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="cauchitasinh" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (-1 + m1[1,`j'] - exp(m2[1,`j'])*1/tan((_pi)*`pctle') + sqrt( 1 + m1[1,`j']^2 - 2*m1[1,`j']*exp(m2[1,`j'])*1/tan((_pi)*`pctle') + exp(m2[1,`j'])^2*1/tan((_pi)*`pctle')^2))/(2* m1[1,`j'] - 2*exp(m2[1,`j'])*1/tan((_pi)*`pctle'))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr8t2" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + (m1[1,`j'] + exp(m2[1,`j'])*log(tan(((_pi)*`pctle')/2)))/( 2*sqrt(2 + (m1[1,`j'] + exp(m2[1,`j'])*log(tan(((_pi)*`pctle')/2)))^2))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr8logistic" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = exp(m1[1,`j'])/(exp(m1[1,`j'])+ 1/tan(((_pi)*`pctle')/2)^ exp(m2[1,`j']))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr8cauchy" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + atan(m1[1,`j'] - exp(m2[1,`j'])*(log(1/tan((_pi *`pctle')/2))))/_pi
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr8burr8" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (2*(atan( exp(m1[1,`j'] - exp(m2[1,`j'])*(log(1/tan(((_pi)*`pctle')/2)))))))/(_pi)
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr8burr7" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (1/2)*(1 + tanh(m1[1,`j']-exp(m2[1,`j'])*log(1/tan(_pi*`pctle'/2))))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr8asinh" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/(1 - m1[1,`j'] + exp(m2[1,`j'])*log(1/tan(((_pi)*`pctle')/2)) + sqrt( 1 + m1[1,`j']^2 - 2*m1[1,`j']*exp(m2[1,`j'])*(log(1/tan(((_pi)*`pctle')/2))) + exp(m2[1,`j'])^2*(log( 1/tan(((_pi)*`pctle')/2)))^2))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr7t2" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + ((-atanh(1 - 2*`pctle') + m1[1,`j']/exp(m2[1,`j']))*exp(m2[1,`j']))/( 2*sqrt(2 + ((-atanh(1 - 2*`pctle') + m1[1,`j']/exp(m2[1,`j']))*exp(m2[1,`j']))^2))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr7logistic" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = exp(m1[1,`j'])/(exp(m1[1,`j']) + exp(exp(m2[1,`j'])*atanh(1 - 2*`pctle')))
        di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr7cauchy" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (1/2) + (atan(m1[1,`j'] - (exp(m2[1,`j'])*atanh(1 - (2*`pctle'))))/_pi)
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr7burr7" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (1/2 )*(1 + tanh(m1[1,`j'] - exp(m2[1,`j'])*atanh(1 - 2*`pctle')))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="burr7asinh" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (-1 + m1[1,`j'] - exp(m2[1,`j']) *atanh(1 - 2* `pctle') + sqrt(1 + m1[1,`j']^2 -2* m1[1,`j'] *exp(m2[1,`j'])* atanh(1 - 2* `pctle') + exp(m2[1,`j'])^2 *atanh( 1 - 2* `pctle')^2))/( 2 *m1[1,`j'] - 2 *exp(m2[1,`j'])* atanh(1 - 2* `pctle'))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="asinht2" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + (((1 - 2*`pctle')/(2*(-1 + `pctle')*`pctle') + m1[1,`j']/exp(m2[1,`j']))*exp(m2[1,`j']))/(2*sqrt(2 + (((1 - 2*`pctle')/( 2*(-1 + `pctle')*`pctle') + m1[1,`j']/exp(m2[1,`j']))*exp(m2[1,`j']))^2))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="asinhlogistic" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = exp(m1[1,`j'])/(exp(m1[1,`j']) + exp((exp(m2[1,`j']) - 2*`pctle'*exp(m2[1,`j']))/(2*`pctle' - 2*(`pctle'^2))))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="asinhcauchy" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/2 + atan(m1[1,`j'] + (exp(m2[1,`j']) - 2*`pctle'*exp(m2[1,`j']))/(2*(-1 + `pctle')*`pctle'))/(_pi)
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="asinhburr8" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 2*(atan( exp(m1[1,`j'] + (exp(m2[1,`j']) - 2*`pctle'*exp(m2[1,`j']))/(2*(-1 + `pctle')*`pctle')))/(_pi))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="asinhburr7" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = (1/2)*(1 + tanh(m1[1,`j'] + (exp(m2[1,`j']) - 2*`pctle'*exp(m2[1,`j']))/(2*(-1 + `pctle')*`pctle')))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

if `"`e(user)'"'=="asinhasinh" {
     /* begin loop */
     local j=1
    while `j'<=`mcol' {
       local ypred = 1/(1 + exp(-asinh(((1 - 2*`pctle')/(2*(-1 + `pctle')*`pctle') + m1[1,`j']/exp(m2[1,`j']))/(1/exp(m2[1,`j'])))))
       di `ypred' "     `blist`j''"
		local j = `j' + 1
    } /* end loop */
}

drop _est_modresults
end

/*
These distributions are from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/

