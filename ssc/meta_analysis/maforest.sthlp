
{smcl}
{* *! version 2.0 05may2021}{...}
{viewerdialog maforest "dialog maforest"}{...}

{marker syntax}{...}

{title:Syntax}

{phang} Simple forest plot for effect sizes and meta-analysis results.

{p 8 16 2}
{cmd:maforest} {effectsizevar} {se_effectsize} {ifin} {cmd:,}
[_options_]

{pstd} where {it:effectsize} is the effect size variable and
{it:se_effectsize} is the standard error of the effect size. The
{it:effectsize} can be any effect size type, such as Cohen's {it:d},
Hedges' {it:g}, logged odds ratio, logged risk ratio, logged logit,
{it:r} or Fisher's {it:Zr}, among others. It is critical that the
effect size is in its analyzable form. For example, the effect size
can be a logged odds ratio but not an odds ratio.

{marker reoptions}{...}
{synoptset 20 tabbed}{...}
{synopthdr :Options}
{synoptline}

{synopt :{opt col1(varname)}}
 first (leftmost) column of labels for the effect size, such as author and year
{p_end}

{synopt :{opt col1lbl(_string_)}}
column label for first column 
{p_end}

{synopt :{opt col2(varname)}}
 second (leftmost) column of labels for the effect size, such as author and year
{p_end}

{synopt :{opt col2lbl(_string_)}}
column label for second column 
{p_end}

{synopt :{opt sortby(varname)}}
 sort effect sizes by {it:varname}
{p_end}

{synopt :{opt xmin(num)}}
minimum value for the {it:x}-axis
{p_end}

{synopt :{opt xmax(num)}}
maximum value for the {it:x}-axis
{p_end}

{synopt :{opt xtics(numlist)}}
list of values for the {it:x}-axis
{p_end}

{synopt :{opt xlabel(_string_)}}
label for {it:x}-axis (default is {it:Effect Size}
{p_end}

{synopt :{opt logxaxis}}
expoential to the axis (useful if effect sizes are logged)
{p_end}

{synopt :{opt font(large|medium|small|tiny)}}
adjust font size
{p_end}

{synopt :{opt mean(_string_)}} add mean effect to bottom of plot; the
{it: _string_} specifies the model type, such as REML, FE, etc; any
model option for {helpmasum} is value.
{p_end}

{synopt :{opt leftside(_string_)}}
column heading for leftside of the forest plot, such as {it:Favors
Treatment}; the default is blank
{p_end}

{synopt :{opt rightside(_string_)}}
column heading for rightside of the forest plot, such as {it:Favors
Control}; the default is blank
{p_end}

{marker description}{...}
{title:Description}

{pstd} {cmd:maforest} performs produces a simple forest plot of effect
sizes and optionally the mean effect size. Options allow you to
control column headings, font sizes, axis labels, and more.

{pstd} Related command are {help masum}, {help maanova}, and
{help mareg}. These perform and overall meta-analysis, a subgroup
meta-analysis, and a meta-regression analysis.


{pstd}
As of Stata version 16.0, Stata has a built-in command for
conducting meta-analysis. See {help meta}.

{marker description}{...}
{title:Acknowledgments}

{pstd} {cmd:maforest} was written by David B. Wilson and is an updated version of a command written as a companion to a book on meta-analysis he co-authored with Mark Lipsey (Lipsey & Wilson, 2001). Portions of this program are based on code from Wolfgang Viechtbauer's {it:metafor} package for R.

{marker description}{...}
{title:References}

{pstd}
Lipsey, M. W., & Wilson, D. B. (2001). {it} Practical
meta-analysis. {sf} Sage.
