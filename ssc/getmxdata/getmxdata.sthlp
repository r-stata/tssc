{smcl}
{* *! version 1.0  october 2019}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "getmxdata##syntax"}{...}
{viewerjumpto "Description" "getmxdata##description"}{...}
{viewerjumpto "Options" "getmxdata##options"}{...}
{viewerjumpto "Remarks" "getmxdata##remarks"}{...}
{viewerjumpto "Examples" "getmxdata##examples"}{...}
{title:Title}

{phang}
{bf:getmxdata} {hline 2} Import data from National Institute of Statistics and Geography (INEGI) & the Bank of Mexico (Banxico) into Stata

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:getmxdata} id_1 [id_2 ... id_n] {cmd:,}{cmdab:API_options} 

{synoptset 27 tabbed}{...}
{synopthdr:API_options}
{synoptline}
{synopt :{opt bie}}use INEGI's API for Bank of economic information (BIE) database {p_end}
{synopt :{opt banxico}}use Banxico's API for Economic Information System (SIE) database{p_end}
{synopt :{opt key}(token)}token for use webservice{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:getmxdata} allows to directly import historic economic series of Mexico. By using APIs of the National Institute of Statistics and Geography (INEGI)
and the Bank of Mexico (Banxico), Stata users can access to all variables in INEGI's Bank of economic information (BIE) database (over  300,000 series) and 
from Economic Information System (SIE) database of Banxico. With the data, getmxdata also retrieve some basic metadata; description of series and units that 
are stored as label of variables.

{marker remarks}{...}
{title:Remarks}

{pstd}
1.- When using the webservice of INEGI, the ID designed is all numeric and due to Stata doesn't allow numeric varnames, variables are renamed using "v_" as 
prefix to avoid an error. If you consult nominal GDP (ID is 494072) on Stata will apear as "v_494072", once the process has ended the user can rename the variable.

{pstd}
2.- Before using getmxdata, you must get a token from INEGI and Banxico.

{p 4 4 2} {hline 1} To get your token for INEGI webservice enter here:  {browse "http://www3.inegi.org.mx//sistemas/api/indicadores/v1/tokenVerify.aspx":INEGI's API service}.{p_end}

{p 4 4 2} {hline 1} To get your token for Bancico webservice enter here:  {browse "https://www.banxico.org.mx/SieAPIRest/service/v1/":Banxico's API service}.{p_end}

{pstd}
3.- It's advisable that users be familiar whit definitions of indicators and catalogues before using getmxdata. Metadata retrived only 
shows basic information, if you need more detailed description on a particular variable it's recommended to check directly on INEGI or Banxico.

{p 4 4 2} {hline 1} To consult series catalogue of INEGI enter here:  {browse "https://www.inegi.org.mx/servicios/api_indicadores.html":INEGI's API service}.{p_end}

{p 4 4 2} {hline 1} To consult series catalogue of Banxico enter here:  {browse "https://www.banxico.org.mx/SieAPIRest/service/v1/":Banxico's API service}.{p_end}

{pstd}
4.- getmxdata uses moss command written by Robert Picard & Nick Cox, first make sure to install before use.

{pstd}
5.- Users can only use a webservice at once.

{pstd}
6.- getmxdata is designed to imporat all variables you want only if they have the same frecuency. This way, users have to make different consults 
if you want to import variables that have diferent frequencies

{marker Examples}{...}
{title:Examples}

{phang}{cmd: local banxico_token token} // paste in token your real token of Banxico {p_end} 

{phang}{cmd: local inegi_token token} // paste in token your real token of INEGI {p_end} 

{phang}{cmd: getmxdata  494072 495466, bie key(`inegi_token')} // Import nominal GDP and GDP deflator {p_end} 

{phang}{cmd: getmxdata SE28533  SE28528, banxico key(`banxico_token')} // Import remittances as number of operations and amount {p_end} 

{marker Author}{...}
{title:Author}

{pstd}
Miguel Angel Gonzalez Favila
{pstd}
miguel.gfavila@gmail.com
