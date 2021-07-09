*! badiag.ado
*! version 1.3.1, 8 July 2013

* Updated (v3.1.1) 8 July 2013 to allow jitter
* Changed (v3.1) 15 August 2000 to handle if & in correctly.
*! written by PTSeed (p.seed@umds.ac.uk)
*! Diagonal Bland-Altman plots 
*!
*! syntax varlist(min=2 max=2 numeric) [if] [in], 
*! [saving(string) textsize(real 100)
*! ci zero mean graph(string) (graph options)];

* larger plotting symbols for overlapping points
* textsize can be set.
* update to stata 6.0


prog define badiag
set trace off
	version 6.0
	preserve

	#delim ;
	syntax varlist(min=2 max=2 numeric) [if] [in], 
[saving(string) XLABel(passthru) YLABel(passthru) textsize(real 100)
ci zero mean graph(string) jitter(passthru) * ];
	#delim cr


	parse "`varlist'", parse(" ")
	local m1 = "`1'"
	local m2 = "`2'"

	local delta_r = `textsize'*923/100
	local delta_c = `textsize'*444/100
 
	if "`saving'" ~= "" { local saving "saving(`saving')" }

	tempvar touse diff 
	qui mark `touse' `if' `in'
	qui markout `touse' `varlist'
	qui keep if `touse'

	baplot `m1' `m2', nograph

	qui gen `diff' = `m1' - `m2' 

	qui summ `diff'
	local n = _result(1)
	local xbar = _result(3)
	local sd = _result(4)^.5

	summ `m2', mean
	local l2 = _result(5)
	local u2 = _result(6)
	tempvar diag

	qui gen `diag' = `m2' 
	
	if "`xlabel'" == "" & "`ylabel'" == "" {
		summ `m2', mean
		local l2 = _result(5)
		local u2 = _result(6)
		summ `m1' , mean
		local l1 = _result(5)
		local u1 = _result(6)
		nicenum labs = 0 `l1' `u1' `l2' `u2'
		local xlabel "xlabel($labs)"
		local ylabel "ylabel($labs)"

	}


	local nobs = _N + 1 	
	qui set obs `nobs'
	qui replace `m2' = 0 if _n == _N
	qui replace `touse' = 1 if _n == _N


* loa
	tempvar lb ub
	qui gen `ub' = `m2' + `xbar' + 1.96*`sd'
	qui replace `ub' = . if `ub' < 0

	qui gen `lb' = `m2' + `xbar' - 1.96*`sd'
	summ `lb', mean
	if _result(5) < 0 {
		qui replace `lb' = . if `lb' < 0 
		local nobs = _N + 1 	
		qui set obs `nobs'
		qui replace `lb' = 0 if _n == _N
		qui replace `m2' = 1.96*`sd' - `xbar' if _n == _N
	}


* ci
	if "`ci'" ~= "" {
		tempvar lci uci
		qui gen `lci' = `m2' + `xbar' - invt(`n'-1,0.95)*`sd'/`n'^.5
		qui gen `uci' = `m2' + `xbar' + invt(`n'-1,0.95)*`sd'/`n'^.5

/*
		summ `lci', mean
		if _result(5) < 0 {
			qui replace `lci' = . if `lci' < 0 
			qui replace `lci' = 0 if _n == _N
			qui replace `m2' = 1.96*`sd' - `xbar' if _n == _N
	}
		summ `uci', mean
		if _result(5) < 0 {
			qui replace `uci' = . if `uci' < 0 
			qui replace `uci' = 0 if _n == _N
			qui replace `m2' = 1.96*`sd' - `xbar' if _n == _N
	}
*/
	}

	summ `m2' if `m2' ~= ., mean

* zero
	if "`zero'"  ~= "" {
		tempvar diag_z
		qui gen `diag_z' = `m2' 
	}
* mean
	if "`mean'" ~= "" | "`ci'" ~= "" | "`zero'" == "" {
		tempvar diag_m
		qui gen `diag_m' = `m2' + `xbar' 
	}

	sort `m1' `m2'
	tempvar f n
	qui by `m1' `m2': gen `f' = _N 
	qui by `m1' `m2': gen `n' = _n 
	qui replace `f' = 1 if `lb' ~= .
	qui replace `n' = 1 if `lb' ~= .

	gph open, `saving'
 	graph `m1' `diag_z' `diag_m' `ub' `lb' `lci' `uci' `m2' if `n' == 1 [fw=`f'], /*
*/ `xlabel' `ylabel' s(oiiiiii) c(.llllll) sort /*
*/ bbox(0,4500,23063,27563,`delta_r',`delta_c',0) `tsize' `graph' `jitter'
	gph close
	

end badiag


exit

