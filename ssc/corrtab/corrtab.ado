*! corrtab version 1.0.0 8/20/03 F.Wolfe
*! Nick Cox made very helpful suggestions
program corrtab 
	version 8
	syntax varlist(min=2) [if] [in] [aweight fweight] ///
	[, Bonferroni Obs Print(real -1) SIDak SIG CWDeletion  ///
	VSort(varname numeric) Vars(int 0) Above(real 0) SORt SPearman ///
	Tlabel Clabel ALLlabel format(string)]

   if ("`alllabel'" == "alllabel" & "`tlabel'" == "tlabel") ///
      | ("`alllabel'" == "alllabel" & "`clabel'" == "clabel") {
      di as err "alllabel cannot be specified with tlabel or clabel"
      exit 198
   }

   if "`bonferroni'" != "" & "`sidak'" != "" {
      di as err "bonferroni and sidak cannot both be specified"
      exit 198
   }

	if "`spearman'" != "" & "`exp'" != "" {
		di as err "weights not allowed with spearman"
		exit 101
	}

	if `above' & `print' != -1 {
		di as err "above() and print() cannot both be specified"
		exit 198
	}
	
	if `print' >= 1 {
		local print = `print' / 100
		if `print' >= 1 {
			di as err "print() out of range"
			exit 198
		}
	}

	foreach var of local varlist {
		capture confirm str variable `var'
		if _rc local stringtest `stringtest' `var'
	}
   
	local varlist : list uniq stringtest
	local vlistlen : list sizeof varlist
   
	if `vars' == 0 local vars = `vlistlen'
	else if `vars' > `vlistlen' {
		di as err "vars() exceeds number of numeric variables"
		exit 198 
	}

   if "`format'" != "" { 
      capture di `format' 1 
      if _rc { 
         di as err "invalid %format `format'" 
         exit 120 
      }  
      local fmt "`format'" 
   }
   else local fmt "%10.3f" 

	marksample touse, novarlist
	if "`cwdeletion'" != "" markout `touse' `varlist'
	qui count if `touse' 
	if r(N) == 0 error 2000
	
	local N = _N 
	preserve 
	qui keep if `touse'
   	if _N < `N' di as txt "(n = `= _N')"

	quietly {
		local counter = 0
		foreach var of local varlist {
			if `++counter' > `vars' continue, break
       			local vtoplist `vtoplist' `var'
		}
		
		if "`sort'" != "" {
			local varlist : list sort varlist
			local varlist : list vtoplist | varlist
			*local varlist : list uniq varlist
		}
		
		local obslen = _N
		local corrobs = `obslen' + 1

// macros
// varlist    = all variables for correlation analysis
// vars       = number of variables for "top" of correlation table
// vlistlen   = number of variables in varlist
// vtoplist   = list of variables for "top" of correlation table
// obslen     = number of observatins in data set
// corrobs    = the start of correlation data

		local bonk = `vlistlen' * (`vars' - 1)/2
		local newobs = `obslen' + (3 * `vlistlen')
		set obs `newobs'

      gen Variable = ""
   	local lineno = `corrobs'
		
		foreach top of local vtoplist {
			foreach var of local varlist {
				if "`spearman'" == "spearman" {   
					capture spearman `top' `var' ///
					in 1 / `obslen'
			        }
				else {
					capture corr `top' `var' ///
               [`weight' `  exp'] in 1 / `obslen'
				}
				
				local lname : char `var'[varname]
				local tname : char `var'[tlabel]

				if "`alllabel'" == "alllabel" & "`lname'" != "" {
					replace Variable = "`lname'" in `lineno'
				}   
				else if "`tlabel'" == "tlabel" & "`tname'" != ""{
					replace Variable = "`tname'" in `lineno'
				}   
				else replace Variable = "`var'" in `lineno'
    
      		if `above' & `above' > abs(r(rho)) {
					replace `top' = .  in `lineno'
				}
				else replace `top' = r(rho)  in `lineno'
				
				replace Variable = "(p)" in `++lineno'
				
				local pval = ///
		tprob(r(N) - 2, r(rho) * sqrt(r(N)-2) / sqrt(1-r(rho)^2))
				if "`bonferroni'" == "bonferroni" {
					local pval = min(1, `bonk' * `pval')
				}
				else if "`sidak'" == "sidak" {
					local pval = ///
				min(1, 1-(1-`pval')^(  `vars' * `vlistlen'))
				}
				
				if `above' & `above' > abs(r(rho)) {
					replace `top' = .  in `lineno'
				}
				else replace `top' = `pval'  in `lineno'
				 
				replace Variable = "(n)"  in `++lineno'
				if `above' & `above' > abs(r(rho)) {
					replace `top' = .  in `lineno'
				}
				else replace `top' = r(N)  in `lineno'

				if `print' != -1 & `pval' > `print' {
					local twoback = `lineno' - 2
					replace `top' = .  in `twoback'/`lineno'
				}
				
				local ++lineno 
    			} 
			local lineno = `corrobs'
		}
	
		keep in `corrobs'/l
		
      if "`clabel'" == "clabel" | "`alllabel'" == "alllabel" {
         local uselabel subvarname
      }   

		if "`vsort'" != "" & "`obs'" != "obs" & "`sig'" != "sig" {
			tempvar vssort 
			gen `vssort' = abs(`vsort')
			gsort - `vssort' 
		}

		capture tostring `vtoplist', replace force format(`fmt')
      if _rc != 0 error 190 ///
         "Requires -tostring- version of 13aug2003 or later"
		
		foreach var of local vtoplist {
         replace `var' = subinstr(`var',".000","",.) ///
				if real(`var') > 1
			replace `var' = "(" + `var' + ")" ///
				if Variable == "(p)" & `var' != "."
			replace `var' = "" if Variable == "(p)" & `var' == "."
			replace `var' = `var' + " " if Variable != "(p)"
		}

      foreach var of local vtoplist {
         local lname : char `var'[varname]
            if length("`lname'") < 5 & "`lname'" != "" ///
               char `var'[varname] "`lname' "
      }
	}
	
	di
	local who = cond("`spearman'" == "spearman", "Spearman", "Pearson")
	di as txt _col(5) "`who' correlations"
	
	if "`obs'" == "obs" & "`sig'" == "sig" {
		l Variable `vtoplist' , noobs nolabel separator(3) `uselabel'
	}
	else if "`obs'" == "obs" & "`sig'" != "sig" {
		l Variable `vtoplist' if Variable != "(p)", noobs nolabel separator(6) `uselabel'
	}
	else if "`obs'" != "obs" & "`sig'" == "sig" {
		l Variable `vtoplist' if Variable != "(n)", noobs nolabel separator(2) `uselabel'
	}
	else if "`obs'" != "obs" & "`sig'" != "sig" {
		l Variable `vtoplist' if Variable != "(p)" & Variable != "(n)", ///
			noobs nolabel separator(0) `uselabel'
	}
end
  
