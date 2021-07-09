*! version 1.0.1 20040119                                      (SJ4-2: st0060)

*  J. Levinsohn, A. Petrin, and B. Poi
*  Created: 20030520

*  Levinsohn-Petrin estimator with option for value-added or revenue
*  Usage:
*    levpet depvar [if] [in], free(freevars) proxy(proxy1 [proxy2]) 
*           capital(capitalvar) i(panelvar) t(timevar) reps(BS reps)
*           level(sig. level) [VAlueadded | REVenue] justid
*
*    where depvar     = log value added if va specified (line search)
*                     = log revenues if revenue specified (GMM)
*          freevars   = log freely variables inputs (e.g. blue & white c. labor)
*          proxy      = log intermediate input(s)
*                       Max 2 if value added is LHS variable
*                       Max 1 if revenue is LHS variable
*          capitalvar = log capital
*          i          = panel ID variable
*          t          = time variable
*          reps       = number of bootstraps to use
*          level      = significance level for z-stats and conf. intervals
*          valueadded = depvar represents log value added (line search)
*                       (valueadded is default)
*          revenue    = depvar represents log gross revenue (GMM)
*          justid     = Uses only capital and lagged proxy as
*                       instruments in GMM
*          grid       = Uses grid search instead of -nl- for GMM

capture program drop levpet
program define levpet, sortpreserve eclass

   version 7.0
   syntax varname [if] [in], free(varlist)                       /*
          */       proxy(varlist numeric min=1 max=2)            /*
          */       capital(varname)                              /* 
          */       [i(varname) t(varname) reps(integer 50)       /*
          */        REVenue VAlueadded Level(int $S_level)       /*
          */        justid grid] 
          
   local depvar `varlist'
   
   marksample touse
   markout `touse' `free' `proxy' `capital' `i' `t'
   
   /* Syntax check: is data tsset? */
   if ("`i'" == "" | "`t'" == "") {
      capture tsset
      if (_rc != 0) {
         di as error "You must tsset your data or specify i() and t()."
         error _rc
      }
      else {
         local i = r(panelvar)
         local t = r(timevar)
      }
   }
   else {
      quietly tsset `i' `t'
   }
   /* Is level valid? */
   if (`level' < 10 | `level' > 99) {
      di as error "level must be between 10 and 99"
      error 198
   }
   /* Value added or revenue? */
   if ("`revenue'" != "" & "`valueadded'" != "") {
      di as error "Only one of revenue and valueadded can be specified."
      exit 198
   }
   if ("`revenue'" != "") {
      local model "revenue"
   }
   else {
      local model "valueadded"
   }
   local numprox : word count `proxy'
   if ("`model'" == "revenue" & `numprox' > 1) {
      di as error "Only one proxy variable can be used with revenue."
      exit 198
   }
   /* Reps reasonable? */
   if (`reps' < 2) {
      di as error "reps() must be at least 2."
      exit 198
   }
   /* Just-identified GMM? */
   local just = 0
   if ("`justid'" != "" & "`model'" != "revenue") {
      di as error "justid can only be used with revenue (GMM) model."
      exit 198
   }
   else if "`justid'" != "" {
      local just = 1
   }
   /* Grid search? */
   local gsrch = 0
   if ("`grid'" != "" & "`model'" != "revenue") {
      di as error "grid can only be used with revenue (GMM) model."
      exit 198
   }
   else if "`grid'" != "" {
      local gsrch = 1
   }

   qui count if `touse'
   loc capn = r(N)

   /* Since we're using version 7 syntax, we need to build up
      a list of the statistics that we want to bootstrap.     */
   local rmacs ""
   foreach var in `free' `capital' {
      local rmacs "`rmacs' (r(`var'))"
   }
   /* If revenue, incl. proxy */
   if ("`model'" == "revenue") {
      local rmacs "`rmacs' (r(`proxy'))"   /* there's only one */
   }

   /* To get clustering to work right, we need to bsample and
      post everything ourselves.				*/
   quietly {
      tempfile postfile datafile
      tempname post
      tempvar idvar
      gen `idvar' = `i'
      preserve
      keep if `touse'
      loc cmd "`depvar' , free(`free') proxy(`proxy') capital(`capital') "
      /* First do it to the original sample. */
      tsset `idvar' `t'
      if ("`model'" == "valueadded") {
         lp_srch `cmd' i(`idvar') t(`t')
      }
      else {
         /* Need to store off the final values of the sample moments */
         global LPone = 1   /* indicates orig. data */
         lp_gmm `cmd' i(`idvar') t(`t') converrs(0) just(`just') grid(`gsrch')
         global LPone = 0   /* prevents overwrite during bootstrap */
      } 
      local converrs = 0
      foreach x of local rmacs {
         if (`x' >= .) {
            local converrs = 1
            noi di as error  /*
*/ "Insufficient variation to identify the capital and intermediate input"
            noi di as error /*
*/ "coefficients separately.  Bootstrapping for first-stage parameters only."
         }
      }
      if ("`model'" == "valueadded") { /* no proxies to post */
         postfile `post' `free' `capital' using `"`postfile'"', /*
            */ double replace
         local rmacs ""
         foreach var in `free' `capital' {
            local rmacs "`rmacs' (r(`var'))"
         }
      }
      else {
         if `converrs' == 0 {
            postfile `post' `free' `capital' `proxy' using `"`postfile'"', /*
               */ double replace
            local rmacs ""
            foreach var in `free' `capital' {
               local rmacs "`rmacs' (r(`var'))"
            }                        
            local rmacs "`rmacs' (r(`proxy'))"   /* there's only one */
         }
         else {
            /* We had convergence problems, only doing free vars */
            postfile `post' `free' using `"`postfile'"', double replace
            local rmacs ""
            foreach var in `free'  {
               local rmacs "`rmacs' (r(`var'))"
            }
         }   
      }
      post `post' `rmacs'
      /* Now do it `reps' times. */
      forvalues cnt = 1/`reps' {
         noi di "." _continue
         restore, preserve
         keep if `touse'
         tempvar idvar
         bsample, cluster(`i') idcluster(`idvar')
         if ("`model'" == "valueadded") {
            lp_srch `cmd' i(`idvar') t(`t')
         }
         else {
            lp_gmm `cmd' i(`idvar') t(`t') converrs(`converrs') /*
               */ just(`just') grid(`gsrch')
         }
         post `post' `rmacs'
      }
      postclose `post'
      /* drop the LPone and LPmoments since we're done with them */
      if ("`model'" == "revenue") {
         macro drop LPone
         mat drop LPmoments
      }
      
      /* Use post results to make e(b) and e(V).  
         First obs in postfile is original sample results. */
      tempname evar eb
      use `"`postfile'"', clear
      mat accum `evar' = * in 2/l , deviations noconstant 
      mat `evar' = `evar' / (r(N) - 1)
      mkmat * in 1, matrix(`eb')
      /* Compute a Wald test for constant returns if no errors */
      if `converrs' == 0 {
         tempname capr diff rvri waldcrs junk
         loc bsize = colsof(`eb')
         mat `capr' = J(1, `bsize', 1)
         mat `rvri' = syminv(`capr'*`evar'*`capr'')
         mat `diff' = `eb'*`capr'' - 1
         mat `junk' = `diff'*`rvri'*`diff'
         scalar `waldcrs' = trace(`junk')
      }
      restore
      estimates post `eb' `evar' , esample(`touse') depname(`"`depvar'"') /*
            */ obs(`capn')
      if `converrs' == 0 {
         estimates scalar waldcrs = `waldcrs'
      }
      estimates local depvar `depvar'
      if ("`model'" == "revenue") {
         estimates local model "revenue"
      }
      else {
         estimates local model "value added"
      }
      estimates local predict "levpet_p"
      estimates local cmd "levpet"
      tsset `i' `t'
   }  /* End of quietly block */
   
   di _n _n
   qui xtdes , i(`i') t(`t')
   di as text "Levinsohn-Petrin productivity estimator" 
   di
   if ("`model'" == "revenue") {
      di as text "Dependent variable represents revenue." _continue
   }
   else {
      di as text "Dependent variable represents value added." _continue
   }
   di _col(49) as text "Number of obs      = " as result %9.0f `capn'
   di as text "Group variable (i): `i'" _continue
   di _col(49) as text "Number of groups   = " as result %9.0f r(N)
   di as text "Time variable (t): `t'" 
   di _col(49) as text "Obs per group: min = " as result %9.0f r(min)
   di _col(49) as text "               avg = " as result %9.1f r(mean)
   di _col(49) as text "               max = " as result %9.0f r(max)
   di
   estimates display, level(`level')
   if `converrs' == 0 {
      di as text "Wald test of constant returns to scale: Chi2 = " /*
         */ as result %6.2f e(waldcrs) as text " (p = " /*
         */ as result %6.4f chi2tail(1, e(waldcrs)) as text ")."
   }
   
end
