*! version 2.1 January 5, 2003
* (C) Copyright 1998-2003 Michael Tomz, Jason Wittenberg, Gary King
* This file is part of the program Clarify.  All Rights Reserved.
* Simulate quantities of interest
program define simqi
   version 6.0
   * future: print-out x values for first differences (a listx for fd's)

   * MARK THE ORIGINAL DATASET (WE WILL REVERT TO IT)
   tempvar tokeep
   qui gen `tokeep' = 1

   * DID USER RUN ESTSIMP BEFORE CALLING THIS ROUTINE?
   local ecmd `e(cmd)'
   gettoken estsimp modname : ecmd   /* parse the command name */
   local modname = trim("`modname'")   /* trim leading spaces    */
   if "`estsimp'" ~= "estsimp" {
      di in r _n "Must run -estsimp- before -simqi-"
      exit 198
   }

   * DID USER RUN SETX, THEREBY CREATING THE MATRIX mrt_xc?
   capture mat list mrt_xc
   if _rc == 0  {                         
      local xccols : colnames(mrt_xc)   
      if "`xccols'" == "`e(rhsvars)'" { local xcfound yes }  
   }
   if "`xcfound'" ~= "yes" {
      di in r _newline "X-values missing or invalid.  Please rerun -setx-."
      exit 198
   }

   * ARE SIMULATED PARAMETERS (b1,b2,b3...) & DEPVAR STILL IN MEMORY?
   local nsims : word count `e(allsims)'
   tokenize "`e(allsims)'"
   local i 1                            
   while `i' <= `nsims' {             
      capture confirm variable ``i''
      if _rc {
         di in r _n "Can't find the simulated" _c
         di in r " variable ``1''.  Rerun -estsimp-"
         exit 198
      }
      local i = `i' + 1
   }
   tsunab var : `e(depvar)'
 
   * STRIP FD & CHANGEX FROM LIST OF OPTIONS THAT USER HAS SPECIFIED
   local opts `"`0'"'               /* list of all specified options */
   while "`opts'" ~= "" {
      if substr(trim("`opts'"),1,3) == "fd(" {  
         local opts : subinstr local opts "fd" ""
         gettoken opt opts : opts, match(p)
         local fd `fd' `opt' /* build a list of fd requests */
      }
      else if substr(trim("`opts'"),1,8) == "changex(" {
         local opts : subinstr local opts "changex" ""
         gettoken changex opts : opts, match(p)
      }
      else {
         gettoken opt opts : opts
         local rest `rest' `opt'
      }
   }
   if "`fd'" ~= "" & "`changex'" == "" {
      di in r _n "If you request a first difference, you must specify "
      di in r "the values of X by using the changex() option"
      exit 198
   }
   if "`fd'" == "" & "`changex'" ~= "" {
      di in r _n "If you include the changex() option, you must request "
      di in r "a first-difference by wrapping one of the options in fd()."
      exit 198
   }
   tokenize "`changex'", parse(",")
   if "`1'" == "," | "`2'" == "," {
      di in r _n "The changex option cannot contain a comma."
      exit 198
   }
   tokenize "`changex'", parse(";")
   if "`1'" == ";" | "`2'" == ";" {
      di in r _n "The changex option cannot contain a semicolon."
      exit 198
   }


   * APPLY HIGH-LEVEL PARSING TO REST OF OPTIONS
   local 0 `rest'  /* reassign to 0 for hi-level parse */
   syntax [, PV GENPV(str) EV GENEV(str) PR   /*
      */ PRVAL(numlist ascending) GENPR(str)  /*
      */ Level(real $S_level) LISTX           /*
      */ MSIMS(numlist integer >0 max=1) TFUNC(string)]
   tempvar sample                             /* mark the original sample  */
   mark `sample'

   * CHECK level
   if int(`level') ~= `level' {
      di in r _n "Confidence level must be an integer."
      exit 198
   }
   if `level' <= 0 | `level' >= 100 {
      di in r _n "Confidence level must be between 1 and 99, inclusive"
      exit 198
   }

   * CHECK tfunc: THE TRANSFORMATION FUNCTION THAT THE USER SELECTED
   * Note: user can only choose squared, sqrt, logiti, exp, or ln
   if "`tfunc'" ~= "" {
      if "`tfunc'" == "squared" { local tfuncOK yes }
      else if "`tfunc'" == "sqrt" { local tfuncOK yes }
      else if "`tfunc'" == "logiti" { local tfuncOK yes }
      else if "`tfunc'" == "exp" { local tfuncOK yes }
      else if "`tfunc'" == "ln" { local tfuncOK yes }
      else {
         di in r _n "tfunc(`tfunc') invalid"
         exit 198
      }
   } 

   * PARSE fd COMMANDS
   if "`fd'" ~= "" { _parsefd ,`fd' }  /* parse 1st difference args */
   local fdev `r(fdev)'                /* save fdev                 */
   local fdgenev `r(fdgenev)'          /* save fdgenev              */
   local fdpr `r(fdpr)'
   local fdprval `r(fdprval)'
   local fdgenpr `r(fdgenpr)'

   * CHECK ALL *gen OPTIONS: ARE THE SPECIFIED VARIABLES UNIQUE?
   local allgens `genpv' `genev' `fdgenev'
   if "`allgens'" ~= "" {
      local ngens : word count `allgens'   /* number of vars to generate    */
      tempvar genlist
      qui gen str1 `genlist' = "" in 1/`ngens'
      tokenize "`allgens'"
      local i 1
      while `i' <= `ngens' {
         confirm new variable ``i''
         qui replace `genlist' = "``i''" in `i'
         local i = `i' + 1
      }
      qui tab `genlist'
      if `r(r)' < `ngens' {
         di in r _n "Error: duplicate variables to generate"
         exit 198
      }
   }

   * PARSE changex COMMANDS
   local nrhsvar : word count `e(rhsvars)'                /* # rhs vars  */
   local allfds `changex'
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
      gettoken amper changex : changex, parse("&")       /* strip-off & */
   }

   * CREATE X-VECTORS (STARTING AND ENDING VECTORS) FOR changex SCENARIOS
   * Note: these vectors do *not* yet contain a constant term.  We'll add
   local i 1
   while `i' <= `nx' {
      tempname xcS`i' xcE`i'                  /* xcStart, xcEnd vectors */
      setx `slist`i'' $mrt_seto keepmrt  /* ?does mrt_seto always have , */
      matrix `xcS`i'' = r(mrt_xc)
      setx `elist`i'' $mrt_seto keepmrt
      matrix `xcE`i'' = r(mrt_xc)
      local i = `i' + 1
   }

   * ACTIVATE DEFAULT OPTIONS FOR EACH MODEL (MUST MODIFY FOR NEW MODEL)
   * Note: this is model-specific and needs to change when we add models
   local mainops `pv' `genpv' `ev' `genev' `pr' `prval' `genpr'/* not fd's */
   if "`mainops'" == "" & `nx' == 0 {
      if "`modname'" == "regress" { local ev ev }
      else if "`modname'" == "logit" { local pr pr }
      else if "`modname'" == "probit" { local pr pr }
      else if "`modname'" == "ologit" { local pr pr }
      else if "`modname'" == "oprobit" { local pr pr }
      else if "`modname'" == "mlogit" { local pr pr }
      else if "`modname'" == "poisson" { local ev ev }
      else if "`modname'" == "nbreg" { local ev ev }
      else if "`modname'" == "sureg" { local ev ev }
      else if "`modname'" == "weibull" { local ev ev }
   }
   * reconstruct
   local mainops `pv' `genpv' `ev' `genev' `pr' `prval' `genpr' 

   * MODEL-SPECIFIC CHECKS
   * Note: no reason to check pv option; it's allowed for all models
   local modabbr = substr("`modname'",1,6)
   CK`modabbr' "`genpv'" "`ev'" "`genev'" "`fdev'" "`fdgenev'" /*
      */ "`pr'" "`prval'" "`genpr'" "`fdpr'" "`fdprval'" "`fdgenpr'" /*
      */ "`nx'" "`msims'" "`tfunc'"  
   if `e(k_cat)' > 0 {   /* if model has categorical d.v. */
      tempname catdi fdcatdi
      matrix `catdi' = r(catdi)
      matrix `fdcatdi' = r(fdcatdi)
      local prval `r(prval)'       /* overwrite prval   */
      local fdprval `r(fdprval)'   /* overwrite fdprval */
   }

   * OUTPUT FOR MAIN OPERATIONS
   if "`mainops'" ~= "" {
      if "`listx'" ~= "" { List_XC }
      QI`modabbr', `pv' genpv("`genpv'") `ev' genev("`genev'") /*
         */ `pr' prval("`prval'") genpr("`genpr'") /*
         */ catdi("`catdi'")  level(`level') `listx' /*
         */ msims("`msims'") tfunc("`tfunc'") xfsetx(mrt_xc)
   }

   * OUTPUT FOR FIRST DIFFERENCES
   * If there are any first differences, build list of names for temporary
   * variables.  We will pass the lists to the QOI program
   * We also build labels for the dependent variable
   if `nx' > 0 {
      * Expected values
      if "`fdev'" ~= "" | "`fdgenev'" ~= "" {
         local minev `e(k_eq)'
         local i 1
         while `i' <= `minev' {
            * list of names
            tempvar evE_`i' evS_`i' fdev_`i'
            local evE `evE' `evE_`i''
            local evS `evS' `evS_`i''
            * labels for dependent variable
            local depvar : word `i' of `e(depvar)'
            if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }
            if "`tfunc'" == "" { local elab_`i' (`depvar') }
            else { local elab_`i' [`tfunc'(`depvar')] }
            local i = `i' + 1
         }
      }
      else { local minev 0 }
      * Probabilities
      if "`fdprval'" ~= "" | "`fdgenpr'" ~= "" {        
         * how many probability values do we need to calculate?
         if "`fdprval'" ~= "" { local vals `fdprval' }
         else {
            tempname ecat
            mat `ecat' = e(cat)
            local nvals : word count `fdgenpr'
            local i 1
            while `i' <= `nvals' {
               local val = `ecat'[1,`i']
               local vals `vals' `val'
               local i = `i' + 1
            }
         }
         local minpr : word count `vals'
         * make lists of minpr temporary variables
         local i 1
         while `i' <= `minpr' {
            tempvar prE`i' prS`i' fdpr`i'
            local prE `prE' `prE`i''
            local prS `prS' `prS`i''
            local value : word `i' of `vals'
            * FIX ME - ABBREVIATE DEPVAR
            local depvar `e(depvar)'
            if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }
            local prlab`i' dPr(`depvar' = `value')
            local i = `i' + 1
         }
      }
      else { local minpr 0 }
      * Note: we do not need list of names or labels for predicted values, 
      * because we don't allow first differences of predicted values
      * Create flag to indicate if we should print first differences
      local printfd `fdev' `fdprval'
      local fdgen `fdgenev' `fdgenpr'
   }
   local n 1
   while `n' <= `nx' {                
      * simulate and return E(Y)|xcE as temporary variables
      QI`modabbr', `fdev' fdgenev("`fdgenev'") `fdpr' /*
         */ fdprval("`fdprval'") fdgenpr("`fdgenpr'") /*
         */ fdcatdi("`fdcatdi'") msims("`msims'") tfunc("`tfunc'") /*
         */ xfsetx(`xcE`n'') evnames("`evE'") prnames("`prE'")
      * simulate and return E(Y)|xcS as temporary variables
      QI`modabbr', `fdev' fdgenev("`fdgenev'") `fdpr' /*
         */ fdprval("`fdprval'") fdgenpr("`fdgenpr'") /*
         */ fdcatdi("`fdcatdi'") msims("`msims'") tfunc("`tfunc'") /*
         */ xfsetx(`xcS`n'') evnames("`evS'") prnames("`prS'")
      if "`printfd'" ~= "" {
         * Print header for first differences (e.g. x1 min sqrt(10))
          gettoken fd allfds : allfds, parse("&")
          di _n(1) "First Difference: `fd'"
          _dihead1 `level'
          gettoken fd allfds : allfds, parse("&")
      }

      * first diffs of expected values
      * (loop through equations)
      local i 1
      while `i' <= `minev' {
         qui gen `fdev_`i'' = `evE_`i'' - `evS_`i''
         if "`printfd'" ~= "" {
            _sumdisp `fdev_`i'' `level' "dE`elab_`i''" printed
         }
         if "`fdgenev'" ~= "" {
            gettoken newvar fdgenev : fdgenev
            _genvar `fdev_`i'' `newvar' "fd`n': dE`elab_`i''"
         }
         drop `evE_`i'' `evS_`i'' `fdev_`i''
         local i = `i' + 1
      }

      * first diffs of probabilities
      * (loop through the requested probability values)
      local i 1
      while `i' <= `minpr' {
         qui gen `fdpr`i'' = `prE`i'' - `prS`i''
         if "`printfd'" ~= "" {
            _sumdisp `fdpr`i'' `level' "`prlab`i''" printed
         }
         if "`fdgenpr'" ~= "" {
            gettoken newvar fdgenpr : fdgenpr
            _genvar `fdpr`i'' `newvar' "fd`n': `prlab`i''"
         }
         drop `prE`i'' `prS`i'' `fdpr`i''
         local i = `i' + 1
      }
      local n = `n' + 1
   }
   if "`fdgen'" ~= "" { _newgens "`fdgen'" }

   * REVERT TO ORIGINAL DATASET
   qui keep if `tokeep' == 1

end


***************************** PARSING ROUTINES *****************************

program define _parsefd, rclass
   * Parses first difference options
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(numlist ascend) GENPR(str)]
   if "`pv'" ~= "" {
      di in r _n "fd(pv) invalid.  -simqi- does not simulate first " _c
      di in r "differences" _n "for predicted values."
      exit 198
   }
   if "`genpv'" ~= "" {
      di in r _n "fd(genpv(`genpv')) invalid.  -simqi- does not generate " _c
      di in r "first differences" _n "for predicted values."
      exit 198
   } 
   return local fdev `ev'
   return local fdgenev `genev'
   return local fdpr `pr'
   return local fdprval `prval'
   return local fdgenpr `genpr'
end


***** MODEL-SPECIFIC CHECKING PROGRAMS (MUST MODIFY FOR NEW MODEL) ******

program define CKregres, rclass
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`pr'`prval'`genpr'`fdpr'`fdprval'`fdgenpr'" ~= "" {
      di in r _n "Probabilities are not allowed with regression."
      exit 198
   }
   if "`msims'" ~= "" & "`tfunc'" == "" {
      di in g _n "Note: msims are not necessary with regress, unless you " /*
      */ " have specified a tfunc()." _n "  msims(`msims') ignored." _n
   }
   ck_genn 1 genpv "`genpv'" /* name only 1 in genpv */
   ck_genn 1 genev "`genev'" /* name only 1 in genev */
   ck_genn `nx' fd(genev()) "`fdgenev'"   /* name only nx in fdgenev */
end

program define CKsureg, rclass
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`pr'`prval'`genpr'`fdpr'`fdprval'`fdgenpr'" ~= "" {
      di in r _n "Probabilities are not allowed with sureg"
      exit 198
   }
   if "`msims'" ~= "" & "`tfunc'" == "" {
      di in g _n "Note: msims are not necessary with sureg, unless you "/*
      */ " have specified a tfunc()." _n "  msims(`msims') ignored." _n
   }
   ck_genn `e(k_eq)' genpv "`genpv'"          /* name only `e(k_eq)' vars  */
   ck_genn `e(k_eq)' genev "`genev'"          /* name only `e(k_eq)' vars  */
   ck_genn `nx'*`e(k_eq)' fd(genev()) "`fdgenev'"
end

program define CKlogit, rclass
   * output
   *   matrix r(catdi): row vector containing 1 if probability for category 
   *      i should be displayed on screen, 0 if not.  e.g. catdi=(0,0,1,0)
   *      indicates that 3rd cat should be displayed, others suppressed
   *   matrix r(fdcatdi): same, except applies to first differences
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`ev'`genev'`fdev'`fdgenev'" ~= "" {
      di in y _n "For models with binary dependent variables, simulated " /*
         */ "expected values are" _n "equivalent to simulated probabilities."/*
         */ "  Please use pr, prval(#), and/or" _n "genpr(varname) in place "/*
         */ "of ev or genev(varname)."
      exit 198
   }
   if "`tfunc'" ~= "" {    
      di in r _n "The tfunc() option does not work with the logit model."
      exit 198
   }
   if "`msims'" ~= "" {
      di in g _n "Note: msims are not necessary to compute probabilities "
      */ "for this model." _n "msims(`msims') ignored." _n
   }
   * Check genpv
   ck_genn 1 genpv "`genpv'"                  /* name only 1 var in genpv  */
   * Check pr, prval, genpr options
   *    Check that #s in prval correspond with values of the dep variable
   *    Create a vector of 1s and 0s indicating which outcomes to display
   *    Calculate max# of new variables that can be generated with genpr()
   *       [cannot exceed the # of outcomes that will be displayed]
   *    Make sure user has not listed more than that # of vars in genpr()
   tempname catdi fdcatdi
   ck_pr "`pr'" "`prval'"
   matrix `catdi' = r(catdi)
   return matrix catdi `catdi'
   local prval `r(prval)'
   return local prval `prval'
   ck_genn `r(oktogen)' genpr "`genpr'" /* name only oktogen vars in genpr*/  
   * Check fdpr, fdprval, fdgenpr options
   *    Check that #s in prval correspond with values of the dep variable
   *    Create a vector of 1s and 0s indicating which outcomes to display
   *    Calculate max# of new variables that can be generated with fdgenpr()
   *       [cannot exceed `nx' * #outcomes that will be displayed]
   *    Make sure user has not listed more than that # of vars in fdgenpr()
   ck_pr "`fdpr'" "`fdprval'"  
   matrix `fdcatdi' = r(catdi)
   return matrix fdcatdi `fdcatdi'
   local fdprval `r(prval)'
   return local fdprval `fdprval'
   ck_genn `nx'*`r(oktogen)' fd(genpr()) "`fdgenpr'"  
end    

program define CKprobit, rclass
   * see comments for CKlogit
   * output
   *   matrix r(catdi): row vector containing 1 if probability for category 
   *      i should be displayed on screen, 0 if not.  e.g. catdi=(0,0,1,0)
   *      indicates that 3rd cat should be displayed, others suppressed
   *   matrix r(fdcatdi): same, except applies to first differences
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`ev'`genev'`fdev'`fdgenev'" ~= "" {
      di in y _n "For models with binary dependent variables, simulated " /*
         */ "expected values are" _n "equivalent to simulated probabilities."/*
         */ "  Please use pr, prval(#), and/or" _n "genpr(varname) in place "/*
         */ "of ev or genev(varname)."
      exit 198
   }
   if "`tfunc'" ~= "" {    
      di in r _n "The tfunc() option does not work with the probit model."
      exit 198
   }
   if "`msims'" ~= "" {
      di in g _n "Note: msims are not necessary to compute probabilities "
      */ "for this model." _n "msims(`msims') ignored." _n
   }
   ck_genn 1 genpv "`genpv'"                  /* name only 1 var in genpv  */
   tempname catdi fdcatdi
   ck_pr "`pr'" "`prval'"
   matrix `catdi' = r(catdi)
   return matrix catdi `catdi'
   local prval `r(prval)'
   return local prval `prval'
   ck_genn `r(oktogen)' genpr "`genpr'" /* name only oktogen vars in genpr*/  
   ck_pr "`fdpr'" "`fdprval'"  
   matrix `fdcatdi' = r(catdi)
   return matrix fdcatdi `fdcatdi'
   local fdprval `r(prval)'
   return local fdprval `fdprval'
   ck_genn `nx'*`r(oktogen)' fd(genpr()) "`fdgenpr'"
end    

program define CKologit, rclass
   * see comments for CKlogit
   * output
   *   matrix r(catdi): row vector containing 1 if probability for category 
   *      i should be displayed on screen, 0 if not.  e.g. catdi=(0,0,1,0)
   *      indicates that 3rd cat should be displayed, others suppressed
   *   matrix r(fdcatdi): same, except applies to first differences
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`ev'`genev'`fdev'`fdgenev'" ~= "" {
      di in y _n "For models with ordered dependent variables, please use " /*
         */ "pr, prval(#), and/or" _n "genpr(varname) in place " /*
         */ "of ev or genev(varname)."
      exit 198
   }
   if "`tfunc'" ~= "" {    
      di in r _n "The tfunc() option does not work with the ologit model."
      exit 198
   }
   if "`msims'" ~= "" {
      di in g _n "Note: msims are not necessary to compute probabilities "
      */ "for this model." _n "msims(`msims') ignored." _n
   }
   ck_genn 1 genpv "`genpv'"
   tempname catdi fdcatdi
   ck_pr "`pr'" "`prval'"
   matrix `catdi' = r(catdi)
   return matrix catdi `catdi'
   local prval `r(prval)'
   return local prval `prval'
   ck_genn `r(oktogen)' genpr "`genpr'"  /* name only 2 vars in genev */   
   ck_pr "`fdpr'" "`fdprval'"
   matrix `fdcatdi' = r(catdi)
   return matrix fdcatdi `fdcatdi'
   local fdprval `r(prval)'
   return local fdprval `fdprval'
   ck_genn `nx'*`r(oktogen)' fd(genpr()) "`fdgenpr'"
end

program define CKoprobi, rclass
   * see comments for CKlogit
   * output
   *   matrix r(catdi): row vector containing 1 if probability for category 
   *      i should be displayed on screen, 0 if not.  e.g. catdi=(0,0,1,0)
   *      indicates that 3rd cat should be displayed, others suppressed
   *   matrix r(fdcatdi): same, except applies to first differences
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`ev'`genev'`fdev'`fdgenev'" ~= "" {
      di in y _n "For models with ordered dependent variables, please use " /*
         */ "pr, prval(#), and/or" _n "genpr(varname) in place " /*
         */ "of ev or genev(varname)."
      exit 198
   }
   if "`tfunc'" ~= "" {    
      di in r _n "The tfunc() option does not work with the oprobit model."
      exit 198
   }
   if "`msims'" ~= "" {
      di in g _n "Note: msims are not necessary to compute probabilities "
      */ "for this model." _n "msims(`msims') ignored." _n
   }
   ck_genn 1 genpv "`genpv'"
   tempname catdi fdcatdi
   ck_pr "`pr'" "`prval'"
   matrix `catdi' = r(catdi)
   return matrix catdi `catdi'
   local prval `r(prval)'
   return local prval `prval'
   ck_genn `r(oktogen)' genpr "`genpr'"  /* name only 2 vars in genev */   
   ck_pr "`fdpr'" "`fdprval'"
   matrix `fdcatdi' = r(catdi)
   return matrix fdcatdi `fdcatdi'
   local fdprval `r(prval)'
   return local fdprval `fdprval'
   ck_genn `nx'*`r(oktogen)' fd(genpr()) "`fdgenpr'"
end

program define CKmlogit, rclass
   * see comments for CKlogit
   * output
   *   matrix r(catdi): row vector containing 1 if probability for category 
   *      i should be displayed on screen, 0 if not.  e.g. catdi=(0,0,1,0)
   *      indicates that 3rd cat should be displayed, others suppressed
   *   matrix r(fdcatdi): same, except applies to first differences
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`ev'`genev'`fdev'`fdgenev'" ~= "" {
      di in y _n "For models with nominal dependent variables, please use " /*
         */ "pr, prval(#), and/or" _n "genpr(varname) in place " /*
         */ "of ev or genev(varname)."
      exit 198
   }
   if "`tfunc'" ~= "" {    
      di in r _n "The tfunc() option does not work with the mlogit model."
      exit 198
   }
   if "`msims'" ~= "" {
      di in g _n "Note: msims are not necessary to compute probabilities "
      */ "for this model." _n "msims(`msims') ignored." _n
   }
   ck_genn 1 genpv "`genpv'"
   tempname catdi fdcatdi
   ck_pr "`pr'" "`prval'"
   matrix `catdi' = r(catdi)
   return matrix catdi `catdi'
   local prval `r(prval)'
   return local prval `prval'
   ck_genn `r(oktogen)' genpr "`genpr'"  /* name only 2 vars in genev */   
   ck_pr "`fdpr'" "`fdprval'"
   matrix `fdcatdi' = r(catdi)
   return matrix fdcatdi `fdcatdi'
   local fdprval `r(prval)'
   return local fdprval `fdprval'
   ck_genn `nx'*`r(oktogen)' fd(genpr()) "`fdgenpr'"
end

program define CKpoisso, rclass
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`tfunc'" ~= "" {    
      di in r _n "The tfunc() option does not work with the poisson model."
      exit 198
   }
   if "`msims'" ~= "" {
      di in g _n "Note: msims are not necessary to compute probabilities "
      */ "for this model." _n "msims(`msims') ignored." _n
   }
   if "`pr'`fdpr'" ~= "" {
      di in r "The pr option is for models with a finite number of outcomes." _n /*
      */ "The poisson model has a potentially infinite number of outcomes." _n /*
      */ "Please use the prval() option to specify the particular outcomes" /*
      */ _n "for which you would like probabilities to be calculated."
      exit 198
   }
   if "`genpr'" ~= "" & "`prval'" == "" {
      di in r _n "For this model, you must specify prval() when using genpr()."
      exit 198
   }
   if "`fdgenpr'" ~= "" & "`fdprval'" == "" {
      di in r _n "For this model, you must specify fd(prval()) when using " /*
         */ fd(genpr())."
      exit 198
   }
   * check genpv option
   ck_genn 1 genpv "`genpv'"  
   * check prval and genpr options
   *    confirm that values in prval are nonnegative integers
   *    Make sure user has not listed too many vars in genpr()
   ck_nnint, optname(prval) intlist("`prval'")
   local n : word count `prval'
   ck_genn `n' genpr "`genpr'"   /* name max of n vars in genpr */
   * check fdprval and fdgenpr options
   *    confirm that values in fdprval are nonnegative integers
   *    Make sure user has not listed too many vars in fdgenpr()
   ck_nnint, optname(fdprval) intlist("`fdprval'")
   local n : word count `fdprval'
   ck_genn `nx'*`n' fdgenpr "`fdgenpr'"  /* name max of n vars in fdgenpr */
end

program define CKnbreg, rclass
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`tfunc'" ~= "" {    
      di in r _n "The tfunc() option does not work with the nbreg model."
      exit 198
   }
   if "`msims'" ~= "" {
      di in g _n "Note: msims are not necessary to compute probabilities "
      */ "for this model." _n "msims(`msims') ignored." _n
   }
   if "`pr'`fdpr'" ~= "" {
      di in r "The pr option is for models with a finite number of outcomes." _n /*
      */ "The poisson model has a potentially infinite number of outcomes." _n /*
      */ "Please use the prval() option to specify the particular outcomes" /*
      */ _n "for which you would like probabilities to be calculated."
      exit 198
   }
   if "`genpr'" ~= "" & "`prval'" == "" {
      di in r _n "For this model, you must specify prval() when using genpr()."
      exit 198
   }
   if "`fdgenpr'" ~= "" & "`fdprval'" == "" {
      di in r _n "For this model, you must specify fd(prval()) when using " /*
         */ fd(genpr())."
      exit 198
   }
   * check genpv option
   ck_genn 1 genpv "`genpv'"  
   * check prval and genpr options
   *    confirm that values in prval are nonnegative integers
   *    Make sure user has not listed too many vars in genpr()
   ck_nnint, optname(prval) intlist("`prval'")
   local n : word count `prval'
   ck_genn `n' genpr "`genpr'"   /* name max of n vars in genpr */
   * check fdprval and fdgenpr options
   *    confirm that values in fdprval are nonnegative integers
   *    Make sure user has not listed too many vars in fdgenpr()
   ck_nnint, optname(fdprval) intlist("`fdprval'")
   local n : word count `fdprval'
   ck_genn `nx'*`n' fdgenpr "`fdgenpr'"  /* name max of n vars in fdgenpr */
end

program define CKweibul, rclass
   version 6.0
   args genpv ev genev fdev fdgenev pr prval genpr fdpr fdprval /*
      */ fdgenpr nx msims tfunc
   if "`tfunc'" ~= "" {    
      di in r _n "The tfunc() option does not work with the weibull model."
      exit 198
   }
   if "`pr'`prval'`genpr'`fdpr'`fdprval'`fdgenpr'" ~= "" {
      di in r _n "Probabilities are not allowed with weibull."
      exit 198
   }
   if "`msims'" ~= "" {
      di in g _n "Note: msims are not necessary to compute probabilities "
      */ "for this model." _n "msims(`msims') ignored." _n
   }
   * check genpv option
   ck_genn 1 genpv "`genpv'"  
   ck_genn 1 genev "`genev'" /* name only 1 in genev */
   ck_genn `nx' fd(genev()) "`fdgenev'"   /* name only nx in fdgenev */
end



***************************** CHECKING UTILITIES ***************************

program define ck_nnint
   * checks for nonnegative integers
   version 6.0
   capture syntax [, OPTNAME(str) INTLIST(numlist integer >=0)]
   if _rc { 
      di in r _n "Numbers in `optname' option must be nonnegative integers."
      exit 198
   }
end

program define ck_pr, rclass
   * args
   *   pr, equals "pr" if Clarify should find probs for all outcomes, otw ""
   *   prval, a list of #s that should correspond to values of the depvar
   * reads
   *   e(k_cat), the # of categories in dependent variable
   *   e(cat), a vector containing the numeric values for the cats
   *   Note: e(k_cat) and e(cat) refer to cats actually used in estimation
   * output
   *   local r(oktogen): max# of vars that can be generated with genpr()
   *   matrix r(catdi): row vector containing 1 if probability for category 
   *      i should be displayed on screen, 0 if not.  e.g. catdi=(0,0,1,0)
   *      indicates that 3rd cat should be displayed, others suppressed
   version 6.0
   args pr prval
   tempname catdi allcats
   matrix `allcats' = e(cat)             /* valid categories */
   if "`pr'" == "" {                      /* pr was not specified */
      matrix `catdi' = J(1,`e(k_cat)',0)    /* cats to display */
      local vals `prval'
      while "`vals'" ~= "" {
         gettoken val vals : vals
         local found 0
         local i 1
         while `i' <= `e(k_cat)' {
            local c = `allcats'[1,`i']
            if `val' == `c' {
               local found 1
               matrix `catdi'[1,`i'] = 1
               local i = `e(k_cat)' + 1  /* exit the loop */
            }
            else { local i = `i' + 1 } /* inspect next # in allcats */
         }
         if ~`found' {
            di in r _n "Error: `val' is not a valid outcome for `e(depvar)'"
            exit 198
         }
      }
   }
   else {                                           /* pr was specified */
      if "`prval'" ~= "" {
         di in g _n "Note: You specified both the pr and the prval() options."
         di in g "pr takes precedence over prval(), so -simqi- will display"
         di in g "Pr(Y=j) for all j, rather than the values listed in prval()."
      }
      matrix `catdi' = J(1,`e(k_cat)',1)  /* display pr's for all outcomes */
      local prval  /* erase prval */
      local i 1    /* rebuild prval to contain all outcome values */
      while `i' <= `e(k_cat)' {
         local c = `allcats'[1,`i']
         local prval `prval' `c'
         local i = `i' + 1
      }
   }
   if "`prval'" == "" { return local oktogen = `e(k_cat)' }
   else { 
      local words : word count `prval'
      return local oktogen = `words'
   }
   return matrix catdi `catdi'
   return local prval `prval'
end

program define ck_genn
   * Make sure only maxnum variables are listed
   * maxnum = maximum number of variables that we allow
   * optname = name of the option
   * vtogen = list of names of variables to generate
   version 6.0
   args maxnum optname vtogen  /* option name and vars to generate */
   local ngen : word count `vtogen'
   if `ngen' > `maxnum' {
      di in r _n "Error: You listed too many variables in the " /* 
         */ "`optname' option."
      exit 198
   }
end

************************** CALCULATION UTILITIES ****************************

program define prep_XC, rclass
   * Arguments
   *    master = chosen values for all x's, even if not used in this equ
   *    i = number of the equation
   * Output
   *    xc, a matrix
   version 6.0
   args master i
   tempname xc tmp
   local rhsvars `e(rhs_`i')'              /* rhsvars for equation i */
   while "`rhsvars'" ~= "" {               /* pluck off chosen values*/
      gettoken rhsvar rhsvars : rhsvars
      matrix `tmp' = `master'["r1","`rhsvar'"]
      mat `xc' = nullmat(`xc'),`tmp'
   }
   if `e(cons_`i')' == 1 { mat `xc' = `xc',1 }      /* add constant */
   matrix colnames `xc' = `e(msn_`i')'            /* rename columns */
   return matrix xc `xc'
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

program define _expand
   version 6.0
   args msims
   capture set obs `msims'
   if _rc {
      di in r _n "Not enough memory for msims(`msims')."
      di in r "Please increase memory or reduce msims()."
      exit 198
   }
end


*! Version 1.0.0 August 3, 1998  Michael Tomz
*Random draws from Poisson
*Reference: William H. Press, et al (1992).  Numerical Recipies in C: 
*      The Art of Scientific Computing.  Cambridge U Press, pp. 206-8
program define rnd_pois
   version 5.0
   local mean `1'
   local out `2'
   if `mean' < 12 {
      tempvar g em t nostop
      qui g `g' = exp(-`mean')       
      qui g `em' = -1 if `g' ~= . 
      qui g `t' = 1 if `g' ~= .    
      qui g `nostop' = 1 if `g' ~= .
      local repeat 1
      while `repeat' > 0 {
         qui replace `em' = `em' + 1 if `nostop' == 1
         qui replace `t' = `t' * uniform() if `nostop' == 1
         qui replace `nostop' = 0 if `t' <= `g'
         qui count if `nostop' == 1
         local repeat = _result(1)
      }
   }
   else {
      tempvar sq alxm g part1 part2 y em t
      g `sq' = sqrt(2*`mean')
      g `alxm' = ln(`mean')
      g `g' = `mean'*`alxm'-lngamma(`mean'+1)
      g `part1' = 1 if `sq' ~= .
      qui g `part2' = .
      qui g `y' = .
      qui g `em' = .
      qui g `t' = .
      local rep1 1
      while `rep1' > 0 {
         qui replace `part2' = `part1'
         qui count if `part2'
         local rep2 = _result(1)
         while `rep2' > 0 {
            qui replace `y' = tan(_pi*uniform()) if `part2'==1
            qui replace `em' = `sq'*`y' + `mean' if `part2'==1
            qui replace `part2' = 0 if `em' >= 0
            qui count if `part2'
            local rep2 = _result(1)
         }
         qui replace `em' = int(`em') if `part1'==1
         qui replace `t'=.9*(1+`y'^2)*exp(`em'*`alxm'-lngamma(`em'+1)-`g') /*
            */ if `part1'==1
         qui replace `part1' = 0 if uniform() <= `t'
         qui count if `part1'
         local rep1 = _result(1)
     }
   }
   qui gen `out' = `em'
end


*! Version 1.0.0 August 3, 1998  Michael Tomz
* Random draws from Gamma
* References: For Ahrens/Dieter algorithm, see Brian D. Ripley (1987).
*               Stochastic Simulation. John Wiley & Sons, p. 88
*             For Best 1978 algorithm, see Luc Devroye (1986).  Non-Uniform
*               Random Variate Generation. NY: Springer-Verlag, p. 410
program define rnd_gam
   version 5.0
   local alpha `1'  /* shape parameter */
   local beta `2'   /* scale parameter */
   local out `3'    /* output variable */
   summarize `alpha', meanonly
   * If minimum alpha is less than 1, use Ahrens/Dieter 1974 algorithm
   if _result(5) < 1 {
      tempvar cond1 cond2 cond3 cond4 nostop u0 u1 x 
      qui g `cond1' = 1 if `alpha' ~= .
      qui g `cond2' = 1 if `alpha' ~= .
      qui g `cond3' = 1 if `alpha' ~= .
      qui g `cond4' = 1 if `alpha' ~= .
      qui g `u0' = .
      qui g `u1' = .
      qui g `x' = .
      local repeat = 1
      while `repeat' > 0 {
       **If condition 1 is true  ( if value has not been accepted )
         qui replace `u0'=uniform() if `cond1'==1
         qui replace `u1'=uniform() if `cond1'==1
         * Evaluate condition 2
         qui replace `cond2'=0 if `cond1'==1 & `u0'<=exp(1)/(`alpha'+exp(1))
       **If condition 2 is still true
         qui replace `x'=-ln((`alpha'+exp(1))*(1-`u0')/(`alpha'*exp(1))) /*
            */ if `cond1'==1 & `cond2'==1
         * Evaluate condition 4
         qui replace `cond4'=0 if `cond1'==1 & `cond2'==1 & /*
            */ `u1'<=`x'^(`alpha'-1)
         * If condition 4 is now false, done!
         qui replace `cond1'=0 if `cond1'==1 & `cond4'==0
         * But if condition 4 is still true, start again
         qui replace `cond3'=1 if `cond1'==1 & `cond4'==1  
       **If condition 2 is now false
         qui replace `x'=((`alpha'+exp(1))*`u0'/exp(1))^(1/`alpha') /*
            */ if `cond1'==1 & `cond2'==0
         * Evaluate condition 3
         qui replace `cond3'=0 if `cond1'==1 & `cond2'==0 & `u1'<=exp(-`x')
         * If condition 3 is now false, done!
         qui replace `cond1'=0 if `cond1'==1 & `cond3'==0
         * But if condition 3 is still true, start again
         qui replace `cond2'=1 if `cond1'==1 & `cond3'==1
         qui replace `cond4'=1 if `cond1'==1 & `cond3'==1
       **Are we done yet?
         qui count if `cond1' == 1
         local repeat = _result(1)
       }
   }
   * Otherwise use Best 1978 algorithm
   else {
      tempvar b c nostop u v w x y z
      qui gen `b' = `alpha' - 1
      qui gen `c' = 3 * `alpha' - .75
      qui gen `nostop' = 1 if `alpha' ~= .
      qui gen `u' = .
      qui gen `v' = .
      qui gen `w' = .
      qui gen `x' = .
      qui gen `y' = .
      qui gen `z' = .
      local repeat = 1
      while `repeat' > 0 {
         qui replace `u' = uniform() if `nostop' == 1
         qui replace `v' = uniform() if `nostop' == 1
         qui replace `w' = `u'*(1-`u') if `nostop' == 1
         qui replace `y' = sqrt(`c'/`w')*(`u'-.5) if `nostop' == 1
         qui replace `x' = `b' + `y' if `nostop' == 1
         qui replace `z' = 64*(`w'^3)*(`v'^2) if `nostop'==1 & `x'>=0
         qui replace `nostop'=0 if `nostop'==1 & `z'<=1-2*(`y'^2)/`x' & `x'>=0
         qui replace `nostop'=0 if `nostop'==1 & /*
            */ ln(`z')<=2*(`b'*ln(`x'/`b')-`y') & `x'>=0
         qui count if `nostop' == 1
         local repeat = _result(1)
      }
   }
   qui gen `out' = `x'*`beta'
end


************************** TRANSFORMATION FUNCTIONS ***********************

program define _squared
   * syntax: tsquared v1old v1new v2old v2new...
   version 6.0
   local vars `0'
   while "`vars'" ~= "" {
      gettoken old vars : vars
      gettoken new vars : vars
      qui gen `new' = `old' ^2
   }
end

program define _sqrt
   * syntax: tsqrt v1old v1new v2old v2new...
   version 6.0
   local vars `0'
   while "`vars'" ~= "" {
      gettoken old vars : vars
      gettoken new vars : vars
      qui gen `new' = sqrt(`old')
   }
end

program define _exp
   * syntax: texp v1old v1new v2old v2new...
   version 6.0
   local vars `0'
   while "`vars'" ~= "" {
      gettoken old vars : vars
      gettoken new vars : vars
      qui gen `new' = exp(`old')
   }
end

program define _ln
   * syntax: tln v1old v1new v2old v2new...
   version 6.0
   local vars `0'
   while "`vars'" ~= "" {
      gettoken old vars : vars
      gettoken new vars : vars
      qui gen `new' = ln(`old')
   }
end

program define _logiti
   * Inverse of logistic transformation
   * syntax: tlogiti v1old v1new v2old v2new... (forget about basevar)
   local vars `0'
   local n 0
   local fun 1                               /* denominator */
   while "`vars'" ~= "" {
      local n = `n' + 1
      gettoken old`n' vars : vars
      gettoken new`n' vars : vars
      local fun `fun' + exp(`old`n'')      /* build expression */
   }
   tempvar denom
   qui gen `denom' = `fun'
   local i 1
   while `i' <= `n' {  
      qui gen `new`i'' = exp(`old`i'')/`denom'
      local i = `i' + 1
   }
end


**************************** OUTPUT ROUTINES ****************************

program define List_XC
   * Lists chosen values of X
   version 6.0
   setx
   di _n(2) "Quantities of interest based on those explanatory values:"
end


program define _dihead1
   * Display header 1 (common header for output)
   * Input is level of confidence interval
   * Quantity of Interest |     Mean       Std. Err.    [95% Conf. Interval]
   * ---------------------+-------------------------------------------------
   *
   version 6.0
   args level
   di in g _n(1) "      Quantity of Interest |     Mean       Std. Err.    "/*
      */ "[`level'% Conf. Interval]" _n _dup(27) "-" "+" _dup(50) "-"
end

program define _sumdisp, rclass
   * Summarize and display simulated quantities of interest
   * Inputs: Name of variable to summarize
   *         Level for confidence interval
   *         Label for quantity of interest
   *         Printed: has display hdr been printed?
   version 6.0
   args var level label printed
   if "`printed'" == "" { _dihead1 `level' }
   qui su `var'                        /* summarize the variable */
   tempname mean sd lo hi
   scalar `mean' = r(mean)
   scalar `sd' = sqrt(r(Var))
   local plo = (100-`level')/2         /* lower bound of percentile */
   local phi = `plo' + `level'         /* upper bound of percentile */
   qui _pctile `var', p(`plo',`phi')   /* calculate percentiles     */
   scalar `lo' = r(r1)
   scalar `hi' = r(r2)
   local skip = 26 - length("`label'")
   di in g _skip(`skip') "`label' |  " in y /*
      */ _col(31) %9.0g `mean' /*
      */ _col(44) %9.0g `sd' /*
      */ _col(57) %9.0g `lo' /*
      */ _col(69) %9.0g `hi'
   return local printed printed
end

program define _genvar
   * Generates and labels a new variable
   version 6.0
   args oldvar newvar label
   qui gen `newvar' = `oldvar'
   label var `newvar' "`label'"
end

program define _newgens
   version 6.0
   args newvars
   di in y _n "Simqi generated the following new variable(s): `newvars'"
end

program define _colcat, rclass
   * returns the column number for the column that contains `val'
   version 6.0
   args val
   tempname ecat
   mat `ecat' = e(cat)
   local i 1
   while `i' <= `e(k_cat)' {
      if `ecat'[1,`i'] == `val' {
         return local colnum `i'
         exit
      }
      local i = `i' + 1
   }
   di "Error: `val' is not a valid outcome for `e(depvar)'"  /* fix */
   exit 198
end


************** (MUST MODIFY FOR NEW MODEL - ADD A QOI PROGRAM) **************
*********************** MODEL-SPECIFIC QOI: SUREG ***************************

program define QIsureg
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc               /* this name will be resused k_eq times */
   local i 1
   while `i' <= `e(k_eq)' {
      prep_XC `xfsetx' `i'   /* pass x's that have been set & equ number */ 
      matrix `xc' = r(xc)    /* vector of chosen values for X's in equ i */
      * assign names to temporary variables
      *    xb_`i' is XB from ith equation
      *    y_`i' is predicted value of Y for ith equation
      *    ty_`i' is *transformed* predicted value of Y for ith equation
      *    ev_`i' is the expected value of Y for the ith equation
      *    pv_`i' is the predicted value of Y for the ith equation
      *    e_`i' is the epsilon (disturbance) for equation i
      *    c`i' is used to draw from multivariate normal
      tempvar xb_`i' y_`i' ty_`i' ev_`i' pv_`i' e_`i' c`i'
      qui matrix score `xb_`i'' = `xc'        /* calculate XB for ith equ */
      local oldnew `oldnew' `y_`i'' `ty_`i''  /* build list for transform */
      local oldnew2 `oldnew2' `pv_`i'' `ty_`i''
      local enames `enames' `e_`i''            /* build list of epsilons   */
      local cnames `cnames' `c`i''            /* build list for MVN       */
      qui gen `ev_`i'' = .                    /* initialize expected valu */
      qui gen `pv_`i'' = .                    /* initialize predicted val */
      * build labels
      local depvar : word `i' of `e(depvar)'
      if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }
      if "`tfunc'" == "" { local elab_`i' (`depvar') }
      else { local elab_`i' [`tfunc'(`depvar')] }
      local i = `i' + 1
   }
   local doev `ev' `genev' `fdev' `fdgenev'
   local dopv `pv' `genpv'
   local newvars `genpv' `genev'
   local printed                 /* initialize "header printed" to blank */
   * USE SHORTCUT FOR EXPECTED VALUES IF POSSIBLE
   if "`doev'" ~= "" & "`tfunc'" == "" {
      * Case 1: no evnames, so we are not dealing with a first difference
      * We will print and save the results
      if "`evnames'" == "" {   
         local i 1
         while `i' <= `e(k_eq)' {
            if "`ev'" ~= "" {
               _sumdisp `xb_`i'' `level' "E`elab_`i''" "`printed'"
               local printed `r(printed)'
            }
            if "`genev'" ~= "" {
               gettoken newvar genev : genev
               _genvar `xb_`i'' `newvar' "E`elab_`i''"
            }
            local i = `i' + 1
         }
      }
      * Case 2: evnames exist, so we are dealing with a first difference
      * We will not print the results.  Instead, the temporary variables
      * listed in evname will remain in memory to be used by main program.  
      else {
         local i 1
         while `i' <= `e(k_eq)' {
            gettoken evname evnames : evnames
            qui gen `evname' = `xb_`i''
            local i = `i' + 1
         }
      }
      if "`dopv'" == "" { 
         if "`newvars'" ~= "" { _newgens "`newvars'" }
         exit                 /* done with ev's.  If no pvs, exit */
      }  
      else { local doev }     /* otw reset doev to signal no more evs */
   }

   * DO EVERYTHING ELSE THE LONG WAY!
   * STEP 1: SET VALUE FOR MSIMS
   * If user wants an expected value, we set msims=1000 or accept the 
   * the value that the user supplied.  If user only wants predicted
   * values (no expected values), we set msims to 1
   if "`doev'" ~= "" {
      if "`msims'" == "" { local msims 1000 }  
      if `msims' > _N { _expand `msims' }
   }
   else { local msims 1 }
   * STEP 2: RESORT THE DATA (we will restore it later)
   tempvar oldsort
   qui gen `oldsort' = _n
   local sortvar `e(msn_1)'
   gettoken sortvar : sortvar
   sort `sortvar'                   /* sort on b1 */
   * STEP 3: CYCLE THROUGH EACH ROW OF SIMULATED PARAMS (s=1 to e(sims))
   * WITH EACH ITERATION, REBUILD SIGMA MATRIX, DRAW DISTURBANCES,
   * AND CALCULATE PREDICTED VALUES.  WE CAN OBTAIN EXPECTED VALUES FROM
   * THE PREDICTED VALUES.
   tempname Sigmat A
   matrix `Sigmat' = J(`e(k_eq)',`e(k_eq)',0)
   di in y _n "Performing calculations.  Please wait..."
   local s 1                        /* for each row of the b's  */
   while `s' <= `e(sims)' {
      local sofar = 10*`s'/`e(sims)'
      if int(`sofar') == `sofar' { di `sofar'*10 "% "_c }
      local sigs `e(asn)'    /* elements of sigma, eg. b7,b8,b9 */
      * REBUILD SIGMAT AND DRAW DISTURBANCES FROM N(0,SIGMAT)
      * RESULT IS `e_`i'', disturbances for ith equation
      local i 1                /* i indexes the row of the matrx*/
      while `i' <= `e(k_eq)' {
         * rebuild sigma matrix
         local j 1             /* j indexes the col of the matrx*/
         while `j' < `i' {
            gettoken sig sigs : sigs
            matrix `Sigmat'[`i',`j'] = `sig'[`s']
            matrix `Sigmat'[`j',`i'] = `sig'[`s']
            local j = `j' + 1
         }
         gettoken sig sigs : sigs
         matrix `Sigmat'[`i',`i'] = `sig'[`s']           
         * draw from standard normal distribution, collect names
         qui gen `c`i'' = invnorm(uniform()) in 1/`e(sims)'
         local i = `i' + 1
      }
      _chol `Sigmat' `e(k_eq)' `A'               /* Cholesky decomp     */
      matrix colnames `A' = `cnames'             /* rename cols to ci...*/
      local i 1
      while `i' <= `e(k_eq)' {
         tempname row`i'
         matrix `row`i'' = `A'[`i',1...]         /* get i^th row of A   */
         matrix score `e_`i'' = `row`i''   /* epsilons for ith equation */
         local i = `i' + 1
      }
      qui drop `cnames'

      * CALCULATE 1 PREDICTED VALUE
      if "`dopv'" ~= "" {
         local i 1
         while `i' <= `e(k_eq)' {
            * generate one value of y and insert into sth position
            qui replace `pv_`i'' = `xb_`i''[`s'] + `e_`i''[1] in `s'
            local i = `i' + 1
         }
      }

      * CALCULATE 1 EXPECTED VALUE AS FUNCTION OF MSIMS PREDICTED VALUES
      if "`doev'" ~= "" { 
         local i 1
         while `i' <= `e(k_eq)' {
            * generate, say, 10000 values of y, which we will average
            qui gen `y_`i'' = `xb_`i''[`s'] + `e_`i'' 
            local i = `i' + 1
         }
         _`tfunc' `oldnew'                    /* must transform y's    */
         local i 1                                 /* mean of transfmd */
         while `i' <= `e(k_eq)' {
            su `ty_`i'', meanonly
            qui replace `ev_`i'' = r(mean) in `s'
            local i = `i' + 1
         }
         qui drop `oldnew'             /* drop y_i and ty_i */
      }

      drop `enames'           /* drop the epsilons */
      local s = `s' + 1
   }
   di _n

   * DISPLAY PREDICTED VALUES
   local printed               /* re-initialize "header printed" to blank */
   if "`dopv'" ~= "" {
      if "`tfunc'" ~= "" {
         _`tfunc' `oldnew2'                    /* transform vars   */
         local i 1                                     /* mean of transfmd */
         while `i' <= `e(k_eq)' {
            if "`pv'" ~= "" {
               _sumdisp `ty_`i'' `level' "Pred`elab_`i''" "`printed'"
               local printed `r(printed)'
            }
            if "`genpv'" ~= "" {
               gettoken newvar genpv : genpv
               _genvar `ty_`i'' `newvar' "Pred`elab_`i''"
            }
            local i = `i' + 1
         }
      }
      else {
         local i 1
         while `i' <= `e(k_eq)' {
            if "`pv'" ~= "" {
               _sumdisp `pv_`i'' `level' "Pred`elab_`i''" "`printed'"
               local printed `r(printed)'
            }
            if "`genpv'" ~= "" {
               gettoken newvar genpv : genpv
               _genvar `pv_`i'' `newvar' "Pred`elab_`i''"
            }
            local i = `i' + 1
         }
      }
   }

   * DISPLAY EXPECTED VALUES (if not a first difference)
   if "`doev'" ~= "" {
      * Case 1: no evnames, so we are not dealing with a first difference
      * We will print and save the results
      if "`evnames'" == "" {   
         local i 1
         while `i' <= `e(k_eq)' {
            if "`ev'" ~= "" {
               _sumdisp `ev_`i'' `level' "E`elab_`i''" "`printed'"
               local printed `r(printed)'
            }
            if "`genev'" ~= "" {
               gettoken newvar genev : genev
               _genvar `ev_`i'' `newvar' "E`elab_`i''"
            }
            local i = `i' + 1
         }
      }
      * Case 2: evnames exist, so we are dealing with a first difference
      * We will not print the results.  Instead, the temporary variables
      * listed in evname will remain in memory to be used by main program.  
      else {
         local i 1
         while `i' <= `e(k_eq)' {
            gettoken evname evnames : evnames
            qui gen `evname' = `ev_`i''
            local i = `i' + 1
         }
      }
  }

  if "`newvars'" ~= "" { _newgens "`newvars'" }
  qui sort `oldsort'  /* revert to the original sort order */

end


************************* MODEL-SPECIFIC QOI: REGRESS **********************

program define QIregres
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc               /* this name will be resused k_eq times */
   prep_XC `xfsetx' 1        /* pass x's that have been set & equ number */ 
   matrix `xc' = r(xc)       /* vector of chosen values for X's */
   tempvar xb y ty ey
   qui gen `ey' = .            /* initialize ey */
   qui matrix score `xb' = `xc'  /* calculate XB */
   local sig2 `e(asn)'           /* name of variable with simulated sig^2 */
   tempvar sig
   qui gen `sig' = sqrt(`sig2')

   * build labels
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }
   if "`tfunc'" == "" { local elab (`depvar') }
   else { local elab [`tfunc'(`depvar')] }

   * this is ok
   local doev `ev' `genev' `fdev' `fdgenev'
   local dopv `pv' `genpv'
   local newvars `genpv' `genev'
   local printed                 /* initialize "header printed" to blank */

   * CALCULATE AND DISPLAY/SAVE PREDICTED VALUES
   if "`dopv'" ~= "" {
      qui gen `y' = `xb' + `sig'*invnorm(uniform()) 
      if "`tfunc'" ~= "" {
         _`tfunc' `y' `ty'                  /* transform vars   */
         if "`pv'" ~= "" {
            _sumdisp `ty' `level' "Pred`elab'" "`printed'"
            local printed `r(printed)'
         }
         if "`genpv'" ~= "" { _genvar `ty' `genpv' "Pred`elab'" }
         qui drop `ty'
      }
      else {
         if "`pv'" ~= "" {
            _sumdisp `y' `level' "Pred`elab'" "`printed'"
            local printed `r(printed)'
         }
         if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred`elab'" }
      }
      qui drop `y'
      if "`doev'" == "" {
         if "`newvars'" ~= "" { _newgens "`newvars'" }
         exit                 /* done with pv's.  If no evs, EXIT */
      }
   }

   * USE SHORTCUT FOR EXPECTED VALUES IF POSSIBLE
   if "`doev'" ~= "" & "`tfunc'" == "" {
      * Case 1: no evnames, so we are not dealing with a first difference
      * We will print and save the results
      if "`evnames'" == "" {   
         if "`ev'" ~= "" {
            _sumdisp `xb' `level' "E`elab'" "`printed'"
            local printed `r(printed)'
         }
         if "`genev'" ~= "" { _genvar `xb' `genev' "E`elab'" }
      }
      * Case 2: evnames exist, so we are dealing with a first difference
      * We will not print the results.  Instead, the temporary variables
      * listed in evname will remain in memory to be used by main program.  
      else { qui gen `evnames' = `xb' }
      if "`newvars'" ~= "" { _newgens "`newvars'" }
      exit                 /* done with ev's.  If no pvs, EXIT */
   }

   * DO EXPECTED VALUES THE LONG WAY, IF WE DIDN'T USE SHORTCUT ABOVE
   tempvar oldsort
   qui gen `oldsort' = _n
   local sortvar `e(msn_1)'
   gettoken sortvar : sortvar
   sort `sortvar'                   /* sort on b1 */
   if "`msims'" == "" { local msims 1000 }  
   if `msims' > _N { _expand `msims' }
   local i 1
   while `i' <= `e(sims)' {
      qui gen `y' = `xb'[`i']+`sig'[`i']*invnorm(uniform()) in 1/`msims'
      _`tfunc' `y' `ty'                       /* must transform y */
      su `ty', meanonly
      qui replace `ey' = `r(mean)' in `i'
      qui drop `y' `ty'
      local i = `i' + 1
   }
   * DISPLAY EXPECTED VALUES (if not a first difference)
   * Case 1: no evnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`evnames'" == "" {   
      if "`ev'" ~= "" {
         _sumdisp `ey' `level' "E`elab'" "`printed'"
         local printed `r(printed)'
      }
      if "`genev'" ~= "" { _genvar `ey' `genev' "E`elab'" }
   }
   * Case 2: evnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in evname will remain in memory to be used by main program.  
   else { qui gen `evnames' = `ey' }
   if "`newvars'" ~= "" { _newgens "`newvars'" }
   qui sort `oldsort'  /* revert to the original sort order */

end


************************* MODEL-SPECIFIC QOI: LOGIT **********************

program define QIlogit
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc               /* this name will be resused k_eq times */
   prep_XC `xfsetx' 1        /* pass x's that have been set & equ number */ 
   matrix `xc' = r(xc)       /* vector of chosen values for X's */
   tempvar xb p0 p1 y
   qui matrix score `xb' = `xc'  /* calculate XB */

   * CALCULATE PROBABILITIES AND PREDICTED VALUES
   qui gen `p1' = 1 /(1+exp(-`xb'))
   qui gen `p0' = 1 - `p1'
   local printed       /* initialized printed to blank */
   local newvars `genpr' `genpv'

   * OUTPUT - PROBABILITIES
   * Case 1: no prnames, so we are not dealing with a first difference
   * We will print and save the results
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }
   if "`prnames'" == "" {
      * Display probabilties on the screen, in order listed in prval
      local vals `prval'
      while "`vals'" ~= "" {
         gettoken val vals : vals
         local label : label (`e(depvar)') `val' 8
         _sumdisp `p`val'' `level' "Pr(`depvar'=`label')" "`printed'"
         local printed `r(printed)'
      }
      * Generate variables in genpr()
      *    if prval(1) genpr(joe) ---> joe refers to y=1
      *    if prval(0) genpr(joe) ---> joe refers to y=0
      *    if prval(0 1) genpr(joe) ---> joe refers to y=0
      *    if prval(0 1) genpr(joe1 joe2) ---> joe1 refers to y=0
      *    if genpr(joe1 joe2) --> joe1 revers to y= 0 
      *    if genpr(joe) -> joe refers to y=0  - User beware!
      local vals `prval'
      if "`vals'" == "" { local vals 0 1 }
      while "`genpr'" ~= "" {       
         gettoken val vals : vals
         local label : label (`e(depvar)') `val' 8
         gettoken var genpr : genpr
         _genvar `p`val'' `var' "Pr(`depvar'=`label')" 
      }
   }
   * Case 2: prnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in prnames will remain in memory to be used by main program.  
   else {
      local vals `fdprval'
      while "`prnames'" ~= "" {
         gettoken prname prnames : prnames
         gettoken val vals : vals
         qui gen `prname' = `p`val''
      }
   }
      
   * OUTPUT - PREDICTED VALUES
   local dopv `pv' `genpv'
   if "`dopv'" ~= "" {
      qui gen `y'= cond(uniform()<`p1',1,0) if `p1' ~= .
      local label : value label `e(depvar)'
      label values `y' `label'
      label var `y' "Pred(`depvar')"
      if "`pv'" ~= "" { tabulate `y' }
      if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred(`depvar')" }
   }

   if "`newvars'" ~= "" { _newgens "`newvars'" }

end

*********************** MODEL-SPECIFIC QOI: PROBIT ************************

program define QIprobit
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc               /* this name will be resused k_eq times */
   prep_XC `xfsetx' 1        /* pass x's that have been set & equ number */ 
   matrix `xc' = r(xc)       /* vector of chosen values for X's */
   tempvar xb p0 p1 y
   qui matrix score `xb' = `xc'  /* calculate XB */

   * CALCULATE PROBABILITIES AND PREDICTED VALUES
   qui gen `p1' = normprob(`xb')
   qui gen `p0' = 1 - `p1'
   local printed       /* initialized printed to blank */
   local newvars `genpr' `genpv'

   * OUTPUT - PROBABILITIES
   * Case 1: no prnames, so we are not dealing with a first difference
   * We will print and save the results
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }
   if "`prnames'" == "" {
      * Display probabilties on the screen, in order listed in prval
      local vals `prval'
      while "`vals'" ~= "" {
         gettoken val vals : vals
         local label : label (`e(depvar)') `val' 8
         _sumdisp `p`val'' `level' "Pr(`depvar'=`label')" "`printed'"
         local printed `r(printed)'
      }
      * Generate variables in genpr()
      *    if prval(1) genpr(joe) ---> joe refers to y=1
      *    if prval(0) genpr(joe) ---> joe refers to y=0
      *    if prval(0 1) genpr(joe) ---> joe refers to y=0
      *    if prval(0 1) genpr(joe1 joe2) ---> joe1 refers to y=0
      *    if genpr(joe1 joe2) --> joe1 revers to y= 0 
      *    if genpr(joe) -> joe refers to y=0  - User beware!
      local vals `prval'
      if "`vals'" == "" { local vals 0 1 }  /* fix */
      while "`genpr'" ~= "" {       
         gettoken val vals : vals
         local label : label (`e(depvar)') `val' 8
         gettoken var genpr : genpr
         _genvar `p`val'' `var' "Pr(`depvar'=`label')" 
      }
   }
   * Case 2: prnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in prnames will remain in memory to be used by main program.  
   else {
      local vals `fdprval'
      if "`vals'" == "" {
         local words : word count `prnames'
         if `words' == 2 { local vals 0 1 }     /* default order */
         else if `words' == 1 { local vals 1 }  /* special case */
      }
      while "`prnames'" ~= "" {
         gettoken prname prnames : prnames
         gettoken val vals : vals
         qui gen `prname' = `p`val''
      }
   }
      
   * OUTPUT - PREDICTED VALUES
   local dopv `pv' `genpv'
   if "`dopv'" ~= "" {
      qui gen `y'= cond(uniform()<`p1',1,0) if `p1' ~= .
      local label : value label `e(depvar)'
      label values `y' `label'
      label var `y' "Pred(`depvar')"
      if "`pv'" ~= "" { tabulate `y' }
      if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred(`depvar')" }
   }

   if "`newvars'" ~= "" { _newgens "`newvars'" }

end


*********************** MODEL-SPECIFIC QOI: OLOGIT ************************

program define QIologit
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc               /* this name will be resused k_eq times */
   prep_XC `xfsetx' 1        /* pass x's that have been set & equ number */ 
   matrix `xc' = r(xc)       /* vector of chosen values for X's */
   tempvar xb y p1 p`e(k_cat)'
   qui matrix score `xb' = `xc'  /* calculate XB */

   * CALCULATE PROBABILITIES
   local cutpts `e(asn)'
   gettoken cutlo cutpts : cutpts
   qui gen `p1' = 1/(1 + exp(`xb' - `cutlo'))
   local i 2
   while `i' < `e(k_cat)' {
      tempvar p`i'
      gettoken cuthi cutpts : cutpts
      qui gen `p`i'' = 1/(1+exp(`xb'-`cuthi')) - 1/(1+exp(`xb'-`cutlo'))
      local cutlo `cuthi'
      local i = `i' + 1
   }
   qui gen `p`e(k_cat)'' = 1 - 1/(1 + exp(`xb' - `cutlo'))

   * PREPARE FOR OUTPUT
   local printed       /* initialized printed to blank */
   local newvars `genpr' `genpv'
   tempname ecat
   mat `ecat' = e(cat)
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }


   * OUTPUT - PROBABILITIES
   * Case 1: no prnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`prnames'" == "" {
      local vals `prval' 
      while "`vals'" ~= "" {
         * Display probabilties on the screen, in order listed in prval 
         gettoken val vals : vals
         _colcat `val'
         local colnum `r(colnum)'
         local colnums `colnums' `colnum'
         local label : label (`e(depvar)') `val' 8
         _sumdisp `p`colnum'' `level' "Pr(`depvar'=`label')" "`printed'"
         local printed `r(printed)'
      }
      if "`genpr'" ~= "" { local colnum 0 }
      while "`genpr'" ~= "" {
         if "`colnums'" ~= "" { gettoken colnum colnums : colnums }
         else { local colnum = `colnum' + 1 }
         gettoken var genpr : genpr
         local val = `ecat'[1,`colnum']
         local label : label (`e(depvar)') `val' 8
         _genvar `p`colnum'' `var' "Pr(`depvar'=`label')"
      }
   }
   * Case 2: prnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in prnames will remain in memory to be used by main program.  
   else {
      if "`fdprval'" ~= "" {
         local vals `fdprval'
         while "`prnames'" ~= "" {
            gettoken prname prnames : prnames
            gettoken val vals : vals
            _colcat `val'
            local colnum `r(colnum)'
            qui gen `prname' = `p`colnum''
         }
      }
      else {
         local colnum 0
         while "`prnames'" ~= "" {
            gettoken prname prnames : prnames
            local colnum = `colnum' + 1
            qui gen `prname' = `p`colnum''
         }
      }
   }
     
   * OUTPUT - PREDICTED VALUES
   local dopv `pv' `genpv'
   if "`dopv'" ~= "" {
      tempvar u done prsum y
      qui gen `y' = .
      qui gen `u' = uniform() if `p1' ~= .
      qui gen `done' = 0 if `p1' ~= .
      qui gen `prsum' = 0
      local i 1
      while `i' <= `e(k_cat)' {       
         qui replace `prsum' = `prsum' + `p`i''
         qui replace `y' = `ecat'[1,`i'] if `u' <= `prsum' & `done' == 0
         qui replace `done' = 1 if `u' <= `prsum' & `done' == 0
         local i = `i' + 1
      }
      local label : value label `e(depvar)'
      label values `y' `label'
      label var `y' "Pred(`depvar')"
      if "`pv'" ~= "" { tabulate `y' }
      if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred(`depvar')" }
   }
   if "`newvars'" ~= "" { _newgens "`newvars'" }

end


*********************** MODEL-SPECIFIC QOI: OPROBIT ************************

program define QIoprobi
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc               /* this name will be resused k_eq times */
   prep_XC `xfsetx' 1        /* pass x's that have been set & equ number */ 
   matrix `xc' = r(xc)       /* vector of chosen values for X's */
   tempvar xb y p1 p`e(k_cat)'
   qui matrix score `xb' = `xc'  /* calculate XB */

   * CALCULATE PROBABILITIES
   local cutpts `e(asn)'
   gettoken cutlo cutpts : cutpts
   qui gen `p1' = normprob(`cutlo' - `xb')
   local i 2
   while `i' < `e(k_cat)' {
      tempvar p`i'
      gettoken cuthi cutpts : cutpts
      qui gen `p`i'' = normprob(`cuthi' - `xb') - normprob(`cutlo' - `xb')
      local cutlo `cuthi'
      local i = `i' + 1
   }
   qui gen `p`e(k_cat)'' = normprob(`xb' - `cutlo')

   * PREPARE FOR OUTPUT
   local printed       /* initialized printed to blank */
   local newvars `genpr' `genpv'
   tempname ecat
   mat `ecat' = e(cat)
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }

   * OUTPUT - PROBABILITIES
   * Case 1: no prnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`prnames'" == "" {
      local vals `prval' 
      while "`vals'" ~= "" {
         * Display probabilties on the screen, in order listed in prval 
         gettoken val vals : vals
         _colcat `val'
         local colnum `r(colnum)'
         local colnums `colnums' `colnum'
         local label : label (`e(depvar)') `val' 8
         _sumdisp `p`colnum'' `level' "Pr(`depvar'=`label')" "`printed'"
         local printed `r(printed)'
      }
      if "`genpr'" ~= "" { local colnum 0 }
      while "`genpr'" ~= "" {
         if "`colnums'" ~= "" { gettoken colnum colnums : colnums }
         else { local colnum = `colnum' + 1 }
         gettoken var genpr : genpr
         local val = `ecat'[1,`colnum']
         local label : label (`e(depvar)') `val' 8
         _genvar `p`colnum'' `var' "Pr(`depvar'=`label')"
      }
   }
   * Case 2: prnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in prnames will remain in memory to be used by main program.  
   else {
      if "`fdprval'" ~= "" {
         local vals `fdprval'
         while "`prnames'" ~= "" {
            gettoken prname prnames : prnames
            gettoken val vals : vals
            _colcat `val'
            local colnum `r(colnum)'
            qui gen `prname' = `p`colnum''
         }
      }
      else {
         local colnum 0
         while "`prnames'" ~= "" {
            gettoken prname prnames : prnames
            local colnum = `colnum' + 1
            qui gen `prname' = `p`colnum''
         }
      }
   }
     
   * OUTPUT - PREDICTED VALUES
   local dopv `pv' `genpv'
   if "`dopv'" ~= "" {
      tempvar u done prsum y
      qui gen `y' = .
      qui gen `u' = uniform() if `p1' ~= .
      qui gen `done' = 0 if `p1' ~= .
      qui gen `prsum' = 0
      local i 1
      while `i' <= `e(k_cat)' {       
         qui replace `prsum' = `prsum' + `p`i''
         qui replace `y' = `ecat'[1,`i'] if `u' <= `prsum' & `done' == 0
         qui replace `done' = 1 if `u' <= `prsum' & `done' == 0
         local i = `i' + 1
      }
      local label : value label `e(depvar)'
      label values `y' `label'
      label var `y' "Pred(`depvar')"
      if "`pv'" ~= "" { tabulate `y' }
      if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred(`depvar')" }
   }
   if "`newvars'" ~= "" { _newgens "`newvars'" }

end

*********************** MODEL-SPECIFIC QOI: MLOGIT ************************


program define QImlogit
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc               /* this name will be resused k_eq times */
   tempvar sum xb_`e(k_cat)' 
   qui gen `sum' = 0
   local i 1                 /* loop through each of e(k_eq) equations */
   while `i' <= `e(k_eq)' {  /*    note that e(k_eq) = e(k_cat) - 1    */
      prep_XC `xfsetx' `i'   /* pass x's that have been set & equ number */ 
      matrix `xc' = r(xc)    /* vector of chosen values for X's in equ i */
      tempvar xb_`i'
      qui matrix score `xb_`i'' = `xc'       /* calculate XB for ith equ */
      qui replace (`xb_`i'') = exp(`xb_`i'') /* take exp of XB for ith   */
      qui replace `sum' = `sum' + `xb_`i''
      local xblist `xblist' `xb_`i''
      local i = `i' + 1
   }
   qui gen `xb_`e(k_cat)'' = 1
   qui replace `sum' = `sum' + `xb_`e(k_cat)''

   * CALCULATE PROBABILITIES
   local i 1                   /* loop through all categories */
   while `i' <= `e(k_cat)' {
      tempvar p`i'
      if `i' == `e(ibasecat)' { local expxb `xb_`e(k_cat)'' }
      else { gettoken expxb xblist : xblist }
      qui gen `p`i'' = `expxb' / `sum'
      local i = `i' + 1
   }
         
   * PREPARE FOR OUTPUT
   local printed       /* initialized printed to blank */
   local newvars `genpr' `genpv'
   tempname ecat
   mat `ecat' = e(cat)
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }

   * OUTPUT - PROBABILITIES
   * Case 1: no prnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`prnames'" == "" {
      local vals `prval' 
      while "`vals'" ~= "" {
         * Display probabilties on the screen, in order listed in prval 
         gettoken val vals : vals
         _colcat `val'
         local colnum `r(colnum)'
         local colnums `colnums' `colnum'
         local label : label (`e(depvar)') `val' 8
         _sumdisp `p`colnum'' `level' "Pr(`depvar'=`label')" "`printed'"
         local printed `r(printed)'
      }
      if "`genpr'" ~= "" { local colnum 0 }
      while "`genpr'" ~= "" {
         if "`colnums'" ~= "" { gettoken colnum colnums : colnums }
         else { local colnum = `colnum' + 1 }
         gettoken var genpr : genpr
         local val = `ecat'[1,`colnum']
         local label : label (`e(depvar)') `val' 8
         _genvar `p`colnum'' `var' "Pr(`depvar'=`label')"
      }
   }
   * Case 2: prnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in prnames will remain in memory to be used by main program.  
   else {
      if "`fdprval'" ~= "" {
         local vals `fdprval'
         while "`prnames'" ~= "" {
            gettoken prname prnames : prnames
            gettoken val vals : vals
            _colcat `val'
            local colnum `r(colnum)'
            qui gen `prname' = `p`colnum''
         }
      }
      else {
         local colnum 0
         while "`prnames'" ~= "" {
            gettoken prname prnames : prnames
            local colnum = `colnum' + 1
            qui gen `prname' = `p`colnum''
         }
      }
   }

   * OUTPUT - PREDICTED VALUES
   local dopv `pv' `genpv'
   if "`dopv'" ~= "" {
      tempvar u done prsum y
      qui gen `y' = .
      qui gen `u' = uniform() if `p1' ~= .
      qui gen `done' = 0 if `p1' ~= .
      qui gen `prsum' = 0
      local i 1
      while `i' <= `e(k_cat)' {       
         qui replace `prsum' = `prsum' + `p`i''
         qui replace `y' = `ecat'[1,`i'] if `u' <= `prsum' & `done' == 0
         qui replace `done' = 1 if `u' <= `prsum' & `done' == 0
         local i = `i' + 1
      }
      local label : value label `e(depvar)'
      label values `y' `label'
      label var `y' "Pred(`depvar')"
      if "`pv'" ~= "" { tabulate `y' }
      if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred(`depvar')" }
   }
   if "`newvars'" ~= "" { _newgens "`newvars'" }

end


************************ MODEL-SPECIFIC QOI: POISSON **********************

program define QIpoisso
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc tmp offset    /* this name will be resused k_eq times */
   prep_XC `xfsetx' 1        /* pass x's that have been set & equ number */ 
   matrix `xc' = r(xc)       /* vector of chosen values for X's */
   tempvar xb ey p y 
   qui matrix score `xb' = `xc'  /* calculate XB */
   if "`e(offset)'" ~= "" { 
      tokenize "`e(offset)'", parse("()")           /*  to end of the list */
      if "`1'"=="ln" {
         local offvar `3'
         matrix `tmp' = `xfsetx'["r1","`offvar'"]
         scalar `offset' = ln(`tmp'[1,1])
      }
      else { 
         local offvar `1'
         matrix `tmp' = `xfsetx'["r1","`offvar'"]
         scalar `offset' = `tmp'[1,1]
      }
      qui replace `xb' = `xb' + `offset'
   }

   * PREPARE FOR OUTPUT
   local printed               /* initialized printed to blank */
   local newvars `genev' `genpr' `genpv'
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }

   * CALCULATE AND REPORT EXPECTED VALUE
   qui gen `ey' = exp(`xb')   /* expected value of Y */
   * Case 1: no evnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`evnames'" == "" {   
      if "`ev'" ~= "" {
         _sumdisp `ey' `level' "E(`depvar')" "`printed'"
         local printed `r(printed)'
      }
      if "`genev'" ~= "" { _genvar `ey' `genev' "E(`depvar')" }
   }
   * Case 2: evnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in evname will remain in memory to be used by main program.  
   else { qui gen `evnames' = `ey' }

   * CALCULATE AND REPORT PROBABILITIES
   * Case 1: no prnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`prnames'" == "" {
      local vals `prval'
      while "`vals'" ~= "" {
         * Display probabilties on the screen, in order listed in prval 
         gettoken val vals : vals
         local label : label (`e(depvar)') `val' 8
         qui gen `p' = exp( -`ey' + `val'*ln(`ey') - lnfact(`val') )
         _sumdisp `p' `level' "Pr(`depvar'=`label')" "`printed'"
         local printed `r(printed)'
         if "`genpr'" ~= "" {
            gettoken var genpr : genpr
            _genvar `p' `var' "Pr(`depvar'=`label')"
         }
         drop `p' /* clean up */
      }
   }
   * Case 2: prnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in prnames will remain in memory to be used by main program.  
   else {
      local vals `fdprval'
      while "`prnames'" ~= "" {
         gettoken prname prnames : prnames
         gettoken val vals : vals
         qui gen `prname' = exp( -`ey' + `val'*ln(`ey') - lnfact(`val') )
      }
   }

   * CALCULATE AND REPORT PREDICTED VALUES
   if "`pv'`genpv'" ~= "" {
      rnd_pois `ey' `y'
      if "`pv'" ~= "" {
         _sumdisp `y' `level' "Pred(`depvar')" "`printed'"
         local printed `r(printed)'
      }
      if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred(`depvar')" }
   }

   if "`newvars'" ~= "" { _newgens "`newvars'" }

end


*********************** MODEL-SPECIFIC QOI: NBREG **********************

program define QInbreg
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc tmp offset    /* this name will be resused k_eq times */
   prep_XC `xfsetx' 1        /* pass x's that have been set & equ number */ 
   matrix `xc' = r(xc)       /* vector of chosen values for X's */
   tempvar xb ey p
   qui matrix score `xb' = `xc'  /* calculate XB */
   if "`e(offset)'" ~= "" { 
      tokenize "`e(offset)'", parse("()")           /*  to end of the list */
      if "`1'"=="ln" {
         local offvar `3'
         matrix `tmp' = `xfsetx'["r1","`offvar'"]
         scalar `offset' = ln(`tmp'[1,1])
      }
      else { 
         local offvar `1'
         matrix `tmp' = `xfsetx'["r1","`offvar'"]
         scalar `offset' = `tmp'[1,1]
      }
      qui replace `xb' = `xb' + `offset'
   }

   * PREPARE FOR OUTPUT
   local printed               /* initialized printed to blank */
   local newvars `genev' `genpr' `genpv'
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }

   * CALCULATE AND REPORT EXPECTED VALUE
   * VERIFY THAT WE CAN USE THIS SHORTCUT!  /* FIX */
   qui gen `ey' = exp(`xb')   /* expected value of Y */
   * Case 1: no evnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`evnames'" == "" {   
      if "`ev'" ~= "" {
         _sumdisp `ey' `level' "E(`depvar')" "`printed'"
         local printed `r(printed)'
      }
      if "`genev'" ~= "" { _genvar `ey' `genev' "E(`depvar')" }
   }
   * Case 2: evnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in evname will remain in memory to be used by main program.  
   else { qui gen `evnames' = `ey' }

   * GET ALPHA, CALCULTE INVERSE
   tempvar a ai
   local lnalpha `e(asn)'
   qui gen `a' = exp(`lnalpha')             /* alpha                */
   qui gen `ai' = 1 / `a'                  /* alpha inverse        */

   * CALCULATE AND REPORT PROBABILITIES
   * Case 1: no prnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`prnames'" == "" {
      local vals `prval'
      while "`vals'" ~= "" {
         * Display probabilties on the screen, in order listed in prval 
         gettoken val vals : vals
         local label : label (`e(depvar)') `val' 8
         qui gen `p' = exp( lngamma(`val'+`ai') - lnfact(`val') - /*
            */ lngamma(`ai') + `ai'*ln(`ai'/(`ai'+`ey')) +        /*
            */ `val'*ln(`ey'/(`ai'+`ey')) )
         _sumdisp `p' `level' "Pr(`depvar'=`label')" "`printed'"
         local printed `r(printed)'
         if "`genpr'" ~= "" {
            gettoken var genpr : genpr
            _genvar `p' `var' "Pr(`depvar'=`label')"
         }
         drop `p' /* clean up */
      }
   }
   * Case 2: prnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in prnames will remain in memory to be used by main program.  
   else {
      local vals `fdprval'
      while "`prnames'" ~= "" {
         gettoken prname prnames : prnames
         gettoken val vals : vals
         qui gen `prname' = exp( -`ey' + `val'*ln(`ey') - lnfact(`val') )
      }
   }

   * CALCULATE AND REPORT PREDICTED VALUES
   if "`pv'`genpv'" ~= "" {
      tempvar expu u mu y
      rnd_gam `ai' `a' `expu'              /* draws from gamma     */
      qui gen `u' = ln(`expu')            /* ln(expu)=u=disturbance*/
      qui gen `mu' = exp(`xb' + `u')
      rnd_pois `mu' `y'                    /* draws from poisson   */
      if "`pv'" ~= "" {
         _sumdisp `y' `level' "Pred(`depvar')" "`printed'"
         local printed `r(printed)'
      }
      if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred(`depvar')" }
   }

   if "`newvars'" ~= "" { _newgens "`newvars'" }

end


******************** MODEL-SPECIFIC QOI: WEIBULL **********************

program define QIweibul
   version 6.0
   syntax [, PV GENPV(str) EV GENEV(str) PR PRVAL(str) GENPR(str) /*
      */ CATDI(str) FDEV FDGENEV(str) FDPR FDPRVAL(str) FDGENPR(str) /*
      */ FDCATDI(str) Level(real $S_level) LISTX MSIMS(str) TFUNC(str) /*
      */ XFSETX(str) EVNAMES(str) PRNAMES(str)]
   * CALCULATE XB'S, 
   tempname xc               /* this name will be resused k_eq times */
   prep_XC `xfsetx' 1        /* pass x's that have been set & equ number */ 
   matrix `xc' = r(xc)       /* vector of chosen values for X's */
   tempvar xb p lambda ey y
   qui matrix score `xb' = `xc'  /* calculate XB */
   qui gen `p' = exp(`e(asn)')   /* anc param -- Note: stata saves ln(p) */
   if "`e(frm2)'" == "hazard" { qui gen `lambda' = exp(`xb') }
   else { qui gen `lambda' = exp(-`xb'*`p') }

   * PREPARE FOR OUTPUT
   local printed               /* initialized printed to blank */
   local newvars `genev' `genpr' `genpv'
   local depvar `e(depvar)'
   if `e(versn)' > 6 { local depvar = abbrev("`depvar'",8) }

   * CALCULATE AND REPORT EXPECTED VALUE
   qui gen `ey' = (`lambda')^(-1/`p') * exp(lngamma(1+1/`p'))
   * Case 1: no evnames, so we are not dealing with a first difference
   * We will print and save the results
   if "`evnames'" == "" {   
      if "`ev'" ~= "" {
         _sumdisp `ey' `level' "E(`depvar')" "`printed'"
         local printed `r(printed)'
      }
      if "`genev'" ~= "" { _genvar `ey' `genev' "E(`depvar')" }
   }
   * Case 2: evnames exist, so we are dealing with a first difference
   * We will not print the results.  Instead, the temporary variables
   * listed in evname will remain in memory to be used by main program.  
   else { qui gen `evnames' = `ey' }

   * CALCULATE AND REPORT PREDICTED VALUES
   if "`pv'`genpv'" ~= "" {
      qui gen `y' = [ln(1-uniform())/-`lambda']^(1/`p')
      if "`pv'" ~= "" {
         _sumdisp `y' `level' "Pred(`depvar')" "`printed'"
         local printed `r(printed)'
      }
      if "`genpv'" ~= "" { _genvar `y' `genpv' "Pred(`depvar')" }
   }

   if "`newvars'" ~= "" { _newgens "`newvars'" }

end

