{smcl}
{* *! version 2.4.02  9feb2015}{...}
{cmd:help weakiv}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: weakiv} {hline 2}}Weak-instrument-robust tests and confidence intervals
for instrumental-variable (IV) estimation of linear, panel, probit and tobit models{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang}
Standalone estimation (specifying model to be estimated):

{p 8 14 2}
{cmd:weakiv}
{it:iv_cmd}
{it:depvar} [{it:varlist1}]
{cmd:(}{it:varlist2}{cmd:=}{it:varlist_iv}{cmd:)} [{it:weight}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,} {it:model_options}}
{it:test_options} {it:ci_options} {it:graph_options} {it: misc_options}]

{phang}
Obtaining model from previous call to {it:ivregress}, {it:ivreg2}, {it:ivreg2h},
{it:xtivreg}, {it:xtivreg2}, {it:xtabond2}, {it:ivprobit}, or {it:ivtobit}:

{p 8 14 2}
{cmd:weakiv}
[{cmd:,} {it:test_options} {it:ci_options} {it:graph_options} {it: misc_options}]

{phang}
Replay syntax:

{p 8 14 2}
{cmd:weakiv}
[{cmd:,} {it:graph_options} {it:project(varlist)} {it:project2(var1 var2)} {it: misc_options}]

{synoptset 20}{...}
{synopthdr:iv_cmd/model_options}
{synoptline}
{synopt:{it:iv_cmd}}
{it:ivregress}, {it:ivreg2}, {it:ivreg2h}, {it:xtivreg}, {it:xtivreg2}, it:xtabond2}, {it:ivprobit}, or {it:ivtobit}
{p_end}
{synopt:{opt <misc>}}
options supported by {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},  {helpb xtivreg},  {helpb xtivreg2}, {helpb xtabond2}, {helpb ivprobit} or {helpb ivtobit}
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:test_options}
{synoptline}
{synopt:{opt null(numlist)}}
null hypotheses for tests of coefficients on weakly-identified endogenous variables in IV model
{p_end}
{synopt:{opt kwt(#)}}
weight on {it:K} test statistic in {it:K-J} test (see also {it:kjlevel(.)} option below)
{p_end}
{synopt:{opt lm}}
use Lagrange multiplier tests (available for linear models only)
{p_end}
{synopt:{opt md}}
use Wald/Minimum Distance tests (all models)
{p_end}
{synopt:{opt strong(varlist)}}
names of strongly-identified endogenous regressors (if not all are weakly identified)
{p_end}
{synopt:{opt cuestrong}}
use LIML or CUE for strongly-identified endogenous regressors (instead of default IV or 2-step GMM)
{p_end}
{synopt:{opt cuepoint}}
report LIML or CUE point estimates for weakly-identified endogenous regressors
and include in grid if grid search used
(linear models only; reporting option only, does not affect test statistics)
{p_end}
{synopt:{opt subset(varlist)}}
endogenous regressors for subset AR test (multiple-endogenous regressor case only)
{p_end}
{synopt:{opt testexog(varlist)}}
exogenous regressors to be included in the reported tests (optional)
{p_end}
{synopt:{opt clrsims(#)}}
number of reps for simulating distribution of the CLR statistic (default=use closed-form method if available, use 10,000 reps if not);
{opt clrsims(0)} means do not simulate (use closed-form or report missing value)
{p_end}
{synopt:{opt small}}
makes small-sample adjustment
{p_end}
{synopt:{opt eq(diff/lev/sys)}}
({it:xtabond2} only) use (only equation in differences / only equation in levels / both) for weak-ID-robust tests
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:ci_options}
{synoptline}
{synopt:{opt usegrid}}
construct grid for confidence-interval estimation, graphs etc.
{p_end}
{synopt:{opt noci}}
supress reporting/calculation of confidence intervals
{p_end}
{synopt:{opt project(varlist)}}
endogenous regressors for projection-based confidence intervals (multiple-endogenous regressor case only)
{p_end}
{synopt:{opt project2(var1 var2)}}
2 endogenous regressors for projection-based confidence set (multiple-endogenous regressor case only)
{p_end}
{synopt:{opt gridpoints(numlist)}}
number(s) of grid points (in dimensions corresponding to endogenous regressors)
{p_end}
{synopt:{opt gridmult(#)}}
multiplier of Wald confidence-interval for grid
{p_end}
{synopt:{opt gridmin(numlist)}}
lower limit(s) for grid search (in dimensions corresponding to endogenous regressors)
{p_end}
{synopt:{opt gridmax(numlist)}}
upper limit(s) for grid search (in dimensions corresponding to endogenous regressors)
{p_end}
{synopt:{opt grid(numlist [ | numlist [ | numlist ... ] ] )}}
explicit list(s) of grid points (in dimensions corresponding to endogenous regressors); if multiple lists, separated by "|"
{p_end}
{synopt:{opt level(numlist)}}
default confidence level(s) for confidence intervals and sets (max 3)
{p_end}
{synopt:{opt arlevel(#)}}
optional confidence level for AR confidence intervals
{p_end}
{synopt:{opt jlevel(#)}}
optional confidence level for J confidence intervals
{p_end}
{synopt:{opt kjlevel(#)}}
(usage 1) optional overall confidence level for K-J confidence intervals and tests
{p_end}
{synopt:{opt kjlevel(#k #j)}}
(usage 2) optional separate confidence levels for K and J in K-J confidence intervals and tests
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:graph_options}
{synoptline}
{synopt:{opt graph(namelist)}}
graph test rejection probabilities and confidence intervals (ar, clr, k, j, kj, wald)
{p_end}
{synopt:{opt graphxrange(numlist)}}
lower and upper limits of x axis for graph of test statistics
(option unavailable for 2-endogenous regressor case)
{p_end}
{synopt:{opt graphopt(string)}}
graph options to pass to graph command
(applies to combined contour/surface graph in 2-endogenous regressor case)
{p_end}
{synoptline}
{col 7}{it:2-endogenous-regressor usage}
{synopt:{opt contouropt(string)}}
graph options to pass to contour graph command
{p_end}
{synopt:{opt surfaceopt(string)}}
graph options to pass to surface graph command
{p_end}
{synopt:{opt contouronly}}
do contour plot (confidence set) only; suppress surface plot
{p_end}
{synopt:{opt surfaceonly}}
do surface plot (rejection probability surface) only; supress contour plot
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:misc_options}
{synoptline}
{synopt:{opt estadd}[({it:prefix})]}
add main {it:weakiv} results (scalars and macros) to model estimated by IV for Wald tests;
estimation results obtained from previous call to
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb xtabond2},
{helpb ivprobit} or {helpb ivtobit}
remain in memory with {it:weakiv} results added;
{it:prefix} is an optional prefix added to names of scalars and macros
(not available with replay syntax)
{p_end}
{synopt:{cmdab:estuse:wald(name)}}
obtain IV model from stored previous estimation by
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb xtabond2},
{helpb ivprobit} or {helpb ivtobit}
{p_end}
{synopt:{cmdab:eststore:wald(name)}}
store IV model used for Wald tests
(estimated by {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb xtabond2},
{helpb ivprobit} or {helpb ivtobit})
under {it:name}
{p_end}
{synopt:{cmdab:display:wald}}
display model estimated by IV for Wald tests
(not available with replay syntax)
{p_end}

{synoptline}
{p2colreset}{...}

{title:Contents}

{phang}{help weakiv##description:Description}{p_end}
{phang}{help weakiv##tests:Tests, confidence intervals, rejection probabilities}{p_end}
{phang}{help weakiv##interpretation1:Summary interpretations of {it:weakiv} output: 1 endogenous regressor}{p_end}
{phang}{help weakiv##interpretation2:Summary interpretations of {it:weakiv} output: 2 endogenous regressors}{p_end}
{phang}{help weakiv##project:Summary interpretations of {it:weakiv} output: Projection-based inference for 2+ endogenous regressors}{p_end}
{phang}{help weakiv##options:Options}{p_end}
{p 8}{help weakiv##model_options:Model options}{p_end}
{p 8}{help weakiv##test_options:Test options}{p_end}
{p 8}{help weakiv##ci_options:Confidence interval estimation}{p_end}
{p 8}{help weakiv##graph_options:Graphing options}{p_end}
{p 8}{help weakiv##misc_options:Miscellaneous options}{p_end}
{phang}{help weakiv##examples:Examples}{p_end}
{p 8}{help weakiv##gen_examples:General use}{p_end}
{p 8}{help weakiv##ci_examples:Confidence interval and grid examples}{p_end}
{p 8}{help weakiv##graph_examples:Graphing examples}{p_end}
{p 8}{help weakiv##misc_examples:{it:estadd} option and other miscellaneous examples}{p_end}
{phang}{help weakiv##saved_results:Saved results}{p_end}
{phang}{help weakiv##acknowledgements:Acknowledgements}{p_end}
{phang}{help weakiv##references:References}{p_end}
{phang}{help weakiv##citation:Citation of weakiv}{p_end}

{marker description}{...}
{title:Description}

{pstd}
{opt weakiv} performs a set of tests of the coefficient(s) on the endogenous variable(s)
in an instrumental variables (IV) model,
and constructs confidence sets for these coefficients.
These tests and confidences are robust to weak instruments
in the sense that identification of the coefficients is not assumed.
This is in contrast to the traditional IV/GMM estimation methods,
where the validity of tests on estimated coefficients requires the assumption that they are identified.

{pstd}
{opt weakiv} can be used to estimate linear
(including panel fixed effects, first diffences, and dynamic panel data),
probit and tobit IV models.
{opt weakiv} supports a range of variance-covariance estimators for linear IV models
including heteroskedastic-, autocorrelation-, and one- and two-way cluster-robust VCEs.
{opt weakiv} also provides graphics options that allow the plotting of
confidence intervals and rejection probabilities (one endogenous regressor),
and confidence regions and rejection surfaces (two endogenous regressors).

{pstd}
{opt weakiv} can estimate models with any number of endogenous regressors.
There are several options available for models with 2 or more endogenous regressors.
(a) The user can specify, using the {opt strong(.)} option,
that some coefficients are strongly identifed,
in which case {opt weakiv} will report tests for the
weakly-identified subset of coefficients.
(b) The {opt project(.)} option requests the reporting
of conservative projection-based confidence intervals
for the specified endogenous regressors. 
(c) The {opt project2(.)} option requests the construction of
2-dimensional projection-based confidence sets
for the 2 specified endogenous regressors.
These 2-D confidence sets can be graphed using the {opt graph(.)} option.
(d) The {opt subset(.)} option specifies that
only the listed subset of endogenous regressors is tested.
The subset test is available only for i.i.d. linear models (including linear panel models)
and only the subset AR test is available.

{pstd}
For estimations with 1 weakly-identified coefficient,
{opt weakiv} reports tests of the specified null,
confidence intervals, and provides graphing options.
For estimations with 2 weakly-identified coefficients,
{opt weakiv} reports tests of the specified null
and provides graphing options for confidence sets and rejection surfaces.
For estimations with more than 2 weakly-identified coefficients,
{opt weakiv} reports only tests of the specified null hypothesis.
The default null is that all weakly-identified coefficients are zero.

{pstd}
{opt weakiv} can be used either as a standalone estimator
where the user provides the specification of the model,
or after previous IV/GMM estimation by {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb xtabond2}, {helpb ivprobit} or {helpb ivtobit}.

{pstd}
When used as a standalone estimator,
{opt weakiv} works by calling {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb xtabond2}, {helpb ivprobit} or {helpb ivtobit}
depending what the user has specified as {it:iv_cmd}.
{opt weakiv} passes all user-specified model estimation options
to the estimation command:
variable lists, VCE specification, estimation method, etc.

{pstd}
When used with a model previously estimated by
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb xtabond2},
{helpb ivprobit} or {helpb ivtobit},
{opt weakiv} obtains the model specification from the previous estimation.
This is either the model currently in memory,
or the stored model provided by the user in {opt usemodel(name)}.

{pstd}
{opt weakiv} also supports Stata {it:replay} syntax.
If the {opt weakiv} results are the current estimation in memory,
{opt weakiv} with no model specified will replay them.
This can be used to tweak the graph options
without {opt weakiv} having to recalculate the full set of estimation results (see below).
The {opt project(.)} and {opt project2(.)} options are also available with {it:replay} syntax.

{pstd}
{opt weakiv} requires {helpb avar} (Baum and Schaffer 2013) to be installed.
The graphing options for the 2-endogenous-regressor case require Stata 12 or higher
for the contour plots of confidence regions,
and require version 1.06 or higher of {helpb surface} (Mander 2005)
for the 3-D plots of rejection surfaces.
{opt weakiv} will prompt the user for installation of
{helpb avar} and {helpb surface} if necessary.
{helpb avar} is an essential component and {opt weakiv} will not run without it.
Neither {helpb graph contour} nor {helpb surface} is an essential component;
{opt weakiv} will run but will not provide the corresponding graphs.

{pstd}
Estimator notes:

{pstd}
Except where noted below,
{opt weakiv} supports the variance-covariance estimation options available
with {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb xtivreg}, {helpb xtabond2} and {helpb xtivreg2}.
Weights that are supported by each IV command are also supported by {opt weakiv}.

{p2col 5 16 17 0: {helpb ivtobit}}
Only variance-covariance estimation options that assume homoskedasticity are supported.
{p_end}

{p2col 5 16 17 0: {helpb ivprobit}}
The {opt twostep} option (Newey's (1987) two-step estimator) is required.
Only variance-covariance estimation options that assume homoskedasticity are supported.
{p_end}

{p2col 5 16 17 0: {helpb ivreg2h}}
(IV estimation using heteroskedasticity-based instruments)
The {opt gen} option of {helpb ivreg2h} is required
in order to generate the new instruments as variables.
{p_end}

{p2col 5 16 17 0: {helpb xtivreg}}
Only the fixed-effects and first-differences estimators are supported.
{p_end}

{p2col 5 16 17 0: {helpb xtabond2}}
If {opt weakiv} used as a postestimation command after {helpb xtabond2},
the preceding estimation by {helpb xtabond2} requires the {opt svmat}
option to save the {helpb xtabond2}-transformed data as {it:e(.)} matrices.
The {opt svmat} option is {it:not} required
if {opt weakiv} used for standalone estimation ({opt weakiv xtabond2 ...}).
Support for {helpb xtabond2} requires matafavor to be set for speed;
to do this type or click
{stata mata mata set matafavor speed : mata mata set matafavor speed}.
{p_end}


{marker tests}{...}
{title:Tests, confidence intervals, rejection probabilities}

{pstd}
{opt weakiv} calculates Lagrange multiplier (LM) or minimum distance (MD)
versions of weak-instrument-robust tests of the coefficient
on the endogenous variable {it:beta} in an instrumental variables (IV) estimation.
In an exactly-identified model where the number of instruments
equals the number of endogenous regressors,
it reports the Anderson-Rubin ({it:AR}) test statistic.
When the IV model contains more instruments than endogenous regressors
(the model is overidentified),
{opt weakiv} also conducts the conditional likelihood ratio ({it:CLR}) test,
the Lagrange multiplier {it:K} test, the {it:J} overidentification test,
and a combination of the {it:K} and overidentification tests ({it:K-J}).

{pstd}
The default behavior of {opt weakiv} is to report LM versions of these tests for linear models,
and MD versions for the IV probit and IV tobit models.
The MD versions of these tests can be requested by the {opt md} option;
for linear models, these are equivalent to Wald-type tests.
The LM versions of these tests are not available for IV probit/tobit models.
In the current implementation of {opt weakiv},
the {it:CLR} test is available for the 1-endog-regressor case only.
For reference, {opt weakiv} also reports a Wald test
using the relevant traditional IV parameter and VCE estimators;
this Wald test is identical to what would be obtained by
standard estimation using
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb xtabond2},
{helpb ivprobit} or {helpb ivtobit}.

{pstd}
The {it:AR} test is a joint test of the structural parameter
({it:beta=b0}, where {it:beta} is the coefficient on the endogenous regressor)
and the exogeneity of the instruments
({it:E(Zu)=0}, where {it:Z} are the instruments
and {it:u} is the disturbance in the structural equation).
The {it:AR} statistic can be decomposed into the {it:K} statistic
(which tests only {it:H0:beta=b0},
assuming the exogeneity conditions {it:E(Zu)=0} are satisfied)
and the {it:J} statistic
(which tests only {it:H0:E(Zu)=0},
assuming that {it:beta=b0} is true).
This {it:J} statistic is evaluated at the null hypothesis,
as opposed to the Hansen {it:J} statistic from GMM estimation,
which is evaluated at the parameter estimate.

{pstd}
The {it:CLR} test is a related approach to testing {it:H0:beta=b0}.
It has good power properties,
and in particular is the most powerful test for the linear model under homoskedasticity
(within a class of invariant similar tests).
An important advantage of the {it:CLR} test over the {it:K} test is that
the {it:K} test can lose power in some regions of the parameter space
when the objective function has a local extremum or inflection point;
the {it:CLR} test does not suffer from this problem.
The {it:CLR} test is a function of a rank statistic {it:rk}.
For the case of more than one endogenous regressor,
there are several such rank tests available;
{opt weakiv} employs the SVD-based test of Kleibergen and Paap (2006)
(see e.g. {helpb ranktest},
which has the computational advantage of a closed-form solution.
The rank statistic {it:rk} can also be interpreted
as a test of underidentification of the model (see Kleibergen 2005);
under the null hypothesis that the model is underidentified,
{it:rk} has a chi-squared distribution.

{marker underid}{...}
{pstd}
The {it:CLR} test statistic has a non-standard distribution.
For the case of i.i.d. linear models with a single weakly-identified endogenous regressor,
{opt weakiv} uses the fast and accurate algorithm
implemented by Mikusheva and Poi (2006).
The default behavior of {opt weakiv} for non-i.i.d. and nonlinear models
with a single weakly-identified endogenous regressor
is to use the same algorithm to obtain p-values for the {it:CLR} test;
although this is not the correct p-value function for these cases,
the simulations by Finlay and Magnusson (2009) suggest it provides
a good approximation.
For all models with multiple endogenous regressors,
{opt weakiv} obtains the p-value by simulation;
the seed for the random number generator is temporarily set to the value 12345
so that the resulting p-values are replicable.
The default number of simulations is 10,000;
this can be altered using the {opt clrsims(#)} option.
This option can also be used to override the default behavior
of the i.i.d.-linear-model algorithm
with single-endogenous regressor models.
A larger number of simulations will give a more accurate p-value
but can slow execution, especially in grid searches.
The simulation method can be turned off completely
by specifying {opt clrsims(0)}.

{pstd}
The {it:K-J} test combines the {it:K} and {it:J} statistics to jointly test
the structural parameter and the exogeneity of the instruments.
It is more efficient than the {it:AR} test and allows different weights or test levels
to be put on the parameter and overidentification hypotheses.
Unlike the {it:K} test,
the {it:K-J} test does not suffer from the problem of spurious power losses.
To perform the {it:K-J} test, the researcher specifies
the significance levels {it:alpha_K} and {it:alpha_J} for
the {it:K} and {it:J} statistics.
Because the {it:K} and {it:J} tests are independent,
the null of the {it:K-J} test is rejected
if either {it:p_K}<{it:alpha_K}
or {it:p_J}<{it:alpha_J},
where {it:p_K} and {it:p_J} are the {it:K} and {it:J} p-values, respectively.
The overall size of the {it:K-J} test is given by (1-(1-{it:alpha_K})*(1-{it:alpha_J})).

{pstd}
The default behavior of {opt weakiv} is for the user to choose
the overall size of the {it:K-J} test
and the weights {it:kwt} and (1-{it:kwt}) to put on
the {it:K} and {it:J} components, respectively.
Alternatively, the user may specify
the separate significance levels {it:alpha_K} and {it:alpha_J},
from which the overall {it:K-J} test size and weights are calculated.
The p-value function for the {it:K-J} test is
{it:p=min(p1,p2)}, where
{it:p1=(p_K/kwt)*(1-(1-kwt)*p_K)} and
{it:p2=(p_J/(1-kwt))*(1-kwt*p_J)}.
For large {it:L%} (e.g., 95%),
this is approximately equivalent to
rejecting the null at the {it:(100-L)%} significance level if
{it:K} is greater than the {it:kwt*(100-L)%} critical value or
{it:J} is greater than the {it:(1-kwt)*(100-L)%} critical value.
For example, if {it:kwt}=0.8 and {it:(100-L)}=5%,
then the text rejects if the p-value for the {it:K} test is below 4%
or the p-value for the {it:J} test is below 1%
(because (1-(1-0.04)*(1-0.01))=0.0496 which is approximately 0.05).

{marker closedform}{...}
{pstd}
For the single-endogenous-regressor case,
{opt weakiv} also inverts these tests to obtain and report
weak-instrument-robust confidence intervals and
(with the {opt graph(.)} option),
the corresponding rejection probabilities.
In a graph of rejection probabilities,
an L% confidence interval is readily visualized
as the range of values for {it:b0}
such that the rejection probability for the statistic
lies below a horizontal line drawn at L%.
In the case of estimation of the i.i.d. linear model,
{opt weakiv} uses a closed-form solution for these confidence intervals.
Closed-form solutions for the {it:J} and {it:K-J} tests are unavailable;
to obtain confidence intervals for these tests,
specify the {opt usegrid} option.
In all other specifications (nonlinear or non-i.i.d.),
{opt weakiv} estimates confidence intervals by grid search.

{pstd}
For the 2-endogenous-regressors case,
{opt weakiv} uses a grid search and graphical methods
to report the corresponding confidence regions
and rejection probabilities.
In this case, the rejection probabilities form a 3-D rejection surface
where {it:beta1}, the coefficient on endogenous regressor 1, is plotted against the x-axis,
{it:beta2}, the coefficient on endogenous regressor 2, is plotted against the y-axis,
and the rejection probability is plotted against the z-axis (vertical axis).
An L% confidence region is the set of values
for {it:b1} and {it:b2} such that
the null hypothesis {it:H0:beta1=b1 and beta2=b2} cannot be rejected.
In a 3-D graph of the rejection probability surface,
an L% confidence region is readily visualized
as the range of values for {it:b1} and {it:b2}
such that the rejection surface lies below a horizontal plane drawn at L%.

{pstd}
{opt weakiv} can also accommodate models with multiple endogenous regressors,
where some coefficients are weakly identified and some are strongly identified.
{opt weakiv} supports this via the {opt strong(.)}, {opt subset(.)},
{opt project(.)} and {opt project2(.)} options.

{pstd}
The {opt strong(.)} option is available for linear models only.
In effect, the strongly-identified coefficients are removed from the testing,
and {opt weakiv} reports tests, confidence intervals, graphs etc.
for the remaining weakly-identified coefficient(s).
Testing in this case follows the method of Kleibergen (2004);
see Mikusheva (2013) for a concise description.
Briefly, the method uses the standard formulae for weak-identification-robust statistics,
but for the strongly-identified coefficients replaces hypothesized values
with estimates obtained under the null from an efficient estimator.
The default efficient estimators are IV in the i.i.d. case
and 2-step efficient GMM in the non-i.i.d. case;
the {opt cuestrong} replaces these with
the LIML and CUE estimators, respectively
(note that the CUE estimator requires numerical optimization
and grid searches in particular will be slow with this option).
To obtain confidence intervals and rejection probabilities,
the procedure is repeated for each hypothesized value
of the weakly-identified coefficient(s).
Note that if a specific null hypothesis is to be tested
using the {opt null(numlist)} option,
the parameter values in {it:numlist} correspond to
the weakly-identified-coefficients only.

{pstd}
{marker SSAR}{...}
The {opt subset(.)} option implements the subset AR test of Guggenberger et al. (2012).
They show that a weak-instrument-robust AR test
of a subset of endogenous regressors can be performed by,
in effect, using LIML to estimate the coefficients on the regressors not in the subset.
This test is available for i.i.d. linear models only.

{pstd}
The {opt project(.)} option implements projection-based
confidence intervals for the listed weakly-identified endogenous variables.
A projection-based test for a coefficient {it:H0:beta=b0} rejects the null
if the test statistic exceeds the test critical value
for every configuration of hypothesized coefficients
on all the other weakly-identified regressors.
It is conservative in the sense that it has asymptotic size
less than or equal to nominal size.
Intuitively, whereas a standard correctly-sized test
at the 5% significance level
will commit a Type I error 5% of the time,
a conservative projection-based test
will commit a Type I error at most 5% of the time.
See Guggenberger et al. (2012) for a discussion and references.
The projection-based confidence intervals implemented by
{opt weakiv} require grid search.
To get an accurate projection-based CI for a variable,
the user should specify a suitably large number of grid points
in that dimension.

{pstd}
For models with 3 or more weakly-identified endogenous regressors,
the {opt project2(var1 var2)} option implements projection-based
confidence sets for the 2 listed weakly-identified endogenous variables.
These confidence sets can be graphed with the {opt graph(.)} option.

{pstd}
To include exogenous regressors in the hypotheses tested,
the {opt testexog(.)} option can be used.
This also allows the user to construct and graph confidence sets
where one regressor is endogenous and one is exogenous.
Projection-based CIs for exogenous regressors can also be calculated.
These exogenous regressors are treated in the same way
as the possibly-weakly-identified endogenous regressors;
the only difference with the tests discussed above is that
an exogenous variable that is a regressor
and the coefficient for which appears in the null hypothesis
also appears in the orthogonality conditions {it:E(Zu)=0}.

{pstd}
The {it:K} and {it:CLR} confidence intervals and sets
are centered around the point estimates from the CUE
(continuously-updated GMM) estimator;
in the iid case, the CUE estimator reduces to the LIML estimator.
The CUE estimates cannot be used directly for inference,
but provide a useful reference point.
The {opt cuepoint} option requests that CUE estimates
for the weakly-identified endogenous regressors are reported
and included as points in the grid search
(if a grid is used, and only if the CUE estimates lie within the grid limits).
This option is primarily for reporting and will have no impact
on the weak-identification-robust tests.
It can be useful in graphing because
the {it:K} and {it:CLR} statistics are zero at the CUE point estimates
and the {opt cuepoint} option will guarantee
that this is visible in graphs of rejection probabilities and surfaces.
The option is available for linear models only.
The default CUE is the standard GMM CUE;
if Wald/MD tests are requested instead of the default LM tests,
the point estimates are those of the CUE-MD estimator
described in Magnusson (2010).
In both cases, the exogenous regressors are partialled out
before the CUE estimates are calculated.
(NB: In exactly-identified models,
the CUE, LIML and IV estimators coincide.)

{pstd}
{marker method}{...}
The LM and MD weak-identification-robust tests implemented by {opt weakiv} are due to
Anderson and Rubin (1949),
Kleibergen (2002, 2005), Moreira (2003),
Magnusson (2010) and Guggenberger et al. (2012).
For the linear models supported by {opt weakiv},
including the panel data fixed effects, first differences and dynamic panel data models,
the MD versions are equivalent to Wald versions of these tests.
In the construction of the LM versions of the tests,
any exogenous regressors are first partialled out.
For further discussion of these tests,
see Finlay and Magnusson (2009),
Kleibergen (2002, 2005),
Mikusheva (2013),
Moreira (2003),
Chernozhukov and Hansen (2005, 2008),
Magnusson (2010),
and the references therein.


{marker interpretation1}{...}
{title:Summary interpretations of {it:weakiv} output: 1 endogenous regressor}

{pstd}
The following summarizes what the various statistics assume and test
in the single-endogenous-regressor case, and how to interpret the results.
The interpretations are similar for the mulitiple-endogenous-regressor case
when only one coefficient is weakly identified.
The structural parameter, {it:beta}, is the coefficient on the endogenous regressor;
{it:b0} is a hypothesized value for {it:beta};
the excluded instruments are {it:Z};
the assumption that the instruments are exogenous is {it:E(Zu)=0}.
Roughly speaking,
a well-specified model is one in which
{it:H0:beta=b0} cannot be rejected for a narrow range of hypothesized values {it:b0}
and the assumption of instrument exogeneity
cannot be rejected for a wide range of hypothesized values {it:b0}
(i.e., the exogeneity assumption is generally satisified).

{marker cset}{...}
{pstd}
An {it:L%} confidence interval is
the range of {it:b0} such that the rejection probability (=1-{it:pvalue}) is below {it:L%}.
Users can use the {it:graph(.)} option to plot rejection probabilities.
The confidence intervals reported by {opt weakiv} can, in overdidentified models,
be empty, disjoint (composed of unconnected segments), open-ended,
or cover the entire range of possible values for {it:beta}.
An empty confidence interval (null set) means there is no possible value {it:b0}
that is consistent with the model;
this is an indication of misspecification when {it:L%} is fairly high.
Disjoint confidence intervals arise when the plot of the rejection probability
dips below {it:L%} in more than one range;
an example is when the {it:K} statistic has inflection points or local minima
that cause spurious power losses
(inspection of a graph of the {it:K} rejection probability is a way of detecting this).
Open-ended confidence intervals commonly arise when the grid
does not extend far enough to capture the point where the rejection probability
crosses above the {it:L%} line.
Interpretation of an {it:L%} confidence interval that covers
the entire grid range of possible values for {it:beta}
depends on the null hypothesis tested:
if the null hypothesis is {it:H0:beta=b0},
it suggests the parameter {it:beta} is poorly identified or unidentified;
if the null hypothesis is {it:H0:E(Zu)=0},
it suggests the exogeneity conditions are generally satisfied.

{pstd}
Summary of specific tests:

{marker CLR}{...}
{p2col 5 11 12 0: {it:CLR}}
The null hypothesis is {it:H0:beta=b0}.
The exogeneity conditions {it:E(Zu)=0} are assumed to be satisfied.
An {it:L%} confidence interval is the set of all values {it:b0} such that
the null hypothesis {it:beta=b0} cannot be rejected at the {it:(100-L)%} significance level.
{p_end}

{marker K}{...}
{p2col 5 11 12 0: {it:K}}
The null hypothesis is {it:H0:beta=b0}.
The exogeneity conditions {it:E(Zu)=0} are assumed to be satisfied.
An {it:L%} confidence interval is the set of all values {it:b0} such that
the null hypothesis {it:beta=b0} cannot be rejected at the {it:(100-L)%} significance level.
{p_end}

{marker J}{...}
{p2col 5 11 12 0: {it:J}}
The null hypothesis is {it:H0:E(Zu)=0}.
The structural parameter is assumed to be {it:beta=b0}.
An {it:L%} confidence interval is the set of all values {it:b0} such that
the null hypothesis {it:E(Zu)=0} cannot be rejected at the {it:(100-L)%} significance level.
Note the differences in the null hypothesis
and interpretation of confidence intervals
vs. the {it:CLR} and {it:K} statistics.
{p_end}

{marker K-J}{...}
{p2col 5 11 12 0: {it:K-J}}
(usage 1, specifying overall test level and weights on {it:K} and {it:J})
The null hypothesis is
{it:H0:beta=b0} {it:and} {it:H0:E(Zu)=0}.
For a test at significance {it:(100-L)%}
with weights on the {it:K} and {it:J} tests
of {it:kwt} and {it:(1-kwt)}, respectively,
the null is rejected if
{it:either}
(a) {it:K} is greater than the critical value for
a test at the {it:kwt*(100-L)%} significance level,
{it:or}
(b) {it:J} is greater than the critical value for
a test at the {it:(1-kwt)*(100-L)%} significance level.
(This is interpretation is an approximation;
see the text above for the exact definition.)
An {it:L%} confidence interval is the set of all values {it:b0} such that
the composite null hypothesis cannot be rejected at the {it:(100-L)%} significance level.
{p_end}

{marker K-J}{...}
{p2col 5 11 12 0: {it:K-J}}
(usage 2, specifying test levels separately for {it:K} and {it:J}) 
The null hypothesis is
{it:H0:beta=b0} {it:and} {it:H0:E(Zu)=0}.
For a test at significance {it:alpha_K} for the {it:K} test
and {it:alpha_J} for the {it:J} test,
the null is rejected if
{it:either}
(a) {it:K} is greater than the critical value for
a test at the {it:alpha_K} significance level,
{it:or}
(b) {it:J} is greater than the critical value for
a test at the  {it:alpha_J} significance level.
The significance level for the overall test is
(1-(1-{it:alpha_K})*(1-{it:alpha_J))}.
An {it:L%} confidence interval is the set of all values {it:b0} such that
the composite null hypothesis cannot be rejected at the {it:(100-L)%} significance level.
{p_end}

{marker AR}{...}
{p2col 5 11 12 0: {it:AR}}
The null hypothesis is
{it:H0:beta=b0} {it:and} {it:H0:E(Zu)=0}.
For a test at significance {it:(100-L)%}
the null is rejected if
{it:either} (a) {it:H0:beta<>b0},
{it:or} (b) {it:H0:E(Zu)<>0}.
An {it:L%} confidence interval is the set of all values {it:b0} such that
the composite null hypothesis cannot be rejected at the {it:(100-L)%} significance level.
{p_end}

{marker Wald}{...}
{p2col 5 11 12 0: {it:Wald}}
The null hypothesis is
{it:H0:beta=b0}.
Identification of {it:beta} in the IV estimation is assumed to be strong.
An {it:L%} confidence interval is the set of all values {it:b0} such that
the null hypothesis cannot be rejected at the {it:(100-L)%} significance level.

{marker interpretation2}{...}
{title:Summary interpretations of {it:weakiv} output: 2 endogenous regressors}

{pstd}
The following summarizes what the various statistics assume and test
in the two-endogenous-regressors case, and how to interpret the results.
The interpretations are similar for the mulitiple-endogenous-regressor case
when only two coefficients are weakly identified.
The structural parameters, {it:beta1} and {it:beta2},
are the coefficients on the endogenous regressors;
{it:b1} and {it:b2} are hypothesized values for {it:beta1} and {it:beta2}, respectively.
Roughly speaking,
a well-specified model is one in which
{it:H0:beta1=b1 and beta2=b2} cannot be rejected
for a narrow range of hypothesized values {it:b1} and {it:b2}
(i.e., {it:beta1} and {it:beta2} are precisely estimated}
and the assumption of instrument exogeneity
cannot be rejected for a wide range of hypothesized values {it:b1} and {it:b2}
(i.e., the exogeneity assumption is generally satisified).

{pstd}
An 2-dimensional confidence set is a straightforward extension
of a 1-dimensional confidence interval.
An {it:L%} confidence set is
the range of {it:b1} and {it:b2} such that
the rejection probability (=1-{it:pvalue}) is below {it:L%}.
{opt weakiv} uses graphical methods to report confidence sets and rejection probabilities;
these are specified using the {it:graph(.)} option.
A confidence set is graphed in x-y space as a contour plot
using Stata 12's {helpb graph twoway contour}.
Up to 3 confidence levels can be specified using the {it:levels(.)} option;
these will be plotted as lower/higher contours in the contour plot.
The rejection probability is graphed in x-y-z space using Mander's (2005) {helpb surface};
the contours plotted by {helpb contour} are the contours of this surface.
The confidence sets plotted by {opt weakiv} can, in overdidentified models,
be empty, disjoint (composed of unconnected regions), open-ended, etc.
An empty confidence set (null set) means
there is no possible combination of values {it:b1} and {it:b2}
that is consistent with the model;
this is an indication of misspecification when {it:L%} is fairly high.
Disjoint confidence regions arise when the rejection probability surface
dips below {it:L%} in more than one range.
Open-ended confidence regions commonly arise when the grid
does not extend far enough to capture the point where the rejection probability
crosses above the {it:L%} plane.

{marker project}{...}
{title:Summary interpretations of {it:weakiv} output: Projection-based inference for 2+ endogenous regressors}

{pstd}
A standard {it:L%} confidence interval is properly sized if
the probability that it will contain the true value of the parameter beta is {it:L%}.
By contrast, the probability that a projection-based {it:L%} confidence interval
will contain the true value of the parameter beta is {it:at least} {it:L%}.
In this sense the projection-based confidence intervals reported by {opt weakiv} are conservative.
Projection-based intervals for the 2-endogenous-regressor case are easily visualized.
For a 2-dimensional confidence set plotted in x-y space,
the projection-based confidence interval for variable x
is the range of the x axis where some part of the confidence set lies above or beneath;
the projection-based confidence interval for variable y
is the range of the y axis where some part of the confidence set lies to the left or to the right.
See below for an example.

{pstd}
A 2-dimensional projection-based confidence set for two endogenous variables
is an extension of the above:
the probability that a {it:L%} 2-D projection-based confidence set
contains the true values of the parameters beta1 and beta2
is {it:at least} {it:L%}.


{marker options}{...}
{title:Options}

{marker model_options}{...}
{dlgtab:Model options (when used for standalone estimation)}

{phang} {it:iv_cmd} specifies the IV estimator to use:
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb xtabond2}, {helpb ivprobit} or {helpb ivtobit}.
This option is valid only when {opt weakiv}
is used for standalone estimation and the details of the model
are also provided; see {help weakiv##syntax:Syntax} above.

{marker test_options}{...}
{dlgtab:Testing}

{phang} {opt null(numlist)} specifies the null hypothesis for the coefficient on the
endogenous variable(s) in the IV model. The default is
{cmd:null(0)} for 1 weakly-identified coefficient,
{cmd:null(0 0)} for 2 weakly-identified coefficients, etc.

{phang} {opt kwt(#)} is the weight put on the {it:K} test statistic in the {it:K-J} test.
The default is {opt kwt(0.8)}.
It may not be used with the {opt kjlevel(#k #j)} option; see below.

{phang} {opt lm} specifies that LM tests instead of
the default Wald/Minimum Distance tests are reported (linear models only).

{phang} {opt strong(varlist)} specifies that,
in a multiple-endogenous-regressor estimation,
the coefficient(s) on the endogenous regressor(s) in {it:varlist}
is (are) strongly-identified (linear models only).
Tests and graphs are reported for the weakly-identified regressor(s) only.

{phang} {opt cuestrong} requests, for i.i.d. linear models,
that the LIML estimatior is used for the strongly-identified coefficients
in preference to the default IV estimator;
and for non-i.i.d. models,
that the CUE estimator is used in preference to
the default 2-step efficient GMM estimator.
The CUE estimator requires numerical optimization methods
and is noticably slower than 2-step GMM;
this will be particularly noticable when a grid search is used.

{phang} {opt subset(varlist)} specifies that,
in a multiple-endogenous-regressor estimation,
the weak-identification-robust subset AR test
is reported for the endogenous regressor(s)
in {it:varlist} (i.i.d. linear models only).

{phang} {opt clrsims(#)} specifies the number of draws to be used
in obtaining p-values for the {it:CLR} test by simulation.
The default is to use the linear-i.i.d.-single-endogenous-regressor
algorithm for models with one endogenous variable,
and 10,000 simulations otherwise.
The simulation method can be turned off by specifying {opt clrsims(0)}.

{phang} {opt small} specifies that small-sample adjustments be made when test
statistics are calculated for linear IV estimation.
When used in standalone estimation by {opt weakiv},
the default is not to employ small-sample adjustments.
When used after estimation of linear models,
the default is given by whatever small-sample
adjustment option was chosen in the IV command.
Small-sample adjustments are always made for IV probit and IV tobit estimation.
The default small-sample adjustment is N/(N-L)
where L is the number of exogenous variables (regressors and instruments);
for the fixed effects estimator, L includes the number of fixed effects;
if a cluster-robust VCE is used, the small-sample adjustment is
N_clust/(N_clust-1)*(N-1)/(N-L),
where N_clust is the number of clusters.

{phang} {opt eq(diff/lev/sys)} is specific to estimation by {helpb xtabond2}.
This requests that only the specified equation(s) (differences, levels, or both)
are used for weak-identification-robust testing.

{marker ci_options}{...}
{dlgtab:Confidence interval estimation}

{phang} {opt usegrid} specifies that a grid search is conducted.
This will override the default analytic solution for
constructing confidence intervals for the i.i.d. linear model.
Under the other models, grid-based estimation
is the only available method for constructing confidence sets.

{phang} {opt noci} requests that confidence intervals not be estimated/reported.
Grid-based test inversion can be time-intensive,
so this option can save time if a grid search is not required,
either because confidence intervals are not needed
or because a closed-form solution for confidence intervals is available
(the i.i.d. linear model only).

{phang} {opt project(varlist)} requests reporting,
for a multiple-endogenous-regressor estimation,
conservative projection-based confidence intervals
for the endogenous regressor(s) in {it:varlist}.
{opt project(_all)} requests reporting these
for all weakly-identified coefficients.

{phang} {opt project2(var1 var2)} requests construction,
for a multiple-endogenous-regressor estimation,
a 2-dimensional projection-based confidence set
for endogenous regressors {it:var1} and {it:var2}.
This confidence set can be graphed using the {opt graph(.)} option.

{marker gridpoints}{...}
{phang} {opt gridpoints(numlist)} specifies the number of equally spaced values over
which to calculate the confidence sets.
The default number of gridpoints is
100, 25, 11, 7 and 5
for the cases of 1, 2, 3, 4 and 5 endogenous regressors, respectively.
If more than 5 endogenous regressors are specified,
the number of gridpoints must be explicitly provided by the user,
e.g., for 6 endogenous regressors the user can specify {cmd:gridpoints(5 5 5 5 5 5)}.
The number of gridpoints can get easily get large in this case;
in this example, the total number of grid points searched is 5^6 = 15,625.
A large number of grid points will increase the required computation time,
but a greater number of grid points
will improve the precision of both graphs and confidence intervals.

{pmore} {bf:Note:} The default grid is centered around the Wald point estimate
(or the CUE point estimate if the {opt cuepoint} estimate is specified)
with a width equal to twice the Wald confidence interval.
With weak instruments,
this may often be too small a grid to estimate the confidence intervals and sets.

{phang} {opt gridmult(#)} is a way of specifying a grid to calculate confidence sets.
This option specifies that the grid be {it:#} times the size
of the Wald confidence interval. The default is {cmd:gridmult(2)}.

{phang} {opt gridmin(numlist)} and {opt gridmax(numlist)}
together provide another way of specifying
the grid to calculate the confidence sets.
The user provides the lower limits
for the corresponding endogenous variable in {it:gridmin(numlist)},
and the upper limits in {opt gridmax(numlist)}.
Each dimension will be split into equally-sized portions
as specified in {opt gridpoints(numlist)}.

{phang} {opt grid(numlist [ | numlist [ | numlist ... ] ] )}
allows the user to list explicitly
the numeric values of the grid points over which to calculate the confidence sets.
If more than one weakly-identified endogenous regressor is specified,
the corresponding grid {it:numlists} should be separated by the "|" character.
This option is not compatible with any other grid options
and will override them if they are also specified.

{phang} {opt level(#)} specifies the default confidence level,
as a percentage, for confidence intervals.
The default is {cmd:level(95)} or as set by {cmd:set level}.
Changing {opt level(#)} also changes the level of significance
used to determine this result: [100-{opt level(#)}]%.
Up to 3 levels can be provided as {opt level(numlist)};
this option is useful for graphing,
when multiple confidence intervals or confidence sets
corresponding to different confidence levels
can be represented in the same graph.
If more than one level is provided, the first is used for tests.
The option can also be used to tweak graphs when {opt weakiv}'s replay syntax is used.

{phang} {opt arlevel(#)} optionally specifies the confidence level, as a percentage,
for the {it:AR} confidence interval if different from the default confidence level.

{phang} {opt jlevel(#)} optionally specifies the confidence level, as a percentage,
for the {it:J} confidence interval if different from the default confidence level.

{phang} {opt kjlevel(#)} (usage 1) optionally specifies the overall confidence level, as a percentage,
for the {it:K-J} confidence interval if different from the default confidence level.

{phang} {opt kjlevel(#k #j)} (usage 2) optionally specifies the separate confidence levels,
as percentages, for the {it:K} and {it:J} tests in the construction of
the {it:K-J} test and confidence intervals.
The overall test level will be (1-(1-{it:#k}/100)*(1-{it:#j}/100)).
Note that this implicitly specifies the weight on the {it:K} and {it:J} tests
and may not be used with the {opt kwt(#)} option.


{marker graph_options}{...}
{dlgtab:Graphing}

{phang} {opt graph(string)} specifies the test rejection probabilities
to plot vs. the hypothesized value for the structural parameter.
Options available are {it:ar}, {it:k}, {it:j}, {it:clr} (1-endog-regressor case only),
{it:kj}, {it:wald} and {it:all}.
Fo exactly-identified models only {it:ar} and {it:wald} are available.
They may be specified in lower or upper case.
For the 1-endogenous-regressor case,
colors for the different rejection probabilities are preassigned
and do not change with the order or list of tests specified.
Default colors can be overridden with the {opt graphopt(string)} option.

{phang} {opt graphxrange(numlist)} allows the user to specify
the range of the x-axis in graph of rejection probabilities.
It is equivalent to adding "{it:if x>=ll & x<=ul}" in a Stata graph command,
where {it:ll} and {it:ul} are the lower and upper limits for the x-axis, respectively.
(NB: This option is not available for the 2-endogenous-regressor case.)
This option does {it:not} affect the limits of the grid search;
to specify these, use the {opt gridmin(numlist)} and {opt gridmax(numlist)} options.

{phang} {opt graphopt(string)} allows the user to specify additional graphing options,
such as titles, subtitle, colors, etc.
For the 1-endogenous-regressor case the internal graph command is {helpb scatter},
and {opt weakiv} will pass the full contents of {opt graphopt(string)} to it.
For the 2-endogenous-regressor case the internal graph command is {helpb graph combine}
(to combine the contour and surface plots),
and {opt weakiv} will pass the full contents of {opt graphopt(string)} to it.

{phang} {opt contouropt(string)} allows the user to specify additional graphing options
to the internal call to Stata's {helpb graph contour} or {helpb graph contourline} commands.
The default is to display the 2-dimensional confidence sets
via shaded contour graphs using {helpb graph contour}.
To request contour line graphs using {helpb graph contourline},
specify {opt contouropt(contourline ...)}.
To request a scatterplot of grid points indicating the confidence set using {helpb graph scatter},
specify {opt contouropt(scatter ...)}.
This last option can be useful for indicating visually the fineness or coarseness of the grid.

{phang} {opt surfaceopt(string)} allows the user to specify additional graphing options
to the internal call to Mander's (2005) {helpb surface} command.

{phang} {opt contouronly} (2-endogenous-regressor case only)
specifies that only the contour plot (confidence set) is graphed;
the surface plot is not provided.

{phang} {opt surfaceonly} (2-endogenous-regressor case only)
specifies that only the surface plot (surface of rejection probabilities) is graphed;
the contour plot is not provided.

{marker misc_options}{...}
{dlgtab:Miscellaneous options}

{phang} {opt estadd}[({it:prefix})] causes {opt weakiv) to mimic the behavior of {helpb estadd} (Jann 2009).
When it is omitted, {opt weakiv} works like most {opt eclass} commands in Stata
and leaves behind in memory the full set of {opt weakiv} saved results and nothing else.
When {opt estadd} is specified,
{opt weakiv} leaves behind in memory the results of command used to estimate the IV model
({helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} or {helpb ivtobit})
but with {opt weakiv} results added to the estimation results (macros and scalars).
{it:prefix} is optional; when included,
the added results have the same names as used by {opt weakiv}
but with {it:prefix} added.

{phang} {cmdab:eststore:wald(name)}}
stores the IV model estimated by
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} or {helpb ivtobit}
under {it:name}.

{phang} {cmdab:estuse:wald(name)}}
obtains the IV model from a stored previous estimation by
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} or {helpb ivtobit}.

{phang} {cmdab:display:wald}
displays the model estimated by IV for Wald tests prior to reporting {opt weakiv} results.


{marker examples}{...}
{title:Examples}

{marker gen_examples}{...}
{title:General use}

{pstd}Setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}
{phang2}. {stata gen byte poshours=(hours>0)}{p_end}

{pstd}Following estimation by {helpb ivregress}; single endogenous regress.
Test significance of {cmd:educ} in the {cmd:lwage} equation (homoskedastic VCE).
Confidence intervals reported by default; no graphs requested.{p_end}

{phang2}. {stata ivregress 2sls lwage exper expersq (educ = fatheduc motheduc)}{p_end}
{phang2}. {stata weakiv}{p_end}

{pstd}Use as a standalone estimation command with {helpb ivreg2}; single endogenous regressor.
Heteroskedastic-robust tests.
Graph AR, K, J and KJ tests.{p_end}

{phang2}. {stata weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), robust graph(ar k j kj)}{p_end}

{pstd}Limited dependent variable estimation.
Standalone estimation syntax.
Note that partly because the grid has only 100 points and is not very fine,
in both cases the CLR and K confidence intervals appear identical.
Graph AR and CLR tests.{p_end}

{phang2}. {stata weakiv ivtobit hours nwifeinc exper expersq age kidslt6 kidsge6 (educ = fatheduc motheduc), ll graph(ar clr)}{p_end}

{phang2}. {stata weakiv ivprobit poshours nwifeinc exper expersq age kidslt6 kidsge6 (educ = fatheduc motheduc), twostep graph(ar clr)}{p_end}

{pstd}As in second example above, but slower and more accurate:
increase grid points to 500 and use simulation-based method of obtaining CLR p-values
with 1 million draws per simulation (per test, per grid point).
Note that compared to the previous example,
the CLR p-value for H0 has changed slightly,
and the CLR and K confidence intervals still start at the same gridpoint
but now end at slightly different gridpoints.
Standalone estimation syntax.
Graph AR and CLR tests.{p_end}

{phang2}. {stata weakiv ivprobit poshours nwifeinc exper expersq age kidslt6 kidsge6 (educ = fatheduc motheduc), twostep graph(ar clr) gridpoints(500) clrsims(1000000)}{p_end}

{pstd}Two weakly-identified endogenous regressors; robust VCE.
Report CUE and center grid on CUE point estimator.
Graph Wald and K tests using shaded contour plots.{p_end}

{phang2}. {stata weakiv ivreg2 lwage exper expersq (educ hours = fatheduc motheduc kidslt6 kidsge6), rob cuepoint graph(wald k)}{p_end}

{pstd}Two weakly-identified endogenous regressors; robust VCE.
Request test of specific null: education coeff=0.1 and exper coeff=0.05.
Limit the grid to 10x10 and use a scatterplot to illustrate the sparseness of the grid.{p_end}

{phang2}. {stata weakiv ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), robust null(0.1 0.05) gridpoints(10 10) graph(k) contouropt(scatter)}{p_end}

{pstd}Two endogenous regressors, one weakly identified and one assumed strongly identified; robust VCE.
Graph Wald and AR tests.
{p_end}

{phang2}. {stata weakiv ivreg2 lwage exper expersq (educ hours = fatheduc motheduc kidslt6 kidsge6), rob strong(educ) graph(wald ar)}{p_end}

{pstd}Two weakly-identified endogenous regressors; i.i.d. linear model; subset AR test for first regressor.{p_end}

{phang2}. {stata weakiv ivreg2 lwage exper expersq (educ hours = fatheduc motheduc kidslt6 kidsge6), subset(educ)}{p_end}

{pstd}Panel data setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata webuse abdata, clear}{p_end}

{pstd}First-differences estimation using {help xtivreg}; fixed effects estimation using {helpb xtivreg2} and cluster-robust SEs.{p_end}

{phang2}. {stata weakiv xtivreg ys k (n=l2.n l3.n), fd}{p_end}
{phang2}. {stata weakiv xtivreg2 ys k (n=l2.n l3.n), fe cluster(id)}{p_end}

{pstd}Dynamic panel data estimation using {help xtabond2}.
Example taken from {help xtabond2} help file examples:
system estimation, 5 endogenous regressors, cluster-robust VCE, small-sample correction.{p_end}

{phang2}. {stata weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep h(2) small}{p_end}

{pstd}As above, but construct a sparse 4x4x4x4x4=1,024 point grid.{p_end}

{phang2}. {stata weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep h(2) small gridpoints(4 4 4 4 4)}{p_end}

{pstd}Using the saved grid and postestimation syntax, construct a 2-D conservative projection-based confidence set for w and L.w.
Note the sparseness of the grid and that all 4x4=16 grid points are in the confidence set.{p_end}

{phang2}. {stata weakiv, project2(w L.w) graph(k)}

{pstd}As above, but using only data in differences for weak-identification-robust tests:
3 endogenous regressors, cluster-robust VCE, small-sample correction.{p_end}

{phang2}. {stata weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep h(2) small eq(diff)}{p_end}

{pstd}As above, but test the specific null H0: coeff on L.n=0.3; coeff on w=0.2; coeff on k=0.1{p_end}

{phang2}. {stata weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep h(2) small eq(diff) null(0.3 0.2 0.1)}{p_end}

{pstd}As above, but construct and report conservative projection-based confidence intervals. Use a 10x10x10 grid.{p_end}

{phang2}. {stata weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep h(2) small eq(diff) project(_all) gridpoints(10 10 10)}{p_end}

{pstd}As above, using only data in differences, and specifying that the coefficient on lagged n is strongly identified:
3 endogenous regressors, 2 of which have weakly-identified coefficients, cluster-robust VCE, small-sample correction.
Request graph of Wald and CLR with grid of 40x40=1,600 points.{p_end}

{phang2}. {stata weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep h(2) small eq(diff) strong(L.n) graph(wald clr) gridpoints(40 40)}{p_end}

{marker ci_examples}{...}
{title:Confidence interval and grid examples}

{pstd}Time-series setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta"}{p_end}
{phang2}. {stata tsset year, yearly}

{pstd}As a standalone estimator using {opt ivreg2}. Estimate the confidence sets over a grid of 500 points.
Report MD (minimum-distance) rather than default LM stats; graph Wald and K stats.
First use default grid width of 2x the Wald confidence interval (centered around the IV point estimate).
Then use a wider grid of 3x the Wald CI
to remove the open-ended confidence intervals for {it:K} test.
Alternatively, specify the lower and upper limits of the grid.
{p_end}

{phang2}. {stata weakiv ivreg2 cinf (unem = l(1/3).unem), robust bw(3) md gridpoints(500) graph(wald k)}{p_end}
{phang2}. {stata weakiv ivreg2 cinf (unem = l(1/3).unem), robust bw(3) md gridpoints(500) graph(wald k) gridmult(3)}{p_end}
{phang2}. {stata weakiv ivreg2 cinf (unem = l(1/3).unem), robust bw(3) md gridpoints(500) graph(wald k) gridmin(-2) gridmax(1)}{p_end}

{pstd}Setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}

{pstd}Two different uses of {opt kjlevel(.)} option.
(1) Specify an overall {it:K-J} test level of exactly 90%, equal weights on {it:K} in {it:K-J},
and hence test levels for {it:K} in {it:K-J} of appx. 95% each.
(2) Specify test levels of exactly 95% for {it:K} in {it:K-J},
and hence equal weights and an overall {it:K-J} test level of appx. 90%.
In both cases also specify a test level of 90% for the {it:AR} test.{p_end}

{phang2}. {stata weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), robust kjlevel(90) kwt(0.5) arlevel(90)}{p_end}
{phang2}. {stata di _col(5) %5.2f e(kj_level) _col(15) %5.2f e(kjk_level) _col(25) %5.2f e(kjj_level)}{p_end}

{phang2}. {stata weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), robust kjlevel(95 95) arlevel(90)}{p_end}
{phang2}. {stata di _col(5) %5.2f e(kj_level) _col(15) %5.2f e(kjk_level) _col(25) %5.2f e(kjj_level)}{p_end}

{marker graph_examples}{...}
{title:Graphing examples}

{pstd}As a standalone estimation command. Graph the rejection probabilities of all 6 tests (robust VCE),
then use replay syntax to tweak graph options without having to reestimate.
Confidence intervals correspond to x-axis range where rejection probabilities are below 95% line.{p_end}

{phang2}. {stata weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), robust graph(all)}{p_end}
{phang2}. {stata weakiv, graph(ar clr wald) graphxrange(-0.05 0.15) graphopt(title("AR, CLR, Wald"))}{p_end}

{pstd}Time-series setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta"}{p_end}
{phang2}. {stata tsset year, yearly}

{pstd}As a standalone estimation command. Illustrates empty confidence interval, {it:K} spurious loss of power,
{it:J} test misspecification and relation to {it:AR} and {it:K-J} tests.{p_end}

{phang2}. {stata weakiv ivreg2 cinf (unem = l(1/3).unem), robust bw(3) graph(ar k) graphopt(title("AR - empty, K - spurious power loss"))}{p_end}
{phang2}. {stata weakiv ivreg2 cinf (unem = l(1/2).unem), robust bw(3) graph(ar k j kj) gridpoints(800) gridmin(-1) gridmax(1) graphopt(title("J suggests misspecification"))}{p_end}

{pstd}Two endogenous regressors.{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}

{phang2}. {stata weakiv ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), graph(wald ar)}{p_end}

{pstd}Two endogenous regressors; estimate using robust VCE, grid of 30x30=900 points, graph {it:K}, request projection-based CIs.
Note how the projection-based CI for educ corresponds to the range of the x axis under the confidence set,
and the projection-based CI for exper corresponds to the range of the y axis to the left of the confidence set.{p_end}

{phang2}. {stata weakiv ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), robust gridpoints(30 30) graph(k) project(_all)}{p_end}

{pstd}Refine appearance of surface graph using replay syntax; note that with replay the levels in the graph do not have to correspond to tests reported in table{p_end}

{phang2}. {stata weakiv, graph(k) surfaceopt(xlabel(0 0.1 0.2) ylabel(-0.02 0.06)) level(95 90)}{p_end}

{pstd}As above but shaded contour graph instead of contour line graph and 3 confidence levels (95%, 90%, 80%).{p_end}

{phang2}. {stata weakiv, graph(k) surfaceopt(xlabel(0 0.1 0.2) ylabel(-0.02 0.06)) level(95 90 80) contouropt(contourshade)}{p_end}


{marker misc_examples}{...}
{title:{it:estadd} and other miscellaneous examples}

{pstd}Illustrates behavior of {it:estadd}.{p_end}

{phang2}. {stata ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), rob}{p_end}
{phang2}. {stata weakiv, estadd}{p_end}
{phang2}. {stata ereturn list}{p_end}
{phang2}. {stata weakiv ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), rob}{p_end}
{phang2}. {stata ereturn list}{p_end}

{pstd}Illustrates behavior of {it:displaywald}.{p_end}

{phang2}. {stata weakiv ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), rob display}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:weakiv} saves the following in {cmd:e()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:e(clr_p)}}{it:CLR} test p-value{p_end}
{synopt:{cmd:e(clr_stat)}}{it:CLR} test statistic{p_end}
{synopt:{cmd:e(ar_p)}}{it:AR} test p-value{p_end}
{synopt:{cmd:e(ar_chi2)}}{it:AR} test statistic{p_end}
{synopt:{cmd:e(k_p)}}{it:K} test p-value{p_end}
{synopt:{cmd:e(k_chi2)}}{it:K} test statistic{p_end}
{synopt:{cmd:e(j_p)}}{it:J} test p-value{p_end}
{synopt:{cmd:e(j_chi2)}}{it:J} test statistic{p_end}
{synopt:{cmd:e(kj_r)}}{it:K-J} test p-value{p_end}
{synopt:{cmd:e(kwt)}}weight on {it:K} in {it:K-J} test{p_end}
{synopt:{cmd:e(rk)}}rk statistic{p_end}
{synopt:{cmd:e(rk_p)}}rk test p-value (test of underidentification){p_end}
{synopt:{cmd:e(wald_p)}}Wald test p-value{p_end}
{synopt:{cmd:e(endo_ct)}}number of endogenous regressors{p_end}
{synopt:{cmd:e(wendo_ct)}}number of weakly-identified endogenous{p_end}
{synopt:{cmd:e(sendo_ct)}}number of strongly-identified endogenous{p_end}
{synopt:{cmd:e(wald_chi2)}}Wald test statistic{p_end}
{synopt:{cmd:e(overid)}}degree of overidentification{p_end}
{synopt:{cmd:e(small)}}=1 if small-sample adjustments used, =0 otherwise{p_end}
{synopt:{cmd:e(alpha)}}default significance level for tests{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters (if cluster-robust VCE used){p_end}
{synopt:{cmd:e(ar_level)}}level in percent used for {it:AR} confidence interval{p_end}
{synopt:{cmd:e(k_level)}}level in percent used for {it:K} confidence interval{p_end}
{synopt:{cmd:e(j_level)}}level in percent used for {it:J} confidence interval{p_end}
{synopt:{cmd:e(kj_level)}}level in percent for {it:K-J} confidence interval{p_end}
{synopt:{cmd:e(kjk_level)}}level in percent for {it:K} test in {it:K-J} confidence interval{p_end}
{synopt:{cmd:e(kjk_level)}}level in percent for {it:J} test in {it:K-J} confidence interval{p_end}
{synopt:{cmd:e(clr_level)}}level in percent used for {it:CLR} confidence interval{p_end}
{synopt:{cmd:e(wald_level)}}level in percent used for {it:Wald} confidence interval{p_end}
{synopt:{cmd:e(points)}}number of points in grid used to estimate confidence sets{p_end}
{synopt:{cmd:e(clrsims)}}number of draws used in simulations to obtain p-values for CLR test{p_end}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Macros}{p_end}
{synopt:{cmd:e(null)}}null hypothesis (numlist){p_end}
{synopt:{cmd:e(clr_cset)}}confidence set based on {it:CLR} test{p_end}
{synopt:{cmd:e(ar_cset)}}confidence set based on {it:AR} test{p_end}
{synopt:{cmd:e(k_cset)}}confidence set based on {it:K} test{p_end}
{synopt:{cmd:e(kj_cset)}}confidence set based on {it:K-J} test{p_end}
{synopt:{cmd:e(wald_cset)}}confidence set based on Wald test{p_end}
{synopt:{cmd:e(pxx_yy_cset)}}as above, projection-based confidence set for variable xx, test yy{p_end}
{synopt:{cmd:e(inexog)}}list of exogenous regressors (excluding any included in the tests){p_end}
{synopt:{cmd:e(tinexog)}}list of any exogenous regressors included in tests ({opt testexog(.)} option){p_end}
{synopt:{cmd:e(exexog)}}list of excluded instruments{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(endo)}}endogenous variable(s){p_end}
{synopt:{cmd:e(wendo)}}weakly-identified endogenous{p_end}
{synopt:{cmd:e(sendo)}}strongly-identified endogenous{p_end}
{synopt:{cmd:e(csendo)}}if subset-AR test reported, endogenous {it:excluded} from the subset{p_end}
{synopt:{cmd:e(pwendo)}}endogenous vars with projection-based confidence sets{p_end}
{synopt:{cmd:e(pwendo_nlist)}}corresponding numbers for e(pwendo); used to identify projection-based confidence sets in e(.) (see above){p_end}
{synopt:{cmd:e(gridpoints)}}list of grid points in each dimension{p_end}
{synopt:{cmd:e(model)}}{it:linear IV}, {it:IV probit} or {it:IV tobit}{p_end}
{synopt:{cmd:e(waldcmd)}}{it:iv_command} used to estimate standard IV model: {it:ivregress}, {it:ivreg2}, {it:ivreg2h},
{it:xtivreg}, {it:xtivreg2}, {it:xtabond2}, {it:ivprobit}, or {it:ivtobit}{p_end}
{synopt:{cmd:e(level)}}default confidence level in percent used for tests of null = 100*(1-alpha){p_end}
{synopt:{cmd:e(levellist)}}confidence level(s) plotted in graphs{p_end}
{synopt:{cmd:e(method)}}lm or md{p_end}
{synopt:{cmd:e(cmd)}}weakiv{p_end}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Matrices}{p_end}
{synopt:{cmd:e(citable)}}table with test statistics, p-values, and rejection
indicators for every grid point over which hypotheses were tested.
If {opt strong(.)} was used, the estimated coefficients
for the strongly-identified regressors are also recorded.{p_end}
{synopt:{cmd:e(pxxcitable)}}grid table with rejection indicators
for projection-based inference;
xx will be 1 or 2 numbers corresponding to the endogenous regressor(s){p_end}
{synopt:{cmd:e(wbeta)}}weakly-identified coefficients from IV model used for Wald tests{p_end}
{synopt:{cmd:e(var_wbeta)}}VCV from IV model used for Wald tests{p_end}
{synopt:{cmd:e(sbeta)}}if {opt strong(.)} was used, estimated strongly-identified coefficients at null{p_end}
{synopt:{cmd:e(ebeta)}}Wald point estimates for full set of endogenous regressors{p_end}
{synopt:{cmd:e(cuebeta)}}if {opt cuepoint} was used, CUE point estimates for full set of endogenous regressors{p_end}
{p2colreset}{...}


{marker acknowledgements}{...}
{title:Acknowledgements}
{pstd}
{opt weakiv} builds on and extends the command {helpb rivest} by Finlay and Magnusson (2009).
The main differences and extensions are:
(a) extension to the multiple-endogenous-regressor case
and to subsets of weakly-identified coefficients;
(b) graphics options that allow the plotting of confidence intervals and rejection probabilities (1-endog-regressor),
and confidence regions and rejection surfaces (2-endog-regressors);
(c) support for a wider range of variance-covariance estimators in linear IV estimation;
including HAC (heteroskedastic-and autocorrelation-robust) and two-way clustering VCEs;
(d) support for a wider range of estimators, including panel data estimators;
(e) support for LM versions of the tests;
(f) support for strongly-identified coefficients, projection-based inference, and subset-AR tests;
(g) specification of models directly in the command line as well as obtaining specification from
a previously-estimated or stored model ({opt weakiv} is an {it:eclass} command);
(h) changes in terminology, syntax etc.

{pstd}
The code in {opt weakiv} for the closed-form solutions for confidence intervals
in the i.i.d. case (homosekdasticity and independence)
derives from {helpb condivreg} by Mikusheva and Poi.


{marker references}{...}
{title:References}

{marker AR1949}{...}
{phang}
Anderson, T. W. and Rubin, H. 1949.
Estimation of the Parameters of Single Equation in a Complete
System of Stochastic Equations.
{it:Annals of Mathematical Statistics} 20:46–63.
{p_end}

{marker BS2013}{...}
{phang}
Baum, C.F. and Schaffer, M.E. 2013.
AVAR: module to perform asymptotic covariance estimation for iid and
non-iid data robust to heteroskedasticity, autocorrelation, 1- and 2-way
clustering, and common cross-panel autocorrelated disturbances.
{browse "http://ideas.repec.org/c/boc/bocode/s457689.html":http://ideas.repec.org/c/boc/bocode/s457689.html}.
{p_end}

{marker CH2005}{...}
{phang}
Chernozhukov, V. and Hansen, C. 2005.
The Reduced Form:
A Simple Approach to Inference with Weak Instruments.
Working paper, University of Chicago, Graduate School of Business.
{browse "http://dx.doi.org/10.2139/ssrn.937943":http://dx.doi.org/10.2139/ssrn.937943}.
{p_end}

{marker CH2008}{...}
{phang}
Chernozhukov, V. and Hansen, C. 2008.
The Reduced Form:
A Simple Approach to Inference with Weak Instruments.
{it:Economics Letters} 100(1):68-71.
{p_end}

{marker FM2009}{...}
{phang}
Finlay, K. and Magnusson, L.M. 2009.
Implementing weak-instrument robust tests for
a general class of instrumental-variables models.
{it:Stata Journal} 9(3):398-421.
{browse "http://www.stata-journal.com/article.html?article=st0171":http://www.stata-journal.com/article.html?article=st0171}.
{p_end}

{marker GKMC2012}{...}
{phang}
Guggenberger, P., Kleibergen, F., Mavroeidis, S. and Chen, L. 2012.
On the Asymptotic Sizes of Subset Anderson–Rubin and Lagrange Multiplier Tests
in Linear Instrumental Variables Regression.
{it:Econometrica}, 80:2649-2666.
{p_end}

{marker BJ2009}{...}
{phang}
Jann, B. 2009.
ESTOUT: Stata module to make regression tables.
{browse "http://ideas.repec.org/c/boc/bocode/s439301.html":http://ideas.repec.org/c/boc/bocode/s439301.html}.
{p_end}

{marker FK2002}{...}
{phang}
Kleibergen, F. 2002.
Pivotal Statistics for Testing Structural Parameters in Instrumental Variables Regression.
{it:Econometrica}, 70:1781-1803.
{p_end}

{marker FK2004}{...}
{phang}
Kleibergen, F. 2004.
Testing Subsets of Structural Parameters in the Instrumental Variables Regression Model.
{it:Review of Economics and Statistics}, 86:418-423.
{p_end}

{marker FK2005}{...}
{phang}
Kleibergen, F. 2005.
Testing Parameters in GMM Without Assuming that They Are Identified.
{it:Econometrica}, 73:1103-1123.
{p_end}

{marker KP2006}{...}
{phang}
Kleibergen, F. and Paap, R.  2006.
Generalized Reduced Rank Tests Using the Singular Value Decomposition.
{it:Journal of Econometrics}, 133:97-126.
{p_end}

{marker AM2005}{...}
{phang}
Mander, A. 2005.
SURFACE: Stata module to draw a 3D wireform surface plot.
{browse "http://ideas.repec.org/c/boc/bocode/s448501.html":http://ideas.repec.org/c/boc/bocode/s448501.html}.
{p_end}

{marker LM2010}{...}
{phang}
Magnusson, L.M. 2010.
Inference in limited dependent variable models robust to weak identification.
{it:Econometrics Journal}, 13:S56-S79.
{p_end}

{marker AM2013}{...}
{phang}
Mikusheva, A. 2013.
Survey on statistical inferences in weakly-identified instrumental variables models.
{it:Applied Econometrics}, 29:117-131.
{browse "http://econpapers.repec.org/article/risapltrx/0206.htm":http://econpapers.repec.org/article/risapltrx/0206.htm}.
{p_end}

{marker MM2003}{...}
{phang}
Moreira, M. 2003.
A Conditional Likelihood Ratio Test for Structural Models.
{it:Econometrica}, 71:1027-1048.
{p_end}

{marker MP2006}{...}
{phang}
Mikusheva, A. and Poi, B. 2006.
Tests and confidence sets with correct size when instruments are potentially weak.
{it:Stata Journal} 6(3):335-347.
{browse "http://www.stata-journal.com/article.html?article=st0033_2":http://www.stata-journal.com/article.html?article=st0033_2}.
{p_end}

{marker citation}{...}
{title:Citation of weakiv}

{pstd}{opt weakiv} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Finlay, K., Magnusson, L.M., Schaffer, M.E. 2013.
weakiv: Weak-instrument-robust tests and confidence intervals
for instrumental-variable (IV) estimation of linear, probit and tobit models.
{browse "http://ideas.repec.org/c/boc/bocode/s457684.html":http://ideas.repec.org/c/boc/bocode/s457684.html}{p_end}


{title:Authors}

	Keith Finlay, Tulane University, USA
	kfinlay@gmail.com
	
	Leandro Magnusson, University of Western Australia
	leandro.magnusson@uwa.edu.au

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 11, number 2: {browse "http://www.stata-journal.com/article.html?article=up0032":st0171_1},{break}
          {it:Stata Journal}, volume 9, number 3: {browse "http://www.stata-journal.com/article.html?article=st0171":st0171}

{p 5 14 2}
Manual:  {manhelp ivregress R},{break}
{manhelp ivprobit R},{break}
{manhelp ivtobit R},{break}
{manhelp xtivreg R},{break}
{manhelp test R}{break}
{p_end}

{p 7 14 2}
Help:  {helpb condivreg}, {helpb ivreg2}, {helpb ivreg2h}, {helpb xtivreg2}, {helpb xtabond2}, {helpb ranktest} {p_end}

