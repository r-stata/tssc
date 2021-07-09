*! ABC Inequality indices
program abg, rclass 
version 10.0 
syntax varlist(numeric ts) [aweight fweight pweight] [if] [in] ,  Generate(string)
qui{
{
marksample touse

capture ssc install logitrank 

   gen `generate'= .
 
local revabc : word 1 of `varlist'

local lc : word count `varlist'
forvalues i = 1(1)`lc' { 
local nomy`i' : word `i' of `varlist'
   }
local control ""
forvalues i = 2/`lc' { 
local toto `nomy`i''
local control "`control' `toto'"
   }

su `revabc'  if `touse'  
replace `revabc' =`revabc' +runiform()*.000001  if `touse'  
sort  `revabc'  
tempvar toto
if "`weight'" == "" &  `touse'    gen `toto' = 1
else gen `toto' `exp'  if `touse'  
su `toto'  if `touse'  

tempname sca BB BS b

scalar `sca' = 2
su `revabc'  [w =`toto']  if `touse'  , d
tempvar yyyabc
gen `yyyabc'=ln(`revabc'/r(p50)) if `touse'  
tempvar xxxabc

logitrank  `revabc'  [w =`toto'] if `touse'  , gen(`xxxabc') 


tempvar th1 th2 th3 
gen `th1'=tanh(`xxxabc' /`sca') if `touse'  
gen `th2'=tanh(`xxxabc' /`sca')^2 if `touse'  
gen `th3'=tanh(`xxxabc' /`sca')^3 if `touse'  

tempvar zozo alpha bet gam centre

gen `zozo'=`yyyabc'/`xxxabc' if abs(`xxxabc')<4 & abs(`xxxabc')>.4  & `touse'
reg `zozo' `xxxabc'  if abs(`xxxabc')<.5 & abs(`xxxabc')>.4  & `touse'
predict `centre'
replace `zozo' = `centre' if abs(`xxxabc')<.4 & `touse'
gen `alpha'=1+runiform()*.00001-.000005 if `touse'
gen `bet' = (`th1'+`th2')/2 if `touse'
gen `gam' = (-`th1'+`th2')/2 if `touse'
reg `zozo' `bet' `gam'  `alpha'   `control'    [pw =`toto']  if `touse' , nocons  
matrix define `BB'=e(b)
matrix define `BS'=e(V)

 
   return scalar abgalpha = `BB'[1,3]
   return scalar abgbeta = `BB'[1,1]
   return scalar abggamma = `BB'[1,2]

   return scalar abgsealpha = sqrt(`BS'[3,3])
   return scalar abgsebeta = sqrt(`BS'[1,1])
   return scalar abgsegamma = sqrt(`BS'[2,2])

tempvar mv20 nv20 v20
xtile `v20'=`yyyabc' [w =`toto']  if `touse', n(20)
bysort `v20': egen `mv20'=max(`yyyabc') if `touse'
gen `nv20'=ln(`mv20')/`xxxabc'  & `touse'

 tabstat `zozo' if `yyyabc'==`mv20'  & `touse' , by(`v20') save
mat def `b'=r(Stat1)
return scalar    iso1 = `b'[1,1]
mat def `b'=r(Stat2)
return scalar    iso2 = `b'[1,1]
mat def `b'=r(Stat3)
return scalar    iso3 = `b'[1,1]
mat def `b'=r(Stat4)
return scalar    iso4 = `b'[1,1]
mat def `b'=r(Stat5)
return scalar    iso5 = `b'[1,1]
mat def `b'=r(Stat6)
return scalar    iso6 = `b'[1,1]
mat def `b'=r(Stat7)
return scalar    iso7 = `b'[1,1]
mat def `b'=r(Stat8)
return scalar    iso8 = `b'[1,1]
mat def `b'=r(Stat9)
return scalar    iso9 = `b'[1,1]
mat def `b'=r(Stat10)
return scalar    iso10 = `b'[1,1]
mat def `b'=r(Stat11)
return scalar    iso11 = `b'[1,1]
mat def `b'=r(Stat12)
return scalar    iso12 = `b'[1,1]
mat def `b'=r(Stat13)
return scalar    iso13 = `b'[1,1]
mat def `b'=r(Stat14)
return scalar    iso14 = `b'[1,1]
mat def `b'=r(Stat15)
return scalar    iso15 = `b'[1,1]
mat def `b'=r(Stat16)
return scalar    iso16 = `b'[1,1]
mat def `b'=r(Stat17)
return scalar    iso17 = `b'[1,1]
mat def `b'=r(Stat18)
return scalar    iso18 = `b'[1,1]
mat def `b'=r(Stat19)
return scalar    iso19 = `b'[1,1]

tempvar uuu1
gen `uuu1' = (`BB'[1,3] * (`xxxabc'/`sca') + `BB'[1,1] * (`bet') *(`xxxabc'/`sca') + `BB'[1,2] *(`gam') *(`xxxabc'/`sca'))/(`xxxabc'/`sca')  if `touse'    
qui tabstat `uuu1'  if `yyyabc'==`mv20' & `touse', by(`v20') save
mat def `b'=r(Stat1)
return scalar    isa1 = `b'[1,1]
mat def `b'=r(Stat2)
return scalar    isa2 = `b'[1,1]
mat def `b'=r(Stat3)
return scalar    isa3 = `b'[1,1]
mat def `b'=r(Stat4)
return scalar    isa4 = `b'[1,1]
mat def `b'=r(Stat5)
return scalar    isa5 = `b'[1,1]
mat def `b'=r(Stat6)
return scalar    isa6 = `b'[1,1]
mat def `b'=r(Stat7)
return scalar    isa7 = `b'[1,1]
mat def `b'=r(Stat8)
return scalar    isa8 = `b'[1,1]
mat def `b'=r(Stat9)
return scalar    isa9 = `b'[1,1]
mat def `b'=r(Stat10)
return scalar    isa10 = `b'[1,1]
mat def `b'=r(Stat11)
return scalar    isa11 = `b'[1,1]
mat def `b'=r(Stat12)
return scalar    isa12 = `b'[1,1]
mat def `b'=r(Stat13)
return scalar    isa13 = `b'[1,1]
mat def `b'=r(Stat14)
return scalar    isa14 = `b'[1,1]
mat def `b'=r(Stat15)
return scalar    isa15 = `b'[1,1]
mat def `b'=r(Stat16)
return scalar    isa16 = `b'[1,1]
mat def `b'=r(Stat17)
return scalar    isa17 = `b'[1,1]
mat def `b'=r(Stat18)
return scalar    isa18 = `b'[1,1]
mat def `b'=r(Stat19)
return scalar    isa19 = `b'[1,1]

replace `generate'=`zozo' if `touse'
}
}   
   end

exit
   
   