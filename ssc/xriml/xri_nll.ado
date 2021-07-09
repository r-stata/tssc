*! v 1.0.4 22Feb2008.
program define xri_nll /* normal likelihood */
version 6

tempname ln2pi
scalar `ln2pi'=1.837877
local ll "`1'"
local M "`2'"
local S "`3'"

cap drop __U
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

	gen double __U = `sqrtw'*($ML_y1-`m')/`s'
	if "$S_cens"=="" {
		replace `ll'=-0.5*(`ln2pi'+2*log(`s')+__U^2-`lnw')
	}
	else {
		replace `ll'=cond($S_cens==0, /*
		 */ -0.5*(`ln2pi'+2*log(`s')+__U^2-`lnw'), /*
		 */ cond($S_cens==1, ln(1-normprob(__U)), ln(normprob(__U))))
	}
	if $S_trunc { replace `ll' = `ll'-log(1-normprob(-`m'/`s')) }
}
end
