*! lmeg V1.0 25/06/2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email:   emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define lmeg, rclass
version 11.0
syntax varlist(min=2 max=2) [if] [in], [LAGs(int 1) AUX(str) coll]
tempvar `varlist'
gettoken yvar xvar : varlist
qui marksample touse
tempvar Time TimeN E DE E1
tempname DF kx kb N SSE0 SSE1 tmin tmax Bo cz cov cov1 ct czp ctp
qui markout `touse' , strok
qui cap count if `touse'
scalar `N' = r(N)
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
local both : list yvar & xvar
if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
 if "`coll'"=="" {
_rmcoll `xvar' `aux' if `touse' , `noconstant' `coll' forcedrop
local xvar "`r(varlist)'"
 }
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:***Engle-Granger Cointegration Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt " {bf:Ho: (Non Stationary) - (   Unit Root) - (No Cointegration)}"
di as txt " {bf:Ha: (    Stationary) - (no Unit Root) - (   Cointegration)}"
di
qui regress `yvar' `xvar' if `touse'
qui predict `E' if `touse' , resid
qui gen `DE' =D.`E' if `touse'
qui gen `E1' =L1.`E' if `touse'
qui regress `DE' `E1' if `touse' , noconstant
scalar `Bo'= _b[`E1']
local lmegz_0 = e(N)*`Bo'
local lmegzp_0= 1-normal(abs(`lmegz_0'))
matrix `cov'=e(V)
scalar `cov1'=`cov'[1,1]
local lmegt_0= `Bo'/sqrt(`cov1')
local lmegtp_0= 1-normal(abs(`lmegt_0'))
di as txt "* Cointegration z Test" _col(25) "AR(0) = " as res %9.4f `lmegz_0' _col(45) "P-Value > z" _col(60) as res %5.4f `lmegzp_0'
di as txt "* Cointegration t Test" _col(25) "AR(0) = " as res %9.4f `lmegt_0' _col(45) "P-Value > t" _col(60) as res %5.4f `lmegtp_0'
return scalar lmegz_0=`lmegz_0'
return scalar lmegzp_0=`lmegzp_0'
return scalar lmegt_0=`lmegt_0'
return scalar lmegtp_0=`lmegtp_0'
di
if "`lags'" != "" {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Augmented Engle-Granger Cointegration Test}}"
di _dup(78) "{bf:{err:=}}"
 }
forvalue i=1/`lags' {
markout `touse' `Time' L(1/`i').(`varlist') `aux'
qui summ `Time' if `touse'
scalar `tmin' = r(min)
scalar `tmax' = r(max)
scalar `N' = r(N)
di as txt " Sample Range" _col(15) "= " as res `tmin' "-" `tmax' _col(35) "Sample Size" _col(15) "= " as res `N'
di as txt " {bf:Lag Length}" _col(15) "= " as res `i'
qui regress `DE' `E1' L(1/`i').`DE' if `touse' , noconstant
scalar `Bo'= _b[`E1']
matrix `cov'=e(V)
scalar `cov1'=`cov'[1,1]
local lmeg`i'= `Bo'/sqrt(`cov1')
local lmegp`i'= 1-normal(abs(`lmeg`i''))
di as txt "* Cointegration t Test" _col(25) "AR(`i') = " as res %9.4f `lmeg`i'' _col(45) "P-Value > t" _col(60) as res %5.4f `lmegp`i''
di _dup(78) "{bf:-}"
return scalar lmeg_`i'=`lmeg`i''
return scalar lmegp_`i'=`lmegp`i''
qui tsset `TimeN'
 }
end

