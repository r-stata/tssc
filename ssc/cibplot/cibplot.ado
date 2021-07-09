*! NJC 1.0.0 18 August 2003
program cibplot, sortpreserve rclass  
	version 8.1 
	syntax varlist(numeric) [if] [in] [aweight fweight]        ///
	[ , BY(varname) LEVel(integer $S_level) Poisson BINomial   ///
	Exposure(varname) EXAct Jeffreys Wilson Agresti Total      ///
	Total2(str asis) MISSing INCLusive                         ///
	YTItle(str asis) XTItLE(str asis)                          ///
	HORizontal VERTical BARopts(str asis) plot(str asis) * ]

	// undocumented options: INCLusive Total() plot()

	// error checks 
	if `"`total'`total2'"' != "" & "`by'" == "" {
		di as err "by() option required with total option"
		exit 198
	}
	
	if "`missing'" != "" & "`by'" == "" {
		di as txt "missing option ignored without by() option"
	}

	if "`inclusive'" != "" marksample touse, novarlist 
	else marksample touse 
	if "`by'" != "" & "`missing'" == "" markout `touse' `by', strok 
		
	qui count if `touse' 
	if r(N) == 0 error 2000 
	
	if "`by'" != "" {
		capture confirm numeric var `by'
		if _rc { 
			tempvar byvar
			encode `by', gen(`byvar')
			_crcslbl `byvar' `by' 
			local by "`byvar'"
		}
		
		local bylab : value label `by'
		qui tab `by' if `touse' , `missing' 
		local nobs = r(r) + (("`total'" != "")|(`"`total2'"' != ""))
	}
	else local nobs = 1 
	
	local nvars : word count `varlist'

	local nshow = `nobs' * `nvars' 
	if `nshow' > _N { 
		di as err "too many intervals: increase data set size" 
		exit 498 
	} 	

	// calculations of confidence intervals 
	tempvar group mean l`level' u`level' which
	tempname lbl

	qui {
		gen `which' = . 
		gen `mean' = .
		gen `l`level'' = .
		gen `u`level'' = .

		// these labels aren't used at present; there if wanted 
		label var `l`level'' "lower limit"
		label var `u`level'' "upper limit"
	
		bysort `touse' `by' : gen byte `group' = _n == 1 if `touse'
		replace `group' = sum(`group')

		// stepping by 2 ensures that group medians of `which' are 
		// integers and can be labelled 
		local w = 2 
		local i = 1 
		local max = `group'[_N]
		
		if "`exposure'" != "" local exposur "e(`exposure')" 
				
		count if !`touse'
		local J = 1 + r(N)

		// loop over groups 
		forval j = 1 / `max' {
			count if `group' == `j'
			local obs = r(N)
			local i1 = `i' 

			// loop over variables 
			foreach v of local varlist {
				ci `v' [`weight' `exp'] if `group' == `j', ///
     		                `exposure' `binomial' `poisson' l(`level') ///
				`exact' `jeffreys' `wilson' `agresti' 
				replace `which' = `w' in `i' 
				local i2 = `i' 
				replace `mean' = r(mean) in `i'
				replace `l`level'' = r(lb) in `i'
				replace `u`level'' = r(ub) in `i'
				if "`by'" == "" { 
					local name "`v'"
					local vlbl : variable label `v' 
					if "`vlbl'" != "" local name "`vlbl'" 
					label def `lbl' `w' "`name'", modify
					local W "`W' `w'"
				} 
				local i = `i' + 1 
				local w = `w' + 2 
			}	

			if "`by'" != "" {
		    		local name = `by'[`J']
				if "`bylab'" != ""  & !mi(`name') {
					local name : label `bylab' `name'
				}
				su `which' in `i1' / `i2', meanonly 
				local median = round((r(min) + r(max)) / 2)
				label def `lbl' `median' "`name'", modify
				local W "`W' `median'"
			}	
	
			// extra spacing between groups 
			local w = `w' + 1 
			local J = `J' + `obs'
		} 	
		
		// c.i. for total wanted? 
		if "`total'`total2'" != "" |  {
			local i1 = `i' 
			foreach v of local varlist { 
				ci `v' [`weight' `exp'] if `touse', ///
				`exposure' `binomial' `poisson' l(`level') ///
				`exact' `jeffreys' `wilson' `agresti' 
				replace `which' = `w' in `i' 
				local i2 = `i' 
				replace `mean' = r(mean) in `i'
				replace `l`level'' = r(lb) in `i'              
				replace `u`level'' = r(ub) in `i'
				local i = `i' + 1 
				local w = `w' + 2 
			}
			
			su `which' in `i1' / `i2', meanonly 
			local median = round((r(min) + r(max)) / 2)
			if `"`total2'"' == "" local total2 "Total"
			label def `lbl' `median' `"`total2'"', modify
			local W "`W' `median'"
		}
		
		label val `which' `lbl'
		if "`by'" != "" _crcslbl `which' `by' 
	}	

	// set up graph 
	if "`horizontal'" == "" { 
		if `"`ytitle'"' == "" { 
			if `nvars' == 1 { 
				local ytitle : variable label `varlist' 
				if `"`ytitle'"' == "" local ytitle "`varlist'" 
			} 	
			else if `"`ytitle'"' == "" local ytitle " " 
		}	
		if `"`xtitle'"' == "" { 
			if "`by'" != "" local xtitle : variable label `by' 
			if `"`xtitle'"' == "" local xtitle "`by'" 
		} 	
	}
	else if "`horizontal'" != "" { 
		if `"`xtitle'"' == "" { 
			if `nvars' == 1 { 
				local xtitle : variable label `varlist'
				if `"`xtitle'"' == "" local xtitle "`varlist'" 
			} 	
			else local xtitle " " 
		} 	
		if `"`ytitle'"' == "" { 
			if "`by'" != "" local ytitle : variable label `by' 
			if `"`ytitle'"' == "" local ytitle "`by'" 
		} 	
	}

	local legend "legend(off)"
		
	local nmax = `which'[`nshow'] + 1

	if "`horizontal'" != "" {
		twoway bar `mean' `which', bcolor(none) base(0)     ///
		hor yla(`W', val noticks ang(h)) `baropts' ||       ///   
		rcap `l`level'' `u`level'' `which',                 /// 
		hor `legend' xtitle(`"`xtitle'"')                   ///
		ytitle(`"`ytitle'"') yscale(r(1,`nmax') reverse)    ///
		note("`level'% confidence intervals") `options' ||  ///
		`plot' 
	}
	else { 
		twoway bar `mean' `which', bcolor(none) base(0)     ///
		xla(`W', val noticks ang(h)) `baropts' ||           ///   
		rcap `l`level'' `u`level'' `which',                 /// 
		`legend' xtitle(`"`xtitle'"')                       ///
		ytitle(`"`ytitle'"') xscale(r(1,`nmax'))            ///
		note("`level'% confidence intervals") `options' ||  ///
		`plot' 
	}	

	return local labelled "`W'" 
end

