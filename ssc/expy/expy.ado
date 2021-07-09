* expy.ado
* Author: Stephan Huber (University of Regensburg)
* Version 17Mar2017
* please report bugs to stephan.huber@wiwi.uni-regensburg.de

program define expy 
version 12
syntax [if] [in] using/ , TRade(varname) id(varname)  prody(varlist) ///
                          PRODuct(varname) [LABel(str) Time(varname) ///
                          NAMEprody(str) replace]

local n = wordcount("`prody'")

if substr("`using'",-3,.)!="dta" local using `using'.dta
if "`replace'"==""{

	cap confirm file `using' // we check this before calculating all indices
	if !_rc {
		di as err "file `using' already exists"
		exit 602
		}
	}

tokenize `prody'
if `n' > 1 {	
	forval l = 1/`n' {
		local check = 0 
		if "`nameprody'"!="" {
			if substr("``l''",1,length("`nameprody'"))=="`nameprody'" local check = 1
			}
		else if "`nameprody'"=="" {
			if substr("``l''",1,5) == "prody" | substr("``l''",1,5) == "PRODY" local check = 1
			}
		}
	if !`check' {
		di as err "There are inconsistencies with the naming of your PRODY-Variables!"
		di as err "Please name all of them consistently either 'prody' or 'PRODY'"
		di as err "You may also specify a (consistent) name by adding the option " as input "nameprody()"
		di in smcl "{error}For further explanation type {help expy:help expy}"
		exit 111
		}
	}

preserve
tempvar totexp
if "`nameprody'" !="" {
	local lngth = length("`nameprody'")+1
	}
else if "`nameprody'" =="" & `n'==1 {
	if lower(substr("``1''",1,5))!="prody" local lngth = length("`1'")+1
	else local lngth = 6
	}
else local lngth = 6

egen `totexp' = total(`trade') , by(`time' `id')
forvalues l=1/`n' {
	local ver = substr("``l''",`lngth',.)
	if substr("`ver'",1,1)=="_" local ver = substr("`ver'",2,.)
	egen expy_`ver' = total((`trade'/`totexp')*``l'') , by(`time' `id')
	if "`label'"=="" {
		local lbl : var lab ``l''
		if "`nameprody'" =="" {
			local lbl : subinstr local lbl "PRODY" "EXPY", all
			}
		else {
			if regexm("`lbl'", "`nameprody'") local lbl : subinstr local lbl "`nameprody'" "EXPY", all
			else local lbl EXPY (`lbl') // only if we do not find a match
			}
		label var expy_`ver' "`lbl'"
		}
	else label var expy_`ver' "`label'"
	if `n'==1 & "`ver'"==""{
		rename expy_ expy
		}
	}
keep `time' `id' expy*
qui duplicates drop
save `using', `replace'


end
