{smcl}
{* *! version 1.1.0  2sep2013 Tom Palmer}{...}
{cmd:help reffadjustsim} {right:}
{hline}

{title:Title}

{p 5}{cmd:reffadjustsim} {hline 2} random effects adjustment: simulating from the distribution of random effect variances and covariances{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}{cmd:reffadjustsim} {it:depvar} {it:indepvars} {cmd:,} {cmd:eqn(}string{cmd:)} [{it:{help betaformula##options:options}}]


{synoptset 30 tabbed}{...}
{marker options}{...}
{synopthdr:options}
{synoptline}
{synopt :{opt eqn:(string)}}name of the equation the adjusted coefficients are to be extracted from{p_end}
{synopt :{opt centileopts:(string)}}options passed to {cmd:centile}{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt mcmcsum:}}use chains from {cmd:mcmcsum}{p_end}
{synopt :{opt n:(#)}}# of observations to simulate; default is 10,000{p_end}
{synopt :{opt post}}post estimation results{p_end}
{synopt :{opt replace}}replace beta_indepvar if variable exists in dataset{p_end}
{synopt :{opt sav:ing(filename [, replace])}}save simulated observations to {it:filename}{p_end}
{synopt :{opth sf:(numlist)}}scaling factors corresponding to each coefficient{p_end}
{synopt :{opt seed:(#)}}seed for random-number generator{p_end}
{synopt :{opt statadrawnorm}}use Stata's {cmd:drawnorm} for Wald type CIs{p_end}
{synopt :{opt sub:level(#)}}sublevel of a repeated group variable{p_end}
{synopt :{opt wald:type}}report means & Wald-type confidence intervals{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}{cmd:reffadjustsim} is a postestimation command to perform adjustment of random effects estimates.
It runs with estimates from {cmd:runmlwin} or chains from {cmd:runmlwin} by {cmd:mcmcsum} (Leckie and Charlton, 2011), {cmd:mixed}/{cmd:xtmixed}, {cmd:meqrlogit}/{cmd:xtmelogit}, and {cmd:meqrpoisson}/{cmd:xtmepoisson}.

{pstd}{cmd:reffadjustsim} generates the specified number of observations of the variances and covariances of the random effects from the corresponding multivariate normal distribution.
Alternatively, values are used from the returned chains from Bayesian estimation in MLwiN by {cmd:mcmcsum, getchains}.
For each observation the adjusted coefficient/s are estimated as described by Fisher (1925, chapter 5, section 29).
The approach is described in more detail in Macdonald-Wallis et al. (2012) and Palmer et al. (in press).
Further details are given in {helpb reffadjust}.
The covariates ({it:indepvars}) can be specified in any order.

{pstd}An alternative approach is to use the accompanying {cmd:reffadjust4nlcom} command to generate the expression for the adjusted coefficient,
and pass that to {cmd:nlcom} to estimate a delta-method confidence interval.

{pstd}See Buis (2011) for a description of how to retrieve random effect variance and correlations from {cmd:xt}/some multilevel commands.

{pstd}{bf:Note on multivariate response models:}
Covariates ({it:indepvars}) in {cmd:runmlwin} estimates from multivariate response models have suffix {bf:_#}, where # is the corresponding equation number.
For example, from equation 1 {it:cons} would be referred to as {it:cons_1}.

{pstd}{bf:Note on shrinkage estimates:}
{cmd:reffadjustsim} uses the estimated random effect variances and covariances from the model.
It does not use the shrinkage estimates of these parameters, i.e. the variances and covariances of the residuals
(see chapter 3 of the MLwiN User Manual).

{pstd}{bf:Warning about waldtype option:}
By default {cmd: reffadjustsim} reports coefficients as medians with 2.5 and 97.5 percentiles.
Coefficients can be reported as means with Wald-type confidence intervals with the {opt waldtype} option.
Means and Wald-type confidence intervals may not be accurate.
It is always advised to compare results with the default output and if possible also with the delta-method confidence interval via {cmd:reffadjust4nlcom} and {cmd:nlcom}.
In general, P-values associated with these estimates may be affected by boundary value issues in the estimation of the random effect variances and covariances
(see {manpage XT 344:Distribution theory for likelihood ratio tests} subsection in {manlinki XT xtmixed}
/{manpage ME 18:Distribution theory for likelihood ratio test}, Gutierrez et al. 2001).

{pstd}{bf:Interpretation of coefficients:}
The coefficients estimated by {cmd:reffadjustsim} represent the mean difference in the random effect entered as the dependent variable,
which is associated with a unit increase in each of the random effects entered as independent variables,
whilst adjusting for the other random effects included as independent variables.

{pstd}{bf:Parameters estimated with zero variance:}
Sometimes a multilevel model can be declared as converged but some parameters
(especially random effect variances and covariances)
may not have a standard error.
A warning is issued that resulting confidence intervals may not be valid in this case.


{marker options}{...}
{title:Options}

{phang}
{opt eqn(string)} the name of the equation the coefficients are to be extracted from.
For example a two level random effects model from {cmd:runmlwin} will typically return four equations (FP1, FP2, RP1, RP2).

{phang}
{opt centileopts(string)} options passed to {helpb centile}, note you may not specify the {opt centile(#)} option here.
The reported percentiles can be changed through the {cmd:level(#)} option.

{phang}
{opt l:evel(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt mcmcsum:} calculates centiles from the Bayesian posterior distribution of the coefficients using chains imported by:
{helpb mcmcsum:mcmcsum, getchains}.
Note your {cmd:runmlwin} model must have been fitted by MCMC.
Options: {opt seed}, {opt n}, {opt statadrawnorm}, {opt waldtype} (and {opt post}) are not required/allowed with {opt mcmcsum}.
Only allowed with {cmd:runmlwin} estimates.

{phang}
{opt n(#)} specifies the number of observations to be simulated.
The default is 10,000 and is not allowed to be less than 10.
Not allowed with {opt mcmcsum}, where {opt n} is taken as the number of observations
in the dataset imported by {cmd:mcmcsum, getchains}.

{phang}
{opt post} causes {cmd:reffadjustsim} to behave like a Stata estimation ({cmd:eclass})
command.  May only be specified with {opt waldtype}.
When {opt post} is specified, {cmd:reffadjustsim} will post the vector of
adjusted estimates and its estimated variance-covariance matrix to
{cmd:e()}. Thus you could, after {opt post}ing, treat the estimation results in
the same way as you would treat results from other Stata estimation commands.
For example, after posting, you could redisplay the results by typing
{cmd:reffadjustsim} without any arguments, or use {helpb test} to perform simultaneous
tests of hypotheses on linear combinations of the estimates.

{pmore}
Specifying {opt post} clears out the previous estimation results,
which can be recovered only by refitting the original model or by storing the
estimation results before running {cmd:reffadjustsim} and then restoring them; see
{manhelp estimates_store R:estimates store}.

{phang}
{opt replace} overwrites variables named {it:beta_indepvar} if they exist in the dataset.
Only valid with {opt mcmcsum}.

{phang}
{opt sav:ing(filename [, replace])} saves the simulated realisations of the random effect variances and covariances to {it:filename},
optionally replacing {it:filename} if it exists.

{phang}
{opt seed(#)} specifies the initial value of the
random-number seed.  The default is the
current random-number seed.  Specifying {opt seed(#)} is the same
as typing {cmd:set seed} {it:#} before issuing the command; see {helpb set_seed}.
Not allowed with {opt mcmcsum}.

{phang}
{opt sf:(numlist)} a numlist of scaling factors.
If specified each number corresponds to the respective covariate ({it:indepvar}),
i.e. first number is the scaling factor for the first coefficient and so on.
If specified the {it:numlist} must be the same length as the number of covariates.
To scale the coefficient by 2 times the dependent variable ({it:Y}), for example, then with one covariate ({it:X}) specify sf(2).
To scale the coefficient by 2 times the covariate specify
sf(.5) because in this case you scale by 2/2^2 since a regression coefficient is given by: cov({it:X},{it:Y})/var({it:X}).

{phang}
{opt statadrawnorm} use Stata's {cmd:drawnorm} to simulate the adjusted coefficients.
For speed by default {cmd:reffadjustsim} uses its own Mata implementation; see {helpb drawnorm}.
Not allowed with {opt mcmcsum}.

{phang}
{opt sub:level(#)} the sublevel of a repeated group variable.
For example, in the following model

{p 8 12 4}{cmd:. mixed} {it:f_p}
{cmd:|| school: z1 z2, nocons cov(id) || school: z3 z4, nocons cov(un)}
{it:options}

{p 8 8}{cmd:z1} and {cmd:z2} are at sublevel 1 and {cmd:z3} and {cmd:z4} are at sublevel 2 of the {cmd:school} group variable.{p_end}
{p 8 8 8}Only valid with {cmd:mixed}/{cmd:xtmixed}, {cmd:meqrlogit}/{cmd:xtmelogit}, and {cmd:meqrpoisson}/{cmd:xtmepoisson}.

{phang}
{opt wald:type} report coefficients as means with Wald-type confidence intervals.
By default {cmd:reffadjustsim} reports coefficients as medians and centiles of the simulated coefficients. This option can produce inaccurate results, as per the warning above please compare with the default output.
Not allowed with {opt mcmcsum}.


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Examples 1 & 2 assume the path to the MLwiN executable is set in {cmd:global MLwiN_path}; see {help runmlwin##installation_instructions:runmlwin}{p_end}

{pstd}{bf:Example 1: Two level continuous response model} (see page 59 of the MLwiN User Manual){p_end}

{phang}{cmd:. * read in data}{p_end}
{phang}{cmd:. }{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/tutorial, clear"}}{p_end}

{phang}{cmd:. * fit model using MLwiN via runmlwin}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin normexam cons standlrt, level1(student: cons) level2(school: cons standlrt) batch"}}{p_end}

{phang}{cmd:. * report coefficient as median with 2.5 & 97.5 percentiles}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons standlrt, eqn(RP2) seed(12345)"}}{p_end}

{phang}{cmd:. * report coefficient as mean & Wald-type confidence interval}{p_end}
{phang}{cmd:. * Warning: mean and Wald-type confidence are inaccurate in this example}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons standlrt, eqn(RP2) seed(12345) waldtype"}}{p_end}

{phang}{cmd:. * compare with delta-method confidence interval (first refit model)}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin normexam cons standlrt, level1(student: cons) level2(school: cons standlrt) batch"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom cons standlrt, eqn(RP2)"}}{p_end}
{phang}{cmd:. }{bf:{stata `"nlcom `r(beta_standlrt)'"'}}{p_end}

{phang}{cmd:. * compare with Bayesian posterior distribution}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin normexam cons standlrt, level1(student: cons) level2(school: cons standlrt) batch mcmc(on) initsprevious seed(121211)"}}{p_end}
{phang}{cmd:. }{bf:{stata "mcmcsum, getchains"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons standlrt, eqn(RP2) mcmcsum"}}{p_end}


{pstd}{bf:Example 2: Multivariate response model} (see page 214 of the MLwiN User Manual){p_end}

{phang}{cmd:. * read in data}{p_end}
{phang}{cmd:. }{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/gcsemv1, clear"}}{p_end}

{phang}{cmd:. * fit model using MLwiN via runmlwin}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level1(student: (cons, eq(1)) (cons, eq(2))) level2(school: (cons, eq(1)) (cons, eq(2))) batch"}}{p_end}

{phang}{cmd:. * report coefficient as median with 2.5 and 97.5 percentiles}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons_1 cons_2, eqn(RP2) seed(12345)"}}{p_end}

{phang}{cmd:. * report coefficient as mean with Wald-type confidence interval}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons_1 cons_2, eqn(RP2) seed(12345) waldtype"}}{p_end}

{phang}{cmd:. * compare with delta-method confidence interval (first refit model)}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level1(student: (cons, eq(1)) (cons, eq(2))) level2(school: (cons, eq(1)) (cons, eq(2))) batch"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom cons_1 cons_2, eqn(RP2)"}}{p_end}
{phang}{cmd:. }{bf:{stata `"nlcom `r(beta_cons_2)'"'}}{p_end}

{phang}{cmd:. * compare with Bayesian posterior distribution}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level1(student: (cons, eq(1)) (cons, eq(2))) level2(school: (cons, eq(1)) (cons, eq(2))) batch mcmc(on) initsprevious seed(121211)"}}{p_end}
{phang}{cmd:. }{bf:{stata "mcmcsum, getchains"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons_1 cons_2, eqn(RP2) mcmcsum"}}{p_end}


{pstd}{bf:Example 3: based on xtmixed helpfile}{p_end}
{phang}{cmd:. }{bf:{stata "webuse nlswork, clear"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 12: xtmixed ln_w grade age c.age#c.age ttl_exp tenure c.tenure#c.tenure || idcode: tenure, cov(uns) var"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 13: mixed ln_w grade age c.age#c.age ttl_exp tenure c.tenure#c.tenure || idcode: tenure, cov(uns)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim _cons tenure, eqn(idcode) seed(12345)"}}{p_end}


{pstd}{bf:Example 4: based on xtmelogit helpfile}{p_end}
{phang}{cmd:. }{bf:{stata "webuse bangladesh, clear"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 12: xtmelogit c_use urban age child* || district: urban, cov(uns) var"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 13: meqrlogit c_use urban age child* || district: urban, cov(uns)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim _cons urban, eqn(district) seed(12345)"}}{p_end}


{pstd}{bf:Example 5: based on xtmepoisson helpfile}{p_end}
{phang}{cmd:. }{bf:{stata "webuse epilepsy, clear"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 12: xtmepoisson seizures treat lbas lbas_trt lage visit || subject: visit, cov(uns) var intpoints(9)"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 13: meqrpoisson seizures treat lbas lbas_trt lage visit || subject: visit, cov(uns) intpoints(9)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim _cons visit, eqn(subject) seed(12345)"}}{p_end}


{pstd}{bf:Example 6: repeated group variable}{p_end}
{phang}{cmd:. }{bf:{stata "webuse nlswork, clear"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 12: xtmixed ln_w grade age || idcode: tenure union, cov(uns) || idcode: race, cov(uns) var"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 13: mixed ln_w grade age || idcode: tenure union, cov(uns) || idcode: race, cov(uns)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim tenure union, eqn(idcode) sub(1) seed(12345)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim race _cons, eqn(idcode) sub(2) seed(12345)"}}{p_end}
    {hline}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:reffadjustsim} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of simulated observations{p_end}

{pstd}
If {opt waldtype} is not specified, {cmd:reffadjustsim} saves the following for each indepvar in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(n_cent_indepvar)}}number of centiles requested (usually 2){p_end}
{synopt:{cmd:r(c_1_indepvar)}}value of 1st centile for indepvar{p_end}
{synopt:{cmd:r(lb_1_indepvar)}}1st centile lower confidence bound{p_end}
{synopt:{cmd:r(ub_1_indepvar)}}1st centile upper confidence bound{p_end}
{synopt:{cmd:r(c_2_indepvar)}}value of 2nd centile for indepvar{p_end}
{synopt:{cmd:r(lb_2_indepvar)}}2nd centile lower confidence bound{p_end}
{synopt:{cmd:r(ub_2_indepvar)}}2nd centile upper confidence bound{p_end}
{synopt:{cmd:r(med_indepvar)}}median of indepvar{p_end}
{synopt:{cmd:r(lb_med_indepvar)}}median lower confidence bound{p_end}
{synopt:{cmd:r(ub_med_indepvar)}}median upper confidence bound{p_end}

{pstd}
If {opt waldtype} is specified, {cmd:reffadjustsim} saves the following in {cmd:r()}:

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}vector of adjusted coefficients{p_end}
{synopt:{cmd:r(V)}}estimated variance-covariance matrix of the adjusted
coefficients{p_end}

{pstd}
If {opt waldtype} and {opt post} are specified, {cmd:reffadjustsim} also saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of simulated observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:reffadjustsim}{p_end}
{synopt:{cmd:e(depvar)}}name of the dependent variable{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of adjusted coefficients{p_end}
{synopt:{cmd:e(V)}}estimated variance-covariance matrix of the adjusted
coefficients{p_end}


{marker references}{...}
{title:References}

{phang}Buis ML. 2011. Stata tip 97: Getting at rho's and sigma's. The Stata Journal. 11(2) 315-317.

{phang}Fisher RA. 1925. Chapter 5: Tests of significance of means, differences of means, and regression coefficients, Section 29:
Regression with several independent variates in Statistical Methods for Research Workers. Oliver and Boyd, Edinburgh.

{phang}Gutierrez RG, Carter S, Drukker DM. 2001. sg160: On boundary-value likelihood ratio tests. Stata Technical Bulletin. 60. 15-18.

{phang}Leckie G, Charlton C. 2011. {cmd:runmlwin}: Stata module for fitting multilevel models in the MLwiN software package. Centre for Multilevel Modelling, University of Bristol, UK. {browse "http://www.bristol.ac.uk/cmm/software/runmlwin/"}

{phang}Macdonald-Wallis C, Lawlor DA, Palmer TM, Tilling K. 2012. Multivariate multilevel spline models for parallel growth processes: application to weight and mean arterial pressure in pregnancy. Statistics in Medicine, 31, 3147-3164.

{phang}Palmer TM, Macdonald-Wallis CM, Lawlor DA, Tilling K. Estimating adjusted associations between random effects from multilevel models: the reffadjust package. The Stata Journal. In press.

{phang}Rasbash J, Charlton C, Browne WJ, Healy M, Cameron B. 2009. MLwiN version 2.1. Centre for Multilevel Modelling, University of Bristol, UK. {browse "http://www.bristol.ac.uk/cmm/software/mlwin"}.

{phang}Rasbash J, Steele F, Browne WJ, Goldstein H. 2009. A user's guide to MLwiN, v2.10. Centre for Multilevel Modelling, University of Bristol, UK. {browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/manuals.html"}.


{marker authors}{...}
{title:Authors}

{phang}Tom Palmer, Division of Health Sciences, Warwick Medical School,
University of Warwick, UK.
 {browse "mailto:t.m.palmer@warwick.ac.uk":t.m.palmer@warwick.ac.uk}.{p_end}

{phang}Corrie Macdonald-Wallis, MRC and University of Bristol Integrative Epidemiology Unit,
School of Social and Community Medicine, University of Bristol, UK.
 {browse "mailto:c.macdonald-wallis@bristol.ac.uk":c.macdonald-wallis@bristol.ac.uk}.{p_end}

{phang}Kate Tilling, School of Social and Community Medicine, University of Bristol, UK.{p_end}


{title:Also see}

{psee}
{space 2}Help:  {helpb reffadjust}, {helpb reffadjust4nlcom}, {helpb runmlwin} (if installed), {helpb mcmcsum} (if installed), {helpb nlcom},
{helpb mixed}, {helpb xtmixed}, {helpb meqrlogit}, {helpb xtmelogit}, {helpb meqrpoisson}, {helpb xtmepoisson}
{p_end}
