*! version 1.4  27december2005
*! Jean-Benoit Hardouin
*
************************************************************************************************************
* Stata program : genscore
* Generate scores from a list of variables
* Version 1.4 : December 27, 2005 /*corrects a bug with the mean option*/
*
* Historic
* Version 1.2 (2005-10-01): Jean-Benoit Hardouin
* Version 1.3 (2005-12-09): Jean-Benoit Hardouin /*centered and standardized options*/
*
* Jean-benoit Hardouin, Regional Health Observatory of Orléans - France
* jean-benoit.hardouin@orscentre.org
*
* News about this program : http://anaqol.free.fr
* FreeIRT Project : http://freeirt.free.fr
*
* Copyright 2005 Jean-Benoit Hardouin
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

program define genscore
version 7.0
syntax varlist(min=1) [if] [in] [fweight] [, SCore(namelist min=1 max=1) CENTered STAndardized MEan MIssing(string) REPlace]

marksample touse
if "`score'"=="" {
   local score score
}

local nbitems:word count `varlist'
tokenize `varlist'

if "`missing'"=="" {
   local missing .
}
capture confirm new variable  `score'
quietly {
   if _rc!=0&"`replace"=="" {
      di in red "The variable {hi:`score'} already defined"
      exit 198
   }
   else if _rc!=0&"`replace"!="" {
      drop `score'
   }
   forvalues i=1/`nbitems' {
      tempname var`i'
      local sd=1
      local moy=0
      if "`standardized'"!=""|"`centered'"!="" {
         su ``i'' [`weight'`exp']
         local moy=r(mean)
         local sd=r(sd)
         if "`standardized'"=="" {
            local sd=1
         }
      }
      gen `var`i''=(``i''-`moy')/`sd'
   }
   gen `score'=0 if `touse'
   forvalues i=1/`nbitems' {
      replace `score'=`score'+`var`i'' if `touse'
      replace `score'=.  if `touse'&``i''==`missing'&``i''>=.
   }
   if "`mean'"!="" {
      replace `score'=`score'/`nbitems'  if `touse'
   }
}

end

