*! Pogram to compute an aggregate intertemporal poverty measure in a panel of individuals
*! Carlos Gradin (Universidade de Vigo)
*! This version 1.0.0  July 2013 

cap program drop povtime
program def povtime, rclass
syntax  [aweight iweight fweight] [if] [in] , y(string) z(string) t(integer) [NONnormalized THao(integer 1) Format(string) Gamma(string) Beta(string) Alpha(string) GENerate(string) DEComp gens(string) ]
version 7
marksample touse, novarlist	/* we want to check missings */

* checking there are no missings

tempname missing
qui: gen `missing'=.
forvalues j=1/`t' {
	qui: replace `missing'=1 if `y'`j'==. & `touse'
}

qui: sum `missing' if `touse'
local nmissing = r(N)
if `nmissing'~=0 {
	qui: replace `touse'=0 if `missing'==1
}



* We fix default value of parameter, and give consecutive numbers 1, 2, ... to betas

if "`gamma'" =="" {
	local gamma 0 1 2
}

if "`alpha'" =="" {
	local alpha 0 1 2
}

if "`beta'" =="" {
	local beta 0 1
}


foreach i in `beta' {
	local Beta `Beta' `i'
	*dis "`Beta'"
}

*************************** Constructing pi(gamma, beta)= individual intertemporal poverty indicators for each gamma and beta

* gi^gamma: 	temporal variable `g`j'_`i'' = (normalized or nonnormalized) gap with j=time (1,..T), and i=gamma (0, 1, 2, ...)
forvalues j = 1/`t' {
	tempname g`j'_0 g`j'_1 
	* non-normalized gaps if option -non- specified
	if "`nonnormalized'" ~= "" {
		qui: gen 	`g`j'_1'	= max(`z'`j'-`y'`j',0) if `touse'
	}
	* normalized gaps, default option
	else {
		qui: gen 	`g`j'_1'	= max((`z'`j'-`y'`j')/`z'`j',0) if `touse'
	}
	*list 	`g`j'_1'
	
	* the special case of gamma=0
	qui: gen 	`g`j'_0'		= 0 if `touse'
	qui: replace `g`j'_0' 	= 1 if `g`j'_1'>0 & `touse'
	*list 	`g`j'_0'
	
	* gaps to the power of gamma, gamma>0
	foreach i in `gamma' {
		if `i'>=2 {
			tempname g`j'_`i'
			qui: gen 	`g`j'_`i''	= `g`j'_1'^`i' if `touse'
			*list 	`g`j'_`i''
		}
	}
}

* di (to which spell each period belongs to: 1st, 2nd, ...,Tth): temporal variable `di_`j'' = number of spell with j=time (1,..T)
* qi (counts the number of poverty spells) temporal variable `qi_`j''

tempname di_1 qi_1
qui: gen `di_1'=1  if `touse'
qui: gen `qi_1'=0  if `touse' 
qui: replace `qi_1'=1  if `g1_0'>0 & `touse' 

forvalues j=2/`t' {
	tempname di_`j' qi_`j'
	local k=`j'-1
	qui: gen `di_`j''=`di_`k'' if `touse'
	qui: replace `di_`j''=`di_`k''+1  if `g`j'_0'~=`g`k'_0' & `touse'
	qui: gen `qi_`j''=`qi_`k'' if `touse'
	qui: replace `qi_`j''=`qi_`k''+1  if `g`j'_0'~=`g`k'_0' & `g`j'_0'>0 & `touse'
	
	*list `di_`j'' if _n<=10
}

* total number of poverty spells for each individual
	tempname npovspells
	qui: gen `npovspells'=`qi_`t'' if `touse'


* si: (poor or nonpoor) spell duration; temporal variable `si_`j'' = (number of periods in jth spell) and `sT_`j'' (relative, `si_`j''/T) (j=1st,...Tth)
* w(beta): (spell weight): temporal variable w_`b'_`j' = si^beta, that is, weight that corresponds to jth spell for each beta (b) =0, .5, 1, 2, 
forvalues j=1/`t' {
	tempname si_`j'
	qui: gen `si_`j''=0 if `touse'
	forvalues i=1/`t' {
		qui: replace `si_`j''=`si_`j'' + 1 if `di_`i''==`j' & `touse'
	}
	*list `si_`j'' if _n<=10

	* we keep si
	tempname s_`j'
	qui:  gen `s_`j''=`si_`j'' if `touse'

	* we divide by T
	qui: replace `si_`j''=`si_`j''/`t' if `touse'

	* we keep si/T
	tempname sT_`j'
	qui:  gen `sT_`j''=`si_`j'' if `touse'

	
	local k=0
	foreach b in `Beta' {
		local k=`k'+1
		tempname w_`k'_`j'
		qui: gen `w_`k'_`j''=`si_`j''^`b'  if `touse'
		*list `w_`k'_`j'' if _n<=10
	}
}

* number of betas to use
local nb=`k'
*dis "`nb'"

	
* wit(beta) temporal variable `wi_`b'_`j'' = weight(beta) that corresponds to each period j (=1, 2..T) depending on the duration of its spell
			* [if period j belongs to the ith spell, then `wi_`b'_`j'' = `w_`b'_`i'']
* sdit temporal variable `sd_`j' = duration of current spell (spell to which period `j' belongs)
			
forvalues j=1/`t' {
	local k=0
	tempname sd_`j'
	qui: gen `sd_`j''=0 if `touse'
	forvalues b=1/`nb' {
		tempname wi_`b'_`j'
		qui: gen `wi_`b'_`j''=0 if `touse'
	}
	
	forvalues i=1/`t' {
		qui: replace `sd_`j''=`s_`i'' if `di_`j''==`i' & `touse'
		forvalues b=1/`nb' {
			qui: replace `wi_`b'_`j''=`w_`b'_`i'' if `di_`j''==`i' & `touse'
		}
	}	
}

* pi(gamma, beta) = individual intertemporal poverty indicator  (gamma=0, 1, 2, ...; beta=0, 0.5, 1, 2)
* 		temporal variable `pi_`i'_`b'' = pi with i=gamma, b=beta

foreach i in `gamma' {
	forvalues b=1/`nb' {
		tempname pi_`i'_`b'
		qui: gen 	`pi_`i'_`b''=0 if `touse'
	}
	
	* we sum weighted gaps across time
	forvalues j = 1/`t' {
		forvalues b=1/`nb' {
			*dis "`b'"
			*list `pi_`i'_`b'' `g`j'_`i'' `wi_`b'_`j'' if _n<=10
			
			qui: replace `pi_`i'_`b'' = `pi_`i'_`b'' + `g`j'_`i''*`wi_`b'_`j'' if `touse'
			*dis "`i'_`b'_`j'"
			*list `pi_`i'_`b'' if _n<=10
		}
		*dis  "`i'_`b'"
	}
	
		
	*dis  "`i'"
	*list `pi_`i'_1' if _n<=10
	

		* we keep the number of poverty periods for each individual (=`pi_0_1') as temporal variable `npoor'
		* average duration of poverty spells (thao=1)
	if `i'==0 {
		tempname npoor
		qui: gen `npoor'=`pi_0_1'  if `touse'
		
		tempname meandur
		qui: gen `meandur'=`npoor'/`npovspells' if `touse'
	}
	
	
	* Chronic poverty, when thao is greater than 1/T
	forvalues b=1/`nb' {
		* the sum of weighted gaps across periods is divided by T
		qui: replace `pi_`i'_`b'' = (`pi_`i'_`b''/`t') if `touse'
		* pi=0 if individual is poor less than thao*T periods
		qui: replace `pi_`i'_`b'' = 0 if `npoor'<`thao' & `touse'
	}
	*dis  "`i'"
	*list `pi_`i'_1' if _n<=10
}

*************************** Constructing P(gamma, beta, alpha)= aggregate intertemporal poverty for each gamma, beta, and alpha

* pi(gamma,beta)^alpha (alpha=0, 1, 2, ...; gamma=0, 1, 2, ...; beta=0, .5, 1, 2): temporal variable `pi_`i'_`b'_`j'' (i=gamma; b=beta; j=alpha)
foreach i in `gamma' {
	foreach j in `alpha' {
		forvalues b=1/`nb' {		
			tempname pi_`i'_`b'_`j'
			qui: gen 	`pi_`i'_`b'_`j''=0 if `touse'
			qui: replace `pi_`i'_`b'_`j''=`pi_`i'_`b''^`j' if `pi_`i'_`b''>0 & `touse'
			*dis "`i'_`b'_`j'"
			*list `pi_`i'_`b'_`j''
		}
	}
}


* P(Y;z)= average of pi(gamma, beta)^alpha

tempname _alpha _gamma _beta P pov dec dec2
qui: gen `P'	 =.
qui: gen `_alpha'=.
qui: gen `_gamma'=.
qui: gen `_beta' =.

local k=1
foreach i in `gamma' {
	foreach j in `alpha' {
		forvalues b=1/`nb' {
			*dis "`i'_`b'_`j'"
			qui: sum `pi_`i'_`b'_`j'' [`weight' `exp']  if `touse'
			qui: replace `P'=r(mean) 	 if _n==`k'
			qui: replace `_gamma'=`i' 	 if _n==`k'
			qui: replace `_alpha'=`j' 	 if _n==`k'
			qui: replace `_beta' =`b' 	 if _n==`k'
			local k=`k'+1
			*dis "`k'"
		}
	
	}
}

**************************	 Decomposition if requested

if "`decomp'"~="" {
	tempname H I V CV2 Ep xx yy
	
	qui: gen `H' 		= `P'[1]
	
	qui: gen `I'	= .
	qui: gen `V'	= .
	qui: gen `CV2'	= .
	qui: gen `Ep'	= .
	qui: gen `xx' 	= .
	qui: gen `yy' 	= .
	
	local k=1
	foreach i in `gamma' {
		foreach j in `alpha' {
			
			forvalues b=1/`nb' {		
				*dis "`i'_`b'_`j'"
				*list `pi_`i'_`b'_`j''							if _n<=10
				qui: sum `pi_`i'_`b'' [`weight' `exp']  		if `touse' & `pi_`i'_`b''>0
				qui: replace 	`I'	= r(mean) 	 				if _n==`k'

				* alternative decomposition, only for alpha=2 and normalized gaps
				if `j'==2  & "`nonnormalized'" == "" {
					qui: replace 	`V'	  = r(Var) 	 			 if _n==`k'
					qui: replace	`CV2' = `V'/(1-`I')^2 		 if _n==`k'
					* to check that the decomposition works
					qui: replace 	`yy'  = `H'*( `I'^2 + `V' )  if _n==`k'
				}

				
				tempname ppi_`i'_`b'_`j'
				qui: gen `ppi_`i'_`b'_`j''= ( `pi_`i'_`b'' / r(mean) )^`j' - 1 if `touse'
				*list `ppi_`i'_`b'_`j'' `pi_`i'_`b'_`j'' if _n<=10
				qui: sum `ppi_`i'_`b'_`j'' [`weight' `exp']  	 if `touse' & `pi_`i'_`b'_`j''>0
				qui: replace	`Ep' = r(mean) 	 				 if _n==`k'
				qui: replace	`Ep' =0 						 if `Ep'<0
				* to check that the decomposition works
				qui: replace	`xx' = `H'*( `I'^`j' )*( 1+`Ep' ) if _n==`k'
				
				local k=`k'+1
			}
		}
	}
}

*list `_gamma' `_beta' `_alpha' `H' `I' `V' `Ep' `xx' `P' if `_gamma'~=.





**************************	 Saving variables if requested

/*

* Saving duration-related variables (only for checking program consistency)

 
if "`gens'" ~= "" {
	cap drop `gens'_*
	cap drop `gens'T_*
	cap drop `gens'sd_*
	cap drop `gens'W_*
	cap drop `gens'Wi_*
	
	forvalues j=1/`t' {
		qui: gen `gens'_`j' =`s_`j'' if `touse' 
		lab var `gens'_`j' 		"durantion of spell number `j' "
		
		qui: gen `gens'T_`j'=`sT_`j'' if `touse' 
		lab var  `gens'T_`j'	"relative duration of spell number `j' "
		*"weight corresponding to spell number `j' "
		
		qui: gen `gens'sd_`j' =`sd_`j''  if `touse' 
		lab var `gens'sd_`j'	"duration of current spell in period `j' "
		
		forvalues b=1/`nb' {
			qui: gen `gens'W_`j'_`b' =`w_`b'_`j''  if `touse' 
			lab var  `gens'W_`j'_`b' "weight corresponding to spell  `j' and beta number `b'  "
			qui: gen `gens'Wi_`j'_`b'=`wi_`b'_`j'' if `touse' 
			lab var  `gens'Wi_`j'_`b' "weight corresponding to period `j' and beta number `b'  "
		}
	}
}

*/

* Saving individual intertemporal poverty indicators, variable of the type pi_i_b (i=gamma; b=beta)

if "`generate'" ~= "" {
	cap drop `generate'_*
	foreach i in `gamma' {
		forvalues b=1/`nb' {
			qui: gen 	`generate'_`i'_`b'=`pi_`i'_`b''  if `touse' 
			lab var 	`generate'_`i'_`b' "Individual poverty indicator for gamma=`i' and beta number `b'"
		}
	}
}

***************************  Reporting results

lab var `_alpha' "alpha (a)"
lab var `_gamma' "gamma (g)"
lab var `_beta'  "beta (b)"


lab def `_beta'  -1 "" 
lab def `_alpha' -1 "" 
lab def `_gamma' -1 "" 

foreach j in `alpha' {
	lab def `_alpha' `j' "a=`j'", add
}

foreach i in `gamma' {
	lab def `_gamma' `i' "g=`i'", add
}

local k=0
foreach b in `Beta' {
	local k=`k'+1
	lab def `_beta' `k' "b=`b'", add
}


lab val `_alpha' `_alpha'
lab val `_beta'  `_beta'
lab val `_gamma' `_gamma'

*list `_gamma' `_alpha' `_beta' `P'

if "`format'" == "" {
	loc format "%9.4f"
}


********
dis ""
di as text "{hline 140}"
di ""
dis as result "Computing Aggregate Measure of Intertemporal Poverty, P(Y;z)"
dis ""
dis as text "based on Gradín, C., Del Río, C, and Cantó, O., <<Measuring Poverty Accounting for Time>>, Review of Income and Wealth, 2012"
dis ""
dis as text "Number of periods  = " as result `t'
dis ""
if "`nonnormalized'" == "" {
	dis as text "Based on" as result " normalized" as text " per-period poverty gaps"
}
else {
	dis as text "Based on" as result " unnormalized" as text " per-period poverty gaps"
}

dis as text "Thao = " as result `thao' " out of " `t'
dis as text "(those below the poverty line at least " as result `thao'  as text " out of " as result `t' as text  " periods are considered intertemporally poor)"
dis ""
tempname _npoor _npovspells _meandur
dis as text "% population ever poor (intertemporally poor)	= " as result %9.2f `P'[1]*100 "%"
dis ""
lab var `npoor' "Number of periods below the poverty line"
tab     `npoor'		 [`weight' `exp']	if `touse'
lab var `npovspells' "Number of poverty spells"
tab 	`npovspells' [`weight' `exp'] 	if `touse'
dis as text "(spell = 1 or more consecutive periods below the poverty line)"
dis ""
dis as text "For intertemporally poor population: "
qui: sum `npoor' [`weight' `exp'] 		if `npoor'>=`thao' & `touse'
scalar  `_npoor'=r(mean)
dis as text "-Average number of periods below the poverty line	= " as result `format' r(mean)
qui: sum `npovspells'  [`weight' `exp'] if `npoor'>=`thao' & `touse'
scalar  `_npovspells'=r(mean)
dis as text "-Average number of poverty spells 			= "	as result `format' r(mean)
qui: sum `meandur' [`weight' `exp'] 	if `npoor'>=`thao' & `touse'
scalar  `_meandur'=r(mean)
dis as text "-Average duration of poverty spells		= " as result `format' r(mean)
dis ""

dis as text "Aggregate Intertemporal Poverty Measure, P(Y;z;thao=" `thao' ",a,b,g)"

if `nmissing'~=0 {
	dis ""
	dis as text "Note: `y' variables contain  " as result `nmissing' as text "  observations with missings, not used in calculations"
	dis ""
}

*tabdisp `_gamma' `_alpha' 	     	if `P'~=.,  c(`P')  f(`format') by(`_beta')	concise stubwidth(15) csepwidth(1)
tabdisp `_alpha' `_gamma' `_beta' 	if `P'~=.,  c(`P')  f(`format') 			concise stubwidth(10) csepwidth(1)

dis ""
dis as text "Parameters:"
dis ""
dis as text "- gamma = sensitivity of individual intertemporal poverty indices to variability in per-period poverty"
dis as text "- beta  = sensitivity of individual intertemporal poverty indices to spells duration"
dis as text "- alpha = sensitivity of aggregate  intertemporal poverty measure to inequality among intertemporal poor individuals"
dis ""
dis as text "Relation with other measures:"
dis ""
dis as text "- Foster's (2009) measure is 			P(Y;z;thao>=1;alpha=1;beta=0;gamma>=0)"
dis as text "- Bossert et al.'s (2012) measure is T times 	P(Y;z;thao=1 ;alpha=1;beta=1;gamma>=0)"

/*
dis ""
dis as text "just to check that the descomposition is ok: "
tabdisp `_alpha' `_gamma' `_beta' 	if `P'~=.,  c(`P' `xx')  f(`format') 			concise stubwidth(10) csepwidth(1)
*/

if "`decomp'" ~= "" {
	dis ""
	dis as result "Decomposition into incidence, intensity, and inequality of interteporal poverty among the poor P(Y;z)=[1+Ep]*HI^a"
	tabdisp `_alpha' `_gamma' `_beta' 	if `P'~=.,  c(`H' `I' `Ep')  f(`format') 	concise stubwidth(10) csepwidth(1)
	dis as text "Rows for each alpha (a): "
	dis as text " (1) H -Head-count ratio-; (2) I -intensity-; (3) Ep -inequality of poverty among the poor (alpha>1) -"
}
dis ""

if "`decomp'" ~= "" & "`nonnormalized'" == "" {
	dis ""
	dis as result "For alpha=2, alternative decomposition based on inequality of 1-p (not p): P(Y;z)=H*[I^2 + C2(1-p)*(1-I)^2]"
	dis ""
	dis as text "Note that V(p) = C2(1-p)*(1-I)^2, P(Y;z)=H*[I^2 + V(p)]"
	dis ""
	tabdisp `_gamma' `_beta' 	if `P'~=. & `_alpha'==2,  c(`H' `I' `CV2' `V')  f(`format') 	concise stubwidth(10) csepwidth(1)
	dis as text "Rows for each gamma (g)): (1) H -Head-count ratio- (3) C2(1-p) -Squared Coef. of Var. of 1-p -"
	dis as text "                          (2) I -intensity-        (4) V(p) -Variance of p- "
	
	/*
	dis ""
	dis as text "just to check that the descomposition is ok: "
	tabdisp `_gamma' `_beta' 	if `P'~=. & `_alpha'==2,  c(`P' `yy')  f(`format') 			concise stubwidth(10) csepwidth(1)
	*/
}



* generating scalars for bootstraping

local k=1
foreach i in `gamma' {
	foreach j in `alpha' {
		forvalues b=1/`nb' {
			*dis "`i'_`b'_`j'"
			tempname P_`i'_`b'_`j'
			scalar `P_`i'_`b'_`j''=`P'[`k']
			ret 	scalar P_`i'_`b'_`j'=`P_`i'_`b'_`j''
			local k=`k'+1
			*dis "`k'"
		}
	}
}	


ret scalar everpoor=`P'[1]*100
ret scalar npoor=`_npoor'
ret scalar npovspells=`_npovspells'
ret scalar meandur=`_meandur'

* we recover true beta numbers (instead of consecutive integers)	

local r=1
foreach b in `Beta' {
	qui: replace `_beta'=`b' if `_beta'==`r'
	local r=`r'+1
}

mkmat `_gamma' `_beta' `_alpha' `P' if `P'~=., mat(`pov')
mat colnames `pov' = gamma N_of_beta alpha P(Y;z)
	
if "`decomp'"~="" {
	mkmat `H' `I' `Ep' if `P'~=., mat(`dec')
	mat colnames `dec' = H I Ep
	mat `pov' = `pov' , `dec'
			
	if "`nonnormalized'" == "" {
		mkmat `_gamma' `_beta' `_alpha' `P' `H' `I' `CV2' `V' if `P'~=. & `_alpha'==2, mat(`dec2')
		mat colnames `dec2' = gamma beta alfa  P(y;z) H I CV2 V
		return matrix dec2=`dec2'	
	}
}
return matrix pov=`pov'	



di ""
di as text "{hline 140}"

end
