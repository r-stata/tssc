{smcl}
{* 1february2011/10aug2012/3sep2013}{...}
{hline}
help for {hi:devnplot}
{hline}

{title:Deviation plots} 

{p 8 17 2} 
{cmd:devnplot} 
{it: yvar}
[{it:x1var} [{it:x2var}]] 
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]

{p 17 17 2}
[{cmd:,}
{cmd:overall}
{cmd:level(}{it:exp}{cmd:)} 
{cmd:sort(}{it:varlist}{cmd:)} 
{cmdab:desc:ending} 
{cmdab:miss:ing} 

{p 17 17 2} 
{cmd:separate(}{it:true_or_false_condition}{cmd:)} 
{cmd:separateopts(}{it:scatter_options}{cmd:)} 

{p 17 17 2}
{cmd:plines}[{cmd:(}{it:added_line_options}{cmd:)}] 
{cmd:superplines}[{cmd:(}{it:added_line_options}{cmd:)}] 
{cmd:pgap(}{it:#}{cmd:)} 
{cmd:superpgap(}{it:#}{cmd:)} 

{p 17 17 2} 
{cmd:lineopts(}{it:line_options}{cmd:)} 
{cmd:rspikeopts(}{it:rspike_options}{cmd:)} 
{cmd:clean}

{p 17 17 2}
{it:scatter_options} 
] 


{title:Description}

{p 4 4 2}
{cmd:devnplot} by default plots the values of numeric variable {it:yvar}
as deviations from the mean in increasing order. That is, each deviation
is represented as a vertical spike with base given by the mean and with
a marker symbol showing the value relative to a vertical scale.

{p 4 4 2}
If one or both of {it:x1var} and {it:x2var} is also specified,
observations are grouped by values of {it:x1var} (and {it:x2var} when
specified). Deviations are plotted from the means of {it:yvar} for each
distinct group so defined, unless the option {cmd:overall} is also
specified. Such distinct groups are considered to define distinct
"panels".  If both {it:x1var} and {it:x2var} are specified, distinct
groups defined by values of {it:x1var} are also considered to define
distinct "superpanels". 

{p 4 4 2}
Further variations from the basic design may be obtained by particular
option choices.


{title:Remarks}

{p 4 4 2}
The immediate stimulus for this program was provided by Whitlock and
Schluter (2009, pp.396, 519). Further similar examples are given by
Grafen and Hails (2002, pp.4{c -}7).  Among antecedents, note various
graphs in Pearson (1956) and the graph of Fisher (1925, Figure 3 and
p.35) combining a quantile plot of rainfall and a plot of wheat yield
versus the rank order of the corresponding rainfall. Not every graph
needs a distinct name, but every Stata command does. "Deviation plot" is
the author's suggestion. 

{p 4 4 2}
A related plot, which seems especially popular in clinical oncology, is 
the waterfall plot (or waterfall chart). Common examples show variations
in change in tumour dimensions during clinical trials. 
{cmd:desc rspikeopts(recast(bar) base(0)) ms(none ..)} would be typical 
option choices. See (e.g.) Gilder (2012). Note, however, that waterfall plots
or charts also refer to at least two quite different plots in business and
in the analysis of spectra. 

{p 4 4 2}
{it:x1var} and {it:x2var} may be numeric or string. In either case,
missing values are ignored unless the {cmd:missing} option is specified.
In either case, variables are treated as categorical. 

{p 4 4 2}
Note that the values of {it:yvar} are plotted as separate variables if
any other variable is specified. This allows the use of (e.g.) different
marker symbols and colours if so desired. The default is to use the same
marker symbol and colour, and where specified the same line colour, but
those choices can be overridden. If you wish to show a particular group
distinctively, that may be easiest to achieve using the Graph Editor. 

{p 4 4 2}
Some may find this a helpful plot for thinking about one-way or two-way
analysis of variance. 

{p 4 4 2}
This plot is intended to work well with very different group numbers. 

{p 4 4 2}
{cmd:devnplot} is not designed to show scatter plots with regression
lines for two measured variables with data points represented as
deviations. For that problem, try code such as 

{p 4 8 2}{cmd:. regress y x}{p_end}
{p 4 8 2}{cmd:. predict predict}{p_end}
{p 4 8 2}{cmd:. scatter y x || rspike y predict x || line predict x, sort ytitle("`: var label y'") legend(off)} 


{title:Options} 

{p 4 4 2}{it:What is to be plotted} 

{p 4 8 2}
{cmd:overall} specifies that deviations are shown from the overall mean,
regardless of any specification of {it:x1var} or {it:x2var}. 

{p 4 8 2}
{cmd:level(}{it:exp}{cmd:)} allows the use of any expression to define
reference levels, rather than means. Commonly, but not necessarily, the
expression will be either a numeric constant or a variable name. It need
not be constant in value, even within groups of {it:x1var} and/or
{it:x2var}. 

{p 4 8 2} 
{cmd:sort(}{it:varlist}{cmd:)} specifies that values are to be sorted on
{it:varlist} rather than {it:yvar}. Usually, but not necessarily, 
{it:varlist} is a single {it:varname}. As a special case, {cmd:_n} may be
specified to insist on respecting current sort order. This option does 
not override any sorting on {it:x1var} (and {it:x2var} when specified). 

{p 4 8 2}
{cmd:descending} specifies that, other instructions aside, values descend 
from left to right rather than ascend. 

{p 4 8 2}
{cmd:missing} specifies that missing values of {it:x1var} and {it:x2var}
are to be included as distinct categories. The default is to omit such
values. 

{p 4 8 2}
{cmd:separate(}{it:true_or_false_condition}{cmd:)} specifies that observations 
satisfying a {it:true_or_false_condition} should be shown differently. 

{p 4 8 2} 
{cmd:separateopts(}{it:scatter_options}{cmd:)} are used in conjunction 
with {cmd:separate()}, described above, to indicate how such observations should be shown. 

{p 4 4 2}{it:Panels and superpanels} 

{p 4 8 2} 
{cmd:plines} is a convenience option specifying that lines should be
drawn between panels using {cmd:xline()}. {cmd:plines} may also be
specified with {help added_line_options}. The default is {cmd:lc(gs8)}. 

{p 4 8 2}
{cmd:superplines} is a convenience option specifying that lines should
be drawn between superpanels using {cmd:xline()}. {cmd:superplines} may
also be specified with {help added_line_options}. The default is
{cmd:lc(gs4) lw(*1.2)}. 

{p 4 8 2}
{cmd:pgap(}{it:#}{cmd:)} tunes the space between panels. The default is
2. 

{p 4 8 2}
{cmd:superpgap(}{it:#}{cmd:)} tunes the space between superpanels.  The
default is 4. 

{p 4 4 2}{it:Other graph options}

{p 4 8 2} 
{cmd:lineopts(}{it:line_options}{cmd:)} 
are options of {help twoway line}, which may be used to tune the
appearance of the horizontal line segments representing the mean(s). 

{p 4 8 2} 
{cmd:rspikeopts(}{it:rspike_options}{cmd:)} 
are options of {help twoway rspike}, which may be used to tune the
appearance of the vertical line segments representing deviations. 

{p 8 8 2} 
{cmd:clean} is a convenient shorthand for 
{cmd:lineopts(lc(none ..)) rspikeopts(lc(none))} 
and removes the scaffolding emphasising that the values are plotted as
deviations. 

{p 4 8 2} 
{it:scatter_options} are options of {help scatter} and may be used to
tune the appearance of markers or the graph in general. 


{title:Examples}

{p 4 8 2}{cmd:. set scheme s1color}

{p 4 8 2}{cmd:. sysuse auto, clear}

{p 4 8 2}{cmd:. devnplot mpg}

{p 4 8 2}{cmd:. devnplot mpg foreign}{p_end}
{p 4 8 2}{cmd:. devnplot mpg rep78}{p_end}
{p 4 8 2}{cmd:. devnplot mpg rep78, pgap(5)}{p_end}
{p 4 8 2}{cmd:. devnplot mpg rep78, overall}{p_end}
{p 4 8 2}{cmd:. devnplot mpg rep78, overall pgap(3)}{p_end}
{p 4 8 2}{cmd:. devnplot mpg rep78, overall plines}{p_end}
{p 4 8 2}{cmd:. devnplot mpg rep78, overall plines pgap(3)}{p_end}
{p 4 8 2}{cmd:. devnplot price foreign}{p_end}
{p 4 8 2}{cmd:. devnplot price foreign, sort(weight)}{p_end}
{p 4 8 2}{cmd:. devnplot price rep78, clean}{p_end}
{p 4 8 2}{cmd:. devnplot price rep78, clean plines}{p_end}
{p 4 8 2}{cmd:. devnplot mpg rep78, clean plines recast(connected)}{p_end}
{p 4 8 2}{cmd:. devnplot mpg foreign, pgap(3) plines(lstyle(major_grid) lc(bg) lw(*8)) plotregion(color(gs15))}

{p 4 8 2}{cmd:. devnplot mpg foreign rep78}{p_end}
{p 4 8 2}{cmd:. devnplot mpg foreign rep78, superplines(lstyle(yxline)) plines}{p_end}
{p 4 8 2}{cmd:. egen median = median(mpg), by(foreign)}{p_end}
{p 4 8 2}{cmd:. devnplot mpg foreign rep78, superplines(lstyle(yxline)) level(median)}

{p 4 8 2}{cmd:. webuse systolic, clear}

{p 4 8 2}{cmd:. version 9: anova systolic drug disease drug*disease}{p_end}
{p 4 8 2}{cmd:. predict predict}{p_end}
{p 4 8 2}{cmd:. predict residual, residual}{p_end}
{p 4 8 2}{cmd:. devnplot systolic drug disease, level(predict) superplines}{p_end}
{p 4 8 2}{cmd:. devnplot residual drug disease, level(0) superplines}{p_end}

{p 4 8 2}{cmd:. webuse grunfeld, clear}

{p 4 8 2}{cmd:. devnplot invest company, sort(time) clean ysc(log) yla(1000 300 100 30 10 3 1) recast(line) subtitle(Grunfeld data)}{p_end}

{p 4 8 2}{cmd:. u smoking_oecd, clear}

{p 4 8 2}{cmd:. devnplot percent gender period, xla(, labsize(*.8) axis(2)) recast(line) xti("", axis(2)) xti("", axis(1)) yla(, ang(h)) superplines(lc(gs14))}{p_end} 
{p 4 8 2}{cmd:. egen nation = group(country)}{p_end}
{p 4 8 2}{cmd:. devnplot percent gender period, xla(, labsize(*.8) axis(2)) recast(line) xti("", axis(2)) xti("", axis(1)) yla(, ang(h)) superplines(lc(gs14)) separate(nation == 24) separateopts(mcolor(blue ..)}
{cmd: msize(*1.2 ..)) note("USA highlighted")}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break}
n.j.cox@durham.ac.uk


{title:Acknowledgments}

{p 4 4 2}Vince Wiggins and David Airey gave helpful and encouraging 
suggestions. 


{title:References}

{p 4 8 2}
Fisher, R.A. 1925. {it:Statistical Methods for Research Workers}. 
Edinburgh: Oliver and Boyd. 

{p 4 8 2}Gilder, K. 2012.
Statistical graphics in clinical oncology.                        
In Krause, A. and O'Connell, M. (Eds) 
{it:A picture is worth a thousand tables: Graphics in life sciences.} 
New York: Springer, 173{c -}198.  

{p 4 8 2}
Grafen, A. and Hails, R. 2002. 
{it:Modern Statistics for the Life Sciences.} 
Oxford: Oxford University Press. 

{p 4 8 2}
Pearson, E.S. 1956.
Some aspects of the geometry of statistics: the use of visual 
presentation in understanding the theory and application of mathematical 
statistics. 
{it:Journal of the Royal Statistical Society} A 119: 125{c -}146.

{p 4 8 2}
Whitlock, M.C. and Schluter, D. 2009. {it:The Analysis of Biological Data.} 
Greenwood Village, CO: Roberts and Company. 


{title:Also see} 

{p 4 4 2}
{help qplot} (if installed);  
{help distplot} (if installed); 
{help stripplot} (if installed); 
{help dotplot}


