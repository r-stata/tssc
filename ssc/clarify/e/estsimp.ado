*! version 2.1 January 5, 2003
* (C) Copyright 1998-2003 Michael Tomz, Jason Wittenberg, Gary King
* This file is part of the program Clarify.  All Rights Reserved.
* Estimate model and simulate parameters
* Models:  regress, logit, probit, ologit, oprobit, mlogit, poisson, nbreg,
*          sureg, weibull
* Inputs:  estimation command with typical Stata options
*          [ sims(), the number of simulations ]
*          [ genname(), a stub-name for variables to generate ]
*          [ antisim, which prompts estsimp to use antithetical simulations ]
*          [ mi(), containing the stub-name or full names of mi datasets ]
*          [ iout, which prompts estsimp to print intermediate output from mi]
*          [ drawt, causes betas to be drawn from multi-T rather than multi-N]
*          [ level(), sets the p-level for confidence intervals]
*          [ dropsims, which drops vars holding simd params from last estimn]
* Outputs: parameter estimates and standard errors, displayed on screen
*          simulated parameters, stored as variables in active dataset
*          e(b), a vector of parameter estimates
*          e(V), the variance-covariance matrix of parameter estimates
*          e(N), the number of observations used in the estimation
*          e(Sigma), the sigma matrix, if model has one (It's 1x1 for reg)
*          e(dfSigma), degrees of freedom to use when simulating sigma
*          e(depvar), the dependent variable(s)
*          e(rhsvars), a list of the unique rhs variables & offset variable
*          e(if), the if expression issued at the command line
*          e(in), the in expression issued at the command line
*          e(wt), the weight expression [`weight'`exp'] issued at cmd line
*          e(milist), the unabbreviated list of mi datasets
*          e(allsims), names of all variables (b1,b2..) holding simd params
*          e(offset), the offset variable, if it exists for the model
*          e(k_cat), the # of categories in dep var (0 if not categorical)
*          e(cat), a matrix with values of the dv, if it's a categorical dv
*          e(ibasecat), a scalar with index for base category in mlogit
*          e(k_eq), the number of equations
*          e(cons_i), a scalar equaling 1 if equation i has a constant, otw 0
*          e(rhs_i), the names of rhs variables (except constant) in equ i
*          e(msn_i), names of main simulated params (eg b1,b2,b3) for equ i
*          e(asn), names of ancillary parameters (e.g. b11,b12,b13)
*          e(sims), the number of draws or simulations of the parameters
*          e(cmd), the command name (e.g. "estsimp logit")
*          e(versn), the version of Stata being used
* Future:  Allow the drawt option (need d.f.)
program define estsimp, eclass
version 6.0

   capture version 7
   if _rc == 0 { local versn 7 }               /* supports version 7 */
   else { local versn 6 }                      /* only suppts vers 6 */

   * REPLAY PREVIOUS RESULTS
   if replay() {                                 /* allow user to re-   */
      if "`e(milist)'" ~= "" {
         di in r _n "You cannot replay estimates that were generated from"
         di in r "multiply imputed datasets."
         exit 198
      }
      tokenize `"`e(cmd)'"'                      /*    display the last */
      if "`1'" ~= "estsimp" { error 301 }        /*    point estimates  */
      else { 
         syntax [, Level(integer $S_level)]
         if `level' <= 0 | `level' >= 100 {
            di in r _n "Confidence level must be between 1 and 99, inclusive"
            exit 198
         }
         est display, level(`level')
         exit
      }
   }

   * DOES ESTSIMP SUPPORT THE MODEL?  (MUST MODIFY FOR NEW MODEL)
   * If the user has abbreviated the model name, we will unabbreviate it here
   * Output from this segment of code:
   *   modname (locmac) name of model being estimated
   gettoken modname 0 : 0                        /* strip modname from input*/
   if substr("`modname'",1,3) == "reg" { local modname regress }
   else if substr("`modname'",1,4) == "logi" { local modname logit }
   else if substr("`modname'",1,4) == "prob" { local modname probit }
   else if substr("`modname'",1,4) == "olog" { local modname ologit }
   else if substr("`modname'",1,5) == "oprob" { local modname oprobit } 
   else if substr("`modname'",1,4) == "mlog" { local modname mlogit }
   else if "`modname'" == "poisson" { local modname poisson }
   else if "`modname'" == "nbreg" { local modname nbreg }
   else if "`modname'" == "sureg" { local modname sureg }
   else if "`modname'" == "weibull" { local modname weibull }
   else if "`modname'" == "by" {
      di in r _n "-estsimp- does not support the " in w "by " in r "option"
      exit 198
   }
   else if "`modname'" == "" {
      di in r _n "Must provide model name and variable list"
      exit 198
   }
   else {
      di in r _n "-estsimp- does not support the " in w "`modname'" in r " model"
      exit 198
   }

   * PARSE THE COMMAND LINE
   * Here, we adopt 2 distinct parsing procedures, one for single-equation
   * models (where "`paren'" == "") and one for multiple-equation models 
   * where equations are written as (y1 x1 x2) (y2 x2 x3) (y3 x1 x4) ....
   * Output from this segment of code
   *   eqn (locmac) used to check for single versus multiple equations
   *   paren (locmac) contains a parenthesis if one was parsed
   *   numeqs (locmac) number of equations the user is estimating
   *   varlist (locmac) list of dependent and independent variables
   *   if (locmac) if-conditions, if they were specified
   *   in (locmac) in-conditions, if they were specified
   *   weight (locmac) type of weight, if one was specified
   *   exp (locmac) expression for weighting procedure, if one was specified
   *   sims (locmac) desired number of simulations (draws) of each parameter
   *   genname (locmac) a stub-name for variables to generate
   *   antisim (locmac) prompts estsimp to use antithetical simulations
   *   mi (locmac) stub-name, or full list of names, of mi datasets
   *   iout (locmac) prompts estsimp to print intermediate output from mi
   *   drawt (locmac) to draw betas from multi-T, rather than multi-Normal
   *   level (locmac) p-level for confidence intervals
   *   options (locmac) any remaining options not specified in syntax...
   *   touse (tempvar) 1 if obs should be used for estimation, 0 otherwise
   *   depvar (locmac) list of all dependent variables
   *   rhsvars (locmac) all RHS vars except constant.  May include repeats
   *   rhscons (locmac) all RHS variables, *plus* the constant.  Incl repeats
   *   rhs_`i' (locmac) RHS vars, excluding constant, for ith equation
   *   equlist (locmac) equation(s) to be estimated,e.g. (y1 x1 x2) (y2 x1 x3)
   *   stop (locmac) 1 when Stata should stop repeating a procedure, 0 otrwise
   *   dv (locmac) one of many dependent variables in a multiple-equ model
   *   rest (locmac) the rest (remainder) of some expression
   *   rhs (locmac) some of the rhs (explanatory) vars in a multiple-equ model
   *   comma (locmac) contains "," if user suppressed constant in the equation
   *   nocons (locmac) contains "nocons" if user suppressed const in the equ'n
   *   cons_`i' (locmac) contains 1 if equation `i' has a constant, 0 otrwise
   *   cmdline (locmac) command line, stripped of simulation-specific options
   gettoken eqn : 0, parse(" ,[") match(paren)    /* check for (eq1) (eq2)*/  
   if "`paren'" == "" {
      local numeqs 1                                /* # of equations     */
      syntax varlist(ts) [if] [in] [aw fw pw iw] [, /*
         */ SIMS(int 1000) GENNAME(str) ANTIsim     /*
         */ MI(str) IOUT DRAWT Level(int $S_level) DROPSIMS *]
      marksample touse
      gettoken depvar rhsvars : varlist             /* separate lhs, rhs  */
      if `versn' > 6 { version 7: tsunab depvar : `depvar' }  
      local rhscons `rhsvars'   /* we'll add the constant later */
      local rhs_1 `rhsvars' /* list of rhs variables for this equation */
      local equlist `varlist'
   }
   else {  /* multiple-equation model */
      local numeqs 0                              
      local stop 0                                /* done parsing yet?  */
      while ~ `stop' { 
         gettoken eqn 0 : 0, parse(" ,[") match(paren) /* fetch expression   */
         if `"`eqn'"' == "[" { local stop 1 }
         else if `"`eqn'"' == "," { local stop 1 }
         else if `"`eqn'"' == "if" { local stop 1 }
         else if `"`eqn'"' == "in" { local stop 1 }
         else if `"`eqn'"' == "" { local stop 1 }
         else {
            local numeqs = `numeqs' + 1          /* parse a new equation */
            tokenize "`eqn'", parse(" :")          
            if "`2'" == ":" {                    /* format is (e : y x1) */
               local dv `3'                      /* get name of dep var  */
               mac shift 3
            }
            else {                               /* format is (y x1)    */
               local dv `1'                      /* name of dep var     */
               mac shift 1
            }
            local rest `*'
            gettoken rhs rest : rest, parse(",") /* abbreviated rhs vars */
            if `versn' > 6 {                     /* unabbrev'd rhs vars  */
               version 7: tsunab rhs : `rhs'
               version 7: tsunab dv : `dv'
            } 
            else { 
               tsunab rhs : `rhs' 
               tsunab dv : `dv'
            } 
            * is the user dropping the constant for this equation?
            gettoken comma nocons : rest, parse(",")
            if "`nocons'" ~= "" { 
               local cons_`numeqs' 0 
               local rhscons `rhscons' `rhs'
            }
            else { 
               local cons_`numeqs' 1 
               local rhscons `rhscons' `rhs' _cons
            }          
            local rhs_`numeqs' `rhs'             /* rhsvars for ith equ  */
            local depvar `depvar' `dv'           /* list of all depvars    */
            local rhsvars `rhsvars' `rhs'        /* list of all rhs vars   */
            local equlist `equlist' (`eqn')      /* build list of all equs */
         }
      }
      local 0 `eqn' `0'		              /* rebuild 0 for hi-lvl parse*/
      syntax [if] [in] [aw fw pw iw] [,          /* parse the remainder
         */ SIMS(int 1000) GENNAME(str) ANTIsim  /*    
         */ MI(str) IOUT DRAWT Level(int $S_level) DROPSIMS *]
      marksample touse
      markout `touse' `depvar' `rhsvars'
   }
   local cmdline `modname' `equlist' if `touse' /* build a command line to 
      */ [`weight'`exp'], `options' l(`level')  /*   use for estimation   */

   * PARSE AND CHECK THE MULTIPLE IMPUTATION AND IOUT OPTIONS
   * If the user is analyzing multiply imputed datasets, this procedure
   * will create a full list of MI datasets with names in unabbreviated
   * format.  It confirms that these files exist on disk.  The procedure
   * also verifies that the user has specified mi() when using iout.
   * Outputs from this segment of code
   *   nfiles (locmac) number of multiple-imputation files to be analyzed
   *   1 (locmac) first token in a string
   *   2 (locmac) second token in a string
   *   milist (locmac) full list of MI datasets to be analyzed
   *   stop (locmac) 1 when Stata should stop repeating a procedure, 0 otrwise
   * e-class and r-class values used:
   *   r(changed) (macro) 1 if dataset has changed since last save, otw 0
   *   _rc (macro) return code for a particular cmd.  See Stata Manual
   if "`mi'" ~= "" {
      qui describe, short          /* if dataset in memory has changed */
      if `r(changed)' { error 4 }  /* since the last save, prohibit mi */
      local nfiles 0
      tokenize "`mi'"
      if "`2'" ~= "" {             /* `2' is the 2nd token in "`mi'"   */
         while "`1'" ~= "" {       /* `1' is the 1st token             */
            capture confirm file `1'.dta   
            if _rc { confirm file `1' }
            local milist `milist' `1'       /* full list of mi files   */
            local nfiles = `nfiles' + 1     /* number of mi files      */
            mac shift		   /* drop a token, so `2' becomes `1' */
         }
      }
      else {
         local nfiles = `nfiles' + 1
         local stop 0
         while ~ `stop' {
            capture confirm file `1'`nfiles'.dta
            if _rc {
               local nfiles = `nfiles' - 1
               local stop 1
            }
            else {
               local milist `milist' `1'`nfiles'  
               local nfiles = `nfiles' + 1   
            }
         }
      }
      if `nfiles' < 2 {
         di in r "Must have at least 2 files for mi"
         exit 198
      }
   }
   else {
      if "`iout'" ~= "" {                        /* check iout option      */
         di in r _n "Must specify mi() when using iout option."
         exit 198
      }
   }

   * CHECK SIMS OPTION
   if `sims' < 1 {                               /* check number of sims   */
      di in r _n "Number of sims must be > 0"   
      exit 198 
   }

   * CHECK MODEL-SPECIFIC OPTIONS AND GENNAME
   * Outputs from this segment of code
   *   nrhsvar (locmac) number of rhs (explanatory) variables listed by user
   *   modabbr (locmac) abbreviated (max 6-character) version of the model name
   *   stuff (locmac) some stuff that will be passed to CK`modabbr' program
   *   ncons (locmac) total number of constants in all equations
   *   nptosim (locmac) #params to simulate (counts main + ancillary params)
   *   maxstub (locmac) max length of the stub-name for vars to generate
   *   genname (locmac) a stub-name for variables to generate [see above]
   * e-class and r-class values used:
   *   r(cons_1) (macro) contains 1 if the 1st equation has a constant
   *   r(nap) (macro) #ancillary params in most cases (we cheat sometimes)
   local nrhsvar : word count `rhsvars'          /* # of independent vars  */
   local modabbr = substr("`modname'",1,6)  
   local stuff touse(`touse') numeqs(`numeqs') `options'
   CK`modabbr' "`depvar' `rhsvars', `stuff'"
   local nap = `r(nap)'           /* number of ancillary parameters */
   if `numeqs' == 1 { 
      local cons_1 `r(cons_1)'
      if `cons_1' == 1 { local rhscons `rhscons' _cons }
      local ncons `cons_1'
   }
   else {
      local ncons 0
      local i 1
      while `i' <= `numeqs' {
         local ncons = `ncons' + `cons_`i''
         local i = `i' + 1
      }
   }
   local nptosim = `nrhsvar' + `ncons' + `nap'
   local maxstub = 8 - length(string(`nptosim'))
   if "`genname'" == "" { local genname b }      /* stub-name: vars to gen */
   if length("`genname'") > `maxstub' {
      di in r _n "Your stub-name, `genname', is too long.  Please choose"
      di in r "a stub-name with no more than `maxstub' characters."
      exit 198
   }
   if "`dropsims'" ~= "" { 
      if "`e(allsims)'" ~= "" { capture drop `e(allsims)' }
      else {
         di in r _n "dropsims option failed.  Please drop variables by hand"
         exit 198
      }
   }
   local i 1
   while `i' <= `nptosim' {
      capture confirm new variable `genname'`i'
      if _rc {
         di in r _n "A variable called `genname'`i' already exists."  
         di in r "Drop `genname'`i' or choose a new stub-name " _c
         di in r "for the simulations."
         exit 110
      }
      local i = `i' + 1
   }

   * ESTIMATION AND SIMULATION
   * Here, we adopt 2 distinct procedures: one for estimation and simulation
   * based on a single dataset ("`milist'" == ""), and one for estimation and
   * simulation from several multiply imputed datasets.

   * BEGIN CASE 1: ESTIMATION AND SIMULATION BASED ON A SINGLE DATASET
   * Outputs from this segment of code
   *   b (tmpmat) beta-hat, the point estimates (for MI, mean of beta-hats)
   *   V (tmpmat) VC matrix of estimates (for MI, sum of wi & btwn variance)
   *   N (locmac) #observations Stata used during estimation (for MI, mean#)
   *   newvars (locmac) list of all new vars generated to hold simulations
   *   sig (tmpmat) Sigma matrix (for MI, avg of the Sigma matrices)
   *   dfsig (tmpscalar) deg freedom associated w Sigma (for MI, mean d.f.)
   * e-class and r-class values used:
   *   e(b) (matrix) beta-hat, the vector of point estimates
   *   e(V) (matrix) variance-covariance matrix of estimates
   *   r(newvars) (macro) list of all new vars generated to hold simulations
   *   r(Sigma) (matrix) sigma from the last model that was estimated
   *   r(dfSigma) (macro) deg freedom associated w Sigma from last model
   if "`milist'" == "" {                           /* if no multiple imps  */
      `cmdline'                                    /* run & show estimates */
      tempname b V sig dfsig
      matrix `b' = e(b)                            /* 1 x k vector         */
      matrix `V' = e(V)                            /* k x k variance matrix*/
      local N = `e(N)'                             /* save # observations  */
      CK_drop "`rhscons'" `V'                      /* were any x's dropped?*/
      * Step 1: Simulate all parameters represented in Variance matrix
      _simp, b(`b') v(`V') s(`sims') g(`genname') `antisim' `drawt'
      local newvars `r(newvars)'   /* list of new variables containing sims*/
      * Step 2: Simulate sigma matrix, if necessary
      _simsig2, s(`sims') g(`genname') `antisim' m(`modname') n(`newvars')
      local newvars `r(newvars)'   /* re-capture list of new variables */
      matrix `sig' = r(Sigma)                   /* sigma matrix         */
      scalar `dfsig' = r(dfSigma)               /* sigma deg of freedom */
   }
   * END CASE 1: ESTIMATION AND SIMULTION BASED ON A SINGLE DATASET

   * BEGIN CASE 2: ESTIMATION AND SIMULTION FROM SEVERAL MI DATASETS
   * Outputs from this segment of code
   *   simsper (locmac) #simulations to obtain from each imputed dataset
   *   misims (tmpdset) temporary dataset to hold sims during MI procedures
   *   file (locmac) name of a single file, drawn from the milist of files
   *   b`i' (tmpmat) beta-hat, the vec of point estimates, from ith dataset
   *   V`i' (tmpmat) variance-covariance matrix obtained from ith dataset
   *   newvars (locmac) list of all new vars generated to hold simulations
   *   sigsum (tmpmat) running sum of Sigmas from all datasets
   *   dfsigsm (tmpscalar) running sum of sigma-related df from all datasets
   *   bsum (tmpmat) running sum of beta-hat vectors from all datasets
   *   Vsum (tmpmat) running some of VC matrices from all datasets
   *   Nsum (tmpscalar) running sum of #valid obs (N's) from all datasets
   *   bb (locmac) expression that is part of the between-imputxn variance
   *   u (tmpvar) contains random numbers drawn from uniform (0,1) distrib
   *   mmo (tmpscalar) Number of MI files, minus 1.  Used in MI calculations
   *   b (tmpmat) mean of beta-hats across all the imputed datasets
   *   WV (tmpmat) within-imputation variance
   *   BV (tmpmat) between-imputation variance
   *   V (tmpmat) sum of within-imputation & btwn-imputation variance
   *   N (locmac) average #observations per dataset used for estimation
   *   sig (tmpmat) mean of the Sigma matrices across all the imputed datasets
   *   dfsig (tmpscalar) mean d.f. for Sigma, across all the imputed datasets
   *   nlength (locmac) #digits in N (where N is the # of observations)
   *   col (locmac) column number, used to format the output
   *   sksp (locmac) #spaces to skip, used to format the output
   *   eqnames (locmac) names of all equatns (if only 1 equ, begins with _)
   *   eqname (locmac) name of one equation in a multiple-equation model
   *   eqlast (locmac) last equation name that was printed on the screen
   *   pname (locmac) name of 1 parameter in the VC.
   *   coef (tmpscalar) point estimate for the ith coefficient or parameter
   *   se (tmpscalar) std error for ith point estimate
   *   tstat (tmpscalar) t-statistic for ith parameter
   *   df (tmpscalar) deg freedom associated with t-stat for ith parameter
   *   pvalue (tmpscalar) p-value for t-stat associated with the ith parameter
   * e-class and r-class values used:
   *   e(b) (matrix) beta-hat, the vector of point estimates
   *   e(V) (matrix) variance-covariance matrix of estimates
   *   r(newvars) (macro) list of all new vars generated to hold simulations
   else {                           /* if multiple imputxns */
      tempname bsum b Vsum V Nsum WV BV mmo sigsum sig dfsigsm dfsig
      if mod(`sims',`nfiles') == 0 { local simsper = `sims'/`nfiles' }
      else { local simsper=int(`sims'/`nfiles')+1 }  /* # sims per file    */
      tempfile misims                          /* temp ds to hold simulxns */
      * LOOP THROUGH EACH DATASET
      local i 1
      while `i' <= `nfiles' {                    
         * Load New Dataset
         di in g _n "Estimation number : " in y "`i' of `nfiles'" 
         local file : word `i' of `milist'
         di in g "Dataset being used: " in y "`file'"
         use `file', clear                         /* load new dataset     */
         * Rebuild Sample Definition and Command Line
         tempvar touse
         mark `touse' `if' `in'
         markout `touse' `depvar' `rhsvars'
         local cmdline `modname' `equlist' if `touse' /* build commandline 
            */ [`weight'`exp'], `options' l(`level')  
         * Estimate Parameters and Save Results
         if "`iout'" ~= "" { `cmdline' }           /* show interim output  */
         else { qui `cmdline' }                    /* hide interim output  */
         tempname b`i' V`i'                        /* b and VC matrix      */
         matrix `b`i'' = e(b)                      /* fetch 1xk b-vector   */
         matrix `V`i'' = e(V)                      /* fetch k x k variance */
         CK_drop "`rhscons'" `V`i''                /* were any x's dropped?*/
         * Simulate Parameters
         _simp, b(`b`i'') v(`V`i'') s(`simsper') g(`genname') `antisim' `drawt'
         local newvars `r(newvars)'                /* new variables        */
         _simsig2, s(`simsper') g(`genname') `antisim' m(`modname') n(`newvars')
         local newvars `r(newvars)'                /* re-capture list      */                    
         keep `newvars'                            /* keep the simulations */
         if `i' == 1 {
            matrix `sigsum' = r(Sigma)             /* running sum of Sigmas*/
            scalar `dfsigsm' = r(dfSigma)          /* running sum of d.f.  */
            matrix `bsum' = `b`i''                 /* running sum of betas */
            matrix `Vsum' = `V`i''                 /* running sum of V's   */
            scalar `Nsum' = `e(N)'                 /* running sum of #obs  */
            local bb (`b`i''-`b')'*(`b`i''-`b')    /* build matrix expressn*/
            qui save `misims'                      /* save sims in tmp file*/
         }
         else {
            matrix `sigsum' = `sigsum' + r(Sigma)
            scalar `dfsigsm' = `dfsigsm' + r(dfSigma)
            matrix `bsum' = `bsum' + `b`i''
            matrix `Vsum' = `Vsum' + `V`i''
            scalar `Nsum' = `Nsum' + `e(N)'
            local bb `bb'+(`b`i''-`b')'*(`b`i''-`b')
            append using `misims'                  /* append new simulxns  */
            qui save `misims', replace             /* save them            */
         }
         local i = `i' + 1                       
      }
      if mod(`sims',`nfiles') ~= 0 {
         tempvar u                                 /* to eliminate missg  */
         gen `u' = uniform()                       /* values & extra sims,*/
         sort `genname'1 `u'                       /* sort dataset & take */
         qui keep in 1/`sims'                      /* a random sample     */
      }
      local file : word 1 of `milist'              /* re-introduce 1st ds */
      merge using `file'                           /*   by merging w sims */
      drop _merge                                  /* drop the merge var  */
      * Compute combined estimates: b, V, Sigma
      scalar `mmo' = `nfiles' - 1                  /* expression for calcs*/
      matrix `b' = `bsum' / `nfiles'               /* point estimates of b*/
      matrix `WV' = `Vsum' / `nfiles'              /* within imp variance */
      matrix `BV' = (1+1/`nfiles')*(`bb')/`mmo'    /* between imp variance*/
      matrix `V' = `WV' + `BV'                     /* total variance      */
      local N = int(`Nsum'/`nfiles')
      matrix `sig' = `sigsum' / `nfiles'           /* sigma matrix         */
      scalar `dfsig' = `dfsigsm' / `nfiles'        /* sigma deg of freedom */
      * Report combined estimates: b and V
      tempname coef se tstat df pvalue
      local nlength = length("`N'")
      local col = 57 - `nlength'
      di in g _n(2) upper(substr("`modname'",1,1)) substr("`modname'",2,.) /*
         */ " estimates (via multiple imputation)" _col(`col') "Nobs = " /*
         */ in y %`nlength'.0f `N' _n
      di in g _dup(63) "-"
      * Format Dependent Variable names for output
      if `numeqs' > 1 { 
         local sksp = 8
         local dv             /* blank */
      }               
      else { 
         local sksp = 8 - length("`depvar'")
         local dv `depvar'
      } 
      di in g _skip(`sksp') "`dv' |" _skip(6) "Coef." _skip(3) /*
         */ "Std. Err."  _skip(7) "t" _skip(9) "d.f." _skip(4) "P>|t|"
      di in g _dup(9) "-" "+" _dup(53) "-"
      local eqnames : coleq(`V')
      local namepVC : colnames `V'
      local i 1
      while `i' <= colsof(`V') {
         gettoken eqname eqnames : eqnames         /* get first eq name   */
         if "`eqname'" ~= "_" {
            if "`eqname'" ~= "`eqlast'" {
               if `i' > 1 { di in g _dup(63) "-" }
               di in y "`eqname'" in g _col(10) "|"
               local eqlast `eqname'
            }
         }
         local pname : word `i' of `namepVC'       /* parameter name      */
         if `versn' > 6 { local pname = abbrev("`pname'",8) }
         scalar `coef' = `b'[1,`i']                /* ith coefficient     */
         scalar `se' = sqrt(`V'[`i',`i'])          /* its standard error  */
         scalar `tstat' = `coef' / `se'            /* its tstat           */
         scalar `df' = `mmo'*(1+`WV'[`i',`i']/`BV'[`i',`i'])^2
         scalar `pvalue' = tprob(`df',`tstat')     /* P>|t|               */
         local sksp = 8 - length("`pname'")        /* skip space          */
         di in g _skip(`sksp') "`pname' | " in y   /*
            */ _col(13) %9.0g `coef'               /*
            */ _col(24) %9.0g `se'                 /*
            */ _col(35) %9.3f `tstat'              /*
            */ _col(46) %9.0f `df'                 /*
            */ _col(55) %9.3f `pvalue'
         local i = `i' + 1
      }
      di in g _dup(63) "-" _n
   }                          
   * END CASE 2: ESTIMATION AND SIMULTION FROM SEVERAL MI DATASETS

   * GET UNIQUE LIST OF RHS AND OFFSET VARIABLES
   * Outputs from this segment of code
   *   rhsvars (locmac) all RHS and Offset vars.  No repeats or dropped vars
   * e-class and r-class values used:
   *   r(rhsvars) (macro) list of all *unique* rhs variables
   _getrhs "`rhsvars'"                             /* get unique rhs vars  */
   local rhsvars `r(rhsvars)'                      /* list of uniq rhs vars*/

   * COLLECT RESULTS FOR POSTING (MAY NEED TO MODIFY FOR NEW MODEL)
   * Have to reassign, b/c we're going to clear the e() result b4 reposting
   * Note: Must refer to modname here, b/c Stata d/n save k_cat for log,prob
   * Outputs from this segment of code
   *   k_cat (locmac) # of categories in categorical dependent variable
   *   cat (tempmat) holds the numeric values for those categories, eg (0,1,2)
   *   offset (locmac) name of offset variable
   *   basecat (locmac) name of basecat variable
   * e-class and r-class values used:
   *   e(k_cat) (scalar) # of categories in categorical dependent variable
   *   e(cat) (matrix) the numeric values for those categories
   *   e(offset) the offset
   *   e(basecat) name of basecat variable
   if "`modname'" == "logit" | "`modname'" == "probit" {
      tempname cat
      local k_cat 2
      matrix `cat' = (0,1)
   }
   else if "`e(k_cat)'" ~= "" {
      tempname cat
      local k_cat = `e(k_cat)'
      matrix `cat' = e(cat)
   }
   else { local k_cat 0 }  /* k_cat=0 if no categorical depvar */
   * Some kluges to fix problems with mlogit
   if "`modname'" == "mlogit" {
      local numeqs = `k_cat' - 1
      local i 2
      while `i' <= `numeqs' {
         local cons_`i' `cons_1'
         local rhs_`i' `rhs_1'
         local i = `i' + 1
      }
   }
   if "`e(offset)'" ~= "" { local offset `e(offset)' }
   if "`e(ibasecat)'" ~= "" { local ibaseca `e(ibasecat)' }
   if "`e(frm2)'" ~= "" { local frm2 `e(frm2)' }     /* time versus hazard */

   * COLLECT NAMES OF VARIABLES THAT CONTAIN SIMULATIONS
   local blist `newvars'
   local i 1
   while `i' <= `numeqs' {
      local rhslist `rhs_`i''
      while "`rhslist'" ~= "" {
         gettoken bname blist : blist    /* get bname, e.g. b1, b2, or b3  */
         local msn_`i' `msn_`i'' `bname' /* append b to list for equ i     */
         gettoken drop rhslist : rhslist /* shorten rhslist by dropping 1  */
      }
      if `cons_`i'' == 1 {
         gettoken bname blist : blist    /* get bname, e.g. b1, b2, or b3  */
         local msn_`i' `msn_`i'' `bname' /* append b to list for equ i     */
      }
      local i = `i' + 1
   }
   local asn `blist'                     /* ancillary parameters           */
      
   * PRINT SUMMARY
   di "Number of simulations  : `sims'"           /* Print # of simulations*/
   di "Names of new variables : `newvars'"        /* Print names of new v's*/
   if "`drawt'" ~= "" { di "Main sampling distrib  : multivariate T" }
   if "`antisim'" ~= "" { di "Type of simulation     : antithetical" }
   if "`milist'" ~= "" { di "Datasets used for MI   : `milist'" }

   * SAVE RESULTS (MAY NEED TO MODIFY FOR NEW MODEL)
   estimates clear                                /* CLEARS THE ESTIMATES */
   estimates post `b' `V', obs(`N')               /* post b's and VC matrix*/
   estimates local depvar `depvar'                /* dependent variable(s) */
   estimates local rhsvars `rhsvars'              /* list of uniq rhs vars */
   estimates local if `if'                        /* if expression         */
   estimates local in `in'                        /* in expression         */
   estimates local wt [`weight'`exp']             /* weight expression     */
   estimates local milist `milist'                /* list of mi datasets   */
   estimates local allsims `newvars'              /* list of new variables */
   if `sig'[1,1] ~= 0 {
      estimates matrix Sigma `sig'                /* post Sigma hat        */
      estimates scalar dfSigma = `dfsig'          /* post deg of freedom   */
   }   
   if `k_cat' > 0 { estimates matrix cat `cat' }
   estimates scalar k_cat = `k_cat'
   if "`ibaseca'" ~= "" { est scalar ibasecat = `ibaseca' }
   if "`offset'" ~= "" { est local offset `offset' }
   local i 1
   while `i' <= `numeqs' {
      estimates scalar cons_`i' = `cons_`i''
      estimates local rhs_`i' `rhs_`i''
      estimates local msn_`i' `msn_`i''
      local i = `i' + 1
   }
   estimates local frm2 `frm2'
   estimates scalar sims = `sims'
   estimates local asn `asn'
   estimates scalar k_eq = `numeqs'
   estimates local cmd estsimp `modname'          /* model name            */
   estimates local versn `versn'
end

*************** CHECKING PROGRAMS (MUST MODIFY FOR NEW MODEL) **************

   program define CKregres, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, NOConstant Hascons DEPname(varname) MSe1 *]
      if "`depname'" ~= "" { NOSUPPT depname(varname) }
      if "`mse1'" ~= "" { NOSUPPT mse1 }
      if "`hascons'" ~= "" { NOSUPPT hascons }
      if "`noconst'" ~= "" { return local cons_1 0 }
      else { return local cons_1 1 }
      return local nap 1   /* number of ancillary parameters */
   end

   program define CKsureg, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, NUMEQS(int 1) *]
      return local nap = `numeqs'*(1+`numeqs')/2  /* # uniq elements in sigma mat*/
   end

   program define CKlogit, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, NOCONstant ASIS OFFset(varname) *]
      if "`asis'" ~= "" { NOSUPPT asis }
      if "`offset'" ~= "" { NOSUPPT offset(varname) }
      if "`noconst'" ~= "" { return local cons_1 0 }
      else { return local cons_1 1 }
      return local nap 0   /* number of ancillary parameters */
   end

   program define CKprobit, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, NOCONstant ASIS OFFset(varname) *]
      if "`asis'" ~= "" { NOSUPPT asis }
      if "`offset'" ~= "" { NOSUPPT offset(varname) }
      if "`noconst'" ~= "" { return local cons_1 0 }
      else { return local cons_1 1 }
      return local nap 0   /* number of ancillary parameters */
   end

   program define CKologit, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, TOUSE(varname) OFFset(varname) *]
      if "`offset'" ~= "" { NOSUPPT offset(varname) }
      gettoken depvar : varlist
      qui tab `depvar' if `touse'
      return local nap = `r(r)' - 1  /* #categories in depvar, minus one*/
      return local cons_1 0
   end

   program define CKoprobi, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, TOUSE(varname) OFFset(varname) *]
      if "`offset'" ~= "" { NOSUPPT offset(varname) }
      gettoken depvar : varlist
      qui tab `depvar' if `touse'
      return local nap = `r(r)' - 1  /* #categories in depvar, minus one*/
      return local cons_1 0
   end

   program define CKmlogit, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, TOUSE(varname) NOConstant *]
      if "`noconst'" ~= "" { return local cons_1 0 }
      else { return local cons_1 1 }
      gettoken depvar rhsvars : varlist
      local nrhsvar : word count `rhsvars'      /* # of independent vars  */
      qui tab `depvar' if `touse'
      return local nap = (`r(r)'-2)*(`nrhsvar' + `return(cons_1)')
      /* Note: the mlogit model does not really have any ancillary params,*/
      /* but we are inflating the value of nap to compensate for the fact */
      /* that we are under-counting the # of main parameters and constants*/
      /* The problem arises because Stata does not treat mlogit as a */
      /* multiple-equ model.  This is what Jason calls a "Kluge," but we */ 
      /* gotta do it!  Also note that the # of parameters does not change */
      /* when the user imposes constraints.  The constrained parameters are */
      /* simply "estimated" to be equal to their constrained values.  :)  */
   end

   program define CKpoisso, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, NOCONstant *]
      if "`noconst'" ~= "" { return local cons_1 0 }
      else { return local cons_1 1 }
      return local nap 0   /* number of ancillary parameters */
   end

   program define CKnbreg, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, NOCONstant Dispersion(str) *]
      if "`dispersion'" ~= "" { NOSUPPT dispersion }
      if "`noconst'" ~= "" { return local cons_1 0 }
      else { return local cons_1 1 }
      return local nap 1  /* number of ancillary parameters=1 (ln(gamma)) */
   end

   program define CKweibul, rclass
      version 6.0
      args 0
      syntax varlist(ts) [, NOCONStant ANCillary(str) STrata(str) FRailty(str) *]
      if "`ancillary'" ~= "" { NOSUPPT ancillary }
      if "`strata'" ~= "" { NOSUPPT strata }
      if "`frailty'" ~= "" { NOSUPPT frailty }
      if "`noconst'" ~= "" { return local cons_1 0 }
      else { return local cons_1 1 }
      return local nap 1   /* number of ancillary parameters=1 (ln(p)) */
   end

   program define NOSUPPT
      version 6.0
      args optname
      di in r _n "Clarify does not support the `optname' option."
      exit 198
   end

   program define CK_drop
      * checks to see if Stata has dropped a variable
      args rhscons V
      local namepVC : colnames `V'
      while "`rhscons'" ~= "" {
         gettoken varname rhscons : rhscons
         gettoken pname namepVC : namepVC
         if "`varname'" ~= "`pname'" {
            di in r _n "Stata has dropped one of your independent variables."
            di in r "Please re-specify your model and try again."
            exit 198
         }
      }         
   end

*************************** SIMULATION UTILITIES ****************************

*! version 1.3.1  April 24, 1999  Michael Tomz
* Simulates parameters from multivar normal after a model has been estimated
* Inputs:  b, a vector containing the last parameter estimates
*          v, the variance-covariance matrix of the last estimates
*          sims, the number of simulations
*          genname, a stub-name for variables to generate
*          antisim, telling simp to perform antithetical simulations
*          drawt, for drawing b's from multi-T rather than multi-Normal
* Outputs: simulated parameters are saved to dataset in memory
*          newvars, the names of new variables holding the simd parameters
*          namepVC, the names of all parameters in the VC that were simulated
* Question: does drawt work adequately in all cases?  Reads e(df_r)...
program define _simp, rclass
   version 6.0

   di _n "Simulating main parameters.  Please wait...."
   syntax [, B(string) V(string) Sims(int 1000) Genname(string) ANTIsim DRAWT]

   * GENERATE RANDOM NORMAL OR RANDOM T VARIABLES
   if `sims' > _N {                                 /* expand ds to fit sims*/
      di in y _n "Note: Clarify is expanding your dataset from " _N /*
         */ " observations to `sims'" _n "observations in order to " /*
         */ "accommodate the simulations.  This will append" _n "missing " /*
         */ "values to the bottom of your original dataset." _n
      qui set obs `sims'
   }            
   if "`antisim'"~="" {                             /* antithetical sims    */
      local top = int(`sims'/2 + .5)                /*   calculate boundary */
      local bot = `top' + 1                         /*   for top&bottom half*/
   }
   if "`drawt'" ~= "" {                             /* for drawing from T   */
      tempvar u tfactor                             /* rather than Normal   */
      qui g `u' = uniform() in 1/`sims'
      if "`antisim'"~="" { qui replace `u'=1-`u'[_n-`top'] in `bot'/`sims' }
      qui gen `tfactor' = sqrt(e(df_r)/invchi(e(df_r),`u')) in 1/`sims'
   }
   local numpVC = colsof(`v')
   local i 1
   while `i' <= `numpVC' {
      tempvar u c`i'
      qui g `u' = uniform() in 1/`sims'
      if "`antisim'"~="" { qui replace `u'=1-`u'[_n-`top'] in `bot'/`sims' }
      if "`drawt'" == "" { qui gen `c`i''= invnorm(`u') in 1/`sims' }
      else { qui gen `c`i'' = invnorm(`u')*`tfactor' in 1/`sims' }
      local cnames `cnames' `c`i''                  /* collect names of vars*/
      local newvars `newvars' `genname'`i'          /* collect names newvars*/
      local i = `i' + 1
   }

   * SIMULATE BETAS FROM NORMAL OR T DISTRIBUTION
   tempname A row
   _chol `v' `numpVC'                              /* Cholesky decomp of V */
   matrix `A' = r(chol)
   matrix colnames `A' = `cnames'                /* cols to `c1'..`c`numpVC'' */
   matrix colnames `A' = sameeq:                 /* Thx to Randy Stevenson */
   di "% of simulations completed: " _c        
   local i 1
   while `i' <= `numpVC' {
      di int(`i'*100/`numpVC') "% " _c             /* display progress     */
      matrix `row' = `A'[`i',1...]                  /* get i^th row of A    */
      tempvar b`i'                                  /* temporary variable   */
      matrix score `b`i'' = `row'                   /* c(NxK) * row(1xK)'   */
      qui replace `b`i'' = `b`i'' + `b'[1,`i']      /* add mean             */
      local i = `i' + 1
   }

   * SAVE AND LABEL THE PARAMETERS
   local namepVC : colnames(`v')                    /* all parameters in VC */
   local eqnames : coleq(`v')                       /* all equs             */
   tokenize "`eqnames'"                             /* check for distinct   */
   if "`1'" ~= "_" { local haseqnm 1 }              /*   equation names in  */
   else { local haseqnm 0 }                         /*   the var-cov matrix */
   local i 1
   while `i' <= `numpVC' {                          /* for each parameter:  */
      qui gen `genname'`i' = `b`i''                 /*   save sims to dset  */
      local pname : word `i' of `namepVC'           /*   fetch name of param*/
      * if has equation name, add eqname to label
      if `haseqnm' {                                
         local eqname : word `i' of `eqnames'       
         label var `genname'`i' "Simulated `eqname':`pname' parameter"
      }                              
      * otherwise use simple label w/o an eqname
      else { label var `genname'`i' "Simulated `pname' parameter" }
      local i = `i' + 1
   }
   order `newvars'
   di _n
   return local newvars `newvars'  /* names of newvars that were created */

end

*! version 1.3  June 7, 2000
* Simulates sigmas
* reads...
*          e(N)
*          e(df_r), the scalar containing residual d.f. for multi-T distrib
*          e(Sigma), the disturbance matrix sigma
*          e(dfSigma), the degrees of freedom associated with e(Sigma)
program define _simsig2, rclass

   version 6.0
   syntax [, Sims(int 1000) Genname(string) ANTIsim Modname(string) /*
      */ Newvars(string)]

   * IF THE MODEL HAS A SIGMA MATRIX, FETCH THE MATRIX AND ITS D.F.
   tempname Sigma dfSigma
   if "`modname'" == "regress" {
      matrix `Sigma' = e(rmse)^2         /* sigma^2 (1 x 1 matrix)         */
      scalar `dfSigma' = e(df_r)         /* degrees of freedom: n-k        */
      local p 1                          /* dimension of Sigma matrix */
   }  
   else if "`modname'" == "sureg" {
      matrix `Sigma' = e(Sigma)             /* sigma matrix (p x p) */
      scalar `dfSigma' = int(e(N)-e(k)/e(k_eq))  /* average d.f.  */
      * NOTE! CHECK TO MAKE SURE THIS "AVERAGING" IS OK, ROBUST, ETC
      local p = colsof(`Sigma')               /* dimension of Sigma matrix */
   }
   else { 
      return local newvars `newvars'
      matrix `Sigma' = 0                /* Return 0 as a placeholder      */
      return matrix Sigma `Sigma'       
      return scalar dfSigma = 0         /* Return 0 as a placeholder      */
      exit
   }

   if `p' == 1 {

      * If p=1, we are dealing with a 1x1 sigma matrix, as in linear 
      * regression with a homoskedastic variance.  We will draw simulations
      * of sigma^2 from the scaled inverse chi-squared distribution.
      * Output: a new variable containing the simulations of sigma^2.  The 
      * name of this new variable is appended to `newvars', a macro containing
      * a list of all simulated variables

      * DRAW VALUES OF SIGMA-SQUARED FROM INVERSE CHI-SQUARED
      di _n "Simulating sigma-squared.  Please wait"
      tempvar u sigs
      qui g `u' = uniform() in 1/`sims'
      if "`antisim'"~="" {
         local top = int(`sims'/2 + .5)                  /* calculate boundary */
         local bot = `top' + 1                           /* for top&bottom half*/
         qui replace `u'=1-`u'[_n-`top'] in `bot'/`sims'
      }
      scalar `sigs' = `Sigma'[1,1]                   /* sigma squared */
      qui g `sigs'=`sigs'*(`dfSigma')/invchi(`dfSigma',`u') in 1/`sims'

      * SAVE AND LABEL THE SIMULATIONS
      local nextvar : word count `newvars'
      local nextvar = `nextvar' + 1
      qui g `genname'`nextvar' = `sigs'
      label var `genname'`nextvar' "Simulated sigma^2 parameter"
      local newvars `newvars' `genname'`nextvar'
      
   }

   else {

      * If p>1, we have a multi-element Sigma matrix, as is produced by
      * seemingly unrelated regression.  We will draw simulations of this
      * matrix from the inverse Wishart distribution.
      * Note: the expected draw from an inverse wishart is S/(df-p-1).
      * To get a draw roughly equal to S, we need to implement a correction.
      * Correcting by (df-p-1) is problematic, because this value can be
      * zero or negative.  Instead we correct by df, the degrees of freedom.
      * Thus, the expected draw from our inverse wishart is S*df/(df-p-1),
      * which is not exactly S but is close.  The error is conservative,
      * since df > (df-p-1).  Also, the mode of the Wishart is S/(df+p+1), so
      * our correction gives a value that is between the mean and the mode.

      * Output: unique elements of the pxp matrix are saved as new 
      * variables in memory.  The names of these new variables are appended
      * to `newvars', a macro containing a list of all simulated variables

      * INITIALIZE VARS THAT WILL HOLD THE SIMULATIONS
      di _n "Simulating Sigma matrix.  Please wait" _c
      local ue = (`p'+`p'^2)/2                    /* unique elements of S */
      local i 1
      while `i' <= `ue' {
         tempvar sigs`i'
         qui gen `sigs`i'' = .                    /* initialize to missing*/
         local i = `i' + 1                        
      }
      
      * CALCULATE SINVERS AND APPLY CHOLESKY
      *    The p x p symmetric scale matrix is S = df*Sigma
      *    Its inverse is Sinvers
      *    The Cholesky of Sinverse is L
      tempname Sinvers L T W                           
      matrix `Sinvers' = syminv(`dfSigma'*`Sigma')
      _chol `Sinvers' `p'                         /* sqrt of Sinvers matrx*/  
      matrix `L' = r(chol)

      * SIMULATE A BUNCH OF CHI SQUARED RANDOM VARIABLES
      * Note: dfSigma is the degrees of freedom
      local i 1
      while `i' <= `p' {                             /* simulate chi squ's   */
         di "." _c                                   /* report progress      */      
         tempvar chi`i'
         qui gen `chi`i'' = sqrt(invchi(`dfSigma'-`i'+1,uniform())) in 1/`sims'
         local chiname `chiname' `chi`i''
         local i = `i' + 1
      }

      * NOW DO THE HARD STUFF     
      di _n "% of simulations completed: 0% " _c        
      matrix `T' = J(`p',`p',0)                   /* initialize mat to 0's  */
      local sim 1                                 /* each loop is 1 draw    */
      while `sim' <= `sims' {
         local sofar = 10*`sim'/`sims'
         if int(`sofar')==`sofar'{di `sofar'*10 "% "_c}
         matrix `T'[1,1] = `chi1'[`sim']             /* fill diagonals w chis  */
         local i 2                                   /* fill off-diagonals in  */
         while `i' <= `p' {                          /*    LOWER triangle with */
            local j 1                                /*    random N(0,1)       */
            while `j' < `i' {
               matrix `T'[`i',`j'] = invnorm(uniform())         
               local j = `j' + 1
            }
            matrix `T'[`i',`i'] = `chi`i''[`sim']    /* filling more diagonals */
            local i = `i' + 1
         }
         matrix `W' = syminv(`L'*`T'*`T''*`L'')      /* draw from Wish, invert */
         local c 1                                   /* counter                */
         local i 1                                   /* break-apart the matrix */
         while `i' <= `p' {                          /*   and store elements in*/
            local j 1                                /*   variables `sigs1',   */
            while `j' <= `i' {                       /*   `sigs2',..,`sigs`ue''*/
               qui replace `sigs`c''=`W'[`i',`j'] in `sim' /* store value      */
               local sigl`c' "Simulated Sigma[`i',`j'] parameter" /* sig label */
               local c = `c' + 1                           
               local j = `j' + 1
            }
            local i = `i' + 1
         }
         local sim = `sim' + 1
      }

      * SAVE AND LABEL THE SIMULATIONS
      local lastvar : word count `newvars'
      local i 1
      while `i' <= `ue' {
         local nextvar = `lastvar' + `i'
         qui gen `genname'`nextvar' = `sigs`i''
         label var `genname'`nextvar' "`sigl`i''"
         local newvars `newvars' `genname'`nextvar'
         local i = `i' + 1
      }

   }   

   di _n  /* formatting */
   return local newvars `newvars'
   return matrix Sigma `Sigma'       /* post sigma matrix              */
   return scalar dfSigma = `dfSigma'

end

************************** COMPUTATION UTILITIES ****************************

*! version 1.3  April 24, 1999  Michael Tomz
* Cholesky decomposition of an arbitrary matrix
* Input: V, the original matrix
*        k, the dimension of the matrix
* Output: chol, the lower-triangle cholesky of V
program define _chol, rclass
   version 6.0
   args V k
   tempname A
   capt matrix `A' = cholesky(`V')             /* square root of VC matrix  */
   if _rc == 506 {                             /* If VC ~ pos definite, ... */
      tempname eye transf varianc vcd tmp
      mat `eye' = I(`k')                       /* identity matrix           */
      mat `transf' = J(1,`k',0)                /* initialize transf matrix  */
      local i 1
      while `i' <= `k' {
         scalar `varianc' = `V'[`i',`i']       /* variance of parameter `i' */
         if `varianc' ~= 0 {                   /* if has variance, add row  */
            mat `tmp' = `eye'[`i',1...]        /* of `eye' to transf matrix */
            mat `transf' = `transf' \ `tmp'
         }
         local i = `i' + 1
      }
      mat `transf' = `transf'[2...,1...]       /* drop 1st row of transf mat*/
      mat `vcd' = `transf'*`V'*`transf''       /* decomposed VC (no 0 rows) */
      mat `A' = cholesky(`vcd')                /* square root of decomp VC  */
      mat `A' = `transf''*`A'*`transf'         /* rebuild full sq root mat  */               
   }
   else if _rc { matrix `A' = cholesky(`V') }  /* redisplay error message   */
   return matrix chol `A'
end


************************** OUTPUT UTILITIES **********************************

*! version 1.3.1  April 24, 1999  Michael Tomz
* Compiles list of unique RHS vars _actually used_ in estimation
* Eliminates duplicate names and appends the offset/exposure variable
* Input: rhsvars, the list of rhsvars originally appearing in command line
* Uses:  e(offset), the name of offset or exposure variable, if it exists
* Output: new list containing unique RHS vars & offset used in estimation
program define _getrhs, rclass
   version 6.0
   args rhsvars
   * append the offset/exposure variable to the list of rhs variables
   if "`e(offset)'" ~= "" {                         /* add offset/exposure */
      tokenize "`e(offset)'", parse("()")           /*  to end of the list */
      if "`1'"=="ln" { local rhsvars `rhsvars' `3' }
      else { local rhsvars `rhsvars' `1' }
   }
   * eliminate repeats from list of rhsvars, save shortened list as `newlist'
   while "`rhsvars'" ~= "" {
      * get first variable in rhsvars and append to newlist
      gettoken var rhsvars : rhsvars
      local newlist `newlist' `var'
      * drop any repeats of that variable from rhsvars
      while "`rhsvars'" ~= "" {
         gettoken var2 rhsvars : rhsvars
         if "`var'" ~= "`var2'" { local oldlist `oldlist' `var2' }
      }
      local rhsvars `oldlist'       /* reset rhsvars to oldlist */
      local oldlist                 /* reset oldlist to empty */
   }
   return local rhsvars `newlist'   /* return the list of uniq rhs vars */
end

