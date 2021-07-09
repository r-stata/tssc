{smcl}
{hline}
help for {hi:himap}{right:(Thomas Roca)}
{hline}

{title:Create heatmaps using highmap's library}

{title:Syntax}
{p 8 17 2} {cmdab:himap} [ {it:varlist} iso3 time_id] 
{cmd:using} {it:filename}
[ {cmd:,} {it:options} ]

{title:Description}

{p 4 4 2}
{cmd:himap} creates heatmaps for the web, using java api developped by highcharts (see:{browse "http://www.highcharts.com/": http://www.highcharts.com/})

To be displayed, the webpage needs to find in its folder, 13 java scripts, these are provided locally, but are also available online:
1. "jquery-1.9.1.js" 		{browse "http://code.jquery.com/jquery-1.9.1.js": http://code.jquery.com/jquery-1.9.1.js}  
2. "highmaps.js" 		{browse "http://code.highcharts.com/maps/highmaps.js" : http://code.highcharts.com/maps/highmaps.js}
3. "exporting.js" 		{browse "http://code.highcharts.com/maps/modules/exporting.js" : http://code.highcharts.com/maps/modules/exporting.js}
4. "world-highres.js"		{browse "http://code.highcharts.com/mapdata/custom/world-highres.js": http://code.highcharts.com/mapdata/custom/world-highres.js}
5. "world-eckert3-highres.js"	{browse "http://code.highcharts.com/mapdata/custom/world-eckert3-highres.js": http://code.highcharts.com/mapdata/custom/world-eckert3-highres.js}
6. "world-robinson-highres.js"	{browse "http://code.highcharts.com/mapdata/custom/world-robinson-highres.js": http://code.highcharts.com/mapdata/custom/world-robinson-highres.js}
7. "africa.js"			{browse "http://code.highcharts.com/mapdata/custom/africa.js": http://code.highcharts.com/mapdata/custom/africa.js}  
8. "asia.js" 			{browse "http://code.highcharts.com/mapdata/custom/asia.js" : http://code.highcharts.com/mapdata/custom/asia.js}
9. "europ.js" 			{browse "http://code.highcharts.com/mapdata/custom/europe.js" : http://code.highcharts.com/mapdata/custom/europe.js}
10. "middle-east.js"		{browse "http://code.highcharts.com/mapdata/custom/middle-east.js": http://code.highcharts.com/mapdata/custom/middle-east.js}
11. "north-america.js"		{browse "http://code.highcharts.com/mapdata/custom/north-ameria.js": http://code.highcharts.com/mapdata/custom/north-ameria.js}
12. "oceania.js"		{browse "http://code.highcharts.com/mapdata/custom/oceania.js": http://code.highcharts.com/mapdata/custom/oceania.js}
13. "south-america"		{browse "http://code.highcharts.com/mapdata/custom/south-america.js": http://code.highcharts.com/mapdata/custom/south-america.js}  

The program will create a folder in the present working directory, containing:
1. The heatmap (HTML) and a copy of the  java files needed included in "himap.zip"
2. A dataset under json format, that will feed the HTML file
All the content of  "himap.zip" must be unzipped in the ado directory. The program will copy the java files from the ado directory.
The ado files comes with a folder name "himap_js", this folder must be located in your ado directory, in the same directory as himap.ado
NB. Do not copy himap.ado into himap folder, leave it at the root, e.g. C:\ado\plus\h 
NB. This programme might not work correctly under unix or mac os. I'm currently working on it, thanks for your comprehension.

The variable to map must be numeric. A country identifier variable must exist in the dataset and contains country ISO 3166-1 alpha-3 codes.
For more information about iso 3166-1 aplpha-3 codes, see: {browse "http://en.wikipedia.org/wiki/ISO_3166-1_alpha-3":http://en.wikipedia.org/wiki/ISO_3166-1_alpha-3}
3 types of earth projection are available: 'world': Natural earth (default option); 'eckert' : Eckart III ; 'robinson' : Robinson.
NB. Note that if the option 'zone' is specified, the option 'projection' will not be implemented even if specified.

    {it:options}{col 38}alternatives
    {hline 160}
  	{cmdab:time}{cmd:(integer)}{col 38}Time (j) of the variable to display {col 140}->[default: 2000]
	{cmdab:width}{cmd:(integer)}{col 38}Width of the map, expressed in pixel{col 140}->[default: 1000]	
	{cmdab:height}{cmd:(integer)}{col 38}Height of the map, expressed in pixel{col 140}->[default: 600]
	{cmdab:projection}{cmd:(string)}{col 38}Projection type: eckert ; robinson ; world {col 140}->[default: world:natural earth]
	{cmdab:zone}{cmd:(integer)}{col 38}0=World |1=Africa |2=Asia |3=Europe |4=Middle-east |5=North-America |6=Oceania |7=South-America{col 140}->[default: world:natural earth]
	{cmdab:rgb1}{cmd:(string)}{col 38}Set color for minimum value in rgb color {col 140}->[default: no ]
	{cmdab:rgb2}{cmd:(string)}{col 38}Set color for maximum value in rgb color{col 140}->[default: no ]
	
	
{title:Examples}
{p}

{p 4 8 2}{cmd:. himap gdp iso3 year using map.html, time(2013)}{p_end}
{p 4 8 2}{cmd:. himap gdp country_iso3 year using map.html, time(2005)}{p_end}
{p 4 8 2}{cmd:. himap gdp country_iso3 year using map.html, time(1990) width(800) height(500)}{p_end}
{p 4 8 2}{cmd:. himap gdp country_iso3 year using map.html, time(1960) projection(robinson)}{p_end}
{p 4 8 2}{cmd:. himap gdp country_iso3 year using map.html, time(2013) zone(1)}{p_end}
{p 4 8 2}{cmd:. himap gdp iso3 year using map.html, time(2012) projection(eckert)  rgb1(255, 225, 104) rgb2(221, 147, 0) }{p_end}

{title:Acknowledgements}

{p}
Note that I'm not the developper of the java engine, I adapted it and integrated it into a stata command.
The primary code was developped by highchart under a Creative Commons Attribution-NonCommercial 3.0 License for non commercial use.
For more information see: {browse "http://shop.highsoft.com/faq": http://shop.highsoft.com/faq}
For more information on the underneath html and java code see: {browse "http://www.highcharts.com/maps/demo/tooltip":http://www.highcharts.com/maps/demo/tooltip}

{title:Author}

{p}
Thomas Roca,PhD, Research department, Agence Française de Développement(AFD), France.
Email:{browse "mailto:rocat@afd.fr":rocat@afd.fr}
{p_end}
