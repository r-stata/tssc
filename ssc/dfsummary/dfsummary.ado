***************************
**   Maximo Sangiacomo   **
** Aug 2013. Version 1.0 **
***************************
program define dfsummary, rclass
	version 9
syntax varname(ts) [if] [in] , [ Lag(numlist min=1 max=1 int >=1) noCONstant Trend Seasonal REGress ]  
qui tsset
local unit "`r(unit)'"
local time `r(timevar)'
marksample touse
markout `touse' `time'

if "`lag'" == "" {
	local lags = 0
}
else {
	local lags = `lag'
}
tempvar vvar vq vtrend 
tempname results

* copy variable to prevent alteration and allow ts ops
qui gen double `vvar' = `varlist' if `touse'


if ("`constant'"!=""&"`trend'"!=""&"`seasonal'"!="")|("`constant'"!=""&"`trend'"!="")|("`constant'"!=""&"`seasonal'"!="") {
	disp in smcl in r "{opt noconstant} cannot be used with the {opt trend} or {opt seasonal} option"
	error 198
}
if "`seasonal'"!=""&"`unit'"!="halfyearly"&"`unit'"!="quarterly"&"`unit'"!="monthly"&"`unit'"!="weekly" {
	disp in r "seasonal is only allowed for frequency: " /// 
	_n _col(8) "1.weekly" _col(23) "2.monthly" _col(38) "3.quarterly" /// 
	_n _col(8) "4.halfyearly"  
	error 120
}
if "`seasonal'"!="" {
	if "`unit'"=="halfyearly" {
		gen `vq' = halfyear(dofh(`time'))
		qui sum `vq'
		local vq1 = r(max)-1
		foreach num of numlist 1/`vq1' {
			capture confirm new variable _d_t`num'
			if _rc!=0 {
				display "_d_t`num' already exists"
				exit _rc
			}
			else {
				qui gen _d_t`num' = cond(`vq'==1,1,0)
				local seas "_d_t`num'"
			}
		}
	}
	if "`unit'"=="quarterly" {
		gen `vq' = quarter(dofq(`time'))
		qui sum `vq'
		local vq1 = r(max)-1
		foreach num of numlist 1/`vq1' {
			capture confirm new variable _d_t`num'
			if _rc!=0 {
				display "_d_t`num' already exists"
				exit _rc
			}
			else {
				qui gen _d_t`num' = cond(`vq'==`num',1,0)
				local st _d_t`num'
				local seas "`seas' `st'"

			}
		}
	}
	if "`unit'"=="monthly" {
		gen `vq' = month(dofm(`time'))
		qui sum `vq'
		local vq1 = r(max)-1
		foreach num of numlist 1/`vq1' {
			capture confirm new variable _d_t`num'
			if _rc!=0 {
				display "_d_t`num' already exists"
				exit _rc
			}
			else {
				qui gen _d_t`num' = cond(`vq'==`num',1,0)
				local st _d_t`num'
				local seas "`seas' `st'"

			}
		}
	}
	if "`unit'"=="weekly" {
		gen `vq' = week(dofw(`time'))
		qui sum `vq'
		local vq1 = r(max)-1
		foreach num of numlist 1/`vq1' {
			capture confirm new variable _d_t`num'
			if _rc!=0 {
				display "_d_t`num' already exists"
				exit _rc
			}
			else {
				qui gen _d_t`num' = cond(`vq'==`num',1,0)
				local st _d_t`num'
				local seas "`seas' `st'"
			}
		}
	}
}
if "`constant'"==""&"`trend'"==""&"`seasonal'"=="" {
	local case 1
	local noc ""
	local adfnoc ""
	local text "Constant included"
}
if "`constant'"!=""&"`trend'"==""&"`seasonal'"=="" {
	local case 2
	local noc ", nocons"
	local adfnoc " nocons"
	local text "no deterministic variables"
}
if "`trend'"!=""&"`seasonal'"=="" { 
	local case 3
	local noc ""
	local adfnoc ""
	local text "Constant and Trend included"
	local dftrend ", trend"
	local adftrend " trend"
	qui gen `vtrend' = _n - 1
	qui replace `vtrend' = . if `vtrend' ==0
	if `lags' == 0 {
		capture confirm new variable _trend0
		if _rc!=0 {
			display in r "_trend0 already exists"
			exit _rc
		}
		else {
			qui gen _trend0 = `vtrend'
			local trend "_trend0"
		}
	}
	else {
		capture confirm new variable _trend`lags'
		if _rc!=0 {
			display in r "_trend`lags' already exists"
			exit _rc
		}
		else {
			qui gen _trend`lags' = L`lags'.`vtrend'
			local trend "_trend`lags'"
		}
	}
}
if "`seasonal'"!=""&"`trend'"==""{
	local noc ""
	local adfnoc ""
	local case 4
	local text "Constant and Seasonals included"
	local note "Note: "
	local note1 "t-adf result based on a model that includes Constant (seasonals ignored)"	
}
if "`trend'"!=""&"`seasonal'"!="" { 
	local noc ""
	local adfnoc ""
	local case 5
	local text "Constant and Trend and Seasonals included"
	local note "Note: "
	local note1 "t-adf result based on a model that includes Constant and Trend (seasonals ignored)"
	local dftrend ", trend"
	local adftrend " trend"
	gen `vtrend' = _n - 1
	qui replace `vtrend' = . if `vtrend' ==0
	if `lags' == 0 {
		capture confirm new variable _trend0
		if _rc!=0 {
			display "_trend0 already exists"
			exit _rc
		}
		else {
			qui gen _trend0 = `vtrend'
			local trend "_trend0"
		}
	}
	else {
		capture confirm new variable _trend`lags'
		if _rc!=0 {
			display "_trend`lags' already exists"
			exit _rc
		}
		else {
			qui gen _trend`lags' = L`lags'.`vtrend'
			local trend "_trend`lags'"
		}
	}
}		

qui {
*DF
	reg D.`vvar' L.`vvar' `trend' `seas' if `touse' `noc'
	local sigma_0 = e(rmse)
	local b1_0 = (1+_b[L.`vvar'])
	local tdy_0 
	local pvtdy_0
	sum `time' if e(sample)
	local tmin = r(min)
	local tmax = r(max)
	estat ic
	mat ic = r(S)
	local aic_0 = ic[1,5]
	local bic_0 = ic[1,6] 
	dfuller `vvar' if `touse' `dftrend' `noc'
	local Zt_0 = round(r(Zt),.0001)
	if length("`Zt_0'") > 6 {
		local Zt_0 = substr("`Zt_0'",1,6)
	}
	local p_0 = r(p)
	if `p_0' <= .05 & `p_0' > .01 {
		local Zts_0 "`Zt_0'*"
	}
	else if `p_0' <= .01 {
		local Zts_0 "`Zt_0'**"
	}
	else {
		local Zts_0 "`Zt_0'"
	}
*ADF
	if "`lag'" != "" {
		local aug "Augmented "
		foreach num of numlist 1/`lag' {
			reg D.`vvar' L.`vvar'  DL(1/`num').`vvar' `trend' `seas' if `touse' `noc'
			local sigma_`num' = e(rmse)
			local b1_`num' = (1+_b[L.`vvar'])
			local tdy_`num' = _b[DL`num'.`vvar']/_se[DL`num'.`vvar']
			local pvtdy_`num' = tprob(e(df_r),`tdy_`num'')
			estat ic
			mat ic = r(S)
			local aic_`num' = ic[1,5]
			local bic_`num' = ic[1,6] 
			dfuller `vvar' if `touse',  lags(`num') `adftrend' `adfnoc' 
			local Zt_`num' = round(r(Zt),0.0001)
			if length("`Zt_`num''") > 6 {
			local Zt_`num' = substr("`Zt_`num''",1,6)
			}
			local p_`num' = r(p)
			if `p_`num'' <= .05 & `p_`num'' > .01 {
				local Zts_`num' "`Zt_`num''*"
			}
			else if `p_`num'' <= .01 {
				local Zts_`num' "`Zt_`num''**"
			}
			else {
				local Zts_`num' "`Zt_`num''"
			}
		}
		reg D.`vvar' L.`vvar'  DL(1/`lag').`vvar' `trend' `seas' if `touse' `noc'
		sum `time' if e(sample)
		local tmin = r(min)
		local tmax = r(max)
		foreach num of numlist 1/`lag' {
			local list DL`num'.`vvar'
			local list_t "`list_t' `list'"
		}
		test `list_t'
		local fp_0 = r(p)
		local lag_0 = 0
		if `lag' > 1 {
			local lag1 = `lag'-1
			foreach num of numlist 1/`lag1' {
				local lag_`num' = `num'
				gettoken first list_t: list_t
				test `list_t'
				local fp_`num' = r(p)
			}
		}
	
	}
}

if "`unit'" == "clocktime" {
	local fd %tc
}
else if "`unit'" == "daily" {
	local fd %td
}
else if "`unit'" == "weekly" {
	local fd %tw
}
else if "`unit'" == "monthly" { 
	local fd %tm
}
else if "`unit'" == "quarterly" { 
	local fd %tq
}
else if "`unit'" == "halfyearly" { 
	local fd %th 
}
else if "`unit'" == "yearly" { 
	local fd %ty
}
else if "`unit'" == "generic" { 
	local fd %tg
}
else {
	disp in r "Frequency must be one of the following: " /// 
	_n _col(8) "1.clocktime" _col(23) "2.daily" _col(38) "3.weekly" /// 
	_n _col(8) "4.monthly" _col(23) "5.quarterly" _col(38) "6.halfyearly" /// 
	_n _col(8) "7.yearly" _col(23) "8.generic"
error 120
}

di in gr _n "`aug'Dickey-Fuller (unit root) test for: "  in ye "`varlist'" /// 
in gr _n "Sample size: " in ye `fd' `tmin' in g " to " in ye `fd' `tmax' /// 
in gr _n  "`text'"  
	di in smcl in gr "{hline 11}{c TT}{hline 80}"
	di in smcl in gr _col(12) "{c |}" /*
	*/ _col(16) "t-adf" _col(25) "beta Y_1" _col(35) "\sigma" /*
	*/ _col(43) "lag" _col(48) "t-DY_lag" _col(59) "t-prob" _col(67) "F-prob" _col(78) "AIC" _col(87) "BIC"
	di in smcl in gr "{hline 11}{c +}{hline 80}"
	if `lags' > 0 {
		local i = `lags'
		while `i' >= 1 {
			di in smcl in gr %10s abbrev("`varlist'",10) _col(12) "{c |}" in ye /*
			*/ _col(11) %9s "`Zts_`i''" /* 
			*/ _col(24) %8.4f `b1_`i'' /* 
			*/ _col(33) %8.4f `sigma_`i'' /* 
			*/ _col(45) %1.0f `i' /* 
			*/ _col(47) %8.4f `tdy_`i'' /* 
			*/ _col(57) %8.4f `pvtdy_`i'' /* 
			*/ _col(65) %8.4f `fp_`i'' /* 
			*/ _col(75) %8.2f `aic_`i'' /* 
			*/ _col(84) %8.2f `bic_`i''
			local --i 
		}
	}
        di in smcl in gr %10s abbrev("`varlist'",10) _col(12) "{c |}" in ye /*
	*/ _col(11) %9s "`Zts_0'" /* 
	*/ _col(24) %8.4f `b1_0' /* 
	*/ _col(33) %8.4f `sigma_0' /* 
	*/ _col(45) %1.0f `lag_0'  /* 
	*/ _col(47) %8.4f `tdy_0' /* 
	*/ _col(57) %8.4f `pvtdy_0' /* 
	*/ _col(65) %8.4f `fp_0' /* 
	*/ _col(75) %8.2f `aic_0' /* 
	*/ _col(84) %8.2f `bic_0'

	di in smcl in gr "{hline 11}{c BT}{hline 80}"
di in smcl in g "{bf:`note'}" in g "`note1'"

if "`regress'" != "" {
	if `lags' == 0 {
*DF
		reg D.`varlist' L.`varlist' `trend' `seas' if `touse' `noc'
	}
*ADF
	else {
		reg D.`varlist' L.`varlist'  DL(1/`lags').`varlist' `trend' `seas' if `touse' `noc'
	}
}

if "`seasonal'" != "" {
drop `seas'
}
if "`trend'" != "" {
drop _trend`lags'
}
*Results
local tdy_0 = .
local pvtdy_0 = .
local fp_`lags' = .
local n = `lags' + 1
mat `results' = J(`n',10,.)
mat colnames `results' = lag t-adf adf-prob "beta Y_1" \sigma t-DY_lag t-prob F-prob AIC BIC
local i = 1
foreach num of numlist `lags'/0 {
mat `results'[`i',1] = `num'  
mat `results'[`i',2] = `Zt_`num''
mat `results'[`i',3] = `p_`num''
mat `results'[`i',4] = `b1_`num''  
mat `results'[`i',5] = `sigma_`num''  
mat `results'[`i',6] = `tdy_`num'' 
mat `results'[`i',7] = `pvtdy_`num''  
mat `results'[`i',8] = `fp_`num''  
mat `results'[`i',9] = `aic_`num''  
mat `results'[`i',10] = `bic_`num''
local ++i
}
return mat results = `results'

end
