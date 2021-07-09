*! version 1.0.0 PR 14apr2010.
program define stsurvdiff
version 10.1
// Computes difference in 2 Kaplan-Meier survival curves + CI
st_is 2 analysis
syntax varname [if] [in] [, Generate(string) Level(cilevel) Smooth ]
local id: char _dta[st_id]
local wt: char _dta[st_wt]	/* type of weight */
if !missing("`wt'") {
	di as err "weights not supported"
	exit 198
}
if missing("`generate'") local generate _km
quietly {
	marksample touse
	replace `touse' = 0 if _st == 0
	if "`id'"!="" {
		// check for multiple time records
		sort `touse' `id'
		tempvar cnt
		by `touse' `id': gen long `cnt'=_N
		sum `cnt' if `touse', meanonly
		if r(max) > 1 {
			noi di as err "multiple time records not allowed"
			exit 198
		}
		drop `cnt'
	}
	// Create binary treatment variable
	tempvar trt s0 s1 se0 se1
	egen int `trt' = group(`varlist') if `touse'
	sum `trt', meanonly
	if r(max) != 2 {
		noi di as err "two treatment arms required, " r(max) " found"
		exit 198
	}
	replace `trt' = `trt' - 1	// !! may still need to label treatment arms according to `varlist'

	foreach thing in "" _se _lci _uci {
		cap drop `generate'`thing'
	}
	forvalues j = 0 / 1 {
		cap drop `se`j''
		sts generate `s`j'' = s if `touse' == 1 & `trt' == `j'
		sts generate `se`j'' = se(s) if `touse' == 1 & `trt' == `j'
		replace `se`j'' = 0 if `trt' == `j' & reldif(`s`j'', 1) < 0.00001
		// Fill in Kaplan-Meier and its SE for "other" group
		fillmiss `s`j''  `touse' 1
		fillmiss `se`j'' `touse' 0
	}
	gen `generate' = `s1' - `s0'
	local z = -invnorm((100 - `level') / 200)
	gen `generate'_se = sqrt(`se0'^2 + `se1'^2)
	if !missing("`smooth'") {
		// Apply running line smooth to difference and SE
		tempvar s
		foreach thing in "" _se {
			running `generate'`thing' _t, gen(`s') nograph
			drop `generate'`thing'
			rename `s' `generate'`thing'
		}
	}
	gen `generate'_lci = `generate' - `z' * `generate'_se
	gen `generate'_uci = `generate' + `z' * `generate'_se
}
end

program define fillmiss, sortpreserve
version 8.1
args x touse filltop
// `x' is KM or se(KM)
quietly {
	count if missing(`x') & `touse'==1
	local m=r(N)
	if `m'==0 exit
	// Fill first value with `filltop': 1 for s(t), 0 for se(s(t))
	gsort -`touse' _t
	if missing(`x'[1]) replace `x'=`filltop' in 1
	while `m' {
		replace `x'=`x'[_n-1] if missing(`x') & `touse'==1
		count if missing(`x') & `touse'==1
		local m=r(N)
	}
}
end
