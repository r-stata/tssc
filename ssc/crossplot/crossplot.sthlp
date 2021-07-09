{smcl}
{* 23nov2004/11apr2014/26apr2014}{...}
{hline}
help for {hi:crossplot}
{hline}

{title:Scatter (or other twoway) plots for each y vs each x variable} 

{p 8 17 2} 
{cmd:crossplot}
({it:yvarlist})
({it:xvarlist}) 
[{it:weight}] 
[{help if}] 
[{help in}]
[
{cmd:,}
{cmd:allobs} 
{it:graph_options}
{cmdab:seq:uence(}{it:words_in_sequence}{cmd:)} 
{cmd:seqopts(}{it:option}{cmd:)} 
{cmd:combine(}{it:combine_options}{cmd:)} 
]

{p 8 17 2}
Weights are supported if and as allowed by the {cmd:twoway} plot requested. 


{title:Description} 

{p 4 4 2} 
{cmd:crossplot} produces an array of {help scatter} or other 
{help twoway} plots for {it:yvarlist} versus {it:xvarlist}.  There is
one plot for each {it:y} variable from {it:yvarlist} and each {it:x}
variable from {it:xvarlist}.  The name {cmd:crossplot} is intended to
signal cross-combination. Graphs are drawn individually and then
combined with {help graph combine}. 


{title:Remarks} 

{p 4 4 2}
The indicated syntax is {cmd:(}{it:yvarlist}{cmd:)}
{cmd:(}{it:xvarlist}{cmd:)}. 

{p 4 4 2}
The actual syntax is more indulgent.  The first token, a single variable
name or a wildcard varlist or a set of variable names in parentheses
{cmd:()}, is interpreted as {it:yvarlist}. Remaining variable names will
be interpreted as {it:xvarlist}, regardless of any parentheses. 

{p 4 4 2}
{it:yvarlist} and {it:xvarlist} are combined using all possible pairs 
with one {it:y} and one {it:x}, i.e.  as a Cartesian product. 

{p 4 4 2} 
A neat arrangement of the individual graphs is produced if the number of
{it:y} variables is equal to the number of {it:x} variables, or the
number of {it:y} variables is 1, or the number of {it:x} variables is 1.
Otherwise, use {cmd:combine()} to tune the number of rows or columns in
the table of graphs. 

{p 4 4 2}
This is a 2014 revision of {cmd:cpyxplot} (SSC) first made public in 1999. 

{p 4 4 2}
Tufte (1983, 1990) remains inspirational on the value of "small
multiples". Heiberger and Holland (2004, 2008) contain enthusiastic
advocacy of Cartesian products in statistical graphics. 

{p 4 4 2} 
See {cmd:combineplot} (SSC) for a more general command in this
territory. 


{title:Options}

{p 4 8 2}
{cmd:allobs} requests plotting of results on each graph for all possible
observations. The default is to show only observations for which all
{it:y} and all {it:x} variables are non-missing. 

{p 4 8 2}
{it:graph_options} are options allowed with {help scatter}.  

{p 8 8 2}
Particular attention is drawn to {help advanced_options:recast()}, which
specifies a {help twoway} plottype that may be used to plot some {it:y}
versus some {it:x}. Possibilities include {help twoway_line:line} and
{help twoway_connected:connected}. 

{p 4 8 2} 
{cmd:sequence()} specifies text to appear in sequence to act as captions
for each plot. For example, {cmd:seq(a b c d)} specifies that successive
graphs will be labelled {cmd:a}, {cmd:b}, {cmd:c} and {cmd:d}.  The
precise syntax is that successive {it:word}s of the argument will be
shown using the option 
{cmd:caption("}{it:word}{cmd:", pos(11) size(large))}. As usual in
Stata, binding in double quotes {cmd:" "} is stronger than separation by
spaces, so syntax such as 
{cmd:seq("first caption" "second caption" "third caption" "fourth caption")} 
would show text with embedded spaces. 

{p 4 8 2} 
{cmd:seqopts()} specifies modification of the default display for
{cmd:sequence()}. For example, {cmd:seqopts(caption(, color(red))}
changes the text colour to red. Note that substantial changes are likely
to require use of the Graph Editor or your own syntax. 

{p 4 8 2}
{cmd:combine()} specifies options allowed with {help graph combine}. 


{title:Examples} 

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. gen rt_mpg = sqrt(mpg)}{p_end}
{p 4 8 2}{cmd:. gen ln_mpg = ln(mpg)}{p_end}
{p 4 8 2}{cmd:. gen rec_mpg = 100/mpg}{p_end}
{p 4 8 2}{cmd:. crossplot (mpg rt_mpg ln_mpg rec_mpg) weight, combine(imargin(small))}

{p 4 8 2}{cmd:. use http://www.stata-press.com/data/r13/audiometric, clear}{p_end}
{p 4 8 2}{cmd:. crossplot (lft*) (rght*), jitter(1)}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}Rory Wolfe suggested the original problem.
         Phil Ender alerted me to a bug.
	 Pete Watt made a helpful suggestion. 

{p 4 4 2}I salute Burt S. Holland
(1946{c -}2010) and James Alexander Green (1926{c -}2014), from whose
excellent little book (Green 1965) I first learned of Cartesian products
and many other such standard beasts. 


{title:References} 

{p 4 8 2}
Green, J.A. 1965. 
{it:Sets and groups.} 
London: Routledge and Kegan Paul. 

{p 4 8 2}
Heiberger, R.M. and Holland, B. 2004. 
{it:Statistical analysis and data display: An intermediate course with examples in S-PLUS, R, and SAS.} 
New York: Springer. 

{p 4 8 2}
Heiberger, R.M. and Holland, B. 2008. 
Structured sets of graphs. 
In Chen, C., H{c a:}rdle, W. and Unwin, A. (Eds) 
{it:Handbook of data visualization.} 
Berlin: Springer, 415{c -}445. 

{p 4 8 2}
Tufte, E.R. 1983, 2nd edition 2001. 
{it:The visual display of quantitative information.} 
Cheshire, CT: Graphics Press. 

{p 4 8 2}
Tufte, E.R. 1990. 
{it:Envisioning information.} 
Cheshire, CT: Graphics Press. 


{title:Also see}

{p 4 13 2}
On-line: help for {help twoway}, help for {help graph matrix}, 
help for {help combineplot} (if installed from SSC),   
help for {help cpcorr} (if installed from SSC)  

