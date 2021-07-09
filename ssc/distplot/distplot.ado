*! 2.2.2 NJC 15 Sep 2017                    
* 2.2.1 NJC 29 Mar 2010                    
* 2.2.0 NJC 18 Dec 2009                    
* 2.1.0 NJC 17 Aug 2005                    
* 2.0.2 NJC 12 Aug 2004                    
* 2.0.1 NJC 29 Sep 2003 tscale -> trscale
* 2.0.0 NJC 7 May 2003       
* 1.6.1 NJC 7 Apr 2003       
* 1.6.0 NJC 5 Dec 2002       
* 1.5.0 NJC 24 Mar 1999        [STB-51: gr41]
* 1.4.0 NJC 17 Mar 1998
* 1.0.0 NJC 5 Mar 1998
program distplot, sort 
	version 8.0

	* allobs undocumented 
	syntax varlist(numeric) [if] [in] [fweight aweight/] ///
	[ , BY(str asis) OVER(varname) FREQuency MIDpoint MISSing ///
	TRSCale(str) REVerse Reverse2(str) MSymbol(str)     ///
	ADDPLOT(str asis) PLOT(str asis) ALLOBS * ]
	
	tokenize `varlist'
	local nvars : word count `varlist'

	// error checks 
	if "`allobs'" != "" marksample touse, novarlist 
	else marksample touse  
	
	if "`missing'" == "" { 
		if "`over'" != "" markout `touse' `over', strok 
	}
	else if "`over'" == "" di as txt "missing only applies with over()" 
	
	if "`exp'" == "" local exp "1" 
	else {
		capture assert `exp' >= 0 if `touse'
		if _rc {
			di as err "weight assumes negative values"
			exit 402
	        }    
	}

	if "`over'" != "" {
		if `nvars' > 1 {
			di as err "too many variables specified"
			exit 103
	    	}
	}


	if `"`by'"' != "" { 
		gettoken by opts : by, parse(",") 
		local byby by(`by' `opts') 
		local bylabel : variable label `by' 
	}	
	
	qui count if `touse'
	if r(N) == 0 {
		di as err "no observations satisfy conditions"
		exit 2000
	}

	if "`trscale'" != "" { 
		if !index("`trscale'","@") { 
			di as err "trscale() does not contain @" 
			exit 198 
		}
	} 

	if "`frequency'" != "" & "`midpoint'" != "" { 
		di as err "frequency and midpoint may not be combined"
		exit 198 
	}

	if "`reverse2'" != "" { 
		if "`reverse2'" != "ge" {
			di as err "reverse() option invalid" 
			exit 198 
		} 	
		if "`midpoint'" != "" { 
			di as txt "(reverse midpoint options assumed)" 
			local reverse "reverse" 
		}
		else local ge "ge" 
	} 
	
	// we're in business 
	
	quietly {
		preserve
		keep if `touse'  
		tempvar wt id col P midP 
		gen double `wt' = `exp'

		if `nvars' > 1 { 
			gen long `id' = _n 
			tempname data datalbl 
			local i = 1 
			foreach v of var `varlist' {
				local lbl`i' : variable label `v' 
				if `"`lbl`i''"' == "" local lbl`i' "`v'" 
				rename `v' `data'`i++'
				local xlbl "`xlbl' `v'"
			} 
	        	reshape long `data', i(`id') j(`col') 
		    	forval i = 1 / `nvars' {
				label def `datalbl' `i' `"`lbl`i''"', modify
	    		}
			label val `col' `datalbl' 
		        local varlist "`data'"
			label var `varlist' "`xlbl'"
			if "`by'" != "" label var `by' `"`bylabel'"' 
			local over "`col'"
		}

		sort `touse' `by' `over' `varlist'
		local over1 "by `touse' `by' `over' :"
		local over2 "by `touse' `by' `over' `varlist' :"
		
		if "`midpoint'" == "" { 
			`over1' gen double `P' = sum(`wt') 
			if "`frequency'" == "" `over1' replace `P' = `P' / `P'[_N]
			if "`reverse'" != ""   `over1' replace `P' = `P'[_N] - `P'
		} 
		else {
			`over2' gen double `P' = sum(`wt') 
			`over2' replace `P' = `P'[_N] 
			`over2' keep if _n == _N 
			`over1' gen double `midP' = 0.5 * `P' + sum(`P'[_n-1]) 
			`over1' replace `P' = sum(`P') 
			`over1' replace `P' = `midP' / `P'[_N] 
			if "`reverse'" != "" replace `P' = 1 - `P' 
 		} 
		
		if "`ge'" != "" replace `varlist' = -`varlist' 
		local ylbl = cond("`xlbl'" != "", "value", "`varlist'") 
	
		if "`midpoint'" != ""  {
			local ytitle "Cumulative probability midpoint" 	
		}
		else if "`frequency'" == "" {
			local ytitle "Cumulative probability"
		}
		else local ytitle "Cumulative frequency" 
		
		if "`over'" != "" {
			tempvar group
			bysort `over' (`P') : gen byte `group' = _n == 1 
			replace `group' = sum(`group')
			local overlab : value label `over'
			local j = 1 
			forval i = 1 / `= `group'[_N]' {
				tempvar P_i`i'
		 		gen double `P_i`i'' = `P' if `group' == `i'
         		        local overval = `over'[`j']
		    		if "`overlab'" != "" { 
					local overval : label `overlab' `overval' 
				}
			        label var `P_i`i'' `"`overval'"'
				local Plist "`Plist' `P_i`i''"
				count if `group' == `i'
				local j = `j' + r(N)
			}
		}
		else { 
			local sort "sort" 
			_crcslbl `P' `varlist' 
			local Plist "`P'"
		}	

		if "`trscale'" != "" { 
			foreach v of var `Plist' { 
				local newv : subinstr local trscale "@" "`v'", all 
				replace `v' = `newv' 
			}
		} 
	} 	

	if "`msymbol'" == "" local msymbol "oh dh th sh smplus x O D T S + X"
	
	twoway line `Plist' `varlist', ytitle("`ytitle'") /// 
	`sort' ms(`msymbol') `byby' `options' ///
	|| `plot' /// 
	|| `addplot' /// 
	// blank 
end

