
* . type rifle.ado
*! rifle v1.0 CBerry AFowler 13July2017
version 14

program rifle, rclass
	version 14
	set more off
	set matsize 5000
	*! varlist contains outcome leader period unit
	syntax varlist(min=4 max=4) [if] [, Controls(varlist numeric fv) Permnum(integer 100) Report(integer 10) SAVING(string) REPLACE noSTITCH noGRAPH GROWTH noTREND] 

	tokenize `varlist'
	
	local permutations = `permnum'
	local reportevery = `report'

	local outcome `1'
	local leader `2'
	local period `3'
	local unit `4'
	
	preserve
	
	* Convert outcome to percentage change if requested
	if "`growth'" == "growth" {
	sort `unit' `period'
	tempvar growth
	quietly gen `growth' = (`outcome' - `outcome'[_n-1])/`outcome'[_n-1] if `unit' == `unit'[_n-1] & `period' == `period'[_n-1] + 1
	local outcome `growth'
	}
	
	if "`trend'" != "notrend" {
	* Residualize outcome by period
	quietly reg `outcome' i.`period' `controls'
	quietly predict resgrowth, residual
	local outcome resgrowth
	}
	
		* Create unit and leader IDs
		egen unitid = group(`unit')
		egen leaderid = group(`leader')
		local unit unitid	
		local leader leaderid
	
		* Drop if missing on any of the 4 required variables
		quietly drop if `outcome'==. | `unit'==. | `leader'==. | `period'==.
		
		if "`stitch'" != "nostitch" {
		*stitch together blocks of continuguous years
		*and generate new time variable that starts at 1 in each unit
		egen unit_time = group(`unit' `period')
		egen min = min(unit_time), by(`unit')
		gen stitchtime = unit_time - min + 1		
		local period stitchtime       
		}
		
		if "`stitch'" == "nostitch" {
		*drop cases where we only have 1 leader for a country-period
		quietly {
		egen leader_id = group(`unit' `leader')
		sort `unit' `period'
		gen unitperiod = _n
		replace unitperiod = unitperiod[_n-1] if `unit' == `unit'[_n-1] & `period' == `period'[_n-1] + 1
		egen sdleaderid = sd(leader_id), by(unitperiod)
		drop if sdleaderid == 0
		drop sdleaderid leader_id
		egen upid = group(unitperiod)
		drop unitperiod
		local unit upid
		egen min_period = min(`period'), by(`unit')
		g period2 = `period' - min_period + 1
		local period period2
		drop min_period
		}
		}
		
	* Run initial regression on real data
	quietly {
	tempname memhold
	tempfile Placebos  
	postfile `memhold' fstat r2  adjr2 real using `Placebos', replace
	areg `outcome', absorb(`leader')
	post `memhold' (e(F_absorb)) (e(r2)) (e(r2_a)) (1)
	}
	
	*generate identifier for leader stints
	sort `unit' `period'
	gen stint = _n
	quietly replace stint = stint[_n-1] if `leader' == `leader'[_n-1] & `unit' == `unit'[_n-1]
	egen stintid = group(stint)
	drop stint
	rename stintid stint
	
	* Do the permutations
	quietly sum `unit'
	local nunits = r(max)
	disp "Permutations Completed:"
	forvalues k = 1/`permutations' {
	quietly {
	*randomly permute leader stints as blocks
	gen random = uniform()
	sort `unit' `period'
	replace random = random[_n-1] if stint == stint[_n-1]
	egen stint2 = group(`unit' random)
	egen minstint = min(stint2), by(`unit')
	replace stint2 = stint2 - minstint + 1
	drop minstint
	gen leader2 = .
		forvalues j = 1/`nunits' {
		scalar counter = 0
		sum stint2 if `unit' == `j'
		local nstints = r(max)
			forvalues i = 1/`nstints' {
			sum `leader' if stint2 == `i' & `unit' == `j'
			replace leader2 = r(mean) if `period' > counter & `period' <= counter + r(N) & `unit' == `j'
			scalar counter = counter + r(N) 
			}
		}
	areg `outcome', absorb(leader2)
	post `memhold' (e(F_absorb)) (e(r2)) (e(r2_a)) (0) 
	drop leader2 stint2 random
	}
	if `k'/`reportevery' == round(`k'/`reportevery') {
	disp `k'
	* disp "$S_TIME  $S_DATE"
	}
}
postclose `memhold'
clear
use `Placebos'
if ("`saving'"!="") {
	save `saving', `replace'
	}
	
*---------------------  Compute and display p-values

	quietly {
	foreach i in fstat r2 adjr2 {
	gen `i'_temp = `i' if real == 1	
	egen `i'_real = max(`i'_temp)		/* Why is this step necessary */
	gen `i'_bigger = `i' > `i'_real
	replace `i'_bigger = . if real==1  /* Ensure real data ommitted when pvalue compted below */
	}
	}
	
	quietly {
	sum r2_real
	scalar realr2 = r(mean)
	local realr2 = r(mean)
	sum r2
	scalar avg = r(mean)
	scalar diff = realr2 - avg
	sum r2_bigger
	scalar pval = r(mean)
	local pval = r(mean)
	}
	
	display as text "--------------------------------------------------"
	display as text "R2 in real data: " as result %-5.4g realr2
	display as text "Avg R2 in permuted data: " as result %-5.4g  avg
	display as text "Difference: " as result %-5.4f  diff
	display as text "p-value: " as result %-5.4g  pval
	display as text "--------------------------------------------------"	

	return scalar real_r2 = realr2
	return scalar avg_r2 = avg
	return scalar diff = diff
	return scalar pval = pval
	
*---------------------  Make graph

if "`graph'" != "nograph" {
quietly {
sum r2
local min = floor(r(min)*100)/100
local max = ceil(r(max)*100)/100
	hist r2 if real == 0, xline(`realr2', lpattern(dash) lwidth(thick)) bin(100) fraction title("RIFLE: Distribution Under the Null") ///
		xtitle("R-squared from Permuted Data") ///
		caption("Dashed line shows R-squared from the real data." "p-value = `pval'", tstyle(smbody) box just(center))
	gr_edit .xaxis1.reset_rule `min' `max' .01 , tickset(major) ruletype(range) 
	}
}

end


