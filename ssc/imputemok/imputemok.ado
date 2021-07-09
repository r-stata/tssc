*! version 2.1 24 November 2008
*! Jean-Benoit Hardouin
************************************************************************************************************
* impmok: Imputation of missing data by a Mokken model
*
* Version 1 : November 25, 2006 (Jean-Benoit Hardouin) /*Dichotomous data*/
* Version 2 : June 30, 2008 (Jean-Benoit Hardouin) /*MAX option*/
* Version 2.1 : November 24, 2008 (Jean-Benoit Hardouin) /*correction of a bug with the MAX option*/
*
* Jean-benoit Hardouin, Faculty of Pharmaceutical Sciences - University of Nantes - France
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program : http://anaqol.free.fr
* FreeIRT Project : http://freeirt.free.fr
*
* Copyright 2006, 2008 Jean-Benoit Hardouin
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


program define imputemok , rclass
version 9
syntax varlist(min=2 numeric) [, PREFix(string) max(int 0)]

local nbitems : word count `varlist'
tokenize `varlist'
if `max'==0 {
   local max=`nbitems'
}



tempname p
matrix `p'=J(3,`nbitems',0)
forvalues i=1/`nbitems' {
   qui su ``i''
   if `r(min)'!=0&`r(max)'!=1 {
       di in red "The -impmok- command runs only with dichotomous items"
       error
   }
   local p`i'=r(mean)
   matrix `p'[1,`i']=`i'
}

forvalues place=1/`nbitems' {
   local pmax=0
   local itemax=0
   forvalues i=1/`nbitems' {
      local t=`p'[1,`i']
      if `p`i''>`pmax'&`t'!=0 {
         local pmax=`p`i''
         local itemax=`i'
      }
   }
   matrix `p'[1,`itemax']=0
   matrix `p'[2,`place']=`itemax'
   matrix `p'[3,`place']=`pmax'
}
local liste
forvalues i=1/`nbitems' {
   local t=`p'[2,`i']
   local liste "`liste' ``t''"
   tempname imp`i'
   qui gen `imp`i''`i'=``i''
}
forvalues j=`=`nbitems'-1'(-1)1 {
   local i=`p'[2,`j']
   local suiv=`p'[2,`=`j'+1']
   qui replace `imp`i''`i'=1 if `imp`suiv''`suiv'==1&`imp`i''`i'==.
}
forvalues j=2/`nbitems'{
   local i=`p'[2,`j']
   local prec=`p'[2,`=`j'-1']
   qui replace `imp`i''`i'=0 if `imp`prec''`prec'==0&`imp`i''`i'==.
}
forvalues j=1/`nbitems' {
   local i=`p'[2,`j']
   local suiv=`p'[2,`=`j'+1']
   local prec=`p'[2,`=`j'-1']
   tempname prec0`i' prec1`i'
   qui gen `prec0`i''=0
   qui gen `prec1`i''=0
   if `j'!=1 {
      qui replace `prec0`i''=`prec0`prec''+1 if `imp`prec''`prec'==0
      qui replace `prec0`i''=`prec0`prec'' if `imp`prec''`prec'!=0
      qui replace `prec1`i''=`prec1`prec''+1 if `imp`prec''`prec'==1
      qui replace `prec1`i''=`prec1`prec'' if `imp`prec''`prec'!=1
      qui replace `imp`i''`i'=0 if `prec0`i''!=0&`prec0`i''>=`prec1`i''&`imp`i''`i'==.
   }
}
forvalues j=`nbitems'(-1)1 {
   local i=`p'[2,`j']
   local suiv=`p'[2,`=`j'+1']
   local prec=`p'[2,`=`j'-1']
   tempname suiv0`i' suiv1`i'
   qui gen `suiv0`i''=0
   qui gen `suiv1`i''=0
   if `j'!=`nbitems' {
      qui replace `suiv0`i''=`suiv0`suiv''+1 if `imp`suiv''`suiv'==0
      qui replace `suiv0`i''=`suiv0`suiv'' if `imp`suiv''`suiv'!=0
      qui replace `suiv1`i''=`suiv1`suiv''+1 if `imp`suiv''`suiv'==1
      qui replace `suiv1`i''=`suiv1`suiv'' if `imp`suiv''`suiv'!=1
      qui replace `imp`i''`i'=1 if `suiv0`i''<=`suiv1`i''&`suiv1`i''!=0&`imp`i''`i'==.
   }
}
forvalues j=1/`nbitems' {
   local i=`p'[2,`j']
   qui replace `imp`i''`i'=uniform()<=`p`i'' if `imp`i''`i'==.
   if "`prefix'"=="" {
      local prefix imp
   }
   qui gen `prefix'``i''=`imp`i''`i'
}


tempvar miss
qui egen `miss'=rowmiss(`varlist')
forvalues i=1/`nbitems' {
    qui replace `prefix'``i''=. if ``i''==.&`miss'>`max'
}

end
