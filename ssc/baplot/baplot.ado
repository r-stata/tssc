*! baplot.ado version 1.4 written by PTS (p.seed@umds.ac.uk) (STB-55: sbe33)
*! Produces Bland-Altman plots for two variables
*! See Bland & Altman Lancet Feb 8 1986, pp 307-310
*!
*! syntax: baplot var1 var2 if in, symbol(symbol) format(%6.3f) avlab("Average") difflab("Difference") yline(str) textsize(#) other graph options 

* Now allows choice of symbol, and extra ylines Feb 8 1996
* larger plotting symbols for overlapping points
* jitter as an alternative


* Correction to the formula for Pitman's test
* as e-mail from Garry Anderson <g.anderson@unimelb.edu.au> 

* 1.96 SD added as an option



cap prog drop baplot
prog define baplot , rclass
version 6.0

* set trace off

	syntax varlist(min=2 max=2 numeric) [if] [in], /*
*/ [Symbol(string) format(string) avlab(string) difflab(string) /*
*/ novars noGRaph ci zero mean yline(string) diag saving(string) /*
*/ text(real 100) ratio(real 1) err(real 2) overlap(string) jitter(passthru) *]"

	parse "`varlist'", parse(" ")
	local m1 "`1'"
	local m2 "`2'"

	if "`symbol'" == "" { local symbol "o" }
	if "`format'" == "" {local format "%6.3f" }
	if "`saving'" ~= "" { local saving "saving(`saving')" }
	if "`ci'" ~= "" {local mean = "mean" }


	preserve
	tempvar touse
	mark `touse' `if' `in'
	markout `touse' `m1' `m2'
	qui keep if `touse'

	tempvar av diff 
	if "`avlab'" == "" { local avlab "Average" }
	if lower("`avlab'") == "nolab" { local avlab " " }

	if "`difflab'" == "" { local difflab "`m1' - `m2'" }
	if lower("`difflab'") == "nolab" { local difflab " " }
	qui gen `av' = (`m1' + `m2')/2 
	qui gen `diff' = `m1' - `m2' 
	label var `av' "`avlab'"
	label var `diff' "`difflab'"

	qui summ `diff' if `touse'
	local xbar = _result(3)
	local sd = _result(4)^.5
	local n = _result(2)
	local se = `sd'/`n'^.5
	local t = invt(_result(2)-1, .95)
	local lrr = `xbar' - `err'*`sd'
	local urr = `xbar' + `err'*`sd'
	local min = _result(5)
	local max = _result(6)
	local lcb = `xbar' - `t'*`se'
	local ucb = `xbar' + `t'*`se'

	summ `av', meanonly
	local xmin = _result(5)
	local xmax = _result(6)

	local yline "`lrr', `urr'"
	if "`ci'" ~= "" {
		local yline "`yline', `lcb', `ucb'"
		}
	if "`mean'" ~= "" | "`zero'" == "" {local yline "`yline', `xbar'"}
	if "`zero'" ~= "" {local yline "`yline', 0"}

	qui corr `av' `diff'
	local r = _result(4)
	local n = _result(1)
	local sig = tprob(`n'-2, `r'*((`n'-2)/(1-`r'*`r'))^.5)


	#delim ;
	di in gr _n "Bland-Altman comparison of `m1' and `m2'";
	di in gr "Limits of agreement (Reference Range for difference): " in ye  `format' `lrr' 
		in gr " to " in ye `format' `urr' ;
	di in gr "Mean difference: " in ye `format' `xbar' 
		in gr " (CI " in ye `format' `lcb' 
		in gr " to " in ye `format' `ucb' 
		in gr ") ";
	di in gr "Range : " in ye  `format' `xmin'
		in gr " to " in ye `format' `xmax';
	di in gr "Pitman's Test of difference in variance: r = " in ye `format' `r' 
		in gr ", n = " in ye `n' 
		in gr ", p =" in ye `format' `sig' ;
	#delim cr

	if "`vars'" ~= "" {
		qui corr `m1' `m2', cov
		local tau = _result(4)
		qui summ `m1'
		local err1 = _result(4) - `tau' 
		qui summ `m2'
		local err2 = _result(4) - `tau' 
		di in gr "Estimated variance of true measure: " in ye `format' `tau'
		di in gr "Estimated error variance (`1'): " in ye `format' `err1'
		di in gr "Estimated error variance (`2'): " in ye `format' `err2'
		di in gr "Very low or negative error variances may indiate that modelling assumptions are violated."
		}

	global S_1 `xbar'
	global S_2 `lrr'
	global S_3 `urr'

	return scalar xbar = `xbar'
	return scalar  lrr = `lrr'
	return scalar  urr = `urr'


	if "`graph'" == "" & "`diag'" == "" { 
		sort `diff' `av'
		tempvar f n
		qui by `diff' `av': gen `f' = _N if `diff' ~= . & `av' ~= .
		if "`overlap'" == "size" {	local wt  "[fw=`f']" }
		qui by `diff' `av': gen `n' = _n if `diff' ~= . & `av' ~= .
di "		graph `diff' `av' if `touse' & `n' == 1 `wt', symbol(`symbol') `xlabel' `ylabel' yline(`yline') `saving' `options' `jitter'
		graph `diff' `av' if `touse' & `n' == 1 `wt', symbol(`symbol') `xlabel' `ylabel' yline(`yline') `saving' `options' `jitter'
		}

	else if "`diag'" ~= "" {

		local nobs = _N + 1 	
		qui set obs `nobs'
		qui replace `m2' = 0 if `m2' == .

* loa		
			tempvar lb ub
			qui gen `ub' = `m2' + `xbar' + `err'*`sd'
			qui replace `ub' = . if `ub' < 0
			summ `ub', mean
			qui replace `ub' = . if `ub' > _result(5) & `ub' < _result(6)

			qui gen `lb' = `m2' + `xbar' - `err'*`sd'
			summ `lb', mean
			if _result(5) < 0 {
				qui replace `lb' = . if `lb' < 0 
				local nobs = _N + 1 	
				qui set obs `nobs'
				qui replace `lb' = 0 if _n == _N
				qui replace `m2' = `err'*`sd' - `xbar' if _n == _N
				}
			summ `lb', mean
			qui replace `lb' = . if `lb' > _result(5) & `lb' < _result(6)

* ci
			if "`ci'" ~= "" {
				tempvar lci uci
				qui gen `lci' = `m2' + `xbar' - invt(`n'-1,0.95)*`sd'/`n'^.5
				qui gen `uci' = `m2' + `xbar' + invt(`n'-1,0.95)*`sd'/`n'^.5
				summ `lci', mean
				if _result(5) < 0 {
					qui replace `lci' = . if `lci' < 0 
 					local nobs = _N + 1 	
					qui set obs `nobs'
					qui replace `lci' = 0 if _n == _N
					qui replace `m2' = invt(`n'-1,0.95)*`sd'/`n'^.5 - `xbar' if _n == _N
					}
				summ `uci', mean
				if _result(5) < 0 {
					qui replace `uci' = . if `uci' < 0 
					local nobs = _N + 1 	
					qui set obs `nobs'
					qui replace `uci' = 0 if _n == _N
					qui replace `m2' = - invt(`n'-1,0.95)*`sd'/`n'^.5 - `xbar' if _n == _N
					}
				summ `lci', mean
				qui replace `lci' = . if `lci' > _result(5) & `lci' < _result(6)
				summ `uci', mean
				qui replace `uci' = . if `uci' > _result(5) & `lci' < _result(6)
				}

			summ `m2' if `m2' ~= ., mean
			tempvar diag

* zero
			if "`zero'"  ~= "" | "`mean'" == "" {
				qui gen `diag' = `m2' if `m2' == _result(5) | `m2' == _result(6)
				}

* mean
			else {
				qui gen `diag' = `m2' + `xbar' if `m2' == _result(5) | `m2' == _result(6)
				summ `diag', mean
				if _result(5) < 0 {
					qui replace `diag' = . if `diag' < 0 
					local nobs = _N + 1 	
					qui set obs `nobs'
					qui replace `diag' = 0 if _n == _N
					qui replace `m2' =  - `xbar' if _n == _N
					}
				}

			sort `m1' `m2'
			tempvar f n
			qui by `m1' `m2': gen `f' = _N
			qui by `m1' `m2': gen `n' = _n

			if ("`xlabel'" == "" | "`ylabel'" == "") & index("`options'","xlab") == 0 &  index("`options'","ylab") == 0  {
				nicenum labels = 0 `m1' `m2'
				local xlabel xlab($labels) 
				local ylabel ylab($labels) 
				}

		local r_tx = int(923 * `text'/100)
		local c_tx = int(444 * `text'/100)
		local c_min = int(16000 - (23063*`ratio'/2))
		local c_max = int(16000 + (23063*`ratio'/2))
di "bbox(0,`c_min',23063,`c_max',`r_tx',`c_tx',0) "
		
		gph open, `saving'

		if "`overlap'" == "size" {	local wt  "[fw=`f']" }
		graph `m1' `diag' `ub' `lb' `lci' `uci' `m2' if `n' == 1 `wt', /*
*/ `xlabel' `ylabel' s(oiiiii) c(.lllll) sort `jitter' /*
*/ bbox(0,`c_min',23063,`c_max',`r_tx',`c_tx',0)  `options'
		gph close
		}

end
exit
