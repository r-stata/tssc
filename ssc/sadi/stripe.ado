capture program drop stripe
program define stripe
version 10
   syntax varlist (min=1) , GENerate(string) [ SYMbols(string) XT XTSPellsep(string) XTDursep(string)]
   if "`symbols'"=="" {
      local symbols "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      }
   local length 0
   foreach var in `varlist' {
      local length = `length' + 1
      }
      
   qui gen str`length' `generate' = ""
   if ("`xt'"=="") {
   di "Creating long string representation"
   foreach a in `varlist' {
     qui replace `generate' = `generate' + substr("`symbols'",`a',1) if !missing(`a') & `a'>0
     qui replace `generate' = `generate' + "." if missing(`a') | `a'<=0
     }
   }
   else {
   di "Creating condensed string representation"
   local sx: word 1 of `varlist'
     qui {
       replace `generate' = substr("`symbols'",`sx',1)
       tempvar dur
       gen `dur'  = 1
       forvalues x = 2/`length' {
         local sx: word `x' of `varlist'
         local sm: word `=`x'-1' of `varlist'
         replace `dur' = `dur' + 1 if `sx'==`sm'
         replace `generate' = `generate' + "`xtdursep'" + string(`dur') + "`xtspellsep'" + substr("`symbols'",`sx',1) if `sx'!=`sm'
         replace `dur' = 1 if `sx'!=`sm'
       }
       replace `generate' = `generate' + "`xtdursep'" + string(`dur')
     }
  }
end
   
   
