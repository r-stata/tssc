*! johans: Johansen's maximum likelihood cointegration rank test
*! version 3.0   PJoly   10dec2002
* v.3.0   PJoly   10dec2002   list critical values, enhanced .hlp
* v.2.0   PJoly   07apr2002   updated to version 7 + misc (see changes20.txt)
* v.1.2.1 RSperling   26mar2002   addition of H0 in display
* v.1.2   PJoly   09feb2001   save coef on deterministic terms (e(mu0),e(mu1))
* v.1.1   PJoly   01jan2001   updated to version 6
* v.1.0   PJoly   09sep2000   retain alpha, beta' matrices
* code taken from mlcoint v.2.0 (Ken Heinecke, 2/9/93, sts9: STB-21)

program define johans, eclass byable(recall) sortpreserve
      version 7.0

quietly {
      syntax varlist(ts min=2) [if] [in] [,                                 /*
                                    */   EXog(varlist ts)                   /*
                                    */   Lags(numlist int min=1 max=1 >0)   /*
                                    */   noConstant                         /*
                                    */   Regress                            /*
                                    */   noNormal                           /*
                                    */   STANdard                           /*
                                    */   Trend Level(numlist min=1 max=1) ]

      if ("`constant'"!="" & "`trend'"!="") {
            di as err "noconstant not allowed with trend"
            exit 198
      }
      if "`level'" == "" { local level 95 }
      if !inlist(`level',50,80,90,95,97.5,99) {
            di as err "level must be one of 50, 80, 90, 95, 97.5, or 99"
            exit 198
      }

      local vars : word count `varlist'
      local normal  = cond("`normal'"=="",1,0)
      local standard  = cond("`standard'"=="",0,1)
      local matrix  = `normal' | `standard'
      if ("`regress'" != "") { local noi "noi" }
      cap set matsize 200                     /* This can only work in Unix */
      if "`lags'"=="" { local lags = 1 }
      local lags = `lags'-1                 /* # of lags after differencing */

      /* Establish a sample over which the VAR can be run one equation at
         a time */

      marksample touse
      _ts tvar panelvar if `touse', sort onepanel
      markout `touse' l`lags'.(`varlist') `exog' `tvar' `panelvar'
      qui count if `touse'
      if !r(N) { n error 2000 }
      qui tsset
      if "`trend'" != "" { local trend `tvar' }
      local fmt : format `tvar'
      qui summ `tvar' if `touse', meanonly
      local tmin = trim(string(r(min), "`fmt'"))
      local tmax = trim(string(r(max), "`fmt'"))

      tsreport if `touse'
      if r(N_gaps) {
            di as err "gaps in sample"
            exit 498
      }

      /* Create lists of residuals */

      tokenize `varlist'
      forv j = 1/`vars' {
            local dres "`dres' d`j'"
            local lres "`lres' l`j'"
      }
      tempvar `dres' `lres'   /* each element will be a tempvar */

      /* Create list for labeling final matrices */

      forv j = 1/`vars' { local vecl "`vecl' vec`j'" }

      /* Estimate first system of regressions and save the residuals
         as d1, d2, ..., d`vars' */

      forv i = 1/`vars' {
            if (`lags'==0) {
                  local list : subinstr local varlist "``i''" "", word all
                  `noi' reg d.``i'' d.(`list') `exog' `trend'               /*
                                         */            if `touse', `constant'
                  predict `d`i'', residual
            }
            else {
                  `noi' reg d.``i'' l(1/`lags')d.(`varlist') `exog'         /*
                                         */    `trend' if `touse', `constant'
                  predict `d`i'', residual
            }
      }

      /* Estimate second system of regressions and save residuals
         as l1, l2, ..., l`vars' */

      forv i = 1/`vars' {
            if (`lags'==0) {
                  local list : subinstr local varlist "``i''" "", word all
                  `noi' reg l.``i'' d.(`list') `exog' `trend'               /*
                                         */            if `touse', `constant'
                  predict `l`i'', residual
            }
            else{
                  `noi' reg l.``i'' l(1/`lags')d.(`varlist') `exog'         /*
                                         */    `trend' if `touse', `constant'
                  predict `l`i'', residual
            }
      }

      /* The residuals from the VARs are calculated and stored.  Allocate
         temporary names for the matrix calculations

         Matrices stored by this routine are:

         ISDD, NA, NBP, SDL, SLL, TEVL(TEIGVAL), TSDL */

      tempname A CHOLD DIF EIGVALS EVECT EVMAX EVTRACE FINMAT
      tempname ICHOLD LDIF ONE SALPHA SBETAP SDD SLDIF STALPHA
      tempname TALPHA TEVECT TICHOLD Z1 Z2 Z3 df idf
      tempname ISDD NA NBP SDL SLL TEVL TSDL

      /* Store degrees of freedom */

      sca `df' = e(N)
      sca `idf' = 1/`df'

      /* set up product moment matrices */

      tokenize `dres'
      forv i = 1/`vars' { local dr "`dr' ```i'''" }
      tokenize `lres'
      forv i = 1/`vars' { local lr "`lr' ```i'''" }

      mat accum `A' =  `dr' `lr' if `touse', noconstant
      mat `SDD' = `A'[1..`vars',1..`vars']
      local r = `vars'+1
      mat `SLL' = `A'[`r'...,`r'...]
      mat `SDL' = `A'[1..`vars',`r'...]
      mat drop `A'

      /* Scale matrices by degrees of freedom */

      mat `SDD' =  `idf'*`SDD'
      mat `SLL' = `idf'*`SLL'
      mat `SDL' = `idf'*`SDL'

      /* Set up likelihood function matrices */

      mat `CHOLD' = cholesky(`SLL')
      mat `ICHOLD' = inv(`CHOLD')
      mat `TSDL' = `SDL''
      mat `ISDD' = syminv(`SDD')
      mat `TICHOLD' = `ICHOLD''
      mat `Z1' = `ICHOLD'*`TSDL'
      mat `Z2' = `Z1'*`ISDD'
      mat `Z3' = `Z2'*`SDL'
      mat `FINMAT' = `Z3'*`TICHOLD'

      /* Calculate eigenvalues and eigenvectors */

      mat symeigen `EVECT' `EIGVALS' = `FINMAT'
      mat `TEVL' = `EIGVALS''

      /* Calculate lambda max stats */

      mat `ONE' = J(`vars',1,1)
      mat `DIF' = `ONE'-`TEVL'
      mat `LDIF' = J(`vars',1,0)
      forv i = 1/`vars' {
            mat `LDIF'[`i',1] = log(`DIF'[`i',1])
      }
      mat `SLDIF' =  `df'*`LDIF'
      mat `EVMAX' = -1*`SLDIF'

      /* Calculate trace stats */

      mat `EVTRACE' = J(`vars',1,0)
      local sevmax = 0
      local n 0
      forv i = 1/`vars' {
            local n = `vars'+1-`i'
            local sevmax = `sevmax'+`EVMAX'[`n',1]
            mat `EVTRACE'[`n',1] = `sevmax'
      }

      /* Display the eigenvalues, maximal eigenvalue statistics, and the trace
         statistics */

      /* lines marked 'temp' will be deleted once most stata commands comply
         w/ -set linesize ...- */
      local lsize : set linesize   /* temp */
      set linesize 78              /* temp */
      n di "{txt}Johansen-Juselius cointegration rank test" _c
      n di "{right: {txt}Sample: {res}`tmin' {txt}to {res}`tmax'}"
      n di "{right: {txt}Number of obs =  {res}`e(N)'}"
      set linesize `lsize'         /* temp */

      n di "{txt}{col 25}{* c |}{col 41}H1:"
      n di "{txt}{col 18}H0:{col 25}{c |}   Max-lambda{col 47}Trace"
      n di "{txt} Eigenvalues  rank<=(r){col 25}{c |}   statistics"  _c
      n di "{txt}{col 45}statistics"
      n di "{txt}  (lambda){col 19}r{col 25}{c |}  (rank<=(r+1))" _c
      n di "{txt}{col 44}(rank<=(p={res}`vars'{txt}))"
      n di "{txt}{dup 24:{c -}}{c +}{dup 32:{c -}}"

      forv i = 1/`vars' {
            n di _s(1) as res %10.0g = `TEVL'[`i',1]           /*
             */  _s(3) as txt %5.0f `i'-1  _s(5) "{txt}{c |}"  /*
             */  _s(3) as res %10.0g = `EVMAX'[`i',1]          /*
             */  _s(6) as res %10.0g = `EVTRACE'[`i',1]
      }

      /* Critical values */

      tempname MX TR MXstar TRstar rLevel
      mat `rLevel' = J(6,1,0)  /* to select column of tables RE level */
      local i 0
      foreach lev in 50 80 90 95 97.5 99 {
            local i = `i'+1
            if `level' == `lev' { mat `rLevel'[`i',1] = 1 }
      }
      n di _n
      n di "{txt}{col 5}Osterwald-Lenum Critical values (`level'% interval):"
      if "`trend'" != "" | "`constant'" == "" {
            if "`trend'" != "" {
                  local case 2
                  local assumstar  "intercept in VAR, trend in CE"
                  local assum "intercept and trend in VAR"
            }
            else {
                  local case 1
                  local assumstar  "intercept in CE"
                  local assum "intercept in VAR"
            }
            Case`case' `MX' `TR' `MXstar' `TRstar'
            mat `MX' = `MX'*`rLevel'
            mat `TR' = `TR'*`rLevel'
            mat `MXstar' = `MXstar'*`rLevel'
            mat `TRstar' = `TRstar'*`rLevel'

            n di _n "{txt}{col 5}Table/Case: {res:`case'*}  "
            n di "{txt}{col 5}(assumption: {res:`assumstar'})" _n
            n di "{txt}{col 18}H0:{col 25}{c |}   Max-lambda{col 47}Trace"
            n di "{txt}{col 14}{dup 11:{c -}}{c +}{dup 32:{c -}}"
            forv i = 1/`vars' {
                  n di _s(14) as txt %5.0f `i'-1  _s(5) "{txt}{c |}"   /*
                   */  _s(5)  as res %6.2f = `MXstar'[`vars'-(`i'-1),1]    /*
                   */  _s(10) as res %6.2f = `TRstar'[`vars'-(`i'-1),1]
            }

            n di _n "{txt}{col 5}Table/Case: {res:`case'}  "
            n di "{txt}{col 5}(assumption: {res:`assum'})" _n
            n di "{txt}{col 18}H0:{col 25}{c |}   Max-lambda{col 47}Trace"
            n di "{txt}{col 14}{dup 11:{c -}}{c +}{dup 32:{c -}}"
            forv i = 1/`vars' {
                  n di _s(14) as txt %5.0f `i'-1  _s(5) "{txt}{c |}"   /*
                   */  _s(5)  as res %6.2f = `MX'[`vars'-(`i'-1),1]    /*
                   */  _s(10) as res %6.2f = `TR'[`vars'-(`i'-1),1]
            }
      }
      else {
            local case 0
            local assum "no intercept, no trend"
            Case`case' `MX' `TR'
            mat `MX' = `MX'*`rLevel'
            mat `TR' = `TR'*`rLevel'

            n di _n "{txt}{col 5}Table/Case {res:`case'}  " _c
            n di "{txt}(assumption: {res:`assum'})"
            n di "{txt}{col 18}H0:{col 25}{c |}   Max-lambda{col 47}Trace"
            n di "{txt}{col 5}{dup 20:{c -}}{c +}{dup 32:{c -}}"
            forv i = 1/`vars' {
                  n di _s(14) as txt %5.0f `i'-1  _s(5) "{txt}{c |}"   /*
                   */  _s(5)  as res %6.2f = `MX'[`vars'-(`i'-1),1]    /*
                   */  _s(10) as res %6.2f = `TR'[`vars'-(`i'-1),1]
            }
      }

      /* Calculate normalized and standardized eigenvectors and their
         corresponding weight matrices, i.e., alpha and beta-prime.

         First calculate the normalized matrices */

      mat `TEVECT' = `EVECT''
      mat `NBP' = `TEVECT'*`ICHOLD'
      mat rownames `NBP' = `vecl'
      mat colnames `NBP' = `varlist'

      mat `TALPHA' = `NBP'*`TSDL'
      mat `NA' = `TALPHA''
      mat rownames `NA' = `varlist'
      mat colnames `NA' = `vecl'

      /* Remaining matrix calculations are not stored. Calculate only if the
         `matrix' option is specified. */

      if `matrix' {
            if `normal' {
                  n di _n as txt "Normalized Beta'"
                  n mat l `NBP', nob noh
                  n di _n as txt "Normalized Alpha"
                  n mat l `NA', nob noh
            }     /* end normalized matrices */

            /* Now calculate the standardized matrices */

            if `standard' {
                  mat `SBETAP' = J(`vars',`vars',0)
                  forv i = 1/`vars' {
                        forv j = 1/`vars' {
                              mat `SBETAP'[`i',`j'] =                       /*
                                 */         `NBP'[`i',`j']/`NBP'[`i',`i']
                        }
                  }
                  mat rownames `SBETAP' = `vecl'
                  mat colnames `SBETAP' = `varlist'
                  n di _n as txt "Standardized Beta'"
                  n mat l `SBETAP', nob noh
                  mat `STALPHA' = J(`vars',`vars',0)
                  forv i = 1/`vars' {
                        forv j = 1/`vars' {
                              mat `STALPHA'[`i',`j'] =                      /*
                                 */     `TALPHA'[`i',`j']* `NBP'[`i',`i']
                        }
                  }
                  mat `SALPHA' = `STALPHA''
                  mat rownames `SALPHA' = `varlist'
                  mat colnames `SALPHA' = `vecl'
                  n di _n as txt "Standardized Alpha"
                  n mat l `SALPHA', nob noh
            }     /* end standardized matrices */
      }         /* end of unstored matrix results */

      /* Coefficient vectors of deterministic elements mu0, mu1 */

      if ("`constant'"=="" | "`trend'"!="") {
            tokenize `varlist'
            forv i = 1/`vars' {
                  reg d.``i'' l(1/`lags')d.(`varlist') l.(`varlist') `exog' /*
                                                     */   `trend', `constant'
                  if ("`constant'"=="") {
                        local cons = _b[_cons]
                        mat mu0 = (nullmat(mu0) \ `cons')
                  }
                  if ("`trend'"!="") {
                        local tren = _b[`trend']
                        mat mu1 = (nullmat(mu1) \ `tren')
                  }
            }
            cap mat rownames mu0 = `varlist'
            cap mat colnames mu0 = _cons
            cap mat rownames mu1 = `varlist'
            cap mat colnames mu1 = trend
      }

      /* Store estimation results for later use */

      local N = e(N)
      est clear
      est local if "`if'"
      est local in "`in'"
est local by = _by()
      est local tmax `tmax'
      est local tmin `tmin'
      est sca lags = `lags'+1       /* lags() on input */
      est sca N = `N'
      if "`constant'" == "" { est mat mu0 mu0 }
      if "`trend'" != "" { est mat mu1 mu1 }
      est mat ISDD `ISDD'
      est mat SDL `SDL'
      est mat SLL `SLL'
      est mat TEVL `TEVL'
      est mat TSDL `TSDL'
      est mat NA `NA'
      est mat NBP `NBP'
      est local exog "`exog'"
      est local cmd "johans"

}     /* end quietly */
end


program define Case0
      args MX TR

mat `MX'     = [ 0.58,  1.82,  2.86,  3.84,  4.93,  6.51 \   /*
           */    4.83,  7.58,  9.52, 11.44, 13.27, 15.69 \   /*
           */    9.71, 13.31, 15.59, 17.89, 20.02, 22.99 \   /*
           */   14.94, 18.97, 21.58, 23.80, 26.14, 28.82 \   /*
           */   20.16, 24.83, 27.62, 30.04, 32.51, 35.17 \   /*
           */   25.54, 30.37, 33.62, 36.36, 38.59, 41.00 \   /*
           */   30.65, 36.01, 38.98, 41.51, 44.28, 47.15 \   /*
           */   36.18, 41.65, 44.99, 47.99, 50.78, 53.90 \   /*
           */   41.36, 47.26, 50.65, 53.69, 56.55, 59.78 \   /*
           */   46.69, 52.65, 56.09, 59.06, 61.57, 65.21 \   /*
           */   52.06, 58.11, 61.96, 65.30, 68.35, 72.36  ]

mat `TR'     = [  0.58,   1.82,   2.86,   3.84,   4.93,   6.51 \   /*
           */     5.42,   8.45,  10.47,  12.53,  14.43,  16.31 \   /*
           */    14.30,  18.83,  21.63,  24.31,  26.64,  29.75 \   /*
           */    27.10,  33.16,  36.58,  39.89,  42.30,  45.58 \   /*
           */    43.79,  51.13,  55.44,  59.46,  62.91,  66.52 \   /*
           */    64.24,  73.10,  78.36,  82.49,  86.09,  90.45 \   /*
           */    88.53,  98.87, 104.77, 109.99, 114.22, 119.80 \   /*
           */   116.97, 128.67, 135.24, 141.20, 146.78, 152.32 \   /*
           */   148.61, 161.63, 169.45, 175.77, 181.44, 187.31 \   /*
           */   184.15, 198.04, 206.05, 212.67, 219.88, 226.40 \   /*
           */   223.51, 239.44, 248.45, 255.27, 261.71, 269.81  ]
end


program define Case1
      args MX TR MXstar TRstar

mat `MXstar' = [ 3.40,  5.91,  7.52,  9.24, 10.80, 12.97 \   /*
           */    8.27, 11.54, 13.75, 15.67, 17.63, 20.20 \   /*
           */   13.47, 17.40, 19.77, 22.00, 24.07, 26.81 \   /*
           */   18.70, 22.95, 25.56, 28.14, 30.32, 33.24 \   /*
           */   23.78, 28.76, 31.66, 34.40, 36.90, 39.79 \   /*
           */   29.08, 34.25, 37.45, 40.30, 43.22, 46.82 \   /*
           */   34.73, 40.13, 43.25, 46.45, 48.99, 51.91 \   /*
           */   39.70, 45.53, 48.91, 52.00, 54.71, 57.95 \   /*
           */   44.97, 50.73, 54.35, 57.42, 60.50, 63.71 \   /*
           */   50.21, 56.52, 60.25, 63.57, 66.24, 69.94 \   /*
           */   55.70, 62.38, 66.02, 69.74, 72.64, 76.63  ]

mat `TRstar' = [  3.40,   5.91,   7.52,   9.24,  10.80,  12.97 \   /*
           */    11.25,  15.25,  17.85,  19.96,  22.05,  24.60 \   /*
           */    23.28,  28.75,  32.00,  34.91,  37.61,  41.07 \   /*
           */    38.84,  45.65,  49.65,  53.12,  56.06,  60.16 \   /*
           */    58.46,  66.91,  71.86,  76.07,  80.06,  84.45 \   /*
           */    81.90,  91.57,  97.18, 102.14, 106.74, 111.01 \   /*
           */   109.17, 120.35, 126.58, 131.70, 136.49, 143.09 \   /*
           */   139.83, 152.56, 159.48, 165.58, 171.28, 177.20 \   /*
           */   174.88, 198.08, 196.37, 202.92, 208.81, 215.74 \   /*
           */   212.93, 228.08, 236.54, 244.15, 251.30, 257.68 \   /*
           */   254.84, 272.82, 282.45, 291.40, 298.31, 307.64  ]

mat `MX'     = [ 0.44,  1.66,  2.69,  3.76,  4.95,  6.65 \   /*
           */    6.85, 10.04, 12.07, 14.07, 16.05, 18.63 \   /*
           */   12.34, 16.20, 18.60, 20.97, 23.09, 25.52 \   /*
           */   17.66, 21.98, 24.73, 27.07, 28.98, 32.24 \   /*
           */   23.05, 27.85, 30.90, 33.46, 35.71, 38.77 \   /*
           */   28.45, 33.67, 36.76, 39.37, 41.86, 45.10 \   /*
           */   33.83, 39.12, 42.32, 45.28, 47.96, 51.57 \   /*
           */   39.29, 45.05, 48.33, 51.42, 54.29, 57.69 \   /*
           */   44.58, 50.55, 53.98, 57.12, 59.33, 62.80 \   /*
           */   49.66, 55.97, 59.62, 62.81, 65.44, 69.09 \   /*
           */   54.99, 61.55, 65.38, 68.83, 72.11, 75.95  ]

mat `TR'     = [  0.44,   1.66,   2.69,   3.76,   4.95,   6.65 \   /*
           */     7.55,  11.07,  13.33,  15.41,  17.52,  20.04 \   /*
           */    18.70,  23.64,  26.79,  29.68,  32.56,  35.65 \   /*
           */    33.60,  40.15,  43.95,  47.21,  50.35,  54.46 \   /*
           */    52.30,  60.29,  64.84,  68.52,  71.80,  76.07 \   /*
           */    75.26,  84.57,  89.48,  94.15,  98.33, 103.18 \   /*
           */   101.22, 112.30, 118.50, 124.24, 128.45, 133.57 \   /*
           */   131.62, 143.97, 150.53, 156.00, 161.32, 168.36 \   /*
           */   165.11, 178.90, 186.39, 192.89, 198.82, 204.95 \   /*
           */   202.58, 217.81, 225.85, 233.13, 239.46, 247.18 \   /*
           */   243.90, 260.82, 269.96, 277.71, 284.87, 293.44  ]
end


program define Case2
      args MX TR MXstar TRstar

mat `MXstar' = [ 5.55,  8.65, 10.49, 12.25, 14.21, 16.26 \   /*
           */   10.90, 14.70, 16.85, 18.96, 21.14, 23.65 \   /*
           */   16.24, 20.45, 23.11, 25.54, 27.68, 30.34 \   /*
           */   21.50, 26.30, 29.12, 31.46, 33.60, 36.65 \   /*
           */   26.72, 31.72, 34.75, 37.52, 40.01, 42.36 \   /*
           */   32.01, 37.50, 40.91, 43.97, 46.84, 49.51 \   /*
           */   37.57, 43.11, 46.32, 49.42, 51.94, 54.71 \   /*
           */   42.72, 48.56, 52.16, 55.50, 58.08, 62.46 \   /*
           */   48.17, 54.34, 57.87, 61.29, 64.12, 67.88 \   /*
           */   53.21, 59.49, 63.18, 66.23, 69.56, 73.73 \   /*
           */   58.54, 64.97, 69.26, 72.72, 75.72, 79.23  ]

mat `TRstar' = [  5.55,   8.65,  10.49,  12.25,  14.21,  16.26 \   /*
           */    15.59,  20.19,  22.76,  25.32,  27.75,  30.45 \   /*
           */    29.53,  35.56,  39.06,  42.44,  45.42,  48.45 \   /*
           */    47.17,  54.80,  59.14,  62.99,  66.25,  70.05 \   /*
           */    68.64,  77.83,  83.20,  87.31,  91.06,  96.58 \   /*
           */    94.05, 104.73, 110.42, 114.90, 119.29, 124.75 \   /*
           */   122.87, 134.57, 141.01, 146.76, 152.52, 158.49 \   /*
           */   155.40, 169.10, 176.67, 182.82, 187.91, 196.08 \   /*
           */   192.37, 207.25, 215.17, 222.21, 228.05, 234.41 \   /*
           */   231.59, 247.91, 256.72, 263.42, 270.33, 279.07 \   /*
           */   276.34, 294.12, 303.13, 310.81, 318.02, 327.45  ]

mat `MX'     = [ 0.45,  1.61,  2.57,  3.74,  4.85,  6.40 \   /*
           */    8.84, 12.55, 14.84, 16.87, 18.57, 21.47 \   /*
           */   14.70, 18.94, 21.53, 23.78, 26.07, 28.83 \   /*
           */   19.99, 24.81, 27.76, 30.33, 32.56, 35.68 \   /*
           */   25.78, 30.75, 33.74, 36.41, 38.68, 41.58 \   /*
           */   30.96, 36.51, 39.50, 42.48, 45.12, 48.17 \   /*
           */   36.44, 42.07, 45.49, 48.45, 51.46, 54.48 \   /*
           */   41.68, 47.51, 51.14, 54.25, 56.87, 60.81 \   /*
           */   46.92, 53.12, 57.01, 60.29, 62.98, 66.91 \   /*
           */   52.33, 59.01, 62.69, 66.10, 69.41, 72.96 \   /*
           */   57.76, 64.40, 68.22, 71.68, 74.90, 78.51  ]

mat `TR'     = [  0.45,   1.61,   2.57,   3.74,   4.85,   6.40 \   /*
           */     9.68,  13.56,  16.06,  18.17,  20.13,  23.46 \   /*
           */    22.66,  28.13,  31.42,  34.55,  36.94,  40.49 \   /*
           */    39.43,  46.66,  50.74,  54.64,  57.79,  61.24 \   /*
           */    60.33,  68.66,  73.40,  77.74,  80.94,  85.78 \   /*
           */    84.53,  94.45, 100.14, 104.94, 109.62, 114.36 \   /*
           */   112.75, 124.18, 130.84, 136.61, 141.55, 146.99 \   /*
           */   144.39, 157.11, 164.34, 170.80, 176.43, 182.51 \   /*
           */   179.72, 194.04, 201.95, 208.97, 215.41, 222.46 \   /*
           */   219.42, 235.26, 244.12, 250.84, 256.60, 263.94 \   /*
           */   262.30, 279.31, 288.08, 295.99, 303.98, 312.58  ]
end
