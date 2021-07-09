*! qsim.ado fw v 1.1.1 simple clarify 4/19/03
*! syntax, [ Command(string asis) setx2(string asis) by(varname)]
*! Put command in quotes"
*! qsim, c("reg euroutil age sex white ra i.edcat") setx2(age 55 sex 1) by(edcat)
*! qsim, c("reg euroutil age sex white ra i.edcat") setx2(age 55) 
*! v 1.1.0 adds support for version 7 and 8 v1.1.1 corrects `by' error
program define qsim
   version 7.0
   forvalues i = 0 (1) 30 {
      capture drop b`i'
   }
   syntax, [ Command(string asis) setx2(string asis) by(varname)]
   local command `command'
   xi: estsimp `command'
   di"`command'"
   if "`by'" != "" {
      if _caller() < 8 {
         qui levels7 `by'
      }
      else {
         qui levels `by'
      }
      di"The levels of `by' are `r(levels)'"
   
      local icount = 0
      foreach num of numlist `r(levels)' {
         local icount = `icount' + 1
         if `icount' >1 {
            loc n1 `n1'  _I`by'_`num' 0
            local baseline `n1'
         }
      }   
      setx mean
      setx "`setx2' `baseline'"
      di "setx `setx2' `baseline'"
      simqi
      qui levels `by'
      local icount = 0
      foreach num of numlist `r(levels)' {
         local icount = `icount' + 1
         if `icount' >1 {
            setx `baseline'
            loc n1  _I`by'_`num' 1 
            setx "`setx2' `n1'"
                  di "setx `setx2' `n1'"
            simqi    
          }
      }   
   di
   }
   else {
      setx mean
      setx `setx2'
      di "setx `setx2'"
      simqi
   }
end


