capture program drop himap
*================================================================================================================================
*!himap v2.0 Thomas Roca, August 2014. 
*It uses 13 javascript files that are provided locally, but that are also available online: 
	*"jquery-1.9.1.js" 				(http://code.jquery.com/jquery-1.9.1.js) 
	*"highmaps.js" 					(http://code.highcharts.com/maps/highmaps.js)
	*"exporting.js" 				(http://code.highcharts.com/maps/modules/exporting.js)
	*"world-highres.js" 			(http://code.highcharts.com/mapdata/custom/world-highres.js)
	*"world-eckert3-highres.js"		(http://code.highcharts.com/mapdata/custom/world-eckert3-highres.js)
	*"world-robinson-highres.js"	(http://code.highcharts.com/mapdata/custom/world-robinson-highres.js)
	*"africa.js"		 			(http://code.highcharts.com/mapdata/custom/africa.js)
	*"asia.js"						(http://code.highcharts.com/mapdata/custom/asia.js)
	*"europe.js"					(http://code.highcharts.com/mapdata/custom/europe.js)
	*"middle-east.js" 				(http://code.highcharts.com/mapdata/custom/middle-east.js)
	*"north-america.js"				(http://code.highcharts.com/mapdata/custom/north-ameria.js)
	*"oceania.js"					(http://code.highcharts.com/mapdata/custom/oceania.js)
	*"south-america.js" 			(http://code.highcharts.com/mapdata/custom/south-america.js)

*A new set of option have been design like the choice of projection (natural earth [default], EckertIII or Robinson
*A country identifier variable must exist in the dataset; this variable must be named "iso3" and contains country ISO 3166-1 alpha-3 codes.
* himap PTS iso3 year using test.html, time(2012)
*===============================================================================================================================

program define himap, rclass sortpreserve
version 9.0
syntax varlist(min=3 max=3) 	/// variable to display iso3
	using						/// filename
	[, 							/// options						
	width(integer 1000)			/// Width of the map																			->[default 1000px]					
	height(integer 600)			/// height of the map																			->[default 700px]
	rgb1(str) 					/// rgb	color																					->[default blue]
	rgb2(str)					/// rgb	color max																				->[default blue]
	time(integer 2000) 			/// the actual value of time id (j) 															->[default 2000]
	projection(str)				/// Projection type: eckert ; robison ; world 													>[default World: natural earth]
	zone(integer 0)				/// 0=World|1=Africa|2=Asia|3=Europe|4=Middle East|5=North & central America|6=Oceania |7=South America ->[default World]
	]	
		
quietly {

capture cd "`dir'"

*===============================================================================
* 	Generate folders that will host HTML, java & image files needed 
*===============================================================================
capture mkdir himap
cd "`c(pwd)'/himap"
capture mkdir himap_js

*===============================================================================
*       Copy from ado directory the java & image files needed 
*===============================================================================

*List of files to copy into himap/himap_js/.
local listJava jquery-1.9.1.js exporting.js highmaps.js world-highres.js world-eckert3-highres.js world-robinson-highres.js africa.js asia.js europe.js middle-east.js north-america.js oceania.js south-america.js


*Search for himap.ado and store its path
findfile himap.ado, all			 
local folder=subinstr(`"`r(fn)'"',"himap.ado","",.)

*Copy the js files needed 
foreach file in `listJava' {
capture copy `folder'/himap_js/`file' himap_js/`file'
}
*store directory
capture local dir=subinstr(`"`c(pwd)'"',"/himap","",.) 	// unix
capture local dir=subinstr(`"`c(pwd)'"',"\himap","",.) 	// Windows

*===============================================================================
*      Set parameters 
*===============================================================================

gettoken ucmd filename : using 
local         filename `filename'


*Var1 is the variable to draw, id is the (i), j is time id
local Var: word 1 of `varlist'
local id: word 2 of `varlist'
local j: word 3 of `varlist'  


qui sum `Var' if `j'==`time'  // test whether ther's data or not
if `r(N)'==0 error 2000

*Store variable label
local label="`: var label `Var''"
if missing("`label'") local label="`Var'"

*Set map dimensions
if missing("`width'") local width=850
if missing("`height'") local height=700

*Set colors
if missing("`rgb1'") local rgb1="224, 233, 249"
if missing("`rgb2'") local rgb2="1, 57, 118"
*set projection option

if missing("`projection'") local projection="world-highres" 
if "`projection'"=="robinson" local projection="world-robinson-highres"
if "`projection'"=="eckert"  local projection="world-eckert3-highres"


*set zone
if `zone'!=0 { 
local iter=0
foreach terre in world-highres africa asia europe middle-east north-america oceania south-america {
if `zone'==`iter' local projection="`terre'"
local iter=`iter'+1
}
local iter=0
}

	
noisily di as text "....."
noisily di as text " Variable to map:`Var', counntry id:`id', Time id:`j', selected time:`time', projection:`projection', zone: `zone'" // summury  of what we draw here


*===============================================================================
local iso3list AFG ALB ATA DZA ASM AND AGO ATG AZE ARG AUS AUT BHS BHR BGD ARM BRB BEL BMU BTN BOL BIH BWA BVT BRA BLZ IOT SLB VGB BRN BGR MMR BDI BLR KHM CMR CAN CPV CYM CAF LKA TCD CHL CHN TWN CXR CCK COL COM MYT COG COD COK CRI HRV CUB CYP CZE BEN DNK DMA DOM ECU SLV GNQ ETH ERI EST FRO FLK SGS FJI FIN ALA FRA GUF PYF ATF DJI GAB GEO GMB PSE DEU GHA GIB KIR GRC GRL GRD GLP GUM GTM GIN GUY HTI HMD VAT HND HKG HUN ISL IND IDN IRN IRQ IRL ISR ITA CIV JAM JPN KAZ JOR KEN PRK KOR KWT KGZ LAO LBN LSO LVA LBR LBY LIE LTU LUX MAC MDG MWI MYS MDV MLI MLT MTQ MRT MUS MEX MCO MNG MDA MNE MSR MAR MOZ OMN NAM NRU NPL NLD CUW ABW SXM BES NCL VUT NZL NIC NER NGA NIU NFK NOR MNP UMI FSM MHL PLW PAK PAN PNG PRY PER PHL PCN POL PRT GNB TLS PRI QAT REU ROU RUS RWA BLM SHN KNA AIA LCA MAF SPM VCT SMR STP SAU SEN SRB SYC SLE SGP SVK VNM SVN SOM ZAF ZWE ESP SSD SDN ESH SUR SJM SWZ SWE CHE SYR TJK THA TGO TKL TON TTO ARE TUN TUR TKM TCA TUV UGA UKR MKD EGY GBR GGY JEY IMN TZA USA VIR BFA URY UZB VEN WLF WSM YEM ZMB ¤LIST_END¤

*Count the number of iso3 id in the list
local LoopEnd : word count `iso3list'
di `LoopEnd'
*Store descriptive stats of the selected variable
qui sum `Var' if `j'==`time'
local min=`r(min)'
local max=`r(max)'


*=================   Generate the HTML file    ================================= 
tempname page
file open `page' using "page", r w
file write `page' ///
`" <!DOCTYPE HTML>																										"' _n /// 
`" <html><head>																											"' _n /// 
`" <meta http-equiv="content-type" content="text/html; charset=UTF-8"> 													"' _n /// 
`"   <title>World Heat map - himaps - with Stata by ThomasRoca</title>												"' _n /// 
`"   <script type='text/javascript' src='himap_js/jquery-1.9.1.js'></script>											"' _n /// 
`"   <style type='text/css'>																							"' _n /// 
`"   #container { 																										"' _n ///
`"	height: `height'px ;  width: `width'px; margin: 0 auto; 															"' _n /// 
`"	}  																													"' _n ///
`" .loading { 																											"' _n ///
`"    margin-top: 10em; text-align: center; color: 'rgb(`rgb2')'; 																"' _n ///
`"  } 																													"' _n ///
`"  </style>  																											"' _n ///
`" <script type='text/javascript'>																						"' _n ///
`" $(function () {																										"' _n ///
`"																														"' _n ///
`"    var data = [  																									"' _n

*==========================  Write the data   ==================================
*Set loop count local as 0
local L=0

foreach iso in `iso3list' {
*Add +1 to loop count 
local L=`L'+1

*Store country and iso2 information
#delimit ;
if "`iso'"=="AFG" local iso2="af" ; if "`iso'"=="AFG" local country="Afghanistan"; if "`iso'"=="ALB" local iso2="al" ; if "`iso'"=="ALB" local country="Albania"; if "`iso'"=="DZA" local iso2="dz" ; if "`iso'"=="DZA" local country="Algeria"; if "`iso'"=="ASM" local iso2="as" ; if "`iso'"=="ASM" local country="American Samoa"; if "`iso'"=="AND" local iso2="ad" ; if "`iso'"=="AND" local country="Andorra"; if "`iso'"=="AGO" local iso2="ao" ; if "`iso'"=="AGO" local country="Angola"; if "`iso'"=="ATG" local iso2="ai" ; if "`iso'"=="ATG" local country="Antigua and Barbuda"; if "`iso'"=="ARG" local iso2="ar" ; if "`iso'"=="ARG" local country="Argentina"; if "`iso'"=="ARM" local iso2="am" ; if "`iso'"=="ARM" local country="Armenia"; if "`iso'"=="ABW" local iso2="aw" ; if "`iso'"=="ABW" local country="Aruba"; if "`iso'"=="AUS" local iso2="au" ; if "`iso'"=="AUS" local country="Australia"; if "`iso'"=="AUT" local iso2="at" ; if "`iso'"=="AUT" local country="Austria"; if "`iso'"=="AZE" local iso2="az" ; if "`iso'"=="AZE" local country="Azerbaijan"; if "`iso'"=="BHS" local iso2="bs" ; if "`iso'"=="BHS" local country="Bahamas, The"; if "`iso'"=="BHR" local iso2="bh" ; if "`iso'"=="BHR" local country="Bahrain"; if "`iso'"=="BGD" local iso2="bd" ; if "`iso'"=="BGD" local country="Bangladesh"; if "`iso'"=="BRB" local iso2="bb" ; if "`iso'"=="BRB" local country="Barbados"; if "`iso'"=="BLR" local iso2="by" ; if "`iso'"=="BLR" local country="Belarus"; if "`iso'"=="BEL" local iso2="be" ; if "`iso'"=="BEL" local country="Belgium"; if "`iso'"=="BLZ" local iso2="bz" ; if "`iso'"=="BLZ" local country="Belize"; if "`iso'"=="BEN" local iso2="bj" ; if "`iso'"=="BEN" local country="Benin"; if "`iso'"=="BMU" local iso2="bm" ; if "`iso'"=="BMU" local country="Bermuda"; if "`iso'"=="BTN" local iso2="bt" ; if "`iso'"=="BTN" local country="Bhutan"; if "`iso'"=="BOL" local iso2="bo" ; if "`iso'"=="BOL" local country="Bolivia"; if "`iso'"=="BIH" local iso2="ba" ; if "`iso'"=="BIH" local country="Bosnia and Herzegovina"; if "`iso'"=="BWA" local iso2="bw" ; if "`iso'"=="BWA" local country="Botswana"; if "`iso'"=="BRA" local iso2="br" ; if "`iso'"=="BRA" local country="Brazil"; if "`iso'"=="BRN" local iso2="bn" ; if "`iso'"=="BRN" local country="Brunei Darussalam"; if "`iso'"=="BGR" local iso2="bg" ; if "`iso'"=="BGR" local country="Bulgaria"; if "`iso'"=="BFA" local iso2="bf" ; if "`iso'"=="BFA" local country="Burkina Faso"; if "`iso'"=="BDI" local iso2="bi" ; if "`iso'"=="BDI" local country="Burundi"; if "`iso'"=="KHM" local iso2="kh" ; if "`iso'"=="KHM" local country="Cambodia"; if "`iso'"=="CMR" local iso2="cm" ; if "`iso'"=="CMR" local country="Cameroon"; if "`iso'"=="CAN" local iso2="ca" ; if "`iso'"=="CAN" local country="Canada"; if "`iso'"=="CPV" local iso2="cv" ; if "`iso'"=="CPV" local country="Cape Verde"; if "`iso'"=="CYM" local iso2="ky" ; if "`iso'"=="CYM" local country="Cayman Islands"; if "`iso'"=="CAF" local iso2="cf" ; if "`iso'"=="CAF" local country="Central African Republic"; if "`iso'"=="TCD" local iso2="td" ; if "`iso'"=="TCD" local country="Chad"; if "`iso'"=="CHL" local iso2="cl" ; if "`iso'"=="CHL" local country="Chile"; if "`iso'"=="CHN" local iso2="cn" ; if "`iso'"=="CHN" local country="China"; if "`iso'"=="COL" local iso2="co" ; if "`iso'"=="COL" local country="Colombia"; if "`iso'"=="COM" local iso2="km" ; if "`iso'"=="COM" local country="Comoros"; if "`iso'"=="COD" local iso2="cd" ; if "`iso'"=="COD" local country="Congo, Dem. Rep."; if "`iso'"=="COG" local iso2="cg" ; if "`iso'"=="COG" local country="Congo, Rep."; if "`iso'"=="CRI" local iso2="cr" ; if "`iso'"=="CRI" local country="Costa Rica"; if "`iso'"=="CIV" local iso2="ci" ; if "`iso'"=="CIV" local country="Cote d'Ivoire"; if "`iso'"=="HRV" local iso2="hr" ; if "`iso'"=="HRV" local country="Croatia"; if "`iso'"=="CUB" local iso2="cu" ; if "`iso'"=="CUB" local country="Cuba"; if "`iso'"=="CUW" local iso2="cw" ; if "`iso'"=="CUW" local country="Curacao"; if "`iso'"=="CYP" local iso2="cy" ; if "`iso'"=="CYP" local country="Cyprus"; if "`iso'"=="CZE" local iso2="cz" ; if "`iso'"=="CZE" local country="Czech Republic"; if "`iso'"=="DNK" local iso2="dk" ; if "`iso'"=="DNK" local country="Denmark"; if "`iso'"=="DJI" local iso2="dj" ; if "`iso'"=="DJI" local country="Djibouti"; if "`iso'"=="DMA" local iso2="dm" ; if "`iso'"=="DMA" local country="Dominica"; if "`iso'"=="DOM" local iso2="do" ; if "`iso'"=="DOM" local country="Dominican Republic"; if "`iso'"=="ECU" local iso2="ec" ; if "`iso'"=="ECU" local country="Ecuador"; if "`iso'"=="EGY" local iso2="eg" ; if "`iso'"=="EGY" local country="Egypt, Arab Rep."; if "`iso'"=="SLV" local iso2="sv" ; if "`iso'"=="SLV" local country="El Salvador"; if "`iso'"=="GNQ" local iso2="gq" ; if "`iso'"=="GNQ" local country="Equatorial Guinea"; if "`iso'"=="ERI" local iso2="er" ; if "`iso'"=="ERI" local country="Eritrea"; if "`iso'"=="EST" local iso2="ee" ; if "`iso'"=="EST" local country="Estonia"; if "`iso'"=="ETH" local iso2="et" ; if "`iso'"=="ETH" local country="Ethiopia"; if "`iso'"=="FRO" local iso2="fo" ; if "`iso'"=="FRO" local country="Faeroe Islands"; if "`iso'"=="FJI" local iso2="fj" ; if "`iso'"=="FJI" local country="Fiji"; if "`iso'"=="FIN" local iso2="fi" ; if "`iso'"=="FIN" local country="Finland"; if "`iso'"=="FRA" local iso2="fr" ; if "`iso'"=="FRA" local country="France"; if "`iso'"=="PYF" local iso2="pf" ; if "`iso'"=="PYF" local country="French Polynesia"; if "`iso'"=="GAB" local iso2="ga" ; if "`iso'"=="GAB" local country="Gabon"; if "`iso'"=="GMB" local iso2="gm" ; if "`iso'"=="GMB" local country="Gambia, The"; if "`iso'"=="GEO" local iso2="ge" ; if "`iso'"=="GEO" local country="Georgia"; if "`iso'"=="DEU" local iso2="de" ; if "`iso'"=="DEU" local country="Germany"; if "`iso'"=="GHA" local iso2="gh" ; if "`iso'"=="GHA" local country="Ghana"; if "`iso'"=="GRC" local iso2="gr" ; if "`iso'"=="GRC" local country="Greece"; if "`iso'"=="GRL" local iso2="gl" ; if "`iso'"=="GRL" local country="Greenland"; if "`iso'"=="GRD" local iso2="gd" ; if "`iso'"=="GRD" local country="Grenada"; if "`iso'"=="GUM" local iso2="gu" ; if "`iso'"=="GUM" local country="Guam"; if "`iso'"=="GTM" local iso2="gt" ; if "`iso'"=="GTM" local country="Guatemala"; if "`iso'"=="GIN" local iso2="gn" ; if "`iso'"=="GIN" local country="Guinea"; if "`iso'"=="GNB" local iso2="gw" ; if "`iso'"=="GNB" local country="Guinea-Bissau"; if "`iso'"=="GUY" local iso2="gy" ; if "`iso'"=="GUY" local country="Guyana"; if "`iso'"=="HTI" local iso2="ht" ; if "`iso'"=="HTI" local country="Haiti"; if "`iso'"=="HND" local iso2="hn" ; if "`iso'"=="HND" local country="Honduras"; if "`iso'"=="HKG" local iso2="hk" ; if "`iso'"=="HKG" local country="Hong Kong SAR, China"; if "`iso'"=="HUN" local iso2="hu" ; if "`iso'"=="HUN" local country="Hungary"; if "`iso'"=="ISL" local iso2="is" ; if "`iso'"=="ISL" local country="Iceland"; if "`iso'"=="IND" local iso2="in" ; if "`iso'"=="IND" local country="India"; if "`iso'"=="IDN" local iso2="id" ; if "`iso'"=="IDN" local country="Indonesia"; if "`iso'"=="IRN" local iso2="ir" ; if "`iso'"=="IRN" local country="Iran, Islamic Rep."; if "`iso'"=="IRQ" local iso2="iq" ; if "`iso'"=="IRQ" local country="Iraq"; if "`iso'"=="IRL" local iso2="ie" ; if "`iso'"=="IRL" local country="Ireland"; if "`iso'"=="IMN" local iso2="im" ; if "`iso'"=="IMN" local country="Isle of Man"; if "`iso'"=="ISR" local iso2="il" ; if "`iso'"=="ISR" local country="Israel"; if "`iso'"=="ITA" local iso2="it" ; if "`iso'"=="ITA" local country="Italy"; if "`iso'"=="JAM" local iso2="jm" ; if "`iso'"=="JAM" local country="Jamaica"; if "`iso'"=="JPN" local iso2="jp" ; if "`iso'"=="JPN" local country="Japan"; if "`iso'"=="JOR" local iso2="jo" ; if "`iso'"=="JOR" local country="Jordan"; if "`iso'"=="KAZ" local iso2="kz" ; if "`iso'"=="KAZ" local country="Kazakhstan"; if "`iso'"=="KEN" local iso2="ke" ; if "`iso'"=="KEN" local country="Kenya"; if "`iso'"=="KIR" local iso2="ki" ; if "`iso'"=="KIR" local country="Kiribati"; if "`iso'"=="PRK" local iso2="kp" ; if "`iso'"=="PRK" local country="Korea, Dem. Rep."; if "`iso'"=="KOR" local iso2="kr" ; if "`iso'"=="KOR" local country="Korea, Rep."; if "`iso'"=="UNK" local iso2="xk" ; if "`iso'"=="UNK" local country="Kosovo"; if "`iso'"=="KWT" local iso2="kw" ; if "`iso'"=="KWT" local country="Kuwait"; if "`iso'"=="KGZ" local iso2="kg" ; if "`iso'"=="KGZ" local country="Kyrgyz Republic"; if "`iso'"=="LAO" local iso2="la" ; if "`iso'"=="LAO" local country="Lao PDR"; if "`iso'"=="LVA" local iso2="lv" ; if "`iso'"=="LVA" local country="Latvia"; if "`iso'"=="LBN" local iso2="lb" ; if "`iso'"=="LBN" local country="Lebanon"; if "`iso'"=="LSO" local iso2="ls" ; if "`iso'"=="LSO" local country="Lesotho"; if "`iso'"=="LBR" local iso2="lr" ; if "`iso'"=="LBR" local country="Liberia"; if "`iso'"=="LBY" local iso2="ly" ; if "`iso'"=="LBY" local country="Libya"; if "`iso'"=="LIE" local iso2="li" ; if "`iso'"=="LIE" local country="Liechtenstein"; if "`iso'"=="LTU" local iso2="lt" ; if "`iso'"=="LTU" local country="Lithuania"; if "`iso'"=="LUX" local iso2="lu" ; if "`iso'"=="LUX" local country="Luxembourg"; if "`iso'"=="MAC" local iso2="mo" ; if "`iso'"=="MAC" local country="Macao SAR, China"; if "`iso'"=="MKD" local iso2="mk" ; if "`iso'"=="MKD" local country="Macedonia, FYR"; if "`iso'"=="MDG" local iso2="mg" ; if "`iso'"=="MDG" local country="Madagascar"; if "`iso'"=="MWI" local iso2="mw" ; if "`iso'"=="MWI" local country="Malawi"; if "`iso'"=="MYS" local iso2="my" ; if "`iso'"=="MYS" local country="Malaysia"; if "`iso'"=="MDV" local iso2="mv" ; if "`iso'"=="MDV" local country="Maldives"; if "`iso'"=="MLI" local iso2="ml" ; if "`iso'"=="MLI" local country="Mali"; if "`iso'"=="MLT" local iso2="mt" ; if "`iso'"=="MLT" local country="Malta"; if "`iso'"=="MHL" local iso2="mh" ; if "`iso'"=="MHL" local country="Marshall Islands"; if "`iso'"=="MRT" local iso2="mr" ; if "`iso'"=="MRT" local country="Mauritania"; if "`iso'"=="MUS" local iso2="mu" ; if "`iso'"=="MUS" local country="Mauritius"; if "`iso'"=="MYT" local iso2="yt" ; if "`iso'"=="MYT" local country="Mayotte"; if "`iso'"=="MEX" local iso2="mx" ; if "`iso'"=="MEX" local country="Mexico"; if "`iso'"=="FSM" local iso2="fm" ; if "`iso'"=="FSM" local country="Micronesia, Fed. Sts."; if "`iso'"=="MDA" local iso2="md" ; if "`iso'"=="MDA" local country="Moldova"; if "`iso'"=="MCO" local iso2="mc" ; if "`iso'"=="MCO" local country="Monaco"; if "`iso'"=="MNG" local iso2="mn" ; if "`iso'"=="MNG" local country="Mongolia"; if "`iso'"=="MNE" local iso2="me" ; if "`iso'"=="MNE" local country="Montenegro"; if "`iso'"=="MAR" local iso2="ma" ; if "`iso'"=="MAR" local country="Morocco"; if "`iso'"=="MOZ" local iso2="mz" ; if "`iso'"=="MOZ" local country="Mozambique"; if "`iso'"=="MMR" local iso2="mm" ; if "`iso'"=="MMR" local country="Myanmar"; if "`iso'"=="NAM" local iso2="na" ; if "`iso'"=="NAM" local country="Namibia"; if "`iso'"=="NPL" local iso2="np" ; if "`iso'"=="NPL" local country="Nepal"; if "`iso'"=="NLD" local iso2="nl" ; if "`iso'"=="NLD" local country="Netherlands"; if "`iso'"=="NCL" local iso2="nc" ; if "`iso'"=="NCL" local country="New Caledonia"; if "`iso'"=="NZL" local iso2="nz" ; if "`iso'"=="NZL" local country="New Zealand"; if "`iso'"=="NIC" local iso2="ni" ; if "`iso'"=="NIC" local country="Nicaragua"; if "`iso'"=="NER" local iso2="ne" ; if "`iso'"=="NER" local country="Niger"; if "`iso'"=="NGA" local iso2="ng" ; if "`iso'"=="NGA" local country="Nigeria"; if "`iso'"=="MNP" local iso2="mp" ; if "`iso'"=="MNP" local country="Northern Mariana Islands"; if "`iso'"=="NOR" local iso2="no" ; if "`iso'"=="NOR" local country="Norway"; if "`iso'"=="OMN" local iso2="om" ; if "`iso'"=="OMN" local country="Oman"; if "`iso'"=="PAK" local iso2="pk" ; if "`iso'"=="PAK" local country="Pakistan"; if "`iso'"=="PLW" local iso2="pw" ; if "`iso'"=="PLW" local country="Palau"; if "`iso'"=="PAN" local iso2="pa" ; if "`iso'"=="PAN" local country="Panama"; if "`iso'"=="PNG" local iso2="pg" ; if "`iso'"=="PNG" local country="Papua New Guinea"; if "`iso'"=="PRY" local iso2="py" ; if "`iso'"=="PRY" local country="Paraguay"; if "`iso'"=="PER" local iso2="pe" ; if "`iso'"=="PER" local country="Peru"; if "`iso'"=="PHL" local iso2="ph" ; if "`iso'"=="PHL" local country="Philippines"; if "`iso'"=="POL" local iso2="pl" ; if "`iso'"=="POL" local country="Poland"; if "`iso'"=="PRT" local iso2="pt" ; if "`iso'"=="PRT" local country="Portugal"; if "`iso'"=="PRI" local iso2="pr" ; if "`iso'"=="PRI" local country="Puerto Rico"; if "`iso'"=="QAT" local iso2="wa" ; if "`iso'"=="QAT" local country="Qatar"; if "`iso'"=="ROU" local iso2="ro" ; if "`iso'"=="ROU" local country="Romania"; if "`iso'"=="RUS" local iso2="ru" ; if "`iso'"=="RUS" local country="Russian Federation"; if "`iso'"=="RWA" local iso2="rw" ; if "`iso'"=="RWA" local country="Rwanda"; if "`iso'"=="WSM" local iso2="ws" ; if "`iso'"=="WSM" local country="Samoa"; if "`iso'"=="SMR" local iso2="sm" ; if "`iso'"=="SMR" local country="San Marino"; if "`iso'"=="STP" local iso2="st" ; if "`iso'"=="STP" local country="Sao Tome and Principe"; if "`iso'"=="SAU" local iso2="sa" ; if "`iso'"=="SAU" local country="Saudi Arabia"; if "`iso'"=="SEN" local iso2="sn" ; if "`iso'"=="SEN" local country="Senegal"; if "`iso'"=="SRB" local iso2="rs" ; if "`iso'"=="SRB" local country="Serbia"; if "`iso'"=="SYC" local iso2="sc" ; if "`iso'"=="SYC" local country="Seychelles"; if "`iso'"=="SLE" local iso2="sl" ; if "`iso'"=="SLE" local country="Sierra Leone"; if "`iso'"=="SGP" local iso2="sg" ; if "`iso'"=="SGP" local country="Singapore"; if "`iso'"=="SVK" local iso2="sk" ; if "`iso'"=="SVK" local country="Slovak Republic"; if "`iso'"=="SVN" local iso2="si" ; if "`iso'"=="SVN" local country="Slovenia"; if "`iso'"=="SLB" local iso2="sb" ; if "`iso'"=="SLB" local country="Solomon Islands"; if "`iso'"=="SOM" local iso2="so" ; if "`iso'"=="SOM" local country="Somalia"; if "`iso'"=="ZAF" local iso2="za" ; if "`iso'"=="ZAF" local country="South Africa"; if "`iso'"=="SSD" local iso2="ss" ; if "`iso'"=="SSD" local country="South Sudan"; if "`iso'"=="ESP" local iso2="es" ; if "`iso'"=="ESP" local country="Spain"; if "`iso'"=="LKA" local iso2="lk" ; if "`iso'"=="LKA" local country="Sri Lanka"; if "`iso'"=="KNA" local iso2="kn" ; if "`iso'"=="KNA" local country="St. Kitts and Nevis"; if "`iso'"=="LCA" local iso2="lc" ; if "`iso'"=="LCA" local country="St. Lucia"; if "`iso'"=="MAF" local iso2="mf" ; if "`iso'"=="MAF" local country="St. Martin (French part)"; if "`iso'"=="VCT" local iso2="vc" ; if "`iso'"=="VCT" local country="St. Vincent and the Grenadines"; if "`iso'"=="SDN" local iso2="sd" ; if "`iso'"=="SDN" local country="Sudan"; if "`iso'"=="SUR" local iso2="sr" ; if "`iso'"=="SUR" local country="Suriname"; if "`iso'"=="SWZ" local iso2="sz" ; if "`iso'"=="SWZ" local country="Swaziland"; if "`iso'"=="SWE" local iso2="se" ; if "`iso'"=="SWE" local country="Sweden"; if "`iso'"=="CHE" local iso2="ch" ; if "`iso'"=="CHE" local country="Switzerland"; if "`iso'"=="SYR" local iso2="sy" ; if "`iso'"=="SYR" local country="Syrian Arab Republic"; if "`iso'"=="TJK" local iso2="tj" ; if "`iso'"=="TJK" local country="Tajikistan"; if "`iso'"=="TZA" local iso2="tz" ; if "`iso'"=="TZA" local country="Tanzania"; if "`iso'"=="THA" local iso2="th" ; if "`iso'"=="THA" local country="Thailand"; if "`iso'"=="TLS" local iso2="tp" ; if "`iso'"=="TLS" local country="Timor-Leste"; if "`iso'"=="TGO" local iso2="tg" ; if "`iso'"=="TGO" local country="Togo"; if "`iso'"=="TON" local iso2="to" ; if "`iso'"=="TON" local country="Tonga"; if "`iso'"=="TTO" local iso2="tt" ; if "`iso'"=="TTO" local country="Trinidad and Tobago"; if "`iso'"=="TUN" local iso2="tn" ; if "`iso'"=="TUN" local country="Tunisia"; if "`iso'"=="TUR" local iso2="tr" ; if "`iso'"=="TUR" local country="Turkey"; if "`iso'"=="TKM" local iso2="tm" ; if "`iso'"=="TKM" local country="Turkmenistan"; if "`iso'"=="TCA" local iso2="tc" ; if "`iso'"=="TCA" local country="Turks and Caicos Islands"; if "`iso'"=="TUV" local iso2="tv" ; if "`iso'"=="TUV" local country="Tuvalu"; if "`iso'"=="UGA" local iso2="ug" ; if "`iso'"=="UGA" local country="Uganda"; if "`iso'"=="UKR" local iso2="ua" ; if "`iso'"=="UKR" local country="Ukraine"; if "`iso'"=="ARE" local iso2="ae" ; if "`iso'"=="ARE" local country="United Arab Emirates"; if "`iso'"=="GBR" local iso2="gb" ; if "`iso'"=="GBR" local country="United Kingdom"; if "`iso'"=="USA" local iso2="us" ; if "`iso'"=="USA" local country="United States"; if "`iso'"=="URY" local iso2="uy" ; if "`iso'"=="URY" local country="Uruguay"; if "`iso'"=="UZB" local iso2="uz" ; if "`iso'"=="UZB" local country="Uzbekistan"; if "`iso'"=="VUT" local iso2="vu" ; if "`iso'"=="VUT" local country="Vanuatu"; if "`iso'"=="VEN" local iso2="ve" ; if "`iso'"=="VEN" local country="Venezuela, RB"; if "`iso'"=="VNM" local iso2="vn" ; if "`iso'"=="VNM" local country="Vietnam"; if "`iso'"=="VIR" local iso2="vi" ; if "`iso'"=="VIR" local country="Virgin Islands (U.S.)"; if "`iso'"=="PSE" local iso2="ps" ; if "`iso'"=="PSE" local country="West Bank and Gaza"; if "`iso'"=="ESH" local iso2="eh" ; if "`iso'"=="ESH" local country="Western Sahara"; if "`iso'"=="YEM" local iso2="ye" ; if "`iso'"=="YEM" local country="Yemen, Rep."; if "`iso'"=="ZMB" local iso2="zm" ; if "`iso'"=="ZMB" local country="Zambia"; 	if "`iso'"=="ZWE" local iso2="zw" ; if "`iso'"=="ZWE" local country="Zimbabwe"; if "`iso'"=="TWN" local iso2="tw" ; if "`iso'"=="TWN" local country="Taiwan";
#delimit cr

*test if variable is not missing for corresponding i and j
qui sum `Var' if `id'=="`iso'" & `j'==`time'

*if not missing: 
if `r(N)'!=0 {
*store value of the variable for the corresponding i and j 
qui levelsof `Var' if `id'=="`iso'" & `j'==`time', local(value)
*set value format
local value : dis %4.3f `value'
*write html content 
file write `page'  `"	 {"hc-key":"`iso2'","value":`value'},   "' _n
	}
*when arriving to the end of the loop, write this line (nb. allows to be sure to have no coma at the end of the last line) 
if "`iso'"=="¤LIST_END¤" file write `page'  `"	 {"hc-key": "ABSURDISTAN","value":0}  "' _n	
}
file write `page'  `" 	];  "' _n
*===============================================================================

file write `page' ///		
`"     $('#container').highcharts('Map', { 												"' _n /// 
`"         title : {text : '`label', `time''},											"' _n /// 
`"         subtitle : {text : ' '},														"' _n /// 
`"         mapNavigation: {enabled: true, buttonOptions: {verticalAlign: 'bottom'}},	"' _n /// 
`"          colorAxis: {min: `min', stops: [	[0, 'rgb(`rgb1')'],[1,'rgb(`rgb2')']]},	"' _n /// 
`"         series : [{																	"' _n /// 
`"             data : data, mapData: Highcharts.maps['custom/`projection''], joinBy: 'hc-key', name: '`label'',	"' _n /// 
`"             states: { hover: { color: 'rgb(`rgb1')'}},									"' _n /// 
`"             dataLabels: { enabled: false,format: '{point.name}' }					"' _n /// 
`"         }]   }); });																	"' _n /// 
`" </script></head><body>																"' _n /// 
`" <script src="himap_js/highmaps.js"></script>										"' _n /// 
`" <script src="himap_js/exporting.js"></script>										"' _n /// 
`" <script src="himap_js/`projection'.js"></script>											"' _n /// 
`" <div id="container"></div>															"' _n /// 
`"  </body>																				"' _n /// 
`" </html>																				"' _n 
file close `page'

capture erase "`filename'"
capture !rename  "page"  "`filename'"			// windows
capture !mv  "page"  "`filename'"			    // unix
capture erase "page"
noisily di "....."
noisily di "Open output web page: " `"{browse "`c(pwd)'/`filename'"}"'
cd "`dir'"

}
end
