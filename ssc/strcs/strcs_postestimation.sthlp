{smcl}
{* *! version 1 25Jun2015}{...}
{cmd:help strcs postestimation} 
{right:also see:  {help strcs}}
{hline}

{title:Title}

{p2colset 5 34 36 2}{...}
{p2col :{hi:[ST] strcs postestimation} {hline 2}}Post-estimation tools for {cmd:strcs}{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following standard post-estimation commands are available:

{synoptset 13 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_adjust2
{p2col :{helpb estat##predict:estat}}post estimation statistics{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{p2col :{helpb strcs postestimation##predict:predict}}predictions, residuals etc{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}


{p 8 16 2}
{cmd:predict} {newvar} {ifin} [{cmd:,} {it:statistic} ]


{phang}
Note: in the table below, {it:vn} is an abbreviation for {it:varname}.

{synoptset 31 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Main}
{synopt :{opt at(vn # [vn # ...])}}predict at values of specified covariates{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{opt cumh:azard}}cumulative hazard function{p_end}
{synopt :{opt h:azard}}hazard function{p_end}
{synopt :{opt hdiff1(vn # [vn # ...])}}1st hazard function for difference in hazard functions{p_end}
{synopt :{opt hdiff2(vn # [vn # ...])}}2nd hazard function for difference in hazard functions{p_end}
{synopt :{opt hrn:umerator(vn # [vn # ...])}}numerator for (time-dependent) hazard ratio{p_end}
{synopt :{opt hrd:enominator(vn # [vn # ...])}}denominator for (time-dependent) hazard ratio{p_end}
{synopt :{opt nodes(#)}}specifies the number of nodes used in Gauss-Legendre quadrature numerical integration 
when predicting the cumulative hazard and calculating the survival (default is 30){p_end}
{synopt :{opt per(#)}}express hazard rates (and differences) per # person years{p_end}
{synopt :{opt sdiff1(vn # [vn # ...])}}1st survival curve for difference in survival functions{p_end}
{synopt :{opt sdiff2(vn # [vn # ...])}}2nd survival curve for difference in survival functions{p_end}
{synopt :{opt stdp}}standard error of predicted function{p_end}
{synopt :{opt s:urvival}}survival function{p_end}
{synopt :{opt time:var(vn)}}time variable used for predictions (default {cmd:_t}){p_end}
{synopt :{opt xb}}the linear predictor{p_end}
{synopt :{opt xbnob:aseline}}predicts the linear predictor, excluding the spline function{p_end}
{synopt :{opt zero:s}}sets all covariates to zero (baseline prediction){p_end}

{syntab:Subsidiary}
{synopt :{opt lev:el(#)}}sets confidence level (default 95){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} 
Statistics are available both in and out of sample; type
{cmd:predict} {it:...} {cmd:if e(sample)} {it:...} if wanted only for the
estimation sample.{p_end}
{p 4 6 2} 


{title:Options for predict}

{pstd}
Note that if a relative survival model has been fitted by use of the
{cmd:bhazard()} option then survival refers to relative
survival and hazard refers to excess hazard.

{dlgtab:Main}

{phang}
{opt at(varname # [ varname # ...])} requests that the covariates specified by 
the listed {it:varname}(s) be set to the listed {it:#} values. For example,
{cmd:at(x1 1 x3 50)} would evaluate predictions at {cmd:x1} = 1 and
{cmd:x3} = 50. This is a useful way to obtain out of sample predictions. 
Note that if {opt at()} is used together with {opt zeros} all covariates not 
listed in {opt at()} are set to zero. If {opt at()} is used without {opt zeros} 
then all covariates not listed in {opt at()} are set to their sample
values. See also {opt zeros}.

{phang}
{opt ci} calculate a confidence interval for the requested statistic and
stores the confidence limits in {it:newvar}{cmd:_lci} and
{it:newvar}{cmd:_uci}.

{phang}
{opt cumhazard} predicts the cumulative hazard function using the Gauss-Legendre 
quadrature numerical integration method.

{phang}
{opt hazard} predicts the hazard function.

{phang}
{opt hdiff1(varname # ...)}, {opt hdiff2(varname # ...)} predict
the difference in hazard functions with the first hazard function defined
by the covariate values listed for {opt hdiff1()} and the second by
those listed for {opt hdiff2()}. By default, covariates not specified
using either option are set to zero. Note that setting the remaining values
of the covariates to zero may not always be sensible. If {it:#} is set to
{cmd:.} then {it:varname} takes its observed values in the dataset.

{pmore}
Example: {cmd:hdiff1(hormon 1)} (without specifying {cmd:hdiff2()})
computes the difference in predicted hazard functions at {cmd:hormon}
= 1 compared with {cmd:hormon} = 0.

{pmore}
Example: {cmd:hdiff1(hormon 2) hdiff2(hormon 1)} computes the difference in
predicted hazard functions at {cmd:hormon} = 2 compared with {cmd:hormon} = 1.

{pmore}
Example: {cmd:hdiff1(hormon 2 age 50) hdiff2(hormon 1 age 30)}
computes the difference in predicted hazard functions at
{cmd:hormon} = 2 and {cmd:age} = 50 compared with {cmd:hormon} = 1
and {cmd:age} = 30.

{phang}
{opt hrdenominator(varname # ...)} specifies the denominator of the hazard
ratio. By default, all covariates other than {it:varname} and any other
variables mentioned are set to zero. See cautionary note in {opt hrnumerator}.
If {it:#} is set to {cmd:.} then {it:varname} takes its observed values
in the dataset.

{phang}
{opt hrnumerator(varname # ...)} predicts the (time-dependent) hazard ratio
with the numerator of the hazard ratio. By default, all covariates other than
{it:varname} and any other variables mentioned are set to zero. Note that
setting the remaining values of the covariates to zero may not always be
sensible. If {it:#} is set to {cmd:.} then {it:varname} takes 
its observed values in the dataset.

{phang} 
{opt nodes(#)} specifies the number of nodes to be used when numerically integrating
the estimated hazard function using Gauss-Legendre quadrature. Numerical integration is required 
when predicting the cumulative hazard and survival functions. The default number of nodes is 30.

{phang}
{opt per(#)} express hazard rates and difference in hazard rates per # person years.

{phang}
{opt sdiff1(varname # ...)}, {opt sdiff2(varname # ...)} predict
the difference in survival curves with the first survival curve defined
by the covariate values listed for {opt sdiff1()} and the second by
those listed for {opt sdiff2()}. By default, covariates not specified
using either option are set to zero. Note that setting the remaining values
of the covariates to zero may not always be sensible. If {it:#} is set to
{cmd:.} then {it:varname} takes its observed values in the dataset.

{pmore}
Example: {cmd:sdiff1(hormon 1)} (without specifying {cmd:sdiff2()})
computes the difference in predicted survival curves at {cmd:hormon}
= 1 compared with {cmd:hormon} = 0.

{pmore}
Example: {cmd:sdiff1(hormon 2) sdiff2(hormon 1)} computes the difference in
predicted survival curves at {cmd:hormon} = 2 compared with {cmd:hormon} = 1.

{pmore}
Example: {cmd:sdiff1(hormon 2 age 50) sdiff2(hormon 1 age 30)}
computes the difference in predicted survival curves at
{cmd:hormon} = 2 and {cmd:age} = 50 compared with {cmd:hormon} = 1
and {cmd:age} = 30.

{phang}
{opt stdp} calculates standard error of prediction and stores it in
{it:newvar}_se. Only available for the {opt xb} and
{opt xbnobaseline} options.

{phang}
{opt survival} predicts the survival function.

{phang}
{opt timevar(varname)} defines the variable used as time in the predictions.
Default {it:varname} is {cmd:_t}. This is useful for large datasets where 
for plotting purposes predictions are only needed for 200 observations for example. 
Note that some caution should be taken when using this option as predictions may be 
made at whatever covariate values are in the first 200 rows of data.
This can be avoided by using the {opt at()} option and/or the {opt zeros} option to 
define the covariate patterns for which you require the predictions.


{phang}
{opt xb} predicts the linear predictor, including the spline function.

{phang}
{opt xbnobaseline} predicts the linear predictor, excluding the spline
function - i.e. only the time-fixed part of the model.

{phang}
{opt zeros} sets all covariates to zero (baseline prediction). For 
example, {cmd:predict s0, survival zeros} calculates the baseline
survival function. See also {opt at()}.

{dlgtab:Subsidiary}

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}
or as set by (help set level}.



 
{title:Examples}

{pstd}Setup{p_end}
{phang2}{stata "webuse brcancer"}{p_end}
{phang2}{stata "stset rectime, failure(censrec = 1)"}{p_end}

{pstd}Proportional hazards model{p_end}
{phang2}{stata "strcs hormon, df(4)"}{p_end}
{phang2}{stata "predict h, hazard ci"}{p_end}
{phang2}{stata "predict s, survival ci"}{p_end}

{pstd}Time-dependent effects on cumulative hazard scale{p_end}
{phang2}{stata "strcs hormon, df(4) tvc(hormon) dftvc(3)"}{p_end}
{phang2}{stata "predict hr, hrnumerator(hormon 1) ci"}{p_end}
{phang2}{stata "predict survdiff, sdiff1(hormon 1) ci"}{p_end}
{phang2}{stata "predict hazarddiff, hdiff1(hormon 1) ci"}{p_end}


{pstd}Use of at() option{p_end}
{phang2}{stata "strcs hormon x1, df(4) tvc(hormon) dftvc(3)"}{p_end}
{phang2}{stata "predict s60h1, survival at(hormon 1 x1 60) ci"}{p_end}


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
Online:  {manhelp strcs ST}; 
{p_end}

