{smcl}
{* *! version 1 23jul2020}{...}
{cmd:help radf}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:radf} {hline 2}}Unit root tests for explosive behaviour:
right-tail augmented Dickey-Fuller (1979) (ADF); right-tail supremum ADF of Phillips, Wu and Yu (2011); right-tail generalised supremum ADF of Phillips, Shi and Yu (2015){p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:radf} {varname} {ifin} [{cmd:,}
{opt pre:fix(string)}
{opt max:lag(integer)}
{opt crit:erion(string)}
{opt win:dow(integer)}
{opt bs}
{opt seed(integer)}
{opt boot(integer)}
{cmdab:print}
{cmdab:graph}]

{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:radf}; see {manhelp tsset TS}.{p_end}
{p 4 6 2}
{it:varname} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{cmd:by} is not allowed. Sample may not contain gaps.{p_end}

{title:Description}

{pstd}
{cmd:radf} computes the right-tail augmented Dickey-Fuller (1979) (ADF) unit root test,
and its further developments based on supremum statistics derived from ADF-type regressions estimated using
recursive windows (Phillips, Wu and Yu, 2011) and recursive flexible windows (Phillips, Shi and Yu, 2015).
The command allows for the number of lags of the dependent variable in the test regression and the width of
rolling windows to be either specified by the user or determined using data-dependent procedures.
Also, it allows for the implementation of the date-stamping procedures advocated by Phillips, Wu and Yu (2011)
and Phillips, Shi and Yu (2015) to identify episodes of explosive behaviour.

{pstd}
For computational convenience, {cmd:radf} takes advantage of a large set of critical values already available in the
R Core Team (2020) package {cmd: exuber}; see Vasilopoulos, Pavlidis, Spavound and Mart{c i'}nez-Garc{c i'}a (2020b) and
Vasilopoulos, Pavlidis and Mart{c i'}nez-Garc{c i'}a (2020a). More specifically, the critical values that we incorporated in {cmd: radf}
are the 90, 95 and 99% critical values provided by {cmd: exuber}, which were obtained using 2000 replications, seed equal to 123,
initial window size given by r = 0.01 + 1.8/sqrt(T), and T = 6, 7, 8, ..., 600, 700, 800, ..., 2000 observations. For 600 < T <= 2000
the sample size is used to interpolate between the critical values. For T > 2000, the critical values that are included in the summary
results table correspond to those for T = 2000.

{pstd}
As an option, {cmd:radf} also computes 90, 95, and 99% bootstrap critical values following the wild bootstrap scheme advocated by Phillips and Shi (2020).
This option allows the computation of bootstrap critical values for any initial window width.

{title:Options}

{phang}
{opt prefix} can be used to provide a `stub' with which variables created in {cmd: radf} will be named if no more than 600 observations
are in the specified sample. If this option is given, four Stata variables will be created for the appropriate range of dates:
{it:prefix_}SADF, {it:prefix_}BSADF, {it:prefix_}BSADF_95 and {it:prefix_}Exceeding. These variables record the SADF and BSADF statistics,
with the third variable displaying the 95% critical values for the BSADF statistic, which vary over the estimation period.
The fourth variable is an indicator, set to 1 when the BSADF statistic exceeds its 95% critical value. The {opt prefix} option must be specified to enable
the {opt graph} option.

{phang}
{opt maxlag} sets the number of lags to be included in the test regression to account for residual serial correlation.
If not specified, {cmd: radf} sets the number of lags following Schwert (1989), with the formula {cmd:maxlag}=int{4*(T/100)^0.25}, where
where T is the total number of observations. In either case, the number of lags is reported in the output. If {opt maxlag} is given and the window width
is set by the data-dependent procedure, they may conflict. In this case, {cmd: radf} reduces {opt maxlag} so that each ADF regression has positive degrees of freedom.

{phang}
{opt criterion} By default, {cmd: radf} computes the ADF regressions based on a fixed {opt maxlag}, either that determined by a data-dependent procedure or specified by the user.
Alternatively, the program can determine the optimal number of lags according to the Akaike or Schwarz information criteria, denoted AIC and SIC, respectively, or by following the
general-to-specific (GTS) algorithm advocated by Hall (1994) and Ng and Perron (1995). The {opt criterion} option can be used to specify {opt AIC, SIC, GTS05} or {opt GTS10} as alternatives
to the default value of {opt FIX}. 

{phang}
{opt window} The initial window width used in the rolling ADF regressions takes the default value of r = 0.01 + 1.8/sqrt(T). The {opt window()} option can be used to select a different window width.
However, as the critical values have been developed for the defsult window width, a warning is provided if the window width is set by the user, showing the default width and the selected width. 

{phang}
{opt bs} computes right-tail Monte Carlo critical values for 90, 95 and 99 percentiles based on the wild bootstrap advocated by Phillips and Shi (2020), using 199 replications.
This option does not permit the user to set a different number of replications, which may be done with the {opt boot()} option. 
Also notice that the bootstrap critical values cannot be replicated unless {opt bs} is used along with option {opt seed}.

{phang}
{opt boot} sets the number of replications to perform the wild bootstrap advocated by Phillips and Shi (2020). 

{phang}
{opt seed} sets the seed for random number generation. 

{phang}
{opt print} specifies that detailed results are to be printed, showing the ADF statistics and lag lengths for each of the regressions being estimated.

{phang}
{opt graph} specifies that the timeseries of the SADF and BSADF statistics, which can be saved as variables with the {opt prefix()} option, should be graphed along with their 90% and 95% critical values.
The graphs will be saved with names specified by the {opt prefix()} option as {it:prefix_}SADF.gph and {it:prefix_}BSADF.gph. The {opt graph} option is not available if more than 600 observations are included in the specified sample,
and requires the use of the {opt prefix()} option. 


{title:Examples}

{pstd}
We illustrate the use of the {cmd:radf} command to assess the existence of explosive behaviour in real house prices. To this end, we use data from the International House Price Database of the Federal Reserve Bank of Dallas,
which contains quarterly price information on 23 countries that dates back to the first quarter of 1975; see Mack and Mart{c i'}nez-Garc{c i'}a (2011) for methodological details on the database. To carry out our empirical illustration
we downloaded the data release for the first quarter of 2015 directly from the R console, following the steps described in Section 5.2 of Vasilopoulos, Pavlidis, Spavound and Mart{c i'}nez-Garc{c i'}a (2020b), and created a Stata version
of the data which was placed with the Boston College Economics Stata datasets.{p_end}

{pstd}
We being by loading the dataset using the command {cmd:bcuse}, available from the SSC Archive, and  verifying that the data have a time-series format:{p_end}

{phang2}{bf:. {stata "bcuse hprices":bcuse hprices}}{p_end}
{phang2}{bf:. {stata "tsset":tsset}}{p_end}

{pstd}
We would like to test whether the price series index of the United Kingdom, {cmd:uk}, contains a unit root, against the alternative that it is an explosive process.
To use the default specifications for {opt criterion} and {opt window}, and setting a {opt maxlag} of p=1 over the full range of observations:{p_end}

{phang2}{bf:. {stata "radf uk, maxlag(1)":radf uk, maxlag(1)}}{p_end}

{pstd}
Given that the results presented above reject the unit root null hypothesis, one might proceed to plot the sequences of t-statistics and corresponding critical values to identify the time periods during which episodes of explosive behaviour
might have taken place. To this end we run the previous command using the {opt prefix} and {opt graph} options:

{phang2}{bf:. {stata "radf uk, maxlag(1) prefix(_t) graph":radf uk, maxlag(1) prefix(_t) graph}}{p_end}

{pstd}
To automatically compute critical values based on the wild bootstrap advocated by Phillips and Shi (2020) using default number of replications (that is, 199): 

{phang2}{bf:. {stata "radf uk, maxlag(1) bs":radf uk, maxlag(1) bs}}{p_end}

{pstd}
To compute critical values based on the wild bootstrap advocated by Phillips and Shi (2020) using any other number of replications, say 999: 

{phang2}{bf:. {stata "radf uk, maxlag(1) boot(999)":radf uk, maxlag(1) boot(999)}}{p_end}

{title:Stored results}

{pstd}
{cmd:radf} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(ntests)}}number of ADF tests{p_end}
{synopt:{cmd:r(gsadfstat)}}GSADF statistic{p_end}
{synopt:{cmd:r(sadfstat)}}SADF statistic{p_end}
{synopt:{cmd:r(adfstat)}}ADF statistic{p_end}
{synopt:{cmd:r(window)}}maximum window width{p_end}
{synopt:{cmd:r(maxlag)}}maximum lag order in test{p_end}
{synopt:{cmd:r(N)}}number of observations in full sample test{p_end}
{synopt:{cmd:r(obs)}}number of observations available{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(last)}}last observation in window{p_end}
{synopt:{cmd:r(first)}}first observation in window{p_end}
{synopt:{cmd:r(varname)}}variable name{p_end}
{synopt:{cmd:r(cmdline)}}command line{p_end}
{synopt:{cmd:r(cmd)}}radf{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(radfstats)}}matrix of test statistics and critical values, {cmd:3 x 4} without bootstrap CVs{p_end}
{synopt:{cmd:r(radfstats)}}matrix of test statistics and critical values, {cmd:3 x 7} with bootstrap CVs{p_end}

{title:References}

{phang}
Dickey, D. A., and W. A. Fuller. 1979. Distribution of the Estimators for Autoregressive Time Series with a Unit Root. Journal of the American Statistical Association 74(366): 427–431.

{phang}
Mack, A., and E. Mart{c i'}nez-Garc{c i'}a. 2011. A cross-country quarterly database of real house prices: a methodological note. Globalization Institute Working Papers 99, Federal Reserve Bank of Dallas.

{phang}
Ng, S., and P. Perron. 1995. Unit Root Tests in ARMA Models with Data-Dependent Methods for the Selection of the Truncation Lag. Journal of the American Statistical Association 90 (429): 268–281.

{phang}
Phillips, P. C. B., and S. Shi. 2020. Real time monitoring of asset markets: bubbles and crises. In Handbook of Statistics: Financial, Macro and Micro Econometrics Using R, ed. H. D. Vinod and C. R. Rao, vol. 42, 61–80. Amsterdam:  Elsevier.

{phang}
Phillips, P. C. B., S. Shi, and J. Yu. 2015. Testing for multiple bubbles: Historical episodes of exuberance and collapse in the S&P 500. International Economic Review 56 (4): 1043–1077.

{phang}
Phillips, P. C. B., Y. Wu, and J. Yu. 2011. Explosive behavior in the 1990s NASDAQ: When did exuberance escalate asset values? International Economic Review 52 (1): 201–226.

{phang}
R Core Team. 2020. R: A Language and Environment for Statistical Computing. R Foundation for Statistical Computing, Vienna, Austria. https://www.R-project.org/.

{phang}
Schwert, G. W. 1989. Tests for unit roots: A Monte Carlo investigation. Journal of Business and Economic Statistics 7 (2): 147-159.

{phang}
Vasilopoulos, K., E. Pavlidis, and E. Mart{c i'}nez-Garc{c i'}a. 2020a. exuber: Recursive Right-Tailed Unit Root Testing with R. Globalization Institute Working Papers 383, FederalReserve Bank of Dallas.

{phang}
Vasilopoulos, K., E. Pavlidis, S. Spavound, and E. Mart{c i'}ez-Garc{c i'}a. 2020b. exuber: Econometric Analysis of Explosive Time Series. R package version 0.4.1. https://github.com/kvasilopoulos/exuber.


{title:Authors}

{pstd}
Christopher F. Baum{break}
Boston College{break}
Chestnut Hill, MA USA{break}
baum@bc.edu{p_end}

{pstd}
Jes{c u'}s Otero{break}
Universidad del Rosario{break}
Bogot{c a'}, Colombia{break}
jesus.otero@urosario.edu.co{p_end}

{title:Also see}

{p 4 14 2}
Article: {it:Stata Journal}, volume 18, number 1: {browse "http://www.stata-journal.com/article.html?article=up0058":st0508_1},{break}
   {it:Stata Journal}, volume 17, number 4: {browse "http://www.stata-journal.com/article.html?article=st0508":st0508}{p_end}
