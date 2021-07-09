*! version 1.0.1 PR 07jun2010
program define stsurvimpute, rclass
version 10
st_is 2 analysis
syntax [varlist(default = none)] [if] [in] , GENerate(string) [ df(int 0) ///
 LLogistic LNormal SCale(string) SEEd(int 0) TRUncate(real 1) UNIForm(varname) WEIbull * ]
local id: char _dta[st_id]
local wt: char _dta[st_wt]	/* type of weight */
if "`wt'"!="" {
	di in red "weights not supported"
	exit 198
}
local time _t
local dead _d

local dcount = ("`llogistic'" != "") + ("`lnormal'" != "") + ("`weibull'" != "")
if `dcount' > 1 {
	di as err "cannot specify more than one of llogistic, lnormal, weibull"
	exit 198
}
if !missing("`weibull'`llogistic'`lnormal'") & (`df' > 0) {
	di as err "df(1) assumed with `weibull'`llogistic'`lnormal'"
	exit 198
}
if "`weibull'"!="" {
	local scale hazard	/* ln cumulative hazard scale */
	local dist Weibull
	local df 1
}
else if "`llogistic'"!="" {
	local scale odds		/* log odds scale */
	local dist log-logistic
	local df 1
}
else  if "`lnormal'"!="" {
	local scale normal	/* default - cumulative Normal scale */
	local dist lognormal
	local df 1
}
if `df' <= 0 {
	di as err "invalid df(), df must be positive"
	exit 198
}
if "`scale'" == "" {
	di as err "must specify scale(), or llogistic, lnormal or weibull"
	exit 198
}

tokenize `"`generate'"', parse(",")
if `"`2'"'!="" {
	if `"`2'"'!="," | `"`4'"'!="" error 198
	if `"`3'"'!="" {
		if `"`3'"'!="replace" error 198
		local replace replace
	}
}
local generate `1'
if "`replace'" == "" confirm new var `generate'

if `seed' > 0 set seed `seed'
quietly {
	marksample touse
	markout `touse' `uniform'
	replace `touse' = 0 if _st == 0
	count if `touse'
	local nobs = r(N)
	count if `touse' == 1 & `dead' == 0
	local ncens = r(N)
	if `ncens' == 0 {
		noi di as err "no censored observations found in estimation sample"
		exit 2000
	}
/*
	if "`id'"!="" {
		// check for multiple time records
		sort `touse' `id'
		tempvar cnt
		by `touse' `id': gen long `cnt' = _N
		sum `cnt' if `touse',meanonly
		if r(max) > 1 {
			noi di as err "multiple time records not allowed"
			exit 198
		}
		drop `cnt'
	}
*/
	tempvar s F u

	// Fit survival model and predict model-based survival probabilities
	noi di as txt _n `"-> fitting: stpm2 `varlist', df(`df') scale(`scale') `options'"'
	stpm2 `varlist' if `touse', df(`df') scale(`scale') `options'
	predict `s' if `touse', survival

	// Impute cumulative distribution of censored observations
	if "`uniform'"=="" gen double `u' = runiform()
	else local u `uniform'
	gen double `F' = 100*(1 - `s' * (1 - (1 - `u') * `truncate')) if `touse' == 1 & `dead' == 0
	cap confirm new var `generate'
	if c(rc) drop `generate'
	predict `generate', centile(`F')
	replace `generate' = _t if `touse' == 1 & `dead' == 1
	lab var `generate' "observed and imputed survival times"
}
di _n as res `ncens' as txt " censored observations imputed from " ///
 as res `nobs' - `ncens' as txt " event times"
end
