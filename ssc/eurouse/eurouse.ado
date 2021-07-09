/*
eurouse: import data from the Eurostat bulk facility 
					   
				   Developed by David Leite Neves (2015)
				ISEG - School of Economics and Management
					University of Lisbon, Portugal
					
					  dneves@iseg.ulisboa.pt

			   The eurouse Package comes with no warranty    	
				  
				  
	DESCRIPTION
	==============================
	Imports data from the Eurostat bulk facility.
	The user only needs to type the code that Eurostat uses to uniquely identify
	a series. You can obtain the codes from the eurostat data navigation tree.
	
	Versions
	==============================
	eurouse version 1.0  January, 2016
*/
set more off
capture program drop eurouse
program define eurouse
version 13
syntax anything , [ CLEAR]

quietly {

local bulkcode "`anything'" 

copy "http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?file=data/`bulkcode'.tsv.gz" . , replace 

if regexm(c(os),"Mac") == 1 { 
shell gzip -d "`bulkcode'.tsv.gz"
}
*
if regexm(c(os),"Windows") == 1 {
di as err _n "Not compatible with windows"
			exit 
}
*******************************************************************************
cap import delimited "`bulkcode'.csv", delimiter(tab) varnames(1) 
cap erase "`bulkcode'.csv"
if _rc {
import delimited "`bulkcode'.tsv", `clear' delimiter(tab) varnames(1)
cap erase "`bulkcode'.tsv"
}
if _rc == 4 {
di as err _n "Error: data in memory would be lost. Use  eurouse `bulkcode', clear  to discard changes."		
}
ds 
local variables = r(varlist) 
local n_vars: word count `variables'

tokenize `variables'
	
	local dataorg = "`1'" 

if 	regexm("`dataorg'" , "geotim") 	== 1 | ///
	regexm("`dataorg'" , "time") 	== 1  | /// 
	regexm("`dataorg'" , "gtime") 	== 1 { 
		
		local dataorgassert = 0
}
if regexm("`dataorg'" , "timegeo") == 1 {
		local dataorgassert = 1 
}
*
if `dataorgassert' == 0 { 
split  *tim*, parse(,) generate(touse) 
local n_tousevars: word count `r(varlist)' 
local geo: word `n_tousevars' of `r(varlist)'
}
if `dataorgassert' == 1 {
split  *timegeo*, parse(,) generate(touse)
local n_tousevars: word count `r(varlist)' 
local time: word `n_tousevars' of `r(varlist)' 
}
forval i=2/`n_vars' {
	rename ``i'' v`i' 
}
keep touse* v*		
order touse* v*

********************************************************************************
foreach var of varlist v2-v`n_vars'  {
cap split `var', limit(1) generate(`var'cleaned)
}
foreach var of varlist v2-v`n_vars' {
cap replace `var' = `var'cleaned1 
}
keep touse* v2 - v`n_vars'
********************************************************************************
foreach var of varlist v2-v`n_vars' { 
local x : variable label `var'
capture rename `var' `bulkcode'`x'
}
destring `bulkcode'*, replace force 
                   
if `dataorgassert' == 0 {
	levelsof touse`n_tousevars', local(geos) /*stores the levels of the geo var in macro geos*/
}
if `dataorgassert' == 1 {
	levelsof touse`n_tousevars', local(times) /*stores the levels of the time var in macro times*/
}
********************************************************************************
if `dataorgassert' == 0 { 

egen tokeep = concat(touse*), punct("_") 

reshape long `bulkcode', i(tokeep) j(time) string

drop tokeep

	local less1tousevars = `n_tousevars' - 1 

egen tokeep = concat(touse1-touse`less1tousevars'), punct("_") 

levelsof tokeep, local(labels) clean 	

drop touse1-touse`less1tousevars'

egen groupid = group(tokeep)

drop tokeep

rename `bulkcode' `bulkcode'_

rename touse`n_tousevars' geo
}
********************************************************************************
 
if `dataorgassert' == 1 {

egen tokeep = concat(touse*), punct("_")

reshape long `bulkcode', i(tokeep) j(geo) string

drop tokeep

	local less1tousevars = `n_tousevars' - 1 

egen tokeep = concat(touse1-touse`less1tousevars'), punct("_") 

levelsof tokeep, local(labels) clean 

drop touse1-touse`less1tousevars'

egen groupid = group(tokeep)

drop tokeep

rename `bulkcode' `bulkcode'_
rename touse`n_tousevars' time
}
/*----------------------------------------------------------------------------*/

reshape wide `bulkcode'_ , i(time geo) j(groupid) 

/*----------------------------------------------------------------------------*/
if substr(time, 5, 1) == "M" { 

	local freq = "Monthly data" 
	
	rename time timetouse

	gen year = substr(timetouse, 1, 4) 
	
	gen month = substr(timetouse, 6, 2) 
	
	destring year, replace
	destring month, replace
	
	gen time = ym(year, month)
	
	format time %tm
	
	drop year month timetouse	
}
else {
if substr(time, 5, 1) == "Q" { 

	local freq = "Quarterly data"
	
	rename time timetouse

	gen year = substr(timetouse, 1, 4) 
	
	gen quarter = substr(timetouse, 6, 1) 
	
	destring year, replace
	destring quarter, replace
	
	gen time = yq(year, quarter)
	
	format time %tq
	
	drop year quarter timetouse
}
else { 
	
	local freq = "Annual data"
	
	destring time, replace
	
	format time %ty
}
}	
keep time geo `bulkcode'*
order time geo
sort geo time /*time geo*/
********************************************************************************
}
*Notes & labels

*describe, fullnames 
di "{newpage}"
di as text "`freq'"
di as text "{hline 59}"
di `"Contains data from {browse "http://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=`bulkcode'&lang=en": here}"'
di as text "{hline 59}"
di "{newpage}"

end
set more on
