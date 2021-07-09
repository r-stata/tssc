*! v 1.1.4 26nov2008.
program define xri_mpll
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
/*
	gamma is Box-Cox power parameter,
	delta is Box-Cox modulus power parameter.
*/

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
* s(igma) is scale factor---in scale of Y

	cap drop __U
	tempvar lnZ ln1u
	gen double `lnZ' = `sqrtw'*log($ML_y1/`M')
	gen double __U = (`M'/`s')*cond(abs(`G'*`lnZ')>`small', /*
	 */ (exp(`G'*`lnZ')-1)/`G', `lnZ'*(1+0.5*`G'*`lnZ'))
	gen double `ln1u' = ln(1+abs(__U))
	replace __U = sign(__U)*cond(abs(`D'*`ln1u')>`small', /*
	 */ (exp(`D'*`ln1u')-1)/`D', `ln1u'*(1+0.5*`D'*`ln1u'))
	if "$S_cens"=="" {
		replace `ll'=(`D'-1)*`ln1u'-0.5*`ln2pi'-log(`s')-0.5*__U^2-(1-`G')*`lnZ'+0.5*`lnw'
	}
	else {
		replace `ll'=cond($S_cens==0, /*
		 */ (`D'-1)*`ln1u'-0.5*`ln2pi'-log(`s')-0.5*__U^2-(1-`G')*`lnZ'+0.5*`lnw', /*
		 */ cond($S_cens==1, ln(1-normprob(__U)), ln(normprob(__U))))
	}
	if $S_trunc {
		tempvar eps
		gen `eps' = -`M'/(`s'*`G')
		nmod `eps' `D'
		replace `ll'=`ll'-log( /*
		 */ cond(`G'<-`small', `eps', 1)-cond(`G'<`small', 0, `eps'))
	}
}
end
program define nmod /* normprob of modulus function */
	replace `1'= normprob(sign(`1')*((abs(`1')+1)^`2'-1)/`2')
end
