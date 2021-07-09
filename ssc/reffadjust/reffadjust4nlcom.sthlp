{smcl}
{* *! version 1.1.0  2sep2013 Tom Palmer}{...}
{cmd:help reffadjust4nlcom} {right:}
{hline}

{title:Title}

{p 5}{cmd:reffadjust4nlcom} {hline 2} random effects adjustment: regression coefficient formula to pass to {cmd:nlcom}{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}{cmd:reffadjust4nlcom} {it:depvar} {it:indepvars} {cmd:,} {cmd:eqn(}string{cmd:)} [{it:{help betaformula##options:options}}]


{synoptset 30 tabbed}{...}
{marker options}{...}
{synopthdr:options}
{synoptline}
{synopt :{opt eqn:(string)}}name of the equation the adjusted coefficients are to be extracted from{p_end}
{synopt :{opt mcmcsum:}}returned local in format for use with chains from {cmd:mcmcsum}{p_end}
{synopt :{opth sf:(numlist)}}scaling factors corresponding to each coefficient{p_end}
{synopt :{opt sub:level(#)}}sublevel of a repeated group variable{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}{cmd:reffadjust4nlcom} is a postestimation command to perform adjustment of random effects estimates.
It runs with estimates from {cmd:runmlwin} or chains from {cmd:runmlwin} by {cmd:mcmcsum} (Leckie and Charlton, 2011), {cmd:mixed}/{cmd:xtmixed}, {cmd:meqrlogit}/{cmd:xtmelogit}, and {cmd:meqrpoisson}/{cmd:xtmepoisson}.
It returns the formula for a regression coefficient to pass to {cmd:nlcom} to generate a delta-method confidence interval.

{pstd}For example, for an outcome variable {it:Y} ({it:depvar}) and covariate {it:X1} ({it:indepvar}) the formula for the regression coefficient {it:beta_X1} is:

{p 8 8 2}{it:beta_X1} = cov({it:Y},{it:X1})/var({it:X1}).{p_end}

{pstd}The approach is described in more detail in Macdonald-Wallis et al. (2012) and Palmer et al. (in press).
Further details are given in {helpb reffadjust}.

{pstd}{cmd:reffadjust4nlcom} can return the formulae for upto four covariates and returns locals for all specified covariates.
The covariates ({it:indepvars}) can be specified in any order.
{cmd:reffadjustsim} can adjust for more covariates.

{pstd}See Buis (2011) for a description of how to retrieve random effect variances and correlations from {cmd:xt}/some multilevel commands.

{pstd}{bf:Note on multivariate response models:}
Covariates ({it:indepvars}) in {cmd:runmlwin} estimates from multivariate response models have suffix {bf:_#}, where # is the corresponding equation number.
For example, from equation 1 {it:cons} would be referred to as {it:cons_1}.

{pstd}{bf:Note on shrinkage estimates:}
{cmd:reffadjust4nlcom} uses the estimated random effect variances and covariances from the model.
It does not use the shrinkage estimates of these parameters, i.e. the variances and covariances of the residuals
(see chapter 3 of the MLwiN User Manual).

{pstd}{bf:Warning about P-values for these estimates}
The P-values associated with these estimates from {cmd:nlcom} may be affected by boundary value issues in the estimation of the random effect variances and covariances
(see {manpage XT 347:Distribution theory for likelihood ratio tests} subsection in {manlinki XT xtmixed}
/{manpage ME 18:Distribution theory for likelihood ratio test}, Gutierrez et al. 2001).

{pstd}{bf:Interpretation of coefficients:}
The coefficients estimated by {cmd:reffadjust4nlcom} represent the mean difference in the random effect entered as the dependent variable,
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
{opt mcmcsum} specifies that the returned local is to use variable names of chains which are returned from MLwiN Bayesian MCMC estimation by {helpb mcmcsum:mcmcsum, getchains}.
Only allowed with {cmd:runmlwin} estimates.

{phang}
{opt sf:(numlist)} a numlist of scaling factors.
If specified each number corresponds to the respective covariate ({it:indepvar}), i.e. the first number is the scaling factor for the first coefficient and so on.
If specified the {it:numlist} must be the same length as the number of covariates.
To scale the coefficient by 2 times the dependent variable ({it:Y}), for example, then with one covariate ({it:X}) specify sf(2).
To scale the coefficient by 2 times the covariate specify sf(.5) because the coefficient is by 2/2^2 since a regression coefficient is given by: cov({it:X},{it:Y})/var({it:X}).

{phang}
{opt sub:level(#)} the sublevel of a repeated group variable.
For example, in the following model

{p 8 12 4}{cmd:. mixed} {it:f_p}
{cmd:|| school: z1 z2, nocons cov(id) || school: z3 z4, nocons cov(un)}
{it:options}

{p 8 8 8}{cmd:z1} and {cmd:z2} are at sublevel 1 and {cmd:z3} and {cmd:z4} are at sublevel 2 of the {cmd:school} group variable.{p_end}
{p 8 8 8}Only valid with {cmd:mixed}/{cmd:xtmixed}, {cmd:meqrlogit}/{cmd:xtmelogit},
and {cmd:meqrpoisson}/{cmd:xtmepoisson}.


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Examples 1 & 2 assume the path to the MLwiN executable is set in {cmd:global MLwiN_path}; see {help runmlwin##installation_instructions:runmlwin}{p_end}

{pstd}{bf:Example 1: Two level continuous response model} (see page 59 of the MLwiN User Manual){p_end}

{phang}{cmd:. * read in data}{p_end}
{phang}{cmd:. }{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/tutorial, clear"}}{p_end}

{phang}{cmd:. * fit model using MLwiN via runmlwin}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin normexam cons standlrt, level1(student: cons) level2(school: cons standlrt) batch"}}{p_end}

{phang}{cmd:. * report coefficient and delta-method confidence interval}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom cons standlrt, eqn(RP2)"}}{p_end}
{phang}{cmd:. }{bf:{stata `"nlcom `r(beta_standlrt)'"'}}{p_end}

{phang}{cmd:. * compare reporting coefficient as median with 2.5 & 97.5 percentiles}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons standlrt, eqn(RP2) seed(12345)"}}{p_end}

{phang}{cmd:. * compare reporting coefficient as mean & Wald-type confidence interval}{p_end}
{phang}{cmd:. * Warning: mean and Wald-type confidence are inaccurate in this example}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons standlrt, eqn(RP2) seed(12345) waldtype"}}{p_end}

{phang}{cmd:. * to view just the coefficient or string expression for the coefficient}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom cons standlrt, eqn(RP2)"}}{p_end}
{phang}{cmd:. }{bf:{stata `"display `r(beta_standlrt)'"'}}{p_end}
{phang}{cmd:. }{bf:{stata `"mata st_macroexpand("`r(beta_standlrt)'")"'}}{p_end}

{phang}{cmd:. * compare with Bayesian posterior distribution}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin normexam cons standlrt, level1(student: cons) level2(school: cons standlrt) batch mcmc(on) initsprevious seed(121211)"}}{p_end}
{phang}{cmd:. }{bf:{stata "mcmcsum, getchains"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom cons standlrt, eqn(RP2) mcmcsum"}}{p_end}
{phang}{cmd:. }{bf:{stata `"gen beta_standlrt = `r(beta_standlrt)'"'}}{p_end}
{phang}{cmd:. }{bf:{stata "mcmcsum beta_standlrt, variables"}}{p_end}


{pstd}{bf:Example 2: Multivariate response model} (see page 214 of the MLwiN User Manual){p_end}

{phang}{cmd:. * read in data}{p_end}
{phang}{cmd:. }{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/gcsemv1, clear"}}{p_end}

{phang}{cmd:. * fit model using MLwiN via runmlwin}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level1(student: (cons, eq(1)) (cons, eq(2))) level2(school: (cons, eq(1)) (cons, eq(2))) batch"}}{p_end}

{phang}{cmd:. * report coefficient and delta-method confidence interval}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom cons_1 cons_2, eqn(RP2)"}}{p_end}
{phang}{cmd:. }{bf:{stata `"nlcom `r(beta_cons_2)'"'}}{p_end}

{phang}{cmd:. * compare reporting coefficient as median with 2.5 and 97.5 percentiles}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons_1 cons_2, eqn(RP2) seed(12345)"}}{p_end}

{phang}{cmd:. * compare reporting coefficient as mean with Wald-type confidence interval}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjustsim cons_1 cons_2, eqn(RP2) seed(12345) waldtype"}}{p_end}

{phang}{cmd:. * to view just the coefficient or string expression for the coefficient}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom cons_1 cons_2, eqn(RP2)"}}{p_end}
{phang}{cmd:. }{bf:{stata `"display `r(beta_cons_2)'"'}}{p_end}
{phang}{cmd:. }{bf:{stata `"mata st_macroexpand("`r(beta_cons_2)'")"'}}{p_end}

{phang}{cmd:. * compare with Bayesian posterior distribution}{p_end}
{phang}{cmd:. }{bf:{stata "runmlwin (written cons female, eq(1)) (csework cons female, eq(2)), level1(student: (cons, eq(1)) (cons, eq(2))) level2(school: (cons, eq(1)) (cons, eq(2))) batch mcmc(on) initsprevious seed(121211)"}}{p_end}
{phang}{cmd:. }{bf:{stata "mcmcsum, getchains"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom cons_1 cons_2, eqn(RP2) mcmcsum"}}{p_end}
{phang}{cmd:. }{bf:{stata `"gen beta_cons_2 = `r(beta_cons_2)'"'}}{p_end}
{phang}{cmd:. }{bf:{stata "mcmcsum beta_cons_2, variables"}}{p_end}


{pstd}{bf:Example 3: based on xtmixed helpfile}{p_end}
{phang}{cmd:. }{bf:{stata "webuse nlswork, clear"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 12: xtmixed ln_w grade age c.age#c.age ttl_exp tenure c.tenure#c.tenure || idcode: tenure, cov(uns) var"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 13: mixed ln_w grade age c.age#c.age ttl_exp tenure c.tenure#c.tenure || idcode: tenure, cov(uns)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom _cons tenure, eqn(idcode)"}}{p_end}
{phang}{cmd:. }{bf:{stata "nlcom `r(beta_tenure)'"}}{p_end}


{pstd}{bf:Example 4: based on xtmelogit helpfile}{p_end}
{phang}{cmd:. }{bf:{stata "webuse bangladesh, clear"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 12: xtmelogit c_use urban age child* || district: urban, cov(uns) var"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 13: meqrlogit c_use urban age child* || district: urban, cov(uns)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom _cons urban, eqn(district)"}}{p_end}
{phang}{cmd:. }{bf:{stata "nlcom `r(beta_urban)'"}}{p_end}


{pstd}{bf:Example 5: based on xtmepoisson helpfile}{p_end}
{phang}{cmd:. }{bf:{stata "webuse epilepsy, clear"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 12: xtmepoisson seizures treat lbas lbas_trt lage visit || subject: visit, cov(uns) var intpoints(9)"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 13: meqrpoisson seizures treat lbas lbas_trt lage visit || subject: visit, cov(uns) intpoints(9)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom _cons visit, eqn(subject)"}}{p_end}
{phang}{cmd:. }{bf:{stata "nlcom `r(beta_visit)'"}}{p_end}


{pstd}{bf:Example 6: repeated group variable}{p_end}
{phang}{cmd:. }{bf:{stata "webuse nlswork, clear"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 12: xtmixed ln_w grade age || idcode: tenure union, cov(uns) || idcode: race, cov(uns) var"}}{p_end}
{phang}{cmd:. }{bf:{stata "version 13: mixed ln_w grade age || idcode: tenure union, cov(uns) || idcode: race, cov(uns)"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom tenure union, eqn(idcode) sub(1)"}}{p_end}
{phang}{cmd:. }{bf:{stata "nlcom `r(beta_union)'"}}{p_end}
{phang}{cmd:. }{bf:{stata "reffadjust4nlcom race _cons, eqn(idcode) sub(2)"}}{p_end}
{phang}{cmd:. }{bf:{stata "nlcom `r(beta__cons)'"}}{p_end}
    {hline}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:reffadjust4nlcom} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(beta_indepvar)}}Formula for beta_indepvar{p_end}


{marker references}{...}
{title:References}

{phang}Buis ML. 2011. Stata tip 97: Getting at rho's and sigma's. The Stata Journal. 11(2) 315-317.

{phang}Gutierrez RG, Carter S, Drukker DM. 2001. sg160: On boundary-value likelihood ratio tests. Stata Technical Bulletin. 60. 15-18.

{phang}Leckie G, Charlton C. 2011. {cmd:runmlwin}: Stata module for fitting multilevel models in the MLwiN software package. Centre for Multilevel Modelling, University of Bristol, UK. {browse "http://www.bristol.ac.uk/cmm/software/runmlwin/"}

{phang}Macdonald-Wallis C, Lawlor DA, Palmer TM, Tilling K. 2012.
Multivariate multilevel spline models for parallel growth processes: application to weight and mean arterial pressure in pregnancy. Statistics in Medicine, 31, 3147-3164.

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


{title:Also see}

{psee}
{space 2}Help:  {helpb reffadjust}, {helpb reffadjustsim}, {helpb runmlwin} (if installed), {helpb mcmcsum} (if installed), {helpb nlcom},
{helpb mixed} {helpb xtmixed}, {helpb meqrlogit}, {helpb xtmelogit}, {helpb meqrpoisson}, {helpb xtmepoisson}
{p_end}
