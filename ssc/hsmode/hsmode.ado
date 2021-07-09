*! NJC 1.0.0 26 Feb 2007
program hsmode, rclass byable(recall)
	version 9
	syntax varlist(numeric) [if] [in] [, Name(int 32) Spaces(int 2) ///
	Format(str) BY(varname) Generate(str) ALLobs MISSing ]

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
		
			confirm new var `generate' 
			generate double `generate' = .                  
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

		if "`by'`allobs'" == "" {
			noi di _n as txt "(n = " as res r(N) as txt ")" 
		}	
		else noi di " "   
			
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
		
		noi di as txt "{col `col'}`sp'`N'`sp'  mode" 

		local line = `col' - 1 + 2 * `spaces' + length("`N'  mode")
		noi di "{hline `line'}"

		tempvar thisuse 
		gen byte `thisuse' = . 

		// loop over variables (-separate- results if -by()-) 
		foreach v of local varlist { 
			local which = cond("`by'" != "", `"`: variable label `v''"', "`v'") 
		
			replace `thisuse' = `touse' & `v' < . 
			count if `thisuse' 
			local n = r(N) 

			mata : hs_mode("`v'", "`thisuse'") 
		
			if "`by'`allobs'" != "" local nshow : di %6s "`n'`SP'" 
			noi di as text `"`which'{col `col'}"'        "`sp'" ///
			       as res "`nshow'"                             ///  
                               as res `format' r(hsmode)         

			// generate? 
			if "`generate'" != "" { 
				replace `generate' = r(hsmode) if `thisuse'
			}

			// leaves only last-calculated in memory 
			return scalar hsmode = r(hsmode)
			return scalar N = `n' 
		}
	}	
end 

mata : 

void hs_mode(string scalar varname, string scalar tousename) 
{ 
	real colvector y
	real scalar n, mode 

        y = st_data(., varname, tousename)    
	n = rows(y) 

	if (n <= 3) { 
		mode = report(y)
	}
	else { 
		real matrix diff 
		real scalar n2, i1, i2,	nties

		i1 = 1 
		_sort(y, 1) 

		while (n > 3) { 
			n2 = floor(n/2) 
			n1 = n - n2
			i2 = i1 + n2 
			diff = y[i2 .. (i2 + n1 - 1)] - y[i1 .. (i1 + n1 - 1)] 
			diff = diff, (i1 .. (i1 + n1 - 1))' 
			_sort(diff, (1,2))
			nties = colsum(diff[,1] :== diff[1,1]) 
			i1 = diff[ceil(nties / 2), 2] 
			n = n1 
		}

		mode = report(y[i1 .. (i1 + n1 - 1)]) 
	}

	st_numscalar("r(hsmode)", mode) 
}  	

real report(real colvector y) 
{ 
	if (rows(y) == 1) { 
		return(y[1])
	}
	else if (rows(y) == 2) {
		return((y[1] + y[2]) / 2) 
	}
	else if (rows(y) == 3) { 
		_sort(y, 1) 
		if ((y[2] - y[1]) < (y[3] - y[2])) { 
			return((y[1] + y[2]) / 2)
		}
		else if ((y[2] - y[1]) > (y[3] - y[2])) { 
			return((y[3] + y[2]) / 2)
		}
		else return(y[2]) 
	} 
}	

end

