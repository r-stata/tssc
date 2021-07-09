*! vlc program to compare value labels across datasets
*! by Austin Nichols austinnichols@gmail.com
*! Version 1.5 22 Feb 2009 fixes _merge var and tab output
* Version 1.4 31 Jan 2008 
prog def vlc
 version 8.2
 syntax [anything] [using/] [in] [if] [aw fw pw iw/] [,to(str) clear tab PCent NOMIss NOFReq NOZero saving(str) replace append]
 local varlist `anything'
 if `"`varlist'"'=="" local varlist="_all"
 if `"`saving'"'!="" {
  tempname table
  file open `table' using `"`saving'"', write text `replace' `append'
  }
 tempfile old oldtmp newtmp
 tempvar ix il cvar sumvar mrg
 cap desc, sh 
 if "`clear'"=="" & r(changed)!=0 {
    error 4
    }
 else loc clear="clear"
 if "`using'"=="" {
  if "`tab'"=="" cap keep in 1
  qui save `old'
  }
 else {
  if "`tab'"=="" qui use `using' in 1, `clear'
  else qui use `using', `clear'
  qui save `old'
  }
 if "`nomiss'"!="" local missg="if value<."
 if `"`exp'"'!=""  local wt=`"[`weight'= `exp']"'
 foreach var of varlist `varlist' {
 use `old', `clear'
 local lvar: val label `var'
 local i 1
 cap la li `lvar'
 if _rc==0 & "`lvar'"!="" {
   uselabel `lvar' using `old', clear
   ren label label`i'
   sort value
   qui save `oldtmp', replace
   local varli="value label`i'"
   if "`tab'"!="" {
    qui use `var' `exp' using `old', clear
    qui gen byte `cvar'=1
    collapse (count) `cvar' `wt' `in' `if', by(`var')
        if "`nofreq'"=="" {
         local varli `varli' freq`i'
         } 
        if "`pcent'"!="" {
         local varli `varli' pc`i'
         qui g double `sumvar'=`cvar' `missg'
         qui replace `sumvar'=sum(`sumvar')
         qui replace `sumvar'=`sumvar'[_N]
         qui g double pc_o`i'=100*`cvar'/`sumvar'
         format pc`i' %4.3f
         }
    ren `cvar' freq`i'
    ren `var' value
    sort value
    qui merge value using `oldtmp', _merge(`mrg')
    cap drop `mrg'
    sort value
    qui save `oldtmp', replace
    }
   if `"`to'"'!="" {
    foreach new in `to' {
     local i=`i'+1
     cap uselabel `lvar' using `new', clear
     if _rc==0 {
      ren label label`i'
      local varli `varli' label`i'
      sort value
      }
     else {
       clear
       g label`i'="`var'"
       g value=.
       sort value
      }
     qui save `newtmp', replace
     if "`tab'"!="" {
      qui use `var' `exp' using `new', clear
      qui gen byte `cvar'=1
      collapse (count) `cvar' `wt' `in' `if', by(`var')
      if "`nofreq'"=="" {
       local varli `varli' freq`i'
       } 
      if "`pcent'"!="" {
       local varli `varli' pc`i'
       qui g double `sumvar'=`cvar' `missg'
       qui replace `sumvar'=sum(`sumvar')
       qui replace `sumvar'=`sumvar'[_N]
       qui g double pc_`new'=100*`cvar'/`sumvar'
       format pc_n`i' %4.3f
       }
      ren `cvar' freq`i'
      ren `var' value
      sort value
      qui merge value using `newtmp'
      cap drop _m
      }
     sort value
     qui merge value using `oldtmp', _merge(`mrg')
     cap drop `mrg'
     sort value
     qui save `oldtmp', replace
     qui merge value using `oldtmp', _merge(`mrg')
    }
   }
   cap drop `mrg'
   if "`nozero'"!="" {
     g byte `cvar'=0
     foreach v of varlist fr_* {
        replace `cvar'=1 if (`v'!=0)
        }
     if "`missg'"=="" local missg=" if `cvar'==1"
     if "`missg'"!="" local missg=" `missg' & `cvar'==1"
     }
   di as res _n "Variable " as txt "`var'" as res " has label " _c
   di as txt "`lvar'" as res " with values and labels:"
   li `varli' `missg', noo clean nol
    if `"`saving'"'!="" {
     cap keep `missg'
     sort value
     forval obs=0/`=_N' {
      file write `table' _n
      foreach var of varlist `varli' {
       if `obs'==0 file write `table' "`var'" _tab
       if `obs'>0 file write `table' "`=`var'[`obs']'" _tab
       }
      }  
     file close `table'
     }
    }
 }
end
