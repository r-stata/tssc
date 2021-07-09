*! version 2.4 3 May 2013
*! Jean-Benoit Hardouin
************************************************************************************************************
* imputeitems: Imputation of missing data of binary items
*
* Version 1 : November 25, 2006 (Jean-Benoit Hardouin) /*Dichotomous data*/
* Version 1.1 : January 26, 2007 (Jean-Benoit Hardouin) /*Correction of a bug with the BIL method*/
* Version 1.2 : March 9, 2007 (Jean-Benoit Hardouin) /*IF*/
* Version 2 : June 30, 2008 (Jean-Benoit Hardouin) /*new names of the methods, MAX option*/
* Version 2.1 : December 3, 2008 (Jean-Benoit Hardouin) /*correction of a bug with the MAX option*/
* Version 2.2 : January 28, 2013 (Jean-Benoit Hardouin) /*noround option*/
* Version 2.3 : February 19, 2013 (Jean-Benoit Hardouin) /*polytomous items with PMS method*/
* Version 2.4 : May 3, 2013 (Jean-Benoit Hardouin) /*minor correction*/
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Pharmacoepidemiology and Subjective Measures in Health Sciences  (UPRES EA 4275 SPHERE)
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@anaqol.org
*
* News about this program :http://www.anaqol.org
*
* Copyright 2006-2008,2013 Jean-Benoit Hardouin
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
************************************************************************************************************/


program define imputeitems
version 9
syntax varlist(min=2 numeric) [if/] [, PREFix(string) METHod(string) RANDom max(int -1) noround]

if "`if'"=="" {
   local if=1
   local ifif
}
else {
   local ifif if `if'
}

*di "IF : `if' `ifif'"

local nbitems : word count `varlist'
tokenize `varlist'

if `max'==-1 {
   local max=`nbitems'
}

if "`method'"=="" {
   local method pms
}
forvalues i=1/`nbitems' {
   qui su ``i'' `ifif'
   if `r(min)'!=0&(`r(max)'!=1&"`method'"!="pms") {
       di in red "The {hi:imputeqol} command runs only with dichotomous items"
       error
   }
   local p`i'=r(mean)
}

if "`method'"!="pms"&"`method'"!="ims"&"`method'"!="cim"&"`method'"!="ics"&"`method'"!="bip"&"`method'"!="bil"&"`method'"!="bic"&"`method'"!="bii"&"`method'"!="log"&"`method'"!="worst" {
   di in red "The method option is unknow (choose among pms, ims, cim, ics, log and worst)"
   error
}
forvalues i=1/`nbitems'{
   qui su ``i'' `ifif'
   local mean`i'=r(mean)
}

if "`method'"=="pms"&"`random'"!="" {
   local method bip
}
else if "`method'"=="ims"&"`random'"!="" {
   local method bii
}
else if "`method'"=="log"&"`random'"!="" {
   local method bil
}
else if "`method'"=="cim"&"`random'"!="" {
   local method bic
}
else if ("`method'"=="ics"|"`method'"=="worst")&"`random'"!="" {
   di in green "The random process is not available with the {hi:ics} or {hi:worst} methods. The {hi:random} option is ignored."
   local random
}


forvalues i=1/`nbitems' {
   tempvar imp`i' tmp`i'
   if "`method'"=="pms"|"`method'"=="bip"|"`method'"=="cim"|"`method'"=="bic" {
      qui egen `imp`i''=rowtotal(`varlist') `ifif'
      qui egen `tmp`i''=rownonmiss(`varlist') `ifif'
      qui replace `imp`i''=`imp`i''/`tmp`i'' `ifif'
      qui replace `imp`i''=``i'' if ``i''!=.&`if'
      if "`method'"=="pms"&"`round'"=="" {
          qui replace `imp`i''=round(`imp`i'') `ifif'
      }
      else if "`method'"=="bip" {
          qui replace `imp`i''=uniform()<`imp`i'' `ifif'
      }
      else if "`method'"=="cim"|"`method'"=="bic"{
         qui replace `imp`i''=`imp`i''*`tmp`i''*`mean`i'' `ifif'
         qui replace `tmp`i''=0 `ifif'
         forvalues j=1/`nbitems' {
            qui replace `tmp`i''=`tmp`i''+`mean`j'' if ``j''!=.&`if'
         }
         qui replace `imp`i''=`imp`i''/`tmp`i'' `ifif'
         qui replace `imp`i''=1 if `imp`i''>1&`imp`i''!=.&`if'
         qui replace `imp`i''=0 if `imp`i''<0&`imp`i''!=.&`if'
         if "`method'"=="cim"&"`round'"=="" {
             qui replace `imp`i''=round(`imp`i'') `ifif'
         }
         else if "`method'"=="bic" {
             qui replace `imp`i''=uniform()<`imp`i'' `ifif'
         }
      }
   }
   else if "`method'"=="ims"|"`method'"=="bii" {
      qui gen `imp`i''=`mean`i'' `ifif'
      if "`method'"=="ims"&"`round'"=="" {
         qui replace `imp`i''=round(`imp`i'') `ifif'
      }
      else if "`method'"=="bii" {
         qui replace `imp`i''=uniform()<`imp`i'' `ifif'
      }
   }
   else if "`method'"=="ics" {
      local item=0
      local corrmax=-2
      forvalues j=1/`nbitems' {
         if `i'!=`j' {
            qui corr ``i'' ``j'' `ifif'
            if r(rho)>`corrmax'&r(rho)!=. {
               local item `j'
               local corrmax=r(rho)
            }
         }
      }
      di "A missing value for the item ``i'' is replaced by the value of the item `item'"
      qui gen `imp`i''=``i'' `ifif'
      qui replace `imp`i''=``item'' if ``i''==.&`if'
   }
   else if "`method'"=="log"|"`method'"=="bil" {
      local liste`i'
      forvalues j=1/`nbitems' {
         if `i'!=`j' {
            local liste`i' `liste`i'' ``j''
         }
      }
      qui sw ,pr(0.05): logit ``i'' `liste`i'' `ifif'
      *local select  :colnames e(b)
      local select=substr("`:colnames e(b)'",1,length("`:colnames e(b)'")-5)
      qui logit ``i'' `select' `ifif'
      qui predict `imp`i'' `ifif'
      if "`method'"=="log"&"`round'"=="" {
          qui replace `imp`i''=round(`imp`i'') if `imp`i''!=.&`if'
      }
      else if "`method'"=="bil" {
          qui replace `imp`i''=uniform()<`imp`i'' if `imp`i''!=.&`if'
      }
   }
   else if "`method'"=="worst" {
      qui gen `imp`i''=0  `ifif'
   }
}
forvalues i=1/`nbitems' {
   qui replace `imp`i''=``i'' if ``i''!=.&`if'
   if "`prefix'"=="" {
      local prefix imp
   }
   qui gen `prefix'``i''=`imp`i'' `ifif'
}

tempvar miss
qui egen `miss'=rowmiss(`varlist')
forvalues i=1/`nbitems' {
   qui replace `prefix'``i''=. if ``i''==.&`miss'>`max'
}

end
