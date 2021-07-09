*! 1.1.0 MLB 06 March 2013
*! 1.0.0 MLB 05 March 2013
program define qenv_sim_beta, rclass
	version 9
	drop _all
	set obs 10
	if c(stata_version) < 10.1 {
		gen x = uniform()
	}
	else {
		gen x = runiform()
	}
	sort x
	return scalar x = x[2]
end
	
