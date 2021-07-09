{smcl}
{* *! version 1.0 30sep2015}{...}
{viewerjumpto "Syntax" "xteurostat##syntax"}{...}
{viewerjumpto "Description" "xteurostat##description"}{...}
{viewerjumpto "Options" "xteurostat##options"}{...}
{viewerjumpto "Citation" "xteurostat##citation"}{...}
{viewerjumpto "Install" "xteurostat##install"}{...}
{viewerjumpto "Remarks" "xteurostat##remarks"}{...}
{viewerjumpto "Examples" "xteurostat##examples"}{...}
{viewerjumpto "Authors" "xteurostat##author"}{...}
{title:Import Panel data from Eurostat - (c) Duarte Gon{c c,}alves 2016}        v1.2  2016/05/20



{phang}
{bf:xteurostat} {hline 2} Imports data from Eurostat in panel data structure.


{phang}{bf: WARNING}: This version of {cmd:xteurostat} may be out of date.  To ensure that you have the latest version, type or click on {stata "ssc install xteurostat, replace":{bf:ssc install xteurostat, replace}}, and then restart STATA.{p_end}

Citation: Gon{c c,}alves, D. 2016. XTEUROSTAT: Stata module to import data from Eurostat in panel data structure, Statistical Software Components s458089, Boston College Department of Economics.
URL: http://EconPapers.repec.org/RePEc:boc:bocode:s458089.





{marker syntax}{...}

{title:Syntax}

{p 8 17 2}
{cmdab:xteurostat} {it:tablecode} [{it:filters}] [, {opt g:eo(geovarname)} {opt t:ime(timevarname)} {opt iso:countrynames} {opt s:tart(starttime)} {opt e:nd(endtime)} {opt vname(newvarname)} {opt date(frequency)} {opt datemask(mask)} {opt clear} {opt path7zg(path)}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt filters:}}retain only observations with dimensions equal to such strings.{p_end}
{synoptline}
{syntab:Other}
{synopt:{opt t:ime}}existing/to be created time variable name.{p_end}
{synopt:{opt g:eo}}existing/to be created geo variable name.{p_end}
{synopt:{opt iso:countrynames}}replace Eurostat's country codes with ISO 3166-1 Alpha-3 country codes
and generates a variable with ISO 3166-1 Numeric country codes, already labelled.{p_end}
{synopt:{opt s:tart}}specify the start time for the extraction, e.g. start(2000); the default is extract from the first year available.{p_end}
{synopt:{opt e:nd}}specify the end time for the extraction, e.g. end(2010); the default is extract until the last year available.{p_end}
{synopt:{opt v:name}}specify the name for the variable to be generated from the extraction, {it:if only one is to be extracted}.{p_end}
{synopt:{opt d:ate}}specify the date format, e.g. y for yearly data, q for quarterly, m for monthly, d for daily  and c for clock - see {it:{help format:date format}}.{p_end}
{synopt:{opt clear}}clears existing data; the default is retain existing data and just merge the new variables.{p_end}
{synopt:{opt path7zg}}determines an ad-hoc path to 7zG.exe that not C:\Program Files\7-Zip\7zG.exe (the default one){p_end}
{synoptline}
{syntab:Advanced}
{synopt:{opt datem:ask}}specify the date mask of the time variable.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is not allowed. {cmd:if} is not allowed.{p_end}
{p 4 4 2}

{phang}{space 2}{p_end}
{phang}{space 2}{bf: Note}: {stata "findit xteurostat":xteurostat} is especially useful for very large extractions from Eurostat{p_end}
{phang}{space 9}{stata "findit getdata":getdata} is better for more flexible extractions from several sources{p_end}


{marker description}{...}

{title:Description}

{pstd}
{cmd:xteurostat} imports data from Eurostat producing ready-to-use panel data structure. {opt tablecode} corresponds to Eurostat target dataset code, e.g. gov_10a_main.
 It requires having 7zip installed - see {it:{help xteurostat##install:install}} below.

{phang}
{cmd:tablecode} should include one Eurostat data file to be downloaded, unzipped and processed.

{pstd}
You should just specify the code, not the .tsv or .gz extension.
The table codes can be found in the navigation tree. The codes are indicated in brackets after the titles.
The navigation tree is located here {browse "http://ec.europa.eu/eurostat/data/database"}.

{phang}
See also {browse "http://ec.europa.eu/eurostat/data/bulkdownload"} and {browse "http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing"}.



{marker options}{...}

{title:Options}

{dlgtab:Main}

{phang}
{opt filters} retain only observations with dimensions equal to such strings

{phang}
{opt       e.g.} if {it:MIO_NAC S13} is specified, STATA will loop over variables values and retain only those observations where the unit of measurement is millions of national currency (MIO_NAC)
and refer to General Government (S13). Only one filter per dimension is permitted and each filter should appear only in one of the dimensions, otherwise the code will yield an error so as to avoid dropping data unintentionally.

{phang}
{opt       Important:} If there are dimensions with "-", the dashes will be removed, given that variables' names in STATA cannot have dashes.



{dlgtab:Other}

{phang}
{opt t:ime} name of the time variable. It should match the time variable name - e.g. "year", if it already exists - otherwise, it will be the name of the time variable generated.

{phang}
{opt g:eo} name of the geo variable. It should match the geo variable name - e.g. "country", if it already exists - otherwise, it will be the name of the geo variable generated.

{phang}
{opt iso:countrynames} replace Eurostat's country codes with ISO 3166-1 Alpha-3 country codes
and generates a variable with ISO 3166-1 Numeric country codes, already labelled, named {it:geovarname}_num.
Although some options were added to contemplate some regional groupings in the numeric 900 section (e.g. EA19, EU28), some other of Eurostat's add-hoc regional groupings may not have an attributed numeric code.

{phang}
{opt s:tart} specify the start year for the extraction, e.g. start(2000); the default is extract all the available data.

{phang}
{opt e:nd} specify the end year for the extraction, e.g. end(2010); the default is extract all the available data.

{phang}
{opt v:name} specify the name for the variable to be generated from the extraction, {it:if only one is to be extracted}; the default is a combination of the parameters.

{phang}
{opt d:ate} specify the date format, e.g. y for yearly data, q for quarterly, m for monthly and d for daily  - see {it:{help format:date format}}.

{phang}
{opt path7zg} determines an ad-hoc path to 7zG.exe that not C:\Program Files\7-Zip\7zG.exe (the default one).

{phang}
{opt clear} clears existing data; the default is retain existing data and just merge the new variables


{dlgtab:Advanced}

{phang}
{opt datem:ask} specify the date mask of the time variable - see {it:{help datetime_translation##mask:datetime translation, mask}}. Requires {opt d:ate} option and a preexisting daily-structured time variable if {opt clear} option is not selected. 

{phang}
{opt Common situations}:  d(y) datem(Y) for yearly-frequenced data; or d(q) datem(YQ) for quarterly-frequenced data; or d(m) datem(YM) for monthly-frequenced data; or d(d) datem(YMD) for daily-frequenced data




{marker citation}{...}
{title:Citation}

{phang}
{cmd:xteurostat} is not an official STATA command. It is a free contribution to the research community to improve data accessibility.  Whenever used, please cite it as follows:

{phang}
       Gon{c c,}alves, D. 2016. XTEUROSTAT: Stata module to import data from Eurostat in panel data structure, Statistical Software Components s458089, Boston College Department of Economics.
       URL: http://EconPapers.repec.org/RePEc:boc:bocode:s458089.



{marker install}{...}
{title:Install}
{phang} {space 5} {p_end}
{pstd}
If you use Windows you also need to install 7-zip into the program files directory (C:\Program Files\7-Zip\7zG.exe). If you install it elsewhere, just specify the {opt path7zg}({it:path_to_7zg}) option.
OSX users don't need to do anything. You can download 7-zip from {browse "http://www.7-zip.org/download.html"}.



{marker remarks}{...}
{title:Remarks}

{pstd}
The Eurostat repository at {browse "http://ec.europa.eu/eurostat/data/database"} 
contains more a large number of EU economic time series.  Each time series is
stored in a separate file that also contains a string-date variable and header
with information about the series. 

{pstd}
{cmd:xteurostat} imports a panel data structured data into STATA directly from Eurostat. It can only refer to a single table at a time, but can download the whole data, one variable only, or several variables.

{pstd}
Flags are erased from the data.

{pstd}
Execution can sometimes be time-consuming mainly due to the necessary reshaping of the data: the more variables are to be imported, the greater the running time.
For a large dataset (gov_10a_exp), to download the table, process it and extract only one series from it takes about 1 minute.
To extract from it only data for General Government sector in millions of national currency (approx. 1500 variables) it takes less than 20 min.
To import the whole of GDP and main components (nama_10_gdp) - 570 variables and 1,360 obs, the runtime is under 3 minutes.

{pstd}
The Eurostat's table codes are case sensitive.



{marker examples}{...}
{title:Examples}
{phang} {space 5} {p_end}
{pstd}A simple extraction{p_end}
{phang2}{cmd: xteurostat une_ltu_a, clear}{p_end}
{phang} {space 5} {p_end}
{pstd}Fully working example{p_end}
{phang2}{cmd: xteurostat gov_10a_main S13 TE MIO_NAC, isocountrynames g(country) t(year) v(govsp) date(y) clear}{p_end}
{phang2}{cmd: xteurostat nama_10_gdp B1GQ CP_MNAC, isocountrynames g(country) t(year) v(gdp) date(y)}{p_end}
{phang2}{cmd: drop if substr(country,1,2) == "EA" | substr(country,1,2) == "EU"}{p_end}
{phang2}{cmd: xtset country_num year}{p_end}
{phang2}{cmd: gen govsp_sh = govsp/gdp*100}{p_end}
{phang2}{cmd: xtline govsp_sh if year > 2000}{p_end}
{phang} {space 5} {p_end}
{pstd}Using {opt datem:ask} option{p_end}
{phang}{space 5}{opt datem:ask} option specifies a particular pattern in the date string variable. As this can take many forms, the program tries to be as broad as possible in recognizing them,{p_end}
{phang}{space 5} but it may not cover all the cases - especially if there is any innovation from the data providers. It converts the date automatically to yyyymmdd format{p_end}
{phang}{space 5}- if neither {opt d:ate(c)} nor {opt d:ate(C)} are chosen as an option - and provides the date in the frequency determined by {opt d:ate} option as well as daily frequency.{p_end}
{phang}{space 5}It requires a daily-structured time variable to merge new data with the already existing one. Exemplifying:{p_end}
{phang} {space 5} {p_end}
{phang2}{cmd: xteurostat nama_10_gdp B1GQ CP_MNAC, isocountrynames g(country) t(date) v(gdp) date(y) datem(Y) clear}{p_end}
{phang2}{cmd: xteurostat irt_st_m MAT_M01, isocountrynames g(country) t(date) v(intrates) d(m) datem(YM)}{p_end}
{phang2}{cmd: xteurostat ei_bsin_q BSICUPC SA, isocountrynames g(country) t(date) v(caput) date(q) datem(YQ)}{p_end}
{phang} {space 5} {p_end}
{phang}{space 5}Daily data can take a while to process due to reshaping and the number of observations. Run this example only with fast computers or if willing to wait{p_end}
{phang2}{cmd: xteurostat ert_h_eur_d, geo(curr) t(date) d(d) datem(YMD) clear}{p_end}
{phang} {space 5} {p_end}



{pstd}
Please, after a few weeks of using the program, send an email with your remarks in order to improve the code.


{marker author}{...}

{title:Authors}


{pstd}
Duarte Gon{c c,}alves {space 8} duarte.goncalves.dg@outlook.com
{p_end}
{pstd}
{space 8}
{p_end}
{pstd}
{space 8}
{p_end}
{pstd}
{space 8}
{p_end}
{pstd}
Draws on code by Sem Vandekerckhove (sem.vandekerckhove@kuleuven.be).
{p_end}
   

