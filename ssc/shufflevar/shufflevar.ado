*1.1 GHR January 24, 2011

*changelog
*1.1 -- fixed bug that let one case per "cluster" be misallocated (thanks to Elizabeth Blankenspoor)

capture program drop shufflevar
program define shufflevar
	version 10
	syntax varlist(min=1) [ , Joint DROPold cluster(varname)]
	tempvar oldsortorder
	gen `oldsortorder'=[_n]
	if "`cluster'"!="" {
		local bystatement "by `cluster': "
	}
	else {
		local bystatement ""
	}
	if "`joint'"=="joint" {
		tempvar newsortorder
		gen `newsortorder'=uniform()
		sort `cluster' `newsortorder'
		foreach var in `varlist' {
			capture drop `var'_shuffled
			quietly {
				`bystatement' gen `var'_shuffled=`var'[_n-1]
				`bystatement' replace `var'_shuffled=`var'[_N] if _n==1
			}
			if "`dropold'"=="dropold" {
				drop `var'
			}
		}
		sort `oldsortorder'
		drop `newsortorder' `oldsortorder'
	}
	else {
		foreach var in `varlist' {
			tempvar newsortorder
			gen `newsortorder'=uniform()
			sort `cluster' `newsortorder'
			capture drop `var'_shuffled
			quietly {
				`bystatement' gen `var'_shuffled=`var'[_n-1]
				`bystatement' replace `var'_shuffled=`var'[_N] if _n==1
			}
			drop `newsortorder'
			if "`dropold'"=="dropold" {
				drop `var'
			}
		}
		sort `oldsortorder'
		drop `oldsortorder'
	}
end

