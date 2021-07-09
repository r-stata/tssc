********************************************************************************
*! "scattercub", v.16, GCerulli, 10apr2020
********************************************************************************
program scattercub , rclass
syntax varlist  [if] [in] [fweight pweight] , [m(numlist>0 integer) save_graph(string) save_data(string)]
marksample touse
********************************************************************************
preserve
********************************************************************************
keep if `touse'
********************************************************************************
if "`m'"!=""{
local G: word count `m'
tempname D
mat `D'=J(`G',1,.)
local k=1
foreach tok of local m{
mat `D'[`k',1]=`tok'
local k=`k'+1
}
}
********************************************************************************
local vars `varlist'
local S: word count `vars'
tempname A
mat `A'=J(2,`S',.)
local i=1
local k=1
foreach y of local vars{
if "`m'"!=""{
local num=`D'[`k',1]
cub `y' [`weight'`exp']  , m(`num')  pi() xi() vce(oim)
}
else if "`m'"==""{
cub `y' [`weight'`exp'] , pi() xi() vce(oim)
}
********************************************************************************
tempname a b
mat `a'=e(pi)
mat `b'=e(xi)
mat `A'[1,`i']=1-`a'
mat `A'[2,`i']=1-`b'
local i=`i'+1
local k=`k'+1
}
********************************************************************************
mat rownames `A'=Uncertainty Feeling
tempname A1
mat `A1'=`A''
svmat `A1' , names(col)
********************************************************************************
cap drop _ID
gen _ID="."
local i=1
foreach y of local vars{
replace _ID="`y'" in `i'
local i=`i'+1
}
********************************************************************************
scatter Feeling Uncertainty , mlabel(_ID) name(gr_scatt , replace) saving(`save_graph',replace)
********************************************************************************
keep _ID Feeling Uncertainty
save `save_data' , replace
drop if _ID!="." 
restore
********************************************************************************
end
********************************************************************************
