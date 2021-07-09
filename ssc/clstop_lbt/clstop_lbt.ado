*! version 1.1.2  09-Feb-2013  Dirk Enzmann

program clstop_lbt, rclass
  version 12
  syntax anything(name=clname) [, ...]
  cluster query `clname'
  local vnames = r(o2_val)
  if !inlist("`r(method)'","kmeans","kmedians") {
    di as error "rule(lbt) only allowed with kmeans or kmedians clustering"
    exit 198
  }
  tempvar cuse
  tempname N k SSE SSB SSE_SST lbt SSE_min

  qui gen byte `cuse' = .
  markout `cuse' `vnames' `clname'
  local nvars : word count `vnames'

  qui count if `cuse'
  scalar `N' = r(N)
  scalar `SSE' = 0
  scalar `SSB' = 0
  foreach v of varlist `vnames' {
    qui anova `v' `clname' if `cuse'
    scalar `SSE' = `SSE' + e(rss)
    scalar `SSB' = `SSB' + e(mss)
  }
  scalar `k' = e(df_m)+1
  scalar `SSE_SST' = `SSE'/(`SSB'+`SSE')
  if `k' >= `nvars' {
    scalar `lbt' = `SSE_SST'
    local note = "NOTE: k >= number of variables, LBT = SSE(k)/SST; Calinski-Harabasz index is recommended"
  }
  else {
    mata: st_numscalar("`SSE_min'",trace(st_data(.,"`vnames'","`cuse'")*st_data(.,"`vnames'","`cuse'")')-sum(symeigenvalues(st_data(.,"`vnames'","`cuse'")*st_data(.,"`vnames'","`cuse'")')[1..st_numscalar("`k'")]))
    scalar `lbt' = (`SSE'-`SSE_min')/(`SSB'+`SSE')
  }
  local K = `k'
  di _n as text "Lower bound technique (Steinley & Brusco):" _n
  if `k' == 2 {
    di as res "SSE(2)/SST = " %5.4f `SSE_SST' " [LBR(normal) = 0.3634, LBR(uniform) = 0.2500]" _n
  }
  di as res "Clusters = `K', LBT = " %5.4f `lbt'
  if `k' >= `nvars' {
    di _n as text "`note'"
  }
  return scalar LBT_`K' = `lbt'
  return scalar calinski_`K' = (`SSB'/(`k'-1))/(`SSE'/(`N'-`k'))
  return scalar SSE_SST_`K' = `SSE_SST'
  return scalar SSB_`K' = `SSB'
  return scalar SSE_`K' = `SSE'
  return scalar k = `k'
  return scalar N = `N'
  return local rule "lbt"
  return local vars "`vnames'"
  return local clname "`clname'"
end
