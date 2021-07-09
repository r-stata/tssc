{smcl}
{* 03Feb2009}{...}
{hline}
{cmd:help wtp}
{hline}


{title:Title}

{p2colset 5 11 20 2}{...}
{p2col :{hi:    wtp} {hline 1}}Confidence intervals for willingness to pay measures.{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{opt wtp} {it:namelist} [,{it:options}]

{synoptset 18 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt de:lta}}delta method (the default){p_end}
{synopt :{opt fi:eller}}Fieller's method {p_end}
{synopt :{opt kr:insky}}Krinsky Robb (parametric bootstrap) method{p_end}
{synopt :{opt reps(#)}}Set the number of repetitions for the Krinsky Robb method;
default is {cmd:reps(1000)}{p_end}
{synopt :{opt seed(#)}}Set the seed; default is {cmd:seed(5426)}{p_end}
{synopt :{opt l:evel(#)}}Set the confidence level{p_end}
{synopt :{opt eq:uation(name)}}Specify the equation name{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:wtp} estimates confidence intervals for willingness to pay (WTP) measures of the type
-b_k/b_c, where b_c is the cost coefficient and b_k is the coefficient for attribute x_k.
It uses one of three methods: the delta method, Fieller's method or the Krinsky Robb (parametric
bootstrap) method. See Hole (2007) for a comparison of the accuracy of the methods in this context.

{pstd}
Any number >1 of variable names may be specified. The first is
taken to be the cost variable, i.e. the variable which coefficient is the denominator in the
ratios. {cmd:wtp} returns and displays a 3xk matrix, r(wtp), where k is the number of specified
variables other than the cost variable. The first row in r(wtp) contains the WTP
estimates and the second and third rows contain the lower and upper	confidence limits of the
WTP estimates.

{pstd}
{cmd:wtp} does not feature a (non-parametric) bootstrap option, since bootstrap confidence intervals
can easiliy be obtained using the {cmd:bootstrap} command (see {help bootstrap}). 

{pstd}
Note: {cmd:wtp} accepts "_cons" as a variable name. Shorthand conventions for variable names
such as xvar* or xvar1-xvar3 are not accepted, however - all names must be written in full.


{title:Options}

{phang}
{opt delta}; use the delta method to construct the confidence intervals (the default).

{phang}
{opt fieller}; use Fieller's method to construct the confidence intervals.

{phang}
{opt krinsky}; use the Krinsky Robb (parametric bootstrap) method to construct the confidence
intervals.

{phang}
{opt reps(#)} sets the number of repetitions for the Krinsky Robb method;
default is {cmd:reps(1000)}.

{phang}
{opt seed(#)} sets the random-number seed; default is {cmd:seed(5426)}. This option is only
relevant for the Krinsky Robb method.

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}.

{phang}
{opt equation(name)} specifies the equation name. This option is relevant if {cmd:wtp}
is used after multiple-equation models such as {cmd:mlogit}. If the equation name is not
specified the default is the first equation.


{title:Examples}

{phang}{cmd:. probit choice wait cost knows thoro}{p_end}

{phang}{cmd:. wtp cost wait knows}{p_end}
{phang}{cmd:. wtp cost wait thoro _cons, fieller level(90)}{p_end}
{phang}{cmd:. wtp cost wait knows thoro, krinsky reps(2000)}{p_end}


{title:References}

{phang}Hole AR. 2007. A comparison of approaches to estimating
confidence intervals for willingness to pay measures. Health Economics 16, 827-840.
{browse "http://dx.doi.org/10.1002/hec.1197"}


{title:Author}

{phang}This command was written by Arne Risa Hole (a.r.hole@sheffield.ac.uk),
Department of Economics, University of Sheffield. I am grateful to Jesper Kjær Hansen
for helpful comments. Comments and suggestions are welcome. {p_end}


