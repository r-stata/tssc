*! version 0.0.5 2009-12-28 jx
* 

// Compute Marginal Effects and Compare Differences in Binary Regression Models Using Bootstrap and Delta

//  TO DO: not in planning at this point

capture program drop grmarg
program define grmarg, rclass

    *local caller = _caller()  // which version called prvalue
    version 8
    
//  decode options and setup error traps

    syntax [if] [in] [, x(passthru) Rest(passthru) Save Diff all  ///
        LEvel(passthru) noBAse  ///
        DELta  DYDXmat(passthru)  ///
        BOOTstrap REPs(passthru) SIze(passthru) DOts] // 

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

    // option error 1: delta option and boot option present    
    if "`dydxmat'"!="" & (  "`reps'"!="" | ///
                            "`size'"!="" | ///
                            "`dots'"!="" | ///
                            "`iterate'"!="")  {
        di as error "You used incompatible options from both the delta and bootstrap methods."
        exit                 
    }
    
    // option error 2: delta and boot option present OR boot and delta option present
    if ("`delta'"!="" & (   "`reps'"!="" | ///
                            "`size'"!="" | ///
                            "`dots'"!="" | ///
                            "`iterate'"!="")) |   ///                            
       ("`bootstrap'"!="" & "`dydxmat'"!="") {
        di as error "You used incompatible options from both the delta and bootstrap methods."
        exit                 
    }

    // option error 3: delta absent with boot options present OR boot absent with delta options present
    if ("`delta'"=="" & (   "`reps'"!="" | ///
                            "`size'"!="" | ///
                            "`dots'"!="" | ///
                            "`iterate'"!="")) {
        loc bootstrap "bootstrap"
    }     
    if "`bootstrap'"=="" & "`dydxmat'"!=""  {
        loc delta "delta"
    }
    
    // boot and delta all missing OR all present, choose delta method
    if ("`bootstrap'"=="" & "`delta'"=="")  |   ///
       ("`bootstrap'"!="" & "`delta'"!="") {
       di _skip(1)
       di in y "This program chose the default delta method."
       loc delta "delta"
    }
    
    if "`save'"!="" {
        global grcimet "`bootstrap'`delta'"
    }
    
    if "`diff'"!="" & "`bootstrap'`delta'"!="$grcimet"   {
        di as error "Your current method for computing confidence intervals is different than your saved one."
        exit
    }    

//  computation
    if "`delta'" == "delta"  {
        _grmargd `if' `in', `x' `rest' `level' `base' `all' `save' `diff'    ///
                            `dydxmat'
    }

    if "`bootstrap'" == "bootstrap"   {
        _grmargb `if' `in', `x' `rest' `level' `base' `all' `save' `diff' ///
                            `reps' `size' `dots' `iterate' 
    }
    
    
end
