
*! version 1.0.0  31aug2007

program  metatrend
version 8.0
syntax varlist(min=2 max=2 numeric) [if] [in]



set more off
/*The first argument is the logOR and the second is its Standard Error (SE) */



/* Initial calculations. Generating the rank of the studies and handling missing inputs*/

tempvar id
qui egen `id' = fill(1 2)
qui   replace `id'=. if  `1'==. |`2'==. 
tempvar id2
qui egen `id2'=group(`id')

qui drop `id'
qui rename `id2' `id'

tempvar id_all
qui gen `id_all' = `id'

qui summ `1' if `1'!=.
local m=r(N)

tempvar logorsr sesr
qui gen `logorsr'=`1'
qui gen `sesr'=`2'

local logor1=`logorsr'[1]
local se1=`sesr'[1]

/* Cumulative meta-analysis */

forvalues i=2(1)`m'{

	preserve
	qui drop if `id' >`i' | `1'==.|`2'==.
	tempvar logorw sumwor sumw logorsf sesf sumwq q isq sumwsq d weir logorwr sumworr sumwr   
	
	qui gen `logorw'=`1'/(`2')^2
	qui egen `sumwor'=sum(`logorw') 
	qui egen `sumw'=sum(1/`2'^2) 
	qui gen `logorsf'=`sumwor'/`sumw' 
	qui gen `sesf' =1/`sumw'
	
	qui gen `sumwq'=((`logorsf' -`1')^2)/(`2'^2)
	qui egen `q'=sum(`sumwq')
	qui gen `isq'=max(0, (`q'-`i' +1)/`q') 
	qui egen `sumwsq'=sum(1/`2'^4) 
	
	qui gen `d'=0
	qui replace `d'= max(0, (`q'-`i'+1)/(`sumw' - (`sumwsq'/`sumw')))
	
	qui gen `weir'=1/(`d'+`2'^2) 
	qui gen `logorwr'=`1'*`weir'
	qui egen `sumworr'=sum(`logorwr') 
	qui egen `sumwr'=sum(`weir') 
	
	local ll =`sumworr'/`sumwr' 
	local ss = sqrt(1/`sumwr')
	
	restore
	qui replace `logorsr'=`ll' if `id'== `i'
	qui replace `sesr' =`ss' if `id'==`i'

 }
 



 
tempvar low1 up1
qui gen `up1'=`logorsr'+1.96*`sesr'
qui gen `low1'=`logorsr'-1.96*`sesr'

local up `up1'
local low `low1'
local cumlogor `logorsr'
local cumse `sesr'

tempvar ii
qui gen `ii'=1

/* The regression-based test using GLS */

qui xtgls `logorsr' `id' [aw=1/`sesr'^2],corr(ar1) i(`ii') t(`id') p(h)
local coef1=_b[`id']
local secoef1=_se[`id']
local rho1= e(rho)
tempvar pr1
qui predict `pr1'  if e(sample)
local pred1 `pr1'
 
tempvar drop _all

/* Calculations excluding the first study */

tempvar id
qui egen `id' = fill(1 2)
qui   replace `id'=. if  `1'==.  |`2'==. 
tempvar id2
qui egen `id2'=group(`id')
qui drop `id'
qui rename `id2' `id'

tempvar logorsr sesr

qui gen `logorsr'=`1' 
qui gen `sesr'=`2' 
qui replace `logorsr'=. if `id' ==1
qui replace `sesr'=. if `id' ==1
qui replace `id'=. if `id' ==1
tempvar id3
qui egen `id3'=group(`id')
qui drop `id'
qui rename `id3' `id'





/* Cumulative meta-analysis excluding the first study*/

forvalues i=2(1)`m'{

	preserve
	
	
	qui drop if `id' >`i' | `1'==.|`2'==. 
	
	
	tempvar logorw sumwor sumw logorsf sesf sumwq q isq sumwsq d weir logorwr sumworr sumwr   
	
	qui gen `logorw'=`1'/(`2')^2 
	qui egen `sumwor'=sum(`logorw') 
	qui egen `sumw'=sum(1/`2'^2) 
	qui gen `logorsf'=`sumwor'/`sumw' 
	qui gen `sesf' =1/`sumw'
	
	qui gen `sumwq'=((`logorsf' -`1')^2)/(`2'^2)
	qui egen `q'=sum(`sumwq') 
	qui gen `isq'=max(0, (`q'-`i' +1)/`q') 
	qui egen `sumwsq'=sum(1/`2'^4)
	
	qui gen `d'=0
	qui replace `d'= max(0, (`q'-`i'+1)/(`sumw' - (`sumwsq'/`sumw')))
	
	qui gen `weir'=1/(`d'+`2'^2) 
	qui gen `logorwr'=`1'*`weir'
	qui egen `sumworr'=sum(`logorwr') 
	qui egen `sumwr'=sum(`weir') 
	
	local ll2 =`sumworr'/`sumwr' 
	local ss2 = sqrt(1/`sumwr')
	/*di `ll' `ss'*/ 
	restore
	qui replace `logorsr'=`ll2' if `id'== `i'
	qui replace `sesr' =`ss2' if `id'==`i'

 }

tempvar ii
qui gen `ii'=1
 
 
 
 /*list `logorsr' `sesr'*/
 
 
 
/* The regression-based test using GLS */

qui xtgls `logorsr' `id' [aw=1/`sesr'^2],corr(ar1) i(`ii') t(`id') p(h)
local coef2=_b[`id']
local secoef2=_se[`id']
local rho2= e(rho)
tempvar pr2
qui predict `pr2' if e(sample)
local pred2 `pr2'
 
 

 
preserve
qui drop if `logorsr'==.
qui drop if `sesr'==.
local logork=`logorsr'[_N]
local sek=`sesr'[_N]

restore


/* The "first vs. subsequent" approach test*/

local z=(`logor1'-`logork')/sqrt(`se1'^2+`sek'^2)
local p=2*min(1-normprob(`z'), normprob(`z'))


/*The graph of the cumulative meta-analysis*/

qui label var `pred1' "Including first study"
qui label var `pred2' "Excluding first study"
qui label var `id_all' "Rank of the studies"
gr7 `cumlogor'  `low' `up' `pred1' `pred2'  `id_all' [aw=1/`cumse'^2], c(.IIll[-]) s(Oiii) xlab ylab  title(Cumulative meta-analysis plot) l1title(Cumulative ES (log-scale))


/*Display of the results*/

di " "
di in gr "Tests for detecting trends in cumulative meta-analysis"
di in gr "------------------------------------------------------"
di " "
di in gr "Number of studies: " in ye `m'
/*di in gr "Number of individuals (Cases/Controls): " in ye "`total' (`cases'""/""`controls')" */
di " "
di in gr "'First vs. Subsequent' method"
di in gr "-----------------------------------------------------------------------------------"
di in gr "                    Effect Size (ES)     P-value      [95% Conf. Interval]"
di in gr "First study       " in ye %12.4f exp(`logor1') %17.3f  2*min(1-normprob(`logor1'/`se1'), normprob(`logor1'/`se1'))   %16.4f exp(`logor1'-1.96*`se1') %8.4f exp(`logor1'+1.96*`se1')
di in gr "Subsequent studies" in ye %12.4f exp(`logork') %17.3f  2*min(1-normprob(`logork'/`sek'), normprob(`logork'/`sek'))   %16.4f exp(`logork'-1.96*`sek') %8.4f exp(`logork'+1.96*`sek')
di ""
di in gr "All Studies       " in ye %12.4f exp(`ll') %17.3f  2*min(1-normprob(`ll'/`ss'), normprob(`ll'/`ss'))   %16.4f exp(`ll'-1.96*`ss') %8.4f exp(`ll'+1.96*`ss')
di in gr "-----------------------------------------------------------------------------------"
di ""

di in gr "Test for the equality of the ESs"
di in gr "--------------------------------"
di ""
di in gr "Ho: ES(first) = ES(subsequent)"
di ""
di in gr "z-value = "in ye %6.3f `z'
di in gr "P-value = "in ye %6.3f `p'

di " "
di " "
di " "
di in gr "Generalized Least Squares (GLS) Regression-based test"
di in gr "-----------------------------------------------------------------------------------"
di in gr "                         Coef.    Std. Err.  P-value  [95% Conf. Interval]    rho"
di in gr "Including all studies  " in ye %8.5f `coef1'  %11.5f  `secoef1' %9.3f  2*min(1-normprob(`coef1'/`secoef1'), normprob(`coef1'/`secoef1'))  %12.5f  `coef1'-1.96*`secoef1' %10.5f  `coef1'+1.96*`secoef1'  %9.3f `rho1'  
di in gr "Excluding first study  " in ye %8.5f `coef2'  %11.5f  `secoef2' %9.3f  2*min(1-normprob(`coef2'/`secoef2'), normprob(`coef2'/`secoef2'))  %12.5f  `coef2'-1.96*`secoef2' %10.5f  `coef2'+1.96*`secoef2'  %9.3f `rho2'  
di in gr "-----------------------------------------------------------------------------------"
di " "

end






