{smcl}
{* 28apr2014}{...}
{hline}
help for {hi:combineplot}
{hline}

{title:Combine similar univariate or bivariate plots for different variables} 

{p 8 17 2} 
{cmd:combineplot}
[{cmd:(}]{it:yvarlist}[{cmd:)}] 
[{cmd:(}][{it:xvarlist}][{cmd:)}] 
[{it:weight}] 
[{help if}] 
[{help in}]
{p_end}
{p 17 17 2} 
[
{cmd:,}
{cmd:allobs} 
{cmd:combine(}{it:combine_options}{cmd:)} 
{cmdab:seq:uence(}{it:words_in_sequence}{cmd:)} 
{cmd:seqopts(}{it:option}{cmd:)} 
]
{p_end}
{p 17 17 2} 
{cmd::} {it:command_pattern}
[ , {it:graph_options} ]


{p 8 17 2}
Weights are supported if and as allowed by the graphics command
requested. 


{title:Description} 

{p 4 4 2} 
{cmd:combineplot} produces an array of plots for each variable in
{it:yvarlist} combined, when specified, with each variable in
{it:xvarlist}.  A {it:command_pattern} must be specified for a graph
command (official or user-written) with rules that the text {cmd:@y}
refers to each {it:y} variable and any text {cmd:@x} refers to each
{it:x} variable. Reference to {cmd:@y} is compulsory, but reference to
{cmd:@x} is at choice.   


{title:Remarks} 

{p 4 4 2} 
The most general Stata recipe for combining several plots in one figure
is to produce the individual plots and then combine them using
{cmd:graph combine}. Many commands offer automation in  doing something
similar using {cmd:over()} or {cmd:by()} options or specific machinery
(e.g. {cmd:graph matrix}). The aim of {cmd:combineplot} is to give a
convenience command offering modest automation whenever each graph is of
the same kind and different plots are for different variables. 

{p 4 4 2}
The syntax is based on the following rules: 

{p 4 4 2}
Rule 1: A variable list without any parentheses is interpreted as
{it:yvarlist}.

{p 4 4 2}
Rule 2: Otherwise parentheses may indicate groupings into {it:yvarlist}
and {it:xvarlist}. The first token, a parenthesised variable list or a
single unparenthesised variable name, is treated as {it:yvarlist}. Any
remaining variables are treated as {it:xvarlist}.  Other parentheses may
be used at discretion but are ignored. 

{p 4 4 2}
Rule 3: The {it:command_pattern} must refer to {cmd:@y} as a placeholder
for the {it:y} variable name. 

{p 4 4 2}
Rule 4: The {it:command_pattern} may refer to {cmd:@x} as a placeholder
for the {it:x} variable name, in which case an {it:xvarlist} must be
specified. 

{p 4 4 2}
Rule 5: When both specified, {it:yvarlist} and {it:xvarlist} are
combined using all possible pairs with one {it:y} and one {it:x}, i.e.
as a Cartesian product. 

{p 4 4 2} 
{it:yvarlist} and {it:xvarlist} may each name a single variable, but if
both are single variable names you might as well produce your graph more
directly. That is to say, this will work:

{p 8 8 2}{cmd:. combineplot (mpg) (weight): scatter @y @x} 

{p 4 4 2}
However, that is no more than a long-winded way to do 

{p 8 8 2}{cmd:. scatter mpg weight} 

{p 4 4 2}
{it:yvarlist} and {it:xvarlist} may share variables or even be
identical. 

{p 4 4 2} 
A neat arrangement of the individual graphs is produced if the number of
{it:y} variables is equal to the number of {it:x} variables, or the
number of {it:y} variables is 1, or the number of {it:x} variables is 1.
Otherwise, use {cmd:combine()} to tune the number of rows or columns in
the table of graphs.  Recall that a total of 4, 9, 16, 25, ... graphs
permits a neat display that is 2 x 2, 3 x 3, 4 x 4, 5 x 5, .... 

{p 4 4 2}
This is a 2014 generalisation of {cmd:cpyxplot} (SSC), first made public
in 1999. 

{p 4 4 2}
Tufte (1983, 1990) remains inspirational on the value of "small
multiples". Heiberger and Holland (2004, 2008) contain enthusiastic
advocacy of Cartesian products in statistical graphics. 


{title:Options}

{p 4 8 2}
{cmd:allobs} requests plotting of results on each graph for all possible
observations. The default is to show only observations for which all
{it:y} and all {it:x} variables are non-missing. 

{p 4 8 2}
{cmd:combine()} specifies options allowed with {help graph combine}. 

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
{cmd:sequence()}. For example, {cmd:seqopts(caption(, color(red)))}
changes the text colour to red. Note that substantial changes are likely
to require use of the Graph Editor or writing your own program. 

{p 4 8 2}
{it:graph_options} are options allowed with whatever graph command is
specified. Options may refer to the current {it:y} variable and/or the
current {it:x} variable using the text {cmd:@y} and {cmd:@x}
respectively. 


{title:Examples} 

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. set scheme s1color}{p_end}

{p 4 8 2}{cmd:. combineplot mpg price weight headroom: graph box @y, over(rep78)}{p_end}
{p 4 8 2}{cmd:. combineplot mpg price weight headroom: dotplot @y, over(rep78)}{p_end}
{p 4 8 2}{cmd:. combineplot price mpg headroom-gear, combine(imargin(small)): histogram @y, freq yla(, ang(h))}{p_end}
{p 4 8 2}{cmd:. combineplot price mpg weight length: qnorm @y}{p_end}
{p 4 8 2}{cmd:. combineplot price (mpg weight length displacement): scatter @y @x || qfit @y @x, legend(off) ytitle("Price (USD)")}{p_end}
{p 4 8 2}{cmd:. combineplot (mpg price) (rep78 foreign), sequence(a b c d) seqopts(caption(, color(red))): graph box @y, over(@x)}{p_end}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}
Comments from Alfonso S{c a'}nchez-Pe{c n~}alver and Dirk Enzmann
stimulated development of the program in 2014. 

{p 4 4 2}
I salute Burt S. Holland (1946{c -}2010) and James Alexander Green
(1926{c -}2014), from whose excellent little book (Green 1965) I first
learned of Cartesian products and many other such standard beasts. 


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
help for {help crossplot} (if installed from SSC),   
help for {help cpcorr} (if installed from SSC), 
help for {help multqplot} (if installed from SJ)   

