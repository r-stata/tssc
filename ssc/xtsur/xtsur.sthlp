{smcl}
{* *! version 1.0.4  11Dec2009}{...}
{cmd: help xtsur}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi: xtsur} {hline 2}}One-way random effect estimation of seemingly-unrelated regressions (SUR) in unbalanced panel data set
{p2colreset}{...}

{title:Syntax}

{phang}
Basic syntax

{p 8 16 2}
{cmd:xtsur }{cmd:(}{it:depvar1} {it:varlist1}{cmd:)} {cmd:(}{it:depvar2} {it:varlist2}{cmd:)} {it:...}{cmd:(}{it:depvarN}
{it:varlistN}{cmd:)} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
[{cmd:,}
{cmdab:l:evel:(}{it:#}{cmd:)}
{cmdab:one:step}
{cmdab:multi:step}
{cmdab:tol:erance:(}{it:real 1e-6}{cmd:)}]

{phang}
Full syntax

{p 8 14 2}
{cmd:xtsur} {cmd:(}[{it:eqname1}{cmd::}]{it:depvar1a}
	[{it:depvar1b} {it:...}{cmd:=}]{it:varlist1} 
        {cmd:)}{break}
        {cmd:(}[{it:eqname2}{cmd::}]{it:depvar2a}
	[{it:depvar2b} {it:...}{cmd:=}]{it:varlist2} 
        {cmd:)}{break}
        {it:...}{break}
        {cmd:(}[{it:eqnameN}{cmd::}]{it:depvarNa}
	[{it:depvarNb} {it:...}{cmd:=}]{it:varlistN} 
        {cmd:)}{break}
	[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
	[{cmd:,}
	{cmdab:l:evel:(}{it:#}{cmd:)}
	{cmdab:one:step}
	{cmdab:multi:step}
	{cmdab:tol:erance:(}{it:real 1e-6}{cmd:)}]{p_end}

{title:Description}

{pstd}
{cmd:xtsur} fits a many-equation seemingly-unrelated regression (SUR) model of the {it:y1} variable on the {it:x1} variables and 
the {it:y2} variable on the {it:x1} or {it:x2} variables and etc..., using random effect estimators in the context of unbalanced panel data.
The approach for this command is based on constructing a multistep (stepwise) algorithm using Generalized Least Squares (GLS) and the Maximum 
Likelihood (ML) procedures. The method is originally developed by Erik Biorn (JoE).

{pstd} 
In order to run this command, {cmd:tsset} must be run to set the panel variable and time variable; see help {help tsset}.

{pstd}
Consider the system of G equation model:

{p 4 12 2}y_git = {bind:x_git * b_g} + u_git
{space 4} i=1,...,N; {space 2} t=1,...,Ti; {space 2} g=1,...,G{p_end}
{p 4 12 2}u_git = v_gi + e_git,{p_end}

{pstd}
where

{p 4 12 2}v_gi are unobserved individual-level effects in the {it:g}th equation;{p_end}

{p 4 12 2}e_git are the observation-specific errors in the {it:g}th equation;{p_end}

{p 4 12 2}x_git is a vector of strictly exogenous covariates (ones dependent on neither current nor past e_git) in the {it:g}th equation;{p_end}

{p 4 12 2}b_g are vectors of parameters to be estimated in the {it:g}th equation;{p_end}

{pstd}
Observations in the unbalanced data set are observed in at least one and at most P periods, and let N_p denotes the number 
of individuals observed in p periods, where p = 1,...,P. Hence, we can rearranged the unbalaned data set in the way that the 
N_1 individuals observed once come first, the N_2 individuals observed twice come second, N_3 individuals observed three times 
come third, and etc. In this way, we can consider the set of N_1 individuals as a cross section, and the sets of N_p individuals
where p = 2,...,P as balanced panels.

{pstd}
For each {it:g}th equation in the system, we can write the model as follows. Here, t is a sequence index, not a time index.

{p 4 12 2}y_git = {bind:x_git * b_g} + v_gi + e_git
{space 4} i=1,...,N; {space 2} t=1,...,Ti; {space 2} g=1,...,G{p_end}

{pstd}
Observations in the unbalanced panel are rearranged into P balanced panels. In each balanced panel, all observations 
are observed with the same number of periods. Therefore, the model can be rewritten for each p in P:

{p 4 12 2}y_i(p) = {bind:x_i(p) * b} + e_p # v_i + e_i(p){p_end}

{pstd}
where

{p 4 12 2}e_p is vector of ones (p x 1);{p_end}
{p 4 12 2}# is the Kronecker direct product.{p_end}

{pstd}
Using the overall within-individual and between-individual covariation matrices, Biorn (2004) derived the unbiased 
estimators of sigma_v and sigma_e for each balanced panel. Using those estimated covariance matrices, the GLS problem 
is considered by minimizing the usual sandwich form with respect to parameter estimates. We then obtain the beta GLS estimator (bGLS_p) 
for the individuals observed p times. The overall GLS estimator can be shown to be the function of bGLS_p and their variances V(bGLS_p) 
for p = 1,...,P. Please see Biorn (2004) for details.

{pstd}
In order to get the efficient estimator of the SUR system, the multistep (stepwise) Maximum Likelihood estimation is implemented.
The multistep is the problem of two sub-problems: (a) maximizing the log likelihood with respect to beta parameters for given sigma_v and sigma_e, 
which is the same as the GLS part above, and (b) maximizing the log likelihood with respect to sigma_v and sigma_e for given beta 
parameters. The multistep algorithm jointly solves (a) and (b), and it will stop until convergence of the overall estimates.

{pstd}
For details of the estimation procedures and simulations for this command, {cmd:xtsur}, please refer to Minh Nguyen and Hoa Nguyen (2010).

{title:Options}

{p 4 8 2}{cmd:level(}{it:#}{cmd:)} specifies the confidence level, in percent,
for confidence intervals of the coefficients; see help {help level}. The default is 95.

{p 4 8 2}{cmd:multistep} implements the multi-step algorithm where the estimated
parameters are repeated until convergence from the multi-step ML and GLS procedures.

{p 4 8 2}{cmd:onestep} implements the one-step algorithm where an overall GLS estimate is
obtained. The default method is {cmd:multistep}.

{p 4 8 2}{cmd:tolerance(#)} sets the convergence tolerance. The default tolerance is 1e-6.

{title:Return values}

{col 4}Scalars
{col 8}{cmd:e(N)}{col 21}number of complete observations in unbalanced panel data
{col 8}{cmd:e(T)}{col 21}maximum number of time periods observed
{col 8}{cmd:e(k_eq)}{col 21}number of equations
{col 8}{cmd:e(N_g)}{col 21}number of unique units in groups
{col 8}{cmd:e(g_min)}{col 21}minumum number of panels
{col 8}{cmd:e(g_max)}{col 21}maximum number of panels
{col 8}{cmd:e(tol)}{col 21}convergence tolerance
{col 8}{cmd:e(cilevel)}{col 21}confidence interval level

{col 4}Macros
{col 8}{cmd:e(cmd)}{col 21}name of the command
{col 8}{cmd:e(cmdline)}{col 21}full command typed
{col 8}{cmd:e(method)}{col 21}estimation method
{col 8}{cmd:e(title)}{col 21}title of regression
{col 8}{cmd:e(version)}{col 21}version of the command
{col 8}{cmd:e(properties)}{col 21}properties of estimation
{col 8}{cmd:e(eqnames)}{col 21}equation names
{col 8}{cmd:e(depvar)}{col 21}dependent variables
{col 8}{cmd:e(exog)}{col 21}exogenous variables
{col 8}{cmd:e(endog)}{col 21}endogenous variables
{col 8}{cmd:e(tvar)}{col 21}time variable
{col 8}{cmd:e(ivar)}{col 21}ID variable

{col 4}Matrices
{col 8}{cmd:e(b)}{col 21}estimated parameters
{col 8}{cmd:e(V)}{col 21}variance-covariance of estimated parameters
{col 8}{cmd:e(sigma_u)}{col 21}variance-covariance of random effects
{col 8}{cmd:e(sigma_e)}{col 21}variance-covariance of error terms
{col 8}{cmd:r(xtsur)}{col 21}structure of the unbalanced panel dataset

{col 4}Functions
{col 8}{cmd:e(sample)}{col 21}sample used in estimation

{title:Examples}

{phang}{title:SUR model with 3 equations}{p_end}
{phang}{cmd:. use example.dta, clear}{p_end}
{phang}{cmd:. xtsur (y1 x1 x2 x3 x4) (y2 x4 x6 x7) (y3 x7 x9)}{p_end}
{phang}{cmd:. xtsur (y1 y2 y3 =  x1 x2 x3 x4 x6 x7 x9), onestep}{p_end}
{phang}{cmd:. xtsur (y1 y2  =  x1 x2 x3 x4 x6) (y3 x6 x7 x9)}{p_end}

{phang}{title:SUR model with 2 global equation names}{p_end}
{phang}{cmd:. global eqn1 (y1 x1 x2 x3)}{p_end}
{phang}{cmd:. global eqn2 (y2 x4 x6 x7)}{p_end}
{phang}{cmd:. xtsur $eqn1 $eqn2}{p_end}

{phang}{cmd:. xtsur (equname1: y1 x2 x3 x4) (equname2: y2 x3 x4)}{p_end}

{phang}{cmd:. global eqn1 (equname1: y1 x2 x3 x4)}{p_end}
{phang}{cmd:. global eqn2 (equname2: y2 x3 x4)}{p_end}
{phang}{cmd:. xtsur $eqn1 $eqn2}{p_end}

{title:References}

{p 4 8 2}Erik Biorn. 2004. 
Regression system for unbalanced panel data: a stepwise maximum likelihood procedure. {it:Journal of Econometrics} 122: 281-91.{p_end}
{p 4 8 2}Minh Nguyen and Hoa Nguyen. 2010. Stata module: Estimation of system of regression equations with unbalanced panel data and random effects. Working Paper.{p_end} 

{title:Acknowledgements}

{pstd}
We would like to thank numerous people for their comments and suggestions. Among them
are Brian Poi, Kit Baum and one anonymous reviewer. We also thank all users who feedback had
led to steady improvement in {cmd:xtsur}.

{title:Author}

{p 4}Minh Cong Nguyen{p_end}
{p 4}Enterprise Analysis Unit{p_end}
{p 4}The World Bank, 2009{p_end}
{p 4}mnguyen3@worldbank.org{p_end}

{p 4}Hoa Bao Nguyen{p_end}
{p 4}Ph.D. Candidate{p_end}
{p 4}Economics Department{p_end}
{p 4}Michigan State University{p_end}
{p 4}East Lansing, MI{p_end}
{p 4}Email: nguye147@msu.edu{p_end}

{title:Version}

{p 4} This is version 1.0.4 released December 11, 2009.{p_end}
