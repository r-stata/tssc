*! spweightcs V2.0 15/01/2013
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define spweightcs, eclass
version 11.0
 syntax varlist , Panel(string) Matrix(string) [TABle]
 tempvar `varlist'
 marksample touse, strok
 {
tempname TM NT NC U E N W WVars W_w Z0 W0
tempvar  TM NT NC U E N WVars W_w Z0 W0 MVar
qui tokenize "`varlist'"
 qui summ `1'
 scalar T=r(max)
 scalar Tpanel=`panel'
 if Tpanel != T {
 di 
 di as err " {bf:panel( )} {cmd:not correct number.} You must set {bf:panel(" T ")}"
 exit
 }
qui gen byte `WVars' = 1
qui preserve
qui keep if `touse'
qui stack `1' `2' , into(`2') clear
qui keep `2' 
qui sort `2'
qui qui by `2': keep if _n==1 
qui tempfile TMat
qui save `"`TMat'"'
qui rename `2' `1'
qui MCS `"`TMat'"'
qui sort `1' `2'
qui save `"`TMat'"', replace
qui restore, pres
qui keep if `touse'
qui keep `1' `2' `WVars'
qui sort `1' `2'
qui merge `1' `2' using `"`TMat'"'
qui drop _merge
qui replace `WVars'=0 if `WVars'>=.
if "`table'"!=""  {
noi table `1' `2',c(sum `WVars') row col center f(%5.0f)
}
qui tempvar user1 user2
qui rename `1' `user1'
qui rename `2' `user2'
qui tempvar sWVars
qui sort `user1' `user2'     
qui by `user1' `user2': gen `sWVars' = sum(`WVars')
qui by `user1' `user2': keep if _n == _N
qui tempvar gro gco
qui sort `user1'
qui by `user1': gen int `gro' = 1 if _n==1
qui replace `gro' = sum(`gro')
qui sort `user2'
qui by `user2': gen int `gco' = 1 if _n==1
qui replace `gco' = sum(`gco')
qui sum `gro', meanonly
qui local r=r(max)
qui rename `gro' i
qui rename `gco' j
qui rename `sWVars' CV
qui sort i j
qui gen int `MVar'= CV[_n+(`r'-1)*(j-i)]
mkmat `MVar' , matrix(`W0')
qui matrix `Z0'=J(1,`panel',1)'
qui matrix Dum=I(`panel')#`Z0'
qui svmat Dum , name(Dums)
qui gen idd=.
local i = 1
while `i' <= `panel' {
qui replace idd=`i' if Dums`i'==1 
local i = `i' + 1
 }
qui gen `N'=_n
local i = 1
while `i' <= `panel' {
qui sum `N' if idd == `i'
scalar min=r(min)
scalar max=r(max)
local min min
local max max
qui matrix `W_w'`i'=`W0'[`min'..`max', 1..1]
qui svmat `W_w'`i' , name(`W_w'`i')
 local i = `i' + 1
 }
 }
qui matrix drop Dum 
qui mkmat `W_w'* in 1/`panel' , matrix(`matrix')
qui svmat `matrix'
qui keep `matrix'*
qui renpfix `matrix' v
di
qui cap matrix drop `matrix'cs
qui drop if v1 ==.
mkmat v* , matrix(`matrix'cs)
di as txt "************************************************************************"
di as txt "*** Cross Section Spatial Weight Matrix (`matrix'cs) File is saved in:"
di as txt "************************************************************************"
pwd
qui save `matrix'cs.dta , replace
ereturn matrix `matrix'cs=`matrix'cs
end

program define MCS /* using `TMat' */
 args using
 local nob = _N
 tempfile cross2
 tempvar order midx
 preserve
 quietly use `"`using'"', clear
 quietly {
 gen long `order'=_n
 expand `nob', clear
 sort `order'
 by `order': gen long `midx' = _n
 sort `midx' `order'
 drop `order'
qui save `"`cross2'"', replace
 restore, preserve
 gen long `midx' = _n
 sort `midx'
 merge `midx' using "`cross2'"
 drop `midx' _merge
 restore, not
 }
end
exit
