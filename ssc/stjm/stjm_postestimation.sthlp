{smcl}
{* *! version 2.0.0 ?????2012}{...}
{vieweralsosee "stjm" "help stjm"}{...}
{vieweralsosee "stjmgraph" "help stjmgraph"}{...}
{vieweralsosee "xtmixed" "help xtmixed"}{...}
{vieweralsosee "streg" "help streg"}{...}
{vieweralsosee "stpm2" "help stpm2"}{...}
{vieweralsosee "stmix" "help stmix"}{...}
{title:Title}

{p2colset 5 28 35 2}{...}
{p2col :{hi:stjm postestimation} {hline 2}}Post-estimation tools for stjm{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following standard post-estimation commands are available:

{synoptset 13 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_estat
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{p2col :{helpb stjm postestimation##predict:predict}}predictions, residuals etc{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{phang}Syntax for obtaining best linear unbiased predictions (BLUPs) of random effects, or the BLUPs' standard errors{p_end}

{p 8 16 2}
{cmd:predict} {{it:stub}{bf:*}|{it:newvarlist}} {cmd:,} {{opt ref:fects} | {opt rese:s}}


{phang}Syntax for obtaining other predictions{p_end}

{p 8 16 2}
{cmd:predict} {newvar} {ifin} [{cmd:,} {it:statistic} {it:options}]


{synoptset 31 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Longitudinal}
{synopt :{opt l:ongitudinal}}longitudinal submodel{p_end}
{synopt :{opt r:esiduals}}longitudinal residuals, response minus fitted values{p_end}
{synopt :{opt rsta:ndard}}standardised residuals{p_end}

{syntab:Survival}
{synopt :{opt h:azard}}hazard{p_end}
{synopt :{opt s:urvival}}survival S(t){p_end}
{synopt :{opt cumh:azard}}cumulative hazard{p_end}
{synopt :{opt mart:ingale}}martingale-like residuals{p_end}
{synopt :{opt dev:iance}}deviance residuals{p_end}

{syntab:Random effects}
{synopt :{opt ref:fects}}best linear unbiased predictions (BLUPS) of the random effects{p_end}
{synopt :{opt rese:s}}standard errors of the best linear unbiased predictions (BLUPS) of the random effects{p_end}
{synoptline}

{synoptset 31 tabbed}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt xb}}see description below{p_end}
{synopt :{opt fit:ted}}fitted values, linear predictor of the fixed portion plus contributions based on predicted random effects{p_end}
{synopt :{opt m(#)}}number of draws from the estimated random effects variance-covariance matrix in survival sub-model predictions{p_end}
{synopt :{opt at(varname # [varname # ...])}}predict at values of specified covariates{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{opt time:var(varname)}}time variable used for predictions (defaults: {cmd:_t0} for longitudinal sub-model, {cmd:_t} for survival sub-model){p_end}
{synopt :{opt meast:ime}}evaluate predictions at measurements, {cmd:_t0}{p_end}
{synopt :{opt survt:ime}}evaluate predictions at survival times, {cmd:_t}{p_end}
{synopt :{opt zero:s}}sets all covariates to zero (baseline prediction){p_end}
{synopt :{opt lev:el(#)}}sets confidence level (default 95){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} 
Statistics are available both in and out of sample; type
{cmd:predict} {it:...} {cmd:if e(sample)} {it:...} if wanted only for the
estimation sample.{p_end}
{p 4 6 2} 


{title:Options for predict}

{dlgtab:Longitudinal}

{phang}
{opt longitudinal} predicts the fitted values for the longitudinal submodel. If {cmd:xb} is specified (the default) then 
only contributions from the fixed portion of the model are included. If {cmd: fitted} is specified then estimates of the random effects are also included.

{phang}
{opt residuals} calculates residuals, equal to the longitudinal response minus fitted values. By default, the fitted values take into 
account the random effects.

{phang}
{opt rstandard} calculates standardized residuals, equal to the residuals multiplied by the inverse square root of the estimated 
error covariance matrix.

{dlgtab:Survival}

{phang}
{opt hazard} calculates the predicted hazard.

{phang}
{opt survival} calculates each observation's predicted survival probability.

{phang}
{opt cumhazard} calculates the predicted cumulative hazard. 

{phang}
{opt martingale} calculates martingale-like residuals.

{phang}
{opt deviance} calculates deviance residuals.

{dlgtab:Random effects}

{phang}
{opt reffects} calculates best linear unbiased predictions (BLUPs) of the random effects. You must specify q new variables, where q is the number of random effects 
terms in the model (or level).  However, it is much easier to just specify stub* and let Stata name the variables stub1...stubq for you.

{phang}
{opt reffects} calculates the standard errors of the best linear unbiased predictions (BLUPs) of the random effects. You must specify q new variables, where q is the number of random effects 
terms in the model (or level).  However, it is much easier to just specify stub* and let Stata name the variables stub1...stubq for you.

{dlgtab:Subsidiary}

{phang}
{opt xb} specifies predictions based on the fixed portion of the model when a longitudinal option is chosen. When the prediction option is 
{cmd:hazard}, {cmd:survival} or {cmd:cumhazard}, the predictions are based on the average of the fixed portion plus {cmd:m} draws from the estimated 
random effects variance-covariance matrix.

{phang}
{opt fitted} linear predictor of the fixed portion plus contributions based on predicted random effects.

{phang}
{opt m} specifies the number of draws from the estimated random effects variance-covariance matrix in survival sub-model predictions when {cmd:xb} is chosen.

{phang}
{opt at(varname # [ varname # ...])} requests that the covariates specified by 
the listed {it:varname}(s) be set to the listed {it:#} values. For example,
{cmd:at(x1 1 x3 50)} would evaluate predictions at {cmd:x1} = 1 and
{cmd:x3} = 50. This is a useful way to obtain
out of sample predictions. Note that if {opt at()} is used together
with {opt zeros} all covariates not listed in {opt at()}
are set to zero. If {opt at()} is used without {opt zeros} then
all covariates not listed in {opt at()} are set to their sample
values. See also {opt zeros}.

{phang}
{opt ci} calculate a confidence interval for the requested statistic and
stores the confidence limits in {it:newvar}{cmd:_lci} and
{it:newvar}{cmd:_uci}.

{phang}
{opt timevar(varname)} defines the variable used as time in the predictions.
This is useful for large datasets where for plotting purposes predictions are only needed for 200 observations for example. 
Note that some caution should be taken when using this option as predictions may be 
made at whatever covariate values are in the first 200 rows of data.
This can be avoided by using the {opt at()} option and/or the {opt zeros} option to 
define the covariate patterns for which you require the predictions.

{phang}
{opt meastime} evaluate predictions at measurement times i.e. {cmd:_t0}.

{phang}
{opt survtime} evaluate predictions at survival times i.e. {cmd:_t}.

{phang}
{opt zeros} sets all covariates to zero (baseline prediction). For 
example, {cmd:predict s0, survival zeros} calculates the baseline
survival function. See also {opt at()}.

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}
or as set by {helpb set level}.


{title:Example}

{pstd}Load simulated example dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/s/stjm_example":. use http://fmwww.bc.edu/repec/bocode/s/stjm_example}{p_end}

{pstd}stset the data:{p_end}
{phang}{stata "stset stop, enter(start) f(event=1) id(id)":. stset stop, enter(start) f(event=1) id(id)}{p_end}

{pstd}Joint model with a random intercept in the longitudinal submodel, and association based on the current value. No covariates in either submodel.{p_end}
{phang}{stata "stjm long_response, panel(id) survmodel(weibull) gh(5) ffp(1)":. stjm long_response, panel(id) survmodel(weibull) gh(5) ffp(1)}{p_end}

{pstd}Predict survival.{p_end}
{phang}{stata "predict s1, survival":. predict s1, survival}{p_end}

{pstd}Predict the longitudinal fitted values including fixed effects and contributions from the random effects.{p_end}
{phang}{stata "predict longfitvals, longitudinal fitted":. predict longfitvals, longitudinal fitted}{p_end}
