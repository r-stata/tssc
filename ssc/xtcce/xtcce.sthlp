{smcl}
{* version 1.1.0 28January2016}{...}
{cmd: help xtcce}{right: ...}
{hline}

{title:Title}

{phang}
{bf:xtcce} {hline 2} Common Correlated Effects Estimation for Static/Dynamic Panels with Cross-Sectional Dependence.

{title:Syntax}

{p 4 4 2}
{cmd:xtcce} {depvar} [{varlist1}] ([{varlist2}] = [{varlist3}]) {ifin} 
[{cmd:,} {it:dynamic gmm pooled full weighted cov(varlist4) alags(#) res(resname)}]{p_end}

{p 4 4 2}Items in [brackets] are optional, {varlist1} contains any exogenous explanatory variables, {varlist2} 
contains any endogenous variables, and lastly {varlist3} contains the instruments. 
You must {cmd:xtset} your data before using {cmd:xtcce}; see {helpb xtset}.{p_end}

{title:Description}

{pstd}
{cmd:xtcce} is for large static or dynamic panel data models (medium to large N and T) that suffer from 
cross-sectional dependence (also known as unobserved common factors or common shocks), slope heterogeneity, 
and endogenous regressors. It implements the Pesaran (2006) Common Correlated Effects ('CCE') estimator for 
static panel estimation, the Chudik & Pesaran (2015) Dynamic CCE estimator for dynamic panel estimation, and 
finally the Neal (2015) 2SLS and GMM extensions of both models.

{p 4 4 2}Consider the following panel model:{p_end}

{p 4 4 2}y_it = rho_i*y_(it-1) + beta_i*x_it + mu_i + gamma_i*f_t + v_it{p_end}

{p 4 4 2}x_it = Gamma_i*f_t + e_it{p_end}

{p 4 4 2}where rho_i is the autoregressive coefficient for individual i, x_it is a NTxK matrix of regressors, 
beta_i is a 1xK vector of coefficients for individual i, mu_i is the individual-specific fixed effect, f_t is a 1xM 
vector of unobserved common factors, gamma_i and Gamma_i are the heterogeneous factor loadings, and v_it and 
e_it are the idiosyncratic error terms. 

{p 4 4 2}Since both the regressors x_it and the dependent variable y_it depend on the vector of unobserved 
common factors f_t, pooled or mean group OLS will provide an inconsistent estimate of rho or beta. The 
presence of unobserved common factors is one representation of cross-sectional dependence in panel data. The 
idea of common correlated effects estimation, introduced in Pesaran (2006), is to approximate the projection 
space of the unobserved common factors with the inclusion of cross section averages of the variables in the 
regression equation.{p_end}

{p 4 4 2}Pesaran (2006) proposed the common correlated effects model (here called CCE-OLS) to consistently 
estimate beta_i in the equation above when rho_i = 0 for all i and the regressors are strictly exogenous. It 
can be estimated with pooled or mean group OLS, with the latter accounting for slope heterogeneity among panel
 units. Chudik and Pesaran (2015) extended this model to allow for a dynamic specification (i.e. rho_i => 0) 
 and weakly exogenous regressors (here called DCCE-OLS). It achieves this by adding lags of the cross section 
 averages to the regression. Neal (2015) further extended the CCE/DCCE approach by estimating the regressions 
 equation(s) with 2SLS or GMM to account for endogenous regressors and improve the efficiency of the DCCE 
 estimator (please see Neal (2015) for Monte Carlo simulation results that demonstrate this), using further 
 lags of the variables to form the instrument set.{p_end}

{p 4 4 2}The result is a powerful and flexible suite of estimation options for large panel models that allows 
for cross-sectional dependence, static or dynamic specifications, exogenous or endogenous regressors, fixed effects, and heterogeneous 
slopes. Please see the references below for further information on the usefulness of these estimators.{p_end}

{title:References and Further Reading}

{p 4 4 2}Pesaran, M.H. (2006) "Estimation and inference in large heterogeneous panels with a multifactor error structure", Econometrica, 74(4), p.967-1012{p_end}

{p 4 4 2}Pesaran, M.H. and Chudik, A. (2015) "Common correlated effects estimation of heterogeneous dynamic panel data models with weakly exogenous regressors", Journal of Econometrics, 188(2), p.393-420{p_end}

{p 4 4 2}Neal, T. (2015) "Estimating Heterogeneous Coefficients in Panel Data Models with Endogenous Regressors and Common Factors", Working Paper{p_end}

{title:Options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt dynamic}}Required option whenever one or more lag of the dependent variable is added as an 
exogenous or endogenous regressor. It adds lags to the cross section averages to ensure consistency, as in 
Chudik and Pesaran (2015). The number of lags is automatically set to T^(1/3), but can be changed manually 
with the option {opt alags(#)} below. {p_end}
{synopt:{opt gmm}}Uses GMM estimation if endogenous and instrumental variables are present in the regression 
equation. If this option is not enabled, 2SLS will be used in those instances.{p_end}
{synopt:{opt weighted}}Weights the mean group coefficient results by the standard errors of the individual 
coefficients. This option is recommended as a robustness check, and whenever the distribution of beta 
coefficients across panel units is volatile.{p_end}
{synopt:{opt full}}Shows regression output for each panel unit in addition to the mean group results at the end. 
Has no effect if the option {opt pooled} is selected.{p_end}
{synopt:{opt pooled}}Uses pooled regression, as opposed to mean group regression which is the default. To account for 
individual-specific factor loadings it interacts the id variable with the cross section averages.
Enabling this option is not recommended when slope heterogeneity is suspected.{p_end}
{synopt:{opt cov(varlist4)}}Adds cross section averages of {it: varlist4} to the regression, without including them 
as regressors. This is recommended whenever it is suspected that the number of 
unobserved common factors exceeds the number of variables in the model.{p_end}
{synopt:{opt alags(#)}}Changes the number of lags of the cross section averages used in dynamic models to #. 
It has no effect if the option {opt dynamic} is not enabled. {p_end}
{synopt:{opt res(resname)}} Stores the residuals of the regressions to resname. {p_end}

{title:Examples}

{p 4 4 2}In cases where the regressor x is strictly exogenous:{p_end}

{p 4 4 2}CCE-OLS:{p_end}{phang}{cmd:. xtcce y x}

{p 4 4 2}DCCE-OLS:{p_end} {phang}{cmd:. xtcce y l.y x, dynamic}

{p 4 4 2}For efficiency improvements in the dynamic specification, one might use:{p_end}

{p 4 4 2}DCCE-2SLS: {p_end}{phang}{cmd:. xtcce y x (l.y = l(2/4).y), dynamic}

{p 4 4 2}DCCE-GMM:{p_end} {phang}{cmd:. xtcce y x (l.y = l(2/4).y), dynamic gmm}

{p 4 4 2}In cases where the regressor x is endogenous, one might use:{p_end}

{p 4 4 2}CCE-2SLS:{p_end} {phang}{cmd:. xtcce y (x = l(1/2).x l(1/2).y)}

{p 4 4 2}CCE-GMM{p_end} {phang}{cmd:. xtcce y (x = l(1/2).x l(1/2).y), gmm}

{p 4 4 2}DCCE-2SLS:{p_end} {phang}{cmd:. xtcce y (l.y x = l(2/3).y l(1/3).x), dynamic}

{p 4 4 2}DCCE-GMM{p_end} {phang}{cmd:. xtcce y (l.y x = l(2/3).y l(1/3).x), dynamic gmm}

{title:Tip}

{p 4 4 2}It is always worthwhile to check the sensitivity of results and try a variety of specifications. 
Check the {cmd:e(bfull)} vector after estimation to see the degree of volatility in the estimated beta coefficient 
across panel units. Use the option {opt full} to see if there are significant outliers or strange results in some of 
the panel units, and then consider excluding them. Try a static and a dynamic version of the model. Try 
treating either the lagged dependent variable or the regressors as endogenous, and use lags to form the 
instrument set. See if the results vary significantly between 2SLS and GMM.{p_end}

{title:Known Issues}

{p 4 4 2}This command will not add cross section averages of any variables with time series operators in order to prevent them 
clashing in dynamic models. This is only problematic with differenced variables (e.g. d.x) or when lags of 
regressors are used and the contemporaneous observation is not (i.e. l(1/3).x but not x). In these situations, the 
variables should be manually transformed prior to estimation.{p_end}

{p 4 4 2}GMM will not use a HAC weight matrix when the estimator is pooled (due to the limitation of the 
command {cmd: ivregress}), in mean group regressions (the default) it will use a HAC weight matrix.{p_end}

{p 4 4 2}Errors will usually arise when mean group estimation is used and one or more of the panel units have 
very small T. Exclude these panel units from the sample to solve this problem.{p_end}

{title:Saved results}

{pstd}{cmd:xtcce} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}Number of usable observations{p_end}
{synopt:{cmd:e(g_min)}}Fewest number of observations in an included
panel unit{p_end}
{synopt:{cmd:e(g_max)}}Largest number of observations in an included
panel unit{p_end}
{synopt:{cmd:e(g_avg)}}The average number of observations in an included
panel unit{p_end}
{synopt:{cmd:e(N_g)}}Number of panel units{p_end}
{synopt:{cmd:e(chi2)}}Chi-squared{p_end}
{synopt:{cmd:e(df_m)}}Model degrees of freedom{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(ivar)}}Panel unit identification variable{p_end}
{synopt:{cmd:e(tvar)}}Time variable{p_end}
{synopt:{cmd:e(depvar)}}Dependent variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}Vector of coefficients{p_end}
{synopt:{cmd:e(V)}}Variance-covariance matrix of the estimates{p_end}
{synopt:{cmd:e(bfull)}}Complete matrix of the individual-level regression coefficients 
(note: not available with option {opt pooled}){p_end}

{title:Author}

{pstd}Timothy Neal{p_end}
{pstd}School of Economics{p_end}
{pstd}University of New South Wales{p_end}
{pstd}Sydney, Australia{p_end}
{pstd}{browse "mailto:timothy.neal@unsw.edu.au":timothy.neal@unsw.edu.au} {p_end}
{pstd}{browse "https://sites.google.com/site/tjrneal/stata-code":https://sites.google.com/site/tjrneal/stata-code} {p_end}

{title:Also see}

{psee}
{space 2}Online:  {helpb xtmg}, {helpb xtpedroni}, {helpb xtset}, {helpb xtpmg}
{p_end}
