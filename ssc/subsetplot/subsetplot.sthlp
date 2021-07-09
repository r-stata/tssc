{smcl}
{* 26sep2014/1oct2014}{...}
{hline}
help for {hi:subsetplot}
{hline}

{title:Plots for each subset with rest of the data as backdrop} 

{p 8 17 2} 
{cmd:subsetplot}
{it:command} 
{it:yvarlist}
{it:xvar} 
[{help if}] 
[{help in}]
{cmd:,}
{cmd:by(}{it:byvar}{cmd:)} 
[
{cmd:subset(}{it:twoway_options}{cmd:)}
{cmd:backdrop(}{it:twoway_command}{cmd:)}
{it:graph_options}
{cmd:ends}[{cmd:(}{it:graph_options}{cmd:)}] 
{cmdab:ext:remes}[{cmd:(}{it:graph_options}{cmd:)}] 
{cmd:combine(}{it:combine_options}{cmd:)} 
]


{title:Description} 

{p 4 4 2} 
{cmd:subsetplot} produces an array of {help scatter} or other 
{help twoway} plots for {it:yvarlist} versus {it:xvar} according to a
further variable {it:byvar}.  There is one plot for observations 
for each distinct subset
of {it:byvar} in which data for that subset are highlighted and the rest
of the data shown as backdrop.  Graphs are drawn individually and then
combined with {help graph combine}. 


{title:Remarks} 

{p 4 4 2}
This approach was discussed in Cox (2010). See also Schwabisch (2014)
for an example. Readers knowing interesting or useful examples or
discussions, especially early in date or comprehensive in detail, are
welcome to email the author. 


{title:Options}

{p 4 8 2}
{cmd:by()} specifies a numeric or string variable {it:byvar} defining
the distinct subsets being plotted. This is a required option. 

{p 4 8 2}
{cmd:subset(}{it:twoway_options}{cmd:)} specifies options of {help twoway} 
used to highlight observations in each distinct subset. 

{p 4 8 2}
{cmd:backdrop(}{it:command}{cmd:)} specifies a {help twoway} command to
show the rest of the data. This option is needed if and only if it is
desired to use a different command from that specified immediately after
the {cmd:subsetplot} command. 

{p 4 8 2} 
{it:graph_options} are options of {help twoway} used to display
observations for the rest of the data in each plot. 

{p 4 8 2}
{cmd:ends}[{cmd:(}{it:twoway_options}{cmd:)}] specifies that end values
(for the lowest and highest {it:x} value in each subset) be flagged
graphically. Options may be specified to tune how this is done. 

{p 4 8 2}
{cmd:extremes}[{cmd:(}{it:twoway_options}{cmd:)}] specifies that extreme
values (for the lowest and highest {it:y} value in each subset) be flagged
graphically. Options may be specified to tune how this is done. (Note:
if two or more variables are specified as {it:yvarlist}, only the first
variable is so treated.)  

{p 4 8 2}
{cmd:combine()} specifies options allowed with {help graph combine}. 


{title:Examples} 

{p 4 8 2}{cmd:. set scheme s1color}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. subsetplot scatter mpg weight, by(rep78)}{p_end}
{p 4 8 2}{cmd:. subsetplot scatter mpg weight, subset(ms(none) mla(rep78) mlabsize(*1.5) mlabpos(0) mlabcolor(blue)) by(rep78)}{p_end}

{p 4 8 2}{cmd:. webuse grunfeld}{p_end}
{p 4 8 2}{cmd:. subsetplot line invest year, by(company) ysc(log) yla(1 10 100 1000)}{p_end}
{p 4 8 2}{cmd:. gen invest2 = round(invest)}{p_end}
{p 4 8 2}{cmd:. subsetplot line invest year, by(company) ends(mla(invest2)) plotregion(margin(l+5 r+4)) combine(imargin(vsmall)) ysc(log) yla(1 10 100 1000)}{p_end}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgments}

{p 4 8 2}Stefan Gawrich reported a bug, on which Daniel Klein commented helpfully. 


{title:References} 

{p 4 8 2}
Cox, N.J. 2010. Graphing subsets. 
{it:Stata Journal} 10: 670{c -}681. 

{p 4 8 2}
Schwabish, J.A. 2014. An economist's guide to visualizing data.
{it:Journal of Economic Perspectives} 28: 209{c -}234.


{title:Also see}

{p 4 13 2}
On-line: help for {help twoway}, help for {help graph matrix}, 
help for {help graph combine}    

