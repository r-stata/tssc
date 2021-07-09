{smcl}
{* *! version 1.0  3mar2011}{...}
{cmd:help orderalpha} 
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{phang}
{bf:leebounds} {hline 2} Lee (2009) treatment effect bounds{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:leebounds}
{it:{help varname:depvar}} {it:{help varname:treatvar}}  {ifin} {weight}, [{cmd:}{it:{help leebounds##options:options}}]


{synoptset 28 tabbed}{...}
{marker Outcome_and_treatment}{...}
{synopthdr :Outcome and treatment}
{synoptline}
{syntab :Model}
{synopt :{it:{help varname:depvar}}}dependent variable{p_end}
{synopt :{it:{help varname:treatvar}}}binary treatment indicator{p_end}

{synoptset 28 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{opth {ul on}sel{ul off}ect(varname)}}selection indicator {p_end}
{synopt :{opth {ul on}tig{ul off}ht(varlist)}}covariats for tightened bounds {p_end}
{synopt :{opt cie:ffect}}compute confidence interval for treatment effect {p_end}

{syntab :SE/Bootstrap}
{space 6}{cmd:vce(}{ul on}{it:ana}{ul off}{it:lytic}|{help bootstrap:{ul on}{it:boot}{ul off}{it:strap}}{cmd:)} {space 3} compute analytic or bootstrapped standard errors; {opt vce(analytic)}  is the default.

{syntab :Reporting}
{synopt :{opt lev:el(#)}}set confidence level; default is {opt level(95)}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{opt pweights} (default), {opt fweights}, and {opt iweights} are allowed, {opt aweights} are not allowed; see {help weight}. Observations with negative weight are skipped for any weight type.{p_end}
{p 4 6 2}{cmd:bootstrap} is allowed, {cmd:by} and {cmd:svy} are not allowed; see {help prefix}.{p_end}



{title:Description}

{pstd}
{cmd:leebounds} computes treatment effect bounds for samples with non-random sample selection/attrition as proposed by Lee (2009). The lower and upper bound, 
respectively, correspond to extreme assumptions about the missing information that are consistent with the observed data. As opposed to parametric
approaches to correcting for sample selection bias, such as the classical Heckman (1979) estimator, Lee (2009) bounds rest on very few assumptions, i.e. random assignment 
of treatment and monotonicity. Monotonicity means that the treatment status affects selection in just one direction. That is, receiving a treatment makes selection either 
more or less likely for any observation. In technical terms, the approach rests on a trimming procedure. Either from below or from above, the group (treatment, control) 
that suffers less from sample attrition is trimmed at the quantile of the outcome variable that corresponds to the share of 'excess observations' in this group. Calculating 
group differentials in mean outcome yields the lower and the upper bound, respectively, for the treatment effect depending on whether trimming is from below or above. 
{cmd:leebounds} assumes that it is unknown, a priori, which group (treatment, control) is subject to the higher selection probability and estimates this from data 
(see Lee, 2009:1090).


{title:Outcome and treatment}

{dlgtab:Model}

{phang}
{opt depvar} specifies the outcome variable.

{phang}
{opt treatvar} specifies a binary variable, indicating receipt of treatment. Estimating the effect of {it:treatvar} 
on {it: depvar} is subject of the empirical analysis. The lager value of {it:treatvar} is assumed to indicate treatment.


{marker options}{...}
{title:Options}

{dlgtab:Main}


{phang}
{opt select(varname)} specifies a binary selection indicator. {it:treatvar} my only take the value zero or unity. If no selction indicator {it:varname} is specified, any observation with non-missing 
information on {it:depvar} is assumed to be selected while all observations with missing information on {it:depvar} are assumed to be not selected. 

{phang}
{opt tight(varlist)} specifies  a list of covariates for computing tightened bounds. With {opt tight()} specified, the sample is splitted into into cells defined by 
the covariates in {it:varlist}. Trimmed means are calculated separately for each cell, where the trimming proportion is specific to each cell. Finally, a weighted average of trimmed means is calculated. 
Continuous variables may, hence, not enter {it:varlist} without afore being converted to categorical variables. Specifying to many cells by including numerous 
variables in {it:varlist}, or by including variables that take numerous different values, will cause error.  

{phang}
{opt cieffect} requests calculation of a confidence interval for the treatment effect. Note that this interval is narrower than the conjunction 
of confidence intervals for the estimated bounds (see Lee, 2009:1089; Imbens and Manski, 2004). This interval captures both, uncertainty 
about the bias due to non-random sample attrition and uncertainty because of sampling error.

{dlgtab:SE/Bootstrap}

{phang}
{opt vce(analytic|bootstrap)} specifies whether analytic or bootstrapped standard errors are calculated for estimated bounds. {it:analytic} 
is the default. {it:bootstrap} allows for the suboptions {opt r:eps(#)} and {opt nodots}; see {help bootstrap:bootstrap}. For {opt vce(analytic)}
the covariance for the estimated lower and upper bound is not computed. If this covariance is of relevance, one should choose {opt vce(bootstrap)}.
Instead of specifying {opt vce(bootstrap)} one may alternatively use the {help prefix:prefix} command {cmd:bootstrap}, which allows for numerous additional options. 
Yet {cmd:leebounds}' internal bootstrapping routine is much faster than the prefix command, allows for sampling weights by 
performing a weighted bootstrap, and makes the option {opt cieffect} use bootstrapped standard errors, too.  

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}. One may change the reported confidence level by retyping 
{cmd:leebounds} without arguments and only specifying the option {opt level(#)}. However, this affects only the confidence interval for the 
bounds, but not for the confidence interval requested with {opt cieffect}.


{title:Examples}

{pstd}Basic syntax{p_end}
{phang2}{cmd:. leebounds wage training}{p_end}

{pstd}Tightened Lee bounds with weighted bootstrap and treatment effect-confidence interval{p_end}
{phang2}{cmd:. leebounds wage training [pw=1/prob], select(wageinfo) tight(female immigrant) cieffect vce(boot, reps(250) nodots)}{p_end}


{title:Saved results}

{pstd}
{cmd:leebounds} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(Nsel)}}number of selected observations{p_end}
{synopt:{cmd:e(trim)}}(overall) trimming proportion{p_end}
{synopt:{cmd:e(cells)}}number of cells (only saved for {opt tight()}){p_end}
{synopt:{cmd:e(cilower)}}lower bound of treatment effect-confidence interval (only saved for {opt cieffect}){p_end}
{synopt:{cmd:e(ciupper)}}upper bound of treatment effect-confidence interval (only saved for {opt cieffect}){p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}
{synopt:{cmd:e(N_reps)}}number of bootstrap repetitions (only saved for {opt vce(bootstrap)}){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:leebounds}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}{cmd:Lee (2009) treatment effect bounds}{p_end}
{synopt:{cmd:e(vce)}}either {opt analytic} or {opt bootstrap}{p_end}
{synopt:{cmd:e(vcetype)}}{cmd:Bootstrap} for {opt vce(bootstrap)}{p_end}
{synopt:{cmd:e(depvar)}}{it:depvar}{p_end}
{synopt:{cmd:e(treatment)}}{it:treatvar}{p_end}
{synopt:{cmd:e(select)}}{it:varname} (only saved for {opt select()}){p_end}
{synopt:{cmd:e(cellsel)}}cell-specific selection pattern, either {opt homo}, or {opt hetero} (only saved for {opt tight()}){p_end}
{synopt:{cmd:e(covariates)}}{it:varlist} (only saved for {opt tight()}){p_end}
{synopt:{cmd:e(trimmed)}}either {opt treatment} or {opt control}{p_end}
{synopt:{cmd:e(wtype)}}either {opt pweight}, {opt fweight}, or {opt iweight} (only saved if weights are specified){p_end}
{synopt:{cmd:e(wexp)}}= {it: exp} (only saved if weights are specified){p_end}
{synopt:{cmd:e(properties)}}{opt b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}{it:1x2} vector of estimated treatment effect bounds ({it:colnames} are of the form {it: treatvar:lower} and {it: treatvar:upper}){p_end}
{synopt:{cmd:e(V)}}{it:2x2} variance-covariance matrix for estimated treatment effect bounds (covariance set to zero for {opt vce(analytic)}){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{pstd}
Heckman, J.J. (1979). Sample Selection Bias as a Specification Error. {it: Econometrica} 47, 153–161.

{pstd}
Imbens, G.W. and C.F. Manski (2004). Confidence Intervals for Partially Identified Parameters. {it: Econometrica} 72,
1845–1857.

{pstd}
Lee, D.S. (2009). Training, Wages, and Sample Selection: Estimating Sharp Bounds on Treatment
Effects. {it: Review of Economic Studies} 76, 1071–1102. 


{title:Also see}

{psee}
Manual:  {manlink R heckman}

{psee}
{space 2}Help:  {manhelp heckman R:heckman}{break}

{psee}
Online:  {helpb bpbounds}, {helpb bpboundsi}, {helpb mhbounds}{p_end} 


{title:Author}

{psee}
Harald Tauchmann{p_end}
{psee}
Rheinisch-Westfälisches Institut für Wirtschaftsforschung (RWI){p_end}
{psee}
Essen, Germany{p_end}
{psee}
E-mail: harald.tauchmann@rwi-essen.de
{p_end}


{title:Disclaimer}
 
{pstd} This software is provided "as is" without warranty of any kind, either expressed or implied. The entire risk as to the quality and 
performance of the program is with you. Should the program prove defective, you assume the cost of all necessary servicing, repair or 
correction. In no event will the copyright holders or their employers, or any other party who may modify and/or redistribute this software, 
be liable to you for damages, including any general, special, incidental or consequential damages arising out of the use or inability to 
use the program.
{p_end} 


{title:Acknowledgements}

{pstd}
This work has been supported in part by the Collaborative Research Center "Statistical Modelling of
Nonlinear Dynamic Processes" (SFB 823) of the German Research Foundation (DFG).
{p_end}
