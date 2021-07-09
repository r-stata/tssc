{smcl}
{title:Title}

{phang}
{cmd:semdiagram} {hline 2} executes {help sem} one-factor measurement model and produces  dynamic path diagram for 
 {browse "www.haghish.com/diagram/diagram.php":diagram} package
 

{title:Syntax}

{p 8 16 2}
{cmd: semdiagram} [:] {it:{help sem} or {help gsem} command} 
{p_end}


{title:Description}

{p 4 4 2}
The {bf:semdiagram} provides an "example" for generating dynamic path diagram, using 
Stata {bf:sem} command. It takes a Stata {bf:sem} or {bf:gsem} command and 
produces a dynamic path diagram. Currently, it is only supporting a 
{it:one-factor measurement model}. Similar to {bf:sem_} and {bf:gsem} commands, 
the path direction can be from right to left or left to write (see the example). 
{bf:semdiagram} produces a dynamic path diagram named {it:semdiagram.gv} that can be rendered 
and exported to a graphical file using {help diagram} package. 

{p 4 4 2}
This program was meant to be used as an example for automating path diagrams 
from Stata. If you wish to improve the program to support more sophisticated 
{bf:sem} models,  {browse "https://github.com/haghish/diagram":fork diagram package on GitHub}.


{title:Example(s)}

    Setup
        . webuse sem_1fmm

    A one-factor measurement model
        . semdiagram sem (X->x1) (X->x2) (X->x3) (X->x4)
		
    Or alternatively
        . semdiagram sem (x1<-X) (x2<-X) (x3<-X) (x4<-X)	
		
    semdiagram creates {it:semdiagram.gv} file which can be exported to a graphical image
        . diagram using semdiagram.gv, export(semdiagram.png)
		

{title:Stored results}

{p 4 4 2}
{bf:semdiagram} stores the SEM output in a matrix:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrix}{p_end}
{synopt:{cmd:r(table)}}results of the SEM command{p_end}


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
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter}      {break}

    {hline}

{p 4 4 2}
{it:This help file was dynamically produced by {browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}} 

