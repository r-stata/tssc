{smcl}
{* version 1.0 27Jul2016}{...}
{title:Title}

{phang}
{bf:googleplaces} {hline 2} Using Google Places API to return search results from Google Places


{title:Syntax}

{p 8 17 2}
{cmdab:googleplaces}
[{help varlist}]
[{help in}],
[textsearch nearbysearch] 
[apikey(stringasis)] 
[{it:options}]{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:googleplaces} uses the Google Places API Web Service to retrieve search results from Google Places,
the database of places that supports Google Maps, Google+ and many other location-based web services.  
{cmd:googleplaces} returns detailed place information for each search and can execute a regular text search 
using keywords that you would enter into the Google search webpage or a nearby search using a set of coordinates 
to retrieve results for places within a specified radius.  Each search result provides the full place name, 
geocoded coordinates, and full address, with the capability to gather additional data such as 
phone number, price level, customer rating and website of that place if applicable.  


{title:Getting an API key for Google Places}

{pstd}
To query the Google Places API, users must register for an API key from the Google Places API Web Service 
by clicking {browse "https://developers.google.com/places/web-service/intro":here}.  The API key must be included in any 
{cmd:googleplaces} command requesting search results.  The Google Places Web Service can be accessed for free, 
but requires a credit card for account validation.  The free service provides 15,000 searches a day.  
Paid services offer more searches per day, which can be explored through the link to usage limits and pricing.


{title:Required Library}

{pstd}
{cmd:googleplaces} users must have insheetjson and libjson installed, 
both of which are available from SSC using the following commands:

{pstd} {stata ssc install insheetjson}, {stata ssc install libjson}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{pstd}{opt varlist} is a list of one or more variables that contain text to be submitted as search queries.  
All variables in the {opt varlist} must be formatted as strings.  
For nearbysearch the {opt varlist} can contain only one variable formatted as described below. 
{opt varlist} should not be included when using the {opt cleanup} option.

{pstd}{opt textsearch} or {opt nearbysearch} must be chosen when submitting search requests 
to specify to Google what kind of query to make.  When using {opt nearbysearch}, 
the {opt varlist} must contain only a single string variable containing a latitude and longitude 
seperated by a single comma and no space (example: "00.0000000,-11.1111111").

{pstd}{opt apikey}(stringasis) allows the user to enter an API key for submitting search requests. 
After registering with Google, each user will copy and paste the API key between parenthesis.
The command will not initiate search requests without an APIkey.

{dlgtab:Supplemental}

{pstd}{opt advanced} submits a two-part search to capture the default search returns 
(full place name, geocoded coordinates, and full address) and submit a follow-up search 
on each return to capture phone number, price level, customer rating, and website (if applicable).  
Choosing the {opt advanced} search option causes {cmd:googleplaces} to use up the 
availble daily search quota more rapidly, although the follow-up queries are 
weighted at 1/10th the value of a normal search query against a user's daily quota 
(15,000 daily searches for free accounts).  

{pstd}{opt results(integer)} controls the maximum number of results to capture for a {opt textsearch} or {opt nearbysearch}.  
The default is 1 if not listed.  The maximum number of results a user can specify is 20.  
Some queries may produce fewer than the specified maximum number of results in which case 
{cmd:googleplaces} returns the number of search results actually found.

{pstd}{opt radius(string asis)} sets the radius for a {opt nearbysearch}.  The default is 0 if not listed.
Note, the search radius must be measured in meters. To set a radius of 5km, enter {opt radius(5000)}.

{pstd}{opt keyword(string asis)} can be included for a {opt nearbysearch} to filter out results with matching keyword.  

{pstd}{opt type(string asis)} limits the results for a {opt nearbysearch} to a specified type using 
Google Places predetermined list of type categories.  To view the available types to choose from on Google's website, click 
{browse "https://developers.google.com/places/supported_types#table1":here}.

{pstd}{opt cleanup} If the command is interrupted or terminated before the search completes, 
the data returned to the Stat dataset will be unsorted and in an incorrect format.  
Run the command with only the cleanup option and no other inputs to finish sorting and reformating the data to it's original form. 
NOTE: If {cmd:googleplaces} terminates without finishing the search, 
the command will not run on the same dataset until after the user submits {cmd: googleplaces, cleanup}.

{marker examples}{...}
{title:Examples}

{pstd}
Conducting a text search using two variables: business_name and address{p_end}
{phang2}{cmd:. googleplaces business_name address, textsearch apikey(yourapikeyhere)}{p_end}

{pstd}
Conducting a nearby search to identify up to 20 police locations within a 10km radius of each geocoded location in the dataset{p_end}
{phang2}{cmd:. googleplaces coordinates, nearbysearch apikey(yourapikeyhere) results(20) radius(10000) type(police)}{p_end}

{pstd}
Limiting a nearby search to return up to 5 results within a 5km radius related to health using the keyword option{p_end}
{phang2}{cmd:. googleplaces coordinates, nearbysearch apikey(yourapikeyhere) results(5) radius(5000) keyword(health)}{p_end}

{pstd}
Conducting a nearby search to identify up to 10 restaurants within 1km and requesting extended search results{p_end}
{phang2}{cmd:. googleplaces coordinates, nearbysearch apikey(yourapikeyhere) results(10) radius(1000) type(restaurant) advanced}{p_end}

{pstd}
If the command terminates before completing a search, the dataset will need to be cleaned up as follows using the cleanup option{p_end}
{phang2}{cmd:. googleplaces, cleanup}{p_end}

{title:Authors}

{pstd}Taylor Crockett ({browse "mailto:tcrockett53@gmail.com":tcrockett53@gmail.com}){p_end}
{pstd}Stephen Barnes ({browse "mailto:barnes@lsu.edu":barnes@lsu.edu}){p_end}
{pstd}Chris Schmidt ({browse "mailto:chris.m.schmidt@utexas.edu":chris.m.schmidt@utexas.edu}){p_end}

{title:Acknowledgements}

{pstd}Developed with support from the LSU Economics & Policy Research Group
