{smcl}
{hline}
help for {hi:scatter3D}{right:(Thomas Roca)}
{hline}

{title:Create 3D scatter plots using HTML5 and CanvasXpress's API}

{title:Syntax}
{p 8 17 2} {cmdab:scatter3D} [ {it:varlist} id ] {cmd:using} {it:filename}
[ {cmd:,} {it:options} ]

{title:Description}

{p 4 4 2}
{cmd:scatter3D} creates 3D scatter plots for the web, using HTML5 3D feature and java api developped by CanvasXpress (see:{browse "http://canvasxpress.org/": http://canvasxpress.org/})

This chart uses HTML5 canvas technology, thus, your web browser needs to embed HTML5 (all updated ones do). 
To be displayed the charts needs several files (images and java). The ado files comes with a folder name "scatter3D",
this folder must be located in your ado directory, in the same directory as scatter3D.ado (NB. Do not copy scatter3D.ado into scatter3D folder, leave it at the root, e.g. C:\ado\plus\s ) 

Executing scatter3D command, a folder will be created in your working directory, containing two subfolders to host the needed files to display the chart (java and images for the menu.
The resulting chart will be a dynamic html file using 3D engine. NB. The copy command might not work correctly under unix or mac os. I'm currently working on it, thanks for your comprehension.

To execute the command 4 variables are required, the first 3 will be displayed on axis X, Y, Z. 
The last one will be use as an identifier (i) (e.g individual id, country names, etc.) to display information rolling the mouse over a dot.
Scatter3D will use variable label if any. Note that the graph won't display if special characters are used in the label or in the variable name especially quote (') and double quote (").

    {it:options}{col 38}alternatives
    {hline 160}
	{cmdab:width}{cmd:(integer)}{col 38}Width of the map, expressed in pixel{col 140}->[default: 850]	
	{cmdab:height}{cmd:(integer)}{col 38}Height of the map, expressed in pixel{col 140}->[default: 700]
	  
{title:Examples}
{p}

{p 4 8 2}{cmd:. scatter3D gdp income inflation country using scatter.html}{p_end}
{p 4 8 2}{cmd:. scatter3D myvar1 myvar2 myvar3 id using scatter.html, width(1000) height(900)}{p_end}

{title:Acknowledgements}

{p 4 4 2}
Note that I'm not the developper of the java engine and 3D solution, I adapted it and integrated it into a Stata command to take benefit of Stata's great possibilities in data management and parsing. 
The primary code was developped by CanvasXpress under a GNU licence Open Source GPL version 3.0.
For more information on the underneath html and java code see: {browse "http://canvasxpress.org/":http://canvasxpress.org/}


{title:Author}

{p}
Thomas Roca,PhD, Research department, Agence Française de Développement(AFD), France.
Email:{browse "mailto:rocat@afd.fr":rocat@afd.fr}
{p_end}
