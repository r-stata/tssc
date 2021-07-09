*! version 1  5may2005
************************************************************************************************************
* gausshermite : Estimate an integral of the form |f(x)g(x/mu,sigma)dx where g(x/mu,sigma) is the distribution function
* of the gaussian distribution of mean mu and variance sigma^2 by Gauss Hermite quadratures
*
* Version 1: May 5, 2005
*
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


program define gausshermite,rclass
version 7
syntax anything [, Sigma(real 1) MU(real 0) Nodes(integer 12) Display]
tempfile gauss
qui capture save `gauss',replace
local save=0
if _rc==0 {
   qui save `gauss',replace
   local save=1
}

tokenize `anything'

drop _all
qui set obs 100
tempname noeuds poids
qui ghquadm `nodes' `noeuds' `poids'
qui gen x=.
qui gen poids=.
forvalues i=1/`nodes' {
   qui replace x=`noeuds'[1,`i'] in `i'
   qui replace poids=`poids'[1,`i'] in `i'
}
qui replace x=x*(sqrt(2)*`sigma')+`mu'

qui gen f=poids/sqrt(_pi)*(`1')
qui su f
return scalar int=r(sum)

if "`display'"!="" {
   di in green "int_R (`1')g(x/sigma=`sigma')dx=" in yellow %12.8f `r(sum)'
}
drop _all
if `save'==1 {
   qui use `gauss',clear
}
end


