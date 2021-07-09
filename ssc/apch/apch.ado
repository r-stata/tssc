program define apch, eclass
    version 11.0 
syntax varlist(numeric ts) [fw aw pw iw] [if] [in], ///
    [age(varname numeric) period(varname numeric) /// 
      offset(varname numeric) exposure(varname numeric) *]
	 
   marksample touse
   markout `touse' `age' `period' `offset' `exposure'
tempname bic0
tempname  bic1
tempname  bicd
tempname  bicd0
tempname  bicd1
tempname dbic_cohort 
tempname dbic_hyster 
tempname	CC
tempname	HH
tempname	aar
tempname	ccr
tempname	ppr
tempvar	agag
tempvar	pepe
tempvar	aaa
tempvar	ccc
tempvar	coco
tempvar	end
tempvar	ppp
tempvar	y
tempvar	tempa
tempvar	tempy
tempvar	coeffcoh
tempvar	hystecoh
tempvar	hyst1
tempvar	w2


* apch version 1.6 / 2 Nov 2011

di ""
di ""
di ""
di ""
di ""
di ""
di ""
di ""
di ""
di ""
di "*********************"	
di "* apch version 1.6  *"	
di "*********************"	
di ""


local expb = subinstr("`exp'","=","",.)
local expc : word count `expb'
if (`expc'==0) {
	quietly: gen `w2'= 1
	}
else {
	quietly: gen `w2'= `expb'
	}
local lc : word count `varlist'
forvalues i = 1(1)`lc' { 
		local nomy`i' : word `i' of `varlist'
	    }
		
local control ""
forvalues i = 2/`lc' { 
		local toto `nomy`i''
		local control "`control' `toto'"
	    }

*quietly: gen `y' = `nomy1'   if `touse'
quietly: gen `aaa' = `age'   if `touse'
quietly: gen `ppp' = `period'   if `touse'

quietly: tostring `aaa' `ppp'  , generate(`tempa' `tempy')
quietly: encode `tempa'  if `touse', gen(`agag')
quietly: encode `tempy'  if `touse', gen(`pepe')
*drop `temp*'

quietly: su `agag'
local maag=int(r(max))
quietly: su `pepe'
local mape=int(r(max))
quietly: gen `ccc' = `period' -`age'   if `touse'
quietly: su `ccc' if `touse'

quietly: gen `coco' = `pepe'-`agag'+`maag'
quietly: su `coco'
local maco=int(r(max))

*tab `aaa' `ppp', su(`ccc') nofreq nost w

quietly: su `agag' [fw=`w2']
quietly: gen rescaage =2*(`agag'-r(min))/(r(max)-r(min))-1
quietly: gen rescaper =(`pepe')/(r(max)-r(min))
quietly: gen rescacoh =(`coco')/(r(max)-r(min))
quietly: su rescaper [fw=`w2']
quietly: replace rescaper =rescaper-(r(max)+r(min))/2
quietly: su rescacoh  [fw=`w2']
quietly: replace rescacoh  =rescacoh -(r(max)+r(min))/2

quietly: replace rescaage =rescaage +runiform()*.001-.0005
quietly: replace rescacoh =rescacoh +runiform()*.001-.0005
quietly: replace rescaper =rescaper +runiform()*.001-.0005

quietly tab `aaa' if `touse', matrow(`aar')
quietly tab `ppp' if `touse', matrow(`ppr')
quietly tab `ccc' if `touse', matrow(`ccr')
local pace `aar'[2,1]-`aar'[1,1] 

forvalues i = 1(1)`maco' { 
tempvar cc`i' 
 quietly: gen `cc`i''= (`i'==`coco' )+runiform()*.001-.0005  if `touse'
 local ccrr=`ccr'[`i',1]
 quietly: gen coh_`ccrr'= `cc`i''   if `touse'
 }

forvalues i = 1(1)`maag' { 
tempvar aa`i' 
 quietly: gen `aa`i''= (`i'==`agag')+runiform()*.001-.0005
 local aarr=`aar'[`i',1]
 quietly: gen age_00`aarr'= `aa`i''    if `touse'
 }

forvalues i = 1(1)`mape' {
tempvar pp`i' 
 quietly: gen `pp`i''= (`i'==`pepe')+runiform()*.001-.0005
 local pprr=`ppr'[`i',1]
 quietly: gen per_`pprr'= `pp`i''    if `touse'
 }

local consg1 "0"
local consg2 "0"
local listcoh ""
local macob=int(`maco'-1)
forvalues i=2(1)`macob' {
	local j=int(-`maco'-1+`i'*2)
	local k=`ccr'[`i',1]
      local consg1 "`consg1'+coh_`k'"
      local consg2 "`consg2'+(`j')*coh_`k'"
	local listcoh "`listcoh' coh_`k'"
 	}
local consg1 "`consg1'=0"
local consg2 "`consg2'=0"
 
 
local consg3 "0"
local consg4 "0"
forvalues i=1(1)`maag' {
	local j=int(-`maag'-1+`i'*2)
	local k=`aar'[`i',1]
      local consg3 "`consg3'+age_00`k'"
      local consg4 "`consg4'+(`j')*age_00`k'"
 	}
local consg3 "`consg3'=0"
local consg4 "`consg4'=0"

local consg5 "0"
local consg6 "0"
forvalues i=1(1)`mape' {
	local j=int(-`mape'-1+`i'*2)
	local k=`ppr'[`i',1]
      local consg5 "`consg5'+per_`k'"
      local consg6 "`consg6'+(`j')*per_`k'"
 	}
local consg5 "`consg5'=0"
local consg6 "`consg6'=0"

quietly: compress
constraint 1  `consg1'
constraint 2  `consg2'
constraint 3  `consg3'
constraint 4  `consg4'
constraint 5  `consg5'
constraint 6  `consg6'

*di ""
*di ""
*di "#######      AP model   #######"
quietly: glm  `nomy1' age_00* per_* rescacoh  rescaage  `control'  `in'  [`weight' `exp'] if `coco'!=1 & `coco'<`maco' & `touse', ///
	`options'  constraints ( 3 4 5 6 )    
	scalar  `bic0'=e(bic)
	est store mcoho0
	
di ""
di ""
di "*******************************************"
di "#######   1st APC Detrended model   #######"
di "*******************************************"
di ""

glm  `nomy1' `listcoh' age_00* per_* rescacoh  rescaage  `control'   `in' [`weight' `exp'] if `coco'!=1 & `coco'<`maco' & `touse', ///
	`options'  constraints (1 2 3 4 5 6)  
	
	scalar  `bic1'=e(bic)
	est store mcoho1

	matrix `CC'= (e(b))' /*vector of apc estimates*/

	quietly: 	gen coeffcoh =.

	forvalues i = 2(1)`macob' { 
	quietly: replace coeffcoh = `CC'[`i'-1,1]  if  `coco'==`i'
	}

	quietly: gen hystecoh = rescaage*coeffcoh
	
	constraint 7 coeffcoh = 1 

	quietly: glm  `nomy1' coeffcoh hystecoh age_00* per_*  rescacoh  rescaage `control'  `in'  [`weight' `exp'] if `coco'!=1 & `coco'<`maco'  & `touse', ///
	`options'  constraints ( 3 4 5 6 7)    

	scalar  `bicd'=e(bic)
	est store mhyster

	matrix `HH'= (e(b))'
	local h1=`HH'[2,1]	

	quietly: gen hyst1=hystecoh *`h1'

di ""
di ""
di "**************************************************"
di "#######   2nd step: iterative APCH model   #######"
di "**************************************************"
di ""
di ""

	
local flag =1
local s=2
scalar hysteresis1 =`h1'


while `flag'>0 { 

	

local r = `s'-1
quietly: gen 	hyst`s'=hyst`r'
constraint 8 hyst`r'  = 1 
quietly: glm  `nomy1' `listcoh' hyst`r' age_00* per_* rescacoh  rescaage  `control'   `in' [`weight' `exp'] if `coco'!=1 & `coco'<`maco' & `touse', ///
	`options'  constraints (1 2 3 4 5 6 8)  
	local bicb`s'=e(bic)
	est store mcoho

	matrix `CC'= (e(b))' /*vector of apc estimates*/


	forvalues i = 2(1)`macob' { 
	quietly: replace coeffcoh = `CC'[`i'-1,1]  if  `coco'==`i'
	}
	matrix `CC'= (e(b))' /*vector of apc estimates*/

	forvalues i = 2(1)`macob' { 
	quietly: replace coeffcoh = `CC'[`i'-1,1]  if  `coco'==`i'
	}

	quietly: replace hystecoh = rescaage*coeffcoh

quietly: glm  `nomy1' coeffcoh  age_00* per_*  rescacoh  rescaage  `control'  `in'  [`weight' `exp'] if `coco'!=1 & `coco'<`maco'  & `touse', ///
	`options'  constraints ( 3 4 5 6 )    
	scalar  `bicd0'=e(bic)
	est store mapc

quietly: glm  `nomy1' coeffcoh hystecoh age_00* per_*  rescacoh  rescaage  `control'  `in'  [`weight' `exp'] if `coco'!=1 & `coco'<`maco'  & `touse', ///
	`options'  constraints ( 3 4 5 6 7)    
	scalar  `bicd1'=e(bic)
	est store mhyster

	matrix `HH'= (e(b))'
	local h1=`HH'[2,1]	

quietly: replace hyst`s'=hystecoh *`h1'
scalar hysteresis`s' = `h1' 
scalar deltahyst`s'=abs(hysteresis`s'-hysteresis`r')
di ""
di "Iteration " `s' "      hysteresis`s'= " hysteresis`s' "        deltahyst`s'= " deltahyst`s'

if `s'<5 | (deltahyst`s'>.01 & `s'<30) {
local flag=1


}
else {
local flag=0
}
local s=`s'+1
}

quietly: gen `end'=. 
drop `w2'-`end'

di ""
di ""
di ""
di ""
di ""
di ""
di ""
di ""
di ""
di ""
di ""
di ""
di "***************************************************"
di "* Estimates of the final Detrended Cohort Effects *"
di "***************************************************"
di "" 
est restore mcoho
estimates replay mcoho
di ""
di ""
di ""
di "*************************************************"
di "* Estimates of the final Hysteresis Coefficient *"
di "*************************************************"
di "" 
est restore mhyster
estimates replay mhyster

scalar `dbic_cohort' = `bic1'-`bic0'
scalar `dbic_hyster' = `bicd1'-`bic1' 

di ""
di ""
di ""
di ""
di ""
di "Delta bic APC compared to AP"
di "dbic_cohort  =   " `dbic_cohort'   
di ""
di "Delta bic APCH compared to APC"
di "dbic_hyster  =   " `dbic_hyster'   
di ""


end

 
