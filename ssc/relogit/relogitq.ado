*! Version 1.1.1  October 28, 1999
*  (C) Copyright 1999 Michael Tomz, Gary King, and Langche Zeng.
*  Current version available at http://gking.harvard.edu
*  RElogitQ: Quantities of Interest from Rare Events Logistic Regression

program define relogitq, rclass
   version 6.0
   if "`e(cmd)'" ~= "relogit" {
      di in r _n "You must run relogit before relogitq."
      exit 198
   }
   ck_xc                                          /* is xc_mrt present?     */
   _strip `"`0'"'                                 /* strip fd wrappers      */
   local fd `r(fd)'                               /* save arg in fd(arg)    */
   local 0 `r(rest)'                              /* rest of command line   */
   syntax [, PR RR(str) CHANGEx(str) LISTX MLE    /*
      */ UNBIased SIMS(numlist integer max=1 >0)  /*
      */ BAYES Level(numlist integer max=1 >0 <100)]

   local analyt : word count `bayes'`unbiased'`mle'  /* analytical methods? */
   if `analyt' > 1 {
      di in r _n "Error: Bayes, Unbiased & MLE options are mutually exclusive"
      exit 198
   }
   local p `e(p)'			             /* proportion of 1's in pop */
   gettoken pLO pHI : p			      /* upper and lower bound    */
   if `analyt' > 0 & "`pHI'" ~= "" {
      di in r _n "Bayes, unbiased and MLE options are not available when " _c
      di in r "the fraction of " _n "1's in the population is not known."
      exit 198
   }
   if "`level'" == "" { local level $S_level }/* level for confid interval */
   local lo = (100-`level')/2                 /* lower bound of confid int */
   local hi = `lo' + `level'                  /* upper bound of confid int */
   if "`fd'" ~= "" {
      if "`changex'" == "" {
         di in r _n "If you request a first difference, you must specify " _c
         di in r "the values of" _n "X by using the changex() option"
         exit 198
      }
      ck_rr `fd'
   }
   else {
      if "`changex'" ~= "" {
         di in r _n "If you include the changex() option, you must request "
         di in r "a first-difference by wrapping one of the options in fd()."
         exit 198
      }
      if "`pr'`rr'" == "" { local pr pr }         /* calculate pr by default*/
   }

   * PARSE CHANGEX AND RELATIVE RISK REQUESTS
   _changex `"`changex'"'                         /* parse changex requests */
   local nx `r(nx)'                               /* # sets of changed x's  */
   local i 1
   while `i' <= `nx' {
      local slist`i' `r(slist`i')'                /* list of changes: start */
      local elist`i' `r(elist`i')'                /* list of changes: end   */
      local i = `i' + 1
   }
   _changex `"`rr'"'                              /* parse relrisk requests */
   local nrr `r(nx)'                              /* # sets of rel risks    */
   local i 1
   while `i' <= `nrr' {
      local srr`i' `r(slist`i')'                  /* list of changes: start */
      local err`i' `r(elist`i')'                  /* list of changes: end   */
      local i = `i' + 1
   }

   * RUN SETX TO PRODUCE CHANGEX AND RR SCENARIOS
   local i 1                                      
   while `i' <= `nx' {                            /* FIRST DIFFERENCES      */
      if "`pHI'" == "" {
         tempname xcS`i' xcE`i'                      /* xcStart, xcEnd vectors */     
         setx `slist`i'' $mrt_seto keepmrt           /* set starting x's       */
         matrix `xcS`i'' = r(mrt_xc)                 /* save starting x's      */
         setx `elist`i'' $mrt_seto keepmrt           /* set ending x's         */
         matrix `xcE`i'' = r(mrt_xc)                 /* save ending x's        */
      }
      else {
         tempname xcSL`i' xcSH`i' xcEL`i' xcEH`i'
         setx `slist`i'' $mrt_seto keepmrt           /* set starting x's       */
         matrix `xcSL`i'' = r(mrt_xcL)
         matrix `xcSH`i'' = r(mrt_xcH)
         setx `elist`i'' $mrt_seto keepmrt           /* set ending x's         */
         matrix `xcEL`i'' = r(mrt_xcL)
         matrix `xcEH`i'' = r(mrt_xcH)
      }
      local i = `i' + 1
   }
   local i 1
   while `i' <= `nrr' {                           /* RELATIVE RISKS         */
      if "`pHI'" == "" {
         tempname rrS`i' rrE`i'                
         setx `srr`i'' $mrt_seto keepmrt
         matrix `rrS`i'' = r(mrt_xc)
         setx `err`i'' $mrt_seto keepmrt
         matrix `rrE`i'' = r(mrt_xc)
      }
      else {
         tempname rrSL`i' rrSH`i' rrEL`i' rrEH`i'
         setx `srr`i'' $mrt_seto keepmrt
         matrix `rrSL`i'' = r(mrt_xcL)
         matrix `rrSH`i'' = r(mrt_xcH)
         setx `err`i'' $mrt_seto keepmrt
         matrix `rrEL`i'' = r(mrt_xcL)
         matrix `rrEH`i'' = r(mrt_xcH)
      }
      local i = `i' + 1
   }

   * SIMULATE PARAMETERS FROM MULTIVARIATE NORMAL
   tempname b V A row
   matrix `b' = e(b)                                /* parameter estimates  */
   matrix `V' = e(V)                                /* var-cov matrix of est*/
   local nptosim = rowsof(`V')		           /* # params to simulate */
   tempvar keepme			                  /* mark the original ds */
   mark `keepme'					    /* to be restored later */
   if "`sims'" == "" { local sims 1000 }            /* 1000 sims by default */
   if `sims' > _N { qui set obs `sims' }            /* expand ds to fit sims*/
   local i 1
   while `i' <= `nptosim' {
      tempvar c`i'
      qui gen `c`i''=invnorm(uniform()) in 1/`sims'
      local cnames `cnames' `c`i''                  /* collect names of vars*/
      local i = `i' + 1
   }
   _chol `V' `nptosim' `A'                          /* Cholesky decomp of v */
   matrix colnames `A' = `cnames'                   /* rename cols to       */
   local i 1
   while `i' <= `nptosim' {
      matrix `row' = `A'[`i',1...]                  /* get i^th row of A    */
      tempvar b`i'                                  /* temporary variable   */
      local bsims `bsims' `b`i''                    /* names of all b's     */      
      matrix score `b`i'' = `row'                   /* c(NxK) * row(1xK)'   */
      qui replace `b`i'' = `b`i'' + `b'[1,`i']      /* add mean             */
      local i = `i' + 1
   }
   qui drop `cnames'
 
   * CREATE LOW AND HIGH INTERCEPT
   if "`pHI'" ~= "" {
      summarize `e(depvar)' if e(sample), meanonly
      local ybar = r(mean)
      tempvar bHI bLO
      qui gen `bLO'=`b`nptosim''-ln(1-`pLO')+ln(`pLO')-ln(`ybar')+ln(1-`ybar')
      qui gen `bHI'=`b`nptosim''-ln(1-`pHI')+ln(`pHI')-ln(`ybar')+ln(1-`ybar')
      local i 1
      while `i' < `nptosim' {
         local bsimsNC `bsimsNC' `b`i''             /* sims w/o constant   */
         local i = `i' + 1
      }
      local bsimsLO `bsimsNC' `bLO'                 /* sims w/ lo constant */
      local bsimsHI `bsimsNC' `bHI'		    /* sims w/ hi constant */
   }
  
   if `nptosim' > `e(df_m)' { local k ,1 }         /* append constant to xc? */
   if "`listx'" ~= "" { setx }			   /* list chosen x-values   */

   * PROBABILITIES
   tempname xc xcL xcH AnaXb AnaPr C
   tempvar SimXb SimPr SimXbLO SimXbHI SimPrLO SimPrHI
   if "`pr'" ~= "" {
      if "`pHI'" == "" {
         matrix `xc' = (mrt_xc`k')                  /* xchosen (vector)      */
         matrix colnames `xc' = `bsims'             /* rename cols of xc     */
         qui matrix score `SimXb' = `xc'		    /* simulated xbetas      */
         qui gen `SimPr' = 1/(1+exp(-`SimXb'))      /* simulated Pr(Y=1)     */
         if `analyt' == 0 { 
            _pctile `SimPr', p(50)			    /* simulated median      */
            return scalar Pr = r(r1)
         }
         else {
            matrix `AnaXb' = (mrt_xc`k')*`b''         /* Analytical xbeta    */
            scalar `AnaPr' = 1/(1+exp(-`AnaXb'[1,1])) /* Analytical Pr(Y=1)  */
            if "`mle'" == "" {
               mat `C' = (`AnaPr'-`AnaPr'^2)*(.5-`AnaPr')     /* correction  */
               mat `C' = `C'*(mrt_xc`k')*`V'*(mrt_xc`k')'     /* correction  */
               if "`bayes'"~="" {scalar `AnaPr'=`AnaPr'+`C'[1,1]}  /* bayes  */
               else { scalar `AnaPr' = `AnaPr' - `C'[1,1] }        /* unbias */
               _recode `AnaPr'                        /* keep wi [0,1] bound */
            }
            return scalar Pr = `AnaPr'	              /* Analytical mean     */
         }
         qui _pctile `SimPr', p(`lo',`hi')            /* calc percentiles    */
         return scalar PrL = r(r1)	              /* lower bound of ci   */
         return scalar PrU = r(r2)		      /* upper bound of ci   */
      }
      else {
         matrix `xcL' = (mrt_xcL`k')                  /* xchosen|pLO (vector)*/
         matrix colnames `xcL' = `bsimsLO'            /* rename cols         */
         qui matrix score `SimXbLO' = `xcL'	      /* simd xbetas|pLO     */
         qui gen `SimPrLO' = 1/(1+exp(-`SimXbLO'))    /* simd Pr(Y=1|pLO)    */
         matrix `xcH' = (mrt_xcH`k')                  /* xchosen|pHI (vector)*/
         matrix colnames `xcH' = `bsimsHI'	      /* rename cols         */
         qui matrix score `SimXbHI' = `xcH'           /* simd xbetas|pHI     */
         qui gen `SimPrHI' = 1/(1+exp(-`SimXbHI'))    /* simd Pr(Y=1|pHI)    */
         qui _pctile `SimPrLO', p(`lo')               /* calc percentiles    */
         return scalar PrL = r(r1)                    /* lower bound of ci   */
         qui _pctile `SimPrHI', p(`hi')               /* calc percentiles    */
         return scalar PrU = r(r1)                    /* upper bound ci      */
         return scalar Pr = (`return(PrU)'+`return(PrL)')/2 /*mean of bounds */
      }
      di _n in g "Probabilities and confidence intervals based on initial X-values"
      di "   Pr(`e(depvar)'==1)  = " %8.5f `return(Pr)'
      di "   `level'% Confidence Interval = " %8.5f `return(PrL)' " to " `return(PrU)'
   }

   * FIRST DIFFERENCES
   tempname xcS xcE AnaXbS AnaXbE AnaPrS AnaPrE xcSL xcSH xcEL xcEH 
   tempname xcdiffL xcplus dPrL dPrH xcdiffH 
   tempvar SimXbS SimXbE diff SimXbSL SimXbSH SimXbEL SimXbEH diffL diffH    
   tempvar ORLO ARpiLO bsLO nonmon nonmonL nonmonU monL monU ARLLO ARULO     
   tempvar ORHI ARpiHI bsHI ARLHI ARUHI
   local i 1
   while `i' <= `nx' {                         
      if "`pHI'" == "" {
         matrix `xcS' = (`xcS`i''`k')            /* starting values for X   */
         matrix `xcE' = (`xcE`i''`k')		 /* ending values for X     */
         matrix colnames `xcS' = `bsims'         /* rename cols of startvals*/
         qui matrix score `SimXbS' = `xcS'	 /* simulated starting Xb's */
         matrix colnames `xcE' = `bsims'         /* rename cols of endvals  */
         qui matrix score `SimXbE' = `xcE'       /* simulated ending Xb's   */
         qui gen `diff' = 1/(1+exp(-`SimXbE')) - 1/(1+exp(-`SimXbS'))
         if `analyt' == 0 { 
            _pctile `diff', p(50)              
            return scalar dPr_`i' = r(r1)        /* simulated median 1stdiff*/
         }
         else {
            matrix `AnaXbS' = (`xcS`i''`k')*`b''         /* Analyt XbS      */
            scalar `AnaPrS' = 1/(1+exp(-`AnaXbS'[1,1]))  /* Analyt Pr(Y=1|S)*/
            matrix `AnaXbE' = (`xcE`i''`k')*`b''         /* Analyt XbE      */
            scalar `AnaPrE' = 1/(1+exp(-`AnaXbE'[1,1]))  /* Analyt Pr(Y=1|E)*/
            if "`mle'" == "" {
               mat `C' = (`AnaPrS'-`AnaPrS'^2)*(.5-`AnaPrS')  /* correctn|S */
               mat `C' = `C'*(`xcS`i''`k')*`V'*(`xcS`i''`k')' /* correctn|S */
               if "`bayes'"~=""{scalar `AnaPrS'=`AnaPrS'+`C'[1,1]} /* bayes */
               else { scalar `AnaPrS' = `AnaPrS' - `C'[1,1] }      /* unbias*/
               mat `C'= (`AnaPrE'-`AnaPrE'^2)*(.5-`AnaPrE')   /* correctn|E */
               mat `C' = `C'*(`xcE`i''`k')*`V'*(`xcE`i''`k')' /* correctn|E */
               if "`bayes'"~=""{scalar `AnaPrE'=`AnaPrE'+`C'[1,1]} /* bayes */
               else { scalar `AnaPrE' = `AnaPrE' - `C'[1,1] }      /* unbias*/
               _recode `AnaPrS' `AnaPrE'                  /* keep in [0,1]  */
            }
            return scalar dPr_`i' = `AnaPrE' - `AnaPrS'
         }
         qui _pctile `diff', p(`lo',`hi')        /* calculate percentiles   */
         return scalar dPrL_`i' = r(r1)          /* lower bound of ci       */
         return scalar dPrU_`i' = r(r2)          /* upper bound of ci       */
         drop `SimXbS' `SimXbE' `diff' 
      }
      else {
         matrix `xcSL' = (`xcSL`i''`k')        /* starting values for X|pLO*/
         matrix `xcEL' = (`xcEL`i''`k')        /* ending values for X|pLO */
         matrix `xcSH' = (`xcSH`i''`k')        /* starting values for X|pHI*/
         matrix `xcEH' = (`xcEH`i''`k')        /* ending values for X|pHI    */
         * Simulate 1st differences under pLO and pHI
         matrix colnames `xcSL' = `bsimsLO'               
         qui matrix score `SimXbSL' = `xcSL'             /* sim XB|S,pLO     */
         matrix colnames `xcSH' = `bsimsHI'               
         qui matrix score `SimXbSH' = `xcSH'             /* sim XB|S,pHI     */
         matrix colnames `xcEL' = `bsimsLO'               
         qui matrix score `SimXbEL' = `xcEL'             /* sim XB|E,pLO     */
         matrix colnames `xcEH' = `bsimsHI'
         qui matrix score `SimXbEH' = `xcEH'             /* sim XB|E,pHI     */
         qui gen `diffL' = 1/(1+exp(-`SimXbEL')) - 1/(1+exp(-`SimXbSL'))
         qui gen `diffH' = 1/(1+exp(-`SimXbEH')) - 1/(1+exp(-`SimXbSH'))

         * CASE 1: pLO
         * Calculate ARpi assuming pLO
         matrix `xcdiffL' = `xcEL' - `xcSL'
         matrix colnames `xcdiffL' = `bsims'
         qui matrix score `ORLO' = `xcdiffL'
         qui replace `ORLO' = exp(`ORLO')                     /* odds ratio */
         qui gen `ARpiLO' = (sqrt(`ORLO')-1)/(sqrt(`ORLO')+1) /* AR_piLO    */
         * Intercept at which AR is maximized, given pLO
         matrix `xcplus' = -.5*(`xcEL' + `xcSL')         /* neg avg xcE, xcS */
         matrix `xcplus'[1,`nptosim'] = 0                /* omit constant    */
         matrix colnames `xcplus' = `bsims'
         qui matrix score `bsLO' = `xcplus'              /* intercept value  */
         * bounds for AR in monotonic and non-monotinic regions
         qui gen `nonmon'=(`bLO'<=`bsLO')&(`bsLO'<=`bHI')  /* nonmonotonic region*/
         qui egen `nonmonL' = rmin(`diffL' `diffH' `ARpiLO') /* nonmonotonic LO*/
         qui egen `nonmonU' = rmax(`diffL' `diffH' `ARpiLO') /* nonmonotonic Hi*/
         qui egen `monL' = rmin(`diffL' `diffH')           /* monotonic LO   */
         qui egen `monU' = rmax(`diffL' `diffH')           /* monotonic HI   */
         qui gen `ARLLO' = (`nonmon')*`nonmonL' + (1-`nonmon')*`monL'
         qui gen `ARULO' = (`nonmon')*`nonmonU' + (1-`nonmon')*`monU'
         * bounds
         qui _pctile `ARLLO', p(`lo')                  /* calc percentiles    */
         scalar `dPrL' = r(r1)                         /* lower bound of ci   */
         qui _pctile `ARULO', p(`hi')                  /* calc percentiles    */
         scalar `dPrH' = r(r1)                         /* upper bound ci      */
         qui drop `ORLO' `ARpiLO' `bsLO' `nonmon' `nonmonL' `nonmonU' /*
            */ `monL' `monU' `ARLLO' `ARULO'

         * CASE2: piHI
         * Calculate ARpi assuming pHI
         matrix `xcdiffH' = `xcEH' - `xcSH'
         matrix colnames `xcdiffH' = `bsims'
         qui matrix score `ORHI' = `xcdiffH'
         qui replace `ORHI' = exp(`ORHI')                     /* odds ratio */
         qui gen `ARpiHI' = (sqrt(`ORHI')-1)/(sqrt(`ORHI')+1) /* AR_piHI    */
         * Intercept at which AR is maximized, given pHI
         matrix `xcplus' = -.5*(`xcEH' + `xcSH')         /* neg avg xcE, xcS */
         matrix `xcplus'[1,`nptosim'] = 0                /* omit constant    */
         matrix colnames `xcplus' = `bsims'
         qui matrix score `bsHI' = `xcplus'              /* intercept value  */
         * bounds for AR in monotonic and non-monotinic regions
         qui gen `nonmon'=(`bLO'<=`bsHI')&(`bsHI'<=`bHI')  /* nonmonotonic region*/
         qui egen `nonmonL' = rmin(`diffL' `diffH' `ARpiHI') /* nonmonotonic LO*/
         qui egen `nonmonU' = rmax(`diffL' `diffH' `ARpiHI') /* nonmonotonic Hi*/
         qui egen `monL' = rmin(`diffL' `diffH')           /* monotonic LO   */
         qui egen `monU' = rmax(`diffL' `diffH')           /* monotonic HI   */
         qui gen `ARLHI' = (`nonmon')*`nonmonL' + (1-`nonmon')*`monL'
         qui gen `ARUHI' = (`nonmon')*`nonmonU' + (1-`nonmon')*`monU'
         * bounds
         qui _pctile `ARLHI', p(`lo')                  /* calc percentiles    */
         if r(r1) < `dPrL' { scalar `dPrL' = r(r1) }
         qui _pctile `ARUHI', p(`hi')                  /* calc percentiles    */
         if r(r1) > `dPrH' { scalar `dPrH' = r(r1) }
         qui drop `ORHI' `ARpiHI' `bsHI' `nonmon' `nonmonL' `nonmonU' /*
            */ `monL' `monU' `ARLHI' `ARUHI' `SimXbSL' `SimXbSH' /*
            */ `SimXbEL' `SimXbEH' `diffL' `diffH'

         * FINAL BOUNDS
         return scalar dPrL_`i' = `dPrL'              /* lower bound of ci   */
         return scalar dPrU_`i' = `dPrH'               /* upper bound ci      */
         return scalar dPr_`i' = (`return(dPrL_`i')'+`return(dPrU_`i')')/2 
      }
      gettoken change changex : changex, parse("&")
      di _n in g "First difference `i': `change'"
      di "   dPr(`e(depvar)'==1)  = " %8.5f `return(dPr_`i')'
      di "   `level'% Confidence Interval = " %8.5f `return(dPrL_`i')' " to " `return(dPrU_`i')'
      gettoken ampers changex : changex, parse("&")
      local i = `i' + 1
   }

   * RELATIVE RISKS
   tempvar SimXbS SimXbE RR
   local i 1
   while `i' <= `nrr' {            
      if "`pHI'" == "" {
         matrix `xcS' = (`rrS`i''`k')
         matrix `xcE' = (`rrE`i''`k')
         matrix colnames `xcS' = `bsims'         /* rename cols of startvals*/
         qui matrix score `SimXbS' = `xcS'	 /* simulated starting Xb's */
         matrix colnames `xcE' = `bsims'         /* rename cols of endvals  */
         qui matrix score `SimXbE' = `xcE'       /* simulated ending Xb's   */
         qui gen `RR' = (1/(1+exp(-`SimXbE'))) / (1/(1+exp(-`SimXbS')))
         if `analyt' == 0 { 
	     _pctile `RR', p(50)              
            return scalar rr_`i' = r(r1)         /* simulated median relrisk*/
         }
         else {
            matrix `AnaXbS' = (`rrS`i''`k')*`b''         /* Analyt XbS      */
            scalar `AnaPrS' = 1/(1+exp(-`AnaXbS'[1,1]))  /* Analyt Pr(Y=1|S)*/
            matrix `AnaXbE' = (`rrE`i''`k')*`b''         /* Analyt XbE      */
            scalar `AnaPrE' = 1/(1+exp(-`AnaXbE'[1,1]))  /* Analyt Pr(Y=1|E)*/
            if "`mle'" == "" {
               mat `C' = (`AnaPrS'-`AnaPrS'^2)*(.5-`AnaPrS')  /* correctn|S */
               mat `C' = `C'*(`rrS`i''`k')*`V'*(`rrS`i''`k')' /* correctn|S */
               if "`bayes'"~=""{scalar `AnaPrS'=`AnaPrS'+`C'[1,1]} /* bayes */
               else { scalar `AnaPrS' = `AnaPrS' - `C'[1,1] }      /* unbias*/
               mat `C'= (`AnaPrE'-`AnaPrE'^2)*(.5-`AnaPrE')   /* correctn|E */
               mat `C' = `C'*(`rrE`i''`k')*`V'*(`rrE`i''`k')' /* correctn|E */
               if "`bayes'"~=""{scalar `AnaPrE'=`AnaPrE'+`C'[1,1]} /* bayes */
               else { scalar `AnaPrE' = `AnaPrE' - `C'[1,1] }      /* unbias*/
               _recode `AnaPrS' `AnaPrE'                  /* keep in [0,1]  */
            }
            return scalar rr_`i' = `AnaPrE' / `AnaPrS'
         }
         qui _pctile `RR', p(`lo',`hi')          /* calculate percentiles   */
         return scalar rrL_`i' = r(r1)           /* lower bound of ci       */
         return scalar rrU_`i' = r(r2)           /* upper bound of ci       */
         drop `SimXbS' `SimXbE' `RR' 
      }
      else {
         tempvar SimXbSL SimXbSH SimXbEL SimXbEH rrL rrH RRL RRH
         matrix `xcSL' = (`rrSL`i''`k')
         matrix `xcSH' = (`rrSH`i''`k')
         matrix `xcEL' = (`rrEL`i''`k')
         matrix `xcEH' = (`rrEH`i''`k')
         matrix colnames `xcSL' = `bsimsLO'               
         qui matrix score `SimXbSL' = `xcSL'             /* sim XB|S,pLO     */
         matrix colnames `xcSH' = `bsimsHI'               
         qui matrix score `SimXbSH' = `xcSH'             /* sim XB|S,pHI     */
         matrix colnames `xcEL' = `bsimsLO'               
         qui matrix score `SimXbEL' = `xcEL'             /* sim XB|E,pLO     */
         matrix colnames `xcEH' = `bsimsHI'
         qui matrix score `SimXbEH' = `xcEH'             /* sim XB|E,pHI     */
         * simd rel risks pLO and pHI
         qui gen `rrL' = (1+exp(-`SimXbSL')) / (1+exp(-`SimXbEL'))
         qui gen `rrH' = (1+exp(-`SimXbSH')) / (1+exp(-`SimXbEH'))
         qui egen `RRL' = rmin(`rrL' `rrH')
         qui egen `RRH' = rmax(`rrL' `rrH')
         * final bounds
         qui _pctile `RRL', p(`lo')                   /* calc percentiles    */
         return scalar rrL_`i' = r(r1)                /* lower bound of ci   */
         qui _pctile `RRH', p(`hi')                   /* calc percentiles    */
  	   return scalar rrU_`i' = r(r1)                /* upper bound ci      */
         return scalar rr_`i' = (`return(rrL_`i')'+`return(rrU_`i')')/2
         qui drop `SimXbSL' `SimXbSH' `SimXbEL' `SimXbEH' `rrL' `rrH' /* 
            */ `RRL' `RRH'
      }
      gettoken change rr : rr, parse("&")         
      di _n in g "Relative Risk `i': `change'"

      di "   rr(`e(depvar)'==1)  = " %8.5f `return(rr_`i')'
      di "   `level'% Confidence Interval = " %8.5f `return(rrL_`i')' " to " `return(rrU_`i')'
      gettoken ampers changex : changex, parse("&")
      local i = `i' + 1
   }

   qui keep if `keepme' == 1

end

****************************** SUB-PROCEDURES ********************************

program define ck_xc
   * Checks for presence of xc matrix, simulated parameters, depvar
   version 6.0
   tokenize "`e(p)'"
   if "`2'" == "" {
      capture mat list mrt_xc                
      if _rc == 0  {                         
         local xccols : colnames(mrt_xc)   
         if "`xccols'" == "`e(rhsvars)'" { local xcfound yes }  
      }
   }
   else {     
      capture mat list mrt_xcL                         /* does xcL mat exist? */
      local rc = _rc
      capture mat list mrt_xcH			       /* does xcH mat exist? */
      local rc = `rc' + _rc
      if `rc' == 0 {                                   /* if xc does exist... */
         local xccolsL : colnames(mrt_xcL)             /* names of vars in xcL*/
         local xccolsH : colnames(mrt_xcH)             /* names of vars in xcH*/
         if "`xccolsL'"=="`e(rhsvars)'"  &             /* if names match ivars
            */ & "`xccolsH'"=="`e(rhsvars)'"           /*
            */ { local xcfound yes }                   /* then xc matrix is OK*/
      }
   }
   if "`xcfound'" ~= "yes" {
      di in r _n "X-values missing or invalid.  Please rerun -setx-."
      exit 198
   }

end

program define _strip, rclass
   * Strips fd and changex from command line
   version 6.0
   args cmdline
   tokenize `"`cmdline'"', parse("@")
   if "`1'" == "@" | "`2'" == "@" {
      di in r _n "The -relogitq- command cannot contain the @ character."
      exit 198
   }
   _parsep fd `cmdline'                   /* strip-off changex(arg)   */
   return local fd `r(Arg)'
   return local rest `r(RestOpt)'
end

program define _parsep, rclass
   * Parsing with embedded parentheses
   * Based on Jeroen Weesie, "Parsing Options with Embedded Parentheses,"
   * Stata Technical Bulletin 40 (Nov 1997), insert ip22.
   * Limitation: input can't contain any @'s
   version 6.0
   if "`*'" == "" {
      return local Arg        /* pass empty argument  */
      return local RestOpt    /* pass empty remainder */
      exit
   }
   local optname `1'                 /* pluck-off option name */
   mac shift
   while "`1'" ~= "" {               /* separate all tokens with @ */
      local optamp `optamp'`1'@
      mac shift
   }
   local H 0
   local Mode0 None
   local ProcArg 0
   tokenize "`optamp'", parse("@()[]")
   while "`1'" ~= "" {
      if "`1'" == "`optname'" & `H' == 0 {
         if "`2'" == "(" {
            local H = `H' + 1
            local Mode`H' p
            local ProcArg 1
            mac shift
         }
      }
      else {
         if "`1'" == "(" {
            local H = `H' + 1
            local Mode`H' p
         }
         else if "`1'" == "[" {
            local H = `H' + 1
            local Mode`H' b
         }
         else if "`1'" == ")" {
            if "`Mode`H''" ~= "p" {
               di in r "too many ')' or ']'"
               exit 132
            }
            local H = `H' - 1
         }
         else if "`1'" == "]" {
            if "`Mode`H''" ~= "b" {
               di in r "too many ')' or ']'"
               exit 132
            }
            local H = `H' - 1
         }
         else if "`1'" == "@" {
            local 1 " "
         }
         if `ProcArg' == 1 {
            if `H' > 0 { local Arg "`Arg'`1'" }
         }
         else { local RestOpt "`RestOpt'`1'" }
         if `H' == 0 {
            local ProcArg 0
            local Arg "`Arg' "
         }
      }
      mac shift
   }
   return local Arg `Arg'
   return local RestOpt `RestOpt'
end

program define ck_fd
   tokenize "`changex'", parse(",")
   if "`1'" == "," | "`2'" == "," {
      di in r _n "The changex option cannot contain a comma."
      exit 198
   }
end

program define _changex, rclass
   * parses the changex commands
   version 6.0
   args changex
   local nrhsvar : word count `e(rhsvars)'                /* # rhs vars  */
   local nx 0                                             /* # sets of x */
   while "`changex'" ~= "" {
      local nx = `nx' + 1                                 /* next set    */
      gettoken changes changex : changex, parse("&")      /* changes in  */
      while "`changes'" ~= "" {                           /*   this set  */
         gettoken vars changes : changes, match(paren)    /* variable(s) */
         gettoken fun1 changes : changes, match(paren1)   /* function 1  */
         gettoken fun2 changes : changes, match(paren2)   /* function 2  */
         while "`vars'" ~= "" {
            gettoken var vars : vars                      /* get varname */
            if "`paren1'" == "" {local slist`nx' `slist`nx'' `var' `fun1'}
            else {local slist`nx' `slist`nx'' `var' (`fun1')}
            if "`paren2'" == "" {local elist`nx' `elist`nx'' `var' `fun2'}
            else {local elist`nx' `elist`nx'' `var' (`fun2')}
         }
      }
      return local slist`nx' `slist`nx''    /* return starting list #nx */
      return local elist`nx' `elist`nx''    /* return ending list #nx   */
      gettoken amper changex : changex, parse("&")       /* strip-off & */
   }
   return local nx `nx'
end

program define ck_pr, rclass
   version 6.0
   args pr prval
   tempname catdi allcats
   if "`pr'" == "no" {                           /* pr was not specified */
      matrix `catdi' = J(1,2,0)
      while "`prval'" ~= "" {
         gettoken val prval : prval
         if `val' == 0 { matrix `catdi'[1,1] = 1 }
         else if `val' == 1 { matrix `catdi'[1,2] = 1 }
         else {
            di in r _n "Error: `val' is not a valid outcome for `e(depvar)'"
            exit 198
         }
      }
   }
   else {                                           /* pr was specified */
      if "`prval'" ~= "" {
         di in g _n "Note: You specified both the pr and the prval() " /*
           */ "options." _n "pr takes precedence over prval(), so -relogitq-"/*
           */ " will display " _n "Pr(Y=0) and Pr(Y=1), rather than the " /*
           */ "values listed in prval()."
      }
      matrix `catdi' = J(1,2,1)
   }
   return matrix catdi `catdi'
end

program define _recode
   version 6.0
   while "`0'" ~= "" {
      gettoken p 0 : 0
      if `p' < 0 { scalar `p' = 0 }
      else if `p' > 1 { scalar `p' = 1 }
   }
end


*! version 1.3  April 24, 1999  Michael Tomz
* Cholesky decomposition of an arbitrary matrix
* Input: V, the original matrix
*        k, the dimension of the matrix
*        A, the name of a new matrix to be created
* Output: A, the lower-triangle cholesky of V
program define _chol
   version 6.0
   args V k A  
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
end

program define ck_rr
   version 6.0
   args fd
   local 0 ,`fd'
   syntax [, PR RR(string) ]
   if "`rr'" ~= "" {
      di in r _n "Error: relogitq does not allow first differences of " /*
         */ "relative risks."
      exit 198
   }
end


