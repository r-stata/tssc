{smcl}
{* *! 30jan2020}{...}
{cmd:help georoute}
{hline}


{title:Title}

{p 4 18 2}
{hi:georoute} {hline 2} Calculate travel distance and travel time
between two addresses or two geographical points identified by 
their coordinates.
{p_end}


{title:Syntax}

{p 4 12 2}
{cmd:georoute} 
{ifin}
{cmd:,} 
{c -(}{opt hereid(string)} {opt herecode(string)} {c |} {opt herekey(string)}{c )-}
{c -(}{opth startad:dress(varlist)} {c |} {opth startxy(varlist)}{c )-}
{c -(}{opth endad:dress(varlist)} {c |} {opth endxy(varlist)}{c )-}
[{opt km} 
{opth di:stance(newvar)} 
{opth ti:me(newvar)} 
{opth diag:nostic(newvar)} 
{cmdab:co:ordinates(}{it:str1 str2}{cmd:)}
{opt replace}
{opt herepaid}
{opt timer}
{opt pause}]


{phang}
Command with immediate arguments:{p_end}
{p 4 12 2}
{cmd:georoutei}
{cmd:,} 
{c -(}{opt hereid(string)} {opt herecode(string)} {c |} {opt herekey(string)}{c )-}
{c -(}{opth startad:dress(string)} {c |} {cmd: startxy(}{it:#x},{it:#y}{cmd:)}{c )-}
{c -(}{opth endad:dress(string)} {c |} {cmd: endxy(}{it:#x},{it:#y}{cmd:)}{c )-}
[{opt km} 
{opt herepaid}]


{title:Description}

{pstd}
{cmd:georoute} calculates the georouting distance between 
two addresses or two geographical points identified by their coordinates. 
It uses the HERE API ({browse "https://developer.here.com"}) to 
retrieve distances in two steps. In the first step, addresses are geocoded
and their geographical coordinates (latitude and longitude) are obtained.
In the second step, the georouting distance between the two points is obtained.
The user can also provide directly geographical coordinates, which will bypass
the first step.


{title:Requirements}

{pstd} {cmd:georoute} and {cmd:georoutei} use the user-written commands 
{cmd: insheetjson} and {cmd:libjson}. Type {stata ssc install insheetjson} 
and {stata ssc install libjson} to load the necessary packages. 

{pstd} Before using {cmd:georoute} and {cmd:georoutei}, the user must get an HERE account 
at {browse "https://developer.here.com"} and create an application that can be used with HERE API.
App ID and App Code are available in applications created before December 2019, but these 
have now been replaced. With new accounts, use the API Key credentials. 
For more information, see {browse "https://developer.here.com/documentation/authentication/dev_guide/index.html"}.


{title:Options}

{phang}{it:georoute_options}{p_end}
{synoptline}
{phang}{opth hereid(string)}, {opth herecode(string)}, and {opth herekey(string)}
must be used to specify HERE credentials. Either both {opt hereid(string)} and 
{opt herecode(string)} must be specified, or {opt herekey(string)} alone must be specified. 

{phang}{opth startaddress(varlist)} and {opth endaddress(varlist)}
specify the addresses of the starting and ending points. Addresses can be
inserted as a single variable or as a list of variables. Alternatively, 
{opth startxy(varlist)} and {opth endxy(varlist)} can be used.
Either {opt startaddress} or {opt startxy} is required. 
Either {opt endaddress} or {opt endxy} is required.

{phang2} Note: the presence of special characters (e.g. French accents) in addresses
might cause errors in the geocoding process. Such characters should be transformed 
before running {cmd:georoute}, e.g. using {help subinstr()}.

{phang}{opth startxy(varlist)} and {opth endxy(varlist)} 
specify the coordinates in decimal degrees of the starting and ending points. 
They can be used as an alternative to {opth startaddress(varlist)} and 
{opth endaddress(varlist)}. Two numeric variables containing x (latitude) and 
y (longitude) coordinates of the starting and ending points should be provided 
in {opth startxy(varlist)} and {opth endxy(varlist)}.

{phang2} Note: x (latitude) must be between -90 and 90. y (longitude) 
must be between -180 and 180. Examples: {break}
- United States Capitol: 38.8897, -77.0089 {break} 
- Eiffel Tower: 48.8584, 2.2923 {break} 
- Cape Horn: -55.9859, -67.2743 {break} 
- Pearl Tower: 31.2378, 121.5225 

{phang}{opt km} specifies that distances should be returned in kilometers. 
The default is to return distances in miles.

{phang}{opth distance(newvar)} creates the new variable {newvar} containing 
the travel distance between the two addresses. If not specified, distance will 
be stored in a variable named {it:travel_distance}.

{phang}{opth time(newvar)} creates the new variable {newvar} containing 
the travel time (by car and under normal traffic conditions) between the 
two addresses. If not specified, time will be stored in a variable 
named {it:travel_time}.

{phang}{opth diagnostic(newvar)} creates the new variable {newvar} containing 
a diagnostic code for the geocoding and georouting outcome of each observation in the database: 
0 = OK, 1 = No route found, 2 = Start and/or end not geocoded, 3 = Start and/or end coordinates missing.
If not specified, the codes will be stored in a variable named {it:georoute_diagnostic}.

{phang}{cmd:coordinates(}{it:str1 str2}{cmd:)} creates the new 
variables {it:str1_x}, {it:str1_y}, {it:str1_match}, {it:str2_x}, {it:str2_y}, 
and {it:str2_match}, that contain the coordinates and the match code of the 
starting ({it:str1_x},{it:str1_y},{it:str1_match}) 
and ending ({it:str2_x},{it:str2_y},{it:str2_match}) addresses.
If {opt coordinates} is not specified, coordinates and match code are not saved.
The match code indicates how well the result matches the request 
in a 4-point scale: 1 = exact, 2 = ambiguous, 3 = upHierarchy, 4 = ambiguousUpHierarchy. 

{phang}{opt replace} specifies that the variables in {cmd:distance()}, {cmd:time()},
{cmd:coordinates()}, and {cmd:diagnostic()} be replaced if they already exist in the database. 
It should be used cautiously because it might definitively drop some data.

{phang}{opt herepaid} allows the user who owns a paid HERE plan to specify it.
This will simply alter the url used for the API requests so as to comply with
HERE policy 
(see {browse "https://developer.here.com/rest-apis/documentation/geocoder/common/request-cit-environment-rest.html"}).

{phang}{opt timer} requests that a timer is printed while geocoding. If specified,
a dot is printed for every centile of the dataset that has been geocoded and 
the number corresponding to every decile is printed. 

{phang}{opt pause} can be used to slow the geocoding process by asking Stata to 
sleep for 30 seconds every 100th observation. This could be useful for large databases,
which might overload the HERE API and result in missing values for batches of 
observations.


{phang}{it:georoutei_options}{p_end}
{synoptline}
{phang}{opth hereid(string)}, {opth herecode(string)}, and {opth herekey(string)}
must be used to specify HERE credentials. Either both {opt hereid(string)} and 
{opt herecode(string)} must be specified, or {opt herekey(string)} alone must be specified. 

{phang}{opth startaddress(string)} and {opth endaddress(string)}
specify the addresses of the starting and ending points.
Alternatively, {cmd: startxy(}{it:#x},{it:#y}{cmd:)} and 
{cmd: endxy(}{it:#x},{it:#y}{cmd:)} can be used.
Either {opt startaddress} or {opt startxy} is required. 
Either {opt endaddress} or {opt endxy} is required. 

{phang}{cmd: startxy(}{it:#x},{it:#y}{cmd:)} and {cmd: endxy(}{it:#x},{it:#y}{cmd:)} 
specify the coordinates in decimal degrees of the starting and ending points. 
They can be used as an alternative to {opth startaddress(string)} and 
{opth endaddress(string)}. Coordinates (latitude and longitude) must be specified 
as two numbers separated by a comma.

{phang}{opt km} specifies that distances should be returned in kilometers. 
The default is to return distances in miles.


{title:Saved results}

{pstd}{cmd:georoutei} saves the following results in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(dist)}}Travel distance{p_end}
{synopt:{cmd:r(time)}}Travel time{p_end}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(start)}}Coordinates of starting point{p_end}
{synopt:{cmd:r(end)}}Coordinates of ending point{p_end}
{synoptset 15 tabbed}{...}



{title:Examples}

{pstd}Input some data{p_end}
{phang2}{cmd:. input str25 strt1 zip1 str15 city1 str11 cntry1}{p_end}
{phang2}{cmd:. "Rue de la Tambourine 17" 1227 "Carouge" "Switzerland"}{p_end}
{phang2}{cmd:. "" 1003 "Lausanne" "Switzerland"}{p_end}
{phang2}{cmd:. "" . "Paris" "France"}{p_end}
{phang2}{cmd:. "" 1003 "Lausanne" "Switzerland"}{p_end}
{phang2}{cmd:. end}{p_end}

{phang2}{cmd:. input str25 strt2 zip2 str15 city2 str11 cntry2}{p_end}
{phang2}{cmd:. "Rue Abram-Louis Breguet 2" 2000 "Neuchatel" "Switzerland"}{p_end}
{phang2}{cmd:. "" 74500 "Evian" "France"}{p_end}
{phang2}{cmd:. "" . "New York" "USA"}{p_end}
{phang2}{cmd:. "" 1203 "Geneva" "Switzerland"}{p_end}

{pstd}Compute travel distances and travel times (the user must replace hereid and herecode by information from his own account){p_end}
{phang2}{cmd:. georoute, hereid(BfSfwSlKMCPHj5WbVJ1g) herecode(bFw1UDZM3Zgc4QM8lyknVg) startad(strt1 zip1 city1 cntry1) endad(strt2 zip2 city2 cntry2) km di(dist) ti(time) co(p1 p2)}{p_end}

{pstd}Usage of the immediate command{p_end}
{phang2}{cmd:. georoutei, hereid(BfSfwSlKMCPHj5WbVJ1g) herecode(bFw1UDZM3Zgc4QM8lyknVg) startad(Rue de la Tambourine 17, 1227 Carouge, Switzerland) endad(Rue Abram-Louis Breguet 2, 2000 Neuchatel, Switzerland) km}{p_end}
{phang2}{cmd:. georoutei, herekey(0wxsecZz7uDgpLTMuO4ae19dPx0RwparL1U91yxQOVE) startxy(46.1761413,6.1393099) endxy(46.99382,6.94049) km}{p_end}


{title:Reference}

{pstd}
Weber S & Péclat M (2017): "A simple command to calculate travel distance and travel time", 
{it:Stata Journal}, {bf:17}(4): 962-971. {browse "https://www.stata-journal.com/article.html?article=dm0092"}


{title:Authors}

{pstd}
Sylvain Weber{break}
University of Neuchâtel{break}
Institute of Economic Research{break}
Neuchâtel, Switzerland{break}
{browse "mailto:sylvain.weber@unine.ch?subject=Question/remark about -georoute-&cc=martin.peclat@unine.ch":sylvain.weber@unine.ch}

{pstd}
Martin Péclat{break}
University of Neuchâtel{break}
Institute of Economic Research{break}
Neuchâtel, Switzerland{break}
{browse "mailto:martin.peclat@unine.ch?subject=Question/remark about -georoute-&cc=sylvain.weber@unine.ch":martin.peclat@unine.ch}
