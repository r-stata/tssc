******************************************
**    Luciano Lopez & Sylvain Weber     **
**        University of Neuchâtel       **
**    Institute of Economic Research    **
**    This version: October 20, 2017    **
******************************************

*! version 4.0 Luciano Lopez & Sylvain Weber 20oct2017
program xtgcause, rclass
version 10.0


*** Syntax ***
#d ;
syntax varlist(min=2 max=2 numeric) [if] [in], 
	[
		Lags(string) 
		REGress 
		BOOTstrap BReps(numlist max=1) 
		BLEVel(numlist max=1) BLENgth(numlist max=1) 
		seed(numlist max=1) 
		nodots
	]
;
#d cr

*Mark sample to be used
marksample touse, novarlist

*Separate varlist into depvar/indepvar
tokenize `varlist'
local depvar `1'
local indepvar `2'

*** Checks ***
*Data must be -xtset- before
cap: xtset
if _rc {
	di as error "Panel variable not set; use xtset before running xtgcause."
	exit 459
}

*Panel must be strongly balanced
qui: xtset
local id "`r(panelvar)'"
local time "`r(timevar)'"
qui: tab `id' if `touse'
local N = r(r)
qui: tab `time' if `touse'
local T = r(r)
qui: sum `time' if `touse'
local tmin = `r(min)'
local tmax = `r(max)'
if `=`tmax'-(`tmin'-1)'>`T' {
	di as error "Panel must be strongly balanced and without gaps (no missing values allowed in " as input "`depvar'" as error " and " as input "`indepvar'" as error ")."
	exit 459
}
qui: count if `touse' & mi(`depvar',`indepvar')
if r(N)>0 {
	di as error "Panel must be strongly balanced and without gaps (no missing values allowed in " as input "`depvar'" as error " and " as input "`indepvar'" as error ")."
	exit 459
}

*Minimal number of obs
if `T'<=8 {
	di as error "Warning: there must be more than 8 periods to run the test, even in its simplest form."
	di as error "(General condition: T > 5+3K, where K is the lag order.)"
	exit 459
}

*Check that lags are correctly specified
if "`lags'"=="" {
	local K = 1
}
else {
	cap: confirm integer number `lags'
	if !_rc local K = `lags'
	if _rc {
		if wordcount("`lags'")>2 {
			di as error "lags() must be a positive integer or aic [#], bic [#], or hqic [#]."
			exit 198
		}
		local ltype = lower(word("`lags'",1))
		if !inlist("`ltype'","aic","bic","hqic") {
			di as error "lags() must be a positive integer or aic [#], bic [#], or hqic [#]."
			exit 198
		}
		cap: local Kmax = word("`lags'",2)
		if "`Kmax'"=="" local Kmax = floor((`T'-6)/3)
		cap: confirm integer number `Kmax'
		if _rc {
			di as error "lags() must be a positive integer or aic [#], bic [#], or hqic [#]."
			exit 198
		}
	}
}

*Minimal/maximal number of lags
if inlist("`ltype'","aic","bic","hqic") local K = `Kmax' // temporarily set K equal to Kmax to run the checks in a single loop
if `K'<=0 {
	di as error "lags() must be a positive integer or aic [#], bic [#], or hqic [#]."
	exit 198
}
if `T'-`K'<=`=5+2*`K'' {
	di as error "Warning: T (here " as input "`T'" as error ") must be larger than 5+3K (here " as input "`=5+3*`K''" as error ") where K is the lag order."
	di as error "The maximal lag order that can be included here is " as input "`=floor((`T'-6)/3)'" as error "." 
	exit 459
}

*Bootstrap options
if "`bootstrap'"=="bootstrap" {
	if "`breps'"=="" local breps = 1000
	cap: confirm integer number `breps'
	if _rc | `breps'<=0 {
		di as error "Number of bootstrap replications must be a positive integer."
		exit 198
	}
	if c(matsize)<`=`breps'+1' set matsize `=`breps'+1'
	if "`blevel'"=="" local blevel = 95
	if `blevel'<=0 | `blevel'>=100 {
		di as error "Bootstrap significance level must be a positive number (strictly) below 100."
		exit 198
	}
	if "`blength'"=="" local blength = 1
	cap: confirm integer number `blength'
	if `blength'<1 | `blength'>`T'-`K' {
		di as error "Bootstrap block length must be between 1 and T-K (`=`T'-`K''). (It should be much smaller than T (`T').)"
		exit 198
	}
}
if "`bootstrap'"=="" {
	if "`breps'"!="" | "`blevel'"!="" | "`blength'"!="" | "`seed'"!="" {
		di as error "breps(#), blevel(#), blength(#) and seed(#) cannot be specified without bootstrap."
		exit 198
	}
}


*** Dumitrescu-Hurlin Granger causality test with # lags ***
if !inlist("`ltype'","aic","bic","hqic") {

	*Initialize some matrices
	mat W = J(`N',1,0)
	mat PV = J(`N',1,0)

	*Individual Wald statistics
	sort `id' `time'
	cap: levelsof `id' if `touse', local(idlist)
	local j 0 
	foreach i of local idlist {
		local ++j
		qui: reg `depvar' l(1/`K').`depvar' l(1/`K').`indepvar' if `id'==`i' & inrange(`time',`=`tmin'+`K'',`tmax')
		if "`regress'"=="regress" {
			di _n(1) as input "Reg for id==`i'"
			noi: reg
			di _n(1) 
		}
		local i 0
		while `i'<`K' {
			local ++i		
			qui: test l`i'.`indepvar', accum
		}
		mat W[`j',1] = `K'*r(F)
		mat PV[`j',1] = 1-F(`K',`e(df_r)',`r(F)')
	}

	*Average Wald statistic
	mat O = J(rowsof(W),1,1)
	mat sum = O'*W
	mat wmean = sum/rowsof(W)
	local wbar = wmean[1,1]
}


*** Dumitrescu-Hurlin Granger causality test with AIC/BIC # lags ***
if inlist("`ltype'","aic","bic","hqic") {

	*Select and estimate best model based on IC. At the end of the loop: local K is the optimal # of lags.
	local ICmin = .
	forv k = 1/`Kmax' {
	
		*Initialize some matrices
		mat W = J(`N',1,0)
		mat PV = J(`N',1,0)
		mat IC = J(`N',1,0)

		*Calculate IC statistics
		sort `id' `time'
		cap: levelsof `id' if `touse', local(idlist)
		local j 0 
		foreach i of local idlist {
			local ++j
			qui: reg `depvar' l(1/`k').`depvar' l(1/`k').`indepvar' if `id'==`i' & inrange(`time',`=`tmin'+`Kmax'',`tmax')
			if "`ltype'"=="aic" local IC = -2*e(ll) + 2*e(rank) 
			if "`ltype'"=="bic" local IC = -2*e(ll) + ln(e(N))*e(rank) 
			if "`ltype'"=="hqic" local IC = -2*e(ll) + 2*ln(ln(e(N)))*e(rank) 
			mat IC[`j',1] = `IC'
		}
		
		*Identify lowest IC 
		mat O = J(rowsof(IC),1,1)
		mat ICsum = O'*IC
		mat ICmean = ICsum/rowsof(IC)
		local ICbar = ICmean[1,1]
		local ICmin = min(`ICmin',`ICbar')
		if `ICbar'==`ICmin' {
			local K = `k'
		}
	}
	
	*Individual Wald statistics for best model
	sort `id' `time'
	cap: levelsof `id' if `touse', local(idlist)
	local j 0 
	foreach i of local idlist {
		local ++j
		qui: reg `depvar' l(1/`K').`depvar' l(1/`K').`indepvar' if `id'==`i' & inrange(`time',`=`tmin'+`K'',`tmax')
		if "`regress'"=="regress" {
			di _n(1) as input "Reg for id==`i' and lags==`K'"
			noi: reg
			di _n(1) 
		}
		local i 0
		while `i'<`K' {
			local ++i		
			qui: test l`i'.`indepvar', accum
		}
		mat W[`j',1] = `K'*r(F)
		mat PV[`j',1] = 1-F(`K',`e(df_r)',`r(F)')
	}

	*Average Wald statistic
	mat O = J(rowsof(W),1,1)
	mat sum = O'*W
	mat wmean = sum/rowsof(W)
	local wbar = wmean[1,1]
}


*** Compute Z-bar and Z-bar tilde ***
local zbar = sqrt(`N'/(2*`K')) * (`wbar'-`K') // Equation (9) in DH
local zbar_pv = 2*(1-normal(abs(`zbar')))

local zbart = sqrt(`N'/(2*`K') * ((`T'-`K')-2*`K'-5)/((`T'-`K')-`K'-3)) * (((`T'-`K')-2*`K'-3)/((`T'-`K')-2*`K'-1)*`wbar' - `K') // Equation (26) in DH adapted with T-K instead of T
local zbart_pv = 2*(1-normal(abs(`zbart')))


*** Bootstrap procedure ***
if "`bootstrap'"=="bootstrap" {
	if "`seed'"!="" set seed `seed'

	local l = length("Bootstrap replications (`breps')")
	di _n(1) _dup(`l') as txt "-"
	di as txt "Bootstrap replications (" as res `breps' as txt ")"
	di _dup(`l') as txt "-"

	*H0 estimations (step 2)
	tempvar epshat yhat
	quietly: gen `epshat' = .
	quietly: gen `yhat' = .
	cap: levelsof `id' if `touse', local(idlist)
	foreach i of local idlist {
		qui: reg `depvar' l(1/`K').`depvar' /*l(1/`K').`indepvar' -> H0*/ if `id'==`i' & inrange(`time',`=`tmin'+`K'',`tmax')
		*Store residuals
		tempvar epshati /*yhati*/
		quietly: predict `epshati' if `id'==`i', res
		*quietly: predict `yhati' if `id'==`i', xb
		quietly: replace `epshat' = `epshati' if `id'==`i'
		*quietly: replace `yhat' = `yhati' if `id'==`i'
		*Store coefficients
		local alpha`i' = _b[_cons]
		forv k = 1/`K' {
			local beta`k'`i' = _b[L`k'.`depvar']
		}
	}

	*Initialize some matrices
	mat Wb = J(`N',1,0)
	mat ZBARb = J(`breps',1,.)
	mat ZBARTb = J(`breps',1,.)
	
	*Bootstrap replications
	forv b = 1/`breps' {
		*Display dots/iteration number
		if "`dots'"!="nodots" _dots `b' 0

		*Resample residuals (step 3)
		tempvar epsb
		qui: gen `epsb' = .
		forv t = `=`tmin'+`K''(`blength')`tmax' {
			local r = `tmin' + `K' + int((`T'-`K'-`blength'+1)*runiform())
			foreach i of local idlist {
				forv l = 1/`blength' {
					qui: sum `epshat' if `id'==`i' & `time'==`=`r'+`l'-1'
					qui: replace `epsb' = r(mean) if `id'==`i' & `time'==`=`t'+`l'-1'
				}
			}
		}

		*Generate vector of K initial conditions (step 4)
		tempvar yb
		qui: gen `yb' = .
		local r = `tmin' + int((`T'-`K')*runiform())
		foreach i of local idlist {
			forv k = 1/`K' {
				qui: sum `depvar' if `id'==`i' & `time'==`=`r'+`k'-1'
				qui: replace `yb' = r(mean) if `id'==`i' & `time'==`=`tmin'+`k'-1'
			}
		}
		
		*Generate pseudo-panel data (step 5)
		foreach i of local idlist {
			local betalist
			forv k = 1/`K' {
				local betalist `betalist' `beta`k'`i''*L`k'.`yb'
			}
			local betalist = subinstr(`"`betalist'"'," "," + ",.)
			qui: replace `yb' = `alpha`i'' + `betalist' + `epsb' if `id'==`i' & inrange(`time',`=`tmin'+`K'',`tmax')
		}

		*Individual Wald statistics (step 6)
		local j 0 
		foreach i of local idlist {
			local ++j
			qui: reg `yb' l(1/`K').`yb' l(1/`K').`indepvar' if `id'==`i' & inrange(`time',`=`tmin'+`K'',`tmax')
			local i 0
			while `i'<`K' {
				local ++i		
				qui: test l`i'.`indepvar', accum
			}
			mat Wb[`j',1] = `K'*r(F)
		}

		*Average Wald statistic
		mat Ob = J(rowsof(Wb),1,1)
		mat sumb = Ob'*Wb
		mat wmeanb = sumb/rowsof(Wb)
		local wbarb = wmeanb[1,1]
		local zbarb = sqrt(`N'/(2*`K')) * (`wbarb'-`K')
		local zbartb = sqrt(`N'/(2*`K') * ((`T'-`K')-2*`K'-5)/((`T'-`K')-`K'-3)) * (((`T'-`K')-2*`K'-3)/((`T'-`K')-2*`K'-1)*`wbarb' - `K')
		
		mat ZBARb[`b',1] = `zbarb'
		mat ZBARTb[`b',1] = `zbartb'
	}
	qui: count
	local Nobs = r(N) // store number of observations (useful in case number of replications > number of obs --> creation of new observations that will be dropped at the end)

	*Compute Z-bar/Z-bar tilde p-values and critical values (step 8)
	tempvar zbarb
	qui: svmat ZBARb, name(`zbarb')
	qui: replace `zbarb' = abs(`zbarb')
	_pctile `zbarb', p(`blevel')
	local zbarb_cv = r(r1)
	qui: count if abs(`zbar')<`zbarb' & !mi(`zbarb')
	local zbar_pv = r(N)/`breps'
	
	tempvar zbartb
	qui: svmat ZBARTb, name(`zbartb')
	qui: replace `zbartb' = abs(`zbartb')
	_pctile `zbartb', p(`blevel')
	local zbartb_cv = r(r1)
	qui: count if abs(`zbart')<`zbartb' & !mi(`zbartb')
	local zbart_pv = r(N)/`breps'
}


*** Display results ***
*Title
di _n(2) as txt "Dumitrescu & Hurlin (2012) Granger non-causality test results:"
di _dup(62) "-"

*Lag order
if !inlist("`ltype'","aic","bic","hqic") {
	di as txt "Lag order: " as res `K'
}
if inlist("`ltype'","aic","bic","hqic") {
	di as txt "Optimal number of lags (`=upper("`ltype'")'): " as res `K' as txt " (lags tested: " as res "1" as txt " to " as res `Kmax' as txt ")."
	local lags `K'
}

*W-bar
di as txt "W-bar =" _col(15) as res %9.4f `wbar' 

*Z-bar and Z-bar tilde
if "`bootstrap'"=="" {
	di as txt "Z-bar =" _col(15) as res %9.4f `zbar' _col(27) as txt "(p-value = " as res %5.4f `zbar_pv' as txt ")"
	di as txt "Z-bar tilde = " _col(15) as res %9.4f `zbart' _col(27) as txt "(p-value = " as res %5.4f `zbart_pv' as txt ")"
}
if "`bootstrap'"=="bootstrap" {
	di as txt "Z-bar =" _col(15) as res %9.4f `zbar' _col(27) as txt "(p-value* = " as res %5.4f `zbar_pv' as txt ", `blevel'% critical value = " as res %5.4f `zbarb_cv' as txt ")"
	di as txt "Z-bar tilde = " _col(15) as res %9.4f `zbart' _col(27) as txt "(p-value* = " as res %5.4f `zbart_pv' as txt ", `blevel'% critical value = " as res %5.4f `zbartb_cv' as txt ")"
}

di _dup(62) "-"
di as txt "H0: " as input "`indepvar'" as txt " does not Granger-cause " as input "`depvar'" as txt "." 
di "H1: " as input "`indepvar'" as txt " does Granger-cause " as input "`depvar'" as txt " for at least one panelvar (" as input "`id'" as txt ")." 
if "`bootstrap'"!="" di as txt "*p-values computed using " as input `breps' as txt " bootstrap replications."

*** Re-store initial number of observations (in case matrices ZBARd and ZBARTd were larger than dataset) ***
if "`bootstrap'"!="" qui: keep in 1/`Nobs'

*** Store results ***
if "`bootstrap'"=="bootstrap" {
	foreach stat in blength blevel breps zbartb_cv zbarb_cv {
		return scalar `stat' = ``stat''
	}
	forv b = 1/`breps' {
		local iter `iter' `b'
	}
	foreach M in ZBARTb ZBARb {
		mat colnames `M' = `M'
		mat rownames `M' = `iter'
		return matrix `M' = `M'
	}
}
local lags = `K'
foreach stat in zbart_pv zbart zbar_pv zbar lags wbar {
	return scalar `stat' = ``stat''
}

*Store matrices (columns and rows renamed)
qui: levelsof `id' if `touse', local(levels)
foreach i of local levels {
	local rnames `rnames' `id'`i'
}
foreach M in PV W {
	mat colnames `M' = `M'i
	mat rownames `M' = `rnames'
	return matrix `M'i = `M'
}

end 

/*
Update history:
- v1.1 (10feb2017):
	- A parenthesis was missing in line 251: sqrt(`N'/2*`lags') --> sqrt(`N'/(2*`lags'))
	- Names of stored statistics modified/shortened: probz --> pvzbar, zbartilde --> zbart, probzbartilde --> pvzbart
- v1.2 (23feb2017):
	- Version submitted to Stata Journal.
	- Order of the stored statistics modified.
- v1.3 (12jul2017):
	- Addition of a nosmall sample adjustment option.
	  Eviews results correspond to xtgcause results (and Zbar-Stat. in Eviews = Z-bar tilde in xtgcause).
	  Exec&Share results (DH) correspond to xtgcause results with the nosmall option.
- v2.0 (13jul2017):
	- nosmall option removed.
	- Selection of lags by AIC/BIC improved.
- v2.1 (18jul2017):
	- Change from locals lags/lmax to a single local K
	- HQIC added
- v2.2 (29jul2017)
	- option -novarlist- added to -marksample- (line 17)
	- Error messages formatted (colors)
- v3.0 (11sep2017)
	- Bootstrap options added
- v4.0 (20oct2017)
	- Initial conditions for bootstrap adapted: series re-constructed based on initial conditions
	- Displaying dots using undocumented command _dots instead of own loop
	- Matrices ZBARb and ZBARTb stored in returned results
*/
