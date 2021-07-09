{smcl}
{* *! version 1 28aug2017}
{cmd:help ksur}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}

{p2col :{hi:ksur} {hline 2}} Calculate Kapetanios & Shin unit root test statistic along with 1, 5 and 10% finite-sample critical values, and associated p-values{p_end}
{p2colreset}{...}


{title:Syntax}
{p 8 17 2}
{cmd:ksur} {varname} {ifin} [{cmd:,} {cmd:noprint}
{cmdab:maxlag(}{it:integer}{cmd:)}
{cmdab:trend}]

{p 4 6 2}
{cmd:by} is not allowed. The routine can be applied to a single unit of a panel.{p_end}
{p 4 6 2}
Before using {opt ksur} you must {opt tsset} your data; see {manhelp tsset TS}.{p_end}
{p 4 6 2}
{it:varname} may contain time series operators; see {manhelp tsvarlist U}.{p_end}
{p 4 6 2}
Sample may not contain gaps.{p_end}

{title:Description}

{pstd}{cmd:ksur} computes Kapetanios & Shin KS (2008) GLS-detrending based unit root tests against the alternative of a globally stationary exponential smooth transition autoregressive (ESTAR) process.
The command accommodates {it:varname} with nonzero mean and nonzero trend. Allowance is also made for the lag length to be either fixed (FIXED)
or determined endogenously using information criteria such as Akaike and Schwarz, denoted AIC and SIC, respectively. A data-dependent procedure often known as the general-to-specific (GTS)
algorithm is also permitted, using significance levels of 5 and 10%, denoted GTS05 and GTS10, respectively; see e.g. Hall (1994). Approximate p-values are also calculated.

{pstd}Both the finite-sample critical values and the p-value are estimated based on an extensive set of Monte Carlo simulations, summarised by means of response surface regressions; for more details see Otero and Smith (2017).


{title:Options}

{phang}{opt noprint} specifies that the results are to be returned but not printed.

{phang}{opt maxlag} sets the number of lags to be included in the test regression to account for residual serial correlation.
If not specified, {hi:ksur} sets the number of lags following Schwert (1989) with the formula maxlag=int(12*(T/100)^0.25), where T is the total number of observations.

{phang}{opt trend} specifies that GLS detrending is to be applied. Use {hi:trend} when {it:varname} is a nonzero trend stochastic process,
 in which case KS recommend detrending the data using GLS.
 
{phang} By default, {it:varname} is assumed to be a nonzero mean stochastic process.

{title:Examples}

{pstd} We test whether coffee price differentials contain a unit root. For this, we use monthly price series of the four best known types of coffee, namely unwashed Arabicas (mainly coffee from Brazil), Colombian mild Arabicas (mainly coffee
from Colombia), other mild Arabicas (mainly coffee from other Latin American countries), and Robusta coffee (mainly coffee grown in African countries and south-east Asia). The coffee prices, denoted br, co, om and ro, respectively,
are considered after applying the logarithmic transformation. The sample period runs from 1990m1 to 2004m1, that is a total of 169 time observations for each series, and the data were downloaded from the website
of the International Coffee Organisation (ICO) at www.ico.org.

{pstd} We begin by downloading the data and verifying that it has a time-series format:

{phang2}{inp:.} {stata "use http://www2.warwick.ac.uk/fac/soc/economics/staff/jsmith/research/coffeedata.dta, clear":use http://www2.warwick.ac.uk/fac/soc/economics/staff/jsmith/research/coffeedata.dta, clear}{p_end}

{phang2}{inp:.} {stata "tsset date":tsset date}{p_end}

{pstd}Then, let us say that we would like to test whether the price differential between Brazilian coffee (br) and Colombia coffee (co), that is brco, contains a unit root, against the alternative that it is a globally stationary ESTAR process.
Given that brco has a nonzero mean, the relevant KS statistic is that based on GLS demeaned data, which is implemented by default.
Initially, the number of lags is set by the user as p=3:

{phang2}{inp:.} {stata "ksur brco, maxlag(3)":ksur brco, maxlag(3)}{p_end}

{pstd}This second illustration is the same as above, but using a subsample of the data that starts in January 1992:

{phang2}{inp:.} {stata "ksur brco if tin(1992m1,), maxlag(3)":ksur brco if tin(1992m1,), maxlag(3)}{p_end}
 
{pstd}Lastly, we perform the KS test using all the available observations, but with the number of lags determined based on Schwert's formula:

{phang2}{inp:.} {stata "ksur brco":ksur brco}{p_end}


{title:Stored results}

{synopt:{cmd:r(varname)}}Variable name{p_end}
{synopt:{cmd:r(treat)}}Demeaned or detrended data, depending on the {cmd:trend} option{p_end}
{synopt:{cmd:r(minp)}}First period used in the test regression{p_end}
{synopt:{cmd:r(maxp)}}Last period used in the test regression{p_end}
{synopt:{cmd:r(tsfmt)}}Time series format of the time variable{p_end}
{synopt:{cmd:r(N)}}Number of observations{p_end}
{synopt:{cmd:r(results)}}Results matrix, 5x6{p_end}

{p}The rows of the results matrix indicate which method of lag length was used: 
FIX (lag selected by user, or using Schwert's formula); AIC; SIC;  GTS05; or GTS10.{p_end}

{p}The columns of the results matrix contain, for each method: the number of lags used;
the KS statistic; its p-value; and the critical values at 1%, 5%, and 10%, respectively.{p_end}

{title:Authors}

{phang} Jesus Otero, Universidad del Rosario, Colombia{break} jesus.otero@urosario.edu.co{p_end}
{phang} Jeremy Smith, Warwick University, United Kingdom{break} jeremy.smith@warwick.ac.uk{p_end}


{title:References}

{phang}Hall, A. (1994). Testing for a unit root in time series with pretest data-based model selection. Journal of Business and Economic Statistics 12, 461-470.

{phang}Kapetanios, G., and Y. Shin (2008). GLS detrending-based unit root tests in nonlinear STAR and SETAR models. Economics Letters 100, 377-380.

{phang}Otero, J., and J. Smith (2017). Response surface models for OLS and GLS detrending-based unit root tests in nonlinear ESTAR models. The Stata Journal, forthcoming.

{phang}Schwert, G. W. (1989). Tests for unit roots: A Monte Carlo investigation. Journal of Business and Economic Statistics 7, 147-159.

