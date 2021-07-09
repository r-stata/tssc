program define apcd, rclass
    version 11.0 
syntax varlist(numeric ts) [fw aw pw iw] [if] [in], ///
    [age(varname numeric) period(varname numeric) /// 
      offset(varname numeric) exposure(varname numeric) *]
	 
		marksample touse
   markout `touse' `age' `period' `offset' `exposure'
tempname bic0  bic1  bicd  bicd0  bicd1 dbic_cohort  dbic_hyster CC HH aar ccr ppr
tempvar	agag pepe aaa 	ccc coco end  ppp y tempa tempy coeffcoh hystecoh hyst1 w2 alpha omega 

gen alpha=.


* apcd version 1.1 / April 5 2012
* this ado file quotes fractions of the Yang & colleagues apc_ie.ado (ssc install apc) 

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
di "* apcd version 1.1  *"	
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

di ""
di ""
di "*******************************************"
di "#######       AP model              #######"
di "*******************************************"
di ""

glm  `nomy1' age_00* per_* rescacoh  rescaage  `control'  `in'  [`weight' `exp'] if `coco'!=1 & `coco'<`maco' & `touse', ///
	`options'  constraints ( 3 4 5 6 )    
	scalar  `bic0'=e(bic)
	est store mcoho0
	
di ""
di ""
di "*******************************************"
di "#######       APC Detrended model   #######"
di "*******************************************"
di ""
gen omega=.
glm  `nomy1' `listcoh' age_00* per_* rescacoh  rescaage  `control'   `in' [`weight' `exp'] if `coco'!=1 & `coco'<`maco' & `touse', ///
	`options'  constraints (1 2 3 4 5 6)  
	predict predictedapcd, xb 
	predict residuedevapcd, deviance 
	scalar  `bic1'=e(bic)
	drop alpha-omega

	   return local bicap = `bic0'
	   return local bicapcd = `bic1'
	   return local deltabic= `bic1'-`bic0'
di ""
di ""
di "*******************************************"
di "Delta Bic = "  `bic1'-`bic0' 
di "*******************************************"
di ""

	  end

 

