*! cic_examples.do
*! Changes-in-changes
*! Exmple of how to use the command (from cic.sthlp)
*! by Keith Kranker

// setup
sysuse nlsw88, clear
set seed 1
gen TREAT = uniform() < .5
replace wage = wage + TREAT
gen POST = uniform() < .5
replace wage = wage - POST

// estimate
cic continuous wage TREAT POST, vce(bootstrap, reps(50))
bootstrap, reps(50): cic all wage TREAT POST, at(50 90) did vce(none)
cic all wage TREAT POST, vce(delta) at(50)
cic dci wage TREAT POST i.occupation, at(50) vce(bootstrap, reps(50))
