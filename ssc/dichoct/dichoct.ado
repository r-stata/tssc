*! version 1.0.0  Dirk Enzmann  28nov2020

version 9.2

program define dichoct, rclass sortpreserve byable(onecall) 
   syntax varname [if] [in], [Centile(real 50) Label(str) Format(str)] Generate(str)
   confirm new var `generate'
   if "`label'" != "" {
   	  cap label list `label'
   	  if !_rc {
   	  	di as err "label {bf:`label'} already defined" 
   	    error 110
   	  }
   }
   if "`label'" != "" & "`_byvars'" != "" {
   	  di as err "label option not allowed with by:"
   	  error 198
   }
   if "`format'" == "" local format = "%6.0g"
   marksample touse
   tempvar d1 d2 newv grcons gr testvar
   tempname ct
   return local varname = "`varlist'"
   return scalar centile = `centile'
   if "`_byvars'"=="" {
   	  return local by = " "
      qui gen int `grcons' = 1
      local _byvars = "`grcons'"
   }
   else return local by = "`_byvars'"
   qui {
      egen `gr' = group(`_byvars'), missing
      replace `gr' = . if !`touse'
      levelsof `gr', local(K)
      gen `d1' = .
      gen `d2' = .
      gen `newv' = .
      gen `generate' = .
      gen `testvar' = float(`varlist')
      local kn = 0
      foreach k of local K {
      	 local ++kn
         centile `testvar' if `touse' & `gr'==`k', centile(`centile')
         scalar `ct' = float(r(c_1))
         replace `d1' = (`testvar' >= scalar(`ct')) if `touse' & `gr'==`k'
         replace `d2' = (`testvar' >  scalar(`ct')) if `touse' & `gr'==`k'
         sum `d1' if `touse' & `gr'==`k', meanonly
         if r(min)==r(max) local d1_ct = 1
         else local d1_ct = abs((1-`centile'/100)-r(mean))
         sum `d2' if `touse' & `gr'==`k', meanonly
         if r(min)==r(max) local d2_ct = 1
         else local d2_ct = abs((1-`centile'/100)-r(mean))
         replace `newv' = cond((`d1_ct' < `d2_ct'), ///
                               (`testvar' >= scalar(`ct')), ///
                               (`testvar' >  scalar(`ct')))
         replace `newv' = . if !`touse'
         replace `generate' = `newv' if `touse' & `gr'==`k'
         return scalar k`kn' = `k'
         return scalar ct`kn' = scalar(`ct')
         return local ie`kn' = cond(`d1_ct' < `d2_ct',">=",">")
      }
      lab var `generate' "`varlist' split at centile `centile'"
      if "`label'" != "" {
         local nk : word count `K'
         if `nk'==1 {
         	  local cnt : di `format' scalar(`ct')
            if `d1_ct' < `d2_ct' {
               lab def `label' 0 "`varlist'  < `cnt'" 1 "`varlist' >= `cnt'"
            }
            else {
               lab def `label' 0 "`varlist' <= `cnt'" 1 "`varlist'  > `cnt'"
            }
            lab val `generate' `label'
         }
      }
   }
end   
