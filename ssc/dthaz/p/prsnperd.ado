*! version 1.3.2 28aug2010  by adinno at post dot harvard dot edu
*! transform a person-time data set into a person-period data set for 
*! discrete-time survival analyses

*   Copyright Notice
*   dthaz, prsnperd and prsnperd.ado are Copryright (c) 2001, 2010 Alexis Dinno
*
*   This file is part of dthaz.
*
*   Dthaz is free software; you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation; either version 2 of the License, or
*   (at your option) at any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program (dthaz.copying); if not, write to the Free Software
*   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

* Check for version compatibility and notify user of version incompatibility 
* and let them know I am ammennable to making back-compatible revisions.

program define prsnperd

  if int(_caller())<7 {
    di in r "prsnperd- does not support this version of Stata." _newline
    di as txt "Requests for a v6 compatible version may be less easy." 
    di as txt "Requests for a version compatible with versions of STATA earlier than v6 are "
    di as txt "untenable since I do not have access to the software." _newline 
    di as txt "All requests are welcome and will be considered."
    exit
  }
   if int(_caller())==7 {
     prsnperd7 `0'
   }
   if int(_caller())>=8 {
     prsnperd8 `0'
   }

end



*******************************************************************************
*******************************************************************************
* prsnperd for STATA Version 7                                                *
*******************************************************************************
*******************************************************************************

 program define prsnperd7
  version 7.0
  syntax varlist(numeric min=1 max=3) [, Truncate(integer 0)                 /*
  */     Pretrunc(integer 0) CSwitch tvp(namelist) /*
  */     fev(namelist(min=1 max=1)) copyleft]


  tokenize `varlist'

quietly {

*******************************************************************************
* Notify the user that CSwitch has been set, and display copyleft if asked.   *
*******************************************************************************

  if "`cswitch'" ~= "" {
    noisily {
      di _newline as yellow "CSwitch option ON. Assuming 0 = censored; 1 = event/failure for censor variable." _newline
    }
  }

  if "`copyleft'" == "copyleft" {
    noisily {
      di _newline "Copyright Notice"
      di "dthaz, prsnperd and prsnperd.ado are Copyright (c) 2001, 2010 alexis dinno" _newline
      di "This file is part of dthaz." _newline
      di "Dthaz is free software; you can redistribute it and/or modify"
      di "it under the terms of the GNU General Public License as published by"
      di "the Free Software Foundation; either version 2 of the License, or"
      di "(at your option) at any later version." _newline
      di "This program is distributed in the hope that it will be useful,"
      di "but WITHOUT ANY WARRANTY; without even the implied warranty of"      
      di "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"     
      di "GNU General Public License for more details." _newline
      di "You should have received a copy of the GNU General Public License"
      di "along with this program (dthaz.copying); if not, write to the Free Software"
      di "Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA" _newline
    }
  }


*******************************************************************************
* Check if time-to-event is in time-varying format, and generate              *
* length-to-event                                                             *
*******************************************************************************

  if ("`fev'" ~= "") {
    order `1' `fev'*
    gen length_to_event = .
    gen censored = 0
    local count = 0
    foreach variable of varlist `fev'* {
      if (`count' == 0 & `variable' == .) {
        drop length_to_event censored
        di as red "ERROR: Some observations missing observed event/no event at first time period!"
        error 1
      } 
      local count = `count' + 1
      replace length_to_event = `count' if (`variable' == 1 & length_to_event == .)
      replace censored = 1 if (`variable' == .)
      replace length_to_event = `count' if (censored == 1)
    }
    replace censored = 1 if length_to_event == .
    replace length_to_event = `count' if length_to_event == .
    local 2 = length_to_event
    local 3 = censored
  }
   local varlist = "`1' `2' `3'"
   local drop count

  
*******************************************************************************
* Idiot check the compatibility of truncate and pretrunc values               *
*******************************************************************************

  sum `2'
  if (`truncate' ~= 0 & `pretrunc' ~=0) {
    if ( (`truncate'-`pretrunc') <= 2 ) {
      noisily {
        di as white "truncate" as err " and " as white "pretrunc" as err " values are incompatible."
        di as err "(Not enough periods would be left to analyze)"
      }
      error ( (`truncate'-`pretrunc') <= 2 )
    }
  }


*******************************************************************************
* Validate the truncate value, set to 0 if no truncate value less than zero   *
*******************************************************************************

  local count=0
  foreach parameter of varlist `varlist' {
    local count=`count'+1
  }

  if `truncate'<0 {
    local truncate=0
  }
  
  if `2'>`truncate' & `truncate'>0 {
    replace `2'=`truncate'
    if `count'==3 {

      if "`cswitch'" == "" {
        replace `3'=1
      }

      if "`cswitch'" ~= "" {
        replace `3'=0
      }

    }
  }


*******************************************************************************
* Expand the dataset and create period variable                               *
*******************************************************************************

  expand `2'
  sort `1'
  by `1': generate _period=_n
  if `count'==2 {
    exit
  }  

*******************************************************************************
* Prepare to create `maxl' number of period indicator variables               *
*******************************************************************************

  sum `2'
  if `truncate'==0 | `truncate'>r(max){
    local maxl=r(max)
  }
    else {
      local maxl=`truncate'
    }
  local mxm1 = `maxl'-1


*******************************************************************************
* Create d1-dX where X = `maxl'                                               *
*******************************************************************************

  if `count'==3 {
    for num 1/`maxl': generate _dX=0\replace _dX = 1 if _period==X   
  }
  
  
*******************************************************************************
* Create Y and status variables for survival analysis applications            *
*******************************************************************************

  if `count' == 3 {
    generate _Y = 0
    if "`cswitch'" == "" {
      replace _Y = 1 if (_period == `2' & `3' == 0)
    }

    if "`cswitch'" ~= "" {
      replace _Y = 1 if (_period == `2' & `3' == 1)
    }

    label var _Y "0: Event did not happen; 1: Event happened"
    generate _status = 1 + (1 - _Y)
    
    if "`cswitch'" == "" {
      replace _status = 3 if (_status == 2 & _period == `2' & `3' == 1)
    }

    if "`cswitch'" ~= "" {
      replace _status = 3 if (_status == 2 & _period == `2' & `3' == 0)
    }
    
    label var _status "1: Left; 2: Stayed; 3: Censored"
  }



*******************************************************************************
* Diagnose potential problems with lack of variation in a single period       *
*******************************************************************************

*Evaluate whether any of the time periods are missing event occurrence.

  forvalues x=1/`maxl' {
   count if _period==`x' & _Y==1
   local events=r(N)
   count if _period==`x' & _Y==0
   local noevents=r(N)
   if `events'==0 | `noevents'==0 {
     noisily {
       di as result "No variation in event occurrence for period " `x' "!"
     }
   }
  }



*******************************************************************************
* Engage in pre-truncation madness!                                           *
*******************************************************************************

*Make sure that pretrunc is greater than or equal to zero AND less than maxl-l
*or do pre-truncation.

  if (`pretrunc'<0 | `pretrunc'>=`mxm1') {
    noisily {
      di as err "Pre-truncation value out of range."
      di as white "No pre-truncation used." _newline
    }
  }
    else {
      if (`pretrunc' ~= 0) {

* Dropping the first `pretrunc' number of period indicator variables
        forvalues x=1/`pretrunc' { drop _d`x' }
    
* Sequentially renaming the remaining period indicators.
        local maxl = `maxl'-`pretrunc'
        forvalues x=1/`maxl' {
          local curper = `pretrunc'+`x'
          rename _d`curper' _d`x'
        }
    
* Dropping observations in the pre-truncated periods    
        drop if _period<=`pretrunc'

* Revaluing _period so that the earliest time value is 1 (i.e.
* subtracting the pre-truncation number from _period.
        replace _period = _period-`pretrunc'

      }

    }


*******************************************************************************
* Deal with Time-Varying Predictors                                           *
*******************************************************************************

  if "`tvp'" ~= "" {
    foreach variable in `tvp' {
      gen `variable' = .
      forvalues n = 1/`maxl' {
        replace `variable' = `variable'`n' if _period == `n'
      }
    }
  }


*******************************************************************************
* Clean up                                                                    *
*******************************************************************************

  macro drop truncate maxl
 }

 end



*******************************************************************************
*******************************************************************************
* prsnperd for STATA Versions 8+                                              *
*******************************************************************************
*******************************************************************************

 program define prsnperd8
  version 8.0
  syntax varlist(numeric min=1 max=3) [, Truncate(integer 0)                 /*
  */     Pretrunc(integer 0) CSwitch tvp(namelist) /*
  */     fev(name) copyleft]

  tokenize `varlist'

quietly {

*******************************************************************************
* Notify the user that CSwitch has been set, and display copyleft if asked.   *
*******************************************************************************

  if "`cswitch'" ~= "" {
    noisily {
      di _newline as yellow "CSwitch option ON. Assuming 0 = censored; 1 = event/failure for censor variable." _newline
    }
  }

  if "`copyleft'" == "copyleft" {
    noisily {
      di _newline "Copyright Notice"
      di "dthaz, prsnperd and prsnperd.ado are Copyright (c) 2001, 2010 alexis dinno" _newline
      di "This file is part of dthaz." _newline
      di "Dthaz is free software; you can redistribute it and/or modify"
      di "it under the terms of the GNU General Public License as published by"
      di "the Free Software Foundation; either version 2 of the License, or"
      di "(at your option) at any later version." _newline
      di "This program is distributed in the hope that it will be useful,"
      di "but WITHOUT ANY WARRANTY; without even the implied warranty of"      
      di "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"     
      di "GNU General Public License for more details." _newline
      di "You should have received a copy of the GNU General Public License"
      di "along with this program (dthaz.copying); if not, write to the Free Software"
      di "Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA" _newline
    }
  }



*******************************************************************************
* Check if time-to-event is in time-varying format, and generate              *
* length-to-event                                                             *
*******************************************************************************

  if ("`fev'" ~= "") {
    order `1' `fev'*
    gen length_to_event = .
    gen censored = 0
    local count = 0
    foreach variable of varlist `fev'* {
      if (`count' == 0 & `variable' == .) {
        drop length_to_event censored
        di as red "ERROR: Some observations missing observed event/no event at first time period!"
        error 1
      } 
      local count = `count' + 1
      replace length_to_event = `count' if (`variable' == 1 & length_to_event == .)
      replace censored = 1 if (`variable' == .)
      replace length_to_event = `count' if (censored == 1)
    }
    replace censored = 1 if length_to_event == .
    replace length_to_event = `count' if length_to_event == .
    local 2 = length_to_event
    local 3 = censored
  }

   local varlist = "`1' `2' `3'"
   local drop count

  
*******************************************************************************
* Idiot check the compatibility of truncate and pretrunc values               *
*******************************************************************************

  sum `2'
  if (`truncate' ~= 0 & `pretrunc' ~=0) {
    if ( (`truncate'-`pretrunc') <= 2 ) {
      noisily {
        di as white "truncate" as err " and " as white "pretrunc" as err " values are incompatible."
        di as err "(Not enough periods would be left to analyze)"
      }
      error ( (`truncate'-`pretrunc') <= 2 )
    }
  }


*******************************************************************************
* Validate the truncate value, set to 0 if no truncate value less than zero   *
*******************************************************************************

  local count=0
  foreach parameter of varlist `varlist' {
    local count=`count'+1
  }

  if `truncate'<0 {
    local truncate=0
  }
  
  if `2'>`truncate' & `truncate'>0 {
    replace `2'=`truncate'
    if `count'==3 {

      if "`cswitch'" == "" {
        replace `3'=1
      }

      if "`cswitch'" ~= "" {
        replace `3'=0
      }

    }
  }


*******************************************************************************
* Expand the dataset and create period variable                               *
*******************************************************************************

  expand `2'
  sort `1'
  by `1': generate _period=_n
  if `count'==2 {
    exit
  }  

*******************************************************************************
* Prepare to create `maxl' number of period indicator variables               *
*******************************************************************************

  sum `2'
  if `truncate'==0 | `truncate'>r(max){
    local maxl=r(max)
  }
    else {
      local maxl=`truncate'
    }
  local mxm1 = `maxl'-1


*******************************************************************************
* Create d1-dX where X = `maxl'                                               *
*******************************************************************************

  if `count'==3 {
    for num 1/`maxl': generate _dX=0\replace _dX = 1 if _period==X   
  }
  
  
*******************************************************************************
* Create Y and status variables for survival analysis applications            *
*******************************************************************************

  if `count' == 3 {
    generate _Y = 0
    if "`cswitch'" == "" {
      replace _Y = 1 if (_period == `2' & `3' == 0)
    }

    if "`cswitch'" ~= "" {
      replace _Y = 1 if (_period == `2' & `3' == 1)
    }

    label var _Y "0: Event did not happen; 1: Event happened"
    generate _status = 1 + (1 - _Y)
    
    if "`cswitch'" == "" {
      replace _status = 3 if (_status == 2 & _period == `2' & `3' == 1)
    }

    if "`cswitch'" ~= "" {
      replace _status = 3 if (_status == 2 & _period == `2' & `3' == 0)
    }
    
    label var _status "1: Left; 2: Stayed; 3: Censored"
  }


*******************************************************************************
* Diagnose potential problems with lack of variation in a single period       *
*******************************************************************************

*Evaluate whether any of the time periods are missing event occurrence.

  forvalues x=1/`maxl' {
   count if _period==`x' & _Y==1
   local events=r(N)
   count if _period==`x' & _Y==0
   local noevents=r(N)
   if `events'==0 | `noevents'==0 {
     noisily {
       di as result "No variation in event occurrence for period " `x' "!"
     }
   }
  }


*******************************************************************************
* Engage in pre-truncation madness!                                           *
*******************************************************************************

*Make sure that pretrunc is greater than or equal to zero AND less than maxl-l
*or do pre-truncation.

  if (`pretrunc'<0 | `pretrunc'>=`mxm1') {
    noisily {
      di as err "Pre-truncation value out of range."
      di as white "No pre-truncation used." _newline
    }
  }
    else {
      if (`pretrunc' ~= 0) {

* Dropping the first `pretrunc' number of period indicator variables
        forvalues x=1/`pretrunc' { drop _d`x' }
    
* Sequentially renaming the remaining period indicators.
        local maxl = `maxl'-`pretrunc'
        forvalues x=1/`maxl' {
          local curper = `pretrunc'+`x'
          rename _d`curper' _d`x'
        }
    
* Dropping observations in the pre-truncated periods    
        drop if _period<=`pretrunc'

* Revaluing _period so that the earliest time value is 1 (i.e.
* subtracting the pre-truncation number from _period.
        replace _period = _period-`pretrunc'

      }

    }


*******************************************************************************
* Deal with Time-Varying Predictors                                           *
*******************************************************************************

  if "`tvp'" ~= "" {
    foreach variable in `tvp' {
      gen `variable' = .
      forvalues n = 1/`maxl' {
        replace `variable' = `variable'`n' if _period == `n'
      }
    }
  }


*******************************************************************************
* Clean up                                                                    *
*******************************************************************************

  macro drop truncate maxl
 }

 end



