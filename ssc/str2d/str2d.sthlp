{smcl}
{* *! version 2.0.0  13nov2014}{...}
{cmd:help str2d}
{hline}


{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:str2d} {hline 2}}Explained variation in survival analysis - Royston-Sauerbrei D measure{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd:str2d} [, {it:str2d_options}]
{cmd::} 
{it:survival_cmd}
{it:xvarlist}
{ifin}
[{cmd:,} {it:survival_cmd_options}]


{synoptset 24}{...}
{synopthdr :str2d_options}
{synoptline}
{synopt :{opt adj:ust}}computes adjusted R2, taking into account model dimension{p_end}
{synopt :{opt bo:otreps(#)}}computes a bootstrap confidence interval using {it:#} replications{p_end}
{synopt :{opt exc:lude(varlist)}}excludes {it:varlist} from the linear predictor when assessing R2{p_end}
{synopt :{opt mod:eldim(#)}}sets the dimension of the fitted model to {it:#}{p_end}
{synopt :{opt nodot:s}}suppresses display of the bootstrap replication dots{p_end}
{synopt :{opt rand:omness}}reports explained randomness (default is explained variation){p_end}
{synopt :{opt val:idate(varname)}}estimates the model in the subsample defined by the lower value
of {it:varname} and computes R2 in the subsample defined by the higher value of {it:varname}{p_end}
{synopt :{it:survival_cmd_options}}options of {it:survival_cmd}{p_end}
{synoptline}

{pstd}
{marker syntax}where

{phang}
{it:survival_cmd} may be
{help stcox},
{help streg},
{help stpm} (if installed), or
{help stpm2} (if installed).

{pstd}
You must have {cmd:stset} your data before using {cmd:str2d}.


{title:Description}

{pstd}
{cmd:str2d} computes Royston & Sauerbrei (2004)'s R2 statistic based on
the D measure of discrimination of proportional hazards, proportional
odds and probit models for censored survival data. The D measure is
available for all the above {it:survival_cmd} commands except
{cmd:streg, distribution(gamma)}.

{pstd}
The model is defined by

{pmore}
{cmd:.} {it:survival_cmd} {it:xvarlist} [ {cmd:,} {it:survival_cmd_options} ]

{pstd}
See the {cmd:validate()} option for comments on out-of-sample prediction
and assessment of R2 in a "validation" or test sample.

{pstd}
IMPORTANT NOTE: For version 2.0.0 and upwards, {cmd:str2d} has
"colon command" syntax. The older syntax (up to and including version 1.2.3)
is no longer available. Also, {cmd:str2ph} has been withdrawn and is
no longer included in this package. It has been shown to be prone to bias
as censoring increases.


{title:Options}

{phang}
{opt adjust} computes adjusted R2, taking into account the dimension
(i.e. number of covariates) of the model. This may be helpful when
R2 is low and/or the model is complex, since the expected value of R2 under
the null hypothesis that the outcome is unrelated to the covariates is
greater than zero and depends on the model dimension. Adjustment
attempts to eliminate this bias in R2 under the null hypothesis.
Since R2 calculated by out-of-sample prediction in a "validation"
sample does not require adjustment, the {opt validate()} option is
not permitted with {opt adjust}. See also the {opt modeldim()} option.

{phang}
{opt bootreps(#)} with {it:#} > 0 computes a bootstrap confidence
interval for R2, using {it:#} bootstrap replications. A minimum reasonable
value of {it:#} is 1000, but a better number is 5000. Note that with
{it:#} = 5000, the computation may take quite some time. The default
value of {it:#} is 0, meaning no bootstrap CI is computed; in that case,
an analytic estimate of the SE of R2 is displayed, derived by the delta method
from the SE of D. See Royston & Sauerbrei (2004) for details of the SE of D.

{phang}
{opt exclude(varlist)} deletes predictors in {it:varlist} from the linear
predictor before computing R2 and D. The point of this option is to
remove the effect of irrelevant or uninteresting structural or adjustment
variables, such as centre or region, from the discrimination of the model
of interest. Note that the model is NOT re-fitted without {it:varlist}; the
values of regression coefficients are retained.

{phang}
{opt modeldim(#)} sets the dimension of the fitted model to {it:#}.
The default is for the dimension to equal the number
of terms in {it:xvarlist}. Some people believe that with stepwise
selection of variables, the correct figure to use for the model
dimension is the number of candidate predictors (or more generally,
with multiparameter predictors such as fractional polynomials functions,
the degrees of freedom). {opt modeldim()} has an effect only when
the {opt adjust} option is also applied.

{phang}
{cmd:nodots} suppresses display of the replication dots
with bootstrap confidence interval estimation. By default, a single dot
character is displayed after each 100 replications.

{phang}
{cmd:randomness} expresses R2 results as "explained randomness".
The default is "explained variation".

{phang}
{cmd:validate(}{it:varname}{cmd:)} estimates the model in the 
subsample defined by the low value of {it:varname} and computes
R2 in the subsample defined by the high value of {it:varname}.
These subsamples may be thought of as a training and a test set.
{it:varname} must have exactly two distinct values in the
estimation sample defined by {it:xvarlist}, {cmd:if} and {cmd:in}.
These two values are arbitrary. {it:varname} may be a string variable,
in which case lexicographic ordering is assumed. R2 is computed
according to the index ({cmd:xb}) predicted from
the training sample (low value of {it:varname}) into the test sample
(high value of {it:varname}). The index predicted on the test sample
is transformed to scaled normal scores and regression on the scores
is performed. The slope of this regression is
Royston & Sauerbrei (2004)'s D statistic. This step
is required to compute D and hence R2.

{phang}
{it:survival_cmd_options} are options of {it:survival_cmd}.
Examples include {cmd:distribution(weibull)} for {cmd:streg},
{cmd:df(2) scale(hazard)} for {cmd:stpm} and {cmd:stpm2}, and
{cmd:strata(x1 x2)} for {cmd:stcox}.


{title:Examples}

{phang}{cmd:. }{stata webuse brcancer, clear}{p_end}
{phang}{cmd:. }{stata stset rectime, failure(censrec) scale(365.24)}{p_end}
{phang}{cmd:. }{stata "str2d: stcox x4a x5e x6 hormon"}{p_end}
{phang}{cmd:. }{stata "str2d, bootreps(500): stcox x4a x5e x6 hormon"}{p_end}
{phang}{cmd:. }{stata "str2d: stpm2 x4a x5e x6 hormon, df(2) scale(hazard)"}{p_end}
{phang}{cmd:. }{stata "str2d: streg x4a x5e x6 hormon, distribution(weibull)"}{p_end}
{phang}{cmd:. }{stata set seed 10101}{p_end}
{phang}{cmd:. }{stata gen byte val = (runiform() < 0.5)}{p_end}
{phang}{cmd:. }{stata "str2d, validate(val): stcox x4a x5e x6 hormon"}{p_end}


{title:Author}

{pstd}
Patrick Royston, MRC Clinical Trials Unit at UCL, London.{break}
j.royston@ucl.ac.uk


{title:References}

{phang}
B. Choodari-Oskooei, P. Royston and M. K. B. Parmar. 2012. A simulation study
of predictive ability measures in a survival model I:
Explained variation measures. {it:Statistics in Medicine} {bf:31}: 2627-2643.

{phang}
J. O’Quigley, R. Xu and J. Stare. 2005.
Explained randomness in proportional hazards models.
{it:Statistics in Medicine} {bf:24}: 479-489.

{phang}
P. Royston. 2006. Explained variation for survival models.
{it:Stata Journal} {bf:6(1)}: 83-96.

{phang}
P. Royston and W. Sauerbrei. 2004. A new measure of prognostic
separation in survival data. {it:Statistics in Medicine} {bf:23}: 723-748.


{title:Also see}

{psee}
Online:  help for {help stcox}, {help streg};
{help stpm}, {help stpm2} (if installed).
{p_end}
