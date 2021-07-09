* 1.0.0 HG 10 May 2020
program define vardistinct
	version 6.0
	syntax varlist [if] [in], GENerate(string) [by(varlist) Missing]
	if !mi("`missing'") {
		if !mi("`in'") & !mi("`by'") {
			bysort `by': egen `generate' = sum(tag) `if' `in'
		}
		else {
			if !mi("`by'") {
				egen tag = tag(`varlist' `by') `if' `in', m
				cap confirm variable `generate'
				if !_rc {
					drop tag
					gen `generate' = .
				}
				bysort `by': egen `generate' = sum(tag) `if' `in'
			}
			else {
				egen tag = tag(`varlist') `if' `in', m
				cap confirm variable `generate'
				if !_rc {
					drop tag
					gen `generate' = .
				}
				egen `generate' = sum(tag) `if' `in'
			}
			drop tag
		}
	}
	else {
		if !mi("`in'") & !mi("`by'") {
			bysort `by': egen `generate' = sum(tag) `if' `in'
		}
		else {
			if !mi("`by'") {
				egen tag = tag(`varlist' `by') `if' `in'
				cap confirm variable `generate'
				if !_rc {
					drop tag
					gen `generate' = .
				}
				bysort `by': egen `generate' = sum(tag) `if' `in'
			}
			else {
				egen tag = tag(`varlist') `if' `in'
				cap confirm variable `generate'
				if !_rc {
					drop tag
					gen `generate' = .
				}
				egen `generate' = sum(tag) `if' `in'
			}
			drop tag
		}
	}
end
