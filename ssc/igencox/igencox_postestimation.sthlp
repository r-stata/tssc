{smcl}
{* *! version 1.0.0  12dec2011}{...}
{cmd:help igencox postestimation}{right:also see:  {helpb igencox:igencox}}
{hline}

{title:Title}

{p2colset 5 31 33 2}{...}
{p2col :{cmd:igencox postestimation} {hline 2}}Postestimation tools for igencox{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
The following postestimation commands are available after {cmd:igencox}:

{synoptset 19 notes}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
INCLUDE help post_estat
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{p2col :{helpb igencox postestimation##predict:predict}}predicted values{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker syntax_predict}{...}
{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:options}]


{synoptset 31 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Main}
{synopt :{opt xb}}linear prediction xb; the default{p_end}
{synopt :{opt stdp}}standard error of the linear prediction; SE(xb){p_end}
{synopt :{opt bases:urv}}baseline survivor function{p_end}
{synopt :{opt surv:ival}}covariate-adjusted survivor function{p_end}
{synopt :{opt basec:hazard}}baseline cumulative hazard function{p_end}
{synopt :{opt cumh:az}}covariate-adjusted cumulative hazard function{p_end}
{p2coldent :* {cmd:at(}{varname}{cmd:=}{it:#} [{varname}{cmd:=}{it:# ...}]{cmd:)}}set value of the specified covariates{p_end}
{p2coldent :+ {cmd:se(}{it:{help newvar:newvarname}}{cmd:)}}save standard error in {it:newvarname}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt at()} is allowed only with {opt survival} or {opt cumhaz}.{p_end}
{p 4 6 2}+ {opt se()} is allowed only with {opt basesurv} or {opt survival}.{p_end}


{marker options_predict}{...}
{title:Options for predict}

{dlgtab:Main}

{phang}
{opt xb}, the default, calculates the linear prediction from the fitted model.
That is, you fit the model by estimating a set of parameters b0, b1, b2, ..., bk,
and the linear prediction is xb.

{pmore}
The x used in the calculation is obtained from the data
currently in memory and need not correspond to the data on the independent
variables used in estimating b.

{phang}
{opt stdp} calculates the standard error of the prediction, that is,
the standard error of xb.

{phang}
{opt basesurv} calculates the baseline survivor function.  
It requires that the {cmd:baseq()} option is specified with {cmd:igencox}.

{phang}
{opt survival} calculates the covariate-adjusted survivor function.  If
{cmd:at()} is not specified, the survivor function is evaluated at the mean
values of the covariates.
{cmd:survival} requires that the {cmd:baseq()} option is specified with {cmd:igencox}.

{phang}
{opt basechazard} calculates the cumulative baseline hazard.
It requires that the {cmd:baseq()} option is specified with {cmd:igencox}.

{phang}
{opt cumhaz} calculates the covariate-adjusted cumulative hazard.  If
{cmd:at()} is not specified, the cumulative hazard is evaluated at the mean
values of the covariates.  {cmd:cumhaz} requires that the {cmd:baseq()} option
is specified with {cmd:igencox}.

{phang}
{cmd:at(}{varname}{cmd:=}{it:# ...}{cmd:)} requests that the
covariates specified by {it:varname} be set to {it:#} when computing
covariate-adjusted survivor or cumulative hazard functions.  By default,
{cmd:predict} evaluates the function by setting each covariate to its mean
value.  This option causes the function to be evaluated at the value of the
covariates listed in {opt at()} and at the mean of all unlisted covariates.
The {cmd:at()} option requires {cmd:survival} or {cmd:cumhaz}.

{phang}
{cmd:se(}{it:{help newvar:newvarname}}{cmd:)} requests that the standard error
of the survivor function be saved in {it:newvarname}.  It requires that
{cmd:baseq()} and {cmd:savesigma()} are specified with {cmd:igencox}.
The {cmd:se()} option requires {cmd:basesurv} or {cmd:survival}.


{marker examples}{...}
{title:Examples}

{title:Compute baseline survivor function}

{pstd}Setup{p_end}
{phang2}{cmd:. use va, clear}{p_end}

{pstd}Fit Cox proportional hazards model and save jump sizes{p_end}
{phang2}{cmd:. igencox status type1 type2 type3, baseq(q)}{p_end}

{pstd}Obtain predicted values of the  baseline survivor function{p_end}
{phang2}{cmd:. predict s, basesurv}{p_end}


{marker survivor}
{title:Compute covariate-adjusted survivor function and its standard error}

{pstd}Setup{p_end}
{phang2}{cmd:. use va, clear}{p_end}
{phang2}{cmd:. igencox status type1 type2 type3, baseq(bq) savesigma(tmp, replace)}{p_end}

{pstd}Predict survivor function and its standard errors at specified values of the covariates{p_end}
{phang2}{cmd:. predict surv, survival se(sesurv) at(status=.4 type1=0 type2=0 type3=0)}{p_end}

{pstd}Calculate the 95% pointwise confidence intervals of the survivor function{p_end}
{phang2}{cmd:. gen tmp = 1.96*sesurv / (surv*log(surv))}{p_end}
{phang2}{cmd:. gen lb = surv^exp(-tmp)}{p_end}
{phang2}{cmd:. gen ub = surv^exp(tmp)}{p_end}

{pstd}Plot the results{p_end}
{phang2}{cmd:. gsort _t surv}{p_end}
{phang2}{cmd:. twoway line surv lb ub _t, connect(J J J)}{p_end}
