{smcl}
{* *! version 1.0.0  04jul2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "cdfquantreg##syntax"}{...}
{viewerjumpto "Description" "cdfquantreg##description"}{...}
{viewerjumpto "Distribution Names" "cdfquantreg##options"}{...}
{viewerjumpto "CDF-Quantile Distributions" "cdfquantreg##options"}{...}
{viewerjumpto "Examples" "cdfquantreg##examples"}{...}
{viewerjumpto "Author" "cdfquantreg##examples"}{...}
{viewerjumpto "References" "cdfquantreg##references"}{...}
{title:Title}

{phang}
{bf:cdfquantreg} {hline 2} General linear models using cdf-quantile distributions for variables on the unit interval

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:cdfquantreg}
{it:varlist} 
{cmd:,cdf(}
{it:distribution1} 
{cmd:)}
{cmd:quantile(}
{it:distribution2} 
{cmd:)}
{cmd:[zvarlist(}
{it:varlist_z}
{cmd:)]}
{cmd:[nolog]}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cdfquantreg} invokes maximum likelhood estimation using {help ml} with 
a linear form.  A general linear model is estimated for a dependent variable 
on the unit (0,1) interval, using a member of the cdf-quantile distributon family.

{pstd}
{it:varlist} must include at least the dependent variable, and also may include the 
predictor variables for the location submodel.  {cmd:zvarlist} is a non-required option 
presenting the predictor variables for the dispersion submodel. 

{pstd}
The {cmd:cdf} and {cmd:quantile} options are required, and they specify the 
cdf-quantile distribution to be used in the model. Likewise, {it:distribution1} 
and {it:distribution2} are names chosen from the {ul:Distributions} list below.

{pstd}
Also available is {cmd:cdfquantreg_p}, a postestimation command, which uses the specified 
cdf-quantile distribution to generate the model's parameter estimates and
fitted values. See the help file for {cmd:cdfquantreg_p}.

{marker options}{...}
{title:Distribution Names}

{dlgtab:Distributions}

{phang}
{opt asinh} invokes the arcsinh distribution.

{phang}
{opt burr7} invokes the Burr 7 distribution.

{phang}
{opt burr8} invokes the Burr 8 distribution.

{phang}
{opt cauchit, cauchy} invokes the Cauchy distribution.

{phang}
{opt logit, logistic} invokes the logistic distribution.

{phang}
{opt t2} invokes the t distribution with 2 degrees of freedom.

{marker options}{...}
{title:CDF-Quantile Distributions}

{dlgtab:CDF-Quantile Distributions}

{phang}
{opt asinhasinh} invokes the arcsinh-arcsinh distribution (finite-tailed subfamily).

{phang}
{opt asinhburr7} invokes the arcsinh-Burr7 distribution (trimodal subfamily).

{phang}
{opt asinhburr8} invokes the arcsinh-Burr8 distribution (trimodal subfamily).

{phang}
{opt asinhcauchy} invokes the arcsinh-Cauchy distribution (finite-tailed subfamily).

{phang}
{opt asinhlogistic} invokes the arcsinh-logistic distribution (trimodal subfamily).

{phang}
{opt asinht2} invokes the arcsinh-t2 distribution (trimodal subfamily).

{phang}
{opt burr7asinh} invokes the Burr7-arcsinh distribution (bimodal subfamily).

{phang}
{opt burr7burr7} invokes the Burr7-Burr7 distribution (logit-logistic subfamily).

{phang}
{opt burr7cauchy} invokes the Burr7-Cauchy distribution (bimodal subfamily).

{phang}
{opt burr7logistic} invokes the Burr7-logistic distribution (logit-logistic subfamily).

{phang}
{opt burr7t2} invokes the Burr7-t2 distribution (bimodal subfamily).

{phang}
{opt burr8asinh} invokes the Burr8-arcsinh distribution (bimodal subfamily).

{phang}
{opt burr8burr7} invokes the Burr8-Burr7 distribution (logit-logistic subfamily).

{phang}
{opt burr8burr8} invokes the Burr8-Burr8 distribution (logit-logistic subfamily).

{phang}
{opt burr8cauchy} invokes the Burr8-Cauchy distribution (bimodal subfamily).

{phang}
{opt burr8logistic} invokes the Burr8-logistic distribution (logit-logistic subfamily).

{phang}
{opt burr8t2} invokes the Burr8-t2 distribution (bimodal subfamily).

{phang}
{opt cauchitasinh} invokes the Cauchit-arcsinh distribution (finite-tailed subfamily).

{phang}
{opt cauchitburr7} invokes the Cauchit-Burr7 distribution (trimodal subfamily).

{phang}
{opt cauchitburr8} invokes the Cauchit-Burr8 distribution (trimodal subfamily).

{phang}
{opt cauchitcauchy} invokes the Cauchit-Cauchy distribution (finite-tailed subfamily).

{phang}
{opt cauchitlogistic} invokes the Cauchit-logistic distribution (trimodal subfamily).

{phang}
{opt cauchitt2} invokes the Cauchit-t2 distribution (trimodal subfamily).

{phang}
{opt logitasinh} invokes the logit-arcsinh distribution (bimodal subfamily).

{phang}
{opt logitburr7} invokes the logit-Burr7 distribution (logit-logistic subfamily).

{phang}
{opt logitburr8} invokes the logit-Burr8 distribution (logit-logistic subfamily).

{phang}
{opt logitcauchy} invokes the logit-Cauchy distribution (bimodal subfamily).

{phang}
{opt logitlogistic} invokes the logit-logistic distribution (logit-logistic subfamily).

{phang}
{opt logitt2} invokes the logit-t2 distribution (bimodal subfamily).

{phang}
{opt t2asinh} invokes the t2-arcsinh distribution (bimodal subfamily).

{phang}
{opt t2burr7} invokes the t2-Burr7 distribution (trimodal subfamily).

{phang}
{opt t2burr8} invokes the t2-Burr8 distribution (trimodal subfamily).

{phang}
{opt t2cauchy} invokes the t2-Cauchy distribution (bimodal subfamily).

{phang}
{opt t2logistic} invokes the t2-logistic distribution (trimodal subfamily).

{phang}
{opt t2t2} invokes the t2-t2 distribution (finite-tailed subfamily).

{marker examples}{...}
{title:Example}

{phang}{cmd:/* This example uses ch6_probguiltstudy1.dta */}{p_end}

{phang}{cmd:. cdfquantreg crguilt crvd1 crvd2, cdf(logit) quantile(logistic)}{p_end}

{phang}{cmd:. estimates store A}{p_end}

{phang}{cmd:. cdfquantreg crguilt crvd1 crvd2, cdf(logit) quantile(logistic) zvarlist(crvd1 crvd2)}{p_end}

{phang}{cmd:. estimates store B}{p_end}

{phang}{cmd:. lrtest A B}{p_end}

{marker author}{...}
{title:Author}

{pstd}
Michael Smithson, Research School of Psychology, The Australian National University, 
Canberra, A.C.T. Australia{break}Michael.Smithson@anu.edu.au

{marker references}{...}
{title:References}

{p 4 4 2}
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling random 
variables on the unit interval. {it:British Journal of Mathematical and Statistical Psychology}, 70(3), 412-438.

{p 4 4 2}
Shou, Y. & Smithson, M. (2019). cdfquantreg: An R package for 
CDF-Quantile Regression. {it:Journal of Statistical Software}, 88, 1-30. 

