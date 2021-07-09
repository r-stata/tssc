*! chowreg V2.0 25/12/2012
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define chowreg , rclass 
version 11.0
syntax varlist [if] [in] [aw iw] , Dum(string) [Type(int 3) NOCONStant ///
 vce(passthru) level(passthru) coll]
gettoken yvar xvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
local both : list yvar & xvar
if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
if "`xvar'"=="" {
di as err " {bf:Independent Variable(s) must be combined with Dependent Variable}"
 exit
 }
tempvar D0 Time DT TimeN
tempname SSE N df1 df2 dfr df1 df2 SSE1 N1 SSE2 N2 chow chowp
tempname fisher fisherp wald waldp lr lrp lm lmp kb
if inlist(`type',1,2,3,4)==0 {
di 
di as err " {bf:type(#)} {cmd:number must be 1, 2, or 3}"
exit
 }
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
if "`tolog'"!="" {
local vlistlog " `varlist' "
qui _rmcoll `vlistlog' , `noconstant' `coll' forcedrop
local vlistlog "`r(varlist)'"
di _dup(45) "-"
di as err " {cmd:** Data Have been Transformed to Log Form **}"
di as txt " {cmd:** `varlist'} "
di _dup(45) "-"
qui foreach var of local vlistlog {
tempvar xyind`var'
qui gen `xyind`var''=`var'
qui replace `var'=ln(`var')
qui replace `var'=0 if `var'==.
 }
 }
 if "`coll'"=="" {
_rmcoll `varlist' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
gettoken yvar xvar : varlist
 }
 if "`weight'" != "" {
local wgt "[`weight'`exp']"
 if "`weight'"=="aw" {
local wgt "[aweight`exp']"
 }
 if "`weight'"=="iw" {
local wgt "[iweight`exp']"
 }
 }
local kx : word count `xvar'
scalar `kb'=`kx'+1
 if "`noconstant'"!="" {
scalar `kb'=`kx'
 }
qui cap drop D0
qui gen D0= 1
qui replace D0= 0 in 1/`dum'
*qui gen D0=inrange(`Time', `dum', .)
 if "`type'"=="1" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Structural Change Regression *}}"
di _dup(78) "{bf:{err:=}}"
 regress `yvar' `xvar' D0 if `touse' `wgt' , `noconstant' `vce' `level'
 testparm D0 
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Structural Change Test: Y = X + D0 *}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(3) "{bf:Ho: no Structural Change}"
di
di as txt "- N1: 1st Period Obs" _col(28) "=" as res %5.0f `dum'
di as txt "- N2: 2nd Period Obs" _col(28) "=" as res %5.0f e(N)-`dum'
di as txt "- Chow Test" _col(28) "=" as res %10.4f r(F) _col(45) as txt "P-Value > F(" r(df) " , " r(df_r) ")" _col(67) as res %5.4f r(p)
 }
 if "`type'"=="2" {
qui foreach var of local xvar {
qui cap drop Dx_`var'
qui gen Dx_`var' = D0*`var'
 }
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Structural Change Regression *}}"
di _dup(78) "{bf:{err:=}}"
 regress `yvar' `xvar' Dx_* if `touse' `wgt' , `noconstant' `vce' `level'
 testparm Dx_* 
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Structural Change Test: Y = X + DX}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(3) "{bf:Ho: no Structural Change}"
di
di as txt "- N1: 1st Period Obs" _col(28) "=" as res %5.0f `dum'
di as txt "- N2: 2nd Period Obs" _col(28) "=" as res %5.0f e(N)-`dum'
di as txt "- Chow Test" _col(28) "=" as res %10.4f r(F) _col(45) as txt "P-Value > F(" r(df) " , " r(df_r) ")" _col(67) as res %5.4f r(p)
 }
 if "`type'"=="3" {
qui regress `yvar' `xvar' if `touse' `wgt' , `noconstant' `vce' `level'
scalar `SSE'= e(rss)
scalar `N'= e(N)
scalar `dfr'= e(N)-`kb'
scalar `df1'= `kb'
scalar `df2'= e(N)-2*`kb'
qui gen `DT'=_n
qui regress `yvar' `xvar' if `DT' <= `dum' `wgt' , `noconstant' `vce' `level'
scalar `SSE1'= e(rss)
scalar `N1'= e(N)
qui regress `yvar' `xvar' if `DT' > `dum' `wgt' , `noconstant' `vce' `level'
scalar `SSE2'= e(rss)
scalar `N2'= e(N)
scalar `chow'= ((`SSE'-(`SSE1'+`SSE2'))/`df1')/((`SSE1'+`SSE2')/`df2')
scalar `chowp'= Ftail(`df1', `df2', `chow')
scalar `fisher'=((`SSE'-`SSE1')/`N2')/(`SSE1'/(`N1'-`df1'))
scalar `fisherp'= Ftail(`N2', (`N1'-`df1'), `fisher')
scalar `wald'=(`SSE'-(`SSE1'+`SSE2'))/((`SSE1'+`SSE2')/`N')
scalar `waldp'=chi2tail(`kx' , `wald')
scalar `lr'=`N'*log(`SSE'/(`SSE1'+`SSE2'))
scalar `lrp'=chi2tail(`kx' , `lr')
scalar `lm'=(`SSE'-(`SSE1'+`SSE2'))/(`SSE'/`N')
scalar `lmp'=chi2tail(`kx' , `lm')
qui foreach var of local xvar {
qui cap drop Dx_`var'
qui gen Dx_`var' = D0*`var'
 }
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Structural Change Regression *}}"
di _dup(78) "{bf:{err:=}}"
 regress `yvar' `xvar' D0 Dx_* if `touse' `wgt' , `noconstant' `vce' `level'
 testparm D0 Dx_*
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Structural Change Tests:  Y = X + D0 + DX}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(3) "{bf:Ho: no Structural Change}"
di
di as txt "- N1: 1st Period Obs" _col(28) "=" as res %5.0f `dum'
di as txt "- N2: 2nd Period Obs" _col(28) "=" as res %5.0f e(N)-`dum'
di as txt "- Chow Test   [K, N-2*K]" _col(28) "=" as res %10.4f `chow' _col(45) as txt "P-Value > F(" `df1' " , " `df2' ")" _col(67) as res %5.4f `chowp'
di as txt "- Fisher Test [N2,(N1-K)]" _col(28) "=" as res %10.4f `fisher' _col(45) as txt "P-Value > F(" `N2' " , " `N1'-`df1' ")" _col(67) as res %5.4f `fisherp'
di as txt "- Wald Test"  _col(28) "=" as res %10.4f `wald' _col(45) as txt "P-Value > Chi2(" `N2' ")" _col(67) as res %5.4f `waldp'
di as txt "- Likelihood Ratio Test" _col(28) "=" as res %10.4f `lr' _col(45) as txt "P-Value > Chi2(" `N2' ")" _col(67) as res %5.4f `lrp'
di as txt "- Lagrange Multiplier Test" _col(28) "=" as res %10.4f `lm' _col(45) as txt "P-Value > Chi2(" `N2' ")" _col(67) as res %5.4f `lmp'
return scalar lmp=`lmp'
return scalar lm=`lm'
return scalar lrp=`lrp'
return scalar lr=`lr'
return scalar waldp=`waldp'
return scalar wald=`wald'
return scalar fisherp=`fisherp'
return scalar fisher=`fisher'
return scalar chowp=`chowp'
return scalar chow=`chow'
 }
qui tsset `TimeN'
end
