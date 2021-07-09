{smcl}
{* 16sep2009}{...}
{hline}
help for {hi:stata2pajek}
{hline}

{title:Export data to Pajek .net format} 

{p 8 17 2} 
{cmd:stata2pajek} {it:ego alter}[, {cmdab:edges tiestrength() filename()}]


{title:Description} 

{p 4 4 2} 
{cmd:stata2pajek} exports data to the ".net" format read by Pajek, Network
Workbench, and many other social network analysis packages.


{title:Remarks} 

{p 4 4 2}
The program assumes that you already have used Stata to create an edge list
or arc list. You specify which (string or numeric) variable identifies ego and 
which alter. Specifying a tie strength variable is optional. {cmd:stata2pajek} 
converts this to .net format, which is a Windows-formatted text file beginning 
with a list of vertices (aka nodes) and their labels, followed by a list of ties 
(arcs or edges).

{p 4 4 2}
As an alternative to this program, you may wish to use {cmd:outsheet} then 
process the saved output with the Windows program txt2pajek.

{p 4 4 2}
Note that {cmd:stata2pajek} treats the Stata versions of your id variables as 
labels even if they are numeric. Thus if you have a node called #15 in Stata
it will not necessarily also be called #15 in Pajek. Please see the vertice 
section of the .net file (which is human-readable text) to see the 
correspondence.

{title:Options} 
 
{p 4 8 2}
{cmd:edges} specifies that ties should be treated as edges (symmetrical ties).
The default is to treat ties as arcs (directed ties).

{p 4 8 2}
{cmd:filename()} allows you to name the output file. By default it is named 
mypajekfile.net

{title:Examples}

{p 4 8 2}{cmd:. *create a random network with 10 nodes and export it as pajek}{p_end}
{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. set obs 200}{p_end}
{p 4 8 2}{cmd:. gen i=int(uniform()*10)+1}{p_end}
{p 4 8 2}{cmd:. gen j=int(uniform()*10)+1}{p_end}
{p 4 8 2}{cmd:. contract i j, freq(strength)}{p_end}
{p 4 8 2}{cmd:. drop if i==j}{p_end}
{p 4 8 2}{cmd:. sort i j}{p_end}
{p 4 8 2}{cmd:. stata2pajek i j, tiestrength(strength) filename(samplerandomnetwork)}{p_end}


{title:Author}

{p 4 4 2}Gabriel Rossman, UCLA{break} 
rossman@soc.ucla.edu

{title:Also see}

{p 4 13 2}On-line:  
help for {help outsheet}

