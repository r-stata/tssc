   // Jun 23 2012 13:35:18
   // Cumulate duration in each state across the sequence

   // cumuldir VARLIST, options CDstub(string) NSTates(int)
   // Varlist describes the sequence, CDSTUB is the stub of the cumulative duration variables
   // which will be created, NSTATES is the number of states
   //
   // Example:
   //   . cumuldur m1-m40, cd(dur) nstates(3)
   // This creates dur1 to dur3
   
program cumuldur
   syntax varlist (min=2), CDstub(string) NSTates(int)

   tempvar totaldur 
   local seql : word count `varlist'
   local varlist1: word 1 of `varlist'
   local state = regexr(`"`varlist1'"',"[0-9]+$","")

   gen `totaldur' = 0

   forvalues x = 1/`nstates' {
      gen `cdstub'`x' = 0
      local state = regexr(`"`varlist1'"',"[0-9]+$","")
      label var `cdstub'`x' "Cumulative duration in `state' `x'"
      forvalues i = 1/`seql' {
         local state : word `i' of `varlist'
         qui replace `cdstub'`x' = `cdstub'`x' + 1 if `state' == `x'
         }
      qui replace `totaldur' = `totaldur' + `cdstub'`x'
      }

   // Check that cumulative sums total to sequence length:
   // otherwise you are perhaps missing a state
   qui su `totaldur'
   if ((`r(max)' != `seql') | (`r(min)' != `seql')) {
      di in red "Warning: states do not sum to total sequence length"
      }
end
   
