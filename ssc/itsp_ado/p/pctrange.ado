

*! pctrange v1.0.6  CFBaum 11aug2008
program pctrange, rclass byable(recall)
	version 10.1
	syntax varlist(min=1 numeric ts) [if] [in] [, noPRINT FORmat(passthru) MATrix(string)]
	marksample touse
	quietly count if `touse'
	if `r(N)' == 0 {
		error 2000
	}
	local nvar : word count `varlist'
	if `nvar' == 1 {
		local res range p7525 p9010 p9505 p9901
		tempname `res'
		quietly summarize `varlist' if `touse', detail
		scalar `range' = r(max) - r(min)
		scalar `p7525' = r(p75) - r(p25)
		scalar `p9010' = r(p90) - r(p10)
		scalar `p9505' = r(p95) - r(p5)
		scalar `p9901' = r(p99) - r(p1)
		if "`print'" != "noprint" {
			display as result _n "Percentile ranges for `varlist', N = `r(N)'"
			display as txt "75-25: " `p7525'
			display as txt "90-10: " `p9010'
			display as txt "95-05: " `p9505'
			display as txt "99-01: " `p9901'
			display as txt "Range: " `range'
		}
		foreach r of local res {
			return scalar `r' = ``r''
		}
		return scalar N = r(N)
	}
	else {
		tempname rmat
		matrix `rmat' = J(`nvar',5,.)
		local i 0
		foreach v of varlist `varlist' {
			local ++i
			quietly summarize `v' if `touse', detail
			matrix `rmat'[`i',1] = r(max) - r(min)
			matrix `rmat'[`i',2] = r(p75) - r(p25)
			matrix `rmat'[`i',3] = r(p90) - r(p10)
			matrix `rmat'[`i',4] = r(p95) - r(p5)
			matrix `rmat'[`i',5] = r(p99) - r(p1)
			local rown "`rown' `v'"
		}
		matrix colnames `rmat' = Range P75-P25 P90-P10 P95-P05 P99-P01
		matrix rownames `rmat' = `rown'
		if "`print'" != "noprint" {
			local form ", noheader"
			if "`format'" != "" {
				local form "`form' `format'"
			}
			matrix list `rmat' `form'
		}
		if "`matrix'" != "" {
			matrix `matrix' = `rmat'
		}
		return matrix rmat = `rmat'
	}	
	return local varname `varlist'
end
