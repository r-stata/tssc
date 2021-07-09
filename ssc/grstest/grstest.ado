capture program drop grstest
program define grstest, eclass
version 9 
syntax varlist (numeric), flist(string) [ret(string)] 
tempname T N K J df1 df2 df3 X Y t w GRS pvalue w1 GRS1 pvalue1 
tempname R Rinv O Oinv xp xr A As M Ms 
preserve
local i=1
local x = "`varlist'"
local y = "`flist'"
local p : word count `x'
local f : word count `flist'
foreach var of varlist `x'{
qui rename `var' p`i'
local i=`i'+1
}
qui count
scalar `T' = `r(N)'
scalar `N' = `p'
scalar `K' = `f'
scalar `J' = `K' +1
scalar `df1' = `N'
scalar `df2' = `T'-`N'-`K'
scalar `df3' = `T'-`N'-1
di ""
di ""
if "`ret'"=="r" {
capture confirm variable rf
if _rc {
di as err "cannot find variable rf (containing the risk free rate) to calculate the excess returns."
exit _rc
}
else if !_rc {
di in green "Your portfolio returns are raw returns, excess returns are automatically calculated to run the test. ! "
foreach var of varlist p1 - p`p' {
qui replace `var'=`var'-rf
}
}
}
else if "`ret'"~="r" | "`ret'"~="" {
di as err "The option ret() is not specified or is specified improperly. grstest will assume that the returns are excess returns."
}
foreach var of varlist p1 - p`p'{
qui reg `var' `flist' 
qui predict R`var',res
}
qui mat accum `xp'  =  Rp*, dev noconstant
mat `R'=`xp'/(r(N)-1) 
drop Rp*
mat `Rinv' = invsym(`R')
if `K' > 1 {
forvalues i=1/`p' {
tempname ap`i'
}
foreach var of varlist p1 - p`p'{
qui reg `var' `flist' 
mat `a`var''= e(b)
}
forvalues i = 1/`p' {
mat `As' = (nullmat(`As'), `ap`i''[1,`J'])
}
mat `A'=`As''
qui mat accum `xr'  = `flist', dev noconstant
mat `O' =`xr'/(r(N)-1) 
mat `Oinv' = invsym(`O')
qui tabstat `flist', statistics(mean) columns(statistics) save
mat `M'=r(StatTotal)
mat `M'=`M''
mat `Ms'=`M''
mat `Y' =`Ms' * `Oinv' * `M'
scalar `Y' = det(`Y')
mat `X' =`As' * `Rinv' * `A' 
scalar `X' = det(`X')
scalar `w' = `X'/(1 + `Y') 
scalar `GRS'=((`T'-`N'-`K')/(`N')) * `w'
scalar `pvalue'= 1-F(`df1',`df2',`GRS')
di in green "You are testing a multi factor model with " in yellow `K' in green " factors " in yellow "`flist'" in green " and " in yellow `N' in green " portfolios."
di in green "The GRS test statistic is:  " in yellow `GRS' in green " and the p-value is:  " in yellow `pvalue'
restore
}
else if `K'==1 {
forvalues i=1/`p' {
tempname kp`i'
}
foreach var of varlist p1 - p`p'{
qui reg `var' `flist' 
mat `k`var''= e(b)
}
forvalues i = 1/`p' {
mat `As' = (nullmat(`As'), `kp`i''[1,`J'])
}
mat `A'=`As''
qui sum `flist',detail
scalar `t'= `r(mean)'/(`r(sd)')
mat `X' =`As' * `Rinv' * `A' 
scalar `X' = det(`X')
scalar `w1'= `X' / (1+(`t'^2))
scalar `GRS1' = ((`T'-`N'-`K')/(`N')) * `w1'
scalar `pvalue1'= 1-F(`df1',`df3',`GRS1')
di in green "You are testing a single factor model with " in yellow `K' in green " factor " in yellow "`flist'" in green " and " in yellow `N' in green " portfolios."
di in green "The GRS test statistic is:  " in yellow `GRS1' in green " and the p-value is:  " in yellow `pvalue1'
restore
}
end
