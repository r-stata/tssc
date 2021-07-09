** GCrobust Test

capture program drop gcrobustvar
program gcrobustvar, rclass

version 14.1

syntax varlist, pos(numlist >0 max=2 max=2 integer) [nocons trimming(real 0.15) lags(numlist >0 sort) horizon(integer -1)]

qui tsset
local plottime = r(timevar)

if "`horizon'" == "-1"{
local hac = 0
local horizon = 0
}
else {
local hac = "`nw'"
}


******************************************** DISPLAY ****************************************8
di "Running the Granger Causality Robust Test..." 
di "Setting: " 
di " Variables in VAR: `varlist' "
di " Lags in VAR:`lags' "

if "`horizon'" == "0" {
di " h is `horizon' (reduced-form VAR)."
}
else {
local hprint = `horizon'+1
di " h is `horizon' (`hprint'-step-ahead VAR-LP forecasting model)."
}

di " Trimming parameter is `trimming' "

if "`cons'" == "nocons" {
di " Constant is NOT included."
}
else {
di " Constant is included."
}

if "`hac'" == "0"{
di " Assuming homoskedasticity in idiosyncratic shocks. "
}
else {
di " Assuming heteroskedasticity and serial correlation in idiosyncratic shocks. "
}



noisily: disp as text "" _newline(3)

set matsize `=_N'
quietly{

******************************************** PREPERATIONS ****************************************8
tokenize `varlist'
* get k, k refers to the number of the series*
local i = 1
while "``i''" != "" {
local ++i
}
local k = `i'-1   

* get matrix of all y
forval i =1/`k' {
mkmat ``i'', matrix(var`i')
}
local T = rowsof(var1)

* rename trimming parameter
local pistart = `trimming'

* get lags vector
if "`lags'" == "" {
mat lags_vec = (1,2)
local lags_max = 2 
local nlag = 2
}
else {
mat lags_vec = (0)
local nlag = 0
foreach p in `lags' {
mat lags_vec = lags_vec,`p'   
local lags_max = `p'
local nlag = `nlag'+1
}
mat lags_vec = lags_vec[1,2...]
}

* get position vectors
if "`pos'" == "" {
mat posY = (0)
forval i =1/`k' {
mat posY = posY, `i'
}
mat posY = posY[1,2...]
mat posX = posY
}
else {
mat pos_vec = (0)
foreach p in `pos' {
mat pos_vec = pos_vec, `p'
}
mat posY = pos_vec[1,2]
mat posX = pos_vec[1,3]
}

* get regX, including all lags and var: C+ pilag1 pilag2 pilag3 pilag4 ulag1 ulag2 ulag3 ulag4 ilag1 ilag2 ilag3 ilag4
mat regX = J(`T'-`lags_max',1,1)
forval i =1/`k' {
forval j =1/`=colsof(lags_vec)' {
local p = lags_vec[1,`j']
mat draft = var`i'
mat regX = regX, draft[`lags_max'-`p'+1..`T'-`p',1]
}
}
* get independent variable vector
if "`cons'" == "nocons" {
mat regX = regX[1...,2...]
}

* set to store values
mat stat = J(1,4,0)
mat pv = J(1,4,0)
mat colnames stat = "ExpW" "MeanW" "Nyblom" "SupLR"
mat colnames pv = "ExpW" "MeanW" "Nyblom" "SupLR"

******************************************** For each equation ****************************************
forval posYcol = 1/`=colsof(posY)' {
forval posXcol = 1/`=colsof(posX)' {
local listY = posY[1,`posYcol']
local listX = posX[1,`posXcol']

* get dependent variable vector
mat regY = var`listY'[`lags_max'+1...,1]

* adjust for horizon
mat regY = regY[`horizon'+1...,1...]
mat regX = regX[1..`=rowsof(regY)',1...]


* get listrestr and listunr based on listX: refers to the position of restricted and unrestricted regressors
mat listrestr = 0
mat listunr = 0
local numX = `k'*`nlag'
forval i = 1/`numX' {
if `i' > `nlag'*(`listX'-1) & `i' <= `nlag'*`listX' {
mat listrestr = listrestr, `i' 
}
else {
mat listunr = listunr, `i' 
}
}
mat listrestr = listrestr[1,2...]
mat listunr = listunr[1,2...]
if "`cons'" != "nocons" {
mat listrestr = listrestr + J(1,`=colsof(listrestr)',1)
mat listunr = 1, listunr + J(1,`=colsof(listunr)',1)
}

**********************************************************************
*  define variables
local T = rowsof(regX)
local ba0 = 0

mat p1plusc = regX
mat p1restr = J(`T',1,1)
forval i = 1/`=colsof(listrestr)' {
mat p1restr = p1restr,regX[1..., el(listrestr,1,`i')]
}
mat p1restr = p1restr[1...,2...]

mat p1unr = J(`T',1,1)
forval i = 1/`=colsof(listunr)' {
mat p1unr = p1unr,regX[1..., el(listunr,1,`i')]
}
mat p1unr = p1unr[1...,2...]


local T = rowsof(p1restr)
local kk = colsof(p1restr)
local restr = colsof(listrestr)
mat iden = I(rowsof(regX)+1)

***************************** Statistics ***************************************
* set initial values
local Nyb0 = 0
mat LLR7v = J(`T',1,.)
local AP0 = 0
local AP00 = 0


* loop
forval t2 = `=round(`T'*`pistart')' / `=round(`T'*(1-`pistart'))' {
    chowgmmstar3 regY p1restr p1unr p1plusc `t2' 0 `hac'
	scalar LLR7 = r(result_chowgmmstar)
	mat LLR7v[`t2',1] = LLR7
	local AP0 = `AP0' + exp(0.5*LLR7)
	local AP00 = `AP00' + LLR7
	local Nyb0 = `Nyb0' + LLR7*(`t2'/`T')*(1-`t2'/`T')
	}


local Jinv=1/(round(`T'*(1-`pistart'))-round(`T'*`pistart')+1)
svmat LLR7v
egen LLR7v_max = max(LLR7v1)

scalar SupLRopt = LLR7v_max
scalar ExpWopt=log(1/((1-`pistart')-`pistart')*`AP0'/`T')
scalar MeanWopt=(1/((1-`pistart')-`pistart'))*`AP00'/`T'



* save temporary dataset
tempfile draft
save `draft'
clear
nyblomstar3 regY p1restr p1unr p1plusc J(`kk',1,0) 0 `hac'
scalar Nyblomopt = r(result_nyblomstar)
* get dataset back
use `draft', clear	


***************************** P-values *****************************************
pvcalc Nyblomopt pvnybopt `restr'
scalar pvNyblomopt = result_pvcalc

pvcalc SupLRopt pvqlropt `restr'
scalar pvSupLRopt = result_pvcalc

pvcalc ExpWopt pvapiopt `restr'
scalar pvExpWopt = result_pvcalc

pvcalc MeanWopt pvap0opt `restr'
scalar pvMeanWopt = result_pvcalc

***************************** store result**************************************
mat result_GCrobust = (ExpWopt,MeanWopt,Nyblomopt,SupLRopt \ pvExpWopt,pvMeanWopt,pvNyblomopt,pvSupLRopt)
mat colnames result_GCrobust = "ExpW" "MeanW" "Nyblom" "SupLR"
mat rownames result_GCrobust = "statistics(``listY'':``listX'')" "p-value(``listY'':``listX'')"
* add to return result
mat stat = stat \ result_GCrobust[1,1...]
mat pv = pv \ result_GCrobust[2,1...]

***************************** display result**************************************
noisily: disp as text "Results of Granger Causality Robust Test: Lags of ``listX'' Granger cause ``listY'' "
noisily: disp as text "ExpW*,MeanW*,Nyblom*,QLR* -- and their p-values below"
noisily: mat l result_GCrobust, noheader
noisily: disp as text "" _newline(3)
}
}

***************************** plot statLR **************************************
scalar ind = `restr'+2
scalar cv5 = pvqlropt[29,ind]
scalar cv10 = pvqlropt[24,ind]
mat plotcv5 = J(_N,1,1)*cv5
mat plotcv10 = J(_N,1,1)*cv10
svmat plotcv5
svmat plotcv10
local Tstart = round(_N*`pistart')
local Tend = round(_N*(1-`pistart'))

line plotcv51 plotcv101 LLR7v1 `plottime' in `Tstart'/`Tend', legend(label(1 5% Critical value) label(2 10% Critical value) label(3 Wald statistics)) lpattern(dash dot solid) color(red dkorange blue) 

* title(Wald statistics across time) 

drop plotcv51 plotcv101
drop LLR7v1 LLR7v_max

***************************** return result**************************************

mat stat = stat[2...,1...]
mat pv = pv[2...,1...]
return matrix result_stat = stat
return matrix result_pv = pv
return matrix result_wald = LLR7v


return local cmd "gcrobustvar"
return local cmdline `"`0'"'
return local depvar "`varlist'"
return local lags "`lags'"



}



end
