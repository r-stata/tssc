{smcl}
{* *! version 1.0 22feb2014}{...}

{cmd:help estrat}
{hline}

{title:Title}

{p 4 8 2} {hi:estrat} {hline 2} Endogenous Stratification for Randomized Experiments.{p_end}

{title:Syntax}

{p 4 18 2}
{cmdab:estrat} {it:{help varname:depvar}} {it:{help varname:treatment}} {it:{help varlist:predictors}}
{ifin}
[{cmd:,}
{it:options}]

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt groups(real)}}specifies the number of sub-groups{p_end}
{synopt:{opt cov(varlist)}}specifies covariates used when estimating treatment effects{p_end}
{synopt:{opt reps(real)}}specifies the number of repeated split sample (RSS) repetitions{p_end}
{synopt:{opt boot(real)}}specifies the number of bootstrap repetitions{p_end}
{synopt:{opt loo_only}}instructs the program to only estimate leave-one-out (LOO) results. {p_end}
{synopt:{opt rss_only}}instructs the program to only estimate repeated-split-sample (RSS) results. {p_end}
{synopt:{opt savegroup}}saves the group number assigned to each observation in the LOO calculation. {p_end}

{synoptline}
  
{title:Description}

{pstd}
{opt estrat} implements leave-one-out (LOO) and repeated split sample (RSS) estimators for randomized experiments. For further details see Abadie, Chingos, and West (2013).{p_end}

{title:Required}

{phang}
{cmd:depvar} {it:{help varname}} that specifies the dependent variable. 
 
{phang}
{cmd:treatment} {it:{help varname}} that specifies the treatment indicator (binary).
     
{phang}
{cmd:predictors} {it:{help varlist}} that specifies the variables used to generate predicted outcomes. 

{title:Options}

{phang}
{opt groups} specifies the number of sub-groups for which to predict outcomes. Defaults to 3.

{phang}
{opt cov} specifies which covariates to use, if any, when estimating the treatment effect.

{phang}
{opt reps(real)} specifies the number of repeated split sample (RSS) repetitions. Defaults to 100.

{phang}
{opt boot(real)} specifies the number of bootstrap repetitions. Defaults to 100.

{phang}
{opt loo_only} instructs the program to only estimate leave-one-out (LOO) results. 

{phang}
{opt rss_only} instructs the program to only estimate repeated-split-sample (RSS) results.

{phang}
{opt savegroup} saves the group number assigned to each observation in the LOO calculation in the variable "estrat_loo_group"


{title:Examples}

    Load example data
	{stata "use jtpa.dta":. use jtpa.dta}

    Basic syntax
	{stata " estrat earnings assignmt prevearn":. estrat earnings assignmt prevearn}
	{stata " estrat earnings assignmt prevearn, groups(4)":. estrat earnings assignmt prevearn, groups(4)}

    By default, estrat calculates unadjusted treatment effects. This can be modified by specifying the covariate option
	{stata " estrat earnings assignmt prevearn, cov(prevearn age)":. estrat earnings assignmt prevearn,  cov(prevearn age)}

    Adjusting the number of repetitions
	{stata " estrat earnings assignmt prevearn age, rep(200) boot(500)":. estrat earnings assignmt prevearn age, rep(200) boot(500)}

{title:Saved results}

{p 4 8 2}
By default, {cmd:estrat}  ereturns the following results, which can be displayed by typing {cmd: ereturn list} after 
{cmd:estrat} is finished (also see {help ereturn}).

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(groups)}}  the number of groups{p_end}
{synopt:{cmd:e(rssrep)}}  the number of RSS reps{p_end}
{synopt:{cmd:e(bootrep)}}  the number of bootstrap reps{p_end}
{synopt:{cmd:e(treated)}}  the number of treated observations{p_end}
{synopt:{cmd:e(untreated)}}  the number of untreated observations{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end} 
{synopt:{cmd:e(covariates)}}  list of covariates {p_end}
{synopt:{cmd:e(predictors)}}  list of predictors{p_end}
{synopt:{cmd:e(treatment)}}  the treatment indicator{p_end}
{synopt:{cmd:e(depvar)}}  the dependent variable{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end} 
{synopt:{cmd: e(RSS_C)}} RSS coefficients {p_end}
{synopt:{cmd: e(RSS_SE)}} RSS bootstrapped standard errors {p_end}
{synopt:{cmd: e(LOO_C)}} LOO coefficients {p_end}
{synopt:{cmd: e(LOO_SE)}} LOO bootstrapped standard errors {p_end}

{title:References}

{p 4 8 2}
Abadie, A. Chingos, M. West, M. 2013. "Endogenous Stratification in Randomized Experiments". NBER Working Paper.
 
{title:Package Author}

      Jeremy Ferwerda, ferwerda@mit.edu
