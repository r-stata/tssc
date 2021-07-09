*! Delta version 1.5 - 5 March 2008
*! Jean-Benoit Hardouin
************************************************************************************************************
* DELTA: delta coefficient
* Version 1.5: March 5, 2008
*
* Historic
* Version 1 (2007-05-21): Jean-Benoit Hardouin
* Version 1.1 (2007-05-22): Jean-Benoit Hardouin /* if in and possibility to use the score*/
* Version 1.2 (2007-05-22): Jean-Benoit Hardouin /*bug when a score is missing*/
* Version 1.3 (2007-06-16): Jean-Benoit Hardouin /*change in the options*/
* Version 1.4 (2007-07-03): Jean-Benoit Hardouin /*correct a bug in the options*/
* Version 1.5 (2008-03-05): Jean-Benoit Hardouin /*correct a bug in the ci option*/
*
* Jean-benoit Hardouin, Faculty of Pharmaceutical Sciences - University of Nantes - France
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program : http://www.anaqol.org
* FreeIRT Project : http://www.freeirt.org
*
* Copyright 2007-2008 Jean-Benoit Hardouin
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

program define delta , rclass
version 7.0
syntax varlist(min=1 numeric) [if] [in] [,ci(integer 0) noDots  MINscore(int 0) MAXscore(int 0)]

preserve
tempfile deltafile
qui save `deltafile'
if "`if'"!=""|"`in'"!="" {
   qui keep `if' `in'
}

local nbitems:word count `varlist'
tokenize `varlist'

local scoremin=`minscore'
local scoremax=`maxscore'



tempvar score
if `nbitems'==1&`scoremax'==0 {
   di in red "If you indicate only the score variable, you must define the {cmd:scoremax} option"
   error 198
}
else if `nbitems'==1&`scoremax'!=0 {
   qui gen `score'=`varlist'
}
else {
   qui genscore `varlist',score(`score')
}
qui drop if `score'==.
qui count
local nbind=r(N)

if `scoremax'==0 {
   qui su `score'
   local scoremax=r(max)
}

tempname error
gen `error'=`score'<`scoremin'|`score'>`scoremax'
qui count if `error'==1
local err=r(N)
if `err'!=0 {
   di in red "`err' individuals has(have) a score inferior to `scoremin' or superior to `scoremax'"
   error 198
}

local sumsqscore=0
forvalues i=`scoremin'/`scoremax' {
   qui count if `score'==`i'
   local score`i'=r(N)
   local sumsqscore=`sumsqscore'+`score`i''^2
}
local delta=(1+`scoremax')*(`nbind'^2-`sumsqscore')/(`nbind'^2*`scoremax')

di in green "Range of the scores : " in ye `scoremin' in gr "/" in ye `scoremax'
di in green "Number of used individuals : " in ye `nbind'

if `ci'!=0 {
   bootstrap delta=r(delta), reps(`ci') nowarn noheader nolegend `dots': delta `varlist' ,minscore(`scoremin') maxscore(`scoremax')
}
else {
   display in green "Delta=  " in yellow %8.6f `delta'
}
return scalar delta=`delta'
qui use `deltafile',clear
restore,not

end
