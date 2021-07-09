{smcl}
{* *! version 1.0.0 4apr2017}{...}
{vieweralsosee "geocode" "help geocode"}{...}
{vieweralsosee "traveltime" "help traveltime"}{...}
{vieweralsosee "geocodehere" "help geocodehere"}{...}
{vieweralsosee "geocodeopen" "help geocodeopen"}{...}
{vieweralsosee "geodist2" "help geodist2"}{...}
{vieweralsosee "georoute" "help georoute"}{...}
{title:Title}

{p2colset 5 19 22 2}{...}
{p2col :{cmd:geocode_ip} {hline 2}}Geocode IP addresses{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmd:geocode_ip}
{varname}
{ifin}{cmd:,}
{opt clear} {opth sleep(#)}]

{marker description}{...}
{title:Description}

{pstd}
{opt geocode_ip} takes a variable with IP addresses and
constructs several location variables (country, region, city, lat, lon, etc.),
using the API service from http://freegeoip.net

{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}
{opt clear}
    Required because this command will replace the current dataset.
    To add the data back in the original dataset,
    you can preserve it
    and then merge thew new dataset, as shown
    {browse "https://github.com/sergiocorreia/geocode_ip/blob/master/test.do":here}.

{phang}
{opt sleep(#)}
    How many seconds to wait before each call to the API. Default is 0.4s
    (consistent with the 150 requests per minute allowed by the API)


{marker author}{...}
{title:Author}

{pstd}Sergio Correia{break}
{browse "mailto:sergio.correia@gmail.com":sergio.correia@gmail.com}{break}
{p_end}


{title:More Information}

{pstd}{break}
To see examples, report bugs, contribute, ask for help, etc. please see the project URL in Github:{break}
{browse "https://github.com/sergiocorreia/geocode_ip"}{break}
{p_end}
