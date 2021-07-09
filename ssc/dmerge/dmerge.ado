*! dmerge.ado  version 1.0.2 fw 9/9/03: wrapper for merge 
*! Sorts and automatically drops _merge; uses -ukeep- instead of -keep-
*! Detects if using data set is not sorted and sorts if required
*! Supresses Stata's label messages.
*! v 1.0.2 adds Table and Loudly; corrects ukeep bug
program define dmerge
   version 8.0
   syntax varlist using/ [, ukeep(string) UNIQue UNIQMaster UNIQUsing ///
   noLabel update replace noKeep  _merge(name) Table Loudly]   
   capture drop _merge
   sort `varlist'
   local msortedby : sortedby
   qui des `varlist' using `using', varlist
   if "`msortedby'" != "`r(sortlist)'" {
      di in yellow "  Using data set not sorted. Now sorting ...."
      preserve
      use `using', clear
      sort `varlist'
      tempfile usefile
      qui save `usefile'
      local using `usefile'
      restore
   }
   if "`loudly'" == "loudly" {
      merge `varlist' using `using' ,  ///
      keep("`ukeep'") `unique' `uniqmaster' `uniqusing' ///
      `label' `update' `replace' `keep'  _merge("`_merge'")
   }
   else{
      qui merge `varlist' using `using' , ///
      keep("`ukeep'") `unique' `uniqmaster' `uniqusing' ///
      `label' `update' `replace' `keep'  _merge("`_merge'")
   }
   if "`table'" == "table" tab _merge
   
end

