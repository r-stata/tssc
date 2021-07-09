// Minimal example, using over-simple built-in imputation models

// mvadmar.dta is a copy of mvad.dta with random runs of missingness
// imposed for testing. 
use mvadmar
mict_prep state, id(id)
mict_impute



// Append the data with missing
append using mvadmar
replace _mct_iter = 0 if missing(_mct_iter)

// For comparison, append the fully observed data
// (mvadmar.dta is mvad.dta with random missingness imposed for testing).
append using mvad
replace _mct_iter = -1 if missing(_mct_iter)

sort id _mct_iter


// Create a string representation of the sequence
local symbols "ABCDEFGH"
gen str72 seqstr = ""
forvalues x = 1/72 {
  replace seqstr = seqstr + substr("`symbols'",state`x',1) if !missing(state`x') & state`x'>0
  replace seqstr = seqstr + "." if missing(state`x') | state`x'<=0
}

by id: gen imputable = regexm(seqstr[2], "\.")

// Examine true, simulated missing and imputed data
list id _mct_iter seqstr if imputable, sepby(id)
