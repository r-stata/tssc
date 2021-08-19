*! Version 1.1.1  October 28, 1999
*  (C) Copyright 1999 Michael Tomz, Gary King, and Langche Zeng.
*  Current version available at http://gking.harvard.edu
*  RElogit: Rare Events Logistic Regression

program define relogit, eclass
  version 6.0
  syntax varlist [if] [in] [aw fw pw iw/] [, pc(numlist sort max=2 >=0 <=1) /*
     */ wc(numlist max=1 >=0 <=1) NOMCN FIRTH NORobust CLuster(varname)     /*
     */ NOCONstant Level(int $S_level)]
  marksample touse                                    /* mark observations  */
  if "`firth'" ~= "" {
     di in r _n "Relogit for Stata does not yet support the FIRTH option"
     exit 198
  }
  if "`norobust'" == "" { local robust robust }       /* default: robust SE */
  if "`cluster'" ~= "" { 
     local cluster cl(`cluster')
     if "`norobust'" ~= "" {
        di in r "Error: the norobust & cluster options are incompatible"
        exit 198
     }
  }
  if "`wc'" ~= "" {
     if "`norobust'" ~= "" {
        di in r _n "Warning: Traditional variance estimates do not make sense"
        di in r "with the wc() option"
     }
     if `wc' == 0 { local wc = .1^8 }
     else if `wc' == 1 { local wc = 1 - .1^8 }
  }
  if "`pc'" ~= "" {
     if "`wc'" ~= "" {
        di in r _n "Error: Can't use the pc() & wc() options together."
        exit 198
     }
     if "`noconst'" ~= "" {
        di in r "Error: Can't use the pc() & noconstant options together."
        exit 198
     }
     gettoken pcLO pcHI : pc
     if "`pcHI'" == "" {
        if `pc' == 0 { local pc = .1^8 }              /* recode to small #  */
        else if `pc' == 1 { local pc = 1 - .1^8 }     /* recode to approx 1 */
     }
     else {
        if `pcLO' == 0 { local pcLO = .1^8 }
        if `pcHI' == 1 { local pcHI = 1 - .1^8 }      
     }
  }

  tempname cat ybar wt0 wt1 b V bfull Vfull df_m k
  gettoken depvar rhsvars : varlist                   /* separate dv,rhs    */
  qui tab `depvar' if `touse', matrow(`cat')          /* tabulate depvar    */
  if `cat'[1,1] ~= 0 | `cat'[2,1] ~= 1 {
     di in r "Error: Dependent variable can only take-on values of 0 or 1"
     exit 198
  }
  qui su `depvar' if `touse', meanonly                /* mean of dep var    */
  scalar `ybar' = r(mean)
  if "`wc'" ~= "" {                                   /* weighting-up 0's   */
     scalar `wt0' = (1-`wc') / (1-`ybar')             /*    weight factor 0 */
     scalar `wt1' = `wc' / `ybar'                     /*    weight factor 1 */
  }
  else {                                              /* don't use weights  */
     scalar `wt0' = 1                                 /*    for estimation  */
     scalar `wt1' = 1                              
  }
  tempvar wt
  if "`exp'" == "" { local exp 1 }                    /* command line weight*/
  qui gen `wt' = `exp'*                               /* multiply cmd line wt 
     */ (`wt0'*(1-`depvar')+`wt1'*`depvar')           /*    into wc weight  */
  qui logit `varlist' if `touse' [aweight=`wt'],      /* run logit
     */ `robust' `cluster' `noconst'
  * FUTURE: DO FIRTH RATHER THAN WEIGHTED LOGIT IF FIRTH REQUESTED
  matrix `b' = e(b)                                   /* fetch estimated b  */
  matrix `V' = e(V)                                   /* fetch estimated VC */
  scalar `df_m' = e(df_m)                             /* # rhs except _cons */
  scalar `k' = colsof(`V')                            /* # rhs includ _cons */
  local N = e(N)
  if "`nomcn'" == "" & "`firth'" == "" {              /* MCN Correction     */
     tempname A Ainv row biasMCN
     tempvar pi wtmcn ksi                                                 
     qui predict `pi', p                              /* predicted Pr(Y=1)  */
     qui gen `wtmcn' = (`pi'-`pi'^2)*`wt'             /* diagonal of W(nxn) */
     qui matrix accum `A' = `rhsvars' [pw=`wtmcn'] if `touse', `noconst'
     matrix `Ainv' = inv(`A')                         /* inverse of A       */
     local vars : colnames `Ainv'                     /* variable names     */
     local sum 0                                      /* initialize sum to 0*/
     local i 1
     while `i' <= `k' {
        gettoken var vars : vars                      /* pluck-off var name */
        matrix `row' = (`Ainv'[1...,`i'])'            /* ith column, tposed */
        tempvar c`i'                                  /* name of new var    */
        matrix score `c`i'' = `row'                   /* generate c`i'      */
        /* build expression for insertation into ksi formula */
        if `i'==`k' & "`noconst'" == "" { local sum `sum' + `c`i'' }                                             
        else { local sum `sum' + `c`i''*`var' }                                         
        local i = `i' + 1
     }
     gen `ksi'= .5 * (`sum') * [(1+`wt1')*`pi'-`wt1']
     /* use WLS to calculate MCN bias */
     qui regress `ksi' `rhsvars' [aw=`wtmcn'] if `touse', `noconst'
     matrix `biasMCN' = e(b)                          /* get estimated bias */
     matrix `b' = `b' - `biasMCN'                     /* corrected coefs    */
     matrix `V' = `V'*(`N'/(`N'+`k'))^2               /* corrected vc matrix*/
  }

  if "`pc'" ~= "" & "`pcHI'" == "" {                  /* intercept prior    */
     mat `b'[1,`k']=`b'[1,`k']-[ln(1-`pc')-ln(`pc')+ln(`ybar')-ln(1-`ybar')]
  }
  
  estimates post `b' `V', obs(`N') depname("`depvar'") esample(`touse')
  if "`robust'" == "robust" { estimates local vcetype Robust }
  if "`weight'" ~= "" { 
     estimates local wt [`weight'=`exp'] 
     estimates local wtype `weight'
     estimates local wexp "=`exp'"
  }
  if "`pcHI'" ~= "" { estimates local p `pcLO' `pcHI' }
  else { estimates local p `pc' `wc' }
  estimates local depvar `depvar'
  estimates local rhsvars `rhsvars'
  estimates local if `if'
  estimates local in `in'
  estimates scalar df_m = `df_m'
  estimates local cmd relogit
  if "`nomcn'" == "nomcn" & "`firth'" == "" & "`wc'" == "" & /*
     */ "`pc'" == "" { local leader Unc }
  else { local leader C }
  di in g _n(2) "`leader'orrected logit estimates" _col(55)  /*
     */ "Number of obs =" in y %9.0f e(N) _n
  estimates display, level(`level')
  if "`pcHI'" ~= "" {
     di _n "Note: The estimated constant is invalid when the fraction " /*
        */ _c "of 1's in the" _n "population is not known, but you can " /*
        */ _c "still use -relogitq- to interpret your" _n "results."
  }

end

