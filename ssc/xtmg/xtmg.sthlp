
{smcl}
{* *! version 1.0.1 8Feb2011}{...}
{cmd:help xtmg}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{pstd}{cmd:xtmg} {hline 2} Estimating panel time series models with heterogeneous slopes 
{p2colreset}{...}


{title:Syntax}

{pstd}{cmd:xtmg} {varlist} {ifin} [{cmd:,} {cmd:trend} {cmd:robust} {cmd:cce} {cmd:aug} {cmd:imp} {cmd:full} 
{cmd:level(}{it:num}{cmd:)} {cmd:res(}{it:string}{cmd:)}]


{title:Description}

{pstd}{cmd:xtmg} implements a number of panel time series estimators which allow for heterogeneous
slope coefficients across group members and are also concerned with correlation across panel members (cross-section dependence):
the Pesaran and Smith (1995) Mean Group estimator, the Pesaran (2006) Common Correlated Effects Mean Group estimator and the 
Augmented Mean Group estimator, introduced in Eberhardt and Teal (2010) and Bond and Eberhardt (2009). 

{pstd}{cmdab:(i) Background:}

{p 4 4 2}These various estimators are designed for 'moderate-T, moderate-N' macro panels, where moderate typically means from around  
15 time-series/cross-section observations --- from a micro panel perspective this is 'large-T, small-N' and from a time-series perspective 
'small-T' and the analysis of this type of data is frequently dominated by estimators developed for micro datasets (see for instance the 
discussion in Roodman, 2009). Examples for this type of data include the Penn World Table and macro panel 
data from organisations such as the World Bank, FAO, IMF, OECD, etc, all of which provide time-series of frequently up to 60 years across 
a significant number of developing and developed economies. For links to these and other datasets refer to 
{browse "http://sites.google.com/site/medevecon/development-economics/devecondata":this} website.{p_end}

{p 4 4 2}The estimators implemented here form part of the panel time series (aka nonstationary panel) literature, which emphasises 
variable nonstationarity, cross-section dependence as well as 
parameter heterogeneity (in the slope parameters, not just time-invariant effects). For discussion and illustration of the application of panel time series methods see Eberhardt and Teal (2010, 2011) 
and Moscone and Tosetti (2010).


{pstd}{cmdab:(ii) Empirical Model:}

{pstd}Assume the following simple model: for i=1,...,N ('group', typically countries or regions) 
and t=1,...,T (time, typically years) let 

{p 8 0 2}(1){space 4}y_it = {bind:x_it'*b_i} + u_it

{p 8 0 2}(2){space 4}x_it = a2_i + {bind:lambda_i*f_t} + {bind:gamma_i*g_t} + eps_it  

{p 8 0 2}(3){space 4}u_it = a1_i + {bind:lambda_i*f_t} + e_it

{pstd}where x_it and y_it are observables, b_i are country-specific slopes on the observable regressors and
u_it contains the unobservables and the error terms e_it. The unobservables in equation (3) are made up of standard group fixed 
effects a1_i, which capture time-invariant heterogeneity across groups, as well as an unobserved common factor f_t with 
heterogeneous factor loadings lambda_i, which can capture time-variant heterogeneity and cross-section dependence. Note that
the factors (f_t and similarly g_t) are not limited to linear evolution over time, but can be non-linear and also 
nonstationary, with obvious implications for cointegration.
For simplicity the model only includes one covariate and one unobserved common factor in the estimation equation of interest (1). Additional problems 
arise if the regressors are driven by some of the same common factors as the observables: note the presence of f_t in 
equations (2) and (3), see discussion in Coakley, Fuertes and Smith (2006). eps_it and e_it are assumed white noise.


{pstd}{cmdab:(iii) Empirical Implementation:}

{p 4 0 2}All Mean Group type estimators follow the same principle methodology: 

{p 8 0 2}(a) estimate a group-specific regression,{p_end}
{p 8 0 2}(b) average the estimated coefficients across groups. 

{p 4 4 2}The following describes the estimators implemented in this routine in some more detail.

{p 4 4 2}The {cmd:Pesaran and Smith (1995) Mean Group estimator} (MG) does not concern itself 
with cross-section dependence and assumes away lambda_i*f_t or models these unobservables with a linear trend. 
Thus equation (1) above is estimated for each panel member i, including an intercept to capture fixed effects and
optionally a linear trend to capture time-variant unobservables. The coefficients b_i are subsequently averaged across panel
members {hline 2} here weights can be applied but in the standard implementation this is just the unweighted 
average. Note that the Blackburne and Frank ({help xtpmg} if installed) command as well as a recent version of Persyn's ({help xtwest} if installed)
command optionally provide MG estimates for dynamic specifications.

{p 4 4 2}The {cmd:Pesaran (2006) Common Correlated Effects Mean Group estimator} (CCEMG) allows for the empirical setup as laid
out in equations (1) to (3), which induces cross-section dependence, time-variant unobservables with heterogeneous 
impact across panel members and problems of identification (b_i is unidentified if the regressor contains f_t). The 
latter issue is comparable to the transmission bias problem in micro production function models, whereby inputs x_it
are correlated with (from the econometrician's perspective) unobserved productivity shocks f_t. The CCEMG solves this problem with a simple but powerful augmentation of the group-specific regression equation: apart from the 
regressors x_it and an intercept this equation now includes the cross-section/panel averages (for the entire panel i=1,...,N) of the dependent and independent 
variables: ybar_t and xbar_t. Together these can account for the unobserved common factor f_t and given the group-specific 
estimation the heterogeneous impact (lambda_i) is also given. The coefficients b_i are again averaged across panel
members, where different weights may be applied. 

{p 4 4 2}In empirical application the estimated coefficients on the 
cross-section averaged variables as well as their average estimates are not interpretable in a meaningful way: they are 
merely present to blend out the biasing impact of the unobservable common factor. The focus of the estimator is on obtaining 
consistent estimates of the parameters related to the observable variables. The CCEMG approach is robust to the 
presence of a limited number of 'strong' factors as well as an infinite number of 'weak' factors {hline 2} the latter can 
be associated with local spillover effects, whereas the former represent global shocks (see Pesaran and Tosetti (2010) for 
further details). Furthermore, as shown by Kapetanios, Pesaran and Yamagata (2011), these factors may be nonstationary. 

{p 4 4 2}The {cmd:Augmented Mean Group estimator} (AMG) was developed in Eberhardt and Teal (2010) as an alternative to 
the Pesaran (2006) CCEMG with production function estimation in mind. In the CCEMG the set of unobservable 
common factors is treated as a nuisance, something to be accounted for which is not of particular interest for the 
empirical analysis. In cross-country production functions, however, unobservables represent Total Factor Productivity (TFP). Note 
that standard panel approaches to cross-country empirics are commonly based on a production function of Cobb-Douglas form, see 
Eberhardt and Teal (2011) for a detailed discussion of the growth empirics literature.{p_end}

{p 4 4 2}The AMG procedure, which is further discussed and tested using Monte Carlo simulations in Bond and Eberhardt (2009), is implemented  
in three steps: (i) A pooled regression model augmented with year dummies is estimated by first difference OLS and the 
coefficients on the (differenced) year dummies are collected. They represent an estimated cross-group average of the 
evolution of unobservable TFP over time. This is referred to as 'common dynamic process'.
(ii) The group-specific regression model is then augmented with this estimated TFP process: either (a) as an explicit variable, 
or (b) imposed on each group member with unit coefficient by subtracting the estimated process from the dependent variable. Like in 
the MG case the regression model includes an intercept, which captures time-invariant fixed effects (TFP level). (iii) Like in the 
MG and CCEMG the group-specific model parameters are  averaged across the panel. In simulations the AMG performed similarly well 
as the CCEMG in terms of bias or RMSE in panels with nonstationary variables (cointegrated or not) and multifactor error terms 
(cross-section dependence).

{p 4 4 2}Note that the {cmd:standard errors} reported in the averaged regression results (i.e. the standard output) are 
constructed following Pesaran and Smith (1995), thus testing the significant difference of the average coefficient from zero. 
In practice the group-specific coefficients are regressed on an intercept, either without any weighting or attaching less weight 
to 'outliers' (see {help rreg} for more details on the latter.
 

{title:Options}

{p 4 4 2}{cmd:cce} implements the Pesaran (2006) CCE Mean Group estimator (default: Pesaran and Smith (1995) Mean
Group estimator). The output includes the averaged coefficients on the cross-section averages of the dependent
and independent variables. These are identified by the suffix _{it:varname}.

{p 4 4 2}{cmd:aug} implements the Augmented MG estimator. 

{p 4 4 2}{cmd:imp} specifies that the Augmented MG estimator is implemented by imposing the 'common dynamic process' with 
unit coefficient (by subtracting it from the dependent variable). This option only works in combination with {cmd:aug}.

{p 4 4 2}{cmd:trend} specifies a group-specific linear trend to be included in the regression model.

{p 4 4 2}{cmd:robust} estimates the outlier-robust mean of parameter coefficients across groups. This is 
implemented via the Stata command {cmd:rreg} for robust regression. An example of this practice can be found in 
Bond, Leblebicioglu and Schiantarelli  (2010).
This option is {it:not to be confused} with the standard option calling for White heteroskedasticity-robust 
standard errors in the {cmd:reg} and {cmd:xtreg} commands.

{p 4 4 2}{cmd:full} provides the underlying group-specific regression results. These can also be accessed 
using the matrices stored as part of the the xtmg command: the group-specific coefficients in e(betas), 
related t-statistics in e(tbetas).

{p 4 4 2}{cmd:level(}{it:num}{cmd:)} specifies the confidence level for confidence intervals, allowing for values between 10 and 99.99 inclusive. 
If option trend is used the routine will compute the number and share of group-specific trends in the sample which are significant at the (100-{it:num})
significance level.

{p 4 4 2}{cmd:res(}{it:string}{cmd:)} provides residuals which are stored in {it:string}. These can then be subjected to 
diagnostic tests, including for cross-section dependence (see {help xtcd} if installed). Note that these residual series
are not based on the linear prediction of the {it:averaged MG estimates} but are derived from the group-specific
regressions. This is similar to the post-estimation command {cmd:predict} with the option {cmd: group(}{it:varname}{cmd:)} in the 
Random Coefficient Model estimator {help xtrc}, although in the latter this only allows for predicted values with residuals 
not directly obtainable.


{title:Return values}

{col 4}Scalars
{col 8}{cmd:e(N)}{col 27}Number of observations used in the estimation
{col 8}{cmd:e(N_g)}{col 27}Number of groups
{col 8}{cmd:e(g_min)}{col 27}Lowest number of observations in an included group
{col 8}{cmd:e(g_max)}{col 27}Highest number of observations in an included group
{col 8}{cmd:e(g_avg)}{col 27}Average number of observations per included group
{col 8}{cmd:e(df_m)}{col 27}Model degrees of freedom
{col 8}{cmd:e(chi2)}{col 27}Wald chi-squared statistic 
{col 8}{cmd:e(sig2)} {col 27}Estimated variance of the model residuals
{col 8}{cmd:e(trend_sig)} {col 27}Share of group-specific linear trends statistically significant
{col 30}(significance level determined by choice of level( ))

{col 4}Macros
{col 8}{cmd:e(cmd)}{col 27}Name of Stata command: "xtmg"
{col 8}{cmd:e(ivar)}{col 27}Group (panel) variable
{col 8}{cmd:e(tvar)}{col 27}Time variable
{col 8}{cmd:e(title2)}{col 27}Estimator selected: MG, AMG or CCEMG
{col 8}{cmd:e(depvar)}{col 27}Dependent variable


{col 4}Matrices
{col 8}{cmd:e(b)}{col 27}Vector of averaged coefficients
{col 8}{cmd:e(V)}{col 27}Variance-covariance matrix
{col 8}{cmd:e(betas)}{col 27}Matrix of group-specific regression coefficients, printed with 
{col 30}the {it:full} option
{col 8}{cmd:e(varbetas)}{col 27}Matrix of variances associated with group-specific regression
{col 30}coefficients
{col 8}{cmd:e(stebetas)}{col 27}Matrix of standard errors associated with group-specific 
{col 30}regression coefficients, printed with the {it:full} option
{col 8}{cmd:e(tbetas)}{col 27}Matrix of t-statistics associated with group-specific regression 
{col 30}coefficients, printed with the {it:full} option

{col 4}Functions
{col 8}{cmd:e(sample)}{col 27}Marks estimation sample


{title:Example}

{p 0 0 2}Download manufacturing {browse "http://sites.google.com/site/medevecon/publications-and-working-papers/manu_stata9.zip":data} (zipped file) for 
48 countries from 1970 to 2002 (unbalanced panel), see Eberhardt and Teal (2010) for more details on data construction and deflation, and open the manu.dta file in Stata.{p_end}

{p 0 0 2}Variables used here: ly - log value-added per worker, lk - log capital stock per worker (for the manufacturing sector respectively). 
The following examples estimate cross-country production functions of the Cobb-Douglas form with CRS imposed. Results can be compared with 
those in the above mentioned paper (except for the -robust- option).

{p 0 4 2}Set panel dimensions: time variable - year, country identifier - list{p_end}
{p 4 8 2}{stata "tsset list year": .tsset list year}

{p 0 4 2}Production function model estimated using the standard MG estimator{p_end}
{p 4 8 2}{stata "xtmg ly lk": .xtmg ly lk}

{p 0 4 2}Dto with country-specific linear trend{p_end}
{p 4 8 2}{stata "xtmg ly lk, trend": .xtmg ly lk, trend}

{p 0 4 2}Dto but computing outlier-robust (instead of unweighted) means{p_end}
{p 4 8 2}{stata "xtmg ly lk, trend robust": .xtmg ly lk, trend robust}

{p 0 4 2}Production function model estimated using the CCEMG estimator{p_end}
{p 4 8 2}{stata "xtmg ly lk, cce": .xtmg ly lk, cce}

{p 0 4 2}Dto but also printing country-specific results{p_end}
{p 4 8 2}{stata "xtmg ly lk, cce full": .xtmg ly lk, cce full}

{p 0 4 2}Dto but storing country-specific regression residuals in variable {it:cce_res}{p_end}
{p 4 8 2}{stata "xtmg ly lk, cce res(cce_res)": .xtmg ly lk, cce res(cce_res)}

{p 0 4 2}Production function model estimated using the AMG estimator 
(group-specific trend-terms included){p_end}
{p 4 8 2}{stata "xtmg ly lk, trend aug": .xtmg ly lk, trend aug}

{p 0 4 2}Dto but imposed the 'common dynamic process' with unit coefficient{p_end}
{p 4 8 2}{stata "xtmg ly lk, trend aug imp": .xtmg ly lk, trend aug imp}


{title:References}

{p 0 4 2}Bond, Steve, Asli Leblebicioglu and Fabio Schiantarelli (2010) 'Capital accumulation and growth: 
a new look at the empirical evidence,' {it:Journal of Applied Econometrics}, Vol. 25(7), pp.1073-1099.

{p 0 4 2}Bond, Steve and Markus Eberhardt (2009) 'Cross-section dependence in nonstationary panel models: a novel estimator',
paper presented at the Nordic Econometrics Conference in Lund, available from {browse "http://sites.google.com/site/medevecon/publications-and-working-papers":here}.

{p 0 4 2}Coakley, Jerry, Ana-Maria Fuertes and Ron P. Smith (2006) 'Unobserved heterogeneity in panel 
time series models', {it:Computational Statistics & Data Analysis}, Vol.50(9), pp.2361-2380.

{p 0 4 2}Eberhardt, Markus and Francis Teal (2011) 'Econometrics for Grumblers: A New Look at the Literature 
on Cross-Country Growth Empirics', {it:Journal of Economic Surveys}, Vol.25(1), pp.109–155, 
available from {browse "http://sites.google.com/site/medevecon/publications-and-working-papers":here}.

{p 0 4 2}Eberhardt, Markus and Francis Teal (2010) 'Productivity Analysis in Global Manufacturing 
Production', Economics Series Working Papers 515, University of Oxford, Department of Economics, 
available from {browse "http://sites.google.com/site/medevecon/publications-and-working-papers":here}.

{p 0 4 2}Kapetanios, George, M. Hashem Pesaran and Takashi Yamagata (2011) Panels with non-stationary 
multifactor error structures, {it:Journal of Econometrics}, Vol.160(2), pp.326-348.

{p 0 4 2}Moscone, Francesco and Elisa Tosetti (2009) 'Health Expenditure and Income in the United States', 
{it:Health Economics}, Vol.19(12), pp.1385-1403.

{p 0 4 2}Pesaran, M. Hashem (2006) 'Estimation and inference in large heterogeneous panels with a multifactor 
error structure.' {it:Econometrica}, Vol. 74(4): pp.967-1012.

{p 0 4 2}Pesaran, M Hashem, Yongcheol Shin and Ron Smith (1999) 'Pooled mean group estimation of dynamic 
heterogeneous panels', {it:Journal of the American Statistical Association}, Vol.94 pp.621-634.

{p 0 4 2}Pesaran, M. Hashem and Ron P. Smith (1995). 'Estimating long-run relationships from dynamic
heterogeneous panels.' {it:Journal of Econometrics}, Vol. 68(1): pp.79-113.

{p 0 4 2}Pesaran, M. Hashem and Elisa Tosetti (2010) 'Large Panels with Common Factors and Spatial
Correlations', Cambridge University, unpublished working paper, December 2010.

{p 0 4 2}Roodman, David (2009) 'A Note on the Theme of Too Many Instruments', Oxford Bulletin of Economics 
and Statistics, Department of Economics, Vol. 71(1), pp.135-158.


{title:Acknowledgements and Disclaimer}

{p 0 0 2}This routine builds to a considerable extent on the existing code for the Swamy RCM estimator ({help xtrc}), 
the Pesaran, Shin and  Smith (1999) Pooled Mean Group estimator written by Edward F. Blackburne 
and Mark W. Frank ({help xtpmg} if installed) and the Westerlund (2007) error correction cointegration test ({help xtwest} 
if installed) written by Damiaan Persyn. Thanks to Kit Baum for help and support. Any errors are of course my own.


{title:Author}

{browse "http://sites.google.com/site/medevecon":Markus Eberhardt}
Centre for the Study of African Economies
Department of Economics
University of Oxford
Manor Road, Oxford OX1 3UQ
{browse "mailto:markus.eberhardt@economics.ox.ac.uk":markus.eberhardt@economics.ox.ac.uk} 


{title:Also see}

{p 0 8 2}Online: help for {help xtrc}, {help xtpmg} (if installed), {help xtwest} (if installed), {help xtcsd} (if installed), 
{help xtcd} (if installed).

