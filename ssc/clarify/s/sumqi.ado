*! version 2.1 January 5, 2003
* (C) Copyright 1998-2003 Michael Tomz, Jason Wittenberg, Gary King
* This file is part of the program Clarify.  All Rights Reserved.
program define sumqi
   version 6.0
   capture version 7
   if _rc == 0 { local versn 7 }               /* supports version 7 */
   else { local versn 6 }                      /* only suppts vers 6 */
   syntax varlist(min=1 ts) [if] [in] [, Level(integer $S_level) ]
   di in g _n(2) "  Variable |     Mean       Std. Dev.    " /*
      */ "[`level'% Conf. Interval]" _n _dup(11) "-" "+" _dup(50) "-"
   tempname mean sd plo phi lo hi
   while "`varlist'" ~= "" {
      gettoken var varlist : varlist
      qui su `var' `if' `in', detail
      scalar `mean' = r(mean)
      scalar `sd' = sqrt(r(Var))
      local plo = (100-`level')/2     /* lower bound of percentile */
      local phi = `plo' + `level'
      qui _pctile `var' `if' `in', p(`plo',`phi')
      scalar `lo' = r(r1)
      scalar `hi' = r(r2)
      if `versn' > 6 { local var = abbrev("`var'",8) }
      local skip = 10 - length("`var'")
      di in g _skip(`skip') "`var' |  " in y /*
      */ _col(15) %9.0g `mean' /*
      */ _col(28) %9.0g `sd' /*
      */ _col(41) %9.0g `lo' /*
      */ _col(53) %9.0g `hi'
      local i = `i' + 1
   }
end
