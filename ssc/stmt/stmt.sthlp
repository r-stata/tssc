{smcl}
{* *! version 1.4.7 06Nov2020}}{...}
{cmd:help stmt}
{right:also see:  {help stmt_postestimation}}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:stmt} {hline 2}}Modelling multiple timescales using flexible parametric survival models on the log hazard scale{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:stmt} [{varlist}] {ifin} [{cmd:,} time1({it:sub-options}) time2({it:sub-options}) time3({it:sub-options}) {it:options}]

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}

{syntab: Multiple timescale options}
{synopt :{opt time1(sub-options)}}sub-options for timescale 1{p_end}
{synopt :{opt time2(sub-options)}}sub-options for timescale 2{p_end}
{synopt :{opt time3(sub-options)}}sub-options for timescale 3{p_end}
{synopt :{opt timeint(int_options)}}specifies two-way timescale interactions{p_end}
{synopt :{opt timeintk:nots(int_options)}}specifies internal knots for timescale interactions{p_end}
{synopt :{opt timeintbk:nots(int_options)}}specifies boundary knots for timescale interactions{p_end}

{syntab: Timescale-specific sub-options}
{synopt :{opt bk:nots(knots_list)}}boundary knots for the timescale specified{p_end}
{synopt :{opt bknotst:vc(knots_list)}}boundary knots for time-dependent effects{p_end}
{synopt :{cmdab:df(#)}}degrees of freedom for the timescale specified {p_end}
{synopt :{opt dft:vc(df_list)}}degrees of freedom for each time-dependent effect{p_end}
{synopt :{opt indi:cator(varname)}}specifies which observations are to have the second or third timescale{p_end}
{synopt :{opt knots(knots_list)}}knot locations for timescale specified{p_end}
{synopt :{opt knotst:vc(knots_list)}}knot locations for time-dependent effects{p_end}
{synopt :{opt knsc:ale(scale)}}scale for user-defined knots (default scale is time){p_end}
{synopt :{opt logt:off}} smooth the timescale over time (default is log time){p_end}
{synopt :{opt start(varname)}} the difference between the timescale and the timescale specified {cmd:stset}{p_end}
{synopt :{opt tvc(varlist)}}varlist of time varying effects{p_end}

{syntab:Estimation options}
{synopt :{opt nocon:stant}}suppress constant term{p_end}
{synopt :{opt nod:es(#)}}specify the number of nodes used in Gauss-Legendre quadrature numerical
integration of the hazard function (default is 30){p_end}
{synopt :{opt noorth:og}}do not use orthogonal transformation of splines variables{p_end}


{syntab:Reporting options}
{synopt :{opt nohr}}do not report hazard ratios{p_end}
{synopt :{opt verb:ose}}verbose output details the process of the {cmd:stmt} program{p_end}

{syntab:Maximization options}
{synopt :{opt from(matrix)}}initial coefficient values stored in a matrix{p_end}
{synopt :{opt init:h(varname)}}initial hazard values{p_end}
{synopt :{it:{help stmt##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stmt}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
{cmd:fweights}, {cmd:iweights}, and {cmd:pweights} may be specified using stset; {manhelp stset ST}.{p_end}

{title:Description}

{pstd}
{cmd:stmt} fits flexible parametric survival models (Royston-Parmar models)
on the log hazard scale where multiple timescales are allowed

{pstd}
See {manhelp stpm2 ST} for flexible parametric survival models on the log cumulative hazard scale, and {manhelp strcs ST}
for flexible parametric survival models on the log hazard scale.


{title:Options}

{dlgtab:Multiple timescale options}

{phang}
{opt time1(sub-options)} {cmd:time1()} contains {it:sub-options} for the first timescale
(see below for a list of {it:sub-options}). The first timescale is always specified using the
{cmd:stset} command.

{phang}
{opt time2(sub-options)} {cmd:time2()} contains {it:sub-options} for the second timescale
(see below for a list of {it:sub-options}). The second and third timescales are functions
 of the first timescale; the difference between the second timescale and the first timescale
 is specified in the {cmd:start} sub-option.

{phang}
{opt time3(sub-options)} {cmd:time3()} contains {it:sub-options} for the third timescale
(see below for a list of {it:sub-options}). The second and third timescales are functions
 of the first timescale; the difference between the third timescale and the first timescale
 is specified in the {cmd:start} sub-option.

{phang}
{opt timeint(int_list)} {it:int_list} contains details for two-way timescale interactions.
The following syntax applies:

{pmore}
{cmd:timeint(t1:t2 2:4)}

{pmore}
This will create an interaction between timescale 1 and timescale 2, as specified in the
time1() and time2() options where a restricted cubic spline function of timescale 1 with
2 degrees of freedom is interacted with a restricted cubic spline function of timescale 2
with 4 degrees of freedom. The space separates the specified timescales and their degrees
of freedom.

{phang}
{opt timeintk:nots(int_list)} {it:int_list} contains the internal knots for two-way timescale interactions.
The following syntax applies:

{pmore}
{cmd:timeint(2 5 : 50 60 70)}

{pmore}
This will create restricted cubic splines for timescale 1 with internal knots at 2 and 5 (3 degrees of freedom), and
restricted cubic splines for timescale 2 at 50, 60 and 70 (4 degrees of freedom), and then interact the spline terms
together. Note that knots should be specified on the timescale specified in the time1() and time2() options.


{phang}
{opt timeintbk:nots(int_list)} {it:int_list} contains the boundary knots for two-way timescale interactions.
The following syntax applies:

{pmore}
{cmd:timeint(0 7 : 25 95)}

{pmore}
This will create restricted cubic splines for timescale 1 with boundary knots at 0 and 7, and
restricted cubic splines for timescale 2 with boundaries at 25 and 95, and then interact the spline terms
together. Note that both the df() options and timeintknots() options can be used with the timeintbknots() option and
that knots should be specified on the timescale specified in the time1() and time2() options.


{dlgtab:Timescale-specific sub-options}

{phang}
{opt bknots(knots_list)} {it:knots_list} is a two-element {it:numlist} giving
the boundary knots. By default these are located at the minimum and maximum
of the uncensored survival times. They are specified on the scale defined
by {cmd:knscale()}.

{phang}
{opt bknotstvc(knots_list)} {it:knots_list} gives the boundary knots for
any time-dependent effects. By default these are the same as for the {cm:bknots()}
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
{opt indicator(varname)} specifies an indicator variable which indicates which
observations have more than one timescale. The indicator variable should be
coded 0 for those observations who did not have the second/third timescale,
and 1 for those who did.

{phang}
{opt knots(# [# ...])} specifies knot locations for the baseline distribution
function, as opposed to the default locations set by {cmd:df()}. Note that
the locations of the knots are placed on the scale defined by {cmd:knscale}.
However, the scale used by the restricted cubic spline function is always
log time unless the {cmd:logtoff} option is specified. Default knot positions are determined by the {opt df()} option.

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
survival times, or log survival times depending on whether the {cmd:logtoff} option
is specified. The default is {cmd:knscale(time)}.

{phang}
{opt logtoff} smoothes the timescale over time using restricted cubic splines.
By default, smoothing is over log time.

{phang}
{opt start(varname)} specifies the difference between the timescale specified in {cmd:stset}
and the timescale of interest. For example, if the first timescale of interest (t1) is time
since diagnosis, and the second timescale (t2) is attained age, attained age is equal to
time since diagnosis plus the age at diagnosis; i.e., t2=t1 + age at diagnosis. Thus in this
example, {it:varname} would be a variable which contains the age at diagnosis. Not for use when
using {cmd:time1()} since this timescale is specified when using the {cmd:stset} command.

{phang}
{opt tvc(varlist)} gives the name of the variables that are time-dependent.
Time-dependent effects are fitted using restricted cubic splines.
The degrees of freedom are specified using the {opt dftvc()} option.


{dlgtab:Estimation options}

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


{dlgtab:Reporting}

{phang}
{opt nohr} reports the coefficients instead of hazard ratios.

{phang}
{opt verbose} verbose output details the process of the {cmd:stmt} program.

{marker maximize_options}{...}
{dlgtab:Maximization options}

{phang}
{opt from(matrix)} defines the matrix containing initial coefficient estimates to be used in maximum
likelihood estimation. By default {cmd:stmt} estimates initial hazard estimates by fitting a model
on the log cumulative hazard scale using the {cmd:stpm2} command.

{phang}
{opt inith(varname)} defines initial hazard estimates to be used in maximum likelihood
estimation. By default {cmd:stmt} estimates initial hazard estimates by fitting a model on the
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
Let t denote time. {cmd:stmt} works by first fitting a flexible parametric survival
model on the log cumulative hazard scale using the {cmd:stpm2} command. The predicted hazard
from this model is used to estimate initial values of the log hazard with specified
covariates. These initial values are used within the maximum likelihood estimation.

{pstd}
Mutliple timescales are included in the model as a function of each other. For example, if one
wishes to model both the effect of time since diagnosis of a disease (timescale 1), and attained age
(timescale 2), timescale 2 is equal to timescale 1 plus the age at diagnosis. Standard models which
use maximum likelihood with analytical forms of the log likelihood function cannot utilize this relationship
between timescales. Here, numerical integration is used to get the log likelihood function meaning that
modelling including multiple timescales in this way is valid. Flexible parametric survival models on the
log hazard scale are used with Gaussian Quadrature.
The log hazard estimate, ln(h_hat(t)), is smoothed on ln(t), or t if {cmd: logtoff} is
specified, using restricted cubic splines with knots placed at certain quantiles of the
distribution of t. The knot positions are chosen automatically if the spline complexity
is specified by the {cmd:df()} option, or manually by way of the {cmd:knots()} option.

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

{pstd}Modelling one timescale (time since diagnosis) {p_end}
{phang2}{stata "stset rectime, failure(censrec = 1) scale(365.24)"}{p_end}
{phang2}{stata "stmt hormon, time1(df(4)) "}{p_end}

{pstd}Modelling one timescale: time-dependent effects on the log hazard scale{p_end}
{phang2}{stata "stmt hormon, time1(df(4) tvc(hormon) dftvc(3))"}{p_end}

{pstd}Modelling two timescales (time since diagnosis and attained age){p_end}
{phang2}{stata "stmt hormon, time1(df(4)) time2(start(x1) df(2))"}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:stmt} stores the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(converged)}}1 if the model converged{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in overall model test{p_end}
{synopt:{cmd:e(dfbase_t#)}}degrees of freedom specified for timescale #{p_end}
{synopt:{cmd:e(Ntimeint)}}number of timescale interactions #{p_end}
{synopt:{cmd:e(df_timeint#_t1)}}degrees of freedom used for timescale 1 of timescale interaction #{p_end}
{synopt:{cmd:e(df_timeint#_t2)}}degrees of freedom used for timescale 2 of timescale interaction #{p_end}
{synopt:{cmd:e(minknot)}}value of minimum knot{p_end}
{synopt:{cmd:e(maxknot)}}value of maximum knot{p_end}
{synopt:{cmd:e(nodes)}}number of nodes used in numerical integration{p_end}
{synopt:{cmd:e(dev)}}deviance{p_end}
{synopt:{cmd:e(AIC)}}Akaike information criterion{p_end}
{synopt:{cmd:e(BIC)}}Bayesian information criterion{p_end}
{synopt:{cmd:e(Ntimescales)}}BNumber of timescales included in model{p_end}

{synoptset 25 tabbed}{...}
{p2col 8 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:stmt}{p_end}
{synopt:{cmd:e(predict)}}{cmd:stmt_pred}{p_end}
{synopt:{cmd:e(varlist)}}variables included in the model{p_end}
{synopt:{cmd:e(depvar)}}{cmd:_d _t}{p_end}
{synopt:{cmd:e(orthog)}}{cmd:orthog} if splines were orthogonalized{p_end}
{synopt:{cmd:e(indicator_t#)}}{cmd:orthog} if timescale # only applied to a subset of observations defined by the indicator variable {p_end}
{synopt:{cmd:e(rcsterms_base_t#)}}name of spline terms used to model timescale #{p_end}
{synopt:{cmd:e(bhknots_t#)}}value of the knots used to model timescale #{p_end}
{synopt:{cmd:e(exp_bhknots_t#)}}exponential of the knots used to model timescale #{p_end}
{synopt:{cmd:e(tvc_t#)}}variables with time-dependent effects on timescale #{p_end}
{synopt:{cmd:e(rcsterms_t#_{it:varname})}}name of spline terms used to model the time-dependent effect for {it:varname} on timescale #{p_end}
{synopt:{cmd:e(tvcknots_t#_{it:varname})}}value of the knots for the time-dependent effect of {it:varname} on timescale #{p_end}
{synopt:{cmd:e(exp_tvcknots_t#_{it:varname})}}exponential of the knots for the time-dependent effect of {it:varname} on timescale #{p_end}
{synopt:{cmd:e(knots_timeint#_t1)}}knots for the first timescale as part of timescale interaction #{p_end}
{synopt:{cmd:e(knots_timeint#_t2)}}knots for the second timescale as part of timescale interaction #{it:varname} on timescale #{p_end}
{synopt:{cmd:e(noconstant)}}{cmd: noconstant} if constant term was supressed{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(vce)}}vcetype specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(ml_method)}}type of ml method{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform maximization or minimization{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of estimators{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(R_bh_t#)}}orthogonlization matrix for timescale #{p_end}
{synopt:{cmd:e(ilog)}}iteration log{p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(R_{it:varname})}}orthogonalization matrix for splines of time-dependent effect {it:varname}{p_end}
{synopt:{cmd:e(R_timeint#_t1)}}orthogonalization matrix for splines of timescale 1 in timescale interaction #{p_end}
{synopt:{cmd:e(R_timeint#_t2)}}orthogonalization matrix for splines of timescale 2 in timescale interaction #{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Author}
{phang}
Hannah Bower,Karolinska Institutet, Stockholm, Sweden.({browse "mailto:hannah.bower@ki.se":hannah.bower@ki.se})

{phang}
Therese M-L Andersson, and Karolinska Institutet, Stockholm, Sweden.

{phang}
Michael Crowther, University of Leicester, UK and Karolinska Institutet, Stockholm, Sweden.

{phang}
Paul Lambert, University of Leicester, UK.


{title:References}

{phang}
H. Bower, M.J. Crowther, P. C. Lambert. strcs: A command for fitting flexible parametric
survival models on the log-hazard scale. The Stata Journal, 2016;16:989-1012.

{phang}
P. Royston, P.C. Lambert. Flexible parametric survival analysis in Stata:
Beyond the Cox model StataPress, 2011


{title:Also see}

{psee}
Online:  {manhelp stmt_postestimation ST};
{p_end}

{psee}
Online:  {manhelp strcs ST};
{p_end}
