{smcl}
{* version 1.0.0 11August2015}{...}
{cmd: help xtkr}{right: ...}
{hline}

{title:Title}

{phang}
{bf:xtkr} {hline 2} The Keane & Runkle Estimator for Dynamic Panel Estimation.

{title:Syntax}

{p 4 4 2}
{cmd:xtkr} {depvar} [{varlist1}] ({varlist2} = {varlist3}) {ifin} 
[{cmd:,} {it:nocons tdum}]{p_end}

{p 4 4 2}Items in [brackets] are optional, {varlist1} contains any exogenous explanatory variables, {varlist2} contains endogenous variables, and lastly {varlist3} contains the instruments. 
You must {cmd:xtset} your data before using {cmd:xtkr}; see {helpb xtset}.{p_end}

{title:Description}

{pstd}
{cmd:xtkr} implemenets the Keane & Runkle (1992) estimator for dynamic panel estimation.

{p 4 4 2}This estimator is for panel data (large N small T) models where the instruments are not strictly exogenous and the errors contain some form of serial correlation. 
It is most commonly applied to dynamic models that contain a lagged dependent variable and fixed/random effects across individuals, such as:{p_end}

{p 4 4 2}y_it = rho*y_(it-1) + beta*x_it + mu_i + e_it{p_end}

{p 4 4 2}where rho is the autoregressive coefficient, x_it is a NTxK matrix of regressors, beta is a 1xK vector of coefficients, mu_i is the individual-specific effect, and e_it is the idiosyncratic error term. 
Applying the within or first-difference estimator to remove the individual effects will result in endogeneity in the lagged dependent variable, and accordingly inconsistent estimates. 
While 2SLS will be consistent in such situations, the Keane & Runkle (KR) estimator uses the idea of forward filtering in the time series literature to improve 
the efficiency of the estimates when the error contains some form of serial correlation.{p_end}

{p 4 4 2}An alternative approach to account for serial correlation is to adopt the Difference of System GMM estimator (implemented in Stata with {cmd:xtabond2} and {cmd:xtdpd}). 
However, as the number of instruments used in those estimators grow non-linearly in T, it can result in the problem of weak or too many instruments which will bias the results towards OLS. 
Restricting or collapsing the instrument matrix can potentially remedy the problem, but there are situations where the Keane & Runkle (1992) estimator will be preferable. Please see Keane & Neal (2015) for further information.{p_end}

{title:References}

{p 4 4 2}Keane, Michael and Neal, Timothy (2015) "The Keane & Runkle Estimator for Dynamic Panel Data Models", Working Paper.{p_end}

{p 4 4 2}Keane, Michael and Runkle, David (1992) "On the Estimation of Panel-Data Models with Serial Correlation When Instruments Are Not Strictly Exogenous," Journal of Business & Economic Statistics, 10 (1), 1-9{p_end}

{title:Options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt nocons}}Suppresses the constant term.{p_end}
{synopt:{opt tdum}}Demeans the data across the time dimension (i.e. the average across i for a given t). This is equivalent and preferable to adding time dummies to the regression, as that can cause collinearity in the second stage.{p_end}

{title:Examples}

{p 4 4 2}In cases where the regressor x is strictly exogenous, one might use:{p_end}

{p 4 4 2}In levels form {p_end}{phang}{cmd:. xtkr y x (l.y = d.l.y d.l(0/1).x)}

{p 4 4 2}In first difference form{p_end} {phang}{cmd:. xtkr d.y d.x (d.l.y = l2.y l(1/2).x)}

{p 4 4 2}In cases where the regressor x is predetermined, one might use:{p_end}

{p 4 4 2}In levels form {p_end}{phang}{cmd:. xtkr y (l.y x = d.l.y d.l(0/1).x)}

{p 4 4 2}In first difference form{p_end} {phang}{cmd:. xtkr d.y (d.l.y d.x = l2.y l(1/2).x)}

{p 4 4 2}In cases where the regressor x is endogenous, one might use:{p_end}

{p 4 4 2}In levels form{p_end} {phang}{cmd:. xtkr y (l.y x = d.l(1/2).y d.l(1/2).x)}

{p 4 4 2}In first difference form{p_end} {phang}{cmd:. xtkr d.y d.x (d.l.y = l(2/3).y l(2/3).x)}

{title:Also see}

{psee}
{space 2}Online:  {helpb xtdata}, {helpb xtabond2}, {helpb xtset}, {helpb xtreg}, {helpb xtdpd}
{p_end}
