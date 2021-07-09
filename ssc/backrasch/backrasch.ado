*! version 2 23may2005
************************************************************************************************************
* Backrasch : Backward procedure under a Rasch model
* version 2 : may 23, 2005
*
* Historic
* Version 1 (2004-02-13) : Jean-Benoit Hardouin
*
* Needed modules :
* raschtestv7 version 7.2.1 (http://freeirt.free.fr)
* gammasym version 2.1 (http://freeirt.free.fr)
* gausshermite version 1 (http://freeirt.free.fr)
* geekel2d version 4.1 (http://freeirt.free.fr)
* ghquadm (findit ghquadm)
* gllamm version 2.3.10 (ssc describe gllamm)
* gllapred version 2.3.2 (ssc describe gllapred)
* elapse (ssc describe elapse)
*
* Jean-benoit Hardouin, Regional Health Observatory of Orléans - France
* jean-benoit.hardouin@orscentre.org
*
* News about this program : http://anaqol.free.fr
* FreeIRT Project : http://freeirt.free.fr
*
* Copyright 2004-2005 Jean-Benoit Hardouin
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

program define backrasch , rclass
version 8.0
syntax varlist(min=3 numeric) , [p(real 0.05) Method(string) Test(string) NBSCales(integer 1) nodetail noAUTOGroup]
local nbitems : word count `varlist'
tokenize `varlist'
preserve


tempfile saveraschtest
qui save `saveraschtest'

local autogroup2
if "`autogroup'"=="" {
    local autogroup2 autogroup
}
if "`method'"=="" {
    local method cml
}
if "`test'"=="" {
    local test R
}

tempname select
matrix `select'=J(1,`nbitems',0)
local dim=1
local less3items=0

while `dim'<=`nbscales'&`less3items'!=1 {
	di
	di in green _col(25) "subscale : " in yellow `dim'
	di in green _col(25) "{hline 12}"
	local nobaditem=0
	while `nobaditem'!=1 {
		local varlistscale
		local nbitemsscale=0
		forvalues i=1/`nbitems' {
			if `select'[1,`i']==0 {
				local nbitemsscale=`nbitemsscale'+1
				local ssitem`nbitemsscale'=`i'
				local varlistscale `varlistscale' ``i''
			}
		}

		if `nbitemsscale'<3 {
			if "`detail'"=="" {
				di in green "The " in yellow "`dim'th " in green "sub-scale can not be created, because there is less than three items remaining"
			}
			local `less3items'=1
			local dim=`dim'-1
			continue, break
		}
		else {
			qui raschtestv7 `varlistscale',m(`method') t(`test') `autogroup2'
			tempname itemFit
			matrix `itemFit'=r(itemFit)
			local minp=`p'
			local deleteitem
			local nobaditem=1
			forvalues i=1/`nbitemsscale' {
				if `itemFit'[`i',3]<`minp' {
					local minp=`itemFit'[`i',3]
					local deleitem=`i'
					local rowdeleteitem=`ssitem`i''
					local nobaditem=0
				}
			 }
			if `nobaditem'==1 {
				if "`detail'"=="" {
					di in green "No more item to remove of the scale " in yellow "`dim'"
				}
				continue, break
			}
			else {
				if "`detail'"=="" {
					di in green "The item " in yellow "``rowdeleteitem'' " in green "is removed of the scale " in yellow "`dim'" in green " (p=" in yellow %6.4f `minp' in green ")"
				}
				matrix `select'[1,`rowdeleteitem']=-1
			}
		}
	}

	if `nbitemsscale'>=3 {
		forvalues i=1/`nbitems' {
			if `select'[1,`i']==0 {
				matrix `select'[1,`i']==`dim'
			}
			if `select'[1,`i']==-1 {
				matrix `select'[1,`i']==0
			}
		}
		local scale`dim'
		forvalues i=1/`nbitems' {
			if `select'[1,`i']==`dim' {
				local scale`dim' "`scale`dim'' ``i''"
			}
		}
		if "`scale`dim''"!="" {
			di
			di in green _col(4) "Number of selected items : " in yellow "`nbitemsscale'"
			raschtestv7 `scale`dim'',m(`method') t(`test') `autogroup2'
			di
			di _dup(70) "-"
		}


		local dim=`dim'+1
	}
	if  `nbitemsscale'<3{
		forvalues i=1/`nbitems' {
			if `select'[1,`i']==-1 {
				matrix `select'[1,`i']==0
			}
		}
		continue, break
	}

}

matrix colnames `select'=`varlist'
matrix rownames `select'=scale

return matrix selection `select'
end

