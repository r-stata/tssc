*! Pogram to compute Households' Employment Deprivation
*! Carlos Gradin
*! This version 1.0, April 2014


cap program drop unemp
program def unemp, rclass byable(recall)
syntax varname [aweight iweight fweight] [if] [in] , hid(varname) [ HSize(varname) THao(real 0) Format(string) Gamma(string) Alpha(string) GENerate(string) decomp ]
version 7
marksample touse /* missings and zero weights not used in calculations */
tempname gap
qui: gen `gap'=`1' if `touse'

if "`gamma'" =="" {
	local gamma 0 1 2
}

if "`alpha'" =="" {
	local alpha 0 1 2
}

tempname indw
gen `indw'=1


*************************** Constructing pi(gamma)= household employment deprivation indicators for each gamma

* gi^gamma: 	temporal variable `g`j'_`i'' = (normalized or nonnormalized) gap with j=time (1,..T), and i=gamma (0, 1, 2, ...maxg)

tempname g_0 g_1 

* the special case of gamma=1
qui: gen `g_1'=`gap' if `touse'

* the special case of gamma=0
qui: gen  	`g_0'	 = 0 if `touse'
qui: replace 	`g_0'	 = 1 if `g_1'>0 & `touse'
	
* gaps to the power of gamma, gamma>=2
foreach i in `gamma' {
	if `i'>=2 {
		*dis `i'
		tempname g_`i'
		qui: gen `g_`i'' = `g_1'^`i' if `touse'
	}
}

* pi(gamma) = household employment deprivation indicator (gamma=0, 1, 2, ...)
* 		temporal variable `pi_`i'' = pi with i=gamma

foreach i in `gamma' {
	*dis "`i'"
	* we sum gaps across individuals in the household
	tempname pi_`i' indw_`i'
	
	qui: bysort `hid' : egen 	`pi_`i''	= sum(`g_`i''*`indw') 	if `touse'
	qui: bysort `hid' : egen 	`indw_`i''	= sum(`indw') 		if `touse'
	qui: bysort `hid' : replace 	`pi_`i''	=`pi_`i''/`indw_`i'' 	if `touse'	
	*sum `pi_`i''
}



* we keep the % of deprived individuals /or hours) in each household (=`pi_1') as temporal variable `hhrate'
	* (we need to create it if gamma=1 was not requested)

if "`pi_1'"==""  {
	tempname pi_1 indw_1
	qui: bysort `hid' : egen 	`pi_1'	= sum(`g_1'*`indw') 	if `touse'
	qui: bysort `hid' : egen 	`indw_1'= sum(`indw') 	  	if `touse'
	qui: bysort `hid' : replace 	`pi_1'	=`pi_1'/`indw_1'  	if `touse'
}

tempname hhrate
qui: gen `hhrate'=`pi_1'  if `touse'

	* pi_1, `hhrate' is greater or equal than threshold th
		* pi_i=0 if household is deprived less than th

foreach i in `gamma' {
	qui: bysort `hid': replace `pi_`i'' = 0 if `hhrate' <= `thao' & `touse' & `thao'< 1
	qui: bysort `hid': replace `pi_`i'' = 0 if `hhrate' <  `thao' & `touse' & `thao'==1
}


*************************** Constructing P(gamma, alpha)= aggregate household employment deprivation measure for each gamma and alpha


* pi(gamma)^alpha (alpha=0, 1, 2, ...; gamma=0, 1, 2, ...): temporal variable `pi_`i'' (i=gamma; j=alpha)
foreach i in `gamma' {
	foreach j in `alpha' {
		tempname pi_`i'_`j'
		qui: gen 	`pi_`i'_`j''= 0 		if `touse'
		*dis "`i'"
		qui: replace 	`pi_`i'_`j''= `pi_`i''^`j' 	if `pi_`i''>0 & `touse'
		*dis "`i'_`j'"
		*list `pi_`i'_`j''
		*sum `pi_`i'_`j''
	}
}

* unweighted: only one observation kept per household


if "`hsize'" ~= "" {
	qui: bysort `hid': replace `touse'=0 if _n>1
	local exp "`exp'*`hsize'"
}


* P(Y;z)= average of pi(gamma)^alpha

tempname _alpha _gamma P 
qui: gen `P'=.
qui: gen `_alpha'=.
qui: gen `_gamma'=.

local k=1
foreach i in `gamma' {
	foreach j in `alpha' {
			*dis "`i'_`j'"
			qui: sum `pi_`i'_`j'' [`weight' `exp']  if `touse'
			*dis "k=`k'"
			qui: replace `P'=r(mean) 	 if _n==`k'
			qui: replace `_gamma'=`i' 	 if _n==`k'
			*tab `_gamma'
			qui: replace `_alpha'=`j' 	 if _n==`k'
			*tab `_alpha'
			local k=`k'+1
			*dis "`k'"
	}
}

*sum `_gamma' `_alpha'

**************************	 Decomposition if requested

if "`decomp'"~="" {
	tempname H I V CV2 Ep xx yy
	
	qui: gen `H' 	= `P'[1]
	
	qui: gen `I'	= .
	qui: gen `V'	= .
	qui: gen `CV2'	= .
	qui: gen `Ep'	= .
	qui: gen `xx' 	= .
	qui: gen `yy' 	= .
	
	local k=1
	foreach i in `gamma' {
		foreach j in `alpha' {
			
				*dis 		"`i'_`j'__`k'"
				*list 		`pi_`i'_`j''					if _n<=10
				qui: sum 	`pi_`i'' [`weight' `exp']  			if `touse' & `pi_`i''>0
				qui: replace 	`I'	= r(mean) 	 			if _n==`k'

				* alternative decomposition, only for alpha=2
				if `j'==2  {
					qui: replace 	`V'	   = r(Var) 	 		if _n==`k'
					qui: replace	`CV2'   = `V'/(1-`I')^2 	 	if _n==`k'
					* to check that the decomposition works
					qui: replace 	`yy'   = `H'*( `I'^2 + `V' ) 		if _n==`k'
				}

				
				tempname ppi_`i'_`j'
				qui: gen 	`ppi_`i'_`j''= ( `pi_`i'' / r(mean) )^`j' - 1 if `touse'
				*list 		`ppi_`i'_`j'' `pi_`i'_`j'' 		if _n<=10
				qui: sum 	`ppi_`i'_`j'' [`weight' `exp']  	if `touse' & `pi_`i'_`j''>0
				qui: replace	`Ep' = r(mean) 	 		 	if _n==`k'
				qui: replace	`Ep' =0 			 	if `Ep'<0
				
				* to check that the decomposition works
				qui: replace	`xx' = `H'*( `I'^`j' )*( 1+`Ep' ) 	if _n==`k'
				
				local k=`k'+1
		}
	}
}

*list `gamma' `alpha' `H' `I' `V' `Ep' `xx' `P' if `gamma'~=.


**************************	 Saving variables if requested


* Saving "household employment deprivation indicators, variable of the type pi_i (i=gamma)

if "`generate'" ~= "" {
	cap drop `generate'_*
	foreach i in `gamma'  {
		qui: gen `generate'_`i'=`pi_`i''  if `touse' 
		lab var  `generate'_`i' "household employment deprivation indicator for gamma=`i'"
	}
}


***************************  Reporting results

lab var `_alpha' "alpha"
lab var `_gamma' "gamma"

lab def `_alpha' -1 ""
lab def `_gamma' -1 ""

lab var `P' "Households employment deprivation"

cap lab var `H' H
cap lab var `CV2' "C2(1-u)"
cap lab var `I' I
cap lab var `V' "V(u)"
cap lab var `Ep' "Ep(u)"

foreach j in `alpha' {
	lab def `_alpha' `j' "`j'", add
}

foreach i in `gamma' {
	lab def `_gamma' `i' "`i'", add
}


lab val `_alpha' `_alpha'
lab val `_gamma' `_gamma'

*list `_gamma' `_alpha' `P'

if "`format'" == "" {
	loc format "%9.4f"
}


********
dis ""
di as text "{hline 140}"
di ""
dis as result "Computing Employment Deprivation among Households"
dis ""
dis as text "Based on Gradín, C., Del Río, C, and Cantó, O., <<Measuring employment deprivation in the EU using a household-level index, Review of the Economics of the Household>>, REHO"
dis ""

dis as text "Individual Employment Gaps given by variable " as result "`1'"
dis as text "	(only observations with nonmissing value used in calculations)"
dis ""

dis as text "Threshold = " as result `thao'

if `thao'==0 {
	dis as text "	(all households with employment deprivation indicator u(gamma=1) > 0 are considered deprived)" 
}
if `thao'>0 & `thao'<1 {
	dis as text "	(only households with employment deprivation indicator u(gamma=1) > " as result `thao' as text " are considered deprived)" 
}
if `thao'==1 {
	dis as text "	(only households with employment deprivation indicator u(gamma=1) = 1 are considered deprived)" 
}

dis ""
if "`head'" ~= "" {
dis as text "Aggregate Households' Employment Deprivation Index, U(.) across" as result " households" as text
dis as text "             each household is weighted according to the weight of the household head (" as result "`head'""==1" as text ") regardless of its size "
}
else {
dis as text "Aggregate Household Employment Deprivation Index, U(.)
}

	tabdisp `_alpha' `_gamma' if `P'~=.,  c(`P')  f(`format') 			concise stubwidth(10) csepwidth(1)

	dis ""
	dis as text "Parameters:"
	dis ""
	dis as text " - gamma = sensitivity of household employment deprivation indices to variability of employment within the household"
	dis as text " - alpha = sensitivity of aggregate households' employment deprivation measure to inequality among deprived households"


if "`decomp'" ~= "" {
	dis ""
	dis as result "Decomposition into incidence, intensity, and inequality of deprivation in employment among deprived households U(Y;z)=[1+Ep]*HI^a"
	
	tabdisp `_alpha' `_gamma' if `P'~=.,  c(`H' `I' `Ep')  f(`format') 	concise stubwidth(10) csepwidth(1)
	
	
	dis as text "Rows for each alpha (a): "

	dis as text " (1) H -Head-count ratio-; (2) I -intensity-; (3) Ep -inequality of deprivation in employment among deprived households (alpha>1)-"

	/*
	dis ""
	dis as text "just to check that the descomposition is ok: "
	tabdisp `_alpha' `_gamma' if `P'~=.,  c(`P' `xx')  f(`format') 			concise stubwidth(10) csepwidth(1)
	*/

}

dis ""

qui: sum `_alpha'
if "`decomp'" ~= "" & r(max)>=2 {
	dis ""
	dis as result "For alpha=2, alternative decomposition based on inequality of employment (1-u) (not deprivation, u): U_2(u)=H*[I^2 + C2(1-u)*(1-I)^2]"
	dis ""
	dis as text "Note that U_2(u)=H*[I^2 + V(u)], where V(u) = C2(1-u)*(1-I)^2"
	dis ""
	tabdisp `_gamma' if `P'~=. & `_alpha'==2,  c(`H' `I' `CV2' `V')  f(`format') 	concise stubwidth(10) csepwidth(1)

	dis as text "(1) H -Head-count ratio- (3) C2(1-u) -Squared Coef. of Var. of 1-u -"
	dis as text "(2) I -intensity-        (4) V(u) -Variance of u- "
	

	/*
	dis ""
	dis as text "just to check that the descomposition is ok: "
	tabdisp `_alpha' `_gamma' if `P'~=. & `_alpha'==2,  c(`P' `yy')  f(`format') concise stubwidth(10) csepwidth(1)
	*/
}

* generating scalars for bootstraping

local k=1
foreach i in `gamma' {
	foreach j in `alpha' {
		*dis "`i'_`j'"
		tempname U_`i'_`j'
		scalar `U_`i'_`j''=`P'[`k']
		ret 	scalar U_`i'_`j'=`U_`i'_`j''
		local k=`k'+1
		*dis "`k'"
	}
}	

tempname pov dec dec2
mkmat `_gamma' `_alpha' `P' if `P'~=., mat(`pov')
mat colnames `pov' = gamma alpha U
	
if "`decomp'"~="" {
	mkmat `H' `I' `Ep' if `P'~=., mat(`dec')
	mat colnames `dec' = H I Ep
	mat `pov' = `pov' , `dec'
			
	if "`nonnormalized'" == "" {
		mkmat `_gamma' `_alpha' `P' `H' `I' `CV2' `V' if `P'~=. & `_alpha'==2, mat(`dec2')
		mat colnames `dec2' = gamma alfa  U H I CV2 V
		return matrix dec2=`dec2'	
	}
}
return matrix unemp=`pov'	

di as text "{hline 140}"

end
