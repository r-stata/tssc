// Copyright Brendan Halpin 2016 brendan.halpin@ul.ie
// Distribution is permitted under the terms of the GNU General Public Licence
// Apr  1 2016
// Calculate and plot silhouette width for a cluster solution and its pairwise distance matrix

version 10.0

program define silhouette
syntax varlist(min=1 max=1) , DISTmat(string) IDvar(varname) [SILH(string) *]
tempname gv groupsize gm so distmat2
gen `so' = _n

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

//marksample touse
qui tab `varlist' /* if `touse' */, matcell(`groupsize')

/* mkmat `touse', matrix(`touse') */
/* mata: `touse'=st_matrix("`touse'") */

//qui putmata `gv'=(`varlist'), replace

mkmat `varlist' /* if `touse' */, matrix(`gv')
mata: `gv'=st_matrix("`gv'")
mata: `distmat2' = st_matrix("`distmat'")
/* mata: `distmat2' = select(select(`distmat2', `touse'), `touse'') */
mata: silhgroup(`distmat2',`gv',st_matrix("`groupsize'"),"`gm'")
mata: mata drop `gv'

qui su `varlist' /* if `touse' */
local ngroups `=r(max)'
forvalues x = 1/`ngroups' {
  tempvar `gm'`x'
}

svmat `gm', names(`gm')

tempname ai bi sil idx zero

forvalues x = 1/`ngroups' {
  capture gen `ai' = .
  qui replace `ai' = `gm'`x' if `x'==`varlist'
}
forvalues x = 1/`ngroups' {
  capture gen `bi' = . // intentionally using missing as bignum
  qui replace `bi' = `gm'`x' if `gm'`x' < `bi' & `x'!=`varlist'
}

qui gen `sil' = (`bi' - `ai')/max(`ai', `bi')
label var `sil' "Silhouette"

// Save the silhouette, if requested --- prevented by marksample/preserve/restore...
if "`silh'" != "" {
//  di "saving sil-dist as `silh'"
  gen `silh' = `sil'
}

table `varlist' /* if `touse' */, c(n `sil' min `sil' mean `sil' max `sil') format(%5.2f)

gsort `varlist' -`sil'

gen `idx' = _n //+ 10*(`varlist'-1)
gen `zero' = 0
label var `sil' "Silhouette"

//local gcmd "pcspike `zero' `idx' `sil' `idx' if `varlist'==1 & `touse'"
local gcmd "pcspike `zero' `idx' `sil' `idx' if `varlist'==1"

forvalues x = 2/`ngroups' {
//  local gcmd "`gcmd' || pcspike `zero' `idx' `sil' `idx' if `varlist'==`x' & `touse'"
  local gcmd "`gcmd' || pcspike `zero' `idx' `sil' `idx' if `varlist'==`x'"
}

twoway `gcmd', legend(off) ytitle("Silhouette width") xtitle("Cases") `options'
sort `so'

end

mata:
  real matrix silhgroup(real matrix dist, real vector groupvar, real vector groupsize, string gm) {
    real scalar ngroups, i
    real vector cumulate, reorder
    real matrix distg
    ngroups  = rows(groupsize)
    cumulate = J(ngroups+1,1,0)
    
    groupmeans = J(rows(dist), 0, .)
    for (i=1; i<=ngroups; i++) {
      cumulate[i+1] = cumulate[i]+groupsize[i]
    }

    // Order the distance matrix by the grouping variable, columns only
    reorder = order(groupvar,1)
    distg = dist[.,reorder]
    
    for (i=1; i<=ngroups; i++) {
      groupmeans = groupmeans, mean(distg[.,cumulate[i]+1..cumulate[i+1]]')'
    }

    st_matrix(gm, groupmeans)
  }
end
