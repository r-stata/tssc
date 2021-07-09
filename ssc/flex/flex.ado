* Version 1.91 - 21 June 2016
* By J.M.C. Santos Silva, S. Tenreyro, and K. Wei
* Please email jmcss@surrey.ac.uk for help and support

	*******************************************
	* This file calls flex_ml.ado flex_ml1.ado*
	*******************************************

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the author be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.


program define flex, eclass                                                                                   
version 11.0

syntax varlist(fv) [if] [in] [fweight aweight] ///
                   [, ul(integer 1) EXTended  Omega(real 1) Delta(real 1) CLuster(string) Margins(varlist) Nose STrict Keep ///
                   TECHnique(string) ITERate(integer 16000) TRace difficult GRADient showstep HESSian SHOWTOLerance ///
                   TOLerance(real 1e-4) LTOLerance(real 1e-7) NRTOLerance(real 1e-5) NONRTOLerance from(string) NOLOg ]
                                                                   
marksample touse  
markout `touse'  `cluster', s                                           
tempname  _y _yy _xb _fit B oscar zeros _fit sd _mean _mad rho
gettoken _y _rhs: varlist  

di

if "`weight'" != "" local wgt "[`weight'`exp']"

local w : word count `cluster' 
if `w' > 1{                                                                                                  
di as error "Too many variables to cluster!"
exit
}

qui su `_y' `wgt' if `touse'
if r(max)>`ul'{
di as error "Some values of " "`_y'" " are larger than the specified upper limit"
exit
}
if `omega'==0{
di as error "The model is not defined for omega equal to zero"
exit
}

if (`delta'<=0)&("`extended'" != ""){
di as error "Delta must be positive"
exit
}

*******************************************
* Check existence of estimates
 di as txt "Checking the existence of the estimates"                                    
 gen `zeros'=1                                                                                                 
 local tot=0                                                                                                   
 local _drop ""                                                                                                
 local _rhss ""                                                                                                
    foreach x of local _rhs{                                                                                   
      qui su `x' `wgt' if (`touse')&(`_y'>0)&(`_y'<`ul')
      scalar `sd'=r(sd) 
      if (`sd'==0) { 
          qui su `x' `wgt' if (`touse')&(`_y'>0)
          scalar `_mean'=r(mean)
          qui su `x' `wgt' if (`_y'==0)&(`touse')
          if (r(min)<`_mean')&(r(max)>`_mean')&("`strict'" == "") {                                            
              local _rhss "`_rhss' `x'"                                                                         
          }
          else{
              qui su `x' `wgt' if `touse', d                                                                         
              scalar `_mad'=r(p50)
              qui su `x' `wgt' if (`touse')&(`x'!=`_mad')
              qui replace `zeros'=0 if (`x'!=`_mad')&((r(sd)==0)|(r(sd)==.))&(`touse')   
              local _drop "`_drop' `x'"
              local tot = `tot'+1                                                                              
          }
        }                                                                                                         
      if (`sd'>0) {                                                                                          
      local _rhss "`_rhss' `x'" 
      }                                                                                                        
    }                                                                                                        
 qui su `touse' `wgt'if `touse'                                                                                     
 local _enne=r(sum)                                                                                               
 qui replace `touse'=0 if (`zeros'==0)&("`keep'"=="")&(`touse')                                                
*******************************************

* Find starting values and check identification if starting values are not given
if ("`from'" == "") {
di 
di as text "Finding starting values"
glm `_y' `_rhss' `wgt' if `touse', family(binomial `ul') nodisplay irls `nolog' link(logit) 
matrix `B'=e(b)
qui predict `_fit' if `touse', mu
qui corr  `_fit' `_y' `wgt' if `touse'
scalar `rho'=r(rho)
qui inspect `_fit' if `touse'
if r(N_unique)<3{
di
di as error "Omega cannot be identified with these regressors"
exit
}
if (r(N_unique)<(e(rank)+5))|`rho'<0.01{
di
di as error "Identification of the model with these regressors may be difficult"
}
qui drop  `_fit'
}

* Check identification if starting values are given
scalar `oscar'=0
if ("`from'" != "") {
matrix `B'=`from'
qui reg `_y' `_rhss'  `wgt' if `touse'
qui predict `_fit' if `touse'
qui inspect `_fit' if `touse'
if r(N_unique)<3{
di
di as error "Omega cannot be identified with these regressors"
exit
}
if (r(N_unique)<(e(rank)+5)){
di
di as error "Identification of the model with these regressors may be difficult"
}
drop `_fit'
 * Check if starting value for omega is provided 
 local names : colfullnames `B'
 foreach x of local names {
 if "`x'"== "omega:_cons" scalar `oscar'=1
 }
}

* Estimation *********************************************************************** 
di
di as text "Estimating the Flex model"

qui g double `_yy'=`_y'/`ul' if `touse'

if (`oscar'==1)&("`cluster'" == "") ml model lf flex_ml (linear_index: `_yy' = `_rhss') /omega `wgt' if `touse', technique(`technique') ///
                      maximize `difficult' `nolog'  nooutput tolerance(`tolerance') ltolerance(`ltolerance') ///  
                      `nonrtolerance' iterate(`iterate') search(off)  vce(robust) ///
                      `trace' `gradient' `showstep' `hessian' `showtolerance' init(`B' , skip)

if (`oscar'==1)&("`cluster'" != "") ml model lf flex_ml (linear_index: `_yy' = `_rhss') /omega `wgt' if `touse', technique(`technique') ///
                      maximize `difficult' `nolog'  nooutput tolerance(`tolerance') ltolerance(`ltolerance') ///  
                      `nonrtolerance' iterate(`iterate') search(off) vce(cluster `cluster') ///
                      `trace' `gradient' `showstep' `hessian' `showtolerance' init(`B', skip)

if (`oscar'==0)&("`cluster'" == "") ml model lf flex_ml (linear_index: `_yy' = `_rhss') /omega `wgt' if `touse', technique(`technique') ///
                      maximize `difficult' `nolog'  nooutput tolerance(`tolerance') ltolerance(`ltolerance') ///  
                      `nonrtolerance' iterate(`iterate') search(off) vce(robust) ///
                      `trace' `gradient' `showstep' `hessian' `showtolerance' init(/omega=`omega' `B' , skip)

if (`oscar'==0)&("`cluster'" != "") ml model lf flex_ml (linear_index: `_yy' = `_rhss') /omega `wgt' if `touse', technique(`technique') ///
                      maximize `difficult' `nolog'  nooutput tolerance(`tolerance') ltolerance(`ltolerance') ///  
                      `nonrtolerance' iterate(`iterate') search(off) vce(cluster `cluster') ///
                      `trace' `gradient' `showstep' `hessian' `showtolerance' init(/omega=`omega' `B', skip)

  if ("`extended'" != ""){
  matrix `B'=e(b)                                
  di
  di as text "Estimating the extended model"
  
  if ("`cluster'" == "") ml model lf flex_ml1 (linear_index: `_yy' = `_rhss') /omega /delta `wgt' if `touse', technique(`technique') vce(robust) ///
                         maximize `difficult' `nolog'  nooutput tolerance(`tolerance') ltolerance(`ltolerance') ///  
                         nrtolerance(`nrtolerance') iterate(`iterate') search(off) ///
                         `trace' `gradient' `showstep' `hessian' `showtolerance' init(`B' /delta=`delta', skip)
  
  else                   ml model lf flex_ml1 (linear_index: `_yy' = `_rhss') /omega /delta `wgt' if `touse', technique(`technique') vce(cluster `cluster') ///
                         maximize `difficult' `nolog'  nooutput tolerance(`tolerance') ltolerance(`ltolerance') ///  
                         nrtolerance(`nrtolerance') iterate(`iterate') search(off) ///
                         `trace' `gradient' `showstep' `hessian' `showtolerance' init(`B' /delta=`delta', skip)                                
  }   

* Results                               
qui predict double `_xb' if `touse', xb
if ("`extended'" == "") qui gen double `_fit'=(1 - (1 + [omega]_b[_cons]*exp(`_xb'))^(-1/[omega]_b[_cons])) if `touse'
else                    qui gen double `_fit'=(1 - (1 + [omega]_b[_cons]*exp(`_xb'))^(-1/[omega]_b[_cons]))^([delta]_b[_cons]) if `touse'
qui corr `_yy' `_fit' `wgt' if `touse'
di
di "R2 = " r(rho)^2 
di "Number of parameters: " e(k)                                                                              
di "Number of observations = " e(N)
local _enne = `_enne' - e(N)                                                                                        
di as result "Number of observations dropped: `_enne'" 
di "Log pseudolikelihood = " e(ll)
ereturn scalar r2=r(rho)^2
ereturn local depvar "`_y'"
ereturn display 
ml footnote
 di as result "Number of regressors dropped to ensure that the estimates exist: `tot'" 
 if ("`_drop'" != "") di "Dropped variables: `_drop'"                                                          
 if ("`strict'" == "") di "Option strict is off"                                                               
 else di "Option strict is on"
if ("`margins'" == "") ereturn local cmd "flex"

* Margins *****************************************************************************
if ("`margins'" != ""){
di
if ("`extended'" != "") margins `wgt', `nose' post expression(((1 - (1 + [omega]_b[_cons]*exp(predict(xb)))^(-1/[omega]_b[_cons]))^([delta]_b[_cons]))*`ul') dydx(`margins')  
                   else margins `wgt', `nose' post expression((1 - (1 + [omega]_b[_cons]*exp(predict(xb)))^(-1/[omega]_b[_cons]))*`ul')  dydx(`margins') 
ereturn local est_cmd "flex"
}
end
