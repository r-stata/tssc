{smcl}
{* *! version 1.0.0  06nov2009}{...}
{cmd:help leanout}{...}
{right:Distribution:  Stata Journal}
{hline}

{title:Title}

{p2colset 5 16 22 2}{...}
{p2col:{cmd:leanout} {hline 2}}Lean output formatting for regressions results{p_end}
{p2colreset}{...}


{title:Syntax}

{pstd}
Standard estimation command syntax

{p 8 31 2}
{cmd:leanout}
	[{cmd:,}
		{it:options}
	] {cmd::} {it:estimation_command}


{pstd}
Survey estimation command syntax

{p 8 31 2}
{cmd:leanout}
	[{cmd:,}
		{it:options}
	] {cmd::} {cmd:svy} [{it:vcetype}] [{cmd:,} {it:svy_options}
	] {cmd::} {it:estimation_command}


{pmore}Where {it:estimation_command} is almost any estimation command and
includes any options for the estimation command.


{synoptset 17 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Reporting}
{synopt:{opt format(fmt)}}display {help format} format for results{p_end}
{synopt:{opt varw:idth(#)}}allow {it:#} characters for displaying 
	variable names{p_end}

{synopt :{it:{help leanout##display_options:display_options}}}control spacing
           and display of omitted variables and base and empty cells{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Weights are allowed if {it:command_name} allows them; see {help weight}.{p_end}
{p 4 6 2}
All postestimation commands behave as they would after the estimation command
without the {opt leanout} prefix. {p_end}
{p 4 6 2}
{cmd:leanout:} [, {it:options} ] may be typed to replay the estimation
results{p_end}
{p 4 6 2}
{cmd:leanout:} [, {it:options} ] may be typed after normal estimation with
most estimation commands to display the lean output.{p_end}


{title:Description}

{pstd}
{opt leanout} fits a model specified by {it:estimation_command}.  It
suppresses the command's normal output and instead displays a "lean" estimation
table comprised of only the variable names, the coefficients, the standard
errors, and the confidence intervals.


{title:Options}

{phang}
{opt format(fmt)} specifies the display {help format} used to display
        the coefficient and its standard error and confidence interval.
	Default format is {bf:%f5.1f}.

{phang}
{opt varwidth(#)} specifies the maximum number of characters for displaying
	variable names.  Names longer than {it:#} are abbreviated.  Default is
	16 characters.

{marker display_options}{...}
{phang}
{it:display_options} may be
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.


{title:Remarks}

{pstd}
{cmd:leanout} works with almost all estimation commands.  It does not produce
useful output after {helpb exlogistic}, {helpb expoisson}, {helpb asmprobit},
{helpb asclogit}, {helpb asroprobit}.

{pstd}
{cmd:leanout} does not support alternate parameterization of estimated
coefficients, such as odds ratios for {help logistic} models.

{pstd}
Most maximim-likelihood estimators, and other estimators requiring
optimization, estimate ancillary parameters in a transformed metric to improve
convergence.  {cmd:leanout} displays ancillary parameters only in the metric
in which they were estimated.  It does not display them in their natural,
untransformed metric.


{title:Examples}

{pstd}Linear regression{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. leanout: regress length turn headroom}{p_end}

{pstd}Replay results{p_end}
{phang2}{cmd:. leanout:}{p_end}

{pstd}Linear regression with factor variables{p_end}
{phang2}{cmd:. leanout: regress length turn headroom i.for i.rep78}{p_end}

{pstd}Showing base categories{p_end}
{phang2}{cmd:. leanout, base: regress length turn headroom i.for i.rep78}{p_end}

{pstd}With a custom format{p_end}
{phang2}{cmd:. leanout, format(%8.4f): regress length turn headroom i.for i.rep78}{p_end}

{pstd}As a postestimation command{p_end}
{phang2}{cmd:. regress length turn headroom i.for i.rep78}{p_end}
{phang2}{cmd:. leanout:}{p_end}

{pstd}Linear regression with survey data{p_end}
{phang2}{cmd:. webuse nhanes2f:}{p_end}
{phang2}{cmd:. svyset psuid [pweight=finalwgt], strata(stratid):}{p_end}
{phang2}{cmd:. leanout: svy: regress zinc age female black orace rural:}{p_end}

{pstd}A maximum-likelihood estimator{p_end}
{phang2}{cmd:. webuse lbw}{p_end}
{phang2}{cmd:. leanout, format(%5.2f):  probit low  smoke ptl ht ui i.race}{p_end}

{pstd}A multiple equation estimator{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. leanout: sureg (mpg trunk length) (turn trunk i.foreign)}{p_end}


{title:Saved results}

{pstd}
{cmd:leanout} leaves behind the estimation command's standard saved results in
{cmd:e()}:

{title:Also see}

{psee}
{space 2}Help:  {manhelp estimates R:estimates table}
{p_end}
