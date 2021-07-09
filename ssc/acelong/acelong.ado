*! acelong: Multilevel mixed-effects ACE variance decomposition models for "long" - one person per data row - formatted twin data (wrapper for 'gsem')
*! version 1.4 03/13/19
program define acelong, rclass
	version 14.1
	syntax varlist(min=4) [if] [in] [fweight pweight iweight] [, rsg mp gw dzc(real .5) mzc(real 1) iwc tcr total ese *]
	marksample touse
	tokenize `varlist'
	* define locals to initialize model
	local one `1'
	macro shift
	local two `1'
	macro shift
	local three `1'
	macro shift
	local four `1'
	macro shift 
	quietly: gsem `one' <- if `touse' [`weight' `exp'], `options'
	local vce "`e(vce)'"
	if "`vce'" == "cluster" {
		local vce "cluster `e(clustvar)'"
		local vc2 "cluster"
		local cva "`e(clustvar)'"
		local ncl "`e(N_clust)'"
	} 
	local lev = r(level)
	local lim = 1 - (1 - `lev'/100)/2
	local f = substr(e(family1), 1, 10)
	local l = e(link1)
	local nc = r(label1) 
	if "`total'" == "total" {
		local te = _b[var(e.`one'):_cons]
		local ts = _se[var(e.`one'):_cons]
	}
	local ee = 1
	if "`l'" == "logit" {
		local ee = _pi^2/3
	}
	local es = 0
	* check if syntax is correct
	if  ("`rsg'" == "rsg" & "`mp'" == "mp") | ("`rsg'" == "rsg" & "`gw'" == "gw") | ("`mp'" == "mp" & "`gw'" == "gw") {
		display as error "Only one model type-option ('rsg' or 'mp' or 'gw') allowed with 'acelong'."
	}
	quietly: assert "`gw'" == "" & "`mp'" == "" if "`rsg'" == "rsg"
	quietly: assert "`mp'" == "" if "`gw'" == "gw"
	if "`f'" != "gaussian" & "`f'" != "gaussian ," & "`f'" != "bernoulli" & "`f'" != "ordinal" {
		display as error "Family '`f'' is not supported by 'acelong'."
	}
	quietly: assert "`f'" == "gaussian" | "`f'" == "gaussian ," | "`f'" == "bernoulli" | "`f'" == "ordinal"
	if "`l'" != "identity" & "`l'" != "probit" & "`l'" != "logit" {
		display as error "Link '`l'' is not supported by 'acelong'."
	}
	quietly: assert "`l'" == "identity" | "`l'" == "probit" | "`l'" == "logit"
	if `two' < 1 | `two' > 2 {
		display as error "The variable indicating zygosity (second variable in the variable list) has to be coded 1 for monozygotic twins and 2 for dizygotic twins."
	}
	quietly: assert `two' == 1 | `two' == 2
	if `dzc' <= 0 | `dzc' >= 1 {
		display as error "The genetic correlation for dizygotic twin pairs ('dzc') has to be larger than 0 and smaller than 1."
	}
	quietly: assert `dzc' > 0 & `dzc' < 1
	if `mzc' <= `dzc' | `mzc' > 1 {
		display as error "The genetic correlation for monozygotic twin pairs ('mzc') has to be larger than `dzc' (the genetic correlation for dizygotic twin pairs) and not larger than 1."
	}
	quietly: assert `mzc' > `dzc' & `mzc' <= 1
	if "`gw'" == "gw" & `dzc' != .5 {
		display as error "No option 'dzc' for Gou/Wang(2002)-model ('gw'). For 'gw' the additive genetic correlation for dizygotic twin pairs ('dzc') is 0.5."
	}
	quietly: assert `dzc' == .5 if "`gw'" == "gw"
	if "`gw'" == "gw" & `mzc' != 1 {
		display as error "No option 'mzc' for Gou/Wang(2002)-model ('gw'). For 'gw' the additive genetic correlation for monozygotic twin pairs ('mzc') is 1."
	}
	quietly: assert `mzc' == 1 if "`gw'" == "gw"
	if ("`f'" != "gaussian" | "`l'" != "identity") & "`tcr'" == "tcr" {
		display as error "Option 'tcr' is only available for uncensored linear models ('family(gaussian) link(indentity)')."
	}
	quietly: assert "`f'" == "gaussian" & "`l'" == "identity" if "`tcr'" == "tcr"
	if ("`f'" != "gaussian" | "`l'" != "identity") & "`total'" == "total" {
		display as error "Option 'total' is only available for uncensored linear models ('family(gaussian) link(indentity)')."
	}
	quietly: assert "`f'" == "gaussian" & "`l'" == "identity" if "`total'" == "total"
	if ("`weight'" != "") & "`total'" == "total" {
		display as error "Option 'total' is only available for models without weights."
	}
	quietly: assert "`weight'" == "" if "`total'" == "total"
	if "`f'" != "bernoulli" & "`f'" != "ordinal" & "`ese'" == "ese" {
		display as error "Option 'ese' is only applicable for ordinal or binary models ('family(ordinal)' or 'family(bernoulli)')."
	}
	quietly: assert "`f'" == "ordinal" & "`f'" == "bernoulli" if "`ese'" == "ese"
	display "Assumed genetic correlation of dizygotic twins: " `dzc'
	if `mzc' != 1 {
		display "Assumed genetic correlation of monozygotic twins: " `mzc'
	}
	* define temporary variables and names
	tempvar i res c0 c1 a au av ij n nval bv sev z p zp lb ub b b2 se se2 ci ci2
	tempname start n_val
	* generate twin identifier
	bysort `three' (`two'): generate `i' = _n
	* calculate additional twin correlations
	if "`tcr'" == "tcr" {
		quietly: regress `one' `*' if `touse' [`weight' `exp']
		quietly: predict `res' if e(sample), residual
		quietly: generate `c0' = `res' if `i' == 2
		quietly: bysort `three': egen `c1' = min(`c0')
		quietly: replace `c0' = `res'
		forvalues x = 1/2 {
			quietly: summarize `c0' if `two' == `x' & `i' == 1 & `touse'
			quietly: replace `c0' = (`c0' - r(mean))/r(sd) if `two' == `x' & `i' == 1 & `touse'
			quietly: summarize `c1' if `two' == `x' & `i' == 1 & `touse'
			quietly: replace `c1' = (`c1' - r(mean))/r(sd) if `two' == `x' & `i' == 1 & `touse'
			if "`vce'" == "oim" | "`vce'" == "opg" {
				quietly: regress `c0' `c1' if `two' == `x' & `i' == 1 & `touse' [`weight' `exp']
			}
			else {
				quietly: regress `c0' `c1' if `two' == `x' & `i' == 1 & `touse' [`weight' `exp'], vce(`vce')
			}
			local e`x' = _b[`c1']
			local s`x' = _se[`c1']
		}
	}
	* Guo/Wang(2002)-model
	if "`gw'" == "gw" {
		quietly: generate double `ij' = `three' if `two' == 1
		quietly: replace `ij' = `four' if `two' == 2
		gsem `one' <- J[`three']@1 IJ[`three'>`ij']@1 `*' if `touse' [`weight' `exp'], `options' notable 
		quietly: lincom 2*_b[var(IJ[`three'>`ij']):_cons]
		local ae = r(estimate)
		local as = r(se)
		quietly: lincom _b[var(J[`three']):_cons] - _b[var(IJ[`three'>`ij']):_cons]
		local ce = r(estimate)
		local cs = r(se)
		if ("`f'" == "gaussian" & "`total'" != "total") | "`f'" == "gaussian ," {
			quietly: lincom _b[var(J[`three']):_cons] + _b[var(IJ[`three'>`ij']):_cons] + _b[var(e.`one'):_cons]
			local te = r(estimate)
			local ts = r(se)
		}
		if "`f'" == "bernoulli" | "`f'" == "ordinal" { 
			quietly: lincom _b[var(J[`three']):_cons] + _b[var(IJ[`three'>`ij']):_cons] + `ee'
			local te = r(estimate)
			local ts = r(se)
			if "`ese'" == "ese" {
				local es = r(se)
			}
		}
	}
	* McArdle/Prescott(2005)-model
	else if "`mp'" == "mp" {
		quietly: generate double `a' = 1 
		quietly: replace `a' = sqrt(`dzc') if `two' == 2
		quietly: generate double `au' = 0
		quietly: replace `au' = sqrt(`mzc' - `dzc') if `two' == 2 & `i' == 1
		quietly: generate double `av' = 0
		quietly: replace `av' = sqrt(`mzc' - `dzc') if `two' == 2 & `i' == 2
		if "`iwc'" == "iwc" {
			display as text "Without constraints:"
			gsem `one' <- C[`three']@1 c.`a'#A[`three']@1 c.`au'#AU[`three']@1 c.`av'#AV[`three']@1 `*' if `touse' [`weight' `exp'], notable noheader `options' ///
			cov(C[`three']*A[`three']@0 C[`three']*AU[`three']@0 C[`three']*AV[`three']@0 A[`three']*AU[`three']@0 A[`three']*AV[`three']@0 AU[`three']*AV[`three']@0)
			matrix `start' = e(b)
			display as text "With constraints:"
			gsem `one' <- C[`three']@1 c.`a'#A[`three']@1 c.`au'#AU[`three']@1 c.`av'#AV[`three']@1 `*' if `touse' [`weight' `exp'], from(`start') notable `options' ///
			var(A[`three']@a AU[`three']@a AV[`three']@a) ///
			cov(C[`three']*A[`three']@0 C[`three']*AU[`three']@0 C[`three']*AV[`three']@0 A[`three']*AU[`three']@0 A[`three']*AV[`three']@0 AU[`three']*AV[`three']@0)
		}
		else {
			gsem `one' <- C[`three']@1 c.`a'#A[`three']@1 c.`au'#AU[`three']@1 c.`av'#AV[`three']@1 `*' if `touse' [`weight' `exp'], notable `options' ///
			var(A[`three']@a AU[`three']@a AV[`three']@a) ///
			cov(C[`three']*A[`three']@0 C[`three']*AU[`three']@0 C[`three']*AV[`three']@0 A[`three']*AU[`three']@0 A[`three']*AV[`three']@0 AU[`three']*AV[`three']@0)
		}
		local ae = _b[var(A[`three']):_cons]
		local as = _se[var(A[`three']):_cons]
		local ce = _b[var(C[`three']):_cons]
		local cs = _se[var(C[`three']):_cons]
		if ("`f'" == "gaussian" & "`total'" != "total") | "`f'" == "gaussian ," { 
			quietly: lincom _b[var(A[`three']):_cons] + _b[var(C[`three']):_cons] + _b[var(e.`one'):_cons]
			local te = r(estimate)
			local ts = r(se)
		}
		if "`f'" == "bernoulli" | "`f'" == "ordinal" { 
			quietly: lincom _b[var(A[`three']):_cons] + _b[var(C[`three']):_cons] + `ee'
			local te = r(estimate)
			local ts = r(se)
			if "`ese'" == "ese" {
				local es = r(se)
			}
		}
	}
	* Rabe-Hesketh/Skrondal/Gjessing(2008)-model
	else {
		quietly: generate double `a' = 1 
		quietly: replace `a' = sqrt(`dzc') if `two' == 2
		quietly: generate double `au' = 0
		quietly: replace `au' = sqrt(`mzc' - `dzc') if `two' == 2
		if "`iwc'" == "iwc" {
			display as text "Without constraints:"
			gsem `one' <- C[`three']@1 c.`a'#A[`three']@1 c.`au'#AU[`three'>`four']@1 `*' if `touse' [`weight' `exp'], notable noheader `options' cov(C[`three']*A[`three']@0)
			matrix `start' = e(b)
			display as text "With constraints:"
			gsem `one' <- C[`three']@1 c.`a'#A[`three']@1 c.`au'#AU[`three'>`four']@1 `*' if `touse' [`weight' `exp'], from(`start') notable `options' ///
			var(A[`three']@a AU[`three'>`four']@a) cov(C[`three']*A[`three']@0)
		}
		else {
			gsem `one' <- C[`three']@1 c.`a'#A[`three']@1 c.`au'#AU[`three'>`four']@1 `*' if `touse' [`weight' `exp'], notable `options' ///
			var(A[`three']@a AU[`three'>`four']@a) cov(C[`three']*A[`three']@0)
		}
		local ae = _b[var(A[`three']):_cons]
		local as = _se[var(A[`three']):_cons]
		local ce = _b[var(C[`three']):_cons]
		local cs = _se[var(C[`three']):_cons]
		if ("`f'" == "gaussian" & "`total'" != "total") | "`f'" == "gaussian ," {
			quietly: lincom _b[var(A[`three']):_cons] + _b[var(C[`three']):_cons] + _b[var(e.`one'):_cons]
			local te = r(estimate)
			local ts = r(se)
		}
		if "`f'" == "bernoulli" | "`f'" == "ordinal" { 
			quietly: lincom _b[var(A[`three']):_cons] + _b[var(C[`three']):_cons] + `ee'
			local te = r(estimate)
			local ts = r(se)
			if "`ese'" == "ese" {
				local es = r(se)
			}
		}
	}
	* define additional locals for quantities estimated
	if "`l'" == "identity" {
		local ee = _b[var(e.`one'):_cons]
		local es = _se[var(e.`one'):_cons]
	}
	if "`f'" == "ordinal" {
		local me = .
		local ms = .
	}
	else {
		local me = _b[`one':_cons]
		local ms = _se[`one':_cons]
	}
	if "`gw'" == "gw" {
		local k = e(k) - 3
	}
	else if "`mp'" == "mp" {
		local k = e(k) - 5
	}
	else {
		local k = e(k) - 4
	}
	if "`f'" == "bernoulli" | "`f'" == "ordinal" {
		local k = `k' + 1
	}
	local names : colnames e(b)
	tokenize `names'
	local l = 1
	local c = 1
	forvalues x = 1/`k' {
		if "`nc'" == "(omitted)" & "``x''" == "_cons" {
			macro shift
			local k = `k' - 1
		}
		if "``x''" !=  "J[`three']" & "``x''" != "IJ[`three'>`ij']" & "``x''" != "C[`three']" & "``x''" != "c.`a'#A[`three']" & "``x''" != "c.`au'#AU[`three']" & "``x''" != "c.`av'#AV[`three']" & "``x''" != "c.`au'#AU[`three'>`four']" {
			local vl`l' "``x''"
			if "`f'" == "ordinal" & "`vl`l''" == "_cons" {
				local vl`l' = "_cut`c'"
				local c = `c' + 1 
			}
			local l = `l' + 1
		}
	}
	if "`gw'" == "gw" {
		local k = `k' - 2
	}
	else if "`mp'" == "mp" {
		local k = `k' - 4
	}
	else {
		local k = `k' - 3
	}
	* define labels for quantities estimated
	quietly: generate `n' = _n
	label variable `n' "`one'"
	label define `n_val' 1 "mean:"
	forvalues x = 1/`k' {
		label define `n_val' `=1+`x'' "`vl`x''", add
	}
	label define `n_val' `=`k'+2' "variance:" `=`k'+3' "A" `=`k'+4' "C" `=`k'+5' "E" `=`k'+6' "A+C+E" `=`k'+7' "A %" `=`k'+8' "C %" `=`k'+9' "E %", add
	if "`tcr'" == "tcr" {
		label define `n_val' `=`k'+10' "obs.cor.:" `=`k'+11' "MZr" `=`k'+12' "DZr", add
	}
	if "`total'" == "total" {
		label define `n_val' `=`k'+6' "total", modify
	}
	label values `n' `n_val'
	quietly: decode `n', generate(`nval')
	* store point estimates
	quietly: generate double `bv' = .
	forvalues x = 1/`k' {
		if `"`=substr("`vl`x''", 1, 4)'"' == "_cut" {
			quietly: replace `bv' = _b[`one'`vl`x'':_cons] if `n' == `=`x'+1'
		}
		else {
			quietly: replace `bv' = _b[`one':`vl`x''] if `n' == `=`x'+1'
		}
	}
	quietly: replace `bv' = `ae' if `n' == `=`k'+3'
	quietly: replace `bv' = `ce' if `n' == `=`k'+4'
	quietly: replace `bv' = `ee' if `n' == `=`k'+5'
	quietly: replace `bv' = `te' if `n' == `=`k'+6'
	quietly: replace `bv' = `ae'/`te'*100 if `n' == `=`k'+7'
	quietly: replace `bv' = `ce'/`te'*100 if `n' == `=`k'+8'
	quietly: replace `bv' = `ee'/`te'*100 if `n' == `=`k'+9'
	if "`tcr'" == "tcr" {
		quietly: replace `bv' = `e1' if `n' == `=`k'+11'
		quietly: replace `bv' = `e2' if `n' == `=`k'+12'
	}
	label variable `bv' "Coef."
	* store standard errors
	quietly: generate double `sev' = .
	forvalues x = 1/`k' {
		if `"`=substr("`vl`x''", 1, 4)'"' == "_cut" {
			quietly: replace `sev' = _se[`one'`vl`x'':_cons] if `n' == `=`x'+1'
		}
		else {
			quietly: replace `sev' = _se[`one':`vl`x''] if `n' == `=`x'+1'
		}
	}
	quietly: replace `sev' = `as' if `n' == `=`k'+3'
	quietly: replace `sev' = `cs' if `n' == `=`k'+4'
	quietly: replace `sev' = `es' if `n' == `=`k'+5'
	quietly: replace `sev' = `ts' if `n' == `=`k'+6'
	quietly: replace `sev' = `as'/`te'*100 if `n' == `=`k'+7' 
	quietly: replace `sev' = `cs'/`te'*100 if `n' == `=`k'+8'
	quietly: replace `sev' = `es'/`te'*100 if `n' == `=`k'+9'
	if "`tcr'" == "tcr" {
		quietly: replace `sev' = `s1' if `n' == `=`k'+11'
		quietly: replace `sev' = `s2' if `n' == `=`k'+12'
	}
	label variable `sev' "Robust S.E."
	if "`vce'" == "oim" {
		label variable `sev' "Std. Err."
	}
	if "`vce'" == "opg" {
		label variable `sev' "OPG S.E."
	}
	* calculate z-values and p-values
	quietly: generate double `z' = `bv'/`sev'
	quietly: generate double `p' = 2*(1 - normal(abs(`z')))
	quietly: tostring `z', replace format(%9.2f) force
	quietly: tostring `p', replace format(%9.3f) force
	quietly: generate `zp' = `z' + "   " + `p'
	quietly: replace `zp' = "" if `zp' == ".   ."
	label variable `zp' "z    P>|z|"
	* calculate confidence intervals
	quietly: generate double `lb' = `bv' - invnormal(`lim')*`sev' if _n <= `=`k'+1' | _n >= `=`k'+11'
	quietly: replace `lb' = exp(ln(`bv') - invnormal(`lim')*`sev'/`bv') if _n > `=`k'+1' & _n <= `=`k'+6'
	quietly: replace `lb' = invlogit(logit(`bv'/100) - invnormal(`lim')*`sev'/`bv')*100 if _n > `=`k'+6' & _n <= `=`k'+9'
	label variable `lb' "[`lev'% Conf."
	quietly: generate double `ub' = `bv' + invnormal(`lim')*`sev' if _n <= `=`k'+1' | _n >= `=`k'+11'
	quietly: replace `ub' = exp(ln(`bv') + invnormal(`lim')*`sev'/`bv') if _n > `=`k'+1' & _n <= `=`k'+6'
	quietly: replace `ub' = invlogit(logit(`bv'/100) + invnormal(`lim')*`sev'/`bv')*100 if _n > `=`k'+6' & _n <= `=`k'+9'
	label variable `ub' "Interval]"
	* display results
	if "`vc2'" == "cluster" {
		display "				   (Std. Err. adjusted for {bf:`ncl'} clusters in `cva')"
	}
	if "`tcr'" == "tcr" {
		tabdisp `n' in 1/`=`k'+12', cell(`bv' `sev' `zp' `lb' `ub')
	}
	else {
		tabdisp `n' in 1/`=`k'+9', cell(`bv' `sev' `zp' `lb' `ub')
	}
	* store results of variance decomposition in return list
	return scalar level = `lev'
	return scalar gdzc = `dzc'
	return scalar gmzc = `mzc'
	mkmat `bv' in `=`k'+3'/`=`k'+9', matrix(`b') rownames(`nval')
	if "`tcr'" == "tcr" {
		mkmat `bv' in `=`k'+11'/`=`k'+12', matrix(`b2') rownames(`nval')
		matrix `b' = `b' \ `b2'
	}																				
	matrix colnames `b' = b
	mkmat `sev' in `=`k'+3'/`=`k'+9', matrix(`se') rownames(`nval')
	if "`tcr'" == "tcr" {
		mkmat `sev' in `=`k'+11'/`=`k'+12', matrix(`se2') rownames(`nval')
		matrix `se' = `se' \ `se2'
	}
	matrix colnames `se' = se
	mkmat `lb' `ub' in `=`k'+3'/`=`k'+9', matrix(`ci') rownames(`nval')
	if "`tcr'" == "tcr" {
		mkmat `lb' `ub' in `=`k'+11'/`=`k'+12', matrix(`ci2') rownames(`nval')
		matrix `ci' = `ci' \ `ci2'
	}
	matrix colnames `ci' = lb ub
	foreach x in ci se b {
		return matrix `x' = ``x''
	}
end
