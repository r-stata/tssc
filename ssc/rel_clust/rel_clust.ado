*! version 1.0.2  09-Feb-2013  Dirk Enzmann

/* Calculate relative clusterability of varlist and optionally
   transform varlist to z-standardized, range-standardized, or to
   variance-to-range ratio weighted variables.

   Reference: Steinley, D. & Brusco, M. J. (2008). A new variable
      weighting and selection procedure for K-means cluster anlysis.
      Multivariate Behavioral Research, 43, 77-108. */

program rel_clust, rclass
  version 9.2
  syntax varlist [if] [in] [, TRansf(name) SUffix(name) norc replace]
  marksample touse
  if "`transf'"=="vr" local transf = "vr_ratio"
  else if "`transf'"=="ra" local transf = "range"
  else if "`transf'"=="z" local transf = "z_score"
  else if !inlist("`transf'","","vr_ratio","range","z_score") {
    di as error "{hi:{ul:tr}ansf()} must specify one of {hi:{ul:vr}_ratio}, {hi:{ul:ra}nge}, or {hi:{ul:z}_score}.
    err 498
  }
  if "`suffix'"=="" & "`transf'"!="" {
    di as error "If a transformation of variables is requested, {hi:{ul:SU}ffix()} must be specified.
    err 498
  }
  if "`transf'"=="" local transf = "vr_ratio"
  if "`suffix'"!="" {
    foreach el of local varlist {
      local newv = "`el'`suffix'"
      if subinword("`varlist'","`newv'"," ",.) != "`varlist'" {
        display as error "{hi:newvar (`newv')} may not be an element of {hi:varlist (`varlist')}"
        display "-trans_cv- not executed"
        exit 498
      }
      local newvlist = "`newvlist' `newv'"
    }
    foreach el of local newvlist {
      if "`replace'"=="replace" {
        capture confirm new var `el'
        if _rc!=0 capture drop `el'
      }
    }
  }

  tempname i RC M_min Rz_min
  local nvars : word count `varlist'
  matrix `RC' = J(`nvars',3,.)
  matrix colnames `RC' = RC M Rz1
  matrix rownames `RC' = `varlist'
  sca `i' = 0
  foreach k of varlist `varlist' {
     tempvar `k'_z1
     sca `i' = `i'+1
     qui sum `k' if `touse'
     matrix `RC'[`i',2] = 12*r(Var)/((r(max)-r(min))^2) // M
     if `i'==1 sca `M_min' = `RC'[1,2]
     else sca `M_min' = min(`RC'[`i',2],`M_min')
     gen ``k'_z1' = (`k'-r(mean))/r(sd) if `touse'      // z1
     qui sum ``k'_z1' if `touse'
     matrix `RC'[`i',3] = r(max)-r(min)                 // Rz1
     if `i'==1 sca `Rz_min' = `RC'[1,3]
     else if float(`M_min')==float(`RC'[`i',2]) sca `Rz_min' = `RC'[`i',3]
  }
  sca `i' = 0
  foreach k of varlist `varlist' {
     sca `i' = `i'+1
     matrix `RC'[`i',1] = `RC'[`i',2]/`M_min'  // RC
     if "`suffix'" != "" {
       if "`transf'"=="z_score" gen `k'`suffix' = ``k'_z1' if `touse'
       else if "`transf'"=="range" gen `k'`suffix' = ``k'_z1'/`RC'[`i',3] if `touse'
       else if "`transf'"=="vr_ratio" gen `k'`suffix' = ``k'_z1'*sqrt(`RC'[`i',1]*`Rz_min'^2/`RC'[`i',3]^2) if `touse'
     }
  }
  matrix `RC' = `RC'[1..`nvars',1]
  if "`rc'" == "" matlist `RC', format(%6.0g) title("Relative clusterability:")
  qui count if `touse'
  return scalar N = r(N)
  return local vars =  "`varlist'"
  if "`suffix'" != "" return local trans = "`transf'"
  return matrix RC = `RC'
end
