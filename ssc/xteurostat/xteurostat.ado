/*	
	'XTEUROSTAT': module to import data from Eurostat in panel data structure
	Author: Duarte Goncalves (duarte.goncalves.dg@outlook.com)
	Last update: 20 May 2016
	Version 1.2
*/


cap program drop xteurostat
program define xteurostat
version 13
syntax namelist [, clear Geo(string) Time(string) ISOcountrynames Vname(string) Start(int 0) End(int 0) DATEMask(string) Date(string) path7zg(string) ]
quietly {
tokenize `namelist'
local nr_vars = wordcount("`namelist'")
forvalues num = 2/`nr_vars' {
	if substr("`3'",1,3) == "num" {
		local 3 = substr("`3'",4,.)
	}
}
if "`geo'" == "" {
local geo = "geo"
}
if "`time'" == "" {
local time = "time"
}
* Table of interest
local var "`1'" 
if c(os) == "Windows" & "`path7zg'" == "" {
local path7zg = "C:\Program Files\7-Zip\7zG.exe"
}
local valuevar_name "`vname'"


**| Errors |**
* -----------
if c(os) == "Windows" {
  capture confirm file "`path7zg'"
  if _rc==0 {
	noisily display in white "7-zip is installed on Windows."
  }
  else {
	noisily display in red "Install 7-zip here: C:\Program Files\7-Zip\7zG.exe, or specify path7zg(path_to_7zG\7zG.exe)."
	exit
  }
}
.

**| Clear data |**
* ----------------
if "`clear'" == "clear"{
	clear
}
local N_init = _N
if `N_init'>0 {
	preserve
}
.

**| See if data not already present |**
* ------------------------------------
cap erase `var'.tsv.gz
cap erase `var'.tsv
cap erase `var'_tmp.tsv

**| Download the data |**
* ----------------------
copy  "http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=data%2F`var'.tsv.gz" "`var'.tsv.gz", replace
if c(os) == "Windows" {
	*Verify that 7-Zip is in this folder
	shell "`path7zg'" x `var'.tsv.gz 
	erase `var'.tsv.gz
}
if c(os) == "MacOSX" | c(os) == "Unix" {
	shell gunzip `var'.tsv.gz
}
filefilter "`var'.tsv" "`var'_tmp.tsv", from(,) to(\t)
import delimited "`var'_tmp.tsv", delim(tab) varnames(1) clear
cap rename geotime `geo'
cap label var `geo' "`geo'"
ds
token "`r(varlist)'"
local nr_extracted = wordcount("`r(varlist)'")
forvalues variable = 1/`nr_extracted' {
	local var_label : variable label ``variable''
	if "`var_label'" != "" & "`var_label'" !=  "``variable''" {
		cap rename ``variable'' `varlabel'
		if _rc != 0 {
			rename ``variable'' v`variable'
		}
	}
	if "`var_label'" == "" {
		label var ``variable'' "``variable''"
	}
}

.

**| Erase working files |**
* ------------------------
erase `var'.tsv
erase `var'_tmp.tsv

**| Drop unwanted data |**
* ----------------------
tokenize `namelist'
cap ds v* `geo', not
if _rc != 0 ds v*, not
local dimensions_of_interest "`r(varlist)'"
foreach element of local dimensions_of_interest {
	cap tostring `element', replace force
}
foreach element of local dimensions_of_interest {
	replace `element' = subinstr(`element',"-","",.)
}
local nr_vars = wordcount("`namelist'")
forvalues dimension = 2/`nr_vars' {
	foreach element of local dimensions_of_interest {
	foreach element2 of local dimensions_of_interest {
		count if `element' == "``dimension''" & `element2' == "``dimension''"
		cap assert r(N) == 0
		if _rc != 0 & "`element'" != "`element2'" {
			di in red "There is more than one dimension with a value `dimension'"
			exit
		}
	}
	}
}
forvalues dimension = 2/`nr_vars' {
	foreach element of local dimensions_of_interest {
		count if `element' == "``dimension''"
		if r(N) != 0 drop if `element' != "``dimension''"
	}
}
.

**| Rename variables |**
* ---------------------
/* ignore flags */
foreach v of varlist v* {
	local x1 : variable label `v'
	local x2 = substr("`x1'",1,1)
	if "`x2'" == "0" rename `v' t_`x1'
	if "`x2'" == "1" rename `v' t_`x1'
	if "`x2'" == "2" rename `v' t_`x1'
	if "`x2'" == "3" rename `v' t_`x1'
	if "`x2'" == "4" rename `v' t_`x1'
	if "`x2'" == "5" rename `v' t_`x1'
	if "`x2'" == "6" rename `v' t_`x1'
	if "`x2'" == "7" rename `v' t_`x1'
	if "`x2'" == "8" rename `v' t_`x1'
	if "`x2'" == "9" rename `v' t_`x1'
	if "`x2'" != "0" & ///
		"`x2'" != "1" & /// 
		"`x2'" != "2" & ///
		"`x2'" != "3" & ///
		"`x2'" != "4" & ///
		"`x2'" != "5" & ///
		"`x2'" != "6" & ///
		"`x2'" != "7" & ///
		"`x2'" != "8" & ///
		"`x2'" != "9" rename `v' `x1'
}
.

**| Reshape to long format |**
* ---------------------------
destring t_*, replace force ignore("a b c d e f g h i j k l m n o p q r s t u v w x y z")
ds t_*, not
cap reshape long t_, i("`r(varlist)'") j(`time') s
cap label var `time' "`time'"
cap rename t_ value
cap order `geo' `time'

if "`start'" != "0" {
	drop if `time' < `start'
}

if "`end'" != "0" {
	drop if `time' > `end'
}


**| Reshape to panel data structure |**
* ------------------------------------

ds value `geo' `time', not
local varlist = "`r(varlist)'"
local varlistlen = wordcount("`varlist'")
token "`varlist'"
local maxchar = int((32-`varlistlen')/`varlistlen'-2)
local nvarlist = substr("`1'",1,`maxchar')
if `varlistlen' > 1 {
	forvalues varnum = 2/`varlistlen' {
		local varnumname = substr("``varnum''",1,`maxchar')
		local nvarlist = "`nvarlist'_`varnumname'"
	}
}
tempvar varlablist
gen `varlablist' = `1'
drop `1'
if `varlistlen' > 1 {
	forvalues varnum = 2/`varlistlen' {
		replace `varlablist' = `varlablist'+"_"+``varnum''
		drop ``varnum''
	}
}
rename value v
reshape wide v, i("`geo' `time'") j(`varlablist') string
	
foreach variable of varlist v* {
	local var_label : variable label `variable'
	local exclude " v"
	local var_label : list var_label - exclude
	label var `variable' "`var_label'"
	local rename_name = substr("`variable'",2,.)
	rename `variable' `rename_name'
}

ds `geo' `time', not
local nr_vars_final = wordcount("`r(varlist)'")
if "`valuevar_name'" != "" & `nr_vars_final' == 1 {
	rename `r(varlist)' `valuevar_name'
}
if "`valuevar_name'" != "" & `nr_vars_final' != 1 {
	cap nois di in red "WARNING: vname option ignored - there is more than one series extracted."
}

if "`isocountrynames'" != "" {
**| Country names |**
* ------------------------------------
replace `geo' = "AFG" if `geo' == "AF"
replace `geo' = "ALA" if `geo' == "AX"
replace `geo' = "ALB" if `geo' == "AL"
replace `geo' = "DZA" if `geo' == "DZ"
replace `geo' = "ASM" if `geo' == "AS"
replace `geo' = "AND" if `geo' == "AD"
replace `geo' = "AGO" if `geo' == "AO"
replace `geo' = "AIA" if `geo' == "AI"
replace `geo' = "ATA" if `geo' == "AQ"
replace `geo' = "ATG" if `geo' == "AG"
replace `geo' = "ARG" if `geo' == "AR"
replace `geo' = "ARM" if `geo' == "AM"
replace `geo' = "ABW" if `geo' == "AW"
replace `geo' = "AUS" if `geo' == "AU"
replace `geo' = "AUT" if `geo' == "AT"
replace `geo' = "AZE" if `geo' == "AZ"
replace `geo' = "BHS" if `geo' == "BS"
replace `geo' = "BHR" if `geo' == "BH"
replace `geo' = "BGD" if `geo' == "BD"
replace `geo' = "BRB" if `geo' == "BB"
replace `geo' = "BLR" if `geo' == "BY"
replace `geo' = "BEL" if `geo' == "BE"
replace `geo' = "BLZ" if `geo' == "BZ"
replace `geo' = "BEN" if `geo' == "BJ"
replace `geo' = "BMU" if `geo' == "BM"
replace `geo' = "BTN" if `geo' == "BT"
replace `geo' = "BOL" if `geo' == "BO"
replace `geo' = "BES" if `geo' == "BQ"
replace `geo' = "BIH" if `geo' == "BA"
replace `geo' = "BWA" if `geo' == "BW"
replace `geo' = "BVT" if `geo' == "BV"
replace `geo' = "BRA" if `geo' == "BR"
replace `geo' = "IOT" if `geo' == "IO"
replace `geo' = "BRN" if `geo' == "BN"
replace `geo' = "BGR" if `geo' == "BG"
replace `geo' = "BFA" if `geo' == "BF"
replace `geo' = "BDI" if `geo' == "BI"
replace `geo' = "KHM" if `geo' == "KH"
replace `geo' = "CMR" if `geo' == "CM"
replace `geo' = "CAN" if `geo' == "CA"
replace `geo' = "CPV" if `geo' == "CV"
replace `geo' = "CYM" if `geo' == "KY"
replace `geo' = "CAF" if `geo' == "CF"
replace `geo' = "TCD" if `geo' == "TD"
replace `geo' = "CHL" if `geo' == "CL"
replace `geo' = "CHN" if `geo' == "CN"
replace `geo' = "CXR" if `geo' == "CX"
replace `geo' = "CCK" if `geo' == "CC"
replace `geo' = "COL" if `geo' == "CO"
replace `geo' = "COM" if `geo' == "KM"
replace `geo' = "COG" if `geo' == "CG"
replace `geo' = "COD" if `geo' == "CD"
replace `geo' = "COK" if `geo' == "CK"
replace `geo' = "CRI" if `geo' == "CR"
replace `geo' = "CIV" if `geo' == "CI"
replace `geo' = "HRV" if `geo' == "HR"
replace `geo' = "CUB" if `geo' == "CU"
replace `geo' = "CUW" if `geo' == "CW"
replace `geo' = "CYP" if `geo' == "CY"
replace `geo' = "CZE" if `geo' == "CZ"
replace `geo' = "DNK" if `geo' == "DK"
replace `geo' = "DJI" if `geo' == "DJ"
replace `geo' = "DMA" if `geo' == "DM"
replace `geo' = "DOM" if `geo' == "DO"
replace `geo' = "ECU" if `geo' == "EC"
replace `geo' = "EGY" if `geo' == "EG"
replace `geo' = "SLV" if `geo' == "SV"
replace `geo' = "GNQ" if `geo' == "GQ"
replace `geo' = "ERI" if `geo' == "ER"
replace `geo' = "EST" if `geo' == "EE"
replace `geo' = "ETH" if `geo' == "ET"
replace `geo' = "FLK" if `geo' == "FK"
replace `geo' = "FRO" if `geo' == "FO"
replace `geo' = "FJI" if `geo' == "FJ"
replace `geo' = "FIN" if `geo' == "FI"
replace `geo' = "FRA" if `geo' == "FR"
replace `geo' = "GUF" if `geo' == "GF"
replace `geo' = "PYF" if `geo' == "PF"
replace `geo' = "ATF" if `geo' == "TF"
replace `geo' = "GAB" if `geo' == "GA"
replace `geo' = "GMB" if `geo' == "GM"
replace `geo' = "GEO" if `geo' == "GE"
replace `geo' = "DEU" if `geo' == "DE"
replace `geo' = "GHA" if `geo' == "GH"
replace `geo' = "GIB" if `geo' == "GI"
replace `geo' = "GRC" if `geo' == "GR" | `geo' == "EL" 
replace `geo' = "GRL" if `geo' == "GL"
replace `geo' = "GRD" if `geo' == "GD"
replace `geo' = "GLP" if `geo' == "GP"
replace `geo' = "GUM" if `geo' == "GU"
replace `geo' = "GTM" if `geo' == "GT"
replace `geo' = "GGY" if `geo' == "GG"
replace `geo' = "GIN" if `geo' == "GN"
replace `geo' = "GNB" if `geo' == "GW"
replace `geo' = "GUY" if `geo' == "GY"
replace `geo' = "HTI" if `geo' == "HT"
replace `geo' = "HMD" if `geo' == "HM"
replace `geo' = "VAT" if `geo' == "VA"
replace `geo' = "HND" if `geo' == "HN"
replace `geo' = "HKG" if `geo' == "HK"
replace `geo' = "HUN" if `geo' == "HU"
replace `geo' = "ISL" if `geo' == "IS"
replace `geo' = "IND" if `geo' == "IN"
replace `geo' = "IDN" if `geo' == "ID"
replace `geo' = "IRN" if `geo' == "IR"
replace `geo' = "IRQ" if `geo' == "IQ"
replace `geo' = "IRL" if `geo' == "IE"
replace `geo' = "IMN" if `geo' == "IM"
replace `geo' = "ISR" if `geo' == "IL"
replace `geo' = "ITA" if `geo' == "IT"
replace `geo' = "JAM" if `geo' == "JM"
replace `geo' = "JPN" if `geo' == "JP"
replace `geo' = "JEY" if `geo' == "JE"
replace `geo' = "JOR" if `geo' == "JO"
replace `geo' = "KAZ" if `geo' == "KZ"
replace `geo' = "KEN" if `geo' == "KE"
replace `geo' = "KIR" if `geo' == "KI"
replace `geo' = "PRK" if `geo' == "KP"
replace `geo' = "KOR" if `geo' == "KR"
replace `geo' = "KWT" if `geo' == "KW"
replace `geo' = "KGZ" if `geo' == "KG"
replace `geo' = "LAO" if `geo' == "LA"
replace `geo' = "LVA" if `geo' == "LV"
replace `geo' = "LBN" if `geo' == "LB"
replace `geo' = "LSO" if `geo' == "LS"
replace `geo' = "LBR" if `geo' == "LR"
replace `geo' = "LBY" if `geo' == "LY"
replace `geo' = "LIE" if `geo' == "LI"
replace `geo' = "LTU" if `geo' == "LT"
replace `geo' = "LUX" if `geo' == "LU"
replace `geo' = "MAC" if `geo' == "MO"
replace `geo' = "MKD" if `geo' == "MK"
replace `geo' = "MDG" if `geo' == "MG"
replace `geo' = "MWI" if `geo' == "MW"
replace `geo' = "MYS" if `geo' == "MY"
replace `geo' = "MDV" if `geo' == "MV"
replace `geo' = "MLI" if `geo' == "ML"
replace `geo' = "MLT" if `geo' == "MT"
replace `geo' = "MHL" if `geo' == "MH"
replace `geo' = "MTQ" if `geo' == "MQ"
replace `geo' = "MRT" if `geo' == "MR"
replace `geo' = "MUS" if `geo' == "MU"
replace `geo' = "MYT" if `geo' == "YT"
replace `geo' = "MEX" if `geo' == "MX"
replace `geo' = "FSM" if `geo' == "FM"
replace `geo' = "MDA" if `geo' == "MD"
replace `geo' = "MCO" if `geo' == "MC"
replace `geo' = "MNG" if `geo' == "MN"
replace `geo' = "MNE" if `geo' == "ME"
replace `geo' = "MSR" if `geo' == "MS"
replace `geo' = "MAR" if `geo' == "MA"
replace `geo' = "MOZ" if `geo' == "MZ"
replace `geo' = "MMR" if `geo' == "MM"
replace `geo' = "NAM" if `geo' == "NA"
replace `geo' = "NRU" if `geo' == "NR"
replace `geo' = "NPL" if `geo' == "NP"
replace `geo' = "NLD" if `geo' == "NL"
replace `geo' = "NCL" if `geo' == "NC"
replace `geo' = "NZL" if `geo' == "NZ"
replace `geo' = "NIC" if `geo' == "NI"
replace `geo' = "NER" if `geo' == "NE"
replace `geo' = "NGA" if `geo' == "NG"
replace `geo' = "NIU" if `geo' == "NU"
replace `geo' = "NFK" if `geo' == "NF"
replace `geo' = "MNP" if `geo' == "MP"
replace `geo' = "NOR" if `geo' == "NO"
replace `geo' = "OMN" if `geo' == "OM"
replace `geo' = "PAK" if `geo' == "PK"
replace `geo' = "PLW" if `geo' == "PW"
replace `geo' = "PSE" if `geo' == "PS"
replace `geo' = "PAN" if `geo' == "PA"
replace `geo' = "PNG" if `geo' == "PG"
replace `geo' = "PRY" if `geo' == "PY"
replace `geo' = "PER" if `geo' == "PE"
replace `geo' = "PHL" if `geo' == "PH"
replace `geo' = "PCN" if `geo' == "PN"
replace `geo' = "POL" if `geo' == "PL"
replace `geo' = "PRT" if `geo' == "PT"
replace `geo' = "PRI" if `geo' == "PR"
replace `geo' = "QAT" if `geo' == "QA"
replace `geo' = "REU" if `geo' == "RE"
replace `geo' = "ROU" if `geo' == "RO"
replace `geo' = "RUS" if `geo' == "RU"
replace `geo' = "RWA" if `geo' == "RW"
replace `geo' = "BLM" if `geo' == "BL"
replace `geo' = "SHN" if `geo' == "SH"
replace `geo' = "KNA" if `geo' == "KN"
replace `geo' = "LCA" if `geo' == "LC"
replace `geo' = "MAF" if `geo' == "MF"
replace `geo' = "SPM" if `geo' == "PM"
replace `geo' = "VCT" if `geo' == "VC"
replace `geo' = "WSM" if `geo' == "WS"
replace `geo' = "SMR" if `geo' == "SM"
replace `geo' = "STP" if `geo' == "ST"
replace `geo' = "SAU" if `geo' == "SA"
replace `geo' = "SEN" if `geo' == "SN"
replace `geo' = "SRB" if `geo' == "RS"
replace `geo' = "SYC" if `geo' == "SC"
replace `geo' = "SLE" if `geo' == "SL"
replace `geo' = "SGP" if `geo' == "SG"
replace `geo' = "SXM" if `geo' == "SX"
replace `geo' = "SVK" if `geo' == "SK"
replace `geo' = "SVN" if `geo' == "SI"
replace `geo' = "SLB" if `geo' == "SB"
replace `geo' = "SOM" if `geo' == "SO"
replace `geo' = "ZAF" if `geo' == "ZA"
replace `geo' = "SGS" if `geo' == "GS"
replace `geo' = "SSD" if `geo' == "SS"
replace `geo' = "ESP" if `geo' == "ES"
replace `geo' = "LKA" if `geo' == "LK"
replace `geo' = "SDN" if `geo' == "SD"
replace `geo' = "SUR" if `geo' == "SR"
replace `geo' = "SJM" if `geo' == "SJ"
replace `geo' = "SWZ" if `geo' == "SZ"
replace `geo' = "SWE" if `geo' == "SE"
replace `geo' = "CHE" if `geo' == "CH"
replace `geo' = "SYR" if `geo' == "SY"
replace `geo' = "TWN" if `geo' == "TW"
replace `geo' = "TJK" if `geo' == "TJ"
replace `geo' = "TZA" if `geo' == "TZ"
replace `geo' = "THA" if `geo' == "TH"
replace `geo' = "TLS" if `geo' == "TL"
replace `geo' = "TGO" if `geo' == "TG"
replace `geo' = "TKL" if `geo' == "TK"
replace `geo' = "TON" if `geo' == "TO"
replace `geo' = "TTO" if `geo' == "TT"
replace `geo' = "TUN" if `geo' == "TN"
replace `geo' = "TUR" if `geo' == "TR"
replace `geo' = "TKM" if `geo' == "TM"
replace `geo' = "TCA" if `geo' == "TC"
replace `geo' = "TUV" if `geo' == "TV"
replace `geo' = "UGA" if `geo' == "UG"
replace `geo' = "UKR" if `geo' == "UA"
replace `geo' = "ARE" if `geo' == "AE"
replace `geo' = "GBR" if `geo' == "GB" | `geo' == "UK" 
replace `geo' = "USA" if `geo' == "US"
replace `geo' = "UMI" if `geo' == "UM"
replace `geo' = "URY" if `geo' == "UY"
replace `geo' = "UZB" if `geo' == "UZ"
replace `geo' = "VUT" if `geo' == "VU"
replace `geo' = "VEN" if `geo' == "VE"
replace `geo' = "VNM" if `geo' == "VN"
replace `geo' = "VGB" if `geo' == "VG"
replace `geo' = "VIR" if `geo' == "VI"
replace `geo' = "WLF" if `geo' == "WF"
replace `geo' = "ESH" if `geo' == "EH"
replace `geo' = "YEM" if `geo' == "YE"
replace `geo' = "ZMB" if `geo' == "ZM"
replace `geo' = "ZWE" if `geo' == "ZW"


gen `geo'_num = .
replace `geo'_num =  4 if `geo' == "AFG"
replace `geo'_num =  248 if `geo' == "ALA"
replace `geo'_num =  8 if `geo' == "ALB"
replace `geo'_num =  12 if `geo' == "DZA"
replace `geo'_num =  16 if `geo' == "ASM"
replace `geo'_num =  20 if `geo' == "AND"
replace `geo'_num =  24 if `geo' == "AGO"
replace `geo'_num =  660 if `geo' == "AIA"
replace `geo'_num =  10 if `geo' == "ATA"
replace `geo'_num =  28 if `geo' == "ATG"
replace `geo'_num =  32 if `geo' == "ARG"
replace `geo'_num =  51 if `geo' == "ARM"
replace `geo'_num =  533 if `geo' == "ABW"
replace `geo'_num =  36 if `geo' == "AUS"
replace `geo'_num =  40 if `geo' == "AUT"
replace `geo'_num =  31 if `geo' == "AZE"
replace `geo'_num =  44 if `geo' == "BHS"
replace `geo'_num =  48 if `geo' == "BHR"
replace `geo'_num =  50 if `geo' == "BGD"
replace `geo'_num =  52 if `geo' == "BRB"
replace `geo'_num =  112 if `geo' == "BLR"
replace `geo'_num =  56 if `geo' == "BEL"
replace `geo'_num =  84 if `geo' == "BLZ"
replace `geo'_num =  204 if `geo' == "BEN"
replace `geo'_num =  60 if `geo' == "BMU"
replace `geo'_num =  64 if `geo' == "BTN"
replace `geo'_num =  68 if `geo' == "BOL"
replace `geo'_num =  70 if `geo' == "BIH"
replace `geo'_num =  72 if `geo' == "BWA"
replace `geo'_num =  74 if `geo' == "BVT"
replace `geo'_num =  76 if `geo' == "BRA"
replace `geo'_num =  92 if `geo' == "VGB"
replace `geo'_num =  86 if `geo' == "IOT"
replace `geo'_num =  96 if `geo' == "BRN"
replace `geo'_num =  100 if `geo' == "BGR"
replace `geo'_num =  854 if `geo' == "BFA"
replace `geo'_num =  108 if `geo' == "BDI"
replace `geo'_num =  116 if `geo' == "KHM"
replace `geo'_num =  120 if `geo' == "CMR"
replace `geo'_num =  124 if `geo' == "CAN"
replace `geo'_num =  132 if `geo' == "CPV"
replace `geo'_num =  136 if `geo' == "CYM"
replace `geo'_num =  140 if `geo' == "CAF"
replace `geo'_num =  148 if `geo' == "TCD"
replace `geo'_num =  152 if `geo' == "CHL"
replace `geo'_num =  156 if `geo' == "CHN"
replace `geo'_num =  344 if `geo' == "HKG"
replace `geo'_num =  446 if `geo' == "MAC"
replace `geo'_num =  162 if `geo' == "CXR"
replace `geo'_num =  166 if `geo' == "CCK"
replace `geo'_num =  170 if `geo' == "COL"
replace `geo'_num =  174 if `geo' == "COM"
replace `geo'_num =  178 if `geo' == "COG"
replace `geo'_num =  180 if `geo' == "COD"
replace `geo'_num =  184 if `geo' == "COK"
replace `geo'_num =  188 if `geo' == "CRI"
replace `geo'_num =  384 if `geo' == "CIV"
replace `geo'_num =  191 if `geo' == "HRV"
replace `geo'_num =  192 if `geo' == "CUB"
replace `geo'_num =  196 if `geo' == "CYP"
replace `geo'_num =  203 if `geo' == "CZE"
replace `geo'_num =  208 if `geo' == "DNK"
replace `geo'_num =  262 if `geo' == "DJI"
replace `geo'_num =  212 if `geo' == "DMA"
replace `geo'_num =  214 if `geo' == "DOM"
replace `geo'_num =  218 if `geo' == "ECU"
replace `geo'_num =  818 if `geo' == "EGY"
replace `geo'_num =  222 if `geo' == "SLV"
replace `geo'_num =  226 if `geo' == "GNQ"
replace `geo'_num =  232 if `geo' == "ERI"
replace `geo'_num =  233 if `geo' == "EST"
replace `geo'_num =  231 if `geo' == "ETH"
replace `geo'_num =  238 if `geo' == "FLK"
replace `geo'_num =  234 if `geo' == "FRO"
replace `geo'_num =  242 if `geo' == "FJI"
replace `geo'_num =  246 if `geo' == "FIN"
replace `geo'_num =  250 if `geo' == "FRA"
replace `geo'_num =  254 if `geo' == "GUF"
replace `geo'_num =  258 if `geo' == "PYF"
replace `geo'_num =  260 if `geo' == "ATF"
replace `geo'_num =  266 if `geo' == "GAB"
replace `geo'_num =  270 if `geo' == "GMB"
replace `geo'_num =  268 if `geo' == "GEO"
replace `geo'_num =  276 if `geo' == "DEU"
replace `geo'_num =  288 if `geo' == "GHA"
replace `geo'_num =  292 if `geo' == "GIB"
replace `geo'_num =  300 if `geo' == "GRC"
replace `geo'_num =  304 if `geo' == "GRL"
replace `geo'_num =  308 if `geo' == "GRD"
replace `geo'_num =  312 if `geo' == "GLP"
replace `geo'_num =  316 if `geo' == "GUM"
replace `geo'_num =  320 if `geo' == "GTM"
replace `geo'_num =  831 if `geo' == "GGY"
replace `geo'_num =  324 if `geo' == "GIN"
replace `geo'_num =  624 if `geo' == "GNB"
replace `geo'_num =  328 if `geo' == "GUY"
replace `geo'_num =  332 if `geo' == "HTI"
replace `geo'_num =  334 if `geo' == "HMD"
replace `geo'_num =  336 if `geo' == "VAT"
replace `geo'_num =  340 if `geo' == "HND"
replace `geo'_num =  348 if `geo' == "HUN"
replace `geo'_num =  352 if `geo' == "ISL"
replace `geo'_num =  356 if `geo' == "IND"
replace `geo'_num =  360 if `geo' == "IDN"
replace `geo'_num =  364 if `geo' == "IRN"
replace `geo'_num =  368 if `geo' == "IRQ"
replace `geo'_num =  372 if `geo' == "IRL"
replace `geo'_num =  833 if `geo' == "IMN"
replace `geo'_num =  376 if `geo' == "ISR"
replace `geo'_num =  380 if `geo' == "ITA"
replace `geo'_num =  388 if `geo' == "JAM"
replace `geo'_num =  392 if `geo' == "JPN"
replace `geo'_num =  832 if `geo' == "JEY"
replace `geo'_num =  400 if `geo' == "JOR"
replace `geo'_num =  398 if `geo' == "KAZ"
replace `geo'_num =  404 if `geo' == "KEN"
replace `geo'_num =  296 if `geo' == "KIR"
replace `geo'_num =  408 if `geo' == "PRK"
replace `geo'_num =  410 if `geo' == "KOR"
replace `geo'_num =  414 if `geo' == "KWT"
replace `geo'_num =  417 if `geo' == "KGZ"
replace `geo'_num =  418 if `geo' == "LAO"
replace `geo'_num =  428 if `geo' == "LVA"
replace `geo'_num =  422 if `geo' == "LBN"
replace `geo'_num =  426 if `geo' == "LSO"
replace `geo'_num =  430 if `geo' == "LBR"
replace `geo'_num =  434 if `geo' == "LBY"
replace `geo'_num =  438 if `geo' == "LIE"
replace `geo'_num =  440 if `geo' == "LTU"
replace `geo'_num =  442 if `geo' == "LUX"
replace `geo'_num =  807 if `geo' == "MKD"
replace `geo'_num =  450 if `geo' == "MDG"
replace `geo'_num =  454 if `geo' == "MWI"
replace `geo'_num =  458 if `geo' == "MYS"
replace `geo'_num =  462 if `geo' == "MDV"
replace `geo'_num =  466 if `geo' == "MLI"
replace `geo'_num =  470 if `geo' == "MLT"
replace `geo'_num =  584 if `geo' == "MHL"
replace `geo'_num =  474 if `geo' == "MTQ"
replace `geo'_num =  478 if `geo' == "MRT"
replace `geo'_num =  480 if `geo' == "MUS"
replace `geo'_num =  175 if `geo' == "MYT"
replace `geo'_num =  484 if `geo' == "MEX"
replace `geo'_num =  583 if `geo' == "FSM"
replace `geo'_num =  498 if `geo' == "MDA"
replace `geo'_num =  492 if `geo' == "MCO"
replace `geo'_num =  496 if `geo' == "MNG"
replace `geo'_num =  499 if `geo' == "MNE"
replace `geo'_num =  500 if `geo' == "MSR"
replace `geo'_num =  504 if `geo' == "MAR"
replace `geo'_num =  508 if `geo' == "MOZ"
replace `geo'_num =  104 if `geo' == "MMR"
replace `geo'_num =  516 if `geo' == "NAM"
replace `geo'_num =  520 if `geo' == "NRU"
replace `geo'_num =  524 if `geo' == "NPL"
replace `geo'_num =  528 if `geo' == "NLD"
replace `geo'_num =  530 if `geo' == "ANT"
replace `geo'_num =  540 if `geo' == "NCL"
replace `geo'_num =  554 if `geo' == "NZL"
replace `geo'_num =  558 if `geo' == "NIC"
replace `geo'_num =  562 if `geo' == "NER"
replace `geo'_num =  566 if `geo' == "NGA"
replace `geo'_num =  570 if `geo' == "NIU"
replace `geo'_num =  574 if `geo' == "NFK"
replace `geo'_num =  580 if `geo' == "MNP"
replace `geo'_num =  578 if `geo' == "NOR"
replace `geo'_num =  512 if `geo' == "OMN"
replace `geo'_num =  586 if `geo' == "PAK"
replace `geo'_num =  585 if `geo' == "PLW"
replace `geo'_num =  275 if `geo' == "PSE"
replace `geo'_num =  591 if `geo' == "PAN"
replace `geo'_num =  598 if `geo' == "PNG"
replace `geo'_num =  600 if `geo' == "PRY"
replace `geo'_num =  604 if `geo' == "PER"
replace `geo'_num =  608 if `geo' == "PHL"
replace `geo'_num =  612 if `geo' == "PCN"
replace `geo'_num =  616 if `geo' == "POL"
replace `geo'_num =  620 if `geo' == "PRT"
replace `geo'_num =  630 if `geo' == "PRI"
replace `geo'_num =  634 if `geo' == "QAT"
replace `geo'_num =  638 if `geo' == "REU"
replace `geo'_num =  642 if `geo' == "ROU"
replace `geo'_num =  643 if `geo' == "RUS"
replace `geo'_num =  646 if `geo' == "RWA"
replace `geo'_num =  652 if `geo' == "BLM"
replace `geo'_num =  654 if `geo' == "SHN"
replace `geo'_num =  659 if `geo' == "KNA"
replace `geo'_num =  662 if `geo' == "LCA"
replace `geo'_num =  663 if `geo' == "MAF"
replace `geo'_num =  666 if `geo' == "SPM"
replace `geo'_num =  670 if `geo' == "VCT"
replace `geo'_num =  882 if `geo' == "WSM"
replace `geo'_num =  674 if `geo' == "SMR"
replace `geo'_num =  678 if `geo' == "STP"
replace `geo'_num =  682 if `geo' == "SAU"
replace `geo'_num =  686 if `geo' == "SEN"
replace `geo'_num =  688 if `geo' == "SRB"
replace `geo'_num =  690 if `geo' == "SYC"
replace `geo'_num =  694 if `geo' == "SLE"
replace `geo'_num =  702 if `geo' == "SGP"
replace `geo'_num =  703 if `geo' == "SVK"
replace `geo'_num =  705 if `geo' == "SVN"
replace `geo'_num =  90 if `geo' == "SLB"
replace `geo'_num =  706 if `geo' == "SOM"
replace `geo'_num =  710 if `geo' == "ZAF"
replace `geo'_num =  239 if `geo' == "SGS"
replace `geo'_num =  728 if `geo' == "SSD"
replace `geo'_num =  724 if `geo' == "ESP"
replace `geo'_num =  144 if `geo' == "LKA"
replace `geo'_num =  736 if `geo' == "SDN"
replace `geo'_num =  740 if `geo' == "SUR"
replace `geo'_num =  744 if `geo' == "SJM"
replace `geo'_num =  748 if `geo' == "SWZ"
replace `geo'_num =  752 if `geo' == "SWE"
replace `geo'_num =  756 if `geo' == "CHE"
replace `geo'_num =  760 if `geo' == "SYR"
replace `geo'_num =  158 if `geo' == "TWN"
replace `geo'_num =  762 if `geo' == "TJK"
replace `geo'_num =  834 if `geo' == "TZA"
replace `geo'_num =  764 if `geo' == "THA"
replace `geo'_num =  626 if `geo' == "TLS"
replace `geo'_num =  768 if `geo' == "TGO"
replace `geo'_num =  772 if `geo' == "TKL"
replace `geo'_num =  776 if `geo' == "TON"
replace `geo'_num =  780 if `geo' == "TTO"
replace `geo'_num =  788 if `geo' == "TUN"
replace `geo'_num =  792 if `geo' == "TUR"
replace `geo'_num =  795 if `geo' == "TKM"
replace `geo'_num =  796 if `geo' == "TCA"
replace `geo'_num =  798 if `geo' == "TUV"
replace `geo'_num =  800 if `geo' == "UGA"
replace `geo'_num =  804 if `geo' == "UKR"
replace `geo'_num =  784 if `geo' == "ARE"
replace `geo'_num =  826 if `geo' == "GBR"
replace `geo'_num =  840 if `geo' == "USA"
replace `geo'_num =  581 if `geo' == "UMI"
replace `geo'_num =  858 if `geo' == "URY"
replace `geo'_num =  860 if `geo' == "UZB"
replace `geo'_num =  548 if `geo' == "VUT"
replace `geo'_num =  862 if `geo' == "VEN"
replace `geo'_num =  704 if `geo' == "VNM"
replace `geo'_num =  850 if `geo' == "VIR"
replace `geo'_num =  876 if `geo' == "WLF"
replace `geo'_num =  732 if `geo' == "ESH"
replace `geo'_num =  887 if `geo' == "YEM"
replace `geo'_num =  894 if `geo' == "ZMB"
replace `geo'_num =  716 if `geo' == "ZWE"


** Own definitions - may conflit with new countries
replace `geo'_num = 942 if `geo' == "EA12"
replace `geo'_num = 943 if `geo' == "EA13"
replace `geo'_num = 945 if `geo' == "EA15"
replace `geo'_num = 946 if `geo' == "EA16"
replace `geo'_num = 947 if `geo' == "EA17"
replace `geo'_num = 948 if `geo' == "EA18"
replace `geo'_num = 949 if `geo' == "EA19"
replace `geo'_num = 925 if `geo' == "EU25"
replace `geo'_num = 927 if `geo' == "EU27"
replace `geo'_num = 928 if `geo' == "EU28"
replace `geo'_num = 998 if `geo' == "FRME"
replace `geo'_num = 997 if `geo' == "DEW"
replace `geo'_num = 996 if `geo' == "NMEC"

replace `geo'_num =  4 if `geo' == "AF"
replace `geo'_num =  248 if `geo' == "AX"
replace `geo'_num =  8 if `geo' == "AL"
replace `geo'_num =  12 if `geo' == "DZ"
replace `geo'_num =  16 if `geo' == "AS"
replace `geo'_num =  20 if `geo' == "AD"
replace `geo'_num =  24 if `geo' == "AO"
replace `geo'_num =  660 if `geo' == "AI"
replace `geo'_num =  10 if `geo' == "AQ"
replace `geo'_num =  28 if `geo' == "AG"
replace `geo'_num =  32 if `geo' == "AR"
replace `geo'_num =  51 if `geo' == "AM"
replace `geo'_num =  533 if `geo' == "AW"
replace `geo'_num =  36 if `geo' == "AU"
replace `geo'_num =  40 if `geo' == "AT"
replace `geo'_num =  31 if `geo' == "AZ"
replace `geo'_num =  44 if `geo' == "BS"
replace `geo'_num =  48 if `geo' == "BH"
replace `geo'_num =  50 if `geo' == "BD"
replace `geo'_num =  52 if `geo' == "BB"
replace `geo'_num =  112 if `geo' == "BY"
replace `geo'_num =  56 if `geo' == "BE"
replace `geo'_num =  84 if `geo' == "BZ"
replace `geo'_num =  204 if `geo' == "BJ"
replace `geo'_num =  60 if `geo' == "BM"
replace `geo'_num =  64 if `geo' == "BT"
replace `geo'_num =  68 if `geo' == "BO"
replace `geo'_num =  70 if `geo' == "BA"
replace `geo'_num =  72 if `geo' == "BW"
replace `geo'_num =  74 if `geo' == "BV"
replace `geo'_num =  76 if `geo' == "BR"
replace `geo'_num =  92 if `geo' == "VG"
replace `geo'_num =  86 if `geo' == "IO"
replace `geo'_num =  96 if `geo' == "BN"
replace `geo'_num =  100 if `geo' == "BG"
replace `geo'_num =  854 if `geo' == "BF"
replace `geo'_num =  108 if `geo' == "BI"
replace `geo'_num =  116 if `geo' == "KH"
replace `geo'_num =  120 if `geo' == "CM"
replace `geo'_num =  124 if `geo' == "CA"
replace `geo'_num =  132 if `geo' == "CV"
replace `geo'_num =  136 if `geo' == "KY"
replace `geo'_num =  140 if `geo' == "CF"
replace `geo'_num =  148 if `geo' == "TD"
replace `geo'_num =  152 if `geo' == "CL"
replace `geo'_num =  156 if `geo' == "CN"
replace `geo'_num =  344 if `geo' == "HK"
replace `geo'_num =  446 if `geo' == "MO"
replace `geo'_num =  162 if `geo' == "CX"
replace `geo'_num =  166 if `geo' == "CC"
replace `geo'_num =  170 if `geo' == "CO"
replace `geo'_num =  174 if `geo' == "KM"
replace `geo'_num =  178 if `geo' == "CG"
replace `geo'_num =  180 if `geo' == "CD"
replace `geo'_num =  184 if `geo' == "CK"
replace `geo'_num =  188 if `geo' == "CR"
replace `geo'_num =  384 if `geo' == "CI"
replace `geo'_num =  191 if `geo' == "HR"
replace `geo'_num =  192 if `geo' == "CU"
replace `geo'_num =  196 if `geo' == "CY"
replace `geo'_num =  203 if `geo' == "CZ"
replace `geo'_num =  208 if `geo' == "DK"
replace `geo'_num =  262 if `geo' == "DJ"
replace `geo'_num =  212 if `geo' == "DM"
replace `geo'_num =  214 if `geo' == "DO"
replace `geo'_num =  218 if `geo' == "EC"
replace `geo'_num =  818 if `geo' == "EG"
replace `geo'_num =  222 if `geo' == "SV"
replace `geo'_num =  226 if `geo' == "GQ"
replace `geo'_num =  232 if `geo' == "ER"
replace `geo'_num =  233 if `geo' == "EE"
replace `geo'_num =  231 if `geo' == "ET"
replace `geo'_num =  238 if `geo' == "FK"
replace `geo'_num =  234 if `geo' == "FO"
replace `geo'_num =  242 if `geo' == "FJ"
replace `geo'_num =  246 if `geo' == "FI"
replace `geo'_num =  250 if `geo' == "FR"
replace `geo'_num =  254 if `geo' == "GF"
replace `geo'_num =  258 if `geo' == "PF"
replace `geo'_num =  260 if `geo' == "TF"
replace `geo'_num =  266 if `geo' == "GA"
replace `geo'_num =  270 if `geo' == "GM"
replace `geo'_num =  268 if `geo' == "GE"
replace `geo'_num =  276 if `geo' == "DE"
replace `geo'_num =  288 if `geo' == "GH"
replace `geo'_num =  292 if `geo' == "GI"
replace `geo'_num =  300 if `geo' == "GR"
replace `geo'_num =  304 if `geo' == "GL"
replace `geo'_num =  308 if `geo' == "GD"
replace `geo'_num =  312 if `geo' == "GP"
replace `geo'_num =  316 if `geo' == "GU"
replace `geo'_num =  320 if `geo' == "GT"
replace `geo'_num =  831 if `geo' == "GG"
replace `geo'_num =  324 if `geo' == "GN"
replace `geo'_num =  624 if `geo' == "GW"
replace `geo'_num =  328 if `geo' == "GY"
replace `geo'_num =  332 if `geo' == "HT"
replace `geo'_num =  334 if `geo' == "HM"
replace `geo'_num =  336 if `geo' == "VA"
replace `geo'_num =  340 if `geo' == "HN"
replace `geo'_num =  348 if `geo' == "HU"
replace `geo'_num =  352 if `geo' == "IS"
replace `geo'_num =  356 if `geo' == "IN"
replace `geo'_num =  360 if `geo' == "ID"
replace `geo'_num =  364 if `geo' == "IR"
replace `geo'_num =  368 if `geo' == "IQ"
replace `geo'_num =  372 if `geo' == "IE"
replace `geo'_num =  833 if `geo' == "IM"
replace `geo'_num =  376 if `geo' == "IL"
replace `geo'_num =  380 if `geo' == "IT"
replace `geo'_num =  388 if `geo' == "JM"
replace `geo'_num =  392 if `geo' == "JP"
replace `geo'_num =  832 if `geo' == "JE"
replace `geo'_num =  400 if `geo' == "JO"
replace `geo'_num =  398 if `geo' == "KZ"
replace `geo'_num =  404 if `geo' == "KE"
replace `geo'_num =  296 if `geo' == "KI"
replace `geo'_num =  408 if `geo' == "KP"
replace `geo'_num =  410 if `geo' == "KR"
replace `geo'_num =  414 if `geo' == "KW"
replace `geo'_num =  417 if `geo' == "KG"
replace `geo'_num =  418 if `geo' == "LA"
replace `geo'_num =  428 if `geo' == "LV"
replace `geo'_num =  422 if `geo' == "LB"
replace `geo'_num =  426 if `geo' == "LS"
replace `geo'_num =  430 if `geo' == "LR"
replace `geo'_num =  434 if `geo' == "LY"
replace `geo'_num =  438 if `geo' == "LI"
replace `geo'_num =  440 if `geo' == "LT"
replace `geo'_num =  442 if `geo' == "LU"
replace `geo'_num =  807 if `geo' == "MK"
replace `geo'_num =  450 if `geo' == "MG"
replace `geo'_num =  454 if `geo' == "MW"
replace `geo'_num =  458 if `geo' == "MY"
replace `geo'_num =  462 if `geo' == "MV"
replace `geo'_num =  466 if `geo' == "ML"
replace `geo'_num =  470 if `geo' == "MT"
replace `geo'_num =  584 if `geo' == "MH"
replace `geo'_num =  474 if `geo' == "MQ"
replace `geo'_num =  478 if `geo' == "MR"
replace `geo'_num =  480 if `geo' == "MU"
replace `geo'_num =  175 if `geo' == "YT"
replace `geo'_num =  484 if `geo' == "MX"
replace `geo'_num =  583 if `geo' == "FM"
replace `geo'_num =  498 if `geo' == "MD"
replace `geo'_num =  492 if `geo' == "MC"
replace `geo'_num =  496 if `geo' == "MN"
replace `geo'_num =  499 if `geo' == "ME"
replace `geo'_num =  500 if `geo' == "MS"
replace `geo'_num =  504 if `geo' == "MA"
replace `geo'_num =  508 if `geo' == "MZ"
replace `geo'_num =  104 if `geo' == "MM"
replace `geo'_num =  516 if `geo' == "NA"
replace `geo'_num =  520 if `geo' == "NR"
replace `geo'_num =  524 if `geo' == "NP"
replace `geo'_num =  528 if `geo' == "NL"
replace `geo'_num =  530 if `geo' == "AN"
replace `geo'_num =  540 if `geo' == "NC"
replace `geo'_num =  554 if `geo' == "NZ"
replace `geo'_num =  558 if `geo' == "NI"
replace `geo'_num =  562 if `geo' == "NE"
replace `geo'_num =  566 if `geo' == "NG"
replace `geo'_num =  570 if `geo' == "NU"
replace `geo'_num =  574 if `geo' == "NF"
replace `geo'_num =  580 if `geo' == "MP"
replace `geo'_num =  578 if `geo' == "NO"
replace `geo'_num =  512 if `geo' == "OM"
replace `geo'_num =  586 if `geo' == "PK"
replace `geo'_num =  585 if `geo' == "PW"
replace `geo'_num =  275 if `geo' == "PS"
replace `geo'_num =  591 if `geo' == "PA"
replace `geo'_num =  598 if `geo' == "PG"
replace `geo'_num =  600 if `geo' == "PY"
replace `geo'_num =  604 if `geo' == "PE"
replace `geo'_num =  608 if `geo' == "PH"
replace `geo'_num =  612 if `geo' == "PN"
replace `geo'_num =  616 if `geo' == "PL"
replace `geo'_num =  620 if `geo' == "PT"
replace `geo'_num =  630 if `geo' == "PR"
replace `geo'_num =  634 if `geo' == "QA"
replace `geo'_num =  638 if `geo' == "RE"
replace `geo'_num =  642 if `geo' == "RO"
replace `geo'_num =  643 if `geo' == "RU"
replace `geo'_num =  646 if `geo' == "RW"
replace `geo'_num =  652 if `geo' == "BL"
replace `geo'_num =  654 if `geo' == "SH"
replace `geo'_num =  659 if `geo' == "KN"
replace `geo'_num =  662 if `geo' == "LC"
replace `geo'_num =  663 if `geo' == "MF"
replace `geo'_num =  666 if `geo' == "PM"
replace `geo'_num =  670 if `geo' == "VC"
replace `geo'_num =  882 if `geo' == "WS"
replace `geo'_num =  674 if `geo' == "SM"
replace `geo'_num =  678 if `geo' == "ST"
replace `geo'_num =  682 if `geo' == "SA"
replace `geo'_num =  686 if `geo' == "SN"
replace `geo'_num =  688 if `geo' == "RS"
replace `geo'_num =  690 if `geo' == "SC"
replace `geo'_num =  694 if `geo' == "SL"
replace `geo'_num =  702 if `geo' == "SG"
replace `geo'_num =  703 if `geo' == "SK"
replace `geo'_num =  705 if `geo' == "SI"
replace `geo'_num =  90 if `geo' == "SB"
replace `geo'_num =  706 if `geo' == "SO"
replace `geo'_num =  710 if `geo' == "ZA"
replace `geo'_num =  239 if `geo' == "GS"
replace `geo'_num =  728 if `geo' == "SS"
replace `geo'_num =  724 if `geo' == "ES"
replace `geo'_num =  144 if `geo' == "LK"
replace `geo'_num =  736 if `geo' == "SD"
replace `geo'_num =  740 if `geo' == "SR"
replace `geo'_num =  744 if `geo' == "SJ"
replace `geo'_num =  748 if `geo' == "SZ"
replace `geo'_num =  752 if `geo' == "SE"
replace `geo'_num =  756 if `geo' == "CH"
replace `geo'_num =  760 if `geo' == "SY"
replace `geo'_num =  158 if `geo' == "TW"
replace `geo'_num =  762 if `geo' == "TJ"
replace `geo'_num =  834 if `geo' == "TZ"
replace `geo'_num =  764 if `geo' == "TH"
replace `geo'_num =  626 if `geo' == "TL"
replace `geo'_num =  768 if `geo' == "TG"
replace `geo'_num =  772 if `geo' == "TK"
replace `geo'_num =  776 if `geo' == "TO"
replace `geo'_num =  780 if `geo' == "TT"
replace `geo'_num =  788 if `geo' == "TN"
replace `geo'_num =  792 if `geo' == "TR"
replace `geo'_num =  795 if `geo' == "TM"
replace `geo'_num =  796 if `geo' == "TC"
replace `geo'_num =  798 if `geo' == "TV"
replace `geo'_num =  800 if `geo' == "UG"
replace `geo'_num =  804 if `geo' == "UA"
replace `geo'_num =  784 if `geo' == "AE"
replace `geo'_num =  826 if `geo' == "GB"
replace `geo'_num =  840 if `geo' == "US"
replace `geo'_num =  581 if `geo' == "UM"
replace `geo'_num =  858 if `geo' == "UY"
replace `geo'_num =  860 if `geo' == "UZ"
replace `geo'_num =  548 if `geo' == "VU"
replace `geo'_num =  862 if `geo' == "VE"
replace `geo'_num =  704 if `geo' == "VN"
replace `geo'_num =  850 if `geo' == "VI"
replace `geo'_num =  876 if `geo' == "WF"
replace `geo'_num =  732 if `geo' == "EH"
replace `geo'_num =  887 if `geo' == "YE"
replace `geo'_num =  894 if `geo' == "ZM"
replace `geo'_num =  716 if `geo' == "ZW"


** Specific Eurostat
replace `geo'_num = 940 if `geo' == "EA"
replace `geo'_num = 952 if `geo' == "EA12"
replace `geo'_num = 953 if `geo' == "EA13"
replace `geo'_num = 955 if `geo' == "EA15"
replace `geo'_num = 956 if `geo' == "EA16"
replace `geo'_num = 957 if `geo' == "EA17"
replace `geo'_num = 958 if `geo' == "EA18"
replace `geo'_num = 959 if `geo' == "EA19"
replace `geo'_num = 900 if `geo' == "EU"
replace `geo'_num = 912 if `geo' == "EU12"
replace `geo'_num = 915 if `geo' == "EU15"
replace `geo'_num = 925 if `geo' == "EU25"
replace `geo'_num = 927 if `geo' == "EU27"
replace `geo'_num = 928 if `geo' == "EU28"

replace `geo'_num = 300 if `geo' == "EL"
replace `geo'_num = 826 if `geo' == "UK"

** Specific OECD
replace `geo'_num = 998 if `geo' == "FRME"
replace `geo'_num = 997 if `geo' == "DEW"
replace `geo'_num = 996 if `geo' == "NMEC"

cap label drop country_iso_num
label def country_iso_num 4 "Afghanistan", add
label def country_iso_num 248 "Aland Islands", add
label def country_iso_num 8 "Albania", add
label def country_iso_num 12 "Algeria", add
label def country_iso_num 16 "American Samoa", add
label def country_iso_num 20 "Andorra", add
label def country_iso_num 24 "Angola", add
label def country_iso_num 660 "Anguilla", add
label def country_iso_num 10 "Antarctica", add
label def country_iso_num 28 "Antigua and Barbuda", add
label def country_iso_num 32 "Argentina", add
label def country_iso_num 51 "Armenia", add
label def country_iso_num 533 "Aruba", add
label def country_iso_num 36 "Australia", add
label def country_iso_num 40 "Austria", add
label def country_iso_num 31 "Azerbaijan", add
label def country_iso_num 44 "Bahamas", add
label def country_iso_num 48 "Bahrain", add
label def country_iso_num 50 "Bangladesh", add
label def country_iso_num 52 "Barbados", add
label def country_iso_num 112 "Belarus", add
label def country_iso_num 56 "Belgium", add
label def country_iso_num 84 "Belize", add
label def country_iso_num 204 "Benin", add
label def country_iso_num 60 "Bermuda", add
label def country_iso_num 64 "Bhutan", add
label def country_iso_num 68 "Bolivia", add
label def country_iso_num 70 "Bosnia and Herzegovina", add
label def country_iso_num 72 "Botswana", add
label def country_iso_num 74 "Bouvet Island", add
label def country_iso_num 76 "Brazil", add
label def country_iso_num 92 "British Virgin Islands", add
label def country_iso_num 86 "British Indian Ocean Territory", add
label def country_iso_num 96 "Brunei Darussalam", add
label def country_iso_num 100 "Bulgaria", add
label def country_iso_num 854 "Burkina Faso", add
label def country_iso_num 108 "Burundi", add
label def country_iso_num 116 "Cambodia", add
label def country_iso_num 120 "Cameroon", add
label def country_iso_num 124 "Canada", add
label def country_iso_num 132 "Cape Verde", add
label def country_iso_num 136 "Cayman Islands", add
label def country_iso_num 140 "Central African Republic", add
label def country_iso_num 148 "Chad", add
label def country_iso_num 152 "Chile", add
label def country_iso_num 156 "China", add
label def country_iso_num 344 "Hong Kong, Special Administrative Region of China", add
label def country_iso_num 446 "Macao, Special Administrative Region of China", add
label def country_iso_num 162 "Christmas Island", add
label def country_iso_num 166 "Cocos (Keeling) Islands", add
label def country_iso_num 170 "Colombia", add
label def country_iso_num 174 "Comoros", add
label def country_iso_num 178 "Congo (Brazzaville)", add
label def country_iso_num 180 "Congo, Democratic Republic of the", add
label def country_iso_num 184 "Cook Islands", add
label def country_iso_num 188 "Costa Rica", add
label def country_iso_num 384 "Côte d'Ivoire", add
label def country_iso_num 191 "Croatia", add
label def country_iso_num 192 "Cuba", add
label def country_iso_num 196 "Cyprus", add
label def country_iso_num 203 "Czech Republic", add
label def country_iso_num 208 "Denmark", add
label def country_iso_num 262 "Djibouti", add
label def country_iso_num 212 "Dominica", add
label def country_iso_num 214 "Dominican Republic", add
label def country_iso_num 218 "Ecuador", add
label def country_iso_num 818 "Egypt", add
label def country_iso_num 222 "El Salvador", add
label def country_iso_num 226 "Equatorial Guinea", add
label def country_iso_num 232 "Eritrea", add
label def country_iso_num 233 "Estonia", add
label def country_iso_num 231 "Ethiopia", add
label def country_iso_num 238 "Falkland Islands (Malvinas)", add
label def country_iso_num 234 "Faroe Islands", add
label def country_iso_num 242 "Fiji", add
label def country_iso_num 246 "Finland", add
label def country_iso_num 250 "France", add
label def country_iso_num 254 "French Guiana", add
label def country_iso_num 258 "French Polynesia", add
label def country_iso_num 260 "French Southern Territories", add
label def country_iso_num 266 "Gabon", add
label def country_iso_num 270 "Gambia", add
label def country_iso_num 268 "Georgia", add
label def country_iso_num 276 "Germany", add
label def country_iso_num 288 "Ghana", add
label def country_iso_num 292 "Gibraltar", add
label def country_iso_num 300 "Greece", add
label def country_iso_num 304 "Greenland", add
label def country_iso_num 308 "Grenada", add
label def country_iso_num 312 "Guadeloupe", add
label def country_iso_num 316 "Guam", add
label def country_iso_num 320 "Guatemala", add
label def country_iso_num 831 "Guernsey", add
label def country_iso_num 324 "Guinea", add
label def country_iso_num 624 "Guinea-Bissau", add
label def country_iso_num 328 "Guyana", add
label def country_iso_num 332 "Haiti", add
label def country_iso_num 334 "Heard Island and Mcdonald Islands", add
label def country_iso_num 336 "Holy See (Vatican City State)", add
label def country_iso_num 340 "Honduras", add
label def country_iso_num 348 "Hungary", add
label def country_iso_num 352 "Iceland", add
label def country_iso_num 356 "India", add
label def country_iso_num 360 "Indonesia", add
label def country_iso_num 364 "Iran, Islamic Republic of", add
label def country_iso_num 368 "Iraq", add
label def country_iso_num 372 "Ireland", add
label def country_iso_num 833 "Isle of Man", add
label def country_iso_num 376 "Israel", add
label def country_iso_num 380 "Italy", add
label def country_iso_num 388 "Jamaica", add
label def country_iso_num 392 "Japan", add
label def country_iso_num 832 "Jersey", add
label def country_iso_num 400 "Jordan", add
label def country_iso_num 398 "Kazakhstan", add
label def country_iso_num 404 "Kenya", add
label def country_iso_num 296 "Kiribati", add
label def country_iso_num 408 "Korea, Democratic People's Republic of", add
label def country_iso_num 410 "Korea, Republic of", add
label def country_iso_num 414 "Kuwait", add
label def country_iso_num 417 "Kyrgyzstan", add
label def country_iso_num 418 "Lao PDR", add
label def country_iso_num 428 "Latvia", add
label def country_iso_num 422 "Lebanon", add
label def country_iso_num 426 "Lesotho", add
label def country_iso_num 430 "Liberia", add
label def country_iso_num 434 "Libya", add
label def country_iso_num 438 "Liechtenstein", add
label def country_iso_num 440 "Lithuania", add
label def country_iso_num 442 "Luxembourg", add
label def country_iso_num 807 "Macedonia, Republic of", add
label def country_iso_num 450 "Madagascar", add
label def country_iso_num 454 "Malawi", add
label def country_iso_num 458 "Malaysia", add
label def country_iso_num 462 "Maldives", add
label def country_iso_num 466 "Mali", add
label def country_iso_num 470 "Malta", add
label def country_iso_num 584 "Marshall Islands", add
label def country_iso_num 474 "Martinique", add
label def country_iso_num 478 "Mauritania", add
label def country_iso_num 480 "Mauritius", add
label def country_iso_num 175 "Mayotte", add
label def country_iso_num 484 "Mexico", add
label def country_iso_num 583 "Micronesia, Federated States of", add
label def country_iso_num 498 "Moldova", add
label def country_iso_num 492 "Monaco", add
label def country_iso_num 496 "Mongolia", add
label def country_iso_num 499 "Montenegro", add
label def country_iso_num 500 "Montserrat", add
label def country_iso_num 504 "Morocco", add
label def country_iso_num 508 "Mozambique", add
label def country_iso_num 104 "Myanmar", add
label def country_iso_num 516 "Namibia", add
label def country_iso_num 520 "Nauru", add
label def country_iso_num 524 "Nepal", add
label def country_iso_num 528 "Netherlands", add
label def country_iso_num 530 "Netherlands Antilles", add
label def country_iso_num 540 "New Caledonia", add
label def country_iso_num 554 "New Zealand", add
label def country_iso_num 558 "Nicaragua", add
label def country_iso_num 562 "Niger", add
label def country_iso_num 566 "Nigeria", add
label def country_iso_num 570 "Niue", add
label def country_iso_num 574 "Norfolk Island", add
label def country_iso_num 580 "Northern Mariana Islands", add
label def country_iso_num 578 "Norway", add
label def country_iso_num 512 "Oman", add
label def country_iso_num 586 "Pakistan", add
label def country_iso_num 585 "Palau", add
label def country_iso_num 275 "Palestinian Territory, Occupied", add
label def country_iso_num 591 "Panama", add
label def country_iso_num 598 "Papua New Guinea", add
label def country_iso_num 600 "Paraguay", add
label def country_iso_num 604 "Peru", add
label def country_iso_num 608 "Philippines", add
label def country_iso_num 612 "Pitcairn", add
label def country_iso_num 616 "Poland", add
label def country_iso_num 620 "Portugal", add
label def country_iso_num 630 "Puerto Rico", add
label def country_iso_num 634 "Qatar", add
label def country_iso_num 638 "Réunion", add
label def country_iso_num 642 "Romania", add
label def country_iso_num 643 "Russian Federation", add
label def country_iso_num 646 "Rwanda", add
label def country_iso_num 652 "Saint-Barthélemy", add
label def country_iso_num 654 "Saint Helena", add
label def country_iso_num 659 "Saint Kitts and Nevis", add
label def country_iso_num 662 "Saint Lucia", add
label def country_iso_num 663 "Saint-Martin (French part)", add
label def country_iso_num 666 "Saint Pierre and Miquelon", add
label def country_iso_num 670 "Saint Vincent and Grenadines", add
label def country_iso_num 882 "Samoa", add
label def country_iso_num 674 "San Marino", add
label def country_iso_num 678 "Sao Tome and Principe", add
label def country_iso_num 682 "Saudi Arabia", add
label def country_iso_num 686 "Senegal", add
label def country_iso_num 688 "Serbia", add
label def country_iso_num 690 "Seychelles", add
label def country_iso_num 694 "Sierra Leone", add
label def country_iso_num 702 "Singapore", add
label def country_iso_num 703 "Slovakia", add
label def country_iso_num 705 "Slovenia", add
label def country_iso_num 90 "Solomon Islands", add
label def country_iso_num 706 "Somalia", add
label def country_iso_num 710 "South Africa", add
label def country_iso_num 239 "South Georgia and the South Sandwich Islands", add
label def country_iso_num 728 "South Sudan", add
label def country_iso_num 724 "Spain", add
label def country_iso_num 144 "Sri Lanka", add
label def country_iso_num 736 "Sudan", add
label def country_iso_num 740 "Suriname *", add
label def country_iso_num 744 "Svalbard and Jan Mayen Islands", add
label def country_iso_num 748 "Swaziland", add
label def country_iso_num 752 "Sweden", add
label def country_iso_num 756 "Switzerland", add
label def country_iso_num 760 "Syrian Arab Republic (Syria)", add
label def country_iso_num 158 "Taiwan, Republic of China", add
label def country_iso_num 762 "Tajikistan", add
label def country_iso_num 834 "Tanzania *, United Republic of", add
label def country_iso_num 764 "Thailand", add
label def country_iso_num 626 "Timor-Leste", add
label def country_iso_num 768 "Togo", add
label def country_iso_num 772 "Tokelau", add
label def country_iso_num 776 "Tonga", add
label def country_iso_num 780 "Trinidad and Tobago", add
label def country_iso_num 788 "Tunisia", add
label def country_iso_num 792 "Turkey", add
label def country_iso_num 795 "Turkmenistan", add
label def country_iso_num 796 "Turks and Caicos Islands", add
label def country_iso_num 798 "Tuvalu", add
label def country_iso_num 800 "Uganda", add
label def country_iso_num 804 "Ukraine", add
label def country_iso_num 784 "United Arab Emirates", add
label def country_iso_num 826 "United Kingdom", add
label def country_iso_num 840 "United States of America", add
label def country_iso_num 581 "United States Minor Outlying Islands", add
label def country_iso_num 858 "Uruguay", add
label def country_iso_num 860 "Uzbekistan", add
label def country_iso_num 548 "Vanuatu", add
label def country_iso_num 862 "Venezuela (Bolivarian Republic of)", add
label def country_iso_num 704 "Viet Nam", add
label def country_iso_num 850 "Virgin Islands, US", add
label def country_iso_num 876 "Wallis and Futuna Islands", add
label def country_iso_num 732 "Western Sahara", add
label def country_iso_num 887 "Yemen", add
label def country_iso_num 894 "Zambia", add
label def country_iso_num 716 "Zimbabwe", add


** Own definitions - may conflit with new countries
label def country_iso_num 940 "Euro area", add
label def country_iso_num 952 "Euro area (12 countries)", add
label def country_iso_num 953 "Euro area (13 countries)", add
label def country_iso_num 955 "Euro area (15 countries)", add
label def country_iso_num 956 "Euro area (16 countries)", add
label def country_iso_num 957 "Euro area (17 countries)", add
label def country_iso_num 958 "Euro area (18 countries)", add
label def country_iso_num 959 "Euro area (19 countries)", add
label def country_iso_num 900 "European Union", add
label def country_iso_num 912 "European Union (12 countries)", add
label def country_iso_num 915 "European Union (15 countries)", add
label def country_iso_num 925 "European Union (25 countries)", add
label def country_iso_num 927 "European Union (27 countries)", add
label def country_iso_num 928 "European Union (28 countries)", add
label def country_iso_num 998 "Former Economies", add
label def country_iso_num 997 "Former Federal Republic of Germany", add
label def country_iso_num 996 "Non-OECD Member Economies", add

cap label values `geo'_num country_iso_num
}

if "`date'" == "y" & "`datemask'" == "" {
	cap destring `time', replace
	format `time' %ty
}
if "`date'" != "" & "`date'" != "c" & "`date'" != "C" & "`datemask'" != "" {
	replace `time' = subinstr(`time',"d","",.)
	replace `time' = subinstr(`time',"w","",.)
	replace `time' = subinstr(`time',"m","",.)
	replace `time' = subinstr(`time',"h","",.)
	replace `time' = subinstr(`time',"s","",.)
	replace `time' = subinstr(`time',"y","",.)
	replace `time' = subinstr(`time',"D","",.)
	replace `time' = subinstr(`time',"W","",.)
	replace `time' = subinstr(`time',"M","",.)
	replace `time' = subinstr(`time',"H","",.)
	replace `time' = subinstr(`time',"S","",.)
	replace `time' = subinstr(`time',"Y","",.)
	if "`date'" == "q" & "`datemask'" == "YQ" {
		gen `time'`date' = quarterly(`time',"`datemask'")
		gen temp = dof`date'(`time'`date')
		drop `time'
		rename temp `time'
		format `time' %td
		format `time'`date' %t`date'
	}
	if "`date'" == "m" & "`datemask'" == "YM" {
		gen temp = date(`time',"`datemask'")
		drop `time'
		rename temp `time'
		format `time' %td
		gen `time'`date' = `date'ofd(`time')
		format `time'`date' %t`date'
	}
	if ~(("`date'" == "q" & "`datemask'" == "YQ") | ("`date'" == "m" & "`datemask'" == "YM")) {
		gen temp = date(`time',"`datemask'")
		drop `time'
		rename temp `time'
		format `time' %td
		gen `time'`date' = `date'ofd(`time')
		format `time'`date' %t`date'
	}
}
if ("`date'" == "c" | "`date'" == "C") & "`datemask'" != "" {
	gen temp = clock(`time',"`datemask'")
	drop `time'
	rename temp `time'
	format `time' %t`date'
}


if `N_init' > 0 {
		order _all, alpha
		order `time' `geo'
		tempfile temp_data
		qui save `temp_data', replace
		if "`datemask'" != "" {
			ds `geo' `geo'_num `time' `time'`date', not
		}
		if "`datemask'" == "" {
			ds `geo' `geo'_num `time', not
		}
		local check_new_var = "`r(varlist)'"
		restore
		cap drop _merge
		ds `geo' `time', not
		local check_restore = "`r(varlist)'"
		foreach variable of local check_new_var {
			foreach variable2 of local check_restore {
				cap assert "`variable'" != "`variable2'"
				if _rc != 0 {
					di in red "WARNING: A variable named `vname' already existed and has been replaced"
					cap drop `variable'
				}
			}
		}
		qui merge 1:1 `time' `geo' using `temp_data', nogenerate force
		sort `time' `geo'
		order `time' `geo'
	}
}
sort `time' `geo'
order _all, alpha
order `time' `geo'

end
