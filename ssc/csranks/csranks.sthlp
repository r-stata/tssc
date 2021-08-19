{smcl}
{* *! version 1.0 13 Jan 2021}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install csranks" "ssc install csranks"}{...}
{vieweralsosee "Help csranks (if installed)" "help csranks"}{...}
{viewerjumpto "Syntax" "csranks##syntax"}{...}
{viewerjumpto "Description" "csranks##description"}{...}
{viewerjumpto "Options" "csranks##options"}{...}
{viewerjumpto "Remarks" "csranks##remarks"}{...}
{viewerjumpto "Examples" "csranks##examples"}{...}

{title:Title}

{phang}
{bf:csranks} {hline 2} construct uniformly asymptotically valid confidence sets on ranks

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:csranks,}
{opt id(varname)} {opt mean(varname)} {opt se(varname)}  [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required }
{synopt:{opt id(varname)}}  unique identifier of observations to be ranked{p_end}
{synopt:{opt mean(varname)}}  sample means{p_end}
{synopt:{opt se(varname)}}  sample standard error of means{p_end}

{syntab:Optional}
{synopt:{opt simul:taneous}}  returns simultaneous confidence set over all observations (otherwise, returns marginal confidence intervals){p_end}
{synopt:{opt b:oot(#)}}  number of bootstrap replications (default = 1000), required if {cmd:simultaneous}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:csranks} implements the methods in "Inference on Ranks with Applications to Mobility Across Neighborhoods and Academic Achievement Across Countries" by Magne Mogstad, Joseph P. Romano, Azeem M. Shaikh, and Daniel Wilhelm (2020). They introduce methods to construct uniformly asymptotically valid two-sided confidence intervals on the ranks of observations in a distribution. These methods require only the means and standard error of means of observations of the observations to be ranked, under an independence assumption across observations. This program implements their methods for marginal confidence intervals that are valid for individual observations as well as for the simultaneous confidence set over all observations.{p_end}

{pstd}
{cmd:csranks} adds three new variables to the data, which are named after the {cmd:id} variable: the minimum rank in the confidence region ({cmd:id_rk_min}), the maximum rank in the confidence region ({cmd:id_rk_max}), and the rank of the original estimate ({cmd:id_rk_mean}). Observations are ranked in decreasing order of the variable.{p_end}

{marker stored}{...}
{title:Stored Results}

{pstd}{cmd:csranks} stores the following in {cmd:e():}{p_end}

{synoptset 24 tabbed}{...}
{syntab:Scalars}

{synopt:{cmd:e(N)}}Number of observations identified by {cmd:id}{p_end}

{synopt:{cmd:e(critval)}}Stores critical value of test statistic.: 1.96 in the case of marginal confidence intervals, obtained by parametric bootstrap in the case of a simultaneous confidence set.{p_end}

{marker examples}{...}
{title:Examples}

{pstd}1. You have a data set of the average standardized test scores (contained in {cmd:est}) of 100 schools (uniquely identified by {cmd:sid}), along with standard errors for each estimate (contained in {cmd:stderr}). This code would construct the simultaneous confidence set on the ranking of all schools.{p_end}

{pstd}{cmd:. set obs 100} {break}
{cmd: . gen sid = _n}{break}
{cmd: . gen estimate = _n + rnormal()}{break}
{cmd: . gen stderr = exp(1 + 0.5*rnormal())}{break}
{cmd: . csranks, id(sid) mean(estimate) se(stderr) simultaneous b(1000)}
{p_end}

{pstd}2. You have a data set of the average standardized test scores (contained in {cmd:est}) of 100 schools (uniquely identified by {cmd:sid}), along with standard errors for each estimate (contained in {cmd:stderr}). This code would construct marginal confidence intervals on the rank of each school. For example, these confidence intervals would be appropriate if you wanted to test the null hypothesis that the school identified by {cmd:sid} == 10 had a rank equal to 1.{p_end}

{pstd}{cmd:. set obs 100} {break}
{cmd: . gen sid = _n}{break}
{cmd: . gen estimate = _n + rnormal()}{break}
{cmd: . gen stderr = exp(1 + 0.5*rnormal())}{break}
{cmd: . csranks, id(sid) mean(estimate) se(stderr)}{break}
{cmd: . di sid_rk_max if id == 10}{break}
{cmd: . di sid_rk_min if id == 10}
{p_end}

{title:Prerequisite}

{pstd}To run, {cmd:csranks} requires that you pre-install the Stata command {help gtools}, available from the SSC.{p_end}

{title:Citation of csranks}

{pstd}{cmd:csranks} is not an official Stata command. It is a free contribution to the research community. Please cite it as such using the following format:{p_end}

{phang}Soltas, E. 2021. "csranks: uniformly asymptotically valid confidence sets on ranks. {browse "http://ideas.repec.org/c/boc/bocode/s458898.html":http://ideas.repec.org/c/boc/bocode/s458898.html} {p_end}

{title:Author}

{pstd}Evan Soltas{break}
MIT Economics{break}
Email: {browse "mailto:esoltas@mit.edu":esoltas@mit.edu}
{p_end}

{marker references}{...}
{title:References}

{phang}
Magne Mogstad, Joseph P. Romano, Azeem M. Shaikh, and Daniel Wilhelm. "Inference on Ranks with Applications to Mobility Across Neighborhoods and Academic Achievement Across Countries."
{it:Becker Friedman Institute Working Paper 2020-16, University of Chicago.}
{browse "https://bfi.uchicago.edu/wp-content/uploads/BFI_WP_202016.pdf":[link]}
{p_end}

{phang}
R package for csranks. 
{browse "https://danielwilhelm.github.io/R-CS-ranks/":https://danielwilhelm.github.io/R-CS-ranks/}
{p_end}
