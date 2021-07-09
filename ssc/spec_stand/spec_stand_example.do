
/*use dataset of standard population */
use spec_stand_pop_2000.dta,clear
egen byte ageband=cut(AGE),at(45,55,65,75,85,150)
tempfile standard
save `standard'

/* use dataset of data and applies the command spec_stand */
use spec_stand_ex.dta, clear
spec_stand num den ageband ,by(indic year) using(`standard') namepopstd(POP) norest const(1000) format(%6.3f)


