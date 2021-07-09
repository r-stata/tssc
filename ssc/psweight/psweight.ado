//****************************************************************************/
*! psweight.ado
*! IPW- and CBPS-type propensity score reweighting, with various extentions
*! Stata command to estimate models
//
*! By Keith Kranker
//
// Copyright (C) Mathematica, Inc. This code cannot be copied, distributed
// or used without the express written permission of Mathematica, Inc.
//*****************************************************************************/

program define psweight, eclass byable(onecall)
  version 15.1
  if _by() {
    local BY `"by `_byvars'`_byrc0':"'
  }
  local cmdline `"psweight `0'"'
	local cmdline : list retokenize cmdline
  if replay() {
    if ("`e(cmd)'" != "psweight") error 301
    if _by() error 190
    if `"`0'"'=="" local 0 ","
    ereturn display
    exit
  }
  gettoken subcmd 0 : 0, parse(" ,")
  if ("`subcmd'"=="call") {
    if _by() error 190
    if (strtrim(`"`0'"')=="") exit
    if regexm(`"`0'"',"=") {
      gettoken vr 0 : 0, parse("=")
      gettoken eq 0 : 0, parse("=")
    }
    return clear
    mata: `vr' `eq' psweight_ado_most_recent.`0'
  }
  else {
    `BY' Estimate `subcmd' `0'
  }
  ereturn local subcmd "`subcmd'"
  ereturn local cmdline `"`cmdline'"'
  ereturn local cmd "psweight"
end

program Estimate, eclass sortpreserve byable(recall)
  version 15.1

  // first word is the name of the "subcommand"
  gettoken subcmd 0 : 0, parse(" ,")
  if      ("`subcmd'"=="mean_sd") ///
    local subcmd mean_sd_sq
  else if ("`subcmd'"=="sd")      ///
    local subcmd sd_sq
  else if (inlist(`"`subcmd'"', "balance", "balanceo", "balanceon", "balanceonl", "balanceonly")) ///
    local subcmd balanceonly
  else if (!inlist(`"`subcmd'"', "pcbps", "ipw", "cbps", "cbpsoid", "mean_sd_sq", "sd_sq", "stdprogdiff")) {
    di as error `""`subcmd'" subcommand invalid"'
    error 198
  }

  // standard syntax parsing
  syntax varlist(min=2 numeric fv) [if] [in] [fw iw/], ///
          [ DEPvarlist(varlist numeric) /// outcome variables (if any)
            ate atet ateu /// to fill in stat
            TREatvariance CONtrolvariance POOledvariance AVEragevariance /// to fill in denominator
            CVTarget(numlist min=3 max=3) SKEWTarget(numlist min=3 max=3) KURTTarget(numlist min=3 max=3) ///
            maxtarget(numlist min=3 max=3) ///  maxtarget is undocumented since it does not converge well
            from(name) /// starting values for maximization
            MWeight(varname numeric) /// 'matching weights' for balanceonly option
            NTABle /// show sample size table at bottom
            * ] //  display and ml options are allowed
  marksample tousevar
  _get_diopts diopts options, `options'
  get_matrix_table_options  , `options' `diopts'
  local matrix_table_options = s(opts)
  mlopts      mlopts        , `options'  // rest is not specified, so any other options will cause error
  if ("`weight'"!="") {
    tempvar wgtvar
    qui gen double `wgtvar'=`exp'
    local wgtexp [`weight'=`exp']
  }

  // check treatment variable
  gettoken tvar varlist: varlist
  _fv_check_depvar `tvar'
  cap assert inlist(`tvar', 0, 1) if `tousevar'
  if _rc {
    di as err `"The treatment variable (`tvar') must be a dummy variable."'
    error 125
  }
  sum `tvar' if `tousevar', mean
  cap assert 0<r(mean) & r(mean) <1
  if _rc {
    di as err `"The treatment variable (`tvar') must be a dummy variable with >1 treatment obs and >1 control obs."'
    error 125
  }

  // exclude observations wtih mweight==.
  if ("`mweight'"!="") {
    if ("`subcmd'"!="balanceonly") {
      di as err `"The mweight(`tvar') option is only applicable with balanceonly."'
      error 198
    }
    markout `tousevar' `mweight'
  }

  // mark collinear variables
  if ("`subcmd'"=="balanceonly") _rmcoll `tvar' `varlist' if `tousevar' `wgtexp', expand
  else                           _rmcoll `tvar' `varlist' if `tousevar' `wgtexp', expand logit touse(`tousevar')
  local varlist `r(varlist)'
  gettoken trash varlist : varlist

  // check type of dependent variables (if any)
  foreach v of local depvarlist {
    markout `tousevar' `v'
    _fv_check_depvar `v'
  }
  tempvar   tousevar_cpy
  clonevar `tousevar_cpy' = `tousevar'

  // parse the "stat" options
  local stat "`ate'`atet'`ateu'"
  if ("`subcmd'"=="balanceonly") {
    if (`"`mweight'"'!="" & "`stat'"=="") {
      di as err `"What kind of weights are in mweight(`mweight')?"' _n `"Specify one of the following: ate, atet, or ateu."'
      error 198
    }
    else if ("`mweight'"=="" & "`stat'"!="") {
      di as error "`stat' not allowed with psweight balance, unless mweight() is also specified."
      error 198
    }
    else if ("`mweight'"=="") local stat "n/a"
  }
  else if ("`stat'"=="") local stat ate
  else if (!inlist("`stat'", "ate", "atet", "ateu")) {
    di as err `"Specify one of the following: ate, atet, or ateu"'
    error 198
  }

  // parse the "cvopt" option
  if (!mi("`maxtarget'")  & mi("`kurttarget'")) local kurttarget "0 . ."
  if (!mi("`kurttarget'") & mi("`skewtarget'")) local skewtarget "0 . ."
  if (!mi("`skewtarget'") & mi("`cvtarget'"))   local cvtarget   "0 . ."
  local cvopt "`cvtarget' `skewtarget' `kurttarget' `maxtarget'"
  local cvopt : list clean cvopt
  if ("`subcmd'"=="balanceonly" & "`cvopt'"!="") {
    di as error "`cvopt' not allowed with `subcmd' subcommand"
    error 198
  }
  else if ("`subcmd'"=="pcbps" & "`cvopt'"=="") {
    di as error `"cvtarget(), skewtarget(), or kurttarget() required with pcbps subcommand"'
    error 198
  }
  else if (!inlist(`: list sizeof cvopt', 0, 3, 6, 9, 12)) {
    di as error `"cvopt() requires 3, 6, 9, 12 elements"'
    error 198
  }
  if ("`subcmd'"=="pcbps") local subcmd cbps // pcbps is a synonym of cbps with cvopt()

  // parse the "denominator" options
  local variance "`treatvariance'`controlvariance'`pooledvariance'`averagevariance'"
  if ("`variance'"=="")                     local denominator = 2
  else if ("`variance'"=="controlvariance") local denominator = 0
  else if ("`variance'"=="treatvariance")   local denominator = 1
  else if ("`variance'"=="pooledvariance")  local denominator = 2
  else if ("`variance'"=="averagevariance") local denominator = 3
  else {
    di as err `"Specify one of the following: controlvariance, treatvariance, pooledvariance, or averagevariance"'
    error 198
  }

  // clear existing results  (varnames match those from psmatch2)
  foreach v in _weight _weight_mtch _pscore _treated {
    cap drop `v'
    qui gen double `v' = .
    format %7.3g `v'
  }
  if ("`subcmd'"!="balanceonly") {
    ereturn clear
    cap mata: mata drop psweight_ado_most_recent
  }
  return clear
  di _n

  // balanceonly option just prints balance and then end the program
  if ("`subcmd'"=="balanceonly") {
    mata: Estimate(0)
  }
  else {

    // switch over to Mata, helper function runs the main function
    mata: Estimate(1)

    // print results to screen
    di as txt _n "Propensity score model coefficients" _c
    di as txt _col(52) "Number of obs" _col(67) "=" _col(69) as res %10.0fc `psweight_N_out'
    di as txt "Propensity score reweigting"
    if      ("`subcmd'"=="ipw"        ) di as txt "Loss = IPW" _c
    else if ("`subcmd'"=="cbps"       ) di as txt "Loss = CBPS (just identified)" _c
    else if ("`subcmd'"=="cbpsoid"    ) di as txt "Loss = CBPS (over identified)" _c
    else if ("`subcmd'"=="mean_sd_sq" ) di as txt "Loss = mean(stddiff())^2" _c
    else if ("`subcmd'"=="sd_sq"      ) di as txt "Loss = sum(stddiff()^2)" _c
    else if ("`subcmd'"=="stdprogdiff") di as txt "Loss = sum(stdprogdiff()^2)" _c
    tokenize `cvopt'
    if !inlist(`"`1'"' , "", "0", ".")  di as txt   " + `1'*abs(wgt_cv()-`2')^`3')" _c
    if !inlist(`"`4'"' , "", "0", ".")  di as txt   " + `4'*abs(wgt_skewness()-`5')^`6')" _c
    if !inlist(`"`7'"' , "", "0", ".")  di as txt   " + `7'*abs(wgt_kurtosis()-`8')^`9')" _c
    if !inlist(`"`10'"', "", "0", ".")  di as txt   " + `10'*abs(wgt_max()-`11')^`12')" _c
    di ""
    ereturn post `psweight_beta_out' `wgtexp', obs(`psweight_N_out') buildfvinfo esample(`tousevar') depname("`tvar'") properties(b)
    _coef_table, `diopts'

  }

  // these locals are returned for balance tables and reweighting
  ereturn                         local stat       = "`stat'"
  ereturn                         local variance   = "`variance'"
  ereturn                         local tvar       = strtrim("`tvar'")
  ereturn                         local tmvarlist  = strtrim("`varlist'")
  if ("`depvarlist'"!="") ereturn local depvarlist = "`depvarlist'"
  if ("`weight'"!="")     ereturn local wtype      = "`weight'"
  if ("`wexp'"!="")       ereturn local wexp       = "`wexp'"
  if ("`cvopt'"!="")      ereturn local cvopt      = "`cvopt'"

  // stick obs-specific weigths and such into Stata vaiables
  mata: psweight_ado_most_recent.fill_vars("_weight _weight_mtch _pscore _treated", "`tousevar_cpy'")

  // this function puts sample sizes into r()
  tempname tempr
  mata: `tempr' = psweight_ado_most_recent.get_N(`=("`ntable'"!="")')

end

program define get_matrix_table_options, sclass
  syntax [, format(passthru) NOOMITted vsquish NOEMPTYcells BASElevels ALLBASElevels NOFVLABel fvwrap(passthru) fvwrapon(passthru) nolstretch *]
  sreturn local opts = strrtrim(stritrim(`"`format' `noomitted' `vsquish' `noemptycells' `baselevels' `passthru' `allbaselevels' `nofvlabel' `fvwrap' `fvwrapon' `nolstretch'"'))
end


// DEFINE MATA FUNCTIONS
version 15.1
mata:
mata set matastrict on
mata set matafavor speed

// This class is local to the .ado file. It inherits almost everything from the parent class.
// The main difference is that stat/fnctn/denominator/cvopt are class variables.
// Therefore, when you, run . psweight call function(),  the arguments given to function()
// are the same arguments that were given to the previous command that created the class instance.
class psweightado extends psweight {
  private:
    string scalar    stat
    string scalar    subcmd
    real   scalar    denominator
    real   rowvector cvopt

  public:
    void set_opts()
    void userweight()
    void balanceresults()
    real rowvector solve(), ipw(), cbps(), cbpsoid(), stddiff(), varratio(), progdiff(), stdprogdiff()
    real scalar mean_sd(), mean_asd(), max_asd(), wgt_cv(), wgt_sd(), wgt_skewness(), wgt_kurtosis(), wgt_max()
    real matrix balancetable()
}

void psweightado::set_opts(string scalar stat_in, string scalar subcmd_in, real scalar denominator_in, real rowvector cvopt_in) {
  this.stat = stat_in
  this.subcmd = subcmd_in
  this.denominator = denominator_in
  this.cvopt = cvopt_in
}

// sets this.W appropriately for the balanceonly option in the .ado file
void psweightado::userweight(| string scalar swvar, string scalar tousevar) {
  if (args()==0 | swvar=="") this.reweight()
  else if (args()==2) {
    real colvector userweight
    userweight=.
    st_view(userweight, ., swvar, tousevar)
    if (length(userweight)!=length(this.T)) _error("Unexpected dimension for " + swvar)
    this.reweight(userweight)
  }
  else _error("userweight() requires 0 or 2 arguments")
}

// these functions are just wrappers
void           psweightado::balanceresults() return(this.super.balanceresults(this.stat, this.denominator))
real rowvector psweightado::solve()          return(this.super.solve(this.stat, this.subcmd, this.denominator, this.cvopt))
real rowvector psweightado::ipw()            return(this.super.ipw(this.stat))
real rowvector psweightado::cbps()           return(this.super.cbps(this.stat, this.denominator))
real rowvector psweightado::cbpsoid()        return(this.super.cbpsoid(this.stat, this.denominator))
real rowvector psweightado::stddiff()        return(this.super.stddiff(this.denominator))
real rowvector psweightado::varratio()       return(this.super.varratio(this.denominator))
real rowvector psweightado::progdiff()       return(this.super.progdiff(this.denominator))
real rowvector psweightado::stdprogdiff()    return(this.super.stdprogdiff(this.denominator))
real scalar    psweightado::mean_sd()        return(this.super.mean_sd(this.denominator))
real scalar    psweightado::mean_asd()       return(this.super.mean_asd(this.denominator))
real scalar    psweightado::max_asd()        return(this.super.max_asd(this.denominator))
real scalar    psweightado::wgt_cv()         return(this.super.wgt_cv(this.stat))
real scalar    psweightado::wgt_sd()         return(this.super.wgt_sd(this.stat))
real scalar    psweightado::wgt_skewness()   return(this.super.wgt_skewness(this.stat))
real scalar    psweightado::wgt_kurtosis()   return(this.super.wgt_kurtosis(this.stat))
real scalar    psweightado::wgt_max()        return(this.super.wgt_max(this.stat))
real matrix    psweightado::balancetable()   return(this.super.balancetable(this.denominator))

// helper function to move Stata locals into Mata and call the main function
// reweight == 1: calcualte inverse propensity weights
//          == 0: just calcuate balance
void Estimate(real scalar reweight) {
  external class   psweightado scalar psweight_ado_most_recent
  string scalar    tvar, varlist, tousevar, swvar, depvarlist
  string scalar    stat, subcmd, mweightvar, ntable
  real   scalar    denominator
  real   rowvector cvopt
  transmorphic temp

  // access key parameters from Stata locals
  tvar        = st_local("tvar")
  varlist     = st_local("varlist")
  tousevar    = st_local("tousevar")
  swvar       = st_local("wgtvar") // note: the .ado files uses "wghvar" (from syntax) while my Mata code uses swvar
  depvarlist  = st_local("depvarlist")
  stat        = st_local("stat")
  subcmd      = st_local("subcmd")
  denominator = strtoreal(st_local("denominator"))
  if  (st_local("cvopt")!="") {
    cvopt       = strtoreal(tokens(st_local("cvopt")))
  }
  else cvopt = J(1, 0, .)

  // initialize class and read in data and parameters
  psweight_ado_most_recent = psweightado()
  if  (swvar!="")     psweight_ado_most_recent.st_set(tvar, varlist, tousevar, swvar)
  else                psweight_ado_most_recent.st_set(tvar, varlist, tousevar)
  if (depvarlist!="") psweight_ado_most_recent.st_set_depvars(depvarlist, tousevar)
  psweight_ado_most_recent.set_opts(stat, subcmd, denominator, cvopt)

  // compute invere probabily weights
  if (reweight) {
    temp = psweight_ado_most_recent.solve()
  }

  // just compute balance
  else {
    mweightvar  = st_local("mweight")
    if (mweightvar!="") {
      psweight_ado_most_recent.userweight(mweightvar, tousevar)
      temp = psweight_ado_most_recent.balanceresults()
    }
    else {
      temp = psweight_ado_most_recent.balancetable()
    }
  }

}

end
