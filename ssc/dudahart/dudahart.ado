capture program drop dudahart
program define dudahart, rclass
syntax, DISTmat(name) IDvar(varname) [NGroups(integer 15) GRaph(string) NAME(name) *]

version 10

if ("`name'"!="") {
  local name "name(`name')"
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


mata: pwd = st_matrix("`distmat'")

tempname resmat

tempvar d1
gen `d1' = 1

tempvar index dh dht
qui {
  gen `index' = .
  gen `dh' = .
  gen `dht' = .
}

forvalues x = 2/`=1+`ngroups'' {
  tempvar d`x'
  cluster gen `d`x'' = groups(`x'), ties(fewer) `name'
}


mata: result = J(0,2,.)
forvalues soln=1/`ngroups' {
  local next = `soln'+1
  local whichsplit 0
  local new1 0
  local new2 0
  qui su `d`soln''
  forvalues x = 1/`r(max)' {
    qui su `d`next'' if `d`soln'' == `x'
    if (`r(min)'!=`r(max)') {
      local whichsplit `x'
      local new1 `r(min)'
      local new2 `r(max)'
    }
  }
  //di "`soln'/`next': `whichsplit' `new1' `new2'"

  tempvar j1 j2
  qui gen `j1' = `d`soln''==`whichsplit'
  qui gen `j2' = `d`next''==`new1'
  qui replace `j2' = 2 if `d`next''==`new2'

  qui putmata j1=`j1' j2=`j2', replace

  mata: j11 = j2 :==1
  mata: j12 = j2 :==2
  mata: SSt = sum(select(select(pwd, j1), j1'))/sum(j1)
  mata: SS1 = sum(select(select(pwd, j11), j11'))/sum(j11)
  mata: SS2 = sum(select(select(pwd, j12), j12'))/sum(j12)
  mata: dh = (SS1+SS2)/SSt
  mata: t = (1/dh - 1)*(sum(j1) - 2)
  mata: result = result\(dh, t)

}
mata: st_matrix("`resmat'",result)

local maxdigs 3
local maxwid 9
local maxwid2 9

di
di as txt "{c TLC}{hline 13}{c TT}{hline 27}{c TRC}"
di as txt "{c |}             {c |}   Duda/Hart on distances  {c |}"
di as txt "{c |}  Number of  {c |}             {c |}  pseudo     {c |}"
di as txt "{c |}  clusters   {c |} Je(2)/Je(1) {c |}  T-squared  {c |}"
di as txt "{c LT}{hline 13}{c +}{hline 13}{c +}{hline 13}{c RT}"
forvalues i = 1/`ngroups' {
  di as txt "{c |} " _c
  di as res "{center 11:{ralign `maxdigs':`i'}}" _c
  di as txt _col(15) "{c |} " _c
  local tmp : di %9.4f `resmat'[`i',1]
  local tmp `tmp'
  di as res "{center 11:{ralign `maxwid':`tmp'}}" _c
  di as txt _col(29) "{c |} " _c
  local tmp : di %9.2f `resmat'[`i',2]
  local tmp `tmp'
  di as res "{center 11:{ralign `maxwid2':`tmp'}}" _c
  di as txt _col(43) "{c |}"
  return scalar duda_`i' = `resmat'[`i',1]
  return scalar dudat2_`i' = `resmat'[`i',2]
  qui {
    replace `index' = `i' in `i'
    replace `dh' = `resmat'[`i',1] in `i'
    replace `dht' = `resmat'[`i',2] in `i'
  }

}
di as txt "{c BLC}{hline 13}{c BT}{hline 13}{c BT}{hline 13}{c BRC}"

if ("`graph'"!="") {
  if ("`graph'"=="dh") {
    line `dh' `index', title("Duda-Hart index") ytitle("DH index") xtitle("N-Clusters")||scatter `dh' `index', legend(off) `options'
  }
  else if ("`graph'"=="dht") {
    line `dht' `index', title("Duda-Hart T-squared") ytitle("DH Tsq") xtitle("N-Clusters")||scatter `dht' `index', legend(off) `options'
  }
  else {
    line `dh' `dht' `index', title("Duda-Hart index") ytitle("DH index") xtitle("N-Clusters")||scatter `dh' `dht' `index', legend(off) `options'
  }
}

end
