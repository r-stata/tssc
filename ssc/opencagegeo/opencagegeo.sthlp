{smcl}
{* *! version 1.2.0 10.02.2018}{...}
{* *! Lars Zeigermann}{...}

{cmd:help opencagegeo}

{hline}

{title:Title}

{phang}
{bf:opencagegeo} {hline 2} (Forward and reverse) geocode locations using the OpenCage Geocoder API.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:opencagegeo}
{ifin}
{cmd:,}
{bind:{cmdab:key(}API key{cmd:)}[{it:options}]}

{p 8 17 2}
{cmdab:opencagegeoi}
{cmd:#location}

{synoptset 32 tabbed}{...}
{synopthdr :opencagegeo_options}
{synoptline}
{syntab:General}
{synopt:{opt key(API key)}} specifies the OpenCage Geocoder API key{p_end}
{synopt:{opt countrycode(varname or string)}} specifies the countrycode of the location{p_end}
{synopt:{opt lang:uage(varname or string)}} specifies the response language {p_end}
{synopt:{opt res:ume}} resume after the query limit was exceeded{p_end}
{synopt:{opt replace}} replace existing results {p_end}

{syntab:Forward geocoding}
{synopt:{opth str:eet(varname)}} specifies the variable containing the street name{p_end}
{synopt:{opth num:ber(varname)}} specifies the variable containing the house number{p_end}
{synopt:{opth post:code(varname)}} specifies the variable containing the postal code{p_end}
{synopt:{opth city(varname)}} specifies the variable containing the city (town,village){p_end}
{synopt:{opth county(varname)}} specifies the variable containing the county{p_end}
{synopt:{opth state(varname)}} specifies the variable containing the state{p_end}
{synopt:{opth country(varname)}} specifies the variable containing the country{p_end}
{synopt:{opth full:address(varname)}} specifies the variable containing the full address{p_end}

{syntab:Reverse geocoding}
{synopt:{opth lat:itude(varname)}} specifies the variable containing the latiude{p_end}
{synopt:{opth lon:gitude(varname)}} specifies the variable containing the longitude{p_end}
{synopt:{opth coord:inates(varname)}} specifies the variable containing latitude longitude pairs{p_end}
{synoptline}

{pstd}
Note: for {cmd:opencagegeoi}, the immediate version of {cmd:opencagegeo}, the user needs to define a global macro mykey containing the OpenCage Geocoder API key.
{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:opencagegeo} uses the OpenCage Geocoder API (application programming interface) to obtain geographic coordinates for addresses (forward geocoding) and to retrieve postal addresses from latitude longitude pairs (reverse geocoding). {cmd:opencagegeo} takes its inputs from data in the memory and stores the results returned from the OpenCage Geocoder API in a set of variables. It allows the user to geocode many locations.
{p_end}

{pstd}
{cmd:opencagegeoi} is the immediate version of {cmd:opencagegeo} for geocoding a single location. The location address to be geocoded is typed directly into the command window. The results are directly displayed in the output window and stored in r().{p_end}

{pstd}
{cmd:opencagegeo} requires an OpenCage Data API key which can be obtained by signing up at {browse "https://geocoder.opencagedata.com/users/sign_up"}. The user can choose among a number of customer plans with different daily rate limits. The free trial plan allows 2.500 requests per day. If the rate limit is hit, opencagegeo will issue an error message and exit. To continue the task on the following day, the user may simply add the {opt resume} option to the orignal specification. {cmd:opencagegeo} will automatically detect which observations are still to be geocoded. The user is strongly advised not to make any changes to the data until geocoding of all observations is completed. A new day begins at 00:00:00 Coordinated Universal Time (UTC). {p_end}

{pstd}
Contrary to other geocoders routines available in Stata, OpenCage Data does not restrict data usage and explicitly allows storage. All geocoded data obtained from {cmd:opencagegeo} is jointly licensed under {browse "http://opendatacommons.org/licenses/odbl/summary/":ODbL} and {browse "https://creativecommons.org/licenses/by-sa/2.0/":CC-BY-SA} licenses.{p_end}

{p 4 4 3}
{cmd:opencagegeo} uses two user-written Stata libraries, {help insheetjson} and {help libjson}, for processing the JavaScript Object Notation (JSON) objects returned by the OpenCage Geocoder API.
They are available via Statistical Software Components.{p_end}


{marker options}{...}
{title:Options for {cmd:opencagegeo}}

{dlgtab:Main}

{phang}
{opt key(API key)} specifies the OpenCage Geocoder API key.

{phang}
{opt countrycode(varname or string)} allows the user to specify the country code of the location. 
Providing a country code will restrict the results to the respective country. If all locations are in the same country, simply input the country code as a string.
If the locations are in two or more countries, specify a variable containing the respective country codes.
{cmd:opencagegeo} takes two character country codes as defined by the {browse "https://www.iso.org/obp/ui/#search":ISO 3166-1 Alpha 2} standard.

{phang}
{opt language(varname or string)} allows the user to specify the language in which the results are returned. As with {opt countrycode()}, either a string or a string variable can be specified.
{cmd:opencagegeo} takes language codes as defined by the
 {browse "http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry":IETF} standard.
User of Stata 13 or older are advised to use the language carefully as many languages contain special characters which cannot be displayed properly.

{phang}
{opt replace} instructs {cmd:opencagegeo} to overwrite existing geocoded results. If either {opt in} or {opt if} are specified, only selected observations will be replaced.

{phang}
{opt resume} allows the user to continue geocoding on the following day if the rate limit was hit. The user is strongly advised not to make any changes to the data set before geocoding of all observations is completed.

{dlgtab:Forward Geocoding}


{phang}
{opth number(varname)}  specifies the variable containing the house number.{p_end}

{phang}
{opth street(varname)}  specifies the variable containing the street name. Varname must be string.{p_end}

{phang}
{opth postcode(varname)}  specifies the variable containing the postal code.{p_end}

{phang}
{opth city(varname)}  specifies the variable containing the city, town or village. Varname must be string.{p_end}

{phang}
{opth county(varname)}  specifies the variable containing the county. Varname must be string.{p_end}

{phang}
{opth state(varname)}  specifies the variable containing the state. Varname must be string.{p_end}

{phang}
{opth country(varname)}  specifies the variable containing the country. Varname must be string.{p_end}

{phang}
{opth fulladdress(varname)}  specifies the variable containing the full address. Varname must be string. For the format, see below. {opt fulladdress()} may not be combined with any of the above options.{p_end}

{dlgtab:Reserve Geocoding}

{phang}
{opth latitude(varname)}  specifies the variable containing the latitude. Values must lie between -90 and 90.{p_end}

{phang}
{opth longitude(varname)}  specifies the variable containing the longitude. Values must lie between -180 and 180.{p_end}

{phang}
{opth coordinates(varname)}  specifies the variable containing latitude longitude pairs. Values for latitudes and longitudes must be in the range of -90 to 90 and -180 to 180 respectively. 
Both values must be separated by a comma. Varname must be string.{p_end}

{marker remarks}{...}
{title:Remarks for {cmd:opencagegeo}}

{pstd}
Not all options for forward geocoding have to be specified at the same time; any meaningful combination is possible. To obtain geocodes of cities you may use {opt city()}, {opt state()} and {opt country()}.
Addresses in a single string variable are entered into {opt fulladdress()} and should follow the local convention, although the OpenCage Geocoder API allows for some flexibility. A well-formatted address might take the following formats:

{phang2}
"number street, city postal code, county, state, country"
{p_end}
{phang2}
"street number, postal code city, county, state, country"
{p_end}

{pstd}
Generally, the OpenCage Geocoder is not case sensitive and can deal with commonly used abbreviations. Running {cmd:opencagegeo} in Stata 14 (or newer) allows Unicode (UTF-8) inputs. That is address names may contain accented characters, symbols and non-latin characters. For older releases, the input variables may only contain printable ASCII characters, i.e. character codes 32 to 127. Otherwise, {cmd:opencagegeo} will issue an error message and exit. {cmd:opencagegeo} is sensitive to spelling mistakes and will return empty strings for misspelled location addresses.

{marker remarks}{...}
{title:Remarks for {cmd:opencagegeoi}}

{pstd}
For {cmd:opencagegeoi} the API key must be stored in a global macro mykey. The user may further specify a global macro language containing the language in which the results shall be returned. The default is English. If the user sets the language to native, the results will be in the native language of the location - provided the underlying OpenStreetMap (OSM) data is available in that language.

{pstd}
For forward geocoding, addresses should be well-formatted as described above. For reverse geocoding, {cmd:opencagegeoi} takes a latitude longitude pair as input. The latitude must be stated first and both values need to be separated by a comma.

{marker output}{...}
{title:Output of {cmd:opencagegeo}}

{pstd}
{cmd:opencagegeo} creates a set of variables which are described below.

{p2colset 10 30 37 80}{...}
{p2col:Variable name}Variable content{p_end}
{p2line}
{p2colset 12 32 38 80}{...}
{p2col:g_latitude}latitude{p_end}
{p2col:g_longitude}longitude{p_end}
{p2col:g_street}street name{p_end}
{p2col:g_number}house number{p_end}
{p2col:g_postcode}postal code{p_end}
{p2col:g_city}city,town or village{p_end}
{p2col:g_county}county{p_end}
{p2col:g_state}state{p_end}
{p2col:g_country}country{p_end}
{p2col:g_formatted}well-formated version of the place name (see below){p_end}
{p2col:g_confidence}confidence level (see below){p_end}
{p2col:g_quality}quality level (see below){p_end}
{p2colset 10 30 37 80}{...}
{p2line}

{pstd}
If the information is missing (e.g. the house number is not known) or not requested (number() was not specified
or no information on the house number was contained in address variable fed into the fulladdress() option), missing values will be returned.

{pstd}
g_formatted is a string variable containing a well-formatted place name generated by the OpenCage Geocoder API.
It addition to the address, it might have information such as the building name, building type (shopping mall, church etc.), the name of the shop etc.

{pstd}
g_confidence provides a measure of precision of the match. The confidence levels is calculated as the distance in kilometres between the South-East and the North-West corners of the bounding box. Confidence levels are defined as follows:

{p2colset 10 30 37 110}{...}
{p2col:Value}Definition{p_end}
{p2line}
{p2colset 12 32 38 110}{...}
{p2col:0}not defined{p_end}
{p2col:1}25km or more{p_end}
{p2col:2}less than 25km{p_end}
{p2col:3}less than 20km{p_end}
{p2col:4}less than 15km{p_end}
{p2col:5}less than 10km{p_end}
{p2col:6}less than 7.5km{p_end}
{p2col:7}less than 5km{p_end}
{p2col:8}less than 1km{p_end}
{p2col:9}less than 0.5km{p_end}
{p2col:10}less than 0.25km{p_end}
{p2colset 10 30 37 110}{...}
{p2line}

{pstd}
The variable g_quality contains the accuracy level of the returned results and is defined as follows:

{p2colset 10 30 37 90}{...}
{p2col:Value (label)}Definition{p_end}
{p2line}
{p2colset 12 32 38 90}{...}
{p2col:0 (not found)}location not found{p_end}
{p2col:1 (country)}country level accuracy{p_end}
{p2col:2 (state)}state level accuracy{p_end}
{p2col:3 (county)}county level accuracy{p_end}
{p2col:4 (city)}city (town, village) level accuracy{p_end}
{p2col:5 (postcode)}postal code level accuracy{p_end}
{p2col:6 (street)}street level accuracy{p_end}
{p2col:7 (number)}house number level accuracy{p_end}
{p2colset 10 30 37 90}{...}
{p2line}

{pstd}
The highest quality level to be reached is hence determined by the inputs; 
if {opt number()} is not specified or no information on the house number is contained in the variable fed into {opt fulladdress()}, the highest quality level to be achieved is street.

{marker storedresults}{...}
{title:Stored results of {cmd:opencagegeoi}}

{pstd}
opencagegeoi saves the following results to {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(input)}}address as typed by user{p_end}
{synopt:{cmd:r(formatted)}}well-formatted address returned from OpenCage Geocoder{p_end}
{synopt:{cmd:r(lat)}}latitude{p_end}
{synopt:{cmd:r(lon)}}longitude{p_end}
{synopt:{cmd:r(conf)}}confidence level of result{p_end}

{marker example}{...}
{title:Examples for {cmd:opencagegeo}}

{pstd}
The following examples shall demonstrate how {cmd:opencagegeo} is used. For execution, an Opencage Geocoder API key is required.
{p_end}

{pstd}
We first generate two location addresses where the address components are contained in separate variables.{p_end}
{phang2}
{stata `"set obs 2"'}
{p_end}
{phang2}
{stata `"gen STREET = "Wittenbergerstrasse" in 1"'}
{p_end}
{phang2}
{stata `"replace STREET = "Denkmalsplatz" in 2"'}
{p_end}
{phang2}
{stata `"gen HOUSENUMBER = "14" in 1"'}
{p_end}
{phang2}
{stata `"gen POSTCODE = "26188" in 1"'}
{p_end}
{phang2}
{stata `"replace POSTCODE = "26180" in 2"'}
{p_end}
{phang2}
{stata `"gen CITY = "Edewecht" in 1"'}
{p_end}
{phang2}
{stata `"replace CITY = "Rastede" in 2"'}
{p_end}

{pstd}
To forward geocode the two locations generated above, we type:
{p_end}
{phang2}
{stata `"opencagegeo, key(YOUR-KEY-HERE) street(STREET) number(HOUSENUMBER) city(CITY)"'} 
{p_end}

{pstd}
For the {opt fulladdress()} option, the location address must be contained in a single string variable.
{p_end}
{phang2}
{stata `"gen ADDRESS = "Wittenbergerstrasse 14,26188 Edewecht,Germany" in 1"'}
{p_end}
{phang2}
{stata `"replace ADDRESS = "Denkmalsplatz,26180 Rastede,Germany" in 2"'}
{p_end}

{pstd}
To obtain geocodes using the {opt fulladdress()} option, we specify {cmd:opencagegeo} as following:
{p_end}
{phang2}
{stata `"opencagegeo, key(YOUR-KEY-HERE) fulladdress(ADDRESS) replace"'}
{p_end}

{pstd}
Now, we generate to variables containing latitudes and longitudes.
{p_end}
{phang2}
{stata `"gen LATITUDE = "53.1479943" in 1"'}
{p_end}
{phang2}
{stata `"replace LATITUDE = "53.2450876" in 2"'}
{p_end}
{phang2}
{stata `"gen LONGITUDE = "7.8664466" in 1"'}
{p_end}
{phang2}
{stata `"replace LONGITUDE = "8.1992326" in 2"'}
{p_end}

{pstd}
To retrieve the postal address, we type:
{p_end}
{phang2}
{stata `"opencagegeo, key(YOUR-KEY-HERE) latitude(LATITUDE) longitude(LONGITUDE) replace"'} 
{p_end}

{pstd}
Alternatively, we might have geographic coordinates saved as comma-separated latitude longitude pairs in a single string variable.
{p_end}
{phang2}
{stata `"gen COORDINATES = "53.1479943,7.8664466" in 1"'}
{p_end}
{phang2}
{stata `"replace COORDINATES = "53.2450876,8.1992326" in 2"'}
{p_end}

{pstd}
To reserve geocoding the geocodes using the {opt coordinates} option, we type:
{p_end}
{phang2}
{stata `"opencagegeo, key(YOUR-KEY-HERE) coordinates(COORDINATES) replace"'} 
{p_end}

{marker example}{...}
{title:Examples for {cmd:opencagegeoi}}

{pstd}
First, we generate the global macro mykey (required) and set the output language (optional), in our case to German:
{p_end}
{phang2}
{stata `"global mykey YOUR-KEY-HERE"'} 
{p_end}
{phang2}
{stata `"global language DE"'} 
{p_end}

{pstd}
To forward geocode an address, we specify {cmd:opencagegeoi} as following:
{p_end}
{phang2}
{stata `"opencagegeoi Wittenbergerstrasse 14, 26188 Edewecht, Germany"'} 
{p_end}

{pstd}
To retrieve the address from a latitude longitude pair, we type:
{p_end}
{phang2}
{stata `"opencagegeoi 53.1479943,7.8664466"'} 
{p_end}

{title:See also}

{pstd}
{help geocode},
geocode3,
{help gcode},
{help geocodeopen}, 
{help geocodehere}


{pstd}
Required ssc packages: {help insheetjson}, {help libjson}

{title:Author}

{pstd}
Lars Zeigermann, D{c u:}sseldorf Institute for Competition Economics (DICE) & Monopolies Commission, ({browse "mailto:lars.zeigermann@monopolkommission.bund.de":lars.zeigermann@monopolkommission.bund.de}){p_end}


{title:Acknowledgements}

{pstd}
Thanks to Ed Freyfolge of OpenCage Data for his support and Achim Ahrens for testing and helping improve {cmd:opencagegeo}. 
I also thank the authors of existing geocoding routines, especially Adam Ozimek and Daniel Miles ({cmd:geocode}). Parts of {cmd:opencagegeo} build upon their code. The immediate version was added at Kit Baum's suggestion. All remaining errors are my own. Comments and suggestions are highly appreciated.
{p_end}
