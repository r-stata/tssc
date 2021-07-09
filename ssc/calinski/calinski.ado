// Copyright 2015 Brendan Halpin brendan.halpin@ul.ie
// Distribution is permitted under the terms of the GNU General Public Licence
version 10.0

program define calinski, rclass
syntax, DISTmat(string) IDvar(varname) [NGroups(integer 15) GRaph NAME(name) *]

if ("`name'"!="") {
  local name ", name(`name')"
}

// Check dist-mat exists
qui matlist `distmat'[1,1]

// Insist on correct sort order, and that it is unique
qui des, varlist
local so `r(sortlist)'
local mainsort : word 1 of `so'
if ("`mainsort'" != "`idvar'") {
  di in red "Error: data must be sorted by same ID variable as used for defining distances"
  error 5
}
isid `idvar'

tempvar groups
tempvar i ch
qui {
gen `i' = .
gen `ch' = .
}

di as txt "{c TLC}{hline 13}{c TT}{hline 19}{c TRC}"
di as txt "{c |}  Number of  {c |} Calinski-Harabasz {c |}"
di as txt "{c |}  clusters   {c |}     pseudo-F      {c |}"
di as txt "{c LT}{hline 13}{c +}{hline 19}{c RT}"

local maxdigs 3
local maxwid 9
local maxwid2 9

forvalues x = 2/`ngroups' {
  capture drop `groups'
  cluster gen `groups' = groups(`x') `name'
  qui discrepancy `groups', id(`idvar') niter(1) distmat(`distmat')
  di as txt "{c |} " _c
  di as res "{center 11:{ralign `maxdigs':`x'}}" _c
  di as txt _col(15) "{c |} " _c
  local tmp : di %9.2f `r(pseudoF)'
  di as res "{center 18:{ralign `maxwid':`tmp'}}" _c
  di as txt _col(29) "{c |} "

  return scalar calinski_`x' = `r(pseudoF)'
  qui {
    replace `i' = `x' in `x'
    replace `ch' = `r(pseudoF)' in `x'
  }
}
di as txt "{c BLC}{hline 13}{c BT}{hline 19}{c BRC}"

if ("`graph'"!="") {
  line `ch' `i', title("Calinski-Harabasz index") ytitle("CH index") xtitle("N-Clusters")||scatter `ch' `i', legend(off) `options'
}

end
