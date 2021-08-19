*! version 2.1 January 5, 2003
* (C) Copyright 1998-2003 Michael Tomz, Jason Wittenberg, Gary King
* This file is part of the program Clarify.  All Rights Reserved.
* Description: Applies multivariate logistic transformation to list of vars
* Syntax:      tlogit v1old v1new v2old v2new..., basevar(varname) [percent]
* Future:      Allow if-in?
program define tlogit
   version 6.0
   gettoken vars 0 : 0, parse(",")         
   syntax , BASE(string) [Percent]
   tsunab base : `base', max(1)          /* check for presence of basevar */
   if "`percent'" == "" { local p 1 }    /* original vars are proportions */
   else { local p 100 }                  /* original vars are percentages */
   local n 0
   local sumall `base'                   /* begin building sum expression */
   while "`vars'" ~= "" {
      local n = `n' + 1
      gettoken old`n' vars : vars
      summarize `old`n'', meanonly
      if r(min) < 0*`p' | r(max) > 1*`p' {
         di in r "Values in `old`n'' are invalid.  All " /*
            */ "values must be between " 0*`p' " and " 1*`p'
         exit 198
      }
      gettoken new`n' vars : vars
      confirm new variable `new`n''
      local fun`n' ln(`old`n''/`base')
      local sumall `sumall' + `old`n''     /* build expression */
   }
   tempvar sum
   qui gen `sum' = `sumall' 
   summarize `sum', meanonly
   if r(min) <= .99*`p' | r(max) >= 1.01*`p' {
      di in r "Variable list is invalid."  /*
         */ "  Values must sum to " 1*`p' "."
      exit 198
   }
   local i 1
   while `i' <= `n' {
      qui gen `new`i'' = `fun`i'' if `sum' ~= .
      label var `new`i'' "`fun`i''"
      local i = `i' + 1
   }
end
