*! lmgc V1.0 25/06/2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email:   emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define lmgc, rclass
version 11.0
syntax varlist(min=2 max=2) [if] [in], [LAGs(int 1) AUX(str) coll REG]
tempvar `varlist'
gettoken yvar xvar : varlist
qui marksample touse
tempvar Time TimeN E DE E1
tempname DF kx kb N SSE0 SSE1 tmin tmax
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
di as txt "{bf:{err:*** Granger Causality Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt " {bf:Ho: {res:`xvar'} does not Granger-Cause {res:`yvar'}}"
di
forvalue i=1/`lags' {
markout `touse' `Time' L(1/`i').(`varlist') `aux'
qui summ `Time' if `touse'
scalar `tmin' = r(min)
scalar `tmax' = r(max)
scalar `N' = r(N)
di as txt " Sample Range" _col(15) "= " as res `tmin' "-" `tmax' _col(35) "Sample Size" _col(15) "= " as res `N'
di as txt " {bf:Lag Length}" _col(15) "= " as res `i'
if "`reg'"!="" {
regress `yvar' L(1/`i').`yvar' `aux' if `touse'
 }
 else {
qui regress `yvar' L(1/`i').`yvar' `aux' if `touse'
 }
scalar `SSE0' = e(rss)
qui regress `yvar' L(1/`i').`yvar' L(1/`i').`xvar' `aux' if `touse'
scalar `SSE1'= e(rss)
scalar `kx'= `i'
scalar `DF'= e(df_r)
local lmgc1`i' = ((`SSE0'-`SSE1')/`kx')/(`SSE1'/`DF')
local lmgc1p`i'= Ftail(`kx',`DF', `lmgc1`i'')
local lmgc2`i' = e(N)*(`SSE0'-`SSE1')/`SSE1'
local lmgc2p`i'= chi2tail(`kx', `lmgc2`i'')
di as txt _col(2) "* F-Test" _col(15) "=" %12.4f as res `lmgc1`i'' _col(35) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(60) "= " %5.4f as res `lmgc1p`i''
di as txt _col(2) "* Wald Test" _col(15) "=" %12.4f as res `lmgc2`i'' _col(35) as txt "P-Value > Chi2(" as res `kx' ")" _col(60) "= " %5.4f as res `lmgc2p`i''
di _dup(78) "{bf:-}"
return scalar lmgc1_`i'=`lmgc1`i''
return scalar lmgc1p_`i'=`lmgc1p`i''
return scalar lmgc2_`i'=`lmgc2`i''
return scalar lmgc2p_`i'=`lmgc2p`i''
qui tsset `TimeN'
 }
end

