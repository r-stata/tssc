{smcl}
{* *! version 1.1.02  3Jan2019}{...}
{cmd:help twostepweakiv}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: twostepweakiv} {hline 2}}Valid two-step identification-robust confidence sets
for instrumental-variable (IV) estimation of linear model{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang}
Standalone estimation (specifying model to be estimated):

{p 8 14 2}
{cmd:twostepweakiv}
{it:estimator}
{it:depvar} [{it:varlist1}]
{cmd:(}{it:varlist2}{cmd:=}{it:varlist_iv}{cmd:)} [{it:weight}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[{cmd:,} {it:project(varlist)}}
{it:test_options} {it:grid_options} {it:size_options} {it: strong_options}]


{synoptset 20}{...}
{synopthdr:estimator}
{synoptline}
{synopt:{opt 2sls}}
two-stage least squares estimator.
{p_end}
{synopt:{opt liml}}
limited-information maximum likelihood estimator.
{p_end}
{synopt:{opt md2s}}
two-step minimum distance estimator.
{p_end}
{synopt:{opt cue}}
continuous updating minimum distance estimator described in Magnusson (2010).
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:test_options}
{synoptline}
{synopt:{opt citestlist(testlist)}}
construct confidence sets for the full parameter vector based on the specified 
tests (AR, K, K_2sls, LC, LC_2sls). If unspecified, default tests are Wald, AR, 
K_2sls, and LC_2sls for {opt 2sls} and {opt liml} estimators; and Wald, AR, 
K, and LC for {opt md2s} and {opt cue} estimators.
{p_end}
{synopt:{opt project(varlist)}}
when there is more than one weak endogenous variable, and we are interested in 
inference for one endogenous regressor β only, we calculate confidence sets 
using the refined projection method for β while treating the 
other endogenous regressors η as free unknown parameters (nuisance parameters.) 
See option strong if we are willing to make additional assumptions about η.
{opt project(varlist)} conducts inference for each of the variable specified in the {it: varlist }
based on the refined projection method. For example,
{opt project(_all)} reports refined projection-based confidence sets
for every weakly-identified coefficient. Unforunately, 
this version of {opt twostepweakiv} does not support
projection-based confidence sets for two endogenous regressors e.g. {opt project2(var1 var2)}
from {helpb weakiv}.
{p_end}
{synopt:{opt ptestlist(project_testlist)}}
construct confidence sets using refined projection method for β specified 
in {opt project} based on the specified 
tests (K, K_2sls, LC, LC_2sls). If unspecified, default tests are Wald and LC_2sls 
for {opt 2sls} and {opt liml} estimators; and Wald and
 LC for {opt md2s} and {opt cue} estimators.
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:grid_options}
{synoptline}

{pmore} {bf:Note:} The default grid is centered around the Wald point estimate
(or the CUE point estimate if the {opt cuepoint} estimate is specified)
with a width equal to five times the Wald confidence interval.
With weak/strong instruments,
this may often be too small/large a grid to estimate the confidence sets.
{p_end}

{synopt:{opt gridmult(#)}}
multiplier of Wald confidence-interval for grid. The default is {cmd:gridmult(5)}.
{p_end}
{synopt:{opt gridmin(numlist)}}
lower limit(s) for grid search (in dimensions corresponding to endogenous regressors).
{p_end}
{synopt:{opt gridmax(numlist)}}
upper limit(s) for grid search (in dimensions corresponding to endogenous regressors).
{p_end}
{synopt:{opt gridpoints(numlist)}}
number(s) of equally spaced grid points (in dimensions corresponding to endogenous regressors)
over which to calculate the confidence sets;
The default number of gridpoints is
100, 25, 11, 7 and 5
for the cases of 1, 2, 3, 4 and 5 endogenous regressors, respectively.
For testing a point null hypothesis e.g. 0, set grid point to 1 and gridmin=gridmax=0.
{p_end}
{synopt:{opt cuepoint}}
report {opt cue} point estimates for weakly-identified endogenous regressors
and include them in grid.
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:size_options}
{synoptline}
{synopt:{opt level(#)}}
confidence level as a percentage (same for all tests performed); 
The default is {cmd:level(95)} for size 5% tests; if specified, {cmd:level(#)} 
with values 99, 95 or 90 allows for faster computation because weights used in {it: LC} and {it:  LC_2sls } tests
are pre-tabulated only for these values. For other values, see {cmd: gammalevel(#)}.
{p_end}
{synopt:{opt gammalevel(#)}}
distortion level for two-step confidence sets based on {it:LC} or {it:LC_2sls} test as a percentage;
The default is {cmd:gammalevel(5)} for a 5% coverage distortion; if specified, 
{cmd: gammalevel(#)} with values 1, 2, 5, 10, 15, or 20 allows for faster computation because weights used in {it: LC} and {it:  LC_2sls } tests
are pre-tabulated only for these values. For values not pre-tabulated, we include simulation code to calculate the corresponding weights and critical values, which can be slow.
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20}{...}
{synopthdr:strong_options}
{synoptline}
{synopt:{opt strong(varlist)}}
specifies strongly-identified endogenous regressors η when there is more than 
one weak endogenous variable, and treats the rest of endogenous regressor β 
as potentially weakly-identified. If unspecified, then all endogenous regressors 
are assumed to be potentially weakly-identified. If strong specified and 
cuestrong is not evoked, then at each grid point β0 
for the potentially weakly-identified endogenous regressor β, 
we calculate {opt md2s} estimates for strongly-identified endogenous 
regressors η under the null hypothesis H0:β=β0. 
We then evaluate test statistics for β, plugging the {opt md2s} estimates 
η in the strongly-identified endogenous regressors.
{p_end}
{synopt:{opt cuestrong}}
uses {opt cue} point estimates for strongly-identified endogenous regressors 
(specified in {opt strong(varlist)}) and include these point estimates in grid. 
That is, at each grid point β0 for the potentially weakly-identified endogenous 
regressor β, we calculate {opt cue} for strongly-identified endogenous regressors
η under the null hypothesis H0:β=β0. 
We then evaluate test statistics for β, plugging the {opt cue} estimates 
η in the strongly-identified endogenous regressors.
Note that this option may be computationally intensive.
{p_end}
{synoptline}
{p2colreset}{...}


{title:Contents}

{phang}{help twostepweakiv##description:Description}{p_end}
{phang}{help twostepweakiv##tests:Tests and confidence sets}{p_end}
{phang}{help twostepweakiv##examples:Examples}{p_end}
{phang}{help twostepweakiv##saved_results:Saved results}{p_end}
{phang}{help twostepweakiv##acknowledgements:Acknowledgements}{p_end}
{phang}{help twostepweakiv##references:References}{p_end}
{phang}{help twostepweakiv##citation:Citation of twostepweakiv}{p_end}

{marker description}{...}
{title:Description}

{pstd}
Building on the existing Stata package {helpb weakiv}, {opt twostepweakiv} construct tests for weak instruments and two-step 
identification-robust confidence sets for the coefficients on endogenous variables 
by comparing non-robust Wald confidence sets to robust confidence sets 
based on the linear combination test proposed by Andrews (2016).

{pstd}
{opt twostepweakiv} can be used to estimate linear IV minimum-distance models.
{opt twostepweakiv} supports a range of variance-covariance estimators for linear IV models
including heteroskedastic-, autocorrelation-, and one- and two-way cluster-robust VCEs.

{pstd}
{opt twostepweakiv} constructs confidence set for the coefficient on endogenous 
variable of interest when there are multiple endogenous variables using a refined 
projection method as in Andrews (2018). 
There are several options available for models with 2 or more endogenous regressors.
(a) The user can specify, using the {opt strong(.)} option,
that some coefficients are strongly identified,
in which case {opt twostepweakiv} will report tests for the
weakly-identified subset of coefficients.
(b) The {opt project(.)} option requests the reporting
of refined projection-based confidence sets
for the specified endogenous regressors. 

{pstd}
{opt twostepweakiv} should be used as a standalone estimator
where the user provides the specification of the model.
{opt twostepweakiv} works by calling {helpb ivreg2} first to parse the specification
and then estimate a minimum-distance model
depending what the user has specified as {it:estimator}.
{opt twostepweakiv} passes all user-specified model estimation options
to the estimation command:
variable lists, VCE specification, estimation method, etc.

{pstd}
{opt twostepweakiv} requires {helpb avar} (Baum and Schaffer 2013) to be installed.
{opt twostepweakiv} will prompt the user for installation of
{helpb avar} if necessary.
{helpb avar} is an essential component and {opt twostepweakiv} will not run without it.
Since {opt twostepweakiv} calls {helpb ivreg2} and {helpb ivreg2} requires ranktest 
to be installed, {opt twostepweakiv} will prompt the user to install it if necessary. 

{pstd}
Estimator notes:

{pstd}
All estimators are formulated as minimum distance (MD) estimators following 
{helpb weakiv} and Finlay and Magnusson (2009). 
We drop the {opt robust} option in {helpb ivreg2} because the choice of estimator 
implies the choice of weight matrix ({opt 2sls} and {opt liml} for inefficient 
weight matrix and {opt md2s} and {opt cue} for efficient weight matrix). 
The choice of VCE estimator is not necessarily the same as the choice of the weight matrix. 
By default, we calculate VCE estimators robust to heteroskedasticity regardless 
of choice of estimator, so that test statistics are robust to heteroskedasticity 
in all cases. Other types of VCE estimators can be specified in {opt cluster} 
for clustered VCE estimator and, {opt kernel} for kernel-based VCE estimator. 
More details can be found in {helpb ivreg2}. 


{marker tests}{...}
{title:Tests and confidence sets}

{pstd}
{opt twostepweakiv} calculates minimum distance (MD)
versions of weak-instrument-robust tests of the coefficients
on the endogenous variables in a linear instrumental variables (IV) estimation.
When the IV model contains more instruments than endogenous regressors
(the model is overidentified),
{opt twostepweakiv} can also conduct the {it:K} test and a linear combination
of {it:K} test and {it:AR} test: the {it:LC}. {opt twostepweakiv} allows 
inefficient weight matrices in {it:K} statistics, which is used to construct 
confidence sets for {opt 2sls} estimators based on {it:K_2sls} or {it:LC_2sls} test. 

{pstd}
In the construction of the MD versions of these tests,
any exogenous regressors are first partialled out.
For further discussion of these tests,
see Andrews (2018),
Finlay and Magnusson (2009),
Kleibergen (2002, 2005),
Magnusson (2010),
and the references therein.

{pstd}
The {it:LC} test combines the {it:K} and {it:AR} statistics.
Unlike the {it:K} test,
the {it:LC} test does not suffer from the problem of spurious power losses.
It can also be used to construct valid two-step identification-robust
confidence sets proposed by Andrews (2018).
For more details on how to construct the {it:LC} or {it:LC_2sls} test, 
see the documentation. The default behavior of {opt twostepweakiv} is to set the
 size of all tests at 5%. For valid two-step identification-robust
confidence sets, the default behavior is to set the distortion cutoff at 5%.

{marker closedform}{...}
{pstd}
{opt twostepweakiv} inverts the above tests to obtain and report
 identification-robust confidence sets by grid search.

{pstd}
{opt twostepweakiv} can also accommodate models with multiple endogenous regressors,
where some coefficients are weakly identified and some are strongly identified.
{opt twostepweakiv} supports this via the {opt strong(.)} and
{opt project(.)} options.

{pstd}
The {opt strong(.)} option essentially removes the strongly-identified coefficients from the testing,
and {opt twostepweakiv} reports tests and confidence sets 
for the remaining weakly-identified coefficient(s).
Testing in this case follows the method of Kleibergen (2004);
see Mikusheva (2013) for a concise description.
Briefly, the method uses the standard formulae for weak-identification-robust statistics,
but for the strongly-identified coefficients replaces hypothesized values
with estimates obtained under the null from an efficient estimator.
The default efficient estimators are  2-step efficient MD;
the {opt cuestrong} replaces these with
the CUE estimators
(note that the CUE estimator requires numerical optimization
and grid searches in particular will be slow with this option).
To obtain confidence sets,
the procedure is repeated for each hypothesized value
of the weakly-identified coefficient(s).

{pstd}
The {opt project(.)} option implements refined projection-based
confidence sets for the listed weakly-identified endogenous variable.
Unlike the conventional projection method, we alter test statistic 
(specifically the {it:K} statistic) to focus inference for the listed weakly-identified endogenous variable. 
Thus we refer to this method the refined projection method. 
See Chaudhuri and Zivot (2011) and Andrews (2018) for a discussion and references.
The refined projection-based confidence sets implemented by
{opt twostepweakiv} require grid search.
To get an accurate projection-based CI for a variable,
the user should specify a suitably large number of grid points
in that dimension.

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta"}{p_end}
{phang2}. {stata gen byte poshours=(hours>0)}{p_end}

{pstd}Constructs a valid two-step identification-robust confidence set for {cmd:educ} 
in the {cmd:lwage} equation based on Wald and LC_2sls tests (default is LC_2sls
due to 2sls estimator, which uses inefficient weight matrix). Confidence sets
based on AR and K_2sls tests are also reported.{p_end}

{phang2}. {stata twostepweakiv 2sls lwage exper expersq (educ = fatheduc motheduc)}{p_end}

{pstd}Constructs valid two-step identification-robust confidence sets
for two weakly-identified endogenous regressors respectively based on refined projection method; 
Report CUE and center grid on CUE point estimator.{p_end}

{phang2}. {stata twostepweakiv 2sls lwage exper expersq (educ hours = fatheduc motheduc kidslt6 kidsge6), cuepoint project(_all)}{p_end}

{pstd}Constructs valid two-step identification-robust confidence sets
for two weakly-identified endogenous regressors respectively based on conventional
 projection method, with a grid of 10x15=900 points.
Note how the projection-based CI for educ corresponds to the range of the x axis under the confidence set,
and the projection-based CI for exper corresponds to the range of the y axis to the left of the confidence set.{p_end}

{phang2}. {stata twostepweakiv 2sls lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), citestlist(lc_2sls) gridpoints(10 15)}{p_end}

{pstd}
Note that the conventional projection-based confidence set for {cmd:educ} is
output as the range of the x axis under the joint confidence set, which can be calculated
by the following code.
The conventional projection-based confidence set for {cmd:exper}  corresponds to 
the range of the y axis under the joint confidence set, which can be calculated similarly.{p_end}

	{cmd:matrix table = e(citable)}
	{cmd:matrix p1citable = J(10,2,.) //create a matrix with grid points of educ and rejection indicator}
	{cmd:matrix colnames p1citable = null1 lc_2sls_r}
	{cmd:forval i = 1/10 {c -(}}
	{cmd:	local r1=15*(`i'-1)+1 //for each grid point of x, there are 15 grid points of y}
	{cmd:	local r2=15*(`i')}
	{cmd:	matrix p1citable[`i',1]=table[`r1',"null1"]}
	{cmd:	matrix lc_2sls_r_vector = table[`r1'..`r2',"lc_2sls_r"]}
	{cmd:	mata: st_matrix("r",sum(st_matrix("lc_2sls_r_vector")):==15) //a grid point x0 is rejected if all grid points of (x0,y) are rejected}
	{cmd:	matrix p1citable[`i',2]=r}
	{cmd:{c )-}}
	{cmd:matrix list p1citable}
	
	{cmd:matrix table = e(citable)}
	{cmd:local citablerowname : colfullnames table}
	{cmd:mata : st_matrix("table", sort(st_matrix("table"), 2)) //citable is sorted by grid points of x, now need to resort by y}
	{cmd:matrix colnames table = `citablerowname'}
	{cmd:matrix p2citable = J(15,2,.) //create a matrix with grid points of educ and rejection indicator}
	{cmd:matrix colnames p2citable = null2 lc_2sls_r}
	{cmd:forval i = 1/15 {c -(}}
	{cmd:	local r1=10*(`i'-1)+1 //for each grid point of y, there are 10 grid points of x}
	{cmd:	local r2=10*(`i')}
	{cmd:	matrix p2citable[`i',1]=table[`r1',"null2"]}
	{cmd:	matrix lc_2sls_r_vector = table[`r1'..`r2',"lc_2sls_r"]}
	{cmd:	mata: st_matrix("r",sum(st_matrix("lc_2sls_r_vector")):==10) //a grid point y0 is rejected if all grid points of (x,y0) are rejected}
	{cmd:	matrix p2citable[`i',2]=r}
	{cmd:{c )-}}
	{cmd:matrix list p2citable}

{pstd}


{pstd} Request test of specific point null: education coeff=0.1 and exper coeff=0.05.
Test statistics and p-values (if calculated) are reported in {cmd:e(citable)}.{p_end}

{phang2}. {stata twostepweakiv md2s lwage (educ exper = fatheduc motheduc kidslt6 kidsge6), gridmin(0.1 0.05) gridmax(0.1 0.05) gridpoints(1 1) citestlist(ar k lc)}{p_end}
{phang2}. {stata matrix list e(citable)}{p_end}

{pstd}Constructs valid two-step identification-robust confidence sets
for {cmd:hours} while {cmd:educ} assumed strongly identified.
{p_end}

{phang2}. {stata twostepweakiv 2sls lwage exper expersq (educ hours = fatheduc motheduc kidslt6 kidsge6), strong(educ) }{p_end}

{pstd}Specify a test level of 90% and a distortion cutoff of 10% .{p_end}

{phang2}. {stata twostepweakiv 2sls lwage exper expersq (educ = fatheduc motheduc), level(90) gammalevel(10)}{p_end}

{pstd}Time-series setup{p_end}

{phang2}. {stata clear}{p_end}
{phang2}. {stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta"}{p_end}
{phang2}. {stata tsset year, yearly}

{pstd}Constructs a valid two-step identification-robust confidence set for {cmd:unem} 
based on Wald and LC_2sls tests (default is LC_2sls
due to 2sls estimator, which uses inefficient weight matrix). Confidence sets
based on AR and K tests are also reported. Tests are calculated with the Newey-Set HAC covariance 
estimator with bandwidth equal to 3.{p_end}

{phang2}. {stata twostepweakiv 2sls cinf (unem = l(1/3).unem), bw(3)}{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:twostepweakiv} saves the following in {cmd:e()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:e(kwt)}}weight on {it:K} in {it:K-J} test{p_end}
{synopt:{cmd:e(endo_ct)}}number of endogenous regressors{p_end}
{synopt:{cmd:e(wendo_ct)}}number of weakly-identified endogenous{p_end}
{synopt:{cmd:e(sendo_ct)}}number of strongly-identified endogenous{p_end}
{synopt:{cmd:e(overid)}}degree of overidentification{p_end}
{synopt:{cmd:e(small)}}=1 if small-sample adjustments used, =0 otherwise{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters (if cluster-robust VCE used){p_end}
{synopt:{cmd:e(ar_level)}}level in percent used for {it:AR} confidence interval{p_end}
{synopt:{cmd:e(k_level)}}level in percent used for {it:K} confidence interval{p_end}
{synopt:{cmd:e(wald_level)}}level in percent used for {it:Wald} confidence interval{p_end}
{synopt:{cmd:e(gamma_level)}} gamma_min used for {it:LC_2sls} confidence interval{p_end}
{synopt:{cmd:e(gamma_hat)}} distortion cutoff for {it:LC_2sls} confidence interval{p_end}
{synopt:{cmd:e(points)}}number of points in grid used to estimate confidence sets{p_end}
{synopt:{cmd:e(clrsims)}}number of draws used in simulations to obtain p-values for CLR test{p_end}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Macros}{p_end}
{synopt:{cmd:e(ar_cset)}}confidence set based on {it:AR} test{p_end}
{synopt:{cmd:e(k_cset)}}confidence set based on {it:K} or {it:K_2sls} test{p_end}
{synopt:{cmd:e(wald_cset)}}confidence set based on Wald test{p_end}
{synopt:{cmd:e(lc_cset)}}confidence set based on LC or LC_2sls test{p_end}
{synopt:{cmd:e(pxx_yy_cset)}}as above, projection-based confidence set for variable xx, test yy{p_end}
{synopt:{cmd:e(inexog)}}list of exogenous regressors (excluding any included in the tests){p_end}
{synopt:{cmd:e(exexog)}}list of excluded instruments{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(endo)}}endogenous variable(s){p_end}
{synopt:{cmd:e(wendo)}}weakly-identified endogenous variable(s){p_end}
{synopt:{cmd:e(sendo)}}strongly-identified endogenous variable(s){p_end}
{synopt:{cmd:e(pwendo)}}endogenous vars with projection-based confidence sets{p_end}
{synopt:{cmd:e(pwendo_nlist)}}corresponding numbers for e(pwendo); used to identify projection-based confidence sets in e(.) (see above){p_end}
{synopt:{cmd:e(gridpoints)}}list of grid points in each dimension{p_end}
{synopt:{cmd:e(model)}}{it:linear IV}{p_end}
{synopt:{cmd:e(waldcmd)}}{it:iv_command} estimator used to estimate standard IV model: {it:2sls}, {it:md2s},{it:liml} or {it:cue}{p_end}
{synopt:{cmd:e(level)}}default confidence level in percent used for tests of null = 100*(1-alpha){p_end}
{synopt:{cmd:e(method)}} md{p_end}
{synopt:{cmd:e(cmd)}}twostepweakiv{p_end}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Matrices}{p_end}
{synopt:{cmd:e(citable)}}table with test statistics, p-values, and rejection
indicators for every grid point over which hypotheses are tested.
If {opt strong(.)} is used, the estimated coefficients
for the strongly-identified regressors are also recorded.{p_end}
{synopt:{cmd:e(pxxcitable)}}grid table with rejection indicators
for projection-based inference;
xx will be 1 or 2 numbers corresponding to the endogenous regressor(s){p_end}
{synopt:{cmd:e(F)}}first stage F statistics for all endogenous regressors.{p_end}
{synopt:{cmd:e(wbeta)}}weakly-identified coefficients from IV model used for Wald tests{p_end}
{synopt:{cmd:e(var_wbeta)}}VCE from IV model used for Wald tests{p_end}
{synopt:{cmd:e(sbeta)}}if {opt strong(.)} is used, estimated strongly-identified coefficients at null{p_end}
{synopt:{cmd:e(ebeta)}}Wald point estimates for full set of endogenous regressors{p_end}
{synopt:{cmd:e(cuebeta)}}if {opt cuepoint} is used, CUE point estimates for full set of endogenous regressors{p_end}
{p2colreset}{...}


{marker acknowledgements}{...}
{title:Acknowledgements}
{pstd}
{opt twostepweakiv} builds on and extends the command {helpb weakiv} by Finlay, Magnusson and Schaffer  (2013).
The main differences and extensions are:
(a) construct valid two-step identification-robust confidence sets based on Andrews (2018) for MD models;
(b) implement linear combination test based on Andrews (2016) and support K test with inefficient weight matrix;
(c) support for MD versions of estimators and tests;
(d) support for refined projection-based inference;
(e) changes in terminology, syntax etc.




{marker references}{...}
{title:References}

{marker A2016}{...}
{phang}
Andrews, I.  2016.
Conditional Linear Combination Tests for Weakly Identified Models.
{it:Econometrica} 84(6):21552182.
{p_end}

{marker A2018}{...}
{phang}
Andrews, I.  2018.
Valid Two-Step Identification-Robust Confidence Sets for GMM.
{it:Review of Economics and Statistics} 100 (2) :337-348.
{p_end}

{marker AR1949}{...}
{phang}
Anderson, T. W. and Rubin, H. 1949.
Estimation of the Parameters of Single Equation in a Complete
System of Stochastic Equations.
{it:Annals of Mathematical Statistics} 20:4663.
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
On the Asymptotic Sizes of Subset AndersonRubin and Lagrange Multiplier Tests
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
{title:Citation of twostepweakiv}

{pstd}{opt twostepweakiv} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Sun, L., 2018.
twostepweakiv: valid two-step identification-robust confidence sets
for instrumental-variable (IV) estimation of linear models.
{browse "https://github.com/lsun20/TwoStep":https://github.com/lsun20/TwoStep}.

{title:Author}

	Liyang Sun, MIT, USA
	lsun20@mit.edu


{p 7 14 2}
Help:  {helpb ivreg2}, {helpb weakiv}{p_end}

