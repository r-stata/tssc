{smcl}
{* *! version 3.0  14 Apr 2021}{...}
{viewerjumpto "Syntax" "examplextgranger##syntax"}{...}
{viewerjumpto "Description" "examplextgranger##description"}{...}
{viewerjumpto "Options" "examplextgranger##options"}{...}
{viewerjumpto "Examples" "examplextgranger##examples"}{...}
{viewerjumpto "Stored results" "exampleproject##stored results"}{...}
{title:Title}
{phang}
{bf:[xt] xtgranger} {hline 2} Testing for Granger non-causality in heterogeneous panel data models, using the methodology developed by Juodis, Karavias, and Sarafidis (2021).

{marker syntax}{...}
{title:Syntax}

{phang}
{p 8 16 2}{cmd:xtgranger} {depvar} [{indepvars}] [if] [in] 
[, lags(integer) maxlags(integer) het sum nodfc] 

{smcl}

{p 4 6 2}
You must {cmd:xtset} your data before using {cmd:xtgranger}; see {helpb xtset:[XT] xtset}.{p_end}

{smcl}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xtgranger} performs the Half-Panel Jackknife (HPJ) Wald-type test for Granger non-causality, developed by Juodis, Karavias, and Sarafidis (2021). 
This test offers superior size and power performance, which stems from the use of a pooled estimator with a sqrt(NT) rate of convergence. 
The test has two other useful properties; it can be used in multivariate systems and it has power against both homogeneous as well as heterogeneous alternatives. 
The command also reports results for the HPJ estimator. 
{smcl}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt lags():} specifies the number of lags of dependent and independent variables to be added to the regression. If {cmd:lags()} is not specified, the default is {cmd:lags(1)}.{p_end}

{phang}
{opt maxlags:()} specifies the upper bound of lags. The BIC criterion is used to select the number of lags that provides the best model fit. {cmd:lags()} and {cmd:maxlags()} cannot be used at the same time.{p_end} 

{dlgtab:SE/Robust}
{phang}
{opt het} allows for cross-sectional heteroskedasticity.

{phang}
{opt nodfc} does not apply a degrees of freedom correction in the computation of the variance-covariance matrix of the HPJ estimator. This option is mostly useful under cross-sectional heteroskedasticity.

{dlgtab:Reporting}
{phang}
{opt sum} presents results on the sum of the estimated feedback coefficients. This option can be useful when the number of lags is greater than 1.


{marker examples}{...}
{title:Examples}

{phang} The dataset xtgranger_example.dta used in this example is downloadable from the SSC Archive and 
{browse "https://sites.google.com/site/yianniskaravias/files/xtgranger"}.

{pstd}xtset the data{p_end}
{phang2}{cmd:xtset cert time} 

{pstd}Dynamic model with given lags{p_end}
{phang2}{cmd:xtgranger roa inefficiency quality, lags(2)} 

{pstd}Dynamic model with given lags, cross-sectional heteroskedasticity-robust standard errors {p_end}
{phang2}{cmd:xtgranger roa inefficiency quality, lags(2) het}

{pstd}Dynamic model with given lags and cross-sectional heteroskedasticity-robust standard errors. It reports the sum of the lagged coefficients {p_end}
{phang2}{cmd:xtgranger roa inefficiency quality, lags(2) het sum}

{pstd}Dynamic model with lag length selection (up to 4 lags) based on BIC, with cross-sectional heteroskedasticity-robust standard errors {p_end}
{phang2}{cmd:xtgranger roa inefficiency quality, maxlags(4) het}{p_end}

{pstd}Dynamic model with lag length selection (up to 4 lags) based on BIC, with cross-sectional heteroskedasticity-robust standard errors, and no variance degrees-of-freedom correction {p_end}
{phang2}{cmd:xtgranger roa inefficiency quality, maxlags(4) het nodfc}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:xtgranger} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}Number of individual units{p_end}
{synopt:{cmd:e(T)}}Number of time periods{p_end}
{synopt:{cmd:e(p)}}Number of lags{p_end}
{synopt:{cmd:e(BIC)}}BIC values{p_end}
{synopt:{cmd:e(W_HPJ)}}The Wald test statistic{p_end}
{synopt:{cmd:e(pvalue)}}P-value for the HPJ Wald test{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b_HPJ)}}The HPJ coefficient estimator{p_end}
{synopt:{cmd:e(Var_HPJ)}}The variance-covariance matrix of the HPJ estimator {p_end}
{synopt:{cmd:e(b_Sum_HPJ)}}Sum of the HPJ estimates for the feedback coefficients{p_end}
{synopt:{cmd:e(Var_Sum_HPJ)}}The variance of the sum of the HPJ estimators {p_end}

{title:References}
{p}
{p_end}
{pstd}

Dhaene, G., Jochmans, K., 2015. Split-panel Jackknife estimation of fixed-effect models. Rev Econ Stud, 82:991–1030

Juodis, A., Karavias, Y., and Sarafidis, V., 2021. A homogeneous approach to testing for Granger non-causality in heterogeneous panels. Empir Econ 60, 93–112. {browse "https://doi.org/10.1007/s00181-020-01970-9"}

Xiao, J., Juodis, A., Karavias, Y., and Sarafidis, V., 2021. Improved Tests for Granger Causality in Panel Data. Submitted to the Stata Journal.

{title:Acknowledgements}
{p}
{p_end}
{pstd}
{cmd:xtgranger} is not an official Stata command. It is a free contribution to the research community. Please cite Xiao et al (2021) and Juodis et al (2021), as listed in the references above.

{title:Authors}
{p}
{p_end}

{pstd}
Jiaqi Xiao{break}
University of Birmingham{break}
Birmingham, UK{break}
{browse "mailto:Jxx963@outlook.com?subject=Question/remark about -xtgranger-&cc=Jxx963@outlook.com":Jxx963@outlook.com}

{pstd}
Yiannis Karavias{break}
University of Birmingham{break}
Birmingham, UK{break}
{browse "mailto:i.Karavias@bham.ac.uk?subject=Question/remark about -xtgranger-&cc=i.Karavias@bham.ac.uk":i.Karavias@bham.ac.uk}

{pstd}
Vasilis Sarafidis{break}
BI Norwegian Business School{break}
Oslo, Norway{break}
{browse "mailto:vasilis.sarafidis@gmail.com?subject=Question/remark about -xtgranger-&cc=vasilis.sarafidis@gmail.com":vasilis.sarafidis@gmail.com}


