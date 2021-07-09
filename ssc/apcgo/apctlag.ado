
	capture which oaxaca
	if _rc==111 ssc install oaxaca
	capture which apcd
	if _rc==111 ssc install apcd
	capture which apch
	if _rc==111 ssc install apch
	
 program apctlag, rclass        
 version 10.0     
 syntax varlist(numeric ts) [fw aw pw iw] [if] [in], ///     
 [age(varname numeric) period(varname numeric) ///      
 offset(varname numeric) exposure(varname numeric) rep(real 1) *]     
 marksample touse     
 * tempvar `toto'     
        
 if `rep'<2 {    
 capture: apctlagb `varlist' if `touse' [`weight'`exp'] ,age(`age') period( `period') `options'    
 if _rc!=0 {    
 di as error "The data must be a complete rectangle (age x period) and the pace between periods must be fix and equal to the distance between age groups."    
 }    
 else {    
 matlist r(table)    
 }    
 }    
 else{    
 forval i=1 2 to `rep' {     
 preserve     
 bsample     
 if mod(`i',50)==0 noi di `i' _c    
 capture: apctlagb `varlist' if `touse' [`weight'`exp'] ,age(`age') period( `period') `options'    
  mat std1=r(table)
  mat std1=std1*std1'
  mat std1=vecdiag(std1)'
  if `i'==1 { 
	mat sd1=std1 
	mat bs1=r(table)
	}
	else {
	mat sd1=(std1+sd1)
	mat  bs1 =(r(table)+bs1)
    }    
if mod(`i',10)==0 noi di "+"  _c    
 restore     
 }     
 if _rc!=0 di as error "The data must be a complete rectangle (age x period) and the pace between periods must be fix and equal to the distance between age groups."    
 capture mat drop table     
 capture mat drop tos     
 mat meanbs1=bs1/`rep'
 mat bssq1=vecdiag(meanbs1*meanbs1')'
 mat sdmean1=sd1/`rep'
 mat Vbs1=sdmean1-bssq1

 
 local en= rowsof(bs1)    
 forval i=1 2 to  `en' {    
 loc lb=meanbs1[`i',1]-(Vbs1[`i',1])^0.5*2    
 loc ub=meanbs1[`i',1]+(Vbs1[`i',1])^0.5*2     
 mat def rtab=meanbs1[`i',1],`lb', `ub'    
 mat def table=(nullmat(table)\rtab)    
 }    
 

 
 
 local names : rownames meanbs1    
 local vrnam : colnames r(table)    
 matrix rownames table=`names'    
     
 matrix colnames table="`vrnam'" "[Cl_L" "Cl_U]"    
 if table[1,1]!=. matlist table, format(%9.3f)    
 return matrix explained=table    
 capture mat drop bs1     
 capture mat drop table     
 capture mat drop meanbs1     
 capture mat drop sdmean1     
 capture mat drop cl     
 capture mat drop sl     
 capture mat drop dis     
 capture mat drop Vbs1     
 capture mat drop dsl     
 capture mat drop sd1    
 capture mat drop std1    
 }
  end    
       
 program define apctlagb, rclass     
    version 11.0      
      
syntax varlist(numeric ts) [fw aw pw iw] [if] [in], ///     
    [age(varname numeric) period(varname numeric) ///      
      offset(varname numeric) exposure(varname numeric) *]     
    
        
 marksample touse                          
    markout `touse' `age' `period' `offset' `exposure'                          
 tempname bic0  bic1  bicd  bicd0  bicd1 dbic_cohort  dbic_hyster CC HH aar ccr ppr                           
 tempvar agag pepe gaga aaa ccc coco coh end  ppp y tempa tempy tempg coeffcoh hystecoh hyst1 w2 diffea cn rgap valgap gapone gapzero ga1 ga0 alpha omega rescaage rescacoh rescaper                       
 qui {                          
       
 local varnam ""       
     
* apctlag version 1.1 / Nov 10 2016    
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
di "************************"      
di "* apctlag version 1.1  *"      
di "************************"      
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
local cntnam ""     
local nam ""    
forvalues i = 2/`lc' {      
local toto `nomy`i''     
local control "`control' `toto'"     
local nam = "`nomy`i''"    
local cntnam "`cntnam' `nam'"    
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
quietly: gen `rescaage' =2*(`agag'-r(min))/(r(max)-r(min))-1     
quietly: gen `rescaper' =(`pepe')/(r(max)-r(min))     
quietly: gen `rescacoh' =(`coco')/(r(max)-r(min))     
quietly: su `rescaper' [fw=`w2']     
quietly: replace `rescaper' =`rescaper'-(r(max)+r(min))/2     
quietly: su `rescacoh'  [fw=`w2']     
quietly: replace `rescacoh'  =`rescacoh' -(r(max)+r(min))/2     
     
quietly: replace `rescaage' =`rescaage' +runiform()*.001-.0005     
quietly: replace `rescacoh' =`rescacoh' +runiform()*.001-.0005     
quietly: replace `rescaper' =`rescaper' +runiform()*.001-.0005     
     
quietly tab `aaa' if `touse', matrow(`aar')     
quietly tab `ppp' if `touse', matrow(`ppr')     
quietly tab `ccc' if `touse', matrow(`ccr')     
local pace = `aar'[2,1]-`aar'[1,1]    
    
      
 forvalues i = 1(1)`maco' {                           
 tempvar cc`i'                        
  qui: gen `cc`i''= (`i'==`coco' )+runiform()*.001-.0005  if `touse'                          
  local ccrr=`ccr'[`i',1]     
  tempvar coh_`ccrr'     
  gen `coh_`ccrr''= `cc`i''  if `touse'      
   if `i'>1 & `i'<`maco' local varnam "`varnam' coh_`ccrr'"     
  }                          
       
 forvalues i = 1(1)`maag' {                           
 tempvar aa`i'                           
  noi: gen `aa`i''= (`i'==`agag')+runiform()*.001-.0005       
  su `aa`i''    
  local aarr=`aar'[`i',1]        
  tempvar age_00`aarr'     
  gen `age_00`aarr'' = `aa`i''    if `touse'        
  local varnam "`varnam' age_00`aarr'"     
       
  }                          
       
 forvalues i = 1(1)`mape' {                          
 tempvar pp`i'                           
  qui: gen `pp`i''= (`i'==`pepe')+runiform()*.001-.0005                          
  local pprr=`ppr'[`i',1]    
  tempvar  per_`pprr'    
  gen `per_`pprr''= `pp`i''    if `touse'        
  local varnam "`varnam' per_`pprr'"     
  }                          
      
     
    
         
 preserve     
 collapse `nomy1'  if `touse' , by(`aaa'  `ppp'  )     
 gen `cn' =`ppp' - `aaa'       
 xtset `cn' `ppp'       
 gen `diffea'=`nomy1'-L`pace'.`nomy1'     
 noi su `diffea'     
 local effage =r(mean)     
     
     
 noi di "age effect =   " `effage'     
 restore     
       
        
       
 local consg1 "0"                          
 local consg2 "0"                          
 local listcoh ""                          
 local macob=int(`maco'-1)                          
 forvalues i=2(1)`macob' {                          
 local j=int(-`maco'-1+`i'*2)                          
 local k=`ccr'[`i',1]                          
   local consg1 "`consg1'+`coh_`k''"                          
   local consg2 "`consg2'+(`j')*`coh_`k''"                          
 local listcoh "`listcoh' `coh_`k''"                          
   }                          
 local consg1 "`consg1'=0"                          
 local consg2 "`consg2'=0"                          
        
        
 local consg3 "0"                          
 local consg4 "0"                          
 local rap= 0     
 local listage ""                                              
 forvalues i=1(1)`maag' {                          
 local j=int(-`maag'-1+`i'*2)                          
 local k=`aar'[`i',1]                          
   local consg3 "`consg3'+`age_00`k''"       
   local consg4 "`consg4'+(`j')*`age_00`k''"      
   local listage "`listage' `age_00`k''"                          
   local rap = `rap'+1/2*`j'*`j'                          
  }                          
       
 local consg3 "`consg3'=0"     
 local cosi=   `rap'*`effage'                      
 local consg4 "`consg4' = `cosi' "                          
       
       
       
       
 local consg5 "0"                          
 local consg6 "0"    
 local listper ""                          
 forvalues i=1(1)`mape' {                          
 local j=int(-`mape'-1+`i'*2)                          
 local k=`ppr'[`i',1]                          
   local consg5 "`consg5'+`per_`k''"                          
   local consg6 "`consg6'+(`j')*`per_`k''"       
   local listper "`listper' `per_`k''"                          
    
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
di "********************************************************************************"     
di "#######      APCTLAG = APC with cohort Trend based on lagged age effect ########"     
di "********************************************************************************"     
di ""     
glm  `nomy1' `listcoh' `listage' `listper'  `control'   `in' [`weight' `exp'] if `coco'!=1 & `coco'<`maco' & `touse', ///     
`options'  constraints ( 3 4 5 6)  nocons     
*predict predictedapcd, xb      
*predict residuedevapcd, deviance      
*drop alpha-omega     
     
di "*******************************************"     
di ""                          
 }      
     
 mat def V=e(b)    
     
 mat def A=V'    
     
 local varnam "`varnam' `cntnam'"    
 matrix coln A="`nomy1'"    
 matrix rown A= :    
 matrix roweq A= " "    
 local line=""    
 local rn ""    
 local lines=rowsof(A)    
 local cols=colsof(A)    
 local title " Variable:   "    
 local kav "   "    
 local names : colnames A    
 foreach v of local names {    
 local title "`title' `v'"    
 local kav "`kav'______________________"    
 }    
 di "`kav'"    
 di "`title'"    
 di "`kav'"    
 forvalues i=1(1)`lines' {    
 local line1 : word `i' of `varnam'    
 local line "    `line1'"    
 local rn "`rn' `line1'"    
 forvalues j=1(1)`cols' {    
 local b=round(A[`i',`j'],0.0005)    
     
 local c=string(`b',"%12.3f")    
    
 local line "`line' `c'"    
 }    
 di "`line'"    
 local line ""    
 }    
 di "`kav'"    
 matrix rown A=`rn'    
 return matrix table=A    
 end                          
    
     
 
    