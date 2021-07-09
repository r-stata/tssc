{smcl}
{* *! version 1.0.16  15oct2019}{...}
{hline}
{cmd:help rlasso}{right: lassopack v1.3.1}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: rlasso} {hline 2}}Program for lasso and sqrt-lasso estimation with data-driven penalization{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{opt rlasso}
{it:depvar} {it:regressors}
[{it:weight}]
[{opt if} {it:exp}] [{cmd:in} {it:range}]
{bind:[ {cmd:,}}
{opt sqrt}
{opt par:tial(varlist)}
{opt pnotp:en(varlist)}
{opt nocons:tant}
{opt fe}
{opt noftools}
{opt rob:ust}
{opt cl:uster(var)}
{opt center}
{opt xdep:endent}
{opt numsim(int)}
{opt prestd}
{opt tol:opt(real)}
{opt tolp:si(real)}
{opt tolz:ero(real)}
{opt maxi:ter(int)}
{opt maxpsii:ter(int)}
{opt maxabsx}
{opt lassopsi}
{opt corrn:umber(int)}
{opt lalt:ernative}
{opt gamma(real)}
{opt c(real)}
{opt c0(real)}
{opt supscore}
{opt ssnumsim(int)}
{opt testonly}
{opt seed(real)}
{opt displayall}
{opt postall}
{opt ols}
{opt ver:bose}
{bind:{cmdab:vver:bose} ]}

{p 8 14 2}
Note: the {opt fe} option will take advantage of the {helpb rlasso##SG2016:ftools}
package (if installed) for the fixed-effects transform;
the speed gains using this package can be large.
See {rnethelp "http://fmwww.bc.edu/RePEc/bocode/f/ftools.sthlp":help ftools}
or click on {stata "ssc install ftools"} to install.

{synoptset 20}{...}
{synopthdr:General options}
{synoptline}
{synopt:{opt sqrt}}
use sqrt-lasso (default is standard lasso)
{p_end}
{synopt:{opt nocons:tant}}
suppress constant from regression (cannot be used with {opt aweights} or {opt pweights})
{p_end}
{synopt:{opt fe}}
fixed-effects model (requires data to be {helpb xtset})
{p_end}
{synopt:{opt noftools}}
do not use FTOOLS package for fixed-effects transform (slower; rarely used)
{p_end}
{synopt:{opt par:tial(varlist)}}
variables partialled-out prior to lasso estimation, including the constant (if present);
to partial-out just the constant, specify {opt partial(_cons)}
{p_end}
{synopt:{opt pnotp:en(varlist)}}
variables not penalized by lasso
{p_end}
{synopt:{opt rob:ust}}
lasso penalty loadings account for heteroskedasticity
{p_end}
{synopt:{opt cl:uster(var)}}
lasso penalty loadings account for clustering on variable {it:var}
{p_end}
{synopt:{opt center}}
center moments in heteroskedastic and cluster-robust loadings
{p_end}
{synopt:{opt lassopsi}}
use lasso or sqrt-lasso residuals to obtain penalty loadings (psi) (default is post-lasso)
{p_end}
{synopt:{opt corrn:umber(int)}}
number of high-correlation regressors used to obtain initial residuals; default=5; if =0, then {it:depvar} is used in place of residuals
{p_end}
{synopt:{opt prestd}}
standardize data prior to estimation (default is standardize during estimation via penalty loadings)
{p_end}
{synopt:{opt seed(real)}}
set Stata's random number seed prior to {opt xdep} and {opt supscore} simulations (default=leave state unchanged)
{p_end}

{synoptset 20}{...}
{synopthdr:Lambda}
{synoptline}
{synopt:{opt xdep:endent}}
penalty level is estimated depending on X
{p_end}
{synopt:{opt numsim(int)}}
number of simulations used for the X-dependent case (default=5000)
{p_end}
{synopt:{opt lalt:ernative}}
alternative (less sharp) lambda0 = 2c*sqrt(N)*sqrt(2*log(2*p/gamma))
(sqrt-lasso = replace 2c with c)
{p_end}
{synopt:{opt gamma(real)}}
"gamma" in lambda0 function (default = 0.1/log(N); cluster-lasso = 0.1/log(N_clust))
{p_end}
{synopt:{opt c(real)}}
"c" in lambda0 function (default = 1.1)
{p_end}
{synopt:{opt c0(real)}}
(rarely used) "c" in lambda0 function in first iteration only when iterating to obtain penalty loadings (default = 1.1)
{p_end}

{synoptset 20}{...}
{synopthdr:Optimization}
{synoptline}
{synopt:{opt tolo:pt(real)}}
tolerance for lasso shooting algorithm (default=1e-10)
{p_end}
{synopt:{opt tolp:si(real)}}
tolerance for penalty loadings algorithm (default=1e-4)
{p_end}
{synopt:{opt tolz:ero(real)}}
minimum below which coeffs are rounded down to zero (default=1e-4)
{p_end}
{synopt:{opt maxi:ter(int)}}
maximum number of iterations for the lasso shooting algorithm (default=10k)
{p_end}
{synopt:{opt maxpsii:ter(int)}}
maximum number of lasso-based iterations for penalty loadings (psi) algorithm (default=2)
{p_end}
{synopt:{opt maxabsx}}
(sqrt-lasso only) use max(abs(x_ij)) as initial penalty loadings as per Belloni et al. ({helpb rlasso##BCW2014:2014})
{p_end}

{synoptset 20}{...}
{synopthdr:Sup-score test}
{synoptline}
{synopt:{opt supscore}}
report sup-score test of statistical significance
{p_end}
{synopt:{opt testonly}}
report only sup-score test; do not estimate lasso regression
{p_end}
{synopt:{opt ssgamma(real)}}
test level for conservative critical value for the sup-score test (default = 0.05, i.e., 5% significance level)
{p_end}
{synopt:{opt ssnumsim(int)}}
number of simulations for sup-score test multiplier bootstrap (default=500; 0 => do not simulate)
{p_end}

{synoptset 20}{...}
{synopthdr:Display and post}
{synoptline}
{synopt:{opt displayall}}
display full coefficient vectors including unselected variables (default: display only selected, unpenalized and partialled-out)
{p_end}
{synopt:{opt postall}}
post full coefficient vector including unselected variables in e(b) (default: e(b) has only selected, unpenalized and partialled-out)
{p_end}
{synopt:{opt ols}}
post OLS coefs using lasso-selected variables in e(b) (default is lasso coefs)
{p_end}
{synopt:{opt ver:bose}}
show additional output
{p_end}
{synopt:{opt vver:bose}}
show even more output
{p_end}
{synopt:{opt dots}}
show dots corresponding to repetitions in simulations ({opt xdep} and {opt supscore})
{p_end}
{synoptline}
{p2colreset}{...}

{phang}
Postestimation:

{p 8 14 2}
{cmd:predict} {dtype} {newvar} {ifin}
{bind:[ {cmd:,}}
{opt xb}
{opt u}
{opt e}
{opt ue}
{opt xbu}
{opt resid}
{opt lasso}
{cmdab:noi:sily}
{bind:{cmd:ols} ]}

{phang}
{cmd:predict} is not currently supported after fixed-effects estimation.

{synoptset 20}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt xb}}
generate fitted values (default)
{p_end}
{synopt:{opt r:esiduals}}
generate residuals
{p_end}
{synopt:{opt e}}
generate overall error component e(it). 
Only after {opt fe}.
{p_end}
{synopt:{opt ue}}
generate combined residuals, i.e., 
u(i) + e(it). Only after {opt fe}.
{p_end}
{synopt:{opt xbu}}
prediction including fixed effect, i.e., 
a + xb + u(i). Only after {opt fe}.
{p_end}
{synopt:{opt u}}
fixed effect, i.e., 
u(i). Only after {opt fe}.
{p_end}
{synopt:{cmdab:noi:sily}}
displays beta used for prediction. 
{p_end}
{synopt:{opt lasso}}
use lasso coefficients for prediction (default is posted e(b) matrix)
{p_end}
{synopt:{opt ols}}
use OLS coefficients based on lasso-selected variables for prediction (default is posted e(b) matrix)
{p_end}
{synoptline}
{p2colreset}{...}

{phang}
Replay:

{p 8 14 2}
{opt rlasso}
{bind:[ {cmd:,}} {opt displayall} ]

{synoptset 20}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt displayall}}
display full coefficient vectors including unselected variables (default: display only selected, unpenalized and partialled-out)
{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
{opt rlasso} may be used with time-series or panel data,
in which case the data must be tsset or xtset first;
see help {helpb tsset} or {helpb xtset}.

{pstd}
{opt aweights} and {opt pweights} are supported; see help {helpb weights}.
{opt pweights} is equivalent to {opt aweights} + {opt robust}.

{pstd}
All varlists may contain time-series operators or factor variables; see help {helpb varlist}.


{title:Contents}

{phang}{help rlasso##description:Description}{p_end}
{phang}{help rlasso##estimation:Estimation methods}{p_end}
{phang}{help rlasso##loadings:Penalty loadings}{p_end}
{phang}{help rlasso##supscore:Sup-score test of joint significance}{p_end}
{phang}{help rlasso##computation:Computational notes}{p_end}
{phang}{help rlasso##misc:Miscellaneous}{p_end}
{phang}{help rlasso##versions:Version notes}{p_end}
{phang}{help rlasso##examples:Examples of usage}{p_end}
{phang}{help rlasso##saved_results:Saved results}{p_end}
{phang}{help rlasso##references:References}{p_end}
{phang}{help rlasso##website:Website}{p_end}
{phang}{help rlasso##installation:Installation}{p_end}
{phang}{help rlasso##acknowledgements:Acknowledgements}{p_end}
{phang}{help rlasso##citation:Citation of lassopack}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt rlasso} is a routine for estimating the coefficients of a lasso
or square-root lasso (sqrt-lasso) regression
where the lasso penalization is data-dependent
and where the number of regressors p may be large
and possibly greater than the number of observations.
The lasso (Least Absolute Shrinkage and Selection Operator, Tibshirani {helpb rlasso##Tib1996:1996})
is a regression method that uses regularization and the L1 norm.
{opt rlasso} implements a version of the lasso
that allows for heteroskedastic and clustered errors;
see Belloni et al. ({helpb rlasso##BCCH2012:2012}, {helpb rlasso##BCH2013:2013}, {helpb rlasso##BCH2014:2014}, {helpb rlasso##BCHK2016:2016}).

{pstd}
The default estimator implemented by {opt rlasso} is the lasso.
An alternative that does not involve estimating the error variance
is the square-root-lasso (sqrt-lasso) of Belloni et al. ({helpb rlasso##BCW2011:2011}, {helpb rlasso##BCW2014:2014}),
available with the {cmd:sqrt} option.

{pstd}
The lasso and sqrt-lasso estimators achieve sparse solutions:
of the full set of p predictors,
typically most will have coefficients set to zero and only s<<p will be non-zero.
The "post-lasso" estimator is OLS applied to the variables
with non-zero lasso or sqrt-lasso coefficients,
i.e., OLS using the variables selected by the lasso or sqrt-lasso.
The lasso/sqrt-lasso and post-lasso coefficients are stored
in {opt e(beta)} and {opt e(betaOLS)}, respectively.
By default, {opt rlasso} posts the lasso or sqrt-lasso coefficients in {opt e(b)}.
To post in {opt e(b)} the OLS coefficients based on lasso- or sqrt-lasso-selected variables,
use the {opt ols} option.

{title:Estimation methods}

{pstd}
{opt rlasso} solves the following problem

	min 1/N RSS + lambda/N*||Psi*beta||_1, 
	
{pstd}
where 

{synoptset 8}{...}
{synopt:RSS}
= sum(y(i)-x(i)'beta)^2 denotes the residual sum of squares,
{p_end}
{synopt:beta}
is a p-dimensional parameter vector,
{p_end}
{synopt:lambda}
is the overall penalty level,
{p_end}
{synopt:||.||_1}
denotes the L1-norm, i.e., sum_i(abs(a[i]));
{p_end}
{synopt:Psi}
is a p by p diagonal matrix of predictor-specific penalty loadings. Note that {opt rlasso} treats Psi as a row vector.
{p_end}
{synopt:N}
number of observations
{p_end}
{p2colreset}{...}

{pstd}
If the option {opt sqrt} is specified, {opt rlasso} estimates the sqrt-lasso estimator, which is defined as the solution to:

	min sqrt(1/N*RSS) + lambda/N*||Psi*beta||_1. 

{pstd}
Note: the above lambda differs from the definition used in parts of the lasso and elastic net literature; 
see for example the R package {it:glmnet} by Friedman et al. ({helpb rlasso##FHT2010:2010}).
The objective functions here follow the format of Belloni et al. ({helpb rlasso##BCW2011:2011}, {helpb rlasso##BCCH2012:2012}).
Specifically, {it:lambda(r)=2*N*lambda(GN)}
where {it:lambda(r)} is the penalty level used by {opt rlasso}
and {it:lambda(GN)} is the penalty level used by {it:glmnet}.

{pstd}
{cmd:rlasso} obtains the solutions to the lasso sqrt-lasso using coordinate descent algorithms. 
The algorithm was first proposed by Fu ({helpb rlasso##FU1998:1998}) for the lasso (then referred to as "shooting").
For further details of how the lasso and sqrt-lasso solutions are obtained,
see {helpb lasso2}.

{pstd}
{opt rlasso} first estimates the lasso penalty level
and then uses the coordinate descent algorithm to obtain the lasso coefficients.
For the homoskedastic case, a single penalty level lambda is applied;
in the heteroskedastic and cluster cases,
the penalty loadings vary across regressors.
The methods are discussed in detail in
Belloni et al. ({helpb rlasso##BCCH2012:2012}, {helpb rlasso##BCH2013:2013}, {helpb rlasso##BCW2014:2014}, {helpb rlasso##BCHK2016:2016})
and are described only briefly here.
For a detailed discussion of an R implementation of {opt rlasso},
see Spindler et al. ({helpb rlasso##SCH2016:2016}).

{pstd}
For compatibility with the wider lasso literature,
the documentation here uses "lambda" to refer to the penalty level that,
combined with the possibly regressor-specific penalty loadings,
is used with the estimation algorithm to obtain the lasso coefficients.
"lambda0" refers to the component of the overall lasso penalty level
that does not depend on the error variance.
Note that this terminology differs from that in the R implementation of {opt rlasso}
by Spindler et al. ({helpb rlasso##SCH2016:2016}).

{pstd}
The default lambda0 for the lasso is 2c*sqrt(N)*invnormal(1-gamma/(2p)),
where p is the number of penalized regressors
and c and gamma are constants
with default values of 1.1 and 0.1/log(N), respectively.
In the cluster-lasso (Belloni et al. {helpb rlasso##BCHK2016:2016})
the default gamma is 0.1/log(N_clust),
where N_clust is the number of clusters (saved in {opt e(N_clust)}).
The default lambda0s for the sqrt-lasso are the same except replace 2c with c.
The constant c>1.0 is a slack parameter;
gamma controls the confidence level.
The alternative formula lambda0 = 2c*sqrt(N)*sqrt(2*log(2p/gamma))
is available with the {opt lalt} option.
The constants c and gamma can be set
using the {opt c(real)} and {opt gamma(real)} options.
The {opt xdep} option is another alternative
that implements an "X-dependent" penalty level lambda0;
see Belloni and Chernozhukov ({helpb rlasso##BC2011:2011})
and Belloni et al. ({helpb rlasso##BCH2013:2013}) for discussion.

{pstd}
The default lambda for the lasso in the i.i.d. case is lambda0*rmse,
where rmse is an estimate of the standard deviation of the error variance.
The sqrt-lasso differs from the standard lasso in that
the penalty term lambda is pivotal in the homoskedastic case
and does not depend on the error variance.
The default for the sqrt-lasso in the i.i.d. case is
lambda=lambda0=c*sqrt(N)*invnormal(1-gamma/(2*p))
(note the absence of the factor of "2" vs. the lasso lambda).

{marker loadings}{...}
{title:Penalty loadings}

{pstd}
As is standard in the lasso literature,
regressors are standardized to have unit variance.
By default, standardization is achieved by incorporating the standard deviations
of the regressors into the penalty loadings.
In the default homoskedastic case,
the penalty loadings are the vector of standard deviations of the regressors.
The normalized penalty loadings are the penalty loadings
normalized by the SDs of the regressors.
In the homoskedastic case the normalized penalty loadings are a vector of 1s.
{opt rlasso} saves
the vector of penalty loadings,
the vector of normalized penalty loadings,
and the vector of SDs of the regressors X in {opt e(.)} macros.

{pstd}
Penalty loadings are constructed after the partialling-out of unpenalized regressors
and/or the FE (fixed-effects) transformation, if applicable.
A alternative to partialling-out unpenalized regressors with the {opt partial(varlist)} option
is to give them penalty loadings of zero with the {opt pnotpen(varlist)} option.
By the Frisch-Waugh-Lovell Theorem for the lasso (Yamada {helpb rlasso##Yam2017:2017}),
the estimated lasso coefficients are the same in theory (but see {helpb rlasso##notpen:below})
whether the unpenalized regressors are partialled-out or given zero penalty loadings,
so long as the same penalty loadings are used for the penalized regressors in both cases.
Note that the calculation of the penalty loadings
in both the {opt partial(.)} and {opt pnotpen(.)} cases
involves adjustments for the partialled-out variables.
This is different from the {opt lasso2} handling
of unpenalized variables specified in the {opt lasso2} option {opt notpen(.)},
where no such adjustment of the penalty loadings is made
(and is why the two no-penalization options are named differently).

{pstd}
Regressor-specific penalty loadings for the
heteroskedastic and clustered cases are derived
following the methods described in
Belloni et al. ({helpb rlasso##BCCH2012:2012}, {helpb rlasso##BCH2013:2013},
{helpb rlasso##BCH2014:2014}, {helpb rlasso##BCW2015:2015}, {helpb rlasso##BCHK2016:2016}).
The penalty loadings for the heteroskedastic-robust case
have elements of the form
sqrt[avg(x^2e^2)]/sqrt[avg(e^2)]
where x is a (demeaned) regressor, e is the residual,
and sqrt[avg(e^2)] is the root mean squared error;
the normalized penalty loadings have elements
sqrt[avg(x^2e^2)]/(sqrt[avg(x^2)]sqrt[avg(e^2)])
where the sqrt(avg(x^2) in the denominator is SD(x),
the standard deviation of x.
This corresponds to the presentation of
penalty loadings in Belloni et al. ({helpb rlasso##BCW2014:2014};
see Algorithm 1 but note that in their presentation,
the predictors x are assumed already to be standardized).
NB: in the presentation we use here,
the penalty loadings for the lasso and sqrt-lasso are the same;
what differs is the overall penalty term lambda.

{pstd}
The cluster-robust case is similar to the heteroskedastic case
except that numerator sqrt[avg(x^2e^2)] in the heteroskedastic case
is replaced by sqrt[avg(u_i^2)],
where (using the notation of the Stata manual's discussion of the {mansection P _robust:_robust} command)
u_i is the sum of x_ij*e_ij over the j members of cluster i;
see Belloni et al. ({helpb rlasso##BCHK2016:2016}).
Again in the presentation used here,
the cluster-lasso and cluster-sqrt-lasso penalty loadings are the same.
The unit vector is again the benchmark for the standardized penalty loadings.
NB: also following {helpb _robust},
the denominator of avg(u_i^2) and Tbar is (N_clust-1).

{pstd}
The {opt center} option centers the x_ij*e_ij terms
(or the cluster-lasso case, the u_i terms)
prior to calculating the penalty loadings.

{marker supscore}{...}
{title:Sup-score test of joint significance}

{pstd}
{opt rlasso} with the {opt supscore} option reports a test
of the null hypothesis H0: beta_1 = ... = beta_p = 0.
i.e., a test of the joint significance of the regressors
(or, alternatively, a test that H0: s=0;
of the full set of p regressors, none is in the true model).
The test follows Chernozhukov et al. ({helpb rlasso##CCK2013:2013}, Appendix M);
see also Belloni et al. ({helpb rlasso##BCCH2012:2012}, {helpb rlasso##BCH2013:2013}).
(The variables are assumed to be rescaled to be centered and with unit variance.)

{pstd}
If the null hypothesis is correct and the rest of the model is well-specified
(including the assumption that the regressors are orthogonal to the disturbance e),
then E(e*x_j) = E((y-beta_0)*x_j) = 0, j=1...p where beta_0 is the intercept.
The sup-score statistic is S=sqrt(N)*max_j(abs(avg((y-b_0)*x_j))/(sqrt(avg(((y-b_0)*x_j)^2)))), where:
(a) the numerator abs(avg((y-b_0)*x_j)) is the absolute value of the average score for regressor x_j
and b_0 is sample mean of y;
(b) the denominator sqrt(avg(((y-b_0)*x_j)^2)) is the sample standard deviation of the score;
(c) the statistic is sqrt(N) times the maximum across the p regressors of the ratio of (a) to (b).

{pstd}
The p-value for the sup-score test is obtained by a multiplier bootstrap procedure simulating the statistic W,
defined as W=sqrt(N)*max_j(abs(avg((y-b_0)*x_j*u))/(sqrt(avg(((y-b_0)*x_j)^2))))
where u is an iid standard normal variate independent of the data.
The {opt ssnumsim(int)} option controls the number of simulated draws (default=500);
{opt ssnumsim(0)} requests that the sup-score statistic is reported without a simulation-based p-value.
{opt rlasso} also reports a conservative critical value (asymptotic bound)
as per Belloni et al. ({helpb rlasso##BCCH2012:2012}, {helpb rlasso##BCCH2013:2013}),
defined as c*invnormal(1-gamma/(2p)); this can be set by the option {opt ssgamma(int)} (default = 0.05).

{marker computation}{...}
{title:Computational notes}

{pstd}
A computational alternative to the default of standardizing "on the fly"
(i.e., incorporating the standardization into the lasso penalty loadings)
is to standardize all variables to have unit variance
prior to computing the lasso coefficients.
This can be done using the {opt prestd} option.
The results are equivalent in theory.
The {opt prestd} option can lead to improved numerical precision
or more stable results in the case of difficult problems;
the cost is (a typically small) computation time required to standardize the data.

{marker notpen}{...}
{pstd}
Either the {opt partial(varlist)} option
or the {opt pnotpen(varlist)} option
can be used for variables that should not be penalized by the lasso.
The options are equivalent in theory (see above), but numerical results can differ
in practice because of the different calculation methods used.
Partialling-out variables can lead to improved numerical precision
or more stable results in the case of difficult problems
vs. specifying the variables as unpenalized,
but may be slower in terms of computation time.

{pstd}
By default the constant (if present) is not penalized
if there are no regressors being partialled out;
this is equivalent to mean-centering prior to estimation.
The exception to this is if {opt aweights} or {opt aweights} are specified,
in which case the constant is partialled-out.
The {opt partial(varlist)} option will automatically also partial out the constant (if present);
to partial out just the constant, specify {opt partial(_cons)}.
The within transformation implemented by the {opt fe} option automatically mean-centers the data;
the {opt nocons} option is redundant in this case and may not be specified with this option.

{pstd}
The {opt prestd} and {opt pnotpen(varlist)} vs. {opt partial(varlist)} options
can be used as simple checks for numerical stability
by comparing results that should be equivalent in theory.
If the results differ,
the values of the minimized objective functions
({cmd:e(pmse)} or {cmd:e(prmse)}) can be compared.

{pstd}
The {opt fe} fixed-effects option is equivalent to
(but computationally faster and more accurate than)
specifying unpenalized panel-specific dummies.
The fixed-effects ("within") transformation
also removes the constant as well as the fixed effects.
The panel variable used by the {opt fe} option
is the panel variable set by {helpb xtset}.
To use weights with fixed effects,
the {rnethelp "http://fmwww.bc.edu/RePEc/bocode/f/ftools.sthlp":ftools}
must be installed.

{marker misc}{...}
{title:Miscellaneous}

{pstd}
By default {opt rlasso} reports only the set of selected variables
and their lasso and post-lasso coefficients;
the omitted coefficients are not reported in the regression output.
The {opt postall} and {opt displayall} options
allow the full coefficient vector
(with coefficients of unselected variables set to zero)
to be either posted in {opt e(b)} or displayed as output.

{pstd}
{opt rlasso}, like the lasso in general,
accommodates possibly perfectly-collinear sets of regressors.
Stata's {helpb fvvarlist:factor variables} are supported by {opt rlasso}
(as well as by {helpb lasso2}).
Users therefore have the option of specifying as regressors
one or more complete sets of factor variables or interactions
with no base levels using the {it:ibn} prefix.
This can be interpreted as allowing {opt rlasso}
to choose the members of the base category.

{pstd}
The choice of whether to use {opt partial(varlist)} or {opt pnotpen(varlist)} will depend on
the circumstances faced by the user.
The {opt partial(varlist)} option can be helpful in dealing with
data that have scaling problems or collinearity issues;
in these cases it can be more accurate and/or achieve convergence faster
than the {opt pnotpen(varlist)} option.
The {opt pnotpen(varlist)} option will sometimes be faster
because it avoids using the pre-estimation transformation employed by {opt partial(varlist)}.
The two options can be used simultaneously
(but not for the same variables).

{pstd}
The treatment of standardization, penalization and partialling-out
in {opt rlasso} differs from that of {opt lasso2}.
In the {opt rlasso} treatment,
standardization incorporates the partialling-out of regressors listed in
the {opt pnotpen(varlist)} list as well as those in the {opt partial(varlist)} list.
This is in order to maintain the equivalence of the lasso estimator
irrespective of which option is used for unpenalized variables
(see the discussion of the Frisch-Waugh-Lovell Theorem for the lasso above).
In the {opt lasso2} treatment,
standardization takes place after the partialling-out
of only the regressors listed
in the {opt notpen(varlist)} option.
In other words,
{opt rlasso} adjusts the penalty loadings for any unpenalized variables;
{opt lasso2} does not.
For further details, see {helpb lasso2}.

{pstd}
The initial overhead for fixed-effects estimation and/or partialling out
and/or pre-estimation standardization
(creating temporary variables and then transforming the data)
can be noticable for large datasets.
For problems that involve looping over data,
users may wish to first transform the data by hand.

{pstd}
If a small number of correlations is set using the {opt corrnum(int)} option,
users may want to increase the number of penalty loadings iterations
from the default of 2 to something higher using the {opt maxpsiiter(int)} option.

{pstd}
The sup-score p-value is obtained by simulation,
which can be time-consuming for large datasets.
To skip this and use only the conservative (asymptotic bound) critical value,
set the number of simulations to zero with the {opt ssnumsim(0)} option.

{marker versions}{...}
{title:Version notes}

{pstd}
Detailed version notes can be found inside the ado files
{stata "viewsource rlasso.ado":rlasso.ado} and {stata "viewsource lassoutils.ado":lassoutils.ado}.
Noteworthy changes appear below.

{pstd}
In versions of {opt lassoutils} prior to 1.1.01 (8 Nov 2018),
the very first iteration to obtain penalty loadings set the constant c=0.55.
This was dropped in version 1.1.01, and the constant c is unchanged in all iterations.
To replicate the previous behavior of {opt rlasso}, use the {opt c0(real)} option.
For example, with the default value of c=1.1, to replicate the earlier behavior use {opt c0(0.55)}.

{pstd}
In versions of {opt lassoutils} prior to 1.1.01 (8 Nov 2018),
the sup-score test statistic S was N*max_j rather than sqrt(N)*max_j
as in Chernozhukov et al. ({helpb rlasso##CCK2013:2013}),
and similarly for the simulated statistic W.


{marker examples}{...}
{title:Examples using prostate cancer data from Hastie et al. ({helpb rlasso##HTF2009:2009})}

{pstd}Load prostate cancer data.{p_end}
{phang2}. {stata "clear"}{p_end}
{phang2}. {stata "insheet using https://web.stanford.edu/~hastie/ElemStatLearn/datasets/prostate.data, tab"}{p_end}

{pstd}Estimate lasso using data-driven lambda penalty; default homoskedasticity case.{p_end}
{phang2}. {stata "rlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45"}{p_end}

{pstd}Use square-root lasso instead.{p_end}
{phang2}. {stata "rlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, sqrt"}{p_end}

{pstd}Illustrate relationships between lambda, lambda0 and penalty loadings:{p_end}

{pstd}Basic usage: homoskedastic case, lasso{p_end}
{phang2}. {stata "rlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45"}{p_end}
{pstd}lambda=lambda0*SD is lasso penalty; incorporates the estimate of the error variance{p_end}
{pstd}default lambda0 is 2c*sqrt(N)*invnormal(1-gamma/(2*p)){p_end}
{phang2}. {stata "di e(lambda)"}{p_end}
{phang2}. {stata "di e(lambda0)"}{p_end}
{pstd}In the homoskedastic case, penalty loadings are the vector of SDs of penalized regressors{p_end}
{phang2}. {stata "mat list e(ePsi)"}{p_end}
{pstd}...and the standardized penalty loadings are a vector of 1s.{p_end}
{phang2}. {stata "mat list e(sPsi)"}{p_end}

{pstd}Heteroskedastic case, lasso{p_end}
{phang2}. {stata "rlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, robust"}{p_end}
{pstd}lambda and lambda0 are the same as for the homoskedastic case{p_end}
{phang2}. {stata "di e(lambda)"}{p_end}
{phang2}. {stata "di e(lambda0)"}{p_end}
{pstd}Penalty loadings account for heteroskedasticity as well as incorporating SD(x){p_end}
{phang2}. {stata "mat list e(ePsi)"}{p_end}
{pstd}...and the standardized penalty loadings are not a vector of 1s.{p_end}
{phang2}. {stata "mat list e(sPsi)"}{p_end}

{pstd}Homoskedastic case, sqrt-lasso{p_end}
{phang2}. {stata "rlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, sqrt"}{p_end}
{pstd}with the sqrt-lasso, the default lambda=lambda0=c*sqrt(N)*invnormal(1-gamma/(2*p));{p_end}
{pstd}note the difference by a factor of 2 vs. the standard lasso lambda0{p_end}
{phang2}. {stata "di e(lambda)"}{p_end}
{phang2}. {stata "di e(lambda0)"}{p_end}

{pstd}{opt rlasso} vs. {opt lasso2} (if installed){p_end}
{phang2}. {stata "rlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45"}{p_end}
{pstd}lambda=lambda0*SD is lasso penalty; incorporates the estimate of the error variance{p_end}
{pstd}default lambda0 is 2c*sqrt(N)*invnormal(1-gamma/(2*p)){p_end}
{phang2}. {stata "di %8.5f e(lambda)"}{p_end}
{pstd}Replicate {opt rlasso} estimates using {opt rlasso} lambda and {opt lasso2}{p_end}
{phang2}. {stata "lasso2 lpsa lcavol lweight age lbph svi lcp gleason pgg45, lambda(44.34953)"}{p_end}

{title:Examples using data from Acemoglu-Johnson-Robinson ({helpb rlasso##AJR2001:2001})}

{pstd} Load and reorder AJR data for Table 6 and Table 8 (datasets need to be in current directory).{p_end}
{phang2}. {stata "clear"}{p_end}
{phang2}. {browse "https://economics.mit.edu/files/5138":(click to download maketable6.zip from economics.mit.edu)}{p_end}
{phang2}. {stata "unzipfile maketable6"}{p_end}
{phang2}. {browse "https://economics.mit.edu/files/5140":(click to download maketable8.zip from economics.mit.edu)}{p_end}
{phang2}. {stata "unzipfile maketable8"}{p_end}
{phang2}. {stata "use maketable6"}{p_end}
{phang2}. {stata "merge 1:1 shortnam using maketable8"}{p_end}
{phang2}. {stata "keep if baseco==1"}{p_end}
{phang2}. {stata "order shortnam logpgp95 avexpr lat_abst logem4 edes1975 avelf, first"}{p_end}
{phang2}. {stata "order indtime euro1900 democ1 cons1 democ00a cons00a, last"}{p_end}

{pstd}Alternatively, load AJR data from our website (no manual download required):{p_end}
{phang2}. {stata "clear"}{p_end}
{phang2}. {stata "use https://statalasso.github.io/dta/AJR.dta"}{p_end}

{pstd}Basic usage:{p_end}
{phang2}. {stata "rlasso logpgp95 lat_abst edes1975 avelf temp* humid* steplow-oilres"}{p_end}

{pstd}Heteroskedastic-robust penalty loadings:{p_end}
{phang2}. {stata "rlasso logpgp95 lat_abst edes1975 avelf temp* humid* steplow-oilres, robust"}{p_end}

{pstd}Partialling-out vs. non-penalization:{p_end}
{phang2}. {stata "rlasso logpgp95 lat_abst edes1975 avelf temp* humid* steplow-oilres, partial(lat_abst)"}{p_end}
{phang2}. {stata "rlasso logpgp95 lat_abst edes1975 avelf temp* humid* steplow-oilres, pnotpen(lat_abst)"}{p_end}

{pstd}Request sup-score test (H0: all betas=0):{p_end}
{phang2}. {stata "rlasso logpgp95 lat_abst edes1975 avelf temp* humid* steplow-oilres, supscore"}{p_end}

{title:Examples using data from Angrist-Krueger ({helpb rlasso##AK1991:1991})}

{pstd}Load AK data and rename variables (dataset needs to be in current directory).
NB: this is a large dataset (330k observations) and estimations may take
some time to run on some installations.{p_end}
{phang2}. {stata "clear"}{p_end}
{phang2}. {browse "https://economics.mit.edu/files/397":(click to download asciiqob.zip from economics.mit.edu)}{p_end}
{phang2}. {stata "unzipfile asciiqob.zip"}{p_end}
{phang2}. {stata "infix lnwage 1-9 edu 10-20 yob 21-31 qob 32-42 pob 43-53 using asciiqob.txt"}{p_end}

{pstd}Alternatively, get data from our website source (no unzipping needed):{p_end}
{phang2}. {stata "use https://statalasso.github.io/dta/AK91.dta"}{p_end}

{pstd}xtset data by place of birth (state):{p_end}
{phang2}. {stata "xtset pob"}{p_end}

{pstd}State (place of birth) fixed effects; regressors are year of birth, quarter of birth and QOBxYOB.{p_end}
{phang2}. {stata "rlasso edu i.yob# #i.qob, fe"}{p_end}

{pstd}As above but explicit penalized state dummies and all categories (no base category) for all factor vars.{p_end}
{pstd}Note that the (unpenalized) constant is reported.{p_end}
{phang2}. {stata "rlasso edu ibn.yob# #ibn.qob ibn.pob"}{p_end}

{pstd}State fixed effects; regressors are YOB, QOB and QOBxYOB; cluster on state.{p_end}
{phang2}. {stata "rlasso edu i.yob# #i.qob, fe cluster(pob)"}{p_end}

{title:Example using data from Belloni et al. ({helpb rlasso##BCH2015:2015})}

{pstd}Load dataset on eminent domain (available at journal website).{p_end}
{phang2}. {stata "clear"}{p_end}
{phang2}. {stata "import excel using CSExampleData.xlsx, first"}{p_end}

{pstd}Settings used in Belloni et al. ({helpb rlasso##BCH2015:2015}) - results as in text discussion (p=147):{p_end}
{phang2}. {stata "rlasso NumProCase Z* BA BL DF, robust lalt corrnum(0) maxpsiiter(100) c0(0.55)"}{p_end}
{phang2}. {stata "di e(p)"}{p_end}

{pstd}Settings used in Belloni et al. ({helpb rlasso##BCH2015:2015}) - results as in journal replication file (p=144):{p_end}
{phang2}. {stata "rlasso NumProCase Z*, robust lalt corrnum(0) maxpsiiter(100) c0(0.55)"}{p_end}
{phang2}. {stata "di e(p)"}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:rlasso} saves the following in {cmd:e()}:

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters in cluster-robust estimation{p_end}
{synopt:{cmd:e(N_g)}}number of groups in fixed-effects model{p_end}
{synopt:{cmd:e(p)}}number of penalized regressors in model{p_end}
{synopt:{cmd:e(s)}}number of selected regressors{p_end}
{synopt:{cmd:e(s0)}}number of selected and unpenalized regressors including constant (if present){p_end}
{synopt:{cmd:e(lambda0)}}penalty level excluding rmse (default = 2c*sqrt(N)*invnormal(1-gamma/(2*p))){p_end}
{synopt:{cmd:e(lambda)}}lasso: penalty level including rmse (=lambda0*rmse); sqrt-lasso: lambda=lambda0{p_end}
{synopt:{cmd:e(slambda)}}standardized lambda; equiv to lambda used on standardized data; lasso: slambda=lambda/SD(depvar); sqrt-lasso: slambda=lambda0{p_end}
{synopt:{cmd:e(c)}}parameter in penalty level lambda{p_end}
{synopt:{cmd:e(gamma)}}parameter in penalty level lambda{p_end}
{synopt:{cmd:e(niter)}}number of iterations for shooting algorithm{p_end}
{synopt:{cmd:e(maxiter)}}max number of iterations for shooting algorithm{p_end}
{synopt:{cmd:e(npsiiter)}}number of iterations for loadings algorithm{p_end}
{synopt:{cmd:e(maxpsiiter)}}max iterations for loadings algorithm{p_end}
{synopt:{cmd:e(rmse)}}rmse using lasso resduals{p_end}
{synopt:{cmd:e(rmseOLS)}}rmse using post-lasso residuals{p_end}
{synopt:{cmd:e(pmse)}}minimized objective function (penalized mse, standard lasso only){p_end}
{synopt:{cmd:e(prmse)}}minimized objective function (penalized rmse, sqrt-lasso only){p_end}
{synopt:{cmd:e(cons)}}=1 if constant in model, =0 otherwise{p_end}
{synopt:{cmd:e(fe)}}=1 if fixed-effects model, =0 otherwise{p_end}
{synopt:{cmd:e(center)}}=1 if moments have been centered{p_end}
{synopt:{cmd:e(supscore)}}sup-score statistic{p_end}
{synopt:{cmd:e(supscore_p)}}sup-score p-value{p_end}
{synopt:{cmd:e(supscore_cv)}}sup-score critical value (asymptotic bound){p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:e(cmd)}}rlasso{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(varX)}}all regressors{p_end}
{synopt:{cmd:e(varXmodel)}}penalized regressors{p_end}
{synopt:{cmd:e(pnotpen)}}unpenalized regressors{p_end}
{synopt:{cmd:e(partial)}}partialled-out regressors{p_end}
{synopt:{cmd:e(selected)}}selected and penalized regressors{p_end}
{synopt:{cmd:e(selected0)}}all selected regressors including unpenalized and constant (if present){p_end}
{synopt:{cmd:e(method)}}lasso or sqrt-lasso{p_end}
{synopt:{cmd:e(estimator)}}lasso, sqrt-lasso or post-lasso ols posted in e(b){p_end}
{synopt:{cmd:e(robust)}}heteroskedastic-robust penalty loadings{p_end}
{synopt:{cmd:e(clustvar)}}variable defining clusters for cluster-robust penalty loadings{p_end}
{synopt:{cmd:e(ivar)}}variable defining groups for fixed-effects model{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:e(b)}}posted coefficient vector{p_end}
{synopt:{cmd:e(beta)}}lasso or sqrt-lasso coefficient vector{p_end}
{synopt:{cmd:e(betaOLS)}}post-lasso coefficient vector{p_end}
{synopt:{cmd:e(betaAll)}}full lasso or sqrt-lasso coefficient vector including omitted, factor base variables, etc.{p_end}
{synopt:{cmd:e(betaAllOLS)}}full post-lasso coefficient vector including omitted, factor base variables, etc.{p_end}
{synopt:{cmd:e(ePsi)}}estimated penalty loadings{p_end}
{synopt:{cmd:e(sPsi)}}standardized penalty loadings (vector of 1s in homoskedastic case{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}
{p2colreset}{...}


{marker references}{...}
{title:References}

{marker AJR2001}{...}
{phang}
Acemoglu, D., Johnson, S. and Robinson, J.A. 2001.
The colonial origins of comparative development: An empirical investigation.
{it:American Economic Review}, 91(5):1369-1401.
{browse "https://economics.mit.edu/files/4123":https://economics.mit.edu/files/4123}
{p_end}

{marker AK1991}{...}
{phang}
Angrist, J. and Kruger, A. 1991.
Does compulsory school attendance affect schooling and earnings?
{it:Quarterly Journal of Economics} 106(4):979-1014.
{browse "http://www.jstor.org/stable/2937954":http://www.jstor.org/stable/2937954}
{p_end}

{marker BC2011}{...}
{phang}
Belloni, A. and Chernozhukov, V. 2011.
High-dimensional sparse econometric models: An introduction.
In Alquier, P., Gautier E., and Stoltz, G. (eds.),
Inverse problems and high-dimensional estimation.
Lecture notes in statistics, vol. 203.
Springer, Berlin, Heidelberg.
{browse "https://arxiv.org/pdf/1106.5242.pdf":https://arxiv.org/pdf/1106.5242.pdf}
{p_end}

{marker BCW2011}{...}
{phang}
Belloni, A., Chernozhukov, V. and Wang, L. 2011.
Square-root lasso: Pivotal recovery of sparse signals via conic programming.
{it:Biometrika} 98:791-806.
{browse "https://doi.org/10.1214/14-AOS1204"}
{p_end}

{marker BCCH2012}{...}
{phang}
Belloni, A., Chen, D., Chernozhukov, V. and Hansen, C. 2012.
Sparse models and methods for optimal instruments with an application to eminent domain.
{it:Econometrica} 80(6):2369-2429.
{browse "http://onlinelibrary.wiley.com/doi/10.3982/ECTA9626/abstract"}
{p_end}

{marker BCH2013}{...}
{phang}
Belloni, A., Chernozhukov, V. and Hansen, C. 2013.
Inference for high-dimensional sparse econometric models.
In {it:Advances in Economics and Econometrics: 10th World Congress}, Vol. 3: Econometrics,
Cambridge University Press: Cambridge, 245-295.
{browse "http://arxiv.org/abs/1201.0220"}
{p_end}

{marker BCH2014}{...}
{phang}
Belloni, A., Chernozhukov, V. and Hansen, C. 2014.
Inference on treatment effects after selection among high-dimensional controls.
{it:Review of Economic Studies} 81:608-650.
{browse "https://doi.org/10.1093/restud/rdt044"}
{p_end}

{marker BCH2015}{...}
{phang}
Belloni, A., Chernozhukov, V. and Hansen, C. 2015.
High-dimensional methods and inference on structural and treatment effects.
{it:Journal of Economic Perspectives} 28(2):29-50.
{browse "http://www.aeaweb.org/articles.php?doi=10.1257/jep.28.2.29"}
{p_end}

{marker BCHK2016}{...}
{phang}
Belloni, A., Chernozhukov, V., Hansen, C. and Kozbur, D. 2016.
Inference in high dimensional panel models with an application to gun control.
{it:Journal of Business and Economic Statistics} 34(4):590-605.
{browse "http://amstat.tandfonline.com/doi/full/10.1080/07350015.2015.1102733"}
{p_end}

{marker BCW2014}{...}
{phang}
Belloni, A., Chernozhukov, V. and Wang, L. 2014.
Pivotal estimation via square-root-lasso in nonparametric regression.
{it:Annals of Statistics} 42(2):757-788.
{browse "https://doi.org/10.1214/14-AOS1204"}
{p_end}

{marker CCK2013}{...}
{phang}
Chernozhukov, V., Chetverikov, D. and Kato, K. 2013.
Gaussian approximations and multiplier bootstrap for maxima
of sums of high-dimensional random vectors.
{it:Annals of Statistics} 41(6):2786-2819.
{browse "https://projecteuclid.org/euclid.aos/1387313390"}
{p_end}

{marker SG2016}{...}
{phang}
Correia, S. 2016.
FTOOLS: Stata module to provide alternatives to common Stata commands optimized for large datasets.
{browse "https://ideas.repec.org/c/boc/bocode/s458213.html"}
{p_end}

{marker FHT2010}{...}
{phang}
Friedman, J., Hastie, T., & Tibshirani, R. (2010).
Regularization Paths for Generalized Linear Models via Coordinate Descent.
{it:Journal of Statistical Software} 33(1), 1\9622. 
{browse "https://doi.org/10.18637/jss.v033.i01"}
{p_end}

{marker FU1998}{...}
{phang}
Fu, W.J.  1998.
Penalized regressions: The bridge versus the lasso.
{it:Journal of Computational and Graphical Statistics} 7(3):397-416.
{browse "http://www.tandfonline.com/doi/abs/10.1080/10618600.1998.10474784"}
{p_end}

{marker HTF2009}{...}
{phang}
Hastie, T., Tibshirani, R. and Friedman, J. 2009.
{it:The elements of statistical learning} (2nd ed.).
New York: Springer-Verlag.
{browse "https://web.stanford.edu/~hastie/ElemStatLearn/":https://web.stanford.edu/~hastie/ElemStatLearn/}
{p_end}

{marker SCH2016}{...}
{phang}
Spindler, M., Chernozhukov, V. and Hansen, C. 2016.
High-dimensional metrics.
{browse "https://cran.r-project.org/package=hdm":https://cran.r-project.org/package=hdm}.
{p_end}

{marker Tib1996}{...}
{phang}
Tibshirani, R. 1996.
Regression shrinkage and selection via the lasso.
{it:Journal of the Royal Statistical Society. Series B (Methodological)} 58(1):267-288.
{browse "https://doi.org/10.2307/2346178"}
{p_end}

{marker Yam2017}{...}
{phang}
Yamada, H. 2017.
The Frisch-Waugh-Lovell Theorem for the lasso and the ridge regression.
{it:Communications in Statistics - Theory and Methods} 46(21):10897-10902.
{browse "http://dx.doi.org/10.1080/03610926.2016.1252403"}
{p_end}

{marker website}{title:Website}

{pstd}
Please check our website {browse "https://statalasso.github.io/"} for more information. 

{marker installation}{title:Installation}

{pstd}
To get the latest stable version of {it:lassopack} from our website, 
check the installation instructions at {browse "https://statalasso.github.io/installation/"}.
We update the stable website version more frequently than the SSC version.

{pstd}
To verify that {it:lassopack} is correctly installed, 
click on or type {stata "whichpkg lassopack"} (which requires {helpb whichpkg} 
to be installed; {stata "ssc install whichpkg"}).

{marker acknowledgements}{title:Acknowledgements}

{pstd}Thanks to Alexandre Belloni for providing Matlab code for the square-root-lasso
and to Sergio Correia for advice on the use of the FTOOLS package.{p_end}


{marker citation}{...}
{title:Citation of rlasso}

{pstd}{opt rlasso} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Ahrens, A., Hansen, C.B., Schaffer, M.E. 2018.
LASSOPACK: Stata module for lasso, square-root lasso, elastic net, ridge, adaptive lasso estimation and cross-validation
{browse "http://ideas.repec.org/c/boc/bocode/s458458.html"}{p_end}

{phang}Ahrens, A., Hansen, C.B., Schaffer, M.E. 2019.
lassopack: Model selection and prediction with regularized regression in Stata
{browse "https://arxiv.org/abs/1901.05397"}{p_end}

{title:Authors}

	Achim Ahrens, Public Policy Group, ETH Zurich, Switzerland
	achim.ahrens@gess.ethz.ch
	
	Christian B. Hansen, University of Chicago, USA
	Christian.Hansen@chicagobooth.edu

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk


{title:Also see}

{p 7 14 2}
Help:  {helpb lasso2}, {helpb cvlasso}, {helpb lassologit}, {help pdslasso}, {help ivlasso} (if installed){p_end}
