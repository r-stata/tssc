* Version 1.03 - 6 Jun 2016
* By J.A.F. Machado, J.M.C. Santos Silva, and K. Wei
* Please email jmcss@surrey.ac.uk for help and support

	*******************************************
	* This file calls            fqreg_ml0.ado*
	*******************************************

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the author be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.


program define fqreg, eclass                                                                                   
version 11.0

syntax varlist(numeric) [if] [in] [, ul(integer 1) Gamma(real 0) CLuster(string) ///
              Quantile(real .5) WLSiter(integer 1) NOWARNing Margins(varlist) Nose ///
              TECHnique(string) ITERate(integer 16000) NOLOg  TRace GRADient showstep HESSian SHOWTOLerance ///
              TOLerance(real 1e-4) LTOLerance(real 1e-7) NRTOLerance(real 1e-5) NONRTOLerance from(string)  ]
                    
                                                                                                                  
marksample touse  
markout `touse'  `cluster' , s                                           
tempname  _y _yy _w0 _f _fit b _e _ae _hs _ep50 _hsi _dens _w _gv _id zeros _Cx _DG _zer A D  ct tt
gettoken _yy _rhs: varlist     

* Checks *******************************************************************************
 if ("`technique'"== "") local technique = "bfgs"
 else{
 foreach x of local technique { 
 if ("`x'" == "nr")|("`x'" == "bhhh") {
 di as error "Optimization technique not allowed; valid options are bfgs and dfp"
 exit
 }
 }
 }
if (`quantile'<=0)|(`quantile'>=1){
di as error "Quantile must be strictly between 0 and 1"
exit
}
local w : word count `cluster' 
if `w' > 1{                                                                                                  
di as error "Too many variables to cluster!"
exit
}
qui su `_yy'  if `touse'
if r(max)>`ul'|r(min)<0{
di as error "`_yy'" " is not bounded between 0 and " "`ul'"
exit
}
if `gamma'<=-1{
di as error "The model is not defined for gamma <= -1"
exit
}
 
* Prepare data *******************************************************************************              
_rmcoll `_rhs' if `touse', forcedrop 
local _rhs "`r(varlist)'" 
qui g double `_y'=`_yy'/`ul' if `touse'

local dum ""
foreach x of local _rhs{
capture tab `x' if `touse'
if r(r)==2 local dum "`dum' `x'" 
}
local _rhx: list _rhs - dum

* Starting values *******************************************************************************              

if ("`from'" != "") matrix `b'=`from'
else{
qui g double `_w0'=log((`_y')/(1-`_y')) if `touse'
capture qreg `_w0' `_rhx' i.(`dum') if `touse', quantile(`quantile') wls(`wlsiter')
if e(convcode)!=0 {
di as error "It was not possible to set initial values; consider changing the value of wlsiter"
exit
}
matrix `b'=e(b)
}

 * Check if starting value for gamma is provided 
 local charlie=0
 if ("`from'" != ""){
 local names : colfullnames `b'
 foreach x of local names {
 if "`x'"== "gamma:_cons" local charlie=1
 }
 }
if (`charlie'==1){
di
di as result "Starting value provided with the option Gamma will be ignored"
}
* Estimation *******************************************************************************

qui g _alpha=`quantile' in 1

if `charlie' ==0{
version 11: ml model lf fqreg_ml0 (`_y' =  `_rhx' i.(`dum') ) /gamma if `touse', technique(`technique') ///
            maximize init(`b' /gamma=`gamma', skip) iterate(`iterate') `trace' `showtolerance' `nolog' ///
            `gradient' `showstep' `hessian' tolerance(`tolerance') ltolerance(`ltolerance') search(off) `nowarning' 
            }
if `charlie' ==1{     
version 11: ml model lf fqreg_ml0 (`_y' =  `_rhx' i.(`dum') ) /gamma if `touse', technique(`technique') ///
            maximize init(`b'               , skip) iterate(`iterate') `trace' `showtolerance' `nolog' ///
            `gradient' `showstep' `hessian' tolerance(`tolerance') ltolerance(`ltolerance') search(off) `nowarning' 
            }
* Covariance *******************************************************************************
qui predict double `_f' if `touse', xb
qui g double `_fit'=max(0,((1 + [gamma]_b[_cons])*(exp(`_f')/(1 + exp(`_f')))-[gamma]_b[_cons])) if `touse'
qui g double `_e'=(`_y' - `_fit') if `touse'
qui g double `_ae'=abs(`_e') if `touse'
qui su `_ae' if `touse',d
qui replace `_e'=0 if (`_ae'<r(p50)*1e-7)&(`touse')

qui g double `_hs'=(invnormal(0.975)^(2/3))*(((1.5*((normalden(invnormal(`quantile')))^2))/(2*((invnormal(`quantile'))^2) + 1))^(1/3)) if `touse'                                      
qui su `_e' if (`_fit'>0)&(`_y'>0)&(`_y'<1)&(`touse') ,d
qui g double `_ep50'=abs(`_e'-r(p50)) if `touse'
qui su `_ep50' if (`_fit'>0)&(`_y'>0)&(`_y'<1)&(`touse') ,d

qui g double `_hsi'=r(p50)*(invnormal(`quantile'+`_hs'*(r(N)^(-1/3)))-invnormal(`quantile'-`_hs'*(r(N)^(-1/3)))) if `touse'
qui replace `_hsi'=min(`_hsi',`_fit',1-`_fit')+(`_y'==0)+(`_y'==1) if `touse'  
qui g double `_dens'=sqrt(0.5*((abs(`_e'/`_hsi')<1)/`_hsi')*(`_fit'>0)*(`_y'>0)*(`_y'<1))  if `touse'

qui g double `_w' = (`quantile'-(`_e'<=0))*(`_fit'>0) if `touse'
qui g `_gv'=_n if `touse'

if "`cluster'"=="" qui g `_id'=_n  if `touse'
else qui g `_id'=`cluster' if `touse'
drop _alpha
preserve
qui g `zeros'=0 if `touse'
recast double `_rhs' 
foreach x of local _rhx{
qui replace `x'=`x'*(`_fit'>0)*(1 + [gamma]_b[_cons])*(exp(`_f')/((1 + exp(`_f'))^2)) if `touse'
}
local aregs " `_rhx'"
foreach x of local dum{
qui replace `x'=`x'*(`_fit'>0)*(1 + [gamma]_b[_cons])*(exp(`_f')/((1 + exp(`_f'))^2)) if `touse'
local aregs " `aregs' `zeros' `x'" 
}

qui g double `_Cx' =  (`_fit'>0)*(1 + [gamma]_b[_cons])*(exp(`_f')/((1 + exp(`_f'))^2)) if `touse'
qui g double `_DG' = -1/(1 + exp(`_f')) if `touse'
local aregs " `aregs' `_Cx'  `_DG'"

sort `_id'
matrix opaccum `A' = `aregs' if `touse', noconstant group(`_id') opvar(`_w')  
sort `_gv'
matrix opaccum `D' = `aregs' if `touse', noconstant group(`_gv') opvar(`_dens')  
matrix Vm=invsym(`D')*`A'*invsym(`D') 

restore

* RESULTS ?????????????????????????????????????????????????????????????????????????????????????????
  ereturn repost  V = Vm
	qui corr `_fit' `_y' if `touse'
	local r2=r(rho)^2
	qui g `_zer'=`_fit'==0 if `touse'
	qui su `_zer' if `touse'
di 
if `quantile'==0.5 di as txt "Median regression"
else di as txt `quantile' " Quantile regression"
	di "R-squared  = " `r2' 
	di "Number of observations = " r(N)
	di "Percentage of zeros = " r(mean)
	di "Objective function = " -e(ll) 
	ereturn scalar r2=`r2'
	ereturn scalar q=`quantile'
  ereturn local depvar "`_yy'"
di  
if "`cluster'" == "" {
di as txt "                                Robust standard errors"
ereturn local vce robust
}
else {
preserve
qui by `cluster', sort: egen `ct'=count(1) if (`touse')
qui by `cluster', sort: egen `tt'=seq() if (`touse')
qui count if (`tt'==1)&(`touse')
di as txt "Standard errors adjusted for " _continue
di as result r(N) _continue
restore
di as txt " clusters in `cluster'"
ereturn local vce clustered
ereturn scalar N_clust=r(N)
}
  ereturn display
  if ("`margins'" == "") ereturn local cmd "fqreg"

* Margins *****************************************************************************
if ("`margins'" != ""){
di
margins , `nose' post expression(`ul'*max(0,((1 + [gamma]_b[_cons])*(exp(predict(xb))/(1 + exp(predict(xb))))-[gamma]_b[_cons])) ) dydx(`margins')  
ereturn local est_cmd "fqreg"
}

end



