*! Nikolas Mittag 02Feb2013

cap program drop mrprobit
program define mrprobit, eclass properties(b V svyb svyr svyj)
version 10.0
syntax varlist(min=1 numeric) [if] [in] [pweight fweight aweight iweight], [MODELOpts(string)] [MAXopts(string)] [Init(string)] [alpha0(string)] [alpha1(string)] [C0] [C1] [Predict]
marksample touse
gettoken dep cov : varlist
tempname par bo v vo g bp

*set up alphas
*alpha0
*constrain alpha0 to a number (alpha0(#))
else if real("`alpha0'")!=. {
	if `alpha0'>0 & `alpha0'<1 local a0=logit(`alpha0')
	else {
		if `alpha0'==0 local a0=-600
		if `alpha0'==1 local a0=600
		if `alpha0'>1 | `alpha0'<0 {
			di as err "Invalid constraint, alpha0 must be in [0,1]"
			exit
		}
	}
constraint 1 [alpha0]_cons=`a0'
local const "1"
}
else if "`alpha0'"!="" {
	*alpha0 contains probability of FP
	*variable specified is considered a probability if 1. only one var specified 2. all obs in [0,1] and 3. values other than 0 and 1 exist
	if wordcount("`alpha0'")==1 & "`c0'"=="" {
		qui: sum `alpha0' if `touse'
		if `r(max)'>1 | `r(min)'<0 local c0 "c0"
		else {
			qui: inspect `alpha0'
			if `r(N_pos)'==`r(N_posint)' local c0 "c0"
			else {
				tempvar pr0
				qui: gen `pr0'=logit(`alpha0') if `touse'
				qui: replace `pr0'=1e10 if `alpha0'==1
				qui: replace `pr0'=-1e10 if `alpha0'==0
				qui: markout `touse' `pr0'
				constraint 1 [alpha0]`pr0'=1
				local const "1"
				local avar=0
				local avar0 "`pr0'"
			}
		}
	}
	*alpha0 contains variables that define cells
	if wordcount("`alpha0'")>1 | "`c0'"!="" {
		tempvar groups0
		capture egen `groups0'=group(`alpha0') if `touse', missing lname(a0lb)
		if _rc!=0 {
			di as err "Could not create groups based on option alpha0(), egen aborted with error code " _rc
			exit
		}
		qui: sum `groups0' if `touse'
		if r(max)>_N/5 {
			di as result "Variables in option alpha0() define `r(max)' groups. With " _N " observations, estimation will likely be unstable"
		}
		tempvar cellsa0
		qui: tab `groups0' if `touse', gen(`cellsa0')
		local avar=0
		local avar0 "`cellsa0'*"
		local c0 "c0"
	}
}

*alpha1
if real("`alpha1'")!=. {
	if `alpha1'>0 & `alpha1'<1 local a1=logit(`alpha1')
	else {
		if `alpha1'==0 local a1=-600
		if `alpha1'==1 local a1=600
		if `alpha1'>1 | `alpha1'<0 {
			di as err "Invalid constraint, alpha1 must be in [0,1]"
			exit
		}
	}
constraint 2 [alpha1]_cons=`a1'
local const "`const' 2"
}
else if "`alpha1'"!=""{
	*alpha1 contains probability of FP
	*variable specified is considered a probability if 1. only one var specified 2. all obs in [0,1] and 3. values other than 0 and 1 exist
	if wordcount("`alpha1'")==1 & "`c1'"=="" {
		qui: sum `alpha1' if `touse'
		if `r(max)'>1 | `r(min)'<0 local c1 "c1"
		else {
			qui: inspect `alpha1'  if `touse'
			if `r(N_pos)'==`r(N_posint)' local c1 "c1"
			else {
				tempvar pr1
				qui: gen `pr1'=logit(`alpha1') if `touse'
				qui: replace `pr1'=1e10 if `alpha1'==1
				qui: replace `pr1'=-1e10 if `alpha1'==0
				qui: markout `touse' `pr0'
				constraint 2 [alpha1]`pr1'=1
				local const "`const' 2"
				if "`avar'"=="" local avar=1
				else local avar=2
				local avar1 "`pr1'"
			}
		}
	}
	*alpha1 contains variables that define cells
	if wordcount("`alpha1'")>1 | "`c1'"!="" {
		tempvar groups1
		capture egen `groups1'=group(`alpha1') if `touse', missing lname(a1lb)
		if _rc!=0 {
			di as err "Could not create groups based on option alpha1(), egen aborted with error code " _rc
			exit
		}
		qui: sum `groups1' if `touse'
		if r(max)>_N/5 {
			di as result "Variables in option alpha1() define `r(max)' groups. With " _N " observations, estimation will likely be unstable"
		}
		tempvar cellsa1
		qui: tab `groups1' if `touse', gen(`cellsa1')
		if "`avar'"=="" local avar=1
		else local avar=2
		local avar1 "`cellsa1'*"
		local c1 "c1"
	}
}

if "`avar'"=="" local model "(Probit:`dep'=`cov') /alpha0 /alpha1"
else {
	if `avar'==0 local model "(Probit:`dep'=`cov') (alpha0:`dep'=`avar0', nocons) /alpha1"
	if `avar'==1 local model "(Probit:`dep'=`cov') /alpha0 (alpha1:`dep'=`avar1', nocons)"
	if `avar'==2 local model "(Probit:`dep'=`cov') (alpha0:`dep'=`avar0', nocons) (alpha1:`dep'=`avar1', nocons)"
}

if "`const'"!="" {
	if strmatch(lower("`modelopts'"),"*const*")==0 local modelopts "`modelopts' constraint(`const')"
	else {
		di as result "Cannot impose constraints on alpha since other constraints are already imposed. If you want to keep these constraints and constrain alpha to a number, define an additional constraint for [alpha#]_cons (where # is 0 or 1). If you want to specify error probabilities for alpha, constrain [alpha#]varname==1 (where varname is the name of the variables containing the probabilities). If you have no clue why this error appears, I probably messed up the code."
		exit
	}
}

*initial values: set alphas to zero
qui: probit `dep' `cov' if `touse' [`weight' `exp']
mat def `bp'=e(b)


*run ml -> currently do not include error if alpha0+alpha1>1, so likelihood function may converge to maximum at (1-alpha0),(1-alpha1)
local conv=0
if strmatch(lower("`maxopts'"),"*nooutput*")==0 local maxopts "nooutput `maxopts'"
capture noisily {
ml model lf mrprlik `model'  if `touse' [`weight' `exp'], `modelopts' missing

ml search /alpha0 -10 0 /alpha1 -10 0
if "`init'"=="" ml init `bp'
else ml init `init'
ml maximize, `maxopts'
local conv=e(converged)
}
if ((_rc==430 | `conv'==0) & strmatch(lower("`maxopts'"),"*dif*")==0) {
	di "Maximization did not converge, specifying 'difficult'"
	local maxopts "`maxopts' difficult"
	capture noisily {
		capture ml report
		if _rc!=0 {
			ml model lf mrprlik `model'  if `touse' [`weight' `exp'], `modelopts' missing			
			ml search /alpha0 -10 0 /alpha1 -10 0
			if "`init'"=="" ml init `bp'
			else ml init `init'
		}
		ml maximize, `maxopts'
		local conv=e(converged)
	}
}
if ((_rc==430 |`conv'==0) & strmatch(lower("`modelopts'"),"*tech*")==0) {
	di "Maximization did not converge, specifying 'difficult' and switching methods"
	capture noisily {
		ml model lf mrprlik `model' if `touse' [`weight' `exp'], technique(dfp bfgs nr bhhh) missing `modelopts'
		ml search /alpha0 -10 0 /alpha1 -10 0
		if "`init'"=="" ml init `bp'
		else ml init `init'
		ml maximize, `maxopts'
		local conv=e(converged)
	}
}
if _rc!=0 {
di as error "Maximization failed with error code " _rc
exit
}
if `conv'==0 {
di as error "Maximization did not converge"
exit
}

*transform alphas
mat def `par'=e(b)
mat def `bo'=e(b)
mat def `v'=e(V)
mat def `vo'=e(V)
mat def `g'=e(gradient)

local i: length local cov
if (`c(version)'>=11 | `i'>244) {
	if `i'>244 & `c(version)'<11 di "Warning: Parameter transformation will not work if Stata 10 has dropped variables from the model. Please make sure all variables from your estimation command are actually included in the parameter vector."
	local i: word count `cov'
	local i=`i'+2
} 
else {
	local names: coleq `par'
	local i=wordcount(substr("`names'",1,strpos("`names'","alpha0")-1))+1
}	

if "`avar0'"=="`pr0'" & "`avar0'"!="" local i=`i'+1
while `i'<=colsof(`par') {
	if `i'==colsof(`par') & "`avar1'"=="`pr1'" & "`avar1'"!="" continue, break
	mat def `par'[1,`i']=invlogit(`par'[1,`i'])
	mat def `v'[1,`i']=`v'[1...,`i']*`par'[1,`i']*(1-`par'[1,`i'])
	mat def `v'[`i',1]=`v'[`i',1...]*`par'[1,`i']*(1-`par'[1,`i'])
	mat def `g'[1,`i']=`g'[1,`i']/`par'[1,`i']*(1-`par'[1,`i'])
	local i=`i'+1
}

local i=wordcount("`cov'")+2
local names: colnames `par'
while `i'<=colsof(`par') {
local names=subinword("`names'",word("`names'",`i'),"_cons",.)
local i=`i'+1
}
matrix colnames `par'=`names'
matrix colnames `v'=`names'
matrix rownames `v'=`names'

ereturn repost b=`par' V=`v', properties(b V svyb svyr svyj) rename
ereturn matrix gradient `g'
ereturn matrix b_o `bo'
ereturn matrix V_o `vo'
ereturn local cmd "mrprobit"
if "`predict'"!="" {
	mat def `g'=J(1,4,0)
	ereturn matrix rules `g'
	ereturn local predict "probit_p"
	local depvar=word(e(depvar),1)
	ereturn local depvar `depvar'
}

*display output
mat def `par'=e(b)
mat def `v'=e(V)
local neq=e(k_eq)

di in smcl as text _col(51) "Number of obs" as text _col(67) "=" as res %11.0g e(N)
di in smcl as text _col(51) "Wald chi2(" as res e(df_m) as text ")" _col(67) "=" as res %11.2f e(chi2)
di in smcl as text"Log likelihood = " as res %11.3f e(ll) as text _col(51) "Prob > chi2" _col(67) "=" as res %11.4f e(p) _newline(1)

di in smcl as text "{hline 13}{c TT}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}"
di in smcl as text `"`dep'{col 14}{c |}      Coef.{col 26}   Std. Err.{col 37}      z{col 46}   P>|z|{col 55}    [95% Conf. Interval]"'

local names: coleq `par'
local names2: colnames `par'
tokenize `names'
local j=1

di in smcl as text "{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}"
di in smcl as res "Probit" as text "{col 14}{text}{c |}"
local eq=word("`names'",`j')
while word("`names'",`j')=="`eq'" {
	di in smcl as text %12s abbrev(word("`names2'",`j'),11) _col(14) "{c |}" _col(17) as res %9.0g `par'[1,`j'] _col(28) %9.0g sqrt(`v'[`j',`j']) _col(38) %8.2f `par'[1,`j']/sqrt(`v'[`j',`j'])  _col(49) %4.3f 2*(1-normal(abs(`par'[1,`j']/sqrt(`v'[`j',`j'])))) _col(58) %9.0g `par'[1,`j']-1.96*sqrt(`v'[`j',`j']) _col(70) %9.0g `par'[1,`j']+1.96*sqrt(`v'[`j',`j'])
	local j=`j'+1
}

foreach i of numlist 0/1 {
	if "`avar`i''"=="" | "`avar`i''"=="`cellsa`i''*"==1 {
		di in smcl as text "{hline 13}{c +}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}"
		di in smcl as res "alpha`i'" as text "{col 14}{text}{c |}"
		local eq="``j''"
		if "`c`i''"!="" local k=1
		while "``j''"=="`eq'" {
			if "`c`i''"!="" local lab : label (`groups`i'') `k' 12
			di in smcl as text %12s cond("`c`i''"=="",abbrev(word("`names2'",`j'),12),"`lab'") _col(14) "{c |}" _col(17) as res %9.0g `par'[1,`j'] _col(28) %9.0g sqrt(`v'[`j',`j']) _col(38) %8.2f `par'[1,`j']/sqrt(`v'[`j',`j'])  _col(49) %4.3f 2*(1-normal(abs(`par'[1,`j']/sqrt(`v'[`j',`j'])))) _col(58) %9.0g `par'[1,`j']-1.96*sqrt(`v'[`j',`j']) _col(70) %9.0g `par'[1,`j']+1.96*sqrt(`v'[`j',`j'])
			local j=`j'+1
			if "c`i'"!="" local k=`k'+1
		}
	}
}

di in smcl as text "{hline 13}{c BT}{hline 11}{hline 11}{hline 9}{hline 9}{hline 12}{hline 12}"

end

