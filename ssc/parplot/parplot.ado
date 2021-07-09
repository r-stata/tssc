*! NJC 1.1.2 19 March 2007 
* NJC 1.1.1 9 Nov 2005 
* NJC 1.1.0 21 July 2004 
* NJC 1.0.0 16 July 2003
program parplot 
	version 8.0
	syntax varlist(min=2 numeric) [if] [in] ///
	[, BY(str asis) TRansform(str) HORizontal PLOT(str asis) ///
	IDentify(varname) Over(varname) variablelabels ADDPLOT(str asis) * ]

	// 1.1.1 over() was identify(); identify() now undocumented 
	if "`over'" != "" & "`identify'" != "" & "`over'" != "`identify'" { 
		di as err "may not specify over() and identify()" 
		exit 198 
	}
	local identify "`over'" 

	if `"`by'"' != "" { 
		tokenize `"`by'"', parse(",") 
		local byvar "`1'"
		local bysubopts `"`3'"' 
			
		capture confirm var `byvar' 
		if _rc { 
			di as err "variable `byvar' not found"
			exit 111
		}	
		
		local bylabel : variable label `byvar' 
		local byvallbl : value label `byvar'
		if `"`byvallbl'"' != "" {
			tempfile bylabels
			qui label save `byvallbl' using `bylabels'.
		}

		if `"`bysubopts'"' != "" { 
			tokenize `bysubopts' 
			forval i = 1 / `: word count `bysubopts'' { 
				if substr("``i''", 1, 4) == "miss" { 
					local missing "missing"
				}
			} 	
		}	
	} 	

	if "`transform'" == "" local transform "m" 
	else { 
		local l = length("`transform'")
		
        	if substr("maxmin", 1, max(1,`l')) == "`transform'" {
	                local transform "m"
	        }
        	else if substr("centered", 1, max(1,`l')) == "`transform'" {
	                local transform "c"
	        }
	 	else if substr("centred", 1, max(1,`l')) == "`transform'" {
	                local transform "c"
	        }
        	else if substr("standardized", 1, max(1,`l')) == "`transform'" {
	                local transform "s"
	        }
	       	else if substr("standardised", 1, max(1,`l')) == "`transform'" {
	                local transform "s"
	        }
	 	else if substr("raw", 1, max(1,`l')) == "`transform'" {
	                local transform "r"
	        }
        	else {
                	di "{err}illegal {cmd}transform {err}option"
	                exit 198
        	}
	}	
	
	marksample touse
	if `"`by'"' != "" & "`missing'" == "" markout `touse' `byvar', strok 
	qui count if `touse'
	if r(N) == 0 error 2000

	if "`identify'" != "" { 
		local idlabel : variable label `identify' 
		local idvallbl : value label `identify'
		if `"`idvallbl'"' != "" {
			tempfile idlabels
			qui label save `idvallbl' using `idlabels'.
		}
	}

	preserve
	qui keep if `touse'
	keep `varlist' `byvar' `identify' 
		
	local nobs = _N 
	local nv : word count `varlist' 

	local suopt = cond("`transform'" == "m", "meanonly", "detail") 
		
	local i = 1 
	qui foreach v of local varlist {

		if "`transform'" != "r" { 
			su `v', `suopt'
			
			if "`transform'" == "m" { 
				replace `v' = (`v' - r(min)) / (r(max) - r(min))
			}
			else if "`transform'" == "c" {
		      		replace `v' = ///
			(`v' - r(p50)) /  max(r(max) - r(p50), r(p50) - r(min))
		        }
			else if "`transform'" == "s" { 
				replace `v' = (`v' - r(mean)) /  r(sd)
			} 
		} 	
	       
		local newlist "`newlist'`v' `byvar' `identify' " 
		
		if "`variablelabels'" != "" { 
			local l : variable label `v'
			if `"`l'"' == "" local l "`v'" 
			local Xla `"`Xla' `i' `"`l'"'"' 
		} 	
		else local Xla "`Xla' `i' `v'"
		
		local ++i 
	}

	tempvar data case extra 
	tempname ParC1 ParC2
	stack `newlist', into(`data' `byvar' `identify') clear 
	
	label var `data' " " 

	if "`transform'" == "m" {
		label def `ParC1' 0 "low" 1 "high"
		local show "0 1"
	}
	else if "`transform'" == "c" { 
		label def `ParC1' -1 "low" 0 "median" 1 "high"
		local line = cond("`horizontal'" == "", "yline(0)", "xline(0)")
		local show "-1 0 1" 
	} 
	else if "`transform'" == "s" { 
		label def `ParC1' 0 "mean" -2 "-2 SD" 2 "+2 SD"
		local line = cond("`horizontal'" == "", "yline(0)", "xline(0)")
		local show "-2 0 2" 
	} 	

	if "`transform'" != "r" label val `data' `ParC1'

	label var _stack " " 
	label def `ParC2' `Xla'
	label val _stack `ParC2' 
	
	gen long `case' = 1 + mod(_n - 1, `nobs')
	qui compress `case'
	
	qui if `"`by'"' != "" { 
		local BY "by(`by')" 
		if `"`bylabel'"' != "" label var `byvar' `"`bylabel'"' 
		if `"`byvallbl'"' != "" {
			do `bylabels'
			label values `byvar' `byvallbl'
		}
	}

	qui if "`identify'" != "" { 
		if `"`idlabel'"' != "" label var `identify' `"`idlabel'"' 
		if `"`idvallbl'"' != "" {
			do `idlabels'
			label values `identify' `idvallbl'
		}

		tempname d 

		if "`horizontal'" == "" {
			separate `data', by(`identify') gen(`d')
			local data "`r(varlist)'" 
			local co `"`: di _dup(`: word count `data'') "L "'"'
			foreach v of local data { 
				local label : variable label `v' 
				local w = index(`"`label'"', "==") + 3
				local label = substr(`"`label'"', `w', .) 
				label variable `v' `"`label'"' 
			}	
		}	
		else { 
			separate _stack, by(`identify') gen(`d')
			local stack "`r(varlist)'"
			local co `"`: di _dup(`: word count `stack'') "l " '"'
			foreach v of local stack { 
				local label : variable label `v' 
				local w = index(`"`label'"', "==") + 3
				local label = substr(`"`label'"', `w', .) 
				label variable `v' `"`label'"' 
			}	
		}
		local yti "yti(" ")" 
	}

	if "`stack'" == "" local stack "_stack" 

	if "`horizontal'" == "" { 
		sort `byvar' `case' `stack'

		if "`co'" == "" local co "L" 
	
		twoway connected `data' `stack',                           ///
		c(`co') xli(1/`nv') xla(1/`nv', noticks val) `yti'         /// 
		yla(`show', val) `line' `BY' `options'                     ///
		|| `plot' 
        } 
	else { 
		qui { 
			bysort `byvar' `case' (`stack') : gen byte `extra' = _n == _N 
			expand 2 if `extra' 
			sort `byvar' `case' `stack'
			foreach v of local stack { 
				by `byvar' `case' : replace `v' = . if _n == _N
				by `byvar' `case' : replace `v' = . if _n == _N
			}	
			by `byvar' `case' : replace `data' = . if _n == _N
		} 	

		if "`co'" == "" local co "l"

		twoway connected `stack' `data',                            ///
		c(`co') cmissing(n ..) yli(1/`nv') yla(1/`nv', noticks val) /// 
		`yti' xla(`show', val) `line' `BY' `options'                ///
		|| `plot'  || `addplot' 
	}
end
