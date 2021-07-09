*! v 1.0.4 26nov2008.
program define xri_slll
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
	if !$S_cv & !$S_lns {
		local s `S' /* sigma parametrization */
	}
	else {
		tempvar s
		if $S_lns { /* log S parametrization */
			if $S_cv { gen double `s' = `M'*exp(`S') }
			else gen double `s' = exp(`S')
		}
		else gen double `s' = `M'*`S'
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

	tempvar Gz
	cap drop __U
	gen double `Gz' = `sqrtw'*`G'*($ML_y1-`M')/`s'
	gen double __U = cond(abs(`Gz')<`small', /*
	 */ (1-0.5*`Gz')*($ML_y1-`M')/`s', log(1+`Gz')/`G' )
	if "$S_cens"=="" {
		replace `ll'=-0.5*`ln2pi'-log(`s')-0.5*__U^2-`G'*__U+0.5*`lnw'
	}
	else {
		replace `ll'=cond($S_cens==0, /*
		 */ -0.5*`ln2pi'-log(`s')-0.5*__U^2-`G'*__U+0.5*`lnw', /*
		 */ cond($S_cens==1, ln(1-normprob(__U)), ln(normprob(__U))))
	}
	if $S_trunc { replace `ll' = `ll'-cond(abs(`G')>`small', /*
	 */ log(1-normprob(log(1-`M'*`G'/`s')/`G')), /*
	 */ log(1-normprob(-`M'/`s')) ) }
}
end
