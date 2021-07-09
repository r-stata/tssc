{smcl}
{* *! version 1.0.0  2july2020}{...}
{vieweralsosee "ranktest" "help ranktest"}{...}
{vieweralsosee "xtivreg" "help xtivreg"}{...}
{vieweralsosee "xthtaylor" "help xthtaylor"}{...}
{vieweralsosee "[if installed] overid" "help overid"}{...}
{vieweralsosee "[if installed] ivreg2" "help ivreg2"}{...}
{vieweralsosee "[if installed] xtivreg2" "help xtivreg2"}{...}
{vieweralsosee "[if installed] xtabond2" "help xtabond2"}{...}
{vieweralsosee "[if installed] xtdpdgmm" "help xtdpdgmm"}{...}
{viewerjumpto "Syntax" "underid##syntax"}{...}
{viewerjumpto "Description" "underid##description"}{...}
{viewerjumpto "Options" "underid##options"}{...}
{viewerjumpto "Classical (unrobust) tests" "underid##unrobust_tests"}{...}
{viewerjumpto "Robust tests" "underid##robust_tests"}{...}
{viewerjumpto "Underidentification examples" "underid##underidexamples"}{...}
{viewerjumpto "Overidentification examples" "underid##overidexamples"}{...}
{viewerjumpto "Stored results" "underid##results"}{...}
{viewerjumpto "References" "underid##references"}{...}
{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi: underid} {hline 2}}Postestimation tests of under- and over-identification after linear IV estimation{p_end}
{p2colreset}{...}


{title:Contents}

{p 4}{help underid##syntax:Syntax}{p_end}
{p 4}{help underid##description:Description}{p_end}
{p 4}{help underid##options:Options}{p_end}
{p 4}{help underid##unrobust_tests:Classical (unrobust) tests}{p_end}
{p 4}{help underid##robust_tests:Robust tests}{p_end}
{p 4}{help underid##underidexamples:Underidentification examples}{p_end}
{p 4}{help underid##overidexamples:Overidentification examples}{p_end}
{p 4}{help underid##results:Stored results}{p_end}
{p 4}{help underid##references:References}{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{opt underid}
[{cmd:,} {it:options}]

{synoptset 22}{...}
{synopthdr:Supported estimators}
{synoptline}
{synopt:{help ivregress}}instrumental variables (IV/2SLS), LIML, GMM{p_end}
{synopt:{help ivreg2}}instrumental variables (IV/2SLS), LIML, 2-step GMM, CUE GMM{p_end}
{synopt:{help xtivreg}}panel IV for random effects (G2SLS and EC2SLS), fixed effects, between effects, first differences{p_end}
{synopt:{help xtivreg2}}panel IV (IV/2SLS, LIML, 2-step GMM, CUE GMM) for fixed effects, between effects, first differences{p_end}
{synopt:{help xtabond2}}dynamic panel data models (must be called with the {opt svmat} option){p_end}
{synopt:{help xtdpdgmm}}dynamic panel data models{p_end}
{synopt:{help xthtaylor}}panel IV Hausman-Taylor and Amemiya-MaCurdy random-effects estimators{p_end}
{synoptline}

{p2col 3 4 4 2:Tests}{p_end}
{synopt :{it:(default)}}Anderson canonical correlations test (iid default){p_end}
{synopt :{opt jcue}}Cragg-Donald test, J statistic from GMM CUE (robust default){p_end}
{synopt :{opt jgmm2s}}J statistic from 2-step GMM (robust) or 2SLS (iid){p_end}
{synopt :{opt j2l}}J2L statistic (robust only){p_end}
{synopt :{opt j2lr}}J2LR statistic (robust only){p_end}
{synopt :{opt kp}}Kleibergen-Paap test (robust only){p_end}

{p2col 3 4 4 2:Main options}{p_end}
{synopt :{opt underid}}underidentication test (default){p_end}
{synopt :{opt overid}}overidentification test{p_end}
{synopt :{opt sw}}Sanderson-Windmeijer underidentification tests for endogenous regressors{p_end}
{synopt :{opt wald}}report Wald-type instead of default LM-type test{p_end}
{synopt :{opt lr}}report LR instead of default LM-type test (Anderson test only){p_end}
{synopt :{opt center}}specifies that the moments in the robust VCE are centered so that they have mean zero
(will override no centering in original estimation){p_end}
{synopt :{opt nocenter}}specifies that the moments in the robust VCE should not be centered
(will override centering in original estimation){p_end}
{synopt :{opt small}}use a small-sample adjustment: instead of N, for LM-type tests use N-K1, and for Wald-type tests use N-L-K1,
where L is the number of instruments Z and K1 is the number of exogenous regressors including the constant{p_end}

{p2col 3 4 4 2:VCE options}{p_end}
{synopt :{it:(default)}}take VCE options from IV estimation{p_end}
{synopt :{opt vceopt(VCE options)}:}override IV VCE specification with user-specified option list selected from the following:{p_end}
{synopt :{bind:  }{opt iid}}report tests using unrobust (standard) VCE that assumes iid{p_end}
{synopt :{bind:  }{cmdab:rob:ust}}report tests that are robust to arbitrary heteroskedasticity{p_end}
{synopt :{bind:  }{opt cluster(varlist)}}report tets that are robust to heteroskedasticity and within-cluster correlation; 2-way clustering is supported{p_end}
{synopt :{bind:  }{opt bw(#)}}report tests that are autocorrelation-consistent (AC)
or (with the {opt robust} option) heteroskedasticity- and autocorrelation-consistent (HAC),
with bandwidth equal to #{p_end}
{synopt :{bind:  }{opt kernel(string)}}specifies the kernel to be used for AC and HAC covariance estimation (default=Bartlett a.k.a. Newey-West){p_end}
{p 2}For more details on available VCE options, see help {help avar} or {help ivreg2}.{p_end}

{p2col 3 4 4 2:Rarely-used options}{p_end}
{synopt :{opt rkopt(options)}}additional options to pass to {cmd:ranktest}, e.g., optimization settings; see {help ranktest}{p_end}
{synopt :{opt noi:sily}}report output of internal call to {help ranktest}{p_end}
{synopt :{opt noreport}}suppress detailed output relating to {help xtabond2}{p_end}
{synopt :{opt usemeans}}(after {help xtivreg} or {help xthtaylor} only) use means instead of demeaned exogenous regressors as IVs{p_end}
{synopt :{opt repstata}}(after {help xtivreg} or {help xthtaylor} only) use Stata method for exogenous regressors in random effects models{p_end}
{synopt :{opt maineq(estimator)}}(requires {help ivreg2}) re-estimate and report main equation; {cmd:estimator} may be {opt iv}, {opt gmm2s} or {opt cue}{p_end}


{p 2 2 2}{cmd:underid} requires the Stata module {cmd:ranktest}, version 02.0.03 or higher;
click {stata ssc install ranktest :here} to install
or type "ssc install ranktest" from inside Stata.{p_end}

{p 2 2 2}Additional robust covariance options accepted by {help avar} may be included as options to {opt underid}.
See help {help avar}, {help ivreg2} or {help ranktest} for details.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:underid} reports tests of underidentification and overidentification
after estimation of single-equation linear instrumental variables (IV) models,
including static and dynamic panel data models.
{p_end}

{pstd}
Denote by y the dependent variable in a linear IV equation,
Y the set of K endogenous regressors,
Z the set of L excluded instruments,
and X any exogenous regressors ("included instruments") including the constant.
The full model is y = Y*beta + X*delta + e.
We assume that X is partialled out of y, Y and Z;
this leads to simpler expressions (and is also how {cmd:underid} and {cmd:ranktest} work internally).
Denote the first-stage coefficients by Pi and their OLS estimates by Pihat = inv(Z'Z)*Z'Y.
The rank condition required for identification is that E(Z'Y) is full column rank.
By default, {cmd:underid} reports a test of the rank of E(Z'Y)
or, equivalently, a test of the rank of Pi.
The null hypothesis is H0:rank(Pi)=K-1, i.e., rank reduction of 1.
The test statistic reported is distributed as chi-square with (L-K+1) degrees of freedom
(see help {help ranktest}).
Rejection (a large test statistic) indicates that the model (beta) is identified
(the excluded instruments are "relevant").
Failure to reject indicates that the model is underidentified.
{p_end}

{pstd}
The same tests of underidentification apply
whether the model is estimated by IV (instrumental variables),
GMM (generalized method of moments)
or LIML (limited information maximum likelihood).
The tests can also be applied to, e.g., static or dynamic panel data models.
The way such panel data models are estimated is that
the data are first transformed by mean-differencing (e.g., fixed effects estimators),
quasi-differencing (e.g., random effects estimators)
or first-differencing (e.g., dynamic panel data estimators),
any required instrument sets constructed,
and then the model is estimated using linear IV or GMM on the transformed data.
After estimation by an IV/GMM panel data model,
{cmd:underid} performs these operations to obtain the same transformed data
and then reports a test of the rank of E(Z'Y)
where Z and Y are the transformed instruments and endogenous regressors, respectively.
{p_end}

{pstd}
Overidentification tests in IV/GMM models are available when L>K,
i.e., the model is overidentified.
The usual intepretation is that the null hypothesis is H0:E(Ze)=0,
i.e., that the excluded instruments Z are orthogonal to the disturbance e.
Rejection (a large test statistic) indicates that the orthogonality conditions are not satisfied
and the model is misspecified.
{p_end}

{pstd}
Overidentification and underidentification are closely connected.
Specifically, consider the model above
where the exogenous regressors X have already been partialled out: {bind:y = Y*beta + e}.
Windmeijer (2018) shows that a test for underidentification in this model
can be interpreted as a test for overidentification
in the auxiliary specification y1 = Y2*delta + u,
where (y1 Y2) = Y.
{p_end}

{pstd}
{cmd:underid} works by assembling the sets of variables (dependent, endogenous, exogenous, instruments)
and then calling {help ranktest} to obtain the appropriate test statistic.
The {opt maineq(estimator)} option will use these variable lists to re-estimate and report the main equation;
this can be useful as a cross-check.
The test statistics reported by {cmd:underid} are based on appropriately re-parameterized linear IV equations;
see {help ranktest} for details.
The returned results from {cmd:underid} include the initial and final coefficient estimates for this equation
(initial will differ from final if the estimation method is iterative).
{p_end}


{marker unrobust_tests}{...}
{title:Classical (unrobust) tests}

Underidentification:

{pstd}
The default underidentification test reported by {opt underid}
for the classical (unrobust, iid assumed) case
is the LM version of the Anderson (1951) canonical correlations test.
Denote by ev_1 < ev_2 < ... < ev_K
the eigenvalues of (Y'*P_z*Y)*inv(Y'Y) where P_z is the projection matrix Z*inv(Z'Z)*Z',
after partialling out X and ordering the eigenvalues from smallest to largest.
The eigenvalues correspond to the squared {help canon:canonical correlations} between Y and Z (Anderson 1951).
The LM version of the Anderson test statistic for a rank reduction of 1 is simply N*ev_1,
i.e., the sample size N times the square of the smallest canonical correlation.
The original LR (likelihood ratio) version of Anderson's test
is -N*ln(1-ev_1) and can be obtained via the {opt lr} option.
The LM version of the Cragg-Donald (1993) test is identical to Anderson's test.
The Wald version of the CD test statistic is equal to N*ev_1/(1-ev_1)
and can be obtained using the {opt wald} option.
Both the Anderson and Cragg-Donald tests are score tests.
All these test statistics are distributed as chi-squared variates
with (L-1)*(K-1) degrees of freedom under the null hypothesis that rank(E(Y'Z))=K-1.

{pstd}
A 2SLS-based underidentification test can be obtained with the {opt jgmm2s} option.
This test is non-invariant and depends on the order of variables in Y = {bind:[y_1 y_2 ... y_K]}.
The reason is that the test is obtained as the Sargan J test for overidentification
for estimation by 2SLS of the model where the dependent variable is y_1
and the endogenous regressors are {bind:[y_2 ... y_K]}.
This is in contrast to the Anderson and Cragg-Donald statistics,
which can be obtained as a J test statistic
when the model is estimated by LIML (limited information maximum likelihood).
The Anderson and CD statistics are score tests
and, unlike the 2SLS-based J test,
invariant to the choice of which of {bind:[y_1 y_2 ... y_K]}
is chosen to be the dependent variable.
The Sanderson-Windmeijer test (see below)
of underidentification of a specific y_k
is the 2SLS-based underidentification test
obtained by specifying y_k as the dependent variable
and the {bind:K-1} remaining variables Y{-k} as the endogenous regressors.
See below and Windmeijer (2018) for discussion.

{pstd}
Note: In the special case of a single endogenous regressor y_1,
{bind:(1) the} LM versions of the Anderson and 2SLS-based underidentification statistics are identical;
{bind:(2) the} Wald versions of the CD and 2SLS-based underidentification statistics are identical.

Overidentification:

{pstd}
The default overidentification test reported by {opt underid}
for the classical (unrobust, iid assumed) case
is the Sargan (1958) statistic for the LIML estimator of the model {bind:y = Y*beta + e},
where again the exogenous regressors X have already been partialled out of Z, Y and y.
Denote the LIML residuals by ehat,
the projection matrix for the instruments Z by P_z,
and the annihilation matrix {bind:I-P_z} by M_z.
The Sargan statistic is {bind:N*(ehat'*P_z*ehat)/ehat'ehat}
and is the LM form of a score test.
The Basmann (1960) statistic {bind:N*(ehat'*P_z*ehat)/ehat'*M_z*ehat}
is essentially the Wald form of the same test
and can be obtained by the {opt wald} option.
When the {opt lr} option is specified,
{cmd:underid} reports the Anderson-Rubin (1950)
overidentification statistic for the LIML estimator,
defined as {bind:N*ln(ev_liml)}
where ev_liml is the eigenvalue of the LIML optimization problem.
These LIML-based tests are score tests.

{pstd}
When the {opt jgmm2s} option is specified,
{cmd:underid} reports the Sargan statistic for the 2SLS estimator,
i.e., the 2SLS residuals are used for ehat.
The Basmann statistic for the 2SLS estimator
is obtained by specifying the {opt jgmm2s} and {opt wald} options together.

{pstd}
The Anderson and Basmann LIML-based overid tests are "undirected" rank tests
and hence have no power to reject a false null in underidentified models.
In contrast, 2SLS-based overid tests are not rank tests
and still possess power to reject a false null in underidentified models
(although they are no longer consistent tests in this case).


Underidentification of individual endogenous regressors:

{pstd}
If the model is found to be underidentified,
then the Sanderson-Windmeijer (SW) conditional underidentification tests
can provide further information about
which endogenous explanatory variables are poorly predicted by the instruments,
controlling for the prediction of the other endogenous explanatory variables in the model.
These are 2SLS-based Sargan or Basmann tests of overidentifying restrictions
in the specifications y_k = Y_{-k}*delta_k+e_k, where Y_{-k} is Y without y_k.
Under the null that E(z_i*e_ki)=0
the SW statistic is distributed as chi-squared with (L-K+1) degrees of freedom.
Under this null, the instruments do not predict the endogenous variable y_k
after having predicted the other endogenous variables Y{-k}.
In the special case of a single endogenous regressor,
the SW statistic is identical to the 2SLS-based underidentification statistic described above.
When the {opt sw} option is specified,
SW statistics for each endogenous regressor in Y are reported
along with a standard underidentification test for the full set of endogenous regressors.
The F-test versions of the SW statistic are obtained as the Basmann test adjusted for the degrees of freedom.


{marker robust_tests}{...}
{title:Robust tests}

{pstd}
{cmd:underid} will by default report statistics using a VCE
that is as "robust" as the VCE used in the linear IV/GMM estimation.
For example, if the IV/GMM equation was reported
using a VCE that is robust to arbitrary heteroskedaticity,
{cmd:underid} will by default report heteroskedastic-consistent test statistics.
This behavior can be overridden by the {opt vceopt(list)} option,
where {it:list} is the list of VCE options (e.g., {it:robust}).
(NB: it is also possible to provide this list directly
without enclosing it in {opt vceopt(.)},
but only if the options don't conflict with the VCE options specified in the IV model;
use of {opt vceopt(.)} is safer and recommended.)
Specification of the VCE options is the same as in
{help avar}, {help ranktest} and {help ivreg2}.

{pstd}
The tests described below have the same limiting distributions
as those for the classical (unrobust, iid-assumed) tests described above,
and the interpretation of the tests is also the same.
The only substantive difference is the robustness of the tests,
i.e., the loosening of the iid assumption.

Underidentification:

{pstd}
The default robust underidentification test reported by {opt underid}
is the LM form of the robust Cragg-Donald (1993) test;
this is equivalent to specifying the {opt jcue} option.
Cragg-Donald (1993) present a test for the rank of B for the non-iid case
that is based on the Generalized Method of Moments (GMM).
Windmeijer (2018) shows that their test statistic
to a J statistic from a regression estimated using
GMM CUE (continuously-updated estimator),
where the Y variables are partitioned into
some that are treated as dependent (LHS) variables
and the remainder are endogenous (RHS) regressors.
Because it is a robust score test,
the test is invariant to the choice of which Y variables
are used as which.
See the {help ranktest} for further details and examples.

{pstd}
The {opt kp} option causes {cmd:underid} to report
the LM form of the Kleibergen-Paap (2006) test.
This test is derived from applying the singular value decomposition (SVD)
to a normalized version of Bhat.
Kleibergen-Paap (2006) show that
the KP test statistic can be interpreted as
Anderson's canonical correlations test generalized to the non-iid case
(a non-Kronecker covariance matrix).
Windmeijer (2018) shows that the KP test statistic
can also be interpreted as a LIML-based robust score test.
He also shows that it can be obtained from an artificial regression
using the residuals from LIML estimation(s);
the LIML residuals are obtained from estimations
where the Y variables are partitioned into
some that are treated as dependent (LHS) variables
and the remainder are endogenous (RHS) regressors.
Because it is a robust score test,
the test is invariant to the choice of which Y variables
are used as which.
See the {help ranktest} for further details and examples.

{pstd}
Windmeijer (2018) proposes two other robust score tests,
available in {cmd:underid} with the {opt j2l} or {opt j2lr} options.
Both are based on a two-step efficient GMM estimator
with the LIML estimator as the first step.
The J2L estimator uses the LIML estimates
to construct optimal instruments in the second step;
the J2LR is based on the iterative algorithm for the CUE estimator
proposed in Windmeijer (2018),
but iterating only once.
NB: neither option is available for tests after {opt xtabond2}.

{pstd}
A 2-step-GMM-based underidentification test can be obtained with the {opt jgmm2s} option.
As in the iid case,
this test is non-invariant and depends on the order of variables in Y = {bind:[y_1 y_2 ... y_K]}.
Also as in the iid case,
the Sanderson-Windmeijer test for y_k
is obtained by specifying y_k as the dependent variable
and the {bind:K-1} remaining variables Y{-k} as the endogenous regressors.

{pstd}
By default, {cmd:underid} reports LM forms of these tests.
Wald versions can be obtained by specifying the {opt wald} option.

{pstd}
Note: In the special case of a single endogenous regressor y_1,
{bind:(1) the} LM versions of these underidentification statistics are identical;
{bind:(2) the} Wald versions of these underidentification statistics are identical.

Overidentification

{pstd}
The default overidentification test reported by {opt underid} for the robust case
is the J statistic for the GMM CUE estimator;
this is equivalent to using the {opt jcue} option.
By default, the LM version of the test is reported.
If {opt wald} is specified, a Wald version is reported;
this statistic is equivalent to the J statistic
for the CUE-MD (minimum distance estimator) of Magnusson (2010).

{pstd}
When the {opt jgmm2s} option is specified along with a robust VCE,
{cmd:underid} reports the Hansen-Sargan statistic for the 2-step-GMM estimator.
By default, the LM version of the test is reported;
if {opt wald} is specified, a Wald version is reported.

Underidentification of individual endogenous regressors:

{pstd}
Specification of the {opt sw} with a robust VCE
causes {cmd:underid} to report robust versions of
the Sanderson-Windmeijer test.


{marker options}{...}
{title:Options}

Main options:

{pstd}
By default, {opt underid} will report only underidentification tests.
Calling {opt underid} with no options is equivalent to {opt underid, underid}.

{pstd}
Specifying {opt underid, overid} will report overidentification tests.
Specifying {opt underid, overid underid} will report both under- and overidentification tests.

{pstd}
The {opt sw} option requests Sanderson-Windmeijer underidentification tests for endogenous regressors.
This test is always either a 2SLS-based (in the iid case)
or a 2-step efficient GMM (in the non-iid case) J statistic.

{pstd}
{opt underid} by default reports LM-type tests.
Wald-type tests can be requested using the {opt wald} option.
For the Anderson test only, an LR test can be specified using the {opt lr} option.

VCE options:

{pstd}The default behavior of {opt underid} is to use the same VCE specification
as that used in the original IV estimation.
An exception is dynamic panel data estimation,
where the VCE reported by {opt under} is always cluster-robust.

{pstd}The {opt vceopt(string)} option can be used to override
the VCE specification original of the original IV estimation.
For example, if the original estimation used a heteroskedastic-consistent ("robust") VCE,
specifying {opt vceopt(cluster(panelid))} will cause {opt underid}
to report cluster-robust test statistics;
specifying {opt vceopt(iid)} will cause {opt underid}
to report classical (unrobust, iid assumed) test statistics.

Rarely-used options:

{pstd}
{opt usemeans} is relevant only for random-effects estimation with {help xtivreg,ec2sls} or {help xthtaylor}
where panels are unbalanced and the model includes exogenous regressors.
The {opt underid} default for these cases is to use a GLS-transformed exogenous regressor
and the demeaned regressor as an additional excluded instrument.
The {opt usemeans} option instead uses the panel mean as an additional excluded instrument.
In the case of a balance panel the two are approaches are numerically equivalent.

{pstd}
{opt repstata} is relevant only for random-effects estimation with {help xtivreg,ec2sls} or {help xthtaylor}
where panels are unbalanced and the model includes exogenous regressors.
Stata's approach in these cases is to treat a GLS-transformed exogenous regressor as {it:endogenous}
and to instrument it with the demeaned regressor and its panel mean as two excluded instruments.
The {opt repstata} option uses this same approach when calculating overidentification and underidentification tests.

{pstd}
{opt maineq(estimator)}reports the results of re-estimating the model using {help ivreg2}
after any required data transformations (first differences, fixed effects, random effects, etc.).
{it:estimator} may be {opt iv} (basic IV/2SLS estimation), {opt gmm2s} (2-step feasible efficient GMM)
or {opt cue} (continuously-updated GMM).

{pstd}
{opt noisily} reports the output of internal calls to {opt ranktest}.
{opt noreport} suppresses the detailed lists of endogenous regressors, exogenous regressors
and instruments for {help xtabond2}.


{marker underidexamples}{...}
{title:Underidentification examples}

{pstd}
Instrumental variables.  Examples follow Hayashi 2000, p. 255.
{p_end}
{phang}. {stata "use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta, clear"}{p_end}
{phang}. {stata ivreg2 lw expr tenure rns smsa i.year (s iq=med kww age mrt), rob}{p_end}

{pstd}
Default: J CUE invariant underidentification test.
{p_end}
{phang}. {stata underid}{p_end}

{pstd}
Reproduce {help ivreg2} Kleibergen-Paap invariant underid statistic.
{p_end}
{phang}. {stata di e(idstat)}{p_end}
{phang}. {stata underid, kp}{p_end}

{pstd}
2-step GMM-based underid statistic is not invariant to ordering of endogenous regressors.
Also illustrate use of {opt vceopt(.)}; underid test is robust, main equation is not.
{p_end}
{phang}. {stata qui ivreg2 lw expr tenure rns smsa i.year (s iq=med kww age mrt)}{p_end}
{phang}. {stata underid, vceopt(rob) jgmm2s}{p_end}
{phang}. {stata qui ivreg2 lw expr tenure rns smsa i.year (iq s=med kww age mrt)}{p_end}
{phang}. {stata underid, vceopt(rob) jgmm2s}{p_end}

{pstd}
Sanderson-Windmeijer underidentification tests.
{p_end}
{phang}. {stata underid, vceopt(rob) sw}{p_end}

{pstd}
Dynamic panel data using {help xtabond2}.
Note that the {help xtabond2} option {opt svmat} is required.
Examples based partly on {help xtabond2} help file examples.{p_end}

{phang}. {stata "use http://www.stata-press.com/data/r7/abdata.dta, clear"}{p_end}

{pstd}
Two-step estimator, system estimation.
{p_end}
{phang}. {stata xtabond2 n L.n L(0/1).(w k), gmm(L.(w k n), lag(1 1) eq(d)) robust twostep svmat}{p_end}
{pstd}
Default: J CUE invariant underidentification test.
{p_end}
{phang}. {stata underid}{p_end}

{pstd}
Two-step estimator, no level equation, J CUE invariant underidentification test.
{p_end}
{phang}. {stata xtabond2 n L.n L(0/1).(w k) yr1979-yr1984, gmm(L.(w k n), lag(1 1) orthog) iv(yr1979-yr1984) h(2) robust twostep orthog noleveleq svmat}{p_end}
{phang}. {stata underid}{p_end}

{pstd}
Sanderson-Windmeijer underidentification tests.
{p_end}
{phang}. {stata underid, sw}{p_end}

{pstd}
One-step estimator, diff and level equations, J CUE test; show {help ranktest} output.
{p_end}
{phang}. {stata xtabond2 n L.n L(0/1).(w k) yr1978-yr1984, gmm(L.(w k n), lag(1 1)) iv(yr1978-yr1984) robust svmat}{p_end}
{phang}. {stata underid, noi}{p_end}

{pstd}
Dynamic panel data using {help xtdpdgmm}.
{p_end}
{phang}. {stata "use http://www.stata-press.com/data/r7/abdata.dta, clear"}{p_end}

{pstd}
Two-step estimator, system estimation; same specification as for {cmd:xtabond2} above.
{p_end}
{phang}. {stata xtdpdgmm n L.n L(0/1).(w k), gmm(L.(w k n), lag(1 1) m(d)) vce(r) twostep}{p_end}

{pstd}
Default: J CUE invariant underidentification test.
{p_end}
{phang}. {stata underid}{p_end}

{pstd}
Static panel data.  Examples based on Stata command help files.
{p_end}
{phang}. {stata webuse nlswork, clear}{p_end}
{phang}. {stata tsset idcode year}{p_end}
{phang}. {stata gen age2=age^2}{p_end}
{phang}. {stata gen black=(race==2)}{p_end}
{phang}. {stata xtivreg ln_wage age (tenure = union south), fe}{p_end}

{pstd}
LIML-based test for the iid case.
{p_end}
{phang}. {stata underid}{p_end}

{pstd}
Cluster-robust J CUE and KP tests; tests are identical in this example
because there is 1 endogenous regressor and test is a test of null rank.
{p_end}
{phang}. {stata underid, vceopt(cluster(idcode)) noi}{p_end}
{phang}. {stata underid, vceopt(cluster(idcode)) noi kp}{p_end}


{marker overidexamples}{...}
{title:Overidentification examples}

{pstd}
Instrumental variables.  Examples follow Hayashi 2000, p. 255.
{p_end}
{phang}. {stata "use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta, clear"}{p_end}
{phang}. {stata ivreg2 lw s expr tenure rns smsa i.year (iq=med kww age mrt), rob}{p_end}

{pstd}
Report J CUE overidentification test.
{p_end}
{phang}. {stata underid, overid}{p_end}

{pstd}
Reproduce {help ivreg2} Hansen J overid statistic.
{p_end}
{phang}. {stata di e(j)}{p_end}
{phang}. {stata underid, overid jgmm2s}{p_end}

{pstd}
Dynamic panel data using {help xtabond2}.
Note that the {help xtabond2} option {opt svmat} is required.
{p_end}
{phang}. {stata "use http://www.stata-press.com/data/r7/abdata.dta, clear"}{p_end}

{pstd}
Two-step estimator, no level equation.
{p_end}
{phang}. {stata xtabond2 n L.n L(0/1).(w k) yr1979-yr1984, gmm(L.(w k n), lag(1 1) orthog) iv(yr1979-yr1984) h(2) robust twostep orthog noleveleq svmat}{p_end}

{pstd}
Reproduce {help xtabond2} Hansen J overid statistic.
{p_end}
{phang}. {stata di e(hansen)}{p_end}
{phang}. {stata underid, overid jgmm2s}{p_end}
{pstd}
Report J CUE overid statistic ({opt underid} default).
Suppress {help xtabond2}-related output.
Also examine CUE coefficients and VCE for endogenous regressors.
{p_end}
{phang}. {stata underid, noreport overid}{p_end}
{phang}. {stata mat list r(b_oid)}{p_end}
{phang}. {stata mat list r(V_oid)}{p_end}

{pstd}
Reproduce {help xtdpdgmm} Hansen J overid statistic.
{p_end}
{phang}. {stata "xtdpdgmm L(0/1).n w k, gmmiv(L.n, l(1 4) c m(d)) iv(w k, d m(d)) twostep vce(robust)"}{p_end}
{phang}. {stata estat overid}{p_end}
{phang}. {stata underid, overid jgmm2s}{p_end}
{pstd}
Report J CUE overid statistic ({opt underid} default).
Also examine CUE coefficients and VCE for endogenous regressors.
{p_end}
{phang}. {stata underid, noreport overid}{p_end}
{phang}. {stata mat list r(b_oid)}{p_end}
{phang}. {stata mat list r(V_oid)}{p_end}

{pstd}
Static panel data.  Examples based on Stata command help files.
{p_end}
{phang}. {stata webuse nlswork, clear}{p_end}
{phang}. {stata tsset idcode year}{p_end}
{phang}. {stata gen age2=age^2}{p_end}
{phang}. {stata gen black=(race==2)}{p_end}

{pstd}
Fixed effects.
{p_end}
{phang}. {stata xtivreg ln_wage age (tenure = union south), fe}{p_end}
{pstd}
LIML-based tests for the iid case.
{p_end}
{phang}. {stata underid, overid}{p_end}
{pstd}
Cluster-robust test.
{p_end}
{phang}. {stata underid, overid vceopt(cluster(idcode))}{p_end}

{pstd}
G2SLS; note overid degrees of freedom: 2 (union, south) - 1 (tenure) = 1.
{p_end}
{phang}. {stata xtivreg ln_wage age (tenure = union south), re}{p_end}
{phang}. {stata underid, overid}{p_end}

{pstd}
EC2SLS; dof = 6 (mean and mean-deviation of union, south, age) - 2 (GLS transform of tenure, age) = 4.
{p_end}
{phang}. {stata xtivreg ln_wage age (tenure = union south), ec2sls}{p_end}
{phang}. {stata underid, overid}{p_end}

{pstd}
EC2SLS; changing the number of included exogenous variables changes the dof of the overid stat.
4 (mean and mean-deviation of union, south) - 1 (GLS transform of tenure) = 3.
{p_end}
{phang}. {stata xtivreg ln_wage (tenure = union south), ec2sls}{p_end}
{phang}. {stata underid, overid}{p_end}

{pstd}
Hausman-Taylor estimation; 2-step GMM J stats.
Note that underlying estimation differs from original; Stata's
{opt xthtaylor} treats GLS-transformed exogenous regressors as endogenous.
dof = 2 (exogenous time-varying age, age2) - 1 (endogenous time-invariant grade) = 1.
{p_end}
{phang}. {stata xthtaylor ln_wage age age2 tenure hours black birth_yr grade, endog(tenure hours grade)}{p_end}
{phang}. {stata underid, overid jgmm2s}{p_end}
{phang}. {stata mat list e(b)}{p_end}
{phang}. {stata mat list r(b0_oid)}{p_end}

{pstd}
As above but use {opt repstata} option; confirm underlying estimation now matches original.
{p_end}
{phang}. {stata xthtaylor ln_wage age age2 tenure hours black birth_yr grade, endog(tenure hours grade)}{p_end}
{phang}. {stata underid, overid jgmm2s repstata}{p_end}
{phang}. {stata mat list e(b)}{p_end}
{phang}. {stata mat list r(b0_oid)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:underid} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(j_uid)}}chi-sq statistic for underidentification{p_end}
{synopt:{cmd:r(df_uid)}}degrees of freedom of underidentification test{p_end}
{synopt:{cmd:r(p_uid)}}p-value for for underidentification test{p_end}
{synopt:{cmd:r(j_oid)}}chi-sq statistic for overeridentification{p_end}
{synopt:{cmd:r(df_oid)}}degrees of freedom of overeridentification test{p_end}
{synopt:{cmd:r(p_oid)}}p-value for for overidentification test{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(rkstat)}}Test statistic (passed to {help ranktest}){p_end}
{synopt:{cmd:r(vceopt)}}Variance-covariance matrix options (passed to {help ranktest}){p_end}
{synopt:{cmd:r(rkopt)}}Additional options (passed to {help ranktest}){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b_uid)}}Coefficient vector corresponding to J-based underid test{p_end}
{synopt:{cmd:r(V_uid)}}VCE of coefficient vector corresponding to J-based underid test{p_end}
{synopt:{cmd:r(S_uid)}}Covariance matrix of orthogonality conditions corresponding to J-based underid test{p_end}
{synopt:{cmd:r(b0_uid)}}Initial coefficient vector corresponding to underid test{p_end}
{synopt:{cmd:r(b_oid)}}Coefficient vector corresponding to J-based overid test{p_end}
{synopt:{cmd:r(V_oid)}}VCE of coefficient vector corresponding to J-based overid test{p_end}
{synopt:{cmd:r(S_oid)}}Covariance matrix of orthogonality conditions corresponding to J-based overid test{p_end}
{synopt:{cmd:r(b0_oid)}}Initial coefficient vector corresponding to overid test{p_end}
{synopt:{cmd:r(sw_uid)}}Sanderson-Windmeijer underidentification tests{p_end}


{marker s_citation}{title:Citation of underid}

{p}{cmd:underid} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Schaffer, M.E., Windmeijer, F. 2020.
underid: Postestimation tests of under- and over-identification after linear IV estimation.
{browse "http://ideas.repec.org/c/boc/bocode/s458805.html"}{p_end}


{marker references}{...}
{title:References}

{p 0 4}Anderson, T.W. 1951. Estimating linear restrictions on regression coefficients
for multivariate normal distributions. Annals of Mathematical Statistics, Vol. 22, pp. 327-51.

{p 0 4}Cragg, J.G. and Donald, S.G. 1993. Testing Identfiability and Specification in
Instrumental Variables Models. Econometric Theory, Vol. 9, pp. 222-240.

{p 0 4}Kleibergen, F. and Paap, R.  2006.  Generalized Reduced Rank Tests Using the Singular Value Decomposition.
Journal of Econometrics, Vol. 133, pp. 97-126.

{p 0 4}Magnusson, L.M. 2010.  Inference in limited dependent variable models robust to weak identification.
Econometrics Journal, 13:S56-S79.

{p 0 4}Sanderson, E. and F. Windmeijer, 2016.
A weak instrument F-test in linear IV models with multiple endogenous variables.
Journal of Econometrics 190, 212-221.
(Link.)

{p 0 4}Windmeijer, F.  2018. Testing Over- and Underidentification in Linear Models,
with Applications to Dynamic Panel Data and Asset-Pricing Models.
Bristol Economics Discussion Papers 18/696.
{browse "https://ideas.repec.org/p/bri/uobdis/18-696.html":https://ideas.repec.org/p/bri/uobdis/18-696.html}


{title:Authors}
	
	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk

	Frank Windmeijer, Oxford University, UK
	frank.windmeijer@stats.ox.ac.uk

