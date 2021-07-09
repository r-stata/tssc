*! version 1.0.4 06Aug2010 MLB
*! version 1.0.3 07Jun2010 MLB
*! version 1.0.2 05Jun2010 MLB
*! version 1.0.1 14Mar2010 MLB
*! version 1.0.0 26Feb2010 MLB & RB
program define obsofint, rclass sortpreserve
	version 8.2
	syntax [varlist] [if] [in]        ///
	       [fweight aweight pweight], ///
	       [ZCUToff(real 3)           ///
		   WHiskerlength(real 3)      ///
		   IDlist(varlist)            ///
		   GENerate(string)           ///
		   z TUKey ASYMtukey          ///
		   SUMmarize(string)          ///
		   SUMmarize2                 /// 
		   SHOWCriterium              ///
		   sortid                     ///
		   nosort                     ///
		   noObs                      ///
		   loud *]
	
	// prepare weights (pweights gives same result as aweight)
	if "`weight'" != "" {
		if "`weight'" == "pweight" {
			local wght "[aweight`exp']"
		}
		else{
			local wght "[`weight'`exp']"
		}
	}

	// remove string variables 
	qui ds `varlist', has(type string)
	local strvars "`r(varlist)'"
	if "`strvars'" != "" {
		if `: word count `strvars'' == 1 {
			local s ""
			local is "is a"
		}
		else {
			local s "s"
			local is "are"
		}
		di as txt "variable`s' " as result "`strvars'" as txt " `is' string variable`s' and will not be checked"
		local oldvars "`varlist'"
		local varlist : list varlist - strvars
		if "`varlist'" == "" {
			di as err "no variable in " as result "`oldvars'" as err " is numeric"
			exit 198
		}
	}
	
	// check options for -list-
	foreach opt of local options {
		capture list `varlist' in 1, `opt'
		if _rc {
			local badopt "`badopt' `opt'"
		}
	}
	if "`badopt'" != "" {
		di as err "options `badopt' not allowed"
		exit 198
	}
	
	// parse sortid option
	if "`sortid'" != "" & "`idlist'" == "" {
		di as err "the sortid option cannot be specified without specifying the idlist() option"
		exit 198
	}
	if "`sortid'" != "" & "`sort'" != "" {
		di as err "the sortid and nosort options cannot be specified together"
		exit 198
	}
	if "`obs'" == "" & "`sort'" == ""{
		tempvar origsort
		gen long `origsort' = _n
		capture confirm variable obs_nr
		if _rc {
			local name "obs_nr"
		}
		else {
			capture confirm variable obs, exact
			if _rc {
				local name "obs"
			}
			else {
				local name "_n"
			}
		}
		char define `origsort'[varname] "`name'"
	}
	if "`sort'" != "" {
		local noobs = cond("`obs'" == "", "", "noobs")
	}
	else {
		local noobs "noobs"
	}
	if "`sort'" == "" {
		tempvar sortorder
		gen long `sortorder' = _n
	}
	
	// parse and check -summarize- option
	if "`summarize2'" != "" {
		local summarize "N mean sd min quartiles max"
	}
	gettoken summarize verbose : summarize, parse(",")
	local verbose : subinstr local verbose "," ""
	local summarize : subinstr local summarize "," ""
	local verbose : list retokenize verbose
	if "`verbose'" != "" & "`verbose'" != "verbose"{
		di as err "the summarize() option only allows the verbose sub-option"
		exit 198
	}
	if "`summarize'" == "" & "`verbose'" != "" {
		local summarize "N mean sd min quartiles max"
	}
	local summarize : subinstr local summarize "quartiles" "p25 p50 p75"
	local summarize : subinstr local summarize "median" "p50"
	local summarize : list uniq summarize
	local allowed "N sum_w mean Var sd skewness kurtosis sum min max p1 p5 p10 p25 p50 p75 p90 p95 p99"
	if !`: list summarize in allowed' {
		di as err "statistic `: list summarize - allowed' in option summarize not allowed"
			exit 198
	}
	if "`summarize'" != "" {
		local sumopt "summarize(`summarize') `verbose'"
	}
	
	// parse replace and all sub-options in the generate option
	gettoken generate gen_opt : generate, parse(",")
	gettoken comma gen_opt : gen_opt, parse(",")
	local allowed_opts "replace all"
	local bad_opts : list gen_opt - allowed_opts
	if "`bad_opts'" != "" {
		di as err "the generate() option only allows the replace and all sub-options"
		exit 198
	}
	local repl "replace"
	if `: list repl in gen_opt' {
		local replace "replace" 
	}
	local al "all"
	if `:list al in gen_opt' {
		local all "all"
	}
	
	// select information from if and in, and make sure there are observations left
	marksample touse, novarlist

	qui count if `touse'
	if r(N) == 0 {
		di as err "no observations"
		exit 2000
	}
	foreach var of varlist `varlist' {
		qui count if `touse' & `var' < .
		if r(N) == 0 {
			local emptyvars "`emptyvars' `var'"
		}
	}
	if `: word count `emptyvars'' == 1 {
		di as txt "no observations for the following variable: " as result "`emptyvars'"
		di as txt "this variable will not be checked"
	}
	if `: word count `emptyvars'' > 1 {
		di as txt "no observations for the following variables: " as result "`emptyvars'"
		di as txt "these variables will not be checked"
	}
	if "`emptyvars'" != "" {
		local varlist : list varlist - emptyvars
	}
		
	// take out any conflicting options
	local crits "`z' `tukey' `asymtukey'"
	local crits : list retokenize crits
	if `: word count `crits'' > 1 {
		di as err "only one of the following options may be specified:"
		di as err "z, tukey, or asymtukey"
		exit 198
	}
	if `whiskerlength' != 3 & "`z'" != "" {
		di as err "the whiskerlength() option may not be combined with the z option"
		exit 198
	}
	if `zcutoff' != 3 & "`tukey'`asymtukey'" != "" {
		di as err "the zcutoff() option may not be combined with either the tukey or asymtukey options"
		exit 198
	}
	
	// make a matrix to collect the results
	local k : word count `varlist'
	tempname result 
	matrix `result' = J(`k',6,.)
	matrix colnames `result' = "nr_flagged"                                        ///
	                           "fences:lb" "fences:ub"                             ///
							   "criterium:z" "criterium:asym_Tukey" "criterium:Tukey"
	matrix rownames `result' = `varlist'
	
	// start finding observations of interest
	local i = 1
	foreach var of varlist `varlist' {
		tempvar oi`var'
		qui sum `var' if `touse' `wght', detail
		if r(sd) == 0 | r(N) == 1 {
			// everybody is the same, so noone is a outlier
			qui gen byte `oi`var'' = 0 if `touse' & `var' < .
			matrix `result'[`i', 1] = 0, ., ., 0, 0, 0
		}
		else {
			if ( ( ( r(p25)==r(p50) | r(p50) == r(p75) ) & (r(N) - 1)/sqrt(r(N)) > `zcutoff' ) & "`tukey'`asymtukey'" == "" ) | "`z'" != ""{
				Zcrit `var' if `touse' ,             ///
				      indicator(`oi`var'')           ///
					  zcutoff(`zcutoff')             ///
					  result(`result') i(`i')        ///
					  `sumopt' `showcriterium'
			}
			else if "`tukey'" == ""{
				Asym `var' if `touse',               ///
				     indicator(`oi`var'')            ///
					 whiskerlength(`whiskerlength')  ///
					 result(`result') i(`i')         ///
					 `sumopt'  `showcriterium'
			}
			else {
				Sym `var' if `touse',                ///
				    indicator(`oi`var'')             ///
					whiskerlength(`whiskerlength')   ///
					result(`result')  i(`i')         ///
					`sumopt' `showcriterium'
			}
		}
		if "`sortid'" != ""{
			local sortvar "`idlist'"
		}
		else if "`sort'" != ""{
			local sortvar ""
		}
		else {
			local sortvar "`var'"
		}
		if "`sort'" == "" {
			sort `sortvar' `sortorder'
		}
		list `origsort' `idlist' `var' if `oi`var'' & `touse' & `var' < ., `options' `noobs' subvarname
		qui count if `oi`var'' & `touse' & `var' < .
		if r(N) > 0 | "`all'" != "" {
			Genindicator `var' if `touse', generate(`generate') `replace' indicator(`oi`var'')
		}
		if r(N) == 0 & "`loud'" != "" {
			di as txt "Variable" as result " `var' " as txt "has no flagged observations"
		}
		local `i++'
	}
	return matrix result = `result'
end

program define Zcrit
	syntax varname [if],     ///
	       indicator(name)   ///
		   zcutoff(real)     ///
		   result(name)      ///
		   i(integer)        ///
		   [                 ///
		   summarize(string) /// 
		   verbose           ///
		   showcriterium     ///
		   ]

	if (r(N)-1)/sqrt(r(N)) < `zcutoff' {
		di in txt "{hline}"
		di in txt "Observations of interest report for" in result " `varlist'" _c
		local varlab : variable label `varlist'
		if `"`varlab'"' != "" {
			di as txt "; " as result `"`varlab'"'
		}
		di _n
		di as txt "The sample size is so small that it is logically impossible"
		di as txt "to find observations of interest using the z > `zcutoff' criterium"
	}

	marksample touse
	local lb = r(mean) - `zcutoff'*r(sd)
	local ub = r(mean) + `zcutoff'*r(sd)
	qui gen byte `indicator' = abs((`varlist'-r(mean))/r(sd)) > `zcutoff' if `touse' 
	
	tempname p25 p50 p75
	scalar `p25' = r(p25)
	scalar `p50' = r(p50)
	scalar `p75' = r(p75)
		
	qui count if `indicator' & `touse' 
	if r(N) > 0 {
		di in txt "{hline}"
		di in txt "Observations of interest report for" in result " `varlist'" _c
		local varlab : variable label `varlist'
		if `"`varlab'"' != "" {
			di as txt "; " as result `"`varlab'"'
		}
		di _n

		Sumdisplay `varlist' if `touse', summarize(`summarize')	`verbose'
		
		if "`showcriterium'" != "" {
			if `p25' == `p75' {
				di as txt "First, second, and third quartile are equal" 
			}
			else if `p25' == `p50'{
				di as txt "First and second quartile are equal"
			}
			else if `p50' == `p75' {
				di as txt "Second and third quartile are equal"
			}
			di as txt "z > " as result `zcutoff' as txt " criterium is used" 		
			di as txt "The fences are: " as result %9.3g `lb' as txt ", " as result %9.3g `ub'
		}
	}
	matrix `result'[`i',1] = r(N), `lb' , `ub', 1, 0, 0
end

program define Asym
	syntax varname [if],       ///
	       indicator(name)     ///
		   whiskerlength(real) /// 
		   result(name)        ///
		   i(integer)          ///
		   [                   ///
		   summarize(string)   ///
		   verbose             ///
		   showcriterium       ///
		   ]
	marksample touse
	tempname lb ub	
	scalar `lb' = r(p25) - 2*`whiskerlength'*(r(p50)-r(p25))
	scalar `ub' = r(p75) + 2*`whiskerlength'*(r(p75)-r(p50))

	if "`: type `varlist''" == "float" {
		qui gen byte `indicator' = `varlist' < float(`lb') | `varlist' > float(`ub') if `touse'
	}
	else {
		qui gen byte `indicator' = `varlist' < `lb' | `varlist' > `ub' if `touse' 
	}
	qui count if `indicator' & `touse' 
	if r(N) > 0 {
		di in txt "{hline}"
		di in txt "Observations of interest report for" in result " `varlist'" _c
		local varlab : variable label `varlist'
		if `"`varlab'"' != "" {
			di as txt "; " as result `"`varlab'"'
		}
		di _n

		Sumdisplay `varlist' if `touse', summarize(`summarize')	`verbose'
		if "`showcriterium'" != "" {
			di in txt "Adjusted Tukey fences used with whiskerlength " as result `whiskerlength'
			di as txt "The fences are: " as result %9.3g `lb' as txt ", " as result %9.3g `ub'
		}
	}
	matrix `result'[`i',1] = r(N), `lb', `ub' , 0 , 1, 0
end

program define Sym
	syntax varname [if],       ///
	       indicator(name)     ///
		   whiskerlength(real) ///
		   result(name)        ///
		   i(integer)          ///
		   [                   ///
		   summarize(string)   ///
		   verbose             ///  
		   showcriterium       ///
		   ]
	marksample touse
	tempname lb ub
	scalar `lb' = r(p25) - `whiskerlength'*(r(p75)-r(p25))
	scalar `ub' = r(p75) + `whiskerlength'*(r(p75)-r(p25))
	
	if "`: type `varlist'" == "float" {
		qui gen byte `indicator' = `varlist' < float(`lb') | `varlist' > float(`ub') if `touse'
	}
	else {
		qui gen byte `indicator' = `varlist' < `lb' | `varlist' > `ub' if `touse' 
	}
	qui count if `indicator' & `touse'
	if r(N) > 0 {
		di in txt "{hline}"
		di in txt "Observations of interest report for" in result " `varlist'" _c
		local varlab : variable label `varlist'
		if `"`varlab'"' != "" {
			di as txt "; " as result `"`varlab'"'
		}
		di _n
		
		Sumdisplay `varlist' if `touse', summarize(`summarize') `verbose'		
		
		if "`showcriterium'" != "" {
			di in txt "Traditional Tukey fences used with whiskerlength" as result `whiskerlength'
			di as txt "The fences are: " as result %9.3g `lb' as txt ", " as result %9.3g `ub'
		}
		
	}
	matrix `result'[`i',1] = r(N), `lb', `ub', 0, 0, 1
end

program define Genindicator
	syntax varname [if], [generate(string) replace] indicator(varlist)
	marksample touse
	if "`generate'" != "" {
		capture confirm variable `generate'_`varlist'
		if !_rc {
			if "`replace'" == "" {
				di as err "`generate'_`varlist' already defined"
				exit 110
			}
			else {
				qui drop `generate'_`varlist'
				label drop `generate'_`varlist'
			}
		}
		qui gen byte `generate'_`varlist' = `indicator' if `touse'
		label define `generate'_`varlist' 0 "not flagged" 1 "flagged"
		label value `generate'_`varlist' `generate'_`varlist'
		label variable `generate'_`varlist' "Obs of interest in `var'"
	}
end

program define Sumdisplay
	syntax varname [if], [summarize(string) verbose]
	if "`summarize'" != "" {
		marksample touse
		qui summarize `varlist' if `touse', detail
		if "`verbose'" == "" {
			local last : word count `summarize'
			local maxsum = floor(c(linesize)/11)
			local Nlines = ceil(`last'/`maxsum')
			forvalues line = 1/`Nlines' {
				local start = (`line' - 1 ) * `maxsum' + 1
				local end = `line'*`maxsum'
				forvalues stat = `start'/`end' {
					local sum`line' "`sum`line'' `: word `stat' of `summarize''"
				}
			}
			local lstat = 1
			local lnum = 1
			forvalues line = 1/`Nlines' {
				local j = 1
				foreach stat of local sum`line' {
					if mod(`j', `maxsum') == 0 | `lstat' == `last' {
						local c ""
					}
					else {
						local c "_c"
					}
					local k : length local stat
					local start = `j'*11 - `k' +1
					di as txt "{col `start'}`stat'" `c'
					local ++j
					local ++ lstat
				}
				local j = 1
				foreach stat of local sum`line' {
					if mod(`j', `maxsum') == 0 {
						local c "_n"
					}
					else if `lnum' == `last' {
						local c ""
					}
					else {
						local c "_c"
					}
					if "`stat'" == "N" {
						di as result "  " %9.0g r(`stat')  `c'
					}
					else {
						di as result "  " %9.3g r(`stat')  `c'
					}
					local ++j
					local ++lnum
				}
			}
		}
		else {
			foreach stat of local summarize {
				if "`stat'" == "N" {
					di as txt "number of observations: {col 26}"  as result %9.0g r(N)
				} 
				else if "`stat'" == "sum_w" {
					di as txt "sum of weights: {col 26}" as result %9.3g r(sum_w)
				} 
				else if "`stat'" == "mean" {
					di as txt "mean: {col 26}" as result %9.3g r(mean)
				} 
				else if "`stat'" == "Var" {
					di as txt "variance: {col 26}" as result %9.3g r(Var)
				} 
				else if "`stat'" == "sd" {
					di as txt "standard deviation: {col 26}" as result %9.3g r(sd)
				} 
				else if "`stat'" == "skewness" {
					di as txt "skewness: {col 26}" as result %9.3g r(skewness)
				} 
				else if "`stat'" == "kurtosis" {
					di as txt "kurtosis: {col 26}" as result %9.3g r(kurtosis)
				} 
				else if "`stat'" == "sum"{
					di as txt "sum of variable: {col 26}" as result %9.3g r(sum)
				}
				else if "`stat'" == "min" {
					di as txt "minimum: {col 26}" as result  %9.3g r(min)
				}
				else if "`stat'" == "max" {
					di as txt "maximum: {col 26}" as result %9.3g r(max)
				} 
				else if "`stat'" == "p1" {
					di as txt "1st percentile: {col 26}" as result  %9.3g r(p1)
				}
				else if "`stat'" == "p5" {
					di as txt "5th percentile: {col 26}" as result %9.3g r(p5)
				}
				else if "`stat'" == "p10" {
					di as txt "10th percentile: {col 26}" as result %9.3g r(p10)
				}
				else if "`stat'" == "p25" {
					di as txt "25th percentile: {col 26}" as result %9.3g r(p25)
				}
				else if "`stat'" == "p50" {
					di as txt "50th percentile: {col 26}" as result %9.3g r(p50)
				}
				else if "`stat'" == "p75" {
					di as txt "75th percentile: {col 26}" as result %9.3g r(p75)
				}
				else if "`stat'" == "p90" {
					di as txt "90th percentile: {col 26}" as result %9.3g r(p90)
				}
				else if "`stat'" == "p95" {
					di as txt "95th percentile: {col 26}" as result  %9.3g r(p95)
				}
				else if "`stat'" == "p99" {
					di as txt "99th percentile: {col 26}" as result %9.3g r(p99)
				}
			}
		}
		di _n
	}
end
