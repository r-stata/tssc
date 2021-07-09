*! 1.1.0 NJC 25 Feb 2007 
*! 1.0.0 NJC 10 May 2006 
program shorth, sortpreserve rclass byable(recall) 
	version 8.2  
	syntax varlist(numeric) [if] [in] ///
	[, INSIDE(str) Name(int 32) Proportion(numlist >0 <1 max=1) Spaces(int 2) ///
	Format(str) BY(varname) Generate(str) GRaph Ties ALLobs MISSing ]
	
	quietly { 
		// what observations to use 
		if "`allobs'" != "" marksample touse, novarlist 
		else marksample touse
		
		if "`by'" != "" & "`missing'" == "" markout `touse' `by', strok 
		
		count if `touse' 
		if r(N) == 0 error 2000

		// variable(s) or group(s) 
		local nv : word count `varlist'

		// generate() option 
		if "`generate'" != "" { 
			if `nv' > 1 { 
				di as err ///
				"generate() cannot be combined with `nv' variables"
				exit 198 
			}

			if _by() { 
				di as err ///
				"generate() cannot be combined with by: : use by() option"
				exit 198 
			}
			
			local OK length max LMS min shorth  
			
			foreach g of local generate { 
				local eq = index("`g'", "=") 
				if `eq' == 0 { 
					di as err "generate(): invalid syntax" 
					exit 198
				}
				
				local g1 = substr("`g'", 1, `eq' - 1) 
				confirm new variable `g1' 
				local G1 `G1' `g1' 

				local g2 = substr("`g'", `eq' + 1, .)
				if "`g2'" == "lms" local g2 "LMS" 
				if !`: list g2 in OK' { 
					di as err "generate(): `g2' invalid"
					exit 198 
				}
				local G2 `G2' `g2' 
			}	
			
			foreach g1 of local G1 { 
				generate double `g1' = .                  
			}	
		}

		// by option 
		if "`by'" != "" { 
			if `nv' > 1 { 
				di as err ///
				"by() cannot be combined with `nv' variables"
				exit 198 
			}

			tempname stub
			separate `varlist' if `touse', ///
			by(`by') g(`stub') veryshortlabel `missing' 
			local varlist "`r(varlist)'" 
		}

		// inside() option 
		if "`inside'" != "" { 
			confirm new var `inside'

			if `nv' > 1 { 
				di as err ///
				"inside() cannot be combined with `nv' variables"
				exit 198
			}	

			gen byte `inside' = 0 
		}	

		if "`by'`allobs'" == "" {
			noi di _n as txt "(n = " as res r(N) as txt ")" 
		}	
			
		// display preparation and initiation 
		local nam = 0 
		foreach v of local varlist { 
			if "`by'" != "" {
				local nam = max(`nam', length(`"`: variable label `v''"')) 
			}	
			else local nam = max(`nam', length("`v'")) 
		}	
		local col = min(`name', `nam') + 1 
	
		if "`format'" == "" local format "%8.2g"
		local ndigits : subinstr local format  "%" "" 
		local ndigits : subinstr local ndigits "0" ""
		local ndigits : subinstr local ndigits "-" "" 
		local ndigits = substr("`ndigits'", 1, 1) 

		if "`ndigits'" == "d" { 
			local ndigits = 9 
			local ldigits = 6
			local lfmt "%6.0f"
		}	
		else if `ndigits' < 6 {
			local fmt "`format'" 
			local format : subinstr local format "`ndigits'" "6" 
			noi di as txt "(note: format `fmt' changed to `format')" 
			local ndigits = 6 
		}	
		
		if "`ldigits'" == "" local ldigits = `ndigits' 
		if "`lfmt'" == "" local lfmt "`format'"

		local sp "{space `spaces'}"
		local SP : di _dup(`spaces') " " 
		if "`by'`allobs'" != "" local N : di %6s "n`SP'" 
		local S : di %`ndigits's "shorth"
		local I : di %`ndigits's "min"
		local M : di %`ndigits's "LMS"
		local X : di %`ndigits's "max"
		local L : di %`ldigits's "length"
		
		noi di _n as txt ///
		"{col `col'}`sp'`N'`S'`sp'`I'`sp'`M'`sp'`X'`sp'`L'" 

		local line = `col' - 1 + 5 * `spaces' + length("`N'`S'`I'`M'`X'`L'")
		noi di "{hline `line'}"

		local footnote = 0 
		local tiesnote = 0 
		
		// initialisation of calculation 
		if "`proportion'" == "" local proportion = 0.5 
		local what = cond(`proportion' != 0.5, "fraction", "half") 
		local whats = cond(`proportion' != 0.5, "fractions", "halves") 
		replace `touse' = -`touse' 
		
		tempvar work i  
		gen double `work' = . 
		gen long `i' = . 
		
		// loop over variables (-separate- results if -by()-) 
		foreach v of local varlist { 
			local which = cond("`by'" != "", `"`: variable label `v''"', "`v'") 
		
			bysort `touse' (`v') : replace `i' = _n 
			count if `touse' & `v' < . 
			local n = r(N) 
			local n2 = floor(`proportion' * r(N)) 
			local n1 = `n' - `n2' 

			replace `work' = ///
			cond(inrange(_n, 1, `n1'), `v'[_n + `n2'] - `v', .)  

			// check for tied shortest half 
			sort `work' `i'  
			count if `work' == `work'[1] 
			if r(N) > 1 { 
				local footnote = 1 
				local flag " (*)" 
				local l = `i'[ceil(r(N) / 2)] 

				if "`ties'" != "" {
					local ++tiesnote 
					if c(version) >= 9 {
						levelsof `i' in 1/`r(N)', local(levels) 
					}		
					else levels `i' in 1/`r(N)', local(levels) 
					local tie`tiesnote' `levels' 
					local tiesvar `tiesvar' `v' 
				}	
			}
			else { 
				local flag 
				local l = `i'[1] 
			}

			if "`graph'" != "" { 
				noi scatter `work' `i' in 1/`n1', ///
				ytitle(shortest `what') ///
				xtitle(index) subtitle(`"`which'"') 
				more 
			}	
		
			local m = `l' + `n2'  
			sort `touse' `i' 
			su `v' in `l'/`m', meanonly 

			if "`inside'" != "" { 
				replace `inside' = 1 in `l'/`m' 
			}	
			
			* set trace on 
			
			if "`by'`allobs'" != "" local nshow : di %6s "`n'`SP'" 
			noi di as text `"`which'{col `col'}"'        "`sp'" ///
			       as res "`nshow'"                             ///  
                               as res `format' r(mean)               "`sp'" ///
                               as res `format' r(min)                "`sp'" ///
                               as res `format' (r(min) + r(max)) / 2 "`sp'" /// 
                               as res `format' r(max)                "`sp'" ///
			       as res `lfmt' r(max) - r(min)         "`sp'" ///
	      	               as txt "`flag'"

			* set trace off 
			// generate? 
			local j = 1 
			foreach g1 of local G1 { 
				local g2 : word `j++' of `G2' 
				if "`g2'" == "length" {
					replace `g1' = r(max) - r(min) if `touse' & `v' < . 
				}	
				else if "`g2'" == "max" { 
					replace `g1' = r(max) if `touse' & `v' < . 
				}	
				else if "`g2'" == "LMS" { 
					replace `g1' = (r(max) + r(min)) / 2 if `touse' & `v' < . 
				}	
				else if "`g2'" == "min" {
					replace `g1' = r(min) if `touse' & `v' < .
				}	
				else if "`g2'" == "shorth" { 
					replace `g1' = r(mean) if `touse' & `v' < .
				}	
			}

			// leaves only last-calculated in memory 
			return scalar length = r(max) - r(min) 
			return scalar rank_max = `m' 
			return scalar max = r(max) 
			return scalar LMS = (r(min) + r(max)) / 2 
			return scalar rank_min = `l' 
			return scalar min = r(min) 
		        return scalar shorth = r(mean) 
			return scalar N = `n' 
		}
	}	

	// endnotes 
	if `footnote' di _n as txt "(*) shortest `what' not unique"

	if `tiesnote' { 
		di _n "Ties for `whats' starting at ranks " 
		local i = 1 
		foreach v of local tiesvar {
			if "`by'" != "" local v : variable label `v' 
			di as txt `"`v'"' as res "{col `col'}`sp'`tie`i++''"
		}	
	}	
end 

