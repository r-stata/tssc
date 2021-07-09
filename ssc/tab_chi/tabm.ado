*! 2.2.1 NJC 20 December 2016
* 2.2.0 NJC 31 March 2016
* 2.1.0 NJC 25 July 2015
* 2.0.0 NJC 1 November 2010
* 1.4.0 NJC 4 November 2005
* 1.3.1 NJC 11 December 2002
* 1.3.0 NJC 10 December 2002
* 1.2.0 NJC 5 February 1999
* 1.0.0 NJC 22 December 1998
program tabm, byable(recall)
	version 8.2
	syntax varlist(min=2) [if] [in] [fw aw iw] ///
	[, ONEway transpose Valuelabel(string) MISSing replace *]

	marksample touse, novarlist

	if "`replace'" != "" & _by() {
		di as err "replace not allowed with by:"
		exit 198
	}

	qui count if `touse'
	if r(N) == 0 error 2000

	if "`exp'" != "" {
		tempvar wt
		gen `wt' `exp'
		local w "[`weight' = `wt']"
	}

	capture confirm string variable `: word 1 of `varlist''
	local strOK = _rc == 0
	local j = 1
	foreach v of local varlist {
		capture confirm string variable `v'
		if (`strOK' & _rc == 0) | (!`strOK' & _rc) {
			local OKlist `OKlist' `v'
			local slist `slist' `v' `wt'
			local lbl`j' : variable label `v'
			if `"`lbl`j''"' == "" local lbl`j' "`v'"
			local ++j
		}
		else local badlist `badlist' `v'  
	}

	if "`badlist'" != "" {
		di _n "{res}`badlist' {txt}different type, so excluded"
	}

	local nvars : word count `OKlist'
	// normal tabulation, no need to stack
	if `nvars' == 1 {
		tab `OKlist' `w', `missing' `options'
		exit 0
	}

	if "`vallbl'" == "" {
		local 1 : word 1 of `slist'
		local vallbl : value label `1'
	}
	// insurance policy
	if "`vallbl'" != "" {
		tempfile flabels
		qui label save `vallbl' using `"`flabels'"'
	}

	preserve
	tempvar data
	stack `slist' if `touse', into(`data' `wt') clear
	label var _stack "variable"
	label var `data' "values"
	forval i = 1 / `nvars' {
		label def _stack `i' `"`lbl`i''"', add
	}
	label val _stack _stack

	if "`vallbl'" != "" {
		if `strOK' di _n as txt "may not label strings"
		else {
			capture label list `vallbl'
			if _rc run `flabels'
			label val `data' `vallbl'
		}
	}

	if "`oneway'" != "" {
		tab `data' `w', `missing' `options'
	}
	else {
		if "`transpose'" == "" {
			tab _stack `data' `w', `missing' `options'
		}
		else tab `data' _stack `w' , `missing' `options'
	}

	if "`replace'" != "" {
		clonevar _values = `data'
		if "`w'" != "" {
			clonevar _weight = `wt'
			label var _weight "weights"
		}
		restore, not
	}
end
