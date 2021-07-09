{smcl}
{* *! version 1.0.1  14apr2020}{...}

{title:Title}

{p2colset 5 19 19 2}{...}
{p2col :{hi:qrprocess} {hline 2}}Quantile regression: fast algorithms, pointwise and uniform inference{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmd:qrprocess} {depvar} [{indepvars}] {ifin} 
[{it:{help qrprocess##weight:weight}}]
	[{cmd:,} {it:{help qrprocess##options:options}}]

{synoptset 30 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{syntab :Quantiles to be estimated}
{synopt :{opth q:uantile(numlist)}} specifies the quantile(s) to be estimated; default value is 0.5 (the median) except if the option {cmd:functional} is activated.{p_end}

{syntab:Algorithmic method}
{synopt :{opt m:ethod}{cmd:(}[{it:{help qrprocess##mtype:mtype}}]{cmd:,} [{it:{help qrprocess##mopts:mopts}}]{cmd:)}} specifies the algorithmic method used to compute the quantile regression estimates as well as the parameters governing the algorithm.{p_end}

{syntab:Inference}
{synopt :{opt v:ce}{cmd:(}[{it:{help qrprocess##vtype:vtype}}]{cmd:,} [{it:{help qrprocess##vopts:vopts}}]{cmd:)}} specifies the technique used to estimate standard errors (variance-covariance matrix of the estimates).{p_end}
{synopt :{opt f:unctional}} activates the tools for functional inference (uniform confidence bands, test of functional hypotheses).{p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}sets confidence level; default is {cmd:level(95)}.{p_end}
{synopt :{opt noprint}}suppresses display of the results.{p_end}
{synoptline}
{p2colreset}{...}


{synoptset 26}{...}
{marker mtype}{...}
{synopthdr :mtype}
{synoptline}
{synopt :{opt qreg}}selects the built-in Stata algorithm used by the official command {cmd:qreg}; the default for sample sizes below 10,000 observations when less than 10 quantile regressions must be estimated.{p_end}
{synopt :{opt fn}}selects a basic implementation of the Frisch-Newton interior point method suggested by {help qrprocess##Portnoy_Koenker_1997:Portnoy and Koenker (1997)}.{p_end}
{synopt :{opt pqreg}}selects the built-in Stata algorithm after the preprocessing step suggested by {help qrprocess##Portnoy_Koenker_1997:Portnoy and Koenker (1997)}.{p_end}
{synopt :{opt pfn}}selects the Frisch--Newton interior point method after the preprocessing step suggested by {help qrprocess##Portnoy_Koenker_1997:Portnoy and Koenker (1997)}; the default for sample sizes above 10,000 observations when less than 10 quantile regressions must be estimated.{p_end}
{synopt :{opt proqreg}}selects the built-in Stata algorithm after the preprocessing step based on the previously estimated quantile regression (preprocessing for the quantile regression process).{p_end}
{synopt :{opt profn}}selects the Frisch--Newton interior point method after the preprocessing step based on the previously estimated quantile regression (preprocessing for the quantile regression process); the default for sample sizes below 50'000 when at least 10 quantile regressions are estimated.{p_end}
{synopt :{opt 1step}}selects the one-step estimator that uses a first-order approximation from one quantile regression to the next; the default for sample sizes above 50'000 when at least 10 quantile regressions are estimated.{p_end}
{synoptline}
{p2colreset}{...}


{synoptset 26}{...}
{marker mopts}{...}
{synopthdr :mopts}
{synoptline}
{synopt :{opt beta(#)}}technical step length parameter used by the {cmd:fn} method; default value is 0.9995.{p_end}
{synopt :{opt small(#)}}tolerance parameter for convergence used by the {cmd:fn} method; default value is 0.00001.{p_end}
{synopt :{opt max_it(#)}}maximum number of iterations for {cmd:fn} method; default value is 100.{p_end}
{synopt :{opt m(#)}}adjustement parameter used by the preprocessing algorithms; default value is 3.{p_end}
{synopt :{opt e:rror_tol(#)}} integer determining the number of allowed mispredicted signs of residuals for the methods involving preprocessing and for the {cmd:bootstrap}. The default value is 0.{p_end}
{synopt :{opt f:irst(mtype)}}selects the algorithm for the first quantile regression when the method is {cmd: proqreg}, {cmd:profn} or {cmd:1step}. {p_end}
{synoptline}
{p2colreset}{...}


{synoptset 26}{...}
{marker vtype}{...}
{synopthdr :vtype}
{synoptline}
{synopt :{opt ker:nel}}selects the kernel estimates of the VCE suggested by {helpb qrprocess##Powell_91:Powell (1991)}; the default when functional tests and confidence bands are not requested.{p_end}
{synopt :{opt nid}}selects the estimate of the VCE suggested by Hendricks and Koenker (1992).{p_end}
{synopt :{opt boot:strap}}selects a bootstrap method; the default when functional tests and confidence bands are requested.{p_end}
{synopt :{opt mult:iplier}}multiplier bootstrap estimates of the VCE.{p_end}
{synopt :{opt iid}}selects an estimate of the VCE that assumes iid standards errors. Not recommended!{p_end}
{synopt :{opt novar}}does not compute the VCE.{p_end}
{synoptline}
{p2colreset}{...}


{synoptset 26}{...}
{marker vopts}{...}
{synopthdr :vopts}
{synoptline}
{synopt :{opt b:ofinger}}selects Bofinger's bandwidth. By default, Hall-Sheather's bandwidth is used.{p_end}
{synopt :{opt miss:pecification}}selects the {help qrprocess##angrist_et_al_2006:Angrist, Chernozhukov and Fernández-Val (2006)} estimator of the variance, which is robust against misspecification.{p_end}
{synopt :{opt c:luster(varname)}}cluster identification variable.{p_end}
{synopt :{opt s:trata(varname)}}strata identification variable.{p_end}
{synopt :{opt bm:ethod}{cmd:(}{it:{help qrprocess##bmethod:bmethod}}{cmd:)}}bootstrap method.{p_end}
{synopt :{opt r:eps(#)}}number of bootstrap replications; default value is 100.{p_end}
{synopt :{opt nor:eplacement}}subsampling only: performs subsampling without replacement; default is subsampling with replacement.{p_end}
{synopt :{opt s:ubsize(#)}}subsampling only: size of the subsamples.{p_end}
{synopt :{opt f:unctional}}requests functional inference results.{p_end}
{synoptline}
{p2colreset}{...}


{synoptset 26}{...}
{marker bmethod}{...}
{synopthdr :bmethod}
{synoptline}
{synopt :{opt empirical}}uses the empirical bootstrap; the default with {cmd: vce(bootstrap)}.{p_end}
{synopt :{opt subsampling}}uses subsampling.{p_end}
{synopt :{opt weighted}}uses the weighted bootstrap with standard exponential weights; can only be used with {cmd: vce(bootstrap)}.{p_end}
{synopt :{opt wild}}uses the wild bootstrap; the default with {cmd: vce(multiplier)}; can only be used with {cmd: vce(multiplier)}.{p_end}
{synopt :{opt Gaussian}}uses Gaussian weights; can only be used with {cmd: vce(multiplier)}.{p_end}
{synopt :{opt weighted}}uses centered standard exponential weights; can only be used with {cmd: vce(multiplier)}.{p_end}
{synoptline}
{p2colreset}{...}


{phang}{cmd:by} is allowed with {cmd:qrprocess}.{p_end}
{marker weight}{...}
{phang}{cmd:qrprocess} allows {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s; see {help weight}.{p_end}
{phang}See {helpb qrprocess_postestimation:qrprocess postestimation} for features available after estimation.


{marker description}{...}
{title:Description}

{pstd}
{cmd:qrprocess} fits linear quantile regression models. This commands implements several algorithms, including new algorithms that are much quicker than
the built-in Stata commands, especially for big data or when a large number of regressions or bootstrap replications must be estimated. {cmd:qrprocess} also provides 
analytical estimates of the variance-covariance matrix of the coefficients for several regressions allowing for weights, clustering and stratification. In addition
to traditional pointwise confidence intervals, these commands also provide functional confidence bands and tests of functional hypotheses.
{it:depvar} is the dependent variable. {it:indepvar} the regressor(s). The quantile(s) to be estimated are determined by the option {cmd:quantile}.
The algorithmic method used to obtain the estimates is determined by the option {cmd:method}.
The pointwise standard errors and confidence intervals are calulated according to the option {cmd:vce}.
Functional tests and confidence bands are provided if the option {cmd:functional} is activated.

{pstd}  
See {helpb plotprocess:plotprocess} to easily plot the coefficients and their confidence intervals.

{pstd}  
The new algorithms have been suggested in {helpb qrprocess##CFM_emec:Chernozhukov, Fernández-Val and Melly (2020a)}.  For more detailed information about the Stata command, please refer 
to {helpb qrprocess##CFM_Stata: Chernozhukov, Fernández-Val and Melly (2020b)}. 

{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}{opt quantile(#)} specifies the quantile(s) to be estimated.
 This is either a number between 0 and 1 or a list of numbers between 0 and 1.
 All the shorthands described in {helpb numlist:[U] 11.1.8} numlist can be used;
 for instance {cmd:quantile}(0.1(0.05)0.9) is allowed.
 The default value is 0,5 if the option {cmd:functional} is not activated.
 When {cmd:functional} is activated, the default is a grid with meshsize 0.01.
 The range of the grid depends on the sample size and the number of regressors. This avoids going too far into the tails when working with moderate sample sizes.

{phang}{opt qlow(#)},{opt qhigh(#)},{opt qstep(#)} can also be used to specify the quantiles to be estimated.
 It is equivalent to quantile(qlow(qstep)qhigh). This alternative is offered only to circumvent the maximum size of a matrix or of a numeric list in Stata.
 These limits, which may be an issue when a large number of quantile regressions are estimated, are not binding in Mata.
 
{dlgtab:Algorithmic Method}

{phang}{cmd:method(}[{it:{help qrprocess##mtype_detail:mtype}}]{cmd:,} [{it:{help qrprocess##mopts_detail:mopts}}]{cmd:)}
specifies the algorithmic method used to compute the quantile regression
estimates as well as the parameters governing the algorithm.

{phang2}
{marker mtype_detail}
{it:mtype} specifies the type of algorithmic method used to compute the point estimates. Available types are {cmd:qreg}, 
{cmd:fn}, {cmd:pqreg}, {cmd:pfn}, {cmd:proqreg}, {cmd:profn}, and {cmd:onestep}.
 The default method tries to select the fastest algorithm for the problem at hand.

{phang3}
{cmd:method(qreg)}, selects the built-in Stata algorithm used by the official command {cmd: qreg}. 
If several quantile regressions are being estimated, {cmd: qrprocess } uses the estimates of the previous quantile
regression as starting values for the next quantile regression. This already decreases the computing time compared
to sequential call of {cmd: qreg}.
 It is based on the quantile regression estimator suggested by {help qrprocess##Koenker_Bassett_1978:Koenker and Bassett (1978)}. The minimization problem solved by the estimator can be written as a convex linear program.
 This kind of problem can be relatively efficiently solved with some form of the simplex algorithm.
 The linear programming problem is a constrained optimization problem.
 The feasible region is defined by the intersection of half-planes, and so it is a convex set.
 The optimum for the problem must lie on the boundary of this feasible region.
 The simplex begins with a feasible point at one of the vertices of the feasible set.
 Then it "walks" along the edges of the feasible set from vertex to vertex, in such a way that the value of the objective function monotonically decreases at each step.
 For this reason, it is an exterior point algorithm.
 The simplex algorithm performs extremely well for problems of moderate size but requires as much as 150 times the computational time of OLS for a sample size of 50,000.

{phang3}
{cmd:method(fn)}, selects a basic implementation of the Frisch-Newton interior point method suggested by {help qrprocess##Portnoy_Koenker_1997:Portnoy and Koenker (1997)}.
 Unlike simplex, interior point algorithms actually begin in the interior of the feasible region of the linear programming program, and travels on a path towards the the boundary, converging at the optimum.
 The inequality constraints are replaced by a barrier that penalizes points that are close to the boundary of the feasible set.
 Since this barrier idea was pioneered by Ragnar Frisch and each iteration corresponds to a Newton step, {help qrprocess##Portnoy_Koenker_1997:Portnoy and Koenker (1997)} call their application of the interior point method to quantile regression the Newton-Frisch algorithm.
 This method is significantly faster for middle to large sample sizes.
 
{phang3}
{cmd:method(pqreg)} & {cmd:method(pfn)}, selects respectively the built-in {cmd:qreg} exterior point method or the Frisch-Newton ({cmd:fn}) interior point method after the {cmd:preprocessing} step suggested by {help qrprocess##Portnoy_Koenker_1997:Portnoy and Koenker (1997)}.
 Using preprocessing allows us to build a faster algorithm for big sample sizes.
 Preprocessing uses preliminary knowledge of the sign of the residuals in order to speed up the estimation process.
 The quantile regression fitted line interpolates at least {it:k} data points (where {it:k} is the number of covariates).
 It can easily be shown that the quantile regression estimates are numerically identical if we change the values of the observations that are not interpolated as long as they remain on the same side of the regression line.
 The sign of the residuals is the only thing that matters in the determination of the estimates.
 This explains why the quantile regression estimator is influenced only by the local behavior of the conditional distribution of the response near the specified quantile and is robust to outliers in the response variable.
 Following an idea in {help qrprocess##Portnoy_Koenker_1997:Portnoy and Koenker (1997)}, we exploit this property to design a quicker algorithm.
 Before proceeding to the main estimations, we start by estimating an initial quantile regression using only a subsample.
 This allows us to guess the sign of the residuals in the whole sample.
 Using this information, we can accelerate the estimation process. 

{phang3}
{cmd:method(proqreg)} and {cmd:method(profn)} estimates the discretized quantile regression process using respectively {cmd:qreg} or {cmd:fn} after the preprocessing step based on
the previously estimated quantile regression (preprocessing for the quantile regression process).
When many quantile regressions are estimated, then we can start with a conventional algorithm  (specified by the suboption {cmd:first}) for the first quantile regression and then
progressively climb over the conditional quantile function, using recursively the previous quantile regression as a guess for the next one. This algorithm
provides numerically the same estimate as the traditional algorithms because we can check if the guesses were correct and stop only if this is the case. 
 This drastically speeds up the estimation process when the estimation is required for many quantiles.

{phang3}
{cmd:method(1step)},  estimates the discretized quantile regression process using one-step iteration.
Note that, contrarily to the other algorithm, this method does not exactly minimizes the quantile objective function
of {help qrprocess##Koenker_Bassett_1978:Koenker and Bassett (1978)}. Thus, the point estimates may differ when this method is used. However,
asymptotically, it converges to the same true if a growing number of quantile regressions is estimated.
Thus, this algorithm is intended to estimate a large number of quantile regressions.
The first regression (for the quantile that is the closest to the median) is estimated using a traditional algorithm (specified by the suboption {cmd:first}).
Then, sequentially, the other quantile regressions are obtained by iterating only one-time starting from the previous quantile regression. 
This is the quickest method with large samples when many quantile regressions are estimated.
 
{phang2}
{marker mopts_detail}
{it:mopts} consists of the following options: {cmd:beta(#)}, {cmd:small(#)}, {cmd:max_it(#)}, {cmd:m(#)}, and {cmd:error_tol(#)}.
 These options are technical in nature and should not be modified if the user does not understand the details of the algorithms. 
 
{phang3}
{cmd:beta(#)} is a technical step length parameter used by the Frisch-Newton interior point method. The default value is 0.9995.

{phang3}
{cmd:small(#)} is tolerance parameter for convergence of the Frisch-Newton interior point method. The default value is 0.00001.

{phang3}
{cmd:max_it(#)} specifies the maximum number of iterations for the Frisch-Newton interior point method. The default value is 100.

{phang3}
{cmd:m(#)} is the constant {it:m} used to determine the subsample size for the methods involving preprocessing ({cmd:pqreg},{cmd:pfn},{cmd:proqreg} and {cmd:profn}).
 The default value is 3.

{phang3}
{cmd:error_tol(#)} is an integer that determines the number of allowed mispredicted signs of residuals for the methods involving preprocessing ({cmd:pqreg},{cmd:pfn},{cmd:proqreg} and {cmd:profn}) along with the {cmd:bootstrap}.
 The default value is 0.

{phang3}
{cmd:first(algorithm)} selects the algorithm for the first quantile regression when the method is {cmd:proqreg}, {cmd:profn} or {cmd:1step}.
 It matters only for the first quantile regression when the whole quantile regression process is estimated.
 The following algorithms are available: {cmd:qreg}, {cmd:fn}, {cmd:pqreg}, and {cmd:pfn}.
 
{dlgtab: Variance Covariance Matrix of the Estimates (VCE)}

{phang}{cmd:vce(}[{it:{help qrprocess##vcetype_detail:vcetype}}]{cmd:,} [{it:{help qrprocess##vceopts_detail:vceopts}}]{cmd:)}
selects the method  to compute the VCE and the options related to the estimation of the variance.

{phang2}
{marker vcetype_detail}
{it:vcetype} selects the estimator of the VCE. Available types are {cmd:kernel},{cmd:nid}, {cmd:bootstrap}, {cmd:multiplier}, {cmd:iid} and {cmd:novar}.

{phang3}
{cmd:vce(kernel)}, selects a kernel estimate of the VCE as proposed by {help qrprocess##Powell_91:Powell (1991)}.
 This is the default {it:vcetype} when functional tests and confidence bands are not requested.
 This method combines relatively good performance with short computation time.
 In our simulations, however, the bootstrap offered an even better performance.

{phang3}
{cmd:vce(nid)}, selects the estimate of the VCE suggested by {help qrprocess##Hendricks_Koenker_1992:Hendricks and Koenker (1992)}, which use a local estimate of the sparsity.
 This method is reliable but requires estimating two additional quantile regressions, and is therefore slower than {cmd: kernel}.

{phang3}
{cmd:vce(bootstrap)}, computes bootstrap estimates of the VCE.
 Estimating the VCE analytically requires the choice of a smoothing method and a bandwidth. To avoid this choice, it is popular to use resampling methods.
 {help qrprocess##Chernozhukov_et_al_2013:Chernozhukov, Fernández-Val and Melly (2013)} proved the validity of the exchangeable bootstrap for the (entire) quantile regression process.
 The exchangeable bootstrap covers the {cmd:empirical}, {cmd:weighted}, {cmd:subsampling} without replacement, and {it:m} out of {it:n} bootstraps ({cmd:subsampling} with replacement) as special cases.
 All these special cases have been implemented in qrprocess. The specific resampling method can be determined with the suboption {it:bmethod}.
 By default, the standard empirical bootstrap is used: {it:n} observations are sampled with replacement from the sample of size {it:n}.

{phang3}
{cmd:vce(multiplier)}, estimates the variance by bootstrapping the first-order approximation of the quantile regression estimates.
The multiplier bootstrap takes less time to compute because it does not involve reestimating
the whole quantile regression process for each bootstrap draw, as it is the case when {vce(bootstrap)}. The first-order approximation is computed once and is
mutiplied with independent bootstrap weights. By default, the wild bootstrap is used but Gaussian or re-centered exponential weights
can also be used as well as the empirical bootstrap or sub-sampling.
 
{phang3}
{cmd:vce(iid)}, computes the VCE assuming iid standard errors. 
 We do not recommend using this method except if the researcher has very good reasons to believe in the location shift model.
 In such a case all quantile regression lines are parallel. This means that this methodolgy is not consistent exactly when quantile regression is interesting.

{phang3}
{cmd:vce(novar)}, does not compute the VCE. This option should be used if only the point estimates are of interest.

{phang2}
{marker vceopts_detail}
{it:vceopts} provides further options related to the computation of the variance.
It consists of the following options: {cmd:bofinger}, {cmd:misspecification}. {cmd:cluster(}{it:varname}{cmd:)}, {cmd:strata(}{it:varname}{cmd:)}, {cmd:bmethod(}{it:bmethod}{cmd:)}, {cmd:reps(#)}, {cmd: subsize(#)}, {cmd:noreplacement}.

{phang3}
{opt b:ofinger}, selects {help qrprocess##bofinger_1975:Bofinger (1975)} bandwidth. By default, {help qrprocess##Hall_Sheather_1988:Hall-Sheather (1988)} bandwidth is used. This option is not relevant if {cmd:bootstrap} is chosen.

{phang3}
{opt miss:pecification}, selects the {help qrprocess##angrist_et_al_2006:Angrist, Chernozhukov and Fernández-Val (2006)} estimator of the variance, which is robust against misspecification of the conditional quantile function. This option is relevant for the {cmd:kernel} and {cmd:nid} estimators of the VCE.

{phang3}
{opt c:luster(varname)}, specifies that the standard errors allow for intragroup correlation, relaxing the usual requirement that the observations be independent. That is, the observations are independent across groups (clusters) but not necessarily within groups. The numeric cluster {it:varname} variable specifies to which group each observation belongs.

{phang3}
{opt s:trata(varname)}, specifies that the sampling was stratified. This means that the population was divided into non-overlapping strata and pre-specified numbers of observations were sampled from each stratum. The numeric strata {it:varname} variable specifies to which stratum each observation belongs.

{marker bmethod_detail}
{phang3}
{opt bm:ethod(bmethod)} selects the bootstrap method.  The following values for {it:bmethod} are available when {cmd:vce(bootstrap)} has been chosen: {cmd:empirical} (the default), {cmd:weighted}, and {cmd:subsampling}. The following values for {it:bmethod} are available when {cmd:vce(multiplier)} has been chosen: {cmd:wild} (the default), {cmd:exponential}, {cmd:Gaussian}, {cmd:empirical}, and {cmd:subsampling}.

{p 16 20 2}{cmd:empirical} uses the standard empirical bootstrap. This is the default option .

{p 16 20 2}{cmd:subsampling} uses subsampling with replacement, also called {it:m} out of {it:n} bootstrap.

{p 16 20 2}{cmd:weighted} uses the weighted bootstrap.
For each bootstrap replication, instead of resampling the observations from the sample, all observations are kept and weighted. The weights are drawn independently from the standard exponential distribution.
One advantage of the weighted bootstrap is that no perfect mutlicolinearity problem can appear for any bootstrap replication.
Since all the bootstrap weights are always strictly positive, the rank of the regressors matrix will remain the same in each of the boostrap replication.
As a resullt, the weighted bootstrap is particularly appropriate when some regressors are indicators of rare characteristics.

{p 16 20 2}{cmd:wild} uses wild bootstrap. This option can be used only when the {cmd:multiplier} bootstrap has been selected.

{p 16 20 2}{cmd:exponential} uses recentered standard exponential weights. This option can be used only when the {cmd:multiplier} bootstrap has been selected.

{p 16 20 2}{cmd:Gaussian} uses Gaussian weights. This option can be used only when the {cmd:multiplier} bootstrap has been selected.

{phang3}
{opt r:eps(#)}, specifies the number of bootstrap replications to be performed. The default is 100. 

{phang3}
{opt nor:eplacement} specifies that the resampling should be done without replacement. This method is not recommended.
 It is crucial to specify a small subsample size (much smaller than the sample size) when this option is activated.
 This option is relevant only if {cmd:bmethod(subsampling)} is chosen.

{phang3}
{opt s:ubsize(#)} specifies the size of the subsamples to be drawn. This option is
relevant only if {cmd:bmethod(subsampling)} is chosen.

{phang}
{opt f:unctional}, activates the tools for functional inference (uniform confidence bands, test of functional hypotheses).
These tools are based on the whole quantile regression process.
Therefore, it is crucial that a large number of quantile regressions is estimated. This is done by default if the options {cmd: quantile}, or, {cmd:qlow}, {cmd:qhigh}, and {cmd:qstep} are not specified.
The tests use the Kolmogov-Smirnov and the Cramer-von-Mises statistics to measure deviations from the null hypothesis.
The p-values for five null hypotheses are computed: no effect, positive effect, negative effect, constant effect (or homogeneity hypothgesis, or location shift hypothesis) and location-scale shift.
Each of these hypothesis is tested for a single parameter or for all slope parameters simultaneously.
{cmd:vce(bootstrap)} or {cmd:vce(multiplier)} are the only accepted methods when {cmd:functional} is activated.

{dlgtab:Reporting}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals. The
default is level(95) or as set by {cmd:set level}; see 
{helpb estimation options##level():[R] estimation options}.

{phang}
{opt norpint} prevents the display of the coefficients table.
 By default, the coefficients table is displayed but it can be extremely voluminous when many quantile regressions are estimated.


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Use the auto dataset{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Median regression{p_end}
{phang2}{cmd:. qrprocess price weight length foreign}{p_end}

{pstd}Replay results{p_end}
{phang2}{cmd:. qrprocess}

{pstd}Estimate .25 quantile regression and estimate the variance with {help qrprocess##Hendricks_Koenker_1992:Hendricks and Koenker (1992)} method and the Bofinger bandwidth{p_end}
{phang2}{cmd:. qrprocess price weight length foreign, quantile(.25) vce(nid, bofinger)}
{p_end}

{pstd}Median regression with bootstrap standard errors{p_end}
{phang2}{cmd:. qrprocess price weight length foreign, vce(boot)}{p_end}

{pstd}Estimate .25, .50, and .75 quantile regressions with bootstrap standard errors{p_end}
{phang2}{cmd:. qrprocess price weight length foreign, vce(boot) quantile(0.25 0.5 0.75)}{p_end}

{pstd}Estimate .9 quantile regression using subsampled bootstrap standard errors with 200 repetitions and a subsize of 50 observations{p_end}
{phang2}{cmd:. qrprocess price weight length foreign, vce(boot, bm(subsampling) subsize(50) reps(200)) quantile(0.95)}{p_end}
 
{pstd}Use the cps91 dataset{p_end}
{phang2}{cmd:. use http://www.stata.com/data/jwooldridge/eacsap/cps91 }{p_end}
 
{pstd}Estimate the discretized quantile regression process for the 0.1,0.02,...,0.9 quantiles, do not print the results{p_end}
{phang2}{cmd:. qrprocess lwage c.age##c.age i.black i.hispanic educ, quantile(0.1(0.01)0.9) noprint}{p_end}

{pstd}Plot all the coefficients{p_end}
{phang2}{cmd:. plotprocess}{p_end}

{pstd}Estimate the same process, activate functional inference, use the multiplier bootstrap with 500 replications{p_end}
{phang2}{cmd:. qrprocess lwage c.age##c.age i.black i.hispanic educ, quantile(0.1(0.01)0.9) functional vce(multiplier, reps(500))}{p_end}

{pstd}Plot the coefficient for education with uniform and pointwise confidence bands{p_end}
{phang2}{cmd:. plotprocess educ, ytitle("QR coefficent") title("Years of education")}{p_end}
 
{pstd}Estimate the same process with the one-step estimator, {p_end}
{phang2}{cmd:. qrprocess lwage c.age##c.age i.black i.hispanic educ, method(onestep) quantile(0.1(0.01)0.9)}{p_end}
	{hline}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:qrprocess} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(N_strat)}}number of strata{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(reps)}}number of replications{p_end}
{synopt:{cmd:e(subsize)}}subsample size{p_end}

{p2col 5 20 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:qrprocess}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}Quantile Regression{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(xvar)}}name of the regressor(s){p_end}
{synopt:{cmd:e(vce)}}vce type specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(bwmethod)}}bandwidth method; hsheather or bofinger{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement estat{p_end}
{synopt:{cmd:e(method)}}algorithmic method{p_end}
{synopt:{cmd:e(bmethod)}}bootstrap method V{p_end}
{synopt:{cmd:e(replacement)}}subsampling method, "with replacement" or "without replacement"{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(stratvar)}}name of strata variable{p_end}

{p2col 5 20 19 2: Matrices}{p_end}
{p2col 5 20 19 2: let {it:k} be the number of regressors and {it:nq} be the number of quantile regressions}{p_end}
{synopt:{cmd:e(quantiles)}}estimated quantile(s); {it:nq}*1 vector{p_end}
{synopt:{cmd:e(b)}}coefficient vector; ({it:k}*{it:nq})*1 vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators; ({it:k}*{it:nq})*({it:k}*{it:nq}) matrix{p_end}
{synopt:{cmd:e(sum_rdev)}}sum of absolute deviations; {it:nq}*1 vector{p_end}
{synopt:{cmd:e(sum_mdev)}}sum of raw deviations; {it:nq}*1 vector{p_end}
{synopt:{cmd:e(coefmat)}}matrix of coefficients; ({it:k}*{it:nq}) matrix{p_end}
{synopt:{cmd:e(pointwise)}}lower and upper bounds of the pointwise confidence intervals; ({it:k}*{it:nq})*2 matrix{p_end}
{synopt:{cmd:e(uniform)}}lower and upper bounds of the functional confidence bands; ({it:k}*{it:nq})*2 matrix{p_end}
{synopt:{cmd:e(tests)}}p-values of the {cmd:functional} tests; ({it:k} + 1)*10 matrix{p_end}

{p2col 5 20 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:Version requirements}

{pstd}This command requires Stata 9.2 or later.  In addition, it requires the 
package {cmd:moremata} (see {help qrprocess##Jann:Jann (2005)}).  Type {cmd:ssc install moremata}
to install this package.

{title:References}

{phang}
{marker angrist_et_al_2006}
Angrist, J., V. Chernozhukov, and I. Fernández-Val. 2006.  Quantile regression under misspecification, with an application to the US wage structure. {it:Econometrica} 74: 539–563.
{p_end}

{phang}
{marker bofinger_1975}
Bofinger, E. 1975. Estimation of a density function using order statistics. {it:Australian Journal of Statistics} 17(1): 1-7.
{p_end}

{phang}
{marker C1994}
Chamberlain, G. 1994. Quantile regression, censoring, and the structure of wages. {it:Advances in Econometrics}, Sixth World Congress (Volume1); C. A. Sims (ed.), Cambridge University Press.
{p_end}

{phang}
{marker Chernozhukov_et_al_2013}
Chernozhukov, V., I. Fernández-Val, and B. Melly. 2013. Inference on counterfactual distributions. {it:Econometrica} 81(6): 2205-2268.
{p_end}

{phang}
{marker CFM_emec}
Chernozhukov, V., I. Fernández-Val, and  B. Melly. 2020a. Fast algorithms for the quantile regression process. {it:Working paper}.
{p_end}

{phang}
{marker CFM_Stata}
Chernozhukov, V., I. Fernández-Val, and  B. Melly. 2020b. Quantile and distribution regression in Stata: algorithms, pointwise and functional inference. {it:Working paper}.
{p_end}

{phang}
{marker Hall_Sheather_1988}
Hall, P., and S. J. Sheather. 1988. On the distribution of a studentized quantile. {it:Journal of the Royal Statistical Society, Series B} 50: 381-391.
{p_end}

{phang}
{marker Hendricks_Koenker_1992}
Hendricks, W., and R. Koenker. 1992. Hierarchical spline models for conditional quantiles and the demand for electricity. {it:Journal of the American Statistical Association} 87(417): 58-68.
{p_end}

{phang}
{marker Jann}
Jann, B. 2005. moremata: Stata module (Mata) to provide various 
functions. Statistical Software Components S455001, Department of Economics, 
Boston College. {browse "http://ideas.repec.org/c/boc/bocode/s455001.html":http://ideas.repec.org/c/boc/bocode/s455001.html}.

{phang}
{marker Koenker_2005}
Koenker, R. 2005. {it:Quantile Regression}. Cambridge University Press: New York.
{p_end}

{phang}
{marker Koenker_Bassett_1978}
Koenker, R., and G. Bassett. 1978. Regression quantiles. {it:Econometrica} 46: 33-50.
{p_end}

{phang}
{marker Portnoy_Koenker_1997}
Portnoy, S., and R. Koenker. 1997. The Gaussian hare and the Laplacian tortoise: computability of squared-error versus absolute-error estimators. {it:Statistical Science} 12(4): 279-300.
{p_end}

{phang}
{marker Powell_1991}
Powell, J. L. 1991. Estimation of monotonic regression models under quantile restrictions. {it:Nonparametric and semiparametric methods in Econometrics},(Cambridge University Press, New York) 357-384.
{p_end}


{title:Remarks}

{p 4 4}This is a preliminary version. Please feel free to share your comments, reports of bugs and
propositions for extensions.

{p 4 4}If you use this command in your work, please cite {helpb qrprocess##CFM_emec:Chernozhukov, Fernández-Val and Melly (2020a)} and/or
{helpb qrprocess##CFM_Stata: Chernozhukov, Fernández-Val and Melly (2020b)}.


{title:Authors}

{p 4 6}Victor Chernozhukov, Iván Fernández-Val and Blaise Melly{p_end}
{p 4 6}MIT, Boston University and University of Bern{p_end}
{p 4 6}mellyblaise@gmail.com{p_end}

