*! version 1.1 October 1, 1999  
*  (C) Copyright 1999 Michael Tomz, Jason Wittenberg, and Gary King
*  Current version available at http://gking.harvard.edu
*
* SETXHL: Lists or changes the value of row vectors mrt_xcH and mrt_xcL
* Option:  [ keepmrt, a programmer's option : do not change mrt globals ]
* Reads:   e(cmd), a system macro containing name of last command
*          e(p), which gives bounds on the proportion of 1's in the population
*          e(depvar), a system macro containing name(s) of dep var
*          e(rhsvars), a system macro containing list of rhs variables
*          e(if), a system macro containing if clause from last command
*          e(in), a system macro containing in clause from last command
*          e(wt), a system macro containing weight clause from last command
*          e(wexp), a system macro containing weight expression from last cmd
*          e(milist), a system macro with list of multiply imputed datasets
*          mrt_xcL, a row vector of chosen values for x, conditional on pLO
*          mrt_xcH, a row vector of chosen values for x, conditional on pHI
*          mrt_vt, a global containing value-types for mrt_xc
* Output:  Displays values of mrt_xcH, mrt_xcL, and mrt_vt in tabular format
*          Changes the values of 
*             mrt_xcL, a row vector of chosen values for x, conditional on pLO
*             mrt_xcH, a row vector of chosen values for x, conditional on pHI
*             mrt_vt, a global containing value-types for values in mrt_xc
*             mrt_seto, a global containing the if-in-wt options used
*          OR
*             returns the matrices r(mrt_xcH) and r(mrt_xcL) while keeping the
*             globals intact
* NEW:     Allows grouping, e.g. -setx (x1 x2 x3) mean (x4 x5) p20-
*          Allows spaces in math if surrounded by (), eg ( sqrt( 3 ) )
*          Supports multiple imputation
* FUTURE:  Allow calcs based on other variables, e.g. -setx x1 ln(mean(x2))-
program define setxHL, rclass
version 6.0

   * HAS USER RUN ESTSIMP PRIOR TO SETX?
   tokenize `"`e(cmd)'"'
   if "`1'" ~= "estsimp"  & "`1'" ~= "relogit" {
      di in r _n "Must run -estsimp- or -relogit- before -setx-"
      exit 198
   }

   * STRIP SETLIST (DESIRED VALUES) FROM COMMAND LINE
   local more 1
   while `more' {
      gettoken token 0 : 0, parse("[,= ") match(paren)
      if `"`token'"' == "[" {             
         tokenize `"`0'"', parse("= ")
         if "`2'" == "=" { local more 0 }     
         else {
            local setlist `setlist'`token'`1'
            mac shift
            local 0 `"`*'"'
         }
      }
      else {
         if `"`token'"' == "" { local more 0 }
         else if `"`token'"' == "if" { local more 0 }
         else if `"`token'"' == "in" { local more 0 }
         else if `"`token'"' == "," { local more 0 }
         if `more' {
            if "`paren'"=="(" { local setlist `setlist' (`token') }
            else { local setlist `setlist' `token' }
         }
      }
   }
   local 0 `"`token' `0'"'

   * PARSE REMAINDER OF COMMAND LINE
   syntax [if] [in] [aw fw pw iw] [, NOINHer NOCWdel KEEPMRT NOBound]
   if "`weight'" == "pweight" | "`weight'" == "iweight" {
      #delimit ;
      di in w _n "-setx- does not allow `weight's.  If you have probability"
      "-weighted or" _n "importance-weighted data, use -svymean- or a "
      "related estimation command to " _n "infer the mean and other "
      "characteristics of the population.  Save or record " _n
      "your estimates, rerun -estsimp-, and then set the explanatory "
      "variables" _n "by typing:" _n(2)
      in y _skip(15) "setx varname1 myest1 varname2 myest2 ..." _n(2)
      in w "where myest1 is the saved/recorded characteristic of varname1" _n;
      #delimit cr
      exit 101
   }

   * CHECK MATRICES MRT_XCL AND MRT_XCH, GLOBAL MRT_VT
   capture mat drop mrt_xc			    /* drop single xc mat  */
   local nrhsvar : word count `e(rhsvars)'          /* # of rhs vars       */
   capture mat list mrt_xcL                         /* does xcL mat exist? */
   local rc = _rc
   capture mat list mrt_xcH			    /* does xcH mat exist? */
   local rc = `rc' + _rc
   if `rc' == 0 {                                   /* if xc does exist... */
      capture di "$mrt_vt"                          /* do valu types exist?*/
      if _rc { mat drop mrt_xcL mrt_xcH }           /* if not, drop matrix */
      else {
         local xccolsL : colnames(mrt_xcL)          /* names of vars in xcL*/
         local xccolsH : colnames(mrt_xcH)          /* names of vars in xcH*/
         local vt $mrt_vt                           /* a copy of mrt_vt    */
         local nvaltyp 0                            /* count the # of value*/
         while "`vt'" ~= "" {                       /*   types in mrt_vt   */
            gettoken token vt : vt, match(paren)
            local nvaltyp = `nvaltyp' + 1
         }
         if "`xccolsL'"=="`e(rhsvars)'"             /* if names match ivars
            */ & "`xccolsH'"=="`e(rhsvars)'"        /*
            */ & `nrhsvar' == `nvaltyp'             /* and # of types match              
            */ { local xcfound yes }                /* then xc matrix is OK*/
         else { mat drop mrt_xcL mrt_xcH }          /* otw drop xc matrices*/
      }
   }
   else { capture mat drop mrt_xcH mrt_xcL }
   tokenize `e(p)'
   local pLO `1'
   local pHI `2'

   * SETLIST EMPTY: LIST CURRENT VALUES FOR MRT_XC
   if "`setlist'" == "" {
      if "`xcfound'" == "yes" {
         tempvar xcnames xcvalsL xcvalsH xctypes
         qui gen str1 `xcnames' = ""
         qui gen str1 `xctypes' = ""
         local vt $mrt_vt
         local i 1
         while `i' <= `nrhsvar' {
            local nmtoget : word `i' of `e(rhsvars)'    /* variable name */
            qui replace `xcnames' = "`nmtoget'" in `i'
            gettoken vttoget vt : vt, match(paren)      /* value type    */
            qui replace `xctypes' = "`vttoget'" in `i'
            if mrt_xcL[1,`i'] ~= mrt_xcH[1,`i'] { local notsame notsame }
            local i = `i' + 1
         }
         tempname xcprime
         matrix `xcprime' = mrt_xcL'
         qui gen `xcvalsL' = matrix(`xcprime'[_n,1])         
         matrix `xcprime' = mrt_xcH'
         qui gen `xcvalsH' = matrix(`xcprime'[_n,1])         
         label var `xcnames' "Variable"
         label var `xctypes' "Description"
         di _n "You have set the following values for the explanatory " _c
         di "variables:"
         if "`notsame'" == "notsame" {         /* xc's are not the same */
            label var `xcvalsL' "Value|p=`pLO'"
            label var `xcvalsH' "Value|p=`pHI'"
            tabdisp `xcnames' if `xcnames' ~= "", /* 
               */ cell(`xcvalsL' `xcvalsH' `xctypes') /*
               */ format(%9.0g) center
         }
         else {                               /* xc's are identical */
            label var `xcvalsL' "Value"
            tabdisp `xcnames' if `xcnames' ~= "", /* 
               */ cell(`xcvalsL' `xctypes') format(%9.0g) center
         }
         gettoken token : 0
         if `"`token'"' ~= "" {
            di in r _n "Note: " in w `"`0'"' in r " invalid, so ignored."
         }
      }
      else { di _n "No values have been set for the explanatory variables." }
      exit
   }


   * SETLIST FULL: EXPAND THE LIST
   * ---> Case 1: Setlist is an observation number
   tokenize "`setlist'", parse("[] ")
   if "`1'" == "[" {
      if "`3'" == "]" {
         if "`4'" ~= "" {
            mac shift 3
            di in r _n "`*' invalid.  Proper syntax is " _c
            di in y "setx [#] " in r ", where # is an observation number."
            exit 198
         }
         local obsno = `2'
         if int(`obsno') ~= `obsno' | `obsno' < 1 | `obsno' > _N {
            di in r _n "`2' is not a valid observation number"
            exit 198
         }
         local setlist  /* everything OK, so clear setlist */
         local i 1
         while `i' <= `nrhsvar' {
            local var`i' : word `i' of `e(rhsvars)'    /* variable */
            local fun`i' `var`i''[`obsno']          /* function */
            local col`i' `i'                        /* column   */
            local mrt_vt `mrt_vt' [`obsno']
            local i = `i' + 1
         }
         local nchange = `nrhsvar'                   /* # changes */
         local makevt 0               /* vlaue types already built */
      }
      else {
         di in r _n "`1'`2'`3' invalid.  Proper syntax is " _c
         di in y "setx [#] " in r ", where # is an observation number."
         exit 198
      }
   }
   else {
      gettoken fun rest : setlist, match(paren)
      * ---> Case 2: Setlist is a single function
      if "`rest'" == "" {
         _ckfun "`fun'"                             /* is functn OK? */
         local i 1
         while `i' <= `nrhsvar' {
            local var`i' : word `i' of `e(rhsvars)'    /* variable */
            local fun`i' `fun'
            local col`i' `i'
            if "`paren'" == "" { local mrt_vt `mrt_vt' `fun' }
            else { local mrt_vt `mrt_vt' (`fun') }
            local i = `i' + 1
         }
         local nchange = `nrhsvar'
         local makevt 0               /* vlaue types already built */
      }
      * ---> Case 3: Setlist contains variables & functions
      else {
         local c 1                                         /* counter     */
         while "`setlist'" ~= "" {
            gettoken vars setlist : setlist, match(paren)  /* variable(s) */
            tsunab vars : `vars'                           /* ck, unabrev */
            gettoken fun setlist : setlist, match(paren)   /* function    */
            _ckfun "`fun'"                                 /* verify funcn*/
            while "`vars'" ~= "" {
               gettoken var`c' vars : vars                 /* get varname */
               local col`c' 0                              /* get col #   */
               local i 1                                      
               while `i' <= `nrhsvar' {      
                  local nmtoget : word `i' of `e(rhsvars)'       
                  if "`nmtoget'" == "`var`c''" {              
                     local col`c' `i'                         
                     local i = `nrhsvar'                      
                  }
                  local i = `i' + 1
               }
               if `col`c'' == 0 {
                  di in w _n "`var`c''" in r " was not an explanatory " _c
                  di in r "variable in the last estimated model."
                  exit 198
               }
               local fun`c' `fun'
               if "`paren'" == "" {local vt`c' `fun'}     /* value type */
               else { local vt`c' (`fun') }
               local c = `c' + 1
            }
         }
         local nchange = `c' - 1       /* number of changes  */
         local makevt 1               /* build val types later */
      }
   }

   * CONSTRUCT SAMPLE DEFINITIONS
   tempvar pvarLO pvarHI
   qui gen `pvarLO' = `pLO'
   qui replace `pvarLO' = (1-`pLO') if `e(depvar)'==0
   qui gen `pvarHI' = `pHI'
   qui replace `pvarHI' = (1-`pHI') if `e(depvar)'==0
   if "`exp'" ~= "" {
      local wtLO [aw`exp'*`pvarLO']               /* use expression, but  */
      local wtHI [aw`exp'*`pvarHI']               /* apply aweights only  */
   }
   else if "`noinher'"=="" & "`e(wexp)'"~="" {    /* inherit old conditions*/
      local wtLO [aw`e(wexp)'*`pvarLO']           /* but adjust for pLO */
      local wtHI [aw`e(wexp)'*`pvarHI']      	  /* and adjust for pHI */
   }
   else {					  /* nothing to inherit, */
      local wtLO [aw=`pvarLO']			  /* and no wts specified*/
      local wtHI [aw=`pvarHI']
   }
   if "`noinher'" == "" {                         /* inherit old conditions*/
      if "`if'" == "" { local if `e(if)' }        /* inherit if */
      if "`in'" == "" { local in `e(in)' }        /* inherit in */
   }

   * CREATE TEMPORARY VECTOR(s) TO HOLD VALUES
   tempname xctmpL xctmpH
   if "`xcfound'"=="yes" {                       /* copy xc matrix    */
       mat `xctmpL' = mrt_xcL
       mat `xctmpH' = mrt_xcH
   }                      
   else {                                         
      mat `xctmpL' = J(1,`nrhsvar',0)              /* create xcL matrix  */
      mat `xctmpH' = J(1,`nrhsvar',0)              /* create xcH matrix  */
      mat colnames `xctmpL' = `e(rhsvars)'           /* label columns     */
      mat colnames `xctmpH' = `e(rhsvars)'           /* label columns     */
   }

   * GET ALL STATISTICS
   local nfiles : word count `e(milist)'
   if `nfiles' == 0 {                        /* no multiple imputation */
      tempvar touse
      mark `touse' `if' `in' `wt'                    /* mark sample    */
      if "`nocwdel'" == "" { markout `touse' `e(rhsvars)' `e(depvar)' }
      tempname newval
      local c 1
      while `c' <= `nchange' {
         _getstat `var`c'' "`fun`c''" `newval' "if `touse' `wtLO'"
         matrix `xctmpL'[1,`col`c''] = `newval'        
         _getstat `var`c'' "`fun`c''" `newval' "if `touse' `wtHI'"
         matrix `xctmpH'[1,`col`c''] = `newval'        
         local c = `c' + 1
      }
   }
   else {
      preserve
      tempname newval xcsumL xcsumH
      mat `xcsum' = J(1,`nrhsvar',0)              /* create xc matrix  */
      local m 1
      while `m' <= `nfiles' {
         local file : word `m' of `e(milist)'
         use `file', clear
         tempvar touse
         mark `touse' `if' `in' `wt'                    /* mark sample    */
         if "`nocwdel'" == "" { markout `touse' `e(rhsvars)' `e(depvar)' }
         local c 1
         while `c' <= `nchange' {
            _getstat `var`c'' "`fun`c''" `newval' "if `touse' `wtLO'"
            matrix `xctmpL'[1,`col`c''] = `newval'
            _getstat `var`c'' "`fun`c''" `newval' "if `touse' `wtHI'"
            matrix `xctmpH'[1,`col`c''] = `newval'
            local c = `c' + 1
         }
         matrix `xcsumL' = `xcsumL' + `xctmpL'     /* running total */
         matrix `xcsumH' = `xcsumH' + `xctmpH'     /* running total */
         local m = `m' + 1
      }
      matrix `xctmpL' = `xcsumL' / `nfiles'         /* average value */
      matrix `xctmpH' = `xcsumH' / `nfiles'         /* average value */
   }

   * COLLECT VALUE DESCRIPTIONS
   if `makevt' {
      tempvar xctypes
      qui gen str7 `xctypes' = "default" in 1/`nrhsvar'
      * fill-in original values
      if "`xcfound'" == "yes" {
         local i 1                                  
         local vt $mrt_vt
         while "`vt'" ~= "" {                       
            gettoken token vt : vt, match(paren)
            if "`paren'" == "" { qui replace `xctypes' = "`token'" in `i' }
            else { qui replace `xctypes' = "(`token')" in `i' }
            local i = `i' + 1
         }
      }
      * substitute any changes
      local c 1
      while `c' <= `nchange' {
         qui replace `xctypes' = "`vt`c''" in `col`c''
         local c = `c' + 1
      }
      * save results in macro
      local i = 1
      while `i' <= `nrhsvar' {
         local vttoget = `xctypes'[`i']
         local mrt_vt `mrt_vt' `vttoget'
         local i = `i' + 1
      }
   }

   if "`nobound'" ~= "" {                       /* take avg of bounds   */
      matrix `xctmpL' = .5*(`xctmpL'+`xctmpH')  /* assign avg to xctmpL */
      matrix `xctmpH' = `xctmpL'                /* and copy to xctmpH,  */
   }						/* so they are identical*/
   if "`keepmrt'" == "" {
      matrix mrt_xcL = `xctmpL'
      matrix mrt_xcH = `xctmpH'
      global mrt_vt `mrt_vt'
      global mrt_seto `if' `in' `wt', `nocwdel'
   }
   else { 
      return matrix mrt_xcL `xctmpL'
      return matrix mrt_xcH `xctmpH'
   }

end

********************************* _ckfun ***********************************

*! version 1.3  April 26, 1999  Michael Tomz
program define _ckfun
   * Checks for valid function
   version 6.0
   args fun                                           /* function   */
   if "`fun'" == "" {
      di in r "You did not enter a function"
      exit 198
   }
   local funok 0
   if "`fun'" == "mean" { local funok 1 }             /* mean       */
   else if "`fun'" == "median" { local funok 1 }      /* median     */
   else if "`fun'" == "min" { local funok 1 }         /* minimum    */
   else if "`fun'" == "minimum" { local funok 1 }     /* minimum    */
   else if "`fun'" == "max" { local funok 1 }         /* maximum    */
   else if "`fun'" == "maximum" { local funok 1 }     /* maximum    */
   else if substr("`fun'",1,1)=="p" & index("`fun'","[")==0 {  /*percentile*/
      local ptile = substr("`fun'",2,.)
      capture confirm number `ptile'
      if _rc == 7 {
         di in r _n "`fun' invalid.  Proper syntax is " _c
         di in y "p# " in r ", where # must be a number between 0 and 100."
         exit 198
      }
      if `ptile' <= 0 | `ptile' >= 100 {
         di in r _n "`ptile' is an invalid percentile."
         di in r "Percentiles must be between 0 and 100."
         exit 198
      }
      local funok 1
   }
   else {                                                 /* # or macro     */
      capture local newval = `fun'                      /* is it a #      */
      if _rc == 0 {                                       /* make sure it's */
         capture tsunab fun : `fun'                      /*   not the 1st  */
         if _rc == 0 {                                    /*   observation  */
            di in r _n "`fun' invalid."                 /*   of a variable*/
            exit 198
         }
         local funok 1
      }
   }
   if `funok' == 0 {
      di in r _n "`fun' is not a valid function"
      exit 198
   }
end

******************************** _getstat **********************************

*! version 1.3  April 26, 1999  Michael Tomz
program define _getstat
   * gets a statistic  <------
   args var fun newval optns  /* optns = "if `touse' `wt'" */
   capture tsunab var : `var'
   if _rc { ErrGONE `var' }
   if "`fun'" == "mean" {
      su `var' `optns', meanonly
      scalar `newval' = r(mean)
   }
   else if "`fun'" == "median" {
      capture _pctile `var' `optns', p(50)
      scalar `newval' = r(r1)
   }
   else if "`fun'"=="min"|"`fun'"=="minimum" {
      su `var' `optns', meanonly
      scalar `newval' = r(min)
   }
   else if "`fun'"=="max"|"`fun'"=="maximum" {
      su `var' `optns', meanonly
      scalar `newval' = r(max)
   }
   else if substr("`fun'",1,1) == "p" & index("`fun'","[") == 0 {
      local ptile = substr("`fun'",2,.)
      _pctile `var' `optns', p(`ptile')
      scalar `newval' = r(r1)
   }
   else { scalar `newval' = `fun' }
   if `newval' == . { ErrMISS `fun' `var' }
end

**************************** error messages *******************************

*! version 1.3  April 26, 1999  Michael Tomz
program define ErrMISS
   version 6.0
   args fun var
   di in r _n "Not enough observations to calculate the `fun' of `var'"
   di in r "No changes were made."
   exit 2000
end

*! version 1.3  April 26, 1999  Michael Tomz
program define ErrGONE
   version 6.0
   args var
   di in r _n "Variable `var' not found.  No changes were made."
   exit 111
end
