*! spweight V2.0 15/01/2013
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

 program define spweight, eclass
 version 11.0
 syntax varlist(numeric min=2 max=2) , Panel(string) Matrix(string) ///
 [Time(string) PTABle TABle INV INV2 Stand EIGw]
 tempvar `varlist'
 gettoken i j : varlist
 marksample touse, strok
 tempname w0 w1 w w_w0 w_w1 sum1 sum2 wm wxt m eVec
 tempvar  wt sum1 sum2
 qui summ `j'
 local T=r(max)
 scalar Tpanel=`panel'
 if Tpanel != `T' {
 di 
 di as err " {bf:panel( )} {cmd:not correct number.} You must set {bf:panel(" `T' ")}"
 exit
 }
 if "`inv'"!="" & "`stand'"=="" {
di as err " {bf:inv( )} {cmd:and} {bf:stand( )} {cmd:must be combined}"
 exit
 }
 if "`inv2'"!="" & "`stand'"=="" {
di as err " {bf:inv( )} {cmd:and} {bf:stand( )} {cmd:must be combined}"
 exit
 }
qui ereturn clear
 preserve
 local N= _N
 local T1= `T'
 local T2= `T'+1
 qui gen `wt'=1
 matrix `w'=J(`T1',`T1',0)
qui forval n=1/`N' {
 if `i'[`n'] < `j'[`n'] {
 matrix `w'[`i'[`n'],`j'[`n']]=`wt'[`n']
 matrix `w'[`j'[`n'],`i'[`n']]=`wt'[`n']
 }
 }
 matrix `w0'=`w'
 matrix `wm'=`w'
 matrix `w1'=`w0''
 svmat `w0' , name(`w_w0')
 svmat `w1' , name(`w_w1')
 qui egen Row = rowtotal(`w_w0'*)
 qui egen Col = rowtotal(`w_w1'*)
 qui sum Col
 scalar rsum=r(sum)
 mkmat Row in 1/`T1' , mat(Row)
 mkmat Col in 1/`T1' , mat(Col)
 matrix Col=Col\rsum
 matrix `w0'=`w0',Row \ Col'
 if "`table'"!=""  {
matlist `w0', twidth(5) border(all) rowtitle(Name) format(%3.0f) nohalf lines(rctotal)
 }
di
di _dup(78) "{bf:{err:=}}"
di as res "* Cross Section Spatial Weight Matrix:" _col(41) "`T1' x `T1'" _col(52) "(`matrix'cs)"
di _dup(78) "{bf:{err:=}}"
if "`stand'"=="" {
di as res " {bf:Binary (0/1) Weight Matrix}"
 } 
if "`stand'"!="" {
local useinv `inv' `inv2'
if "`stand'"!="" & "`useinv'"=="" {
di as res " {bf:Standardized Weight Matrix}"
 } 
local NC=`panel'
tempname Xo
matrix `Xo'=J(`NC',1,1)
matrix `wm'1=`wm'*`Xo'*`Xo''
mata: X = st_matrix("`wm'")
mata: Y = st_matrix("`wm'1")
mata: `wm'=X:/Y
mata: `wm'=st_matrix("`wm'",`wm')
mata: `wm' = st_matrix("`wm'")
 if "`inv'"!="" {
di as res " {bf:Inverse Standardized Weight Matrix (1/W)}"
mata: `wm'=1:/`wm'
mata: _editmissing(`wm', 0)
mata: `wm'=st_matrix("`wm'",`wm')
 }
 if "`inv2'"!="" {
di as res " {bf:Inverse Squared Standardized Weight Matrix (1/W^2)}"
mata: `wm'=`wm':*`wm'
mata: `wm'=1:/`wm'
mata: _editmissing(`wm', 0)
mata: `wm'=st_matrix("`wm'",`wm')
 }
}
matrix wcs=`wm'
 if "`eigw'"!="" {
matrix eigenvalues ew `eVec' =`wm'
matrix ewcs=ew'
ereturn matrix ewcs=ewcs
 }
 qui cap drop `i' `j'
 qui cap matrix drop Row Col
 drop _all
 qui svmat `wm' , name(`m')
 qui drop if `m'1 ==.
 qui renpfix `m' v
 qui cap matrix drop `matrix'cs
 qui mkmat v* in 1/`T1' , matrix(`matrix'cs)
 matrix `wm'=`matrix'cs
 qui save `matrix'cs.dta , replace
 if "`time'"!="" {
 if `time' > 1 {
 local NT=`panel'*`time'
di as res "* Panel Spatial Weight Matrix:" _col(41) "`NT' x `NT'" _col(52) "(`matrix'xt)"
di _dup(78) "{bf:{err:=}}"
qui cap matrix drop `wxt'
qui cap matrix drop `matrix'xt
qui matrix `wxt'=`wm'#I(`time')
 if "`eigw'"!="" {
matrix ewxt=vecdiag(diag(e(ewcs))#I(`time'))'
ereturn matrix ewxt=ewxt
 }
drop _all
 qui svmat `wxt' , name(`m')
 qui drop if `m'1 ==.
qui renpfix `m' v
 mkmat v* in 1/`NT' , matrix(`matrix'xt)
qui save `matrix'xt.dta , replace
ereturn matrix wxt=`wxt'
 }
}
di as res "*** Weight Matrix File is saved in:"
pwd
ereturn matrix wcs=`wm'
 if "`ptable'"!="" & `time' > 1 {
 matrix list e(wxt) , noheader format(%5.0g) nohalf nonames noblank
 }
qui matrix drop _all
 restore
 end
