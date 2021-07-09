{smcl}
{* 21aug2014}{...}
{title:Title}

{pstd}{hi:hte sd} {hline 2} Heterogeneous Treatment Effect Analysis: Smoothing-Differencing Method


{title:Syntax}

{p 8 15 2}
    {cmd:hte sd} {it:{help varname:depvar1}} [{it:{help varname:depvar2}} {it:...} {cmd:=}]
    {it:{help varname:treatvar}} [{indepvars}] {ifin} {weight}
    [{cmd:,}
    {help hte sd##opt:{it:options}}
    ]

{synoptset 20 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{syntab :Main}
{synopt :{cmd:noci}}suppress confidence bands
    {p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt list:wise}}use listwise deletion to handle missing values; 
    excludes observations with missing value on (at least one) dependent 
    variable
    {p_end}
{synopt :{opt case:wise}}synonym for {cmd:listwise}
    {p_end}

{syntab :Propensity score}
{synopt :{opt logit}}use {helpb logit} instead of {helpb probit} to estimate 
    propensity score
    {p_end}
{synopt :{opt estopt:s(options)}}options to be passed through to the 
    estimation command
    {p_end}
{synopt :{opt noi:sily}}display model output
    {p_end}
{synopt :{opt _pscore(varname)}}provide variable containing propensity score 
    and skip estimation
    {p_end}

{syntab :Local polynomial fit}
{synopt: {opth k:ernel(lpoly##kernel:kernel)}}specify kernel function;
    default is {cmd:kernel(epanechnikov)}
    {p_end}
{synopt :{opt deg:ree(#)}}degree of the polynomial smooth; default is {cmd:degree(1)}
    {p_end}
{synopt :{opt bw:idth(#|varname)}}specify kernel
    bandwidth; for treatment group specific values type
    {opt bwidth(# #)} or {opt bwidth(varname1 varname2)}
    {p_end}
{synopt :{opt pw:idth(#)}}specify pilot bandwidth for standard error 
    calculation; for treatment group specific values type
    {opt pwidth(# #)}{p_end}
{synopt :{opt v:ar(#|varname)}}specify estimates of residual variance; 
    for treatment group specific values type
    {opt var(# #)} or {opt var(varname1 varname2)}
    {p_end}
{synopt :{opt ngrid(#)}}obtain the smooth at {it:#} points on a regular grid between 0 and 1; default is
    min(N,50); note that only grid points within the support of the propensity score are used{p_end}
{synopt :{opt at(varname)}}obtain the smooth at the values specified by 
    {it:varname}
    {p_end}
{synopt :{opt atmat(matname)}}obtain the smooth at the values specified by vector
    {it:matname}
    {p_end}
{synopt :{opt comsup}}restrict the evaluation grid to the common support of the 
    propensity score in the treatment group and control group; {opt comsup} has no 
    effect if {cmd:at()} or {cmd:atmat()} is specified

{syntab :Graph}
{synopt :{opt nogr:aph}}suppress graph
    {p_end}
{synopt :{it:{help cline_options}}}affect rendition of the treatment effect 
    smooth
    {p_end}
{synopt :{opt ciopt:s(options)}}affect rendition of confidence bands; 
    {it:options} are {it:{help cline_options}} or {it:{help area_options}}, 
    depending on whether {cmd:overlay} is specified or not
    {p_end}
{synopt :{opt overlay}}include results for all dependent variables in one plot; 
    the default is to use separate plots and combine them into one graph 
    using {helpb graph combine}
    {p_end}
{synopt :{cmd:combine(}{it:{help graph_combine:options}}{cmd:)}}options passed through to 
    {helpb graph combine} (unless {cmd:overlay} is specified)
    {p_end}
{synopt :{it:{help twoway_options}}}any options other than {opt by()} documented in
    {bind:{bf:[G] {it:twoway_options}}}
    {p_end}
    
{syntab :Save results (for last {it:depvar})}
{synopt :{opt gen:erate(fit [at])}}store treatment effect smooth in 
    variable {it:fit} and corresponding propensity score values in variable 
    {it:at}
    {p_end}
{synopt :{opt se(newvar)}}store standard errors in {newvar}
    {p_end}
{synopt :{opt ci(lb ub)}}store lower and upper bounds of confidence interval in  
    variables {it:lb} and {it:ub}
    {p_end}
{synopt :{opt pscore(newvar)}}save estimated propensity score in {newvar}
    {p_end}
{synopt :{opt replace}}allow overwriting existing variables
    {p_end}
{synopt :{opt post}}post results in {cmd:e()}
    {p_end}
{synoptline}
{pstd}
    {cmd:fweight}s are allowed; see help {help weight}.


{title:Description}

{pstd}
    {cmd:hte sd} performs heterogeneous treatment effect analysis using the
    smoothing-differencing method as proposed by Xie, Brand, and Jann
    (2012). It first estimates the propensity score using of a probit model of
    {it:treatvar} on {it:indepvars} and then, separately for the treated and
    the untreated, computes a nonparametric fit of {it:depvar} on the
    propensity score using {helpb lpoly}. The propensity score specific treatment
    effects are then derived as the difference between the two nonparametric 
    fits and are plotted in a graph along with pointwise confidence intervals.
    {it:treatvar} is a dichotomous variable identifying the treatment group 
    (typically coded as 1) and the control group (typically coded as 0).


{title:Options}

{dlgtab:Main}

{phang}
    {cmd:noci} suppresses the pointwise confidence intervals.

{phang}
    {cmd:level(#)} sets the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)} or as set by
    {helpb set level}.

{phang}
    {cmd:listwise} handles missing values through listwise deletion, meaning
    that an observation is excluded from all computations if any of the
    specified variables is missing for that observation. By default, {cmd:hte sd} uses all
    available observations to compute the propensity strata without regard
    to whether values for the outcome variables (the {it:depvars}) are missing.
    
{phang}
    {cmd:casewise} is a synonym for {cmd:listwise}.

{dlgtab:Propensity score}

{phang}
    {cmd:logit} uses logistic regression (see help {helpb logit}) to estimate the 
    propensity score. The default is to use Probit regression (see help {helpb probit}).
    
{phang}
    {cmd:estopts(}{it:options}{cmd:)} specifies options to be passed through to 
    the estimation command for the propensity score.
    
{phang}
    {cmd:noisily} causes the output from the propensity score estimation model to be 
    displayed.

{phang}
    {cmd:_pscore(}{it:varname}{cmd:)} provides a variable containing the propensity 
    score values. In this case, estimation of the propensity score is skipped.

{dlgtab:Local polynomial fit}

{phang}
    {cmd:kernel(}{it:kernel}{cmd:)} specifies the kernel function. The
    default is {cmd:kernel(epanechnikov)}. See help {helpb lpoly##kernel:lpoly}
    for alternative kernel functions. 
    
{phang}
    {cmd:degree(#)} specifies the degree of the local polynomial fit. The default 
    is {cmd:degree(1)} (local-linear smoothing).
    
{phang}
    {cmd:bwidth(#}|{it:varname}{cmd:)} sets the half-width of the kernel. 
    If {cmd:bwidth()} is not specified, a rule-of-thumb (ROT) bandwidth estimator
    used; see {manlink R lpoly} for details. A local variable bandwidth may be 
    specified in {it:varname}, in conjunction with an explicit smoothing grid 
    using the {cmd:at()} option. To use different bandwidths for the untreated and the
    treated type {cmd:bwidth(# #)} or {cmd:bwidth(}{it:varname} {it:varname}{cmd:)}, 
    where the first bandwidth applies to the control group and the second bandwidth
    applies to the treatment group.
    
{phang}
    {cmd:pwidth(#)} specifies the pilot bandwidth to be used for standard-error 
    computations. The default is chosen to be 1.5 times the value of the 
    ROT bandwidth selector. To use different pilot bandwidths for the untreated and the
    treated type {cmd:pwidth(# #)}, where the first value applies to the control 
    group and the second bandwidth applies to the treatment group.

{phang}
    {cmd:var(#}|{it:varname}{cmd:)} specifies an estimate of a constant residual 
    variance or a variable containing estimates of the residual variances at 
    each grid point required for standard-error computation. See help {helpb lpoly}
    for more information. To use different variances for the untreated and the
    treated type {cmd:var(# #)} or {cmd:var(}{it:varname} {it:varname}{cmd:)}, 
    where the first variance applies to the control group and the second variance
    applies to the treatment group.
    
{phang}
    {cmd:ngrid(#)} specifies the number of points at which the smooth is to be 
    calculated. The default is min(N,50), where N is the number of observations.
    A regular grid between 0 and 1 is used; grid points 
    outside the support of the propensity score are discarded.
    
{phang}
    {cmd:at(}{it:varname}{cmd:)} specifies a variable that contains the values 
    at which the smooth should be calculated. By default, a regular grid between 
    0 and 1 of size {cmd:ngrid()} is used. Values outside the support of 
    the propensity score will be discarded. 
    
{phang}
    {cmd:atmat(}{it:matname)} specifies a vector (see help {helpb matrix}) that contains the values 
    at which the smooth should be calculated. By default, a regular grid between 
    0 and 1 of size {cmd:ngrid()} is used. Values outside the support of 
    the propensity score will be discarded. 

{phang}
    {cmd:comsup} restricts the evaluation grid to the common support of the 
    propensity score in the treatment group and control group. {opt comsup} has no 
    effect if {cmd:at()} or {cmd:atmat()} is specified.

{dlgtab:Graph}

{phang}
    {cmd:nograph} suppresses drawing the graph.

{phang}
    {it:connect_options} affect the rendition of the smoothed line; see
    {manhelpi cline_options G-3}.
    
{phang}
    {cmd:ciopts(}{it:options}{cmd:)} affects the rendition of confidence bands. 
    {it:options} are {it:{help cline_options}} or {it:{help area_options}}, 
    depending on whether {cmd:overlay} is specified or not.

{phang}
    {cmd:overlay} causes the results for all dependent variables to be included 
    in a single plot. The default is to use separate plots and combine 
    them into one graph using {helpb graph combine}.
    
{phang}
    {cmd:combine(}{it:options}{cmd:)} provides options to be passed through to 
    {helpb graph combine} (not relevant if {cmd:overlay} is specified). {it:options}
    are as described in help {helpb graph combine}.
    
{phang}
    {it:twoway_options} are general twoway options, other than {opt by()}, as documented 
    in help {it:{help twoway_options}}.
    
{dlgtab:Save results}

{phang}
    {cmd:generate(}{it:fit} [{it:at}]{cmd:)} stores the treatment effect smooth in 
    variable {it:fit} and, unless {cmd:at()} is specified, the corresponding 
    propensity score values (i.e. the evaluation points) in variable {it:at}. Results 
    for the rightmost dependent variable are stored if multiple dependent 
    variables are specified. 

{phang}
    {cmd:se(}{it:newvar}{cmd:)} stores the standard errors in variable 
    {newvar}. Standard errors for the rightmost dependent variable are stored if multiple dependent 
    variables are specified. 
    
{phang}
    {cmd:ci(}{it:lb ub}{cmd:)} stores the lower and upper bounds of the 
    confidence interval in variables {it:lb} and {it:ub}. Confidence interval
    bounds for the rightmost dependent variable are stored if multiple dependent 
    variables are specified. 

{phang}
    {cmd:pscore(}{it:newvar}{cmd:)} saves the estimated propensity scores in variable 
    {newvar}.

{phang}
    {cmd:replace} allows overwriting existing variables

{phang}
    {cmd:post} post the results in {cmd:e()}; see {help hte_sd##savedresults:Saved Results} below. Results 
    for the rightmost dependent variable are posted if multiple dependent 
    variables are specified.


{title:Examples}

{pstd}
    Treatment effect of college on wages:

        . {stata sysuse nlsw88}
        . {stata generate sq_exp = ttl_exp^2}
        . {stata hte sd wage collgrad ttl_exp sq_exp tenure south smsa, comsup ngrid(100)}


{marker savedresults}{...}
{title:Saved results}

{pstd}
    If {cmd:post} is omitted, {cmd:hte sd} leaves behind in {cmd:e()} the results 
    from the propensity score estimation model and, for the rightmost dependent variable,
    saves the following in {cmd:r()}:
    
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(ngrid)}}number of evaluation points{p_end}
{synopt:{cmd:r(degree)}}degree of lpoly fit{p_end}
{synopt:{cmd:r(N0)}}number of observations in control group{p_end}
{synopt:{cmd:r(N1)}}number of observations in treatment group{p_end}
{synopt:{cmd:r(bwidth0)}}bandwidth of lpoly fit in control group{p_end}
{synopt:{cmd:r(bwidth1)}}bandwidth of lpoly fit in treatment group{p_end}
{synopt:{cmd:r(pwidth0)}}pilot bandwidth of lpoly fit in control group{p_end}
{synopt:{cmd:r(pwidth1)}}pilot bandwidth of lpoly fit in treatment group{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:r(indepvars)}}names of control variables{p_end}
{synopt:{cmd:r(treatvar)}}name of treatment variable{p_end}
{synopt:{cmd:r(treatgrp0)}}value of control group{p_end}
{synopt:{cmd:r(treatgrp1)}}value of treatment group{p_end}

{pstd}If {cmd:post} is specified, {cmd:hte sd} saves the following in {cmd:e()} for 
the rightmost dependent variable:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(ngrid)}}number of evaluation points{p_end}
{synopt:{cmd:e(degree)}}degree of lpoly fit{p_end}
{synopt:{cmd:e(N0)}}number of observations in control group{p_end}
{synopt:{cmd:e(N1)}}number of observations in treatment group{p_end}
{synopt:{cmd:e(bwidth0)}}bandwidth of lpoly fit in control group{p_end}
{synopt:{cmd:e(bwidth1)}}bandwidth of lpoly fit in treatment group{p_end}
{synopt:{cmd:e(pwidth0)}}pilot bandwidth of lpoly fit in control group{p_end}
{synopt:{cmd:e(pwidth1)}}pilot bandwidth of lpoly fit in treatment group{p_end}
{synopt:{cmd:e(cilevel)}}confidence levels{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:hte sd}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(indepvars)}}names of control variables{p_end}
{synopt:{cmd:e(treatvar)}}name of treatment variable{p_end}
{synopt:{cmd:e(treatgrp0)}}value of control group{p_end}
{synopt:{cmd:e(treatgrp1)}}value of treatment group{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}propensity score specific treatment effects{p_end}
{synopt:{cmd:e(at)}}evaluation points{p_end}
{synopt:{cmd:e(lb)}}lower bounds of confidence interval{p_end}
{synopt:{cmd:e(ub)}}upper bounds of confidence interval{p_end}
{synopt:{cmd:e(se)}}standard errors{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}
    Xie, Yu, Jennie E. Brand, Ben Jann. 2012. Estimating Heterogeneous Treatment 
    Effects with Observational 
    Data. {browse "http://dx.doi.org/10.1177/0081175012452652":Sociological Methodology 42: 314-347}.
    {p_end}


{title:Authors}

{pstd}
    Ben Jann (University of Bern, jann@soz.unibe.ch)
    {p_end}
{pstd}
    Jennie E. Brand (UCLA, brand@soc.ucla.edu)
    {p_end}
{pstd}
    Yu Xie (University of Michigan, yuxie@isr.umich.edu)
    {p_end}

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B., J. E. Brand, Y. Xie. 2010. hte: Stata module to perform
    heterogeneous treatment effect analysis. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s457129.html"}.


{title:Also see}

{psee}
    Online:  help for
    {helpb hte}, {helpb hte sm}, {helpb hte sd}, {helpb lpoly}
