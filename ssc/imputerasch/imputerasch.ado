*! version 2 30 June 2008
*! Jean-Benoit Hardouin
************************************************************************************************************
* imputerasch: Imputation of missing data by a Rasch model
*
* Version 1 : November 25, 2006 (Jean-Benoit Hardouin) /*Dichotomous data*/
* Version 1.1 : January 26, 2007 (Jean-Benoit Hardouin) /*Correction of a bug with the Binomial option*/
* Version 2 : June 30, 2008 (Jean-Benoit Hardouin) /*norandom option, max option*/
*
* Jean-benoit Hardouin, Faculty of Pharmaceutical Sciences - University of Nantes - France
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program : http://www.anaqol.org
* FreeIRT Project : http://www.freeirt.org
*
* Copyright 2006-2008 Jean-Benoit Hardouin
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


program define imputerasch
version 9
syntax varlist(min=2 numeric) [, PREFix(string) noBINomial noRANDom SAVEProba(string) NBITeration(integer 1) DETails MAX(int 0) ]
preserve
qui ds
local order=r(varlist)
local nbitems : word count `varlist'
tokenize `varlist'

if `max'==0 {
   local max=`nbitems'
}

if "`random'"!="" {
   local binomial nobinomial
}

if "`binomial'"==""&`nbiteration'!=1 {
   local binomial nobinomial
   di in green "You must use the {hi:norandom} option when you use iterative process. This option is assumed."
}

if `nbiteration'!=1 {
   di in ye  "Iteration : 1"
}

tempvar lt0 lt1 score id item lt name
qui gen `id'=_n
qui egen `score'=rowtotal(`varlist')
forvalues i=1/`nbitems' {
   qui rename ``i'' `name'`i'
}

qui reshape  long `name' ,i(`id') j(`item')
forvalues i=1/`nbitems' {
   qui gen ``i''=`item'==`i'
}
qui gllamm  `name' `varlist' ,family(bin) nocons link(logit) i(`id') it(1)
qui gllapred `lt' ,u
qui bysort `id':egen `lt'=min(`lt'm1)
drop `lt's1 `lt'm1
tempname diff
matrix `diff'=e(b)
drop `varlist'
qui reshape  wide `name' ,i(`id') j(`item')
forvalues i=1/`nbitems' {
   qui rename `name'`i' ``i''
   tempvar imp`i'
   local diff`i'=`diff'[1,`i']
   qui gen `imp`i''=exp(`lt'-`diff`i'')/(1+exp(`lt'-`diff`i''))
   if "`saveproba'"!="" {
      qui gen `saveproba'``i''=`imp`i''
   }
   if "`binomial'"!="" {
       qui replace `imp`i''=round(`imp`i'')
   }
   else {
       qui replace `imp`i''=uniform()<`imp`i''
   }
}


restore,not
forvalues i=1/`nbitems' {
   qui replace `imp`i''=``i'' if ``i''!=.
   if "`prefix'"=="" {
      local prefix imp
   }
   qui gen `prefix'``i''=`imp`i''
}

if "`details'"!="" {
  forvalues i=1/`nbitems' {
     qui count if ``i''==.
     local nbmiss`i'=r(N)
     di in ye "``i'':" in gr " Number of missing data: " in ye "`nbmiss`i''"
  }
}
if `nbiteration'>1 {
   local flag=0
   local it=2
   tempname p new
   while `flag'!=1&`it'<=`nbiteration' {
      di in ye "Iteration : `it'"
      imputerasch `prefix'`1'-`prefix'``nbitems'', savep(`p') prefix(`new') nobin
      local flag=1
      forvalues i=1/`nbitems' {
         qui replace `new'`prefix'``i''=round(`p'`prefix'``i'') if ``i''==.
         qui corr `prefix'``i'' `new'`prefix'``i''
         local rho=round(r(rho)*1000000)
         qui count if `prefix'``i''==`new'`prefix'``i''&``i''==.
         qui count if ``i''==.
         local nbmiss`i'=r(N)
         local coher=r(N)
         local txcoher=`coher'/`nbmiss`i''*100
         di in ye "``i'':" in gr " Coherence rate between iterations `it' and `=`it'-1': " in ye %6.2f `txcoher' in gr "%"
         if int(`txcoher')!=100 {
            local flag=0
         }
         qui replace `prefix'``i''=`new'`prefix'``i''
      }
      drop `p'`prefix'`1'-`p'`prefix'``nbitems'' `new'`prefix'`1'-`new'`prefix'``nbitems''
      local ++it
   }
}

tempvar miss
qui egen `miss'=rowmiss(`varlist')
forvalues i=1/`nbitems' {
   qui replace `prefix'``i''=. if ``i''==.&`miss'>`max'
}

end
