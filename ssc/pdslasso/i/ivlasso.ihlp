{smcl}
{* *! version 1.0.11  15jan2019}{...}
{hline}
{cmd:help pdslasso, help ivlasso}{right: pdslasso v1.1}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: pdslasso} and {hi: ivlasso} {hline 2}}Programs for post-selection and post-regularization OLS or IV estimation and inference{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:pdslasso}
{it:depvar} {it:regressors} {cmd:(}{it:hd_controls}{cmd:)}
[{it:weight}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[ {cmd:,}}
{opt partial(varlist)}
{opt pnotpen(varlist)}
{opt aset(varlist)}
{opt post(method)}
{opt r:obust}
{opt cl:uster(var)}
{opt fe}
{opt noftools}
{cmd:rlasso}[{cmd:(}{it:name}{cmd:)}]
{opt sqrt}
{opt noi:sily}
{opt lopt:ions(options)}
{opt olsopt:ions(options)}
{bind:{cmdab:noc:onstant} ]}

{p 8 14 2}
{cmd:ivlasso}
{it:depvar} {it:regressors} [{cmd:(}{it:hd_controls}{cmd:)}]
{cmd:(}{it:endog}{cmd:=}{it:instruments}{cmd:)}
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[ {cmd:,}}
{opt partial(varlist)}
{opt pnotpen(varlist)}
{opt aset(varlist)}
{opt post(method)}
{opt r:obust}
{opt cl:uster(var)}
{opt fe}
{opt noftools}
{cmd:rlasso}[{cmd:(}{it:name}{cmd:)}]
{opt sqrt}
{opt noi:sily}
{opt lopt:ions(options)}
{opt ivopt:ions(options)}
{opt first}
{opt idstats}
{opt sscset}
{opt ssgamma(real)}
{opt ssgridmin(real)}
{opt ssgridmax(real)}
{opt ssgridpoints(integer 100)}
{opt ssgridmat(name)}
{bind:{cmdab:noc:onstant} ]}

{p 8 14 2}
Note: {opt pdslasso} requires {opt rlasso} to be installed;
{opt ivlasso} also requires {opt ranktest}.
See {rnethelp "http://fmwww.bc.edu/RePEc/bocode/r/rlasso.sthlp":help rlasso}
and {rnethelp "http://fmwww.bc.edu/repec/bocode/r/ranktest.hlp":help ranktest}
or click on {stata "ssc install lassopack"} or {stata "ssc install ranktest"} to install.

{p 8 14 2}
Note: the {opt fe} option will take advantage of the {helpb ivlasso##SG2016:ftools}
package (if installed) for the fixed-effects transform;
the speed gains using this package can be large.
See {rnethelp "http://fmwww.bc.edu/RePEc/bocode/f/ftools.sthlp":help ftools}
or click on {stata "ssc install ftools"} to install.

{p 8 14 2}
Note: {opt ivlasso} also supports the simpler {cmd:pdslasso} syntax.

{synoptset 20}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt partial(varlist)}}
controls and instruments to be partialled-out prior to lasso estimation
{p_end}
{synopt:{opt pnotpen(varlist)}}
controls and instruments always included, not penalized by lasso
{p_end}
{synopt:{opt aset(varlist)}}
controls and instruments in amelioration set, always included in post-lasso
{p_end}
{synopt:{opt post(method)}}
{it:pds}, {it:lasso} or {it:plasso}; which estimation results are to be posted in {opt e(b)} and {opt e(V)}
{p_end}
{synopt:{opt r:obust}}
heteroskedastic-robust VCE; lasso penalty loadings account for heteroskedasticity
{p_end}
{synopt:{opt cl:uster(var)}}
cluster-robust VCE; lasso penalty loadings account for clustering
{p_end}
{synopt:{opt fe}}
fixed-effects model (requires data to be {helpb xtset})
{p_end}
{synopt:{opt noftools}}
do not use FTOOLS package for fixed-effects transform (slower; rarely used)
{p_end}
{synopt:{cmd:rlasso}[{cmd:(}{it:name}{cmd:)}]}
store and display intermediate lasso and post-lasso results from rlasso with optional prefix {it:name}
(if just {opt rlasso} is specified the default prefix is _ivlasso_ or _pdslasso_)
{p_end}
{synopt:{opt sqrt}}
use sqrt-lasso instead of standard lasso
{p_end}
{synopt:{opt noi:sily}}
display step-by-step intermediate {opt rlasso} estimation results
{p_end}
{synopt:{opt lopt:ions(options)}}
lasso options specific to {opt rlasso} estimation; see {helpb rlasso:help rlasso}
{p_end}
{synopt:{opt olsopt:ions(options)}}
({opt pdslasso} only) options specific to PDS OLS estimation of structural equation
{p_end}
{synopt:{opt ivopt:ions(options)}}
({opt ivlasso} only) options specific to PDS OLS or IV estimation of structural equation
{p_end}
{synopt:{opt first}}
({opt ivlasso} only) display and store first-stage results for 2SLS
{p_end}
{synopt:{opt idstats}}
({opt ivlasso} only) request weak-identification statistics for 2SLS
{p_end}
{synopt:{opt noc:onstant}}
suppress constant from regression (cannot be used with {opt aweights} or {opt pweights})
{p_end}
{synoptline}

{synopthdr:Sup-score test}
{synopt:({opt ivlasso} only)}
{p_end}
{synoptline}
{synopt:{opt sscset}}
request sup-score weak-identification-robust confidence set
{p_end}
{synopt:{opt ssgamma(real)}}
significance level for sup-score weak-identification-robust tests and confidence intervals (default=0.05, 5%)
{p_end}
{synopt:{opt ssgridmin(real)}}
minimum value for grid search for sup-score weak-identification-robust confidence intervals (default=grid centered at OLS estimate)
{p_end}
{synopt:{opt ssgridmax(real)}}
maximum value for grid search for sup-score weak-identification-robust confidence intervals (default=grid centered at OLS estimate)
{p_end}
{synopt:{opt ssgridpoints(real)}}
number of points in grid search for sup-score weak-identification-robust confidence intervals (default=100)
{p_end}
{synopt:{opt ssgridmat(name)}}
user-supplied Stata r x k matrix of r jointly hypothesized values for the k endogenous regressors
to be tested using the sup-score test
{p_end}
{synopt:{opt ssomitgrid(name)}}
supress display of sup-score test results with user-supplied grid
{p_end}
{synopt:{opt ssmethod(name)}}
"abound" (default) = use conservative critical value (asymptotic bound) c*sqrt(N)*invnormal(1-gamma/(2p));
"simulate" = simulate distribution to obtain p-values for sup-score test;
"select" = reject if {opt rlasso} selects any instruments
{p_end}
{synoptline}
{p2colreset}{...}

{phang}
Postestimation:

{p 8 14 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} 
{cmd:resid} {cmd:xb} ]

{pstd}
{opt pdslasso} and {opt ivlasso} may be used with time-series or panel data,
in which case the data must be tsset or xtset first;
see help {helpb tsset} or {helpb xtset}.

{pstd}
{opt aweights} and {opt pweights} are supported; see help {helpb weights}.
{opt pweights} is equivalent to {opt aweights} + {opt robust}.

{pstd}
All varlists may contain time-series operators or factor variables; see help varlist.


{title:Contents}

{phang}{help ivlasso##description:Description}{p_end}
{phang}{help ivlasso##computation:Computational notes}{p_end}
{phang}{help ivlasso##examples:Examples of usage}{p_end}
{phang}{help ivlasso##saved_results:Saved results}{p_end}
{phang}{help ivlasso##references:References}{p_end}
{phang}{help ivlasso##website:Website}{p_end}
{phang}{help ivlasso##installation:Installation}{p_end}
{phang}{help ivlasso##acknowledgements:Acknowledgements}{p_end}
{phang}{help ivlasso##citation:Citation of pdslasso and ivlasso}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt pdslasso} and {opt ivlasso} are routines for estimating
structural parameters in linear models with many controls and/or instruments.
The routines use methods for estimating sparse high-dimensional models,
specifically the lasso (Least Absolute Shrinkage and Selection Operator, Tibshirani {helpb ivlasso##Tib1996:1996})
and the square-root-lasso (Belloni et al. {helpb ivlasso##BCW2011:2011}, {helpb ivlasso##BCW2014:2014}).
Two approaches are implemented in {opt pdslasso} and {opt ivlasso}:

{p 10 15}1. The "post-double-selection" (PDS) methodology of Belloni et al. ({helpb ivlasso##BCCH2012:2012},
{helpb ivlasso##BCH2013:2013}, {helpb rlasso##BCH2014:2014},
{helpb ivlasso##BCH2015:2015}, {helpb ivlasso##BCHK2016:2016}),
denoted "PDS methodology" below.

{p 10 15}2. The "post-regularization" methodology of Chernozhukov, Hansen and Spindler
({helpb ivlasso##CHS2015:2015}), denoted "CHS methodology" below.

{pstd}
The implemention of these methods in {opt pdslasso} and {opt ivlasso}
uses the separate Stata program {helpb rlasso},
which provides lasso and sqrt-lasso estimation with data-driven penalization;
see {helpb rlasso} for details.

{pstd}
The intution behind the methodology is most clearly seen
from the PDS methodology applied to the case where a researcher
has an outcome variable {it:y}, a structural or causal variable of interest {it:d},
and a large set of potential control variables {it:x1, x2, x3, ...}.
The problem the researcher faces is that the "right" set of controls is not known.
In traditional practice, this presents her with a difficult choice:
use too few controls, or the wrong ones,
and omitted variable bias will be present;
use too many, and the model will suffer from overfitting.

{pstd}
The PDS methodology uses the lasso estimator to select the controls.
Specifically, the lasso is used twice:
(1) estimate a lasso regression with {it:y} as the dependent variable
and the control variables {it:x1, x2, x3, ...} as regressors;
(2) estimate a lasso regression with {it:d} as the dependent variable
and again the control variables {it:x1, x2, x3, ...} as regressors.
The lasso estimator achieves a sparse solution, i.e., most coefficients are set to zero.
The final choice of control variables to include
in the OLS regression of {it:y} on {it:d}
is the union of the controls selected selected in steps (1) and (2),
hence the name "post-double selection" for the methodolgy.
The PDS methodology can be employed to select instruments as well
as controls in instrumental variables estimation.

{pstd}
The CHS methodology is closely related.
Instead of using the lasso-selected controls and instruments
in a post-regularization OLS or IV estimation,
the selected variables are used to construct
orthogonalized versions of the dependent variable,
the exogenous and/or endogenous causal variables of interest
and to construct optimal instruments from the lasso-selected IVs.
The orthogonalized versions are based either on the lasso
or post-lasso estimated coefficients;
the post-lasso is OLS applied to lasso-selected variables.
See Chernozhukov et al. ({helpb ivlasso##CHS2015:2015}) for details.

{pstd}
The set of variables selected by the lasso
and used in the OLS post-lasso estimation
and in the PDS structural estimation
can be augmented by variables that were penalized but not selected by the lasso.
The penalized variables that are used in this way to augment the post-lasso and PDS estimations
are called the "amelioration set" and can be specified with the {opt aset(varlist)} option.
This option affects only the CHS post-lasso-based and PDS estimations;
the CHS lasso-based orthogonalized variables are unaffected.
See Chernozhukov et al. ({helpb ivlasso##BCH2014:2014}) for details.

{pstd}
{opt pdslasso} and {opt ivlasso} report
the PDS-based and the two (lasso and post-lasso) CHS-based estimations.
If the {opt sqrt} option is specified,
instead of the lasso the sqrt-lasso estimator is used;
see {helpb rlasso} for further details and references.

{pstd}
If the IV model is weakly identified
(the instruments are only weakly correlated with the endogenous regressors)
Belloni et al. ({helpb ivlasso##BCCH2012:2012}, {helpb ivlasso##BCH2013:2013})
suggest using weak-identification-robust hypothesis tests and confidence sets
based the Chernozhukov et al. ({helpb ivlasso##CCK2013:2013}) sup-score test.
The intuition behind the sup-score test is
similar to that of the Anderson-Rubin ({helpb ivlasso##AR1949:1949}) test.
Consider the simplest case (a single endogenous regressor {it:d}
and no exogenous regressors or controls)
where the null hypothesis is that the coefficient on {it:d}
is {it:H0:beta=b0}.
If the null is true,
then the structural residual is simply {it:e=y-b0*d}.
Under the additional assumption that the instruments are valid
(orthogonal to the true disturbance),
they should be uncorrelated with {it:e}.

{pstd}
The sup-score tests reported by {opt ivlasso}
are in effect high-dimensional versions of the Anderson-Rubin test.
The test is implemented in {helpb rlasso};
see {helpb rlasso:help rlasso} for details.
Specifically, {opt ivlasso} reports sup-score tests of statistical significance
of the instruments where the dependent variable is {it:e=y-b0*d},
the instruments are regressors,
and {it:b0} is a hypothesized value of the coefficient on {it:d};
a large test statistic indicates rejection of the null H0:{it:beta=b0}.
The default is to use a conservative (asymptotic bound) critical value as suggested by
Belloni et al. ({helpb ivlasso##BCCH2012:2012}, {helpb ivlasso##BCH2013:2013})
(option {opt ssmethod(abound)}).
Alternative methods are to use p-values obtained by simulation via a multiplier bootstrap
(option {opt ssmethod(simulate)}),
or to estimate a lasso regression with the instruments as regressors,
and if (no) instruments are selected we (fail to) reject the null {it:H0:beta=b0}
at the {it:gamma} significance level
(option {opt ssmethod(select)}).

{pstd}
A {it:100*(1-gamma)%} sup-score-based confidence set can be constructed
by a grid search over the range of hypothesized values of {it:beta}.
{opt ivlasso} reports the result of the sup-score test of the null {it:H0:beta=0}
with the {opt idstats} option,
and in addition, for the single endogenous regressor case only,
reports sup-score confidence sets with the {opt sscset} option.
For the multiple-endogenous regressor case,
sets of jointly hypothesized values for the componets of {it:beta}
can be tested using the {opt ssgridmat(name)} option.
The matrix provided in the option should be an r x k Stata matrix,
where each row contains a set of values
that together specify a null hypothesis for the coefficients of the k endogenous regressors.
This option allows the user to specify a grid search in multiple dimensions.

{marker computation}{...}
{title:Computational notes}

{pstd}
The various options available for the underlying calls to {opt rlasso} can be controlled
via the option {opt loptions(rlasso option list)}.
The {opt rlasso} option {opt center},
to center moments in heteroskedastic and cluster-robust loadings,
will be a commonly-employed option.
This can be specified by {opt lopt(center)}.

{pstd}
Another {opt rlasso} option that may often be used is
to "pre-standardize" the data to have unit variance
prior to computing the lasso coefficients with the {opt prestd} option.
This is a computational alternative to the {opt rlasso} default of standardizing "on the fly"
(i.e., incorporating the standardization into the lasso penalty loadings).
This is specified by {opt lopt(prestd)}.
The results are equivalent in theory.
The {opt prestd} option can lead to improved numerical precision
or more stable results in the case of difficult problems;
the cost is (a typically small) computation time required to standardize.

{pstd}
{opt rlasso} implements a version of the lasso with data-dependent penalization
and, for the heteroskedastic and clustered cases,
regressor-specific penalty loadings; see {helpb rlasso} for details.
Note that specification of {opt robust} or {opt cluster(.)}
as options to {opt pdslasso} or {opt ivlasso}
automatically implies the use of robust or cluster-robust
lasso penalty loadings.
Penalty loadings and VCE type can be separately controlled
via the {opt olsoptions(.)} (for {opt pdslasso})
or {opt ivoptions(.)} (for {opt ivlasso}) vs. {opt loptions(rlasso option list)};
for example, {opt olsoptions(cluster(clustvar))} + {opt loptions(robust)}
would use heteroskedastic-robust penalty loadings for the lasso estimations
and a cluster-robust covariance estimator
for the PDS and CHS estimations of the structural equation.

{pstd}
Either the {opt partial(varlist)} option
or the {opt pnotpen(varlist)} option
can be used for variables that should not be penalized by the lasso.
By the Frisch-Waugh-Lovell Theorem for the lasso (Yamada {helpb rlasso##Yam2017:2017}),
the estimated lasso coefficients are the same in theory
whether the unpenalized regressors are partialled-out or given zero penalty loadings,
so long as the same penalty loadings are used for the penalized regressors in both cases.
Although the options are equivalent in theory, numerical results can differ
in practice because of the different calculation methods used;
see {helpb rlasso##notpen:rlasso} for further details.
The constant, if present, is always unpenalized or partialled-out
By default the constant (if present) is not penalized
if there are no regressors being partialled out;
this is equivalent to mean-centering prior to estimation.
The exception to this is if {opt aweights} or {opt aweights} are specified,
in which case the constant is partialled-out.
The {opt partial(varlist)} option always partials out the constant (if present)
along with the variables specified in {it:varlist};
to partial out just the constant, specify {opt partial(_cons)}.
Partialling-out of controls is done by {opt ivlasso};
partialling-out of instruments is done in the lasso estimation by {opt rlasso}.

{pstd}
The lasso and sqrt-lasso estimations are obtained via numerical methods (coordinate descent).
Results can be unstable for difficult problems
(e.g., if the scaling of variables covers a wide range of magnitudes).
Using variables that are all measured on a similar scale will help (as usual).
Partialling-out variables is usually preferable to specifying them as unpenalized.
See {helpb rlasso} for discussion of the various options
for controlling the numerical methods used.

{pstd}
The sup-score-based tests reported by {opt ivlasso}
come in three versions:
(a) using lasso-orthogonalized variables,
where the variables have first been orthogonalized
with respect to the high-dimensional controls using the lasso;
(b) using post-lasso-orthogonalized variables;
(c) using the variables without any orthogonalization.
The orthogonalizations use the same lasso settings as in the main estimation.
After orthgonalization,
{it:e~ = y~ - b0*d~} is constructed (where a tilde indicates an orthogonalized variable),
and then the sup-score test is conducted using {it:e~} and the instruments.
Versions (a) and (b) are not reported
if there are no high-dimensional controls.
Version (c) is available if there are high-dimensional controls
but only if the {opt method(select)} option is used.
The sup-score-based tests are not available if the specification
also includes either exogenous causal regressors or unpenalized instruments.

{pstd}
For large datasets, obtaining the p-value for the sup-score test
by simulation (multiplier bootstrap, {opt ssmethod(simulate)} option) can be time-consuming.
In such cases, using the default method of a conservative (asymptotic bound) critical value
({opt ssmethod(abound)} option) will be much faster.

{pstd}
The grid search to construct the sup-score confidence set can be controlled
by the {opt ssgridmin}, {opt ssgridmax} and {opt ssgridpoints} options.
If these options are not specified by the user,
a 100-point grid centered on the OLS estimator is used.

{pstd}
The {opt fe} fixed-effects option is equivalent to
(but computationally faster and more accurate than)
specifying unpenalized panel-specific dummies.
The fixed-effects ("within") transformation
also removes the constant as well as the fixed effects.
The panel variable used by the {opt fe} option
is the panel variable set by {helpb xtset}.

{pstd}
{opt rlasso}, like the lasso in general,
accommodates possibly perfectly-collinear sets of regressors.
Stata's {helpb fvvarlist:factor variables} are supported by {opt rlasso}.
Users therefore have the option of specifying
as high-dimensional controls or instruments
one or more complete sets of factor variables or interactions
with no base levels using the {it:ibn} prefix.
This can be interpreted as allowing the lasso
to choose the members of the base category.

{pstd}
For a detailed discussion of an R implementation of this methodology, 
see Spindler et al. ({helpb ivlasso##SCH2016:2016}).

{marker examples}{...}
{title:Examples using data from Acemoglu-Johnson-Robinson (2001)}

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

{pstd}Examples with exogenous regressors:{p_end}

{pstd}Replicate OLS results in Panel C, col. 9.{p_end}
{phang2}. {stata "reg logpgp95 avexpr lat_abst edes1975 avelf temp* humid* steplow-oilres"}{p_end}

{pstd}Basic usage: select from high-dim controls.{p_end}
{phang2}. {stata "pdslasso logpgp95 avexpr (lat_abst edes1975 avelf temp* humid* steplow-oilres)"}{p_end}

{pstd}As above, hetoroskedastic-robust.{p_end}
{phang2}. {stata "pdslasso logpgp95 avexpr (lat_abst edes1975 avelf temp* humid* steplow-oilres), rob"}{p_end}

{pstd}Specify that latitude is an unpenalized control to be partialled out.{p_end}
{phang2}. {stata "pdslasso logpgp95 avexpr (lat_abst edes1975 avelf temp* humid* steplow-oilres), partial(lat_abst)"}{p_end}

{pstd}Specify that latitude is an unpenalized control using the notpen option (equivalent).{p_end}
{phang2}. {stata "pdslasso logpgp95 avexpr (lat_abst edes1975 avelf temp* humid* steplow-oilres), pnotpen(lat_abst)"}{p_end}

{pstd}Specify that latitude is in the amelioration set.{p_end}
{phang2}. {stata "pdslasso logpgp95 avexpr (lat_abst edes1975 avelf temp* humid* steplow-oilres), aset(lat_abst)"}{p_end}

{pstd}Example with endogenous regressor, high-dimensional controls and low-dimensional instrument:{p_end}

{pstd}Replicate IV results in Panels A & B, col. 9.{p_end}
{phang2}. {stata "ivreg logpgp95 (avexpr=logem4) lat_abst edes1975 avelf temp* humid* steplow-oilres, first"}{p_end}

{pstd}Select controls; specify that logem4 is an unpenalized instrument to be partialled out.{p_end}
{phang2}. {stata "ivlasso logpgp95 (avexpr=logem4) (lat_abst edes1975 avelf temp* humid* steplow-oilres), partial(logem4)"}{p_end}

{pstd}Example with endogenous regressor and high-dimensional instruments and controls:{p_end}

{pstd}Select controls and instruments;
specify that logem4 is an unpenalized instrument and lat_abst is an unpenalized control;
request weak identification stats and first-stage results.{p_end}
{phang2}. {stata "ivlasso logpgp95 (lat_abst edes1975 avelf temp* humid* steplow-oilres) (avexpr=logem4 euro1900-cons00a), partial(logem4 lat_abst) idstats first"}{p_end}

{pstd}Replay first-stage estimation. (Can also use {opt est restore} to make this the current estimation results.){p_end}
{phang2}. {stata "est replay _ivlasso_avexpr"}{p_end}

{pstd}Select controls and instruments;
specify that lat_abst is an unpenalized control;
request weak identification stats and sup-score confidence sets.{p_end}
{phang2}. {stata "ivlasso logpgp95 (lat_abst edes1975 avelf temp* humid* steplow-oilres) (avexpr=logem4 euro1900-cons00a), partial(lat_abst) idstats sscset"}{p_end}

{pstd}As above but heteroskedastic-robust and use grid options to control grid search and test level;
also set seed in {opt rlasso} options to make multiplier-bootstrap p-values replicable.{p_end}
{phang2}. {stata "ivlasso logpgp95 (lat_abst edes1975 avelf temp* humid* steplow-oilres) (avexpr=logem4 euro1900-cons00a), partial(lat_abst) rob idstats sscset ssgridmin(0) ssgridmax(2) ssgamma(0.1) lopt(seed(1))"}{p_end}

{marker examples}{...}
{title:Examples using data from Angrist-Krueger ({helpb ivlasso##AK1991:1991})}

{pstd}Load AK data and rename variables (dataset needs to be in current directory).
NB: this is a large dataset (330k observations) and estimations may take
some time to run on some installations.{p_end}
{phang2}. {stata "clear"}{p_end}
{phang2}. {browse "https://economics.mit.edu/files/397":(click to download asciiqob.zip from economics.mit.edu)}{p_end}
{phang2}. {stata "unzipfile asciiqob.zip"}{p_end}
{phang2}. {stata "infix lnwage 1-9 edu 10-20 yob 21-31 qob 32-42 pob 43-53 using asciiqob.txt"}{p_end}

{pstd}Alternative source (no unzipping needed):{p_end}
{phang2}. {stata "use https://statalasso.github.io/dta/AK91.dta""}{p_end}

{pstd}xtset data by place of birth (state):{p_end}
{phang2}. {stata "xtset pob"}{p_end}

{pstd}Table VII (1930-39) col 2. Year and state of birth = yob & pob.{p_end}
{phang2}. {stata "ivregress 2sls lnwage i.pob i.yob (edu=i.qob i.yob#i.qob i.pob#i.qob)"}{p_end}

{pstd}Fixed effects; select year controls and IVs; IVs are QOB and QOBxYOB.{p_end}
{phang2}. {stata "ivlasso lnwage (i.yob) (edu=i.qob i.yob#i.qob), fe"}{p_end}

{pstd}Fixed effects; select year controls and IVs; IVs are QOB, QOBxYOB, QOBxSOB.{p_end}
{phang2}. {stata "ivlasso lnwage (i.yob) (edu=i.qob i.yob#i.qob i.pob#i.qob), fe"}{p_end}

{pstd}All dummies & interactions incl. base levels.{p_end}
{phang2}. {stata "ivlasso lnwage (i.yob) (edu=ibn.qob ibn.yob#ibn.qob ibn.pob#ibn.qob), fe"}{p_end}

{title:Example using data from Belloni et al. ({helpb ivlasso##BCH2015:2015})}

{pstd}Load dataset on eminent domain (available at journal website).{p_end}
{phang2}. {stata "clear"}{p_end}
{phang2}. {stata "import excel using https://statalasso.github.io/dta/CSExampleData.xlsx, first"}{p_end}

{pstd}Settings used in Belloni et al. ({helpb ivlasso##BCH2015:2015}) - results as in journal replication file (not text){p_end}
{pstd}(Includes use of undocumented {opt rlasso} option {opt c0(real)} to control initial penalty loadings.){p_end}
{pstd}Store {opt rlasso} intermediate results for replay later.{p_end}
{phang2}. {stata "ivlasso CSIndex (NumProCase = Z*), nocons robust rlasso lopt(lalt corrnum(0) maxpsiiter(100) c0(0.55))"}{p_end}
{phang2}. {stata "estimates replay _ivlasso_step5_NumProCase"}{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:ivlasso} saves the following in {cmd:e()}:

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{opt e(N)}}sample size{p_end}
{synopt:{opt e(xhighdim_ct)}}number of all high-dimensional controls{p_end}
{synopt:{opt e(zhighdim_ct)}}number of all high-dimensional instruments{p_end}
{synopt:{opt e(N_clust)}}number of clusters in cluster-robust estimation{p_end}
{synopt:{opt e(N_g)}}number of groups in fixed-effects model{p_end}
{synopt:{opt e(ss_gamma)}}significance level in sup-score tests and CIs{p_end}
{synopt:{opt e(ss_level)}}test level in % in sup-score tests and CIs (=100*(1-gamma)){p_end}
{synopt:{opt e(ss_gridmin)}}min grid point in sup-score CI{p_end}
{synopt:{opt e(ss_gridmax)}}max grid point in sup-score CI{p_end}
{synopt:{opt e(ss_gridpoints)}}number of grid points in sup-score CI{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{opt e(cmd)}}pdslasso or ivlasso{p_end}
{synopt:{opt e(depvar)}}name of dependent variable{p_end}
{synopt:{opt e(dexog)}}name(s) of exogenous structural variable(s){p_end}
{synopt:{opt e(dendog)}}name(s) endogenous structural variable(s){p_end}
{synopt:{opt e(xhighdim)}}names of high-dimensional control variables{p_end}
{synopt:{opt e(zhighdim)}}names of high-dimensional instruments{p_end}
{synopt:{opt e(method)}}lasso or sqrt-lasso{p_end}
{synopt:{opt e(ss_null)}}result of sup-score test (reject/fail to reject){p_end}
{synopt:{opt e(ss_null_l)}}result of lasso-orthogonalized sup-score test (reject/fail to reject){p_end}
{synopt:{opt e(ss_null_pl)}}result of post-lasso-orthogonalized sup-score test (reject/fail to reject){p_end}
{synopt:{opt e(ss_cset)}}confidence interval for sup-score test{p_end}
{synopt:{opt e(ss_cset_l)}}confidence interval for lasso-orthogonalized sup-score test{p_end}
{synopt:{opt e(ss_cset_pl)}}confidence interval for post-lasso-orthogonalized sup-score test{p_end}
{synopt:{opt e(ss_method)}}simulate, abound or select{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{opt e(b)}}posted coefficient vector{p_end}
{synopt:{opt e(V)}}posted variance-covariance matrix{p_end}
{synopt:{opt e(beta_pds)}}PDS coefficient vector{p_end}
{synopt:{opt e(V_pds)}}PDS variance-covariance matrix{p_end}
{synopt:{opt e(beta_lasso)}}CHS lasso-based coefficient vector{p_end}
{synopt:{opt e(V_lasso)}}CHS lasso-based variance-covariance matrix{p_end}
{synopt:{opt e(beta_plasso)}}CHS post-lasso-based coefficient vector{p_end}
{synopt:{opt e(V_plasso)}}CHS post-lasso-based variance-covariance matrix{p_end}
{synopt:{opt e(ss_citable)}}sup-score test results used to construct confidence sets{p_end}
{synopt:{opt e(ss_gridmat)}}sup-score test results using user-specified grid{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: functions}{p_end}
{synopt:{opt e(sample)}}{p_end}
{p2colreset}{...}


{marker references}{...}
{title:References}

{marker AR1949}{...}
{phang}
Anderson, T. W. and Rubin, H. 1949.
Estimation of the Parameters of Single Equation in a Complete
System of Stochastic Equations.
{it:Annals of Mathematical Statistics} 20:46-63.
{browse "https://projecteuclid.org/euclid.aoms/1177730090"}
{p_end}

{marker AK1991}{...}
{phang}
Angrist, J. and Kruger, A. 1991.
Does compulsory school attendance affect schooling and earnings?
{it:Quarterly Journal of Economics} 106(4):979-1014.
{browse "http://www.jstor.org/stable/2937954"}
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
Inference in High Dimensional Panel Models with an Application to Gun Control.
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

{marker CHS2015}{...}
{phang}
Chernozhukov, V. Hansen, C., and Spindler, M. 2015.
Post-selection and post-regularization inference in linear models
with many controls and instruments.
{it:American Economic Review: Papers & Proceedings} 105(5):486-490.
{browse "http://www.aeaweb.org/articles.php?doi=10.1257/aer.p20151022"}
{p_end}

{marker SG2016}{...}
{phang}
Correia, S. 2016.
FTOOLS: Stata module to provide alternatives to common Stata commands optimized for large datasets.
{browse "https://ideas.repec.org/c/boc/bocode/s458213.html"}
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
Regression Shrinkage and Selection via the Lasso.
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
To get the latest stable version of {it:lassopack} and {it:pdslasso} from our website, 
check the installation instructions at {browse "https://statalasso.github.io/installation/"}.
We update the website versions more frequently than the SSC version.

{pstd}
To verify that {it:pdslasso} is correctly installed, 
click on or type {stata "whichpkg pdslasso"} (which requires {helpb whichpkg}
to be installed; {stata "ssc install whichpkg"}).

{marker acknowledgements}{title:Acknowledgements}

{pstd}Thanks to Sergio Correia for advice on the use of the FTOOLS package.{p_end}

{marker citation}{...}
{title:Citation of pdslasso and ivlasso}

{pstd}{opt pdslasso} and {opt ivlasso} are not official Stata commands.
They are free contributions to the research community, like a paper.
Please cite it as such:{p_end}

{phang}Ahrens, A., Hansen, C.B., Schaffer, M.E. 2018.
pdslasso and ivlasso: Progams for post-selection and post-regularization OLS or IV estimation and inference.
{browse "http://ideas.repec.org/c/boc/bocode/s458459.html"}{p_end}


{title:Authors}

	Achim Ahrens, Economic and Social Research Institute, Ireland
	achim.ahrens@esri.ie
	
	Christian B. Hansen, University of Chicago, USA
	Christian.Hansen@chicagobooth.edu

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk


{title:Also see}

{p 7 14 2}
Help:  {helpb rlasso}, {helpb lasso2}, {helpb cvlasso} (if installed){p_end}
