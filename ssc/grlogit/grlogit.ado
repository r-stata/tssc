program define grlogit
*! 1.0.0 6 June 2000 Jan Brogger
	version 6.0
	syntax varlist (max=2 min=2 numeric) [if/] [,gropt(string) debug]

	preserve

	tokenize "`varlist'"
	local dep "`1'"
	local indep "`2'"

	*tempvar freq_z
	capture confirm new variable freq_z
	if _rc ~= 0 {
		display ""
		exit 110
	}
	tempvar sum
	tempvar prev
	tempvar logit

	quietly {

		if "`if'"~="" {
			drop if !(`if') 
		}
		table `indep' `dep', replace name(freq_z)

		sort `indep'
		gen `sum'=.
		by `indep': replace `sum'=freq_z[_n]+freq_z[_N] if _n==1
		drop if `sum'==.
		gen `prev'=.
		replace `prev'=freq_z/`sum'
		gen `logit'=.
		replace `logit'=`prev'/(1-`prev')

		label variable `logit' "logit `dep'"

	}

	if "`debug'" ~= "" {
		di "gropt:`gropt'"
	}

	graph `logit' `indep' , c("l") t1("Logit `dep' vs `indep'") `gropt'
	
	restore
end
