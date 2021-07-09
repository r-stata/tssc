/***************************************************************************************************
original code from egenmore 
https://ideas.repec.org/c/boc/bocode/s386401.html
***************************************************************************************************/

program define _gfastwpctile
	version 10, missing
	syntax newvarname =/exp [if] [in]  [, p(real 50) BY(varlist) ALTdef Weights(varname)]

	if `p'<=0 | `p'>=100 { 
		di in red "p(`p') must be between 0 and 100"
		exit 198
	}
	tempvar touse x


	if "`altdef'" ~= "" & "`weights'" ~= "" {
		local optweights "[aweight=`weights']"
		if "`altdef'" != "" { 
			di as error "weights are not allowed with altdef"
			exit 198 
		}
	}

	quietly {
		mark `touse' `if' `in'
		cap confirm variable `exp'
		if _rc{
			gen double `x' = `exp' if `touse'
		}
		else{
			local x exp
		}
		if "`by'"=="" {
			_pctile `x' `optweights' if `touse', p(`p') `altdef'
			gen `typlist' `varlist' = r(r1) if `touse'
		}
		else{
			count if `touse'
			local samplesize = r(N)
			local touse_first = _N - `samplesize' + 1
			local touse_last = _N


			gen `typlist' `varlist' = .
			tempvar bylength
			local type = cond(c(N)>c(maxlong), "double", "long")
			bys `touse' `by' : gen `type' `bylength' = _N 
			local start = `touse_first'
			while `start' <= `touse_last'{
				local end  = `start' + `=`bylength'[`start']' - 1
				_pctile  `x' `optweights' in `start'/`end', percentiles(`p') `altdef'
				qui replace `varlist' = r(r1) in `start'/`end'
				local start = `end' + 1
			}
			
		}
	}
end
