{smcl}
{* *! version 0.6.0 04jan2013}{...}
{hline}
{cmd:help stgenreg postestimation} {right:also see:  {helpb stgenreg}}
{hline}

{title:Title}

{p2colset 5 32 36 2}{...}
{p2col :{cmd:stgenreg postestimation} {hline 2}}Postestimation tools for stgenreg{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following standard postestimation commands are also available:

{synoptset 16 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_estat
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{p2col :{helpb sthaz postestimation##predict:predict}}predictions{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {newvar} {ifin} [{cmd:,} {it:statistic}]


{synoptset 25 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Main}
{synopt :{opt h:azard}}hazard function{p_end}
{synopt :{opt s:urvival}}survival function{p_end}
{synopt :{opt cumh:azard}}cumulative hazard function{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{opt stdp}}standard error of predicted function{p_end}
{synopt :{opt time:var(varname)}}time variable used for predictions (default _t){p_end}
{synopt :{opt at(vn # [vn # ...])}}predict at values of specified covariates{p_end}
{synopt :{opt zero:s}}sets all covariates to zero (baseline prediction){p_end}
{synopt :{opt mata}}the user-defined [log] hazard function contains a Mata only function, see details{p_end}
               
{syntab:Subsidiary}
{synopt :{opt l:evel}}sets confidence level (default 95){p_end}
{synoptline}
{p2colreset}{...}


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt hazard} calculates the predicted hazard.

{phang}
{opt survival} calculates the predicted survivor function

{phang}
{opt cumhazard} calculates the predicted cumulative hazard.

{phang}
{opt ci} calculate a confidence interval for the requested statistic and
stores the confidence limits in {it:newvar}{cmd:_lci} and
{it:newvar}{cmd:_uci}.

{phang}
{opt stdp} calculates standard error of prediction and stores it in
{newvar}{cmd:_se}. 

{phang}
{opt timevar(varname)} defines the variable used as time in the predictions.
Default {it:varname} is {cmd:_t}. This is useful for large datasets where 
for plotting purposes predictions are only needed for 200 observations for example. 
Note that some caution should be taken when using this option as predictions may be 
made at whatever covariate values are in the first 200 rows of data.
This can be avoided by using the {opt at()} option and/or the {opt zeros} option to 
define the covariate patterns for which you require the predictions.

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
{opt zeros} sets all covariates to zero (baseline prediction). For 
example, {cmd:predict s0, survival zeros} calculates the baseline
survival function. See also {opt at()}.

{phang}
{opt mata} uses Mata to calculate the prediction, required when a Mata only function is included in the 
user-defined [log] hazard function used to fit the model. {cmd:ci} is not available when {cmd:mata} is used.


{dlgtab:Subsidiary}

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}
or as set by {help set level}.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{stata "webuse brcancer"}{p_end}
{phang2}{stata "stset rectime, failure(censrec = 1) scale(365.25)"}{p_end}

{pstd}Weibull proportional hazards model{p_end}
{phang2}{stata "stgenreg, loghazard([ln_lambda] :+ [ln_gamma] :+ (exp([ln_gamma]):-1):*log(#t)) ln_lambda(hormon)"}{p_end}
{phang2}{stata "predict h1, hazard ci"}{p_end}
{phang2}{stata "predict s1, survival ci"}{p_end}

{pstd}Restricted cubic spline model on the log hazard scale{p_end}
{phang2}{stata "stgenreg, loghazard([xb]) xb(hormon | #rcs(df(3)))"}{p_end}
{phang2}{stata "predict h2, hazard ci"}{p_end}
{phang2}{stata "predict s2, survival ci"}{p_end}
