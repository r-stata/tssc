*! Version 3.3 16October2012
************************************************************************************************************
* Traces: Traces of items
* Version 3.3: October 16, 2012 /*minor modifications*/
*
* Historic:
* Version 1 (2003-06-29): Jean-Benoit Hardouin
* Version 2 (2003-07-04): Jean-Benoit Hardouin
* version 3 (2003-07-09): Jean-Benoit Hardouin
* Version 3.1 (2005-06-07): Jean-Benoit Hardouin /*small modifications*/
* Version 3.2: May 27, 2007 /*onlyone option*/
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Clinical Research and Subjective Measures in Health Sciences
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@anaqol.org
*
* News about this program :http://www.anaqol.org
* FreeIRT Project website : http://www.freeirt.org
*
* Copyright 2003, 2005, 2007, 2012 Jean-Benoit Hardouin
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*
************************************************************************************************************

program define traces
version 8.0
syntax varlist(numeric min=2) [, Score Test Restscore Logistic CI CUMulative REPFiles(string) SCOREFiles(string) RESTSCOREFiles(string) LOGISTICFile(string) noDraw noDRAWComb REPlace ONLYone(string) THResholds(string) Black]

local nbitems : word count `varlist'
tokenize `varlist'

if "`onlyone'"!=""&"`drawcomb'"!="" { 
   local drawcomb
}

tempvar varscore
qui gen `varscore'=0
label variable `varscore' "Total score"
local scoremax=0
local flag=0

if "`score'"==""&"`restscore'"==""&&"`logistic'"=="" {
   local score="score"
}

forvalues i=1/`nbitems' {
   qui replace `varscore'=`varscore'+``i''
   qui su ``i''
   local modamax`i'=r(max)
   if r(min)!=0 {
      local flag=1
   }
   local scoremax=`scoremax'+`modamax`i''
      if `modamax`i''!=1 {
      local flagbin=0
   }
}


if `flag'==1 {
   di as error "The lower modality of the item must be 0"
   exit
}
if "`flagbin'"!=""&"`logistic'"!="" {
   di as error "The logistic option is not possible with polytomous items"
   exit
}

qui su `varscore'
local maxscore=r(max)

forvalues i=0/`maxscore' {
   qui count if `varscore'==`i'
   local nscore`i'=r(N)
}


global score
global restscore
global logistic

if "`score'"!="" {
   if "`thresholds'"!="" {
   * set trace on
      local nbth:word count `thresholds'
      forvalues t=1/`nbth' {
         local th`t':word `t' of `thresholds'
      }
      tempname label
      local recode 0/`th1'=1 `=`th`nbth''+1'/max=`=`nbth'+1'
      qui label define `label' 1 "0/`th1'",add
      qui label define `label' `=`nbth'+1' "`=`th`nbth''+1'/max",add
      forvalues j=2/`nbth' {
         local recode `recode'  `=`th`=`j'-1''+1'/`th`j''=`j'
         qui label define `label' `j' "`=`th`=`j'-1''+1'/`th`j''",add
      }
      tempname varscore2
      qui gen `varscore2'=`varscore'
      qui recode `varscore' `recode'
      qui label values `varscore' `label'
      local nbgroups=`nbth'+1
      local minimum=1
   }
   else {
      local nbgroups=`maxscore'
      local minimum=0
   }

   forvalues i=1/`nbitems' {
      local y`i'
      forvalues k=1/`modamax`i'' {
         tempvar propscore`i'`k' tmp
         if "`cumulative'"!="" {
            qui gen `tmp'=``i''>=`k'&``i''!=.
            bysort `varscore' : egen `propscore`i'`k''=mean(`tmp')
            label variable `propscore`i'`k'' "Item ``i''>=`k'"
         }
         else {
            qui gen `tmp'=``i''==`k'&``i''!=.
            bysort `varscore' : egen `propscore`i'`k''=mean(`tmp')
            label variable `propscore`i'`k'' "Item ``i''=`k'"
         }
         local y`i'="`y`i'' `propscore`i'`k''"
         local style="solid"
         local color="black"
         local width="medthick"
         if `modamax`i''==1&"`ci'"!="" {
            tempvar icscoreminus icscoreplus
            forvalues l=1/`maxscore' {
               qui count if `varscore'==`l'
               local nscore`l'=r(N)
            }
            qui gen `icscoreminus'=`propscore`i'1'-1.96*sqrt(`propscore`i'1'*(1-`propscore`i'1')/`nscore1')
            qui gen `icscoreplus'=`propscore`i'1'+1.96*sqrt(`propscore`i'1'*(1-`propscore`i'1')/`nscore1')
            label variable `icscoreminus' "Lower 95% confidence interval"
            label variable `icscoreplus' "Upper 95% confidence interval"
            local y`i'="`icscoreminus' `icscoreplus' `propscore`i'1'"
            local style="dash dash solid"
            local color="red red black"
            local width="thin thin medthick"
         }
         if `modamax`i''==1&"`test'"!="" {
            qui regress `propscore`i'1' `varscore'
            local p=Fden(e(df_m),e(df_r),e(F))
            if `p'<0.0001 {
               local note="Test: slope=0, p<0.0001"
            }
            else {
               local p=substr("`p'",1,6)
               local note="Test: slope=0, p=`p'"
            }
         }
      }
      if "``i''"=="`onlyone'"|"`onlyone'"=="" {
         qui graph twoway (line `y`i'' `varscore', clpattern(`style') clcolor(`color') clwidth(`width')) if `varscore'!=0&`varscore'!=`maxscore' , note("`note'") ylabel(0(.25)1) xlabel(`minimum'(1)`nbgroups',valuelabel) name(score`i',replace) title("Trace of the item ``i'' as a function of the score") ytitle("Rate of positive response")  `draw'  areastyle(none)
      }
      global score "$score score`i'"
      if "`scorefiles'"!="" {
         graph save score`i' `repfiles'\\`scorefiles'``i'' ,`replace'
      }
   }
   if "`thresholds'"!="" {
      qui replace `varscore'=`varscore2'
   }
}
if "`restscore'"!="" {
   forvalues i=1/`nbitems' {
      local y`i'
      tempvar restscore`i'
      qui gen `restscore`i''=`varscore'-``i''
      label variable `restscore`i'' "Rest score with respect to the item ``i''"
      if "`thresholds'"!="" {
      * set trace on
         local nbth:word count `thresholds'
         forvalues t=1/`nbth' {
            local th`t':word `t' of `thresholds'
         }
         tempname label
         local recode 0/`th1'=1 `=`th`nbth''+1'/max=`=`nbth'+1'
         qui label define `label' 1 "0/`th1'",add
         qui label define `label' `=`nbth'+1' "`=`th`nbth''+1'/max",add
         forvalues j=2/`nbth' {
            local recode `recode' `=`th`=`j'-1''+1'/`th`j''=`j'
            qui label define `label' `j' "`=`th`=`j'-1''+1'/`th`j''",add
         }

         *di "recode `restscore`i'' `recode'"
         qui recode `restscore`i'' `recode'
         qui label values `restscore`i'' `label'
         local nbgroups=`nbth'+1
         local minimum=1
      }
      else {
         local nbgroups=`maxscore'
         local minimum=0
      }

      forvalues k=1/`modamax`i'' {
         tempvar rtmp proprestscore`i'`k'
         if "`cumulative'"!="" {
            qui gen `rtmp'=``i''>=`k'&``i''!=.
            bysort `restscore`i'': egen `proprestscore`i'`k''=mean(`rtmp')
            label variable `proprestscore`i'`k'' "Item ``i''>=`k'"
         }
         else {
            qui gen `rtmp'=``i''==`k'&``i''!=.
            bysort `restscore`i'': egen `proprestscore`i'`k''=mean(`rtmp')
            label variable `proprestscore`i'`k'' "Item ``i''=`k'"
         }
         local y`i'="`y`i'' `proprestscore`i'`k''"
         local style="solid"
         local color="black"
         local width="medthick"
         if `modamax`i''==1&"`ci'"!="" {
            tempvar icrestscoreminus icrestscoreplus
            qui su `restscore`i''
            local maxrestscore=r(max)
            forvalues l=1/`maxrestscore' {
               qui count if `restscore`i''==`l'
               local nrestscore`i'=r(N)
            }
            qui gen `icrestscoreminus'=`proprestscore`i'1'-1.96*sqrt(`proprestscore`i'1'*(1-`proprestscore`i'1')/`nrestscore`i'')
            qui gen `icrestscoreplus'=`proprestscore`i'1'+1.96*sqrt(`proprestscore`i'1'*(1-`proprestscore`i'1')/`nrestscore`i'')
            label variable `icrestscoreminus' "Lower 95% confidence interval"
            label variable `icrestscoreplus' "Upper 95% confidence interval"
            local y`i'="`icrestscoreminus' `icrestscoreplus' `proprestscore`i'1'"
            local style="dash dash solid"
            local color="red red black"
            local width="thin thin medthick"
         }
         if `modamax`i''==1&"`test'"!="" {
            qui regress `proprestscore`i'1' `varscore'
            local p=Fden(e(df_m),e(df_r),e(F))
            if `p'<0.0001 {
               local note="Test: slope=0, p<0.0001"
            }
            else {
               local p=substr("`p'",1,6)
               local note="Test: slope=0, p=`p'"
            }
         }
      }
      local restscoremax=`scoremax'-`modamax`i''
      if "``i''"=="`onlyone'"|"`onlyone'"=="" {
         *tab `proprestscore`i'1' `restscore`i''
         qui graph twoway (line `y`i'' `restscore`i'', clpattern(`style') clcolor(`color') clwidth(`width')), note("`note'") ylabel(0(0.25)1) xlabel(`minimum'(1)`nbgroups',valuelabel) name(restscore`i',replace) title("Trace of the item ``i'' as a function of the restscore") ytitle("Rate of positive response") `draw'
      }
      global restscore "$restscore restscore`i'"
      if "`restscorefiles'"!="" {
         graph save restscore`i' `repfiles'\\`restscorefiles'``i''  ,`replace'
      }
   }
}
if "logistic"!="" {
   forvalues i=1/`nbitems' {
      qui logistic ``i'' `varscore'
      tempname coef
      matrix `coef'=e(b)
      local pente`i'=`coef'[1,1]
      local intercept`i'=`coef'[1,2]
      tempvar logit`i'
      qui gen `logit`i''=exp(`intercept`i''+`pente`i''*`varscore')/(1+exp(`intercept`i''+`pente`i''*`varscore'))
      label variable `logit`i'' "Item ``i''"
      sort `varscore'
      global logistic "$logistic `logit`i''"
   }
}
if "`drawcomb'"!="" {
   local drawcomb="nodraw"
}

if "`score'"!=""&"`onlyone'"=="" {
   graph combine $score , title("Trace of the items as a function of the score") name(score,replace) `drawcomb'
   if "`scorefiles'"!="" {
      graph save score `repfiles'\\`scorefiles'  ,`replace'
   }
}

if "`restscore'"!=""&"`onlyone'"=="" {
   graph combine $restscore  , title("Trace of the items as a function of the restscores") name(restscore,replace)  `drawcomb'
   if "`restscorefiles'"!="" {
      graph save restscore `repfiles'\\`restscorefiles'   ,`replace'
   }
}
if "`logistic'"!="" {
   graph twoway (line $logistic `varscore'), ylabel(0(0.25)1) xlabel(0(1)`nbitems') title("Logistic traces") ytitle("") name(logistic,replace) `drawcomb'
   if "`logisticfile'"!="" {
      graph save logistic `repfiles'\\`logisticfile'   ,`replace'
   }
}


end


