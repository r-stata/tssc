program pairdata
version 8.0
syntax varlist(min=1 max=15000) [if], INDividual(varname numeric) FAMily(varname numeric) [CONstant(varlist min=1)]

preserve
if "`if'"~="" {
quietly keep `if'
}
local UniqueID `individual'
local FamilyID `family'
tempvar dup1
quietly duplicates tag `FamilyID' `UniqueID', generate(`dup1')

local g : list posof "famcount" in varlist
local h : list posof "nsibpair" in varlist
local i : list posof "famcount" in constant
local j : list posof "nsibpair" in constant
local k : list posof `"`UniqueID'"' in varlist
local l : list posof `"`FamilyID'"' in varlist
local m : list posof `"`UniqueID'"' in constant
local n : list posof `"`FamilyID'"' in constant

if `k'>0 | `l'>0 {
display as error "IndividualID and FamilyID must not be in varlist."
exit 
}
else if `m'>0 | `n'>0 {
display as error "IndividualID and FamilyID must not be in 'Constant' list."
exit 
}
else if "`UniqueID'"=="`FamilyID'"{
display as error "Individual ID and FamilyID must be different."
exit 
}
else{
quietly count if `dup1' > 0
}
if r(N)>0 {
display as error "IndividualID is not unique within FamilyID, please remove duplicate IndividualID's."
exit 
} 
else if `i'>0 | `g'>0 {
display as error "This program generates a variable called 'famcount', please rename your 'famcount' variable."
exit 
}
else if `j'>0 | `h'>0{
display as error "This program generates a variable called 'nsibpair', please rename your 'nsibpair' variable."
exit 
}
else {
qui count if missing(`FamilyID')
}
if r(N)>0 {
display as error  "WARNING: FamilyID has missing values"
}
else {

quietly destring `FamilyID' `UniqueID', replace
order `FamilyID' `UniqueID'

keep  `UniqueID' `FamilyID' `varlist' `constant'
sort `FamilyID' `UniqueID'
tempvar withinfamID
quietly egen `withinfamID'=rank(`UniqueID'), track by(`FamilyID')
order `FamilyID' `UniqueID' `withinfamID'

tempfile temp
quietly save  "`temp'", replace

foreach var of varlist `UniqueID' `withinfamID' `varlist'{
rename `var' `var'_1
}


bysort `FamilyID' : gen famcount = _N

tempfile master

quietly save "`master'", replace

use "`temp'", clear

foreach var of varlist `UniqueID' `withinfamID' `varlist'{
rename `var' `var'_2
}

tempfile using 

quietly save "`using'", replace

use "`master'", clear

quietly joinby `FamilyID' using "`using'"
 
quietly drop if `UniqueID'_1==`UniqueID'_2

bysort `FamilyID': gen nsibpair=_N
aorder
tempvar doub
quietly gen `doub'=.
quietly replace `doub'=1 if `UniqueID'_1>`UniqueID'_2
quietly replace `doub'=2 if `UniqueID'_2>`UniqueID'_1

tempvar stringwfamid1
tempvar stringwfamid2
tempvar tempuniquepairid1
tempvar tempuniquepairid2

quietly gen `stringwfamid1'=string(`withinfamID'_1)
quietly gen `stringwfamid2'=string(`withinfamID'_2)
quietly gen `tempuniquepairid1'=`stringwfamid1' + `stringwfamid2' if `doub'==1
quietly gen `tempuniquepairid2'=`stringwfamid2' + `stringwfamid1' if `doub'==2
quietly  destring `tempuniquepairid1', replace
quietly  destring `tempuniquepairid2', replace
tempvar Uniquepairid
quietly gen `Uniquepairid'=`tempuniquepairid1'
quietly replace `Uniquepairid'=`tempuniquepairid2' if `Uniquepairid'==.

order `FamilyID' famcount nsibpair `constant' `UniqueID'_1 `UniqueID'_2 `Uniquepairid'
tempfile tempfinal
quietly save `tempfinal'
quietly drop `stringwfamid1' `stringwfamid2' `tempuniquepairid1' `tempuniquepairid2' `doub' `withinfamID'*  `Uniquepairid'
quietly save double, replace

use `tempfinal', clear
sort `FamilyID' `Uniquepairid'
quietly by `FamilyID' `Uniquepairid': sample 1, count
quietly drop `stringwfamid1' `stringwfamid2' `tempuniquepairid1' `tempuniquepairid2' `doub' `withinfamID'* `Uniquepairid'
quietly replace nsibpair=nsibpair/2
quietly save singlerand, replace

use `tempfinal', clear
quietly drop if `UniqueID'_1>`UniqueID'_2
quietly replace nsibpair=nsibpair/2
quietly drop `stringwfamid1' `stringwfamid2' `tempuniquepairid1' `tempuniquepairid2' `doub' `withinfamID'*  `Uniquepairid'
quietly save single, replace
}
end

