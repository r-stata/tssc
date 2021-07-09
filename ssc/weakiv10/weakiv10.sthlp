{smcl}
{* *! version 1.0.11  9sept2014}{...}
{cmd:help weakiv10}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: weakiv10} {hline 1}}Weak-instrument-robust tests and confidence intervals
for instrumental-variable (IV) estimation of linear, probit and tobit models{p_end}
{p2colreset}{...}

{title:Note}

{pstd}
{cmd:weakiv10} is an older version of {cmd:weakiv} suitable for Stata 10
without many of the extensions available in the latter.
Users with Stata 11 or later are recommended to {stata net install weakiv.pkg:install} and use {cmd:weakiv}.

{marker syntax}{...}
{title:Syntax}

{phang}
Standalone estimation (specifying model to be estimated):

{p 8 14 2}
{cmd:weakiv10}
{it:iv_cmd}
{it:depvar} [{it:varlist1}]
{cmd:(}{it:varlist2}{cmd:=}{it:varlist_iv}{cmd:)} [{it:weight}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,} {it:model_options}}
{it:test_options} {it:ci_options} {it:graph_options} {it: misc_options}]

{phang}
Obtaining model from previous call to {it:ivregress}, {it:ivreg2}, {it:ivreg2h},
{it:xtivreg}, {it:xtivreg2}, {it:ivprobit}, or {it:ivtobit}:

{p 8 14 2}
{cmd:weakiv10}
[{cmd:,} {it:test_options} {it:ci_options} {it:graph_options} {it: misc_options}]

{phang}
Replay syntax:

{p 8 14 2}
{cmd:weakiv10}
[{cmd:,} {it:graph_options} {it: misc_options}]

{synoptset 20}{...}
{synopthdr:iv_cmd/model_options}
{synoptline}
{synopt:{it:iv_cmd}}
{it:ivregress}, {it:ivreg2}, {it:ivreg2h}, {it:xtivreg}, {it:xtivreg2}, {it:ivprobit}, or {it:ivtobit}
{p_end}
{synopt:{opt <misc>}}
options supported by {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},  {helpb xtivreg},  {helpb xtivreg2}, {helpb ivprobit} or {helpb ivtobit}
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:test_options}
{synoptline}
{synopt:{opt null(#)}}
null hypothesis for test of coefficient on single endogenous variable in IV model
{p_end}
{synopt:{opt kwt(#)}}
weight on {it:K} test statistic in {it:K-J} test (see also {it:kjlevel(.)} option below)
{p_end}
{synopt:{opt lm}}
use LM instead of default Wald/Minimum Distance tests (linear models only)
{p_end}
{synopt:{opt small}}
makes small-sample adjustment
{p_end}
{synoptline}
{col 7}{it:2-endogenous-regressor usage}
{synopt:{opt null1(#)}}
value under the null hypothesis for test of coefficient on endogenous regressor 1
{p_end}
{synopt:{opt null2(#)}}
value under the null hypothesis for test of coefficient on endogenous regressor 2
{p_end}
{synopt:{opt strong(varname)}}
name of strongly-identified endogenous regressor (if only 1 of the 2 is weakly identified)
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:ci_options}
{synoptline}
{synopt:{opt points(#)}}
number of grid points for confidence-interval estimation
{p_end}
{synopt:{opt gridmult(#)}}
multiplier of Wald confidence-interval for grid
{p_end}
{synopt:{opt gridlimits(numlist)}}
lower and upper limits for grid for confidence-interval estimation
{p_end}
{synopt:{opt grid(numlist)}}
explicit list of grid points for confidence-interval estimation
{p_end}
{synopt:{opt usegrid}}
force grid-based confidence-interval estimation in homoskedastic linear IV
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
{synopt:{opt noci}}
supress reporting/calculation of confidence intervals
{p_end}
{synoptline}
{col 7}{it:2-endogenous-regressor usage}
{synopt:{opt points1(#)}}
number of grid points on axis 1 (x)
{p_end}
{synopt:{opt points2(#)}}
number of grid points on axis 2 (y)
{p_end}
{synopt:{opt grid1(numlist)}}
explicit list of grid points for axis 1 (x)
{p_end}
{synopt:{opt grid2(numlist)}}
explicit list of grid points for axis 2 (y)
{p_end}
{synopt:{opt gridlimits1(numlist)}}
upper/lower limits of grid axis 1 (x)
{p_end}
{synopt:{opt gridlimits2(numlist)}}
upper/lower limits of grid axis 2 (y)
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
add main {it:weakiv10} results (scalars and macros) to model estimated by IV for Wald tests;
estimation results obtained from previous call to
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} or {helpb ivtobit}
remain in memory with {it:weakiv10} results added;
{it:prefix} is an optional prefix added to names of scalars and macros
(not available with replay syntax)
{p_end}
{synopt:{cmdab:estuse:wald(name)}}
obtain IV model from stored previous estimation by
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} and {helpb ivtobit}
{p_end}
{synopt:{cmdab:eststore:wald(name)}}
store IV model used for Wald tests
(estimated by {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} or {helpb ivtobit})
under {it:name}
{p_end}
{synopt:{cmdab:display:wald}}
display model estimated by IV for Wald tests
(not available with replay syntax)
{p_end}

{synoptline}
{p2colreset}{...}

{title:Contents}

{phang}{help weakiv10##description:Description}{p_end}
{phang}{help weakiv10##tests:Tests, confidence intervals, rejection probabilities}{p_end}
{phang}{help weakiv10##interpretation1:Summary interpretations of {it:weakiv10} output: 1 endogenous regressor}{p_end}
{phang}{help weakiv10##interpretation2:Summary interpretations of {it:weakiv10} output: 2 endogenous regressors}{p_end}
{phang}{help weakiv10##options:Options}{p_end}
{p 8}{help weakiv10##model_options:Model options}{p_end}
{p 8}{help weakiv10##test_options:Test options}{p_end}
{p 8}{help weakiv10##ci_options:Confidence interval estimation}{p_end}
{p 8}{help weakiv10##graph_options:Graphing options}{p_end}
{p 8}{help weakiv10##misc_options:Miscellaneous options}{p_end}
{phang}{help weakiv10##est_examples:Estimation and testing examples}{p_end}
{phang}{help weakiv10##ci_examples:Confidence interval and grid examples}{p_end}
{phang}{help weakiv10##graph_examples:Graphing examples}{p_end}
{phang}{help weakiv10##misc_examples:{it:estadd} option and other miscellaneous examples}{p_end}
{phang}{help weakiv10##saved_results:Saved results}{p_end}
{phang}{help weakiv10##acknowledgements:Acknowledgements}{p_end}
{phang}{help weakiv10##references:References}{p_end}
{phang}{help weakiv10##citation:Citation of weakiv10}{p_end}

{marker description}{...}
{title:Description}

{pstd}
{opt weakiv10} performs a set of tests of the coefficient(s) on the endogenous variable(s)
in an instrumental variables (IV) model,
and constructs confidence sets for these coefficients.
These tests and confidences are robust to weak instruments
in the sense that identification of the coefficients is not assumed.
This is in contrast to the traditional IV/GMM estimation methods,
where the validity of tests on estimated coefficients requires the assumption that they are identified.

{pstd}
{opt weakiv10} can be used to estimate linear (including panel fixed effects and first diffences),
probit and tobit IV models with one or two endogenous regressors.
{opt weakiv10} supports a range of variance-covariance estimators for linear IV models
including heteroskedastic-, autocorrelation-, and one- and two-way cluster-robust VCEs.
{opt weakiv10} also provides graphics options that allow the plotting of
confidence intervals and rejection probabilities (one endogenous regressor),
and confidence regions and rejection surfaces (two endogenous regressors).

{pstd}
{opt weakiv10} can be used either as a standalone estimator
where the user provides the specification of the model,
or after previous IV estimation by {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb ivprobit}, or {helpb ivtobit}.

{pstd}
When used as a standalone estimator,
{opt weakiv10} works by calling {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb ivprobit}, or {helpb ivtobit}
depending what the user has specified as {it:iv_cmd}.
{opt weakiv10} passes all user-specified model estimation options
to the estimation command:
variable lists, VCE specification, estimation method, etc.

{pstd}
When used with a model previously estimated by
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb ivprobit}, or {helpb ivtobit},
{opt weakiv10} obtains the model specification from the previous estimation.
This is either the model currently in memory,
or the stored model provided by the user in {opt usemodel(name)}.

{pstd}
{opt weakiv10} also supports Stata {it:replay} syntax.
If the {opt weakiv10} results are the current estimation in memory,
{opt weakiv10} with no model specified will replay them.
This can be used to tweak the graph options
without {opt weakiv10} having to recalculate the full set of estimation results (see below).

{pstd}
For linear IV estimation including panel fixed effects and first differences,
{opt weakiv10} supports all the variance-covariance estimation options available
with {helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb xtivreg} and {helpb xtivreg2}.
When used with {helpb ivreg2h}
(IV estimation using heteroskedasticity-based instruments)
the {opt gen} option of {helpb ivreg2h} is required
in order to generate the new instruments;
see {helpb ivreg2h}.
For IV probit and IV tobit estimation,
{opt weakiv10} supports only variance-covariance estimation options that assume
homoskedasticity (that is, all variance-covariance options except
{cmd:vce(robust)} and {cmd:vce(cluster} {it:clustvar}{cmd:)}).
For IV probit estimation,
{opt weakiv10} supports only estimation using Newey's (1987) two-step estimator,
and the {opt twostep} option is required;
see help {helpb ivprobit}.
Weights that are supported by each IV command are also supported by {opt weakiv10}.

{pstd}
{opt weakiv10} requires {helpb avar} (Baum and Schaffer 2013) to be installed.
The graphing options for the 2-endogenous-regressor case require Stata 12 or higher
for the contour plots of confidence regions,
and require version 1.06 or higher of (helpb surface} (Mander 2005)
for the 3-D plots of rejection surfaces.
{opt weakiv10} will prompt the user for installation of
{helpb avar} and {helpb surface} if necessary.
{helpb avar} is an essential component and {opt weakiv10} will not run without it.
Neither {helpb graph contour} nor {helpb surface} is an essential component;
{opt weakiv10} will run but will not provide the corresponding graphs.

{marker tests}{...}
{title:Tests, confidence intervals, rejection probabilities}

{pstd}
{opt weakiv10} calculates minimum distance (MD) or Lagrange multiplier (LM)
versions of weak-instrument-robust tests of the coefficient
on the endogenous variable {it:beta} in an instrumental variables (IV) estimation.
In an exactly-identified model where the number of instruments
equals the number of endogenous regressors,
it reports the Anderson-Rubin ({it:AR}) test statistic.
When the IV model contains more instruments than endogenous regressors
(the model is overidentified),
{opt weakiv10} also conducts the conditional likelihood ratio ({it:CLR}) test,
the Lagrange multiplier {it:K} test, the {it:J} overidentification test,
and a combination of the {it:K} and overidentification tests ({it:K-J}).
The default behavior of {opt weakiv10} is to report MD versions of these tests;
for linear models, these are equivalent to Wald-type tests.
{opt weakiv10} can optionally report instead LM-type versions of
the {it:AR}, {it:K}, {it:J} and {it:K-J} tests.
In the current implementation of {opt weakiv10},
the {it:CLR} test is available for the 1-endog-regressor case only.
For reference, {opt weakiv10} also reports a Wald test
using the relevant traditional IV parameter and VCE estimators.

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

{pstd}
The {it:K-J} test combines the {it:K} and {it:J} statistics to jointly test
the structural parameter and the overidentifying restrictions.
It is more efficient than the {it:AR} test and allows different weights or test levels
to be put on the parameter and overidentification hypotheses.
Unlike the {it:K} test when used on its own,
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
The default behavior of {opt weakiv10} is for the user to choose
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

{pstd}
For the single-endogenous-regressor case,
{opt weakiv10} also inverts these tests to obtain and report
weak-instrument-robust confidence intervals and
(with the {opt graph(.)} option),
the corresponding rejection probabilities.
In a graph of rejection probabilities,
an L% confidence interval is readily visualized
as the range of values for {it:b0}
such that the rejection probability for the statistic
lies below a horizontal line drawn at L%.
In the case of estimation of the linear model under the assumption of homoskedasticity and independence,
{opt weakiv10} uses a closed-form solution for these confidence intervals.
In all other specifications,
{opt weakiv10} estimates confidence intervals by grid search.

{pstd}
For the 2-endogenous-regressors case,
{opt weakiv10} uses a grid search and graphical methods
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
A special case arises when there are 2 endogenous regressors,
but one coefficient is weakly identified and one is strongly identified.
{opt weakiv10} supports this via the {opt strong(.)} option;
the option is available for linear models only.
By convention, the weakly-identified endogenous coefficient is #1
and the strongly-identified endogenous coefficient is #2.
Testing in this case follows the method of Kleibergen (2004);
see Mikusheva (2013) for a concise description.
For a given hypothesized value for the weakly-identified coefficient,
the method first estimates the strongly-identified coefficient
using an efficient estimator
(2SLS in the i.i.d. case or 2-step efficient GMM in the non-i.i.d. case),
and then calculates the test statistic
using the same expressions as for the 2-endogenous-regressor case,
the hypothesized value for the weakly-identified coefficient,
but the estimated value for the strongly-identified coefficient.
To obtain confidence intervals and rejection probabilities,
the procedure is repeated for each hypothesized value
of the weakly-identified coefficient.
Testing, graphing and other options follow the syntax
for the 1-endogenous-regressor case.

{pstd}
{marker method}{...}
The default tests implemented by {opt weakiv10} are the Magnusson (2010) minimum-distance (MD) versions of
the weak-identification-robust tests introduced by
Anderson and Rubin (1949),
Kleibergen (2002, 2005) and Moreira (2003).
For the linear models supported by {opt weakiv10},
including the panel data fixed effects and first differences models,
the MD versions are equivalent to Wald versions of these tests.
When the {it:lm} options is specified,
{opt weakiv10} reports the Kleibergen (2002, 2005) LM versions
of the {it:AR}, {it:K}, {it:J} and {it:K-J} tests for linear models
(and the Kleibergen (2005) GMM generalization of Moreira's CLR statistic
for non-iid linear models only).
In the construction of the LM versions of the tests,
any exogenous regressors are first partialled out.
For further discussion of these tests,
see Finlay and Magnusson (2009),
Magnusson (2010),
Kleibergen (2002, 2005),
Moreira (2003),
Chernozhukov and Hansen (2005, 2008),
and the references therein.


{marker interpretation1}{...}
{title:Summary interpretations of {it:weakiv10} output: 1 endogenous regressor}

{pstd}
The following summarizes what the various statistics assume and test
in the single-endogenous-regressor case, and how to interpret the results.
The interpretations are similar for the 2-endogenous-regressor case
when only one coefficient is weakly identified.
The structural parameter, {it:beta}, is the coefficient on the endogenous regressor;
{it:b0} is a hypothesized value for {it:beta};
the excluded instruments are {it:Z};
the assumption that the instruments are exogenous is {it:E(Zu)=0}.
Roughly speaking,
a well-specified model is one in which
{it:H0:beta=b0} cannot be rejected for a narrow range of hypothesized values {it:b0}
(i.e., {it:beta} is precisely estimated}
and the assumption of instrument exogeneity
cannot be rejected for a wide range of hypothesized values {it:b0}
(i.e., the exogeneity assumption is generally satisified).

{marker cset}{...}
{pstd}
An {it:L%} confidence interval is
the range of {it:b0} such that the rejection probability (=1-{it:pvalue}) is below {it:L%}.
Users can use the {it:graph(.)} option to plot rejection probabilities.
The confidence intervals reported by {opt weakiv10} can, in overdidentified models,
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
{it:or} (b) {it:H0:E(Zu)<>b0}.
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
{title:Summary interpretations of {it:weakiv10} output: 2 endogenous regressors}

{pstd}
The following summarizes what the various statistics assume and test
in the two-endogenous-regressors case, and how to interpret the results.
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
{opt weakiv10} uses graphical methods to report confidence sets and rejection probabilities;
these are specified using the {it:graph(.)} option.
A confidence set is graphed in x-y space as a contour plot
using Stata 12's {helpb graph twoway contour}.
Up to 3 confidence levels can be specified using the {it:levels(.)} option;
these will be plotted as lower/higher contours in the contour plot.
The rejection probability is graphed in x-y-z space using Mander's (2005) {helpb surface};
the contours plotted by {helpb contour} are the contours of this surface.
The confidence sets plotted by {opt weakiv10} can, in overdidentified models,
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


{marker options}{...}
{title:Options}

{marker model_options}{...}
{dlgtab:Model options (when used for standalone estimation)}

{phang} {it:iv_cmd} specifies the IV estimator to use:
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h},
{helpb xtivreg}, {helpb xtivreg2}, {helpb ivprobit} or {helpb ivtobit}.
This option is valid only when {opt weakiv10}
is used for standalone estimation and the details of the model
are also provided; see {help weakiv10##syntax:Syntax} above.

{marker test_options}{...}
{dlgtab:Testing}

{phang} {opt null(#)} specifies the null hypothesis for the coefficient on the
endogenous variable in the IV model. The default is
{cmd:null(0)}.
The {opt null1(#)} and {opt null2(#)} options can be used
to specify the null for the 2-endog-regressor case;
the default null is 0 for both coefficients.

{phang} {opt kwt(#)} is the weight put on the {it:K} test statistic in the {it:K-J} test.
The default is {opt kwt(0.8)}.
It may not be used with the {opt kjlevel(#k #j)} option; see below.

{phang} {opt lm} specifies that LM tests instead of
the default Wald/Minimum Distance tests are reported (linear models only).

{phang} {opt strong(varname)} specifies that,
in a 2-endogenous-regressor estimation,
the endogenous regressor {it:varname} is strongly identified (linear models only).
Tests and graphs are reported for the weakly-identified regressor only.

{phang} {opt small} specifies that small-sample adjustments be made when test
statistics are calculated for linear IV estimation.
When used in standalone estimation by {opt weakiv10},
the default is not to employ small-sample adjustments.
When used after estimation by {helpb ivregress}, {helpb ivreg2} or {helpb ivreg2h},
the default is given by whatever small-sample
adjustment option was chosen in the IV command.
Small-sample adjustments are always made for IV probit and IV tobit estimation.
The default small-sample adjustment is N/(N-L)
where L is the number of exogenous variables (regressors and instruments);
for the fixed effects estimator, L includes the number of fixed effects;
if a cluster-robust VCE is used, the small-sample adjustment is
N_clust/(N_clust-1)*(N-1)/(N-L),
where N_clust is the number of clusters.


{marker ci_options}{...}
{dlgtab:Confidence interval estimation}

{phang} {opt noci} requests that confidence intervals not be estimated/reported.
Grid-based test inversion can be time-intensive,
so this option can save time if a grid search is not required,
either because confidence intervals are not needed
or because a closed-form solution for confidence intervals is available
(the linear model with homoskedastic errors only).

{phang} {opt points(#)} specifies the number of equally spaced values over
which to calculate the confidence sets.
In the single endogenous regressor case,
the default is {cmd:points(100)} and the maximum number of points is {cmd:points(800)}.
In the 2-endog regressor case,
the defaults are {cmd:points1(10)} and {cmd:points2(10)},
and can either be set separately or set simultaneously by {cmd:points(#)};
the total number of values in the grid over which the search takes place
will be {cmd:points1(#)}*{cmd:points2(#)}.
Increasing the number of grid points will increase the time required to
estimate the confidence intervals, but a greater number of grid points will
improve precision.

{pmore} {bf:Note:} The default grid is centered around the point estimate
with a width equal to twice the Wald confidence interval.
With weak instruments,
this is often too small of a grid to estimate the confidence intervals and sets.

{phang} {opt gridmult(#)} is a way of specifying a grid to calculate confidence sets.
This option specifies that the grid be {it:#} times the size
of the Wald confidence interval. The default is {cmd:gridmult(2)}.

{phang} {opt gridlimits(numlist)} is another way of specifying
the grid to calculate the confidence sets.
The user provides the lower and upper limits in {it:numlist}.
This option is not compatible with {opt gridmult(#)}
and will override it if it is also specified.
For the 2-endogenous regressor case,
the limits are specified separately for the two regressors using
the {opt gridlimits1(numlist)} and {opt gridlimits2(numlist)} options.

{phang} {opt grid(numlist)} allows the user to list explicitly
the numeric values of the grid points over which to calculate the confidence sets.
This option is not compatible with any other grid options
and will override them if they are also specified.

{phang} {opt usegrid} forces grid-based test inversion for confidence-interval
estimation under the homoskedastic linear IV model. The default is to use the
analytic solution. Under the other models, grid-based estimation is the only
method.

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
The option can also be used to tweak graphs when {opt weakiv10}'s replay syntax is used.

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
to specify these, use the {opt gridlimits(numlist)} option.

{phang} {opt graphopt(string)} allows the user to specify additional graphing options,
such as titles, subtitle, colors, etc.
For the 1-endogenous-regressor case the internal graph command is {helpb scatter},
and {opt weakiv10} will pass the full contents of {opt graphopt(string)} to it.
For the 2-endogenous-regressor case the internal graph command is {helpb graph combine}
(to combine the contour and surface plots),
and {opt weakiv10} will pass the full contents of {opt graphopt(string)} to it.

{phang} {opt contouropt(string)} allows the user to specify additional graphing options
to the internal call to Stata's {helpb graph contour} or {helpb graph contourline} commands.
The default is to produce contour line graphs using {helpb graph contourline};
to request shaded contour graphs using {helpb graph contour},
specify {opt contouropt(contourshade ...)}.

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

{phang} {opt estadd}[({it:prefix})] causes {opt weakiv10) to mimic the behavior of {helpb estadd} (Jann 2009).
When it is omitted, {opt weakiv10} works like most {opt eclass} commands in Stata
and leaves behind in memory the full set of {opt weakiv10} saved results and nothing else.
When {opt estadd} is specified,
{opt weakiv10} leaves behind in memory the results of command used to estimate the IV model
({helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} or {helpb ivtobit})
but with {opt weakiv10} results added to the estimation results (macros and scalars).
{it:prefix} is optional; when included,
the added results have the same names as used by {opt weakiv10}
but with {it:prefix} added.

{phang} {cmdab:eststore:wald(name)}}
stores the IV model estimated by
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} or {helpb ivtobit}
under {it:name}.

{phang} {cmdab:estuse:wald(name)}}
obtains the IV model from a stored previous estimation by
{helpb ivregress}, {helpb ivreg2}, {helpb ivreg2h}, {helpb ivprobit} or {helpb ivtobit}.

{phang} {cmdab:display:wald}
displays the model estimated by IV for Wald tests prior to reporting {opt weakiv10} results.


{marker est_examples}{...}
{title:Estimation and testing examples}

{pstd}Setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}
{phang2}. {stata gen byte poshours=(hours>0)}{p_end}

{pstd}Following estimation by {helpb ivregress}: test significance of {cmd:educ} in the {cmd:lwage} equation (homoskedastic VCE).
Graph Wald, AR and CLR tests.{p_end}

{phang2}. {stata ivregress 2sls lwage exper expersq (educ = fatheduc motheduc)}{p_end}
{phang2}. {stata weakiv10, graph(wald ar clr)}{p_end}

{pstd}Use as a standalone estimation command (robust VCE, LM versions of tests).
Graph AR, K, J and KJ tests.{p_end}

{phang2}. {stata weakiv10 ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), robust lm graph(ar k j kj)}{p_end}

{pstd}Limited dependent variable estimation (standalone IV tobit and following estimation by {helpb ivprobit}.{p_end}

{phang2}. {stata weakiv10 ivtobit hours nwifeinc exper expersq age kidslt6 kidsge6 (educ = fatheduc motheduc), ll}{p_end}

{phang2}. {stata ivprobit poshours nwifeinc exper expersq age kidslt6 kidsge6 (educ = fatheduc motheduc), twostep}{p_end}
{phang2}. {stata weakiv10}{p_end}

{pstd}Two endogenous regressors. Only tests of null hypotheses reported; no grid used.{p_end}

{phang2}. {stata weakiv10 ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), robust null1(0.1) null2(0.05)}{p_end}

{pstd}Two endogenous regressors, both assumed weakly identified. Graph Wald and K tests; robust VCE.{p_end}

{phang2}. {stata weakiv10 ivreg2 lwage exper expersq (educ hours = fatheduc motheduc kidslt6 kidsge6), rob graph(wald k)}{p_end}

{pstd}Two endogenous regressors.  Same as above except one assumed strongly identified.{p_end}

{phang2}. {stata weakiv10 ivreg2 lwage exper expersq (educ hours = fatheduc motheduc kidslt6 kidsge6), rob strong(educ) graph(wald k)}{p_end}

{pstd}Time-series setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta"}{p_end}
{phang2}. {stata tsset year, yearly}

{pstd}Following estimation by {helpb ivreg2}. Test null that coefficient on {opt unem}=-0.5; use weight of 0.75 on {it:K} in {it:K-J} test;
request small-sample adjustment.{p_end}

{phang2}. {stata ivreg2 cinf (unem = l(1/3).unem), robust bw(3)}{p_end}
{phang2}. {stata weakiv10, null(-0.5) kwt(0.75) small}{p_end}

{pstd}Panel data setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata webuse abdata}{p_end}

{pstd}First-differences estimation using {help xtivreg}; fixed effects estimation using {helpb xtivreg2} and cluster-robust SEs.{p_end}

{phang2}. {stata weakiv10 xtivreg ys k (n=l2.n l3.n), fd}{p_end}
{phang2}. {stata weakiv10 xtivreg2 ys k (n=l2.n l3.n), fe cluster(id)}{p_end}


{marker ci_examples}{...}
{title:Confidence interval and grid examples}

{pstd}As a standalone estimator using {opt ivreg2}. Estimate the confidence sets over a grid of 500 points.
Use a wider grid (width=3x the Wald confidence interval, centered around the IV point estimate)
to remove the open-ended confidence intervals for {it:K} test.{p_end}

{phang2}. {stata weakiv10 ivreg2 cinf (unem = l(1/3).unem), robust bw(3) points(500) gridmult(3)}{p_end}

{pstd}As above, but instead specify the lower and upper limits of the grid.{p_end}

{phang2}. {stata weakiv10 ivreg2 cinf (unem = l(1/3).unem), robust bw(3) points(500) gridlimits(-2 1)}{p_end}

{pstd}Two different uses of {opt kjlevel(.)} option.
(1) Specify an overall {it:K-J} test level of exactly 90%, equal weights on {it:K} in {it:K-J},
and hence test levels for {it:K} in {it:K-J} of appx. 95% each.
(2) Specify test levels of exactly 95% for {it:K} in {it:K-J},
and hence equal weights and an overall {it:K-J} test level of appx. 90%.
In both cases also specify a test level of 90% for the {it:AR} test.{p_end}

{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}

{phang2}. {stata weakiv10 ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), robust kjlevel(90) kwt(0.5) arlevel(90)}{p_end}
{phang2}. {stata di _col(5) %5.2f e(kj_level) _col(15) %5.2f e(kjk_level) _col(25) %5.2f e(kjj_level)}{p_end}

{phang2}. {stata weakiv10 ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), robust kjlevel(95 95) arlevel(90)}{p_end}
{phang2}. {stata di _col(5) %5.2f e(kj_level) _col(15) %5.2f e(kjk_level) _col(25) %5.2f e(kjj_level)}{p_end}

{marker graph_examples}{...}
{title:Graphing examples}

{pstd}Setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}

{pstd}As a standalone estimation command. Graph the rejection probabilities of all 6 tests (robust VCE),
then use replay syntax to tweak graph options without having to reestimate.
Confidence intervals correspond to x-axis range where rejection probabilities are below 95% line.{p_end}

{phang2}. {stata weakiv10 ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), robust graph(all)}{p_end}
{phang2}. {stata weakiv10, graph(ar clr wald) graphxrange(-0.05 0.15) graphopt(title("AR, CLR, Wald"))}{p_end}

{pstd}Time-series setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta"}{p_end}
{phang2}. {stata tsset year, yearly}

{pstd}As a standalone estimation command. Illustrates empty confidence interval, {it:K} spurious loss of power,
{it:J} test misspecification and relation to {it:AR} and {it:K-J} tests.{p_end}

{phang2}. {stata weakiv10 ivreg2 cinf (unem = l(1/3).unem), robust bw(3) graph(ar k) graphopt(title("AR - empty, K - spurious power loss"))}{p_end}
{phang2}. {stata weakiv10 ivreg2 cinf (unem = l(1/2).unem), robust bw(3) graph(ar k j kj) points(800) gridlimits(-1 1) graphopt(title("J suggests misspecification"))}{p_end}

{pstd}Two endogenous regressors.{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}

{phang2}. {stata weakiv10 ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), graph(wald ar)}{p_end}

{pstd}Two endogenous regressors; estimate using robust VCE, grid of 25x25=625 points{p_end}

{phang2}. {stata weakiv10 ivreg2 lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), robust points(25) graph(k)}{p_end}

{pstd}Refine appearance of surface graph using replay syntax; note that with replay the levels in the graph do not have to correspond to tests reported in table{p_end}

{phang2}. {stata weakiv10, graph(k) surfaceopt(xlabel(0 0.1 0.2) ylabel(-0.02 0.06)) level(95 90)}{p_end}

{pstd}As above but shaded contour graph instead of contour line graph and 3 confidence levels (95%, 90%, 80%).{p_end}

{phang2}. {stata weakiv10, graph(k) surfaceopt(xlabel(0 0.1 0.2) ylabel(-0.02 0.06)) level(95 90 80) contouropt(contourshade)}{p_end}


{marker misc_examples}{...}
{title:{it:estadd} and other miscellaneous examples}

{pstd}With estimation by {helpb ivregress}. Illustrates behavior of {it:estadd}.{p_end}

{phang2}. {stata ivregress 2sls cinf (unem = l(1/3).unem), vce(hac bartlett 2)}{p_end}
{phang2}. {stata weakiv10, estadd}{p_end}
{phang2}. {stata ereturn list}{p_end}
{phang2}. {stata weakiv10 ivregress 2sls cinf (unem = l(1/3).unem), vce(hac bartlett 2) estadd(myprefix_)}{p_end}
{phang2}. {stata ereturn list}{p_end}

{pstd}As a standalone estimation command. Illustrates behavior of {it:displaywald}.{p_end}

{phang2}. {stata weakiv10 ivreg2 cinf (unem = l(1/3).unem), rob bw(3) display}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:weakiv10} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(null)}}null hypothesis{p_end}
{synopt:{cmd:e(null1)}}null hypothesis for 1st endogenous regressor (2 endog case only){p_end}
{synopt:{cmd:e(null2)}}null hypothesis for 2nd endogenous regressor (2 endog case only){p_end}
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
{synopt:{cmd:e(wald_p)}}Wald test p-value{p_end}
{synopt:{cmd:e(wald_chi2)}}Wald test statistic{p_end}
{synopt:{cmd:e(points)}}number of points in grid used to estimate confidence sets{p_end}
{synopt:{cmd:e(points1)}}number of points in 1st (x) axis of grid (2 endog case only){p_end}
{synopt:{cmd:e(points1)}}number of points in 2nd (y) axis of grid (2 endog case only){p_end}
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

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(clr_cset)}}confidence set based on {it:CLR} test{p_end}
{synopt:{cmd:e(ar_cset)}}confidence set based on {it:AR} test{p_end}
{synopt:{cmd:e(k_cset)}}confidence set based on {it:K} test{p_end}
{synopt:{cmd:e(kj_cset)}}confidence set based on {it:K-J} test{p_end}
{synopt:{cmd:e(inexog)}}list of exogenous regressors{p_end}
{synopt:{cmd:e(exexog)}}list of excluded instruments{p_end}
{synopt:{cmd:e(endo)}}endogenous variable(s){p_end}
{synopt:{cmd:e(wald_cset)}}confidence set based on Wald test{p_end}
{synopt:{cmd:e(grid)}}range of grid used to estimate confidence sets{p_end}
{synopt:{cmd:e(model)}}{it:linear}, {it:ivprobit} or {it:ivtobit}{p_end}
{synopt:{cmd:e(level)}}default confidence level in percent used for tests of null = 100*(1-alpha){p_end}
{synopt:{cmd:e(levellist)}}confidence level(s) plotted in graphs{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(citable)}}table with test statistics, p-values, and rejection
indicators for every grid point over which hypotheses were tested{p_end}
{p2colreset}{...}


{marker acknowledgements}{...}
{title:Acknowledgements}
{pstd}
{opt weakiv10} builds on and extends the command {helpb rivest} by Finlay and Magnusson (2009).
The main differences and extensions are:
(a) extension to the 2-endogenous-regressor case;
(b) graphics options that allow the plotting of confidence intervals and rejection probabilities (1-endog-regressor),
and confidence regions and rejection surfaces (2-endog-regressors);
(c) support for a wider range of variance-covariance estimators in linear IV estimation;
including HAC (heteroskedastic-and autocorrelation-robust) and two-way clustering VCEs;
(d) support for LM versions of the tests;
(e) specification of models directly in the command line as well as obtaining specification from
a previously-estimated or stored model ({opt weakiv10} is an {it:eclass} command);
(f) minor changes in terminology and syntax.

{pstd}
The code in {opt weakiv10} for the closed-form solutions for confidence intervals
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
Mikusheva, A. 2003.
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
{title:Citation of weakiv10}

{pstd}{opt weakiv10} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Finlay, K., Magnusson, L.M., Schaffer, M.E. 2013.
weakiv10: Weak-instrument-robust tests and confidence intervals
for instrumental-variable (IV) estimation of linear, probit and tobit models.
{browse "http://ideas.repec.org/c/boc/bocode/s457910.html":http://ideas.repec.org/c/boc/bocode/xxxxx.html}{p_end}


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
Help:  {helpb condivreg}, {helpb ivreg2}, {helpb ivreg2h}, {helpb xtivreg2} {p_end}

