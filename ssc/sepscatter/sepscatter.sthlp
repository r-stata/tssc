{smcl}
{* 29apr2014/9may2014/10dec2018}{...}
{hline}
help for {hi:sepscatter}
{hline}

{title:Scatter (or other twoway) plots separated by a third variable} 

{p 8 17 2} 
{cmd:sepscatter}
{it:yvar}
{it:xvar} 
[{it:weight}] 
[{help if}] 
[{help in}]
{cmd:,}
{cmdab:sep:arate(}{it:varname}{cmd:)} 
[
{cmdab:miss:ing} 
{c -(} 
{cmdab:myla:bel(}{it:varname}{cmd:)}
{c |} 
{cmdab:mynu:meric(}{it:varname}{cmd:)}
{c )-} 
{it:graph_options}
]

{p 8 17 2}
Weights are supported if and as allowed by the {cmd:twoway} plot requested. 


{title:Description} 

{p 4 4 2} 
{cmd:sepscatter} produces a {help scatter} or other {help twoway} plot
for {it:yvar} versus {it:xvar}.  Points, or as recast lines, are
portrayed separately according to the distinct values of a third
variable, which must be specified through the {cmd:separate()} option. 


{title:Options}

{p 4 8 2}
{cmd:separate()} specifies a variable used to classify points or lines
on the plot. Typically, the variable consists of two or more categories,
and points or lines will be shown distinctly according to those
categories, say by using different markers. The default is to show only
observations for which the variable specified is non-missing. This is a
required option. 

{p 4 8 2}
{cmd:missing} specifies that observations that are missing on the
variable specified in {cmd:separate()} should be included in the plot. 

{p 4 8 2}
{cmd:mylabel()} specifies a variable which will be used for marker
labels for each category shown. Commonly, this will be the variable
itself. For example, showing distinct values 1 to 5 may be preferred to
showing arbitrary markers representing 1 to 5. With this option marker
symbols themselves will be suppressed. Alternatively, you may wish to 
use a variable created for the purpose. 

{p 4 8 2}
{cmd:mynumeric()} specifies a variable which will be used for marker
labels for each category shown. Commonly, this will be the variable
itself. For example, showing distinct values 1 to 5 may be preferred to
showing arbitrary markers representing 1 to 5. With this option marker
symbols themselves will be suppressed. Alternatively, you may wish to 
use a variable created for the purpose. This option resembles {cmd:mylabel()} 
but differs in insisting that any value labels of a numeric variable be
ignored and the numeric values be used instead. Thus with the {cmd:foreign}
variable of the auto dataset, the value labels "Domestic" and "Foreign" would 
be informative, but create a messy graph with much overlap. 
{cmd:mynumeric(foreign)} would insist that the underlying numeric values be
shown, in this case 0 and 1. 

{p 8 8 2}
Only one of {cmd:mylabel()} and {cmd:mynumeric()} may be specified. 

{p 4 8 2}
{it:graph_options} are options allowed with {help scatter}.  
Note in particular that {cmd:addplot()} is supported. 

{p 8 8 2}
Particular attention is drawn to {help advanced_options:recast()}, which
specifies a {help twoway} plottype that may be used to plot some {it:yvar}
versus some {it:xvar}. Possibilities include {help twoway_line:line} and
{help twoway_connected:connected}. 


{title:Examples} 

{p 4 8 2}{cmd:. sysuse auto, clear}

{p 4 8 2}{cmd:. sepscatter mpg weight, separate(foreign)}{p_end}
{p 4 8 2}{cmd:. gen myforeign = substr("df", foreign + 1, 1)}{p_end}
{p 4 8 2}{cmd:. sepscatter mpg weight, separate(foreign) mylabel(myforeign)}{p_end}
{p 4 8 2}{cmd:. sepscatter mpg weight, separate(foreign) mynumeric(myforeign)}{p_end}

{p 4 8 2}{cmd:. sepscatter mpg weight, separate(rep78) mylabel(rep78)}{p_end}
{p 4 8 2}{cmd:. sepscatter mpg weight, separate(rep78) missing legend(ring(0) pos(1) col(1))}{p_end}

{p 4 8 2}{cmd:. webuse grunfeld, clear}{p_end}
{p 4 8 2}{cmd:. sepscatter mvalue time, separate(company) recast(connect) ysc(log) yla(5000 2000 1000 500 200 100)  legend(pos(3) col(1))}{p_end}
{p 4 8 2}{cmd:. sepscatter mvalue time, separate(company) recast(connect) ysc(log) yla(5000 2000 1000 500 200 100)  legend(pos(3) col(1))} 


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgments}

{p 4 4 2}Vince Wiggins suggested adding {cmd:recast()} examples to the help and flagged a small bug. 
Alfonso S{c a'}nchez-Pe{c n~}alver posed the problem addressed by the 
{cmd:mynumeric()} option. 


{title:References} 

{p 4 8 2}
Cox, N.J. 2005.
Classifying data points on scatter plots. 
{it:Stata Journal} 5: 604{c -}606.   
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=gr0023":http://www.stata-journal.com/sjpdf.html?articlenum=gr0023}


{title:Also see}

{p 4 13 2}
On-line: help for {help scatter}, help for {help twoway}

