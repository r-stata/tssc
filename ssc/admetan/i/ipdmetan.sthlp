{smcl}
{* *! version 3.2  David Fisher  28jan2019}{...}
{vieweralsosee "admetan" "help admetan"}{...}
{vieweralsosee "admetani" "help admetani"}{...}
{vieweralsosee "ipdover" "help ipdover"}{...}
{vieweralsosee "forestplot" "help forestplot"}{...}
{vieweralsosee "metan" "help metan"}{...}
{viewerjumpto "Syntax" "ipdmetan##syntax"}{...}
{viewerjumpto "Description" "ipdmetan##description"}{...}
{viewerjumpto "Options" "ipdmetan##options"}{...}
{viewerjumpto "Saved results" "ipdmetan##saved_results"}{...}
{viewerjumpto "Examples" "ipdmetan##examples"}{...}
{viewerjumpto "References" "ipdmetan##references"}{...}
{title:Title}

{phang}
{cmd:ipdmetan} {hline 2} Perform two-stage individual participant data (IPD) meta-analysis


{marker syntax}{...}
{title:Syntax}

{phang}
Syntax 1: {it:command}-based syntax; "generic" effect measure

{p 8 18 2}
{cmd:ipdmetan}
	[{it:{help exp_list}}]
	{cmd:, {ul:s}tudy(}{it:varname} [{cmd:, {ul:m}issing}]{cmd:)} [{it:options}] {cmd::} {it:command} {ifin} {it:...}

{phang}
Syntax 2: {bf:{help collapse}}-based syntax; "specific" effect measure

{p 8 18 2}
{cmd:ipdmetan}
	{it:input_varlist} {ifin}
	{cmd:, {ul:s}tudy(}{it:varname} [{cmd:, {ul:m}issing}]{cmd:)} [{it:options}]

{pstd}
where {it:input_varlist} is one of the following:

{p 8 34 2}{it:var_outcome} {it:var_treat}{space 11}where {it:var_outcome} and {it:var_treat} are both binary 0, 1{p_end}
{p 8 34 2}{it:var_outcome} {it:var_treat}{space 11}where {it:var_outcome} is continuous and {it:var_treat} is binary 0, 1{p_end}
{p 8 34 2}{it:var_treat}{space 23}where {it:var_treat} is binary 0, 1 and the data have previously been {bf:{help stset}}.{p_end}


{pstd}
The terms "generic" and "specific" are used here with reference to the {bf:{help admetan}} documentation,
and differentiate between derivation of effect sizes and standard errors which could, in the inverse-variance meta-analysis context,
be interpreted generically (although in practice, of course, the interpretation is governed by {it:command});
and the use of {bf:{help collapse}} to directly convert the IPD to an aggregate dataset with a specific data structure
such as a 2x2 contingency table, or means and SDs by treatment arm.
With {cmd:ipdmetan}, there is a substantial difference in syntax;
hence in the remainder of the {cmd:ipdmetan} documentation the terms "Syntax 1" and "Syntax 2" will be used.


{synoptset 34 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{it:{help admetan##options:admetan_options}}}any {bf:{help admetan}} options except {opt npts(varname)}{p_end}

{syntab :Syntax 1 only}
{synopt :{opt me:ssages}}print messages relating to success of model fits{p_end}
{synopt :{opt inter:action}}automatically identify and pool a treatment-covariate interaction{p_end}
{synopt :{opt pool:var(model_coefficient)}}specify explicitly the coefficient to pool{p_end}
{synopt :{opt notot:al}}suppress initial fitting of {it:command} to the entire dataset{p_end}
{synopt :{opt wgt(exp)}}user-defined weights{p_end}

{syntab :Syntax 2 only}
{synopt :{cmd:wgt(}[{opt (stat)}] {it:varname}{cmd:)}}user-defined weights{p_end}

{syntab :Syntax 2 with {opt logrank} only}
{synopt :{opt st:rata}}specify further variables by which to stratify the log-rank calculations{p_end}

{syntab :Combined IPD/aggregate data analysis}
{synopt :{cmd:ad(}{it:{help filename}} {ifin}{cmd:,} {help ipdmetan##aggregate_data_options:{it:aggregate_data_options}}{cmd:)}}
combine IPD with aggregate data stored in {it:filename}{p_end}

{syntab :Forest plots}
{synopt :{cmdab:lcol:s(}{help ipdmetan##cols_info:{it:cols_info}}{cmd:)} {cmdab:rcol:s(}{help ipdmetan##cols_info:{it:cols_info}}{cmd:)}}
display (and/or save) columns of additional data{p_end}
{synopt :{cmd:npts}}display participant numbers in the forest plot{p_end}
{synopt :{cmd:plotid(}{it:varname}{cmd:|_BYAD} [{cmd:, {ul:l}ist {ul:nogr}aph}]{cmd:)}}
define groups of observations in which to apply specific plot rendition options{p_end}
{synopt :{it:{help admetan##fplotopts:admetan_fplotopts}}}other options pertaining to the forest plot as described in {bf:{help admetan}}{p_end}
{synopt :{cmdab:forest:plot(}{help forestplot##options:{it:forestplot_options}}{cmd:)}}other options as described in {bf:{help forestplot}}{p_end}
{synoptline}

{pstd}
where {it:model_coefficient} is a variable name, a level indicator, an interaction indicator,
or an interaction involving continuous variables (c.f. syntax of {help test})

{marker cols_info}{...}
{pstd}
and where {it:cols_info} has the following syntax, which is based on that of {bf:{help collapse}}:

{pmore}
[{opt (stat)}] [{it:newname}=]{it:item} [{it:%fmt}] [{cmd:"}{it:label}{cmd:"}] [[{it:newname}=]{it:item} [{it:%fmt} {cmd:"}{it:label}{cmd:"}] ] {it:...} [ [{opt (stat)}] {it:...}]

{pmore}
where {it:stat} is as defined in {bf:{help collapse}};
{it:newname} is an optional user-specified variable name;
{it:item} is the name of either a numeric returned quantity from {it:command} (in parentheses, see {it:{help exp_list}})
or a variable currently in memory; {it:%fmt} is an optional {help format}; and {cmd:"}{it:label}{cmd:"} is an optional variable label.

{marker aggregate_data_options}{...}
{synopthdr :aggregate_data_options}
{synoptline}
{synopt :{opt vars(varlist)}}variables containing effect size and either standard error or 95% confidence limits, on the normal scale{p_end}
{synopt :{opt npts(varname)}}variable containing participant numbers{p_end}
{synopt :{opt byad}}IPD and aggregate data are to be treated as subgroups (rather than as a single set of estimates){p_end}
{synopt :{opt logr:ank}}specify that {opt vars()} are to be interpreted as {it:O-E} and {it:V}{p_end}
{synopt :{opt rel:abel}}force relabelling of studies within the combined IPD/aggregate dataset{p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:ipdmetan} performs two-stage individual participant-data (IPD) meta-analysis.  There are two basic syntaxes, as shown above.

{pstd}
Syntax 1 fits the model {it:command} once within each level of {it:study_ID}
and saves effect sizes and standard errors. By default these are pooled using inverse-variance, with output displayed on screen and in a forest plot.
Any e-class regression command (whether built-in or user-defined) should be compatible with this syntax of {cmd:ipdmetan}.

{pmore}
In the case of non e-class commands - those which do not change the contents of {cmd:e(b)} -,
the effect size and standard error statistics to be collected from the execution of {it:command}
must be specified manually by supplying {it:{help exp_list}}.
If {it:command} changes the contents in {cmd:e(b)}, {it:exp_list} defaults to
{cmd:_b[}{it:varname}{cmd:]} {cmd:_se[}{it:varname}{cmd:]},
where {it:varname} is the first independent variable within {it:command}.

{pstd}
Syntax 2 converts the IPD to aggregate data using {bf:{help collapse}};
after which any of the analysis methods used by {bf:{help metan}},
such as Mantel-Haenszel and Standardised Weighted Means, become applicable.

{pmore}
There are three ways in which {cmd:ipdmetan} Syntax 2 can convert IPD to aggregate data, as listed under {help ipdmetan##syntax:Syntax}.
In the first case (binary outcome; binary treatment variable), the data will be summarised by study as cell counts from a 2x2 contingency table.
In the second case (continuous outcome; binary treatment variable), the data will be summarised by study as means and SDs by treatment arm.
Finally, if a binary treatment variable alone is supplied and the data is {bf:{help stset}},
the survival data will be summarised by study using Peto logrank {it:O-E} and {it:V} statistics
(note that this supersedes {cmd:petometan} which previously formed part of the {cmd:ipdmetan} package).
These summaries correspond to the "specific effect measure" inputs listed in the {bf:{help admetan#syntax:admetan}} help file.

{pmore}
Note that with Syntax 2, the effect measure must be made explicit by use of an option such as {opt rr}, {opt or}, {opt hr}, {opt smd} or {opt logrank};
see {bf:{help admetan}} and {it:{help eform_option}}.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:study(}{it:study_ID} [{cmd:, missing}]{cmd:)} (required) specifies the variable containing the study identifier,
which must be either integer-valued or string.

{pmore}
{opt missing} requests that missing values be treated as potential study identifiers; the default is to exclude them.

{phang}
{opt interaction} (Syntax 1 only) indicates that {it:command} contains one or more interaction effects
supplied using factor-variable syntax (see {help fvvarlist}),
and that the first valid interaction effect should be pooled across studies.
This is intended as a helpful shortcut for performing two-stage "deft" interaction analyses as described in {help ipdmetan##references:Fisher 2017}.
However, it is not foolproof, and the identified coefficient should be checked carefully.
Alternatively, the desired coefficient to be pooled may be supplied directly using {opt poolvar()}.

{phang}
{opt messages} (Syntax 1 only) requests that information is printed to screen regarding whether effect size and standard error statistics
have been successfully obtained from each study, and (if applicable) whether the iterative random-effects calculations
converged successfully.

{phang}
{opt nototal} (Syntax 1 only) requests that {it:command} not be fitted within the entire dataset, e.g. for time-saving reasons.
By default, such fitting is done to check for problems in convergence and in the validity of requested coefficients and
returned expressions. If {opt nototal} is specified, either {opt poolvar()} or {it:exp_list} must be supplied,
and a message appears above the table of results warning that estimates should be double-checked by the user.

{phang}
{opt poolvar(model_coefficient)} (Syntax 1 only) allows the coefficient to be pooled to be explicitly stated in situations where it may not be obvious,
or where {cmd:ipdmetan} has made a previous incorrect assumption. {it:model_coefficient} should be a variable name,
a level indicator, an interaction indicator, or an interaction involving continuous variables (c.f. syntax of {help test}).
To use equations, use the format {cmd:poolvar(}{it:eqname}{cmd::}{it:varname}{cmd:)}.

{phang}
{opt strata(varlist)} (Syntax 2 with {opt logrank} only) specifies further variables to be used in log-rank calculations
but not be presented in the output.

{phang}
{opt wgt()} specifies user-defined weights. With Syntax 1, {opt wgt()} expects an expression involving returned statistics.
For example, to weight on the number of observations, you might specify {bf:wgt(e(N))}.
With Syntax 2, {opt wgt()} expects a {bf:{help collapse}}-based syntax.
Hence, again, to weight on the number of observations, you might specify {bf:wgt((sum) cons)} where {bf:cons} is a variable containing 1 for all observations. You should only use this option if you are satisfied that the weights are meaningful.

{pmore}
Note that the scale of user-defined weights is immaterial, since individual weights are normalised.
Hence, if {opt saving()} option is used, an analysis may be recreated from within the saved dataset
using the option {cmd:wgt(_WT)}.


{dlgtab:Combined IPD/aggregate data analysis}

{phang}
{cmd:ad(}[{it:{help filename}}] {ifin}{cmd:,} {it:aggregate_data_options}{cmd:)}
allows aggregate (summary) data may be included in the analysis alongside IPD, for example if some studies do not have IPD available.

{phang}
{it:aggregate_data_options} are as follows:

{pmore}
{opt vars(varlist)} contains the names of variables containing the effect size
and either a standard error or lower and upper 95% confidence limits, on the linear scale.
If {it:{help filename}} is supplied, {it:varlist} will be taken from within the external file;
otherwise {it:varlist} will be taken from the data currently in memory.
If confidence limits are supplied, they must be derived from a Normal distribution or the pooled result will not be accurate (see {bf:{help admetan}}).

{pmore}
{opt npts(varname)} allows participant numbers stored in {it:varname} within {it:filename} to be displayed in tables and forest plots.

{pmore}
{opt byad} specifies that aggregate data and IPD respectively are to be treated as subgroups.

{pmore}
{opt logrank} specifies that {opt vars(varlist)} contains the statistics {it:O-E} and {it:V}
rather than the default {it:ES} and {it:seES}.

{pmore}
{opt relabel} tells {cmd:ipdmetan} to re-label all studies sequentially as "1", "2", etc.,
(copying value labels across, if found) in the event that value labels do not agree between IPD and aggregate datasets.

{pmore}
Note that subgroups in aggregate data may be analysed in the same way as for IPD - that is, with the {opt by(varname)} option to {cmd:ipdmetan}.
{it:varname} may be found in either the data in memory (IPD), or in the aggregate dataset, or both.


{dlgtab:Forest plots}

{phang}
{cmd:lcols(}{help ipdmetan##cols_info:{it:cols_info}}{cmd:)}, {cmd:rcols(}{help ipdmetan##cols_info:{it:cols_info}}{cmd:)}
define columns of additional summary data to be presented to the left or right of the forest plot.
With {cmd:admetan} these options simply require a {it:varlist}, but in the IPD context the syntax is more complicated.
The user may specify summary statistics by which to {bf:{help collapse}} the data,
as well as characteristics of the summarised variables such as name, title and format which will be carried over to the forest plot.

{pmore}
Specifying {it:newname} is only necessary in circumstances where the name of the variable is important
in the dataset underlying the forest plot (i.e. the dataset created by {opt saving()} if applicable).
For example, you may have an aggregate dataset with a variable containing data equivalent to an {it:item},
and wish for all such data (whether IPD or aggregate) to appear in a single column in the forest plot.
To achieve this, specify {it:newname} as the name of the relevant variable in the aggregate dataset.
Make sure that the variables in the IPD and aggregate datasets do not have conflicting {help data_types} (e.g. string vs numeric)
or a {bf:{help merge}} error will be returned.

{pmore}
If {it:item} is an existing string variable, the first non-empty observation for each study will be used,
and {it:item} will not be displayed alongside overall or subgroup pooled estimates.
(This behaviour may also be forced upon a numeric variable by first converting it into a string using {bf:{help recode}} or {bf:{help tostring}}.)

{pmore}
Formatting of forest plot columns may be controlled using {help ipdmetan##cols_info:{it:cols_info}}.
Note that unlike {opt (stat)}, {it:%fmt} only applies to each immediately preceding {it:item}.
By default, Stata displays strings as right-justified.
A single string-valued forest plot column may be left-justified as described in {help format}.
To left-justify {ul:all} strings in the forest plot, the {help forestplot##options:{it:forestplot_option}} {opt leftjustify} has been provided.

{pmore}
(Note that the syntax of {opt lcols()} and {opt rcols()} with {bf:{help admetan}} and {bf:{help forestplot}} is as a list of existing variable names only.)

{phang}
{cmd:npts} requests that participant numbers be displayed in a column to the left of the forest plot.
This is effectively shorthand for {cmd:lcols(}{it:cols_info_defining_participant_numbers}{cmd:)}.

{phang}
{cmd:plotid(}{it:varname}{cmd:|_BYAD} [{cmd:, list nograph}]{cmd:)} is really a {bf:{help forestplot}} option, but has a slightly
extended syntax when supplied to {cmd:ipdmetan}.  {it:varname} may be replaced with {cmd:_BYAD} if the {opt byad} suboption
is supplied to {opt ad}, since in this case the subgrouping is not defined by an existing variable.

{pmore}
For further details of this option and the {opt list} and {opt nograph} suboptions, see {bf:{help forestplot}}.


{marker saved_results}{...}
{title:Saved results}

{pstd}{cmd:ipdmetan} saves the same results in {cmd:r()} as {bf:{help admetan}}, with the following additions:{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(command)}}Full estimation command-line{p_end}
{synopt:{cmd:r(cmdname)}}Estimation command name{p_end}
{synopt:{cmd:r(estexp)}}Name of pooled coefficient{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(coeffs)}}Matrix of study and subgroup identifiers, effect coefficients, numbers of participants, and weights{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Variables}{p_end}
{synopt:{cmd:_rsample}}Observations included in the analysis (c.f. {cmd:e(sample)}){p_end}

{pstd}
N.B. For obvious reasons, {help admetan##saved_results:new variables} {bf:_ES}, {bf:_seES} etc. are {ul:not} added to the data with {cmd:ipdmetan}.
They are instead returned within the matrix {cmd:r(coeffs)}.


{marker examples}{...}
{title:Examples}

{pstd}
Setup

{cmd}{...}
{* example_start - ipdmetan_setup1}{...}
{phang2}
. use "http://fmwww.bc.edu/repec/bocode/i/ipdmetan_example.dta", clear{p_end}
{phang2}
. stset tcens, fail(fail){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdmetan_setup1 using ipdmetan.sthlp, restnot:click to run})}{p_end}


{pstd}
Basic use

{phang2}
{cmd:. {stata "ipdmetan, study(trialid) hr by(region) nograph : stcox trt, strata(sex)"}}{p_end}


{pstd}
Use of {cmd:plotid()}

{cmd}{...}
{* example_start - ipdmetan_ex2}{...}
{phang2}
. ipdmetan, study(trialid) hr by(region) plotid(region){* ///}{p_end}
{p 16 20 2}
forest(favours(Favours treatment # Favours control) box1opts(mcolor(red)) ci1opts(lcolor(red) rcap){* ///}{...}
box2opts(mcolor(blue)) ci2opts(lcolor(blue))){* ///}{p_end}
{p 16 20 2}
: stcox trt, strata(sex){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdmetan_ex2 using ipdmetan.sthlp, restpres:click to run})}{p_end}


{pstd}
Treatment-covariate interactions

{cmd}{...}
{* example_start - ipdmetan_ex3}{...}
{phang2}
. ipdmetan, study(trialid) interaction hr keepall{* ///}{p_end}
{p 16 20 2}
forest(boxsca(200) fp(3){* ///}{p_end}
{p 16 20 2}
favours("Favours greater treatment effect" "with higher disease stage"{* ///}{...}
# "Favours greater treatment effect" "with lower disease stage")){* ///}{p_end}
{p 16 20 2}
: stcox trt##c.stage{p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdmetan_ex3 using ipdmetan.sthlp, restpres:click to run})}{p_end}


{pstd}
Aggregate data setup: create aggregate dataset from IPD dataset (for example purposes only)

{cmd}{...}
{* example_start - ipdmetan_setup2}{...}
{phang2}
. qui ipdmetan, study(trialid) hr nograph saving(region2.dta) : stcox trt if region==2, strata(sex){p_end}
{phang2}
. clonevar _STUDY = trialid{p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdmetan_setup2 using ipdmetan.sthlp, restpresnot:click to run})}{p_end}


{pstd}
Including aggregate data in the analysis

{cmd}{...}
{* example_start - ipdmetan_ex4}{...}
{phang2}
. ipdmetan, study(_STUDY) hr ad(region2.dta if _USE==1, vars(_ES _seES) npts(_NN) byad) nooverall{* ///}{p_end}
{p 16 20 2}
: stcox trt if region==1, strata(sex){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdmetan_ex4 using ipdmetan.sthlp, restpres:click to run})}{p_end}


{pstd}
Use of non e-class commands and {opt lcols()}: Peto log-rank analysis

{cmd}{...}
{* example_start - ipdmetan_ex5}{...}
{phang2}
. ipdmetan (u[1,1]/V[1,1]) (1/sqrt(V[1,1])), study(trialid) by(region) eform effect(Haz. Ratio){* ///}{p_end}
{p 16 20 2}
lcols((u[1,1]) %5.2f "o-E(o)" (V[1,1]) %5.2f "V(o)"){* ///}{p_end}
{p 16 20 2}
forest(nostats nowt favours(Favours treatment # Favours control)){* ///}{p_end}
{p 16 20 2}
: sts test trt, mat(u V){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdmetan_ex5 using ipdmetan.sthlp, restpres:click to run})}{p_end}


{pstd}
However, that was just to demonstrate Syntax 1 with a non e-class command.
The example is a Peto logrank survival analysis, which is much more straightforward using Syntax 2 and the {opt oev} option:

{cmd}{...}
{* example_start - ipdmetan_ex6}{...}
{phang2}
. ipdmetan trt, study(trialid) hr iv oev by(region){* ///}{p_end}
{p 16 20 2}
forest(nostats nowt favours(Favours treatment # Favours control)){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run ipdmetan_ex6 using ipdmetan.sthlp, restpres:click to run})}{p_end}



{title:Author}

{pstd}
David Fisher, MRC Clinical Trials Unit at UCL, London, UK.{p_end}

{pstd}
Email {browse "mailto:d.fisher@ucl.ac.uk":d.fisher@ucl.ac.uk}{p_end}



{title:Acknowledgments}

{pstd}
Thanks to Phil Jones at UWO, Canada for suggesting improvements in functionality.

{pstd}
The "click to run" element of the examples in this document is handled using an idea originally developed by Robert Picard.



{marker references}{...}
{title:References}

{phang}Fisher DJ. 2015. Two-stage individual participant data meta-analysis and generalised forest plots.
Stata Journal 15: 369-96{p_end}

{phang}Fisher DJ, Carpenter JR, Morris TP, Freeman SC, Tierney JF. 2017.
Meta-analytical methods to identify who benefits most from treatments: daft, deluded, or deft approach?
BMJ 356: j573{p_end}

