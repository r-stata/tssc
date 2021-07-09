{smcl}
{* 20sep2011}{...}
{cmd:help writekml}{right:}
{hline}

{title:Title}

{p 4 4 2}{hi:writekml} {hline 2} Keyhole Markup Language file writer


{title:Syntax}

{p 8 17 2}
{cmd:writekml}{cmd:,}
{cmd:filename(}{it:string}{cmd:)}
{cmd:plcategory(}{it:varname string}{cmd:)}
[{cmd:plname(}{it:varname string}{cmd:)}
{cmd:pldesc(}{it:varname string}{cmd:)}]


 
{title:Description} 

{p 4 4 2} {cmd:writekml} takes latitude and longitude information from a data set in memory and writes a KML file in the current working directory.


{title:Options}

{phang} {cmd:filename(}{it:string}{cmd:)} is the name of the KML file to be written. If it already exists, it will be replaced.

{phang} {cmd:plcategory(}{it:varname string}{cmd:)} is the name of the variable that groups the places being mapped. Each group is mapped with paddles (flags) of the same color. The Google Maps API makes available eight colors. Trying to map more groups will return an error message.

{phang} {cmd:plname(}{it:varname string}{cmd:)} is the name of the variable that stores the names of the places being mapped. These names will show up in bold black letters on the list next to the Google map that the KML file renders.

{phang} {cmd:pldesc(}{it:varname string}{cmd:)} is the name of the variable that stores descriptions of the places being mapped. The descriptions will show up in smaller, lighter-colored type below the place names in the list.


{marker remarks}{...}
{title:Remarks}

{pstd}{cmd:writekml} expects latitude and longitude to be present in the data set as numeric variables with the same names.{p_end}
{pstd}If place names or descriptions are missing {cmd:writekml} will fill in the category name instead.{p_end}
{pstd}The easiest way to associate latitude and longitude information with a data set of physical addresses is to run {helpb geocode} (if installed) before running {cmd:writekml}.{p_end} 


{title:Example}

{p 4 8 2}{cmd:. writekml, filename(kmlout) plname(name) pldesc(description) plcategory(kind)}{p_end} 


{title:Acknowledgements}

{pstd}Adam Ozimek and Daniel Miles, the authors of {cmd: geocode}, inspired this.{p_end}


{title:Author}

{pstd}Gabi Huiber{p_end}
{pstd}Durham, NC USA{p_end}
{pstd}ghuiber@gmail.com{p_end}


{title:Also see}  

{p 4 14 2}
The article that introduced {cmd: geocode}:  {it:Stata Journal}, volume 11, number 1: {browse "http://www.stata-journal.com/article.html?article=dm0053":dm0053}
{p_end}
{p 4 14 2}
The {browse "http://code.google.com/apis/kml/documentation/mapsSupport.html":KML documentation}
{p_end}
