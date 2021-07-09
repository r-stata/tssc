{smcl}
{* *! Version 1.0.0 09 August 2017}{...}

{title:Title}

{p2colset 5 35 37 2}{...}
{p2col :{helpb nehurdle postestimation} {hline 4}}Postestimation tools 
for nehurdle{p_end}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
The following postestimation commands are available after {cmd:nehurdle}:

{synoptset 17 notes}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt:{helpb contrast}}contrasts and ANOVA-style joint tests of estimates{p_end}
{synopt:{helpb estat ic}}Akaike's and Schwarz's Bayesian information criteria
	(AIC and BIC){p_end}
{synopt:{helpb estat summarize}}summary statistics for the estimation sample{p_end}
{synopt:{helpb estat vce}}variance-covariance matrix of the estimators (VCE){p_end}
{synopt:{help svy estat: {bf:estat} (svy)}}postestimation statistics for survey
	data{p_end}
{synopt:{helpb estimates}}cataloging estimation results{p_end}
{synopt:{helpb lincom}}point estimates, standard errors, testing, and inference
	for linear combinations of coefficients{p_end}
{p2coldent:(1) {helpb lrtest}}likelihood-ratio test{p_end}
{synopt:{helpb margins}}marginal means, predictive margins, marginal effects,
	and average marginal effects{p_end}
{synopt:{helpb marginsplot}}graph the results from margins (profile plots,
	interaction plots, etc.){p_end}
{p2coldent:(1) {helpb nehtests}}Wald tests of joint significance of all the estimated
	equations, and the overall joint significance test{p_end}
{synopt:{helpb nlcom}}point estimates, standard errors, testing, and inference
	for nonlinear combinations of coefficients{p_end}
{synopt:{helpb nehurdle postestimation##predict:predict}}predictions,
	residuals, influence statistics, and other diagnostic measures{p_end}
{synopt:{helpb predictnl}}point estimates, standard errors, testing, and
	inference for generalized predictions{p_end}
{synopt:{helpb pwcompare}}pairwise comparisons of estimates{p_end}
{synopt:{helpb suest}}seemingly unrelated estimation{p_end}
{synopt:{helpb test}}Wald tests of simple and composite linear hypotheses{p_end}
{synopt:{helpb testnl}}Wald tests of nonlinear hypotheses{p_end}
{synoptline}
{p2colreset}{...}
{phang}
(1) {cmd:lrtest} and {cmd:nehtests} are not appropriate with {cmd:svy} estimation results.
{p_end}


{marker predict}{...}
{title:Syntax for predict}

{phang}
General syntax
{p_end}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:statistic}]
{p_end}

{phang}
Syntax for scores
{p_end}

{p 8 16 2}
{cmd:predict} {dtype} {c -(}{it:stub*}{c |}{it:{help newvar:newvarlist}}{c )-}
{ifin}
{cmd:,} {opt sc:ores}
{p_end}

{synoptset 21 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :All estimators}
{synopt :{opt yc:en}}{it:E}(y), prediction of the censored mean; the default{p_end}
{synopt :{opt yt:run}}{it:E}(y {c |} y > 0), prediction of the truncated mean{p_end}
{synopt :{opt ps:el}}Pr(y > 0), prediction of probability of being observed{p_end}
{synopt :{opt xbv:al}}linear prediction for value equation{p_end}
{synopt :{opt xbsig}}linear prediction for natural logarithm of the standard deviation
	of the value equation{p_end}
{synopt :{opt sig:ma}}prediction for standard deviation of the value equation{p_end}
{synopt :{opt resc:en}}residuals of prediction of the censored mean{p_end}
{synopt :{opt rest:run}}residuals of prediction of the truncated mean{p_end}
{synopt :{opt resv:al}}residuals of linear prediction for value equation{p_end}
{synopt :{opt ress:el}}residuals of prediction of probability of being observed{p_end}

{syntab :Truncated Hurdle and Type II Tobit}
{synopt :{opt xbs:el}}linear prediction for selection equation{p_end}
{synopt :{opt xbsels:ig}}linear prediction for natural logarithm of the standard
	deviation of selection equation{p_end}
{synopt :{opt selsig:ma}}prediction of the standard deviation of selection
	equation{p_end}

{syntab :Type II Tobit}
{synopt :{opt lam:bda}}prediction of coefficient on inverse mills ratio
	(covariance of the errors across equations){p_end}
{synoptline}

{marker options_predict}{...}
{title:Options for predict}

{dlgtab:All estimators}

{phang}
{opt ycen}, the default, calculates the prediction of the censored mean. When
using this option with {cmd: margins dydx(*)} after an Exponential Tobit estimation
you will need to add the {opt force} option to avoid an error from Stata.
{p_end}

{phang}
{opt ytrun} calculates the prediction of the truncated mean, i.e. prediction of y
	given that y is positive (and observed). When using this option with
	{cmd: margins dydx(*)} after an Exponential Tobit estimation you will need to
	add the {opt force} option to avoid an error from Stata.
{p_end}

{phang}
{opt psel} calculates the probability that y is positive (and observed).
{p_end}

{phang}
{opt xbval} calculates the linear prediction for the value equation. You can also
think about this as the linear prediction of the uncensored (latent) variable (mean),
y*. Notice that if you specified the value equation to be exponential, with the
{opt exponential} option, the prediction will be of the latent natural logarithm of y.
{p_end}

{phang}
{opt xbsig} calculates the linear prediction for natural logarithm of the
	standard deviation of the value equation. For homoskedastic value equations,
	this will be equal to the coefficient on /lnsigma. However, if you have
	modeled heteroskedasticity in the value equation the prediction will vary
	across observations.
{p_end}

{phang}
{opt sigma} calculates the prediction for standard deviation of the value
	equation. It is simply the exponential of the prediction you would get with
	{opt xbsig}.
{p_end}

{phang}
{opt rescen} calculates the residuals against the censored mean. That is y -
	{it:E}(y), where {it:E}(y) is the censored mean you get with the
	{opt ycen} option.
{p_end}

{phang}
{opt restrun} calculates the residuals against the truncated mean. That is y - 
	{it:E}(y {c |} y > 0), where {it:E}(y {c |} y > 0) is the truncated mean you
	get with the {opt ytrun} option.
{p_end}

{phang}
{opt resval} calculates the residuals against the linear prediction for value
	equation that you would get with {opt xbval}. Notice that if you have
	specified the value equation to be exponential these residuals would be
	limited to those observations with a positive value of y, since ln(y) is
	indeterminate for those observations where y = 0.
{p_end}

{phang}
{opt ressel} residuals of the prediction of probability of being observed. This
this is calculated as the difference between the dummy variable that identifies
whether y > 0, and the predicted Pr(y > 0) that you get with {opt psel}.
{p_end}

{dlgtab:Truncated Hurdle and Type II Tobit}

{phang}
{opt xbsel} calculates the linear prediction for selection equation.
{p_end}

{phang}
{opt xbselsig} calculates the linear prediction of the natural logarithm of the
	standard deviation of selection equation. This option is only available if
	you have modeled heteroskedasticity in the selection equation, for otherwise
	the prediction would be 0 since the Probit estimator normalizes the standard
	deviation to 1.
{p_end}

{phang}
{opt selsigma} calculates the prediction of the standard deviation of the selection
	equation. Like with {opt xbselsig} this is only available if you have modeled
	heteroskedasticity in the selection equation, and for the same reasons. This
	is calculated by taking the exponential of the prediction with the {opt xbselsig}
	option.
{p_end}

{dlgtab:Type II Tobit}

{phang}
{opt lambda} calculates the prediction of what some people call the coefficient
	on inverse mills ratio. It is a prediction of the covariance of the errors
	of both equations (selection and value). It is calculated by multiplying the
	prediction of the standard deviation of the selection equation times the
	prediction of the standard deviation of the value equation times the estimate
	of the correlation of the errors of both equations.
{p_end}

{marker examples}{...}
{title:Examples}

{pstd}Data Setup{p_end}
{phang2}. {stata "webuse womenwk, clear"}{p_end}
{phang2}. {stata "replace wage = 0 if missing(wage)"}{p_end}
{phang2}. {stata "global xvars i.married children educ age"}{p_end}

{pstd}Homoskedastic Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, tobit nolog"}{p_end}
{phang2}. {stata "margins, dydx(*)"} // AMEs on censored mean{p_end}
{phang2}. {stata "margins, dydx(*) predict(ytrun)"} // AMEs on truncated mean{p_end}

{pstd}Heteroskedastic Exponential Truncated Hurdle{p_end}
{phang2}. {stata "nehurdle wage $xvars, expon het($xvars) nolog"}{p_end}
{phang2}. {stata "margins, dydx(*)"} // AMEs on censored mean{p_end}
{phang2}. {stata "margins, dydx(*) predict(sigma)"} // AMEs on the standard deviation of value equation{p_end}
{phang2}. {stata "predict rsel, rescen"} // Residuals against the censored prediction.{p_end}

{pstd}Heteroskedastic Exponential Type II Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, heckman expon het($xvars) nolog"}{p_end}
{phang2}. {stata "margins, dydx(*)"} // AMEs on censored mean{p_end}
{phang2}. {stata "margins, predict(lambda)"} // Estimate of the coefficient on inverse-mills ratio{p_end}

