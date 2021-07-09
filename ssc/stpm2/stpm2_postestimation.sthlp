{smcl}
{* *! version 1.7.1 16JuN2018}{...}
{cmd:help stpm2 postestimation} 
{right:also see:  {help stpm2}}
{hline}

{title:Title}

{p2colset 5 34 36 2}{...}
{p2col :{hi:[ST] stpm2 postestimation} {hline 2}}Post-estimation tools for stpm2{p_end}
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
{p2col :{helpb stpm2 postestimation##predict:predict}}predictions, residuals etc{p_end}
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
{synopt :{opt abc}}area between log hazard ratio curves{p_end}
{synopt :{opt at(vn # [vn # ...])}}predict at values of specified covariates{p_end}
{synopt :{opt cen:tile(#)}}#th centile of survival distribution{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{opt cumh:azard}}cumulative hazard{p_end}
{synopt :{opt cumo:dds}}cumulative odds{p_end}
{synopt :{opt cure}}cure proportion{p_end}
{synopt :{opt dens:ity}}density function{p_end}
{synopt :{opt fail:ure}}failure function{p_end}
{synopt :{opt h:azard}}hazard function{p_end}
{synopt :{opt hrn:umerator(vn # [vn # ...])}}numerator for (time-dependent) hazard ratio{p_end}
{synopt :{opt hrd:enominator(vn # [vn # ...])}}denominator for (time-dependent) hazard ratio{p_end}
{synopt :{opt hdiff1(vn # [vn # ...])}}1st hazard function for difference in hazard functions{p_end}
{synopt :{opt hdiff2(vn # [vn # ...])}}2nd hazard function for difference in hazard functions{p_end}
{synopt :{opt lif:elost}}calculate the loss in expectation of life after fitting a relative survival model{p_end}
{synopt :{opt mart:ingale}}martingale residuals{p_end}
{synopt :{opt means:urv}}population averaged survival function{p_end}
{synopt :{opt meansurvwt(varname)}}apply weights when obtaining population averaged survival function{p_end}
{synopt :{opt nor:mal}}standard normal deviate of survival function{p_end}
{synopt :{opt per(#)}}express hazard rates (and differences) per # person years{p_end}
{synopt :{opt rm:st}}restricted mean survival time{p_end}
{synopt :{opt rsd:st}}standard deviation of restricted survival time{p_end}
{synopt :{opt sdiff1(vn # [vn # ...])}}1st survival curve for difference in survival functions{p_end}
{synopt :{opt sdiff2(vn # [vn # ...])}}2nd survival curve for difference in survival functions{p_end}
{synopt :{opt stdp}}standard error of predicted function{p_end}
{synopt :{opt s:urvival}}survival function{p_end}
{synopt :{opt time:var(vn)}}time variable used for predictions (default {cmd:_t}){p_end}
{synopt :{opt tma:x(#)}}upper bound of time for {opt rmst} and {opt abc} options{p_end}
{synopt :{opt tmi:n(#)}}lower bound of time for {opt rmst} and {opt abc} options{p_end}
{synopt :{opt tvc(vn)}}time-varying coefficient for {it: varname}{p_end}
{synopt :{opt unc:ured}}obtain survival and hazard functions for the 'uncured'{p_end}
{synopt :{opt xb}}the linear predictor{p_end}
{synopt :{opt xbnob:aseline}}predicts the linear predictor, excluding the spline function{p_end}
{synopt :{opt zero:s}}sets all covariates to zero (baseline prediction){p_end}

{syntab:Subsidiary}
{synopt :{opt centol(#)}}tolerance level when estimating centile{p_end}
{synopt :{opt dev:iance}}deviance residuals{p_end}
{synopt :{opt dxb}}derivative of linear predictor{p_end}
{synopt :{opt lev:el(#)}}sets confidence level (default 95){p_end}
{synopt :{opt startunc(#)}}sets starting value for Newton-Raphson algorithm for estimating a centile 
of the survival distribution of 'uncured'{p_end}
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
{opt abc} evaluates the area between a constant log hazard ratio and a
time-dependent log hazard ratio curve. It integrates the difference between
a log HR curve and a constant log HR over the time range between {opt tmin()}
and {opt tmax()}. The constant HR is supplied by the {opt hr0()} option.
The time-dependent log HR curve is determined according to {opt hrnumerator()},
which must therefore be specified. You may also specify
{opt hrdenominator()}. The {opt n()}, {opt at()} and {opt zeros} options
are valid with {opt abc}.

{phang}
{opt at(varname # [ varname # ...])} requests that the covariates specified by 
the listed {it:varname}(s) be set to the listed {it:#} values. For example,
{cmd:at(x1 1 x3 50)} would evaluate predictions at {cmd:x1} = 1 and
{cmd:x3} = This is a useful way to obtain
out of sample predictions. Note that if {opt at()} is used together
with {opt zeros} all covariates not listed in {opt at()}
are set to zero. If {opt at()} is used without {opt zeros} then
all covariates not listed in {opt at()} are set to their sample
values. See also {opt zeros}. Sometime is is useful to specificy certain covariates to take values of a variable
rather than a scalar. This can be done using {opt at(varname = varname)}. 

{phang}
{opt centile(#)} gives the {it:#}th centile of the survival time distribution,
calculated using a Newton-Raphson algorithm.

{phang}
{opt ci} calculate a confidence interval for the requested statistic and
stores the confidence limits in {it:newvar}{cmd:_lci} and
{it:newvar}{cmd:_uci}.

{phang}
{opt cumhazard} predicts the cumulative hazard function.

{phang}
{opt cumodds} predicts the cumulative odds of failure function.

{phang}
{opt cure} predicts the cure proportion after fitting a cure model.

{phang}
{opt density} predicts the density function.

{phang}
{opt failure} predicts the failure function, i.e. F(t) = 1 - S(t).

{phang}
{opt hazard} predicts the hazard function.

{phang}
{opt hdiff1(varname # ...)}, {opt hdiff2(varname # ...)} predict
the difference in hazard functions with the first hazard function defined
by the covariate values listed for {opt hdiff1()} and the second by
those listed for {opt hdiff2()}. By default, covariates not specified
using either option are set to zero. Note that setting the remaining values
of the covariates to zero may not always be sensible. If {it:#} is set to
missing ({cmd:.}) then {it:varname} takes its observed values in the dataset.

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
and {cmd:age} =30.

{phang}
{opt hrdenominator(varname # ...)} specifies the denominator of the hazard
ratio. By default all covariates other than {it:varname} and any other
variables mentioned are set to zero. See cautionary note in {opt hrnumerator}.
If {it:#} is set to missing ({cmd:.}) then {it:varname} takes its observed values
in the dataset.

{phang}
{opt hrnumerator(varname # ...)} predicts the (time-dependent) hazard ratio
with the numerator of the hazard ratio. By default all covariates other than
{it:varname} and any other variables mentioned are set to zero. Note that
setting the remaining values of the covariates to zero may not always be
sensible, particularly with models other than on the cumulative hazard scale,
or when more than one variable has a time-dependet effect. If {it:#} is set
to missing ({cmd:.}) then {it:varname} takes its observed values in the dataset.

{phang}
{opt lifelost} calculates the loss in expectation of life after fitting a relative 
model. This the difference between the expected remaining lifetime in a disease free 
population and the expected remaing lifetime in the diseased population. See Anderson {it et al.} 
for details of the approach. There are a number of further options that can be used with 
the {opt lifelost} option, which are described below,

{phang2}
{opt using(filename)} specifies the population mortality file to be used for expected survival probabilities.

{phang2}
{opt mergeby(varlist)} specifies the variables by which the file of general population survival probabilities
is sorted.

{phang2}
{opt diagage(varname)} specifies the variable containing age at diagnosis. Default is diagage.

{phang2}
{opt diagyear(varname)} specifies the variable containing calendar year of diagnosis. Default is diagyear.

{phang2}
{opt maxage(#)} specifies the maximum age for which general population survival probabilities are
provided in the using file. Probabilities for individuals older than this value are
assumed to be the same as for the maximum age. Default is 99.

{phang2}
{opt attage(varname)} specifies the variable containing attained age in the popmort file. This variable
cannot exist in the patient data file. Default is _age.

{phang2}
{opt attyear(varname)} specifies the variable containing attained calendar year in the popmort file. This
variable cannot exist in the patient data file. Default is _year.

{phang2}
{opt survprob(varname)} specifies the variable containing survival probabilities in the popmort file. This
variable cannot exist in the patient data file. Default is prob.

{phang2}
{opt by(varname)} specifies stratification variables. Survival probabilities are averaged for each
combination of these variables and assumed the same within each combination. Can only be used together with the grpd option.

{phang2}
{opt maxyear(#)} specifies the maximum age for which general population survival probabilities are
provided in the population mortality file. Probabilities for years beyond this value are assumed to be
the same as for the maximum year. Default is 2050.

{phang2}
{opt nodes(#)} specifies the number of nodes to be used for the numerical integration. Default is 50.

{phang2}
{opt tinf(#)} specifies the end year used for the numerical integration. Both observed and expected
survival is assumed to be 0 after this point. Default is 50. This needs to be larger if extrapolating 
for very young patients.

{phang2}
{opt tcond(#)} specifies the starting follow-up year used for the numerical integration. This is used to retrieve
conditional estimates. Default is 0.

{phang2}
{opt grpd} specifies that average survival probabilities should be used, as opposed to individual
probabilities. If this is used together with the by option, the average is calculated
within each combination of the specified by variables.

{phang2}
{opt stub(stubname)} stubname for estimated life expectency in absence and presence of cancer.

{phang}
{opt martingale} calculates martingale like residuals.

{phang}
{opt meansurv} calculate the population average survival curve. Note this
differs from the predicted survival curve at the mean of all the covariates
in the model. A predicted survival curve is obtained for each subject and all
the survival curves are averaged. The process can be computationally intensive.
It is recommended that the {opt timevar()} option is used to reduce the number
of survival times at which ths survival curves are averaged. Combining this
option with the {cmd:at()} option enables adjusted survival curves to be
estimated.

{phang}
{opt meansurvwt} applies weights in the calculation of population average survival
curves. This option is useful when obtaining externally standardized survival curves.

{phang}
{opt n(#)} [{opt rmst} only] defines the number of evaluation points
for integrating the estimated survival function(s) with respect to time.
The larger {it:#} is, the more accurate is the estimated restricted mean
survival time, but the longer the calculation takes. There is no gain
by setting {it:#} above 5000. Default {it:#} is 1001.

{phang}
{opt normal} predicts the standard normal deviate of the survival function.

{phang}
{opt per(#)} express hazard rates and difference in hazard rates per # person years.

{phang}
{opt rmst} evaluates the mean or restricted mean survival time. This is
done by integrating the predicted survival curve from 0 to {opt tmax(#)};
see also the {opt n()} and {opt tmax()} options. Note that the {opt at()},
{opt zeros} and {opt meansurv} options are valid with {opt rmst}. The
effect of {opt meansurv} is to produce RMST estimates based on population
averaged or 'covariate-adjusted' survival curves; see {opt meansurv}
and {opt tmax()} for further information.


{phang}
{opt rsdst} evaluates the standard deviation of the (restricted) survival
time. For a single sample the SE of the restricted mean survival time
may be estimated by dividing the SD by the square root of the number
of observations. See also the {opt rmst}, {opt n()} and {opt tmax()} options.
Note that the {opt at()} and {opt zeros} options are valid with {opt rsdst}.

{phang}
{opt sdiff1(varname # ...)}, {opt sdiff2(varname # ...)} predict
the difference in survival curves with the first survival curve defined
by the covariate values listed for {opt sdiff1()} and the second by
those listed for {opt sdiff2()}. By default, covariates not specified
using either option are set to zero. Note that setting the remaining values
of the covariates to zero may not always be sensible. If {it:#} is set to
missing ({cmd:.}) then {it:varname} takes its observed values in the dataset.

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
and {cmd:age} =30.

{phang}
{opt stdp} calculates standard error of prediction and stores it in
{newvar}{cmd:_se}. Only available for the {opt xb}, {opt dxb},
{opt xbnobaseline} and {opt rmst} options.

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
{opt tmax(#)} [{opt rmst} and {opt abc} only] defines the upper limit of time
over which the integration of the estimated survival function is to be
conducted. Default {it:#} is 0, meaning an upper limit as close to
t = infinity as is reasonable (in fact, using the estimated 99.999999th
centile of the survival distribution).

{pmore}
When {opt meansurv} is specified with {opt rmst}, the extended syntax
{opt tmax(tlist)} is supported, where {it:tlist} is a {help numlist} of
times (t*). The RMST estimates are stored in {it:newvar} in the same order as
presented in {it:tlist}. The extension is feasible because {opt rmst meansurv}
produces only one RMST value for a given time (t

{phang}
{opt tmin(#)} [{opt rmst} and {opt abc} only] defines the lower bound of time
over which the integration of the estimated survival function is to be
conducted. Default {it:#} is -1, taken as 0 and meaning a lower bound of 0.

{phang}
{opt tvc(varname)} stands for "time-varying coefficient" and computes the estimated coefficient 
for {it: varname}, a covariate in stpm2's varlist. If {it: varname} is "time-fixed", 
then {it: newvarname} will be a constant. If {it: varname} is included in the {opt tvc()} option,
then {it: newvarname} will depend on {cmd: _t} and may be interpreted as the time-varying effect
of {it: varname} on the chosen scale of the model (proportional hazards, proportional odds
or probit).  For example, in a hazards-scale model ({cmd: scale(hazard)}), {it: newvarname}
multiplied by {it: varname} will be an estimate of the time-varying log cumulative hazard 
ratio for {it: varname} (compared with {it: varname} = 0) at every observed value of {it: varname}. 
{it: newvarname} alone will give the log cumulative hazard ratio for a one-unit change 
in {it: varname}. Note that the time-varying log cumulative hazard ratio for {it: varname}
will NOT be identical to the time- varying log hazard ratio for {it: varname}.


{phang}
{opt uncured} can be used after fitting a cure model. It can be used with the
{cmd:survival}, {cmd:hazard} or {opt centile()} options to base predictions 
for the 'uncured' group.

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
{opt centol(#)} defines the  tolerance when searching for predicted
suvival time at a given centile of the survival distribution. Default
{it:#} is 0.0001.

{phang}
{opt deviance} calculates deviance residuals.

{phang}
{opt dxb} calculates the derivative of the linear predictor.

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}
or as set by (help set level}.

{phang}
{opt startunc(#)} sets starting value for Newton-Raphson algorithm for estimating a 
centile of the survival time distribution of 'uncured'; default 12.5th centile of 
the observed follow-up times.

 
{title:Examples}

{pstd}Setup{p_end}
{phang2}{stata "webuse brcancer"}{p_end}
{phang2}{stata "stset rectime, failure(censrec = 1)"}{p_end}

{pstd}Proportional hazards model{p_end}
{phang2}{stata "stpm2 hormon, scale(hazard) df(4) eform"}{p_end}
{phang2}{stata "predict h, hazard ci"}{p_end}
{phang2}{stata "predict s, survival ci"}{p_end}

{pstd}Time-dependent effects on cumulative hazard scale{p_end}
{phang2}{stata "stpm2 hormon, scale(hazard) df(4) tvc(hormon) dftvc(3)"}{p_end}
{phang2}{stata "predict hr, hrnumerator(hormon 1) ci"}{p_end}
{phang2}{stata "predict survdiff, sdiff1(hormon 1) ci"}{p_end}
{phang2}{stata "predict hazarddiff, hdiff1(hormon 1) ci"}{p_end}


{pstd}Use of at() option{p_end}
{phang2}{stata "stpm2 hormon x1, scale(hazard) df(4) tvc(hormon) dftvc(3)"}{p_end}
{phang2}{stata "predict s60h1, survival at(hormon 1 x1 60) ci"}{p_end}


{title:References}

{phang}
T. M-L. Andersson, P.W. Dickman, S. Eloranta, M. Lambe, P.C. Lambert. Estimating 
the loss in expectation of life due to cancer using flexible parametric survival 
models. Statistics in Medicine 2013;32:5286-5300

{phang}
P. C. Lambert and P. Royston. Further development of flexible parametric
models for survival analysis. Stata Journal 2009;9:265-290

{phang}
C. P. Nelson, P. C. Lambert, I. B. Squire and D. R. Jones. 
Flexible parametric models for relative survival, with application
in coronary heart disease. Statistics in Medicine 2007;26:548-5498

{phang}
P. Royston and M. K. B. Parmar. Flexible proportional-hazards and
proportional-odds models for censored survival data, with application
to prognostic modelling and estimation of treatment effects.
Statistics in Medicine 2002;21:2175-2197.

{phang}
P. Royston and M. K. B. Parmar. The use of restricted mean survival time
to estimate the treatment effect in randomized clinical trials when the
proportional hazards assumption is in doubt.
Statistics in Medicine 2011;30:2409-2421.

{phang}
P. Royston, P.C. Lambert. Flexible parametric survival analysis in Stata: 
Beyond the Cox model StataPress, 2011

{title:Also see}

{psee}
Online:  {manhelp stpm2 ST}; 
{p_end}

