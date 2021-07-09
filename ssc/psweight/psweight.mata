//****************************************************************************/
*! psweight.mata
*! IPW- and CBPS-type propensity score reweighting, with extentions
*! Class defintion: psweight()
//
*! By Keith Kranker
//
// Copyright (C) Mathematica, Inc. This code cannot be copied, distributed
// or used without the express written permission of Mathematica, Inc.
//*****************************************************************************/

version 15.1
mata:

mata set matastrict on
mata set matafavor speed

// Define the class
class psweight {
  protected:
    real colvector   T, W, sel1, sel0, Y0, SW, W_mtch, PS_mtch
    real matrix      X, XC, Xstd
    string scalar    tvar, depvars, swvar
    string rowvector tmvarlist
    real rowvector   means1, means0, meansP, variances0, variances1, variancesP, variancesA
    real matrix      covariances0, covariances1, covariancesP, covariancesA
    void             calcmeans(), calcvariances(), calcN(), calccovariances(), cbps_port_stata(), cbps_port_r(), postbeta()
    real scalar      K, N1, N0, N, N1_raw, N0_raw, N_raw
    real scalar      mean_sd_sq()
    real rowvector   olsbeta(), diagvariance(), logitbeta(), sd_sq(), wgt_moments(), stdprogdiff()
    real colvector   olspredict(), logitpredict(), logitweights(), cbps_port_stata_moments(), trim()
    real matrix      cbps_port_stata_wgt_matrix(), cbps_port_stata_gradient(), Ct()

  public:
    void             new(), clone(), set(), set_depvars(), st_set(), st_set_depvars(), reweight(), fill_vars()
    void             cbpseval(), balanceresults()
    real rowvector   solve(), ipw(), cbps(), cbpsoid()
    real colvector   get_pscore(), get_weight_mtch(), get_weight()
    real rowvector   diff(), stddiff(), varratio(), progdiff(), pomean()
    real scalar      mean_sd(), mean_asd(), max_asd(), wgt_cv(), wgt_sd(), wgt_skewness(), wgt_kurtosis(), wgt_max()
    real matrix      balancetable(), get_N()
}

// SETUP FUNCTIONS
// The following functions read data into the instance of the class

void psweight::new() {
  // /* */ "New instance of psweight class created"
  // /* */ "psweight::new() doesn't do anything"
  // /* */ "T is " + strofreal(rows(this.T)) + " by " + strofreal(cols(this.T))
  this.depvars = ""
}

// clones an instance of the class
// all views will be turned into regular variables
// matching weights are reset to 1 and sample sizes are recalculated
void psweight::clone(class psweight scalar src) {
  this.N_raw    = src.N_raw
  this.N0_raw   = src.N0_raw
  this.N1_raw   = src.N1_raw
  this.sel0     = src.sel0
  this.sel1     = src.sel1
  this.T        = src.T
  this.X        = src.X
  this.SW       = src.SW
  this.Y0       = src.Y0
  this.tvar     = src.tvar
  this.tmvarlist= src.tmvarlist
  this.swvar    = src.swvar
  this.depvars  = src.depvars
  this.reweight()
  this.calcN()
}

// loads Stata data into the class, using views wherever possible
void psweight::st_set(string scalar tvar,
                      string scalar tmvarlist,
                      | string scalar tousevar,
                        string scalar swvar) {
  // Define treatment dummy
  this.tvar = tvar
  if (args()<3) st_view(this.T, ., tvar)
  else          st_view(this.T, ., tvar, tousevar)
  // /* */  "T is " + strofreal(rows(this.T)) + " by " + strofreal(cols(this.T))

  // Define covariates
  this.tmvarlist  = tokens(tmvarlist)
  if (args()<3)  st_view(this.X, ., this.tmvarlist)
  else           st_view(this.X, ., this.tmvarlist, tousevar)
  this.K = cols(this.X)
  // /* */  "X contains" ; this.tmvarlist
  // /* */  "X is " + strofreal(rows(this.X)) + " by " + strofreal(cols(this.X))

  // Define sample weights (SW)
  // This code assumes weights are **already** normalized, if necessary.
  // Here's code to normalize: this.W = this.W :/ (rows(this.W) / quadcolsum(this.W))
  if (args()>=4) {
    this.swvar = swvar
    if (args()<3) st_view(this.SW, ., this.swvar)
    else          st_view(this.SW, ., this.swvar, tousevar) // an extra copy of the weight variable that can only be set via this function. Useful for reweighting/matching situations.
  }
  else this.SW = J(rows(this.T), 1, 1)
  // /* */  "W is " + strofreal(rows(this.W)) + " by " + strofreal(cols(this.W))
  // initialize W_mtch=1 and W=SW
  // SW is potentially a view, but W and W_mtch always contain the data
  this.reweight()
  // /* */  "SW is " + strofreal(rows(this.SW)) + " by " + strofreal(cols(this.SW))
  // /* */  "W is " + strofreal(rows(this.W)) + " by " + strofreal(cols(this.W))

  // Index to select observations in control and treatment groups
  this.sel0 = selectindex(!this.T :& this.SW)
  this.sel1 = selectindex( this.T :& this.SW)

  // Save raw number of observations
  this.N0_raw = rows(this.sel0)
  this.N1_raw = rows(this.sel1)
  this.N_raw = this.N0_raw + this.N1_raw
  if (min((this.N0_raw, this.N1_raw)==0)) _error("At least one treatment and control observation required.")

  // calculate sample sizes
  this.calcN()
}

// calculates unweighted/wegihted sample sizes for treatment and control group
void psweight::calcN() {

  // Save weighted number of observations
  this.N0 = quadcolsum(this.W[this.sel0])
  this.N1 = quadcolsum(this.W[this.sel1])
  this.N = this.N0 + this.N1
  if (min((this.N0, this.N1)==0)) _error("Sum of weights is 0 in the treatment or control group.")

  // these means/varinaces are saved internally in the class (to avoid computing them over and over).
  // They need to be reset because we just reweighted the sample.
  // If I'm re-calcuating sample sizes, this is probably the case.  Set to missing here just to be safe.
  this.means0 = this.means1 = this.meansP = this.variances0 = this.variances1 = this.variancesP = this.variancesA = J(1, 0, .)
  this.covariances0 = this.covariances1 = this.covariancesP = this.covariancesA = J(0, 0, .)
}

// display/return sample sizes
real matrix psweight::get_N(| s) {

  if (args() < 1) s = 0

  st_numscalar("r(N_raw)" , N_raw)
  st_numscalar("r(N1_raw)", N1_raw)
  st_numscalar("r(N0_raw)", N0_raw)

  real scalar sum_sw_1, sum_sw_0, sum_sw
  sum_sw_1 = quadcolsum(this.SW[this.sel1])
  sum_sw_0 = quadcolsum(this.SW[this.sel0])
  sum_sw   = sum_sw_1 + sum_sw_0

  st_numscalar("r(sum_sw)"  , sum_sw)
  st_numscalar("r(sum_sw_1)", sum_sw_1)
  st_numscalar("r(sum_sw_0)", sum_sw_0)

  st_numscalar("r(sum_w)"   , N)
  st_numscalar("r(sum_w_1)" , N1)
  st_numscalar("r(sum_w_0)" , N0)

  real matrix N_table
  N_table = (this.N1_raw, this.N0_raw, this.N_raw \
             sum_sw_1,    sum_sw_0,    sum_sw \
             this.N1,     this.N0,     this.N)
  st_matrix("r(N_table)", N_table)
  st_matrixcolstripe("r(N_table)", ("", "Treatment" \ "", "Control" \ "" ,"Total"))
  st_matrixrowstripe("r(N_table)", ("", "Number of rows" \ "", "Sum of sample weights" \ "", "Sum of weights"))

  if (s) {
    string scalar tmp
    tmp = st_tempname()
    stata("matrix " + tmp + " = r(N_table)")
    stata("_matrix_table " + tmp)
  }

  return(N_table)
}

// loads the Stata dependent variable data into the class
// Note: this function doesn't allow the class to touch the treatment group's outcome data
void psweight::st_set_depvars(string scalar depvarlist,
                              | string scalar tousevar) {
  real colvector Y
  this.depvars = tokens(depvarlist)
  Y=.
  if (args()<2)  st_view(Y, ., this.depvars)
  else           st_view(Y, ., this.depvars, tousevar)
  st_select(this.Y0, Y, !this.T)
  // /* */  "Y0 is " + strofreal(rows(this.Y0)) + " by " + strofreal(cols(this.Y0))
}

// loads Mata data into the class
void psweight::set(real colvector t,
                   real matrix tm,
                   | real colvector sw) {
  // Define treatment dummy
  this.tvar = "t"
  this.T = (t:!=0)

  // Define covariates
  this.tmvarlist = invtokens(J(1, cols(tm), "tm_") :+ strofreal(1..cols(tm)))
  if (rows(t)==rows(tm)) {
    this.X = tm
  }
  else _error("tm needs to have same number of rows as t")
  this.K = cols(this.X)
  // /* */  "X contains" ; this.tmvarlist
  // /* */  "X is " + strofreal(rows(this.X)) + " by " + strofreal(cols(this.X))

  // Define weights
  // This code assumes weights are **already** normalized. Here's code to normalize: this.W = this.W :/ (rows(this.W) / quadcolsum(this.W))
  if (args()>=3) {
    this.swvar = "sw"
    if (rows(t)!=rows(sw)) {
      this.SW = sw
    }
    else _error("sw needs to have same number of rows as t")
    // an extra copy of the weight variable that can only be set via this function. Useful for reweighting/matching situations.
  }
  else this.SW = J(rows(this.T), 1, 1)
  // /* */  "W is " + strofreal(rows(this.W)) + " by " + strofreal(cols(this.W))
  // initialize W_mtch=1 and W=SW
  // SW is a view, but W and W_mtch are not
  this.reweight()
  // /* */  "SW is " + strofreal(rows(this.SW)) + " by " + strofreal(cols(this.SW))
  // /* */  "W is " + strofreal(rows(this.W)) + " by " + strofreal(cols(this.W))

  // Index to select observations in control and treatment groups
  this.sel0 = selectindex(!this.T :& this.SW)
  this.sel1 = selectindex( this.T :& this.SW)

  // Save raw number of observations
  this.N0_raw = rows(this.sel0)
  this.N1_raw = rows(this.sel1)
  this.N_raw = this.N0_raw + this.N1_raw
  if (min((this.N0_raw, this.N1_raw)==0)) _error("At least one treatment and control observation required.")

  // calculate and display sample sizes
  this.calcN()
}

// loads Mata dependent variable data into the class
void psweight::set_depvars(real matrix y0) {
  if (rows(y0)==this.N0_raw) {
    this.Y0 = y0
  }
  else _error("y0 has an unexpected number of rows")
  this.depvars = invtokens(J(1, cols(y0), "y0_") :+ strofreal(1..cols(y0)))
  // /* */  "Y0 is " + strofreal(rows(this.Y0)) + " by " + strofreal(cols(this.Y0))
}

// multiply the original weights by a matching weight
// and, optimally, store IPW weights in this.PS_mtch
void psweight::reweight(| real colvector w,
                          real colvector p) {
  // weights
  if (args()<1) this.W_mtch = J(rows(this.T), 1, 1)
  else          this.W_mtch = w
  this.W = this.SW :* this.W_mtch
  // p-scores
  if (args()>1)      this.PS_mtch = p
  else if (args()<1) this.PS_mtch = .
  // recalculate N and set means/variances to missing.
  this.calcN()
  this.means0 = this.means1 = this.meansP = this.variances0 = this.variances1 = this.variancesP = this.variancesA = J(1, 0, .)
  this.covariances0 = this.covariances1 = this.covariancesP = this.covariancesA = J(0, 0, .)
}

// functions to let user to obtain the weights and propensity scores
real colvector psweight::get_pscore()      return(this.PS_mtch)
real colvector psweight::get_weight_mtch() return(this.W_mtch)
real colvector psweight::get_weight()      return(this.W)

// used to push the resulting weights and propensity scores back into Stata
void psweight::fill_vars(string rowvector newvarnames,
                         | string scalar tousevar) {
  real matrix thisview
  if (length(tokens(newvarnames))!=4) _error("psweight::fill_vars() requires four numeric variable names")
  if (args()<2)  st_view(thisview, ., newvarnames)
  else           st_view(thisview, ., newvarnames, tousevar)

  if (rows(thisview)==rows(this.W)) thisview[., 1] = this.W
  else thisview[., 1] = J(rows(thisview), 1, .)

  if (rows(thisview)==rows(this.W_mtch)) thisview[., 2] = this.W_mtch
  else thisview[., 2] = J(rows(thisview), 1, .)

  if (rows(thisview)==rows(this.PS_mtch)) thisview[., 3] = this.PS_mtch
  else thisview[., 3] = J(rows(thisview), 1, .)

  if (rows(thisview)==rows(this.T)) thisview[., 4] = this.T
  else thisview[., 4] = J(rows(thisview), 1, .)

  display("New variables created: " +
          `"{stata "tabstat "' + tokens(newvarnames)[1] + `" if e(sample), by(_treated) c(s) s(N mean sd min p1 p10 p25 p50 p75 p90 p99 max) format":"' + tokens(newvarnames)[1] + `"} "' +
          `"{stata "tabstat "' + tokens(newvarnames)[2] + `" if e(sample), by(_treated) c(s) s(N mean sd min p1 p10 p25 p50 p75 p90 p99 max) format":"' + tokens(newvarnames)[2] + `"} "' +
          `"{stata "tabstat "' + tokens(newvarnames)[3] + `" if e(sample), by(_treated) c(s) s(N mean sd min p1 p10 p25 p50 p75 p90 p99 max) format":"' + tokens(newvarnames)[3] + `"} "' +
          `"{stata "tabstat "' + tokens(newvarnames)[4] + `" if e(sample),              c(s) s(N mean    min                            max) format":"' + tokens(newvarnames)[4] + `"} "' )
  ""

}

// Construct a balance table (and print it to the screen)
real matrix psweight::balancetable(| real scalar denominator) {
  real matrix table
  string rowvector colstripe, tmp, frmts
  if (args()<1) denominator=2

  if (!length(this.means1))     this.calcmeans()
  if (!length(this.variances1)) this.calcvariances()

  table = (this.means1 \
           this.means0 \
           this.diff() \
           this.stddiff(denominator) \
           (denominator==0 ? sqrt(this.variances0) : (denominator==1 ? sqrt(this.variances1) : (denominator==2 ? sqrt(this.variancesP) : (denominator==3 ? sqrt(this.variancesA) : _error("denominator argument invalid"))))) \
           this.varratio())'

  colstripe = ("mean_T",
               "mean_C",
               "diff",
               "std_diff",
               (denominator==0 ? "sd_C" : (denominator==1 ? "sd_T" : (denominator==2 ? "sd_pool" : (denominator==3 ? "sd_avg" : "")))),
               "var_ratio")

  st_matrix("r(bal)", table)
  st_matrixcolstripe("r(bal)", (J(length(colstripe), 1,""), colstripe'))
  st_matrixrowstripe("r(bal)", (J(length(tmvarlist), 1,""), tmvarlist'))

  tmp=st_tempname()
  frmts= st_local("matrix_table_options")
  if (frmts == ".") frmts = J(1, 1,"")
  else              frmts = ", " + frmts
  stata("matrix "+tmp+"=r(bal)")
  stata("_matrix_table " + tmp + frmts); ""
  "Mean standardized diff.             = " + strofreal(this.mean_sd(denominator),  "%9.5f")
  "Mean absolute standardized diff.    = " + strofreal(this.mean_asd(denominator), "%9.5f")
  "Maximum absolute standardized diff. = " + strofreal(this.max_asd(denominator),  "%9.5f")
  return(table)
}

// Prints the balance table and other stuff to the screen
void psweight::balanceresults(| string scalar stat,
                                real scalar denominator) {
  if (args()<1) stat="ate"
  if (args()<2) denominator=2
  transmorphic temp
  if (all(this.W_mtch:==1)) "Unmatched data"
  st_rclear()
  "Balance:"
  temp = this.balancetable(denominator)
  if (!allof(this.W_mtch, 1)) {
    "C.V. of matching weights:           = " + strofreal(this.wgt_cv(stat), "%9.5f")
    "S.D. of matching weights:           = " + strofreal(this.wgt_sd(stat), "%9.5f")
    "Skewness of matching weights:       = " + strofreal(this.wgt_skewness(stat), "%9.5f")
    "Kurtosis of matching weights:       = " + strofreal(this.wgt_kurtosis(stat), "%9.5f")
    "Maximum matching weight:            = " + strofreal(this.wgt_max(stat), "%9.5f")
  }
  else ("Weights equal 1")
  if (this.depvars!="") {
    ""; "Prognostic scores:"
    temp = this.progdiff(denominator)
  }
}

// Calculates the means for the T and C groups
// These means are saved internally in the class (to avoid computing them over and over)
// Call this function whenever sample or weights change
void psweight::calcmeans() {
  this.means0 = mean(this.X[this.sel0, .], this.W[this.sel0])
  this.means1 = mean(this.X[this.sel1, .], this.W[this.sel1])
  this.meansP = mean(this.X, this.W)
  // /* */ "Control group means:"  ; this.means0
  // /* */ "Treatment group means:"; this.means1
}

// Calculates the difference in means between the T and C groups
real rowvector psweight::diff() {
  real rowvector diff
  if (!length(this.means1)) this.calcmeans()
  diff = this.means1 :- this.means0

  st_matrix("r(diff)", diff)
  st_matrixcolstripe("r(diff)", (J(length(tmvarlist), 1,""), tmvarlist'))
  return(diff)
}

// diagvariance(x, w) is the same as diagonal(quadvariance(x, w))'
// but it can be a lot faster than quadvariance, especially when you have lots of columns.
// For testing, mreldif(diagvariance(X, w), diagonal(quadvariance(X, w))') should be small
real rowvector psweight::diagvariance(real matrix x,
                                      | real colvector w,
                                        real rowvector xmean) {
  real rowvector v
  if (args()<2) w = 1
  if (args()<3) xmean = mean(x, w)

  if (all(w:==1)) v = quadcolsum( (x:-xmean):^2)     / (rows(x)-1)
  else            v = quadcolsum(((x:-xmean):^2):*w) / (quadcolsum(w)-1)
  return(v)
}

// Calculates the variances for the T and C group,
// These variances are saved internally in the class
// Call this function whenever sample or weights change
void psweight::calcvariances() {
  if (!length(this.means1)) this.calcmeans()
  this.variances0 = this.diagvariance(this.X[this.sel0, .], this.W[this.sel0], this.means0)
  this.variances1 = this.diagvariance(this.X[this.sel1, .], this.W[this.sel1], this.means1)
  this.variancesP = this.diagvariance(this.X, this.W)
  this.variancesA = (this.variances0 :+ this.variances1) :/ 2
  // /* */ "Control group variances:"; this.variances0
  // /* */ "Treatment group variances:"; this.variances1
  // /* */ "Pooled variances:"; this.variancesP
  // /* */ "Average of variances from treatment and control groups"; this.variancesA
}

// Calculates the variances for the T and C group,
// and saves the results in private variables
void psweight::calccovariances() {
  if (all(this.W:==1)) {
    this.covariances0 = quadvariance(this.X[this.sel0, .])
    this.covariances1 = quadvariance(this.X[this.sel1, .])
    this.covariancesP = quadvariance(this.X)
  }
  else {
    this.covariances0 = quadvariance(this.X[this.sel0, .], this.W[this.sel0])
    this.covariances1 = quadvariance(this.X[this.sel1, .], this.W[this.sel1])
    this.covariancesP = quadvariance(this.X, this.W)
  }
  this.covariancesA = (this.covariances0 :+ this.covariances1) :/ 2
  // /* */ "Control group covariances:"; this.covariances0
  // /* */ "Treatment group covariances:"; this.covariances1
  // /* */ "Pooled covariances:"; this.covariancesP
  // /* */ "Average of covariances from treatment and control groups"; this.covariancesA
  this.variances0 = diagonal(this.covariances0)'
  this.variances1 = diagonal(this.covariances1)'
  this.variancesP = diagonal(this.covariancesP)'
  this.variancesA = diagonal(this.covariancesA)'
  // /* */ "Average of variances from treatment and control groups"; this.variancesA
}

// Calculates standardized differences in means between the T and C groups
// The first argument is optional, and tells the function which variance to use in the denominator
//    = 0, it uses the control groups' variances
//    = 1, it uses the treatment groups' variances (this is the default)
//    = 2, it uses the pooled variances
//    = 3, it uses (control groups' variances + treatment groups' variances)/2  (the definition from Stata's tbalance command)
real rowvector psweight::stddiff(| real scalar denominator) {
  if (args()<1) denominator=2
  real rowvector stddiff
  if (!length(this.variances1)) this.calcvariances()
  if      (denominator==0) stddiff = (this.diff() :/ sqrt(this.variances0))
  else if (denominator==1) stddiff = (this.diff() :/ sqrt(this.variances1))
  else if (denominator==2) stddiff = (this.diff() :/ sqrt(this.variancesP))
  else if (denominator==3) stddiff = (this.diff() :/ sqrt(this.variancesA))
  else _error(strofreal(denominator)+ " is an invalid argument for psweight::stddiff()")

  st_matrix("r(stddiff)", stddiff)
  st_matrixcolstripe("r(stddiff)", (J(length(tmvarlist), 1,""), tmvarlist'))
  return(stddiff)
}

// Calculate means, variance, CV, SD, skewness, kurtosis, and higher moments of the matching weights
real rowvector psweight::wgt_moments(real scalar r,
                                     string scalar stat) {
  real scalar v, m
  real colvector W_sel
  if      (strlower(stat)=="ate")  W_sel=this.W_mtch
  else if (strlower(stat)=="atet") W_sel=this.W_mtch[this.sel0]
  else if (strlower(stat)=="ateu") W_sel=this.W_mtch[this.sel1]
  else _error(stat + " is an invalid argument for psweight::wgt_moments()")
  m = mean(W_sel)
  if (r==0) { // the only exception is that r==0 gives the sd
    v = sqrt(quadcolsum((W_sel:-m):^2) / (rows(W_sel)-1))
  }
  else v = quadcolsum((W_sel:-m):^r)
  return((v, m))
}

real scalar psweight::wgt_cv(string scalar stat) {
  real rowvector vm
  real scalar cv
  vm = this.wgt_moments(0, stat)
  cv = vm[1]/vm[2]
  st_numscalar("r(wgt_cv)", cv)
  return(cv)
}

real scalar psweight::wgt_sd(string scalar stat) {
  real scalar sd
  sd = this.wgt_moments(0, stat)[1]
  st_numscalar("r(wgt_sd)", sd)
  return(sd)
}

real scalar psweight::wgt_skewness(string scalar stat) {
  real scalar skew
  skew = (this.wgt_moments(3, stat)[1]) * (this.wgt_moments(2, stat)[1])^(-3/2)
  st_numscalar("r(wgt_skewness)", skew)
  return(skew)
}

real scalar psweight::wgt_kurtosis(string scalar stat) {
  real scalar kurt
  kurt = (this.wgt_moments(4, stat)[1]) * (this.wgt_moments(2, stat)[1])^(-2)
  st_numscalar("r(wgt_kurtosis)", kurt)
  return(kurt)
}

real scalar psweight::wgt_max(string scalar stat) {
  real scalar mx
  if      (strlower(stat)=="ate")  mx = max(this.W_mtch)
  else if (strlower(stat)=="atet") mx = max(this.W_mtch[this.sel0])
  else if (strlower(stat)=="ateu") mx = max(this.W_mtch[this.sel1])
  else _error(stat + " is an invalid argument for psweight::wgt_moments()")
  st_numscalar("r(wgt_max)", mx)
  return(mx)
}

real rowvector psweight::sd_sq(| real scalar denominator) {
  if (args()<1) denominator=2
  return(this.stddiff(denominator):^2)
}

real scalar psweight::mean_sd(| real scalar denominator) {
  real scalar out
  if (args()<1) denominator=2
  out = mean(this.stddiff(denominator)')
  st_numscalar("r(mean_sd)", out)
  return(out)
}

real scalar psweight::mean_asd(| real scalar denominator) {
  real scalar out
  if (args()<1) denominator=2
  out = mean(abs(this.stddiff(denominator))')
  st_numscalar("r(mean_asd)", out)
  return(out)
}

real scalar psweight::max_asd(| real scalar denominator) {
  real scalar out
  if (args()<1) denominator=2
  out = max(abs(this.stddiff(denominator))')
  st_numscalar("r(max_asd)", out)
  return(out)
}

real scalar psweight::mean_sd_sq(| real scalar denominator) {
  real scalar out
  if (args()<1) denominator=2
  out = mean(this.stddiff(denominator)')
  st_numscalar("r(mean_sd)", out)
  out = out^2
  st_numscalar("r(mean_sd_sq)", out)
  return(out)
}


// Calculates the ratio of variances between the T and C groups
real rowvector psweight::varratio() {
  real rowvector varratio
  if  (!length(this.variances1)) this.calcvariances()
  varratio = this.variances1 :/ this.variances0

  st_matrix("r(varratio)", varratio)
  st_matrixcolstripe("r(varratio)", (J(length(tmvarlist), 1,""), tmvarlist'))
  return(varratio)
}

// Calculates the difference in y_hat, where y_hat is generated using a
// OLS regression of y on X using the control group data
// Denominator is defined the same as in stddiff(), and is passed to stdprogdiff()
real rowvector psweight::progdiff(| real scalar denominator) {
  real rowvector beta, progdiff, yhat_bar_0, yhat_bar_1, y_bar_0, stdprogdiff
  real colvector yhat
  real scalar c
  real matrix table
  string rowvector colstripe, tmp
  if (!length(this.depvars)) _error("Dependent variable is undefined.  Use psweight::st_set_depvars().")
  if (args()<1) denominator=2

  yhat = J(rows(this.X), cols(this.Y0), .)
  for (c=1; c<=cols(this.Y0); c++) {
    beta = this.olsbeta(this.Y0[., c], this.X[this.sel0, .], this.W[this.sel0])
    yhat[., c] = this.olspredict(this.X, beta)
  }

  yhat_bar_0  = mean(yhat[this.sel0, .], this.W[this.sel0])
  yhat_bar_1  = mean(yhat[this.sel1, .], this.W[this.sel1])
  progdiff    = yhat_bar_1 :- yhat_bar_0
  stdprogdiff = stdprogdiff(denominator, yhat, progdiff)
  y_bar_0     = mean(this.Y0, this.W[this.sel0])

  table = (yhat_bar_1 \ yhat_bar_0 \ progdiff \ stdprogdiff \ y_bar_0)'

  colstripe = ("mean_yhat_T",
               "mean_yhat_C",
               "diff",
               "std_diff",
               "mean_y_C")

  st_matrix("r(progdiff)", table)
  st_matrixcolstripe("r(progdiff)", (J(length(colstripe), 1,""), colstripe'))
  st_matrixrowstripe("r(progdiff)", (J(length(depvars)  , 1,""), depvars'))

  tmp=st_tempname()
  stata("matrix "+tmp+"=r(progdiff)")
  stata("_matrix_table "+tmp+","+st_local("diopts"))
  "Note: The std_diff column does not account for the standard error of the linear predictions."

  return(progdiff)
}

// Calculates standardized differences in prognositc scores
// Variances do not account for the OLS modeling; they are just the variance of the y_hat variable
// Note: when this is used in the optimization program, the OLS model is re-estimated each iteration.
// This is to estimate the OLS model with a reweighted comparison group that "looks like" the treatment group.
real rowvector psweight::stdprogdiff(| real scalar denominator,
                                       real matrix yhat,
                                       real rowvector progdiff) {
  real rowvector beta, yhat_bar_0, yhat_bar_1, stddiff
  real scalar c
  if (args()<1) denominator=2
  if (args()<2) {
    if (!length(this.depvars)) _error("Dependent variable is undefined.  Use psweight::st_set_depvars().")
    yhat = J(rows(this.X), cols(this.Y0), .)
    for (c=1; c<=cols(this.Y0); c++) {
      beta = this.olsbeta(this.Y0[., c], this.X[this.sel0, .], this.W[this.sel0])
      yhat[., c] = this.olspredict(this.X, beta)
    }
  }
  if (args()<3) {
    yhat_bar_0 = mean(yhat[this.sel0, .], this.W[this.sel0])
    yhat_bar_1 = mean(yhat[this.sel1, .], this.W[this.sel1])
    progdiff = yhat_bar_1 :- yhat_bar_0
  }
  if (!length(this.variances1)) this.calcvariances()
  if      (denominator==0) stddiff = (progdiff :/ sqrt(this.diagvariance(yhat[this.sel0, .], this.W[this.sel0])))
  else if (denominator==1) stddiff = (progdiff :/ sqrt(this.diagvariance(yhat[this.sel1, .], this.W[this.sel1])))
  else if (denominator==2) stddiff = (progdiff :/ sqrt(this.diagvariance(yhat, this.W)))
  else if (denominator==3) stddiff = (progdiff :/ sqrt((this.diagvariance(yhat[this.sel0, .], this.W[this.sel0]) :+ this.diagvariance(yhat[this.sel1, .], this.W[this.sel1])) :/ 2))
  else _error(strofreal(denominator)+ " is an invalid argument for psweight::stddiff()")
  return(stddiff)
}

// Calculates coefficients for an OLS regression model
// A contant term is included in the regression.
real rowvector psweight::olsbeta(real matrix y,
                                 real matrix X,
                                 | real colvector w,
                                   real scalar addconst) {
  real colvector beta
  real matrix XX, Xy
  if (args()<3) w=1
  if (args()<4) addconst=1

  if (addconst) {
    XX = quadcross(X, 1, w, X, 1)
    Xy = quadcross(X, 1, w, y, 0)
    beta = invsym(XX,(cols(X)+1))*Xy
  }
  else {
    XX = quadcross(X, 0, w, X, 0)
    Xy = quadcross(X, 0, w, y, 0)
    beta = invsym(XX)*Xy
  }
  return(beta')
}

// Returns predicted values, X*beta'
// If cols(X)+1==cols(beta), the function assumes the last coefficient corresponds to the constant term, and X just doesn't have a constant term
// Warning: this function doesn't check the conformability; I rely on Stata to produce errors with invalid arguments
real colvector psweight::olspredict(real matrix X,
                                    real rowvector beta) {
  if ((cols(X)==cols(beta)) & cols(beta)) {
    return(X*beta')
  }
  else if ((cols(X)==cols(beta)-1) & cols(beta)) {
    return((X*beta[1..(cols(beta)-1)]') :+ beta[cols(beta)])
  }
  else _error("X and beta are not conformable.")
}

// Computes weights (and returns them in this.W_mtch)
//    stat corresponds to the options in psweight::logitweights()
//    stat = "ate"  computes weights for average treatment effect (the default)
//         = "atet" computes weights for average treatment effect on the treated
//         = "ateu" computes weights for average treatment effect on the untreated
real rowvector psweight::ipw(| string scalar stat) {
  real rowvector beta
  real colvector pscore, ipwwgt
  real matrix Ct
  this.reweight()
  if (args()<1) stat="ate"
  Ct = this.Ct((this.tmvarlist,"_cons"))
  beta   = this.logitbeta(this.T, this.X, this.SW, 1, Ct)
  // /* */ "propensity score (logit) model beta:"; beta
  pscore = this.logitpredict(this.X, beta)
  ipwwgt = this.logitweights(pscore, stat)
  this.postbeta(beta)
  this.reweight(ipwwgt, pscore)
  return(beta)
}

// Returns (weighted) mean of the dependent variable(s) in the control group
real rowvector psweight::pomean() {
  if (this.depvars=="") _error("dependent variable not defined. use psweight::st_set_depvars()")
  return(mean(this.Y0, this.W[this.sel0]))
}

// Returns predicted values (e.g., propensity scores) if given the X's and betas, using the logit model functional form
// If cols(X)+1==cols(beta), the function assumes the last coefficient corresponds to a constant term, and X just doesn't include it
// Warning: this function doesn't check conformability; I assume Stata will produce an error with invalid arguments
real colvector psweight::logitpredict(real matrix X,
                                      real rowvector beta) {
  if ((cols(X)==cols(beta)) & cols(beta)) {
    return(invlogit(X*beta'))
  }
  else if ((cols(X)==cols(beta)-1) & cols(beta)) {
    return(invlogit((X*beta[1..(cols(beta)-1)]') :+ beta[cols(beta)]))
  }
  else _error("X and beta are not conformable.")
}

// Trims a generic column vector, x
// by default, trimming is at 1e-6 and 1-1e-6, which is useful for trimming propensity scores very close to 0 or 1
real colvector psweight::trim(real colvector x,
                              | real scalar minval,
                                real scalar maxval) {
  real colvector out
  if (args()<2) minval = 1e-6
  if (args()<3) maxval = 1-minval
  out = rowmax((J(rows(x), 1, minval), rowmin((J(rows(x), 1, maxval), x))))
  return(out)
}

// This turns a vector of pscores into IPW weights. This assumes a logit setup.
// Formulas match the normalized weights in Stata's teffects IPW command
//    pscore is a vector of propensity scores
//    stat = "ate"  computes weights for average treatment effect (the default)
//         = "atet" computes weights for average treatment effect on the treated
//         = "ateu" computes weights for average treatment effect on the untreated
real colvector psweight::logitweights(real colvector pscore,
                                      | string scalar stat) {
  real colvector pm
  real matrix ipwwgt
  if (args()<2) stat="ate"

  if (any(pscore:<=0) | any(pscore:>=1)) _error("Propensity scores need to be greater than 0 and less than 1.")
  //  /* */ if (minmax[1, 1]<=0.03 & (strlower(stat)=="ate" | strlower(stat)=="ateu")) errprintf("Warning: minimum propensity score is %12.0g \n", minmax[1, 1])
  //  /* */ if (minmax[1, 2]>=0.97 & (strlower(stat)=="ate" | strlower(stat)=="atet")) errprintf("Warning: maximum propensity score is %12.0g \n", minmax[1, 2])

  pm = 1 :- (!this.T)
  if      (strlower(stat)=="ate")   ipwwgt = (pm :/pscore) :+ (!pm:/(1:-pscore))
  else if (strlower(stat)=="atet")  ipwwgt =  pm :+ (!pm :* (pscore:/(1:-pscore)))
  else if (strlower(stat)=="ateu")  ipwwgt = !pm :+  (pm :* ((1:-pscore):/pscore))
  else _error(stat + " is an invalid argument for psweight::logitweights()")

  // normalize the weights to have mean 1 in each group
  if (strlower(stat)=="ate" | strlower(stat)=="atet") ipwwgt[this.sel0] = ipwwgt[this.sel0] :/ mean(ipwwgt[this.sel0], this.SW[this.sel0])
  if (strlower(stat)=="ate" | strlower(stat)=="ateu") ipwwgt[this.sel1] = ipwwgt[this.sel1] :/ mean(ipwwgt[this.sel1], this.SW[this.sel1])
  return(ipwwgt)
}

// Define function to calculate coefficients for a logit regression model
// A contant term is added to the model and its coefficient is included in the vector of betas
// The program looks at Stata local mlopts for options related to controlling maximization
real rowvector psweight::logitbeta(real colvector Ymat,
                                   real matrix Xmat,
                                   | real colvector Wmat,
                                     real scalar addconst,
                                     real matrix Ct) {
  transmorphic S
  if (args()<4) addconst=1

  S=moptimize_init()
  moptimize_init_evaluator(S, &psweight_logit_eval())
  moptimize_init_evaluatortype(S,"lf")
  moptimize_init_depvar(S, 1, Ymat)
  moptimize_init_eq_indepvars(S, 1, Xmat)
  if (!addconst) moptimize_init_eq_cons(S, 1, "off")
  if (args()>=3 & !allof(Wmat, 1)) moptimize_init_weight(S, Wmat)
  moptimize_init_eq_colnames(S, 1, (J(1, cols(Xmat),"x") + strofreal((1..cols(Xmat)))))
  moptimize_init_vcetype(S, "robust")
  if (args()>=5) moptimize_init_constraints(S, Ct)
  if (st_local("mlopts")!="") moptimize_init_mlopts(S, st_local("mlopts"))
  if (st_local("from")!="") {
    "(Initial parameter values were provided)"
    optimize_init_params(S, st_matrix(st_local("from")))
  }
  moptimize(S)
  // /* */ "Logit model coefficients and robust standard errors:"; moptimize_result_display(S)
  return(moptimize_result_coefs(S))
}

// Builds a constraint matrix for optimization commands
// Based on Dave Drukker's post: https://blog.stata.com/2016/02/09/programming-an-estimation-command-in-stata-handling-factor-variables-in-optimize/
real matrix psweight::Ct(string rowvector tmvarlist) {
  string scalar tempmat
  real scalar ko, p, j
  real matrix Ct, mo
  tempmat = st_tempname()
  st_matrix(tempmat, J(1, length(tmvarlist), 0))
  stata("matrix colnames " +  tempmat + " = " + invtokens(tmvarlist))
  stata("_ms_omit_info   " +  tempmat)
  mo = st_matrix("r(omit)")
  ko = sum(mo)
  p  = cols(mo)
  if (ko) {
    Ct   = J(0, p, .)
    for (j=1; j<=p; j++) {
      if (mo[j]==1) Ct = Ct \ e(j, p)
    }
    Ct = Ct, J(ko, 1, 0)
  }
  else Ct = J(0, p+1, .)
  return(Ct)
}

// Sends coefficients and N back to Stata in a matrix named `psweight_beta_out'
void psweight::postbeta(real rowvector beta) {
  string scalar tempmatname
  st_eclear()
  tempmatname=st_tempname()
  st_matrix(tempmatname, beta)
  st_local("psweight_beta_out", tempmatname)
  if      ((this.K==cols(beta))   & cols(beta)) st_matrixcolstripe(tempmatname, (J(cols(beta), 1,""), this.tmvarlist'))
  else if ((this.K==cols(beta)-1) & cols(beta)) st_matrixcolstripe(tempmatname, (J(cols(beta), 1,""),(this.tmvarlist' \ "_cons")))
  else _error("beta does not have the expected dimensions.")
  st_local("psweight_N_out", strofreal(this.N))
}

void psweight_logit_eval(transmorphic S,
                         real rowvector beta,
                         real colvector lnf) {
  real colvector Y, pm, xb, lj
  Y  = moptimize_util_depvar(S, 1)
  xb = moptimize_util_xb(S, beta, 1)
  pm = 2*(Y :!= 0) :- 1
  lj = invlogit(pm:*xb)
  if (anyof(lj, 0)) {
    lnf = .
    return
  }
  lnf  = ln(lj)
}

// Computes coefficents under a variety of schemes, including CBPS
//    stat corresponds to the options in psweight::logitweights()
//    subcmd corresponds to the balance measure
//    denominator is passed to stddiff() and related functions
//    oid=1 turns on the "over-identified" version of the CBPS model; oid=0 leaves it off
//    cvopt adds the CV of the matching weights to the optimization objective function; see documentation
real rowvector psweight::solve(| string scalar stat,
                                 string scalar subcmd,
                                 real scalar denominator,
                                 real rowvector cvopt) {
  real rowvector beta
  real colvector pscore, cbpswgt
  real matrix ww, Ct
  real scalar oid, unnorm
  if (args()<1) stat="ate"
  if (args()<2) subcmd="ipw"
  if (args()<3) denominator=2
  if (args()<4) cvopt=J(1, 0, .)
  this.reweight()
  oid = 0

  // If the user is asking for the IPW result, just call my ipw() function
  if (subcmd=="ipw") {
    if (!length(cvopt)) return(this.ipw(stat))
    else _error("IPW does not work with modified loss function")
  }

  // I have two implimentations of the CBPS function.  Here I pick the one I need.
  // cbps_port_stata - has the gradient functions built in (so it converges faster)
  //                 - but it cannot deal with weighted data.
  //                 - was based on the Stata implimentation of CBPS by Filip Premik
  // cbps_port_r     - works with weighted data
  //                 - doesn't have the gradient functions, and therefore
  //                      (1) works with cvopt and
  //                      (2) converges more slowly
  //                 - was based on the R implimentation of CBPS on CRAN by Imai et al.
  // In addition, the program looks at Stata local mlopts with instructions for controlling maximization
  else if (subcmd=="cbpsoid") {
    subcmd="cbps"
    oid=1
  }
  if (subcmd=="cbps" & allof(this.SW, 1)) {
    subcmd="cbps_port_stata"
  }
  else if (subcmd=="cbps") {
    subcmd="cbps_port_r"
  }

  transmorphic S
  S=optimize_init()
  optimize_init_evaluator(S, &psweight_cbps_eval())
  optimize_init_which(S, "min")
  optimize_init_argument(S, 1, this)
  optimize_init_argument(S, 2, stat)
  optimize_init_argument(S, 3, subcmd)
  optimize_init_argument(S, 4, denominator)
  optimize_init_argument(S, 5, oid)
  optimize_init_argument(S, 6, cvopt)
  optimize_init_conv_maxiter(S, 120)         // probably want to make this setable
  optimize_init_technique(S, "bfgs")
  optimize_init_tracelevel(S, "value")  // "none", "value", "params"

  // the remaining optimization options depend on the method
  if (subcmd=="cbps_port_r") {
    optimize_init_conv_ptol(S,  1e-13)
    optimize_init_conv_vtol(S,  1e-14)
    optimize_init_conv_nrtol(S, 1e-12)
    optimize_init_evaluatortype(S,"d0")
  }
  else if (subcmd=="cbps_port_stata") {
    optimize_init_conv_ptol(S,  1e-13)
    optimize_init_conv_vtol(S,  1e-14)
    optimize_init_conv_nrtol(S, 1e-12)
    if (oid)  optimize_init_evaluatortype(S,"gf1")  // for overidentified version
    else      optimize_init_evaluatortype(S,"d1")   // d1 if I'm running plain vanilla. otherwise just use "do" (numerical gradient)
  }
  else if (subcmd=="mean_sd_sq" | subcmd=="sd_sq" | subcmd=="stdprogdiff") {
    optimize_init_evaluatortype(S,"d0")
    optimize_init_conv_ignorenrtol(S, "off")
    optimize_init_conv_ptol(S,  1e-10)
    optimize_init_conv_vtol(S,  1e-11)
    optimize_init_conv_nrtol(S, 1e-9)
  }
  else _error(subcmd + " is invalid with psweight::solve()")
  if (st_local("mlopts")!="") psweight_init_mlopts(S, st_local("mlopts"))

  // cvopt adds 1 or more elements to the loss function
  // I don't have gradient functions
  if (length(cvopt)) optimize_init_evaluatortype(S,"gf0")

  // for certain methods,
  // -- normalize Xs to mean 0, sd 1, apply SVD
  // -- add a column with constant term
  if (subcmd=="cbps_port_r") {
    real matrix sel, meansP_orig, sdP_orig, svd_s, svd_v, svd_s_inv, tmp
    unnorm = 1
    if (!length(this.variances1)) this.calcvariances()
    meansP_orig = mean(this.X, this.W)
    sdP_orig = sqrt(this.diagvariance(this.X, this.W))
    sel = selectindex(sdP_orig')' // if we have a factor variable, for example, giving us a column of zeros, then the SD is 0 and Xstd would be ".".  Therefore, take that column out of the X matrix.
    this.Xstd = ((this.X[., sel] :- meansP_orig[., sel]) :/ sdP_orig[., sel], J(this.N_raw, 1, 1))
    pragma unset svd_v
    pragma unset svd_s
    _svd(this.Xstd, svd_s, svd_v)
  }
  else if (subcmd=="cbps_port_stata") {
    unnorm=0
    if (!length(this.XC)) this.XC = (this.X, J(this.N_raw, 1, 1)) // not the most efficient -- data is copied from a view into a matrix -- but at least I only do it once
  }
  else unnorm=0

  // constraint matrix
  if (subcmd=="cbps_port_r") Ct = this.Ct((this.tmvarlist[sel],"_cons"))
  else                     Ct = this.Ct((this.tmvarlist,"_cons"))
  optimize_init_constraints(S, Ct)

  // initial values
  real rowvector beta_logit
  if (st_local("from")!="") {
    "Step 1 skipped (initial values provided by user):"
    beta_logit = st_matrix(st_local("from"))
  }
  else if (subcmd=="cbps_port_r") {
    "Step 1 (initial values from logit model):"
    // constant term was alrady added to Xstd. don't include dropped columns
    beta_logit = this.logitbeta(this.T, this.Xstd, this.W, 0, Ct)
  }
  else {
    "Step 1 (initial values from logit model):"
    // constant term will be added to X in last column
    beta_logit = this.logitbeta(this.T, this.X, this.W, 1, Ct)
  }
  optimize_init_params(S, beta_logit)

  // This is an extra matrix the can be passed to optimiztion engine. I use it for different purposes.
  // It is only calculated once -- not once every time the ojective function is called.
  if (subcmd=="cbps_port_stata") {
    // is this just this.covariancesP ?
    ww = this.cbps_port_stata_wgt_matrix(beta_logit, oid, stat)
    ww = invsym(ww)
    if (!allof(this.SW, 1)) _error("psweight::cbps_port_stata_moments() does not yet accomodate weighted samples")
  }
  else if (subcmd=="cbps_port_r" & !oid) {
    if (!oid) ww = invsym(quadcross(this.Xstd, this.W, this.Xstd))
  }
  else ww = .
  optimize_init_argument(S, 7, ww)
  ""

  "Step 2 (CBPS) :"
  (void) optimize(S)
  beta    = optimize_result_params(S)
  // /* */ "beta:" ; beta

  // undoing the normalization and SVD
  if (unnorm)  {
    this.Xstd = .
    svd_s_inv = svd_s:^-1
    svd_s_inv = svd_s_inv :* (svd_s :> 1e-5)
    beta = (svd_v' * diag(svd_s_inv) * beta')'
    if (length(beta)<this.K) { // deal with the columns I took out above
      tmp = J(1, this.K+1, 0)
      tmp[(sel, this.K+1)] = beta
      beta = tmp
    }
    beta[sel] = (beta[sel] :/ sdP_orig[sel])
    beta[this.K+1] = beta[this.K+1] :- meansP_orig[sel] * beta[sel]'
    // /* */ "CBPS beta after undoing the normalization"; ((this.tmvarlist,"_cons")', strofreal(beta)')
  }

  pscore = this.logitpredict(this.X, beta)
  pscore = this.trim(pscore)
  cbpswgt = this.logitweights(pscore, stat)

  this.postbeta(beta)
  this.reweight(cbpswgt, pscore)
  return(beta)
}

// helper function -- note this is not a member of the class
void psweight_cbps_eval(real todo,
                        real beta,
                        class psweight scalar M,
                        string stat,
                        string subcmd,
                        real denominator,
                        real oid,
                        real cvopt,
                        real ww,
                        real lnf,
                        real g,
                        real H) {
  M.cbpseval(todo, beta, stat, subcmd, denominator, oid, cvopt, ww, lnf, g, H)
}

// the function to be called by optimize() to evaluate f(p).
// This function needs to be public, but it is just called by solve().
void psweight::cbpseval(real   scalar    todo,
                        real   rowvector beta,
                        string scalar    stat,
                        string scalar    subcmd,
                        real   scalar    denominator,
                        real   scalar    oid,
                        real   rowvector cvopt,
                        real   matrix    ww,
                        real   matrix    lnf,
                        real   matrix    g,
                        real   matrix    H) {
  real colvector  pscore, cbpswgt
  if      (subcmd=="cbps_port_stata")  this.cbps_port_stata(todo, beta, stat, oid, ww, lnf, g, H)
  else if (subcmd=="cbps_port_r")      this.cbps_port_r(todo, beta, stat, oid, ww, lnf, g, H)
  else if (subcmd=="mean_sd_sq" | subcmd=="sd_sq"  | subcmd=="stdprogdiff") {
    pscore = this.logitpredict(this.X, beta)
    pscore = this.trim(pscore)
    cbpswgt = this.logitweights(pscore, stat)
    this.reweight(cbpswgt)
    if      (subcmd=="mean_sd_sq")      lnf = this.mean_sd_sq(denominator)
    else if (subcmd=="sd_sq")           lnf = quadsum(this.sd_sq(denominator))
    else if (subcmd=="stdprogdiff")     lnf = quadsum(this.stdprogdiff(denominator):^2)
    else                                _error(subcmd + " is invalid with psweight::cbpseval()")
  }

  // cvopt, a row vector, modifies the loss function as documented above
  if (!length(cvopt)) return
  else if (mod(length(cvopt), 3)!=0 | length(cvopt)<3 | length(cvopt)>12) _error("cvopt() should have 0, 3, 6, 9, or 12 elements")
  else if (todo>0) _error("cvopt is not compatable with todo>0 in psweight::cbpseval()")
  if (subcmd=="cbps_port_stata" | subcmd=="cbps_port_r") {
    if (subcmd=="cbps_port_r") pscore = this.logitpredict(this.Xstd, beta)
    else                       pscore = this.logitpredict(this.X, beta)
    pscore = this.trim(pscore)
    cbpswgt = this.logitweights(pscore, stat)
    this.reweight(cbpswgt)
  }
  if (cvopt[1, 1]) lnf = (lnf \ (cvopt[1, 1]:*abs((this.wgt_cv(stat):-cvopt[1, 2]):^cvopt[1, 3])))

  if (length(cvopt)<6) return
  if (cvopt[1, 4]) lnf = (lnf \ (cvopt[1, 4]:*abs((this.wgt_skewness(stat):-cvopt[1, 5]):^cvopt[1, 6])))

  if (length(cvopt)<9) return
  if (cvopt[1, 7]) lnf = (lnf \ (cvopt[1, 7]:*abs((this.wgt_kurtosis(stat):-cvopt[1, 8]):^cvopt[1, 9])))

  if (length(cvopt)<12) return
  if (cvopt[1, 10]) lnf = (lnf \ (cvopt[1, 10]:*abs((this.wgt_max(stat):-cvopt[1, 11]):^cvopt[1, 12])))
}

// Calls CBPS model (not over-identified); this just calls solve() -- described above.
real rowvector psweight::cbps(| string scalar stat,
                                real scalar denominator) {
  if (args()<1) stat="ate"
  if (args()<2) denominator=2
  return(solve(stat, "cbps", denominator))
}

// Calls over-identified CBPS model; this just calls solve() -- described above.
real rowvector psweight::cbpsoid(| string scalar stat,
                                   real scalar denominator) {
  if (args()<1) stat="ate"
  if (args()<2) denominator=2
  return(solve(stat, "cbpsoid", denominator))
}

// Port of the objective function from the Stata verion of CBPS
void psweight::cbps_port_stata(real   scalar    todo,
                               real   rowvector beta,
                               string scalar    stat,
                               real   scalar    oid,
                               real   matrix    ww,
                               real   matrix    lnf,
                               real   matrix    g,
                               real   matrix    H) {
   real colvector  pscore
   pscore = this.logitpredict(this.X, beta)
   pscore = this.trim(pscore)
   real matrix dpscore, gg, G
   dpscore = pscore:*(1:-pscore)
   gg = this.cbps_port_stata_moments(pscore, dpscore, oid, stat)
   lnf = gg' * ww * gg
   if (todo==0) return
   G = this.cbps_port_stata_gradient(pscore, oid, stat)
   g = G' * ww * gg :* (2:*this.N)
   g = g'
}

// Port of the moment function from the Stata verion of CBPS
real colvector psweight::cbps_port_stata_moments(real colvector pscore,
                                                 real matrix dpscore,
                                                 real scalar overid,
                                                 string scalar stat) {
  real colvector gg

  // this is inefficient
  if (strlower(stat)=="ate") {
      gg=quadcross(this.XC, (this.T-pscore):/pscore:/(1:-pscore)):/this.N_raw
  }
  else if (strlower(stat)=="atet") {
      gg=quadcross(this.XC, (this.T-pscore):/(1:-pscore)):/this.N1_raw
  }
  else _error(stat + " is invalid with psweight::cbps_port_stata_moments()")

  if(overid) {
    gg = (quadcross(this.XC, dpscore:*(this.T-pscore):/pscore:/(1:-pscore)):/this.N_raw \ gg)
  }

  gg = gg:/this.N_raw

  return(gg)
}


// Port of the gradient function from the Stata verion of CBPS
real matrix psweight::cbps_port_stata_gradient(real colvector pscore,
                                               real scalar overid,
                                               string scalar stat) {
  real matrix G, dw
  if (strlower(stat)=="ate") {
    G = -(this.XC:*((this.T:-pscore):^2):/pscore:/(1:-pscore))'this.XC
  }
  else if (strlower(stat)=="atet") {
    dw=(pscore:*(this.T:-1)):/(1:-pscore):*(this.N_raw/this.N1_raw)
    G = quadcross(this.XC:*dw, this.XC)
  }
  if (overid) {
    G = ((-(this.XC:*(pscore:*(1:-pscore)))' this.XC) \ G)
  }
  G = G :/ this.N
  return(G)
}


// Port of the weighting matrix function from the Stata verion of CBPS
real matrix psweight::cbps_port_stata_wgt_matrix(real rowvector beta,
                                                 real scalar overid,
                                                 string scalar stat) {
  real matrix ww
  real colvector pscore, dpscore
  pscore  = this.logitpredict(this.X, beta)
  pscore  = this.trim(pscore)
  if (!overid) {
    if (strlower(stat)=="ate") {
      ww = quadcross(this.XC:/(pscore:*(1:-pscore)), this.XC)
    }
    else if (strlower(stat)=="atet") {
      ww = quadcross(this.XC:*(pscore:/(1:-pscore)):*(this.N_raw/this.N1_raw):^2, this.XC)
    }
  }
  else {
    dpscore = pscore:*(1:-pscore)
    if (strlower(stat)=="ate") {
      ww = (      quadcross(this.XC:*(dpscore:^2:/pscore:/(1:-pscore)), this.XC), // this seems inefficint. isn't  pscore:/(1:-pscore) = dpscore:^-1 ?
                  quadcross(this.XC:*(dpscore:/pscore:/(1:-pscore)), this.XC))
      ww = (ww \ (quadcross(this.XC:*(dpscore:/pscore:/(1:-pscore)), this.XC),
                  quadcross(this.XC:*(1:/pscore:/(1:-pscore)), this.XC)))
    }
    else if (strlower(stat)=="atet") {
      ww = (      quadcross(this.XC:*(pscore:/(1:-pscore):*dpscore:^2:/pscore:^2), this.XC),
                  quadcross(this.XC:*(pscore:/(1:-pscore):*dpscore:/pscore):*(this.N_raw/this.N1_raw), this.XC))
      ww = (ww \ (quadcross(this.XC:*(pscore:/(1:-pscore):*dpscore:/pscore):*(this.N_raw/this.N1_raw), this.XC),
                  quadcross(this.XC:*(pscore:/(1:-pscore)):*((this.N_raw/this.N1_raw)^2), this.XC)))
    }
  }
  ww=ww:/this.N_raw
  return(ww)
}


// Port of the gmm.func() function from CBPS.Binary.R (version 0.17)
void psweight::cbps_port_r(real   scalar    todo,
                           real   rowvector beta,
                           string scalar    stat,
                           real   scalar    overid,
                           real   matrix    ww,
                           real   matrix    lnf,
                           real   matrix    g,
                           real   matrix    H) {
  real colvector pscore, w_cbps
  pscore = this.logitpredict(this.Xstd, beta)
  pscore = this.trim(pscore)
  if (strlower(stat)=="atet") {
     w_cbps = (this.N/this.N1) :* (this.T:-pscore) :/ (1:-pscore)
  }
  else if (strlower(stat)=="ate") {
     w_cbps = (pscore:-1:+this.T):^-1
  }
  if (!overid) {
     w_cbps = 1/this.N :* w_cbps
     lnf = abs(quadcross(w_cbps, this.SW, this.Xstd) * ww * quadcross(this.Xstd, this.SW, w_cbps))
  }
  else {
    real colvector gbar, wx1, wx2, wx3
    real matrix V
    gbar = (quadcross(this.Xstd, this.SW, this.T:-pscore) \ quadcross(this.Xstd, this.SW, w_cbps)) :/ this.N
    if (strlower(stat)=="atet") {
      wx1 = this.Xstd:*sqrt((1:-pscore):*pscore)
      wx2 = this.Xstd:*sqrt(pscore:/(1:-pscore))
      wx3 = this.Xstd:*sqrt(pscore)
      V =  (quadcross(wx1, this.SW, wx1), quadcross(wx3, this.SW, wx3) \
            quadcross(wx3, this.SW, wx3), quadcross(wx2, this.SW, wx2) :* (this.N:/this.N1_raw)) :/ this.N1_raw
    }
    else if (strlower(stat)=="ate") {
      wx1 = this.Xstd:*sqrt((1:-pscore):*pscore)
      wx2 = this.Xstd:*((pscore:*(1:-pscore)):^-.5)
      wx3 = this.Xstd
      V = (quadcross(wx1, this.SW, wx1), quadcross(wx3, this.SW, wx3) \
           quadcross(wx3, this.SW, wx3), quadcross(wx2, this.SW, wx2)) :/ this.N
    }
    else _error(stat + " is not allowed.")
    lnf = gbar' * invsym(V) * gbar
  }
  if (todo<1) return
  else _error("psweight::cbps_port_r() is not compatable with todo>=1")
}


// extract optimize_init_*() options parsed by Stata program -mlopts-
// I just copied moptimize_init_mlopts source code, then updated according to the optimize() help entry
void psweight_init_mlopts(transmorphic scalar M,
                          string scalar mlopts) {
        string scalar arg, arg1, tok
        transmorphic t, t1

        t = tokeninit(" ","","()")
        tokenset(t, mlopts)
        arg = tokenget(t)
        t1 = tokeninit("()")

        while (strlen(arg)) {
          arg1 = ""
          if (strmatch(arg,"trace"))               optimize_init_tracelevel(M, "value")
          else if (strmatch(arg,"gradient"))       optimize_init_tracelevel(M, "gradient")
          else if (strmatch(arg,"hessian"))        optimize_init_tracelevel(M, "hessian")
          else if (strmatch(arg,"showstep"))       optimize_init_tracelevel(M, "step")
          else if (strmatch(arg,"nonrtolerance"))  optimize_init_conv_ignorenrtol(M, "on")
          else if (strmatch(arg,"showtolerance"))  optimize_init_tracelevel(M, "tolerance")
          else if (strmatch(arg,"difficult"))      optimize_init_singularHmethod(M, "hybrid")
          else {
            arg1 = tokenget(t)
            tokenset(t1, arg1)
            tok = tokenget(t1)
            if (strmatch(arg,"technique"))         optimize_init_technique(M, tok)
            else if (strmatch(arg,"iterate"))      optimize_init_conv_maxiter(M, strtoreal(tok))
            else if (strmatch(arg,"tolerance"))    optimize_init_conv_ptol(M, strtoreal(tok))
            else if (strmatch(arg,"ltolerance"))   optimize_init_conv_vtol(M, strtoreal(tok))
            else if (strmatch(arg,"nrtolerance"))  optimize_init_conv_nrtol(M, strtoreal(tok))
            else arg = arg1
          }
          if (!strmatch(arg, arg1)) {
            arg = tokenget(t)
          }
        }
}

end
