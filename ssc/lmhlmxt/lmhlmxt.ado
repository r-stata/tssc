*! lmhlmxt V1.0 15jan2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm
 
program define lmhlmxt, rclass 
version 10.1
syntax varlist [if] [in] [aw fw iw pw] , id(str) [ NOCONStant vce(passthru) *] 
 tempvar `varlist'
 gettoken yvar xvar : varlist
 marksample touse
 markout `touse' 
 tempvar X0 panel tm idv itv X Time
 tempname X0 X
 gettoken yvar xvar : varlist
 local both : list yvar & xvar
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS & RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS:`xvar'"
 exit
 } 
marksample touse
qui gen `Time'=_n
qui summ `Time'
local NT = r(N)
local S = `id'
local T = `NT'/`id'
scalar S = `S'
scalar T = `T'
scalar NT = `NT'
qui cap drop `idv'
qui cap drop `itv'
qui gen `idv'=0 if `touse'
qui gen `itv'=0 if `touse'
qui forvalues i = 1/`id' {
qui summ `Time' if `touse' , meanonly
local min=int(`T'*`i'-`T'+1)
local max=int(`T'*`i')
 replace `idv'= `i' in `min'/`max'
 replace `itv'= `Time'-`min'+1 in `min'/`max'
 }
 qui summ `idv'
 scalar Tidv=r(max)
 qui summ `itv'
 scalar Titv=r(max)
 if `NT' != Titv*Tidv {
 di 
 di as err " Number of obs  = " `NT'
 di as err " Cross Sections = " Tidv
 di as err " Time           = " Titv
 di as res " Product of (Time x Cross Sections) must be Equal Sample Size"
 di as err " {bf:id(`S')} {cmd:Wrong Number, Check Correct Number Units of Cross Sections.}"
 exit
 }
 
tempvar Sig2 SigLM SigLMs E E2 EE1 En resid cN cT Obs Egh Time
qui gen `Time'=_n
local id `idv'
qui tab `id'
local N_g = r(r)
local scalar `C' = r(r)
local scalar `N' = r(N)
qui tsset `Time'
qui regress `yvar' `xvar'  if `touse' `wgt' , `noconstant' `vce'
qui predict `E' if `touse', res
qui gen double `E2' = `E'^2 if `touse'
qui sum `E2' if `touse' , meanonly
local NT = _N
local Sig2 = r(sum)/`NT'
qui gen double `SigLM' = . if `touse' 
local SigLMs = 0
qui levels `id' , local(levels)
qui foreach l of local levels {
 sum `E2' if `id' == `l', meanonly
 replace `SigLM' = r(sum)/r(N)  if `id' == `l'
 replace `SigLM' = (`SigLM'/`Sig2'-1)^2  if `id' == `l'
 sum `SigLM' if `id' == `l', meanonly
local SigLMs =`SigLMs'+ r(mean)
 }
local hdf = `N_g'-1
local TM=`NT'/`N_g'
local lmhlm=`TM'/2*(`SigLMs')
local lmhlmp= chiprob(`hdf', abs(`lmhlm'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Breusch-Pagan Lagrange Multiplier Panel Heteroscedasticity Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(2) "{bf: Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity}"
di
di as txt _col(5) "Lagrange Multiplier LM Test" _col(35) " = " as res %10.5f `lmhlm'
di as txt _col(5) "Degrees of Freedom" _col(35) " = " as res %10.1f `hdf'
di as txt _col(5) "P-Value > Chi2(" `hdf' ")" _col(35) " = " as res %10.5f `lmhlmp'
di _dup(78) "{bf:{err:=}}"
qui `cmd'
return scalar lmh = `lmhlm'
return scalar lmhp= `lmhlmp'
return scalar lmhdf= `hdf'
end
