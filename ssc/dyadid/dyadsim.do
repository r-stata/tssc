// dyadsim.dta is based on the household structure of the
// Wave 18 British Household Panel Survey, but with simulated
// data values.
// See https://www.iser.essex.ac.uk/bhps for more info. 

use dyadsim

// Generate dyad record indices for father, mother, spouse
dyadid id fid, gen(fidx)
dyadid id mid, gen(midx)
dyadid id sid, gen(sidx)

// Get spouse's age
gen spage = age[sidx]

// Compare spouse pair ages
ttest spage == age if sex==1
scatter spage age if sex==1, xtitle("Male's age") ytitle("Female's age") || function x, range(age)

// Get parents' employment status, where they are present
gen feun = eun[fidx]
gen meun = eun[midx]
label values feun eun
label values meun eun

tab eun feun
tab meun feun
