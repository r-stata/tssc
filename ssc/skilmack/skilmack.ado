*! Skillings-Mack Statistic 
*! Basic syntax		 : skilmack score, i(id) repeated(group)
*! Date                  : 24 Feb 2009
*! Version               : 1.3 - Passed on 24 Feb 2009 to replace v1.0 on Boston website - added "cap" before "return matrix wsumse = finalcol"  
*! History               : 1.2 - Stata Journal removed minimum abbreviations from repeated() and reps() options. 
*! History               : 1.1 - now returns matrix with wsumse 'effect sizes'; also cautionary note now for if p(no ties)<0.02, p may be conservative.) 
*! History               : 1.0 - passed on 20 Feb 2007 to Boston website
*! Authors               : Mark Chatfield & Adrian Mander


program define skilmack, rclass
preserve
version 9.0
syntax varname [if] [in], Id(varname) repeated(varname) [Covariance reps(integer 1000) Seed(integer -1) Forcesims(string) Notable(string) ]


cap matrix drop iiinvsigma0 
cap matrix drop actualA
cap matrix drop fortable
cap matrix drop finalcol 


qui {


if ~("`if'"=="" & "`in'"=="") keep `if' `in'
keep `varlist' `id' `repeated'
drop if `varlist'==.


n isid `id' `repeated'


tempvar kvars r avrank wsumcrank observed 


duplicates report `id' `varlist'
local ties = (`r(unique_value)' ~= `r(N)')
local combs = `r(unique_value)'
duplicates report `id'
local tieinfo: di "{res}`r(N)' {txt}rows of [`id', `varlist']; {res}`combs' {txt}different combinations;  n(`id') = {res}`r(unique_value)'"



capture confirm string v `repeated'
if _rc==0 encode `repeated', gen(`kvars') l(lbl)
else {
  local lbl : value label `repeated'
  gsort `repeated', gen(`kvars')
}



/* for nice appearance of table of output */
levelsof `repeated', local(levels)
global kvarslabcommand "label define kvarslab "
local maxlen 5
if length("`repeated'")>`maxlen' local maxlen =length("`repeated'")


local onetok 1
foreach l of local levels {
  if "`lbl'"=="" local item `l'
  else   local item: label `lbl' `l' 
  if length("`item'") >`maxlen' local maxlen = length("`item'")
  global kvarslabcommand `"$kvarslabcommand `onetok++' "`item'" "' 
}



summ `kvars'
local k = r(max)


bysort `id': egen `r' = rank(`varlist')
bysort `id': egen `avrank'= mean(`r')
gen `wsumcrank' = sqrt(6/`avrank')*(`r'-`avrank')
/* strictly this is not yet the sum, but just the weighted centered ranks */



/* Covariance construction */
keep `varlist' `wsumcrank' `id' `kvars'
reshape wide `varlist' `wsumcrank', i(`id') j(`kvars') 
drop `id'                      
tempname lambdas full sigma0 zerocheck m SM 
forvalues X = 1/`k' {
 gen `observed'`X' = (`varlist'`X'~=.)
}
matrix accum `lambdas' = `observed'* , nocons
matrix define `full' = diag(J(1,`k',1)*`lambdas') - `lambdas'
matrix `sigma0' = `full'[1..`k'-1, 1..`k'-1]
matrix `zerocheck' =diag(vec(`full'))
matrix fortable = `full'



/* calculate SM */
tabstat `wsumcrank'*, save  stat(sum)
matrix `m' = r(StatTotal)
matrix actualA = `m'[1, 1..`k'-1]
matrix `SM' = actualA*invsym(`sigma0')*actualA'
local S : di %8.3f `SM'[1,1]



/* Table of Output to indicate where differences lie */
if "`notable'"==""| "`notable'"=="tiescov" {
  tempname id2 
  gen `id2' = _n
  drop `varlist'* 
  reshape long  `wsumcrank', i(`id2') j(`kvars')
  drop if `wsumcrank'==.
  n smtable `repeated', wsumcrank(`wsumcrank') id(`id2') kvars(`kvars') maxlen(`maxlen') k(`k')
}


n di
n di "{txt}Skillings Mack    ={res}`S'" 
n di "{txt}P-value (No ties) = {res}" %8.4f chiprob(`k' - 1, `S')
if chiprob(`k' - 1, `S') < 0.02 n di "{p 5 5}{txt}N.B. As P-value <0.02, it is likely to be conservative (unless n large). Consider obtaining a p-value from a simulated null distribution of SM - see options." 


if diag0cnt(`zerocheck')~=0 n di as err "{p}Do not use the p-value above as there are no people with both repeats i and j (for some i and j). However, one could use the p-value from the simulated null distribution below, though this may not be ideal."


restore


if "`ties'" =="1" {
n di ""
n di "{txt}  Ties exist. Above SEs and P-value approximate, if not too many ties;"
n di "  `tieinfo'"
}


/* Can't assume SM is distributed chisquare under null hypothesis when have many ties, or when there are no people with both repeats i and j (for some i and j) */


if "`forcesims'"~="off" & ("`forcesims'"=="on" | ("`ties'" =="1"|diag0cnt(`zerocheck')~=0) ) {
  matrix iiinvsigma0 = invsym(`sigma0')
  preserve
  n _nulldist `varlist' `if' `in', id(`id') repeated(`repeated') `covariance' reps(`reps') seed(`seed') maxlen(`maxlen') notable(`notable') stat(`S') 
  return scalar p_2 = r(simp)
  if "`covariance'" ~= "" return scalar sm_2 = r(newSM)  
  restore
  matrix drop iiinvsigma0
}


return scalar p = chiprob(`k' - 1, `S')
return scalar sm = `S'
cap return matrix wsumse = finalcol
matrix drop actualA
cap matrix drop fortable
cap matrix drop finalcol
macro drop kvarslabcommand
n di


} /* End of quiet */
end




program define _nulldist, rclass
version 9.0
syntax varname [if] [in], Id(varname) repeated(varname) [Covariance reps(integer 1000) SEed(integer 1) Maxlen(numlist) Notable(string)] STat(real) 
di ""
di "{txt}  Consider using the p-value below, (which is found from a simulated"
di "        {it:conditional} null distribution of SM   - see options -" 
di "  simulating ." _continue


qui {
if ~("`if'"=="" & "`in'"=="") keep `if' `in'
keep `varlist' `id' `repeated'
drop if `varlist'==.
/* keeps missing data structure in */



/*from previous */
tempvar kvars r avrank wsumcrank 
capture confirm string v `repeated'
if _rc==0 encode `repeated', gen(`kvars') 
else gsort `repeated', gen(`kvars')
summ `kvars'
local k = r(max)
bysort `id': egen `r' = rank(`varlist')
bysort `id': egen `avrank'= mean(`r')
gen `wsumcrank' = sqrt(6/`avrank')*(`r'-`avrank')



tempfile j q orig
preserve
keep `wsumcrank' `id'
/* might as well work just with the weighted centered ranks, so don't need to rank every iteration */
sort `id' `wsumcrank'
save "`j'"
restore


keep `id' `kvars' `wsumcrank'
save "`orig'"
drop `wsumcrank'



/* Simulate and save Conditional null distribution of SM */


local time "$S_TIME"
tokenize "`time'" ,parse(":")
local initseed "`1'`3'`5'"
if "`seed'"~="-1" local initseed "`seed'"
local tenth = floor(`reps'/10)
local preps = 0
tempname mark
postfile `mark' i j A using "`q'"
sort `id' `kvars'


forvalues i=1/`reps' {
  if mod(`i',`tenth') == 0 n di "." _continue
  local seed = `initseed' +`i'
  tempvar u
  set seed `seed'
  gen `u' = uniform()
  sort `id' `u'
  /* shuffles the days randomly */
  merge `id' using "`j'"
  /* using original data will mean have same number of ties as data */
  drop _merge `u'


  /* calculate sim SMs */
  tempname A SM 
  tabstat `wsumcrank', by(`kvars') stat(sum) save
  matrix `A' =  r(Stat1)
  post `mark' (`i') (1) (`A'[1,1])
  foreach X of num 2/`k' { 
      matrix `A' = `A', r(Stat`X')
      post `mark' (`i') (`X') (`A'[1,`X'])
  }
  matrix `A' = `A'[1, 1..`k'-1]
  matrix `SM' = `A'*iiinvsigma0*`A''
  local simS = `SM'[1,1]
  if `simS' > `stat' local preps = `preps' + 1  
  drop `wsumcrank' 
}


postclose `mark'


if "`covariance'" == "" {
  local adjp: di %8.4f `preps'/`reps'
  n di ")"
  n di ""
  n di "Empirical P-value (Ties)    ~ {res}`adjp'"
  return scalar simp = `adjp'
}
else { 
  /* Estimate Cov and then calc all SMs */
  use "`q'",clear
  reshape wide A, i(i) j(j)
  tempname Cov Inv newSM m prod
  matrix accum `Cov' = A*, nocons dev
  matrix `Cov' = `Cov' / (r(N) - 1)
  cap matrix drop fortable
  matrix fortable = `Cov'
  matrix `Cov' = `Cov'[1..`k'-1, 1..`k'-1]
  matrix `Inv' = invsym(`Cov')
  matrix `newSM' = actualA*`Inv'*actualA'
  local newSM : di %8.3f `newSM'[1,1]
  local preps = 0
  drop A`k'
  forv n = 1/`reps' {
      if mod(`n',`tenth') == 0 n di "." _continue
      mkmat A* in `n' , matrix(`m')
      matrix `prod' = `m'*`Inv'*`m''
      local simS = `prod'[1,1]
      if `simS' > `newSM' local preps = `preps' + 1 
  }
  n di ")"
  use "`orig'",clear
  if "`notable'"==""| "`notable'"=="noties"  n smtable `repeated', wsumcrank(`wsumcrank') id(`id') kvars(`kvars') maxlen(`maxlen') k(`k')
  local adjp: di %8.4f `preps'/`reps' 
  n di ""
  n di "{txt}Skillings Mack    ={res}`newSM'  {txt}(using estimated covariance matrix)"
  n di "Empirical P-value (Ties)    ~ {res}`adjp'"
  return scalar simp = `adjp'
  return scalar newSM = `newSM'
}


}


end



program define smtable
syntax namelist(name = repeated), Wsumcrank(varname) Id(varname) KVars(varname) Maxlen(numlist) K(numlist)
qui {
n di
  n di "{txt}Weighted Sum of Centered Ranks"
  tempvar si sd stand N 
  bysort `id': egen `si' = count(`wsumcrank')
  count if `si'==1
  local howmany  "`r(N)'"
  keep if `si' > 1
  gen `stand' = `wsumcrank'
  gen `sd' = .
  forv X = 1/`k' {
    replace `sd' = sqrt(fortable[`X',`X']) if `kvars'==`X'
    replace `stand' = `stand' / sqrt(fortable[`X',`X']) if `kvars'==`X'
  }
  collapse (count) `N'=`wsumcrank' (sum) `wsumcrank' (mean) `sd' (sum) `stand'  , by(`kvars') 
  $kvarslabcommand
  label values `kvars' kvarslab
  n di
  n di " `repeated' {col `=`maxlen'+3'}{c |}     N  WSumCRank        SE   WSum/SE  "
  n di "{dup `maxlen':{c -}}{c -}{c -}{c +}{dup 37 :{c -}}"
  mkmat `stand', mat(finalcol) 
  forv line =1/`=_N' {
    local i1: di `kvars'[`line']
    local item: label kvarslab `i1'
    local i2: di %5.0f `N'[`line']
    local i3: di %10.2f `wsumcrank'[`line']
    local i4: di %9.2f `sd'[`line']
    local i5: di %9.2f `stand'[`line']
    n di " {txt}`item' {col `=`maxlen'+3'}{c |} {res}`i2' `i3' `i4' `i5'  "
  }
  n di "{txt}{dup `maxlen':{c -}}{c -}{c -}{c BT}{dup 37 :{c -}}"  
  n di " Total  {col `=`maxlen'+15'}  {res}0 "
  if "`howmany'" ~="0" {
    n di ""
    n di "{txt}Note N= {res}`howmany' {txt}not included as only had one observation"
  } 
}
end
