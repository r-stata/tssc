* version 1.1 10Mar2021  Matteo Pinna, matteo.pinna@gess.ethz.ch

cap program drop inlist2
program define inlist2
version 12.1
	syntax varlist (min=1 max=1), VALues(string) [  ///
	/* optional */ name(string) ///
	]
	
	if ("`name'"=="") local name "inlist2" 
	capture confirm variable `name'
	if (!_rc==1) di as error "Warning: inlist2 is replacing a preexisting variable with the same name. See option name(string)"
	cap drop `name'
	
	tokenize "`values'", parse(",")
	local num_values=((length("`values'") - length(subinstr("`values'",",","", .)))*2)+1
	cap gen `name'=.
	capture confirm string variable `varlist'
		if !_rc {
			forvalues iteration=1(2)`num_values' {
			replace `name'=1 if `varlist'=="``iteration''"
			}	
		}
		else {
			forvalues iteration=1(2)`num_values'{
			replace `name'=1 if `varlist'==``iteration''
			}
		}
end
	
	
