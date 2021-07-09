{smcl}
{* *! version 1.0.2)}
{hline}
{cmd:help clan}{right: ({})}
{hline}
{vieweralsosee "[R] mixed" "help mixed"}{...}
{viewerjumpto "Syntax" "clan##syntax"}{...}
{viewerjumpto "Menu" "clan##menu"}{...}
{viewerjumpto "Description" "clan##description"}{...}
{viewerjumpto "Options" "clan##options"}{...}
{viewerjumpto "Examples" "clan##examples"}{...}
{viewerjumpto "Stored results" "clan##results"}{...}
{viewerjumpto "Authors" "clan##authors"}{...}

{title:Title}

{p2colset 5 20 20 2}{...}
{p2col :{hi:clan} {hline 2}}Cluster-level analysis of data from a 
cluster randomised trial{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:clan}
        {it:{help depvar}}
        {it:{help indepvars}}
		{ifin}
        {cmd:,}
        {opth arm(varname)}
        {opth clus:ter(varname)}
        {opt eff:ect(effect)}
        [{it:options}]

{synoptset 29 tabbed}{...}
{marker options}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab : Main}
{p2coldent :* {opth arm(varname)}}variable defining the (two) trial 
arms{p_end}
{p2coldent :* {opth clus:ter(varname)}}variable defining the 
clusters{p_end}
{p2coldent :* {opth eff:ect(clan##effspec:effect)}}a descriptor 
telling {cmd:clan} which effect estimate you want to produce{p_end}
{synopt :{opth str:ata(varname)}}variable defining the (single) 
stratification factor used in the trial{p_end}
{synopt :{opth fup:time(varname)}}variable describing the follow-up 
time in trials where the outcome is time-to-event{p_end}
{synopt :{opt plot}}produce a scatter plot of cluster summaries
{p_end}
{synopt: {cmdab:sav:ing(}{it:{help filename}}[{cmd:, replace}]{cmd:)}}
save the cluster-level dataset in {it:filename.dta}. {p_end}
{synopt :{opth l:evel(#)}}set the level for confidence intervals; 
default is 95%{p_end}
{synoptline}
{p 4 6 2}*these options are required{p_end}
{p 4 6 2}{it:indepvars} may contain factor variables, but cannot 
contain interactions{p_end}
{p2colreset}{...}

{synoptset 30}{...}
{marker effspec}{...}
{synopthdr :effect}
{synoptline}
{synopt :{opt rr}}risk ratio{p_end}
{synopt :{opt rd}}risk difference{p_end}
{synopt :{opt rater}}rate ratio{p_end}
{synopt :{opt rated}}rate difference{p_end}
{synopt :{opt mean}}mean difference{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:clan} performs analysis of cluster randomised trials at the 
cluster level allowing for stratification and adjustment for 
individual- and cluster-level covariates. {it: depvar} gives the 
outcome, and {it: indepvars} give adjustment covariates.

{pstd}
If any independent variables are included, an appropriate regression 
model (logistic, linear, or Poisson) is run on the outcome with these
 variables but {it:without} the arm variable and {it:ignoring} 
 clustering. The residuals are then summarised by cluster. If no 
 independent variables are included, the outcome itself is summarised
 by cluster. For a binary outcome, these summaries are cluster 
 proportions; for a continuous outcome, they are cluster means; for a
 time-to-event outcome, they are rates. For calculation of ratio 
 estimators, the command uses the logarithm of the summaries.

{pstd}
These cluster summaries are then compared between the arms in a 
linear regression adjusting for the stratification variable if it 
is specified.

{pstd}
Degrees of freedom are calculated from the number of clusters and 
then penalising by: two to account for the treatment arms; one fewer than
 the number of stratification levels; and one for each cluster-level 
 variable included in the first stage regression.

{pstd}
The data in memory will not be altered by this command.

{marker options}{...}
{title:Options}

{phang}
{opth arm(varname)} is the variable which identifies the two trial 
arms.
It must be coded 0/1.

{phang}
{opth clus:ter(varname)} is the variable which describes the 
clusters. It must be a numeric variable.

{phang}
{opt eff:ect(effect)} specifies which measure of effect you wish to 
calculate. If {it:rr} or {it:rater} are specified, the confidence 
interval will be calculated on the log scale and the estimate will be
 the ratio of geometric means of the cluster summaries. If any 
 cluster has zero events, 0.5 will be added to all cluster totals to
 allow logarithms to be taken.

{phang}
{opth str:ata(varname)} is the variable which identifies the 
stratification used in the trial randomisation. Only one 
stratification factor is permitted. It must be a numeric variable.

{phang}
{opth fup:time(varname)} is the variable which gives the length of 
time each participant was in the study; this is necessary to 
calculate time-to-event when either rate differences or ratios are to
 be calculated.

{phang}
{opt plot} produces a scatter plot of the cluster summaries used to 
produce the effect measure. For adjusted analyses these will be 
summaries of residual values, and hence will not have a direct 
interpretation.

{phang}
{cmdab:saving(}{it:{help filename}}[{cmd:, replace}]{cmd:)} saves a 
dataset with the cluster summaries. A new filename is required unless
 {opt replace} is also specified. {opt replace} allows the 
 {it:filename} to be overwritten with new data.

{phang}
{opt l:evel(#)} sets the confidence level; the default is {cmd:level(95)}



{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. net get clan}{p_end}
{phang2}{cmd:. sysuse mkvtrial, clear}{p_end}

{pstd}Analyse intervention effect on the knowledge of HIV; estimate risk 
ratio{p_end}
{phang2}{cmd:. clan know, arm(arm) clus(community) effect(rr)}{p_end}

{pstd}Adjust for the effect of age
{p_end}{phang2}{cmd:. clan know i.agegp, arm(arm) clus(community) effect(rr) plot}
{p_end}

{pstd}Also include a stratification factor, and produce a 99% 
confidence interval{p_end}
{phang2}{cmd:. clan know i.agegp, arm(arm) clus(community) strata(stratum) effect(rr) level(99)}{p_end}

{pstd}Calculate risk difference instead, and plot cluster summaries
{p_end}
{phang2}{cmd:. clan know, arm(arm) clus(community) effect(rd) plot}
{p_end}

{pstd}Note that when an adjusted model is run, the cluster summaries 
are not interpretable{p_end}
{phang2}{cmd:. clan know i.agegp, arm(arm) clus(community) effect(rd) plot}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:clan} stores the following in {cmd:e()}:

{synoptset 18 tabbed}{...}
{p2col 5 20 20 4: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of clusters{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(p)}}p-value{p_end}
{synopt:{cmd:e(lb)}}lower bound of confidence interval{p_end}
{synopt:{cmd:e(ub)}}upper bound of confidence interval{p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}

{p2col 7 20 24 2: Depending on effect specified:}{p_end}
{synopt:{cmd:e(rd)}}estimated risk difference{p_end}
{synopt:{cmd:e(rr)}}estimated risk ratio{p_end}
{synopt:{cmd:e(rated)}}estimated rate difference{p_end}
{synopt:{cmd:e(rater)}}estimated rate ratio{p_end}
{synopt:{cmd:e(mean)}}estimated mean difference{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:clan}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector from the regression in the 
second stage{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators
{p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{p2colreset}{...}

{marker references}{...}

{title:References}

{phang}
RJ Hayes and LH Moulton. Cluster Randomised Trials;
Chapman and Hall/CRC; Second edition, 2017; ISBN 9781498728225

{phang}
RJ Hayes, and S Bennett. Simple sample size calculation for 
cluster-randomized trials; 
IJE 1999; 28:2:319-326 doi: 10.1093/ije/28.2.319

{phang}
S Bennett, T Parpia, R Hayes, and S Cousens. Methods for the analysis
 of incidence rates in cluster randomized trials; IJE 2002; 31:4:
 839-846 doi: 10.1093/ije/31.4.839

{marker Authors}{...}

{title:Authors}

Stephen Nash, Jennifer Thompson, Baptiste Leurent
London School of Hygiene and Tropical Medicine
London, UK
jennifer.thompson@lshtm.ac.uk
baptiste.leurent@lshtm.ac.uk
