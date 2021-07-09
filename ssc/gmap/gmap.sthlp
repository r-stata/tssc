{smcl}
{* September 2014}{...}
{hline}
help for {hi:gmap}{right:(Thomas Roca)}
{hline}

{title:Create heatmaps using google geochart's api}

{title:Syntax}
{p 8 17 2} {cmdab:gmap} [ {it:varlist} iso3 time_id]  ] 
{cmd:using} {it:filename}
[ {cmd:,} {it:options} ]

{title:Description}

{p 4 4 2}
{cmd:gmap} creates heatmaps for the web, using java api developped by google (see:{browse "https://developers.google.com/chart/interactive/docs/gallery/geochart": https://developers.google.com/chart/interactive/docs/gallery/geochart/})

To be displayed, the webpage needs to find in its folder, 2 java scripts:
1. "jaspi" available at {browse "https://www.google.com/jsapi":https://www.google.com/jsapi}
2. "jquery-latest.js" available at: {browse "http://code.jquery.com/jquery-latest.js":http://code.jquery.com/jquery-latest.js}
NB. Make sure the using name is different from one map to another in the same folder if not the first page will be displayed instead of the freshly created.

The program will create a folder in the present working directory, containing: 1.the heatmap (HTML) and a copy of the two java files needed ("jsapi" & "jquery-latest.js" ) included in "gmap.zip"
Thus, all the content of  "gmap.zip" must be unzipped in the ado directory. The program will copy the java files from the ado directory.
NB. This programme should work under unix or mac os, contact me otherwise.

The variable to map must be numeric. A country identifier variable must exist in the dataset; this variable must be named "iso3" and contains country ISO 3166-1 alpha-3 codes.
For more information about iso 3166-1 aplpha-3 codes, see: {browse "http://en.wikipedia.org/wiki/ISO_3166-1_alpha-3":http://en.wikipedia.org/wiki/ISO_3166-1_alpha-3}

    {it:options}{col 38}alternatives
    {hline 160}
    {cmdab:zone}{cmd:(integer)}{col 38}0=World| 1=Europe| 2=North America| 3=South America| 4=Africa| 5=Asia| 6=Asia Pacific| 7=Oceania|{col 140}->[default: World]
	{cmdab:time}{cmd:(integer)}{col 38}Mandatory value of your j variable (year, etc.){col 140}->[default: 2000]
	{cmdab:color}{cmd:(integer)}{col 38}1=Blue | 2=Green | 3=Purple | 4=Yellow {col 140}->[default: Blue]
	{cmdab:color1_rgb}{cmd:(string)}{col 38}Custom color for minimum value: r,g,b  {col 140}->[default: Blue]
	{cmdab:color2_rgb}{cmd:(string)}{col 38}Custom color for maximum value: r,g,b {col 140}->[default: Blue]
	{cmdab:width}{cmd:(integer)}{col 38}Width of the map, expressed in pixel{col 140}->[default: 850]	
	{cmdab:height}{cmd:(integer)}{col 38}Height of the map, expressed in pixel{col 140}->[default: 700]
	{cmdab:title}{cmd:(string)}{col 38}Title of the map{col 140}->[default: "a stata command"]
	{cmdab:legend}{cmd:(string)}{col 38}yes|no{col 140}->[default: no]
	  
{title:Examples}
{p}

{p 4 8 2}{cmd:. gmap gdp iso3 year using map.html, time(2013)}{p_end}
{p 4 8 2}{cmd:. gmap myvar country_iso year using map.html, time(1990)}{p_end}
{p 4 8 2}{cmd:. gmap gdp country_iso year using map.html, time(1995) width(800) height(500)}{p_end}
{p 4 8 2}{cmd:. gmap gdp country_iso year using map.html, time(2000) zone(6) color(3) }{p_end}
{p 4 8 2}{cmd:. gmap gdp country_iso year using map.html, time(2000) color1_rgb(120,165,90) color2_rgb(210,120,169) }{p_end}
{p 4 8 2}{cmd:. gmap gdp country_iso year using map.html, time(2010) color(2) legend(yes) title(my map)}{p_end}

{title:Acknowledgements}

{p}
For more information on the underneath html and java code see: {browse "https://developers.google.com/chart/interactive/docs/gallery/geochart":https://developers.google.com/chart/interactive/docs/gallery/geochart}

{title:Author}

{p}
Thomas Roca,PhD, Research department, Agence Française de Développement(AFD), France.
Email:{browse "mailto:rocat@afd.fr":rocat@afd.fr}
{p_end}
