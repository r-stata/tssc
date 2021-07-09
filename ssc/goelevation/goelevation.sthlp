{smcl}
{* *! version 8.0  23 Agust 2014}{...}


{viewerjumpto "Syntax" "goelevation##syntax"}{...}
{viewerjumpto "Description" "goelevation##description"}{...}
{viewerjumpto "Options" "goelevation##options"}{...}
{viewerjumpto "Examples" "goelevation##examples"}{...}

{cmd:help goelevation}
{hline}

{title:Title}

{phang}
{bf:goelevation} {hline 2} Elevation for langitude and longidute from google

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:goelevation}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt lat}} latitude variable. {p_end}
{synopt:{opt lng}} longitude variable. {p_end}
{synopt:{opt saving}} Save data in memory to file in Stata format. {p_end}
{synopt:{opt replace}} Replace current data set from elevation data.{p_end}
{synopt:{opt ptah}} Path from latitude and longitude.{p_end}
{synopt:{opt samples}} Number of sample points to mesaure elevation. Default size is 100.{p_end}
{synopt:{opt nograph}} Without drawing elevation profile graphs.{p_end}
{synopt:{opt map}} Map type to draw the path on google map. Default map is terrain map.{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:goelevation} The program can be used for two purposes. 1- If the location has gps codes from latitude and longitude this program will calculate the elevation for each point using google map data (API). 2. If two locations specify usign latitude and longitude this will calculate elevation for straight line between these two (or more than two) locations. This program has been tested with decimal degrees. 

Internet connection is necessary in order to run this program. User limitation and rectriction of the google map API 3 is avaiable at "https://developers.google.com/maps/documentation/elevation/"

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt lat}	- Latitude varaible should be specify when calculating elevation for location.

{phang}
{opt lng}	- Longitude varaible should be specify when calculating elevation for location.
  
{phang}
{opt saving}	- Saving option can be used to save the elevation data. Either saving or replace should be use in order to execute goelevation command.
 
{phang}
{opt replace}	- Replace option drop the current data and keep the elevation data on Stata. Either saving or replace should be use in order to execute goelevation command.
  
{phang}
{opt path}	- When calculating elevation for specific two location path should be specify. Path should be given in decimal degrees and it should be correct order(latitude,longitude) and separated by comma ",". Spaces does not allow anywhere in the path.
  
{phang}
{opt samples}	- Samples uses to indicate number of points for elevation between two locations. Default value is 100.

{phang}
{opt nograph}	- Nograph option ignore the elevation profile graphs.
    
{phang}
{opt map}	- User can define which type of map should be used to show the path on google map. The default map is terrain. Currently roadmap is support with this option.

{marker examples}{...}
{title:Examples}



{pstd}
1. To calculate elevation for a data file with gps locaitons: 

		clear
		{cmd:. set obs 3}
		{cmd:. gen latitude =.}
		{cmd:. gen longitude=.}
		{cmd:. replace latitude=6.925928 in 1}
		{cmd:. replace longitude=79.902935 in 1}
		{cmd:. replace latitude=7.307487 in 2}
		{cmd:. replace longitude=80.603313 in 2}
		{cmd:. replace latitude=7.292503 in 3}
		{cmd:. replace longitude=80.229778 in 3}
		{cmd:. list}
		{cmd:. goelevation, lat(latitude) lng(longitude) replace}
		{cmd:. list}


 	{cmd:. goelevation, lat(latitude) lng(longitude) replace}
	 {it:({stata "goelevation,example":click to run})}
	{* goelevation }{...}

 
2. To create elevation profile for two locations

{phang}{cmd:. goelevation,path(6.926014,79.850750|5.950742,80.532074) replace}
{it:({stata "goelevation,path(6.926014,79.850750|5.950742,80.532074)replace":click to run})}

3. To create elevation profile for 3 locations with sample points of 200

{phang}{cmd:. goelevation,path(45.420543,-75.709620|43.649001,-79.399679|51.085205,-114.082395)replace samples(200)map(roadmap)}
{it:({stata "goelevation,path(45.420543,-75.709620|43.649001,-79.399679|51.085205,-114.082395)replace samples(200)map(roadmap)":click to run})}

{title:Authors}
{p 4 4 2}
K. Chamara Anuranga {break}
Institute for Health Policy {break}
Sri Lanka {break}
 
{p 4 4 2}
J.V. Jayanthan {break}
University of Calgary {break}
Canada {break}
jvjayant@gmail.com{p_end}



 
