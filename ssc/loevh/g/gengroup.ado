*! version 1.2  28october2009
*! Jean-Benoit Hardouin
*
************************************************************************************************************
* Stata program : genscore
* Generate groups of individals based on the values of an ordinal variable
*
* Historic
* Version 1 (2007-05-27): Jean-Benoit Hardouin
* Version 1.1 (2007-06-21): Jean-Benoit Hardouin /*Correction of a bug without -if- */
* Version 1.2 (2009-10-28): Jean-Benoit Hardouin /*-continuous- option*/
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Clinical Research and Subjective Measures in Health Sciences
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program :http://www.anaqol.org
* FreeIRT Project website : http://www.freeirt.org
*
* Copyright 2007, 2009 Jean-Benoit Hardouin
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

program define gengroup ,rclas
version 7.0
syntax varlist(numeric min=1 max=1) [if/] [in]  [, NEWvariable(namelist min=1 max=1)  REPlace MINsize(integer 30) DETails CONTinuous]
tempvar sort
qui gen `sort'=_n

if "`if'"!="" {
   local if2="if `if'"
   local if3="&(`if')"
}

marksample touse
if "`newvariable'"=="" {
   local newvariable group
}

capture confirm new variable  `newvariable'
if _rc!=0&"`replace'"=="" {
   di in red "The variable {hi:`newvariable'} is already defined"
   exit 198
}
else if _rc!=0&"`replace"!="" {
   qui drop `newvariable'
}

if "`continuous'"=="" {
   qui gen `newvariable'=`varlist' `if2' `in'

   qui su `newvariable' `if2' `in'
   local min=r(min)
   local max=r(max)

   local groupmin=`min'
   local groupmax=`min'-1
   local numgroup=1
   local recode
   local list

   while (`groupmin'<`max'+1) {
      local n=0
      while (`n'<`minsize') {
         local groupmax=`groupmax'+1
         qui count if `newvariable'>=`groupmin'&`newvariable'<=`groupmax'`if3' `in'
         local n=r(N)
         if `groupmax'>`max' {
            local n=`minsize'+1
            local numgr
         }
      }
      if `groupmax'<`max' {
         local list `list' `groupmax'
      }
      local recode `recode' `groupmin'/`groupmax'=`numgroup'
      if "`details'"!="" {
         di in gr "Group " in ye `numgroup' in gr ": Values " in ye `groupmin' in gr " to " in ye `groupmax'
      }
      local groupmin=`groupmax'+1
      local groupmax=`groupmin'-1
      local numgroup=`numgroup'+1
   }

   qui recode `newvariable' `recode' `if2' `in'
   qui count if `newvariable'==`numgroup'-1`if3' `in'
   local dernier=r(N)
   if `dernier'<`minsize' {
      qui recode `newvariable' `=`numgroup'-1'=`=`numgroup'-2' `if2' `in'
      if "`details'"!="" {
         di in gr "The group " in ye `=`numgroup'-1' in gr " is recoded in " in ye `=`numgroup'-2'
      }
      local list2
      forvalues i=1/`=`numgroup'-3' {
         local w:word `i' of `list'
         local list2 `list2' `w'
      }
      local list `list2'
   }
}
else {
   local list
   qui sort `varlist'
   qui tempvar sort2
   qui gen `sort2'=_n
   qui gen `newvariable'=0 `if2' `in'
   qui count `if2' `in'
   local nbind=r(N)
   local nbused=0
   tempvar used
   qui gen `used'=0 `if2' `in'
   local num=1
   while (`=`nbused'+`minsize''<`nbind'+1) {
      qui su `varlist' if `sort2'==`=`nbused'+`minsize''`if3' `in'
      local mean=r(mean)
      local list `list' `mean'
      local mean=round(`mean',0.0000001)+0.0000001
      if "`details'"!="" {
         di in gr "The values inferior to " in ye `mean' in gr " are recoded in " in ye `num'
      }
      qui replace `newvariable'=`num' if `varlist'<=`mean'&`used'==0
      qui replace `used'=1 if `newvariable'!=0&`newvariable'!=.
      qui count if `used'==1
      local nbused=`r(N)'
      local num=`num'+1
   }
   qui replace `newvariable'=`num'-1 if `newvariable'==0
   qui sort `sort'
}
return local list `list'
end
