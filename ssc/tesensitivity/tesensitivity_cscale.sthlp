{smcl}
{* *! version 1.2.1  07mar2013}{...}
{vieweralsosee "tesensitivity" "tesensitivity"}{...}
{viewerjumpto "Syntax" "tesensitivity_cscale##syntax"}{...}
{viewerjumpto "Description" "tesensitivity_cscale##description"}{...}
{viewerjumpto "Options" "tesensitivity_cscale##options"}{...}
{viewerjumpto "Remarks" "tesensitivity_cscale##remarks"}{...}
{viewerjumpto "Stored Results" "tesensitivity_cscale##results"}{...}
{viewerjumpto "Examples" "tesensitivity_cscale##examples"}{...}
{title:Title}

{phang}
{bf:tesensitivity cscale} {hline 2} c-dependence scale analysis

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:tesensitivity} {cmd:cscale} [{it:{help varlist:varlist}}]
[{cmd:,} 
{it:{help tesensitivity_cscale##options:options}}]

{phang}
{it:varlist} is a subset of covariates to be included in the analysis

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt:{opt cmax}}include the maximum propensity score deviation for each covariate{p_end}
{synopt:{opt quantiles(numlist)}}quantiles of the propensity score deviation distributions to include{p_end}
{synopt:{opt density}}plot density of propensity score deviations for the specified covariate{p_end}
{synoptline}
{p 4 6 2}

{marker description}{...}
{title:Desciption}

{pstd}
{cmd:tesensitivity cscale} is a post estimation command that helps interpret
the scale of the sensitivity parameter c used in c-dependence. Propensity scores obtained
from the full model are compared to propensity scores obtained when leaving out
one of the covariates. This induces a distribution over the support of the covariates. The options {cmd:cmax} and {cmd:quantiles} select the
features of this distribution to calculate for each omitted covariate. If either of these
options are selected, the results are displayed in a table and stored in {cmd:r()}. 
If the {cmd:density} option is selected, then a kernel density of the propensity
score deviations is plotted for the selected covariate.

{pstd}
For a discussion of the interpretation of this analysis and its relationship
to c-dependence see Remarks.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd: cmax} Calculate the supremum over the distribution of the distribution of the 
difference between full-model and leave-one-out propensity scores.

{phang}
{cmd: quantiles(numlist)} A numlist of quantiles. Calculate each of these quantiles 
of the distribution of the difference between full-model and leave-one-out 
propensity scores.

{phang}
{cmd: density} Calculate and plot the density of the distribution of the difference
between full-model and leave-one-out propensity scores for a given covariate.
 
{p 8 8 2} Note: if no options are specified, then the
default options {cmd:quantiles(.5, .75, .9)} {cmd:cmax} are used. If any options are
selected, this default is ignored. 
 
{marker remarks}{...}
{title:Remarks}

{p 4 4 4}
See {help tesensitivity##further_information:here} for links to the articles 
this package is based on, more detailed documentation on the implementation in 
this package, and examples of its use. 
 
{marker results}{...}
{title:Stored results}

{cmd:tesensitivity cscale} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(cmax)}}maximum propensity score deviations for each covariate{p_end}
{synopt:{cmd:r(cquantiles)}}quantiles of the distribution of propensity score deviations for each covariates{p_end}

{marker examples}{...}
{title:Examples}

{phang} For examples see this {browse "https://github.com/mattmasten/tesensitivity/blob/master/vignette/vignette.pdf":vignette}.

 
