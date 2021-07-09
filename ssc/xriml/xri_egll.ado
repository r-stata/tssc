*! v 1.0.1 22feb2008.
program define xri_egll
version 6

local ll "`1'"
local M "`2'"
local S "`3'"
if "`4'"=="" { local G $S_gamma }
else local G "`4'"

tempname ln2pi small
scalar `ln2pi'=1.837877
scalar `small'=1e-9

quietly {
	if "$S_off"!="" {
		local m (`M'+$S_off)
	}
	else local m `M'
	if !$S_cv & !$S_lns {
		local s `S' /* sigma parametrization */
	}
	else {
		tempvar s
		if $S_lns { /* log S parametrization */
			if $S_cv { gen double `s' = `m'*exp(`S') }
			else gen double `s' = exp(`S')
		}
		else gen double `s' = `m'*`S'
	}
	if "$S_wt"=="" {
		local w 1
		local lnw 0
		local sqrtw 1
	}
	else {
		local w $S_wt
		local lnw ln(`w')
		local sqrtw sqrt(`w')
	}

* s(igma) is scale factor

	tempvar z surv theta u
	gen double `theta'=(`G')^(-2) 
	gen double `z' = `sqrtw'*($ML_y1-`m')/`s'
	replace `z'  = -`z' if `G'<0
	gen double `u' = `theta'*exp(`z'*abs(`G'))
	
* `surv' is survivor function (upper tail of gamma distribution)

	gen double `surv'=gammap(`theta',`u')
	replace `surv'=1-`surv' if `G'>0
	cap drop __U
	gen double __U=-invnorm(`surv')
	if "$S_cens"=="" {
		replace `ll'=cond(abs(`G')<0.01, /*
		 */ -0.5*`ln2pi'-0.5*(`z'^2-`lnw')- ln(`s'), /*
		 */((`theta'-0.5)*ln(`theta')) /*
		 */  + (`z'*sqrt(`theta'))-`u' /*
		 */ -lngamma(`theta') - ln(`s') + 0.5*`lnw')
	}
	else {
		replace `ll'=cond(abs(`G')<0.01, /*
		 */ cond($S_cens==0, /*
		 */ -0.5*`ln2pi'-0.5*(`z'^2-`lnw')- ln(`s'), /*
		 */ cond($S_cens==1, ln(`surv'), ln(1-`surv'))), /*
		 */ cond($S_cens==0, /*
		 */ ((`theta'-0.5)*ln(`theta')) /*
		 */  + (`z'*sqrt(`theta'))-`u' /*
		 */ -lngamma(`theta') - ln(`s') + 0.5*`lnw', /*
		 */ cond($S_cens==1, ln(`surv'), ln(1-`surv'))))
	}
}
end
