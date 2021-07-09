{smcl}
{* *! version 1.0.0 03oct2014}{...}
{hline}
{cmd:help staft} {right:also see: {helpb staft postestimation}}
{hline}

{title:Title}

{p2colset 5 14 35 2}{...}
{p2col :{cmd:staft} {hline 2}}Flexible parametric accelerated failure time models{p_end}
{p2colreset}{...}

{title:Syntax}

{phang2}
{cmd: staft} [{varlist}] {ifin} [{cmd:,} {it:options}]


{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt bk:nots(numlist)}}boundary knots for baseline{p_end}
{synopt :{opt bknotstvc(knots list)}}boundary knots for time-dependent effects{p_end}
{synopt :{cmdab:df(#)}}degrees of freedom for baseline function{p_end}
{synopt :{opt dft:vc(df_list)}}degrees of freedom for each time-dependent effect{p_end}
{synopt :{opt knots(numlist)}}knot locations for baseline {p_end}
{synopt :{opt knotst:vc(numlist)}}knot locations for time-dependent effects{p_end}
{synopt :{opt knscale(scale)}}scale for user-defined knots (default scale is time){p_end}
{synopt :{opt noorth:og}}do not use orthogonal transformation of splines variables{p_end}
{synopt :{opt tvc(varlist)}}varlist of time varying effects{p_end}

{syntab:Reporting}
{synopt :{opt eform}}exponentiate coefficients of first {cmd:ml} equation{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt showinit:ial}}display output from initial value model fits{p_end}

{syntab:Maximization options}
{synopt :{opt search(string)}}search option to pass to {cmd:ml}{p_end}
{synopt :{opt initmat(matrix_name)}}matrix of initial values to pass to {cmd:ml}{p_end}
{synopt :{opt copy}}parameters in the initial values matrix are entered by position{p_end}
{synopt :{opt skip}}any parameters found in initial values matrix but not in model are skipped{p_end}
{synopt :{opt nolog}}suppress display of log-likelihood iteration log{p_end}
{synopt :{it:{help staft##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stgenreg}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
{cmd:fweights}, {cmd:iweights}, and {cmd:pweights} may be specified using stset; {manhelp stset ST}.{p_end}
{p 4 6 2}
Factor variables are not currently supported.{p_end}


{title:Description}

{pstd}
{cmd:staft} fits flexible parametric accelerated failure time models, using restricted cubic splines. Time-dependent effects can be included. 
{cmd:staft} can be used with single- or multiple-record or single- or multiple-failure {cmd:st} data.
{p_end}

{pstd}
The model is parametrised as follows, 
{p_end}

{pmore}
S(t|X) = S_{0}(t exp(-X beta))

{pstd}
Consider the log cumulative hazard function of a Weibull distribution,
{p_end}

{pmore}
log H(t|X) = log lambda + gamma log(t)

{pstd}
we then incorporate our linear predictor
{p_end}

{pmore}
log H(t|X) = log lambda + gamma log(t exp(-X beta))

{pstd}
and expand log(t exp(-X beta)) into our spline basis functions.
{p_end}

{pstd}
See {helpb stpm2} for the flexible parametric models in a proportional hazards metric (Royston-Parmar models).
{p_end}

{pstd}
See {manhelp streg ST} for other (standard) parametric survival models.


{title:Options}

{dlgtab:Model}

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
{cmd: noorthog} suppresses orthogonal transformation of spline variables.

{phang}
{opt tvc(varlist)} gives the name of the variables that are time-dependent.
Time-dependent effects are fitted using restricted cubic splines.
The degrees of freedom are specified using the {opt dftvc()} option. 

{dlgtab:Reporting}

{phang}
{opt eform} exponentiate the coefficients of the first {cmd:ml} equation.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals. 
The default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
{opt showinitial} displays the models fitted to obtain initial values for {cmd:staft}, which includes an 
AFT Weibull model using {cmd:streg}, and a null {cmd:stpm2} model.

{dlgtab:Maximization}

{marker maximize_options}{...}
{phang}
{it:maximize_options}; {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, 
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt shownr:tolerance}, {opt tol:erance(#)}, 
{opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, {opt from(init_specs)}; see {manhelp maximize R}.  These 
options are seldom used, but the {opt difficult} option may be useful if there
are convergence problems.


{title:Example}

{pstd}Setup{p_end}
{phang2}{stata "webuse brcancer"}{p_end}
{phang2}{stata "stset rectime, failure(censrec = 1) scale(365.25)"}{p_end}

{pstd}Fit AFT model with 3 degrees of freedom for the spline function.{p_end}
{phang2}{stata "staft hormon, df(3)"}{p_end}

{title:Author}

{pstd}Michael J. Crowther{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:References}

{pstd}
P. Royston and M. K. B. Parmar. Flexible proportional-hazards and proportional-odds models for censored survival data, with 
application to prognostic modelling and estimation of treatment effects.  Statistics in Medicine 2002;21:2175-2197.
{p_end}

{pstd}
P. Royston, P.C. Lambert. Flexible parametric survival analysis in Stata:  Beyond the Cox model StataPress, 2011
{p_end}


{title:Also see}

{psee}
Online: {helpb staft postestimation}, {helpb stpm2}, {manhelp streg ST}
{p_end}
