{smcl}
{* *! version 1.0.0 12jun2013}{...}

{cmd:help geocodeopen}

{hline}

{title:Title}
{phang}
{bf:geocodeopen} {hline 2} Geocode addresses using MapQuest Open Geocoding Services and Open Street Maps


{title:Syntax}
{p 8 17 2}
{cmd:geocodeopen}
{ifin}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt keyname(AppKey)}}specify MapQuest AppKey{p_end}
{synopt:{opt address(varname)}}specify {it:varname} of address variable{p_end}
{synopt:{opt city(varname)}}specify {it:varname} of city variable{p_end}
{synopt:{opt state(varname)}}specify {it:varname} of state variable{p_end}
{synopt:{opt zip(varname)}}specify {it:varname} of ZIP code variable{p_end}
{synopt:{opt fulladdr(varname)}}specify {it:varname} of full address variable{p_end}
{synopt:{opt replace}}replace latitude and longitude variables if they exist{p_end}
{synoptline}
{p2colreset}{...}

 
{title:Description}

{pstd}
{cmd:geocodeopen} uses MapQuest Open Geocoding APIs to geocode addresses and calculate latitude and longitude.   This allows it to overcome the restrictive limits on number of queries imposed by geocode commands that use the Google Maps API.


{title:Options}

{dlgtab:Main}

{phang}
{opt key(keyname)} specifies your MapQuest Application Key, {it:keyname} (necessary to use the MapQuest APIs). The argument {it:keyname} should be enclosed in quotation marks. Request an Application Key from http://developer.mapquest.com

{phang}
{opt address(varname)} specifies that {it:varname} contains the street number and street name.

{phang}
{opt city(varname)} specifies that {it:varname} contains the city.

{phang}
{opt state(varname)} specifies that {it:varname} contains the state (two letter postal abbreviation).

{phang}
{opt zip(varname)} specifies that {it:varname} contains the ZIP code.

{phang}
{opt fulladdr(varname)} may be used to specify that {it:varname} contains the full address in the form: 1234 Main St, Sunnydale, CA 95037

{phang}
{opt replace} instructs {cmd:geocodeopen} to overwrite variables named latitude and longitude if they already exist.


{title:Remarks}

{pstd}
{cmd:geocodeopen} generates variables latitude and longitude that contain the geocoded latitudes and longitudes for a list of specified addresses.

{pstd}
It also generates the following variables: geo_type, geo_quality, geo_address, geo_city, geo_state, geo_zip.  The variable geo_type specifies the granularity of the geocoding, and the variable geo_quality specifies the quality of the geocoding.  The variables geo_address, geo_city, geo_state, and geo_zip report how MapQuest interpreted the address, city, state, and ZIP code respectively.  The geo_type and geo_quality variables may be interpreted using the code book available at http://open.mapquestapi.com/geocoding/geocodequality.html

{pstd}
As of June 2013, MapQuest requires an AppKey in order to make API calls. An AppKey may be requested at no charge by signing up at http://developer.mapquest.com. Alternatively, you may specify the following AppKey, but no guarantees are made that it will work: youFmjtd%7Cluub2gualu%2Ca2%3Do5-9uaaqr 

{pstd}
Geocoding Courtesy of MapQuest. Data generated from this program are made available under the Open Database License: http://opendatacommons.org/licenses/odbl/1.0/. Any rights in individual contents of the database are licensed under the Database Contents License: http://opendatacommons.org/licenses/dbcl/1.0/.

{title:Examples}

{phang}{cmd:. geocodeopen in 1/1000, key("youFmjtd%7Cluub2gualu%2Ca2%3Do5-9uaaqr") address(home_address) city(city_name) state(name_of_state) zip(numerical_zipcode)}

{phang}{cmd:. geocodeopen, key("youFmjtd%7Cluub2gualu%2Ca2%3Do5-9uaaqr") fulladdr(full_address) replace}


{title:Author}

{pstd}
Michael L. Anderson, UC Berkeley, mlanderson@berkeley.edu, http://are.berkeley.edu/~mlanderson/
{p_end}
