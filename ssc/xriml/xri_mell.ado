*! v 1.1.4 22Feb2008.
program define xri_mell
version 6

local ll "`1'"
local M "`2'"
local S "`3'"

tempname ln2pi small
scalar `ln2pi'=1.837877
scalar `small'=1e-9

if $S_gfix {
	local G $S_gamma
	if $S_dfix { local D $S_delta }
	else local D `4'
}
else {
	local G `4'
	if $S_dfix { local D $S_delta }
	else local D `5'
}
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

* `s'(igma) is scale factor---in scale of Y

	cap drop __U
	tempvar u Gz z ln1u
	gen double `z' = `sqrtw'*($ML_y1-`m')/`s'
	gen double `Gz' = `G'*`z'
	gen double `u' = cond(abs(`Gz')<`small', /*
	 */ (1+0.5*`Gz')*`z', (exp(`Gz')-1)/`G' )
	gen double `ln1u' = ln(1+abs(`u'))
	gen double __U = sign(`u')*cond(abs(`D'*`ln1u')>`small', /*
	 */ (exp(`D'*`ln1u')-1)/`D', `ln1u'*(1+0.5*`D'*`ln1u'))
	if "$S_cens"=="" {
		replace `ll'= -0.5*`ln2pi'-log(`s')-0.5*__U^2 /*
	 	 */ +ln(1+`G'*`u')+(`D'-1)*`ln1u'+0.5*`lnw'
	}
	else {
		replace `ll'=cond($S_cens==0, -0.5*`ln2pi'-log(`s') /*
		 */ -0.5*__U^2+ln(1+`G'*`u')+(`D'-1)*`ln1u'+0.5*`lnw', /*
		 */ cond($S_cens==1, ln(1-normprob(__U)), ln(normprob(__U))))
	}
	if $S_trunc {
		tempvar A B
		gen `A' = cond(`G'<`small', -99, -1/`G')
		gen `B' = cond(`G'<-`small', -1/`G', 99)
		nmod `A' `D'
		nmod `B' `D'
		replace `ll' = `ll'-log(`B'-`A')
	}
}
end
program define nmod /* normprob of modulus function */
	replace `1'= normprob(sign(`1')*((abs(`1')+1)^`2'-1)/`2')
end
