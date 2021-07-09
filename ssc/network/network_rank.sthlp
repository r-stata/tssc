{smcl}
{* *! version 1.1 27may2015}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Main network help page" "network"}{...}
{viewerjumpto "Syntax" "network_rank##syntax"}{...}
{viewerjumpto "Description" "network_rank##description"}{...}
{viewerjumpto "Examples" "network_rank##examples"}{...}
{title:Title}

{phang}
{bf:network rank} {hline 2} Rank treatments after network meta-analysis 


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network rank} {cmd:min|max} {ifin} [, {it:mvmeta_pbest_options}]

{pstd}{cmd:network rank} makes sensible choices for
{cmd:if} and {cmd:in} which it would be unwise to change.

{pstd}{it:mvmeta_pbest_options} are any {help mvmeta##pbest:suboptions for the pbest option of mvmeta}.
{cmd:network rank} makes sensible choices for
{cmd:zero} and {cmd:id()} which it would be unwise to change.
The options listed below are likely to be useful.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:mvmeta_pbest_options}
{synopt:{opt all}}Reports probabilities for all ranks. 
The default is to report only the probabilities of being the best treatment.{p_end}
{synopt:{opt rep:s(#)}}Set the number of replicates - larger numbers reduce Monte Carlo error{p_end}
{synopt:{opt seed(#)}}Set the random number seed for reproducibility{p_end}
{synopt:{opt bar}}Draw a bar graph of ranks{p_end}
{synopt:{opt line}}Draw a line graph of ranks{p_end}
{synopt:{opt cum:ulative}}Make the bar or line graph show cumulative ranks{p_end}
{synopt:{opt pred:ict}}Ranks the true effects in a future study with the same covariates, 
thus allowing for heterogeneity as well as parameter uncertainty, 
as in the calculation of prediction intervals {help mvmeta##Higgins++09:(Higgins et al, 2009)}.
The default behaviour is instead to rank linear predictors and does not allow for heterogeneity.{p_end}
{synopt:{opt mean:rank}}Tabulate the mean rank and the SUCRA {help mvmeta##Salanti++11:(Salanti et al, 2011)}. 
The SUCRA is the rescaled mean rank: it
is 1 when a treatment is certain to be the best and 0 when a treatment is certain to be the worst.{p_end}
{synopt:{opt saving(filename)}}Writes the draws from the posterior distribution 
(indexed by the identifier and the replication number) to {it:filename}.{p_end}
{synopt:{opt replace}}Allows {it:filename} in {cmd:saving(}{it:filename}{cmd:)} to be overwritten.{p_end}
{synopt:{opt clear}}Loads the rank data into memory and gives the commands needed to reproduce the table and graph.{p_end}
{syntab:Other options}
{synopt:{opt trtc:odes}}makes the display use the treatment codes rather than the treatment names.{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:network rank} ranks treatments after a network meta-analysis has been fitted. 
This currently only works after running {cmd:network meta consistency} or {cmd:network meta inconsistency} 
in the {cmd:augmented} format.

{pstd}
Use {cmdab:network rank min} if the best treatment is that with the lowest (most negative) treatment
effect
and {cmdab:network rank max} if the best treatment is that with the highest (most positive) treatment
effect.

{pstd}
After fitting the inconsistency model, and after fitting a meta-regression, 
the treatment effect - and hence the ranking - differs across studies. 
{cmd:network rank} therefore computes and displays ranks for all studies unless {cmd:if} or {cmd:in} is specified.
After fitting the consistency model without covariates, on the other hand, 
the ranks are the same for all studies
and {cmd:network rank} displays ranks for just the first study. 


{marker examples}{...}
{title:Examples}

{pstd}Assume the thrombolytics data have been loaded and the consistency model has been fitted.

{pstd}Find the probabilities that each treatment is the best 
(i.e. lowest log hazard ratio)
under the consistency model:

{pin}. {stata network rank min}

{pstd}The same, setting the seed (for reproducibility); 
considering all ranks, not just the best; drawing a rankogram; 
and increasing the number of replicates (to reduce Monte Carlo error):

{pin}. {stata network rank min, seed(48106) all line cumul reps(10000) meanrank}



{p}{helpb network: Return to main help page for network}

