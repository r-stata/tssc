* Version 1.3 - 30 April 2012
* By J.A.F. Machado and J.M.C. Santos Silva 
* Please email jmcss@essex.ac.uk for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define mss, rclass
version 11.1
syntax  [varlist(default=none)]


if ("`e(wtype)'" == "")|("`e(wtype)'" == "fweight"){
tempname  _e _g _f _f2 _s MSS touse _fw  oldest
if (e(cmd)=="qreg")|(e(cmd)=="bsqreg")|(e(cmd)=="regress")|(e(cmd)=="sqreg"){
local tot=0
qui gen byte `touse' = e(sample)
if "`e(wtype)'" == "" qui g `_fw'=1 if `touse'
else qui g `_fw' `e(wexp)' if `touse'

if "`varlist'"==""{
local tot = `tot'+1
qui predict `_f' if `touse', xb
qui g double `_f2'= `_f'^2 if `touse'
local varlist "`varlist' `_f' `_f2'"
}
local _k : word count `varlist'
qui predict `_e' if `touse', residuals
if (e(cmd)=="sqreg") local eta=1-e(q1)
if (e(cmd)=="qreg")|(e(cmd)=="bsqreg") local eta=1-e(q)
if (e(cmd)=="regress") {
 qui g byte `_s'=`_e'>=0 if `touse'
 qui su `_s' [fweight=`_fw'] if `touse'
 local eta=r(mean)
}

_est hold `oldest'

qui g double `_g'=`_e'*((`_e'>=0)-`eta') if `touse'
qui reg  `_g' `varlist' [fweight=`_fw'] if  `touse'
local MSS=e(N)*e(r2)
_est unhold `oldest' 

di 
di as txt "Machado-Santos Silva test for heteroskedasticity"
di as txt "         Ho: Constant variance"
di as txt "         Variables: " _continue
if `tot'==1 {
di as result "Fitted values of " "`e(depvar)'" " and its squares"
}
else di as result "`varlist'"
di
di as txt "         chi2(" _continue
di as result `_k' _continue
di as txt ")" _continue
di _column(23) "=  " _continue
di %6.3f as result `MSS'
di as txt "         Prob > chi2  =  " _continue
di %6.3f as result chi2tail(`_k',`MSS')  
return scalar chi2 = `MSS'
return scalar df = `_k'
return scalar p = chi2tail(`_k',`MSS')
}
else di as error "ERROR: mss  valid only after reg, qreg, sqreg, or bsqreg
}
else di as err "ERROR: mss not appropriate after estimation with `e(wtype)'"
end
