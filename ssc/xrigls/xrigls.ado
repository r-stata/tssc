*! version 3.0.0 PR 01aug2007
program define xrigls, rclass
version 10
syntax varlist(min=2 max=2) [if] [in] [, ALpha(real 0.05) /*
 */ COVArs(string) CEntile(numlist >0 <100) CYcles(int 2) CV DETail /*
 */ FP(str) noGRaph noLEAve noTIdy PARam(str) POwers(numlist) ROpts(str) /*
 */ SAVing(string asis) SE noSELect ]
if "`covars'"!="" local graph nograph
local small 1e-6
if "`select'"=="noselect" local omit "noomit"
local dist bc
local dupper "N "
if "`centile'"=="" local centile "3 97"
tokenize "`centile'"
local i 0
while "`1'"!="" {
	local nc=`nc'+1
	local cent`nc' `1'
	mac shift
}
local ginit 1 /* i.e. normal distribution */
if "`powers'"!="" local powers "powers(`powers')"
if "`param'"!="" {
	parse "`param'", parse(" ")
	while "`1'"!="" {
		local fl=lower(substr("`1'",1,2))
		if "`fl'"=="cv" 	local cv "cv"
		else if "`fl'"=="ln" 	local lns "lns"
		else {
			di as err "invalid param() option `1'"
			exit 198
		}
		mac shift
	}
}
if "`cv'"!="" local cv "cv"
if "`cv'"!="" local slab "CV"
else local slab "SD"
/*
	Extract regression options
*/
_jprxrpa "`ropts'" ms "regression options"
local ncl `r(nclust)'
local i 1
while `i'<=`ncl' {
	local param `r(p`i')'
	local `param'opt `r(c`i')'
	local i = `i'+1
}
/*
	Extract base variables for each parameter
*/
_jprxrpa "`covars'" ms "covariates"
local ncl `r(nclust)'
local i 1
while `i'<=`ncl' {
	local param `r(p`i')'
	local `param'base `r(c`i')'
	local i = `i'+1
}
/*
	Most of the next 5 stmts are probably unnecessary
*/
global S_trunc = "`trunc'"!=""
global S_cv = "`cv'"!=""
global S_tau = "`tau'"!=""
global S_lns = "`lns'"!=""
global S_gamma `ginit'

gettoken lhs rhs: varlist
local rhs=trim("`rhs'")
tempvar y
marksample touse
markout `touse' `lhs' `rhs' `mbase' `sbase'
/*
	Extract details of FP model
*/
_jprxrpa "`fp'" ms "FP model terms"
local ncl `r(nclust)' /* could be 0 */
local i 1
while `i'<=`ncl' {
	local curve`i' `r(p`i')'
	local spec`i' `r(c`i')'
	local i=`i'+1
}
local i 1
while `i'<=`ncl' {
	local curve `curve`i''
	local spec `spec`i''
	tokenize `spec'
	local first = lower("`1'")
	if "`first'"=="fix" {
		if "`curve'"=="m" | "`curve'"=="s" {
			di as err "invalid `spec'"
			exit 198
		}
		local `curve'fix "`curve'fix"
	}
	else if "`first'"=="df" {
		mac shift
		confirm num `*'
		if `1'<0 {
			di as err "invalid df"
			exit 198
		}
		local `curve'df `1'
	}
	else {
		if "`first'"=="powers" mac shift
		qui fracgen `rhs' `*' if `touse', name(X`curve') replace
		local `curve'vars `r(names)'
		local `curve'fixpow `*'
	}
	local i = `i'+1
}
/*
	Deal with df
*/
local c1 m
local c2 s
local i 1
while `i'<=2 {
	local curve `c`i''
	if "``curve'fixpow'"!="" {
		if "``curve'df'"!="" {
			di as err "invalid df" /* 'cos have fixpowers */
			exit 198
		}
		local `curve'pow ``curve'fixpow'
		local `curve'df -1	/* means have fixpowers */
	}
	else if "``curve'df'"=="" {
		if "`curve'"=="m" {
			local mdf 4	/* default for M */
		}
		else	local sdf 2	/* default for S */
	}
	local `curve'powS = 2+2*``curve'df' /* pos'n of powers in S_ */
	local i = `i'+1
}
quietly {
/*
	Calc y-fit, then sd from regression on abs residuals,
	then refit both using weights based on fitted sd.
*/
	local exp
/*
	!! [Boxcox option deleted]
	If Boxcox transformation is requested,
	find the geometric mean of y and transform y to standardized form.
*/
	gen `y' = `lhs' if `touse'

* ----------------------------------------------------------------------
/*
	Initialisation (cycle 0, if iteration required)
*/
	tempvar M S wt
	tempvar mse sse
	gen `wt' = 1 if `touse'
	local exp "[aweight=`wt']"
	if "`cv'"!="" local expy "[aweight=`wt'*`M'^-2]"
	else		local expy `exp'
	if "`mfixpow'"!="" | `mdf'==0 {
		regress `y' `mvars' `mbase', `mopt'
	}
	else {
		if "`mbase'"!="" local base "base(`mbase')"
		else local base
		frachoos regress `y' `rhs', `base' `powers' `omit' /*
		 */ `scaling' alpha(`alpha') `mopt' name(Xm) df(`mdf')  
		local mpow `r(pwrs)'
		local mvars `r(n)'
		regress `y' `mvars' `mbase', `mopt'
	}
	if e(df_r)<1 error 2001 /* need at least 1 residual df */
	local obs = e(N)
	local ssr = e(rss)
	local rmse = e(rmse)
	_devian `wt' `obs' `ssr' 1
	local dev=r(dev)
	local devold `dev'
	predict `M' if `touse'
	if "`se'"!="" predict `mse' if `touse', stdp
	if `sdf'==0 & "`cv'`sbase'"=="" {
		local spow " "
		gen `S' = `rmse'
	}
	else {
		local spowold " "
		tempvar absres
		if "`lns'"=="" {
			local f=sqrt(_pi/2)
			if "`cv'"=="" {
				gen `absres' = `f'*abs(`y'-`M')
			}
			else gen `absres' = `f'*abs(`y'/`M'-1)
		}
		else {
			local f 0.63518142
			if "`cv'"=="" {
				gen `absres' = `f'+ln(abs(`y'-`M'))
			}
			else gen `absres' = `f'+ln(abs(`y'/`M'-1))
		}
		if "`sfixpow'"!="" | `sdf'==0 {
			regress `absres' `svars' `sbase', `sopt'
		}
		else {
			if "`sbase'"!="" local base "base(`sbase')"
			else local base
			frachoos regress `absres' `rhs', `base' `omit' /*
			 */ `powers' `scaling' alpha(`alpha') /*
			 */ `sopt' name(Xs) df(`sdf') 
			local spow $S_4
			local svars $S_5
			regress `absres' `svars' `sbase', `sopt'
		}
		predict `S' if `touse'
		if "`se'"!="" predict `sse' if `touse', stdp
		if "`lns'"!="" replace `S'=exp(`S')
		replace `wt' = `S'^-2 if `touse'
	}
/*
	End of `sdf'==0 conditional
*/
	noi di _n as txt _col(11) "--- FP Powers ---" _n /*
	 */ "Cycle" _col(11) "Mean" _col(22) "`slab'" /*
	 */ _col(33) " Deviance" _col(44) "   Change" /*
	 */ _col(55) "Residual SS" _n _dup(65) "-"

        noi di as res 0 _col(11) as res "`mpow'" /*
	 */ _col(22) "`spowold'" _col(33) as res %9.3f `dev' /*
	 */ _col(44) as res %9.3f 0 _col(55) as res %9.0g `ssr'
	if !(`sdf'==0 & "`cv'`sbase'"=="") {
/*
	Cycle between mean fit and SD fit
*/
		local it 1
		while `it'<=`cycles' {
			local lastit = (`it'==`cycles')
/*
	Weighted fit for mean
*/
			if "`mfixpow'"!="" | `mdf'==0 {
				regress `y' `mvars' `mbase' `expy', `mopt'
			}
			else {
				if "`mbase'"!="" local base "base(`mbase')"
				else local base
				frachoos regress `y' `rhs' `expy', `omit' /*
				 */ `base' `powers' `scaling' /*
				 */ alpha(`alpha') `mopt' name(Xm) df(`mdf')
				local mpow `r(pwrs)'
				local mvars `r(n)'
				regress `y' `mvars' `mbase' `expy', `mopt'
			}
			local ssr = e(rss)
			local rmse = e(rmse)
			drop `M'
			cap drop `mse'
			predict `M' if `touse'
			if "`se'"!="" predict `mse' if `touse', stdp
			if "`cv'"!="" local mf `M'
			else		local mf 1
			_devian `wt' `obs' `ssr' `mf'
			local dev=r(dev)
			local spowold `spow'
			if !`lastit' {
/* ************************************************************************

	Weighted fit for SD

	Note use of `exp' (i.e. weight = `wt') in following regression,
	to allow for the variance of the absolute residuals
	(see Carroll and Ruppert p 80, expression (3.20).
*/
	if "`lns'"=="" {
		if "`cv'"=="" {
			replace `absres' = `f'*abs(`y'-`M')
		}
		else replace `absres' = `f'*abs(`y'/`M'-1)
	}
	else {
		if "`cv'"=="" {
			replace `absres' = `f'+ln(abs(`y'-`M'))
		}
		else replace `absres' = `f'+ln(abs(`y'/`M'-1))
	}
	if "`sfixpow'"!="" | `sdf'==0 {
		regress `absres' `svars' `sbase' `e', `sopt'
	}
	else {
		if "`sbase'"!="" local base "base(`sbase')"
		else local base
		frachoos regress `absres' `rhs' `e', `omit' /*
		 */ `base' `powers' `scaling' /*
		 */ alpha(`alpha') `mopt' name(Xs) df(`sdf')
		local spow `r(pwrs)'
		local svars `r(n)'
		regress `absres' `svars' `sbase' `e', `sopt'
	}
	drop `S' 
	cap drop `sse'
	predict `S' if `touse'
	if "`se'"!="" predict `sse' if `touse', stdp
	if "`lns'"!="" replace `S'=exp(`S')
	sum `S'
	if r(min)<=0 {
		noi di as err "negative fitted standard deviation"
		exit 2002
	}
	replace `wt' = `S'^-2 if `touse'
************************************************************************
			}
			noi di as res `it' _col(11) "`mpow'" /*
			 */ _col(22) "`spowold'" _col(33) %9.3f `dev' /*
			 */ _col(44) as res %9.3f `dev'-`devold' /*
			 */ _col(55) as res %9.0g `ssr'
			local devold `dev'
			local it=`it'+1
		} /* end of cycling loop */
*-----------------------------------------------------------------------------
	}
/*
	Standardized residuals (Z-scores)
*/
	tempvar Z
	if "`cv'"=="" {
		gen `Z' = (`y'-`M')/`S' if `touse'
	}
	else	gen `Z' = (`y'/`M'-1)/`S' if `touse'
/*
	Reference interval
*/
	centcalc `M' `S', centile(`centile') prefix(C) /*
	 */ dist(`dist') gamma(1) `cv'
/*
	Extract names of centile variables
*/
	local C
	local i 0
	while `i'<`nc' {
		local i=`i'+1
		local C`i' `s(cvar`i')'
		local C `C' `C`i''
		mac shift
	}
}
/*
	SEs of centile values.
*/
quietly {
	count if `touse'
	local nobs=r(N)
	if "`se'"!="" {
		local i 0
		while `i'<`nc' {
		    local i=`i'+1
		    tempvar c`i'se 
		    local z=invnorm(`cent`i''/100)
		    gen `c`i'se'=sqrt(`mse'^2 + (`z'*`sse')^2)
    	    	    if `sdf'==0 {
			replace `sse'=`S'/sqrt(2*(`nobs'-1))
		        replace `c`i'se'=sqrt(`mse'^2 + (`z'*`sse')^2)
		    }
		    if "`cv'"!="" {
	 	    	if `sdf'==0 {
			   replace `sse'=sqrt(`S'^2/(2*(`nobs'-1)*`M'^2) /*
			    */ +(`mse'*`S'/`M'^2)^2)
			}
 			replace `c`i'se'=sqrt( (`z'*`M'*`sse')^2 /*
			 */ +((1+(`z'*`S'))*`mse')^2 +(`z'*`mse'*`sse')^2)
		    }
		}
	}
}
/*
	Graph
*/
if "`graph'"!="nograph" {
	if `"`saving'"'!="" local saving `"saving(`saving')"'
	if "`mbase'`sbase'`gbase'`dbase'"!="" local cs "s(.pppppppp)"
	else local cs "c(.ssssssss) s(oiiiiiiii)"
	local title "Normal model, `centile' centiles"
	graph7 `y' `M' `C' `rhs', title("`title'") /*
	 */ l1("`lhs'") b2("`rhs'") xlab ylab `cs' sort `saving'
}
/*
	Save variables if required
*/
/* need to save weights first */
tempvar wts
if "`cv'"!="" qui gen `wts'=`wt'*`M'^-2
else qui gen `wts'=`wt'
if "`leave'"!="noleave" {

	local prog "_gls"

	local vn Z`prog'
	cap drop `vn'
	rename `Z' `vn'
	lab var `vn' "`dupper' Z-scores"

	if "`cv'"!="" local cvl "CV"
	else		local cvl "SD"
	if "`lns'"!="" {
		qui replace `S' = ln(`S')
		local lnsl "log "
	}

	local a1 m
	local a2 s

	local b1 "mean"
	local b2 "`lnsl'`cvl'"

	local i 1
	local p 2
	while `i'<=`p' {
		local a `a`i''
		local A = upper("`a'")
		local b `b`i''
		local vn `A'`prog'
		cap drop `vn'
		rename ``A'' `vn'

		if ``a'df'==0	local add "constant"
		else	 	local add "powers ``a'pow'"
		lab var `vn' "`dupper' `b': `add'"
		local i = `i'+1
	}
	local i 0
	while `i'<`nc' {
		local i=`i'+1
		local cent `cent`i''
		local vn=substr("`C`i''`prog'",1,8)
		cap drop `vn'
		rename `C`i'' `vn'
		lab var `vn' "`dupper' `cent' centile"
		if "`se'"!="" {
			local vn=substr("se`vn'",1,8)
			cap drop `vn'
			rename `c`i'se' `vn'
			lab var `vn' "`dupper' se[`cent' centile]"
		}
	}
}
else {
	local i 0
	while `i'<`nc' {
		local i=`i'+1
		cap drop `C`i''
	}
}

di as txt _n "Final deviance = " %9.3f as res `dev' /*
 */ as txt " (" as res `obs' as txt " observations)."
di as txt "Power(s) for mean curve = " as res "`mpow'" as txt "." _cont
if trim("`spow'")!="" {
	di as txt " Power(s) for " "`slab'" " curve = " as res "`spow'" as txt "." _cont
}
di
if "`detail'"!="" {
    if trim("`mpow'")!="" {
    	di as txt _n "Regression for mean curve" _n _dup(25) "-"
	regress `y' `mvars' `mbase' [aweight=`wts'], `mopt' depname(`lhs')
        describe `mvars'
    }
    if trim("`spow'")!="" {
	di as txt _n "Regression for " "`slab'" " curve" _n _dup(23) "-"
	regress `absres' `svars' `sbase' `e', `sopt' depname(`lhs')
        describe `svars'
    }
}
if "`tidy'"!="notidy" {
	if "`mvars'"!="" & "`mvars'"!="`rhs'" drop `mvars'
	if "`svars'"!="" & "`svars'"!="`rhs'" drop `svars'
}
return scalar dev=`dev'
return local mpow `mpow'
return local spow `spow'
global S_1 `dev'	/* double save */
global S_2 `mpow'	/* double save */
global S_3 `spow'	/* double save */
end

program define _devian, rclass /* deviance for xrigls */
	args wt obs ssr M
/*
	Mean log normalized weights - use means.ado
	Note: local mnlnwt = log (geom mean/arith mean)
*/
	tempvar w
	qui gen `w'=`wt'*`M'^-2
	means `w'
	ret scalar dev = /*
	 */ `obs'*(1+log(2*_pi*`ssr'/`obs')-log(r(mean_g)/r(mean)))
end

program define frachoos, rclass
local cmd `1'
mac shift
local varlist "req ex min(2)"
local if "opt"
local in "opt"
local weight "fweight aweight"
#delimit ;
local options "ALpha(real .05) noOMit noHEad DF(int 0) BAse(string)
 Name(string) POwers(string) SCAling noTIDy *" ;
#delimit cr
parse "`*'"
if `df'<0 {
	di as err "invalid df"
	exit 198
}
if `df'==0 local df 4
if `df'==1 {					/* linear */
	if "`powers'"!="" {
		di as err "powers() invalid with df(1)"
		exit 198
	}
}
else {
	if "`powers'"=="" local powers "-2,-1,-.5,0,.5,1,2,3"
	local powers "powers(`powers')"
	local degree=int(`df'/2+.5)
	local deg "degree(`degree')"
}
if "`name'"!="" local name "name(`name')"
if "`weight'"!="" { 
	local weight "[`weight'`exp']"
}
parse "`varlist'", parse(" ")
local lhs `1'
mac shift
local rhs
if "`head'"=="" {
	di as txt "Variable" _col(11) "df" _col(21) "Deviance" /*
	 */ _col(33) "Deviance" _col(47) "P" /*
	 */ _col(55) "Final"
	di as txt _col(32) "difference" _col(55) "Powers     df"
	di as txt _dup(67) "-" _cont
}
local i 1
while "``i''"!="" { 
	local n ``i''
	qui fracpoly `cmd' `lhs' `n' `base' `if' `in' /*
	 */ `weight', compare sequential `deg' `powers' `options'
	if "`n'"!="`e(fp_xp)'" drop `e(fp_xp)'
	local devdeg=e(fp_d`degree')
	local vname "``i''"
	local degx `degree'
	local done 0
	while `degx'>0 & !`done' {
		local degx1 `degx'
		local degx=`degx'-1
		local df=2*`degx1'
		if `degx'==0 {
			local dev=e(fp_dlin)
		}
		else {
			local dev=e(fp_d`degx')
		}
		local d=`dev'-`devdeg'
		local P ${S_E_P`degx1'}	/* !! not yet dup by e(fp_) funs */
		local pwrs `e(fp_p`degx1')'
		di _n as txt "`vname'" as res _col(12) `df' /*
		 */ _col(20) %9.3f `devdeg' /*
		 */ _col(32) %9.3f `d' /*
		 */ _col(44) %6.3f `P' _col(55) "`pwrs'" _col(67) _cont
		local vname
		if `P'<`alpha' | "`omit'"!="" {
			local done 1
			local dev `devdeg'
			qui fracgen `n' `pwrs', replace `scaling' `name'
			local n `r(names)'
		}
		local devdeg `dev'
	}
/*
	Deal with linear.
*/
	if !`done' {
		local devdeg=e(fp_dlin)
		local P $S_E_Plin	/* !! not yet dup by e(fp_) funs */
		local d=e(fp_d0)-`devdeg'
		local df 1
		local pwrs 1
		di _n as txt "`vname'" as res _col(12) `df' /*
		 */ _col(20) %9.3f `devdeg' /*
		 */ _col(32) %9.3f `d' /*
		 */ _col(44) %6.3f `P' _col(55) "`pwrs'" _col(67) _cont
		if "`omit'"=="" & `P'>`alpha' {
/*
	`Dropping' RHS variable since 1 df test of beta=0 is non-sig.
*/
			local done 1
			local dev=e(fp_d0)
			local df 0
			local pwrs
			local n
		}
		if !`done' {
			local dev `devdeg'
		}
	}
	di `df'
	local rhs "`rhs' `n'"
	local i = `i'+1
}
di as txt _dup(67) "-"
ret local rhs `rhs'
ret scalar df=`df'
ret scalar dev=`dev'
ret local pwrs `pwrs'
ret local n `n'
global S_1 `rhs'
global S_2 `df'
global S_3 `dev'
global S_4 `pwrs'
global S_5 `n'
end

program define _jprxrpa, rclass /* parses "clusters" */
args stuff prefixs items
* stuff   = string to be parsed
* prefixs = string of permitted one-character prefixes
* items   = items in error message if #clusters > #prefixes

local nprefix=length("`prefixs'")
local i 1
while `i'<=`nprefix' {
	local p`i'=substr("`prefixs'",`i',1)
	global S_p`i'
	global S_c`i'
	local i=`i'+1
}
tokenize "`stuff'", parse(",")
local nclust 0		/* # of comma-delimited clusters */
while "`1'"!="" {
	if "`1'"=="," mac shift
	local nclust = `nclust'+1
	local clust`nclust' "`1'"
	mac shift
}
if "`clust`nclust''"=="" local nclust=`nclust'-1
if `nclust'>`nprefix' {
	noi di as err "too many `items' specified"
	exit 198
}
/*
	Disentangle each prefix:string cluster
*/
local i 1
while `i'<=`nclust' {
	tokenize "`clust`i''", parse("=:")
	local prefix = lower(substr("`1'",1,1))
	local j 1
	local found 0
	while (`j'<=`nprefix') & !`found' {
		if "`prefix'"=="`p`j''" {
			return local p`i' `prefix'
			return local c`i' "`3'"
			local found 1
		}
		local j=`j'+1
	}
	if !`found' {
		noi di as err "invalid `clust`i''"
		exit 198
	}
	local i = `i'+1
}
return local nclust `nclust'
end
