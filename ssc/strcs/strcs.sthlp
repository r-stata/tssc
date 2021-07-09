{smcl}
{* *! version 1.4 19Feb2016}{...}
{cmd:help strcs} 
{right:also see:  {help strcs_postestimation}}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:strcs} {hline 2}}Flexible parametric survival models on the log hazard scale{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:strcs} [{varlist}] {ifin} [{cmd:,} {it:options}]

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Knot selection options}
{synopt :{opt bk:nots(numlist)}}boundary knots for baseline{p_end}
{synopt :{opt bknotstvc(knots list)}}boundary knots for time-dependent effects{p_end}
{synopt :{cmdab:df(#)}}degrees of freedom for baseline hazard function{p_end}
{synopt :{opt dftvc(df_list)}}degrees of freedom for each time-dependent effect{p_end}
{synopt :{opt kn:ots(numlist)}}internal knot locations for baseline hazard{p_end}
{synopt :{opt knotst:vc(numlist)}} internal knot locations for time-dependent effects{p_end}
{synopt :{opt knscale(scale)}}scale for user-defined knots (default scale is time){p_end}
{synopt :{opt tvc(varlist)}}varlist of time varying effects{p_end}

{syntab:Estimation options}
{synopt :{opt bhaz:ard(varname)}}invokes relative survival models where {it: varname}
 holds the expected mortality rate (hazard) at the time of death{p_end}
{synopt :{opt bht:ime}}smooth the baseline hazard over time (default is log time){p_end}
{synopt :{opt nocon:stant}}suppress constant term{p_end}
{synopt :{opt nod:es(#)}}specify the number of nodes used in Gauss-Legendre quadrature numerical
integration of the hazard function (default is 30){p_end}
{synopt :{opt noorth:og}}do not use orthogonal transformation of splines variables{p_end}
{synopt :{opt off:set(varname)}}specifies a variable whose coefficient is constrained to be 1{p_end}
{synopt :{opt reverse}}calculate the splines in reverse order{p_end}

{syntab:Reporting options}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt nohr}}do not report hazard ratios{p_end}
{synopt :{opt verb:ose}}verbose output details the process of the {cmd:strcs} program{p_end}

{syntab:Maximization options}
{synopt :{opt from(matrix)}}initial coefficient values stored in a matrix{p_end}
{synopt :{opt init:h(varlist)}}initial hazard values{p_end}
{synopt :{it:{help strcs##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:strcs}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
{cmd:fweights}, {cmd:iweights}, and {cmd:pweights} may be specified using stset; {manhelp stset ST}.{p_end}

{title:Description}

{pstd}
{cmd:strcs} fits flexible parametric survival models (Royston-Parmar models) on the log  hazard scale. {cmd:strcs} can be used with single- or multiple-record or 
single- or multiple-failure {cmd:st} data. 


{pstd}
See {manhelp stpm2 ST} for flexible parametric survival models on the log cumulative hazard scale.


{title:Options}

{dlgtab:Knot selection options}

{phang}
{opt bknots(knots_list)} {it:knots_list} is a two-element {it:numlist} giving
the boundary knots. By default these are located at the minimum and maximum
of the uncensored survival times. They are specified on the scale defined
by {cmd:knscale()}.

{phang}
{opt bknotstvc(knots_list)} {it:knots_list} gives the boundary knots for 
any time-dependent effects. By default these are the same as for the bknots
option. They are specified on the scale defined by {cmd:knscale()}.

{pmore}
For example,

{pmore}
{cmd:bknotstvc(x1 0.01 10 x2 0.01 8)}

{phang}
{opt df(#)} specifies the degrees of freedom for the restricted
cubic spline function used for the baseline function; the number of degrees of 
freedom does not include the constant term. {it:#} must be between
1 and 10. The {cmd:knots()} option is not applicable if the {cmd:df()} option
is specified. The knots are placed at equally spaced centiles of the distribution
of the uncensored log survival times. For example, for {cmd:df(5)} knots are 
placed at the 20th, 40th, 60th and 80th centiles of the distribution of the 
uncensored log survival times. Note that these are {it:interior knots} and 
there are also boundary knots placed at the minimum and maximum of the distribution 
of uncensored survival times. 

{phang}
{opt dftvc(df_list)} gives the degrees of freedom for time-dependent effects
in {it:df_list}. With 1 degree of freedom a linear effect is fitted.
If there is more than one time-dependent effect and different degrees of freedom
are requested for each time-dependent effect then the following syntax applies:

{pmore}
{cmd:dftvc(x1:3 x2:2 1)}

{pmore}
This will use 3 degrees of freedom for {cmd:x1}, 2 degrees of freedom for
{cmd:x2} and 1 degree of freedom for all remaining time-dependent effects. 


{phang}
{opt knots(# [# ...])} specifies internal knot locations for the baseline distribution
function, as opposed to the default locations set by {cmd:df()}. Note that
the locations of the knots are placed on the scale defined by {cmd:knscale}.
However, the scale used by the restricted cubic spline function is always
log time unless the {cmd:bhtime} option is specified. Default knot positions are determined by the {opt df()} option.

{phang}
{opt knotstvc(knots_list)} defines numlist {it:knots_list} as the location
of the interior knots for time-dependent effects. If different knots 
are required for different time-dependent effects the option is
specified, for example, as follows:

{pmore}
{cmd:knotstvc(x1 1 2 3 x2 1.5 3.5)}

{phang}
{opt knscale(scale)} sets the scale on which user-defined knots are specified.
{cmd:knscale(time)} denotes the original time scale, {cmd:knscale(log)} the
log time scale and {cmd:knscale(centile)} specifies that the knots
are taken to be centile positions in the distribution of the uncensored
survival times, or log survival times depending on whether the {cmd:bhtime} option 
is specified. The default is {cmd:knscale(time)}.

{phang}
{opt tvc(varlist)} gives the name of the variables that are time-dependent.
Time-dependent effects are fitted using restricted cubic splines.
The degrees of freedom are specified using the {opt dftvc()} option. 


{dlgtab:Estimation options}

 {phang}
{opt bhazard(varname)} invokes a relative survival model where {it:varname} holds the expected 
mortality rate (hazard) at the time of death/censoring.

{phang}
{opt bhtime} smoothes the estimated log hazard function over time using restricted cubic splines. 
By default, smoothing is over log time.

{phang}
{opt noconstant};
see {helpb st estimation options##noconstant:[ST] estimation options}.

{phang}
{opt nodes(#)} specifies the number of nodes to be used in Gauss-Legendre quadrature
numerical integration when calculating the estimated cumulative hazard function
from the estimated hazard function. The default number of nodes is 30. Changing the 
number of nodes may be useful if there are convergence problems. Too few nodes 
may result in a poor approximation involved in the numerical integration. Analyses should
be performed to ensure the results are not sensitive to the number of nodes.

{phang}
{cmd: noorthog} suppresses orthogonal transformation of spline variables.

{phang}
{cmd: offset} specifies a variable whose coefficient is constrained to be 1.

{phang}
{cmd: reverse} specifies that the splines be calculated backwards. See Andersson 
{it: et al.} for details of the approach.

{dlgtab:Reporting}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level(95)} or as set by {help set level}.

{phang}
{opt nohr} reports the coefficients instead of hazard ratios.

{phang}
{opt verbose} verbose output details the process of the {cmd:strcs} program. 

{marker maximize_options}{...}
{dlgtab:Maximization options}

{phang}
{opt from(matrix)} defines the matrix containing initial coefficient estimates to be used in maximum 
likelihood estimation. By default {cmd:strcs} estimates initial hazard estimates by fitting a model 
on the log cumulative hazard scale using the {cmd:stpm2} command.

{phang}
{opt inith(varlist)} defines initial hazard estimates to be used in maximum likelihood
estimation. By default {cmd:strcs} estimates initial hazard estimates by fitting a model on the
log cumulative hazard scale using the {cmd:stpm2} command.
 
{phang}
{it:maximize_options}; {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, 
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt shownr:tolerance}, {opt tol:erance(#)}, 
{opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, {opt from(init_specs)}; see {manhelp maximize R}.  These 
options are seldom used, but the {opt difficult} option may be useful if there
are convergence problems.




{title:Remarks}

{pstd}
Let t denote time. {cmd:strcs} works by first fitting a flexible parametric survival 
model on the log cumulative hazard scale using the {cmd:stpm2} command. The predicted hazard
from this model is used to estimate initial values of the log hazard with specified 
covariates. These initial values are used within the maximum likelihood estimation. 

{pstd}
The log hazard estimate, ln(h_hat(t)), is smoothed on ln(t), or t if {cmd: bhtime} is 
specified, using restricted cubic splines with knots placed at certain quantiles of the 
distribution of t. The knot positions are chosen automatically if the spline complexity 
is specified by the {cmd:df()} option, or manually by way of the {cmd:knots()} option.

{pstd}
The cumulative hazard function, H(t), is required in order to maximise the likelihood and
fit the model. The cumulative hazard function can be estimated by integrating the 
hazard estimate. The hazard cannot be integrated analytically due to its complexity, thus it 
must be integrated numerically. Integration is performed as a two-part process to reduce 
computational time. The hazards prior to the first, and after the last knots can be integrated
analytically; numerical integration is only performed between the first and the last knots by
Gauss-Legendre quadrature. The number of nodes used within Gauss-Legendre quadrature can be 
specified using the {cmd:nodes(#)} option.

{pstd}
The survival function is calculated as 

{pin}
	S_hat(t) = exp(-exp H_hat(t)).

{pstd}
With {cmd:df(1)} a Weibull model is fitted.

{pstd}
Estimation is performed by maximum likelihood. Optimisation uses the
default technique ({cmd:nr}, meaning Stata's version of Newton-Raphson
iteration.


{title:Examples}

    {hline}
{pstd}Setup{p_end}

{phang2}{stata "webuse brcancer"}{p_end}
{phang2}{stata "stset rectime, failure(censrec = 1)"}{p_end}

{pstd}Proportional hazards model{p_end}
{phang2}{stata "strcs hormon, df(4) "}{p_end}

{pstd}Time-dependent effects on the log hazard scale{p_end}
{phang2}{stata "strcs hormon, df(4) tvc(hormon) dftvc(3)"}{p_end}

{pstd}User defined knots at centiles of uncensored event times{p_end}
{phang2}{stata "strcs hormon, knots(20 50 80) knscale(centile)"}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:strcs} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(converged)}}number of observations{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in overall model test{p_end}
{synopt:{cmd:e(dfbase)}}degrees of freedom specified for baseline hazard function{p_end}
{synopt:{cmd:e(df_{it:varname})}}degrees of freedom specified for the time-dependent effect of {it:varname}{p_end}
{synopt:{cmd:e(minknot)}}value of minimum knot{p_end}
{synopt:{cmd:e(maxknot)}}value of maximum knot{p_end}
{synopt:{cmd:e(nodes)}}number of nodes used in numerical integration{p_end}
{synopt:{cmd:e(dev)}}deviance{p_end}
{synopt:{cmd:e(AIC)}}Akaike information criterion{p_end}
{synopt:{cmd:e(BIC)}}Bayesian information criterion{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:strcs}{p_end}
{synopt:{cmd:e(predict)}}{cmd:strcs_pred}{p_end}
{synopt:{cmd:e(varlist)}}variables included in the model{p_end}
{synopt:{cmd:e(depvar)}}{cmd:_d _t}{p_end}
{synopt:{cmd:e(rcsterms_base)}}name of spline terms used to model the baseline hazard function{p_end}
{synopt:{cmd:e(bhknots)}}value of the knots used to model the baseline hazard function{p_end}
{synopt:{cmd:e(exp_bhknots)}}exponential of the knots used to model the baseline hazard function{p_end}
{synopt:{cmd:e(tvc)}}variables with time-dependent effects{p_end}
{synopt:{cmd:e(rcsterms_{it:varname})}}name of spline terms used to model the time-dependent effect for {it:varname}{p_end}
{synopt:{cmd:e(tvcknots_{it:varname})}}value of the knots for the time-dependent effect of {it:varname}{p_end}
{synopt:{cmd:e(exp_tvcknots_{it:varname})}}exponential of the knots fot the time-dependent effect of {it:varname}{p_end}
{synopt:{cmd:e(bhazard)}}name of the expected hazard rate used if a relative survival model is fitted{p_end}
{synopt:{cmd:e(bhtime)}}{cmd:bhtime} if time is modelled rather than the default of log time{p_end}
{synopt:{cmd:e(noconstant)}}{cmd: noconstant} if constant term was supressed{p_end}
{synopt:{cmd:e(orthog)}}{cmd:orthog} if splines were orthogonalized{p_end}
{synopt:{cmd:e(reverse)}}{cmd:reverse} if splones are calculated in reverse order{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(vce)}}vcetype specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(ml_method)}}type of ml method{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform maximization or minimization{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of estimators{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(R_bh)}}orthogonlization matrix{p_end}
{synopt:{cmd:e(ilog)}}iteration log{p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(R_{it:varname})}}orthogonalization matrix for splines of time-dependent effect {it:varname}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Hannah Bower,Karolinska Institutet, Stockholm, Sweden.
({browse "mailto:hannah.bower@ki.se":hannah.bower@ki.se})

{pstd}
Paul Lambert, University of Leicester, UK.
({browse "mailto:paul.lambert@leicester.ac.uk":paul.lambert@leicester.ac.uk})


{pstd}
Michael Crowther, University of Leicester, UK and Karolinska Institutet, Stockholm, Sweden.
({browse "michael.crowther@le.ac.uk":michael.crowther@le.ac.uk})


{title:References}

{phang}
T. M-L. Andersson, P.W Dickman, S. Eloranta and P. C. Lambert. Estimating and modelling 
cure in population-based cancer studies within the framework of flexible parametric survival 
models. BMC Medical Research Methodology 2011;11:96.

{phang}
M. J. Crowther and P. C. Lambert. A general framework for parametric survival analysis.
Statistics in Medicine 2014;33:5280-5297.

{phang}
P. C. Lambert and P. Royston. Further development of flexible parametric
models for survival analysis. Stata Journal 2009;9:265-290.

{phang}
C. P. Nelson, P. C. Lambert, I. B. Squire and D. R. Jones. 
Flexible parametric models for relative survival, with application
in coronary heart disease. Statistics in Medicine 2007;26:5486-5498.

{phang}
P. Royston and M. K. B. Parmar. Flexible proportional-hazards and
proportional-odds models for censored survival data, with application
to prognostic modelling and estimation of treatment effects.
Statistics in Medicine 2002;21:2175-2197.

{phang}
P. Royston, P.C. Lambert. Flexible parametric survival analysis in Stata: 
Beyond the Cox model StataPress, 2011



{title:Also see}

{psee}
Online:  {manhelp strcs_postestimation ST}; 
{p_end}
