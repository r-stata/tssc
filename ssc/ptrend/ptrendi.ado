*! version 2.0.0 PR 27oct2014
program define ptrendi /* chisq for trend, based on Stata tabi.ado */
	version 8.0
	tokenize "`*'", parse(",\ ")

	local r 1 
	local c 1
	local cols .
	while ("`1'"!="" & "`1'"!=",") { 
		if "`1'"=="\" {
			local ++r
			if `cols'==. { 
				if `c' <= 2 { 
					di as err "too few columns"
					exit 198
				}
				local cols `c'
			}
			else {
				if (`c'!=`cols') error 198
			}
			local c 1
		}
		else {
			if `c' < 3 {
				confirm integer num `1'
				if (`1' < 0) error 411
			}
			else {
				confirm num `1'
			}
			local n`r'`c' `1'
			local ++c
		}
		mac shift
	}
	if (`c'!=`cols') error 198
	local --cols
	if (`cols'!=3) error 198
	local rows = `r' 
			
/*
	!! replacing next few lines, to conform with
	!! standard `immediate command' operation.

	local options "REPLACE *"
	parse "`*'"
	if "`replace'"=="" & _N!=0 { 
		preserve
	}
	capture {
*/
	tokenize "`*'"
	preserve
	quietly {
		drop _all
		set obs `rows'
		gen long r = .
		gen long nr = .
		gen x = .
		forvalues r = 1/`rows' {
			forvalues c = 1/`cols' {
				if (`c'==1)      replace r = `n`r'`c'' in `r'
				else if (`c'==2) replace nr = `n`r'`c'' in `r'
				else if (`c'==3) replace x = `n`r'`c'' in `r'
			}
		}
		gen _prop = r / (r + nr)
		format _prop %8.3f
		format r %8.0f
		format nr %8.0f
		format x %8.2f
	}
/*
	Trend calculation.
*/
	ptrend r nr x _prop
end
