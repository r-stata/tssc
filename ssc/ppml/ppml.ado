* Version 2.2.2 - 20 October 2015

* By J.M.C. Santos Silva & Silvana Tenreyro
* Thanks to Markus Baldauf for the help in developing the initial version of this code
* Please email jmcss@surrey.ac.uk for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.


program define ppml, eclass                                                                                    // Defines program name
version 11.1                                                                                                   // Stata version
                                                                                                               // Command syntax
syntax varlist(numeric min=2) [if] [in] [aweight pweight fweight iweight] [, CLuster(string) TECHnique(string)      ///
                  STrict mu(string) Keep ITERate(integer 5000) DIFficult search TRace GRADient showstep HESSian     ///
                  SHOWTOLerance fisher(integer 1) TOLerance(real 1e-6) LTOLerance(real 1e-7) NRTOLerance(real 1e-5) /// 
                  NONRTOLerance OFFset(string) from(string) NOCONstant CHECKonly]   
                                                 
marksample touse   
markout `touse'  `cluster', s                                                                                  // Defines observations to use
tempname logy y _rhs _rhss _drop beta fit ll zeros yh                                                          // Temporary names used in the program
gettoken y _rhs: varlist                                                                                       // Breaks varlist into y and x
 
 
 di
 di as txt "note: checking the existence of the estimates"                                    
 qui gen `logy'=.  if (`touse')                                                                                // Creates regressand for first step
 qui replace `logy'=log(`y') if (`touse')&(`y'>0)                                                              // Modifies regressand for first step
 qui reg `logy' `_rhs' if (`touse')&(`y'>0) [`weight'`exp'], `noconstant'                                      // Performs first step
 gen `zeros'=1                                                                                                 // Initialize observations selector
 local _drop ""                                                                                                // List of regressors to exclude
 local _rhss ""                                                                                                // List of regressors to include
 qui summarize `y' if (`touse')                                                                       
 if r(max)>1000000 di as error "WARNING: `y' has very large values, consider rescaling"                        // Warn if there are large values
    foreach x of local _rhs{                                                                                   // Start loop over all regressors: LOOP 1
      if (_se[`x']==0) {                                                                                       // Try to include regressors dropped in the
          qui summarize `x' if (`touse')                                                                       // first stage: LOOP 1.1
          if r(max)>ln(1000000)|r(min)<-ln(1000000){
          di as error "WARNING: `x' has very large values, consider rescaling or recentering"
          }
          qui summarize `x' if (`y'>0)&(`touse'), meanonly
          local _mean=r(mean)
          qui summarize `x' if (`y'==0)&(`touse')
          if (r(min)<`_mean')&(r(max)>`_mean')&("`strict'" == "") {                                            // Include regressor if conditions met and
              local _rhss "`_rhss' `x'"                                                                        // strict is off 
          }
          else{
              qui su `x' if `touse', d                                                                         // Otherwise, drop regressor
              local _mad=r(p50)
              qui inspect  `x'  if `touse'                                                                         
              qui replace `zeros'=0 if (`x'!=`_mad')&(r(N_unique)==2)&(`touse')                                // Mark observations to drop
              local _drop "`_drop' `x'"
          }
      }                                                                                                        // End of LOOP 1.1 
      if _se[`x']>0 {                                                                                          // Include safe regressors: LOOP 1.2
      qui summarize `x' if (`touse')                                                                       
      if r(max)>ln(1000000)|r(min)<-ln(1000000){                                                               // Warn if there are large values
      di as error "WARNING: `x' has very large values, consider rescaling  or recentering"                             
      }
      local _rhss "`_rhss' `x'" 
      }                                                                                                        // End LOOP 1.2
    }                                                                                                          // End LOOP 1
 qui su `touse' if `touse', mean                                                                               // Summarize touse to obtain N
 local _enne=r(sum)                                                                                            // Save N
 qui replace `touse'=0 if (`zeros'==0)&("`keep'"=="")&(`y'==0)&(`touse')                                       // Drop observations with perfect fit
 di                                                                                                              // if keep is off
 local k_excluded : word count `_drop'                                                                         // Number of variables causing perfect fit
 di as error "Number of regressors excluded to ensure that the estimates exist: `k_excluded'" 
 if ("`_drop'" != "") di "Excluded regressors: `_drop'"                                                        // List dropped variables if any
 qui su `touse' if `touse', mean
 local _enne = `_enne' - r(sum)                                                                                // Number of observations dropped
 di as error "Number of observations excluded: `_enne'" 
 local _enne =  r(sum)
 di

_rmcoll `_rhss'  [`weight'`exp'] if `touse', forcedrop `noconstant'                                            // Remove collinear variables
local _rhss "`r(varlist)'"
if r(k_omitted) >0 di

 if ("`checkonly'" != "") {
 local w : word count `_rhss'
 ereturn clear
 ereturn post , esample(`touse') 
 ereturn scalar N = `_enne'
 ereturn scalar k = `w'+("`noconstant'" == "")
 ereturn scalar k_omitted = r(k_omitted)                                                                       // Post number of collinear variables
 ereturn scalar k_excluded = `k_excluded'                                                                      // Post number of excluded variables
 ereturn local excluded(`_drop')                                                                               // List of excluded regressors
 ereturn local included(`_rhss')                                                                               // List of included regressors
 ereturn local cmd "ppml"                                                                                      // Post cmd on e 
 exit
 }

 di as txt "note: starting ppml estimation"                                                                           
 local k_omitted=r(k_omitted) 
 local w : word count `cluster'                                                                                // Counts arguments in option cluster
 if `w' >1 {                                                                                                   // Do if number of arguments in cluster 
 di as error "ERROR: Too many variables to cluster"                                                            // is valid
 exit
 }
 
 if `w'==0{                                                                                                   // Estimation with robust s.e.: LOOP 2
 
  if ("`technique'" == "")|("`technique'" == "irls") glm `y' `_rhss' if `touse' [`weight'`exp'], family(poisson) ///          // IRLS 
                 link(log) irls mu(`mu') noheader iterate (`iterate') notable vce(robust) `trace' `noconstant' offset(`offset')
                
  else glm `y' `_rhss' if `touse' [`weight'`exp'], family(poisson) link(log) technique(`technique') `difficult' ///           // ML
                `search'  noheader iterate (`iterate') notable vce(robust) `trace' `gradient' ///
                `showstep' `hessian' `showtolerance' fisher(`fisher') tolerance(`tolerance') offset(`offset')  ///
                ltolerance(`ltolerance') nrtolerance(`nrtolerance') `nonrtolerance' from(`from') `noconstant'
  }                                                                                                            // End of LOOP 2
  if `w'==1{                                                                                                   // Estimation with cluster s.e.: LOOP 3
  
  if ("`technique'" == "")|("`technique'" == "irls") glm `y' `_rhss' if `touse' [`weight'`exp'], family(poisson) ///           // IRLS
            link(log) irls mu(`mu') noheader iterate (`iterate') notable vce(cluster `cluster') `trace' `noconstant' offset(`offset')
          
  else glm `y' `_rhss' if `touse' [`weight'`exp'], family(poisson) link(log) technique(`technique') `difficult' ///            // ML
               `search'  noheader iterate (`iterate') notable vce(cluster `cluster') `trace' `gradient' ///
                `showstep' `hessian' `showtolerance' fisher(`fisher') tolerance(`tolerance')  offset(`offset') ///
                ltolerance(`ltolerance') nrtolerance(`nrtolerance') `nonrtolerance' from(`from') `noconstant' 
 }                                                                                                             // End of LOOP 3 
 di "Number of parameters: " e(k)                                                                              // Display number of parameters
 di "Number of observations: " e(N)                                                                            // Display number of observations
 matrix `beta' =e(b)                                                                                           // Start computation of predictions
 matrix score double `fit' = `beta' if `touse'                                                                 // Get predictions
 if ("`technique'" == "")|("`technique'" == "irls"){                                                           // If irls is used, compute ll: LOOP 4
 qui gen double `ll' = e(N)*(-exp(`fit')+`y'*`fit'- lngamma(`y'+1)) if `touse'                                 // N times individual log-likelihood
 qui summarize `ll' if `touse', meanonly                                                                       // Get log-likelihood
 ereturn scalar ll = r(mean)                                                                                   // Post ll on e
 }                                                                                                             // End of LOOP 4
 di "Pseudo log-likelihood: " e(ll)                                                                            // Display log-likelihood
 qui gen `yh'=exp(`fit')                                                                                       // Compute R2
 qui corr `yh' `y' if (`touse')
 di "R-squared: " r(rho)^2
 ereturn scalar r2 = r(rho)^2                                                                                  // Post R2 on e
 if ("`strict'" == "") di "Option strict is: off"                                                              // Display option for strict
 else di "Option strict is: on
 qui su `y' if (`y'>0)&(`touse')                                                                               // Start check for overfitting
 local _lbp=r(min)                                                                                      
 qui su `yh' if (`y'==0)&(`touse')
 if (r(min)<1e-6*`_lbp')  di as error "WARNING: The model appears to overfit some observations with `y'=0" // End check for overfitting
 ereturn display                                                                                               // Display results table
 ereturn scalar k_omitted = `k_omitted'                                                                        // Post number of collinear variables
 ereturn scalar k_excluded = `k_excluded'                                                                              // Post number of excluded variables
 ereturn local excluded(`_drop')                                                                               // List of excluded regressors
 ereturn local included(`_rhss')                                                                               // List of included regressors
 ereturn local cmd "ppml"                                                                                      // Post cmd on e 
end                                                                                                            // End program
