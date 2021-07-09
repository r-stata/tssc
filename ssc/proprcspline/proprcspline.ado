*! 1.2.3 MLB 03 Feb 2010
*! Large portions of the code are based on -rcspline- by Nick Cox

program proprcspline, rclass sortpreserve
	version 10 
        
    forvalues i = 1/ 15 { // 15 is the maximum number of categories is y
      	local rareaopts "`rareaopts' rareaopt`i'(str asis)"
    }
        
    syntax varlist(numeric) [if] [in] [fweight pweight],     ///
	[at(string)                                               ///
    Stub(str) NKnots(passthru) Knots(passthru)              ///
    MLOGITopts(str) addplot(str asis) Generate(str)          ///
    SHowknots LABLength(str) by(str) CATLEGend CATAXis `rareaopts' * ] 
		
	if "`catlegend'`cataxis'" == "" {
		local cataxis "cataxis"
		local defaultcat = 1
	}

	if "`lablength'" == "" {
		local lablength 20
	}
	else if "`lablength'" == "all" {
		local lablength ""
	}
	else {
		capture confirm integer number `lablength'
		local ok = _rc == 0
		capture assert `lablength' > 0
		if !`ok' | _rc > 0  {
			di as err `"the option lablength() may contain either "all" or a positive integer"'
			exit 198
		}
		
	}
	 
	marksample touse 
	if "`by'" != "" {
       	gettoken byvarlist : by, parse(",")
       		
       	markout `touse' `byvarlist', strok
       	
       	if `: word count `byvarlist'' > 1 {
			tempvar byvar
			qui bys `touse' `byvarlist' : gen `byvar' = _n == 1 if `touse' 
			qui replace `byvar' = sum(`byvar') if `touse'
		}
		else {
			local byvar "`byvarlist'"
		}
		qui levelsof `byvar'
		local k_by : word count `r(levels)'
		local levs_by "`r(levels)'"
		if `k_by' > 10 {
			di as err "more than 10 groups cannot be specified in the by() option"
			exit 198
		}
		if `k_by' > 2 {
			local cataxis ""
			local catlegend "catlegend"
			if "`defaultcat'" == "" {
				di as err "the cataxis option can only be specified without the by() option or"
				di as err "when the comparison implied in the by() option involves 2 groups"
				exit 198
			}
		}
	}
	qui count if `touse' 
	if r(N) == 0 error 2000 
	        
	gettoken y x : varlist
	gettoken x control : x
	local i = 1
	while "`at'" != "" {
		gettoken vars at : at
		gettoken value at : at
		unab vars : `vars'
		if !`: list vars in control' {
			di as err "the uneven elements in the at() option must be control variables specified in the main varlist"
			exit 198
		}
		capture confirm number `value'
		if _rc {
			di as err "the even elements in the at() option must be a number"
		}
		foreach var of varlist `vars' {
			local at2 "`at2' `var' `value'"
		}
		local at : list retokenize at
		if `i' > 100 {
			di as err "something went wrong while checking the at() option, more than 100 values specified"
			exit 198
		}
		local i = `i' + 1
	}
	local at : list retokenize at2
		
	qui levelsof `y' if `touse'
	local levs `"`r(levels)'"'
	local k : word count `r(levels)'
	if `k' > 15 {
		di as err "`y' must contain less than 16 unique values"
		exit 198
	}

	if "`generate'" != "" { 
	    forvalues i = 1/`k' {
			capture confirm new variable `generate'`i' 
			if _rc { 
				di as err "`generate'1-`generate'`k' need to be new variable names" 
				exit _rc 
			}
	    } 
	} 

    if "`stub'" == "" tempname stub 
	if "`weight'" == "fweight" {
		local wgt "[`weight'`exp']"
	}
    qui mkspline `stub' = `x' if `touse' `wgt' ///
             , cubic `nknots' `knots'                
    local knots `r(N_knots)' 
    tempname xk 
    matrix `xk' = r(knots) 


    if "`showknots'" != "" { 
        forval i = 1/`knots' { 
            local xx `=`xk'[1, `i']'
            local showk `showk' || pci 0 `xx' 1 `xx', lstyle(yxline)
        } 
    } 


    local xtitle `""`: var label `x''""' 
    if `"`xtitle'"' == "" local xtitle "`x'"  

	if "`addplot'" == "" {
		tempvar tousegr
		bys `touse' `byvar' `x' : gen byte `tousegr' = cond(`touse'==1, _n==1, 0)
	}
	else{
		local tousegr "`touse'"	
	}

	if "`by'" != "" {
		forvalues j = 1/`k' {
			tempvar pr`j'
			qui gen `pr`j'' = .
		}
		if "`: type `byvar''" == "float" {
			local fl_b "float("
			local fl_e ")"
		}
		local i = 1
		foreach lev of local levs_by {
			qui mlogit `y' `stub'* `control' if `touse' & `byvar'==`fl_b'`lev'`fl_e' ///
			[`weight' `exp'] , `mlogitopts'
			tempname pr_`i'_
			Adj if `touse', stub(`pr_`i'_') at(`at') control(`control')
			forvalues j = 1/`k' {
				qui replace `pr`j'' = `pr_`i'_'`j' if `byvar' == `fl_b'`lev'`fl_e'
			}
			local `i++'
		}
		if "`catlegend'" == "" {
			gettoken left right : by, parse(",")
			gettoken comma right : right, parse(",")
			local byopt `"by(`left', legend(off) `right')"'
		}
		else {
			local byopt `"by(`by')"'
		}
		
		tempvar y0 y1
		qui gen `y0' = 0
		qui gen `y1' = `pr1'
		local areagr `"rarea `y0' `y1' `x' if `tousegr', `rareaopt1' "'
				
		forvalues i = 2/`k' {
			tempvar y`i'`
			local j = `i' - 1
			qui gen `y`i'' = `y`j'' + `pr`i''
			local areagr `"`areagr' || rarea `y`j'' `y`i'' `x' if `tousegr', `rareaopt`i''"'
		}
	}
	else {
		qui mlogit `y' `stub'* `control' if `touse' [`weight' `exp'] , `mlogitopts'
		tempname pr
		Adj if `touse', stub(`pr') at(`at') control(`control')
	
		tempvar y0 y1
		qui gen `y0' = 0
		qui gen `y1' = `pr'1
			
		local areagr `"rarea `y0' `y1' `x' if `tousegr', `rareaopt1' "'
			
		forvalues i = 2/`k' {
			tempvar y`i'`
			local j = `i' - 1
			qui gen `y`i'' = `y`j'' + `pr'`i'
			local areagr `"`areagr' || rarea `y`j'' `y`i'' `x' if `tousegr', `rareaopt`i''"'
		}
	}
				
	if "`catlegend'" != "" {
		local i = 1
		if "`y'" != "" {
			foreach lev of local levs {
				local lab : label (`y') `lev' `lablength'
				local legend `"`i++' `"`lab'"' `legend' "'
			}
		}
		local legopt `"legend(order(`legend'))"' 
	}
	else {
		local legopt "legend(off)"
	}
		
	if "`cataxis'" != "" {
		sort `byvar' `x'
		
		if "`byvar'" != "" {
			sum `byvar' if `touse', meanonly
			if "`: type `byvar''" == "float" {
				local byif " & `byvar' == float(`r(max)')"
			}
			else {
				local byif " & `byvar' == `r(max)'"
			}
		}
		sum `x' if `touse' `byif', meanonly
		tempname xmax
			scalar `xmax' = r(max)
			local i = 1
			foreach lev of local levs {
				local lab : label (`y') `lev' `lablength'
				local j = `i'-1
				
				sum `y`i'' if `touse' & float(`x') == float(`xmax') `byif', meanonly
				local end = r(mean)
				sum `y`j'' if `touse' & float(`x') == float(`xmax') `byif', meanonly
				local begin = r(mean)
				local ypos = (`end' - `begin')/2 + `begin'
				local yaxis `"`yaxis' `ypos' `"`lab'"' "'
				local `i++'
			}
			sum `x', meanonly
			local axisopt `"|| scatteri .5 `r(mean)' , msymbol(i) yaxis(2) yscale(range(0 1) axis(2)) ytitle("",axis(2)) ylab(`yaxis', axis(2) angle(horizontal)) "'
		}
		
		twoway `areagr'                         ///
		yti("proportion")                       ///
		xti(`xtitle')                           /// 
		plotregion(margin(zero))                /// 
		`legopt'                                /// 
		`byopt'                                 ///
		`options'                               ///
		`axisopt' || `addplot' `showk'
	
        if "`generate'" != "" { 
        	forvalues i = 1/`k' {
        		if "`by'" == "" {
		                gen `generate'`i' = `pr'`i' if `touse' 
		        }
		        else {
		                gen `generate'`i' = `pr`i'' if `touse' 
		        }
	        }
        } 

        return scalar N_knots = `knots' 
        return matrix knots = `xk' 
end     

program define Adj
	syntax [if] , stub(namelist min=1 max=1) [at(string) control(varlist) ]
	marksample touse
	tempvar id
	gen long `id' = _n
	if c(stata_version) < 11 {
		sort `id'
	}
	tempfile orig
	qui save `orig'

	nobreak {
		capture {
			local i = 1
			while "`at'" != "" {
				gettoken var at : at
				gettoken value at : at
				replace `var' = `value'
				local atvars "`atvars' `var'"
				local at : list retokenize at
				if `i' > 100 {
					exit 198
				}
				local i = `i' + 1
			}
			if "`: list control - atvars'" != ""  {
				foreach var of varlist `: list control - atvars' {
					sum `var' if `touse', meanonly
					replace `var' = r(mean)
				}
			}
			
			predict `stub'*, pr
			keep `id' `stub'1-`stub'`e(k_out)'
			tempname _merge
			if c(stata_version) >= 11 {
				merge 1:1 `id' using `orig', generate(`_merge')
			}
			else {
				merge `id' using `orig', _merge(`_merge')
			}
			assert `_merge' == 3
		}
		if _rc {
			use `orig', clear
			di as err "something went wrong while predicting adjusted probabilities"
			exit _rc
		}
	}
end
