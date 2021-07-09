*! provide a weighted logit rank stored in a given variable 
program logitrank, rclass sortpreserve 
version 10.0 
syntax varlist(numeric ts) [aweight fweight pweight] [if] [in] ,  Generate(string)

qui {

  if ("`generate'"!="") {
    gen `generate'= .
    if (`:word count `generate'' != 1 ) {
      di as error "option generate() invalid"
      exit 198	
    }
  } 

  
marksample touse
	
local revabc : word 1 of `varlist'
gen temprev= `revabc' if `touse'
*replace temprev = 0 if  temprev==. & `touse'
replace temprev = temprev +runiform()*.000001 if `touse'   

sort  temprev    
tempvar toto

if "`weight'" == ""  & `touse'    gen `toto' = 1
else gen `toto' `exp'  if `touse'  

sort temprev
su temprev  [w =`toto']   if `touse' , d
	gen ytemp=(temprev/r(p50))*100 if `touse'    
	gen lytemp=ln(ytemp) if  `touse'  
	gen xtemp = sum(`toto') if  `touse'  
	su xtemp [w =`toto']    if  `touse'  
	replace xtemp=(xtemp/r(max)) if  `touse'  
	su xtemp [w =`toto']    if  `touse'  
	replace xtemp=((xtemp-r(min)/2)/r(max)) if  `touse'  
	gen lxtemp =ln(xtemp/(1-xtemp)) if  `touse'  
	replace `generate' =lxtemp if  `touse'  
	drop *tem*
}   
   end




exit
   
   