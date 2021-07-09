{smcl}
{* 16may2004/7sep2004/7jun2005/2jul2008/20aug2012/21sep2016}{...}
{hline}
help for {hi:mylabels} and {hi:myticks}
{hline}

{title:Axis labels or ticks on specified scales}

{p 8 17 2}
{cmd:mylabels}
{it:lbllist}
{cmd:,}
{cmdab:l:ocal(}{it:macname}{cmd:)}
[
{cmdab:my:scale(}{it:transformation_syntax}{cmd:)}
{cmdab:f:ormat(}{it:format}{cmd:)} 
{cmd:clean} 
{cmdab:pre:fix(}{it:text}{cmd:)} 
{cmdab:suf:fix(}{it:text}{cmd:)} 
]

{p 8 17 2}
{cmd:myticks}
{it:ticklist}
{cmd:,}
{cmdab:l:ocal(}{it:macname}{cmd:)}
[
{cmdab:my:scale(}{it:transformation_syntax}{cmd:)}
]
 

{title:Description}

{p 4 4 2}
{cmd:mylabels} and {cmd:myticks} generate axis labels and ticks on
specified scales. Their use is best explained by examples, as below.
Note that the label list {it:lbllist} and tick list {it:ticklist} will
be expanded if presented as legal {help numlist}s and left as specified
otherwise. 


{title:Remarks} 

{p 4 4 2}
You draw a graph and one axis is on a transformed square root scale.
You wish the axis labels to show untransformed values. For some values
this is easy; for example, {cmd:ylabel(0 1 2 "4" 3 "9" 4 "16" 5 "25")}
says use {cmd:"4"} as label for {cmd:2}, and so forth. For other values
and/or other transformations the conversion may be more difficult to do
in your head, so that a dedicated utility is helpful. 

{p 4 4 2}
The idea behind {cmd:mylabels} is that you feed it the labels (usually,
but not necessarily, numeric labels) that you want shown and the
transformation being used. It will then place the appropriate
specification in a local macro which you name. You may then use that
local macro as part of a later {cmd:graph} command. 

{p 4 4 2} 
So suppose that you want labels 0 1 4 9 16 25 36 49, and your data are 
square roots of these. Your call is 
{cmd:mylabels 0 1 4 9 16 25 36 49, myscale(sqrt(@)) local(labels)}. Or
suppose you want percents shown, and your data are proportions 0-1. Your
call is {cmd:mylabels 0(25)100, myscale(@/100) local(labels)}. Think of
this in the following way: my graph labels that I want are 0(25)100, but
my data scale is that of the labels divided by 100. 

{p 4 4 2}
For a more challenging example, see the graph on Gabriel Rossman's blog at 
{browse "http://codeandculture.wordpress.com/2010/02/08/memetracker-into-stata/":http://codeandculture.wordpress.com/2010/02/08/memetracker-into-stata/} 

{p 4 4 2}
Here the {it:x} axis variable is a date-time and the {it:x} axis labels
shown are nice numbers in terms of clock time in milliseconds but by any
other standard are arbitrary and awkward. The dates span a period in
late 2008 and early 2009, so monthly labels would seem more natural
(even though not regularly spaced in terms of clock time). An example is
then 
{cmd:mylabels "1 Aug 2008" "1 Sep 2008"  "1 Oct 2008"  "1 Nov 2008" "1 Dec 2008" "1 Jan 2009" "1 Feb 2009", myscale(clock("@", "DMY")) local(labels)}

{p 4 4 2} 
A similar idea may be used for axis ticks. 


{title:Options}

{p 4 8 2}
{cmd:local(}{it:macname}{cmd:)} inserts the option specification in
local macro {it:macname} within the calling program's space.  Hence that
macro will be accessible after {cmd:mylabels} or {cmd:myticks} has
finished. This is helpful for subsequent use with {help graph} or other
graphics commands. This is a required option. 

{p 4 8 2}
{cmd:myscale()} specifies the transformation used to produce the data
you have. Stata syntax should be used with {cmd:@} as placeholder for
original value. To show proportions as percents, specify
{cmd:myscale(@/100)}. If no transformation is being used, you may
specify {cmd:myscale(@)}, but that is also the default. 

{p 4 8 2}
{cmd:format()} specifies a format controlling the labels. This is an
occasionally specified option. Its main use is to enforce the
presentation of leading zeros. 

{p 4 8 2}
{cmd:clean} specifies a minimal format eliding trailing zeros and
decimal points (whether periods (stops) or commas). This option is most
often used together with {cmd:format()}. Thus by itself
{cmd:format(%03.2f)} would render 0(0.25)1 as 0.00 0.25 0.50 0.75 1.00
but {cmd:clean} reduces it to 0 0.25 0.5 0.75 1. 

{p 4 8 2}
{cmd:prefix()} specifies text to be prepended to all axis labels.
Specify any blank spaces within {cmd:" "}. 

{p 4 8 2}
{cmd:suffix()} specifies text to be appended to all axis labels. Specify
any blank spaces within {cmd:" "}. 


{title:Examples}

{p 4 8 2}{cmd:. webuse nlswork, clear }{p_end}
{p 4 8 2}{cmd:. spikeplot ln_wage, root}{p_end}
{p 4 8 2}{cmd:. mylabels 1 3 10 30 100 300, myscale(ln(@)) local(myxla)}{p_end}
{p 4 8 2}{cmd:. mylabels 0 25 100 225, myscale(sqrt(@)) local(myyla)}{p_end}
{p 4 8 2}{cmd:. spikeplot ln_wage, root xla(`myxla') yla(`myyla') ytitle(frequency (root scale)) xtitle(wage/GNP deflator (log scale)) xsc(titlegap(*5))}{p_end}

{p 4 8 2}{cmd:. sysuse auto, clear }{p_end}
{p 4 8 2}{cmd:. scatter mpg weight}{p_end}
{p 4 8 2}{cmd:. gen gpm = 1000/mpg}{p_end}
{p 4 8 2}{cmd:. mylabels 15(5)40, myscale(1000/@) local(myyla)}{p_end}
{p 4 8 2}{cmd:. sc gpm weight, yla(`myyla', ang(h)) ytitle(Miles per gallon (reciprocal scale))}{p_end}
{p 4 8 2}{cmd:. myticks 12/41, myscale(1000/@) local(myyti)}{p_end}
{p 4 8 2}{cmd:. sc gpm weight, yla(`myyla', ang(h)) ytitle(Miles per gallon (reciprocal scale)) ymtic(`myyti')}{p_end}

{p 4 8 2}{cmd:. mylabels 0(5)20, local(labels) myscale(@/100) suffix(" %")}{p_end}
{p 4 8 2}{cmd:. mylabels 0(5)20, local(labels) prefix($)}{p_end}

{p 4 8 2}{cmd:. mylabels 0(0.2)1, clean local(labels) }{p_end}
{p 4 8 2}{cmd:. mylabels 0(0.25)1, clean local(labels)}{p_end}
{p 4 8 2}{cmd:. mylabels -0.025(0.005)0.025, clean local(labels)}{p_end}
{p 4 8 2}{cmd:. mylabels 0.005(0.005)0.025, format(%04.3f) clean local(labels)}{p_end}

{p 4 8 2}{cmd:. su mpg}{p_end}
{p 4 8 2}{cmd:. mylabels -1/3, myscale(`r(mean)' + (@) * `r(sd)') local(labels)}{p_end}
{p 4 8 2}{cmd:. histogram mpg, xaxis(1 2) xla(`labels', axis(2) grid) xtitle(z scale, axis(2)) normal}{p_end}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}
The idea behind these programs may be traced to a program by Patrick
Royston (1996). A question from Richard Campbell led to the last example
above. A question from Clive Nicholas and a suggestion by Philippe van
Kerm led to a correction and further comments above. A question from
Richard Goldstein led to the {cmd:prefix()} and {cmd:suffix()} options.
An example on Gabriel Rossman's blog, as noted above, provided a
stimulus to generalise the program. A question from John Kim reminded me
of my frequent need to elide trailing zeros and decimal points when 
enforcing leading zeros. 
	

{title:References} 

{p 4 8 2}
Royston, P. 1996. 
Flexible axis scaling. 
{it:Stata Technical Bulletin} 34, 9-10 (and in {it:STB Reprints} 6, 34-36). 
Freely accessible at 
{browse "http://www.stata.com/products/stb/journals/stb34.pdf":http://www.stata.com/products/stb/journals/stb34.pdf}


{title:Also see}

{p 4 13 2}
Online:  help for {help axis_label_options}
{p_end}
