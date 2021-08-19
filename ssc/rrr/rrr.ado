//Reduced rank regression
capture program drop  rrr
program rrr
version 9

syntax varlist [if] [in], x(varlist) [Rank(integer 0) NOstd SAVEvar LOADings]
marksample touse

local n_depvars: word count `varlist' // count the number of y
local n_indvars: word count `x' // count the number of x

display  _newline(1) "*Number of response variables=`n_depvars', " "Number of predictors=`n_indvars'*"

//single y scenario
if `n_depvars'==1 {
display  _newline(2) "*Regress `varlist' on `x'*"
reg `varlist' `x' if `touse'
predict `varlist'_hat if `touse',xb
label var `varlist'_hat "Linear prediction of `varlist'"
display  _newline(2) "*Predicted value of `varlist'*"
sum `varlist'_hat if `touse'
display  _newline(2) "*Warning! RRR is a multivariate model. For single dependent variable scenario, the results are from general linear regression*"
exit
}

//standardize x and y; multivariate regression and predicted y values
if "`nostd'"=="" {
local name1
foreach i of local x {
quietly egen `i'_std=std( `i' ) if `touse'
local name1 = "`name1' `i'_std"
}
local name2
foreach j of local varlist {
quietly egen `j'_std=std( `j' ) if `touse'
display  _newline(2) "*Regress `j'_std on `name1'*"
reg `j'_std `name1' if `touse'
predict `j'_hat if `touse',xb
label var `j'_hat "Linear prediction of `j'_std"
display  _newline(2) "*Predicted value of `j'_std*"
sum `j'_hat if `touse'
local name2 = "`name2' `j'_hat"
}
}
else {
local name2
foreach j of local varlist {
display  _newline(2) "*Regress `j' on `x'*"
reg `j' `x' if `touse'
predict `j'_hat if `touse',xb
label var `j'_hat "Linear prediction of `j'"
display  _newline(2) "*Predicted value of `j'*"
sum `j'_hat if `touse'
local name2 = "`name2' `j'_hat"
}
}

//Principal component analysis with predicted values of response variables 
display  _newline(2) "*Principal component analysis of `name2'*"
if `rank'==0 { 
pca `name2' if `touse',cov
predict f1-f`n_depvars' if `touse',score
display "*Reduced Rank Regression factor scores saved as f1-f`n_depvars'*" _newline(1) // f1-f`n_depvars' uncorrelated
}
else if `rank'==1 {
pca `name2' if `touse',cov com(`rank')
predict f1 if `touse',score
display "*Reduced Rank Regression factor score saved as f1*" _newline(1) // only f1
}
else {
pca `name2' if `touse',cov com(`rank')
predict f1-f`rank' if `touse',score
display "*Reduced Rank Regression factor scores saved as f1-f`rank'*" _newline(1) // f1-f`rank' uncorrelated
}


//calculate variations of response variables explained by each Reduced Rank Regression factor
display _newline(2) "*Variations of response variables explained by each Reduced Rank Regression factor*" 
display as text "No  `varlist'  Average  Cumulative_average"
display as text "------------------------------------------------------------------------------"

if `rank'==0 { 
local cumulativey = 0
forvalues i = 1(1)`n_depvars'  {
local variationy = 0
local vy
foreach j of local varlist {
quietly reg `j' f`i'   if `touse'
local variationy = `variationy'+e(r2)
local e = round(e(r2),0.000001)
local vy = "`vy'  `e'"
}
local variationy = `variationy'/`n_depvars'
local cumulativey = `cumulativey'+`variationy'
display as text "f`i'  `vy'  " as result  `variationy' as text "  " as result  `cumulativey'
}
}
//forvalues m = 1(1)`n_depvars' {
//quietly mvreg `varlist' = f`m'  if `touse'
//local vy`m' = e(r2)
//display as text "f`m'" as result e(r2)
else if `rank'==1 {
local variationy = 0
local vy
foreach j of local varlist {
quietly reg `j' f1   if `touse'
local variationy = `variationy'+e(r2)
local e = round(e(r2),0.000001)
local vy = "`vy'  `e'"
}
local variationy = `variationy'/`n_depvars'
display as text "f1  `vy'  " as result  `variationy' as text "  " as result  `variationy'
}
else {
local cumulativey = 0
forvalues i = 1(1)`rank'  {
local variationy = 0
local vy
foreach j of local varlist {
quietly reg `j' f`i'   if `touse'
local variationy = `variationy'+e(r2)
local e = round(e(r2),0.000001)
local vy = "`vy'  `e'"
}
local variationy = `variationy'/`n_depvars'
local cumulativey = `cumulativey'+`variationy'
display as text "f`i'  `vy'  " as result  `variationy' as text "  " as result  `cumulativey'
}
}


//calculate variations of predictors explained by each Reduced Rank Regression factor
display _newline(2) "*Variations of predictors explained by each Reduced Rank Regression factor*" 
display as text "No  `x'  Average  Cumulative_average"
display as text "------------------------------------------------------------------------------"

if `rank'==0 { 
local cumulativex = 0
forvalues i = 1(1)`n_depvars'  {
local variationx = 0
local vx
foreach j of local x {
quietly reg `j' f`i'   if `touse'
local variationx = `variationx'+e(r2)
local e = round(e(r2),0.000001)
local vx = "`vx'  `e'"
}
local variationx = `variationx'/`n_indvars'
local cumulativex = `cumulativex'+`variationx'
display as text "f`i'  `vx'  " as result  `variationx' as text "  " as result  `cumulativex'
}
}
else if `rank'==1 {
local variationx = 0
local vx
foreach j of local x {
quietly reg `j' f1   if `touse'
local variationx = `variationx'+e(r2)
local e = round(e(r2),0.000001)
local vx = "`vx'  `e'"
}
local variationx = `variationx'/`n_indvars'
display as text "f1  `vx'  " as result  `variationx' as text "  " as result  `variationx'
}
else {
local cumulativex = 0
forvalues i = 1(1)`rank'  {
local variationx = 0
local vx
foreach j of local x {
quietly reg `j' f`i'   if `touse'
local variationx = `variationx'+e(r2)
local e = round(e(r2),0.000001)
local vx = "`vx'  `e'"
}
local variationx = `variationx'/`n_indvars'
local cumulativex = `cumulativex'+`variationx'
display as text "f`i'  `vx'  " as result  `variationx' as text "  " as result  `cumulativex'
}
}

//generate factor loadings
if "`loadings'" != "" {
display _newline(2) "*Factor loadings of each Reduced Rank Regression factor*" 
if `rank'==0 { 
if "`nostd'"=="" {
forvalues i = 1(1)`n_depvars'  {
quietly reg f`i' `name1'  if `touse',noc
display _newline(1) "*Factor loadings of f`i'*" 
matrix list e(b)
}
}
else {
forvalues i = 1(1)`n_depvars'  {
quietly reg f`i' `x'  if `touse',noc
display _newline(1) "*Factor loadings of f`i'*" 
matrix list e(b)
}
}
}
else if `rank'==1 {
if "`nostd'"=="" {
quietly reg f1 `name1'  if `touse',noc
display _newline(1) "*Factor loadings of f1*" 
matrix list e(b)
}
else {
quietly reg f1 `x'  if `touse',noc
display _newline(1) "*Factor loadings of f1*" 
matrix list e(b)
}
}
else {
if "`nostd'"=="" {
forvalues i = 1(1)`rank'  {
quietly reg f`i' `name1'  if `touse',noc
display _newline(1) "*Factor loadings of f`i'*" 
matrix list e(b)
}
}
else {
forvalues i = 1(1)`rank'  {
quietly reg f`i' `x'  if `touse',noc
display _newline(1) "*Factor loadings of f`i'*" 
matrix list e(b)
}
}
}
}

//drop variables
if "`savevar'" == "" {
if "`nostd'"=="" {
foreach j of local varlist {
local name1 = "`name1' `j'_std"
}
drop `name1' `name2'
}
else {
drop `name2'
}
}

end
