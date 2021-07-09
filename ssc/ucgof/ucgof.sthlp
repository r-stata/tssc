{smcl}
{* *! version 1.0.0  21aug2018}{...}
{vieweralsosee "[R] tabulate" "help tabulate twoway"}{...}
{vieweralsosee "[D] contract" "help contract"}{...}
{vieweralsosee "[D] expand" "help expand"}{...}
{p2colset 1 10 20 2}{...}
{p2col:{bf:ucgof} {hline 2}}Univariate categorical goodness-of-fit tests{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmdab:ucgof} {varname}
[{cmd:,}
{it:options}]

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt model(# # ...)}}proportions (as percentages) specified by the model, 0 < P < 100; default model is for equal proportions in all categories (100 divided by number of categories){p_end}
{synopt:{opt freq}}use this option if the input data are given as a frequency table rather than individual observations.  The variable in the data file that shows frequencies needs to be named {cmd:_freq}.{p_end}

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:ucgof} displays the conventional chi-squared goodness-of-fit tests for a single categorical variable--namely, Pearson (χ²) and likelihood-ratio (G).  Standardized residuals and their Bonferroni-adjusted p-values are also computed.
{p_end}

{pstd}
Note: {cmd:ucgof} was designed to be used on raw data--i.e., data that are stored as individual observations rather than aggregated frequencies.  However, there is an option to use frequencies if needed.
{p_end}

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}

{pstd}Compute the GOF tests for {cmd:race}; since no model was specified, the default model of equal proportions is used (in this instance, {cmd: race} has three levels, so 33.3% for all categories){p_end}
{phang2}{cmd:. ucgof race}{p_end}

{pstd}Compute the GOF tests for {cmd:race} using the model 70% white, 25% black, and 5% other{p_end}
{phang2}{cmd:. ucgof race, model(70 25 5)}{p_end}


{marker examples}{...}
{title:Acknowledgment}

{pstd} This program was adapted from the following packages:{p_end}

{phang2}- tab_chi/chitest (N. J. Cox, 1999){p_end}
{phang2}- csgof (Statistical Consulting Group - UCLA, 2015){p_end}

