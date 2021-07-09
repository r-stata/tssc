* ! version 0.0.1  2009-12-28 jx

// Compute averaged differences in predicted probabilities in binary regressions
// TO DO: not in planning at this point

capture program drop gradip     
program define gradip, rclass     
    version 10.0     
    tempname    xbase xbase1 xbase2 xbase3 xbase4       ///
                adip adiptmp adip_hi adip_lo adipmat    ///
                post_name post_file post_var lastest    ///
                totobs                                  ///
                z           // z score associated with confidence level
    tempvar     touse    
    tempfile     
         
    syntax [varlist(numeric min=1 max=1)] [if] [in],                ///
        [x(passthru) rest(passthru) level(integer $S_level) all     /// 
        From(real -867.5309) To(real 867.5309)                      ///
        Group(string)                                               ///
        Reps(int 1000)  SIze(int -9) dots]                          // 

//  MODELS APPLIED
    
        if "`e(cmd)'"=="logistic" | ///
           "`e(cmd)'"=="logit"    {
            local io = "typical binary"
        }
        
   
        if "`io'"=="" {
            di in r "this grcompare command does not work for the last type of model estimated."
            exit
    }        
    
    di _skip(1)
    di in g         "Computational Note for Average Group Difference"    ///
        _newline    "======================================================================"    ///
        _newline    "{b_c*(v2-v1)}^(-1)*{[ln(exp(-xb|g=1,c=v2)+1)-ln(exp(-xb|g=0,c=v2)+1)]-"    ///
        _newline    "                    [ln(exp(-xb|g=1,c=v1)+1)-ln(exp(-xb|g=0,c=v1)+1)]} " 

    // get change var names
    loc varcoef `varlist' // only one variable's name
    // decode groupvar into three parts
    gettoken grpvar group: group, parse(" ")    // group variable name
    gettoken grp0 group: group, parse(" ")      // group 0 group value
    gettoken grp1: group, parse(" ")            // group 1 group value                 
    
    
    loc cmdline "`e(cmdline)'"
    if "`size'"=="-9" | "`size'"=="" { // -9 is default for size
        loc size = e(N)
    } 
    local dots = cond("`dots'"=="", "*", "noisily")
    mark `touse' if e(sample)
    
    sca `z' = -invnorm((1-`level'/100)/2) 
    
    // command from SPost to get number of indepvars and indepvar names
    _perhs
    loc nrhs = `r(nrhs)'
    loc rhsnms "`r(rhsnms)'"
       
    * locate specified variable among rhs variables
    loc fndcnt "no"
    loc fndgrp "no"
    loc varnumcnt -1
    loc varnumgrp -1
    
    *look in main equation, if not there: varnum == -1
    // check if the group variable and the continuous variable (varlist) are in the estimation model
    loc i = 1
    loc i_to : word count `rhsnms'
    while `i' <= `i_to' {
        loc varchk : word `i' of `rhsnms'
        unab varchk : `varchk', max(1)
        
        if "`varlist'"=="`varchk'" {
            loc fndcnt "yes"
            loc varnumcnt = `i'            
        }
        
        if "`grpvar'"=="`varchk'"    {
            loc fndgrp "yes"
            loc varnumgrp = `i'        
        }
        
        if "`varnumcnt'"!="-1" & "`varnumgrp'"!="-1"    {
            loc i = `i_to'
        }
        
        local i = `i' + 1
    }
    
    // get base values
    _pebase `if' `in', `x' `rest' `all' 
    * mat list r(pebase)
    // without one
    mat `xbase' = r(pebase) 
    forvalues i2 = 1/4{
        mat `xbase`i2'' = `xbase'    
    }
    
    // replace the groupvar's values for group 1 and group 0
    // replace the continuous var's value (from and to)
    mat `xbase1'[1, `varnumcnt'] = `from'
    mat `xbase1'[1, `varnumgrp'] = `grp0'
    
    mat `xbase2'[1, `varnumcnt'] = `to'
    mat `xbase2'[1, `varnumgrp'] = `grp0'
    
    mat `xbase3'[1, `varnumcnt'] = `from'
    mat `xbase3'[1, `varnumgrp'] = `grp1'
    
    mat `xbase4'[1, `varnumcnt'] = `to'
    mat `xbase4'[1, `varnumgrp'] = `grp1'
    
    
    // compute linear predictors for the four locales
    forvalues i3 = 1/4    {
        tempname matxb`i3' xb`i3'
        mat PE_in = `xbase`i3''
        _pepred, level(`level') 
        mat `matxb`i3'' = r(xb)
        sca `xb`i3''    = `matxb`i3''[1,1]    
    }
    
    // compute the group comparison statistic
    sca `adip' =     (_b[`varcoef']*(`to'-`from'))^(-1)*(           ///
                                        (ln(exp(-1*`xb4')+1)        ///
                                        -ln(exp(-1*`xb2')+1))       ///
                                    -   (ln(exp(-1*`xb3')+1)        ///
                                        -ln(exp(-1*`xb1')+1))       ///
                    ) 
    *mat list `xbase1'
    *di in y `xb1'                        
    *di in y `adip'
    
    
    // bootstrap this statistic
    _estimates hold `lastest', restore 
    qui postfile `post_name' `post_var' using `post_file', replace    
    *set seed 123454321    
        
    forvalues i=1/`reps'{    
        quietly {        
                    `dots' dodot `reps' `i'    
                    preserve    
                    keep if `touse'    
                    bsample `size'    
                    `cmdline'    
          
                    forvalues j = 1/4    {
                        tempname matxb`j' xb`j'
                        // command from SPost to get predictions for the linear predictor
                        mat PE_in = `xbase`j''
                        _pepred, level(`level') 
                        mat `matxb`j'' = r(xb)
                        sca `xb`j''    = `matxb`j''[1,1]    
                    }   
    
                    sca `adiptmp' =     (_b[`varcoef']*(`to'-`from'))^(-1)*(            ///
                                                            (ln(exp(-1*`xb4')+1)        ///
                                                            -ln(exp(-1*`xb2')+1))       ///
                                                        -   (ln(exp(-1*`xb3')+1)        ///
                                                            -ln(exp(-1*`xb1')+1))       ///
                                        )  
                   
                    post `post_name' (`adiptmp')     
                    restore    
        }    
    }    
    postclose `post_name'    
    
    
    // use percentile to construct confidence interval
    preserve            
    use `post_file', clear    
    qui count    
    sca `totobs' = r(N)            
        
    qui _pctile `post_var', nq(1000)    
    loc upperpctile = 500 - 5*-`level'    
    loc lowerpctile = 1000 - `upperpctile'    
    sca `adip_hi' = r(r`upperpctile')    
    sca `adip_lo' = r(r`lowerpctile')    
    *di in y `gavgdip_lo' `gavgdip' `gavgdip_hi'    
    mat `adipmat' = `adip_lo', `adip', `adip_hi' 
    mat colnames `adipmat' = adip_lo adip adip_hi
    mat list `adipmat', noheader
    ret mat adipmat = `adipmat'    
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

