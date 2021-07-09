* uniquestrata - Ensure that the given strata account for all observations uniquely

** Relies on -distinct- being installed.

capture program drop uniquestrata
program define uniquestrata
syntax varlist
version 9

local combinationcount = 1
foreach var of varlist `varlist' {
	qui distinct `var'
	local combinationcount = `combinationcount' * r(ndistinct)
}

qui count
if r(N) > `combinationcount' {
	di in red "Too many observations: You are missing some combinations of strata or need to specify more strata vars."
 	error 9
}
else if r(N) < `combinationcount' {
	di in red "Too many observations: You have specified too many strata vars."
 	error 9
}


end

