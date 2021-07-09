{smcl}
{* *! version 1.22 24mar2016}{...}
{viewerjumpto "Syntax" "getdata##syntax"}{...}
{viewerjumpto "Description" "getdata##description"}{...}
{viewerjumpto "Options" "getdata##options"}{...}
{viewerjumpto "Citation" "getdata##citation"}{...}
{viewerjumpto "Install" "getdata##install"}{...}
{viewerjumpto "Remarks" "getdata##remarks"}{...}
{viewerjumpto "Examples" "getdata##examples"}{...}
{viewerjumpto "Providers" "getdata##providers"}{...}
{viewerjumpto "Configuring a Network Proxy" "getdata##proxy"}{...}
{viewerjumpto "Author" "getdata##author"}{...}
{title:Import SMDX Data - (c) Duarte Gon{c c,}alves 2016}        v1.22  2016/03/24



{phang}
{bf:getdata} {hline 2} Imports data from several SDMX Data providers (OECD, EUROSTAT, ECB, IMF, ILO, ...) in raw, cross-sectional, time series or panel data structure using SDMX rest codes.



{phang}{bf: WARNING}: This version of {cmd:getdata} may be out of date.  To ensure that you have the latest version, type or click on {stata "ssc install getdata, replace":{bf:ssc install getdata, replace}}, and then restart STATA.{p_end}

Citation: Gon{c c,}alves, D. 2016. GETDATA: Stata module to import SDMX data from several providers, Statistical Software Components S458093, Boston College Department of Economics.
URL: http://EconPapers.repec.org/RePEc:boc:bocode:s458093.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:getdata} {it:structure} {it:provider}, {opt r:est(restcode)} [{opt g:eo(s1 [s2])} {opt t:ime(s1 [s2])} {opt iso:countrycodes(codetype)} {opt s:tart(starttime)} {opt e:nd(endtime)} {opt m:erge(1:1|1:m|m:1|m:m)} {opt replace} {opt update} 
{opt f:requency(frequency)} {opt datem:ask(mask)} {opt v:arname(varname)} {opt set} {opt clear}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt structure}}{opt raw}, {opt cs} (cross-sectional), {opt ts} (time series) or {opt xt} (panel).{p_end}
{synopt:{opt provider}}SDMX data provider.{p_end}
{synopt:{opt r:est}}rest code, e.g. {it:EO/USA.YRGT.A} (from OECD) or {it:irt_h_euryld_q/Q.YIELD.Y1.} (from EUROSTAT); check {cmd: {stata "getdatacodes":getdatacodes}}.{p_end}

{synoptline}

{syntab:CS, TS and XT}
{synopt:{opt g:eo}}{it:s1}: geo variable name as is in the "raw" dataset; {it:s2}: existing/to be created geo variable name.{p_end}
{synopt:{opt t:ime}}{it:s1}: time variable name as is in the "raw" dataset - default is {it:DATE}; {it:s2}: existing/to be created time variable name.{p_end}
{synopt:{opt iso:countrycodes}}replace country codes with ISO 3166-1 country codes: {it:alpha3} for ISO 3166-1 Alpha-3; {it:alpha2} for ISO 3166-1 Alpha-2;
{it:num} for ISO 3166-1 Numeric country codes (labelled);
more than one is permitted, e.g. {opt iso(alpha3 num)}.{p_end}
{synopt:{opt m:erge}}specify the type of {opt merge} with existing data, {it:1:1}, {it:1:m}, {it:m:1} or {it:m:m}; the default is {it:1:1} - see {it:{help merge}}.{p_end}
{synopt:{opt replace}}specify {opt replace} in {opt merge} options - see {it:{help merge}}.{p_end}
{synopt:{opt update}}specify {opt update} in {opt merge} options (no need to use both {opt replace} and {opt update}) - see {it:{help merge}}.{p_end}
{synopt:{opt s:tart}}specify the start time for the extraction, e.g. start(2000); the default is extract from the first year available.{p_end}
{synopt:{opt e:nd}}specify the end time for the extraction, e.g. end(2010); the default is extract until the last year available.{p_end}
{synopt:{opt v:arname}}specify the name for the variable to be generated from the extraction, {it:if only one is to be extracted}.{p_end}
{synopt:{opt f:requency}}specify the date format, e.g. {it:y} for yearly data, {it:q} for quarterly, {it:m} for monthly, {it:d} for daily and {it:c} for clock - see {it:{help format:date format}}.{p_end}
{synopt:{opt set}}sets the data as time series or panel data, depending on the structure chosen.{p_end}
{synopt:{opt clear}}clears existing data; the default is retain existing data and just merge the new variables.{p_end}

{synoptline}

{syntab:Advanced}
{synopt:{opt datem:ask}}specify the date mask of the time variable; must be used with {opt frequency}.{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is not allowed. {cmd:if} is not allowed.{p_end}
{p 4 4 2}

{phang}{space 2}{p_end}
{phang}{space 2}{bf: Note}: {stata "findit getdata":getdata} is better for more flexible extractions from several sources{p_end}
{phang}{space 9}{stata "findit xteurostat":xteurostat} is especially useful for very large extractions from Eurostat{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:getdata} imports data from several SDMX Data providers (OECD, EUROSTAT, ECB, IMF, ILO, ...) in raw, cross-sectional, time series or panel data structure using SDMX rest codes.
It is able to produce ready-to-use cross-sectional, time series panel data structure. {opt rest} corresponds to the rest query code, {it:EO/USA.YRGT.A} (from OECD) or {it:irt_h_euryld_q/Q.YIELD.Y1.} (from EUROSTAT).

{phang}
This package installs automatically Bank of Italy's SDMX Connector for STATA.

{phang}
{cmd:rest} codes can be obtained by calling {it:{stata "getdatacodes":getdatacodes}}, selecting a Provider, a Flow ID and the Dimensions - it appears in the white box above.
To copy it select everything in the white box on the top and click Ctrl+C.

{phang}
Some providers' websites, e.g. {browse "http://stats.oecd.org"}, also enable users to get the rest code from the URL.



{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt structure} {bf:raw}, {bf:cs} (cross-sectional), {bf:ts} (time series) or {bf:xt} (panel).

{phang}
{opt provider} SDMX data provider, e.g. OECD, EUROSTAT, ECB, IMF, ILO, or other.

{phang}
{opt r:est} rest code, e.g. {it:EO/USA.YRGT.A} (from OECD) or {it:irt_h_euryld_q/Q.YIELD.Y1.} (from EUROSTAT). Check {it:{stata "getdatacodes":getdatacodes}} as mentioned above.

{phang}
{opt       Important:} If there are dimensions with "-" or other characters aside alphanumeric ones and the underscore ({it:_}), these characters will be removed, given that variables' names in STATA cannot contain special characters.
The variables' names are also shortened to comply with STATA's limit on varname characters (32).



{dlgtab:CS, TS and XT}

{phang}
{opt g:eo} {it:s1} geo variable name as is in the "raw" dataset - e.g. {it:LOCATION} (common in OECD tables) or {it:GEO} (the defaul in EUROSTAT tables); {it:s2}: existing/to be created geo variable name.
If the existing data already contains a geo variable name, it should be specified ({it:s2}) - e.g. "country", if it already exists. Otherwise, {it:s2} will be the name of the geo variable generated.
The default assumes the {it:s2}={it:s1}; there is no default for {it:s1} in itself.

{phang}
{opt t:ime} {it:s1} time variable name as is in the "raw" dataset - e.g. {it:DATE} (the default in raw tables); {it:s2}: existing/to be created time variable name.
If the existing data already contains a time variable name, it should be specified ({it:s2}) - e.g. "year", if it already exists.
Otherwise, {it:s2} will be the name of the time variable generated. The default assumes {it:s2}={it:s1} and {it:s1}="{it:DATE}".

{phang}
{opt iso:countrycodes} replace country codes with ISO 3166-1 country codes: {it:alpha3} for ISO 3166-1 Alpha-3; {it:alpha2} for ISO 3166-1 Alpha-2; {it:num} for ISO 3166-1 Numeric country codes (labelled), named {it:geovarname_s2}_num.
Although some options were added to contemplate some regional groupings in the numeric sections greater than 999 (e.g. EA19, EU28), some other of the providers' add-hoc regional groupings will not have an attributed numeric code
and thus frustrate the use of the panel setting. The first option in {opt iso:countrycodes} is considered the default; any other option creates an additional variable. E.g. {opt iso:countrycodes(alpha3 num)} assumes that the {it:geo} variable
follows ISO 3166-1 Alpha-3 and creates an additional {it:geo} variable, {it:geo_num}, following the numeric ISO coding.

{phang}
{opt m:erge} specify the type of {opt merge} with existing data, {it:1:1}, {it:1:m}, {it:m:1} or {it:m:m}; the default is {it:1:1} - see {it:{help merge}}.

{phang}
{opt replace} specify {opt replace} in {opt merge} options - see {it:{help merge}}.

{phang}
{opt update} specify {opt update} in {opt merge} options (no need to use both {opt replace} and {opt merge}) - see {it:{help merge}}.

{phang}
{opt s:tart} specify the start year for the extraction, e.g. start(2000); the default is extract all the available data.

{phang}
{opt e:nd} specify the end year for the extraction, e.g. end(2010); the default is extract all the available data.

{phang}
{opt v:arname} specify the name for the variable to be generated from the extraction, {it:if only one is to be extracted}; the default is a combination of the parameters.

{phang}
{opt f:requency} specify the date format, e.g. {it:y} for yearly data, {it:q} for quarterly, {it:m} for monthly, {it:d} for daily and {it:c} for clock - see {it:{help format:date format}}.

{phang}
{opt set} sets the data as time series or panel data, depending on the structure chosen.

{phang}
{opt clear} clears existing data; the default is retain existing data and just merge the new variables



{dlgtab:Advanced}

{phang}
{opt datem:ask} specify the date mask of the time variable - see {it:{help datetime_translation##mask:datetime translation, mask}}.
Requires {opt d:ate} option and a preexisting daily-structured time variable if {opt clear} option is not selected.
Must be used with {opt frequency}

{phang}
{opt Common situations}:  d(y) datem(Y) for yearly-frequenced data; or d(q) datem(YQ) for quarterly-frequenced data; or d(m) datem(YM) for monthly-frequenced data; or d(d) datem(YMD) for daily-frequenced data.


{marker citation}{...}
{title:Citation}

{phang}
{cmd:getdata} is not an official STATA command. It is a free contribution to the research community to improve data accessibility.  Whenever used, please cite it as follows:

{phang}
       Gon{c c,}alves, D. 2016. GETDATA: Stata module to import SDMX data from several providers, Statistical Software Components S458093, Boston College Department of Economics.
       URL: http://EconPapers.repec.org/RePEc:boc:bocode:s458093.


{marker install}{...}
{title:Install}
{phang} {space 5} {p_end}
{pstd}
Requires STATA version 13 or above.



{marker remarks}{...}
{title:Remarks}

{pstd}
Imports data from several SDMX Data providers (OECD, EUROSTAT, ECB, IMF, ILO, ...) in raw, cross-sectional, time series or panel data structure using SDMX rest codes.

{pstd}
{cmd:getdata} imports cross-sectional, time series or panel data structured data into STATA directly from data providers. It can only refer to a single table at a time, but can download the whole data, one variable only, or several variables.

{pstd}
Flags are erased from the data.

{pstd}
Execution can sometimes be time-consuming mainly due to the necessary reshaping of the data: the more variables are to be imported, the greater the running time. For a big dataset (gov_10a_exp), to download the table, process it
and extract only one series from it takes about 1 second. To extract from it only data for General Government sector in millions of national currency (over 1500 variables) it takes less than 5 min.

{pstd}
The rest codes are case sensitive.
{p_end}

{pstd}
EUROSTAT has currently a cap on the quantity of data one can extract directly at once. Try {stata "findit xteurostat":xteurostat} as an alternative for very large extractions.
{p_end}

{pstd}
This program uses the SDMX Connector for STATA, licensed to Banca d'Italia (Bank of Italy) under a European Union Public Licence
(world-wide, royalty-free, non-exclusive, sub-licensable licence). 
See {browse "https://github.com/amattioc/SDMX/wiki/SDMX-Connector-for-STATA"} and
{browse "https://joinup.ec.europa.eu/sites/default/files/eupl1.1.-licence-en_0.pdf"}.

{pstd}
I dearly thank Attilio Mattiocco ({it:Attilio.Mattiocco@bancaditalia.it}) for all the help regarding the SDMX Connector for STATA
and Bo Werth ({it:Bo.WERTH@oecd.org}) for additional clarifications.

{pstd}
For a statistics provider to be able to be included, please contact Attilio Mattiocco ({it:Attilio.Mattiocco@bancaditalia.it}). See also {help getdata##providers:Adding a Provider}.



{marker examples}{...}
{title:Examples}
{phang} {space 5} {p_end}
{pstd}Calling the getdatacodes{p_end}
{phang2}{cmd: {stata "getdatacodes":getdatacodes}}{p_end}
{phang} {space 5} {p_end}
{pstd}Simple extractions{p_end}
{phang2}{cmd: getdata raw IMF, r(DM/111.PPPGDP.WEO.H.A) clear}{p_end}
{phang2}{cmd: getdata ts IMF, r(DM/111.PPPGDP.WEO.H.A) g(REF_AREA) t(DATE) clear}{p_end}
{phang2}{cmd: getdata ts IMF, r(DM/111.PPPGDP.WEO.H.A) g(REF_AREA country) t(DATE year) f(y) v(us_gdp_ppp) set clear}{p_end}
{phang2}{cmd: getdata cs EUROSTAT, r(inn_cis5_gen/.MAR_LREG.TOT_INN.TOTAL.NR.INNOACT.) g(GEO country) v(nr_innov_firms_2006) clear}{p_end}
{phang2}{cmd: getdata xt OECD, r(EO/USA.YRGT.A) geo(LOCATION country) iso(num) time(DATE year) f(y) set clear}{p_end}
{phang} {space 5} {p_end}
{pstd}Different ISO Country codes{p_end}
{phang2}{cmd: getdata xt EUROSTAT, r(gov_10a_exp/A.MIO_NAC.S13.TOTAL.TE.) geo(GEO country) iso(alpha3) time(DATE year) f(y) v(govsp) clear}{p_end}
{phang2}{cmd: getdata xt OECD, r(SNA_TABLE11/.TLYCG.T.GS13.C) geo(LOCATION country) iso(alpha2) time(DATE year) f(y) v(govsp) clear}{p_end}
{phang2}{cmd: getdata xt OECD, r(SNA_TABLE11/.TLYCG.T.GS13.C) geo(LOCATION country) iso(num) time(DATE year) f(y) v(govsp) set clear}{p_end}
{phang2}{cmd: getdata xt OECD, r(SNA_TABLE11/.TLYCG.T.GS13.C) geo(LOCATION country) iso(num alpha3) time(DATE year) f(y) v(govsp) set clear}{p_end}
{phang} {space 5} {p_end}
{pstd}Fully working example{p_end}
{phang2}{cmd: getdata xt OECD, r(EO/AUT+BEL+DEU+ESP+EST+FIN+FRA+IRL+ITA+LUX+LVA+NLD+PRT+SVK+SVN.GDP.A) geo(LOCATION country) iso(num) time(DATE year) f(y) v(gdp) clear}{p_end}
{phang2}{cmd: replace gdp = gdp/(10^6)}{p_end}
{phang2}{cmd: getdata xt OECD, r(SNA_TABLE11/AUT+BEL+DEU+ESP+EST+FIN+FRA+IRL+ITA+LUX+LVA+NLD+PRT+SVK+SVN.TLYCG.090.GS13.C) geo(LOCATION country) iso(num) time(DATE year) f(y) v(govsp_educ)}{p_end}
{phang2}{cmd: getdata xt OECD, r(SNA_TABLE11/AUT+BEL+DEU+ESP+EST+FIN+FRA+IRL+ITA+LUX+LVA+NLD+PRT+SVK+SVN.TLYCG.T.GS13.C) geo(LOCATION country) iso(num) time(DATE year) f(y) v(govsp) set}{p_end}
{phang2}{cmd: gen govsp_on_gdp = govsp/gdp}{p_end}
{phang2}{cmd: gen govsp_educ_on_gdp = govsp_educ/gdp}{p_end}
{phang2}{cmd: label var govsp_on_gdp "Total Gvt Spending"}{p_end}
{phang2}{cmd: label var govsp_educ_on_gdp "Gvt Spending on Education"}{p_end}
{phang2}{cmd: xtline govsp_on_gdp govsp_educ_on_gdp, byopts(title("Government Spending (%GDP)") note("OECD, SNA Table 11")) name("govsp_on_gdp", replace) xtitle("") ytitle("")}{p_end}
{phang} {space 5} {p_end}
{pstd}Update data using different sources and the same variables{p_end}
{phang2}{cmd: getdata xt EUROSTAT, r(gov_10a_exp/A.MIO_NAC.S13.TOTAL.TE.) g(GEO country) t(DATE year) set f(y) iso(num) v(govsp) clear}{p_end}
{phang2}{cmd: getdata xt OECD, r(SNA_TABLE11/.TLYCG.T.GS13.C) g(LOCATION country) t(DATE year) set f(y) iso(num) v(govsp) update}{p_end}
{phang} {space 5} {p_end}
{pstd}Merge regional and national data{p_end}
{phang2}{cmd: getdata xt OECD, r(REGION_ECONOM/2.ES11+ES12+ES13+ES21+ES22+ES23+ES24+ES30+ES41+ES42+ES43+ES51+ES52+ES53+ES61+ES62+ES63+ES64+ES70+FR10+FR21+FR22+FR23+FR24+FR25+FR26+FR30+FR41+FR42+FR43+FR51+FR52+FR53+FR61+FR62+FR63+FR71+FR72+FR81+FR82+FR83.SNA_2008.GDP.CURR_PR.ALL.) g(REG_ID) t(TIME year) f(y) clear v(y_reg)}{p_end}
{phang2}{cmd: getdata xt OECD, r(REGION_ECONOM/2.ES11+ES12+ES13+ES21+ES22+ES23+ES24+ES30+ES41+ES42+ES43+ES51+ES52+ES53+ES61+ES62+ES63+ES64+ES70+FR10+FR21+FR22+FR23+FR24+FR25+FR26+FR30+FR41+FR42+FR43+FR51+FR52+FR53+FR61+FR62+FR63+FR71+FR72+FR81+FR82+FR83.SNA_2008.INCOME_DISP.CURR_PR.ALL.) g(REG_ID) t(TIME year) f(y) v(yd_reg)}{p_end}
{phang2}{cmd: gen country = substr(REG_ID,1,2)}{p_end}
{phang2}{cmd: getdata xt OECD, r(EO/FRA+ESP.GDP.A) g(LOCATION country) t(DATE year) f(y) merge(m:1) iso(alpha2 num) v(y)}{p_end}
{phang} {space 5} {p_end}
{pstd}Merge data of different frequencies{p_end}
{phang2}{cmd: getdata ts OECD, r(EO/USA.GDP.Q) g(LOCATION country) t(DATE year) f(q) datem(YQ) v(gdp) clear}{p_end}
{phang2}{cmd: replace year = yofd(year)}{p_end}
{phang2}{cmd: format year %ty}{p_end}
{phang2}{cmd: getdata ts OECD, r(EO/USA.YPGT.A) g(LOCATION country) t(DATE year) f(y) v(govsp) m(m:1)}{p_end}
{phang} {space 5} {p_end}
{phang} {space 5} {p_end}
{pstd}Using {opt datem:ask} option{p_end}
{phang}{space 2}{opt datem:ask} option specifies a particular pattern in the date string variable. As this can take many forms, the program tries to be as broad as possible in recognizing them,{p_end}
{phang}{space 2} but it may not cover all the cases - especially if there is any innovation from the data providers. It converts the date automatically to yyyymmdd format{p_end}
{phang}{space 2}- if neither {opt f:requency(c)} nor {opt f:requency(C)} are chosen as an option - and provides the date in the frequency determined by {opt f:requency} option as well as daily frequency.{p_end}
{phang}{space 2}It requires a daily-structured time variable to merge new data with the already existing one. E.g.{p_end}
{phang2}{cmd: getdata ts EUROSTAT, r(irt_h_euryld_d/D.YIELD.Y1.EA) geo(GEO) time(DATE year) f(d) datem(YMD) clear}{p_end}
{phang2}{cmd: getdata ts OECD, r(EO/USA.GDP.Q) geo(LOCATION) time(DATE year) f(q) datem(YQ) clear}{p_end}
{phang2}{cmd: getdata ts ECB, r(EON/D.EONIA_TO.RATE) g(GEO) t(DATE day) v(eonia) f(d) datem(YMD) set clear}{p_end}


{pstd}
Please, after a few weeks of using the program, send an email with your remarks in order to improve the code.



{marker providers}{...}
{title:Providers}

{pstd}
{bf:Adding a Provider}

Is is possible to add custom data providers using the configuration.properties file {it: given that the providers follow SDMX 2.1 standards}.
{phang2} 1. Do {cmd: cd "`c(sysdir_plus)'jar"}  {p_end}
{phang2} 2. If you have downloaded the configuration.properties file already, go to step 3. Otherwise, do {it:{stata "net get getdata.pkg":net get getdata.pkg}} {p_end}
{phang2} 3. Go to the ado\plus\jar folder (do {cmd: di "`c(sysdir_plus)'jar"} to see which one it is) {p_end}
{phang2} 4. Open the configuration.properties file on Notepad (or a similar text editor) and under "Providers settings" find "Add New Providers" and follow the instructions{p_end}


{pstd}
{bf:International Sources}

{break}
Eurostat {browse "http://ec.europa.eu/eurostat/web/sdmx-web-services/rest-sdmx-2.1"}
European Central Bank (ECB) {browse "https://sdw-wsrest.ecb.europa.eu/"}
International Monetary Fund (IMF) {browse "http://sdmxws.imf.org/"}
Organisation for Economic Co-operation and Development (OECD) {browse "http://stats.oecd.org"} (export to SDMX tool)
United Nations (UN) {browse "http://data.un.org/Host.aspx?Content=API"}
UN Food & Agriculture Organization (FAO) {browse "http://api.data.fao.org/1.0/esb-rest/sdmx/introduction.html"}
UN International Labour Organization (ILO) {browse "http://www.ilo.org/ilostat/faces/home/statisticaldata/technical_page?_adf.ctrl-state=25zdozvi8_9&_afrLoop=1131342564621899"}
World Bank (WB) {browse "http://databank.worldbank.org/data/"} (export to SDMX tool)


{pstd}
{bf:National Sources}

{break}
AUS Australian Bureau of Statistics (ABS) {browse "http://stat.abs.gov.au/"} (export to SDMX tool)
BEL National Bank of Belgium {browse "http://stat.nbb.be/"} (export to SDMX tool)
CAN Statistics Canada {browse "http://www.statcan.gc.ca/"}
GER Deutsche Bundesbank {browse "https://www.bundesbank.de/Navigation/EN/Statistics/Time_series_databases/time_series_databases.html"}
FRA Institut National de la Statistique et des Etudes Economiques (INSEE) {browse "http://www.bdm.insee.fr/bdm2/statique?page=sdmx"} (export to SDMX tool)
MEX Sistema Nacional de Información Estadística y Geográfica de México (SNIEG) {browse "http://www.snieg.mx/opendata/"}
ESP Instituto Nacional de Estadística {browse "http://www.ine.es/fmi/nsdp.htm"} (export to SDMX tool)
GBR Office of National Statistics (ONS) {browse "https://www.ons.gov.uk/ons/apiservice/web/apiservice/how-to-guides#sdmx"}
USA US Federal Reserve {browse "http://www.federalreserve.gov/DataDownload/help/default.htm"} (export to SDMX tool)

{pstd}



{marker proxy}{...}
{title:Configuring a Network Proxy}

{phang} If there is any need to configure a network proxy in order to the program to work, {it: after installing getdata} follow the steps below{p_end}
{phang2} 1. Do {cmd: cd "`c(sysdir_plus)'jar"}  {p_end}
{phang2} 2. If you have downloaded the configuration.properties file already, go to step 3. Otherwise, do {it:{stata "net get getdata.pkg":net get getdata.pkg}}  {p_end}
{phang2} 3. Go to the ado\plus\jar folder (do {cmd: di "`c(sysdir_plus)'jar"} to see which one it is) {p_end}
{phang2} 4. Open the configuration.properties file on Notepad (or a similar text editor) and under "Network Configuration" add the following:{p_end}
{phang2} {space 5} http.proxy.default = URL_FOR_INTERNET_PROXY:NUMBER_OF_PROXY_PORT{p_end}
{phang2} {space 3} For example,{p_end}
{phang2} {space 5} http.proxy.default = proxy.institution.org:80{p_end}
{phang2} 5. After editting the configuration.properties file, restart STATA and do {it:{stata "getdataconfig":getdataconfig}}.{p_end}
{phang2} It is advisable to follow the instructions on the configuration.properties file, that you can edit with any text processor, e.g. Notepad.{p_end}



{marker author}{...}
{title:Author}

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

   

