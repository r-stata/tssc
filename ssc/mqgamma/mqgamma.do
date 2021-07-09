clear all
set seed 12345671

local keep = 2000

program define mkxdata
	local N = `1'
	drop _all
	set obs `N'

// generate covariates
	gen double health     = rchi2(3)/10
	gen double active     = rchi2(4)/7

	gen double uy     = runiform()

// generate y0
//	gen double ln_sy0  = .12 
	gen double ln_sy0  = .12 + .2*health 
	gen double sy0     = exp(ln_sy0)
	gen double zy0     = .12 + .3*active
	gen double exp_zy0 = exp(zy0)
	gen double alphay0 = 1/(sy0^2)
	gen double betay0  = (sy0^2)*exp_zy0
	gen double y0     = invgammap(alphay0 , uy )*(betay0 )

//	gen double ln_sy1  = .11 
	gen double ln_sy1  = .11 + .5*health 
	gen double sy1     = exp(ln_sy1)
	gen double zy1     = .11 + 1.0*active
	gen double exp_zy1 = exp(zy1)
	gen double alphay1 = 1/(sy1^2)
	gen double betay1  = (sy1^2)*exp_zy1
	gen double y1     = invgammap(alphay1 , uy )*(betay1 )


	gen double uc     = runiform()
	gen double ln_sc  = .7 + .7*health
	gen double sc     = exp(ln_sc)
	gen double zc     = 3.3 + 3.2*active
	gen double exp_zc = exp(zc)
	gen double alphac = 1/(sc^2)
	gen double betac  = (sc^2)*exp_zc
	gen double c     = invgammap(alphac , uc )*(betac )

	gen treat          = (-.6 + .5*health + .75*active + rnormal()) > 0

	gen double w      = treat*min(y1,c) + (1-treat)*min(y0,c)
	gen f0            = y0<=c
	gen f1            = y1<=c
	gen double f      = treat*f1 + (1-treat)*f0
	gen double cons   = 1

	rename w t
	rename f fail
	rename treat exercise

	keep t fail exercise health active

end

mkxdata `keep'
save exercise, replace
clear all


use exercise
mqgamma t active, treat(exercise) fail(fail) lns(health) quantile(.25 .75)

nlcom (_b[q25_1:_cons] - _b[q25_0:_cons]) 	///
	(_b[q75_1:_cons] - _b[q75_0:_cons])

mqgamma t active, treat(exercise) fail(fail) lns(health) 	///
	quantile(.25 .75) aequations

predict double z0, equation(z_0)

predict double lns0, equation(lns_0)

generate double cd0 = gammap(exp(-2*lns0), .2151604/(exp(z0)*exp(2*lns0)))
sum cd0

gmm ( gammap(exp(-2*lns0), {qh}/(exp(z0)*exp(2*lns0))) - .25), onestep


