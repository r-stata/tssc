*! version 2.0.0 04dec2011 by alexis dot dinno at pdx dot edu
*! calculate estimated hazard and survivor probabilities for
*! multiply-specified discrete-time event history analyses

*   Copyright Notice
*   dthaz msdthaz and msdthaz.ado are Copryright (c) 2001, 2011 Alexis Dinno
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

* Syntax:   msdthaz using filename [, TPar(#) Link(string) level(#) 
*           CLUSter(varname) BASEline Model GRaph(#) dthaz_options copyleft]

* Check for version compatibility and notify user of version incompatibility 
* and let them know I am ammennable to making back-compatible revisions.

program define msdthaz

  if int(_caller())<7 {
    di in r "msdthaz- does not support this version of Stata." _newline
    di as txt "Requests for a v6 compatible version may be less easy." 
    di as txt "Requests for a version compatible with versions of STATA earlier than v6 are "
    di as txt "untenable since I do not have access to the software." _newline 
    di as txt "All requests are welcome and will be considered."
    exit
    }
   if int(_caller())==7 {
     msdthaz7 `0'
     }
   if int(_caller())>=8 {
     msdthaz8 `0'
     }
end


********************************************************************************
********************************************************************************
* msdthaz for STATA Version 7                                                  *
********************************************************************************
********************************************************************************


program define msdthaz7, eclass
 version 7.0
 syntax using/ [if] [in] [fweight pweight iweight] [, TPar(integer -1)        /*
 */     Link(string) level(cilevel) CLUSter(varlist numeric min=1 max=1)      /*
 */     BASEline Model GRaph(integer 0) suppress copyleft * ]


*NOTE The suppress option is used by the program to communicate with dthaz.     
*User setting of the suppress switch has no effect on the performance of the    
*program

quietly {

preserve


********************************************************************************
* display copyleft if requested
********************************************************************************

  if "`copyleft'" == "copyleft" {
    noisily {
      di _newline "Copyright Notice"
      di "dthaz, msdthaz and msdthaz.ado are Copyright (c) 2001, 2011 alexis dinno" _newline
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
*Validate link() option
******************************************************************************* 

  if "`link'"=="" {
    local link = "logit"
    }
  if (!("`link'"=="logit" | "`link'"=="cloglog" | "`link'"=="probit")) {
    noisily {
      di as err "invalid link():  `link'." _newline "valid link() options are logit, cloglog, or probit."
      }
    error (199)
    }


******************************************************************************* 
*Take care of dthaz's graph and suppress options...
******************************************************************************* 

  local msgraph=`graph'
  if `msgraph'>4 | `msgraph'<1 { local `graph'=0 }
  local graph=0

  local suppress=""

******************************************************************************* 
*Juicy `main course' of the msdthaz program right here...                     * 
*******************************************************************************
       
*Get into the specification file and read it...
  tempname SPECS TempHaz Hazard
  local linenum = 0
  file open `SPECS' using "`using'", read
  file read `SPECS' line

*let the kind users know that something is happening...
  noisily {di as white _newline "Specified models calculated: " _continue}      

*For each line of the file do all this stuff...
  while r(eof)==0 {
    local linenum = `linenum' + 1

*Obtain the varlist of predictors to be used by dthaz from the first line of the
*file.
    if `linenum'==1 {local predictors = "`line'"}    

*Otherwise calculate appropriate probabilities!
    if `linenum'>1 {

*If this is the first estimate calculation, then we do things a little
*differently (like actually run the estimate).
      if `linenum'==2 {
        local args = " `predictors' "+"`if' `in' [`weight' `exp']"+" , sp("+"`line'"+") "+" tpar(`tpar') "+" link(`link') "+" cluster(`cluster') "+"  `options' "

*margs is for later output of the model if requested. For some reason the
*program seems to loose the cloglog estimate on my system.
        local margs = "`args'" + " model  suppress"
        }
          
*Otherwise we just REUSE the estimate (cloglog volatility doesn't happen this
*early on)
      if `linenum'>2 {
        local args = " `predictors' "+"`if' `in' [`weight' `exp']"+" , sp("+"`line'"+") "+" tpar(`tpar') "+" link(`link') "+" cluster(`cluster') "+"  `options' "+" reuse"
        }
  
*Boogie on down
      dthaz `args'
  
*Ennumeration for the masses!
      noisily {
        di as white `linenum'-1 " " _continue
        }

*The first set of probabilities generated will serve as the start of the output
*matrix. Thereafter, we only need the Hazard and Survival columns since the
*period column is the same for each. 
      local Tplus1 = colsof(e(Hazard))
      matrix Period = J(1,`Tplus1',.)
      forvalues i = 1(1)`Tplus1' {
        matrix Period[1,`i'] = `i'-1
        }
      if `linenum'==2 {
        matrix TempHaz = (Period'),(e(Hazard)'),(e(HazardSE)'),(e(Survival)',(e(SurvivalSE)'))
        matname TempHaz Period Hazard_1 SE_Hazard_1 Survival_1 SE_Survival_1 , columns(1...) explicit
        }

*Speaking of which, here we go grabbing just those columns and identifying
*them by name as to which line of the specification file each set of            
*probability estimates is derrived from
      if `linenum'>2 {
        matrix Hazard = (Period'),(e(Hazard)'),(e(Survival)')
        local specnum = `linenum'-1
        matname Hazard Hazard_`specnum' SE_Hazard_`specnum' Survival_`specnum' SE_Survival_`specnum', columns(2...) explicit
        matrix TempHaz = TempHaz,Hazard[1...,2...]
        }
    
      }

    file read `SPECS' line
    }
  file close `SPECS'

*Append baseline probabilities if requested
  if "`baseline'"=="baseline" {
    local args = "`if' `in' [`weight' `exp'], tpar(`tpar') link(`link') `cluster' `options'"
    dthaz `args'
    local Tplus1 = colsof(e(Hazard))
    matrix Period = J(1,`Tplus1',.)
    forvalues i = 1(1)`Tplus1' {
      matrix Period[1,`i'] = `i'-1
      }
    matrix Hazard = (Period'),(e(Hazard)'),(e(HazardSE)'),(e(Survival)',(e(SurvivalSE)'))
    matname Hazard Hazard_Baseline SE_Hazard_Baseline Survival_Baseline SE_Survival_Baseline, columns(2...) explicit
    matrix TempHaz = TempHaz,Hazard[1...,2...]       
    noisily {di as white `linenum' " " _continue}
  }       


*******************************************************************************
*Output segment of msdthaz                                                    *
*******************************************************************************

noisily {

*Initial output. Tell the user what's in store, reiterate predictors for
*estimate specification.
  di _newline
  di as txt "Multiply-Specified Discrete Time Survival Analysis Estimates"      
  di as txt "--------------------------------------"


*Indicate parameterization of time
  if `tpar' ==-2 { di as txt "Time Parameterization:  Square Root" }
  if `tpar' ==-1 { di as txt "Time Parameterization: Fully Discrete" }
  if `tpar'  ==0 { di as txt "Time Parameterization: Constant Effect polynomial of order 0)" }
  if `tpar'  ==1 { di as txt "Time Parameterization: Linear (polynomial of order 1)" }
  if `tpar'  ==2 { di as txt "Time Parameterization: Quadratic (polynomial of order 2)" }
  if `tpar'  ==3 { di as txt "Time Parameterization: Cubic (polynomial of order 3)"}
  if `tpar'  >=4 { di as txt "Polynomial Time Parameterization of Order " `tpar' }
          
*Indicate predictors
  di _newline as txt "Predictors specified: `predictors'" _newline
     
*Indicate estimate link   
    
  if "`model'"=="" {
    if "`link'"=="logit"   { di as txt "Logit Link (assumes proportional odds)" }
    if "`link'"=="cloglog" { di as txt "Complementary Log-Log Link (assumes proportional hazards)" }
    if "`link'"=="probit"  { di as txt "Probit Link (probit hazards)" }
    }
    
  }
    
*Provide model of appropriate estimate if requested
  if "`model'"=="model" { noisily { dthaz `margs' } }
    
  }        

matrix MSHazard = TempHaz
ereturn matrix MSHazard TempHaz

*******************************************************************************
*Graph some output!                                                           *
*******************************************************************************

if `msgraph'~=0 {

  local maxl = rowsof(MSHazard)-1
  svmat MSHazard, names(col)
 
  set more on

*Manage graphing options input. If baseline is requested the number of plotted
*lines increases by one
  if "`baseline'"=="baseline" { local specnum=`specnum'+1 }
 
    local drop connect symbol pen c s p
    local connect = "l"
    forvalues num=2/`specnum' {
      local connect = "`connect'l"
      }    
    local connect "c(`connect')"
  
    local pen = 1
    local pennum = 1
    forvalues num=2/`specnum' {
      if `pennum'>8 { local pennum = 1 }
       else {local pennum = `num'}
      local pen = "`pen'`pennum'"
      local pennum = `pennum'+1
      }
    local pen "pen(`pen')"

    local symbol = "."
    forvalues num=2/`specnum' {
      local symbol = "`symbol'"+"."
      }
    local symbol "symbol(`symbol')"

    if "`baseline'"=="baseline" { local specnum=`specnum'-1 }
    
    local ytick = "yt(0(.2)1)"
    local ylabel = "yla(0(.2)1)"
    local gap = "gap(2)"     
 
*Create the list of conditional hazard probability sets if needed
    if `msgraph'==1 | `msgraph'==3 {
      local hazards = " Hazard_1"
      forvalues num=2/`specnum' {
        local hazards = "`hazards'" + " Hazard_`num' "
        }
      if "`baseline'"=="baseline" { local hazards = "`hazards'" + " Hazard_Baseline" }
      }
 
*Create the list of survival probability sets if needed
    if `msgraph'==2 | `msgraph'==3 {
      local survivals = " Survival_1"
      forvalues num=2/`specnum' {
        local survivals = "`survivals'" + " Survival_`num' " 
        }
      if "`baseline'"=="baseline" { local survivals = "`survivals'" + " Survival_Baseline" }
      }
   
*Create the list of cumulative event probability sets if needed
  if `msgraph'==4 {
    forvalues num=1/`specnum' {
      quietly {
        gen CumEvent_`num' = 1 - Survival_`num'
        }
      }
    local cumevents = " CumEvent_1"
    forvalues num=2/`specnum' {
      local cumevents = "`cumevents'" + " CumEvent_`num' " 
      }
    if "`baseline'"=="baseline" { 
      quietly {
        gen CumEvent_Baseline = 1 - Survival_Baseline
        }
      local cumevents = "`cumevents'" + " CumEvent_Baseline" 
      }
    }
   
*Graph conditional hazard probabilities
    if `msgraph'==1 {
  
*Deal with axes specific to conditional hazard curves
      local xtick "xt(1(1)`maxl')"
      local xlabel "xla(1(1)`maxl')"
      local l1title = "l1(Estimated Conditional Hazard Probability)"
    
      gr `hazards' Period if Period~=0, `connect' `symbol' `pen' `xtick' `ytick' `xlabel' `ylabel' `l1title' `gap' `options'
      }
 
*Graph survival probabilities
    if `msgraph'==2 | `msgraph' ==4{
 
*Deal with axes specific to survival and cumulative event curves
      local xtick "xt(0(1)`maxl')"
      local xlabel "xla(0(1)`maxl')"
      if `msgraph' == 2 {
        local l1title = "l1(Estimated Survival Probability)"
        gr `survivals' Period, `connect' `symbol' `pen' `xtick' `ytick' `xlabel' `ylabel' `l1title' `gap' `options'
        }
      if `msgraph' == 4 {
        local l1title = "l1(Estimated Cumulative Event Probability)"
        gr `cumevents' Period, `connect' `symbol' `pen' `xtick' `ytick' `xlabel' `ylabel' `l1title' `gap' `options'
        }
      }
 
*Graph both conditional hazard and survival probabilities
    if `msgraph'==3 {

*Prepare for different x-axis labeling needs for hazard and survival
      local tempxt="`xtick'"
      local tempxla="`xlabel'"
      local l1title = "l1(Estimated Conditional Hazard Probability)"
  
      local xtick "xt(1(1)`maxl')"
      local xlabel "xla(1(1)`maxl')"
      gr `hazards' Period if Period~=0, `connect' `symbol' `pen' `xtick' `ytick' `xlabel' `ylabel' `l1title' `gap' `options'
    
      more

      local xtick="`tempxt'"
      local xlabel="`tempxla'"
      local xtick "xt(0(1)`maxl')"
      local xlabel "xla(0(1)`maxl')"
      local l1title = "l1(Estimated Survival Probability)"

      gr `survivals' Period, `connect' `symbol' `pen' `xtick' `ytick' `xlabel' `ylabel' `l1title' `gap' `options'   
      }
 
    restore, preserve
    }
    
  end
        


********************************************************************************
********************************************************************************
* msdthaz for STATA Versions 8+                                                *
********************************************************************************
********************************************************************************

program define msdthaz8, eclass
version 8.0
syntax using/  [if] [in] [fweight pweight iweight] [, TPar(integer -1)       /*
*/     Link(string) level(cilevel) CLUSter(varlist numeric min=1 max=1)      /*
*/     BASEline Model GRaph(integer 0) suppress copyleft * ]


*NOTE The suppress option is used by the program to communicate with dthaz. 
*User setting of the suppress switch has no effect on the performance of the 
*program

quietly {
 
  preserve


********************************************************************************
* display copyleft if requested
********************************************************************************

  if "`copyleft'" == "copyleft" {
    noisily {
      di _newline "Copyright Notice"
      di "dthaz, msdthaz and msdthaz.ado are Copyright (c) 2001, 2011 alexis dinno" _newline
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
*Validate link() option
******************************************************************************* 

  if "`link'"=="" {
    local link = "logit"
    }
  if (!("`link'"=="logit" | "`link'"=="cloglog" | "`link'"=="probit")) {
    noisily {
      di as err "invalid link():  `link'." _newline "valid link() options are logit, cloglog, or probit."
      }
    error (199)
    }

*Take care of dthaz's graph and suppress options...

  local msgraph=`graph'
  if `msgraph'>4 | `msgraph'<1 {
    local `graph'=0
    } 
  local graph=0
  local suppress=""

*******************************************************************************
*Juicy `main course' of the msdthaz program right here...                     *
*******************************************************************************

*Get into the specification file and read it...
  tempname SPECS TempHaz Hazard
  local linenum = 0
  file open `SPECS' using "`using'", read
  file read `SPECS' line

*let the kind users know that something is happening...
  noisily {
    di as white _newline "Specified models calculated: " _continue
    }

*For each line of the file do all this stuff...
  while r(eof)==0 {
    local linenum = `linenum' + 1

*Obtain the varlist of predictors to be used by dthaz from the first line of the 
*file.
    if `linenum'==1 {
      local predictors = "`line'"
      }

*Otherwise calculate appropriate probabilities!
    if `linenum'>1 {

*If this is the first estimate calculation, then we do things a little 
*differently (like actually run the estimate).
        if `linenum'==2 { 
          local args = " `predictors' "+"`if' `in' [`weight' `exp']"+" , sp("+"`line'"+") "+" tpar(`tpar') "+" link(`link') "+" cluster(`cluster') "+" `options' "

*margs is for later output of the model if requested. For some reason the 
*program seems to loose the cloglog estimate on my system.
          local margs = "`args'" + " model  suppress"
          }

*Otherwise we just REUSE the estimate (cloglog volatility doesn't happen this 
*early on)
        if `linenum'>2 {
          local args = " `predictors' "+"`if' `in' [`weight' `exp']"+" , sp("+"`line'"+") "+" tpar(`tpar') "+" link(`link') "+" cluster(`cluster') "+" `options' "+" reuse" 
          }

*Boogie on down
        dthaz `args'
    
*Ennumeration for the masses!
        noisily {
          di as white `linenum'-1 " " _continue
          }
 
*The first set of probabilities generated will serve as the start of the output
*matrix. Thereafter, we only need the Hazard and Survival columns since the 
*period column is the same for each.
        local Tplus1 = colsof(e(Hazard))
        matrix Period = J(1,`Tplus1',.)
        forvalues i = 1(1)`Tplus1' {
          matrix Period[1,`i'] = `i'-1
          }
        if `linenum'==2 {
          matrix TempHaz = (Period'),(e(Hazard)'),(e(HazardSE)'),(e(Survival)',(e(SurvivalSE)'))
          matname TempHaz Period Hazard_1 SE_Hazard_1 Survival_1 SE_Survival_1, columns(1...) explicit
          }

*Speaking of which, here we go grabbing just those columns and identifying 
*them by name as to which line of the specification file each set of 
*probability estimates is derrived from
        if `linenum'>2 { 
          matrix Hazard = (Period'),(e(Hazard)'),(e(HazardSE)'),(e(Survival)',(e(SurvivalSE)'))
          local specnum = `linenum'-1
          matname Hazard Hazard_`specnum' SE_Hazard_`specnum' Survival_`specnum' SE_Survival_`specnum', columns(2...) explicit
          matrix TempHaz = TempHaz,Hazard[1...,2...]
          }        

    }    
    file read `SPECS' line

  }
  file close `SPECS'

*Append baseline probabilities if requested
  if "`baseline'"=="baseline" {
    local args = "`if' `in' [`weight' `exp'], tpar(`tpar') link(`link') `cluster' `options'"
    dthaz `args'
    local Tplus1 = colsof(e(Hazard))
    matrix Period = J(1,`Tplus1',.)
    forvalues i = 1(1)`Tplus1' {
      matrix Period[1,`i'] = `i'-1
      }
    matrix Hazard = (Period'),(e(Hazard)'),(e(HazardSE)'),(e(Survival)',(e(SurvivalSE)'))
    matname Hazard Hazard_Baseline SE_Hazard_Baseline Survival_Baseline SE_Survival_Baseline, columns(2...) explicit
    matrix TempHaz = TempHaz,Hazard[1...,2...]
    noisily {
      di as white `linenum' " " _continue
      }
    }
    

*******************************************************************************
*Output segment of msdthaz                                                    *
*******************************************************************************

noisily {

*Initial output. Tell the user what's in store, reiterate predictors for   
*estimate specification.
 di _newline
 di as txt "Multiply-Specified Discrete Time Survival Analysis Estimates"
 di as txt "------------------------------------------------------------------------------"

*Indicate parameterization of time
 
 if `tpar'==-2 {
   di as txt "Time Parameterization:  Square Root" 
   }
 
 if `tpar'==-1 {
   di as txt "Time Parameterization: Fully Discrete" 
   }
 
 if `tpar'==0 {
   di as txt "Time Parameterization: Constant Effect polynomial of order 0)" 
   } 
 
 if `tpar'==1 {
   di as txt "Time Parameterization: Linear (polynomial of order 1)" 
   }
 
 if `tpar'==2 {
   di as txt "Time Parameterization: Quadratic (polynomial of order 2)" 
   }
 
 if `tpar'==3 {
   di as txt "Time Parameterization: Cubic (polynomial of order 3)" 
   }
 
 if `tpar'>=4 {
   di as txt "Polynomial Time Parameterization of Order " `tpar' 
   }

*Indicate predictors
 di _newline as txt "Predictors specified: `predictors'" _newline

*Indicate estimate link
 
 if "`model'"=="" {
   if "`link'"=="logit" {
     di as txt "Logit Link (assumes proportional hazards)" 
     }
   if "`link'"=="cloglog" {
     di as txt "Complementary Log-Log Link (assumes proportional hazards)" 
     }
   if "`link'"=="probit" {
     di as txt "Probit Link (assumes probit hazards)" 
     }
   }
 
 }

*Provide model of appropriate estimate if requested
  if "`model'"=="model" {
    noisily {
      dthaz `margs' 
      } 
    }
        
 }
 
 matrix MSHazard = TempHaz
 ereturn matrix MSHazard TempHaz

*******************************************************************************
*Graph some output!                                                           *
*******************************************************************************

if `msgraph'~=0 {

 local maxl = rowsof(MSHazard)-1
 svmat MSHazard, names(col)

 set more on

*Manage graphing options input. If baseline is requested the number of plotted
*lines increases by one
 if "`baseline'"=="baseline" {
   local specnum=`specnum'+1 
   }

 local drop connect symbol pen c s p
 local connect = "l"
 forvalues num=2/`specnum' {
   local connect = "`connect'l"
   }
 local connect "c(`connect')"

 local pen = 1
 local pennum = 1
 forvalues num=2/`specnum' {
   if `pennum'>8 {
     local pennum = 1 
     }
    else {
     local pennum = `num'
     }
   local pen = "`pen'`pennum'"
   local pennum = `pennum'+1
   }
 local pen "pen(`pen')"

 local symbol = "."
 forvalues num=2/`specnum' {
   local symbol = "`symbol'"+"."
   }
 local symbol "symbol(`symbol')"
 
 if "`baseline'"=="baseline" {
   local specnum=`specnum'-1 
   }

 local ytick = "yt(0(.2)1)"
 local ylabel = "yla(0(.2)1)"
 local gap = "gap(2)"
 
*Create the list of conditional hazard probability sets if needed
 if `msgraph'==1 | `msgraph'==3 {
   forvalues num=1/`specnum' {
     quietly {
       gen HazardLB_`num' = Hazard_`num'-(invnormal(1-((1-(`level'/100))/2))*SE_Hazard_`num')
       gen HazardUB_`num' = Hazard_`num'+(invnormal(1-((1-(`level'/100))/2))*SE_Hazard_`num')
       }
     }
   local hazards = " Hazard_1"
   local hazardLBs = " HazardLB_1"
   local hazardUBs = " HazardUB_1"
   forvalues num=2/`specnum' {
     local hazards = "`hazards'" + " Hazard_`num' "
     local hazardLBs = "`hazardLBs'" + " HazardLB_`num' "
     local hazardUBs = "`hazardUBs'" + " HazardUB_`num' "
     }
   if "`baseline'"=="baseline" {
     quietly {
       gen HazardLB_Baseline = Hazard_Baseline-(invnormal(1-((1-(`level'/100))/2))*SE_Hazard_Baseline)
       gen HazardUB_Baseline = Hazard_Baseline+(invnormal(1-((1-(`level'/100))/2))*SE_Hazard_Baseline)
       }
     local hazards = "`hazards'" + " Hazard_Baseline " 
     local hazardLBs = "`hazardLBs'" + " HazardLB_Baseline "
     local hazardUBs = "`hazardUBs'" + " HazardUB_Baseline "
     }
   }

*Create the list of survival probability sets if needed
 if `msgraph'==2 | `msgraph'==3 {
   forvalues num=1/`specnum' {
     quietly {
       gen SurvivalLB_`num' = Survival_`num'-(invnormal(1-((1-(`level'/100))/2))*SE_Survival_`num')
       gen SurvivalUB_`num' = Survival_`num'+(invnormal(1-((1-(`level'/100))/2))*SE_Survival_`num')
       }
     }
   local survivals = " Survival_1"
   local survivalLBs = " SurvivalLB_1"
   local survivalUBs = " SurvivalUB_1"
   forvalues num=2/`specnum' {
     local survivals = "`survivals'" + " Survival_`num' "
     local survivalLBs = "`survivalLBs'" + " SurvivalLB_`num' "
     local survivalUBs = "`survivalUBs'" + " SurvivalUB_`num' "
   }
   if "`baseline'"=="baseline" {
     quietly {
       gen SurvivalLB_Baseline = Survival_Baseline-(invnormal(1-((1-(`level'/100))/2))*SE_Survival_Baseline)
       gen SurvivalUB_Baseline = Survival_Baseline+(invnormal(1-((1-(`level'/100))/2))*SE_Survival_Baseline)
       }
     local survivals = "`survivals'" + " Survival_Baseline" 
     local survivalLBs = "`survivalLBs'" + " SurvivalLB_Baseline " 
     local survivalUBs = "`survivalUBs'" + " SurvivalUB_Baseline " 
   }
 }

*Create the list of cumulative event probability sets if needed
 if `msgraph'==4 {
   forvalues num=1/`specnum' {
     quietly {
       gen CumEvent_`num' = 1 - Survival_`num'
       gen CumEventLB_`num' = CumEvent_`num'-(invnormal(1-((1-(`level'/100))/2))*SE_Survival_`num')
       gen CumEventUB_`num' = CumEvent_`num'+(invnormal(1-((1-(`level'/100))/2))*SE_Survival_`num')
       }
     }
   local cumevents = " CumEvent_1"
   local cumeventLBs = " CumEventLB_1"
   local cumeventUBs = " CumEventUB_1"
   forvalues num=2/`specnum' {
     local cumevents = "`cumevents'" + " CumEvent_`num' " 
     local cumeventLBs = "`cumeventLBs'" + " CumEventLB_`num' " 
     local cumeventUBs = "`cumeventUBs'" + " CumEventUB_`num' " 
   }
   if "`baseline'"=="baseline" { 
     quietly {
       gen CumEvent_Baseline = 1 - Survival_Baseline
       gen CumEventLB_Baseline = CumEvent_Baseline-(invnormal(1-((1-(`level'/100))/2))*SE_Survival_Baseline)
       gen CumEventUB_Baseline = CumEvent_Baseline+(invnormal(1-((1-(`level'/100))/2))*SE_Survival_Baseline)
       }
     local cumevents = "`cumevents'" + " CumEvent_Baseline" 
     local cumeventLBs = "`cumeventLBs'" + " CumEventLB_Baseline " 
     local cumeventUBs = "`cumeventUBs'" + " CumEventUB_Baseline " 
     }
 }
   

*Create color and line weighting schemes
   tokenize "red blue green violet orange brown pink cyan gold salmon yellow gray olive mint purple lavender navy orange_red magenta teal ltblue ltkhaki dkorange cranberry sienna"
   local linecolors = "red"
   local linewidths = "medium"
   local CIwidths = "vvthin"
   forvalues num=2/`specnum' {
     macro shift
     local linecolors = "`linecolors'" + "  " + "`1'"
     local linewidths = "`linewidths'"+" medium"
     local CIwidths = "`CIwidths'"+" vvthin"
     if `num'==`specnum' & "`baseline'" =="baseline" {
       local linewidths = "`linewidths'"+" medium"
       local CIwidths = "`CIwidths'"+" vvthin"
       local linecolors = "`linecolors'"+" black"
       }
     }
   local linecolors = "`linecolors'" + " `linecolors'" +" `linecolors'"
   local linewidths = "`linewidths'"+" `CIwidths'"+" `CIwidths'"

*Graph conditional hazard probabilities
   if `msgraph'==1 {

*Deal with axes specific to conditional hazard curves
     local xtick "xt(1(1)`maxl')"
     local xlabel "xla(1(1)`maxl')"
     local ytitle = "ytitle(Estimated Conditional Hazard Probability)"
     line `hazards' `hazardLBs' `hazardUBs' Period if Period~=0, lcolor(`linecolors') lwidth(`linewidths') `xtick' `ytick' `xlabel' `ylabel' `ytitle' `options'
   }
   
*Graph survival or cumulative event probabilities
   if `msgraph'==2 | `msgraph' == 4 {

   *Deal with axes specific to survival curves
    local xtick "xt(0(1)`maxl')"
    local xlabel "xla(0(1)`maxl')"
    if `msgraph'==2 {
      local ytitle = "ytitle(Estimated Survival Probability)"
      line `survivals' `survivalLBs' `survivalUBs' Period, lcolor(`linecolors') lwidth(`linewidths') `xtick' `ytick' `xlabel' `ylabel' `ytitle' `options'
      }
    if `msgraph'==4 {
      local ytitle = "ytitle(Estimated Cumulative Event Probability)"
      line `cumevents' `cumeventLBs' `cumeventUBs' Period, lcolor(`linecolors') lwidth(`linewidths') `xtick' `ytick' `xlabel' `ylabel' `ytitle' `options'
      }
         
   }

*Graph both conditional hazard and survival probabilities
   if `msgraph'==3 {
   
*Prepare for different x-axis labeling needs for hazard and survival
    local tempxt="`xtick'"
    local tempxla="`xlabel'"
    local ytitle = "ytitle(Estimated Conditional Hazard Probability)"
    
    local xtick "xt(1(1)`maxl')"
    local xlabel "xla(1(1)`maxl')"
    line `hazards' `hazardLBs' `hazardUBs' Period if Period~=0, lcolor(`linecolors') lwidth(`linewidths') `xtick' `ytick' `xlabel' `ylabel' `ytitle' `options'

    more
    
    local xtick="`tempxt'"
    local xlabel="`tempxla'"
    local xtick "xt(0(1)`maxl')"
    local xlabel "xla(0(1)`maxl')"
    local ytitle = "ytitle(Estimated Survival Probability)"

    line `survivals' `survivalLBs' `survivalUBs' Period, lcolor(`linecolors')  lwidth(`linewidths') `xtick' `ytick' `xlabel' `ylabel' `ytitle' `options'
   }

   restore, preserve 
}
 

end



