{smcl}
{* *! version 3.2  David Fisher  28jan2019}{...}
{vieweralsosee "ipdmetan" "help ipdmetan"}{...}
{vieweralsosee "forestplot" "help forestplot"}{...}
{vieweralsosee "metan" "help metan"}{...}
{vieweralsosee "admetan" "help admetan"}{...}
{vieweralsosee "admetani" "help admetani"}{...}
{viewerjumpto "Syntax" "ipdover##syntax"}{...}
{viewerjumpto "Description" "ipdover##description"}{...}
{viewerjumpto "Options" "ipdover##options"}{...}
{viewerjumpto "Saved results" "ipdover##saved_results"}{...}
{viewerjumpto "Examples" "ipdover##examples"}{...}
{title:Title}

{phang}
{cmd:ipdover} {hline 2} Generate data for forest plots outside of the context of meta-analysis


{marker syntax}{...}
{title:Syntax}

{phang}
Syntax 1: {it:command}-based syntax; "generic" effect measure

{p 8 18 2}
{cmd:ipdover}
	[{it:{help exp_list}}]
	{cmd:, over(}{it:over_varlist} [{cmd:, {ul:m}issing}]{cmd:)} [{cmd: over(}{it:varname} [{cmd:, {ul:m}issing}]{cmd:)} {it:options}] {cmd::} {it:command} {ifin} {it:...}

{phang}
Syntax 2: {bf:{help collapse}}-based syntax; "specific" effect measure

{p 8 18 2}
{cmd:ipdover}
	{it:input_varlist} {ifin}
	{cmd:, over(}{it:over_varlist} [{cmd:, {ul:m}issing}]{cmd:)} [{cmd: over(}{it:varname} [{cmd:, {ul:m}issing}]{cmd:)} {it:options}]

{pstd}
where {it:input_varlist} is one of the following:

{p 8 34 2}{it:var_outcome} {it:var_treat}{space 11}where {it:var_outcome} and {it:var_treat} are both binary 0, 1{p_end}
{p 8 34 2}{it:var_outcome} {it:var_treat}{space 11}where {it:var_outcome} is continuous and {it:var_treat} is binary 0, 1{p_end}
{p 8 34 2}{it:var_treat}{space 23}where {it:var_treat} is binary 0, 1 and the data have previously been {bf:{help stset}}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ipdover} extends the functionality of {bf:{help ipdmetan}} outside the context of meta-analysis.
It does not perform any pooling or heterogeneity calculations;
rather, its intended use is creating forest plots of subgroup analyses within a single trial dataset.
Basic syntaxes are the same as for {bf:{help ipdmetan}}, but with {opt over(varlist)} replacing {opt study(varname)}.
Where {cmd:ipdmetan} summarises data by study, {cmd:ipdover} summarises data within each level of each variable in {it:varlist}.
The optional second {opt over(varname)} allows stratification of results by a further single variable,
in a similar way to {opt by(varname)} with {cmd:ipdmetan}.

{pstd}
Forest plots produced by {cmd:ipdover} are weighted by sample size rather than by the inverse of the variance,
and by default sample size will appear to the left of the plot
(instead of study weights appearing to the right of the plot as in {cmd:ipdmetan}).

{pstd}
{help admetan##saved_datasets:Saved datasets} may include the following identifier variables:{p_end}
{p2colset 8 24 24 8}
{p2col:{cmd:_BY}}subset of data (c.f. {help by}) as supplied to second {opt over()} option, if applicable{p_end}
{p2col:{cmd:_OVER}}identifier of variable within {it:over_varlist}{p_end}
{p2col:{cmd:_LEVEL}}level (category) of variable identified by {cmd:_OVER}.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Options specific to ipdover}

{phang}
{cmd:over(}{it:varlist} [{cmd:, missing}]{cmd:)} [{cmd: over(}{it:varname} [{cmd:, missing}]{cmd:)}] specifies the variable(s) whose levels {it:command} is to be fitted within.
The option may be repeated at most once, in which case the second option must contain a single {it:varname} defining
subsets of the data (c.f. {help by}).

{pmore} All variables must be either integer-valued or string.
Variable and value labels will appear in output where appropriate.

{pmore}
{opt missing} requests that missing values be treated as potential subgroups or subsets (the default is to exclude them).

{phang}
{cmd:plotid(_BY | _OVER | _LEVEL | _n} [{cmd:, list nograph}]{cmd:)} functions in basically the same way as in {bf:{help ipdmetan}},
but instead of a {it:varname}, it accepts one of the following values, corresponding to variables created in saved
datasets created by {cmd:ipdover}:{p_end}
{p2colset 8 24 24 8}
{p2col:{cmd:_BY}}group observations by levels of {cmd:_BY}{p_end}
{p2col:{cmd:_OVER}}group observations by levels of {cmd:_OVER}{p_end}
{p2col:{cmd:_LEVEL}}group observations by levels of {cmd:_LEVEL}{p_end}
{p2col:{cmd:_n}}allow each observation to be its own group.{p_end}

{pstd}Most other options as described for {bf:{help ipdmetan##options:ipdmetan}}, {bf:{help admetan##options:admetan}}
or {bf:{help forestplot##options:forestplot}} may also be supplied to {cmd:ipdover},
with the exception of options concerning heterogeneity statistics or pooled results
such as {opt model()}, {opt cumulative} or {opt influence}.
(However, note that {opt poolvar()} {ul:is} allowed (with Syntax 1), since it refers to the coefficient to be extracted
from each model fit rather than to the pooled result {it:per se}.)


{marker saved_results}{...}
{title:Saved results}

{pstd}{cmd:ipdover} saves the following in {cmd:r()}:{p_end}
{pstd}(in addition to any scalars saved by {bf:{help forestplot}}){p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:r(k)}}Number of subgroups{p_end}
{synopt:{cmd:r(n)}}Total number of included patients{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(citype)}}Method of constructing confidence intervals{p_end}
{synopt:{cmd:r(command)}}Full estimation command-line{p_end}
{synopt:{cmd:r(cmdname)}}Estimation command name{p_end}
{synopt:{cmd:r(estexp)}}Name of coefficient representing effect size{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(coeffs)}}Matrix of study and subgroup identifiers, effect coefficients, and numbers of participants{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Variables}{p_end}
{synopt:{cmd:_rsample}}Observations included in the analysis (c.f. {cmd:e(sample)}){p_end}


{marker examples}{...}
{title:Examples}

{pstd}
Using the Hosmer & Lemeshow low birthweight data from {bf:{help logistic}},
look at the effect of maternal age on odds of LBW within various data subgroups:

{cmd}{...}
{* example_start - ipdover_ex1}{...}
{phang2}
. webuse lbw, clear{p_end}
{phang2}
. ipdover, over(race smoke ht) or{* ///}{p_end}
{p 16 20 2}
forestplot(favours("Odds of LBW decrease" "as age increases" # "Odds of LBW increase" "as age increases")){* ///}{p_end}
{p 16 20 2}
: logistic low age{p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdover_ex1 using ipdover.sthlp:click to run})}{p_end}


{pstd}
With the same dataset, use Syntax 2 of {cmd:ipdover} to derive mean and SD of maternal age within birthweight categories,
and hence analyse the mean difference in maternal age between those whose babies were LBW vs those who were normal weight.
This example also demonstrates the use of {opt group1()}, {opt group2()}:

{cmd}{...}
{* example_start - ipdover_ex2}{...}
{phang2}
. webuse lbw, clear{p_end}
{phang2}
. ipdover age low, over(race ht) wmd{* ///}{p_end}
{p 16 20 2}
forestplot(favours(`"Mean maternal age higher"' `"among those with LBW infant"' # {* ///}{p_end}
{p 16 20 2}
`"Mean maternal age lower"' `"among those with LBW infant"')){* ///}{p_end}
{p 16 20 2}
counts group1(`"Age of mothers"' `"of low BW infants"') group2(`"Age of mothers"' `"of normal BW infants"'){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdover_ex2 using ipdover.sthlp, list:click to run})}{p_end}


{pstd}
Note that, following other meta-analysis software such as the {help ipdover#references:Cochrane Review Manager},
the standard error of the (unstandardised) mean difference is derived as {bf:sqrt(}{it:sd0}{bf:^2/}{it:n0} {bf:+} {it:sd1}{bf:^2/}{it:n1}{bf:)}
where {it:sd0}, {it:sd1} are the SDs in the two treatment arms with respective sample sizes {it:n0}, {it:n1}.
Therefore, we could also perform this analysis using {help vwls:variance-weighted least-squares regression}, albeit without the {opt counts} option:

{cmd}{...}
{* example_start - ipdover_ex3}{...}
{phang2}
. webuse lbw, clear{p_end}
{phang2}
. ipdover, over(race ht) wmd : vwls age low{p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdover_ex3 using ipdover.sthlp, list:click to run})}{p_end}


{pstd}
Finally, we apply {bf:ipdover} to a set of clinical trials, showing the treatment effect by covariate subgroup by trial
(using the example IPD meta-analysis dataset from {bf:{help ipdmetan}}):

{pstd}
(Note the use of the option {bf:maxwidth(18)}.  As {bf:stage} contains only the extremely short labels "I", "II" and "III",
by default {cmd:forestplot} would underestimate the width needed to contain the column title.  See {help forestplot:help forestplot} for more details.)

{cmd}{...}
{* example_start - ipdover_ex4}{...}
{phang2}
. use http://fmwww.bc.edu/repec/bocode/i/ipdmetan_example.dta, clear{p_end}
{phang2}
. stset tcens, fail(fail){p_end}
{phang2}
. ipdover, over(stage) over(trialid) hr nosubgroup nooverall{* ///}{p_end}
{p 16 20 2}
forestplot(favours(Favours treatment # Favours control) maxwidth(18)) : stcox trt{p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdover_ex4 using ipdover.sthlp, list:click to run})}{p_end}



{title:Author}

{p}
David Fisher, MRC Clinical Trials Unit at UCL, London, UK.

Email {browse "mailto:d.fisher@ucl.ac.uk":d.fisher@ucl.ac.uk}



{title:Acknowledgments}

{pstd}
Thanks to Phil Jones at UWO, Canada for suggesting improvements in functionality.

{pstd}
The "click to run" element of the examples in this document is handled using an idea originally developed by Robert Picard.



{marker references}{...}
{title:References}

{phang}Review Manager (RevMan) [Computer program]. Version 5.3. 
Copenhagen: The Nordic Cochrane Centre, The Cochrane Collaboration, 2014.{p_end}
