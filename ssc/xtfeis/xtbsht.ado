/*
User-written Stata ado
Computes Bootstrapped Hausman Test (BSHT) with pairwise-clustered sampling
Author: Volker Ludwig
Version 1.0: 16-04-2019
*/

program define xtbsht, rclass
syntax anything , [reps(integer 50)] [seed(string)] [cluster] [keep(varlist numeric fv ts)]

if `"`: word count `anything''"' != "2" {
	di as err "You need to specify the names of two models to compare" 
}

tokenize `anything'
local model1 `1'
macro shift
local model2 `*'

qui est restore `model2'
local est2 `"`e(cmdline)'"'
qui est restore `model1'
local est1 `"`e(cmdline)'"'

//returned results
tempvar sam
qui ge `sam'=0
qui replace `sam'=1 if e(sample)
local touse `"`sam'"'
local av `"`e(depvar)'"'
local uv `"`e(indepvar)'"'
local slope `"`e(slopevar)'"'
local id `"`e(ivar)'"'
local noconstant `"`e(noconstant)'"'

local uvnames : colfullnames e(b)
local uvnames=subinstr("`uvnames'"," _cons","",.)
_ms_extract_varlist `uvnames', noomitted
local uvnames `"`r(varlist)'"'


if (length("`keep'")>0) {
	fvunab keep : `keep'
	_ms_extract_varlist `keep', noomitted
	local uvnames `"`r(varlist)'"'
}

local k : word count `uvnames' 

//Get coefs 
tempname b _b_ b1 b2 bv

//Model 1
mat `b'=e(b)'
foreach v of local uvnames {
	mat `_b_'=`b'[`"`v'"',1]
	local bv=`_b_'[1,1]
	mat `b1' = (nullmat(`b1') \ `bv')
	cap mat drop `_b_'
}
mat rownames `b1' = `uvnames'

//Model 2
qui est restore `model2'
cap mat drop `b' 
mat `b'=e(b)'
foreach v of local uvnames {
	mat `_b_'=`b'[`"`v'"',1]
	local bv=`_b_'[1,1]
	mat `b2' = (nullmat(`b2') \ `bv')
	cap mat drop `_b_'
}
mat rownames `b2' = `uvnames'


//Pairwise cluster Bootstrapping 

tempname bs1 bs2 newid

mat `bs1'=J(`reps',`k',.)
mat `bs2'=J(`reps',`k',.)

if length("`seed'")>0 {
	qui set seed `seed'
}
forv i=1/`reps' {
	preserve
	qui bsample if `touse', cluster(`id') idcluster(`newid')
	qui replace `id'=`newid'
	qui xtset `id' `_dta[tis]'
	qui `est1'
*	qui xtfeis `av' `uv', slope(`slope') cluster(`id') 
	qui keep if e(sample)
	local n=1
	foreach v of local uvnames {
		mat `bs1'[`i',`n']=_b[`v']
		local n=`n'+1
	}
	qui `est2'  
*	qui xtreg `av' `uv' `slope' if `touse', fe  cluster(`id')  
	local n=1
	foreach v of local uvnames {
		mat `bs2'[`i',`n']=_b[`v']
		local n=`n'+1
	}
	forv j=0(50)`reps' {
		if `i'==`j' {
			di in red "`i'"
		}
	}
	restore
}	

//Results
//matrix of diff in coefficients
tempname bdiff U m1 m2 bdiffm diff V H
mat `bdiff'=`bs1'-`bs2'

mat `U' = J(`reps',1,1)
mat `m1' = `U'*((`U''*`bs1')/`reps')
mat `m2' = `U'*((`U''*`bs2')/`reps')

mat `bdiffm'=(`m1'-`m2')
mat `diff'=`bdiff'-`bdiffm'
//Covariance matrix
mat `V'=`diff''*`diff'
mat `V'=`V'/(`reps'-1)

//Hausman test statistic
mat `H' = (`b1'-`b2')' * invsym(`V') * (`b1'-`b2')
local H=`H'[1,1]

//p-value
local p=chiprob(`k',`H')

//s.e. of diff in coeff
tempname v se 
mat `v'=vecdiag(`V')'
mat `se' = J(`k',1,.)
forval i = 1/`k' { 
	mat `se'[`i',1] = sqrt(`v'[`i',1]) 
}
mat rownames `se' = `uvnames'

di _newline(3)
di "----------------------------------------------"
di _n as text "Bootstrapped Hausman Test" _n
di _n as text "Pairwise-clustered Bootstrapping" _n
di "----------------------------------------------"
di _newline(1)
di as text "Comparing models: " as res "`model1'" as text " and " as res "`model2'" 
di _newline(1)
di as text "Bootstrapped estimates with " as res `reps' as text " replications" 
di as text "Sampling from clusters defined by " as res "`id'" 
di _newline(1)
di in gr "Test of H0: estimates of `model1' and `model2' consistent" 
di in gr "Alternative H1: `model1' consistent, `model2' inconsistent"
di _newline(1)
di in gr "Test statistic: chi2(`k') =" _column(35) as res %6.2f `H' 
di in gr "Prob > chi2 =" _column(35) as res %6.4f `p' 

//return results
return local p `p'
return local chi2 `H'
return local df `k'
return local reps `reps'
return matrix V_diff `V'
return matrix b1 `b1'
return matrix b2 `b2'

end 
