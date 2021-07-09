{smcl}
{* *! version 2.0.0 ?????2012}{...}
{vieweralsosee "stmixed" "help stmixed"}{...}
{vieweralsosee "merlin postestimation" "help merlin postestimation"}{...}
{vieweralsosee "streg" "help streg"}{...}
{vieweralsosee "stpm2" "help stpm2"}{...}
{title:Title}

{p2colset 5 31 30 2}{...}
{p2col :{cmd:stmixed postestimation} {hline 2}}Post-estimation tools for stmixed{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following standard post-estimation commands are available:

{synoptset 13 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{p2col :{helpb stmixed postestimation##predict:predict}}predictions, residuals etc{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{phang}Syntax for obtaining predictions{p_end}

{p 8 16 2}
{cmd:predict} {newvar} {ifin} [{cmd:,} {it:statistic} {it:options}]


{synoptset 31 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Survival}
{synopt :{opt eta}}linear predictor{p_end}
{synopt :{opt h:azard}}hazard{p_end}
{synopt :{opt s:urvival}}survival S(t){p_end}
{synopt :{opt ch:azard}}cumulative hazard{p_end}
{synopt :{opt cif}}cumulative incidence function{p_end}
{synopt :{opt rmst}}restricted mean survival time (integral of {cmd:survival}){p_end}
{synopt :{opt timelost}}time lost due to event (integral of {cmd:cif}){p_end}
{synoptline}

{synoptset 31 tabbed}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt fixedonly}}specifies predictions based on the fixed portion of the model.{p_end}
{synopt :{opt marginal}}compute prediction marginally with respect to the latent variables{p_end}
{synopt :{opt at(varname # [varname # ...])}}predict at values of specified covariates{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{opt time:var(varname)}}time variable used for predictions (defaults: {cmd:_t0} for longitudinal sub-model, {cmd:_t} for survival sub-model){p_end}
{synopt :{opt lev:el(#)}}sets confidence level (default 95){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} 
Statistics are available both in and out of sample; type
{cmd:predict} {it:...} {cmd:if e(sample)} {it:...} if wanted only for the
estimation sample.{p_end}
{p 4 6 2} 


{title:Options for predict}

{phang}
Note that if a relative survival model has been fitted by use of the {cmd:bhazard()} option then survival refers to 
relative survival and hazard refers to excess hazard.

{dlgtab:Survival}

{phang}
{opt eta} calculates the expected value of the linear predictor

{phang}
{opt hazard} calculates the predicted hazard.

{phang}
{opt survival} calculates each observation's predicted survival probability.

{phang}
{opt chazard} calculates the predicted cumulative hazard. 

{phang}
{opt cif} calculates the predicted cumulative incidence function. 

{phang}
{opt rmst} calculates the restricted mean survival time.

{phang}
{opt timelost} calculates the time lost due to the event occuring, i.e. the integral of the cumulative incidence 
function.

{dlgtab:Subsidiary}

{phang}
{opt fixedonly} specifies predictions based on the fixed portion of the model.

{phang}
{opt marginal} compute prediction marginally with respect to the latent variables

{phang}
{opt at(varname # [ varname # ...])} requests that the covariates specified by 
the listed {it:varname}(s) be set to the listed {it:#} values. For example,
{cmd:at(x1 1 x3 50)} would evaluate predictions at {cmd:x1} = 1 and
{cmd:x3} = 50. This is a useful way to obtain
out of sample predictions. 

{phang}
{opt ci} calculate a confidence interval for the requested statistic and
stores the confidence limits in {it:newvar}{cmd:_lci} and
{it:newvar}{cmd:_uci}.

{phang}
{opt timevar(varname)} defines the variable used as time in the predictions.
This is useful for large datasets where for plotting purposes predictions are only needed for 200 observations for example. 
Note that some caution should be taken when using this option as predictions may be 
made at whatever covariate values are in the first 200 rows of data.
This can be avoided by using the {opt at()} option to 
define the covariate patterns for which you require the predictions.

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}
or as set by {helpb set level}.


{title:Example}

{pstd}This is a simulated example dataset representing a multi-centre trial scenario, with 100 centres and each centre recuiting 60 patients, resulting in 
6000 observations. Two covariates were collected, a binary covariate {bf:x1} (coded 0/1), and a continuous covariate, {bf:x2}, within the range [0,1].{p_end}

{pstd}Load dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stmixed_example1":. use http://fmwww.bc.edu/repec/bocode/s/stmixed_example1}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stime, f(event=1)":. stset stime, f(event=1)}{p_end}

{pstd}We fit a mixed effect survival model, with a random intercept and Weibull distribution, adjusting for fixed effects of {bf:x1} and {bf:x2}.{p_end}
{phang}{stata "stmixed x1 x2 || centre: , dist(weibull)":. stmixed x1 x2 || centre: , dist(weibull)}{p_end}

{pstd}Predict survival based on the fixed effects only.{p_end}
{phang}{stata "predict s1, survival":. predict s1, survival}{p_end}
