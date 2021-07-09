*! rensheet v1.0 26 January 2008
*! program to edit variable names and labels in a spreadsheet
*! by Austin Nichols austinnichols@gmail.com
prog rensheet
version 8.2
syntax [varlist] using/ [, replace Append Label Do Run Val(varlist) Immed]
if `"`using'`immed'"'=="" {
 di as err "Must specify using filename or immed option"
 error 198
 }
if `"`using'"'=="" {
 tempfile using
 loc run="run"
 }
foreach v of local val {
 if substr("`:type `v''",1,3)=="str" {
  di as err "Variable `v' is not numeric: no value labels possible"
  loc val: list val - v
 }
}
foreach v of local val {
 loc lbl: value label `v'
 loc lbls `lbls' `lbl'
 }
qui if "`val'"!="" {
 preserve
 tempfile lvals
 uselabel `lbls', clear
 save `lvals'
 restore
 }
qui {
if "`replace'"=="" & "`append'"=="" conf new file "`using'"
preserve
tempvar o l vl
g `o'=""
g `l'=""
g `vl'=""
loc n: word count `varlist'
cap set obs `n'
loc i=1
foreach v of local varlist {
 replace `l'="`: var label `v''" in `i'
 replace `vl'="`: value label `v''" in `i'
 replace `o'="`v'" in `i++'
}
keep `o' `l' `vl'
keep if !mi(`o')
ren `o' oldname
g name=old
ren `l' oldlabel
g label=oldl
ren `vl' lname
if "`label'"=="" edit name
else edit name label
}
tempname f
file open `f' using "`using'", write `replace' `append'
cap assert oldn==name & oldl==label
if _rc!=0 {
g obs=_n
sort name
cap assert name!=name[_n-1]
if _rc {
 replace obs=_n if name==name[_n-1]
 su obs, meanonly
 di as err "Cannot use name `=name[`r(min)']' more than once"
 error 198
 }
sort obs
forv i=1/`=_N' {
 if oldn[`i']!=name[`i'] {
 file write `f' "ren `=oldn[`i']' `=name[`i']'" _n
 }
 if oldl[`i']!=label[`i'] {
 file write `f' `"la var `=name[`i']' "`=label[`i']'""' _n
 }
} 
}
file close `f'
tempfile lab
if "`val'"!="" {
 drop label oldlab
 sort lname
 merge lname using `lvals'
 drop _m
 sort lname value
 qui save `lab'
}
restore
qui if "`val'"!="" {
 foreach v of loc val {
  preserve
  keep `v'
  bys `v': g count=_N
  by `v': drop if _n>1
  g lname="`: value label `v''"
  ren `v' value
  sort lname value
  merge lname value using `lab', nokeep
  replace count=0 if mi(count)
  g `v'=value
  ren label oldlabel
  g label=oldlab
  g c=count
  edit count `v' label
  cap assert c==count
  local r= _rc
  if `r'!=0 {
   di as err "Attempt to change counts! Variable `v' skipped"
   }
  cap assert value==`v'
  local r=max(_rc,`r')
  if _rc!=0 {
   di as err "Attempt to change values! Variable `v' skipped"
   }
  cap assert oldlab==label
  if _rc!=0 & `r'==0 {
   tempname f
   file open `f' using "`using'", write append
   file write `f' "la val `=name' `=name'" _n
   forv i=1/`=_N' {
    if label[`i']!="" {
    file write `f' `"la def `=name[`i']' `=value[`i']' "`=label[`i']'", modify"' _n
    }
   } 
   file close `f'
  }
  restore
 }
}
if "`do'"!="" & "`run'"=="" do `using'
if "`run'"!="" run `using'
end
