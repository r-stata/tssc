*! multibar.ado v 1.1.0 03aug2007
*! keywords graph bar dot hbar
program multibar
   version 9.2
   syntax varlist [if] [in], GNUMber(numlist >1 int) ///
   CATLABels(string asis) Type(string) [ STATistic(string) Percent List * ]

   // varnum:  total number of variables
   // gnumber: number of groups  - each "drug" is a group
   // vonline: number of variables to be processed for each group

   if "`type'" != "bar" & "`type'" != "hbar" & "`type'" != "dot" {
      di as err "type() must be entered as bar or hbar or dot"
      exit 198
   }

   local varnum : word count `varlist'
   if mod(`varnum',`gnumber') != 0 {
      di as err ///
      "number of variables specified and gnumber() are inconsistent"
      exit 198
   }

   marksample touse, novarlist

   quietly {
      count if `touse'
      if r(N) == 0 error 2000

      preserve
      keep if `touse'
      keep `varlist'
      if "`statistic'" == "" local statistic mean
      collapse (`statistic') `varlist' 
   
      local vonline = `varnum' / `gnumber'
      expand `gnumber'
      tempvar mygroup
      egen `mygroup' = seq(), f(1) to(`gnumber') block(1)
   
      forval i = 1 / `vonline' {
         tempvar temp
         gen byte `temp' = .
         local temps `temps' `temp'
      }

      if "`percent'" != "" local factor "100 *"
    
      forval j = 1 / `gnumber' {
         local c = 0
         forval i =  1(`gnumber')`varnum' {
            local c = `c' + 1
            local k = `i' + `j' - 1
            local v: word `k' of `varlist'
            local t: word `c' of `temps'
            replace `t' = `factor' `v' if `j' == `mygroup'
         }
      }

      if `"`catlabels'"' != "" {
         tempname mylabel
         label define `mylabel' `catlabels'
         label values `mygroup' `mylabel'
      }
   }

   graph `type' `temps', over(`mygroup') `options'
   
   if "`list'" == "list" {
      collapse `temps',by(`mygroup')
      char `mygroup'[varname] Group
      local counter = 0
      foreach var of local temps {
         local ++counter
         char `var'[varname] "Subgroup `counter'"
      }
      list, noobs subvarname ab(16)
   }
end
exit
*  touched NJC 30 July 2007
* v 1.1.0 corrected code and help file; added  statistic() option
