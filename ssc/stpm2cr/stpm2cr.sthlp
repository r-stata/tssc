{smcl}
{* *! version 2.3 11Nov2018}{...}
{cmd:help stpm2cr} 
{right:also see:  {help stpm2}, {help stpm2cr postestimation}}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:stpm2cr} {hline 2}}Flexible parametric competing risks regression models{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:stpm2cr} [{it:cause1}{cmd::} [{varlist}] [{cmd:,} {it:{help stpm2cr##suboptions:suboptions}}]] 
						[{it:cause2}{cmd::} [{varlist}] [{cmd:,} {it:{help stpm2cr##suboptions:suboptions}}]] 
						... [[{it:causeN}{cmd::} [{varlist}] [{cmd:,} {it:{help stpm2cr##suboptions:suboptions}}]]] 
						{ifin} 
						[{cmd:,} {it:{help stpm2cr##options:options}}]

{marker suboptions}{...}
{synoptset 29 tabbed}{...}
{synopthdr: suboptions}
{synoptline}

{syntab: Equation Options}
{synopt :{opt bk:nots(numlist)}}boundary knots for baseline{p_end}
{synopt :{opt bknotstvc(knots list)}}boundary knots for time-dependent effects{p_end}
{synopt :{opt cure}}fit a cure model for {it:causeN}{p_end}
{synopt :{cmdab:df(#)}}degrees of freedom for baseline hazard function{p_end}
{synopt :{opt dft:vc(df_list)}}degrees of freedom for each time-dependent effect{p_end}
{synopt :{opt knots(numlist)}}knot locations for baseline hazard{p_end}
{synopt :{opt knotst:vc(numlist)}}knot locations for time-dependent effects{p_end}
{synopt :{opt nocon:stant}}suppress constant term{p_end}
{synopt :{opt sc:ale(scalename)}}specifies the scale on which the survival model is
 to be fitted{p_end}
{synopt :{opt tvc(varlist)}}varlist of time varying effects{p_end}

{synoptline}

{marker options}{...}
{synopthdr:options}
{synoptline}

{syntab:Main Options}
{synopt :{opt c:ause(numlist)}}indicator values for {it:causeN}{p_end}
{synopt :{opt cens:value(numlist)}}indicator(s) for censored values; default is {cmd:censvalue(0)}{p_end}
{synopt :{opt noorth:og}}do not use orthogonal transformation of splines variables{p_end}

{syntab:Reporting}
{synopt :{opt alleq}}report all equations{p_end}
{synopt :{opt ef:orm}}exponentiate coefficients{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}

{syntab:Max options}
{synopt :{opt lin:init}}obtain initial values by first fitting a linear function of ln(time){p_end}
{synopt :{it:{help stpm2cr##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}

{synoptline}

{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stpm2cr}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
{cmd:fweights}, {cmd:iweights}, and {cmd:pweights} may be specified using stset; {manhelp stset ST}.{p_end}

{title:Description}

{pstd}
{cmd:stpm2cr} fits competing risks flexible parametric regression models (Royston-Parmar models) by directly modelling the cumulative incidence function. 
{cmd:stpm2cr} can be used with single- or multiple-record {cmd:st} data. However, it cannot be used for multiple failures per subject.
{cmd:stpm2cr} can be fitted on either the log cumulative subdistribution hazard scale or the log cumulative odds of failure scale.

{pstd}
Alternatively, we may fit models using {manhelp stpm2 ST} in the presence of competing risks to either 
estimate the crude probability of death after fitting a relative survival model, (see {manhelp stpm2cm ST}),
estimate the cumulative incidence function i.e. cause-specific hazards using {manhelp stpm2cif ST} or 
calculate the net probability of death in a hypothetical world where competing events do not occur (a relative survival model).

{title:Suboptions}

{dlgtab:Equation Options}

{phang}
{opt bknots(knotslist)} {it:knotslist} is a two-element {it:numlist} giving
the boundary knots. By default these are located at the minimum and maximum
of the uncensored survival times. They are specified on the normal time-scale.

{phang}
{opt bknotstvc(knotslist)} {it:knotslist} gives the boundary knots for 
any time-dependent effects. By default these are the same as for the bknots
option. They are specified on the normal time-scale.

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
cubic spline function used for the baseline function. {it:#} must be more than 0,
but usually a value between 1 and 4 is sufficient, with 1 being the
default. The {cmd:knots()} option is not applicable if the {cmd:df()} option
is specified. The internal knots are placed at equally spaced centiles of the
distribution of the uncensored log survival times including two boundary knots
at the 0 and 100 centiles. For example, for {opt df(4)}:

        {hline 60}
        df  	internal knots    	centile positions
        {hline 60}
         4    	3    			25th 50th 75th
        {hline 60}
        
{pmore}
Note again that these are {it:interior knots} and there are also boundary knots
placed at the minimum and maximum of the distribution of uncensored survival
times. 

{pmore}
When the {cmd:cure} option is used df must be more than 2. An adjustment is made
to the default locations of the knots shown above. Following the same example for
{opt df(4)}, we have:

        {hline 60}
        df  	internal knots      centile positions
        {hline 60}
         4    	3                   33rd 67th 95th
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
{opt knots(# [# ...])} specifies knot locations for the baseline distribution
function, as opposed to the default locations set by {cmd:df()}. Note that
the locations of the knots are placed on the normal time-scale.
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
{opt noconstant};
see {helpb st estimation options##noconstant:[ST] estimation options}.

{phang}
{opt scale(scalename)} specifies on which scale the survival model is to be
fitted. 

{pmore}
{cmd:scale({ul:h}azard)} fits a model on the log cumulative subhazard scale,
i.e. the scale of ln(-ln(1 - F(t))). If no time-dependent effects are specified,
the resulting model has proportional subhazards.

{pmore}
{cmd:scale({ul:o}dds)} fits a model on the log cumulative odds scale for the ,
i.e. ln((F(t))/(1 - F(t))). If no time-dependent effects 
are specified then this assumes proportionality of the odds ratios over time.

{phang}
{opt tvc(varlist)} gives the name of the variables that are time-dependent.
Time-dependent effects are fitted using restricted cubic splines.
The degrees of freedom are specified using the {opt dftvc()} option. 


{title:Main Options}

{dlgtab:Model}

{phang}
{opt cause(numlist)} specifies the indicator values in the data for the causes that are fitted in the model.

{phang}
{opt censvalue(# [# ...])}  specifies the indicator value(s) in the data which represents a censored individual. 
More than one value can indicate a censored individual. 
For example, if censored individuals are indicated by values 0 and 99, we have, {opt censvalue(0 99)}. 

{phang}
{cmd: noorthog} suppresses orthogonal transformation of spline variables.

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
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.

{marker maximize_options}{...}
{dlgtab:Max options}

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
Let t denote time. {cmd:stpm2cr} works by first generating the cumulative incidence function, F(t),
using {manhelp stcompet [ST]} and then fitting a regression model against a function of the cumulative incidence. 
The procedure is illustrated for proportional hazards models, specified by option
{cmd:scale(hazard)}. F(t) is converted to an estimate of the log cumulative subhazard
function Z(t) by the formula

{pin}
        Z(t) = ln(-ln(1 - F(t)))

{pstd}
This estimate of Z(t) is then smoothed on ln(t) using regression splines with
knots placed at certain quantiles of the distribution of t. The knot positions
are chosen automatically if the spline complexity is specified by the {cmd:df()}
option, or manually by way of the {cmd:knots()} option. (Note that the knots
are placed on values of ln(t), not t.) Denote the predicted values of the log cumulative
subhazard function by Z_hat(t). The density function f(t) is

{pin}
        f(t) = dF(t)/dt = dF/dZ_hat dZ_hat/dt = (1 - F(t)) exp(Z_hat) dZ_hat(t)/dt

{pstd}
dZ_hat(t)/dt is computed from the regression coefficients of the fitted spline
function. The estimated cumulative incidence function is calculated as

{pin}
        F_hat(t) = 1 - exp(-exp(Z_hat(t)).

{pstd}
The subhazard function is calculated as f(t)/(1 - F_hat(t)).

{pstd}
If {it:varlist} is specified, the baseline cumulative incidence function (i.e. at zero values
of the covariates) is used instead of the cumulative incidence function of the raw
observations. With {cmd:df(1)} a Weibull model is fitted.

{pstd}
With {cmd:scale(odds)}, smoothing is of the log cumulative odds of failure function,
ln(F(t)/(1 - F(t))), instead of the log cumulative subhazard function. With
{cmd:df(1)} a subdistribution log-logistic model is fitted.

{pstd}
Estimation is performed by maximum likelihood. Optimisation uses the
default technique ({cmd:nr}, meaning Stata's version of Newton-Raphson
iteration.


{title:Examples}

    {hline}
{pstd}Setup{p_end}

{phang2}{stata "use http://www.stata-journal.com/software/sj4-2/st0059/prostatecancer"}{p_end}
{phang2}{stata "stset time, failure(status==1, 2, 3) scale(12) id(id) noshow"}{p_end}
{phang2}{stata "tab treatment, gen(trt)"}{p_end}

{pstd}Proportional log-cumulative subdistribution hazards model{p_end}
{phang2}{stata "stpm2cr [prostate: trt2, scale(hazard) df(4)] [CVD: trt2, scale(hazard) df(4)] [other: trt2, scale(hazard) df(4)], events(status) cause(1 2 3) cens(0) eform"}{p_end}

{pstd}Proportional odds of failure model{p_end}
{phang2}{stata "stpm2cr [prostate: trt2, scale(odds) df(4)] [CVD: trt2, scale(odds) df(4)] [other: trt2, scale(odds) df(4)], events(status) cause(1 2 3) cens(0) eform"}{p_end}

{pstd}Time-dependent effects on log-cumulative subdistribution hazard scale{p_end}
{phang2}{stata "stpm2cr [prostate: trt2, scale(hazard) df(4) tvc(trt2) dftvc(2)] [CVD: trt2, scale(hazard) df(4) tvc(trt2) dftvc(2)] [other: trt2, scale(hazard) df(4) tvc(trt2) dftvc(2)], events(status) cause(1 2 3) cens(0) eform"}{p_end}



{title:Author}

{pstd}
Sarwar Islam, University of Leicester, UK.
({browse "mailto:si113@leicester.ac.uk":si113@leicester.ac.uk})

{pstd}
Paul Lambert, University of Leicester, UK and Karolinska Institutet, Stockholm, Sweden. 
({browse "mailto:paul.lambert@leicester.ac.uk":paul.lambert@leicester.ac.uk})

{pstd}
Mark Rutherford, University of Leicester, UK.
({browse "mailto:mark.rutheford@leicester.ac.uk":mark.rutherford@leicester.ac.uk})

{title:References}

{phang}
P. C. Lambert and P. Royston. Further development of flexible parametric
models for survival analysis. Stata Journal 2009;9:265-290

{phang}
P. Royston, P.C. Lambert. Flexible parametric survival analysis in Stata: 
Beyond the Cox model StataPress, 2011


{title:Also see}

{psee}
Online:  {manhelp stpm2cr_postestimation ST:stpm2cr postestimation};
{manhelp stset ST},
{manhelp stpm2 ST},
{manhelp stpm2cif ST}
{p_end}
