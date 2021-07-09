{smcl}
{cmd:help kappaetc, loa}{right: ({browse "http://www.stata-journal.com/article.html?article=st0544":SJ18-4: st0544})}
{hline}

{title:Title}

{p2colset 5 22 24 2}{...}
{p2col:{cmd:kappaetc, loa} {hline 2}}Limits of agreement (Bland-Altman
plot){p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:kappaetc} 
{it:{help varname:varname1}} {it:{help varname:varname2}}
{ifin} {weight}{cmd:,} {cmd:loa}[{cmd:(}{it:#}{cmd:)}]
[{it:{help kappaetc_loa##opts:options}}]


{synoptset 30 tabbed}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{p2coldent:* {cmd:loa}[{cmd:(}{it:#}{cmd:)}]}estimate {it:#} percent limits of 
agreement and create Bland-Altman plot; default is {cmd:loa({ccl level})}{p_end}
{synopt:{cmd:cformat(}{it:{help format:{bf:%}fmt}}{cmd:)}}control format of default 
y-axis labels{p_end}
{synopt:{opt novarl:abel}}do not use variable labels as axis titles{p_end}
{synopt:{opt line:opts(line_options)}}options for 
{helpb graph twoway line}{p_end}
{synopt:{opt scatter:opts(scatter_options)}}options for 
{helpb graph twoway scatter}{p_end}
{synopt:{opt twoway:opts(twoway_options)}}options for 
{helpb graph twoway}{p_end}
{synopt:{opt keep}}keep temporary variables used for the plot{p_end}
{synopt:{opt return}[{opt only}]}return results in {cmd:r()}[; do not 
produce a graph]{p_end}
{synoptline}
{pstd}
* {opt loa} is required.{p_end}
{p 4 6 2}
{cmd:by} is allowed; see {manlink D by}.
{p_end}
{p 4 6 2}
{cmd:fweight}s and {cmd:iweight}s are allowed; see {help weight}.
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:kappaetc} with the {opt loa} option estimates limits of agreement and
creates a Bland-Altman plot (Bland and Altman 1986), where differences between
paired ratings are plotted against their averages.


{title:Options}

{phang}
{opt loa}[{cmd:(}{it:#}{cmd:)}] estimates {it:#} percent limits of agreement
and creates a Bland-Altman plot.  The default is {cmd:loa({ccl level})}.
{cmd:loa} is required.

{phang}
{cmd:cformat(%}{it:fmt}{cmd:)} specifies how to format the default y-axis
labels, that is, the mean and the lower and  upper limits of agreement.  The
default is {cmd:cformat(%8.4f)}.  This is a convenience option.  The axis
labels and other details in the graph are controlled by the {opt lineopts()},
{opt scatteropts()}, and {opt twowayopts()} options described below.

{phang}
{opt novarlabel} specifies that variable names are used as axis titles, not
variable labels (the default).  This is a convenience option.  Axis titles and
other details in the graph are controlled by the {opt lineopts()},
{cmd:scatteropts()}, and {opt twowayopts()} options described below.

{phang}
{cmd:lineopts(}{it:{help line_options}}{cmd:)} are options for
{cmd:graph twoway line} and modify the appearance of the plotted lines.  The
default is {cmd:lineopts(sort lstyle(p1 p2 p2))}.

{phang}
{cmd:scatteropts(}{it:{help scatter##marker_options:scatter_options}}{cmd:)}
are {it:{help marker_options}}, {it:{help marker_label_options}}, and
{it:{help scatter##jitter_options:jitter_options}} for 
{cmd:graph twoway scatter} and modify the appearance of the plotted markers.
The default is {cmd:scatteropts(mstyle(p1))}.

{phang}
{cmd:twowayopts(}{it:{help twoway_options}}{cmd:)} are options for twoway
graphs.

{phang}
{opt keep} keeps temporary variables used to create the plot.  The variable
names are {cmd:_pairmean}, {cmd:_pairdiff}, {cmd:_meandiff}, {cmd:_lowerloa},
and {cmd:_upperloa}.  All variables are created in double precision.
{cmd:keep} may not be combined with the {cmd:by} prefix.

{phang}
{opt return}[{opt only}] stores results in {cmd:r()}.  For example, the
following are stored: the mean difference, its standard deviation, and the
lower and upper limits of agreement, among other scalars.  If {opt returnonly}
is specified, no graph is produced.


{title:Example}

{phang}{cmd:. webuse p615b}{p_end}
{phang}{cmd:. kappaetc rater1 rater2, loa}{p_end}


{title:Stored results}

{pstd}
{cmd:kappaetc} with the {opt loa} option stores nothing in {cmd:r()}.  With
the {cmd:return} option, it stores the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(N)}}number of subjects{p_end}
{synopt:{cmd:r(mean_diff)}}mean difference of ratings{p_end}
{synopt:{cmd:r(sd_diff)}}standard deviation of mean difference{p_end}
{synopt:{cmd:r(loa_ll)}}lower limit of agreement{p_end}
{synopt:{cmd:r(loa_ul)}}upper limit of agreement{p_end}
{synopt:{cmd:r(loa_level)}}level for limits of agreement{p_end}

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:kappaetc}{p_end}
{synopt:{cmd:r(cmd2)}}{cmd:loa}{p_end}


{title:Reference}

{phang}
Bland, J. M., and D. G. Altman. 1986. Statistical methods for assessing 
agreement between two methods of clinical measurement. {it:Lancet} 327: 307-310.


{title:Author}

{pstd}
Daniel Klein{break}
International Centre for Higher Education Research Kassel{break}
Kassel, Germany{break}
klein@incher.uni-kassel.de


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 4: {browse "http://www.stata-journal.com/article.html?article=st0544":st0544}{p_end}

{p 7 14 2}
Help:  {manhelp icc R}, {manhelp kappa R}, {helpb baplot}, {helpb batplot},
{helpb concord}, {helpb kappaetc} (if installed){p_end}
