log using test.log, replace
*
*  test data for rc_spline.ado
*
set more on
set obs 101
gen xvar = (_n-1)*.1
gen y = exp(-xvar) - exp(-(10-xvar)/3 ) + 1
gen z = exp(-xvar) + exp(-(10-xvar)/3 ) 
gen freq = 3*(xvar<5) +1
rc_spline xvar [weight = freq]
regress y _S* [weight = freq]
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(3)
regress y _S* 
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar [fweight = freq], nknots(3) 
regress y _S* [fweight = freq]
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(4)
regress y _S* 
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(5)
regress y _S* 
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(6)
regress y _S* 
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(7)
regress y _S* 
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more


drop *hat _S*
rc_spline xvar, nknots(3)
regress z _S* 
predict zhat, xb
scatter z xvar || line zhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(4)
regress z _S* 
predict zhat, xb
scatter z xvar || line zhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(5)
regress z _S* 
predict zhat, xb
scatter z xvar || line zhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(6)
regress z _S* 
predict zhat, xb
scatter z xvar || line zhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(7)
regress z _S* 
predict zhat, xb
scatter z xvar || line zhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar,  knots(1 2 3 4 5 6 7 8)
regress z _S* 
predict zhat, xb
scatter z xvar || line zhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(8) knots(1 2 3 4 5 6 7 8)
regress y _S* 
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more

drop *hat _S*
rc_spline xvar, nknots(9) knots(1 2 3 4 5 6 7 8)
regress y _S* 
predict yhat, xb
scatter y xvar || line yhat xvar, clwidth(medthick) clcolor(red)
more

log close
