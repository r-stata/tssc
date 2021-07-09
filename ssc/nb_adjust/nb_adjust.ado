*! version 2.02  29-Jul-2015, Dirk Enzmann
*! Adjust or remove outliers of a negative binomial distributed variable

// Main Program
// ------------

// Mata functions -nb_adj()- and -rnbinom()- are defined in
// "nb_adj.mata" and "rnbinom.mata"

* Install -fre- if necessary:
cap which fre
if _rc ssc install fre
* Install -moremata- if necessary:
cap mata: mm_which(0)
if _rc ssc install moremata

program nb_adjust, rclass byable(onecall)
  version 12.1

  syntax varname(numeric) [if] [in] [ , Generate(string) SMall(integer 0)   ///
         LArge(integer 0) THreshold(integer 0) LImit(integer 0) seed(real -1) ///
         REPlicates(integer 250) REMove CENsor noDetail replace ]
  marksample touse

  tempvar nvar bygr touseby
  tempname n_extreme n mu size nout pmisfit thout nadj low

  * Check options:
  if `replicates' < 0 {
    di "Warning: number of replicates has been set to 0"
    local replicates = 0
  }
  if ("`remove'" == "remove" & "`censor'" == "censor") {
    di as error "option censor may not be chosen together with option remove"
    exit 498
  }
  if (`large' < `small') & ("`remove'" == "" & "`censor'" == "") {
    di as error "value of option large(#) may not be less than " ///
                "value of option small(#)"
    exit 498
  }
  if (`threshold' > 0 & `threshold' < `small') {
    di as error "value of option threshold(#) may not be less than " ///
                "value of option small(#)"
    exit 498
  }
  if (`large' < 0) {
    di as error "value of option large(#) may not be negative"
    exit 498
  }
  if (`limit' < 0) {
    di as error "value of option limit(#) may not be negative"
    exit 498
  }
  if (`limit' > 0) & (`limit' < `large') {
    di as error "value of option limit(#) may not be less than " ///
                "value of option large(#)"
    exit 498
  }
  if (`threshold' < 0) {
    di as error "value of option threshold(#) may not be negative"
    exit 498
  }
  if (`threshold' == 0) local method = "rule-based"
  else local method = "fixed"

  * Check existence of variables and set seed if seed != -1:
  local checkv : list varlist - generate
  if "`checkv'" != "`varlist'" {
    di as error "{hi:newvar (`generate')} may not be an element of " ///
                "{hi:varlist (`varlist')}"
    exit 498
  }
  if "`_byvars'" != "" {
    local checkv : list _byvars - generate
    if "`checkv'" != "`_byvars'" {
      di as error "{hi:newvar (`generate')} may not be an element of " ///
                  "{hi:by-variables (`_byvars')}"
      exit 498
    }
  }
  if "`replace'"=="replace" {
    capture confirm new var `generate'
    if (_rc != 0) capture drop `generate'
  }
  if "`generate'" != "" confirm new var `generate'
  if (`seed' != -1) set seed `seed'

  * Prepare -by:- steps:
  if "`_byvars'" != "" {
    qui egen `bygr' = group(`_byvars'), missing lname(bylab)
  }
  else gen `bygr' = 1
  if ("`generate'" != "") {
    qui clonevar `generate' = `varlist'
    qui replace `generate' = .
  }
  qui levelsof `bygr' if `touse', local(K)
  local ngr : word count `K'
  local step = 0
  qui gen `touseby' = .

  * Repeat the following for each group defined by -by:- :
  foreach k of local K {
    local ++step
    if "`_byvars'" != "" {
      di "{hline}" _n as res "-> `_byvars' = `: label (`bygr') `k''"
    }

    * Remove extreme values (> limit) if limit > 0:
    sca `n_extreme' = 0
    if (`limit' > 0) {
      qui sum `varlist' if `varlist' > `limit' & `touse' & `bygr'==`k'
      sca `n_extreme' = r(N)
      qui replace `touse' = 0 if (`varlist' > `limit') & `touse' & `bygr'==`k'
      if `n_extreme' > 0 {
        if ("`detail'") == "" {
          di _n "Cases greater than limit `limit':" _c
          table `varlist' if (`varlist' > `limit') & `varlist' < . & `bygr'==`k', row cell(12)
        }
        if `n_extreme' == 1 {
          if ("`generate'" != "") {
            di _n as res `n_extreme' " extreme value greater than " ///
              "`limit' has been removed and set to .r in `generate'."
          }
          else {
            di _n as res `n_extreme' " extreme value greater than " ///
               "`limit' has temporarily been removed."
          }
        }
        else {
          if ("`generate'" != "") {
            di _n as res `n_extreme' " extreme values greater than " ///
               "`limit' have been removed and set to .r in `generate'."
          }
          else {
            di _n as res `n_extreme' " extreme values greater than " ///
               "`limit' have temporarily been removed."
          }
        }
      }
    }

    sca `low' = `large'
    sca `thout' = `threshold'
    sca `nout' = .
    sca `pmisfit' = .
    sca `nadj' = .
    local notify = ""

    * newvar = varlist if mean of varlist = 0:
    qui sum `varlist' if `touse' & `bygr'==`k', meanonly
    if r(mean) == 0 {
      fre `varlist' if `touse' & `bygr'==`k'
      di as text "(Note: `varlist' is zero for all observations!)"
      sca `n' = r(N)
      sca `low' = 0
      sca `mu' = 0
      sca `size' = 0
      sca `nout' = 0
      sca `nadj' = 0
      sca `pmisfit' = 0
      qui gen `nvar' = `varlist' if `touse' & `bygr'==`k'
      qui recode `nvar' (. = .r) if missing(`nvar') & !missing(`varlist') & `bygr'==`k'
    }
    else {
      * Determine n and parameter size and mu using -nbreg-:
      qui nbreg `varlist' if `touse' & `bygr'==`k', d(c)
      sca `n' = e(N)
      sca `mu' = exp(_b[_cons])
      sca `size' = `mu'/e(delta)

      * Determine threshold thout and adjust, censor, or remove outliers:
      qui replace `touseby' = `touse'
      qui replace `touseby' = 0 if `bygr' != `k'
      mata: nb_adj("`varlist'","`nvar'","`touseby'", `=`thout'', `=`small'', ///
                   `=`low'',`=`n'',`=`mu'',`=`size'', `=`replicates'', ///
                   "`remove'", "`censor'")
      qui replace `nvar' = `varlist' if (`varlist' > .) & `bygr'==`k'
      qui recode `nvar' (. = .r) if missing(`nvar') & !missing(`varlist') & `bygr'==`k'
      label variable `nvar' "`varlist' adjusted"
    }
    if "`generate'" != "" qui replace `generate' = `nvar' if `bygr'==`k'

    * Output of results:
    if ("`detail'" == "" & `mu' > 0) fre `varlist' if `touse' & `bygr'==`k'
    sum `varlist' if `touse' & `bygr'==`k'
    di _n as text "Analysis of outliers:" ///
       _n as res "Outliers > threshold (" `thout' "): n = " `nout' " (" ///
       %5.3f `pmisfit' "%)"

    if "`remove'" == "" & "`censor'" == "" {
      if (`nout' > 0) {
        if ("`notify'" != "") {
          if (`thout' < `small') {
            di as text "`notify' lower bound has been set to " ///
                       `""small" = "' `small' ")"
          }
          else {
            di as text "`notify' lower bound has been set to " ///
                       "outlier threshold)"
          }
        }
        if ("`detail'" == "") {
          if (`nout' == 1) {
            di _n as text "Summary of `varlist' with " ///
               as res `nout' as text " outlier removed:"
          }
          else {
            di _n as text "Summary of `varlist' with " ///
               as res `nout' as text " outliers removed:"
          }
          sum `varlist' if `varlist' <= `thout' & `touse' & `bygr'==`k'
        }
        if (`nadj' > 0) {
          if ("`detail'" == "") {
            di _n as text "Outliers and adjusted values:" _c
            table `nvar' `varlist' if `varlist' > max(`thout', `small') ///
                  & `touse' & `bygr'==`k', row col
          }
          if (`nadj' == 1) {
            if ("`generate'" != "") {
              di _n as text "Summary of `generate' with " ///
                 as res `nadj' as text " outlier adjusted:"
            }
            else {
              di _n as text "Summary of `varlist' with " ///
                 as res `nadj' as text " outlier temporarily adjusted:"
            }
          }
          else {
            if ("`generate'" != "") {
            di _n as text "Summary of `generate' with " ///
               as res `nadj' as text " outliers adjusted:"
            }
            else {
              di _n as text "Summary of `varlist' with " ///
                 as res `nadj' as text " outliers temporarily adjusted:"
            }
          }
          if ("`generate'" != "") {
            sum `generate' if `touse' & `bygr'==`k'
            label variable `generate' "`varlist' with outliers adjusted"
          }
          else {
            sum `nvar' if `touse' & `bygr'==`k'
          }
        }
      }
      if (`nadj' == 0) {
        if ("`generate'" != "") {
          di _n as text "Summary of `generate' (no outliers to adjust):"
          sum `generate' if `touse' & `bygr'==`k'
          label variable `generate' "`varlist' with outliers adjusted"
        }
        else {
          di _n as text "Summary of `varlist' (no outliers to adjust):"
          sum `nvar' if `touse' & `bygr'==`k'
        }
      }
    }
    else if "`censor'" == "censor" {
      if (`nout' > 0) {
        if ("`notify'" != "") {
          if (`thout' < `small') {
            di as text "`notify' lower bound has been set to " ///
                       `""small" = "' `small' ")"
          }
          else {
            di as text "`notify' lower bound has been set to " ///
                       "outlier threshold)"
          }
        }
        if ("`detail'" == "") {
          if (`nout' == 1) {
            di _n as text "Summary of `varlist' with " ///
               as res `nout' as text " outlier removed:"
          }
          else {
            di _n as text "Summary of `varlist' with " ///
               as res `nout' as text " outliers removed:"
          }
          sum `varlist' if `varlist' <= `thout' & `touse' & `bygr'==`k'
        }
        if (`nadj' > 0) {
          if ("`detail'" == "") {
            di _n as text "Outliers censored:" _c
            table `nvar' `varlist' if `varlist' > max(`thout', `small') ///
                  & `touse' & `bygr'==`k', col
          }
          if (`nadj' == 1) {
            if ("`generate'" != "") {
              di _n as text "Summary of `generate' with " ///
                 as res `nadj' as text " outlier censored:"
            }
            else {
              di _n as text "Summary of `varlist' with " ///
                 as res `nadj' as text " outlier temporarily censored:"
            }
          }
          else {
            if ("`generate'" != "") {
            di _n as text "Summary of `generate' with " ///
               as res `nadj' as text " outliers censored:"
            }
            else {
              di _n as text "Summary of `varlist' with " ///
                 as res `nadj' as text " outliers temporarily censored:"
            }
          }
          if ("`generate'" != "") {
            sum `generate' if `touse' & `bygr'==`k'
            label variable `generate' "`varlist' with outliers censored"
          }
          else {
            sum `nvar' if `touse' & `bygr'==`k'
          }
        }
      }
      if (`nadj' == 0) {
        if ("`generate'" != "") {
          di _n as text "Summary of `generate' (no outliers to censor):"
          sum `generate' if `touse' & `bygr'==`k'
          label variable `generate' "`varlist' with outliers censored"
        }
        else {
          di _n as text "Summary of `varlist' (no outliers to censor):"
          sum `nvar' if `touse' & `bygr'==`k'
        }
      }
    }
    else if ("`remove'" == "remove") {
      if (`nout' > 0) & ("`notify'" != "") & (`thout' < `small') {
        di as text "`notify' Outlier threshold not used because it is less " ///
                   `"than "small" = "' `small' "!)"
      }
      if (`nadj' > 0) {
        if ("`detail'" == "") & ("`generate'" != "") {
          if (`nadj' == 1) {
            di _n as res "1 value > " max(`thout', `small') ///
               " has been set to missing (.o) in `generate'."
          }
          else {
            di _n as res `nadj' " values > " max(`thout', `small') ///
               " have been set to missing (.o) in `generate'."
          }
          di _n as text "Outliers removed:" _c
          table `nvar' `varlist' if `nvar' == .o & `bygr'==`k', col
        }
        if (`nadj' == 1) {
          if "`generate'" != "" {
            di _n as text "Summary of `generate' with " as res 1 ///
               as text " outlier set to .o:"
          }
          else {
            di _n as text "Summary of `varlist' with " as res 1 ///
               as text " outlier temporarily set to missing:"
          }
        }
        else {
          if "`generate'" != "" {
            di _n as text "Summary of `generate' with " as res `nadj' ///
               as text " outliers set to .o:"
          }
          else {
            di _n as text "Summary of `varlist' with " as res `nadj' ///
               as text " outliers temporarily set to missing:"
          }
        }
        if "`generate'" != "" {
          label variable `generate' "`varlist' with outliers set to .o"
          sum `generate' if `touse' & `bygr'==`k'
        }
        else {
          sum `nvar' if `touse' & `bygr'==`k'
        }
      }
      else {
        if ("`detail'" == "") {
          if ("`generate'" != "") {
            di _n as text "Summary of `generate' (no outliers to remove):"
            sum `generate' if `touse' & `bygr'==`k'
          }
          else {
            di as text "No outliers to remove."
          }
        }
        if ("`generate'" != "") {
          label variable `generate' "`varlist' with outliers set to .o"
        }
      }
    }
    if ("`_byvars'" != "" & `step' < `ngr') di
    drop `nvar'
  }

  if !(`nadj' == 0 & ("`remove'" != "" |"`censor'" != "") & "`detail'" != "")  di _n "{hline}"
  else di "{hline}"

  return scalar nadj = `nadj'
  return scalar low = `low'
  return scalar percout = `pmisfit'
  return scalar nout = `nout'
  return scalar threshold = `thout'
  return scalar size = `size'
  return scalar mu = `mu'
  return scalar N = `n'
  return local method = "`method'"
  if ("`remove'" == "" & "`censor'" == "") return local adj = "adjusted"
  else if ("`remove'" == "remove") return local adj = "removed"
  else return local adj = "censored"
  return scalar nextr = `n_extreme'
  return scalar repl = `replicates'
  return scalar seed = `seed'
  return scalar limit = `limit'
  return scalar large = `large'
  return scalar small = `small'
  return local newvar = "`generate'"
  return local in = "`in'"
  return local if = "`if'"
  return local varname = "`varlist'"
end
