*! version 1.5.3 PR 12jun2007
program define stpm_p
* 1.5.3 / 12jun2007: fix bug in deviance and martingale residuals
* 1.5.2 / 11jan2007: add deviance and martingale residual options
* 1.5.1 / 02oct2006: add store() option to save values of output variable to global macro
*				   : add failure option for cumulative incidence (1 - survival)
* 1.5.0 / 20apr2006: implements SE(survival function) via stdp option
* 1.4.6 / 02feb2006: convert se(centile to log time) to se(centile of time)
* 1.4.5 / 07jul2005: allow centile() option to specify a number or a variable
*		     (when a variable, useful for simulation of data from
*		     distribution implied by spline model)
* 1.4.4 / 18feb2005: allow for offset near line 252
* 1.4.3 / 02aug2004: add +# offset facility to at() option
* 1.4.2 / 18feb2004: add stdp option for dzdy and log hazard
* 1.4.1 / 14jan2004: fix bug in nooffset option
version 8.1
/*
if e(nomodel)==1 {
	di in red "prediction not available, no parameters were estimated"
	exit 198
}
*/
gettoken varn 0 : 0, parse(" ,[")
gettoken nxt : 0, parse(" ,[(")
if !(`"`nxt'"'=="" | `"`nxt'"'=="if" | `"`nxt'"'=="in" | `"`nxt'"'==",") {
	local typ `varn'
	gettoken varn 0 : 0, parse(" ,[")
}
confirm new var `varn'
syntax [if] [in] [, At(string) CUMHazard CUMOdds Density DEViance Hazard MArtingale ///
 Normal Failure Survival Time(string) XB STDP CEntile(string) DZdy Zero TOL(real .001) ///
 SPline TVc(varname) noCONStant noOFFset STore(string) ]

if "`deviance'`martingale'"!="" {
	if "`deviance'"!="" & "`martingale'"!="" {
		di as err "cannot specify both deviance and martingale"
		exit 198
	}
	tempvar lnH mgale
	predict `typ' `lnH' `if' `in', cumhaz
	gen `typ' `mgale' = _d-exp(`lnH')
	if "`deviance'"!="" {
		gen `typ' `varn' = sign(`mgale')*sqrt( -2*(`mgale' + (_d!=0)*(ln((_d!=0)-`mgale'))))
	}
	else rename `mgale' `varn'
	lab var `varn' "`deviance'`martingale' residuals"
	exit
}
if "`store'"!="" {
	tokenize `store'
	if "`3'"!="" {
		di as err "`store' invalid"
		exit 198
	}
	if "`2'"!="" confirm integer number `2'
}
* Failure signifies cumulative incidence = 1 - survival; local flag `failure' = 0 or 1.
if "`failure'`survival'"!="" {
	if "`failure'"!="" {
		local failure 1
		local survival survival
	}
	else local failure 0
}
if "`centile'"!="" {
	* `centile' may be a number or an existing variable
	local type centile
	cap confirm var `centile'
	local rc=_rc
	if `rc'==0 {
		local centtype var
	}
	else {
		local centtype num
		cap confirm number `centile'
		if _rc {
			di as err "`centile' is neither a number nor a variable"
			exit 198
		}
	}
}
else if "`tvc'"!="" {
	local type tvc
}
else local type "`cumhazard'`cumodds'`density'`hazard'`normal'`survival'`spline'`dzdy'`xb'"
local theta=e(theta)
local orthog `e(orthog)'
if "`orthog'"=="orthog" {
	local hasQ  q(e(Q))
}
if "`stdp'"!="" {
	if "`type'"=="density" {
		di in red "standard errors not available for `type'"
		exit 198
	}
	if "`type'"=="hazard" & e(scale)!=0 {
		di in red "standard errors of log hazard function available only for models with scale(hazard)"
		exit 198
	}
	tempvar se
}
if "`type'"==""  {
	di in gr "(option xb assumed)"
	local type xb
}
/*
if "`type'"=="xb" & "`time'"!="" {
	di in red "time() inapplicable"
	exit 198
}
*/
if "`type'"=="tvc" {
	if "`at'"!="" {
		di in red "at() inapplicable with tvc()"
		exit 198
	}
	cap local btvc=[xb]_b[`tvc']
	if _rc {
		di in red "`tvc' not in time-fixed part of model"
		exit 198
	}
}
if "`time'"=="" {
	local time _t
}
else {
	cap confirm var `time'
	if _rc {
		cap confirm num `time'
		if _rc {
			di in red "invalid time()"
			exit 198
		}
	}
}
local df=e(df)
if `df'>1 {
	local bknots `e(bknots)'
	local k0: word 1 of `bknots'
	local kN: word 2 of `bknots'
	local knots `e(knots)'
}
local cscale `e(cscale)'
if e(scale)==0 {
	local scale h
}
else if e(scale)==1 {
	local scale n
}
else if e(scale)==2 {
	local scale o
}
tempvar XB
tempname coef b tmp
matrix `coef'=e(b)				/* entire coefficient matrix */
capture matrix `b'=`coef'[1,"xb:"]			/* eqn for covariates */
if _rc==0 {
	local xvars `e(fvl)'				/* names of covariates */
	local nx=colsof(`b')				/* no. of covariates inc. cons */
	local eqxb "equation(xb)"
}
else {
	local nx 0
}
local nat 0
local plus	/* plus adds a constant to the linear predictor */
if "`at'"!="" {
	tokenize `at'
	if substr("`1'",1,1)=="+" {
		local plus=substr("`1'",2,.)	/* Offsets the subsequent value */
		confirm number `plus'
	}
	else if substr("`1'",1,1)=="@" {
		local vn=substr("`1'",2,.)
		confirm var `vn'
		local vns: type `vn'
		local vns=substr("`vns'",1,3)=="str"	/* vn is string variable */
		mac shift
		local vnval `1'
		local at
		local j 1
		while `j'<`nx' {
			local nat=`nat'+1
			local covar: word `j' of `xvars'
			local atvar`nat' `covar'
			if `vns' {
				qui sum `covar' if `vn'=="`vnval'", meanonly
			}
			else qui sum `covar' if `vn'==`vnval', meanonly
			local atval`nat'=r(mean)
			local at `at' `atvar`nat'' `atval`nat''
			local j=`j'+1
		}
	}
	else {
		while "`1'"!="" {
			unab 1: `1'
			cap confirm var `2'
			if _rc {
				cap confirm num `2'
				if _rc {
					di in red "invalid at(... `1' `2' ...)"
					exit 198
				}
			}
			local nat=`nat'+1
			local atvar`nat' `1'
			local atval`nat' `2'
			mac shift 2
		}
	}
}
if `nat'==0 {
	* at() might contain +.. only.
	local at
}
quietly if "`type'"=="centile" {
	tempvar esample t0 s0 d0 maxerr
	if "`centtype'"=="num" {
		tempname gp p
		local gen scalar
	}
	else {
		tempvar gp p
		local gen gen double
	}
	`gen' `p'=1-`centile'/100	/* point in distribution fn not survival fn */
	if e(scale)==0 {
		`gen' `gp'=ln(-ln(`p'))
	}
	else if e(scale)==1 {
		`gen' `gp'=-invnorm(`p')
	}
	else if e(scale)==2 {
		`gen' `gp'=ln(1/`p'-1)
	}
	local left `e(left)'
	if "`left'"!="" {
		local left left(`left')
	}
	if "`at'"!="" {
		local AT at(`at')
	}
	gen byte `esample'=1 if e(sample)
	* Save model estimates
	_estimates hold `tmp'
	stpm `xvars' if `esample', df(1) scale(`scale') `left' index(2) theta(`theta')
	* Linear predictor on transformed cum distribution scale
	predict double `XB' `if' `in', `AT' `zero'
	* Find `t0' = first guess at t for given centile
	_predict double `s0' `if' `in', equation(s0)
	gen double `t0'=exp((`gp'-`XB')/`s0')
	drop `XB' `s0' `esample' `e(sbasis)'
	* Restore model
	_estimates unhold `tmp'
	* Predict fitted spline `s0' and first derivative `d0' at guess `t0'
	predict double `s0' `if' `in', time(`t0') `AT' `zero' `cscale'
	predict double `d0' `if' `in', time(`t0') `AT' `zero' dzdy
	* Iterate to solution
	local done 0
	while !`done' {
		* Update estimate of time
		replace `t0'=exp(ln(`t0')-(`s0'-`gp')/`d0')
		* Update estimate of transformed centile and check prediction
		drop `s0' `d0'
		predict `s0' `if' `in', time(`t0') `AT' `zero' `cscale'
		* Max absolute error
		gen double `maxerr'=abs(`s0'-`gp')
		sum `maxerr'
		if r(max)<`tol' {
			local done 1
		}
		else {
			predict double `d0' `if' `in', time(`t0') `AT' `zero' dzdy
		}
		drop `maxerr'
	}
	if "`stdp'"=="" {
		gen `typ' `varn'=`t0'
		if "`centtype'"=="num" label var `varn' "survival time: `centile'th centile"
		else label var `varn' "survival time: centiles from `centile'"
	}
	else {
/*
	Unfortunately, need time (t0) to compute standard error.
	Results in wasted computation of t0 but can't be avoided
	with "predict <>, stdp" design.
*/
		predict double `d0' `if' `in', time(`t0') `AT' `zero' dzdy
		tempvar lnt0
		gen double `lnt0'=ln(`t0')
		if `df'>1 {
			cap drop I__d0*
			frac_spl `lnt0' `knots', `orthog' name(I__d0) deg(3) bknots(`k0' `kN') `hasQ'
			local v `r(names)'
		}
		else local v `lnt0'
		Gense `se' "`v'" "`zero'" "`at'" `"`if'"' `"`in'"'
		* The SE just found is for log time. Multiply by `t0' to convert to SE of time centile.
		gen `typ' `varn'=`t0'*`se'/abs(`d0')
		if "`centtype'"=="num" label var `varn' "survival time: S.E. of `centile'th centile"
		else label var `varn' "survival time: S.E. of centiles from `centile'"
		drop `v'
	}
	Store `varn' `store'
	exit
}
/*
	Compute index. First check if model has a constant.
*/
tempname cons
cap scalar `cons'=`b'[1,`nx']
if _rc!=0 {
	local hascons 0
	scalar `cons'=0
}
else local hascons 1
if "`at'`zero'"=="" {
	if "`e(offset)'"!="" & "`offset'"=="nooffset" {
		qui gen double `XB'=`cons' `if' `in'
	}
	else qui _predict double `XB' `if' `in', `eqxb' `offset'
}
else {
	qui gen double `XB'=`cons' `if' `in'	/* cons */
	if "`e(offset)'"!="" & "`offset'"!="nooffset" {
		qui replace `XB'=`XB'+`e(offset)'
	}
}
if `hascons' & "`constant'"=="noconstant" {
	qui replace `XB'=`XB'-`cons'
}
if "`plus'"!="" {
	qui replace `XB'=`XB'+`plus'
}
if "`at'`zero'"!="" {
/*
	Calc linear predictor allowing for at and zero.
	Note inefficiency (for clarity) if zero!="" and at=="" ,
	since then XB is not altered but j loops anyway.
*/
	local j 1
	while `j'<`nx' {		/* nx could be 0, then no looping */
		local changed 0
		local covar: word `j' of `xvars'
		local xval `covar'
		if "`at'"!="" {
			local k 1
			while `k'<=`nat' & !`changed' {
				if "`covar'"=="`atvar`k''" {
					local xval `atval`k''
					local changed 1
				}
				local k=`k'+1
			}
		}
		if `changed' | (!`changed' & "`zero'"=="") {
			qui replace `XB'=`XB'+`xval'*`b'[1,`j']
		}
		local j=`j'+1
	}
}
if "`type'"=="xb" {
	if "`stdp'"=="" {
		qui gen `typ' `varn'=`XB'
		label var `varn' "Linear prediction"
	}
	else {
		Gense `se' "" "`zero'" "`at'" `"`if'"' `"`in'"'
		qui gen `typ' `varn'=`se'
		label var `varn' "S.E. of linear predictor"
	}
	* eval at specified time point not required
	if "`time'"=="" {
		Store `varn' `store'
		exit
	}
}
/*
	Time-dependent quantities.
	Compute spline basis variable(s), names stored in `v'.
*/
tempvar lnt
tempname c
qui gen double `lnt'=ln(`time') `if' `in'
if `df'>1 {
	cap drop I__d0*
	tempname Q
	qui frac_spl `lnt' `knots', `orthog' name(I__d0) deg(3) bknots(`k0' `kN') `hasQ'
	local v `r(names)'
}
else	local v `lnt'
/*
	Index specified with time(`time'), evaluated at `time'
*/
if "`type'"=="xb" {
	if "`stdp'"!="" {
		di as err "stdp not available with xb and time()"
		exit 198
	}
	local j 1
	while `j'<`nx' {		/* nx could be 0, then no looping */
		local changed 0
		local covar: word `j' of `xvars'
		local xval `covar'
/*
	Check if `covar' has a time-varying coefficient
*/
		cap matrix `c' = `coef'[1,"s0:`covar'"]
		local hastvc = (_rc==0)
		if `hastvc' {
			if "`at'"!="" {
				local k 1
				while `k'<=`nat' & !`changed' {
					if "`covar'"=="`atvar`k''" {
						local xval `atval`k''
						local changed 1
					}
					local ++k
				}
			}
			if `changed' | (!`changed' & "`zero'"=="") {
				* add time-varying component for variable `covar' to xb
				local i 0
				while `i'<`df' {
					local i1 = `i'+1
					local svar: word `i1' of `v'
					matrix `c' = `coef'[1,"s`i':`covar'"]
					qui replace `varn' = `varn'+`c'[1,1]*`svar'*`xval'
					local i `i1'
				}
			}
		}
		local ++j
	}
	Store `varn' `store'
	exit
}
/*
	Time-varying coefficient or SE for variable `tvc'.
*/
if "`type'"=="tvc" {
	* check if `tvc' has a time-varying coefficient
	* (interaction with lnt, at least)
	cap matrix `c'=`coef'[1,"s0:`tvc'"]
	local hastvc=(_rc==0)
	if "`stdp'"=="" {
		* This could have been done in Genstvc via _predict.
		tempvar tmp
		qui gen double `tmp'=[xb]_b[`tvc'] `if' `in'
		if `hastvc' {
			local i 0
			while `i'<`df' {
				local i1=`i'+1
				local svar: word `i1' of `v'
				matrix `c'=`coef'[1,"s`i':`tvc'"]
				qui replace `tmp'=`tmp'+`c'[1,1]*`svar'
				local i `i1'
			}
		}
		gen `typ' `varn'=`tmp'
		lab var `varn' "TVC(`tvc')"
	}
	else {
		if `hastvc' {
			Genstvc `tvc' `se' "`v'" `"`if'"' `"`in'"'
			qui gen `typ' `varn'=`se'
		}
		else qui gen `typ' `varn'=[xb]_se[`tvc'] `if' `in'
		lab var `varn' "S.E. of TVC(`tvc')"
	}
	drop `v'
	Store `varn' `store'
	exit
}
/*
	Calc fitted spline, allowing for stratification.
	First, compute spline coefficients (names in string coefn).
*/
tempvar Zhat
local i 0
while `i'<`df' {
	matrix `c'=`coef'[1,"s`i':"]		/* eqn for spline coeff i, 0=lin */
	local cn: colnames(`c')
	local nc=colsof(`c')			/* 1 + # strat vars */
	tempvar coef`i'
	qui gen double `coef`i''=`c'[1,`nc']	/* baseline coefficient */
	local j 1
	while `j'<`nc' {
		local changed 0
		local cnj: word `j' of `cn'
		local xval `cnj'
		if "`at'"!="" {
			local k 1
			while `k'<=`nat' & !`changed' {
				if "`cnj'"=="`atvar`k''" {
					local xval `atval`k''
					local changed 1
				}
				local k=`k'+1
			}
		}
		if `changed' | (!`changed' & "`zero'"=="") {
			qui replace `coef`i''=`coef`i''+`c'[1,`j']*`xval'
		}
		local j=`j'+1
	}
	local i=`i'+1
}
if "`type'"=="cumhazard" | "`type'"=="cumodds" | "`type'"=="normal" | "`type'"=="spline" {
	if "`type'"=="spline" {
		local varnlab "spline function"
	}
	else if "`type'"=="cumhazard" {
		local varnlab "log cumulative hazard function"
	}
	else if "`type'"=="cumodds" {
		if `theta'==1 {
			local varnlab "log cumulative odds function"
		}
		else {
			local varnlab "transformed survival function (theta = `theta')"
		}
	}
	else if "`type'"=="normal" {
		local varnlab "Normal deviate function"
	}
	if "`stdp'"!="" {
		if "`type'"!="`cscale'" & "`type'"!="spline" {
			noi di in red "standard errors not available with this combination of options"
			exit 198
		}
		Gense `se' "`v'" "`zero'" "`at'" `"`if'"' `"`in'"'
		gen `typ' `varn'=`se'
		lab var `varn' "S.E. of `varnlab'"
		drop `v'
		Store `varn' `store'
		exit
	}
}
qui gen double `Zhat'=`XB' if `lnt'!=.
if `df'==0 {	/* df=0 if spline() has been used by stpm in estimating the model */
	qui replace `Zhat'=`Zhat'+`e(sbasis)'
}
else {
	local i 0
	while `i'<`df' {
		local i1=`i'+1
		local svar: word `i1' of `v'
		qui replace `Zhat'=`Zhat'+`coef`i''*`svar'
		local i `i1'
	}
}
if "`type'"=="cumhazard" | "`type'"=="cumodds" | "`type'"=="normal" | "`type'"=="spline" {
	if "`type'"=="spline" {
		local expr `Zhat'
	}
	else if "`type'"=="cumhazard" {
		if e(scale)==0 {
			local expr `Zhat'
		}
		else if e(scale)==1 {
			local expr ln(-ln(normprob(-`Zhat')))
		}
		else if e(scale)==2 {
			local expr -ln(`theta')+ln(ln(1+exp(`theta'*`Zhat')))
		}
	}
	else if "`type'"=="cumodds" {
		if e(scale)==0 {
			local expr ln(exp(exp(`Zhat'))-1)
		}
		else if e(scale)==1 {
			local expr ln(1/normprob(-`Zhat')-1)
		}
		else if e(scale)==2 {
			if `theta'==1 {
				local expr `Zhat'
			}
			else {
				local expr ln((1+exp(`theta'*`Zhat'))^(1/`theta')-1)
			}
		}
	}
	else if "`type'"=="normal" {
		if e(scale)==0 {
			local expr -invnorm(exp(-exp(`Zhat')))
		}
		else if e(scale)==1 {
			local expr `Zhat'
		}
		else if e(scale)==2 {
			if `theta'==1 {
				local expr -invnorm(1/(1+exp(`Zhat')))
			}
			else {
				local expr -invnorm((1+exp(`theta'*`Zhat'))^(-1/`theta'))
			}
		}
	}
	gen `typ' `varn'=(`expr')
	lab var `varn' "Predicted `varnlab'"
	drop `v'
	Store `varn' `store'
	exit
}
* Compute dZdy via first derivatives of basis functions
tempvar dZdy one
if `df'==0 {	/* df=0 if spline() has been used by stpm in estimating the model */
	qui gen double `dZdy'=`e(obasis)'
	qui gen double `one'=0
}
else {
	if `df'>1 {
		cap drop I__e0*
		frac_s3b `lnt', k(`knots') bknots(`k0' `kN') name(I__e0) `hasQ'
		local o `r(names)'
	}
	local i 0
	while `i'<`df' {
		if `i'==0 {
			qui gen double `dZdy'=`coef`i''
		}
		else {
			local ovar: word `i' of `o'
			qui replace `dZdy'=`dZdy'+`coef`i''*`ovar'
		}
		local i=`i'+1
	}
	* Needed for computations involving derivative of spline
	qui gen double `one'=`coef0'
}
if "`dzdy'"!="" {
	local varnlab "Spline first derivative"
	if "`stdp'"!="" {
		Gensdz `se' "`one' `o'" "`zero'" "`at'" `"`if'"' `"`in'"'
		gen `typ' `varn'=`se'
		lab var `varn' "S.E. of `varnlab'"
	}
	else {
		gen `typ' `varn'=`dZdy'
		lab var `varn' "`varnlab'"
	}
	if `df'>1 {
		drop `o'
	}
	Store `varn' `store'
	exit
}
if e(scale)==0 {
	local surv exp(-exp(`Zhat'))
	local haz `dZdy'*exp(`Zhat'-`lnt')
	local dens (`haz')*(`surv')
}
else if e(scale)==1 {
	local surv normprob(-`Zhat')
	local dens `dZdy'*normd(`Zhat')/`time'
	local haz (`dens')/(`surv')
}
else if e(scale)==2 {
	local surv (1+exp(`theta'*`Zhat'))^(-1/`theta')
	local dens `dZdy'*exp(`theta'*`Zhat'-`lnt')*(`surv')^(1+`theta')
	local haz (`dens')/(`surv')
}
if "`type'"=="hazard" {
	if "`stdp'"!="" {
		Genselnhaz `se' "`v'" "`one' `o'" `dZdy' "`zero'" "`at'" `"`if'"' `"`in'"'
		gen `typ' `varn'=`se'
		lab var `varn' "S.E. of log hazard function"
	}
	else {
		gen `typ' `varn'=(`haz')
		lab var `varn' "Predicted hazard function"
	}
}
else if "`type'"=="survival" {
	qui gen `typ' `varn'=(`surv')	// estimated survival function
	if "`stdp'"!="" {
		Gense `se' "`v'" "`zero'" "`at'" `"`if'"' `"`in'"'	// SE of Zhat
		* Apply delta method to get approximate SE of survival function
		if 	e(scale)==0	qui replace `varn'=`se'*`varn'*(-ln(`varn'))
		else if e(scale)==1	qui replace `varn'=`se'*normd(-`Zhat')
		else if e(scale)==2	qui replace `varn'=`se'*`varn'*(1-`varn')
		if `failure' lab var `varn' "S.E. of predicted cumulative incidence (failure) function"
		else lab var `varn' "S.E. of predicted survival function"
	}
	else {
		if `failure' {
			replace `varn' = 1-`varn'
			lab var `varn' "Predicted cumulative incidence (failure) function"
		}
		else lab var `varn' "Predicted survival function"
	}
	drop `v'
}
else if "`type'"=="density" {
	qui gen `typ' `varn'=(`dens')
	lab var `varn' "Predicted density function"
}
if `df'>1 {
	drop `o'
}
Store `varn' `store'
end

program define Store
* Store successive values of `1' = `varn' in global macro `2', if non-null.
* `3', if non-null, results are round to # decimal places.
* Slow and inefficient, but useful.
args varn store dp
if "`store'"=="" exit
global `store'
local n=_N
if "`dp'"=="" {
	forvalues i=1/`n' {
		if !missing(`varn'[`i']) {
			local v = `varn'[`i']
			global `store' $`store' `v'
		}
	}
}
else {
	forvalues i=1/`n' {
		if !missing(`varn'[`i']) {
			frac_ddp `varn'[`i'] `dp'
			global `store' $`store' `r(ddp)'
		}
	}
}
end

program define Gense
version 8.1
/*
	Collapse equations for predicting SE.
	If sbasis is null then calculations are for index, otherwise spline.
*/
args se sbasis zero at if in
local nat 0
if "`at'"!="" {
	tokenize `at'
	while "`1'"!="" {
		unab 1: `1'
		local nat=`nat'+1
		local atvar`nat' `1'
		local atval`nat' `2'
		mac shift 2
	}
}
tempname btmp Vtmp
matrix `btmp'=e(b)
matrix `Vtmp'=e(V)
local ncovar: word count `e(fvl)'
local coefn
if "`sbasis'"!="" {	/* spline + index */
	local df=e(df)
	local stratif `e(strat)'
	local nstrat: word count `stratif'
	if "`stratif'"=="" {
		local coefn `sbasis'
	}
	else {
		local j 1
		while `j'<=`df' {
			local basis: word `j' of `sbasis'
			local i 1
			while `i'<=`nstrat' {
				local changed 0
				local x: word `i' of `stratif'
				local xval `x'
				if "`at'"!="" {
					local k 1
					while `k'<=`nat' & !`changed' {
						*if "`basis'"=="`atvar`k''" {
						if "`x'"=="`atvar`k''" {
							local xval `atval`k''
							local changed 1
						}
						local k=`k'+1
					}
				}
				if !`changed' & "`zero'"!="" {
					local xval 0
				}
				tempvar v`j'`i'
				gen double `v`j'`i''=`xval'*`basis' `if' `in'
				local coefn `coefn' `v`j'`i''
				local i=`i'+1
			}
			local coefn `coefn' `basis'
			local j=`j'+1
		}
	}
}
else {		/* index only */
	matrix `btmp'=`btmp'[1,"xb:"]
	matrix `Vtmp'=`Vtmp'["xb:","xb:"]
}
* Deal with at & zero in index
if "`at'`zero'"=="" {
	local coefn `coefn' `e(fvl)'
}
else {
	local j 1
	while `j'<=`ncovar' {	/* ncovar could be 0, then no looping */
		local changed 0
		local covar: word `j' of `e(fvl)'
		if "`at'"!="" {
			local k 1
			while `k'<=`nat' & !`changed' {
				if "`covar'"=="`atvar`k''" {
					local xval `atval`k''
					local changed 1
				}
				local k=`k'+1
			}
		}
		if !`changed' & "`zero'"!="" {
			local xval 0
			local changed 1
		}
		if `changed' {
			tempvar v`j'
			gen double `v`j''=`xval' `if' `in'
			local coefn `coefn' `v`j''
		}
		else local coefn `coefn' `covar'
		local j=`j'+1
	}
}
local coefn `coefn' _cons
matrix colnames `btmp'=`coefn'
matrix colnames `btmp'=_:
matrix colnames `Vtmp'=`coefn'
matrix colnames `Vtmp'=_:
matrix rownames `Vtmp'=`coefn'
matrix rownames `Vtmp'=_:
tempname tmp
_estimates hold `tmp'
ereturn post `btmp' `Vtmp'
_predict double `se' `if' `in', stdp
_estimates unhold `tmp'
end

program define Genstvc
version 8.1
/*
	Compute SE of time-varying coefficient for covariate `tvc'.

	For model with spline degree m (i.e. df=m+1), and `tvc' = z1, this is SE of
	beta_z1   + gamma_11*x + gamma_21*v_1(x) +...+ gamma_m+1,1*v_m(x), i.e.
	[xb]_b[z1]+[s0]_b[z1]*x+[s1]_b[z1]*v_1(x)+...+[sm]_b[z1]*v_m(x).

	Done by creating coeff and VCE matrix and posting them, then _predict, stdp.
*/
args tvc se sbasis if in
tempname btmp Vtmp c
matrix `btmp'=e(b)
matrix `Vtmp'=e(V)
local df=e(df)
* Create equation for TVC via "interactions of basis functions with 1".
* Build required coefficient matrix and VCE matrix "manually" (ugh).
local B
local V
local j 1
while `j'<=`df' {
	* extract relevant coefficient from overall coeff matrix
	local j1=`j'-1
	matrix `c'=`btmp'[1,"s`j1':`tvc'"]
	local cc=`c'[1,1]
	local B `B' `cc'

	* loop to extract j'th row of VC matrix into Vrow.
	local Vrow
	local k 1
	while `k'<=`df' {
		local k1=`k'-1
		matrix `c'=`Vtmp'["s`j1':`tvc'", "s`k1':`tvc'"]
		local cc=`c'[1,1]
		local Vrow `Vrow' `cc'
		local k=`k'+1
	}
	matrix `c'=`Vtmp'["s`j1':`tvc'", "xb:`tvc'"]
	local cc=`c'[1,1]
	local Vrow `Vrow' `cc'

	* update VCE matrix (string form)
	local V `V' `Vrow' \

	local j=`j'+1
}
* term for constant (relevant coefficient is [xb]_b[`tvc'])
matrix `c'=`btmp'[1,"xb:`tvc'"]
local cc=`c'[1,1]
local B `B' `cc'

* loop to extract [xb] row of VC matrix into Vrow.
local Vrow
local k 1
while `k'<=`df' {
	local k1=`k'-1
	matrix `c'=`Vtmp'["xb:`tvc'", "s`k1':`tvc'"]
	local cc=`c'[1,1]
	local Vrow `Vrow' `cc'
	local k=`k'+1
}
matrix `c'=`Vtmp'["xb:`tvc'", "xb:`tvc'"]
local cc=`c'[1,1]
local Vrow `Vrow' `cc'

* update VCE matrix (string form)
local V `V' `Vrow'

* Assign and post
matrix input `btmp'=(`B')
matrix input `Vtmp'=(`V')

local vn `sbasis' _cons
matrix colnames `btmp'=`vn'
matrix colnames `btmp'=_:
matrix colnames `Vtmp'=`vn'
matrix colnames `Vtmp'=_:
matrix rownames `Vtmp'=`vn'
matrix rownames `Vtmp'=_:
tempname tmp
_estimates hold `tmp'
ereturn post `btmp' `Vtmp'
_predict double `se' `if' `in', stdp
_estimates unhold `tmp'
end

program define Gensdz
version 8.1
/*
	s.e. of spline derivative, dz/d(lnt).
*/
args se obasis zero at if in
local nat 0
if "`at'"!="" {
	tokenize `at'
	while "`1'"!="" {
		unab 1: `1'
		local nat=`nat'+1
		local atvar`nat' `1'
		local atval`nat' `2'
		mac shift 2
	}
}
tempname btmp Vtmp
matrix `btmp'=e(b)
matrix `Vtmp'=e(V)
local coefn
local df=e(df)
local stratif `e(strat)'
local nstrat: word count `stratif'
if "`stratif'"=="" {
	local coefn `obasis'
}
else {
	local j 1
	while `j'<=`df' {
		local basis: word `j' of `obasis'
		local i 1
		while `i'<=`nstrat' {
			local changed 0
			local x: word `i' of `stratif'
			local xval `x'
			if "`at'"!="" {
				local k 1
				while `k'<=`nat' & !`changed' {
					if "`x'"=="`atvar`k''" {
						local xval `atval`k''
						local changed 1
					}
					local k=`k'+1
				}
			}
			if !`changed' & "`zero'"!="" {
				local xval 0
			}
			tempvar v`j'`i'
			gen double `v`j'`i''=`xval'*`basis' `if' `in'
			local coefn `coefn' `v`j'`i''
			local i=`i'+1
		}
		local coefn `coefn' `basis'
		local j=`j'+1
	}
}
* Pick out first part of b and V matrix - don't need [xb] part, which comes at the end.
local nterms=`df'+`df'*`nstrat'
matrix `btmp'=`btmp'[1, 1..`nterms']
matrix `Vtmp'=`Vtmp'[1..`nterms', 1..`nterms']
matrix colnames `btmp'=`coefn'
matrix colnames `btmp'=_:
matrix colnames `Vtmp'=`coefn'
matrix colnames `Vtmp'=_:
matrix rownames `Vtmp'=`coefn'
matrix rownames `Vtmp'=_:
tempname tmp
_estimates hold `tmp'
ereturn post `btmp' `Vtmp'
_predict double `se' `if' `in', stdp
_estimates unhold `tmp'
end

program define Genselnhaz
version 8.1
/*
	Calc SE of ln hazard function. Involves ln H and dlnH/dlnt.
	Need to combine basis functions obasis and sbasis.
	Obasis must be divided by dlnH/dlnt before combining with sbasis.
	Not straightforward.
*/
args se sbasis obasis dZdy zero at if in
local nat 0
if "`at'"!="" {
	tokenize `at'
	while "`1'"!="" {
		unab 1: `1'
		local nat=`nat'+1
		local atvar`nat' `1'
		local atval`nat' `2'
		mac shift 2
	}
}
tempname btmp Vtmp
matrix `btmp'=e(b)
matrix `Vtmp'=e(V)
local ncovar: word count `e(fvl)'
local coefn
local df=e(df)
local stratif `e(strat)'
local nstrat: word count `stratif'

* Combine sbasis and obasis to make basis
local basis
forvalues j=1/`df' {
	local sb: word `j' of `sbasis'
	local ob: word `j' of `obasis'
	tempvar basis`j'
	gen double `basis`j''=`sb'+`ob'/`dZdy'
	local basis `basis' `basis`j''
}

if "`stratif'"=="" {
	local coefn `basis'
}
else {
	local j 1
	while `j'<=`df' {
		local i 1
		while `i'<=`nstrat' {
			local changed 0
			local x: word `i' of `stratif'
			local xval `x'
			if "`at'"!="" {
				local k 1
				while `k'<=`nat' & !`changed' {
					if "`x'"=="`atvar`k''" {
						local xval `atval`k''
						local changed 1
					}
					local k=`k'+1
				}
			}
			if !`changed' & "`zero'"!="" {
				local xval 0
			}
			tempvar v`j'`i'
			gen double `v`j'`i''=`xval'*`basis`j'' `if' `in'
			local coefn `coefn' `v`j'`i''
			local i=`i'+1
		}
		local coefn `coefn' `basis`j''
		local j=`j'+1
	}
}
* Deal with at & zero in index
if "`at'`zero'"=="" {
	local coefn `coefn' `e(fvl)'
}
else {
	local j 1
	while `j'<=`ncovar' {	/* ncovar could be 0, then no looping */
		local changed 0
		local covar: word `j' of `e(fvl)'
		if "`at'"!="" {
			local k 1
			while `k'<=`nat' & !`changed' {
				if "`covar'"=="`atvar`k''" {
					local xval `atval`k''
					local changed 1
				}
				local k=`k'+1
			}
		}
		if !`changed' & "`zero'"!="" {
			local xval 0
			local changed 1
		}
		if `changed' {
			tempvar v`j'
			gen double `v`j''=`xval' `if' `in'
			local coefn `coefn' `v`j''
		}
		else local coefn `coefn' `covar'
		local j=`j'+1
	}
}
local coefn `coefn' _cons
matrix colnames `btmp'=`coefn'
matrix colnames `btmp'=_:
matrix colnames `Vtmp'=`coefn'
matrix colnames `Vtmp'=_:
matrix rownames `Vtmp'=`coefn'
matrix rownames `Vtmp'=_:
tempname tmp
_estimates hold `tmp'
ereturn post `btmp' `Vtmp'
_predict double `se' `if' `in', stdp
_estimates unhold `tmp'
end
