{smcl}
{* *! version 1.0.0  24aug2017}{...}
{cmd:help irax}{right: Wim van Putten, Patrick Royston}
{hline}


{title:Title}

{p2colset 5 13 15 2}{...}
{p2col :{hi:irax} {hline 2}}Isotonic regression analysis (extended){p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd:irax}
{it:yvar}
{it:xvar}
{ifin}
[{cmd:,} {it:options} {it:twoway_options}]


{synoptset 16}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt ci}}pointwise confidence interval for fitted step function{p_end}
{synopt :{opt com:bine}}combine the "forward" and "reverse" step functions{p_end}
{synopt :{opt gen:erate(varname)}}store fitted function in {it:varname}, and other quantities (see Options){p_end}
{synopt :{opt nogr:aph}}suppress graph{p_end}
{synopt :{opt nopt:s}}suppress scatter plot of {it:yvar} against {it:xvar}{p_end}
{synopt :{opt rev:erse}}impose non-increasing association between {it:yvar} and {it:xvar}{p_end}
{synopt :{it:twoway_options}}options for {cmd:graph twoway}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:irax} performs isotonic regression analysis of {it:yvar} on {it:xvar}.
Isotonic regression means regression under order restriction. Whereas linear
regression fits a straight line, isotonic regression analysis fits a
step function, constrained to be either monotonically non-decreasing in {it:xvar}
(the default) or monotonically non-increasing (with the {opt reverse} option).

{pstd}
{cmd:irax} uses the PAVA (pool adjacent violators algorithm) to fit the step
function. See Barlow {it:et al} (1972) for further information.


{title:Options}

{phang}
{opt ci} estimates a pointwise, partition-wise confidence interval for
the fitted step function. To do so, {cmd:irax} fits an auxiliary 
regression on the partition groups. In sparse partitions, the
CI may be unavailable due to a too-small sample size. Note that the CI
is likely to be quite wide, due to the potentially large number of
parameters that are fitted.

{phang}
{opt combine} computes the sum of the forward (positive association)
and reverse (negative association) step functions, and subtracts the mean
of {it:yvar}. This option relaxes the monotonicity constraints, and
represents an heuristic extension of isotonic regression analysis.
WORK IN PROGRESS.

{phang}
{cmd:generate(}{it:varname} [{cmd:, replace}]{cmd:)} stores the fitted step
function in {it:varname} and the partition variable in {it:varname}{cmd:_p}.
If {opt replace} is specified, existing variables are replaced. If the
{opt ci} option is specified, the lower and upper confidence limits are
stored in {it:varname}{cmd:_lci} and {it:varname}{cmd:_uci}, respectively.

{phang}
{opt nograph} suppresses the plot of the fitted step function and possible
other adornments.

{phang}
{opt nopts} supppresses the scatter of {it:yvar} against {it:xvar} that is
produced as part of the graphical output in the linear regression case.
{opt nopts} has no effect in the binary case.

{phang}
{opt reverse} imposes a monotonically non-increasing association between
{it:yvar} and {it:xvar}. The default is to impose a monotonically
non-decreasing association.

{phang}
{it:twoway_options} are any options appropriate to {cmd:graph, twoway}.


{title:Examples}

{phang}{cmd:. }{stata sysuse auto, clear}{p_end}
{phang}{cmd:. }{stata irax price weight}{p_end}
{phang}{cmd:. }{stata irax mpg weight, reverse ci}{p_end}
{phang}{cmd:. }{stata irax foreign mpg, generate(p_ira)}{p_end}
{phang}{cmd:. }{stata websuse brcancer, clear}{p_end}
{phang}{cmd:. }{stata stset rectime, fail(censrec)}{p_end}
{phang}{cmd:. }{stata predict mg, mgale}{p_end}
{phang}{cmd:. }{stata irax mg x1, combine ci nopts}{p_end}


{title:Authors}

{pstd}
Wim van Putten, Erasmus MC, Rotterdam.{break}
w.vanputten@erasmusmc.nl

{pstd}
Patrick Royston, MRC Clinical Trials Unit at UCL, London.{break}
j.royston@ucl.ac.uk


{title:Reference}

{phang}
R. E. Barlow, D. J. Bartholomew, J. M. Bremner and H. D. Brunk.
1972. {it:Statistical inference under order restrictions;}
{it:the theory and application of isotonic regression}.
New York: Wiley. ISBN 0-471-04970-0.


{title:Also see}

{psee}
Online:  {helpb graph_twoway}, {helpb running} (if installed){p_end}
