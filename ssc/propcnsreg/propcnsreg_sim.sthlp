*=================================================================================
* Check if the ideas presented in
* http://blog.stata.com/2011/08/22/use-poisson-rather-than-regress-tell-a-friend/
* also apply to -propcnsreg-
* not working as well as I would have liked/hoped, especially the standard errors
*
* also requires -simsum- and -simpplot-, both can be installed using -ssc-
*=================================================================================


clear all
program define sim, rclass
	drop _all
	set obs 5000
	gen z1 = rnormal()
	gen z2 = rnormal()

	gen lat = .25*z1 + .5*z2
	gen x1 = rnormal()
	gen x2 = rnormal()
	gen lam = 1 + .5*x1
	gen y = exp(.25*x1 + .25*x2 + lam*lat + .2*rnormal())

	propcnsreg y x1 x2 , constr(z1 z2) lambda(x1) lcons poisson robust
	return scalar w     = e(w_p)
	return scalar bz1   =   [constrained]_b[z1]
	return scalar bz2   =   [constrained]_b[z2]
	return scalar blx1  =        [lambda]_b[x1]
	return scalar bx1   = [unconstrained]_b[x1]
	return scalar sez1  =   [constrained]_se[z1]
	return scalar sez2  =   [constrained]_se[z2]
	return scalar selx1 =        [lambda]_se[x1]
	return scalar sex1  = [unconstrained]_se[x1]
end

set seed 123456

simulate w=r(w)                  ///
bz1  = r(bz1)  sez1  = r(sez1)   ///
bz2  = r(bz2)  sez2  = r(sez2)   ///
blx1 = r(blx1) selx1 = r(selx1)  ///
bx1  = r(bx1)  sex1  = r(sex1),  ///
reps(5000):sim

simsum bz1 , se(sez1)  true(.25) mcse
simsum bz2 , se(sez2)  true(.50) mcse
simsum blx1, se(selx1) true(.50) mcse 
simsum bx1 , se(sex1)  true(.25) mcse

gen pz1  = 2*normal(-abs(( bz1-.25)/sez1 ))
gen pz2  = 2*normal(-abs(( bz2-.50)/sez2 ))
gen plx1 = 2*normal(-abs((blx1-.50)/selx1))
gen px1  = 2*normal(-abs(( bx1-.25)/sex1 ))

simpplot w pz1 pz2 plx1 px1, scheme(s2color) name(pois_coef, replace)

exit
