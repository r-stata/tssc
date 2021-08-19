program define mrsprep_example
  version 16.0
  syntax [, EGNUMBER(integer 1) LEAVEDATA]

  if "`leavedata'" != "" {
    qui desc
    if `r(N)'!=0 | `r(k)'!=0 {
      di as error `"To leave the example data in memory,"' _newline ///
                   "You need to start with an empty dataset."
      exit
    }         
  }
  
if `egnumber' == 1 {

if "`leavedata'" == "" {
  qui frame
  local currentframe `r(currentframe)'
  preserve
}

display "\\ Load and stset melanoma data"
display `". use "https://pclambert.net/data/melanoma.dta""'
display ". stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)"
use "https://pclambert.net/data/melanoma.dta"
stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)

display "// Use mrsprep to expand data and calculate weights"  
display ///
`". mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///"' _newline ///
"                                                           verbose breaks(0(0.2)10) " _newline

mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///
                           verbose breaks(0(0.2)10) newframe(, replace)
display _newline
display "// incorprate weights when using stset"
display ". stset tstop [iw=wt], enter(tstart) failure(event==1)"
stset tstop [iw=wt], enter(tstart) failure(event==1)	

display "// Fit marginal model using the weighted mean hazard" _newline
display ". stpm2, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id)"
stpm2, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id)
                           
display "// predict marginal relative survival"
display ". range tt 0 10 101"
display ". predict s_mrs, surv timevar(tt) ci"       
range tt 0 10 101
predict s_mrs, surv timevar(tt) ci     

di ///
". twoway (line s_mrs* tt, lcolor(red..) lpattern(solid dash dash)) ///" _newline ///
"         , legend(off)                                             ///" _newline ///
"           ylabel(0.6(0.1)1, format(%3.1f))                        ///" _newline ///
"           ytitle(Marginal relative survival)                      ///" _newline ///
"   	    xtitle(Years from diagnosis)                               " _newline                                 
twoway (line s_mrs* tt, lcolor(red..) lpattern(solid dash dash)) ///
       , legend(off)                                             ///
	 ylabel(0.6(0.1)1, format(%3.1f))                        ///
         ytitle("Marginal relative survival")                    ///
	 xtitle("Years from diagnosis")                
         
if "`leavedata'" == "" {
  frame change `currentframe'
  frame drop mrs_data
  restore  
}           
}      
  

  
  
  else if `egnumber' == 2 {
          
if "`leavedata'" == "" {
  qui frame
  local currentframe `r(currentframe)'
  preserve
}
        

qui frame change default
display "\\ Load and stset melanoma data"
display `". use "https://pclambert.net/data/melanoma.dta""'
display ". stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)"
use "https://pclambert.net/data/melanoma.dta"
stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)
        
di "// change age groups to those defined in ICSS" _newline
di ". drop agegrp" _newline
di ". egen agegrp=cut(age), at(0 45 55 65 75 200) icodes" _newline
di ". replace agegrp = agegrp + 1" _newline
di `". label variable agegrp "Age group""' _newline
di `". label define agegrplab 1 "0-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+", replace"' _newline
di ". label values agegrp agegrplab" _newline

drop agegrp
egen agegrp=cut(age), at(0 45 55 65 75 200) icodes
replace agegrp = agegrp + 1
label variable agegrp "Age group"
label define agegrplab 1 "0-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+", replace
label values agegrp agegrplab

di "// create weights in reference population (ICSS)" _newline
di "recode agegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt)" _newline
recode agegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt) 
         
di "// calculate relative weights" _newline
di ". local total= _N" _newline
di ". bysort agegrp: gen a_age = _N/`total'" _newline
di ". gen double wt_age = ICSSwt/a_age" _newline         
local total= _N
bysort agegrp: gen a_age = _N/`total'
gen double wt_age = ICSSwt/a_age         

di  "// Prepare data for marginal model" _newline
di ///
`". mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///"' _newline ///
"                           verbose breaks(0(0.2)10)               ///" _newline ///
"                           indweights(wt_age)                     ///" _newline ///
"                           newframe(mrs_stand, replace)" _newline
mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///
                                verbose breaks(0(0.2)10)               ///
                           indweights(wt_age)                     ///
                           newframe(mrs_stand, replace)
                           
di  "// incorprate weights when using stset"
di ". stset tstop [iw=wt], enter(tstart) failure(event==1)" _newline					   
stset tstop [iw=wt], enter(tstart) failure(event==1)					   

di "// Fit marginal model using the weighted mean hazard" _newline
di ". stpm2, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id)" _newline
stpm2, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id) 
                           
di "// predict externally age standardized marginal relative survival" _newline
di ". range tt 0 10 101" _newline
di ". predict s_mrs, surv timevar(tt) ci" _newline 
range tt 0 10 101
predict s_mrs, surv timevar(tt) ci                          

di "// Plot results"
di ///
". twoway (line s_mrs* tt, lcolor(red..) lpattern(solid dash dash)) ///" _newline ///
"       , legend(off)                                             ///" _newline ///
"	  ylabel(0.6(0.1)1, format(%3.1f))                        ///" _newline ///
"         ytitle(Marginal relative survival)                      ///" _newline ///
"	  xtitle(Years from diagnosis)" _newline                            

if "`leavedata'" == "" {
  frame change `currentframe'
  frame drop mrs_data
  restore  
}  
    
  }
  else if `egnumber' == 3 {
          
if "`leavedata'" == "" {
  qui frame
  local currentframe `r(currentframe)'
  preserve
}          

qui frame change default
display "\\ Load and stset melanoma data"
display `". use "https://pclambert.net/data/melanoma.dta""'
display ". stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)"
use "https://pclambert.net/data/melanoma.dta"
stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)

display "// Use mrsprep to expand data and calculate weights"  
display ///
`". mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///"' _newline ///
"                                                           verbose breaks(0(0.2)10) " _newline

di "// change age groups to those defined in ICSS" _newline
di ". drop agegrp" _newline
di ". egen agegrp=cut(age), at(0 45 55 65 75 200) icodes" _newline
di ". replace agegrp = agegrp + 1" _newline
di `". label variable agegrp "Age group""' _newline
di `". label define agegrplab 1 "0-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+", replace"' _newline
di ". label values agegrp agegrplab" _newline

drop agegrp
egen agegrp=cut(age), at(0 45 55 65 75 200) icodes
replace agegrp = agegrp + 1
label variable agegrp "Age group"
label define agegrplab 1 "0-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+", replace
label values agegrp agegrplab

di "// create weights in reference population (ICSS)" _newline
di "recode agegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt)" _newline
recode agegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt) 


di "// Proportion within each age group by sex" _newline
di ". gen female = sex == 2" _newline
di ". bysort female: egen totalsex = total(sex)" _newline
di ". bysort agegrp female: gen a_age_sex = _N/totalsex" _newline
di ". gen double wt_age_sex = ICSSwt/a_age_sex" _newline
gen female = sex == 2
bysort female: egen totalsex = total(sex)
bysort agegrp female: gen a_age_sex = _N/totalsex
gen double wt_age_sex = ICSSwt/a_age_sex   
        
di "// Prepare data for marginal model" _newline
di `". mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///"' ///
"                           pmmaxyear(2000)                        ///" _newline ///
"                           verbose breaks(0(0.2)10)               ///" _newline ///
"                           indweights(wt_age_sex)                 ///" _newline ///
"                           by(female)                             ///" _newline ///
"                           newframe(mrs_stand, replace)  " _newline
mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///
                           pmmaxyear(2000)                        ///
                           verbose breaks(0(0.2)10)               ///
                           indweights(wt_age_sex)                 ///
                           by(female)                             ///
                           newframe(mrs_stand, replace) 
                           
di "// incorprate weights when using stset" _newline 
di ". stset tstop [iw=wt], enter(tstart) failure(event==1)" _newline 
stset tstop [iw=wt], enter(tstart) failure(event==1)

di "// Fit proportional hazards marginal model" _newline
di ". stpm2 female, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id)" _newline 
stpm2 female, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id)    

di "// Relax proportional hazards assumption" _newline
di ". stpm2 female, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id) ///" _newline ///
"              tvc(female) dftvc(3)" _newline 

 // predict externally age standardized marginal relative survival by sex
di "range tt 0 10 101" _newline
di "predict s_mrs_male,   surv timevar(tt) ci at(female 0)" _newline
di "predict s_mrs_female, surv timevar(tt) ci at(female 1)" _newline
range tt 0 10 101
predict s_mrs_male,   surv timevar(tt) ci at(female 0)
predict s_mrs_female, surv timevar(tt) ci at(female 1)

di "//Plot results" _newline
di ". twoway (line s_mrs_male* tt, lcolor(red..) lpattern(solid dash dash)) ///" _newline ///
"       (line s_mrs_female* tt, lcolor(blue..) lpattern(solid dash dash))   ///" _newline ///
"       , legend(off)                                                       ///" _newline ///
"	 ylabel(0.6(0.1)1, format(%3.1f))                                   ///" _newline ///
"         ytitle(Marginal relative survival)                                ///" _newline ///
"	 xtitle(Years from diagnosis)" _newline  

twoway (line s_mrs_male* tt, lcolor(red..) lpattern(solid dash dash)) ///
       (line s_mrs_female* tt, lcolor(blue..) lpattern(solid dash dash)) ///
       , legend(off)                                             ///
	 ylabel(0.6(0.1)1, format(%3.1f))                        ///
         ytitle(Marginal relative survival)                    ///
	 xtitle(Years from diagnosis)  

if "`leavedata'" == "" {
  frame change `currentframe'
  frame drop mrs_data
  restore  
}        
    
  }
  
end   
