{smcl}
{* *! version 1.0.0  20jul2013}{...}
{cmd:help tihtest}
{hline}


{title:Title}

{p2colset 5 17 21 2}{...}
{p2col :{hi:tihtest} {hline 2}}Testing for time invariant unobserved heterogeneity in GLMs for panel data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}{cmd:tihtest} {depvar} [{indepvars}] {ifin} {weight}
[, {it:{help tihtest##options:options}}]

{marker options}{...}
{synoptset 31 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Model}
{synopt :{cmdab:m:odel(}{opt cnorm:al)}}Gaussian fixed-effects linear model, the default{p_end}
{synopt :{cmdab:m:odel(}{opt clog:it)}}Fixed-effects logit model{p_end}
{synopt :{cmdab:m:odel(}{opt colog:it)}}Fixed-effects ordered logit model{p_end}
{synopt :{cmdab:m:odel(}{opt cpoi:sson)}}Fixed-effects Poisson model{p_end}

{syntab :Starting values}
{synopt:{cmdab:from(}{it:{help tihtest##from_maximize_option:init_specs}})}specify initial values for the coefficients{p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}number of times {it:#} the random values are tried; the default is 10{p_end}
{synopt :{opt rescale}}determine the rescaling of initial values{p_end}

{syntab:SE/Robust}
{synopt:{cmdab:vce(}{it:{help tihtest##vce_options:vcetype}})}{it:vcetype} may be {opt oim} or {opt r:obust}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end} 
{syntab:Reporting}
{synopt :{opt display:estimates}}show full and pairwise estimates{p_end}
{synopt :{opt level(#)}}set confidence interval level; default is {cmd:level(95)}{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help tihtest##display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help tihtest##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{synoptline}
{p 4 6 2}
Panel and time variables must be specified. Use {helpb xtset}.{p_end}
{p 4 6 2}
{it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{it:depvars} and {it:indepvars} cannot contain time-series operators; see
{help tsvarlist}.{p_end}
{p 4 6 2}
{opt by} is allowed; see {help prefix}.{p_end}
{p 4 6 2}{opt aweight}s, {opt fweight}s and {opt pweight}s are allowed; see {help weight}.{p_end}
{p 4 6 2}Weights must be constant within panel.{p_end}


{title:Description}

{pstd}
{cmd:tihtest} performs the Bartolucci et al. (2013) 
	test for time invariant unobserved heterogeneity in Generalized Linear Models (GLMs) for panel data. To this aim,
	this version fits full and pairwise Conditional Maximum Likelihood (CML) estimators for the logit, ordered logit, 
	Poisson and Gaussian linear models.

{title:Options}

{dlgtab:Models}

{phang}
{opt model(model)} specifies the {it: model} to be estimated as: Gaussian fixed-effects linear model ({opt cnormal}), fixed-effects logit model ({opt clogit}), fixed-effects ordered logit model ({opt cologit}), 
fixed-effects Poisson model ({opt cpoisson}). The default is {opt cnormal}. 

{dlgtab:Starting values}
{marker from_maximize_option}
{phang}
{opt from(init_spec [, from_options])} specifies initial values for the coefficients.  
You can specify the initial values in one of three ways: by specifying the name of a
vector containing the initial values (e.g., {cmd:from(b0)}, where {cmd:b0} is a
properly labeled vector); by specifying coefficient names with the values
(e.g., {cmd:from(age=2.1 /sigma=7.4)}); or by specifying a list of values
(e.g., {cmd:from(2.1 7.4, copy)}). Poor values in {opt from()} may lead to convergence
problems.

{synoptset 32}{...}
{marker from_options}{...}
{synopt :{it: from_options}}description{p_end}
{synoptline}
{synopt :{cmd:skip}}specifies that any parameters found in the specified initialization
vector that are not also found in the model be ignored.  
The default action is to issue an error message.{p_end}
{synopt :{cmd:copy}}specifies that the list of values or the initialization
vector be copied into the initial-value vector by position rather than
by name.{p_end}
{synoptline}
{p2colreset}{...}

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.
{marker vce_options}{...}

{dlgtab:SE}

{pstd}
This entry describes the arguments of {opt vce()} option. {cmd:vce()} specifies how to estimate the
variance-covariance matrix (VCE) corresponding to the parameter estimates.
The standard errors reported in the table of parameter estimates are the
square root of the variances (diagonal elements) of the VCE.

{synoptset 32}{...}
{synopt :{it:vcetype}}description{p_end}
{synoptline}
{synopt :{cmd:oim}}observed information matrix (OIM). see {help vcetype}. Even if {opt oim} is specified and the OIM VCE is displayed 
(and reported), the tih test will be performed using the clustered sandwich estimator where {it:clustvar} is {it:panelvar}.  {p_end}
{synopt :{cmdab:r:obust}}clustered sandwich estimator where {it:clustvar} is {it:panelvar}, where {it:panelvar} has been specified through {help xtset}. In this case the resulting (co)variance matrix will also contain the covariance between the full and pairwise estimators.{p_end}
{p2colreset}{...}

{dlgtab:Reporting}

{phang}
{opt displayestimates} allows the user to display estimation results. 

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt postscore} save observation-by-observation scores in the estimation results list. 
All evaluators are of type {cmd:gf2}, thus scores are defined as the derivative of the objective function 
with respect to the {help mf_moptimize##def_K:coefficients}.

{phang}
{opt posthessian} save the Hessian corresponding to the full set of coefficients 
in the estimation results list. The Hessian is defined as the second derivative of 
the objective function with respect to the {help mf_moptimize##def_K:coefficients}.

{dlgtab:Maximization}
{marker maximize_options}
{phang}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tol:erance(#)},
{opt ltol:erance(#)}, {opt nrtol:erance(#)},
{opt nonrtol:erance}; see {manhelp maximize R}.  These
options are seldom used.

{dlgtab:Display}
{marker display_options}{...}
{phang}
{it:display_options}:
{opt vsquish},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

	
{title:Remarks}
{marker tihtest_remarks}{...}

{pstd}
It is worth noting that this version of {cmd:tihtest} works only in the case of balanced panel data.{p_end}


{title:References}

{pstd}
Bartolucci, F., Belotti, F., Peracchi, F., (2013). Testing for time-invariant unobserved heterogeneity in 
generalized linear models for panel data. EIEF Working paper 12.{p_end}

{title:Examples}

{pstd}Setup {p_end}
{phang2}{cmd:. use health}{p_end}
{phang2}{cmd:. xtset id t}{p_end}

{pstd}Fixed-effects logit model{p_end}
{phang2}{cmd:. tihtest hinsurance age bmi hexp i.t, display model(clogit) robust}

{pstd}Fixed-effects ordered logit model{p_end}
{phang2}{cmd:. tihtest hs age c.age#c.age bmi hexp i.t, display model(cologit) robust}

{pstd}Fixed-effects Poisson model{p_end}
{phang2}{cmd:. tihtest visits age bmi hexp i.t, display model(cpoisson) robust}

{pstd}Fixed-effects Gaussian linear model{p_end}
{phang2}{cmd:. tihtest income age bmi hexp i.t, display model(cnormal) robust}


{title:Saved results}

{pstd}
{cmd:tihtest} saves the following in {cmd:e()} when the option {opt displayestimates} has been specified:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(g_min)}}minimum number of observations per group{p_end}
{synopt:{cmd:e(g_avg)}}average number of observations per group{p_end}
{synopt:{cmd:e(g_max)}}maximum number of observations per group{p_end}
{synopt:{cmd:e(k_autoCns)}}number of base, empty, and omitted constraints{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:tihtest}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:e(tvar)}}variable denoting time{p_end}
{synopt:{cmd:e(model)}}model type{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{pstd}
{cmd:tihtest} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(N_g)}}number of groups{p_end}
{synopt:{cmd:r(df)}}degrees of freedom{p_end}
{synopt:{cmd:r(stat)}}chi-squared{p_end}
{synopt:{cmd:r(p)}}p-value for the chi-squared{p_end}
{synopt:{cmd:r(g_min)}}minimum number of observations per group{p_end}
{synopt:{cmd:r(g_avg)}}average number of observations per group{p_end}
{synopt:{cmd:r(g_max)}}maximum number of observations per group{p_end}
{synopt:{cmd:r(k_autoCns)}}number of base, empty, and omitted constraints{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:tihtest}{p_end}
{synopt:{cmd:r(cmdline)}}command as typed{p_end}
{synopt:{cmd:r(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:r(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:r(tvar)}}variable denoting time{p_end}
{synopt:{cmd:r(model)}}model type{p_end}
{synopt:{cmd:r(covariates)}}model covariates{p_end}


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}


{title:Also see}

{psee}
{space 2}Help:  {help xtreg}; {help xtivreg}; {help xtlogit}; {help xtpoisson}.
{p_end}
