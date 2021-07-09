//
//
// cem.ado - coarsened exact matching
//
// Inputs: varlist: data on which to match
//         treatment(): name of the treatment variable
//         [cutpoints(): list of cutpoints for each variable]
//        [eval.imbalance: logical to evaluate balance]
//         [k2k: return k-to-k matching?]
//        [verbose: print to screen?]

program define cem, rclass
version 10.1

return local cem_call = "`0'"

syntax anything(name=coarse id="variable list") [if] [, TReatment(varname) AUTOcuts(string) K2k SHowbreaks imbbreaks(string) miname(string) misets(real 0) NOIMBal IMPvar(varname)]

marksample touse

if ("`autocuts'" == "") {
    local autocuts sturges
}

if ("`imbbreaks'" == "") {
    if ("`r(L1_breaks)'" == "") {
        local imbbreaks scott
    }
    else {
        local imbbreaks "`r(L1_breaks)'"
        dis in green "(using the `imbbreaks' break method for imbalance)"
    }
}


// getting the list of user-given cuts
local more 1
while `more' > 0 {
    gettoken currvar coarse : coarse, parse("() ") match(paren)
    if "`currvar'" == "" {
        local more 0
    }
    else {
        local varlist `varlist' `currvar'
        mata: st_local("peek", substr(strltrim("`coarse'"),1,1))
        if "`peek'" == "(" {
            gettoken currcut coarse : coarse, parse("() ") match(paren)
            local varcuts `varcuts' (`currcut')
        }
        else {
            local varcuts `varcuts' (`autocuts')
        }
    }
}

mata: cem_out = cemStata("`varlist'","`varcuts'","`treatment'","`showbreaks'","`miname'", `misets', "`impvar'")

dis ""
dis in green "Matching Summary:"
dis in green "-----------------"
dis in green "Number of strata: " as res r(n_strata)

if ("`treatment'" != "") {

  if ("`k2k'"!="") {
    mata: k2k("`varlist'","`treatment'","random", "`impvar'")
  }

  dis in green "Number of matched strata: " as res r(n_mstrata)
  matrix list r(cem_sum), noheader
  dis ""

  if ("`noimbal'"=="") {
    mata: imbalance("`varlist'","`imbbreaks'","`treatment'",1,"`impvar'")

    if (`r(n_groups)' == 2) {
      dis ""
      dis in green "Multivariate L1 distance: " as res r(L1)
      dis ""
      dis in green "Univariate imbalance:"
      matrix list r(imbal), noheader format(%7.5g)
      return scalar L1 = r(L1)
      matrix A = r(imbal)
      return matrix imbal = A
    }
    else {
      dis ""
      dis in green "NOTE: Treatment has must have only 2 levels to compute distance and weights. In addition, k2k cannot be used."
      dis ""
      drop cem_weights
    }
  }

  matrix A = r(cem_sum)
  matrix B = r(groups)
  return matrix match_table = A
  return matrix groups = B
  return scalar n_matched = r(n_matched)
  return scalar n_mstrata = r(n_mstrata)
  return local treatment = "`treatment'"
  return scalar n_groups = r(n_groups)
}

return local varlist = "`varlist'"
return scalar n_strata = r(n_strata)
return local L1_breaks = "`imbbreaks'"


end

version 10.1
do "`c(sysdir_plus)'c/cem-mata.do"
