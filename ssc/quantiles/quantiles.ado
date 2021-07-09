*! version 1.1 jun_2006
*! STABLE option added
*! International Poverty Centre/UNDP
*! Written by Rafael Guerreiro Osorio

capture program drop quantiles

program quantiles, sortpreserve byable(onecall)
   
   version 8.0
   
   syntax varlist(max=1 numeric) [fweight aweight iweight] [if] [in], GENcatvar(name) ///
      [Nquant(integer 10) Keeptog(varname) Stable]
   
   confirm new variable `gencatvar'
   
   if `nquant' < 2 {
      di ""
      di as error "ERROR: invalid Nquant(); number of quantiles should be at least 2"
   	exit
   }

   if _by() { 
      local byopt "by `_byvars'"
      local colon ":"
   }
   
   tempvar pop cumpop peso touse
   
   mark `touse' `if' `in'
   markout `touse' `varlist'
   
   if "`weight'" == "" {
      gen `peso' = 1
   }
   else {
      gen `peso' `exp'
   }
   
   sort `_byvars' `touse' `varlist' `keeptog', `stable'
   capture `byopt'`colon' egen `pop' = sum(`peso') if `touse'  
   capture `byopt'`colon' gen `cumpop' = sum(`peso') if `touse'
   
   gen `gencatvar' = int(`cumpop'/((`pop'+1)/`nquant')) + 1 if `touse'
   
   if "`keeptog'" != "" {
      capture replace `gencatvar' = `gencatvar'[_n-1] if ///
         (`gencatvar' != `gencatvar'[_n-1] & `keeptog' == `keeptog'[_n-1]) & `touse'
   } 
			
   label variable `gencatvar' "`nquant' quantiles of `varlist' `byopt'`if'"

end 
