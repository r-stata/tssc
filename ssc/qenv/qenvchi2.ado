*! 1.0.0 MLB 26 February 2013
program qenvchi2, rclass
	version 9
	syntax varname(numeric) [if] [in], [ df(numlist min=1 max=1 >0) *]

	marksample touse
	qui count if `touse'
	if r(N) == 0 error 2000
	
	if "`df'" == "" {
		sum `varlist' if `touse', meanonly
		if r(mean) <= 0 {
			di as err "the mean of `varlist' is less than or equal to 0"
			exit 411
		}
		local alpha = r(mean)/2
	}
	else {
		local alpha = `df'/2
	}
	
	qenvgamma `varlist' if `touse', `options' alpha(`alpha') beta(2)
	
	return scalar df = `alpha'*2
end
