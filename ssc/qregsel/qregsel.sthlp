{smcl}
{* *! version 1.1 September 2020}{...}
{cmd: help qregsel}
{hline}

{title:Title}

{phang}
{bf:Quantile Regression Corrected for Sample Selection}

{title:Syntax}

{p 8 17 2}
{cmd:qregsel}
{it:depvar} {it:varlist}
{ifin} 
{cmd:,}
{cmdab:sel:ect(}[{it:depvar_s} {cmd:=}] {it:varlist_s}{cmd:)}
{cmd:quantile(}{it:#}{cmd:)}
[
{cmd:copula(}{it:copula}{cmd:)}
{cmdab:nocons:tant}
{cmdab:finergrid}
{cmdab:rescale}
]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sel:ect()}}specifies a selection equation.{p_end}

{synopt:{opt quantile:(#)}}specifies the quantiles to be estimated.{p_end}

{synopt:{opt copula:(copula)}}specifies a copula;
	default is gaussian.{p_end}

{synopt:{opt nocons:tant}}suppresses a constant term in the outcome equation.{p_end}

{synopt:{opt finergrid:}}find the value of the copula parameter using a grid of 199 values instead of 100, as done by default.{p_end}

{synopt:{opt rescale:}}rescale the regressors in the outcome equation.{p_end}



{title:Description}

{pstd}
{cmd:qregsel} estimates a copula-based sample selection model for quantile regression.
Users can specify a copula from the lists below. 

{p 4 4 2}
Available copulas are {it: gaussian} and {it:frank}.

{p 4 4 2} 
Notes: The name of the copula is case-sensitive. 


{title:Options}

{dlgtab:Main}

{phang}
{opt sel:ect()} is required. It specifies a selection equation. 
If {it:depvar_s} is specified, it should be coded as 0 or 1, which 0 indicating {it:depvar} not observed for an observation 
and 1 indicating {it:depvar} observed for an observation. 

{phang} 
{opt quantile(#)} is required. It specifies a set of quantiles to be estimated.

{phang}
{opt copula(copula)} specifies a copula function for the dependence between outcome and selection equation.
See above for the list of available copulas. 
Default is {bf:gaussian}. 

{phang}
{opt noncons:tant} suppresses a constant term of the outcome equation.

{phang}
{opt finergrid} find the value of the copula parameter using a grid of 199 values instead of 100, as done by default. These values are chosen such that U and V have a rank correlation between -.99 and .99.

{phang}
{opt rescale} rescale the regressors of the outcome equation substracting sample mean and dividing by standard deviation..
 

{title:Saved results}

{pstd}
{cmd:qregsel} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(rank)}}number of parameters{p_end}
{synopt:{cmd:e(df_r)}}degrees of freedom{p_end}
{synopt:{cmd:e(rho)}}copula parameter{p_end}
{synopt:{cmd:e(kendall)}}Kendall's tau{p_end}
{synopt:{cmd:e(spearman)}}Spearman's rank correlation{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(copula)}}specified {cmd:copula}{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(indepvar)}}independent variables{p_end}
{synopt:{cmd:e(cmdline)}}command line{p_end}
{synopt:{cmd:e(outcome_eq)}}outcome equation{p_end}
{synopt:{cmd:e(select_eq)}}selection equation{p_end}
{synopt:{cmd:e(cmd)}}{cmd:qregsel}{p_end}
{synopt:{cmd:e(predict)}}predict command name{p_end}
{synopt:{cmd:e(rescale)}}use of rescale option{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(coefs)}}coefficient matrix. Each column corresponds to the coefficients for a quantile{p_end}
{synopt:{cmd:e(grid)}}matrix with the values of the objective function for each value of rho, and its respective Spearman rank correlation and Kendall's tau{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{title:Examples}

{cmd:. webuse womenwk, clear}
{cmd:. qregsel wage educ age, select(married children educ age) quantile(.1 .5 .9)}
{cmd:. ereturn list}

{title:References}

{pstd}
Arellano, M., and S. Bonhomme. 2017.
"Quantile  Selection  Models  With  an  Application  to  Understanding Changes in Wage Inequality." Econometrica 85(1): 1–28.

{title:Authors}
{p}
{p_end}

{pstd}
Ercio Munoz, CUNY Graduate Center, New York, US.

{pstd}
Email: {browse "mailto:emunozsaavedra@gc.cuny.edu":emunozsaavedra@gc.cuny.edu}

{pstd}
Mariel Siravegna, Georgetown University, Washington DC, US.

{pstd}
Email: {browse "mailto:mcs92@georgetown.edu":mcs92@georgetown.edu}

{title: Also see}

{psee}
Online: {help heckman}, {help qreg}, {help heckmancopula}





