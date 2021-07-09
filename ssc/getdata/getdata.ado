/*	
	'GETDATA': module to import data
	Author: Duarte Goncalves (duarte.goncalves.dg@outlook.com)
	Last update: 24 March 2016
	Version 1.22
	
	This program uses the SDMX Connector for STATA, licensed to Banca d'Italia (Bank of Italy) under a European Union Public Licence
	(world-wide, royalty-free, non-exclusive, sub-licensable licence). 
	See https://github.com/amattioc/SDMX/wiki/SDMX-Connector-for-STATA and
	https://joinup.ec.europa.eu/sites/default/files/eupl1.1.-licence-en_0.pdf
	
	
	I dearly thank Attilio Mattiocco (Attilio.Mattiocco@bancaditalia.it) for all the help regarding the SDMX Connector for STATA
	and Bo Werth (Bo.WERTH@oecd.org) for additional clarifications.
*/







cap program drop getdata
program define getdata
version 13
syntax namelist(min=2), Rest(string) [Geo(string) Time(string) ISOcountrycodes(string) Start(int 0) End(int 0) Merge(string) Frequency(string) DATEMask(string) Varname(string) METAdata(int 1) set clear replace update]

quietly {
****************************************************
**||       Create locals and Trace errors       ||**
****************************************************
**| structure and provider
tokenize `namelist'
local structure "`1'"
local provider "`2'"

if "`structure'" == "" local "`structure'" = "raw"

if "`structure'" != "raw" & "`structure'" != "cs" & "`structure'" != "ts" & "`structure'" != "xt" {
	noisily display in red "ERROR: Choose an appropriate data structure: raw, cs, ts or xt."
	exit
}

if "`provider'" == "" {
	noisily display in red "ERROR: Choose an appropriate provider. If needed, please check the provider by running: getdatacodes."
	exit
}


**| rest
if "`rest'" == "" {
	noisily display in red "ERROR: An appropriate rest query must be used."
	exit
}
local table = substr("`rest'",1,strpos("`rest'","/")-1)


**| geo
tokenize `geo'
local geo1 "`1'"
local geo2 "`2'"
local geo3 "`3'"

if "`geo1'" == "" & "`structure'" != "raw" & "`structure'" != "ts" {
	noisily display in red "ERROR: The chosen data structure requires to specify geo() option with the variable provided in the table to identify location. Call getdatacodes to check the correct name for the geo variable."
	exit
}

if "`geo3'" != "" {
	noisily display in red "ERROR: Only two elements are admissible in geo() option."
	exit
}

if "`geo2'" == "" local geo2 = "`geo1'"


**| time
tokenize `time'
local time1 "`1'"
local time2 "`2'"
local time3 "`3'"

if "`time1'" == "" local time1 = "DATE"

if "`time3'" != "" {
	noisily display in red "ERROR: Only two elements are admissible in time() option."
	exit
}

if "`time2'" == "" local time2 = "`time1'"


**| isocountrycodes
tokenize `isocountrycodes'
local isocountrycodes1 "`1'"
local isocountrycodes2 "`2'"
local isocountrycodes3 "`3'"

if "`isocountrycodes1'" != "" & "`isocountrycodes1'" != "alpha2" & "`isocountrycodes1'" != "alpha3" & "`isocountrycodes1'" != "num" {
	noisily display in red "ERROR: Choose an appropriate ISO country coding option: alpha2, alpha3 and/or num, separated by blank spaces."
	exit
}

if "`isocountrycodes2'" != "" & "`isocountrycodes2'" != "alpha2" & "`isocountrycodes2'" != "alpha3" & "`isocountrycodes2'" != "num" {
	noisily display in red "ERROR: Choose an appropriate ISO country coding option: alpha2, alpha3 and/or num, separated by blank spaces."
	exit
}

if "`isocountrycodes3'" != "" & "`isocountrycodes3'" != "alpha2" & "`isocountrycodes3'" != "alpha3" & "`isocountrycodes3'" != "num" {
	noisily display in red "ERROR: Choose an appropriate ISO country coding option: alpha2, alpha3 and/or num, separated by blank spaces."
	exit
}

local erroriso = 0
if "`isocountrycodes1'" == "alpha2" | "`isocountrycodes2'" == "alpha2" | "`isocountrycodes3'" == "alpha2" local erroriso = `erroriso' + 1
if "`isocountrycodes1'" == "alpha3" | "`isocountrycodes2'" == "alpha3" | "`isocountrycodes3'" == "alpha3" local erroriso = `erroriso' + 1

/*
if `erroriso' == 2 {
	noisily display in red "ERROR: Choose either alpha2 or alpha3, not both."
	exit
}	
*/

**| starttime and endtime
if "`start'" == "0" local start = ""
if "`end'" == "0" local end = ""


**| merge
if "`merge'" == "" local merge = "1:1"

if "`merge'" != "1:1" & "`merge'" != "m:1" & "`merge'" != "1:m" & "`merge'" != "m:m" {
	noisily display in red "ERROR: The chosen data structure requires to specify time() option with the variable provided in the table to identify time."
	exit
}


**| conflicting options
if "`time1'" == "" & "`structure'" != "raw" & "`structure'" != "cs" {
	noisily display in red "ERROR: The chosen data structure requires to specify time() option with the variable provided in the table to identify time."
	exit
}

if "`structure'" != "raw" & "`structure'" != "cs" & "`structure'" != "ts" & "`structure'" != "xt" {
	noisily display in red "ERROR: Choose an appropriate data structure: raw, cs, ts or xt."
	exit
}


**| varname
local valuevar_name "`varname'"


**| clear
if "`clear'" == "clear"{
	clear
}
local N_init = _N
if `N_init'>0 {
	preserve
}
clear


**| metadata
if "`structure'" != "raw" local metadata 1



****************************************************
**||              Getting the data              ||**
****************************************************

noisily di "Getting the data ..."

local before_extraction = _N

cap javacall it.bancaditalia.oss.sdmx.client.StataClientHandler getTimeSeries, args("`provider'" "`rest'" "`start'" "`end'" "`metadata'")
if `before_extraction' >= _N | _rc != 0 {
	di in red "ERROR: No data matched the query specified. Please check the query by running: getdatacodes"
	exit
}



****************************************************
**||  Dealing with Resulting Variables' Names   ||**
****************************************************

noisily di "Preparing the data ..."

if  "`structure'" == "raw" exit

if "`structure'" == "cs" {
levelsof `time1', clean l(levelsofDATE)
local nr_dif_DATE = wordcount("`levelsofDATE'")
	if `nr_dif_DATE' > 1 {
		noisily display in red "ERROR: The data is not cross-sectional. Please select an appropriate data structure. Use raw if in doubt."
		clear
		restore
		exit
	}
}


**| removing the country name and the tablecode
replace VALUE = . if VALUE == .
cap replace TSNAME = subinstr(TSNAME,`geo1'+".","",.)
cap replace TSNAME = subinstr(TSNAME,"."+`geo1',"",.)
*cap replace TSNAME = subinstr(TSNAME,`time1'+".","",.)
cap replace TSNAME = subinstr(TSNAME,"."+`time1',"",.)
replace TSNAME = subinstr(TSNAME,"`table'.","",.)
replace TSNAME = subinstr(TSNAME,".`table'","",.)


**| removing "odd" symbols
foreach symbol in - ! # $ % & / \ ( ) = ? + * ~ ^ , ; . : | @ £ [ ] « » {
replace TSNAME = subinstr(TSNAME,"`symbol'","_",.)
}
replace TSNAME = subinstr(TSNAME,"."," ",.)
replace TSNAME = "n"+substr(TSNAME,1,31) if substr(TSNAME,1,1) == "0" | substr(TSNAME,1,1) == "1" | substr(TSNAME,1,1) == "2" | substr(TSNAME,1,1) == "3" | substr(TSNAME,1,1) == "4" | substr(TSNAME,1,1) == "5" | substr(TSNAME,1,1) == "6" | substr(TSNAME,1,1) == "7" | substr(TSNAME,1,1) == "8" | substr(TSNAME,1,1) == "9"


**| generate new variables' names
local loop = wordcount(TSNAME[1])-1
local looplast = `loop'+1

gen remainder = TSNAME
forvalues vnum = 1/`loop' {
	gen v`vnum' = substr(remainder,1,strpos(remainder," ")-1)
	replace remainder = substr(remainder,strpos(remainder," ")+1,.)
}
rename remainder v`looplast'

local max_char_dim = floor((31-`loop')/(`loop'+1))
replace v1 = substr(v1,1,`max_char_dim')
local char_spent = 0
forvalues vnum = 2/`looplast' {
	local vnumminusone = `vnum' - 1
	local char_spent = `char_spent'+strlen(v`vnumminusone')
	local char_left = 32 - 1 - `char_spent'
	local max_char = floor(`max_char_dim'*`vnum'-`char_spent')
	if `max_char' > `max_char_dim' & `vnum' != `looplast' replace v`vnum' = substr(v`vnum',1,`max_char')
	if `max_char' <= `max_char_dim'  & `vnum' != `looplast' replace v`vnum' = substr(v`vnum',1,`max_char_dim')
	if `vnum' == `looplast' replace v`vnum' = substr(v`vnum',1,`char_left')
}

gen varnames = ""
forvalues vnum = 1/`looplast' {
	if `vnum' != `looplast' replace varnames = varnames+v`vnum'+"_"
	if `vnum' == `looplast' replace varnames = varnames+v`vnum'
}



****************************************************
**||             Reshaping the Data             ||**
****************************************************

if "`structure'" == "cs" {
	cap ds `geo1'
	if _rc != 0 di in red "Please check whether the geographical variable is `geo1'"
	rename `geo1' `geo2'
	rename VALUE v
	keep varnames `geo2' v
	reshape wide v, i("`geo2'") j(varnames) string
	foreach variable of varlist v* {
		local var_label : variable label `variable'
		local exclude " v"
		local var_label : list var_label - exclude
		label var `variable' "`var_label'"
		local rename_name = substr("`variable'",2,.)
		rename `variable' `rename_name'
	}
	ds `geo2', not
	local nr_vars_final = wordcount("`r(varlist)'")
	if "`valuevar_name'" != "" & `nr_vars_final' == 1 {
		rename `r(varlist)' `valuevar_name'
	}
	if "`valuevar_name'" != "" & `nr_vars_final' != 1 {
		cap nois di in red "WARNING: varname() option ignored - there is more than one series extracted."
	}

}

if "`structure'" == "ts" {
	rename `time1' `time2'
	rename VALUE v
	keep varnames `time2' v
	reshape wide v, i("`time2'") j(varnames) string
	foreach variable of varlist v* {
		local var_label : variable label `variable'
		local exclude " v"
		local var_label : list var_label - exclude
		label var `variable' "`var_label'"
		local rename_name = substr("`variable'",2,.)
		rename `variable' `rename_name'
	}
	ds `time2', not
	local nr_vars_final = wordcount("`r(varlist)'")
	if "`valuevar_name'" != "" & `nr_vars_final' == 1 {
		rename `r(varlist)' `valuevar_name'
	}
	if "`valuevar_name'" != "" & `nr_vars_final' != 1 {
		cap nois di in red "WARNING: varname() option ignored - there is more than one series extracted."
	}
}

if "`structure'" == "xt" {
	cap ds `geo1'
	if _rc != 0 di in red "Please check whether the geographical variable is `geo1'"
	rename `geo1' `geo2'
	rename `time1' `time2'
	rename VALUE v
	keep varnames `geo2' `time2' v
	reshape wide v, i("`geo2' `time2'") j(varnames) string
	foreach variable of varlist v* {
		local var_label : variable label `variable'
		local exclude " v"
		local var_label : list var_label - exclude
		label var `variable' "`var_label'"
		local rename_name = substr("`variable'",2,.)
		rename `variable' `rename_name'
	}
	ds `geo2' `time2', not
	local nr_vars_final = wordcount("`r(varlist)'")
	if "`valuevar_name'" != "" & `nr_vars_final' == 1 {
		rename `r(varlist)' `valuevar_name'
	}
	if "`valuevar_name'" != "" & `nr_vars_final' != 1 {
		cap nois di in red "WARNING: varname() option ignored - there is more than one series extracted."
	}
}




****************************************************
**||        Formatting the Time Variable        ||**
****************************************************

if "`structure'" == "ts" | "`structure'" == "xt" {
	if "`frequency'" == "y" & "`datemask'" == "" {
		cap destring `time2', replace
		format `time2' %ty
	}
	if "`frequency'" != "" & "`frequency'" != "c" & "`frequency'" != "C" & "`datemask'" != "" {
		replace `time2' = subinstr(`time2',"d","",.)
		replace `time2' = subinstr(`time2',"w","",.)
		replace `time2' = subinstr(`time2',"m","",.)
		replace `time2' = subinstr(`time2',"h","",.)
		replace `time2' = subinstr(`time2',"s","",.)
		replace `time2' = subinstr(`time2',"y","",.)
		replace `time2' = subinstr(`time2',"D","",.)
		replace `time2' = subinstr(`time2',"W","",.)
		replace `time2' = subinstr(`time2',"M","",.)
		replace `time2' = subinstr(`time2',"H","",.)
		replace `time2' = subinstr(`time2',"S","",.)
		replace `time2' = subinstr(`time2',"Y","",.)
		if "`frequency'" == "q" & "`datemask'" == "YQ" {
			gen `time2'`frequency' = quarterly(`time2',"`datemask'")
			gen temp = dof`frequency'(`time2'`frequency')
			drop `time2'
			rename temp `time2'
			format `time2' %td
			format `time2'`frequency' %t`frequency'
		}
		if "`frequency'" == "m" & "`datemask'" == "YM" {
			gen temp = date(`time2',"`datemask'")
			drop `time2'
			rename temp `time2'
			format `time2' %td
			gen `time2'`frequency' = `frequency'ofd(`time2')
			format `time2'`frequency' %t`frequency'
		}
		if ~(("`frequency'" == "q" & "`datemask'" == "YQ") | ("`frequency'" == "m" & "`datemask'" == "YM")) {
			gen temp = date(`time2',"`datemask'")
			drop `time2'
			rename temp `time2'
			format `time2' %td
			gen `time2'`frequency' = `frequency'ofd(`time2')
			format `time2'`frequency' %t`frequency'
		}
	}
	if ("`frequency'" == "c" | "`frequency'" == "C") & "`datemask'" != "" {
		gen temp = clock(`time2',"`datemask'")
		drop `time2'
		rename temp `time2'
		format `time2' %t`frequency'
	}
}






****************************************************
**||   Producing ISO 3166-1 Country Variables   ||**
****************************************************

if !("`isocountrycodes1'" == "alpha2" | "`isocountrycodes1'" == "alpha3" | "`isocountrycodes1'" == "num") & "`isocountrycodes1'" != "" {
	nois di in red "ERROR: specify the isocountrycodes option with appropriate arguments"
}
if "`isocountrycodes1'" == "alpha2" | "`isocountrycodes1'" == "alpha3" | "`isocountrycodes1'" == "num" {
**|  Value Labels
if "`isocountrycodes1'" == "num" | "`isocountrycodes2'" == "num"  | "`isocountrycodes3'" == "num" {
	cap label drop country_iso_num
	label def country_iso_num 1 "World", modify
	label def country_iso_num 4 "Afghanistan", modify
	label def country_iso_num 8 "Albania", modify
	label def country_iso_num 10 "Antarctica", modify
	label def country_iso_num 12 "Algeria", modify
	label def country_iso_num 16 "American Samoa", modify
	label def country_iso_num 20 "Andorra", modify
	label def country_iso_num 24 "Angola", modify
	label def country_iso_num 28 "Antigua and Barbuda", modify
	label def country_iso_num 31 "Azerbaijan", modify
	label def country_iso_num 32 "Argentina", modify
	label def country_iso_num 36 "Australia", modify
	label def country_iso_num 40 "Austria", modify
	label def country_iso_num 44 "Bahamas", modify
	label def country_iso_num 48 "Bahrain", modify
	label def country_iso_num 50 "Bangladesh", modify
	label def country_iso_num 51 "Armenia", modify
	label def country_iso_num 52 "Barbados", modify
	label def country_iso_num 56 "Belgium", modify
	label def country_iso_num 60 "Bermuda", modify
	label def country_iso_num 64 "Bhutan", modify
	label def country_iso_num 68 "Bolivia", modify
	label def country_iso_num 70 "Bosnia and Herzegovina", modify
	label def country_iso_num 72 "Botswana", modify
	label def country_iso_num 74 "Bouvet Island", modify
	label def country_iso_num 76 "Brazil", modify
	label def country_iso_num 84 "Belize", modify
	label def country_iso_num 86 "British Indian Ocean Territory", modify
	label def country_iso_num 90 "Solomon Islands", modify
	label def country_iso_num 92 "Virgin Islands (British)", modify
	label def country_iso_num 96 "Brunei Darussalam", modify
	label def country_iso_num 100 "Bulgaria", modify
	label def country_iso_num 104 "Myanmar", modify
	label def country_iso_num 108 "Burundi", modify
	label def country_iso_num 112 "Belarus", modify
	label def country_iso_num 116 "Cambodia", modify
	label def country_iso_num 120 "Cameroon", modify
	label def country_iso_num 124 "Canada", modify
	label def country_iso_num 132 "Cabo Verde", modify
	label def country_iso_num 136 "Cayman Islands", modify
	label def country_iso_num 140 "Central African Republic", modify
	label def country_iso_num 144 "Sri Lanka", modify
	label def country_iso_num 148 "Chad", modify
	label def country_iso_num 152 "Chile", modify
	label def country_iso_num 156 "China", modify
	label def country_iso_num 158 "Taiwan (Province of China)", modify
	label def country_iso_num 162 "Christmas Island", modify
	label def country_iso_num 166 "Cocos (Keeling) Islands", modify
	label def country_iso_num 170 "Colombia", modify
	label def country_iso_num 174 "Comoros", modify
	label def country_iso_num 175 "Mayotte", modify
	label def country_iso_num 178 "Congo", modify
	label def country_iso_num 180 "Congo (the Democratic Republic of the)", modify
	label def country_iso_num 184 "Cook Islands", modify
	label def country_iso_num 188 "Costa Rica", modify
	label def country_iso_num 191 "Croatia", modify
	label def country_iso_num 192 "Cuba", modify
	label def country_iso_num 196 "Cyprus", modify
	label def country_iso_num 203 "Czech Republic", modify
	label def country_iso_num 204 "Benin", modify
	label def country_iso_num 208 "Denmark", modify
	label def country_iso_num 212 "Dominica", modify
	label def country_iso_num 214 "Dominican Republic", modify
	label def country_iso_num 218 "Ecuador", modify
	label def country_iso_num 222 "El Salvador", modify
	label def country_iso_num 226 "Equatorial Guinea", modify
	label def country_iso_num 231 "Ethiopia", modify
	label def country_iso_num 232 "Eritrea", modify
	label def country_iso_num 233 "Estonia", modify
	label def country_iso_num 234 "Faroe Islands", modify
	label def country_iso_num 238 "Aland Islands [Malvinas]", modify
	label def country_iso_num 239 "South Georgia and the South Sandwich Islands", modify
	label def country_iso_num 242 "Fiji", modify
	label def country_iso_num 246 "Finland", modify
	label def country_iso_num 248 "Falkland Islands", modify
	label def country_iso_num 250 "France", modify
	label def country_iso_num 254 "French Guiana", modify
	label def country_iso_num 258 "French Polynesia", modify
	label def country_iso_num 260 "French Southern Territories", modify
	label def country_iso_num 262 "Djibouti", modify
	label def country_iso_num 266 "Gabon", modify
	label def country_iso_num 268 "Georgia", modify
	label def country_iso_num 270 "Gambia", modify
	label def country_iso_num 275 "Palestine, State of", modify
	label def country_iso_num 276 "Germany", modify
	label def country_iso_num 288 "Ghana", modify
	label def country_iso_num 292 "Gibraltar", modify
	label def country_iso_num 296 "Kiribati", modify
	label def country_iso_num 300 "Greece", modify
	label def country_iso_num 304 "Greenland", modify
	label def country_iso_num 308 "Grenada", modify
	label def country_iso_num 312 "Guadeloupe", modify
	label def country_iso_num 316 "Guam", modify
	label def country_iso_num 320 "Guatemala", modify
	label def country_iso_num 324 "Guinea", modify
	label def country_iso_num 328 "Guyana", modify
	label def country_iso_num 332 "Haiti", modify
	label def country_iso_num 334 "Heard Island and McDonald Islands", modify
	label def country_iso_num 336 "Holy See", modify
	label def country_iso_num 340 "Honduras", modify
	label def country_iso_num 344 "Hong Kong", modify
	label def country_iso_num 348 "Hungary", modify
	label def country_iso_num 352 "Iceland", modify
	label def country_iso_num 356 "India", modify
	label def country_iso_num 360 "Indonesia", modify
	label def country_iso_num 364 "Iran", modify
	label def country_iso_num 368 "Iraq", modify
	label def country_iso_num 372 "Ireland", modify
	label def country_iso_num 376 "Israel", modify
	label def country_iso_num 380 "Italy", modify
	label def country_iso_num 384 "Cote d'Ivoire", modify
	label def country_iso_num 388 "Jamaica", modify
	label def country_iso_num 392 "Japan", modify
	label def country_iso_num 398 "Kazakhstan", modify
	label def country_iso_num 400 "Jordan", modify
	label def country_iso_num 404 "Kenya", modify
	label def country_iso_num 408 "Korea (the Democratic People's Republic of)", modify
	label def country_iso_num 410 "Korea (the Republic of)", modify
	label def country_iso_num 414 "Kuwait", modify
	label def country_iso_num 417 "Kyrgyzstan", modify
	label def country_iso_num 418 "Lao People's Democratic Republic", modify
	label def country_iso_num 422 "Lebanon", modify
	label def country_iso_num 426 "Lesotho", modify
	label def country_iso_num 428 "Latvia", modify
	label def country_iso_num 430 "Liberia", modify
	label def country_iso_num 434 "Libya", modify
	label def country_iso_num 438 "Liechtenstein", modify
	label def country_iso_num 440 "Lithuania", modify
	label def country_iso_num 442 "Luxembourg", modify
	label def country_iso_num 446 "Macao", modify
	label def country_iso_num 450 "Madagascar", modify
	label def country_iso_num 454 "Malawi", modify
	label def country_iso_num 458 "Malaysia", modify
	label def country_iso_num 462 "Maldives", modify
	label def country_iso_num 466 "Mali", modify
	label def country_iso_num 470 "Malta", modify
	label def country_iso_num 474 "Martinique", modify
	label def country_iso_num 478 "Mauritania", modify
	label def country_iso_num 480 "Mauritius", modify
	label def country_iso_num 484 "Mexico", modify
	label def country_iso_num 492 "Monaco", modify
	label def country_iso_num 496 "Mongolia", modify
	label def country_iso_num 498 "Moldova", modify
	label def country_iso_num 499 "Montenegro", modify
	label def country_iso_num 500 "Montserrat", modify
	label def country_iso_num 504 "Morocco", modify
	label def country_iso_num 508 "Mozambique", modify
	label def country_iso_num 512 "Oman", modify
	label def country_iso_num 516 "Namibia", modify
	label def country_iso_num 520 "Nauru", modify
	label def country_iso_num 524 "Nepal", modify
	label def country_iso_num 528 "Netherlands", modify
	label def country_iso_num 531 "Curacao", modify
	label def country_iso_num 533 "Aruba", modify
	label def country_iso_num 534 "Sint Maarten (Dutch part)", modify
	label def country_iso_num 535 "Bonaire, Sint Eustatius and Saba", modify
	label def country_iso_num 540 "New Caledonia", modify
	label def country_iso_num 548 "Vanuatu", modify
	label def country_iso_num 554 "New Zealand", modify
	label def country_iso_num 558 "Nicaragua", modify
	label def country_iso_num 562 "Niger", modify
	label def country_iso_num 566 "Nigeria", modify
	label def country_iso_num 570 "Niue", modify
	label def country_iso_num 574 "Norfolk Island", modify
	label def country_iso_num 578 "Norway", modify
	label def country_iso_num 580 "Northern Mariana Islands", modify
	label def country_iso_num 581 "United States Minor Outlying Islands", modify
	label def country_iso_num 583 "Micronesia", modify
	label def country_iso_num 584 "Marshall Islands", modify
	label def country_iso_num 585 "Palau", modify
	label def country_iso_num 586 "Pakistan", modify
	label def country_iso_num 591 "Panama", modify
	label def country_iso_num 598 "Papua New Guinea", modify
	label def country_iso_num 600 "Paraguay", modify
	label def country_iso_num 604 "Peru", modify
	label def country_iso_num 608 "Philippines", modify
	label def country_iso_num 612 "Pitcairn", modify
	label def country_iso_num 616 "Poland", modify
	label def country_iso_num 620 "Portugal", modify
	label def country_iso_num 624 "Guinea-Bissau", modify
	label def country_iso_num 626 "Timor-Leste", modify
	label def country_iso_num 630 "Puerto Rico", modify
	label def country_iso_num 634 "Qatar", modify
	label def country_iso_num 638 "Reunion", modify
	label def country_iso_num 642 "Romania", modify
	label def country_iso_num 643 "Russian Federation", modify
	label def country_iso_num 646 "Rwanda", modify
	label def country_iso_num 652 "Saint Barthelemy", modify
	label def country_iso_num 654 "Saint Helena, Ascension and Tristan da Cunha", modify
	label def country_iso_num 659 "Saint Kitts and Nevis", modify
	label def country_iso_num 660 "Anguilla", modify
	label def country_iso_num 662 "Saint Lucia", modify
	label def country_iso_num 663 "Saint Martin (French part)", modify
	label def country_iso_num 666 "Saint Pierre and Miquelon", modify
	label def country_iso_num 670 "Saint Vincent and the Grenadines", modify
	label def country_iso_num 674 "San Marino", modify
	label def country_iso_num 678 "Sao Tome and Principe", modify
	label def country_iso_num 682 "Saudi Arabia", modify
	label def country_iso_num 686 "Senegal", modify
	label def country_iso_num 688 "Serbia", modify
	label def country_iso_num 690 "Seychelles", modify
	label def country_iso_num 694 "Sierra Leone", modify
	label def country_iso_num 702 "Singapore", modify
	label def country_iso_num 703 "Slovakia", modify
	label def country_iso_num 704 "Viet Nam", modify
	label def country_iso_num 705 "Slovenia", modify
	label def country_iso_num 706 "Somalia", modify
	label def country_iso_num 710 "South Africa", modify
	label def country_iso_num 716 "Zimbabwe", modify
	label def country_iso_num 724 "Spain", modify
	label def country_iso_num 728 "South Sudan", modify
	label def country_iso_num 729 "Sudan", modify
	label def country_iso_num 732 "Western Sahara*", modify
	label def country_iso_num 740 "Suriname", modify
	label def country_iso_num 744 "Svalbard and Jan Mayen", modify
	label def country_iso_num 748 "Swaziland", modify
	label def country_iso_num 752 "Sweden", modify
	label def country_iso_num 756 "Switzerland", modify
	label def country_iso_num 760 "Syrian Arab Republic", modify
	label def country_iso_num 762 "Tajikistan", modify
	label def country_iso_num 764 "Thailand", modify
	label def country_iso_num 768 "Togo", modify
	label def country_iso_num 772 "Tokelau", modify
	label def country_iso_num 776 "Tonga", modify
	label def country_iso_num 780 "Trinidad and Tobago", modify
	label def country_iso_num 784 "United Arab Emirates", modify
	label def country_iso_num 788 "Tunisia", modify
	label def country_iso_num 792 "Turkey", modify
	label def country_iso_num 795 "Turkmenistan", modify
	label def country_iso_num 796 "Turks and Caicos Islands", modify
	label def country_iso_num 798 "Tuvalu", modify
	label def country_iso_num 800 "Uganda", modify
	label def country_iso_num 804 "Ukraine", modify
	label def country_iso_num 807 "Macedonia (the former Yugoslav Republic of)", modify
	label def country_iso_num 818 "Egypt", modify
	label def country_iso_num 826 "United Kingdom", modify
	label def country_iso_num 831 "Guernsey", modify
	label def country_iso_num 832 "Jersey", modify
	label def country_iso_num 833 "Isle of Man", modify
	label def country_iso_num 834 "Tanzania, United Republic of", modify
	label def country_iso_num 840 "United States of America", modify
	label def country_iso_num 850 "Virgin Islands (U.S.)", modify
	label def country_iso_num 854 "Burkina Faso", modify
	label def country_iso_num 858 "Uruguay", modify
	label def country_iso_num 860 "Uzbekistan", modify
	label def country_iso_num 862 "Venezuela", modify
	label def country_iso_num 876 "Wallis and Futuna", modify
	label def country_iso_num 882 "Samoa", modify
	label def country_iso_num 887 "Yemen", modify
	label def country_iso_num 894 "Zambia", modify
	
	** Withdrawn ISO coding (withdrawn ISO 3166-1 Numeric + 1000)
	label def country_iso_num 1000 "Former Economies", modify
	label def country_iso_num 1200 "Czechoslovakia", modify
	label def country_iso_num 1278 "Former German Democratic Republic", modify
	label def country_iso_num 1280 "Former Federal Republic of Germany", modify
	label def country_iso_num 1810 "USSR", modify
	label def country_iso_num 1890 "Yugoslavia", modify
		
	** EUROSTAT Specific Coding
	* EU = 2100 + Nr countries
	label def country_iso_num 2100 "European Union", modify
	label def country_iso_num 2106 "European Union (6 Countries)", modify
	label def country_iso_num 2109 "European Union (9 Countries)", modify
	label def country_iso_num 2110 "European Union (10 Countries)", modify
	label def country_iso_num 2112 "European Union (12 Countries)", modify
	label def country_iso_num 2115 "European Union (15 Countries)", modify
	label def country_iso_num 2125 "European Union (25 Countries)", modify
	label def country_iso_num 2127 "European Union (27 Countries)", modify
	label def country_iso_num 2128 "European Union (28 Countries)", modify
	label def country_iso_num 2129 "European Union (29 Countries)", modify
	label def country_iso_num 2130 "European Union (30 Countries)", modify
	label def country_iso_num 2131 "European Union (31 Countries)", modify
	label def country_iso_num 2132 "European Union (32 Countries)", modify
	label def country_iso_num 2133 "European Union (33 Countries)", modify
	label def country_iso_num 2134 "European Union (34 Countries)", modify
	label def country_iso_num 2135 "European Union (35 Countries)", modify
	
	* EA = 2150 + Nr countries
	label def country_iso_num 2150 "Euro Area", modify
	label def country_iso_num 2161 "Euro Area (11 Countries)", modify
	label def country_iso_num 2162 "Euro Area (12 Countries)", modify
	label def country_iso_num 2163 "Euro Area (13 Countries)", modify
	label def country_iso_num 2164 "Euro Area (14 Countries)", modify
	label def country_iso_num 2165 "Euro Area (15 Countries)", modify
	label def country_iso_num 2166 "Euro Area (16 Countries)", modify
	label def country_iso_num 2167 "Euro Area (17 Countries)", modify
	label def country_iso_num 2168 "Euro Area (18 Countries)", modify
	label def country_iso_num 2169 "Euro Area (19 Countries)", modify
	label def country_iso_num 2170 "Euro Area (20 Countries)", modify
	label def country_iso_num 2171 "Euro Area (21 Countries)", modify
	label def country_iso_num 2172 "Euro Area (22 Countries)", modify
	label def country_iso_num 2173 "Euro Area (23 Countries)", modify
	label def country_iso_num 2174 "Euro Area (24 Countries)", modify
	label def country_iso_num 2175 "Euro Area (25 Countries)", modify
	
	
	** OECD Specific Coding	
	label def country_iso_num 2200 "OECD Total", modify
	label def country_iso_num 2201 "OECD (23 Countries)", modify
	label def country_iso_num 2203 "OECD Pacific Countries", modify
	label def country_iso_num 2209 "Non-OECD Member Countries", modify
	label def country_iso_num 2211 "22 OECD European countries (break 1991, 1993)", modify
	label def country_iso_num 2231 "Rest of the World", modify
	label def country_iso_num 2240 "Oil Producers", modify
	label def country_iso_num 2241 "OPEC", modify
	label def country_iso_num 2242 "Other Oil Producers", modify
	label def country_iso_num 2249 "Remaining Countries that are not oil producers", modify
	label def country_iso_num 2260 "Dynamic Asian Economies", modify
	label def country_iso_num 2270 "NAFTA", modify
	label def country_iso_num 2280 "Other Groups", modify
}

**| Check which geo variables are to be created
* Check whether the original variable is a string
cap replace `geo2' = "testifstring" if `geo2' == "testifstring"
if _rc == 0 local originalisstring = 1
if _rc != 0 local originalisstring = 0

* Create geo variables needed
if ("`isocountrycodes1'" == "alpha2" | "`isocountrycodes2'" == "alpha2" | "`isocountrycodes3'" == "alpha2") gen `geo2'_alpha2 = ""
if ("`isocountrycodes1'" == "alpha3" | "`isocountrycodes2'" == "alpha3" | "`isocountrycodes3'" == "alpha3") gen `geo2'_alpha3 = ""
if ("`isocountrycodes1'" == "num" | "`isocountrycodes2'" == "num" | "`isocountrycodes3'" == "num") gen `geo2'_num = .
if ("`isocountrycodes1'" == "alpha3" | "`isocountrycodes2'" == "alpha3" | "`isocountrycodes3'" == "alpha3") local alpha3 = "alpha3"
if ("`isocountrycodes1'" == "alpha2" | "`isocountrycodes2'" == "alpha2" | "`isocountrycodes3'" == "alpha2") local alpha2 = "alpha2"
if ("`isocountrycodes1'" == "num" | "`isocountrycodes2'" == "num" | "`isocountrycodes3'" == "num") local vargeonum = "vargeonum"

**| IMF Specific Country Coding
if "`provider'" == "IMF" & ("`alpha2'" == "alpha2" | "`alpha3'" == "alpha3") {
	getdata_imf_alpha3 `geo2'
}
if "`provider'" == "IMF" & ("`vargeonum'" == "vargeonum") {
	getdata_imf_num `geo2'
}

**| Create Alpha2 if requested
* If original geo variable is already string, make it equal to original
if `originalisstring' == 1  & "`alpha2'" == "alpha2" cap replace `geo2'_alpha2 = `geo2'
* If original geo variable is not a string, convert from Numeric to Alpha2
if `originalisstring' == 0 & "`alpha2'" == "alpha2" {
replace `geo2'_alpha2 = "AF" if `geo2' == 4
replace `geo2'_alpha2 = "AL" if `geo2' == 8
replace `geo2'_alpha2 = "AQ" if `geo2' == 10
replace `geo2'_alpha2 = "DZ" if `geo2' == 12
replace `geo2'_alpha2 = "AS" if `geo2' == 16
replace `geo2'_alpha2 = "AD" if `geo2' == 20
replace `geo2'_alpha2 = "AO" if `geo2' == 24
replace `geo2'_alpha2 = "AG" if `geo2' == 28
replace `geo2'_alpha2 = "AZ" if `geo2' == 31
replace `geo2'_alpha2 = "AR" if `geo2' == 32
replace `geo2'_alpha2 = "AU" if `geo2' == 36
replace `geo2'_alpha2 = "AT" if `geo2' == 40
replace `geo2'_alpha2 = "BS" if `geo2' == 44
replace `geo2'_alpha2 = "BH" if `geo2' == 48
replace `geo2'_alpha2 = "BD" if `geo2' == 50
replace `geo2'_alpha2 = "AM" if `geo2' == 51
replace `geo2'_alpha2 = "BB" if `geo2' == 52
replace `geo2'_alpha2 = "BE" if `geo2' == 56
replace `geo2'_alpha2 = "BM" if `geo2' == 60
replace `geo2'_alpha2 = "BT" if `geo2' == 64
replace `geo2'_alpha2 = "BO" if `geo2' == 68
replace `geo2'_alpha2 = "BA" if `geo2' == 70
replace `geo2'_alpha2 = "BW" if `geo2' == 72
replace `geo2'_alpha2 = "BV" if `geo2' == 74
replace `geo2'_alpha2 = "BR" if `geo2' == 76
replace `geo2'_alpha2 = "BZ" if `geo2' == 84
replace `geo2'_alpha2 = "IO" if `geo2' == 86
replace `geo2'_alpha2 = "SB" if `geo2' == 90
replace `geo2'_alpha2 = "VG" if `geo2' == 92
replace `geo2'_alpha2 = "BN" if `geo2' == 96
replace `geo2'_alpha2 = "BG" if `geo2' == 100
replace `geo2'_alpha2 = "MM" if `geo2' == 104
replace `geo2'_alpha2 = "BI" if `geo2' == 108
replace `geo2'_alpha2 = "BY" if `geo2' == 112
replace `geo2'_alpha2 = "KH" if `geo2' == 116
replace `geo2'_alpha2 = "CM" if `geo2' == 120
replace `geo2'_alpha2 = "CA" if `geo2' == 124
replace `geo2'_alpha2 = "CV" if `geo2' == 132
replace `geo2'_alpha2 = "KY" if `geo2' == 136
replace `geo2'_alpha2 = "CF" if `geo2' == 140
replace `geo2'_alpha2 = "LK" if `geo2' == 144
replace `geo2'_alpha2 = "TD" if `geo2' == 148
replace `geo2'_alpha2 = "CL" if `geo2' == 152
replace `geo2'_alpha2 = "CN" if `geo2' == 156
replace `geo2'_alpha2 = "TW" if `geo2' == 158
replace `geo2'_alpha2 = "CX" if `geo2' == 162
replace `geo2'_alpha2 = "CC" if `geo2' == 166
replace `geo2'_alpha2 = "CO" if `geo2' == 170
replace `geo2'_alpha2 = "KM" if `geo2' == 174
replace `geo2'_alpha2 = "YT" if `geo2' == 175
replace `geo2'_alpha2 = "CG" if `geo2' == 178
replace `geo2'_alpha2 = "CD" if `geo2' == 180
replace `geo2'_alpha2 = "CK" if `geo2' == 184
replace `geo2'_alpha2 = "CR" if `geo2' == 188
replace `geo2'_alpha2 = "HR" if `geo2' == 191
replace `geo2'_alpha2 = "CU" if `geo2' == 192
replace `geo2'_alpha2 = "CY" if `geo2' == 196
replace `geo2'_alpha2 = "CZ" if `geo2' == 203
replace `geo2'_alpha2 = "BJ" if `geo2' == 204
replace `geo2'_alpha2 = "DK" if `geo2' == 208
replace `geo2'_alpha2 = "DM" if `geo2' == 212
replace `geo2'_alpha2 = "DO" if `geo2' == 214
replace `geo2'_alpha2 = "EC" if `geo2' == 218
replace `geo2'_alpha2 = "SV" if `geo2' == 222
replace `geo2'_alpha2 = "GQ" if `geo2' == 226
replace `geo2'_alpha2 = "ET" if `geo2' == 231
replace `geo2'_alpha2 = "ER" if `geo2' == 232
replace `geo2'_alpha2 = "EE" if `geo2' == 233
replace `geo2'_alpha2 = "FO" if `geo2' == 234
replace `geo2'_alpha2 = "FK" if `geo2' == 238
replace `geo2'_alpha2 = "GS" if `geo2' == 239
replace `geo2'_alpha2 = "FJ" if `geo2' == 242
replace `geo2'_alpha2 = "FI" if `geo2' == 246
replace `geo2'_alpha2 = "AX" if `geo2' == 248
replace `geo2'_alpha2 = "FR" if `geo2' == 250
replace `geo2'_alpha2 = "GF" if `geo2' == 254
replace `geo2'_alpha2 = "PF" if `geo2' == 258
replace `geo2'_alpha2 = "TF" if `geo2' == 260
replace `geo2'_alpha2 = "DJ" if `geo2' == 262
replace `geo2'_alpha2 = "GA" if `geo2' == 266
replace `geo2'_alpha2 = "GE" if `geo2' == 268
replace `geo2'_alpha2 = "GM" if `geo2' == 270
replace `geo2'_alpha2 = "PS" if `geo2' == 275
replace `geo2'_alpha2 = "DE" if `geo2' == 276
replace `geo2'_alpha2 = "GH" if `geo2' == 288
replace `geo2'_alpha2 = "GI" if `geo2' == 292
replace `geo2'_alpha2 = "KI" if `geo2' == 296
replace `geo2'_alpha2 = "GR" if `geo2' == 300
replace `geo2'_alpha2 = "GL" if `geo2' == 304
replace `geo2'_alpha2 = "GD" if `geo2' == 308
replace `geo2'_alpha2 = "GP" if `geo2' == 312
replace `geo2'_alpha2 = "GU" if `geo2' == 316
replace `geo2'_alpha2 = "GT" if `geo2' == 320
replace `geo2'_alpha2 = "GN" if `geo2' == 324
replace `geo2'_alpha2 = "GY" if `geo2' == 328
replace `geo2'_alpha2 = "HT" if `geo2' == 332
replace `geo2'_alpha2 = "HM" if `geo2' == 334
replace `geo2'_alpha2 = "VA" if `geo2' == 336
replace `geo2'_alpha2 = "HN" if `geo2' == 340
replace `geo2'_alpha2 = "HK" if `geo2' == 344
replace `geo2'_alpha2 = "HU" if `geo2' == 348
replace `geo2'_alpha2 = "IS" if `geo2' == 352
replace `geo2'_alpha2 = "IN" if `geo2' == 356
replace `geo2'_alpha2 = "ID" if `geo2' == 360
replace `geo2'_alpha2 = "IR" if `geo2' == 364
replace `geo2'_alpha2 = "IQ" if `geo2' == 368
replace `geo2'_alpha2 = "IE" if `geo2' == 372
replace `geo2'_alpha2 = "IL" if `geo2' == 376
replace `geo2'_alpha2 = "IT" if `geo2' == 380
replace `geo2'_alpha2 = "CI" if `geo2' == 384
replace `geo2'_alpha2 = "JM" if `geo2' == 388
replace `geo2'_alpha2 = "JP" if `geo2' == 392
replace `geo2'_alpha2 = "KZ" if `geo2' == 398
replace `geo2'_alpha2 = "JO" if `geo2' == 400
replace `geo2'_alpha2 = "KE" if `geo2' == 404
replace `geo2'_alpha2 = "KP" if `geo2' == 408
replace `geo2'_alpha2 = "KR" if `geo2' == 410
replace `geo2'_alpha2 = "KW" if `geo2' == 414
replace `geo2'_alpha2 = "KG" if `geo2' == 417
replace `geo2'_alpha2 = "LA" if `geo2' == 418
replace `geo2'_alpha2 = "LB" if `geo2' == 422
replace `geo2'_alpha2 = "LS" if `geo2' == 426
replace `geo2'_alpha2 = "LV" if `geo2' == 428
replace `geo2'_alpha2 = "LR" if `geo2' == 430
replace `geo2'_alpha2 = "LY" if `geo2' == 434
replace `geo2'_alpha2 = "LI" if `geo2' == 438
replace `geo2'_alpha2 = "LT" if `geo2' == 440
replace `geo2'_alpha2 = "LU" if `geo2' == 442
replace `geo2'_alpha2 = "MO" if `geo2' == 446
replace `geo2'_alpha2 = "MG" if `geo2' == 450
replace `geo2'_alpha2 = "MW" if `geo2' == 454
replace `geo2'_alpha2 = "MY" if `geo2' == 458
replace `geo2'_alpha2 = "MV" if `geo2' == 462
replace `geo2'_alpha2 = "ML" if `geo2' == 466
replace `geo2'_alpha2 = "MT" if `geo2' == 470
replace `geo2'_alpha2 = "MQ" if `geo2' == 474
replace `geo2'_alpha2 = "MR" if `geo2' == 478
replace `geo2'_alpha2 = "MU" if `geo2' == 480
replace `geo2'_alpha2 = "MX" if `geo2' == 484
replace `geo2'_alpha2 = "MC" if `geo2' == 492
replace `geo2'_alpha2 = "MN" if `geo2' == 496
replace `geo2'_alpha2 = "MD" if `geo2' == 498
replace `geo2'_alpha2 = "ME" if `geo2' == 499
replace `geo2'_alpha2 = "MS" if `geo2' == 500
replace `geo2'_alpha2 = "MA" if `geo2' == 504
replace `geo2'_alpha2 = "MZ" if `geo2' == 508
replace `geo2'_alpha2 = "OM" if `geo2' == 512
replace `geo2'_alpha2 = "NA" if `geo2' == 516
replace `geo2'_alpha2 = "NR" if `geo2' == 520
replace `geo2'_alpha2 = "NP" if `geo2' == 524
replace `geo2'_alpha2 = "NL" if `geo2' == 528
replace `geo2'_alpha2 = "CW" if `geo2' == 531
replace `geo2'_alpha2 = "AW" if `geo2' == 533
replace `geo2'_alpha2 = "SX" if `geo2' == 534
replace `geo2'_alpha2 = "BQ" if `geo2' == 535
replace `geo2'_alpha2 = "NC" if `geo2' == 540
replace `geo2'_alpha2 = "VU" if `geo2' == 548
replace `geo2'_alpha2 = "NZ" if `geo2' == 554
replace `geo2'_alpha2 = "NI" if `geo2' == 558
replace `geo2'_alpha2 = "NE" if `geo2' == 562
replace `geo2'_alpha2 = "NG" if `geo2' == 566
replace `geo2'_alpha2 = "NU" if `geo2' == 570
replace `geo2'_alpha2 = "NF" if `geo2' == 574
replace `geo2'_alpha2 = "NO" if `geo2' == 578
replace `geo2'_alpha2 = "MP" if `geo2' == 580
replace `geo2'_alpha2 = "UM" if `geo2' == 581
replace `geo2'_alpha2 = "FM" if `geo2' == 583
replace `geo2'_alpha2 = "MH" if `geo2' == 584
replace `geo2'_alpha2 = "PW" if `geo2' == 585
replace `geo2'_alpha2 = "PK" if `geo2' == 586
replace `geo2'_alpha2 = "PA" if `geo2' == 591
replace `geo2'_alpha2 = "PG" if `geo2' == 598
replace `geo2'_alpha2 = "PY" if `geo2' == 600
replace `geo2'_alpha2 = "PE" if `geo2' == 604
replace `geo2'_alpha2 = "PH" if `geo2' == 608
replace `geo2'_alpha2 = "PN" if `geo2' == 612
replace `geo2'_alpha2 = "PL" if `geo2' == 616
replace `geo2'_alpha2 = "PT" if `geo2' == 620
replace `geo2'_alpha2 = "GW" if `geo2' == 624
replace `geo2'_alpha2 = "TL" if `geo2' == 626
replace `geo2'_alpha2 = "PR" if `geo2' == 630
replace `geo2'_alpha2 = "QA" if `geo2' == 634
replace `geo2'_alpha2 = "RE" if `geo2' == 638
replace `geo2'_alpha2 = "RO" if `geo2' == 642
replace `geo2'_alpha2 = "RU" if `geo2' == 643
replace `geo2'_alpha2 = "RW" if `geo2' == 646
replace `geo2'_alpha2 = "BL" if `geo2' == 652
replace `geo2'_alpha2 = "SH" if `geo2' == 654
replace `geo2'_alpha2 = "KN" if `geo2' == 659
replace `geo2'_alpha2 = "AI" if `geo2' == 660
replace `geo2'_alpha2 = "LC" if `geo2' == 662
replace `geo2'_alpha2 = "MF" if `geo2' == 663
replace `geo2'_alpha2 = "PM" if `geo2' == 666
replace `geo2'_alpha2 = "VC" if `geo2' == 670
replace `geo2'_alpha2 = "SM" if `geo2' == 674
replace `geo2'_alpha2 = "ST" if `geo2' == 678
replace `geo2'_alpha2 = "SA" if `geo2' == 682
replace `geo2'_alpha2 = "SN" if `geo2' == 686
replace `geo2'_alpha2 = "RS" if `geo2' == 688
replace `geo2'_alpha2 = "SC" if `geo2' == 690
replace `geo2'_alpha2 = "SL" if `geo2' == 694
replace `geo2'_alpha2 = "SG" if `geo2' == 702
replace `geo2'_alpha2 = "SK" if `geo2' == 703
replace `geo2'_alpha2 = "VN" if `geo2' == 704
replace `geo2'_alpha2 = "SI" if `geo2' == 705
replace `geo2'_alpha2 = "SO" if `geo2' == 706
replace `geo2'_alpha2 = "ZA" if `geo2' == 710
replace `geo2'_alpha2 = "ZW" if `geo2' == 716
replace `geo2'_alpha2 = "ES" if `geo2' == 724
replace `geo2'_alpha2 = "SS" if `geo2' == 728
replace `geo2'_alpha2 = "SD" if `geo2' == 729
replace `geo2'_alpha2 = "EH" if `geo2' == 732
replace `geo2'_alpha2 = "SR" if `geo2' == 740
replace `geo2'_alpha2 = "SJ" if `geo2' == 744
replace `geo2'_alpha2 = "SZ" if `geo2' == 748
replace `geo2'_alpha2 = "SE" if `geo2' == 752
replace `geo2'_alpha2 = "CH" if `geo2' == 756
replace `geo2'_alpha2 = "SY" if `geo2' == 760
replace `geo2'_alpha2 = "TJ" if `geo2' == 762
replace `geo2'_alpha2 = "TH" if `geo2' == 764
replace `geo2'_alpha2 = "TG" if `geo2' == 768
replace `geo2'_alpha2 = "TK" if `geo2' == 772
replace `geo2'_alpha2 = "TO" if `geo2' == 776
replace `geo2'_alpha2 = "TT" if `geo2' == 780
replace `geo2'_alpha2 = "AE" if `geo2' == 784
replace `geo2'_alpha2 = "TN" if `geo2' == 788
replace `geo2'_alpha2 = "TR" if `geo2' == 792
replace `geo2'_alpha2 = "TM" if `geo2' == 795
replace `geo2'_alpha2 = "TC" if `geo2' == 796
replace `geo2'_alpha2 = "TV" if `geo2' == 798
replace `geo2'_alpha2 = "UG" if `geo2' == 800
replace `geo2'_alpha2 = "UA" if `geo2' == 804
replace `geo2'_alpha2 = "MK" if `geo2' == 807
replace `geo2'_alpha2 = "EG" if `geo2' == 818
replace `geo2'_alpha2 = "GB" if `geo2' == 826
replace `geo2'_alpha2 = "GG" if `geo2' == 831
replace `geo2'_alpha2 = "JE" if `geo2' == 832
replace `geo2'_alpha2 = "IM" if `geo2' == 833
replace `geo2'_alpha2 = "TZ" if `geo2' == 834
replace `geo2'_alpha2 = "US" if `geo2' == 840
replace `geo2'_alpha2 = "VI" if `geo2' == 850
replace `geo2'_alpha2 = "BF" if `geo2' == 854
replace `geo2'_alpha2 = "UY" if `geo2' == 858
replace `geo2'_alpha2 = "UZ" if `geo2' == 860
replace `geo2'_alpha2 = "VE" if `geo2' == 862
replace `geo2'_alpha2 = "WF" if `geo2' == 876
replace `geo2'_alpha2 = "WS" if `geo2' == 882
replace `geo2'_alpha2 = "YE" if `geo2' == 887
replace `geo2'_alpha2 = "ZM" if `geo2' == 894
}
* Convert from String to Alpha2
if "`alpha2'" == "alpha2" {
replace `geo2'_alpha2 = "AF" if `geo2'_alpha2 == "AFG"
replace `geo2'_alpha2 = "AL" if `geo2'_alpha2 == "ALB"
replace `geo2'_alpha2 = "AQ" if `geo2'_alpha2 == "ATA"
replace `geo2'_alpha2 = "DZ" if `geo2'_alpha2 == "DZA"
replace `geo2'_alpha2 = "AS" if `geo2'_alpha2 == "ASM"
replace `geo2'_alpha2 = "AD" if `geo2'_alpha2 == "AND"
replace `geo2'_alpha2 = "AO" if `geo2'_alpha2 == "AGO"
replace `geo2'_alpha2 = "AG" if `geo2'_alpha2 == "ATG"
replace `geo2'_alpha2 = "AZ" if `geo2'_alpha2 == "AZE"
replace `geo2'_alpha2 = "AR" if `geo2'_alpha2 == "ARG"
replace `geo2'_alpha2 = "AU" if `geo2'_alpha2 == "AUS"
replace `geo2'_alpha2 = "AT" if `geo2'_alpha2 == "AUT"
replace `geo2'_alpha2 = "BS" if `geo2'_alpha2 == "BHS"
replace `geo2'_alpha2 = "BH" if `geo2'_alpha2 == "BHR"
replace `geo2'_alpha2 = "BD" if `geo2'_alpha2 == "BGD"
replace `geo2'_alpha2 = "AM" if `geo2'_alpha2 == "ARM"
replace `geo2'_alpha2 = "BB" if `geo2'_alpha2 == "BRB"
replace `geo2'_alpha2 = "BE" if `geo2'_alpha2 == "BEL"
replace `geo2'_alpha2 = "BM" if `geo2'_alpha2 == "BMU"
replace `geo2'_alpha2 = "BT" if `geo2'_alpha2 == "BTN"
replace `geo2'_alpha2 = "BO" if `geo2'_alpha2 == "BOL"
replace `geo2'_alpha2 = "BA" if `geo2'_alpha2 == "BIH"
replace `geo2'_alpha2 = "BW" if `geo2'_alpha2 == "BWA"
replace `geo2'_alpha2 = "BV" if `geo2'_alpha2 == "BVT"
replace `geo2'_alpha2 = "BR" if `geo2'_alpha2 == "BRA"
replace `geo2'_alpha2 = "BZ" if `geo2'_alpha2 == "BLZ"
replace `geo2'_alpha2 = "IO" if `geo2'_alpha2 == "IOT"
replace `geo2'_alpha2 = "SB" if `geo2'_alpha2 == "SLB"
replace `geo2'_alpha2 = "VG" if `geo2'_alpha2 == "VGB"
replace `geo2'_alpha2 = "BN" if `geo2'_alpha2 == "BRN"
replace `geo2'_alpha2 = "BG" if `geo2'_alpha2 == "BGR"
replace `geo2'_alpha2 = "MM" if `geo2'_alpha2 == "MMR"
replace `geo2'_alpha2 = "BI" if `geo2'_alpha2 == "BDI"
replace `geo2'_alpha2 = "BY" if `geo2'_alpha2 == "BLR"
replace `geo2'_alpha2 = "KH" if `geo2'_alpha2 == "KHM"
replace `geo2'_alpha2 = "CM" if `geo2'_alpha2 == "CMR"
replace `geo2'_alpha2 = "CA" if `geo2'_alpha2 == "CAN"
replace `geo2'_alpha2 = "CV" if `geo2'_alpha2 == "CPV"
replace `geo2'_alpha2 = "KY" if `geo2'_alpha2 == "CYM"
replace `geo2'_alpha2 = "CF" if `geo2'_alpha2 == "CAF"
replace `geo2'_alpha2 = "LK" if `geo2'_alpha2 == "LKA"
replace `geo2'_alpha2 = "TD" if `geo2'_alpha2 == "TCD"
replace `geo2'_alpha2 = "CL" if `geo2'_alpha2 == "CHL"
replace `geo2'_alpha2 = "CN" if `geo2'_alpha2 == "CHN"
replace `geo2'_alpha2 = "TW" if `geo2'_alpha2 == "TWN"
replace `geo2'_alpha2 = "CX" if `geo2'_alpha2 == "CXR"
replace `geo2'_alpha2 = "CC" if `geo2'_alpha2 == "CCK"
replace `geo2'_alpha2 = "CO" if `geo2'_alpha2 == "COL"
replace `geo2'_alpha2 = "KM" if `geo2'_alpha2 == "COM"
replace `geo2'_alpha2 = "YT" if `geo2'_alpha2 == "MYT"
replace `geo2'_alpha2 = "CG" if `geo2'_alpha2 == "COG"
replace `geo2'_alpha2 = "CD" if `geo2'_alpha2 == "COD"
replace `geo2'_alpha2 = "CK" if `geo2'_alpha2 == "COK"
replace `geo2'_alpha2 = "CR" if `geo2'_alpha2 == "CRI"
replace `geo2'_alpha2 = "HR" if `geo2'_alpha2 == "HRV"
replace `geo2'_alpha2 = "CU" if `geo2'_alpha2 == "CUB"
replace `geo2'_alpha2 = "CY" if `geo2'_alpha2 == "CYP"
replace `geo2'_alpha2 = "CZ" if `geo2'_alpha2 == "CZE"
replace `geo2'_alpha2 = "BJ" if `geo2'_alpha2 == "BEN"
replace `geo2'_alpha2 = "DK" if `geo2'_alpha2 == "DNK"
replace `geo2'_alpha2 = "DM" if `geo2'_alpha2 == "DMA"
replace `geo2'_alpha2 = "DO" if `geo2'_alpha2 == "DOM"
replace `geo2'_alpha2 = "EC" if `geo2'_alpha2 == "ECU"
replace `geo2'_alpha2 = "SV" if `geo2'_alpha2 == "SLV"
replace `geo2'_alpha2 = "GQ" if `geo2'_alpha2 == "GNQ"
replace `geo2'_alpha2 = "ET" if `geo2'_alpha2 == "ETH"
replace `geo2'_alpha2 = "ER" if `geo2'_alpha2 == "ERI"
replace `geo2'_alpha2 = "EE" if `geo2'_alpha2 == "EST"
replace `geo2'_alpha2 = "FO" if `geo2'_alpha2 == "FRO"
replace `geo2'_alpha2 = "FK" if `geo2'_alpha2 == "FLK"
replace `geo2'_alpha2 = "GS" if `geo2'_alpha2 == "SGS"
replace `geo2'_alpha2 = "FJ" if `geo2'_alpha2 == "FJI"
replace `geo2'_alpha2 = "FI" if `geo2'_alpha2 == "FIN"
replace `geo2'_alpha2 = "AX" if `geo2'_alpha2 == "ALA"
replace `geo2'_alpha2 = "FR" if `geo2'_alpha2 == "FRA"
replace `geo2'_alpha2 = "GF" if `geo2'_alpha2 == "GUF"
replace `geo2'_alpha2 = "PF" if `geo2'_alpha2 == "PYF"
replace `geo2'_alpha2 = "TF" if `geo2'_alpha2 == "ATF"
replace `geo2'_alpha2 = "DJ" if `geo2'_alpha2 == "DJI"
replace `geo2'_alpha2 = "GA" if `geo2'_alpha2 == "GAB"
replace `geo2'_alpha2 = "GE" if `geo2'_alpha2 == "GEO"
replace `geo2'_alpha2 = "GM" if `geo2'_alpha2 == "GMB"
replace `geo2'_alpha2 = "PS" if `geo2'_alpha2 == "PSE"
replace `geo2'_alpha2 = "DE" if `geo2'_alpha2 == "DEU"
replace `geo2'_alpha2 = "GH" if `geo2'_alpha2 == "GHA"
replace `geo2'_alpha2 = "GI" if `geo2'_alpha2 == "GIB"
replace `geo2'_alpha2 = "KI" if `geo2'_alpha2 == "KIR"
replace `geo2'_alpha2 = "GR" if `geo2'_alpha2 == "GRC"
replace `geo2'_alpha2 = "GL" if `geo2'_alpha2 == "GRL"
replace `geo2'_alpha2 = "GD" if `geo2'_alpha2 == "GRD"
replace `geo2'_alpha2 = "GP" if `geo2'_alpha2 == "GLP"
replace `geo2'_alpha2 = "GU" if `geo2'_alpha2 == "GUM"
replace `geo2'_alpha2 = "GT" if `geo2'_alpha2 == "GTM"
replace `geo2'_alpha2 = "GN" if `geo2'_alpha2 == "GIN"
replace `geo2'_alpha2 = "GY" if `geo2'_alpha2 == "GUY"
replace `geo2'_alpha2 = "HT" if `geo2'_alpha2 == "HTI"
replace `geo2'_alpha2 = "HM" if `geo2'_alpha2 == "HMD"
replace `geo2'_alpha2 = "VA" if `geo2'_alpha2 == "VAT"
replace `geo2'_alpha2 = "HN" if `geo2'_alpha2 == "HND"
replace `geo2'_alpha2 = "HK" if `geo2'_alpha2 == "HKG"
replace `geo2'_alpha2 = "HU" if `geo2'_alpha2 == "HUN"
replace `geo2'_alpha2 = "IS" if `geo2'_alpha2 == "ISL"
replace `geo2'_alpha2 = "IN" if `geo2'_alpha2 == "IND"
replace `geo2'_alpha2 = "ID" if `geo2'_alpha2 == "IDN"
replace `geo2'_alpha2 = "IR" if `geo2'_alpha2 == "IRN"
replace `geo2'_alpha2 = "IQ" if `geo2'_alpha2 == "IRQ"
replace `geo2'_alpha2 = "IE" if `geo2'_alpha2 == "IRL"
replace `geo2'_alpha2 = "IL" if `geo2'_alpha2 == "ISR"
replace `geo2'_alpha2 = "IT" if `geo2'_alpha2 == "ITA"
replace `geo2'_alpha2 = "CI" if `geo2'_alpha2 == "CIV"
replace `geo2'_alpha2 = "JM" if `geo2'_alpha2 == "JAM"
replace `geo2'_alpha2 = "JP" if `geo2'_alpha2 == "JPN"
replace `geo2'_alpha2 = "KZ" if `geo2'_alpha2 == "KAZ"
replace `geo2'_alpha2 = "JO" if `geo2'_alpha2 == "JOR"
replace `geo2'_alpha2 = "KE" if `geo2'_alpha2 == "KEN"
replace `geo2'_alpha2 = "KP" if `geo2'_alpha2 == "PRK"
replace `geo2'_alpha2 = "KR" if `geo2'_alpha2 == "KOR"
replace `geo2'_alpha2 = "KW" if `geo2'_alpha2 == "KWT"
replace `geo2'_alpha2 = "KG" if `geo2'_alpha2 == "KGZ"
replace `geo2'_alpha2 = "LA" if `geo2'_alpha2 == "LAO"
replace `geo2'_alpha2 = "LB" if `geo2'_alpha2 == "LBN"
replace `geo2'_alpha2 = "LS" if `geo2'_alpha2 == "LSO"
replace `geo2'_alpha2 = "LV" if `geo2'_alpha2 == "LVA"
replace `geo2'_alpha2 = "LR" if `geo2'_alpha2 == "LBR"
replace `geo2'_alpha2 = "LY" if `geo2'_alpha2 == "LBY"
replace `geo2'_alpha2 = "LI" if `geo2'_alpha2 == "LIE"
replace `geo2'_alpha2 = "LT" if `geo2'_alpha2 == "LTU"
replace `geo2'_alpha2 = "LU" if `geo2'_alpha2 == "LUX"
replace `geo2'_alpha2 = "MO" if `geo2'_alpha2 == "MAC"
replace `geo2'_alpha2 = "MG" if `geo2'_alpha2 == "MDG"
replace `geo2'_alpha2 = "MW" if `geo2'_alpha2 == "MWI"
replace `geo2'_alpha2 = "MY" if `geo2'_alpha2 == "MYS"
replace `geo2'_alpha2 = "MV" if `geo2'_alpha2 == "MDV"
replace `geo2'_alpha2 = "ML" if `geo2'_alpha2 == "MLI"
replace `geo2'_alpha2 = "MT" if `geo2'_alpha2 == "MLT"
replace `geo2'_alpha2 = "MQ" if `geo2'_alpha2 == "MTQ"
replace `geo2'_alpha2 = "MR" if `geo2'_alpha2 == "MRT"
replace `geo2'_alpha2 = "MU" if `geo2'_alpha2 == "MUS"
replace `geo2'_alpha2 = "MX" if `geo2'_alpha2 == "MEX"
replace `geo2'_alpha2 = "MC" if `geo2'_alpha2 == "MCO"
replace `geo2'_alpha2 = "MN" if `geo2'_alpha2 == "MNG"
replace `geo2'_alpha2 = "MD" if `geo2'_alpha2 == "MDA"
replace `geo2'_alpha2 = "ME" if `geo2'_alpha2 == "MNE"
replace `geo2'_alpha2 = "MS" if `geo2'_alpha2 == "MSR"
replace `geo2'_alpha2 = "MA" if `geo2'_alpha2 == "MAR"
replace `geo2'_alpha2 = "MZ" if `geo2'_alpha2 == "MOZ"
replace `geo2'_alpha2 = "OM" if `geo2'_alpha2 == "OMN"
replace `geo2'_alpha2 = "NA" if `geo2'_alpha2 == "NAM"
replace `geo2'_alpha2 = "NR" if `geo2'_alpha2 == "NRU"
replace `geo2'_alpha2 = "NP" if `geo2'_alpha2 == "NPL"
replace `geo2'_alpha2 = "NL" if `geo2'_alpha2 == "NLD"
replace `geo2'_alpha2 = "CW" if `geo2'_alpha2 == "CUW"
replace `geo2'_alpha2 = "AW" if `geo2'_alpha2 == "ABW"
replace `geo2'_alpha2 = "SX" if `geo2'_alpha2 == "SXM"
replace `geo2'_alpha2 = "BQ" if `geo2'_alpha2 == "BES"
replace `geo2'_alpha2 = "NC" if `geo2'_alpha2 == "NCL"
replace `geo2'_alpha2 = "VU" if `geo2'_alpha2 == "VUT"
replace `geo2'_alpha2 = "NZ" if `geo2'_alpha2 == "NZL"
replace `geo2'_alpha2 = "NI" if `geo2'_alpha2 == "NIC"
replace `geo2'_alpha2 = "NE" if `geo2'_alpha2 == "NER"
replace `geo2'_alpha2 = "NG" if `geo2'_alpha2 == "NGA"
replace `geo2'_alpha2 = "NU" if `geo2'_alpha2 == "NIU"
replace `geo2'_alpha2 = "NF" if `geo2'_alpha2 == "NFK"
replace `geo2'_alpha2 = "NO" if `geo2'_alpha2 == "NOR"
replace `geo2'_alpha2 = "MP" if `geo2'_alpha2 == "MNP"
replace `geo2'_alpha2 = "UM" if `geo2'_alpha2 == "UMI"
replace `geo2'_alpha2 = "FM" if `geo2'_alpha2 == "FSM"
replace `geo2'_alpha2 = "MH" if `geo2'_alpha2 == "MHL"
replace `geo2'_alpha2 = "PW" if `geo2'_alpha2 == "PLW"
replace `geo2'_alpha2 = "PK" if `geo2'_alpha2 == "PAK"
replace `geo2'_alpha2 = "PA" if `geo2'_alpha2 == "PAN"
replace `geo2'_alpha2 = "PG" if `geo2'_alpha2 == "PNG"
replace `geo2'_alpha2 = "PY" if `geo2'_alpha2 == "PRY"
replace `geo2'_alpha2 = "PE" if `geo2'_alpha2 == "PER"
replace `geo2'_alpha2 = "PH" if `geo2'_alpha2 == "PHL"
replace `geo2'_alpha2 = "PN" if `geo2'_alpha2 == "PCN"
replace `geo2'_alpha2 = "PL" if `geo2'_alpha2 == "POL"
replace `geo2'_alpha2 = "PT" if `geo2'_alpha2 == "PRT"
replace `geo2'_alpha2 = "GW" if `geo2'_alpha2 == "GNB"
replace `geo2'_alpha2 = "TL" if `geo2'_alpha2 == "TLS"
replace `geo2'_alpha2 = "PR" if `geo2'_alpha2 == "PRI"
replace `geo2'_alpha2 = "QA" if `geo2'_alpha2 == "QAT"
replace `geo2'_alpha2 = "RE" if `geo2'_alpha2 == "REU"
replace `geo2'_alpha2 = "RO" if `geo2'_alpha2 == "ROU"
replace `geo2'_alpha2 = "RU" if `geo2'_alpha2 == "RUS"
replace `geo2'_alpha2 = "RW" if `geo2'_alpha2 == "RWA"
replace `geo2'_alpha2 = "BL" if `geo2'_alpha2 == "BLM"
replace `geo2'_alpha2 = "SH" if `geo2'_alpha2 == "SHN"
replace `geo2'_alpha2 = "KN" if `geo2'_alpha2 == "KNA"
replace `geo2'_alpha2 = "AI" if `geo2'_alpha2 == "AIA"
replace `geo2'_alpha2 = "LC" if `geo2'_alpha2 == "LCA"
replace `geo2'_alpha2 = "MF" if `geo2'_alpha2 == "MAF"
replace `geo2'_alpha2 = "PM" if `geo2'_alpha2 == "SPM"
replace `geo2'_alpha2 = "VC" if `geo2'_alpha2 == "VCT"
replace `geo2'_alpha2 = "SM" if `geo2'_alpha2 == "SMR"
replace `geo2'_alpha2 = "ST" if `geo2'_alpha2 == "STP"
replace `geo2'_alpha2 = "SA" if `geo2'_alpha2 == "SAU"
replace `geo2'_alpha2 = "SN" if `geo2'_alpha2 == "SEN"
replace `geo2'_alpha2 = "RS" if `geo2'_alpha2 == "SRB"
replace `geo2'_alpha2 = "SC" if `geo2'_alpha2 == "SYC"
replace `geo2'_alpha2 = "SL" if `geo2'_alpha2 == "SLE"
replace `geo2'_alpha2 = "SG" if `geo2'_alpha2 == "SGP"
replace `geo2'_alpha2 = "SK" if `geo2'_alpha2 == "SVK"
replace `geo2'_alpha2 = "VN" if `geo2'_alpha2 == "VNM"
replace `geo2'_alpha2 = "SI" if `geo2'_alpha2 == "SVN"
replace `geo2'_alpha2 = "SO" if `geo2'_alpha2 == "SOM"
replace `geo2'_alpha2 = "ZA" if `geo2'_alpha2 == "ZAF"
replace `geo2'_alpha2 = "ZW" if `geo2'_alpha2 == "ZWE"
replace `geo2'_alpha2 = "ES" if `geo2'_alpha2 == "ESP"
replace `geo2'_alpha2 = "SS" if `geo2'_alpha2 == "SSD"
replace `geo2'_alpha2 = "SD" if `geo2'_alpha2 == "SDN"
replace `geo2'_alpha2 = "EH" if `geo2'_alpha2 == "ESH"
replace `geo2'_alpha2 = "SR" if `geo2'_alpha2 == "SUR"
replace `geo2'_alpha2 = "SJ" if `geo2'_alpha2 == "SJM"
replace `geo2'_alpha2 = "SZ" if `geo2'_alpha2 == "SWZ"
replace `geo2'_alpha2 = "SE" if `geo2'_alpha2 == "SWE"
replace `geo2'_alpha2 = "CH" if `geo2'_alpha2 == "CHE"
replace `geo2'_alpha2 = "SY" if `geo2'_alpha2 == "SYR"
replace `geo2'_alpha2 = "TJ" if `geo2'_alpha2 == "TJK"
replace `geo2'_alpha2 = "TH" if `geo2'_alpha2 == "THA"
replace `geo2'_alpha2 = "TG" if `geo2'_alpha2 == "TGO"
replace `geo2'_alpha2 = "TK" if `geo2'_alpha2 == "TKL"
replace `geo2'_alpha2 = "TO" if `geo2'_alpha2 == "TON"
replace `geo2'_alpha2 = "TT" if `geo2'_alpha2 == "TTO"
replace `geo2'_alpha2 = "AE" if `geo2'_alpha2 == "ARE"
replace `geo2'_alpha2 = "TN" if `geo2'_alpha2 == "TUN"
replace `geo2'_alpha2 = "TR" if `geo2'_alpha2 == "TUR"
replace `geo2'_alpha2 = "TM" if `geo2'_alpha2 == "TKM"
replace `geo2'_alpha2 = "TC" if `geo2'_alpha2 == "TCA"
replace `geo2'_alpha2 = "TV" if `geo2'_alpha2 == "TUV"
replace `geo2'_alpha2 = "UG" if `geo2'_alpha2 == "UGA"
replace `geo2'_alpha2 = "UA" if `geo2'_alpha2 == "UKR"
replace `geo2'_alpha2 = "MK" if `geo2'_alpha2 == "MKD"
replace `geo2'_alpha2 = "EG" if `geo2'_alpha2 == "EGY"
replace `geo2'_alpha2 = "GB" if `geo2'_alpha2 == "GBR"
replace `geo2'_alpha2 = "GG" if `geo2'_alpha2 == "GGY"
replace `geo2'_alpha2 = "JE" if `geo2'_alpha2 == "JEY"
replace `geo2'_alpha2 = "IM" if `geo2'_alpha2 == "IMN"
replace `geo2'_alpha2 = "TZ" if `geo2'_alpha2 == "TZA"
replace `geo2'_alpha2 = "US" if `geo2'_alpha2 == "USA"
replace `geo2'_alpha2 = "VI" if `geo2'_alpha2 == "VIR"
replace `geo2'_alpha2 = "BF" if `geo2'_alpha2 == "BFA"
replace `geo2'_alpha2 = "UY" if `geo2'_alpha2 == "URY"
replace `geo2'_alpha2 = "UZ" if `geo2'_alpha2 == "UZB"
replace `geo2'_alpha2 = "VE" if `geo2'_alpha2 == "VEN"
replace `geo2'_alpha2 = "WF" if `geo2'_alpha2 == "WLF"
replace `geo2'_alpha2 = "WS" if `geo2'_alpha2 == "WSM"
replace `geo2'_alpha2 = "YE" if `geo2'_alpha2 == "YEM"
replace `geo2'_alpha2 = "ZM" if `geo2'_alpha2 == "ZMB"
replace `geo2'_alpha2 = "GB" if `geo2'_alpha2 == "UK"
replace `geo2'_alpha2 = "GR" if `geo2'_alpha2 == "EL"
}

**| Create Alpha3 if requested
* If original geo variable is already string, make it equal to original
if `originalisstring' == 1  & "`alpha3'" == "alpha3" cap replace `geo2'_alpha3 = `geo2'
* If original geo variable is not a string, convert from Numeric to Alpha3
if `originalisstring' == 0 & "`alpha3'" == "alpha3" {
replace `geo2'_alpha3 = "AFG" if `geo2' == 4
replace `geo2'_alpha3 = "ALB" if `geo2' == 8
replace `geo2'_alpha3 = "ATA" if `geo2' == 10
replace `geo2'_alpha3 = "DZA" if `geo2' == 12
replace `geo2'_alpha3 = "ASM" if `geo2' == 16
replace `geo2'_alpha3 = "AND" if `geo2' == 20
replace `geo2'_alpha3 = "AGO" if `geo2' == 24
replace `geo2'_alpha3 = "ATG" if `geo2' == 28
replace `geo2'_alpha3 = "AZE" if `geo2' == 31
replace `geo2'_alpha3 = "ARG" if `geo2' == 32
replace `geo2'_alpha3 = "AUS" if `geo2' == 36
replace `geo2'_alpha3 = "AUT" if `geo2' == 40
replace `geo2'_alpha3 = "BHS" if `geo2' == 44
replace `geo2'_alpha3 = "BHR" if `geo2' == 48
replace `geo2'_alpha3 = "BGD" if `geo2' == 50
replace `geo2'_alpha3 = "ARM" if `geo2' == 51
replace `geo2'_alpha3 = "BRB" if `geo2' == 52
replace `geo2'_alpha3 = "BEL" if `geo2' == 56
replace `geo2'_alpha3 = "BMU" if `geo2' == 60
replace `geo2'_alpha3 = "BTN" if `geo2' == 64
replace `geo2'_alpha3 = "BOL" if `geo2' == 68
replace `geo2'_alpha3 = "BIH" if `geo2' == 70
replace `geo2'_alpha3 = "BWA" if `geo2' == 72
replace `geo2'_alpha3 = "BVT" if `geo2' == 74
replace `geo2'_alpha3 = "BRA" if `geo2' == 76
replace `geo2'_alpha3 = "BLZ" if `geo2' == 84
replace `geo2'_alpha3 = "IOT" if `geo2' == 86
replace `geo2'_alpha3 = "SLB" if `geo2' == 90
replace `geo2'_alpha3 = "VGB" if `geo2' == 92
replace `geo2'_alpha3 = "BRN" if `geo2' == 96
replace `geo2'_alpha3 = "BGR" if `geo2' == 100
replace `geo2'_alpha3 = "MMR" if `geo2' == 104
replace `geo2'_alpha3 = "BDI" if `geo2' == 108
replace `geo2'_alpha3 = "BLR" if `geo2' == 112
replace `geo2'_alpha3 = "KHM" if `geo2' == 116
replace `geo2'_alpha3 = "CMR" if `geo2' == 120
replace `geo2'_alpha3 = "CAN" if `geo2' == 124
replace `geo2'_alpha3 = "CPV" if `geo2' == 132
replace `geo2'_alpha3 = "CYM" if `geo2' == 136
replace `geo2'_alpha3 = "CAF" if `geo2' == 140
replace `geo2'_alpha3 = "LKA" if `geo2' == 144
replace `geo2'_alpha3 = "TCD" if `geo2' == 148
replace `geo2'_alpha3 = "CHL" if `geo2' == 152
replace `geo2'_alpha3 = "CHN" if `geo2' == 156
replace `geo2'_alpha3 = "TWN" if `geo2' == 158
replace `geo2'_alpha3 = "CXR" if `geo2' == 162
replace `geo2'_alpha3 = "CCK" if `geo2' == 166
replace `geo2'_alpha3 = "COL" if `geo2' == 170
replace `geo2'_alpha3 = "COM" if `geo2' == 174
replace `geo2'_alpha3 = "MYT" if `geo2' == 175
replace `geo2'_alpha3 = "COG" if `geo2' == 178
replace `geo2'_alpha3 = "COD" if `geo2' == 180
replace `geo2'_alpha3 = "COK" if `geo2' == 184
replace `geo2'_alpha3 = "CRI" if `geo2' == 188
replace `geo2'_alpha3 = "HRV" if `geo2' == 191
replace `geo2'_alpha3 = "CUB" if `geo2' == 192
replace `geo2'_alpha3 = "CYP" if `geo2' == 196
replace `geo2'_alpha3 = "CZE" if `geo2' == 203
replace `geo2'_alpha3 = "BEN" if `geo2' == 204
replace `geo2'_alpha3 = "DNK" if `geo2' == 208
replace `geo2'_alpha3 = "DMA" if `geo2' == 212
replace `geo2'_alpha3 = "DOM" if `geo2' == 214
replace `geo2'_alpha3 = "ECU" if `geo2' == 218
replace `geo2'_alpha3 = "SLV" if `geo2' == 222
replace `geo2'_alpha3 = "GNQ" if `geo2' == 226
replace `geo2'_alpha3 = "ETH" if `geo2' == 231
replace `geo2'_alpha3 = "ERI" if `geo2' == 232
replace `geo2'_alpha3 = "EST" if `geo2' == 233
replace `geo2'_alpha3 = "FRO" if `geo2' == 234
replace `geo2'_alpha3 = "FLK" if `geo2' == 238
replace `geo2'_alpha3 = "SGS" if `geo2' == 239
replace `geo2'_alpha3 = "FJI" if `geo2' == 242
replace `geo2'_alpha3 = "FIN" if `geo2' == 246
replace `geo2'_alpha3 = "ALA" if `geo2' == 248
replace `geo2'_alpha3 = "FRA" if `geo2' == 250
replace `geo2'_alpha3 = "GUF" if `geo2' == 254
replace `geo2'_alpha3 = "PYF" if `geo2' == 258
replace `geo2'_alpha3 = "ATF" if `geo2' == 260
replace `geo2'_alpha3 = "DJI" if `geo2' == 262
replace `geo2'_alpha3 = "GAB" if `geo2' == 266
replace `geo2'_alpha3 = "GEO" if `geo2' == 268
replace `geo2'_alpha3 = "GMB" if `geo2' == 270
replace `geo2'_alpha3 = "PSE" if `geo2' == 275
replace `geo2'_alpha3 = "DEU" if `geo2' == 276
replace `geo2'_alpha3 = "GHA" if `geo2' == 288
replace `geo2'_alpha3 = "GIB" if `geo2' == 292
replace `geo2'_alpha3 = "KIR" if `geo2' == 296
replace `geo2'_alpha3 = "GRC" if `geo2' == 300
replace `geo2'_alpha3 = "GRL" if `geo2' == 304
replace `geo2'_alpha3 = "GRD" if `geo2' == 308
replace `geo2'_alpha3 = "GLP" if `geo2' == 312
replace `geo2'_alpha3 = "GUM" if `geo2' == 316
replace `geo2'_alpha3 = "GTM" if `geo2' == 320
replace `geo2'_alpha3 = "GIN" if `geo2' == 324
replace `geo2'_alpha3 = "GUY" if `geo2' == 328
replace `geo2'_alpha3 = "HTI" if `geo2' == 332
replace `geo2'_alpha3 = "HMD" if `geo2' == 334
replace `geo2'_alpha3 = "VAT" if `geo2' == 336
replace `geo2'_alpha3 = "HND" if `geo2' == 340
replace `geo2'_alpha3 = "HKG" if `geo2' == 344
replace `geo2'_alpha3 = "HUN" if `geo2' == 348
replace `geo2'_alpha3 = "ISL" if `geo2' == 352
replace `geo2'_alpha3 = "IND" if `geo2' == 356
replace `geo2'_alpha3 = "IDN" if `geo2' == 360
replace `geo2'_alpha3 = "IRN" if `geo2' == 364
replace `geo2'_alpha3 = "IRQ" if `geo2' == 368
replace `geo2'_alpha3 = "IRL" if `geo2' == 372
replace `geo2'_alpha3 = "ISR" if `geo2' == 376
replace `geo2'_alpha3 = "ITA" if `geo2' == 380
replace `geo2'_alpha3 = "CIV" if `geo2' == 384
replace `geo2'_alpha3 = "JAM" if `geo2' == 388
replace `geo2'_alpha3 = "JPN" if `geo2' == 392
replace `geo2'_alpha3 = "KAZ" if `geo2' == 398
replace `geo2'_alpha3 = "JOR" if `geo2' == 400
replace `geo2'_alpha3 = "KEN" if `geo2' == 404
replace `geo2'_alpha3 = "PRK" if `geo2' == 408
replace `geo2'_alpha3 = "KOR" if `geo2' == 410
replace `geo2'_alpha3 = "KWT" if `geo2' == 414
replace `geo2'_alpha3 = "KGZ" if `geo2' == 417
replace `geo2'_alpha3 = "LAO" if `geo2' == 418
replace `geo2'_alpha3 = "LBN" if `geo2' == 422
replace `geo2'_alpha3 = "LSO" if `geo2' == 426
replace `geo2'_alpha3 = "LVA" if `geo2' == 428
replace `geo2'_alpha3 = "LBR" if `geo2' == 430
replace `geo2'_alpha3 = "LBY" if `geo2' == 434
replace `geo2'_alpha3 = "LIE" if `geo2' == 438
replace `geo2'_alpha3 = "LTU" if `geo2' == 440
replace `geo2'_alpha3 = "LUX" if `geo2' == 442
replace `geo2'_alpha3 = "MAC" if `geo2' == 446
replace `geo2'_alpha3 = "MDG" if `geo2' == 450
replace `geo2'_alpha3 = "MWI" if `geo2' == 454
replace `geo2'_alpha3 = "MYS" if `geo2' == 458
replace `geo2'_alpha3 = "MDV" if `geo2' == 462
replace `geo2'_alpha3 = "MLI" if `geo2' == 466
replace `geo2'_alpha3 = "MLT" if `geo2' == 470
replace `geo2'_alpha3 = "MTQ" if `geo2' == 474
replace `geo2'_alpha3 = "MRT" if `geo2' == 478
replace `geo2'_alpha3 = "MUS" if `geo2' == 480
replace `geo2'_alpha3 = "MEX" if `geo2' == 484
replace `geo2'_alpha3 = "MCO" if `geo2' == 492
replace `geo2'_alpha3 = "MNG" if `geo2' == 496
replace `geo2'_alpha3 = "MDA" if `geo2' == 498
replace `geo2'_alpha3 = "MNE" if `geo2' == 499
replace `geo2'_alpha3 = "MSR" if `geo2' == 500
replace `geo2'_alpha3 = "MAR" if `geo2' == 504
replace `geo2'_alpha3 = "MOZ" if `geo2' == 508
replace `geo2'_alpha3 = "OMN" if `geo2' == 512
replace `geo2'_alpha3 = "NAM" if `geo2' == 516
replace `geo2'_alpha3 = "NRU" if `geo2' == 520
replace `geo2'_alpha3 = "NPL" if `geo2' == 524
replace `geo2'_alpha3 = "NLD" if `geo2' == 528
replace `geo2'_alpha3 = "CUW" if `geo2' == 531
replace `geo2'_alpha3 = "ABW" if `geo2' == 533
replace `geo2'_alpha3 = "SXM" if `geo2' == 534
replace `geo2'_alpha3 = "BES" if `geo2' == 535
replace `geo2'_alpha3 = "NCL" if `geo2' == 540
replace `geo2'_alpha3 = "VUT" if `geo2' == 548
replace `geo2'_alpha3 = "NZL" if `geo2' == 554
replace `geo2'_alpha3 = "NIC" if `geo2' == 558
replace `geo2'_alpha3 = "NER" if `geo2' == 562
replace `geo2'_alpha3 = "NGA" if `geo2' == 566
replace `geo2'_alpha3 = "NIU" if `geo2' == 570
replace `geo2'_alpha3 = "NFK" if `geo2' == 574
replace `geo2'_alpha3 = "NOR" if `geo2' == 578
replace `geo2'_alpha3 = "MNP" if `geo2' == 580
replace `geo2'_alpha3 = "UMI" if `geo2' == 581
replace `geo2'_alpha3 = "FSM" if `geo2' == 583
replace `geo2'_alpha3 = "MHL" if `geo2' == 584
replace `geo2'_alpha3 = "PLW" if `geo2' == 585
replace `geo2'_alpha3 = "PAK" if `geo2' == 586
replace `geo2'_alpha3 = "PAN" if `geo2' == 591
replace `geo2'_alpha3 = "PNG" if `geo2' == 598
replace `geo2'_alpha3 = "PRY" if `geo2' == 600
replace `geo2'_alpha3 = "PER" if `geo2' == 604
replace `geo2'_alpha3 = "PHL" if `geo2' == 608
replace `geo2'_alpha3 = "PCN" if `geo2' == 612
replace `geo2'_alpha3 = "POL" if `geo2' == 616
replace `geo2'_alpha3 = "PRT" if `geo2' == 620
replace `geo2'_alpha3 = "GNB" if `geo2' == 624
replace `geo2'_alpha3 = "TLS" if `geo2' == 626
replace `geo2'_alpha3 = "PRI" if `geo2' == 630
replace `geo2'_alpha3 = "QAT" if `geo2' == 634
replace `geo2'_alpha3 = "REU" if `geo2' == 638
replace `geo2'_alpha3 = "ROU" if `geo2' == 642
replace `geo2'_alpha3 = "RUS" if `geo2' == 643
replace `geo2'_alpha3 = "RWA" if `geo2' == 646
replace `geo2'_alpha3 = "BLM" if `geo2' == 652
replace `geo2'_alpha3 = "SHN" if `geo2' == 654
replace `geo2'_alpha3 = "KNA" if `geo2' == 659
replace `geo2'_alpha3 = "AIA" if `geo2' == 660
replace `geo2'_alpha3 = "LCA" if `geo2' == 662
replace `geo2'_alpha3 = "MAF" if `geo2' == 663
replace `geo2'_alpha3 = "SPM" if `geo2' == 666
replace `geo2'_alpha3 = "VCT" if `geo2' == 670
replace `geo2'_alpha3 = "SMR" if `geo2' == 674
replace `geo2'_alpha3 = "STP" if `geo2' == 678
replace `geo2'_alpha3 = "SAU" if `geo2' == 682
replace `geo2'_alpha3 = "SEN" if `geo2' == 686
replace `geo2'_alpha3 = "SRB" if `geo2' == 688
replace `geo2'_alpha3 = "SYC" if `geo2' == 690
replace `geo2'_alpha3 = "SLE" if `geo2' == 694
replace `geo2'_alpha3 = "SGP" if `geo2' == 702
replace `geo2'_alpha3 = "SVK" if `geo2' == 703
replace `geo2'_alpha3 = "VNM" if `geo2' == 704
replace `geo2'_alpha3 = "SVN" if `geo2' == 705
replace `geo2'_alpha3 = "SOM" if `geo2' == 706
replace `geo2'_alpha3 = "ZAF" if `geo2' == 710
replace `geo2'_alpha3 = "ZWE" if `geo2' == 716
replace `geo2'_alpha3 = "ESP" if `geo2' == 724
replace `geo2'_alpha3 = "SSD" if `geo2' == 728
replace `geo2'_alpha3 = "SDN" if `geo2' == 729
replace `geo2'_alpha3 = "ESH" if `geo2' == 732
replace `geo2'_alpha3 = "SUR" if `geo2' == 740
replace `geo2'_alpha3 = "SJM" if `geo2' == 744
replace `geo2'_alpha3 = "SWZ" if `geo2' == 748
replace `geo2'_alpha3 = "SWE" if `geo2' == 752
replace `geo2'_alpha3 = "CHE" if `geo2' == 756
replace `geo2'_alpha3 = "SYR" if `geo2' == 760
replace `geo2'_alpha3 = "TJK" if `geo2' == 762
replace `geo2'_alpha3 = "THA" if `geo2' == 764
replace `geo2'_alpha3 = "TGO" if `geo2' == 768
replace `geo2'_alpha3 = "TKL" if `geo2' == 772
replace `geo2'_alpha3 = "TON" if `geo2' == 776
replace `geo2'_alpha3 = "TTO" if `geo2' == 780
replace `geo2'_alpha3 = "ARE" if `geo2' == 784
replace `geo2'_alpha3 = "TUN" if `geo2' == 788
replace `geo2'_alpha3 = "TUR" if `geo2' == 792
replace `geo2'_alpha3 = "TKM" if `geo2' == 795
replace `geo2'_alpha3 = "TCA" if `geo2' == 796
replace `geo2'_alpha3 = "TUV" if `geo2' == 798
replace `geo2'_alpha3 = "UGA" if `geo2' == 800
replace `geo2'_alpha3 = "UKR" if `geo2' == 804
replace `geo2'_alpha3 = "MKD" if `geo2' == 807
replace `geo2'_alpha3 = "EGY" if `geo2' == 818
replace `geo2'_alpha3 = "GBR" if `geo2' == 826
replace `geo2'_alpha3 = "GGY" if `geo2' == 831
replace `geo2'_alpha3 = "JEY" if `geo2' == 832
replace `geo2'_alpha3 = "IMN" if `geo2' == 833
replace `geo2'_alpha3 = "TZA" if `geo2' == 834
replace `geo2'_alpha3 = "USA" if `geo2' == 840
replace `geo2'_alpha3 = "VIR" if `geo2' == 850
replace `geo2'_alpha3 = "BFA" if `geo2' == 854
replace `geo2'_alpha3 = "URY" if `geo2' == 858
replace `geo2'_alpha3 = "UZB" if `geo2' == 860
replace `geo2'_alpha3 = "VEN" if `geo2' == 862
replace `geo2'_alpha3 = "WLF" if `geo2' == 876
replace `geo2'_alpha3 = "WSM" if `geo2' == 882
replace `geo2'_alpha3 = "YEM" if `geo2' == 887
replace `geo2'_alpha3 = "ZMB" if `geo2' == 894
}
* Convert from String to Alpha3
if "`alpha3'" == "alpha3" {
replace `geo2'_alpha3 = "GRC" if `geo2'_alpha3 == "EL"
replace `geo2'_alpha3 = "GBR" if `geo2'_alpha3 == "UK"
replace `geo2'_alpha3 = "AFG" if `geo2'_alpha3 == "AF"
replace `geo2'_alpha3 = "ALB" if `geo2'_alpha3 == "AL"
replace `geo2'_alpha3 = "ATA" if `geo2'_alpha3 == "AQ"
replace `geo2'_alpha3 = "DZA" if `geo2'_alpha3 == "DZ"
replace `geo2'_alpha3 = "ASM" if `geo2'_alpha3 == "AS"
replace `geo2'_alpha3 = "AND" if `geo2'_alpha3 == "AD"
replace `geo2'_alpha3 = "AGO" if `geo2'_alpha3 == "AO"
replace `geo2'_alpha3 = "ATG" if `geo2'_alpha3 == "AG"
replace `geo2'_alpha3 = "AZE" if `geo2'_alpha3 == "AZ"
replace `geo2'_alpha3 = "ARG" if `geo2'_alpha3 == "AR"
replace `geo2'_alpha3 = "AUS" if `geo2'_alpha3 == "AU"
replace `geo2'_alpha3 = "AUT" if `geo2'_alpha3 == "AT"
replace `geo2'_alpha3 = "BHS" if `geo2'_alpha3 == "BS"
replace `geo2'_alpha3 = "BHR" if `geo2'_alpha3 == "BH"
replace `geo2'_alpha3 = "BGD" if `geo2'_alpha3 == "BD"
replace `geo2'_alpha3 = "ARM" if `geo2'_alpha3 == "AM"
replace `geo2'_alpha3 = "BRB" if `geo2'_alpha3 == "BB"
replace `geo2'_alpha3 = "BEL" if `geo2'_alpha3 == "BE"
replace `geo2'_alpha3 = "BMU" if `geo2'_alpha3 == "BM"
replace `geo2'_alpha3 = "BTN" if `geo2'_alpha3 == "BT"
replace `geo2'_alpha3 = "BOL" if `geo2'_alpha3 == "BO"
replace `geo2'_alpha3 = "BIH" if `geo2'_alpha3 == "BA"
replace `geo2'_alpha3 = "BWA" if `geo2'_alpha3 == "BW"
replace `geo2'_alpha3 = "BVT" if `geo2'_alpha3 == "BV"
replace `geo2'_alpha3 = "BRA" if `geo2'_alpha3 == "BR"
replace `geo2'_alpha3 = "BLZ" if `geo2'_alpha3 == "BZ"
replace `geo2'_alpha3 = "IOT" if `geo2'_alpha3 == "IO"
replace `geo2'_alpha3 = "SLB" if `geo2'_alpha3 == "SB"
replace `geo2'_alpha3 = "VGB" if `geo2'_alpha3 == "VG"
replace `geo2'_alpha3 = "BRN" if `geo2'_alpha3 == "BN"
replace `geo2'_alpha3 = "BGR" if `geo2'_alpha3 == "BG"
replace `geo2'_alpha3 = "MMR" if `geo2'_alpha3 == "MM"
replace `geo2'_alpha3 = "BDI" if `geo2'_alpha3 == "BI"
replace `geo2'_alpha3 = "BLR" if `geo2'_alpha3 == "BY"
replace `geo2'_alpha3 = "KHM" if `geo2'_alpha3 == "KH"
replace `geo2'_alpha3 = "CMR" if `geo2'_alpha3 == "CM"
replace `geo2'_alpha3 = "CAN" if `geo2'_alpha3 == "CA"
replace `geo2'_alpha3 = "CPV" if `geo2'_alpha3 == "CV"
replace `geo2'_alpha3 = "CYM" if `geo2'_alpha3 == "KY"
replace `geo2'_alpha3 = "CAF" if `geo2'_alpha3 == "CF"
replace `geo2'_alpha3 = "LKA" if `geo2'_alpha3 == "LK"
replace `geo2'_alpha3 = "TCD" if `geo2'_alpha3 == "TD"
replace `geo2'_alpha3 = "CHL" if `geo2'_alpha3 == "CL"
replace `geo2'_alpha3 = "CHN" if `geo2'_alpha3 == "CN"
replace `geo2'_alpha3 = "TWN" if `geo2'_alpha3 == "TW"
replace `geo2'_alpha3 = "CXR" if `geo2'_alpha3 == "CX"
replace `geo2'_alpha3 = "CCK" if `geo2'_alpha3 == "CC"
replace `geo2'_alpha3 = "COL" if `geo2'_alpha3 == "CO"
replace `geo2'_alpha3 = "COM" if `geo2'_alpha3 == "KM"
replace `geo2'_alpha3 = "MYT" if `geo2'_alpha3 == "YT"
replace `geo2'_alpha3 = "COG" if `geo2'_alpha3 == "CG"
replace `geo2'_alpha3 = "COD" if `geo2'_alpha3 == "CD"
replace `geo2'_alpha3 = "COK" if `geo2'_alpha3 == "CK"
replace `geo2'_alpha3 = "CRI" if `geo2'_alpha3 == "CR"
replace `geo2'_alpha3 = "HRV" if `geo2'_alpha3 == "HR"
replace `geo2'_alpha3 = "CUB" if `geo2'_alpha3 == "CU"
replace `geo2'_alpha3 = "CYP" if `geo2'_alpha3 == "CY"
replace `geo2'_alpha3 = "CZE" if `geo2'_alpha3 == "CZ"
replace `geo2'_alpha3 = "BEN" if `geo2'_alpha3 == "BJ"
replace `geo2'_alpha3 = "DNK" if `geo2'_alpha3 == "DK"
replace `geo2'_alpha3 = "DMA" if `geo2'_alpha3 == "DM"
replace `geo2'_alpha3 = "DOM" if `geo2'_alpha3 == "DO"
replace `geo2'_alpha3 = "ECU" if `geo2'_alpha3 == "EC"
replace `geo2'_alpha3 = "SLV" if `geo2'_alpha3 == "SV"
replace `geo2'_alpha3 = "GNQ" if `geo2'_alpha3 == "GQ"
replace `geo2'_alpha3 = "ETH" if `geo2'_alpha3 == "ET"
replace `geo2'_alpha3 = "ERI" if `geo2'_alpha3 == "ER"
replace `geo2'_alpha3 = "EST" if `geo2'_alpha3 == "EE"
replace `geo2'_alpha3 = "FRO" if `geo2'_alpha3 == "FO"
replace `geo2'_alpha3 = "FLK" if `geo2'_alpha3 == "FK"
replace `geo2'_alpha3 = "SGS" if `geo2'_alpha3 == "GS"
replace `geo2'_alpha3 = "FJI" if `geo2'_alpha3 == "FJ"
replace `geo2'_alpha3 = "FIN" if `geo2'_alpha3 == "FI"
replace `geo2'_alpha3 = "ALA" if `geo2'_alpha3 == "AX"
replace `geo2'_alpha3 = "FRA" if `geo2'_alpha3 == "FR"
replace `geo2'_alpha3 = "GUF" if `geo2'_alpha3 == "GF"
replace `geo2'_alpha3 = "PYF" if `geo2'_alpha3 == "PF"
replace `geo2'_alpha3 = "ATF" if `geo2'_alpha3 == "TF"
replace `geo2'_alpha3 = "DJI" if `geo2'_alpha3 == "DJ"
replace `geo2'_alpha3 = "GAB" if `geo2'_alpha3 == "GA"
replace `geo2'_alpha3 = "GEO" if `geo2'_alpha3 == "GE"
replace `geo2'_alpha3 = "GMB" if `geo2'_alpha3 == "GM"
replace `geo2'_alpha3 = "PSE" if `geo2'_alpha3 == "PS"
replace `geo2'_alpha3 = "DEU" if `geo2'_alpha3 == "DE"
replace `geo2'_alpha3 = "GHA" if `geo2'_alpha3 == "GH"
replace `geo2'_alpha3 = "GIB" if `geo2'_alpha3 == "GI"
replace `geo2'_alpha3 = "KIR" if `geo2'_alpha3 == "KI"
replace `geo2'_alpha3 = "GRC" if `geo2'_alpha3 == "GR"
replace `geo2'_alpha3 = "GRL" if `geo2'_alpha3 == "GL"
replace `geo2'_alpha3 = "GRD" if `geo2'_alpha3 == "GD"
replace `geo2'_alpha3 = "GLP" if `geo2'_alpha3 == "GP"
replace `geo2'_alpha3 = "GUM" if `geo2'_alpha3 == "GU"
replace `geo2'_alpha3 = "GTM" if `geo2'_alpha3 == "GT"
replace `geo2'_alpha3 = "GIN" if `geo2'_alpha3 == "GN"
replace `geo2'_alpha3 = "GUY" if `geo2'_alpha3 == "GY"
replace `geo2'_alpha3 = "HTI" if `geo2'_alpha3 == "HT"
replace `geo2'_alpha3 = "HMD" if `geo2'_alpha3 == "HM"
replace `geo2'_alpha3 = "VAT" if `geo2'_alpha3 == "VA"
replace `geo2'_alpha3 = "HND" if `geo2'_alpha3 == "HN"
replace `geo2'_alpha3 = "HKG" if `geo2'_alpha3 == "HK"
replace `geo2'_alpha3 = "HUN" if `geo2'_alpha3 == "HU"
replace `geo2'_alpha3 = "ISL" if `geo2'_alpha3 == "IS"
replace `geo2'_alpha3 = "IND" if `geo2'_alpha3 == "IN"
replace `geo2'_alpha3 = "IDN" if `geo2'_alpha3 == "ID"
replace `geo2'_alpha3 = "IRN" if `geo2'_alpha3 == "IR"
replace `geo2'_alpha3 = "IRQ" if `geo2'_alpha3 == "IQ"
replace `geo2'_alpha3 = "IRL" if `geo2'_alpha3 == "IE"
replace `geo2'_alpha3 = "ISR" if `geo2'_alpha3 == "IL"
replace `geo2'_alpha3 = "ITA" if `geo2'_alpha3 == "IT"
replace `geo2'_alpha3 = "CIV" if `geo2'_alpha3 == "CI"
replace `geo2'_alpha3 = "JAM" if `geo2'_alpha3 == "JM"
replace `geo2'_alpha3 = "JPN" if `geo2'_alpha3 == "JP"
replace `geo2'_alpha3 = "KAZ" if `geo2'_alpha3 == "KZ"
replace `geo2'_alpha3 = "JOR" if `geo2'_alpha3 == "JO"
replace `geo2'_alpha3 = "KEN" if `geo2'_alpha3 == "KE"
replace `geo2'_alpha3 = "PRK" if `geo2'_alpha3 == "KP"
replace `geo2'_alpha3 = "KOR" if `geo2'_alpha3 == "KR"
replace `geo2'_alpha3 = "KWT" if `geo2'_alpha3 == "KW"
replace `geo2'_alpha3 = "KGZ" if `geo2'_alpha3 == "KG"
replace `geo2'_alpha3 = "LAO" if `geo2'_alpha3 == "LA"
replace `geo2'_alpha3 = "LBN" if `geo2'_alpha3 == "LB"
replace `geo2'_alpha3 = "LSO" if `geo2'_alpha3 == "LS"
replace `geo2'_alpha3 = "LVA" if `geo2'_alpha3 == "LV"
replace `geo2'_alpha3 = "LBR" if `geo2'_alpha3 == "LR"
replace `geo2'_alpha3 = "LBY" if `geo2'_alpha3 == "LY"
replace `geo2'_alpha3 = "LIE" if `geo2'_alpha3 == "LI"
replace `geo2'_alpha3 = "LTU" if `geo2'_alpha3 == "LT"
replace `geo2'_alpha3 = "LUX" if `geo2'_alpha3 == "LU"
replace `geo2'_alpha3 = "MAC" if `geo2'_alpha3 == "MO"
replace `geo2'_alpha3 = "MDG" if `geo2'_alpha3 == "MG"
replace `geo2'_alpha3 = "MWI" if `geo2'_alpha3 == "MW"
replace `geo2'_alpha3 = "MYS" if `geo2'_alpha3 == "MY"
replace `geo2'_alpha3 = "MDV" if `geo2'_alpha3 == "MV"
replace `geo2'_alpha3 = "MLI" if `geo2'_alpha3 == "ML"
replace `geo2'_alpha3 = "MLT" if `geo2'_alpha3 == "MT"
replace `geo2'_alpha3 = "MTQ" if `geo2'_alpha3 == "MQ"
replace `geo2'_alpha3 = "MRT" if `geo2'_alpha3 == "MR"
replace `geo2'_alpha3 = "MUS" if `geo2'_alpha3 == "MU"
replace `geo2'_alpha3 = "MEX" if `geo2'_alpha3 == "MX"
replace `geo2'_alpha3 = "MCO" if `geo2'_alpha3 == "MC"
replace `geo2'_alpha3 = "MNG" if `geo2'_alpha3 == "MN"
replace `geo2'_alpha3 = "MDA" if `geo2'_alpha3 == "MD"
replace `geo2'_alpha3 = "MNE" if `geo2'_alpha3 == "ME"
replace `geo2'_alpha3 = "MSR" if `geo2'_alpha3 == "MS"
replace `geo2'_alpha3 = "MAR" if `geo2'_alpha3 == "MA"
replace `geo2'_alpha3 = "MOZ" if `geo2'_alpha3 == "MZ"
replace `geo2'_alpha3 = "OMN" if `geo2'_alpha3 == "OM"
replace `geo2'_alpha3 = "NAM" if `geo2'_alpha3 == "NA"
replace `geo2'_alpha3 = "NRU" if `geo2'_alpha3 == "NR"
replace `geo2'_alpha3 = "NPL" if `geo2'_alpha3 == "NP"
replace `geo2'_alpha3 = "NLD" if `geo2'_alpha3 == "NL"
replace `geo2'_alpha3 = "CUW" if `geo2'_alpha3 == "CW"
replace `geo2'_alpha3 = "ABW" if `geo2'_alpha3 == "AW"
replace `geo2'_alpha3 = "SXM" if `geo2'_alpha3 == "SX"
replace `geo2'_alpha3 = "BES" if `geo2'_alpha3 == "BQ"
replace `geo2'_alpha3 = "NCL" if `geo2'_alpha3 == "NC"
replace `geo2'_alpha3 = "VUT" if `geo2'_alpha3 == "VU"
replace `geo2'_alpha3 = "NZL" if `geo2'_alpha3 == "NZ"
replace `geo2'_alpha3 = "NIC" if `geo2'_alpha3 == "NI"
replace `geo2'_alpha3 = "NER" if `geo2'_alpha3 == "NE"
replace `geo2'_alpha3 = "NGA" if `geo2'_alpha3 == "NG"
replace `geo2'_alpha3 = "NIU" if `geo2'_alpha3 == "NU"
replace `geo2'_alpha3 = "NFK" if `geo2'_alpha3 == "NF"
replace `geo2'_alpha3 = "NOR" if `geo2'_alpha3 == "NO"
replace `geo2'_alpha3 = "MNP" if `geo2'_alpha3 == "MP"
replace `geo2'_alpha3 = "UMI" if `geo2'_alpha3 == "UM"
replace `geo2'_alpha3 = "FSM" if `geo2'_alpha3 == "FM"
replace `geo2'_alpha3 = "MHL" if `geo2'_alpha3 == "MH"
replace `geo2'_alpha3 = "PLW" if `geo2'_alpha3 == "PW"
replace `geo2'_alpha3 = "PAK" if `geo2'_alpha3 == "PK"
replace `geo2'_alpha3 = "PAN" if `geo2'_alpha3 == "PA"
replace `geo2'_alpha3 = "PNG" if `geo2'_alpha3 == "PG"
replace `geo2'_alpha3 = "PRY" if `geo2'_alpha3 == "PY"
replace `geo2'_alpha3 = "PER" if `geo2'_alpha3 == "PE"
replace `geo2'_alpha3 = "PHL" if `geo2'_alpha3 == "PH"
replace `geo2'_alpha3 = "PCN" if `geo2'_alpha3 == "PN"
replace `geo2'_alpha3 = "POL" if `geo2'_alpha3 == "PL"
replace `geo2'_alpha3 = "PRT" if `geo2'_alpha3 == "PT"
replace `geo2'_alpha3 = "GNB" if `geo2'_alpha3 == "GW"
replace `geo2'_alpha3 = "TLS" if `geo2'_alpha3 == "TL"
replace `geo2'_alpha3 = "PRI" if `geo2'_alpha3 == "PR"
replace `geo2'_alpha3 = "QAT" if `geo2'_alpha3 == "QA"
replace `geo2'_alpha3 = "REU" if `geo2'_alpha3 == "RE"
replace `geo2'_alpha3 = "ROU" if `geo2'_alpha3 == "RO"
replace `geo2'_alpha3 = "RUS" if `geo2'_alpha3 == "RU"
replace `geo2'_alpha3 = "RWA" if `geo2'_alpha3 == "RW"
replace `geo2'_alpha3 = "BLM" if `geo2'_alpha3 == "BL"
replace `geo2'_alpha3 = "SHN" if `geo2'_alpha3 == "SH"
replace `geo2'_alpha3 = "KNA" if `geo2'_alpha3 == "KN"
replace `geo2'_alpha3 = "AIA" if `geo2'_alpha3 == "AI"
replace `geo2'_alpha3 = "LCA" if `geo2'_alpha3 == "LC"
replace `geo2'_alpha3 = "MAF" if `geo2'_alpha3 == "MF"
replace `geo2'_alpha3 = "SPM" if `geo2'_alpha3 == "PM"
replace `geo2'_alpha3 = "VCT" if `geo2'_alpha3 == "VC"
replace `geo2'_alpha3 = "SMR" if `geo2'_alpha3 == "SM"
replace `geo2'_alpha3 = "STP" if `geo2'_alpha3 == "ST"
replace `geo2'_alpha3 = "SAU" if `geo2'_alpha3 == "SA"
replace `geo2'_alpha3 = "SEN" if `geo2'_alpha3 == "SN"
replace `geo2'_alpha3 = "SRB" if `geo2'_alpha3 == "RS"
replace `geo2'_alpha3 = "SYC" if `geo2'_alpha3 == "SC"
replace `geo2'_alpha3 = "SLE" if `geo2'_alpha3 == "SL"
replace `geo2'_alpha3 = "SGP" if `geo2'_alpha3 == "SG"
replace `geo2'_alpha3 = "SVK" if `geo2'_alpha3 == "SK"
replace `geo2'_alpha3 = "VNM" if `geo2'_alpha3 == "VN"
replace `geo2'_alpha3 = "SVN" if `geo2'_alpha3 == "SI"
replace `geo2'_alpha3 = "SOM" if `geo2'_alpha3 == "SO"
replace `geo2'_alpha3 = "ZAF" if `geo2'_alpha3 == "ZA"
replace `geo2'_alpha3 = "ZWE" if `geo2'_alpha3 == "ZW"
replace `geo2'_alpha3 = "ESP" if `geo2'_alpha3 == "ES"
replace `geo2'_alpha3 = "SSD" if `geo2'_alpha3 == "SS"
replace `geo2'_alpha3 = "SDN" if `geo2'_alpha3 == "SD"
replace `geo2'_alpha3 = "ESH" if `geo2'_alpha3 == "EH"
replace `geo2'_alpha3 = "SUR" if `geo2'_alpha3 == "SR"
replace `geo2'_alpha3 = "SJM" if `geo2'_alpha3 == "SJ"
replace `geo2'_alpha3 = "SWZ" if `geo2'_alpha3 == "SZ"
replace `geo2'_alpha3 = "SWE" if `geo2'_alpha3 == "SE"
replace `geo2'_alpha3 = "CHE" if `geo2'_alpha3 == "CH"
replace `geo2'_alpha3 = "SYR" if `geo2'_alpha3 == "SY"
replace `geo2'_alpha3 = "TJK" if `geo2'_alpha3 == "TJ"
replace `geo2'_alpha3 = "THA" if `geo2'_alpha3 == "TH"
replace `geo2'_alpha3 = "TGO" if `geo2'_alpha3 == "TG"
replace `geo2'_alpha3 = "TKL" if `geo2'_alpha3 == "TK"
replace `geo2'_alpha3 = "TON" if `geo2'_alpha3 == "TO"
replace `geo2'_alpha3 = "TTO" if `geo2'_alpha3 == "TT"
replace `geo2'_alpha3 = "ARE" if `geo2'_alpha3 == "AE"
replace `geo2'_alpha3 = "TUN" if `geo2'_alpha3 == "TN"
replace `geo2'_alpha3 = "TUR" if `geo2'_alpha3 == "TR"
replace `geo2'_alpha3 = "TKM" if `geo2'_alpha3 == "TM"
replace `geo2'_alpha3 = "TCA" if `geo2'_alpha3 == "TC"
replace `geo2'_alpha3 = "TUV" if `geo2'_alpha3 == "TV"
replace `geo2'_alpha3 = "UGA" if `geo2'_alpha3 == "UG"
replace `geo2'_alpha3 = "UKR" if `geo2'_alpha3 == "UA"
replace `geo2'_alpha3 = "MKD" if `geo2'_alpha3 == "MK"
replace `geo2'_alpha3 = "EGY" if `geo2'_alpha3 == "EG"
replace `geo2'_alpha3 = "GBR" if `geo2'_alpha3 == "GB"
replace `geo2'_alpha3 = "GGY" if `geo2'_alpha3 == "GG"
replace `geo2'_alpha3 = "JEY" if `geo2'_alpha3 == "JE"
replace `geo2'_alpha3 = "IMN" if `geo2'_alpha3 == "IM"
replace `geo2'_alpha3 = "TZA" if `geo2'_alpha3 == "TZ"
replace `geo2'_alpha3 = "USA" if `geo2'_alpha3 == "US"
replace `geo2'_alpha3 = "VIR" if `geo2'_alpha3 == "VI"
replace `geo2'_alpha3 = "BFA" if `geo2'_alpha3 == "BF"
replace `geo2'_alpha3 = "URY" if `geo2'_alpha3 == "UY"
replace `geo2'_alpha3 = "UZB" if `geo2'_alpha3 == "UZ"
replace `geo2'_alpha3 = "VEN" if `geo2'_alpha3 == "VE"
replace `geo2'_alpha3 = "WLF" if `geo2'_alpha3 == "WF"
replace `geo2'_alpha3 = "WSM" if `geo2'_alpha3 == "WS"
replace `geo2'_alpha3 = "YEM" if `geo2'_alpha3 == "YE"
replace `geo2'_alpha3 = "ZMB" if `geo2'_alpha3 == "ZM"
}

**| Create Numeric if requested
* If original geo variable is already numeric, make it equal to original
if `originalisstring' == 0 & "`vargeonum'" == "vargeonum" cap replace `geo2'_num = `geo2'
* If original geo variable is not numeric, convert from String to Numeric
if `originalisstring' == 1 & "`vargeonum'" == "vargeonum" {
replace `geo2'_num = 4 if `geo2' == "AF"
replace `geo2'_num = 8 if `geo2' == "AL"
replace `geo2'_num = 10 if `geo2' == "AQ"
replace `geo2'_num = 12 if `geo2' == "DZ"
replace `geo2'_num = 16 if `geo2' == "AS"
replace `geo2'_num = 20 if `geo2' == "AD"
replace `geo2'_num = 24 if `geo2' == "AO"
replace `geo2'_num = 28 if `geo2' == "AG"
replace `geo2'_num = 31 if `geo2' == "AZ"
replace `geo2'_num = 32 if `geo2' == "AR"
replace `geo2'_num = 36 if `geo2' == "AU"
replace `geo2'_num = 40 if `geo2' == "AT"
replace `geo2'_num = 44 if `geo2' == "BS"
replace `geo2'_num = 48 if `geo2' == "BH"
replace `geo2'_num = 50 if `geo2' == "BD"
replace `geo2'_num = 51 if `geo2' == "AM"
replace `geo2'_num = 52 if `geo2' == "BB"
replace `geo2'_num = 56 if `geo2' == "BE"
replace `geo2'_num = 60 if `geo2' == "BM"
replace `geo2'_num = 64 if `geo2' == "BT"
replace `geo2'_num = 68 if `geo2' == "BO"
replace `geo2'_num = 70 if `geo2' == "BA"
replace `geo2'_num = 72 if `geo2' == "BW"
replace `geo2'_num = 74 if `geo2' == "BV"
replace `geo2'_num = 76 if `geo2' == "BR"
replace `geo2'_num = 84 if `geo2' == "BZ"
replace `geo2'_num = 86 if `geo2' == "IO"
replace `geo2'_num = 90 if `geo2' == "SB"
replace `geo2'_num = 92 if `geo2' == "VG"
replace `geo2'_num = 96 if `geo2' == "BN"
replace `geo2'_num = 100 if `geo2' == "BG"
replace `geo2'_num = 104 if `geo2' == "MM"
replace `geo2'_num = 108 if `geo2' == "BI"
replace `geo2'_num = 112 if `geo2' == "BY"
replace `geo2'_num = 116 if `geo2' == "KH"
replace `geo2'_num = 120 if `geo2' == "CM"
replace `geo2'_num = 124 if `geo2' == "CA"
replace `geo2'_num = 132 if `geo2' == "CV"
replace `geo2'_num = 136 if `geo2' == "KY"
replace `geo2'_num = 140 if `geo2' == "CF"
replace `geo2'_num = 144 if `geo2' == "LK"
replace `geo2'_num = 148 if `geo2' == "TD"
replace `geo2'_num = 152 if `geo2' == "CL"
replace `geo2'_num = 156 if `geo2' == "CN"
replace `geo2'_num = 158 if `geo2' == "TW"
replace `geo2'_num = 162 if `geo2' == "CX"
replace `geo2'_num = 166 if `geo2' == "CC"
replace `geo2'_num = 170 if `geo2' == "CO"
replace `geo2'_num = 174 if `geo2' == "KM"
replace `geo2'_num = 175 if `geo2' == "YT"
replace `geo2'_num = 178 if `geo2' == "CG"
replace `geo2'_num = 180 if `geo2' == "CD"
replace `geo2'_num = 184 if `geo2' == "CK"
replace `geo2'_num = 188 if `geo2' == "CR"
replace `geo2'_num = 191 if `geo2' == "HR"
replace `geo2'_num = 192 if `geo2' == "CU"
replace `geo2'_num = 196 if `geo2' == "CY"
replace `geo2'_num = 203 if `geo2' == "CZ"
replace `geo2'_num = 204 if `geo2' == "BJ"
replace `geo2'_num = 208 if `geo2' == "DK"
replace `geo2'_num = 212 if `geo2' == "DM"
replace `geo2'_num = 214 if `geo2' == "DO"
replace `geo2'_num = 218 if `geo2' == "EC"
replace `geo2'_num = 222 if `geo2' == "SV"
replace `geo2'_num = 226 if `geo2' == "GQ"
replace `geo2'_num = 231 if `geo2' == "ET"
replace `geo2'_num = 232 if `geo2' == "ER"
replace `geo2'_num = 233 if `geo2' == "EE"
replace `geo2'_num = 234 if `geo2' == "FO"
replace `geo2'_num = 238 if `geo2' == "FK"
replace `geo2'_num = 239 if `geo2' == "GS"
replace `geo2'_num = 242 if `geo2' == "FJ"
replace `geo2'_num = 246 if `geo2' == "FI"
replace `geo2'_num = 248 if `geo2' == "AX"
replace `geo2'_num = 250 if `geo2' == "FR"
replace `geo2'_num = 254 if `geo2' == "GF"
replace `geo2'_num = 258 if `geo2' == "PF"
replace `geo2'_num = 260 if `geo2' == "TF"
replace `geo2'_num = 262 if `geo2' == "DJ"
replace `geo2'_num = 266 if `geo2' == "GA"
replace `geo2'_num = 268 if `geo2' == "GE"
replace `geo2'_num = 270 if `geo2' == "GM"
replace `geo2'_num = 275 if `geo2' == "PS"
replace `geo2'_num = 276 if `geo2' == "DE"
replace `geo2'_num = 288 if `geo2' == "GH"
replace `geo2'_num = 292 if `geo2' == "GI"
replace `geo2'_num = 296 if `geo2' == "KI"
replace `geo2'_num = 300 if `geo2' == "GR"
replace `geo2'_num = 304 if `geo2' == "GL"
replace `geo2'_num = 308 if `geo2' == "GD"
replace `geo2'_num = 312 if `geo2' == "GP"
replace `geo2'_num = 316 if `geo2' == "GU"
replace `geo2'_num = 320 if `geo2' == "GT"
replace `geo2'_num = 324 if `geo2' == "GN"
replace `geo2'_num = 328 if `geo2' == "GY"
replace `geo2'_num = 332 if `geo2' == "HT"
replace `geo2'_num = 334 if `geo2' == "HM"
replace `geo2'_num = 336 if `geo2' == "VA"
replace `geo2'_num = 340 if `geo2' == "HN"
replace `geo2'_num = 344 if `geo2' == "HK"
replace `geo2'_num = 348 if `geo2' == "HU"
replace `geo2'_num = 352 if `geo2' == "IS"
replace `geo2'_num = 356 if `geo2' == "IN"
replace `geo2'_num = 360 if `geo2' == "ID"
replace `geo2'_num = 364 if `geo2' == "IR"
replace `geo2'_num = 368 if `geo2' == "IQ"
replace `geo2'_num = 372 if `geo2' == "IE"
replace `geo2'_num = 376 if `geo2' == "IL"
replace `geo2'_num = 380 if `geo2' == "IT"
replace `geo2'_num = 384 if `geo2' == "CI"
replace `geo2'_num = 388 if `geo2' == "JM"
replace `geo2'_num = 392 if `geo2' == "JP"
replace `geo2'_num = 398 if `geo2' == "KZ"
replace `geo2'_num = 400 if `geo2' == "JO"
replace `geo2'_num = 404 if `geo2' == "KE"
replace `geo2'_num = 408 if `geo2' == "KP"
replace `geo2'_num = 410 if `geo2' == "KR"
replace `geo2'_num = 414 if `geo2' == "KW"
replace `geo2'_num = 417 if `geo2' == "KG"
replace `geo2'_num = 418 if `geo2' == "LA"
replace `geo2'_num = 422 if `geo2' == "LB"
replace `geo2'_num = 426 if `geo2' == "LS"
replace `geo2'_num = 428 if `geo2' == "LV"
replace `geo2'_num = 430 if `geo2' == "LR"
replace `geo2'_num = 434 if `geo2' == "LY"
replace `geo2'_num = 438 if `geo2' == "LI"
replace `geo2'_num = 440 if `geo2' == "LT"
replace `geo2'_num = 442 if `geo2' == "LU"
replace `geo2'_num = 446 if `geo2' == "MO"
replace `geo2'_num = 450 if `geo2' == "MG"
replace `geo2'_num = 454 if `geo2' == "MW"
replace `geo2'_num = 458 if `geo2' == "MY"
replace `geo2'_num = 462 if `geo2' == "MV"
replace `geo2'_num = 466 if `geo2' == "ML"
replace `geo2'_num = 470 if `geo2' == "MT"
replace `geo2'_num = 474 if `geo2' == "MQ"
replace `geo2'_num = 478 if `geo2' == "MR"
replace `geo2'_num = 480 if `geo2' == "MU"
replace `geo2'_num = 484 if `geo2' == "MX"
replace `geo2'_num = 492 if `geo2' == "MC"
replace `geo2'_num = 496 if `geo2' == "MN"
replace `geo2'_num = 498 if `geo2' == "MD"
replace `geo2'_num = 499 if `geo2' == "ME"
replace `geo2'_num = 500 if `geo2' == "MS"
replace `geo2'_num = 504 if `geo2' == "MA"
replace `geo2'_num = 508 if `geo2' == "MZ"
replace `geo2'_num = 512 if `geo2' == "OM"
replace `geo2'_num = 516 if `geo2' == "NA"
replace `geo2'_num = 520 if `geo2' == "NR"
replace `geo2'_num = 524 if `geo2' == "NP"
replace `geo2'_num = 528 if `geo2' == "NL"
replace `geo2'_num = 531 if `geo2' == "CW"
replace `geo2'_num = 533 if `geo2' == "AW"
replace `geo2'_num = 534 if `geo2' == "SX"
replace `geo2'_num = 535 if `geo2' == "BQ"
replace `geo2'_num = 540 if `geo2' == "NC"
replace `geo2'_num = 548 if `geo2' == "VU"
replace `geo2'_num = 554 if `geo2' == "NZ"
replace `geo2'_num = 558 if `geo2' == "NI"
replace `geo2'_num = 562 if `geo2' == "NE"
replace `geo2'_num = 566 if `geo2' == "NG"
replace `geo2'_num = 570 if `geo2' == "NU"
replace `geo2'_num = 574 if `geo2' == "NF"
replace `geo2'_num = 578 if `geo2' == "NO"
replace `geo2'_num = 580 if `geo2' == "MP"
replace `geo2'_num = 581 if `geo2' == "UM"
replace `geo2'_num = 583 if `geo2' == "FM"
replace `geo2'_num = 584 if `geo2' == "MH"
replace `geo2'_num = 585 if `geo2' == "PW"
replace `geo2'_num = 586 if `geo2' == "PK"
replace `geo2'_num = 591 if `geo2' == "PA"
replace `geo2'_num = 598 if `geo2' == "PG"
replace `geo2'_num = 600 if `geo2' == "PY"
replace `geo2'_num = 604 if `geo2' == "PE"
replace `geo2'_num = 608 if `geo2' == "PH"
replace `geo2'_num = 612 if `geo2' == "PN"
replace `geo2'_num = 616 if `geo2' == "PL"
replace `geo2'_num = 620 if `geo2' == "PT"
replace `geo2'_num = 624 if `geo2' == "GW"
replace `geo2'_num = 626 if `geo2' == "TL"
replace `geo2'_num = 630 if `geo2' == "PR"
replace `geo2'_num = 634 if `geo2' == "QA"
replace `geo2'_num = 638 if `geo2' == "RE"
replace `geo2'_num = 642 if `geo2' == "RO"
replace `geo2'_num = 643 if `geo2' == "RU"
replace `geo2'_num = 646 if `geo2' == "RW"
replace `geo2'_num = 652 if `geo2' == "BL"
replace `geo2'_num = 654 if `geo2' == "SH"
replace `geo2'_num = 659 if `geo2' == "KN"
replace `geo2'_num = 660 if `geo2' == "AI"
replace `geo2'_num = 662 if `geo2' == "LC"
replace `geo2'_num = 663 if `geo2' == "MF"
replace `geo2'_num = 666 if `geo2' == "PM"
replace `geo2'_num = 670 if `geo2' == "VC"
replace `geo2'_num = 674 if `geo2' == "SM"
replace `geo2'_num = 678 if `geo2' == "ST"
replace `geo2'_num = 682 if `geo2' == "SA"
replace `geo2'_num = 686 if `geo2' == "SN"
replace `geo2'_num = 688 if `geo2' == "RS"
replace `geo2'_num = 690 if `geo2' == "SC"
replace `geo2'_num = 694 if `geo2' == "SL"
replace `geo2'_num = 702 if `geo2' == "SG"
replace `geo2'_num = 703 if `geo2' == "SK"
replace `geo2'_num = 704 if `geo2' == "VN"
replace `geo2'_num = 705 if `geo2' == "SI"
replace `geo2'_num = 706 if `geo2' == "SO"
replace `geo2'_num = 710 if `geo2' == "ZA"
replace `geo2'_num = 716 if `geo2' == "ZW"
replace `geo2'_num = 724 if `geo2' == "ES"
replace `geo2'_num = 728 if `geo2' == "SS"
replace `geo2'_num = 729 if `geo2' == "SD"
replace `geo2'_num = 732 if `geo2' == "EH"
replace `geo2'_num = 740 if `geo2' == "SR"
replace `geo2'_num = 744 if `geo2' == "SJ"
replace `geo2'_num = 748 if `geo2' == "SZ"
replace `geo2'_num = 752 if `geo2' == "SE"
replace `geo2'_num = 756 if `geo2' == "CH"
replace `geo2'_num = 760 if `geo2' == "SY"
replace `geo2'_num = 762 if `geo2' == "TJ"
replace `geo2'_num = 764 if `geo2' == "TH"
replace `geo2'_num = 768 if `geo2' == "TG"
replace `geo2'_num = 772 if `geo2' == "TK"
replace `geo2'_num = 776 if `geo2' == "TO"
replace `geo2'_num = 780 if `geo2' == "TT"
replace `geo2'_num = 784 if `geo2' == "AE"
replace `geo2'_num = 788 if `geo2' == "TN"
replace `geo2'_num = 792 if `geo2' == "TR"
replace `geo2'_num = 795 if `geo2' == "TM"
replace `geo2'_num = 796 if `geo2' == "TC"
replace `geo2'_num = 798 if `geo2' == "TV"
replace `geo2'_num = 800 if `geo2' == "UG"
replace `geo2'_num = 804 if `geo2' == "UA"
replace `geo2'_num = 807 if `geo2' == "MK"
replace `geo2'_num = 818 if `geo2' == "EG"
replace `geo2'_num = 826 if `geo2' == "GB"
replace `geo2'_num = 831 if `geo2' == "GG"
replace `geo2'_num = 832 if `geo2' == "JE"
replace `geo2'_num = 833 if `geo2' == "IM"
replace `geo2'_num = 834 if `geo2' == "TZ"
replace `geo2'_num = 840 if `geo2' == "US"
replace `geo2'_num = 850 if `geo2' == "VI"
replace `geo2'_num = 854 if `geo2' == "BF"
replace `geo2'_num = 858 if `geo2' == "UY"
replace `geo2'_num = 860 if `geo2' == "UZ"
replace `geo2'_num = 862 if `geo2' == "VE"
replace `geo2'_num = 876 if `geo2' == "WF"
replace `geo2'_num = 882 if `geo2' == "WS"
replace `geo2'_num = 887 if `geo2' == "YE"
replace `geo2'_num = 894 if `geo2' == "ZM"
replace `geo2'_num = 1278 if `geo2' == "DD"
replace `geo2'_num = 1280 if `geo2' == "DEW"
replace `geo2'_num = 1810 if `geo2' == "SU"
replace `geo2'_num = 1810 if `geo2' == "SU"
replace `geo2'_num = 1890 if `geo2' == "YU"
replace `geo2'_num = 300 if `geo2' == "EL"
replace `geo2'_num = 826 if `geo2' == "UK"
replace `geo2'_num = 1 if `geo2' == "WLD"
replace `geo2'_num = 4 if `geo2' == "AFG"
replace `geo2'_num = 8 if `geo2' == "ALB"
replace `geo2'_num = 10 if `geo2' == "ATA"
replace `geo2'_num = 12 if `geo2' == "DZA"
replace `geo2'_num = 16 if `geo2' == "ASM"
replace `geo2'_num = 20 if `geo2' == "AND"
replace `geo2'_num = 24 if `geo2' == "AGO"
replace `geo2'_num = 28 if `geo2' == "ATG"
replace `geo2'_num = 31 if `geo2' == "AZE"
replace `geo2'_num = 32 if `geo2' == "ARG"
replace `geo2'_num = 36 if `geo2' == "AUS"
replace `geo2'_num = 40 if `geo2' == "AUT"
replace `geo2'_num = 44 if `geo2' == "BHS"
replace `geo2'_num = 48 if `geo2' == "BHR"
replace `geo2'_num = 50 if `geo2' == "BGD"
replace `geo2'_num = 51 if `geo2' == "ARM"
replace `geo2'_num = 52 if `geo2' == "BRB"
replace `geo2'_num = 56 if `geo2' == "BEL"
replace `geo2'_num = 60 if `geo2' == "BMU"
replace `geo2'_num = 64 if `geo2' == "BTN"
replace `geo2'_num = 68 if `geo2' == "BOL"
replace `geo2'_num = 70 if `geo2' == "BIH"
replace `geo2'_num = 72 if `geo2' == "BWA"
replace `geo2'_num = 74 if `geo2' == "BVT"
replace `geo2'_num = 76 if `geo2' == "BRA"
replace `geo2'_num = 84 if `geo2' == "BLZ"
replace `geo2'_num = 86 if `geo2' == "IOT"
replace `geo2'_num = 90 if `geo2' == "SLB"
replace `geo2'_num = 92 if `geo2' == "VGB"
replace `geo2'_num = 96 if `geo2' == "BRN"
replace `geo2'_num = 100 if `geo2' == "BGR"
replace `geo2'_num = 104 if `geo2' == "MMR"
replace `geo2'_num = 108 if `geo2' == "BDI"
replace `geo2'_num = 112 if `geo2' == "BLR"
replace `geo2'_num = 116 if `geo2' == "KHM"
replace `geo2'_num = 120 if `geo2' == "CMR"
replace `geo2'_num = 124 if `geo2' == "CAN"
replace `geo2'_num = 132 if `geo2' == "CPV"
replace `geo2'_num = 136 if `geo2' == "CYM"
replace `geo2'_num = 140 if `geo2' == "CAF"
replace `geo2'_num = 144 if `geo2' == "LKA"
replace `geo2'_num = 148 if `geo2' == "TCD"
replace `geo2'_num = 152 if `geo2' == "CHL"
replace `geo2'_num = 156 if `geo2' == "CHN"
replace `geo2'_num = 158 if `geo2' == "TWN"
replace `geo2'_num = 162 if `geo2' == "CXR"
replace `geo2'_num = 166 if `geo2' == "CCK"
replace `geo2'_num = 170 if `geo2' == "COL"
replace `geo2'_num = 174 if `geo2' == "COM"
replace `geo2'_num = 175 if `geo2' == "MYT"
replace `geo2'_num = 178 if `geo2' == "COG"
replace `geo2'_num = 180 if `geo2' == "COD"
replace `geo2'_num = 184 if `geo2' == "COK"
replace `geo2'_num = 188 if `geo2' == "CRI"
replace `geo2'_num = 191 if `geo2' == "HRV"
replace `geo2'_num = 192 if `geo2' == "CUB"
replace `geo2'_num = 196 if `geo2' == "CYP"
replace `geo2'_num = 203 if `geo2' == "CZE"
replace `geo2'_num = 204 if `geo2' == "BEN"
replace `geo2'_num = 208 if `geo2' == "DNK"
replace `geo2'_num = 212 if `geo2' == "DMA"
replace `geo2'_num = 214 if `geo2' == "DOM"
replace `geo2'_num = 218 if `geo2' == "ECU"
replace `geo2'_num = 222 if `geo2' == "SLV"
replace `geo2'_num = 226 if `geo2' == "GNQ"
replace `geo2'_num = 231 if `geo2' == "ETH"
replace `geo2'_num = 232 if `geo2' == "ERI"
replace `geo2'_num = 233 if `geo2' == "EST"
replace `geo2'_num = 234 if `geo2' == "FRO"
replace `geo2'_num = 238 if `geo2' == "FLK"
replace `geo2'_num = 239 if `geo2' == "SGS"
replace `geo2'_num = 242 if `geo2' == "FJI"
replace `geo2'_num = 246 if `geo2' == "FIN"
replace `geo2'_num = 248 if `geo2' == "ALA"
replace `geo2'_num = 250 if `geo2' == "FRA"
replace `geo2'_num = 254 if `geo2' == "GUF"
replace `geo2'_num = 258 if `geo2' == "PYF"
replace `geo2'_num = 260 if `geo2' == "ATF"
replace `geo2'_num = 262 if `geo2' == "DJI"
replace `geo2'_num = 266 if `geo2' == "GAB"
replace `geo2'_num = 268 if `geo2' == "GEO"
replace `geo2'_num = 270 if `geo2' == "GMB"
replace `geo2'_num = 275 if `geo2' == "PSE"
replace `geo2'_num = 276 if `geo2' == "DEU"
replace `geo2'_num = 288 if `geo2' == "GHA"
replace `geo2'_num = 292 if `geo2' == "GIB"
replace `geo2'_num = 296 if `geo2' == "KIR"
replace `geo2'_num = 300 if `geo2' == "GRC"
replace `geo2'_num = 304 if `geo2' == "GRL"
replace `geo2'_num = 308 if `geo2' == "GRD"
replace `geo2'_num = 312 if `geo2' == "GLP"
replace `geo2'_num = 316 if `geo2' == "GUM"
replace `geo2'_num = 320 if `geo2' == "GTM"
replace `geo2'_num = 324 if `geo2' == "GIN"
replace `geo2'_num = 328 if `geo2' == "GUY"
replace `geo2'_num = 332 if `geo2' == "HTI"
replace `geo2'_num = 334 if `geo2' == "HMD"
replace `geo2'_num = 336 if `geo2' == "VAT"
replace `geo2'_num = 340 if `geo2' == "HND"
replace `geo2'_num = 344 if `geo2' == "HKG"
replace `geo2'_num = 348 if `geo2' == "HUN"
replace `geo2'_num = 352 if `geo2' == "ISL"
replace `geo2'_num = 356 if `geo2' == "IND"
replace `geo2'_num = 360 if `geo2' == "IDN"
replace `geo2'_num = 364 if `geo2' == "IRN"
replace `geo2'_num = 368 if `geo2' == "IRQ"
replace `geo2'_num = 372 if `geo2' == "IRL"
replace `geo2'_num = 376 if `geo2' == "ISR"
replace `geo2'_num = 380 if `geo2' == "ITA"
replace `geo2'_num = 384 if `geo2' == "CIV"
replace `geo2'_num = 388 if `geo2' == "JAM"
replace `geo2'_num = 392 if `geo2' == "JPN"
replace `geo2'_num = 398 if `geo2' == "KAZ"
replace `geo2'_num = 400 if `geo2' == "JOR"
replace `geo2'_num = 404 if `geo2' == "KEN"
replace `geo2'_num = 408 if `geo2' == "PRK"
replace `geo2'_num = 410 if `geo2' == "KOR"
replace `geo2'_num = 414 if `geo2' == "KWT"
replace `geo2'_num = 417 if `geo2' == "KGZ"
replace `geo2'_num = 418 if `geo2' == "LAO"
replace `geo2'_num = 422 if `geo2' == "LBN"
replace `geo2'_num = 426 if `geo2' == "LSO"
replace `geo2'_num = 428 if `geo2' == "LVA"
replace `geo2'_num = 430 if `geo2' == "LBR"
replace `geo2'_num = 434 if `geo2' == "LBY"
replace `geo2'_num = 438 if `geo2' == "LIE"
replace `geo2'_num = 440 if `geo2' == "LTU"
replace `geo2'_num = 442 if `geo2' == "LUX"
replace `geo2'_num = 446 if `geo2' == "MAC"
replace `geo2'_num = 450 if `geo2' == "MDG"
replace `geo2'_num = 454 if `geo2' == "MWI"
replace `geo2'_num = 458 if `geo2' == "MYS"
replace `geo2'_num = 462 if `geo2' == "MDV"
replace `geo2'_num = 466 if `geo2' == "MLI"
replace `geo2'_num = 470 if `geo2' == "MLT"
replace `geo2'_num = 474 if `geo2' == "MTQ"
replace `geo2'_num = 478 if `geo2' == "MRT"
replace `geo2'_num = 480 if `geo2' == "MUS"
replace `geo2'_num = 484 if `geo2' == "MEX"
replace `geo2'_num = 492 if `geo2' == "MCO"
replace `geo2'_num = 496 if `geo2' == "MNG"
replace `geo2'_num = 498 if `geo2' == "MDA"
replace `geo2'_num = 499 if `geo2' == "MNE"
replace `geo2'_num = 500 if `geo2' == "MSR"
replace `geo2'_num = 504 if `geo2' == "MAR"
replace `geo2'_num = 508 if `geo2' == "MOZ"
replace `geo2'_num = 512 if `geo2' == "OMN"
replace `geo2'_num = 516 if `geo2' == "NAM"
replace `geo2'_num = 520 if `geo2' == "NRU"
replace `geo2'_num = 524 if `geo2' == "NPL"
replace `geo2'_num = 528 if `geo2' == "NLD"
replace `geo2'_num = 531 if `geo2' == "CUW"
replace `geo2'_num = 533 if `geo2' == "ABW"
replace `geo2'_num = 534 if `geo2' == "SXM"
replace `geo2'_num = 535 if `geo2' == "BES"
replace `geo2'_num = 540 if `geo2' == "NCL"
replace `geo2'_num = 548 if `geo2' == "VUT"
replace `geo2'_num = 554 if `geo2' == "NZL"
replace `geo2'_num = 558 if `geo2' == "NIC"
replace `geo2'_num = 562 if `geo2' == "NER"
replace `geo2'_num = 566 if `geo2' == "NGA"
replace `geo2'_num = 570 if `geo2' == "NIU"
replace `geo2'_num = 574 if `geo2' == "NFK"
replace `geo2'_num = 578 if `geo2' == "NOR"
replace `geo2'_num = 580 if `geo2' == "MNP"
replace `geo2'_num = 581 if `geo2' == "UMI"
replace `geo2'_num = 583 if `geo2' == "FSM"
replace `geo2'_num = 584 if `geo2' == "MHL"
replace `geo2'_num = 585 if `geo2' == "PLW"
replace `geo2'_num = 586 if `geo2' == "PAK"
replace `geo2'_num = 591 if `geo2' == "PAN"
replace `geo2'_num = 598 if `geo2' == "PNG"
replace `geo2'_num = 600 if `geo2' == "PRY"
replace `geo2'_num = 604 if `geo2' == "PER"
replace `geo2'_num = 608 if `geo2' == "PHL"
replace `geo2'_num = 612 if `geo2' == "PCN"
replace `geo2'_num = 616 if `geo2' == "POL"
replace `geo2'_num = 620 if `geo2' == "PRT"
replace `geo2'_num = 624 if `geo2' == "GNB"
replace `geo2'_num = 626 if `geo2' == "TLS"
replace `geo2'_num = 630 if `geo2' == "PRI"
replace `geo2'_num = 634 if `geo2' == "QAT"
replace `geo2'_num = 638 if `geo2' == "REU"
replace `geo2'_num = 642 if `geo2' == "ROU"
replace `geo2'_num = 643 if `geo2' == "RUS"
replace `geo2'_num = 646 if `geo2' == "RWA"
replace `geo2'_num = 652 if `geo2' == "BLM"
replace `geo2'_num = 654 if `geo2' == "SHN"
replace `geo2'_num = 659 if `geo2' == "KNA"
replace `geo2'_num = 660 if `geo2' == "AIA"
replace `geo2'_num = 662 if `geo2' == "LCA"
replace `geo2'_num = 663 if `geo2' == "MAF"
replace `geo2'_num = 666 if `geo2' == "SPM"
replace `geo2'_num = 670 if `geo2' == "VCT"
replace `geo2'_num = 674 if `geo2' == "SMR"
replace `geo2'_num = 678 if `geo2' == "STP"
replace `geo2'_num = 682 if `geo2' == "SAU"
replace `geo2'_num = 686 if `geo2' == "SEN"
replace `geo2'_num = 688 if `geo2' == "SRB"
replace `geo2'_num = 690 if `geo2' == "SYC"
replace `geo2'_num = 694 if `geo2' == "SLE"
replace `geo2'_num = 702 if `geo2' == "SGP"
replace `geo2'_num = 703 if `geo2' == "SVK"
replace `geo2'_num = 704 if `geo2' == "VNM"
replace `geo2'_num = 705 if `geo2' == "SVN"
replace `geo2'_num = 706 if `geo2' == "SOM"
replace `geo2'_num = 710 if `geo2' == "ZAF"
replace `geo2'_num = 716 if `geo2' == "ZWE"
replace `geo2'_num = 724 if `geo2' == "ESP"
replace `geo2'_num = 728 if `geo2' == "SSD"
replace `geo2'_num = 729 if `geo2' == "SDN"
replace `geo2'_num = 732 if `geo2' == "ESH"
replace `geo2'_num = 740 if `geo2' == "SUR"
replace `geo2'_num = 744 if `geo2' == "SJM"
replace `geo2'_num = 748 if `geo2' == "SWZ"
replace `geo2'_num = 752 if `geo2' == "SWE"
replace `geo2'_num = 756 if `geo2' == "CHE"
replace `geo2'_num = 760 if `geo2' == "SYR"
replace `geo2'_num = 762 if `geo2' == "TJK"
replace `geo2'_num = 764 if `geo2' == "THA"
replace `geo2'_num = 768 if `geo2' == "TGO"
replace `geo2'_num = 772 if `geo2' == "TKL"
replace `geo2'_num = 776 if `geo2' == "TON"
replace `geo2'_num = 780 if `geo2' == "TTO"
replace `geo2'_num = 784 if `geo2' == "ARE"
replace `geo2'_num = 788 if `geo2' == "TUN"
replace `geo2'_num = 792 if `geo2' == "TUR"
replace `geo2'_num = 795 if `geo2' == "TKM"
replace `geo2'_num = 796 if `geo2' == "TCA"
replace `geo2'_num = 798 if `geo2' == "TUV"
replace `geo2'_num = 800 if `geo2' == "UGA"
replace `geo2'_num = 804 if `geo2' == "UKR"
replace `geo2'_num = 807 if `geo2' == "MKD"
replace `geo2'_num = 818 if `geo2' == "EGY"
replace `geo2'_num = 826 if `geo2' == "GBR"
replace `geo2'_num = 831 if `geo2' == "GGY"
replace `geo2'_num = 832 if `geo2' == "JEY"
replace `geo2'_num = 833 if `geo2' == "IMN"
replace `geo2'_num = 834 if `geo2' == "TZA"
replace `geo2'_num = 840 if `geo2' == "USA"
replace `geo2'_num = 850 if `geo2' == "VIR"
replace `geo2'_num = 854 if `geo2' == "BFA"
replace `geo2'_num = 858 if `geo2' == "URY"
replace `geo2'_num = 860 if `geo2' == "UZB"
replace `geo2'_num = 862 if `geo2' == "VEN"
replace `geo2'_num = 876 if `geo2' == "WLF"
replace `geo2'_num = 882 if `geo2' == "WSM"
replace `geo2'_num = 887 if `geo2' == "YEM"
replace `geo2'_num = 894 if `geo2' == "ZMB"
replace `geo2'_num = 1200 if `geo2' == "CSHH"
replace `geo2'_num = 1278 if `geo2' == "DDDE"
replace `geo2'_num = 1280 if `geo2' == "DEW"
replace `geo2'_num = 1810 if `geo2' == "SOV"
replace `geo2'_num = 1810 if `geo2' == "SUHH"
replace `geo2'_num = 1810 if `geo2' == "USSR"
replace `geo2'_num = 1890 if `geo2' == "YUCS"
replace `geo2'_num = 300 if `geo2' == "GRC"
replace `geo2'_num = 826 if `geo2' == "GBR"
replace `geo2'_num = 2100 if `geo2' == "EU"
replace `geo2'_num = 2106 if `geo2' == "EU6"
replace `geo2'_num = 2109 if `geo2' == "EU9"
replace `geo2'_num = 2110 if `geo2' == "EU10"
replace `geo2'_num = 2112 if `geo2' == "EU12"
replace `geo2'_num = 2115 if `geo2' == "EU15"
replace `geo2'_num = 2125 if `geo2' == "EU25"
replace `geo2'_num = 2127 if `geo2' == "EU27"
replace `geo2'_num = 2128 if `geo2' == "EU28"
replace `geo2'_num = 2129 if `geo2' == "EU29"
replace `geo2'_num = 2130 if `geo2' == "EU30"
replace `geo2'_num = 2131 if `geo2' == "EU31"
replace `geo2'_num = 2132 if `geo2' == "EU32"
replace `geo2'_num = 2133 if `geo2' == "EU33"
replace `geo2'_num = 2134 if `geo2' == "EU34"
replace `geo2'_num = 2135 if `geo2' == "EU35"
replace `geo2'_num = 2150 if `geo2' == "EA"
replace `geo2'_num = 2161 if `geo2' == "EA11"
replace `geo2'_num = 2162 if `geo2' == "EA12"
replace `geo2'_num = 2163 if `geo2' == "EA13"
replace `geo2'_num = 2164 if `geo2' == "EA14"
replace `geo2'_num = 2165 if `geo2' == "EA15"
replace `geo2'_num = 2166 if `geo2' == "EA16"
replace `geo2'_num = 2167 if `geo2' == "EA17"
replace `geo2'_num = 2168 if `geo2' == "EA18"
replace `geo2'_num = 2169 if `geo2' == "EA19"
replace `geo2'_num = 2170 if `geo2' == "EA20"
replace `geo2'_num = 2171 if `geo2' == "EA21"
replace `geo2'_num = 2172 if `geo2' == "EA22"
replace `geo2'_num = 2173 if `geo2' == "EA23"
replace `geo2'_num = 2174 if `geo2' == "EA24"
replace `geo2'_num = 2175 if `geo2' == "EA25"
replace `geo2'_num = 2176 if `geo2' == "EA26"
replace `geo2'_num = 2177 if `geo2' == "EA27"
replace `geo2'_num = 2178 if `geo2' == "EA28"
replace `geo2'_num = 2179 if `geo2' == "EA29"
replace `geo2'_num = 2180 if `geo2' == "EA30"
replace `geo2'_num = 1000 if `geo2' == "FRME"
replace `geo2'_num = 2200 if `geo2' == "OTO"
replace `geo2'_num = 2201 if `geo2' == "OECD23"
replace `geo2'_num = 2203 if `geo2' == "PAC"
replace `geo2'_num = 2209 if `geo2' == "NMEC"
replace `geo2'_num = 2211 if `geo2' == "EUR"
replace `geo2'_num = 2231 if `geo2' == "RWD"
replace `geo2'_num = 2240 if `geo2' == "OIL"
replace `geo2'_num = 2241 if `geo2' == "OPEC"
replace `geo2'_num = 2242 if `geo2' == "OOP"
replace `geo2'_num = 2249 if `geo2' == "ROW"
replace `geo2'_num = 2260 if `geo2' == "DAE"
replace `geo2'_num = 2270 if `geo2' == "NAT"
replace `geo2'_num = 2280 if `geo2' == "GRPS"
replace `geo2'_num = 1 if `geo2' == "WLD"
}
if "`provider'" == "IMF" & ("`vargeonum'" == "vargeonum") {
	getdata_imf_num `geo2'
}
if "`vargeonum'" == "vargeonum" label values `geo2'_num country_iso_num

**| Set default geo variable
drop `geo2'
if "`isocountrycodes1'" == "alpha2" rename `geo2'_alpha2 `geo2'
if "`isocountrycodes1'" == "alpha3" rename `geo2'_alpha3 `geo2'
if "`isocountrycodes1'" == "num" rename `geo2'_num `geo2'
}



****************************************************
**||               Merge the Data               ||**
****************************************************

if "`structure'" == "cs" {
	if `N_init' > 0 {
		order _all, alpha
		order `geo2'
		tempfile temp_data
		qui save `temp_data', replace
		ds `geo2', not
		local check_new_var = "`r(varlist)'"
		restore
		cap drop _merge
		ds `geo2', not
		local check_restore = "`r(varlist)'"
		foreach variable of local check_new_var {
			cap ds `variable'
			if _rc == 0 {
				if "`update'" == "update" {
					di in red "WARNING: A variable named `variable' already existed and has been updated"
				}
				if "`replace'" == "replace" {
					di in red "WARNING: A variable named `variable' already existed and has been replaced"
					cap drop `variable'
				}
			}
		 }

**| merge options
		if "`update'" == "" & "`replace'" == "" {
			merge `merge' `geo2' using `temp_data', nogenerate force
			sort `geo2'
			order `geo2'
		}
		 if "`update'" == "update" {
			merge `merge' `geo2' using `temp_data', nogenerate force update
			sort `geo2'
			order `geo2'
		}
		if "`replace'" == "replace" {
			merge `merge' `geo2' using `temp_data', nogenerate force update replace
			sort `geo2'
			order `geo2'
		}
	}
	sort `geo2'
	order _all, alpha
	order `geo2'
}



if "`structure'" == "ts" {
	if `N_init' > 0 {
		order _all, alpha
		order `time2'
		tempfile temp_data
		qui save `temp_data', replace
		if "`datemask'" != "" {
			ds `time2' `time2'`frequency', not
		}
		if "`datemask'" == "" {
			ds `time2', not
		}
		local check_new_var = "`r(varlist)'"
		restore
		cap drop _merge
		cap ds `time2' `time2'`frequency', not
		if _rc != 0 ds `time2', not
		local check_restore = "`r(varlist)'"
		foreach variable of local check_new_var {
			cap ds `variable'
			if _rc == 0 {
				if "`update'" == "update" {
					di in red "WARNING: A variable named `variable' already existed and has been updated"
				}
				if "`replace'" == "replace" {
					di in red "WARNING: A variable named `variable' already existed and has been replaced"
					cap drop `variable'
				}
			}
		 }

**| merge options
		if "`update'" == "" & "`replace'" == "" {
			merge `merge' `time2' using `temp_data', nogenerate force
			sort `time2'
			order `time2'
		}
		if "`update'" == "update" {
			merge `merge' `time2' using `temp_data', nogenerate force update
			sort `time2'
			order `time2'
		}
		if "`replace'" == "replace" {
			merge `merge' `time2' using `temp_data', nogenerate force update replace
			sort `time2' 
			order `time2'
		}
	}
	sort `time2'
	order _all, alpha
	order `time2'
}


if "`structure'" == "xt" {
	if `N_init' > 0 {
		order _all, alpha
		order `time2' `geo2'
		tempfile temp_data
		qui save `temp_data', replace
		if "`datemask'" != "" {
			ds `geo2' `time2' `time2'`frequency', not
		}
		if "`datemask'" == "" {
			ds `geo2' `time2', not
		}
		local check_new_var = "`r(varlist)'"
		restore
		cap drop _merge
		cap ds `geo2' `time2' `time2'`frequency', not
		if _rc != 0 ds `geo2' `time2', not
		local check_restore = "`r(varlist)'"
		foreach variable of local check_new_var {
			cap ds `variable'
			if _rc == 0 {
				if "`update'" == "update" {
					di in red "WARNING: A variable named `variable' already existed and has been updated"
				}
				if "`replace'" == "replace" {
					di in red "WARNING: A variable named `variable' already existed and has been replaced"
					cap drop `variable'
				}
			}
		 }

**| merge options
		if "`update'" == "" & "`replace'" == "" {
			merge `merge' `time2' `geo2' using `temp_data', nogenerate force
			sort `geo2' `time2'
			order `geo2' `time2'
		}
		if "`update'" == "update" {
			merge `merge' `time2' `geo2' using `temp_data', nogenerate force update
			sort `geo2' `time2'
			order `geo2' `time2'
		}
		if "`replace'" == "replace" {
			merge `merge' `time2' `geo2' using `temp_data', nogenerate force update replace
			sort `geo2' `time2'
			order `geo2' `time2'
		}
	}
	sort `geo2' `time2'
	order _all, alpha
	order `geo2' `time2'
}




****************************************************
**||          Set Time Series or Panel          ||**
****************************************************

if "`structure'" == "ts" & "`set'" == "set" {
	if "`datemask'" == "" cap noisily tsset `time2'
	if "`datemask'" != "" cap noisily tsset `time2'`frequency'
}

if "`structure'" == "xt" & "`set'" == "set" {
	cap replace `geo2' = "testifstring" if `geo2' == "testifstring"
	if _rc == 0 {
		cap count if `geo2'_num == .
		if _rc != 0 di in red "WARNING: xtset requires a numeric geographical variable without any missing values. Check help getdata and the isocountrycodes(num) option."
		if _rc == 0 {
			if "`datemask'" == "" cap noisily xtset `geo2'_num `time2'
			if "`datemask'" != "" cap noisily xtset `geo2'_num `time2'`frequency'
			if _rc != 0 di in red "WARNING: Check whether `geo2'_num has any missing values; this would imply `geo2' has non-ISO codes. Either drop those obs or fill in the gaps to do xtset."
		}
	}
	if _rc != 0 {
		if "`datemask'" == "" cap noisily xtset `geo2' `time2'
		if "`datemask'" != "" cap noisily xtset `geo2' `time2'`frequency'
		if _rc != 0 di in red "WARNING: Check whether the geographical numeric variable has any missing values due to non-ISO codes by using isocountrycodes(alpha3 alpha2 num) instead of just isocountrycodes(num)."
	}
}

}
end
