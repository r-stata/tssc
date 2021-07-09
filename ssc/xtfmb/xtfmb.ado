*! xtfmb, version 2.0.0, Daniel Hoechle, 10sep2011
* 
* This program is an implementation of Fama and MacBeth's (1973) 
* two-step algorithm.
*
*
* Syntax:
* =======
* 
*   xtfmb depvar [indepvar] [if] [in] [aweight=exp] [, Level(cilevel) VERBose LAG(integer 9999)]
*   xtfmb is byable.
* 
* Notes:
* ======
* 
* (1) Post-estimation commands other than -test- won't work since it is 
*     not clear what the residuals of the Fama and MacBeth (1973) procedure are.
* 
* (2) Version 1.0.2 corrects a bug when using weighted estimation.
* 
* (3) Version 1.0.3 adds option verbose which allows for listing the coefficient
*     estimates and R2 of all cross-sectional regressions estimated in step 1
*     of the procedure.
* 
* (4) Version 2.0.0 adds option lag. If a lag is provided, then heteroscedasticity and
*     autocorrelation up to LAG periods consistent standard error estimates for the Fama-
*     MacBeth coefficients are provided. However, note that in this case post-estimation
*     command -test- with multivariate tests won't work.
* 
* ==============================================================
* Daniel Hoechle, 10. September 2011
* ==============================================================

capture program drop xtfmb
program define xtfmb , eclass sortpreserve byable(recall)
  version 9.2

  if !replay() {
      tempname b V
      tempvar ones
      ereturn clear
      syntax varlist(numeric) [if] [in] [aweight/] [, Level(cilevel) VERBose LAG(integer 9999)]
      marksample touse
      
      * Check if the dataset is tsset:
        qui tsset
        local panelvar "`r(panelvar)'"
        local timevar  "`r(timevar)'"

      * Split varlist into dependent and independent variables:
        tokenize `varlist'
        local lhsvar "`1'"
        macro shift 1
        local rhsvars "`*'"

      * Count the total number of observations:
        qui count if `touse'
        scalar nObs = r(N)

      * preserve the dataset:
        preserve

      * Produce the first step of the Fama-MacBeth (1973) procedure:
        if "`weight'"=="" {
             qui statsby _b e(r2), by(`timevar') clear:     ///
                    reg `lhsvar' `rhsvars' if `touse'
         }
         else {
             qui statsby _b e(r2), by(`timevar') clear:     ///
                    reg `lhsvar' `rhsvars' if `touse' [aweight=`exp']
         }
      
      * Rename the resulting variable names and the name for the R-squared:
        qui foreach var of local rhsvars {
            rename _b_`var' `var'
        }
        rename _b_cons constant
        rename _eq2_stat_1 R2
        
      * Perform the second step of the Fama-MacBeth procedure. 
      
        if `lag'==9999 {
           * Instead of just computing the mean value and the standard deviation for each 
           * coefficient estimate, we estimate the final coefficient estimates
           * by aid of SUR. To do so, we apply Stata's -mvreg- command as follows:
             gen `ones' = 1
             qui mvreg `rhsvars' constant = `ones', noconstant
             matrix Beta = e(b)
             matrix VCV = e(V)
             scalar nYears = e(N)
        }
        else {
             qui tsset `timevar'
             local AllVars "`rhsvars' constant"
             scalar Dim = wordcount("`AllVars'")
             matrix Beta = J(1,Dim,0)
             matrix VCV = J(Dim,Dim,0)
             local Counter = 1
             qui foreach var of local AllVars {
                newey `var' , lag(`lag')
                matrix Beta[1,`Counter'] = e(b)
                matrix VCV[`Counter',`Counter'] = e(V)
                scalar nYears = e(N)
                local Counter = `Counter' + 1
             }
        }
        
        
        qui sum R2, meanonly
        local avgR2 = r(mean)
        
        if "`verbose'"!="" {
             tempfile CRRes
             qui save `CRRes', replace
         }
        
      * restore the dataset: 
        restore
      
      * Next, we have to attach row and column names to the produced matrices:
        foreach var of local rhsvars {
            local CNames "`CNames' :`var'"
        }
            
        matrix rownames Beta = y1
        matrix colnames Beta = `CNames' :_cons
        matrix rownames VCV = `CNames' :_cons
        matrix colnames VCV = `CNames' :_cons

        ereturn clear

      * Then we prepare the matrices for upload into e() ...
        matrix `b' = Beta
        matrix `V' = VCV

      * ... post the results in e():
        ereturn post `b' `V', esample(`touse') depname("`lhsvar'")
        ereturn scalar N = nObs
        ereturn scalar N_g = nYears
        ereturn scalar df_m = wordcount("`rhsvars'")
        ereturn scalar df_r = nYears - 1

        qui if "`rhsvars'"!=""  test `rhsvars', min   // Perform the F-Test
        ereturn scalar F = r(F)

        ereturn scalar r2 = `avgR2'

        if "`weight'"==""   ereturn local title "Fama-MacBeth (1973) Two-Step procedure"
        else                ereturn local title "Weighted Fama-MacBeth (1973) 2-Step procedure"
        ereturn local vcetype "Fama-MacBeth"
        ereturn local depvar "`lhsvar'"
        ereturn local method "Fama-MacBeth Two-Step procedure"
        ereturn local cmd "xtfmb"
  }
  else {      // Replay of the estimation results
        if "`e(cmd)'"!="xtfmb" error 301
        syntax [, Level(cilevel)]
  }
  
  * Display the results
    local R2text "avg. R-squared    =    "
    if `lag'!=9999    local SE_Text "Newey-West corrected SE (lag length: `lag')"
              
  * Header
    #delimit ;
    disp _n
      in green `"`e(title)'"'
      _col(50) in green `"Number of obs     ="' in yellow %10.0f e(N) _n
      _col(50) in green `"Num. time periods ="' in yellow %10.0f e(N_g) _n
      _col(50) in green `"F("' in yellow %3.0f e(df_m) in green `","' in yellow %6.0f e(df_r)
      in green `")"' _col(68) `"="' in yellow %10.2f e(F) _n
      _col(50) in green `"Prob > F          =    "' 
      in yellow %6.4f fprob(e(df_m),e(df_r),e(F)) _n 
      _col(1) in green `"`SE_Text'"'
      _col(50) in green `"`R2text'"' in yellow %5.4f e(r2)
      ;
    #delimit cr

  * Estimation results
    ereturn display, level(`level')
    
  * Potentially list the regression results from the first step regressions:  
    if "`verbose'"!="" {
       preserve
       qui use `CRRes', clear
       capture drop `ones'
       disp _n  in green "Coefficient estimates and R-squared of the cross-sectional regressions in step 1"
       list * , table mean(`rhsvars' constant R2) N(`rhsvars' constant R2) noobs labvar(`timevar') separator(0)
       restore
    }

   disp ""
       
end
