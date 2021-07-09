/***************************************************************************************************
original code from egenmore 
https://ideas.repec.org/c/boc/bocode/s386401.html
***************************************************************************************************/

program _gfastxtile, byable(onecall) sortpreserve
version 10
gettoken type 0 : 0
gettoken h    0 : 0 
gettoken eqs  0 : 0

syntax varname(numeric) [if] [in] [, ///
Percentiles(string) ///
Nquantiles(string) ///
Weights(string) ALTdef by(varlist) ]

marksample touse 

// Error Checks

if "`altdef'" ~= "" & "`weights'" ~= "" {
	di as error "weights are not allowed with altdef"
	exit 111
}

if "`percentiles'" != "" & "`nquantiles'" != "" {
	di as error "do not specify percentiles and nquantiles"
	exit 198
}

// Default Settings etc.

if "`weights'" ~= "" {
	local weight "[aw = `weights']"
}

if "`percentiles'" != "" {
	local percnum "`percentiles'"
}
else if "`nquantiles'" != "" {
	local perc = 100/`nquantiles'
	local first = `perc'
	local step = `perc'
	local last = 100-`perc'
	local percnum "`first'(`step')`last'"
}

if "`nquantiles'" == "" & "`percentiles'" == "" {
	local percnum 50
}

quietly {
	gen `type' `h' = .
	if "`by'"=="" {
		// Without by
		local i 1
		_pctile `varlist' `weight' if `touse', percentiles(`percnum') `altdef'
		foreach p of numlist `percnum' {
			if `i' == 1 {
				replace `h' = `i' if `varlist' <= r(r`i') & `touse'
			}
			replace `h' = `++i' if `varlist' > r(r`--i')  & `touse'
			local i = `i' + 1
		}
	}
	else{
		// With by
		count if `touse'
		local samplesize=r(N)
		local touse_first=_N-`samplesize'+1
		local touse_last=_N
		tempvar bylength
		local type = cond(c(N)>c(maxlong), "double", "long")
		bys `touse' `by' : gen `type' `bylength' = _N 
		local start = `touse_first'
		while `start' <= `touse_last'{
			local end = `start' + `=`bylength'[`start']' - 1
			_pctile `varlist' `weight' in `start'/`end', percentiles(`percnum') `altdef'
			local j = 1
			foreach p of numlist `percnum' {
				if `j' == 1 {
					replace `h' = `j' if `varlist' <= r(r`j') in `start'/`end'
				}
				replace `h' = `++j' if `varlist' > r(r`--j')  in `start'/`end'
				local j = `j' + 1
			}
			local start = `end' + 1
		}
	}
}
end

