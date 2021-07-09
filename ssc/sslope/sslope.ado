program define sslope
version 8
syntax varlist [if] [in], i(varlist) [sd(real 1.0)] [Graph] [go(string)] [Fits]

regress `varlist' `if' `in'
marksample touse
tempvar M
matrix `M'=e(V) // use the variance-covariance matrix of the regression coefficients
tokenize `i'
// obtain number of coefficients in i
local way:word count `i'

*2-way interaction (y= b1x+ b2z +b3xz + b0)
if `way'==3 {
local rx=rownumb(`M',"`1'")
local cx=colnumb(`M',"`1'")
local sxx=el(matrix(`M'),`rx',`cx') //variance of bx
local rxz=rownumb(`M',"`3'")
local cxz=colnumb(`M',"`3'")
local sxxz=el(matrix(`M'),`rx',`cxz') //covariance of bxbxz
local sxzxz=el(matrix(`M'),`rxz',`cxz') //variance of bxz
quietly summarize `2' if `touse'==1 // summarize the moderator z
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 

// calculate conditional values
local Zhi=`s'*`sd' 
local Zlo=-`s'*`sd'
// calculate standard error for the conditional effects
local Sxzhi=sqrt((`sxx')+(2*`Zhi'*`sxxz')+(`Zhi'*`Zhi'*`sxzxz'))
local Sxzlo=sqrt((`sxx')+(2*`Zlo'*`sxxz')+(`Zlo'*`Zlo'*`sxzxz'))
local Sxzm=sqrt((`sxx'))
// calculate simple slopes
local bxzhi=_b[`1']+(_b[`3']*`Zhi')
local bxzlo=_b[`1']+(_b[`3']*`Zlo')
local bxzm=_b[`1']

//calculate t-test
local thi=`bxzhi'/`Sxzhi'
local tm=`bxzm'/`Sxzm'
local tlo = `bxzlo'/`Sxzlo'

//calculate p-value
local thp=2*(ttail(e(df_r),abs(`thi')))
local tmp=2*(ttail(e(df_r),abs(`tm')))
local tlp=2*(ttail(e(df_r),abs(`tlo')))


//display table
di
di
di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `2'  +/- `sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`2'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bxzhi' "{col 28}" %9.0g `Sxzhi' "{col 42}" %5.2f `thi' "{col 49}" %6.3f `thp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bxzm' "{col 28}" %9.0g `Sxzm' "{col 42}" %5.2f `tm' "{col 49}" %6.3f `tmp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bxzlo' "{col 28}" %9.0g `Sxzlo' "{col 42}" %5.2f `tlo' "{col 49}" %6.3f `tlp'
di "{txt}{hline 12}{c BT}{hline 53}"

//default graph option
if "`graph'"=="graph" {
tempvar fitzhi fitzlo fitzmean
quietly gen `fitzhi' =`1'*`bxzhi'+ `Zhi'*_b[`2']+_b[_cons] if `touse'==1
quietly gen `fitzlo' =`1'*`bxzlo'+ `Zlo'*_b[`2']+ _b[_cons] if `touse'==1
quietly gen `fitzmean' =`1'*_b[`1']+ _b[_cons] if `touse'==1
label var `fitzhi' "`2'+`sd'sd"
label var `fitzlo' "`2'-`sd'sd"
label var `fitzmean' "`2' mean"
local ytitle `e(depvar)'
local xtitle `1'
scatter  `e(depvar)' `fitzhi' `fitzmean' `fitzlo' `1' if `touse'==1, c(. l l l) m(o i i i) sort ytitle("`ytitle'") xtitle("`xtitle'") jitter(5)
}
// user specified graph options
if "`go'" != "" {
tempvar fitzhi fitzlo fitzmean
quietly gen `fitzhi' =`1'*`bxzhi' + `Zhi'*_b[`2']+ _b[_cons]
quietly gen `fitzlo' =`1'*`bxzlo' + `Zlo'*_b[`2']+ _b[_cons]
quietly gen `fitzmean' =`1'*_b[`1']+ _b[_cons]
label var `fitzhi' "`2'+`sd'sd"
label var `fitzlo' "`2'-`sd'sd"
label var `fitzmean' "`2' mean"
scatter  `e(depvar)' `fitzhi' `fitzmean' `fitzlo' `1' if `touse'==1, `go'
}
//calculate fits if fit option is specified
if "`fits'" =="fits" {
	tempvar fitzhi fitzmean fitzlo
	
	local fitzhi: permname fitzhi
	local fitzmean: permname fitzmean
	local fitzlo: permname fitzlo
	
	quietly gen `fitzhi' =`1'*`bxzhi' + `Zhi'*_b[`2']+ _b[_cons] if `touse'==1
	quietly gen `fitzlo' =`1'*`bxzlo' + `Zlo'*_b[`2']+ _b[_cons] if `touse'==1
	quietly gen `fitzmean' =`1'*_b[`1']+ _b[_cons] if `touse'==1
	
	label var `fitzhi' "`2'+`sd'sd"
	label var `fitzmean' "`2' mean"
	label var `fitzlo' "`2'-`sd'sd"
}
}
*//3-way interaction y=b1x+b2z+b3w+b4xz+b5xw+b6zw+b7xzw+b0
if `way'==7 {
local rx=rownumb(`M',"`1'")
local cx=colnumb(`M',"`1'")
local sxx=el(matrix(`M'),`rx',`cx')        // variance of bx
local rxz=rownumb(`M',"`4'")
local cxz=colnumb(`M',"`4'")
local sxxz=el(matrix(`M'),`rx',`cxz')    //covariance of bxbxz
local sxzxz=el(matrix(`M'),`rxz',`cxz') //variance of bxz



local rxw=rownumb(`M',"`5'")
local cxw=colnumb(`M',"`5'")
local sxwxw=el(matrix(`M'),`rxw',`cxw')  //variance of bxw
local sxxw=el(matrix(`M'),`rx',`cxw')    // covariance of bxbxw
local sxzxw=el(matrix(`M'),`rxz',`cxw')  //covariance of bxzbxw

local rxzw=rownumb(`M',"`7'")
local cxzw=colnumb(`M',"`7'")
local sxzwxzw=el(matrix(`M'),`rxzw',`cxzw') // variance of bxzw
local sxxzw=el(matrix(`M'),`rx',`cxzw')     // covariance of bxbxzw
local sxzxzw=el(matrix(`M'),`rxz',`cxzw')   // covariance of bxzbxzw
local sxwxzw=el(matrix(`M'),`rxw',`cxzw')   // covariance of bxwbxzw

// calculate conditional values of z
quietly summarize `2' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
local Zhi=`s'*`sd'
local Zlo=(-1)*(`s')*(`sd')


// calculate conditional values of w
quietly summarize `3' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
local Whi=`s'*`sd'
local Wlo=(-1)*(`s')*(`sd')

// calculate standard errors for combinations of z and w

local Sxzhiwhi=sqrt((`sxx')+(`Zhi'*`Zhi'*`sxzxz')+(`Whi'*`Whi'*`sxwxw') ///
+((`Zhi'*`Zhi')*(`Whi'*`Whi')*`sxzwxzw')+(2*`Zhi'*`sxxz')+(2*`Whi'*`sxxw') ///
+(2*(`Zhi'*`Whi')*`sxxzw')+(2*`Zhi'*`Whi'*`sxzxw')+(2*`Whi'*`Zhi'*`Zhi'*`sxzxzw') ///
+(2*`Whi'*`Whi'*`Zhi'*`sxwxzw'))


local Sxzlowlo=sqrt((`sxx')+(`Zlo'*`Zlo'*`sxzxz')+(`Wlo'*`Wlo'*`sxwxw') ///
+(`Zlo'*`Zlo'*`Wlo'*`Wlo'*`sxzwxzw')+(2*`Zlo'*`sxxz')+(2*`Wlo'*`sxxw') ///
+(2*`Zlo'*`Wlo'*`sxxzw')+(2*`Zlo'*`Wlo'*`sxzxw')+(2*`Wlo'*`Zlo'*`Zlo'*`sxzxzw') ///
+(2*`Wlo'*`Wlo'*`Zlo'*`sxwxzw'))

local Sxzhiwlo= sqrt((`sxx')+(`Zhi'*`Zhi'*`sxzxz')+(`Wlo'*`Wlo'*`sxwxw') ///
+((`Zhi'*`Zhi')*(`Wlo'*`Wlo')*`sxzwxzw')+(2*`Zhi'*`sxxz')+(2*`Wlo'*`sxxw') ///
+(2*(`Zhi'*`Wlo')*`sxxzw')+(2*`Zhi'*`Wlo'*`sxzxw')+(2*`Wlo'*`Zhi'*`Zhi'*`sxzxzw') ///
+(2*`Wlo'*`Wlo'*`Zhi'*`sxwxzw'))

local Sxzlowhi= sqrt((`sxx')+(`Zlo'*`Zlo'*`sxzxz')+(`Whi'*`Whi'*`sxwxw') ///
+((`Zlo'*`Zlo')*(`Whi'*`Whi')*`sxzwxzw')+(2*`Zlo'*`sxxz')+(2*`Whi'*`sxxw') ///
+(2*(`Zlo'*`Whi')*`sxxzw')+(2*`Zlo'*`Whi'*`sxzxw')+(2*`Whi'*`Zlo'*`Zlo'*`sxzxzw') ///
+(2*`Whi'*`Whi'*`Zlo'*`sxwxzw'))

local Sxzmwhi= sqrt((`sxx')+(`Whi'*`Whi'*`sxwxw') ///
+(2*`Whi'*`sxxw'))  ///

local Sxzmwlo= sqrt((`sxx')+(`Wlo'*`Wlo'*`sxwxw') ///
+(2*`Wlo'*`sxxw'))  ///

local Sxzlowm= sqrt((`sxx')+(`Zlo'*`Zlo'*`sxzxz') ///
+(2*`Zlo'*`sxxz')) ///

local Sxzhiwm= sqrt((`sxx')+(`Zhi'*`Zhi'*`sxzxz') ///
+(2*`Zhi'*`sxxz')) ///

local Sxzmwm= sqrt((`sxx')) ///

//calculate simple slopes

local bxzhiwhi=_b[`1']+(_b[`4']*`Zhi')+(_b[`5']*`Whi')+(_b[`7']*`Zhi'*`Whi')
local bxzhiwm=_b[`1']+(_b[`4']*`Zhi')
local bxzhiwlo=_b[`1']+(_b[`4']*`Zhi')+(_b[`5']*`Wlo')+(_b[`7']*`Zhi'*`Wlo')

local bxzmwhi=_b[`1']+(_b[`5']*`Whi')
local bxzmwm=_b[`1']
local bxzmwlo=_b[`1']+(_b[`5']*`Wlo')

local bxzlowhi=_b[`1']+(_b[`4']*`Zlo')+(_b[`5']*`Whi')+(_b[`7']*`Zlo'*`Whi')
local bxzlowm=_b[`1']+(_b[`4']*`Zlo')
local bxzlowlo=_b[`1']+(_b[`4']*`Zlo')+(_b[`5']*`Wlo')+(_b[`7']*`Zlo'*`Wlo')


// calculate t-test
local thihi= `bxzhiwhi'/`Sxzhiwhi'
local thim= `bxzhiwm'/`Sxzhiwm'
local thilo= `bxzhiwlo'/`Sxzhiwlo'

local tmhi= `bxzmwhi'/`Sxzmwhi'
local tmm= `bxzmwm'/`Sxzmwm'
local tmlo= `bxzmwlo'/`Sxzmwlo'

local tlohi= `bxzlowhi'/`Sxzlowhi'
local tlom= `bxzlowm'/`Sxzlowm'
local tlolo= `bxzlowlo'/`Sxzlowlo'

// calculate p-value
local thhp=2*(ttail(e(df_r),abs(`thihi')))
local thmp=2*(ttail(e(df_r),abs(`thim')))
local thlp=2*(ttail(e(df_r),abs(`thilo')))

local tmhp=2*(ttail(e(df_r),abs(`tmhi')))
local tmmp=2*(ttail(e(df_r),abs(`tmm')))
local tmlp=2*(ttail(e(df_r),abs(`tmlo')))

local tlhp=2*(ttail(e(df_r),abs(`tlohi')))
local tlmp=2*(ttail(e(df_r),abs(`tlom')))
local tllp=2*(ttail(e(df_r),abs(`tlolo')))


//display table
di
di
di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `2' +`sd'sd, `3' +/-`sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`3'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bxzhiwhi' "{col 28}" %9.0g `Sxzhiwhi' "{col 42}" %5.2f `thihi' "{col 49}" %6.3f `thhp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bxzhiwm' "{col 28}" %9.0g `Sxzhiwm' "{col 42}" %5.2f `thim' "{col 49}" %6.3f `thmp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bxzhiwlo' "{col 28}" %9.0g `Sxzhiwlo' "{col 42}" %5.2f `thilo' "{col 49}" %6.3f `thlp'
di "{txt}{hline 12}{c BT}{hline 53}"

di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `2' mean, `3' +/-`sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`3'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bxzmwhi' "{col 28}" %9.0g `Sxzmwhi' "{col 42}" %5.2f `tmhi' "{col 49}" %6.3f `tmhp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bxzmwm' "{col 28}" %9.0g `Sxzmwm' "{col 42}" %5.2f `tmm' "{col 49}" %6.3f `tmmp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bxzmwlo' "{col 28}" %9.0g `Sxzmwlo' "{col 42}" %5.2f `tmlo' "{col 49}" %6.3f `tmlp'
di "{txt}{hline 12}{c BT}{hline 53}"

di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `2' -`sd'sd, `3' +/-`sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`3'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bxzlowhi' "{col 28}" %9.0g `Sxzlowhi' "{col 42}" %5.2f `tlohi' "{col 49}" %6.3f `tlhp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bxzlowm' "{col 28}" %9.0g `Sxzlowm' "{col 42}" %5.2f `tlom' "{col 49}" %6.3f `tlmp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bxzlowlo' "{col 28}" %9.0g `Sxzlowlo' "{col 42}" %5.2f `tlolo' "{col 49}" %6.3f `tllp'
di "{txt}{hline 12}{c BT}{hline 53}"

// default graph option
if "`graph'"=="graph" {
tempvar fithihi fitlolo fithilo fitlohi fitmlo fitmhi fitlom fithim
quietly gen `fithihi' =`1'*`bxzhiwhi'+_b[`2']*`Zhi' +_b[`3']*`Whi'+_b[`6']*`Zhi'*`Whi'+ _b[_cons]
quietly gen `fitlolo' =`1'*`bxzlowlo'+ _b[`2']*`Zlo' +_b[`3']*`Wlo'+_b[`6']*`Zlo'*`Wlo'+ _b[_cons]
quietly gen `fithilo' =`1'*`bxzhiwlo'+ _b[`2']*`Zhi' +_b[`3']*`Wlo'+_b[`6']*`Zhi'*`Wlo'+ _b[_cons]
quietly gen `fitlohi' =`1'*`bxzlowhi'+ _b[`2']*`Zlo' +_b[`3']*`Whi'+_b[`6']*`Zlo'*`Whi'+ _b[_cons]
quietly gen `fitmhi' =`1'*`bxzmwhi' +_b[`3']*`Whi' + _b[_cons]
quietly gen `fitmlo' =`1'*`bxzmwlo'+_b[`3']*`Wlo' + _b[_cons]
quietly gen `fithim' =`1'*`bxzhiwm'+ _b[`2']*`Zhi' + _b[_cons]
quietly gen `fitlom' =`1'*`bxzlowm'+ _b[`2']*`Zlo' + _b[_cons]

label var `fithihi' "`2'+`sd'sd,`3' +`sd'sd"
label var `fitlolo' "`2'-`sd'sd,`3' -`sd'sd"
label var `fithilo' "`2'+`sd'sd,`3' -`sd'sd"
label var `fitlohi' "`2'-`sd'sd,`3' +`sd'sd"
local ytitle `e(depvar)'
local xtitle `1'
tempfile hi lo hi2 lo2
scatter  `e(depvar)' `fithihi'  `fitlohi' `1' if `touse'==1, c(. l l) m(o i i) sort ytitle("") xtitle("`xtitle'") title("`3' +`sd'sd") saving(`hi')
scatter  `e(depvar)'  `fitlolo' `fithilo'  `1' if `touse'==1, c(. l l) m(o i i) sort ytitle("") xtitle("`xtitle'") title("`3' -`sd'sd") saving(`lo')
scatter  `e(depvar)' `fithihi'  `fithilo' `1' if `touse'==1, c(. l l) m(o i i) sort ytitle("") xtitle("`xtitle'") title("`2' +`sd'sd") saving(`hi2')
scatter  `e(depvar)'  `fitlolo' `fitlohi'  `1' if `touse'==1, c(. l l) m(o i i) sort ytitle("") xtitle("`xtitle'") title("`2' -`sd'sd") saving(`lo2')
graph combine "`hi'" "`lo'" "`hi2'" "`lo2'",ycommon
}

// user-defined graph options
if "`go'" !="" {
tempvar fithihi fitlolo fithilo fitlohi fitmlo fitmhi fithim fitlom fitmm
quietly gen `fithihi' =`1'*`bxzhiwhi'+_b[`2']*`Zhi' +_b[`3']*`Whi'+_b[`6']*`Zhi'*`Whi'+ _b[_cons] if `touse'==1
quietly gen `fitlolo' =`1'*`bxzlowlo'+ _b[`2']*`Zlo' +_b[`3']*`Wlo'+_b[`6']*`Zlo'*`Wlo'+ _b[_cons] if `touse'==1
quietly gen `fithilo' =`1'*`bxzhiwlo'+ _b[`2']*`Zhi' +_b[`3']*`Wlo'+_b[`6']*`Zhi'*`Wlo'+ _b[_cons] if `touse'==1
quietly gen `fitlohi' =`1'*`bxzlowhi'+ _b[`2']*`Zlo' +_b[`3']*`Whi'+_b[`6']*`Zlo'*`Whi'+ _b[_cons] if `touse'==1
quietly gen `fitmhi' =`1'*`bxzmwhi' +_b[`3']*`Whi' + _b[_cons] if `touse'==1
quietly gen `fitmlo' =`1'*`bxzmwlo'+_b[`3']*`Wlo' + _b[_cons] if `touse'==1
quietly gen `fithim' =`1'*`bxzhiwm'+ _b[`2']*`Zhi' + _b[_cons] if `touse'==1
quietly gen `fitlom' =`1'*`bxzlowm'+ _b[`2']*`Zlo' + _b[_cons] if `touse'==1
quietly gen `fitmm' =`1'*_b[`1']+ _b[_cons] if `touse'==1

label var `fithihi' "`2'+`sd'sd,`3' +`sd'sd"
label var `fitlolo' "`2'-`sd'sd,`3' -`sd'sd"
label var `fithilo' "`2'+`sd'sd,`3' -`sd'sd"
label var `fitlohi' "`2'-`sd'sd,`3' +`sd'sd"
local ytitle `e(depvar)'
local xtitle `1'
tempfile hi lo hi2 lo2
scatter  `e(depvar)' `fithihi'  `fitlohi' `1' if `touse'==1, `go' saving(`hi')
scatter  `e(depvar)'  `fitlolo' `fithilo'  `1' if `touse'==1, `go' saving(`lo')
scatter  `e(depvar)' `fithihi'  `fithilo' `1' if `touse'==1, `go' saving(`hi2')
scatter  `e(depvar)'  `fitlolo' `fitlohi'  `1' if `touse'==1, `go' saving(`lo2')
graph combine "`hi'" "`lo'" "`hi2'" "`lo2'",ycommon
}
// calculate fits for fit option
if "`fits'" =="fits" {
	tempvar fithihi fitlolo fithilo  fitlohi  fitmlo fitmhi fithim fitlom fitmm
	local fithihi: permname fithihi
	local fitlolo: permname fitlolo
	local fithilo: permname fithilo
	local fitlohi: permname fitlohi
	local fitmlo: permname fitmlo
	local fitmhi: permname fitmhi
	local fithim: permname fithim
	local fitlom: permname fitlom
	local fitmm: permname fitmm
	
	quietly gen `fithihi' =`1'*`bxzhiwhi'+_b[`2']*`Zhi' +_b[`3']*`Whi'+_b[`6']*`Zhi'*`Whi'+ _b[_cons] if `touse'==1
	quietly gen `fitlolo' =`1'*`bxzlowlo'+ _b[`2']*`Zlo' +_b[`3']*`Wlo'+_b[`6']*`Zlo'*`Wlo'+ _b[_cons] if `touse'==1
	quietly gen `fithilo' =`1'*`bxzhiwlo'+ _b[`2']*`Zhi' +_b[`3']*`Wlo'+_b[`6']*`Zhi'*`Wlo'+ _b[_cons] if `touse'==1
	quietly gen `fitlohi' =`1'*`bxzlowhi'+ _b[`2']*`Zlo' +_b[`3']*`Whi'+_b[`6']*`Zlo'*`Whi'+ _b[_cons] if `touse'==1
	quietly gen `fitmhi' =`1'*`bxzmwhi' +_b[`3']*`Whi' + _b[_cons] if `touse'==1
	quietly gen `fitmlo' =`1'*`bxzmwlo'+_b[`3']*`Wlo' + _b[_cons] if `touse'==1
	quietly gen `fithim' =`1'*`bxzhiwm'+ _b[`2']*`Zhi' + _b[_cons] if `touse'==1
	quietly gen `fitlom' =`1'*`bxzlowm'+ _b[`2']*`Zlo' + _b[_cons] if `touse'==1
	quietly gen `fitmm' =`1'*_b[`1']+ _b[_cons] if `touse'==1
	
	
	label var `fithihi' "`2'+`sd'sd,`3' +`sd'sd"
	label var `fitlolo' "`2'-`sd'sd,`3' -`sd'sd"
	label var `fithilo' "`2'+`sd'sd,`3' -`sd'sd"
	label var `fitlohi' "`2'-`sd'sd,`3' +`sd'sd"
	label var `fitmhi' "`2'mean,`3' +`sd'sd"
	label var `fitmlo' "`2'mean,`3' -`sd'sd"
	label var `fithim' "`2' +`sd'sd,`3' mean"
	label var `fitlom' "`2' -`sd'sd,`3' mean"
	label var `fitmm' "`2' mean,`3' mean"
	
}

}

*quadratic (y=b1x+b2x-squared+b0)
if `way'==2 {
local rx=rownumb(`M',"`1'")
local cx=colnumb(`M',"`1'")
local sxx=el(matrix(`M'),`rx',`cx')  //variance of bx
local rxx=rownumb(`M',"`2'")
local cxx=colnumb(`M',"`2'")
local sxxx=el(matrix(`M'),`rx',`cxx')  //covariance of bxbxx
local sxxxx=el(matrix(`M'),`rxx',`cxx')  //variance of bxx
// calculate conditional values
quietly summarize `1' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
local Xhi=`s'*`sd'
local Xlo=-`s'*`sd'

// calculate standard errors for simple slopes
local Sxxhi=sqrt((`sxx')+(4*`Xhi'*`sxxx')+(4*(`Xhi'*`Xhi')*`sxxxx'))
local Sxxlo=sqrt((`sxx')+(4*`Xlo'*`sxxx')+(4*(`Xlo'*`Xlo')*`sxxxx'))
local Sxxm=sqrt((`sxx'))
// calculate simple slopes
local bxxhi=_b[`1']+(2*_b[`2']*`Xhi')
local bxxlo=_b[`1']+(2*_b[`2']*`Xlo')
local bxxm=_b[`1']
// calculate t-test
local thi=`bxxhi'/`Sxxhi'
local tm=`bxxm'/`Sxxm'
local tlo=`bxxlo'/`Sxxlo'
//calculate p-value
local thp=2*(ttail(e(df_r),abs(`thi')))
local tmp=2*(ttail(e(df_r),abs(`tm')))
local tlp=2*(ttail(e(df_r),abs(`tlo')))



// calculate the minimum/maximum of curve
local minmax= -_b[`1']/(2*_b[`2'])

//display table
di
di
di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `1'  +/- `sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`1'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bxxhi' "{col 28}" %9.0g `Sxxhi' "{col 42}" %5.2f `thi' "{col 49}" %6.3f `thp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bxxm' "{col 28}" %9.0g `Sxxm' "{col 42}" %5.2f `tm' "{col 49}" %6.3f `tmp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bxxlo' "{col 28}" %9.0g `Sxxlo' "{col 42}" %5.2f `tlo' "{col 49}" %6.3f `tlp'
di "{txt}{hline 12}{c BT}{hline 53}"
display " The minimum/maximum of the curve: `1' = `minmax'"
di as text "{hline 66}"

// default graph
if "`graph'"=="graph" {
tempvar fit
quietly gen `fit' =(`1'*_b[`1'])+(_b[`2']*(`1'*`1'))+ _b[_cons] if `touse'==1

label var `fit' "Fitted Line"

local ytitle `e(depvar)'
local xtitle `1'
scatter  `e(depvar)' `fit'  `1' if `touse'==1, c(. l ) m(o i ) sort ytitle("`ytitle'") xtitle("`xtitle'")
}

//user-defined graph option
if "`go'" !="" {
tempvar fit
quietly gen `fit' =(`1'*_b[`1'])+(_b[`2']*(`1'*`1'))+ _b[_cons] if `touse'==1

label var `fit' "Fitted Line"

local ytitle `e(depvar)'
local xtitle `1'
scatter  `e(depvar)' `fit'  `1' if `touse'==1,`go'
}
// calculate fits for fit option
if "`fits'" =="fits" {
	tempvar fit
	local fit: permname fit
	quietly gen `fit' =(`1'*_b[`1'])+(_b[`2']*(`1'*`1'))+ _b[_cons]  if `touse'==1
	label var `fit' "`1'+`1'squared"
	
}
}
*2-way + quadratic, i.e., y= b1x + b2z + b3x^2 + b4xz +b0
if `way'==4 {
// determine if slope of x conditional upon x and z; or slope of z conditional upon x is requested (i.e., is the b3 term the quadratic of b1). 
tempvar quad rho
// create a new variable by squaring the first term
gen `quad'=`1'*`1' if `touse'==1
//correlate new variable with the quadratic term in model
quietly corr `3' `quad' if `touse'==1
// obtain correlation coefficient
gen `rho'= r(rho)
// if new variable and quadratic term r=1.0 then third term is the quadratic of first, give slope of x conditional upon x and z
if `rho'== 1{

*simple slopes for the x term in y= b1x +  b2z + b3x^2 + b4xz +b0

local rx=rownumb(`M',"`1'")
local cx=colnumb(`M',"`1'")
local sxx=el(matrix(`M'),`rx',`cx') // variance of bx 
local rz=rownumb(`M',"`2'")
local cz=colnumb(`M',"`2'")
local szz=el(matrix(`M'),`rz',`cz') // variance of bz
local rxx=rownumb(`M',"`3'")
local cxx=colnumb(`M',"`3'")
local sxz=el(matrix(`M'),`rx',`cz') // covariance bxbz
local sxxx=el(matrix(`M'),`rx',`cxx') // covariance bxbx^2
local sxxxx=el(matrix(`M'),`rxx',`cxx')  // variance bx^2

local rxz=rownumb(`M',"`4'")
local cxz=colnumb(`M',"`4'")
local sxzxz=el(matrix(`M'),`rxz',`cxz') // variance bxz
local sxxz=el(matrix(`M'),`rx',`cxz') // covariance bxbxz
local szxz=el(matrix(`M'),`rz',`cxz') // covariance bzbxz
local sxxxz=el(matrix(`M'),`rxx',`cxz') // covariance bx^2bxz

// calculate conditional values
quietly summarize `1' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
local Xhi=`s'*`sd'
local Xlo=-`s'*`sd'
quietly summarize `2' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
local Zhi=`s'*`sd'
local Zlo=-`s'*`sd'

// calculate standard errors
local Sxxhizhi=sqrt((`sxx')+(4*`Xhi'*`Xhi'*`sxxxx')+(`Zhi'*`Zhi'*`sxzxz')+(4*`Xhi'*`sxxx')+(2*`Zhi'*`sxxz')+(4*`Xhi'*`Zhi'*`sxxxz'))
local Sxxmzhi=sqrt((`sxx')+(`Zhi'*`Zhi'*`sxzxz')+(2*`Zhi'*`sxxz'))
local Sxxlozhi=sqrt((`sxx')+(4*`Xlo'*`Xlo'*`sxxxx')+(`Zhi'*`Zhi'*`sxzxz')+(4*`Xlo'*`sxxx')+(2*`Zhi'*`sxxz')+(4*`Xlo'*`Zhi'*`sxxxz'))

local Sxxhizlo=sqrt((`sxx')+(4*`Xhi'*`Xhi'*`sxxxx')+(`Zlo'*`Zlo'*`sxzxz')+(4*`Xhi'*`sxxx')+(2*`Zlo'*`sxxz')+(4*`Xhi'*`Zlo'*`sxxxz'))
local Sxxmzlo=sqrt((`sxx')+(`Zlo'*`Zlo'*`sxzxz')+(2*`Zlo'*`sxxz'))
local Sxxlozlo=sqrt((`sxx')+(4*`Xlo'*`Xlo'*`sxxxx')+(`Zlo'*`Zlo'*`sxzxz')+(4*`Xlo'*`sxxx')+(2*`Zlo'*`sxxz')+(4*`Xlo'*`Zlo'*`sxxxz'))


local Sxxhizm=sqrt((`sxx')+(4*`Xhi'*`Xhi'*`sxxxx')+(4*`Xhi'*`sxxx'))
local Sxxmzm=sqrt((`sxx'))
local Sxxlozm=sqrt((`sxx')+(4*`Xlo'*`Xlo'*`sxxxx')+(4*`Xlo'*`sxxx'))

//calculate simple slopes
local bxxhizhi=_b[`1']+(2*_b[`3']*`Xhi')+(_b[`4']*`Zhi')
local bxxmzhi=_b[`1']+(_b[`4']*`Zhi')
local bxxlozhi=_b[`1']+(2*_b[`3']*`Xlo')+(_b[`4']*`Zhi')

local bxxhizlo=_b[`1']+(2*_b[`3']*`Xhi')+(_b[`4']*`Zlo')
local bxxmzlo=_b[`1']+(_b[`4']*`Zlo')
local bxxlozlo=_b[`1']+(2*_b[`3']*`Xlo')+(_b[`4']*`Zlo')


local bxxhizm=_b[`1']+(2*_b[`3']*`Xhi')
local bxxlozm=_b[`1']+(2*_b[`3']*`Xlo')
local bxxmzm=_b[`1']


//calculate t-test
local thihi=`bxxhizhi'/`Sxxhizhi'
local tmhi = `bxxmzhi'/`Sxxmzhi'
local tlohi = `bxxlozhi'/`Sxxlozhi'

local thim = `bxxhizm'/`Sxxhizm'
local tmm = `bxxmzm'/`Sxxmzm'
local tlom = `bxxlozm'/`Sxxlozm'

local thilo = `bxxhizlo'/`Sxxhizlo'
local tmlo = `bxxmzlo'/`Sxxmzlo'
local tlolo = `bxxlozlo'/`Sxxlozlo'



//calculate p-value
local thhp=2*(ttail(e(df_r),abs(`thihi')))
local tmhp=2*(ttail(e(df_r),abs(`tmhi')))
local tlhp=2*(ttail(e(df_r),abs(`tlohi')))

local thmp=2*(ttail(e(df_r),abs(`thim')))
local tmmp=2*(ttail(e(df_r),abs(`tmm')))
local tlmp=2*(ttail(e(df_r),abs(`tlom')))

local thlp=2*(ttail(e(df_r),abs(`thilo')))
local tmlp=2*(ttail(e(df_r),abs(`tmlo')))
local tllp=2*(ttail(e(df_r),abs(`tlolo')))

//calculate minimum/maximum of the curves conditional upon z

local minmaxzhi= (-1*(_b[`1']+_b[`4']*`Zhi'))/(2*_b[`3'])
local minmaxzmean= (-1*(_b[`1']))/(2*_b[`3'])
local minmaxzlo= (-1*(_b[`1']+_b[`4']*`Zlo'))/(2*_b[`3'])

//display table
di
di
di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `2' + `sd'sd,  `1' +/- `sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`1'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bxxhizhi' "{col 28}" %9.0g `Sxxhizhi' "{col 42}" %5.2f `thihi' "{col 49}" %6.3f `thhp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bxxmzhi' "{col 28}" %9.0g `Sxxmzhi' "{col 42}" %5.2f `tmhi' "{col 49}" %6.3f `tmhp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bxxlozhi' "{col 28}" %9.0g `Sxxlozhi' "{col 42}" %5.2f `tlohi' "{col 49}" %6.3f `tlhp'
di "{txt}{hline 12}{c BT}{hline 53}"
display " The minimum/maximum of the curve: `1' = " as result %6.3f  `minmaxzhi' as text " (`2' +`sd'sd) "
display in text "{hline 66}"

di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `2' mean,  `1' +/- `sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`1'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bxxhizm' "{col 28}" %9.0g `Sxxhizm' "{col 42}" %5.2f `thim' "{col 49}" %6.3f `thmp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bxxmzm' "{col 28}" %9.0g `Sxxmzm' "{col 42}" %5.2f `tmm' "{col 49}" %6.3f `tmmp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bxxlozm' "{col 28}" %9.0g `Sxxlozm' "{col 42}" %5.2f `tlom' "{col 49}" %6.3f `tlmp'
di "{txt}{hline 12}{c BT}{hline 53}"
display " The minimum/maximum of the curve: `1' = " as result %6.3f  `minmaxzmean' as text " (`2' mean) "
display in text "{hline 66}"

di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `2' - `sd'sd,  `1' +/- `sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`1'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bxxhizlo' "{col 28}" %9.0g `Sxxhizlo' "{col 42}" %5.2f `thilo' "{col 49}" %6.3f `thlp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bxxmzlo' "{col 28}" %9.0g `Sxxmzlo' "{col 42}" %5.2f `tmlo' "{col 49}" %6.3f `tmlp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bxxlozlo' "{col 28}" %9.0g `Sxxlozlo' "{col 42}" %5.2f `tlolo' "{col 49}" %6.3f `tllp'
di "{txt}{hline 12}{c BT}{hline 53}"
display " The minimum/maximum of the curve: `1' = " as result %6.3f  `minmaxzlo' as text " (`2' -`sd'sd)"
display in text "{hline 66}"
di


//default graph option

if "`graph'"=="graph" {
tempvar fitzhi fitzlo fitzmean
quietly gen `fitzhi' =(`1'*_b[`1'])+(`Zhi'*_b[`2'])+(_b[`3']*`1'*`1')+(_b[`4']*`1'*`Zhi')+ _b[_cons]
quietly gen `fitzlo' =(`1'*_b[`1'])+(`Zlo'*_b[`2'])+(_b[`3']*`1'*`1')+(_b[`4']*`1'*`Zlo')+ _b[_cons]
quietly gen `fitzmean' =(`1'*_b[`1'])+(_b[`3']*`1'*`1')+ _b[_cons]

label var `fitzhi' "`2' +`sd'sd "
label var `fitzlo' "`2' -`sd'sd "
label var `fitzmean' "`2' mean "


local ytitle `e(depvar)'
local xtitle `1'
scatter  `e(depvar)' `fitzhi' `fitzmean' `fitzlo'  `1' if `touse'==1, c(. l l l) m(o i i i) sort ytitle("`ytitle'") xtitle("`xtitle'")
}
//user-defined graph options
if "`go'" != "" {
tempvar fitzhi fitzlo fitzmean
quietly gen `fitzhi' =(`1'*_b[`1'])+(`Zhi'*_b[`2'])+(_b[`3']*`1'*`1')+(_b[`4']*`1'*`Zhi')+ _b[_cons]
quietly gen `fitzlo' =(`1'*_b[`1'])+(`Zlo'*_b[`2'])+(_b[`3']*`1'*`1')+(_b[`4']*`1'*`Zlo')+ _b[_cons]
quietly gen `fitzmean' =(`1'*_b[`1'])+(_b[`3']*`1'*`1')+ _b[_cons]

label var `fitzhi' "`2' +`sd'sd "
label var `fitzlo' "`2' -`sd'sd "
label var `fitzmean' "`2' mean "


local ytitle `e(depvar)'
local xtitle `1'
scatter  `e(depvar)' `fitzhi' `fitzmean' `fitzlo'  `1' if `touse'==1, `go'
}
//calculate fits for the fit option
if "`fits'" =="fits" {
	tempvar fitzhi fitzlo fitzmean
	local fitzhi: permname fitzhi
	local fitzmean: permname fitzmean
	local fitzlo: permname fitzlo
	quietly gen `fitzhi' =(`1'*_b[`1'])+(`Zhi'*_b[`2'])+(_b[`3']*`1'*`1')+(_b[`4']*`1'*`Zhi')+ _b[_cons]
	quietly gen `fitzlo' =(`1'*_b[`1'])+(`Zlo'*_b[`2'])+(_b[`3']*`1'*`1')+(_b[`4']*`1'*`Zlo')+ _b[_cons]
	quietly gen `fitzmean' =(`1'*_b[`1'])+(_b[`3']*`1'*`1')+ _b[_cons]
	label var `fitzhi' "`2'+`sd'sd"
	label var `fitzmean' "`2' mean"
	label var `fitzlo' "`2'-`sd'sd"
}
}
// if the b3 term is not the quadratic of the b1 term then cacluate simple slopes for the linear interaction
if `rho'!=1 {
*//simple slopes for the z term in y= b1z + b2x +b3x^2+b4xz +b0

local rz=rownumb(`M',"`1'")
local cz=colnumb(`M',"`1'")
local szz=el(matrix(`M'),`rz',`cz') // variance of bz
local rx=rownumb(`M',"`2'")
local cx=colnumb(`M',"`2'")
local sxx=el(matrix(`M'),`rx',`cx') // variance of bx
local rxx=rownumb(`M',"`3'")
local cxx=colnumb(`M',"`3'")
local sxz=el(matrix(`M'),`rx',`cz') // covariance bxbz
local sxxx=el(matrix(`M'),`rx',`cxx') // covariance bxbx^2
local sxxxx=el(matrix(`M'),`rxx',`cxx')  // variance bx^2

local rxz=rownumb(`M',"`4'")
local cxz=colnumb(`M',"`4'")
local sxzxz=el(matrix(`M'),`rxz',`cxz') // variance bxz
local sxxz=el(matrix(`M'),`rx',`cxz') // covariance bxbxz
local szxz=el(matrix(`M'),`rz',`cxz') // covariance bzbxz
local sxxxz=el(matrix(`M'),`rxx',`cxz') // covariance bx^2bxz

//calculate conditional values
quietly summarize `1' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
local Zhi=`s'*`sd'
local Zlo=-`s'*`sd'
quietly summarize `2' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
local Xhi=`s'*`sd'
local Xlo=-`s'*`sd'
//calculate standard errors
local Szxhi=sqrt((`szz')+(2*`Xhi'*`szxz')+(`Xhi'*`Xhi'*`sxzxz'))
local Szxm=sqrt((`szz'))
local Szxlo=sqrt((`szz')+(2*`Xlo'*`szxz')+(`Xlo'*`Xlo'*`sxzxz'))
//calculate simple slopes
local bzxhi=_b[`1']+(_b[`4']*`Xhi')
local bzxm=_b[`1']
local bzxlo=_b[`1']+(_b[`4']*`Xlo')

//calculate t-test
local thi=`bzxhi'/`Szxhi'
local tm = `bzxm'/`Szxm'
local tlo = `bzxlo'/`Szxlo'

//calculate p-value
local thp=2*(ttail(e(df_r),abs(`thi')))
local tmp=2*(ttail(e(df_r),abs(`tm')))
local tlp=2*(ttail(e(df_r),abs(`tlo')))

//display table
di
di
di "{txt}{hline 66}"
display in text "	Simple slope of `e(depvar)' on `1' at `2' +/- `sd'sd "
di "{txt}{hline 12}{c TT}{hline 53}"
di as text "{ralign 11:`2'} {c |} {ralign 10: Coef.}{ralign 13: Std. Err.}{ralign 7: t}{ralign 10: P>|t|}"
di "{hline 12}{c +}{hline 53}"
di "{txt}{ralign 11: High} {c |}" as result %9.0g "{col 16}" %9.0g `bzxhi' "{col 28}" %9.0g `Szxhi' "{col 42}" %5.2f `thi' "{col 49}" %6.3f `thp'  
di "{txt}{ralign 11: Mean} {c |}" as result %9.0g "{col 16}" %9.0g `bzxm' "{col 28}" %9.0g `Szxm' "{col 42}" %5.2f `tm' "{col 49}" %6.3f `tmp'
di "{txt}{ralign 11: Low} {c |}" as result %9.0g "{col 16}" %9.0g `bzxlo' "{col 28}" %9.0g `Szxlo' "{col 42}" %5.2f `tlo' "{col 49}" %6.3f `tlp'
di "{txt}{hline 12}{c BT}{hline 53}"


// default graph option
if "`graph'"=="graph" {
tempvar fitxhi fitxlo fitxmean
quietly gen `fitxhi' =`1'*`bzxhi'+ `Xhi'*_b[`2']+`Xhi'*`Xhi'*_b[`3']+_b[_cons]
quietly gen `fitxlo' =`1'*`bzxlo'+ `Xlo'*_b[`2']+`Xlo'*`Xlo'*_b[`3']+ _b[_cons]
quietly gen `fitxmean' =`1'*_b[`1']+ _b[_cons]
label var `fitxhi' "`2'+`sd'sd"
label var `fitxlo' "`2'-`sd'sd"
label var `fitxmean' "`2' mean"
local ytitle `e(depvar)'
local xtitle `1'
scatter  `e(depvar)' `fitxhi' `fitxmean' `fitxlo' `1' if `touse'==1, c(. l l l) m(o i i i) sort ytitle("`ytitle'") xtitle("`xtitle'") jitter(5)
}
//user-defined graph options
if "`go'" != "" {
tempvar fitxhi fitxlo fitxmean
quietly gen `fitxhi' =`1'*`bzxhi'+ `Xhi'*_b[`2']+`Xhi'*`Xhi'*_b[`3']+_b[_cons]
quietly gen `fitxlo' =`1'*`bzxlo'+ `Xlo'*_b[`2']+`Xlo'*`Xlo'*_b[`3']+ _b[_cons]
quietly gen `fitxmean' =`1'*_b[`1']+ _b[_cons]
label var `fitxhi' "`2'+`sd'sd"
label var `fitxlo' "`2'-`sd'sd"
label var `fitxmean' "`2' mean"
local ytitle `e(depvar)'
local xtitle `1'
scatter  `e(depvar)' `fitxhi' `fitxmean' `fitxlo' `1' if `touse'==1, `go'
}
//calculate fits for fit option
if "`fits'" =="fits" {
	tempvar fitxhi fitxmean fitxlo
	
	local fitxhi: permname fitxhi
	local fitxmean: permname fitxmean
	local fitxlo: permname fitxlo
	
	quietly gen `fitxhi' =`1'*`bzxhi'+ `Xhi'*_b[`2']+`Xhi'*`Xhi'*_b[`3']+_b[_cons]
	quietly gen `fitxlo' =`1'*`bzxlo'+ `Xlo'*_b[`2']+`Xlo'*`Xlo'*_b[`3']+ _b[_cons]
	quietly gen `fitxmean' =`1'*_b[`1']+ _b[_cons]
	label var `fitxhi' "`2'+`sd'sd"
	label var `fitxlo' "`2'-`sd'sd"
	label var `fitxmean' "`2' mean"
}
}
}
end
