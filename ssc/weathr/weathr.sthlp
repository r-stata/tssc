{smcl}
{* *! version 1.0.0  01jan2011}{...}
{cmd:help weathr}
{hline}

{title:Title}

{phang}
{bf:weather} {hline 2} Weather conditions from weather.com


{title:Syntax}

{p 8 17 2}
{cmdab:weathr}
[zipcode(s)]

{title:Description}

{pstd}
{cmd:weathr} retrieves the current weather conditions and the forecast for the next 36 hours from yahoo.com for one or more US zipcodes. It requires a connection to the internet.

{title:Remarks}

{pstd}
If you define a global macro weathrzipcode with one or more zipcodes, seperated by spaces, you need not enter anything after {cmd:weathr}. Note that weathrzipcode, like {cmd:weathr}, is missing an e. A convienent place to define $weathrzipcode is in your profile.do. 

{title:Examples}

{p 8 12}{stata "weathr 27599" :. weathr 27599} {p_end}

{p 8 12}{stata "weathr 77845 27513 60606" :. weathr 77845 27513 60606} {p_end}

{p 8 12}{stata "global weathrzipcode 90210" :. global weathrzipcode 90210} {p_end}

{p 8 12}{stata "weathr" :. weathr} {p_end}


{title:Author}

{p 0 4} Neal Caren (neal.caren@unc.edu) University of North Carolina, Chapel Hill
