{smcl}
{* *! version 0.3.7 20.05.2020}{...}

{title:Title}

{phang}
{bf:geocodehere} {hline 2} Geocode locations using HERE maps (Nokia). It is required to obtain HERE maps API credentials, which will be cost-free and takes only a few seconds, provided that you stay below 250,000 monthly transactions.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:geocodehere}
{ifin}{cmd:,} apikey( ... )    [{it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt replace}} replace existing geocode results {p_end}
{synopt:{opt noisily}} produce more terminal output while running {p_end}

{syntab:Credentials (required)}
{synopt:{opt apikey(...)}} HERE maps API key (see below){p_end}

{syntab:Response switches}
{synopt:{opt language(...)}} Specifies the language for returned string variables {p_end}

{syntab:Search specification}
{synopt:{opt searchtext(...)}} HERE maps search text{p_end}
{synopt:{opt country(...)}} HERE maps search key{p_end}
{synopt:{opt countryfocus(...)}} HERE maps search key{p_end}
{synopt:{opt state(...)}} HERE maps search key{p_end}
{synopt:{opt county(...)}} HERE maps search key{p_end}
{synopt:{opt district(...)}} HERE maps search key{p_end}
{synopt:{opt city(...)}} HERE maps search key{p_end}
{synopt:{opt street(...)}} HERE maps search key{p_end}
{synopt:{opt housenumber(...)}} HERE maps search key{p_end}
{synopt:{opt postalcode(...)}} HERE maps search key{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:geocodehere} uses HERE maps (Nokia) to find geographic coordinates and additional information on addresses/locations.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt replace} replace existing geocode results (all variables geocodehere_*). Even if the current round fails to geocode a certain observation old entries will be lost.

{phang}
{opt noisily} produce more terminal output while running. Useful for debugging and for understanding issues with authentification.

{dlgtab:Credentials}

{phang}
{opt apikey(...)}  specify the HERE maps API  key. Credentials can be obtained through the HERE maps website, takes about three minutes and will be free for the most common uses with Stata (e.g. geo locating several hundred municipalities).
More details are available under:
{browse "https://developer.here.com/pricing"}
(most likely you'd have to select the consumer plan "Freemium") 
{p_end}


{dlgtab:Response switches}

{phang}
{opt language(...)} Specifies the language for returned string variables.  Language code must be provided according to RFC 4647 standard. {p_end}


{dlgtab:Search specification}

{phang}
Options for specifying search criteria behave as specified in the HERE maps API documentation.   Details can be found here:
{browse "https://developer.here.com/rest-apis/documentation/geocoder/topics/resource-geocode.html"}.{p_end}

{phang}
{opt searchtext(...)} search text with flexible/fuzzy matching. See documentation for details.{p_end}

{phang}
{opt [searchkey](...)} search parameters with different effects. See documentation for details.{p_end}

{marker output}{...}
{title:Output}

{pstd}
The program generates several variables containting information on the found locality. Most importantly geocodehere_lat and geocodehere_lon contain coordinates.
Some variables vary in their definition depending on the country (e.g. postal code or county).
Other variables contain information that can be used to assess the quality of the match.
To interpret the results the HERE documentation is very helpful: {browse "https://developer.here.com/rest-apis/documentation/geocoder/topics/resource-type-response-geocode.html"}.

{pstd}
The generated variables are:

{p2colset 10 45 37 55}{...}
{p2col:Variable name}Content{p_end}
{p2col:}  (JSON Path){p_end}
{p2line}
{p2colset 12 46 38 55}{...}
{p2col:geocodehere_country}3-digit country code{p_end}
{p2col:}  (Result:1:Location:Address:Country){p_end}
{p2col:geocodehere_lon}Longitude{p_end}
{p2col:}  (Result:1:Location:DisplayPosition:Longitude){p_end}
{p2col:geocodehere_lat}Latitude{p_end}
{p2col:}  (Result:1:Location:DisplayPosition:Latitude){p_end}
{p2col:geocodehere_label}Address label{p_end}
{p2col:}  (Result:1:Location:Address:Label){p_end}
{p2col:geocodehere_match_level}Match level{p_end}
{p2col:}  (Result:1:MatchLevel){p_end}
{p2col:geocodehere_match_code}Match code{p_end}
{p2col:}  (Result:1:MatchCode){p_end}
{p2col:geocodehere_locationtype}Location type{p_end}
{p2col:}  (Result:1:Location:LocationType){p_end}
{p2col:geocodehere_county}County{p_end}
{p2col:}  (Result:1:Location:Address:County){p_end}
{p2col:geocodehere_city}City{p_end}
{p2col:}  (Result:1:Location:Address:City){p_end}
{p2col:geocodehere_district}District{p_end}
{p2col:}  (Result:1:Location:Address:District){p_end}
{p2col:geocodehere_street}Street name{p_end}
{p2col:}  (Result:1:Location:Address:Street){p_end}
{p2col:geocodehere_housenumber}House number{p_end}
{p2col:}  (Result:1:Location:Address:HouseNumber){p_end}
{p2col:geocodehere_postalcode}Postal code{p_end}
{p2col:}  (Result:1:Location:Address:PostalCode){p_end}
{p2colset 10 25 27 55}{...}
{p2line}

{marker example}{...}
{title:Example}

{pstd}
This example code creates a data set of three entirely different localites. Before the code is executable, it is required to obtain HERE maps API credentials (see above).

{phang}
{stata `"set obs 3"'}
{p_end}
{phang}
{stata `"gen postalcode = "e26dx" in 1"'}
{p_end}
{phang}
{stata `"replace postalcode = "37213" in 2"'}
{p_end}
{phang}
{stata `"gen housenumber = "12" in 2"'}
{p_end}
{phang}
{stata `"gen street = "weserstr" in 2"'}
{p_end}
{phang}
{stata `"gen searchtext = "Elephant Walk, Accra, Ghana" in 3"'}
{p_end}
{phang}
{stata `"geocodehere, apikey(Your HERE maps API key) postalcode(postalcode) street(street) housenumber(housenumber) searchtext(searchtext)"'} 
{p_end}

{title:See also}

{pstd}
{help geocode},
{help gcode},
{help geocodeopen}, 
geocode3

{pstd}
Required ssc package: {help insheetjson}

{title:Author}

{pstd}
Simon Heß, Goethe University Frankfurt.{p_end}

{pstd}
The latest version of geocodehere can always be obtained from {browse "https://github.com/simonheb/geocodehere"} or {browse "http://HessS.org"}.{p_end}

{pstd}
I am happy to receive comments and suggestions regarding bugs or possibilites for improvements/extensions via {browse "https://github.com/simonheb/geocodehere/issues"}.{p_end}

{title:Known issues with geocodehere}

{pstd}
Stata versions before Stata 14 are not able to handle unicode character encodings. As a result, response data from HERE containing special characters may appear partly
scrambled (e.g. "Straße" != "StraÃŸe"). In some cases it helps to specify the option language(EN).
{p_end}
