*! v 1.2.4 22Feb2008.
program define xri_enll
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

	tempvar z Gz
	cap drop __U
	gen double `z' = `sqrtw'*($ML_y1-`m')/`s'
	gen double `Gz' = `G'*`z'
	gen double __U = cond(abs(`Gz')<`small', /*
	 */ (1+0.5*`Gz')*`z', (exp(`Gz')-1)/`G' )
	if "$S_cens"=="" {
		replace `ll'=-0.5*(`ln2pi'+2*log(`s')+__U^2-`lnw')+`Gz'
	}
	else {
		replace `ll'=cond($S_cens==0, /*
		 */ -0.5*(`ln2pi'+2*log(`s')+__U^2-`lnw')+`Gz', /*
		 */ cond($S_cens==1, ln(1-normprob(__U)), ln(normprob(__U))))
	}
	if $S_trunc {
		replace `ll' = `ll'-log( /*
		 */ cond(`G'<-`small', normprob(-1/`G'), 1 ) /*
		 */ -cond(`G'<`small', 0, normprob(-1/`G') ) )
	}
}
end
