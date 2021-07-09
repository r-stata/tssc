*Written for Stata 8.0 by Kerry L. Papps (klp27@cornell.edu)
*28 April 2005, update suggested by Guilherme F. de Avila 26 November 2013
*This ado-file writes formatted descriptive statistics to a text file
*The syntax is:
*outsum varlist [[weight]] [if exp] [in range] using filename [, append nolabel noparen bracket nonobs nonotes replace comma quote title(textlist) ctitle(textlist) addnote(textlist)]
*The options are the same as those for outreg
program define outsum
version 9.2 
syntax varlist [aweight fweight iweight] [if] [in] using/ [, APpend NOLabel NOPAren BRacket NONOBs NONOTes replace COMma QUOte TItle(string) CTitle(string) ADDNote(string)] 
tokenize `varlist' 
foreach i in if in { 
if "``i''"=="" { 
local `i' "*" 
} 
} 
if "`quote'"=="" { 
local noquote "noquote" 
} 
if strpos("`using'",".")==0 local suffix ".out"
preserve 
quietly { 
while "`1'" ~= "" { 
keep `if' 
keep `in' 
local nobs=_N 
su `1' [`weight'`exp'] 
local mean=r(mean) 
local sd=r(sd) 
local varlabel: variable label `1' 
tempfile `1' 
clear 
set obs 2 
gen str32 varname="" 
gen str8 stats="" 
replace varname="`1'" in 1 
replace varname="`varlabel'" if "`varlabel'"~="" & varname~="" & "`nolabel'"=="" 
replace stats=string(round(`mean',0.0001)) in 1 
replace stats="("+string(round(`sd',0.0001))+")" in 2 
if "`noparen'"~="" { 
replace stats=string(round(`sd',0.0001)) in 2 
} 
if "`bracket'"~="" { 
replace stats="["+string(round(`sd',0.0001))+"]" in 2 
} 
save "``1''" 
restore, preserve 
mac shift 
} 
clear 
set obs 1 
gen str32 varname="Variable" 
gen str8 stats="(1)" 
replace stats="`ctitle'" if "`ctitle'"~="" 
tempfile stats 
tokenize `varlist' 
while "`1'" ~= "" { 
append using "``1''" 
save `stats', replace 
mac shift 
} 
if "`nonobs'"=="" { 
local N=_N+1 
set obs `N' 
replace varname="Observations" in `N' 
replace stats="`nobs'" in `N' 
} 
save `stats', replace 
if "`append'"=="" { 
if "`title'"~="" { 
clear 
set obs 1 
gen str32 varname="`title'" 
gen str8 stats="" 
append using `stats' 
} 
if "`nonotes'"=="" { 
local N=_N+1 
set obs `N' 
if "`bracket'"=="" replace varname="Standard deviations in parentheses" in `N' 
else replace varname="Standard deviations in brackets" in `N' 
} 
if "`addnote'"~="" { 
local N=_N+1 
set obs `N' 
replace varname="`addnote'" in `N' 
} 
outsheet using "`using'", `noquote' nonames `replace' `comma' 
} 
else { 
clear 
insheet using "`using'`suffix'", nonames 
rename v1 varname 
gen type=1 
replace type=2 if varname=="" 
replace varname=varname[_n-1] if varname=="" 
gen order1=_n 
local rowobs=_N 
sort varname type 
local i=0 
foreach var of varlist v* { 
local i=`i'+1 
} 
foreach j of numlist 2/`i' { 
local k=`j'-1 
local type`j': type v`j' 
local v`j'st=substr("`type`j''",1,3) 
if "`v`j'st'"~="str" { 
gen v`j'st=string(v`j') 
replace v`j'st="" if v`j'st=="." 
drop v`j' 
rename v`j'st v`j' 
} 
capture drop v`j'st 
rename v`j' stats`k' 
} 
order varname stats* 
tempfile statsold 
save `statsold' 
use `stats', clear 
rename stats stats`i' 
replace stats`i'="("+"`i'"+")" in 1 
if "`ctitle'"~="" { 
replace stats="`ctitle'" in 1 
} 
gen type=1 
replace type=2 if varname=="" 
replace varname=varname[_n-1] if varname=="" 
gen order2=_n 
sort varname type 
save `stats', replace 
use `statsold', clear 
merge varname type using `stats' 
sort order1 order2 
replace order1=`rowobs'-0.5 if order1==. & varname[`rowobs']=="Observations" 
replace order1=`rowobs'+1 if order1==. & stats1[`rowobs']~="" 
local rowobs=`rowobs'-1 
replace order1=`rowobs'-0.5 if order1==. & stats1[`rowobs']~="" 
local rowobs=`rowobs'-2 
replace order1=`rowobs'-0.5 if order1==. & stats1[`rowobs']~="" 
sort order1 order2 
replace varname="" if type==2 
drop type order1 order2 _merge 
outsheet using "`using'`suffix'", `noquote' nonames replace `comma' 
} 
} 
end
