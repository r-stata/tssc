*! v 3.0.0 PR 24Jul2000.
program define centcalc, sclass
version 6
local hidopts "TRunc TAu LNs"
syntax varlist(min=2 max=2) [if] [in] [, Centiles(numlist >0 <100) /*
 */ DIst(string) Prefix(string) Gamma(string) DElta(string) CV `hidopts' ]
if "`dist'"=="" { local dist n }
else local dist = lower(substr("`dist'", 1, 2))
if "`dist'"=="n"|"`dist'"=="no" {
	local dnum 0
}
else local dnum=1*("`dist'"=="sl")+2*("`dist'"=="pn") /*
 */	       +3*("`dist'"=="en")+4*("`dist'"=="eg") /*
 */ 	       +5*("`dist'"=="ep")+6*("`dist'"=="ee") /*
 */ 	       +7*("`dist'"=="mp")+8*("`dist'"=="me")
local pars4=(`dnum'>=5)
if `dnum'>0 {
	if "`gamma'"=="" {
		di in red "gamma() required for `dist' distribution"
		exit 198
	}
	cap confirm var `gamma'
	if _rc { confirm num `gamma' }
	if `pars4' {
		if "`delta'"=="" {
			di in red "delta() required for `dist' distribution"
			exit 198
		}
		cap confirm var `delta'
		if _rc { confirm num `delta' }
	}
}
/*
	mu is M curve.
	sfit is fitted S curve, could be cv, log sigma, etc.
*/
gettoken mu sfit: varlist
quietly {

* deal with user prefix for centile variable(s)
	if "`prefix'"=="" { local prefix "C" }

* parse the centiles
	if "`centile'"=="" {
		local nc 1
		local c1 50
	}
	else {
		local nc 0 /* counter to index strings containing centiles */
		tokenize "`centile'"
		while "`1'"!="" {
			local nc=`nc'+1
			local c`nc' `1'
			mac shift
		}
	}
/*
	Estimate the centiles.
	sigma is the scale (S) parameter.
*/
	if "`cv'"=="" & "`lns'"=="" {
		local sigma `sfit'	/* sigma parametrization */
	}
	else {
		tempvar sigma
		if "`lns'"!="" {	/* log S parametrization */
			if "`cv'"!="" {
				gen double `sigma' = `mu'*exp(`sfit')
			}
			else gen double `sigma' = exp(`sfit')
		}
		else gen double `sigma' = `mu'*`sfit'
	}
	if "`tau'"!="" & (`dnum'==2|`dnum'==5) { /* PN, tau parametrization */
		tempvar g			 /* lambda */
		gen `g' = 1-`gamma'*`mu'/`sigma'
	}
	else local g `gamma'
	local i 0
	while `i'<`nc' {
		local i=`i'+1
		centcal `dnum' `mu' `sigma' "`g'" "`delta'" /*
		 */ `c`i'' `prefix' "`trunc'"
		sret local cvar`i' `s(cname)'
	}
}
end

program define centcal, sclass /* based on freestanding _centcal v 1.0.3 28-Feb-95. */
* args: 1=delta, 2=gamma, 3=mu, 4=sigma, 5=centile value,
* 6=variable to hold estimated centile,
* 7=distribution (0=normal, 1=SL, 2=PN, 3=EN, 4=EG, 5=EP, 6=EE, 7=MP, 8=ME),
* 8=trunc flag.
	local dnum `1'
	local mu `2'
	local sigma `3'
	local gamma "`4'"
	local delta "`5'"
	local centile `6'
	local C `7'
	local trunc = "`8'"!=""

	tempvar A B

	local q = `centile'/100

	if `centile'>0 {
* Compute z-value from user's centile
		local z=invnorm(`q')
		local c `C'`centile'    /* name of centile var incs centile */
* fix up name if contains a dec point
		local pt=index("`c'",".")
		if `pt' {
			local c=substr(substr("`c'",1,`pt'-1) /*
			 */ +"_"+substr("`c'",`pt'+1,.),1,8)
		}
	}
	else {
		local z=invnorm(-`q')
		local c `C'             /* user-supplied name if centile<0 */
	}

* Estimate centile
	if `trunc' { tempvar uq }
	else local uq `z'
	cap drop `c'
	local small 1e-6
	if `dnum'==0 {				/* normal */
		if `trunc' {
			gen `uq' = invnorm( `q'+(1-`q')* /*
			 */ normprob(-`mu'/`sigma') )
		}
		gen `c' = `mu'+`sigma'*`uq'
	}
	else if `dnum'==1 {			/* SL */
		if `trunc' {
			gen `uq' = cond(abs(1-`mu'*`gamma'/`sigma')<`small', /*
			 */ `z', /*
			 */ cond(abs(`gamma')<`small', /*
			 */ invnorm( `q'+(1-`q')* /*
			 */ normprob(-`mu'/`sigma') ), /*
			 */ invnorm( `q'+(1-`q')* /*
			 */ normprob(log(1-`mu'*`gamma'/`sigma')/`gamma')) ))
		}
		gen `c'=cond(abs(`gamma')<`small', /*
		 */ `mu'+`sigma'*`uq', /*
		 */ `mu'+(exp(`gamma'*`uq')-1)*`sigma'/`gamma' )
	}
	else if `dnum'==2 {			/* PN */
		if `trunc' {
			gen `A' = cond(`gamma'<`small', /*
			 */ 0, normprob(-`mu'/(`sigma'*`gamma')) )
			gen `B' = cond(`gamma'<-`small', /*
			 */ normprob(-`mu'/(`sigma'*`gamma')), 1)
			gen `uq' = invnorm(`q'*`B'+(1-`q')*`A')
		}
		gen `c'=cond(abs(`gamma')<`small', /*
		 */ `mu'*exp(`sigma'*`uq'/`mu'), /*
		 */ `mu'*(1+`gamma'*`sigma'*`uq'/`mu')^(1/`gamma') )
	}
	else if `dnum'==3 {			/* EN */
		if `trunc' {
			gen `A' = cond(`gamma'<`small', /*
			 */ 0, normprob(-1/`gamma') )
			gen `B' = cond(`gamma'<-`small', /*
			 */ normprob(-1/`gamma'), 1 )
			gen `uq' = invnorm(`q'*`B'+(1-`q')*`A')
		}
		gen `c'=cond(abs(`gamma')<`small', /*
		 */ `mu'+`sigma'*`uq', /*
		 */ `mu'+`sigma'*log(1+`gamma'*`uq')/`gamma' )
	}
	else if `dnum'==4 {			/* EG */
		gen double `A'=(`gamma')^(-2) 	/* theta = kappa^-2 */
		gen `B'=cond(`gamma'<0, invgammap(`A',1-`q'), invgammap(`A',`q'))
		gen `c'=cond(abs(`gamma')<0.01, /*
		 */ `mu'+`sigma'*`uq', /*
		 */ `mu'+`sigma'*(ln(`B'/`A')/`gamma'))
	}
	else if `dnum'==5 {			/* EP */
		tempvar G
		gen `G' = `gamma'*`sigma'/`mu' /* back to gamma param. */
		if `trunc' {
			_eetrunc `G' `delta' `A' `B'
			_epccalc `mu' `sigma' `gamma' `delta' `q' `A' `B' `c'
		}
		else {
			_epccalc `mu' `sigma' `gamma' `delta' `q' 0 1 `c'
		}
	}
	else if `dnum'==6 {			/* EE */
		tempvar D
		gen `D' = `delta'-`gamma'	/* delta, from eta */
		if `trunc' {
			_eetrunc `gamma' `D' `A' `B'
			_eeccalc `mu' `sigma' `gamma' `D' `q' `A' `B' `c'
		}
		else {
			_eeccalc `mu' `sigma' `gamma' `D' `q' 0 1 `c'
		}
	}
	else if `dnum'==7 {			/* MPN */
		if `trunc' {
			tempvar eps
			gen `eps' = -`mu'/(`sigma'*`gamma')
			nmod `eps' `delta'
			gen `A' = cond(`gamma'<`small', 0, `eps')
			gen `B' = cond(`gamma'<-`small', `eps', 1)
			_mpccalc `mu' `sigma' `gamma' `delta' `q' `A' `B' `c'
		}
		else {
			_mpccalc `mu' `sigma' `gamma' `delta' `q' 0 1 `c'
		}
	}
	else if `dnum'==8 {			/* MEN */
		if `trunc' {
			gen `A' = cond(`gamma'<`small', -99, -1/`gamma')
			gen `B' = cond(`gamma'<-`small', -1/`gamma', 99)
			nmod `A' `delta'
			nmod `B' `delta'
			_meccalc `mu' `sigma' `gamma' `delta' `q' `A' `B' `c'
		}
		else {
			_meccalc `mu' `sigma' `gamma' `delta' `q' 0 1 `c'
		}
	}
	sret local cname `c'
end

program define nmod /* normprob of modulus function */
	replace `1'= normprob(sign(`1')*((abs(`1')+1)^`2'-1)/`2')
end
*! v 1.0.0 PR 12Sep95.
program define _meccalc /* calc centile for truncated EEN dist. */
	local mu `1'
	local sigma `2'
	local G `3'	/* gamma parameter---not lambda */
	local D `4'	/* delta power parameter */
	local q `5'	/* desired quantile, e.g. .95 */
	local A `6' 	/* existing, lower limit in prob scale */
	local B `7' 	/* existing, upper limit in prob scale */
	local c `8'	/* existing var to hold centile */
	tempname small
	scalar `small'=1e-6
	tempvar u zq
	gen `zq' = invnorm(`q'*`B'+(1-`q')*`A')
	gen `u' = sign(`zq')*cond(abs(`D')<`small', exp(abs(`zq'))-1, /*
	 */ (1+`D'*abs(`zq'))^(1/`D')-1 )
	gen `c'=`mu'+`sigma'*cond(abs(`G')<`small', `u', log(1+`G'*`u')/`G' )
end
*! v 1.0.0 PR 12Sep95.
program define _mpccalc /* calc centile for truncated MPN dist. */
	local mu `1'
	local sigma `2'	 /* scale, not CV */
	local lambda `3' /* called gamma elsewhere */
	local D `4'	 /* delta power parameter */
	local q `5'	 /* desired quantile(s), e.g. .95 */
	local A `6' 	 /* existing, lower limit in prob scale */
	local B `7' 	 /* existing, upper limit in prob scale */
	local c `8'	 /* existing var to hold centile */
	tempname small
	scalar `small'=1e-6
	tempvar u zq
	gen `zq' = invnorm(`q'*`B'+(1-`q')*`A')
	gen `u' = sign(`zq')*cond(abs(`D')<`small', exp(abs(`zq'))-1, /*
	 */ (1+`D'*abs(`zq'))^(1/`D')-1 )
	gen `c'=`mu'*cond(abs(`lambda')<`small', /*
	 */ exp(`sigma'*`u'/`mu'), /*
	 */ (1+`lambda'*`sigma'*`u'/`mu')^(1/`lambda') )
end
