capture program drop gmap
/*================================================================================================================================
! gmap v2.0 Thomas Roca, September 2014. 
This program draws heat maps within and HTML file, using Google geochart javascript library (see https://google-developers.appspot.com/chart/interactive/docs/gallery/geochart)
A country identifier variable must exist in the dataset; this variable must be named "iso3" and contains country ISO 3166-1 alpha-3 codes.
Many options are available to personalize the map (i.e. region, color, size ..)

It uses 2 javascript files: 
	*"jquery-latest.js" 			(http://code.jquery.com/jquery-1.9.1.js) 
	*"jsapi"	 					(https://www.google.com/jsapi)
	
How to use it? see help gmap // e.g. of command gmap PTS iso3 year using test.html, time(2012)  
History: machine dependancy fixed
*===============================================================================================================================*/

program define gmap, rclass sortpreserve
version 9.0
syntax varlist(min=3 max=3) 			/// variable to display iso3 !NEED TO FIX THAT
	using								/// filename
	[, 									/// options						
	zone(integer 0)						/// 0=World;1=Europe;2=North America;3=South America;4=Africa;5=Asia;6=Asia Pacific;7=Oceania 		->[default World]
	color(integer 1)					/// Type in 1=Blue | 2=Green | 3=Purple | 4=Yellow  												->[default Blue]
	color1_rgb(string)					/// r,g,b
	color2_rgb(string)					/// r,g,b
	width(integer 850)					/// Width of the map																				->[default 850px]					
	height(integer 700)					/// height of the map																				->[default 700px]
	title(str)							/// title of the map																				->[default My gmap Title]
	legend(str) 						/// yes or no																						->[default no]
	time(integer 2000) 					/// the actual value of time id (j) 
	]
	
quietly {

capture cd "`dir'"

*===============================================================================
* 	Generate folders that will host HTML, java & image files needed 
*===============================================================================
capture mkdir gmap
cd "`c(pwd)'/gmap"

*===============================================================================
*       Copy from ado directory the java & image files needed 
*===============================================================================

*List of files to copy into gmap/.
local listJava jsapi jquery-latest.js

*Search for gmap.ado and store its path
findfile gmap.ado, all			 
local folder=subinstr(`"`r(fn)'"',"gmap.ado","",.)

*Copy the js files needed 
foreach file in `listJava' {
capture copy `folder'/`file' `file'
}

*store directory
capture local dir=subinstr(`"`c(pwd)'"',"/gmap","",.) 	// unix
capture local dir=subinstr(`"`c(pwd)'"',"\gmap","",.) 	// Windows

*===============================================================================
*      Set parameters 
*===============================================================================
gettoken ucmd filename : using 
local         filename `filename'

*Store var1 and var2 one of them is the iso3 coutry code (string) the other is a number
local Var: word 1 of `varlist'
local id: word 2 of `varlist'
local j: word 3 of `varlist'  

qui sum `Var' if `j'==`time'
if `r(N)'==0 error 2000 
noisily di as text "....."
noisily di as text " Variable to map:`Var', counntry id:`id', Time id:`j', selected time:`time'"


*setting default option
if missing("`title'") local title="a stata command"
if missing("`label'") local label="My data label"
if missing("`legend'") local legend="legend: 'none',"

if "`legend'"=="yes" local legend=""
if "`legend'"=="no" local legend="legend: 'none',"

local label="`: var label `Var''"

*======================= Set region option =====================================
#delimit ; 
if `zone'==0 local ZONE="world" ; if `zone'==1 local ZONE="150" ; if `zone'==2 local ZONE="021" ; if `zone'==3 local ZONE="005" ;
if `zone'==4 local ZONE="002" ; if `zone'==5 local ZONE="142" ; if `zone'==6 local ZONE="035" ; if `zone'==7 local ZONE="009" ;
if `zone'==0 local ZONEstr="world" ; if `zone'==1 local ZONEstr="Europe" ; if `zone'==2 local ZONEstr="North America" ; 
if `zone'==3 local ZONEstr="South America" ; if `zone'==4 local ZONEstr="Africa" ; if `zone'==5 local ZONEstr="Asia" ;
if `zone'==6 local ZONEstr="Asia Pacific" ; if `zone'==7 local ZONEstr="Oceania" ;
#delimit cr

*===============================================================================
*Set color options
local colorFormatted=`color'

if missing(`colorFormatted') local colorFormatted=1

if `colorFormatted'==1 {
local color1="#E0F2F7"
local color2="#045FB4"
}

if `colorFormatted'==2 {
local color1="#BCF5A9"
local color2="#04B431"
}

if `colorFormatted'==3 {
local color1="#F8E0F7"
local color2="#610B5E"
}

if `colorFormatted'==4 {
local color1="#F5F6CE"
local color2="#FFBF00"
}
*default values
if missing( "`color1_rgb'") |  missing( "`color2_rgb'") {
local color1="#E0F2F7"
local color2="#045FB4"
}

if !missing( "`color1_rgb'")  {
local color1="rgb(`color1_rgb')"
}
if !missing( "`color2_rgb'")  {
local color2="rgb(`color2_rgb')"
}


*===============================================================================
local iso3list AFG ALB ATA DZA ASM AND AGO ATG AZE ARG AUS AUT BHS BHR BGD ARM BRB BEL BMU BTN BOL BIH BWA BVT BRA BLZ IOT SLB VGB BRN BGR MMR BDI BLR KHM CMR CAN CPV CYM CAF LKA TCD CHL CHN TWN CXR CCK COL COM MYT COG COD COK CRI HRV CUB CYP CZE BEN DNK DMA DOM ECU SLV GNQ ETH ERI EST FRO FLK SGS FJI FIN ALA FRA GUF PYF ATF DJI GAB GEO GMB PSE DEU GHA GIB KIR GRC GRL GRD GLP GUM GTM GIN GUY HTI HMD VAT HND HKG HUN ISL IND IDN IRN IRQ IRL ISR ITA CIV JAM JPN KAZ JOR KEN PRK KOR KWT KGZ LAO LBN LSO LVA LBR LBY LIE LTU LUX MAC MDG MWI MYS MDV MLI MLT MTQ MRT MUS MEX MCO MNG MDA MNE MSR MAR MOZ OMN NAM NRU NPL NLD CUW ABW SXM BES NCL VUT NZL NIC NER NGA NIU NFK NOR MNP UMI FSM MHL PLW PAK PAN PNG PRY PER PHL PCN POL PRT GNB TLS PRI QAT REU ROU RUS RWA BLM SHN KNA AIA LCA MAF SPM VCT SMR STP SAU SEN SRB SYC SLE SGP SVK VNM SVN SOM ZAF ZWE ESP SSD SDN ESH SUR SJM SWZ SWE CHE SYR TJK THA TGO TKL TON TTO ARE TUN TUR TKM TCA TUV UGA UKR MKD EGY GBR GGY JEY IMN TZA USA VIR BFA URY UZB VEN WLF WSM YEM ZMB ¤LIST_END¤
*Count the number of iso3 id in the list
local LoopEnd : word count `iso3list'

*Store descriptive stats of the selected variable
qui sum `Var' if `j'==`time'
local min=`r(min)'
local max=`r(max)'

*Store variable label
local label="`: var label `Var''"
if missing("`label'") local label="`Var'"

*Set loop count local as 0
local L=0

tempname page
file open `page' using "page", r w
file write `page' ///	
`"  <script src="jquery-latest.js"></script> "' _n  ///
`"  <script type='text/javascript' src='jsapi'></script> "' _n  ///
`" <script type='text/javascript'> "' _n  ///
`"  google.load('visualization', '1', {packages: ['geochart']});"' _n  /// 
`"  google.setOnLoadCallback(drawChart); "' _n  ///
`"  function drawChart() { "' _n  ///
`"  var data = new google.visualization.DataTable(); "' _n  ///
`"  data.addColumn('string', 'Country'); "' _n  ///
`"  data.addColumn('number', '`label''); "' _n  ///
`"  data.addColumn('string', 'url'); "' _n  ///
`"  data.addRows([ "' _n  

foreach iso in `iso3list' {

*Add +1 to loop count 
local L=`L'+1

*Store country information
#delimit ;
if "`iso'"=="AFG" local country="Afghanistan" ; if "`iso'"=="ALB" local country="Albania" ; if "`iso'"=="DZA" local country="Algeria" ; if "`iso'"=="ASM" local country="American Samoa" ; if "`iso'"=="AND" local country="Andorra" ; if "`iso'"=="AGO" local country="Angola" ; if "`iso'"=="ATG" local country="Antigua and Barbuda" ; if "`iso'"=="ARG" local country="Argentina" ; if "`iso'"=="ARM" local country="Armenia" ; if "`iso'"=="ABW" local country="Aruba" ; if "`iso'"=="AUS" local country="Australia" ; if "`iso'"=="AUT" local country="Austria" ; if "`iso'"=="AZE" local country="Azerbaijan" ; if "`iso'"=="BHS" local country="Bahamas" ; if "`iso'"=="BHR" local country="Bahrain" ; if "`iso'"=="BGD" local country="Bangladesh" ; if "`iso'"=="BRB" local country="Barbados" ; if "`iso'"=="BLR" local country="Belarus" ; if "`iso'"=="BEL" local country="Belgium" ; if "`iso'"=="BLZ" local country="Belize" ; if "`iso'"=="BEN" local country="Benin" ; if "`iso'"=="BMU" local country="Bermuda" ; if "`iso'"=="BTN" local country="Bhutan" ; if "`iso'"=="BOL" local country="Bolivia" ; if "`iso'"=="BIH" local country="Bosnia and Herzegovina" ; if "`iso'"=="BWA" local country="Botswana" ; if "`iso'"=="BRA" local country="Brazil" ; if "`iso'"=="BRN" local country="Brunei" ; if "`iso'"=="BGR" local country="Bulgaria" ; if "`iso'"=="BFA" local country="Burkina Faso" ; if "`iso'"=="BDI" local country="Burundi" ; if "`iso'"=="KHM" local country="Cambodia" ; if "`iso'"=="CMR" local country="Cameroon" ; if "`iso'"=="CAN" local country="Canada" ; if "`iso'"=="CPV" local country="Cape Verde" ; if "`iso'"=="CYM" local country="Cayman Islands" ; if "`iso'"=="CAF" local country="Central African Republic" ; if "`iso'"=="TCD" local country="Chad" ; if "`iso'"=="CHL" local country="Chile" ; if "`iso'"=="CHN" local country="China" ; if "`iso'"=="COL" local country="Colombia" ; if "`iso'"=="COM" local country="Comoros" ; if "`iso'"=="COD" local country="Democratic Republic of the Congo" ; if "`iso'"=="COG" local country="Congo" ; if "`iso'"=="CRI" local country="Costa Rica" ; if "`iso'"=="CIV" local country="Ivory Coast" ; if "`iso'"=="HRV" local country="Croatia" ; if "`iso'"=="CUB" local country="Cuba" ; if "`iso'"=="CYP" local country="Cyprus" ; if "`iso'"=="CZE" local country="Czech Republic" ; if "`iso'"=="DNK" local country="Denmark" ; if "`iso'"=="DJI" local country="Djibouti" ; if "`iso'"=="DMA" local country="Dominica" ; if "`iso'"=="DOM" local country="Dominican Republic" ; if "`iso'"=="ECU" local country="Ecuador" ; if "`iso'"=="EGY" local country="Egypt" ; if "`iso'"=="SLV" local country="El Salvador" ; if "`iso'"=="GNQ" local country="Equatorial Guinea" ; if "`iso'"=="ERI" local country="Eritrea" ; if "`iso'"=="EST" local country="Estonia" ; if "`iso'"=="ETH" local country="Ethiopia" ; if "`iso'"=="FJI" local country="Fiji" ; if "`iso'"=="FIN" local country="Finland" ; if "`iso'"=="FRA" local country="France" ; if "`iso'"=="PYF" local country="French Polynesia" ; if "`iso'"=="GAB" local country="Gabon" ; if "`iso'"=="GMB" local country="Gambia" ; if "`iso'"=="GEO" local country="Georgia" ; if "`iso'"=="DEU" local country="Germany" ; if "`iso'"=="GHA" local country="Ghana" ; if "`iso'"=="GIB" local country="Gibraltar" ; if "`iso'"=="GRC" local country="Greece" ; if "`iso'"=="GRL" local country="Greenland" ; if "`iso'"=="GRD" local country="Grenada" ; if "`iso'"=="GUM" local country="Guam" ; if "`iso'"=="GTM" local country="Guatemala" ; if "`iso'"=="GIN" local country="Guinea" ; if "`iso'"=="GNB" local country="Guinea-Bissau" ; if "`iso'"=="GUY" local country="Guyana" ; if "`iso'"=="HTI" local country="Haiti" ; if "`iso'"=="HND" local country="Honduras" ; if "`iso'"=="HKG" local country="Hong Kong" ; if "`iso'"=="HUN" local country="Hungary" ; if "`iso'"=="ISL" local country="Iceland" ; if "`iso'"=="IND" local country="India" ; if "`iso'"=="IDN" local country="Indonesia" ; if "`iso'"=="IRN" local country="Iran" ; if "`iso'"=="IRQ" local country="Iraq" ; if "`iso'"=="IRL" local country="Ireland" ; if "`iso'"=="IMN" local country="Isle of Man" ; if "`iso'"=="ISR" local country="Israel" ; if "`iso'"=="ITA" local country="Italy" ; if "`iso'"=="JAM" local country="Jamaica" ; if "`iso'"=="JPN" local country="Japan" ; if "`iso'"=="JOR" local country="Jordan" ; if "`iso'"=="KAZ" local country="Kazakhstan" ; if "`iso'"=="KEN" local country="Kenya" ; if "`iso'"=="KIR" local country="Kiribati" ; if "`iso'"=="PRK" local country="North Korea" ; if "`iso'"=="KOR" local country="South Korea" ; if "`iso'"=="KWT" local country="Kuwait" ; if "`iso'"=="KGZ" local country="Kyrgyzstan" ; if "`iso'"=="LAO" local country="Laos" ; if "`iso'"=="LVA" local country="Latvia" ; if "`iso'"=="LBN" local country="Lebanon" ; if "`iso'"=="LSO" local country="Lesotho" ; if "`iso'"=="LBR" local country="Liberia" ; if "`iso'"=="LBY" local country="Libya" ; if "`iso'"=="LIE" local country="Liechtenstein" ; if "`iso'"=="LTU" local country="Lithuania" ; if "`iso'"=="LUX" local country="Luxembourg" ; if "`iso'"=="MAC" local country="Macau" ; if "`iso'"=="MKD" local country="The former Yugoslav Republic of Macedonia" ; if "`iso'"=="MDG" local country="Madagascar" ; if "`iso'"=="MWI" local country="Malawi" ; if "`iso'"=="MYS" local country="Malaysia" ; if "`iso'"=="MLI" local country="Mali" ; if "`iso'"=="MLT" local country="Malta" ; if "`iso'"=="MHL" local country="Marshall Islands" ; if "`iso'"=="MRT" local country="Mauritania" ; if "`iso'"=="MUS" local country="Mauritius" ; if "`iso'"=="MEX" local country="Mexico" ; if "`iso'"=="FSM" local country="Micronesia" ; if "`iso'"=="MDA" local country="Moldova" ; if "`iso'"=="MCO" local country="Monaco" ; if "`iso'"=="MNG" local country="Mongolia" ; if "`iso'"=="MNE" local country="Montenegro" ; if "`iso'"=="MAR" local country="Morocco" ; if "`iso'"=="MOZ" local country="Mozambique" ; if "`iso'"=="MMR" local country="Myanmar" ; if "`iso'"=="NAM" local country="Namibia" ; if "`iso'"=="NPL" local country="Nepal" ; if "`iso'"=="NLD" local country="Netherlands" ; if "`iso'"=="NZL" local country="New Zealand" ; if "`iso'"=="NIC" local country="Nicaragua" ; if "`iso'"=="NER" local country="Niger" ; if "`iso'"=="NGA" local country="Nigeria" ; if "`iso'"=="NOR" local country="Norway" ; if "`iso'"=="OMN" local country="Oman" ; if "`iso'"=="PAK" local country="Pakistan" ; if "`iso'"=="PLW" local country="Palau" ; if "`iso'"=="PAN" local country="Panama" ; if "`iso'"=="PNG" local country="Papua New Guinea" ; if "`iso'"=="PRY" local country="Paraguay" ; if "`iso'"=="PER" local country="Peru" ; if "`iso'"=="PHL" local country="Philippines" ; if "`iso'"=="POL" local country="Poland" ; if "`iso'"=="PRT" local country="Portugal" ; if "`iso'"=="PRI" local country="Puerto Rico" ; if "`iso'"=="QAT" local country="Qatar" ; if "`iso'"=="ROU" local country="Romania" ; if "`iso'"=="RUS" local country="Russia" ; if "`iso'"=="RWA" local country="Rwanda" ; if "`iso'"=="WSM" local country="Samoa" ; if "`iso'"=="SMR" local country="San Marino" ; if "`iso'"=="SAU" local country="Saudi Arabia" ; if "`iso'"=="SEN" local country="Senegal" ; if "`iso'"=="SRB" local country="Serbia" ; if "`iso'"=="SYC" local country="Seychelles" ; if "`iso'"=="SLE" local country="Sierra Leone" ; if "`iso'"=="SGP" local country="Singapore" ; if "`iso'"=="SVK" local country="Slovakia" ; if "`iso'"=="SVN" local country="Slovenia" ; if "`iso'"=="SLB" local country="Solomon Islands" ; if "`iso'"=="SOM" local country="Somalia" ; if "`iso'"=="ZAF" local country="South Africa" ; if "`iso'"=="ESP" local country="Spain" ; if "`iso'"=="LKA" local country="Sri Lanka" ; if "`iso'"=="KNA" local country="Saint Kitts and Nevis" ; if "`iso'"=="LCA" local country="Saint Lucia" ; if "`iso'"=="VCT" local country="Saint Vincent and the Grenadines" ; if "`iso'"=="SDN" local country="Sudan" ; if "`iso'"=="SUR" local country="Suriname" ; if "`iso'"=="SWZ" local country="Swaziland" ; if "`iso'"=="SWE" local country="Sweden" ; if "`iso'"=="CHE" local country="Switzerland" ; if "`iso'"=="SYR" local country="Syria" ; if "`iso'"=="TJK" local country="Tajikistan" ; if "`iso'"=="TZA" local country="Tanzania" ; if "`iso'"=="THA" local country="Thailand" ; if "`iso'"=="TLS" local country="Timor-Leste" ; if "`iso'"=="TGO" local country="Togo" ; if "`iso'"=="TON" local country="Tonga" ; if "`iso'"=="TTO" local country="Trinidad and Tobago" ; if "`iso'"=="TUN" local country="Tunisia" ; if "`iso'"=="TUR" local country="Turkey" ; if "`iso'"=="TKM" local country="Turkmenistan" ; if "`iso'"=="TCA" local country="Turks and Caicos Islands" ; if "`iso'"=="TUV" local country="Tuvalu" ; if "`iso'"=="UGA" local country="Uganda" ; if "`iso'"=="UKR" local country="Ukraine" ; if "`iso'"=="ARE" local country="United Arab Emirates" ; if "`iso'"=="GBR" local country="United Kingdom" ; if "`iso'"=="USA" local country="United States" ; if "`iso'"=="URY" local country="Uruguay" ; if "`iso'"=="UZB" local country="Uzbekistan" ; if "`iso'"=="VUT" local country="Vanuatu" ; if "`iso'"=="VEN" local country="Venezuela" ; if "`iso'"=="VNM" local country="Vietnam" ; if "`iso'"=="PSE" local country="Palestinian Territories" ; if "`iso'"=="YEM" local country="Yemen" ; if "`iso'"=="ZMB" local country="Zambia" ; if "`iso'"=="ZWE" local country="Zimbabwe" ; if "`iso'"=="NRU" local country="Nauru" ; if "`iso'"=="TWN" local country="Taiwan" ;
#delimit cr

*test if variable is not missing for corresponding i and j
qui sum `Var' if `id'=="`iso'" & `j'==`time'

*if not missing: 
if `r(N)'!=0 {
*store value of the variable for the corresponding i and j 
qui levelsof `Var' if `id'=="`iso'" & `j'==`time', local(value)
*set value format
local value : dis %3.2f `value'
*write html content 
file write `page'  `"	 ["`country'",`value'," "],   "' _n
	}

*when arriving to the end of the loop, write this line (nb. allows to be sure to have no coma at the end of the last line) 
if "`iso'"=="¤LIST_END¤" file write `page'  `"	["ABSURDISTAN",0,' ']  "' _n	
}

file write `page' ///	
`" 		  "' _n  ///
`"    ]); "' _n  ///
`"         "' _n  ///
`"   var view = new google.visualization.DataView(data); "' _n  ///
`"   view.setColumns([0, 1]);  "' _n  ///
`"         var chart = new google.visualization.GeoChart(document.getElementById('map_div')); "' _n  ///
`" 		   var options = {colorAxis: {colors:['`color1'','`color2'']}, title:"",`legend' region: '`ZONE''}; "' _n  /// 
`" <!-- suppress legend: 'none' if you want the legend to be displayed -->    "' _n  /// 
`"   	   google.visualization.events.addListener(chart, 'select', function () { "' _n  ///
`"         var selection = chart.getSelection(); "' _n  ///
`"         var row = selection[0].row; "' _n  ///
`"         var url = data.getValue(row, 2); "' _n  ///
`"         window.open(url, "_self"); "' _n  ///
`"    }); "' _n  ///
`"     "' _n  ///
`"  chart.draw(view, options);"' _n  ///
`" };"' _n  ///
`" </script>"' _n  ///
`" <p style="font-family: Calibri; vertical-align: middle; text-align:left; color:#`color2'"><big>"' _n  ///
`" Google geochart - <font color="#151515">`title'</big><br>"' _n  ///
`" <font color="black">Variable displayed:</big><small><font color="#151515"><i> `Var'</i></small></br>"' _n ///
`" <font color="black"> Variable label: <font color="#151515"><i><small>`label' </i><font color="black"></small> "' _n ///
`" </br>Region: <font color="black"><i><small>`ZONEstr'</i></small></FONT></br>"' _n  ///
`" <a href="#" onclick="window.print();return false;"><small>print as pdf</a> "' _n ///
`" <p><div id="map_div" style="width: `width'px; height:`height'px; align:center; valign=center;"></div></p>"' _n ///
`" "' _n  

file close `page'
capture erase "`filename'"
capture !rename "page"  "`filename'"			// windows
capture !mv  "page" 	 "`filename'"		   // unix
capture erase "page"

noisily di "----------------------"
noisily di as txt "Done ! Open output web page: " `"{browse  "`c(pwd)'/`filename'"}"'
cd "`dir'"

}
end

