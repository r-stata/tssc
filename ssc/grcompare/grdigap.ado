*! version 0.0.2 2010-06-04
*  1. add computation for differences in casewise group averaged predicted probabilities
*     what it does is to compute two predicted probabilites for each case in estimation sample by varying group membership from 0 to 1
*     then take a difference between these two and last average across all cases.
*  version 0.0.1 2009-12-28 jx
* do d:\project\stats\brgc\grcompare\grdigap.ado

// Difference in group average predicted prob in binary regressions using bootstrap

// TO DO List:

     capture program drop grdigap
     program define grdigap, rclass
         version 10.0
         syntax [if] [in] [,level(integer $S_level)         ///
                            Group(string)                   ///
                            Reps(int 1000)  SIze(int -9)    ///
                            Casewise                        ///
                            dots]                           //
                            
        tempname    post_name   /// post name
                    post_var    /// post variable name
                    lastest     /// last estimation results
                    totobs      /// total observations
                    p1          /// predicted probabilities of y=1
                    g1avgp      /// group 1 averaged predicted probabilities
                    g0avgp      /// group 0 averaged predicted probabilities
                    gavgdip     /// group averaged difference in predicted probabilities
                    gavgdip_hi  ///
                    gavgdip_lo  ///
                    gavgdipmat  //
        tempvar     p1  p1tmp               /// variable containing predicted probabilities of y=1 for all sample observations
                    p1a p1atmp              ///
                    p1b p1btmp              ///
                    p1grp1 p1grp1tmp        ///
                    p1grp0 p1grp0tmp        ///                    
                    touse                   // sample marker                    
        tempfile post_file
        
//  MODELS APPLIED
    
        if "`e(cmd)'"=="logistic" | ///
           "`e(cmd)'"=="logit"    | ///
           "`e(cmd)'"=="probit"   | ///
           "`e(cmd)'"=="cloglog"    {
            local io = "typical binary"
        }
        
   
        if "`io'"=="" {
            di in r "this grcompare command does not work for the last type of model estimated."
            exit
        }
    
        // decompost the groupvar option into three parts
        gettoken grpvar group: group, parse(" ")    // group variable name
        gettoken grp0 group: group, parse(" ")      // group 0 group value
        gettoken grp1: group, parse(" ")            // group 1 group value        
        
        loc cmdline "`e(cmdline)'"
        if "`size'"=="-9" | "`size'"=="" { // -9 is default for size
            loc size = e(N)
        }
        local dots = cond("`dots'"=="", "*", "noisily")
        mark `touse' if e(sample)
        // hold last estimation results, and restore it when the program ends normally or there is an error 

        
        if "`casewise'" == "" {
            // get predictions for two groups
            qui predict `p1', p
            qui sum `p1' if `touse' & `grpvar'==`grp1' 
            sca `g1avgp' = r(mean)
            qui sum `p1' if `touse' & `grpvar'==`grp0'
            sca `g0avgp' = r(mean)
            // sca `gavgdip'= `g1avgp'-   `g0avgp'
        }
        
        // if casewise option is specified
        if "`casewise'" != ""  {
            
            preserve
            qui {
                predict `p1a', p
                gen double `p1grp1' = .
                gen double `p1grp0' = .
                replace `p1grp1' = `p1a' if `touse' & `grpvar'==`grp1' 
                replace `p1grp0' = `p1a' if `touse' & `grpvar'==`grp0' 
        
                recode `grpvar' `grp0'=`grp1' `grp1'=`grp0'
                predict `p1b', p
                replace `p1grp1' = `p1b' if `touse' & `grpvar'==`grp1' 
                replace `p1grp0' = `p1b' if `touse' & `grpvar'==`grp0' 
        
                sum `p1grp1' // if `touse' 
                sca `g1avgp' = r(mean)
                sum `p1grp0' // if `touse' 
                sca `g0avgp' = r(mean)
            }
            restore
        }
     
     
        sca `gavgdip'= `g1avgp'-   `g0avgp'    
        * sca list `gavgdip'
     
      
        // start of resampling
        _estimates hold `lastest', restore 
        qui postfile `post_name' `post_var' using `post_file', replace
               
        forvalues i=1/`reps'{
           quietly {    
                        `dots' dodot `reps' `i'
                        preserve
                        keep if `touse'
                        bsample `size'
                        // estimation from cmdline
                        `cmdline'
                        
                        if "`casewise'" == "" {
                            predict `p1tmp', p
                            sum `p1tmp' if `touse' & `grpvar'==`grp1' 
                            sca `g1avgp' = r(mean)
                            sum `p1tmp' if `touse' & `grpvar'==`grp0' 
                            sca `g0avgp' = r(mean)
                        }
                        
                        if "`casewise'" != ""  {
                            qui {
                                predict `p1atmp', p
                                gen double `p1grp1tmp' = .
                                gen double `p1grp0tmp' = .
                                replace `p1grp1tmp' = `p1atmp' if `touse' & `grpvar'==`grp1' 
                                replace `p1grp0tmp' = `p1atmp' if `touse' & `grpvar'==`grp0' 
        
                                recode `grpvar' `grp0'=`grp1' `grp1'=`grp0'
                                predict `p1btmp', p
                                replace `p1grp1tmp' = `p1btmp' if `touse' & `grpvar'==`grp1' 
                                replace `p1grp0tmp' = `p1btmp' if `touse' & `grpvar'==`grp0' 
        
                                sum `p1grp1tmp' // if `touse' 
                                sca `g1avgp' = r(mean)
                                sum `p1grp0tmp' // if `touse' 
                                sca `g0avgp' = r(mean)
                            } // end of quietly
                        }                        
                         
                        // compute the difference in group averaged predicted probabilities
                        loc gavgdiptmp= `g1avgp' - `g0avgp'
                        *di "`gavgdiptmp'"
                        post `post_name' (`gavgdiptmp') 
                        restore
                   }
            }
        postclose `post_name'
        
        // use percentile method to compute confidence intervals
        preserve        
        qui use `post_file', clear
        qui count
        sca `totobs' = r(N)        
        
        qui _pctile `post_var', nq(1000)
        loc upperpctile = 500 - 5*-`level'
        loc lowerpctile = 1000 - `upperpctile'
        sca `gavgdip_hi' = r(r`upperpctile')
        sca `gavgdip_lo' = r(r`lowerpctile')
        *di in y `gavgdip_lo' `gavgdip' `gavgdip_hi'
        mat `gavgdipmat' = `gavgdip_lo', `gavgdip', `gavgdip_hi'
        mat colnames `gavgdipmat' = dif_lo gavgdip dif_hi
        mat rownames `gavgdipmat' = lo_stat_hi
        di in g "Differences in Group Averaged Predicted Probabilities"
        mat list `gavgdipmat', noheader
        ret mat gavgdipmat = `gavgdipmat'
        restore
        *_estimates unhold `lastest'
    end
 
 
 * produce dots
 capture program drop dodot
 program define dodot
     version 8
     args N n
     tempname s
     local dot "."
     * don't bother with %'s if few than 20 reps
     if `N'>19 {
         scalar `s' = `N'/10
         forvalues c = 0/10 {
             local c`c' = floor(`c'*`s')
             if `n'==`c`c'' {
                 local pct = `c'*10
                 di in g `pct' "%" _c
                 local dot ""
                 * new line when iterations are done
                 if `pct'==100 {
                     di
                 }
             }
         } //forvalues
     } // if > 19
     di in g as txt "`dot'" _c
end

