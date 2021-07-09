*! NJC 7 May 2003 
*! 1.6.1 NJC 7 Apr 2003       
*! 1.6.0 NJC 5 Dec 2002       
*! 1.5.0 NJC 24 March 1999        [STB-51: gr41]
* 1.4.0 NJC 17 March 1998
* 1.0.0 NJC 5 March 1998
program def distplot7
	version 7.0
	syntax varlist [if] [in] [fweight aweight/] /* 
	*/ [ , Generate(str) Freq BY(varname) YLOg L1title(str) /* 
	*/ Surv MONO MISSing * ]
	tokenize `varlist'
	local nvars : word count `varlist'
	tempvar touse gencum result copy

	mark `touse' `if' `in'
	if "`missing'" == "" {
		if "`by'" != "" { 
		 	markout `touse' `by', strok 
		}
	}
	else {
		if "`by'" == "" { 
			di as txt "missing only applies with by()" 
		}
	}

	qui count if `touse'
	if r(N) == 0 {
		di as err "no observations satisfy conditions"
		exit 2000
	}

	if "`exp'" == "" { 
		local exp "1" 
	}
	else {
		capture assert `exp' >= 0 `if' `in'
		if _rc {
			di as err "weight assumes negative values"
			exit 402
	        }    
	}

	if "`by'" != "" {
		if "`in'" != "" {
			di as err "in may not be combined with by"
			exit 190
		}
		if `nvars' > 1 {
			di as err "too many variables specified"
			exit 103
	    	}
	}

	tempvar wt
	qui gen `wt' = `exp'

	if `nvars' > 1 {
		preserve
		tempvar id col 
		gen long `id' = _n 
		tempname data datalbl 
		local i = 1 
		foreach v of var `varlist' { 
			rename `v' `data'`i'
			local xlbl "`xlbl' `v'"
			local i = `i' + 1 
		} 
	        qui reshape long `data', i(`id') j(`col') 
	    	forval i = 1 / `nvars' {
			label def `datalbl' `i' "`lbl`i''", modify
	    	}
		label val `data' `datalbl' 
	        local varlist "`data'"
		label var `varlist' "`xlbl'"
		local by "`col'"
	}

	if "`surv'" == "surv" {
		local ineq ">"
		local minus "-"
	}
	else local ineq "<=" 

	quietly {
		gen float `gencum' = `varlist' if `touse'
		sort `touse' `by' `gencum'
		local byf "by `touse' `by' :"
		`byf' gen float `result' = /*
		 */ sum((`wt') * (`gencum' != .)) if `touse'
		local ylbl = cond("`xlbl'" != "", "value", "`varlist'") 
		
		if "`freq'" == "" {
			`byf' replace `result' = `result' / `result'[_N]
			label var `result' "Probability `ineq' `ylbl'"
		}
		else label var `result' "Frequency `ineq' `ylbl'" 
		
		if "`surv'" == "surv" {
			`byf' replace `result' = `result'[_N] - `result'
		}
		
		replace `result' = . if `gencum' == .
		gen `copy' = `result'
		
		if "`ylog'" == "ylog" { 
			replace `result' = . if `result' == 0 
		}
		if "`by'" != "" & "`mono'" == "" {
			tempvar group
			`byf' gen byte `group' = _n == 1 if `touse'
			replace `group' = sum(`group')
			local max = `group'[_N]
			local bylab : value label `by'
			count if !`touse'
			local j = 1 + r(N)
			forval i = 1 / `max' {
				tempvar res`i'
		 		gen `res`i'' = `result' if `group' == `i'
         		        local byval = `by'[`j']
		    		if "`bylab'" != "" { 
					local byval : label `bylab' `byval' 
				}
			        label var `res`i'' "`byval'"
				local reslist "`reslist' `res`i''"
				count if `group' == `i'
				local j = `j' + r(N)
			}
			if "`l1title'" == "" {
				local l1title : variable label `result'
			}
		}
		else {
			if "`by'" != "" {
				tempvar bymin
				egen `bymin' = min(`gencum'), by(`by')
				gsort - `bymin' `by' `gencum' `minus' `result'
		        }
		    	local reslist "`result'"
		}
	}

	gra `reslist' `varlist', `options' `ylog' l1("`l1title'")

	if "`generate'" != "" & `nvars' == 1 {
		confirm new var `generate'
		qui gen `generate' = `copy'
		_crcslbl `generate' `result'
	}
end

