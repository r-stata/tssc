************************************************************************************************************
* DETECT: detect, Iss and R indexes
* Version 3.1: May 13, 2004
*
* Historic
* Version 1 (2003-06-20): Jean-Benoit Hardouin
* Version 2 (2004-01-18): Jean-Benoit Hardouin
* Version 3 (2004-01-26): Jean-Benoit Hardouin
*
* Jean-benoit Hardouin, Regional Health Observatory of Orléans - France
* jean-benoit.hardouin@neuf.fr
*
* News about this program : http://anaqol.free.fr
* FreeIRT Project : http://freeirt.free.fr
*
* Copyright 2003, 2004 Jean-Benoit Hardouin
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

program define detect , rclass
version 7.0
syntax varlist(min=2 numeric), PARTition(numlist integer >0) [noSCOres noRESTscores]

local nbitemstest=0
tokenize `partition'
local Q:word count `partition'
local firstitem=0
local dim0=1
forvalues i=1/`Q' {
	local dim`i'=``i''
	local firstitem`i'=`firstitem`=`i'-1''+`dim`=`i'-1''
	local nbitemstest=`nbitemstest'+`dim`i''
	tempvar score`i'
	qui gen `score`i''=0
	forvalues j=`firstitem`i''/`=`firstitem`i''+`dim`i''-1' {
		local item`j': word `j' of `varlist'
		qui replace `score`i''=`score`i''+`item`j''
	}
}



local nbitems:word count `varlist'
tokenize `varlist'

if `nbitems'!=`nbitemstest' {
	di in red "The sum of the numbers of items in all the dimensions is different of the total number of items precised in varlist"
exit
}

tempname Corrscores Corrrestscores

matrix define `Corrscores'=J(`nbitems',`Q',0)
matrix define `Corrrestscores'=J(`nbitems',`Q',0)


forvalues i=1/`nbitems' {
	forvalues j=1/`Q' {
		tempvar restscore`i's`j'
		qui gen `restscore`i's`j''=`score`j''-``i''
		qui corr ``i'' `score`j''
		local corr`i's`j'=r(rho)
		qui corr ``i'' `restscore`i's`j''
		local corr`i'rs`j'=r(rho)
		matrix `Corrscores'[`i',`j']=`corr`i's`j''
		matrix `Corrrestscores'[`i',`j']=`corr`i'rs`j''
	}
}


qui count
local nbind=r(N)

tempvar score
qui gen `score'=0
forvalues i=1/`nbitems' {
	qui replace `score'=`score'+``i''
}

forvalues i=1/`nbitems' {
	local tmp=`i'+1
	forvalues j=`tmp'/`nbitems' {
		tempvar restscorei`i'j`j'
		qui gen `restscorei`i'j`j''=`score'-``i''-``j''
	}
}

forvalues k=0/`nbitems'{
	tempname Tcov`k'
	qui count if `score'==`k'
	local n`k'=r(N)
	if `n`k''>1 {
	   qui matrix accum `Tcov`k''=`varlist' if `score'==`k',nocons dev
	}
	else {
           matrix `Tcov`k''=J(`nbitems',`nbitems',0)
        }
	if `n`k''!=0 {
		matrix `Tcov`k''=`Tcov`k''/`n`k''
	}
}


forvalues i=1/`nbitems'{
	local tmp=`i'+1
	forvalues j=`tmp'/`nbitems' {
		local tmp=`nbitems'-2
		forvalues k=0/`tmp' {
			tempname Rcovi`i'j`j'k`k'
			qui count if `restscorei`i'j`j''==`k'
			local ni`i'j`j'k`k'=r(N)
                        if `ni`i'j`j'k`k''>1 {
			   qui matrix accum `Rcovi`i'j`j'k`k''=`varlist' if `restscorei`i'j`j''==`k',nocons dev
			}
			else {
                           matrix  `Rcovi`i'j`j'k`k''=J(`nbitems',`nbitems',0)
                        }
                        if `ni`i'j`j'k`k''!=0 {
				matrix `Rcovi`i'j`j'k`k''=`Rcovi`i'j`j'k`k''/`ni`i'j`j'k`k''
			}
		}
	}
}


tempname delta
matrix `delta'=J(`nbitems',`nbitems',-1)

local debut=1
local fin=0
forvalues i=1/`Q' {
	local fin=`fin'+`dim`i''
	forvalues j=`debut'/`fin' {
		forvalues k=`debut'/`fin' {
			matrix `delta'[`j',`k']=1
		}
	}
	local debut=`debut'+`dim`i''
}

tempname Tcov Rcov Covfin Issm Abscov

matrix  `Tcov'=J(`nbitems',`nbitems',0)
matrix  `Rcov'=J(`nbitems',`nbitems',0)
forvalues k=0/`nbitems' {
	matrix `Tcov'=`Tcov'+`Tcov`k''*`n`k''
}
forvalues i=1/`nbitems'{
	local tmp=`i'+1
	forvalues j=`tmp'/`nbitems' {
		local tmp=`nbitems'-2
		forvalues k=0/`tmp' {
			matrix `Rcov'[`i',`j']=`Rcov'[`i',`j']+`Rcovi`i'j`j'k`k''[`i',`j']*`ni`i'j`j'k`k''
			matrix `Rcov'[`j',`i']=`Rcov'[`i',`j']
		}
	}
}


matrix  `Covfin'=J(`nbitems',`nbitems',0)
matrix  `Issm'=J(`nbitems',`nbitems',0)
matrix  `Abscov'=J(`nbitems',`nbitems',0)
forvalues i=1/`nbitems' {
	forvalues j=1/`nbitems' {
		matrix `Covfin'[`i',`j']=(`Tcov'[`i',`j']+`Rcov'[`i',`j'])/2*`delta'[`i',`j']
		matrix `Issm'[`i',`j']=sign(`Tcov'[`i',`j']+`Rcov'[`i',`j'])*`delta'[`i',`j']
		matrix `Abscov'[`i',`j']=abs(`Tcov'[`i',`j']+`Rcov'[`i',`j'])/2
	}
}

local somme=0
local Iss=0
local R=0
forvalues i=1/`nbitems' {
	local tmp=`i'+1
	forvalues j=`tmp'/`nbitems' {
		local somme=`somme'+`Covfin'[`i',`j']
		local Iss=`Iss'+`Issm'[`i',`j']
		local R=`R'+`Abscov'[`i',`j']
	}
}
local DETECT=`somme'*2/(`nbind'*`nbitems'*(`nbitems'-1))
local Iss=`Iss'*2/(`nbitems'*(`nbitems'-1))
local R=`DETECT'/(`R'*2/(`nbind'*`nbitems'*(`nbitems'-1)))


di 
di in green _col(20)  "DETECT : " as result %5.4f `DETECT'
di in green _col(23)  "Iss : " as result %5.4f `Iss'
di in green _col(25)  "R : " as result %5.4f `R'

di 

if "`scores'"=="" {
	di _col(5) in green "Correlations Items-Scores"
	di in green _col(5) "{hline 25}"
	di
	di in green _col(5) "Items"  _continue
	local col=10
	forvalues q=1/`Q' {
		local col=`col'+10
		di in green _col(`col') "dim `q'" _continue
	}
	di
	local length=`Q'*10+10
	di in green _col(5) "{hline `length'}"
	forvalues i=1/`nbitems' {
		forvalues q=2/`Q' {
			if `i'==`firstitem`q'' {
				di _col(5) in green _dup(`length') "-" 
			}
		}
		di in green _col(5) "``i''" _continue
		local col=5
		forvalues q=1/`Q' {
			local col=`col'+10
			di in yellow _col(`col') %10.4f `corr`i's`q'' _continue
		}
		di
	}
	di in green _col(5) "{hline `length'}"
	di
}


if "`restscore'"=="" {
	di _col(5) in green "Correlations Items-Rest-Scores"
	di in green _col(5) "{hline 30}"
	di
	di in green _col(5) "Items"  _continue
	local col=10
	forvalues q=1/`Q' {
		local col=`col'+10
		di in green _col(`col') "dim `q'" _continue
	}
	di
	local length=`Q'*10+10
	di in green _col(5) "{hline `length'}"
	forvalues i=1/`nbitems' {
		forvalues q=2/`Q' {
			if `i'==`firstitem`q'' {
				di _col(5) in green _dup(`length') "-" 
			}
		}
		di in green _col(5) "``i''" _continue
		local col=5
		forvalues q=1/`Q' {
			local col=`col'+10
			di in yellow _col(`col') %10.4f `corr`i'rs`q'' _continue
		}
		di
	}
	di in green _col(5) "{hline `length'}"
	di
}
	
local namesdim
forvalues q=1/`Q' {
	local namesdim "`namesdim' dim`q'"
}

matrix rownames `Tcov'=`varlist'
matrix rownames `Rcov'= `varlist'
matrix rownames `Covfin'= `varlist'
matrix rownames `Corrscores'= `varlist'
matrix rownames `Corrrestscores'= `varlist'
matrix colnames `Tcov'= `varlist'
matrix colnames `Rcov' =`varlist'
matrix colnames `Covfin'= `varlist'
matrix colnames `Corrscores'= `namesdim'
matrix colnames `Corrrestscores'= `namesdim'

			
return scalar DETECT=`DETECT'
return scalar Iss=`Iss'
return scalar R=`R'
return matrix Tcov `Tcov'
return matrix Rcov `Rcov'
return matrix Covfin `Covfin'
return matrix Corrscores `Corrscores'
return matrix Corrrestscores `Corrrestscores'


end
