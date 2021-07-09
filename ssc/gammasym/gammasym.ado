************************************************************************************************************
* Gammasym : Symmetric gamma function
* Version 2: February 1, 2004
*
* Historic:
* Version 1 (2004-01-29): Jean-Benoit Hardouin
*
* Jean-benoit Hardouin, Regional Health Observatory of Orléans - France
* jean-benoit.hardouin@neuf.fr
*
* News about this program : http://anaqol.free.fr
* FreeIRT Project : http://freeirt.free.fr
*
* Copyright 2004 Jean-Benoit Hardouin
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


program define gammasym,rclass
version 8
syntax anything


local nbgroups:word count `anything'

tokenize `anything'
local list
forvalues i=1/`nbgroups' {
          local tmp=-``i''
          local list "`list' `tmp'"
}

tokenize `list'


local gamma1r0=1
local gamma1r1=exp(`1')
forvalues i=2/`nbgroups' {
	forvalues j=0/`i' {
		local gamma`i'r`j'=0
		if 0<=`j'&`j'<=`=`i'-1' {
			local gamma`i'r`j'=`gamma`i'r`j''+`gamma`=`i'-1'r`j''
		}
		if 1<=`j'&`j'<=`i' {
			local gamma`i'r`j'=`gamma`i'r`j''+exp(``i'')*`gamma`=`i'-1'r`=`j'-1''
		}
	}
}

forvalues r=0/`nbgroups' {
	return scalar gamma`r'= `gamma`nbgroups'r`r''
}
end


