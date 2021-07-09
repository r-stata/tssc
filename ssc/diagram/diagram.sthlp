{smcl}
{right:version 1.0.1}
{title:Title}

{phang}
{cmd:diagram} {hline 2} implements  {browse "http://www.graphviz.org/":Graphviz} in Stata and generates dynamic diagrams 
 using  {browse "http://en.wikipedia.org/wiki/Dot":DOT markup language} and 
 exports images in {bf:pdf}, {bf:png}, {bf:jpeg}, {bf:gif}, and {bf:bmp} format. 
 The package also includes several programs that generate automatic path diagrams. For 
 more information  {browse "http://www.haghish.com/diagram/diagram.php":visit diagram homepage}.
 

{title:Syntax}

{p 8 16 2}
{cmd: diagram} {{it:DOT} | {help using} {it:filename}} {cmd:,} {it:export(filename)} 
[{it:replace}  {it:magnify(real)} {it:phantomjs(str)} {it:engine(name)} ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt replace}}replace the exported diagram{p_end}
{synopt:{opt engine(name)}}specifies the    {break}
{browse "http://www.graphviz.org/Download.php":graphViz} engine for rendering the 
diagram which can be {bf:dot}, {bf:osage}, {bf:circo}, {bf:neato}, {bf:twopi} and {bf:fdp}. 
The default engine is {bf:dot} {p_end}
{synopt:{opt e:xport(filename)}}export the diagram. The file extension specifies the 
format and it can be {bf:.pdf}, {bf:.png}, {bf:.jpeg}, {bf:.gif}, or {bf:.bmp}{p_end}
{synopt:{opt mag:nify(real)}}increases the resolution of the exported image by multiplying its 
resolution to the specified number. The value of the real number should be above {bf:0} and 
by default is {bf:1.0}{p_end}
{synopt:{opt phantomjs(str)}}specifies the path to executable 
{browse "http://www.phantomjs.org/download.html":phantomjs software} on the machine{p_end}
{synoptline}
{p2colreset}{...}



{title:Example programs}

{p 4 4 2}
The package includes several example programs that generate DOT path diagrams 
that can be rendered using the {bf:diagram} command. These programs can be used to 
visualize a function call of an ado-program, generate path diagram from data set, 
and also create dynamic SEM models (prototype development). These example programs 
are documented in separate help files:

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr:Example program}
{synoptline}
{synopt:{help semdiagram}}draws dynamic SEM models{p_end}
{synopt:{help makediagram}}generates DOT path diagram from data set{p_end}
{synopt:{help calldiagram}}visualizes the function calls of an ado-program{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{p 4 4 2}
{bf:diagram} renders  {browse "http://www.graphviz.org/Download.php":graphViz} graphs 
within Stata and exports them to several graphical formats including {bf:pdf}, 
{bf:png}, {bf:jpeg}, {bf:gif}, and {bf:bmp}. This package is 
independent of the software and does not require installing graphViz. The {bf:diagram} 
command can render a graph using {it:DOT} markup or by using file that includes the 
markup. For large graphs, it is advices to create a file and then render the graph. 

{p 4 4 2}
{browse "http://www.graphviz.org/Download.php":graphViz} is an open source graph visualization 
software which can be used to represent structural information such as diagrams of 
algorithms, groups, abstract graphs, and networks. The software has had notable 
applications in a variety of fields such as network visualization, bioinformatics,    {break}
machine learning. The software renders graphics using a markup language which is 
highly customizable and can be altered with precision. Yet, it can be written in a 
very simple and basic way to make it human-readable. FOr more information regarding 
the software visit  {browse "http://www.graphviz.org/":graphViz homepage}. 

{p 4 4 2}
This package can have plenty of applications for Stata users. For example, it can 
be used to develop analysis diagrams, visualize information/algorithms, create 
diagrams for education purpose as well as write Stata programs that generate 
dynamic diagrams based on the results of data analysis. 



{title:Engines}

{p 4 4 2}
{browse "http://www.graphviz.org/Documentation/pdf/libguide.pdf":graphViz} has several engines which are {bf:dot}, 
{bf:neato}, {bf:fdp}, {bf:twopi}, {bf:circo}, and {bf:osage}. These engines render the 
diagrams differently but their markup is not identical. All of these engines are 
supported in this package but the user should read the engines carefully. 
The most popular engines are {bf:dot} and {bf:neato}. A brief description of the 
engines is presented below : 

{p 4 4 2}
{browse "http://www.graphviz.org/pdf/dot.1.pdf":dot} - "directed graphs" which is the 
default engine for rendering graphs where edges have directionality e.g. 
{bf:A -> B}.

{p 4 4 2}
{browse "http://www.graphviz.org/pdf/neatoguide.pdf":neato} is recommended for undirected diagrams, 
especially when the size of the diagram is about 100 nodes or less. 

{p 4 4 2}
{browse "http://www.graphviz.org/pdf/fdp.1.pdf":fdp} draws undirected graphs similar to 
{bf:neato}, but applies different layouts.

{p 4 4 2}
{browse "http://www.graphviz.org/pdf/twopi.1.pdf":twopi} applies radial layouts. 

{p 4 4 2}
{browse "http://www.graphviz.org/pdf/circo.1.pdf":circo} applies circular layouts.

{p 4 4 2}
{browse "http://www.graphviz.org/pdf/osage.1.pdf":osage} applies clustered layouts.



{title:Third-party software}

{p 4 4 2}
For exporting graphical files, the package requires  {browse "http://phantomjs.org/download.html":phantomJS}, 
which is an open-source freeware available for Windows, Mac, and Linux. The 
path to the executable {it:phantomjs} file is required in order to export the 
graphical files.    {break}



{title:Example(s)}

    rendering DOT markup
        . graphviz digraph G {a -> b;}, magnify(2.5) export(../diagram.png) 	///
          phantomjs("/usr/local/bin/phantomjs")

    rendering a graphviz file
        . graphviz using myfile.dot, magnify(2.5) export(../diagram.png) 	///
          phantomjs("/usr/local/bin/phantomjs")

		  

{title:Acknowledgements}

{p 4 4 2}
The JavaScript engine of the program was developed by 
{browse "https://www.github.com/mdaines":Michael Daines}.    {break}


{title:Author}

{p 4 4 2}
{bf:E. F. Haghish}       {break}
Center for Medical Biometry and Medical Informatics       {break}
University of Freiburg, Germany       {break}
{it:and}          {break}
Department of Mathematics and Computer Science         {break}
University of Southern Denmark       {break}
haghish@imbi.uni-freiburg.de       {break}

{p 4 4 2}
{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php":http://www.haghish.com/markdoc}           {break}
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter}    {break}

    {hline}

{p 4 4 2}
This help file was dynamically produced by {help markdoc:MarkDoc Literate Programming package}

