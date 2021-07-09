{smcl}
{* *! version 1.6.6 22Jul2016}{...}
{cmd:help stpm2} 
{right:also see:  {help stpm}, {help stpm2 postestimation}}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:stpm2} {hline 2}}Flexible parametric survival models{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:stpm2} [{varlist}] {ifin} [{cmd:,} {it:options}]

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt bhaz:ard(varname)}}invokes relative survival models where {it: varname}
 holds the expected mortality rate (hazard) at the time of death{p_end}
{synopt :{opt bk:nots(numlist)}}boundary knots for baseline{p_end}
{synopt :{opt bknotstvc(knots list)}}boundary knots for time-dependent effects{p_end}
{synopt :{opt cure}}fit a cure model{p_end}
{synopt :{cmdab:df(#)}}degrees of freedom for baseline hazard function{p_end}
{synopt :{opt dft:vc(df_list)}}degrees of freedom for each time-dependent effect{p_end}
{synopt :{opt failconvlininit}}automatically try lininit option if convergence fails{p_end}
{synopt :{opt knots(numlist)}}knot locations for baseline hazard{p_end}
{synopt :{opt knotst:vc(numlist)}}knot locations for time-dependent effects{p_end}
{synopt :{opt knscale(scale)}}scale for user-defined knots (default scale is time){p_end}
{synopt :{opt nocon:stant}}suppress constant term{p_end}
{synopt :{opt rcsbaseoff}}do not include baseline spline variables{p_end}
{synopt :{opt noorth:og}}do not use orthogonal transformation of splines variables{p_end}
{synopt :{opt sc:ale(scalename)}}specifies the scale on which the survival model is
 to be fitted{p_end}
{synopt :{opt st:ratify(varlist)}}for backward comapatibility with stpm{p_end}
{synopt :{opt th:eta(est|#)}}for backward comapatibility with stpm{p_end}
{synopt :{opt tvc(varlist)}}varlist of time varying effects{p_end}

{syntab:Reporting}
{synopt :{opt alleq}}report all equations{p_end}
{synopt :{opt ef:orm}}exponentiate coefficients{p_end}
{synopt :{opt keepc:ons}}do not drop constraints used in ml routine{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt showc:ons}}list constraints in output{p_end}

{syntab:Max options}
{synopt :{opt const:heta(#)}}constrain value of theta when using Aranda-Ordaz family of link functions{p_end}
{synopt :{opt initstrata(varlist)}}stratification variables for initial values{p_end}
{synopt :{opt initt:heta(#)}}initial value of theta (default 1: log cumulative odds scale){p_end}
{synopt :{opt lin:init}}obtain initial values by first fitting a linear function of ln(time){p_end}
{synopt :{it:{help stpm2##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stpm2}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
{cmd:fweights}, {cmd:iweights}, and {cmd:pweights} may be specified using stset; {manhelp stset ST}.{p_end}

{title:Description}

{pstd}
{cmd:stpm2} fits flexible parametric survival models (Royston-Parmar models). {cmd:stpm2} 
can be used with single- or multiple-record or single- or multiple-failure {cmd:st} data.
Survival models can be fitted on the log cumulative hazard scale, the log cumulative
odds scale, the standard normal deviate (probit) scale, or on a scale defined by the
value of {it:theta} using the Aranda-Ordaz family of link functions.

{pstd}
{cmd:stpm2} can fit the same models as {cmd:stpm}, but is more flexible in that it does
not force the knots for time-dependent effects to be the same as those used
for the baseline distribution function. In addition, {cmd:stpm2} can fit relative survival
models by use of the {cmd:bhazard()} option. Post-estimation commands have been extended
over what is available in {cmd:stpm}. {cmd:stpm2} is noticeably faster than {cmd:stpm}.

{pstd}
See {manhelp streg ST} for other (standard) parametric survival models.


{title:Options}

{dlgtab:Model}

{phang}
{opt bhazard(varname)} is used when fitting relative survival models.
{it:varname} gives the expected mortality rate at the time of death/censoring.
{cmd:stpm2} gives an error message when there are missing values of {it:varname},
since this usually indicates that an error has occurred when merging the
expected mortality rates. 

{phang}
{opt bknots(knotslist)} {it:knotslist} is a two-element {it:numlist} giving
the boundary knots. By default these are located at the minimum and maximum
of the uncensored survival times. They are specified on the scale defined
by {cmd:knscale()}.

{phang}
{opt bknotstvc(knotslist)} {it:knotslist} gives the boundary knots for 
any time-dependent effects. By default these are the same as for the bknots
option. They are specified on the scale defined by {cmd:knscale()}.

{pmore}
For example,

{pmore}
{cmd:bknotstvc(x1 0.01 10 x2 0.01 8)}

{phang}
{opt cure} is used when fitting cure models. It forces the cumulative hazard to 
be constant after the last knot. When the {cmd:df()} option is used together with 
the {cmd:cure} option the internal knots are placed evenly according to centiles of the
distribution of the uncensored log survival times except one that is placed at the 
95th centile. Cure models can only be used when modelling on the log cumulative 
hazard scale ({cmd:scale(hazard)}

{phang}
{opt df(#)} specifies the degrees of freedom for the restricted
cubic spline function used for the baseline function. {it:#} must be between
1 and 10, but usually a value between 1 and 4 is sufficient, with 3 being the
default. The {cmd:knots()} option is not applicable if the {cmd:df()} option
is specified. The knots are placed at the following centiles of the
distribution of the uncensored log survival times:

        {hline 60}
        df  knots        Centile positions
        {hline 60}
         1    0    (no knots)
         2    1    50
         3    2    33 67
         4    3    25 50 75
         5    4    20 40 60 80
         6    5    17 33 50 67 83
         7    6    14 29 43 57 71 86
         8    7    12.5 25 37.5 50 62.5 75 87.5
         9    8    11.1 22.2 33.3 44.4 55.6 66.7 77.8 88.9
        10    9    10 20 30 40 50 60 70 80 90     
        {hline 60}
	
{pmore}
Note that these are {it:interior knots} and there are also boundary knots
placed at the minimum and maximum of the distribution of uncensored survival
times. 

{pmore}
When the {cmd:cure} option is used df must be between 3 and 11 and the default 
location of the knots are as follows.

        {hline 60}
        df  knots        Centile positions
        {hline 60}
         3    2    50 95
         4    3    33 67 95
         5    4    25 50 75 95
         6    5    20 40 60 80 95
         7    6    17 33 50 67 83 95
         8    7    14 29 43 57 71 86 95
         9    8    12.5 25 37.5 50 62.5 75 87.5 95
        10    9    11.1 22.2 33.3 44.4 55.6 66.7 77.8 88.9 95
        11   10    10 20 30 40 50 60 70 80 90 95		
        {hline 60}


{phang}
{opt dftvc(df_list)} gives the degrees of freedom for time-dependent effects
in {it:df_list}. The potential degrees of freedom are listed under the
{opt df()} option. With 1 degree of freedom a linear effect of log time is fitted.
If there is more than one time-dependent effect and different degress of freedom
are requested for each time-dependent effect then the following syntax applies:

{pmore}
{cmd:dftvc(x1:3 x2:2 1)}

{pmore}
This will use 3 degrees of freedom for {cmd:x1}, 2 degrees of freedom for
{cmd:x2} and 1 degree of freedom for all remaining time-dependent effects. 

{phang}
{opt failconvlininit} automatically tries the {opt lininit} option of the
model fails to converge.

{phang}
{opt initstrata(varlist)} By default stpm2 fits a Cox model to obtain initial values.
The initstrata() option fits a stratified model for the initial values and may useful when fitting competing risks models or to allow the estimated baseline hazard to vary between the specified strata.


{phang}
{opt knots(# [# ...])} specifies knot locations for the baseline distribution
function, as opposed to the default locations set by {cmd:df()}. Note that
the locations of the knots are placed on the scale defined by {cmd:knscale}.
However, the scale used by the restricted cubic spline function is always
log time. Default knot positions are determined by the {opt df()} option.

{phang}
{opt knotstvc(knotslist)} defines numlist {it:knotslist} as the location
of the interior knots for time-dependent effects. If different knots 
are required for different time-dependent effects the option is
specified, for example, as follows:

{pmore}
{cmd:knotstvc(x1 1 2 3 x2 1.5 3.5)}

{phang}
{opt knscale(scale)} sets the scale on which user-defined knots are specified.
{cmd:knscale(time)} denotes the original time scale, {cmd:knscale(log)} the
log time scale and {cmd:knscale(centile)} specifies that the knots
are taken to be centile positions in the distribution of the uncensored log
survival times. The default is {cmd:knscale(time)}.

{phang}
{opt noconstant};
see {helpb st estimation options##noconstant:[ST] estimation options}.

{phang}
{cmd: noorthog} suppresses orthogonal transformation of spline variables.

{phang}
{cmd: rcsbaseoff} drops baseline spline variables from the model. With this option
you will generally want to specify your baseline separatly in two or more strata. For example, 
the following code will fit a separate baseline hazard for males and females.

{pmore}
{cmd:stpm2 males females, scale(hazard) tvc(males females) dftvc(3) nocons rcsbaseoff}

{phang}
Note that identical fitted values would be obtained if using the following.

{pmore}
{cmd:stpm2  females, df(3) scale(hazard) tvc(females) dftvc(3)}

{phang}
{opt scale(scalename)} specifies on which scale the survival model is to be
fitted. 

{pmore}
{cmd:scale({ul:h}azard)} fits a model on the log cumulative hazard scale,
i.e. the scale of ln(-ln S(t)). If no time-dependent effects are specified,
the resulting model has proportional hazards.

{pmore}
{cmd:scale({ul:o}dds)} fits a model on the log cumulative odds scale,
i.e. ln((1 - S(t))/S(t)). If no time-dependent effects 
are specified then this is a gives a proportional odds model.

{pmore}
{cmd:scale({ul:n}ormal)} fits a model on the normal equivalent deviate
scale (i.e. a probit link for the survival function, invnorm(1 - S(t))). 

{pmore}
{cmd:scale({ul:t}heta)} fits a model on a scale defined by the value of theta
for the Aranda-Ordaz family of link functions, i.e.
ln((S(t)^(-{it:theta}) - 1)/{it:theta}). Note that theta = 1 corresponds to a
proportional odds model and theta = 0 to a proportional
cumulative hazards model.

{phang}
{opt stratify(varlist)} is provided for compatibility with {help stpm}.
Members of {it:varlist} are modelled with time-dependent effects. See
the {opt tvc()} and {opt dftvc()} options for {cmd:stpm2}'s way of
specifying time-dependent effects.

{phang}
{cmd:theta(}{cmd:est}|{it:#}{cmd:)} is provided for compatibility with
{help stpm}. {cmd:est} requests that theta be estimated, whereas {it:#}
fixes theta to {it:#}. See {opt constheta()} and {opt inittheta()} for
{cmd:stpm2}'s way of specifying theta.

{phang}
{opt tvc(varlist)} gives the name of the variables that are time-dependent.
Time-dependent effects are fitted using restricted cubic splines.
The degrees of freedom are specified using the {opt dftvc()} option. 


{dlgtab:Reporting}

{phang}
{opt alleq} reports all equations used by ml. The models are fitted by using
various constraints for parameters associated with the derivatives of the
spline functions. These parameters are generally not of interest and thus
are not shown by default. In addition, an extra equation is used when fitting
delayed entry models, and again this is not shown by default.

{phang}
{opt eform} reports the exponentiated coefficents. For models on the log
cumulative hazard scale {opt scale(hazard)} this gives hazard ratios if
the covariate is not-time dependent. Similarly, for models on the log
cumulative odds scale {opt scale(odds)} this option will give odds ratios
for non time-dependent effects.

{phang}
{opt keepcons} prevents the constraints imposed by {cmd:stpm2} on the
derivatives of the spline function when fitting delayed entry models
being dropped. By default, the constraints are dropped.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
{opt showcons} The constraints used by {cmd:stpm2} for the derivatives of
the spline function and when fitting delayed entry models are not listed by
default. Use of this option lists them in the output.

{marker maximize_options}{...}
{dlgtab:Max options}
 
{phang}
{opt constheta(#)} constrains the value of theta, i.e. it is treated as a known
constant.

{phang}
{opt inittheta(#)} gives an initial value for theta in the Aranda-Ordaz
family of link functions.

{phang}
{opt lininit} This obtains initial values by fitting only the first spline
basis function (i.e. a linear function of log survival time).
This option is seldom needed.

{phang}
{it:maximize_options}; {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, 
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt shownr:tolerance}, {opt tol:erance(#)}, 
{opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, {opt from(init_specs)}; see {manhelp maximize R}.  These 
options are seldom used, but the {opt difficult} option may be useful if there
are convergence problems when fitting models that use Aranda-Ordaz family of link
functions.


{title:Remarks}

{pstd}
Let t denote time. {cmd:stpm2} works by first calculating the survival function
after fitting a Cox proportional hazards model. The procedure is
illustrated for proportional hazards models, specified by option
{cmd:scale(hazard)}. S(t) is converted to an estimate of the log cumulative hazard
function Z(t) by the formula

{pin}
	Z(t) = ln(-ln S(t))

{pstd}
This estimate of Z(t) is then smoothed on ln(t) using regression splines with
knots placed at certain quantiles of the distribution of t. The knot positions
are chosen automatically if the spline complexity is specified by the {cmd:df()}
option, or manually by way of the {cmd:knots()} option. (Note that the knots
are placed on values of ln(t), not t.) Denote the predicted values of the log cumulative
hazard function by Z_hat(t). The density function f(t) is

{pin}
	f(t) = -dS(t)/dt = dS/dZ_hat dZ_hat/dt = S(t) exp(Z_hat) dZ_hat(t)/dt

{pstd}
dZ_hat(t)/dt is computed from the regression coefficients of the fitted spline
function. The estimated survival function is calculated as

{pin}
	S_hat(t) = exp(-exp Z_hat(t)).

{pstd}
The hazard function is calculated as f(t)/S_hat(t).

{pstd}
If {it:varlist} is specified, the baseline survival function (i.e. at zero values
of the covariates) is used instead of the survival function of the raw
observations. With {cmd:df(1)} a Weibull model is fitted.

{pstd}
With {cmd:scale(normal)}, smoothing is of the Normal quantile function,
invnorm(1 - S(t)), instead of the log cumulative hazard function. With
{cmd:df(1)} a lognormal model is fitted.

{pstd}
With {cmd:scale(odds)}, smoothing is of the log odds of failure function,
ln((1 - S(t))/S(t)), instead of the log cumulative hazard function. With
{cmd:df(1)} a log-logistic model is fitted.

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
{phang2}{stata "stpm2 hormon, scale(hazard) df(4) eform"}{p_end}

{pstd}Proportional odds model{p_end}
{phang2}{stata "stpm2 hormon, scale(odds) df(4) eform"}{p_end}

{pstd}Time-dependent effects on cumulative hazard scale{p_end}
{phang2}{stata "stpm2 hormon, scale(hazard) df(4) tvc(hormon) dftvc(3)"}{p_end}

{pstd}User defined knots at centiles of uncensored event times{p_end}
{phang2}{stata "stpm2 hormon, scale(hazard)  knots(20 50 80) knscale(centile)"}{p_end}


{title:Author}

{pstd}
Paul Lambert, University of Leicester, UK.
({browse "mailto:paul.lambert@leicester.ac.uk":paul.lambert@leicester.ac.uk})

{pstd}
The option to fit cure models was implemented by Therese Andersson, Karolinska Institutet, Stockholm, Sweden
({browse "mailto:therese.m-l.andersson@ki.se":therese.m-l.andersson@ki.se})

{pstd}
Various other additions and suggestions by Patrick Royston, MRC Clinical Trials Unit, London, UK.
({browse "mailto:pr@ctu.mrc.ac.uk":pr@ctu.mrc.ac.uk})


{title:References}

{phang}
P. C. Lambert and P. Royston. Further development of flexible parametric
models for survival analysis. Stata Journal 2009;9:265-290

{phang}
C. P. Nelson, P. C. Lambert, I. B. Squire and D. R. Jones. 
Flexible parametric models for relative survival, with application
in coronary heart disease. Statistics in Medicine 2007;26:5486-5498

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
Online:  {manhelp stpm2_postestimation ST:stpm2 postestimation};
{manhelp stset ST},
{help stpm}
{p_end}
