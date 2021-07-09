*! v 1.0.3 26nov2008.
program define xri_pnll
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
	if $S_tau { /* G is tau parametrization, convert to g=lambda */
		tempvar g
		gen double `g' = 1-`G'*`M'/`s'
	}
	else local g `G'
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

	tempvar lnZ
	cap drop __U
	gen double `lnZ' = `sqrtw'*log($ML_y1/`M')
	gen double __U = (`M'/`s')*cond(abs(`g'*`lnZ')>`small', /*
	 */ (exp(`g'*`lnZ')-1)/`g', `lnZ'*(1+0.5*`g'*`lnZ'))

* Last term, V, is (1-lambda)*log(y/mu)

	if "$S_cens"=="" {
		replace `ll'=-0.5*`ln2pi'-log(`s')-0.5*__U^2-(1-`g')*`lnZ'+0.5*`lnw'
	}
	else {
		replace `ll'=cond($S_cens==0, /*
		 */ -0.5*`ln2pi'-log(`s')-0.5*__U^2-(1-`g')*`lnZ'+0.5*`lnw', /*
		 */ cond($S_cens==1, ln(1-normprob(__U)), ln(normprob(__U))))
	}
	if $S_trunc { replace `ll' = /*
	 */ `ll'-cond(abs(`g')<`small', 0,  cond(`g'>0, /*
	 */ log(normprob(`M'/(`g'*`s'))), log(normprob(-`M'/(`g'*`s')))) ) }
}
end
