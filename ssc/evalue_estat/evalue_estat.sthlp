{smcl}
{* *! version 1.0.0 24Sept2019}{...}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col:{hi:evalue_estat} {hline 2}} Postestimation tool for conducting sensitivity analyses of unmeasured confounding in observational studies  {p_end}
{p2colreset}{...}


{title:Syntax}

{pstd}
E-value for testing against a null effect (equaling a rate ratio of 1.0):

{p 8 14 2}
{cmd:evalue_estat}
{it: coef_name}


{pstd}
E-value for testing against a different value:

{p 8 14 2}
{cmd:evalue_estat}
{it: coef_name}
{cmd:==}
{it:#}


{pstd}
{it: coef_name} identifies a coefficient in the preceding estimation model. {it: coef_name} is typically a variable name with or without a level indicator (see {helpb fvvarlist}). The easiest
way to identify the {it: coef_name} assigned by the estimation model is to specify the {cmd: coeflegend} option; see {helpb estimation options}.  

{pstd}
For continuous outcomes estimated with {helpb regress}, {helpb tobit}, {helpb truncreg} or { helpb hetregress}, 
{it: coef_name} must be a binary variable, as {cmd: evalue_estat} computes the standardized mean difference between 2 levels of a variable.



{title:Description}

{pstd}
{opt evalue_estat} is a postestimation command that performs sensitivity analyses for unmeasured confounding in observational studies using the methodology 
proposed by VanderWeele and Ding (2017). {opt evalue_estat} reports E-values, defined as the minimum strength of association on the risk ratio scale that an 
unmeasured confounder would need to have with both the treatment and the outcome to fully explain away a specific treatment-outcome association, conditional 
on the measured covariates. 

{pstd}
{opt evalue_estat} computes E-values for point estimates and confidence limits for several common outcome types, including risk and rate ratios, 
odds ratios with common or rare outcomes, hazard ratios with common or rare outcomes, and standardized mean differences in outcomes. Estimation models currently supported by 
{opt evalue_estat} are {helpb logistic}, {helpb logit}, {helpb cloglog}, {helpb scobit}, {helpb clogit}, {helpb stcox}, {helpb streg}, {helpb poisson}, {helpb cpoisson}, {helpb tpoisson}, {helpb nbreg}, {helpb zip}, {helpb zinb}, 
{helpb regress}, {helpb tobit}, {helpb truncreg}, {helpb hetregress}, and {helpb xtreg}.

{pstd}
See {helpb evalue} for a comprehensive discussion of how to interpret results produced by {opt evalue_estat}.



{title:Examples}

{pstd}
{opt 1) E-value for a risk ratio:}{p_end}

{pmore} Set-up {p_end}
{pmore2}{bf:{stata "webuse dollhill3": . webuse dollhill3}} {p_end}

{pmore} Estimate a Poisson model {p_end}
{pmore2}{bf:{stata "poisson deaths smokes i.agecat, exposure(pyears) irr": . poisson deaths smokes i.agecat, exposure(pyears) irr}} {p_end}

{pmore} Compute the E-value for the coefficient {cmd: smokes}. {p_end}
{pmore2}{bf:{stata "evalue_estat smokes": . evalue_estat smokes}} {p_end}

{pmore} Same as above but assessing the amount of confounding needed to shift the point estimate (1.43) to 1.10. {p_end}
{pmore2}{bf:{stata "evalue_estat smokes==1.1": . evalue_estat smokes==1.1}} {p_end}


{pstd}
{opt 2) E-value for an odds ratio:}{p_end}

{pmore} Set-up {p_end}
{pmore2}{bf:{stata "webuse lbw": . webuse lbw}} {p_end}

{pmore} Estimate a logistic regression model. Note that, in this example, the exposure variable {cmd:smoke} is specified as a factor variable. {p_end}
{pmore2}{bf:{stata "logistic low age lwt i.race i.smoke ptl ht ui": . logistic low age lwt i.race i.smoke ptl ht ui}} {p_end}

{pmore} Compute the E-value for the coefficient {cmd: i.smoke} {p_end}
{pmore2}{bf:{stata "evalue_estat 1.smoke": . evalue_estat 1.smoke}} {p_end}


{pstd}
{opt 3) E-value for a hazard ratio:}{p_end}

{pmore} Set-up {p_end}
{pmore2}{bf:{stata "webuse drugtr": . webuse drugtr}} {p_end}

{pmore} Estimate a Cox regression model.{p_end}
{pmore2}{bf:{stata "stcox drug age": . stcox drug age}} {p_end}

{pmore} Compute the E-value for the coefficient {cmd: drug} {p_end}
{pmore2}{bf:{stata "evalue_estat drug": . evalue_estat drug}} {p_end}

{pmore} Estimate a survival regression model with a Weibull distribution.{p_end}
{pmore2}{bf:{stata "streg drug age, dist(weibull)": . streg drug age, dist(weibull)}} {p_end}

{pmore} Compute the E-value for the coefficient {cmd: drug} {p_end}
{pmore2}{bf:{stata "evalue_estat drug": . evalue_estat drug}} {p_end}


{pstd}
{opt 4) E-value for a standardized mean difference:}{p_end}

{pmore} Set-up  {p_end}
{pmore2}{bf:{stata "sysuse auto": . sysuse auto}} {p_end}

{pmore} Estimate a linear regression model  {p_end}
{pmore2}{bf:{stata "regress mpg weight foreign": . regress mpg weight foreign}} {p_end}

{pmore} Compute the E-value for the coefficient {cmd: foreign} {p_end}
{pmore2}{bf:{stata "evalue_estat foreign": . evalue_estat foreign}} {p_end}



{title:Stored results}

{pstd}
{cmd:evalue_estat} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}

{synopt:{cmd:r(est)}}Model coefficient for the point estimate{p_end}
{synopt:{cmd:r(ll)}}Model lower confidence limit{p_end}
{synopt:{cmd:r(ul)}}Model upper confidence limit{p_end}
{synopt:{cmd:r(eval_est)}}E-value for the point estimate{p_end}
{synopt:{cmd:r(eval_ci)}}E-value for the confidence interval{p_end}


{p2col 5 16 20 2: When {cmd:regress}, {cmd:tobit}, {cmd:truncreg}, {cmd:hetregress}, or {cmd:xtreg} is the estimation model, these scalars are also added:}{p_end} 

{synopt:{cmd:r(d)}}Cohen's d{p_end}
{synopt:{cmd:r(se_d)}}standard error of the Cohen's d estimate{p_end}
{synopt:{cmd:r(sdy)}}e(sample) standard deviation of the outcome variable{p_end}
{synopt:{cmd:r(n0)}}sample size of the control group in e(sample){p_end}
{synopt:{cmd:r(n1)}}sample size of the treatment group in e(sample){p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Linden, A., Mathur, M.B., and T. J. VanderWeele. Conducting Sensitivity Analysis for Unmeasured Confounding in Observational Studies using E-values: The evalue package. 
{it:Stata Journal}, Forthcoming.

{p 4 8 2}
VanderWeele, T. J., and Ding, P. (2017). Sensitivity analysis in observational research: introducing the E-value. {it: Annals of Internal Medicine}, 167(4): 268-274.{p_end}



{marker citation}{title:Citation of {cmd:evalue_estat}}

{p 4 8 2}{cmd:evalue_estat} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). EVALUE_ESTAT: Stata module for conducting postestimation sensitivity analyses of unmeasured confounding in observational studies.



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb evalue} if installed, {helpb esizereg} if installed {p_end}

