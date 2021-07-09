{smcl}
{* *! version 1 20nov2016}{...}
{cmd:help ersur}{right: ({browse "http://www.stata-journal.com/article.html?article=up0058":SJ18-1: st0508_1})}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:ersur} {hline 2}}Calculate Elliott, Rothenberg, and Stock (1996)
unit-root test statistic along with 1%, 5%, and 10% finite-sample critical values and associated p-values{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:ersur} {varname} {ifin} [{cmd:,} {cmd:noprint}
{cmdab:maxl:ag(}{it:integer}{cmd:)}
{cmdab:trend}]

{p 4 6 2}
{cmd:by} is not allowed.  The routine may be applied to a single unit of a panel.{p_end}
{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:ersur}; see {manhelp tsset TS}.{p_end}
{p 4 6 2}
{it:varname} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
Sample may not contain gaps.{p_end}


{title:Description}

{pstd}
{cmd:ersur} computes Elliott, Rothenberg, and Stock (1996) generalized
least squares (GLS)-detrending-based unit-root tests against the alternative
of stationarity.  The command accommodates {it:varname} with nonzero mean and
nonzero trend.  Allowance is also made for the lag length to be either fixed or
determined endogenously using information criteria such as Akaike and Schwarz,
denoted AIC and SIC, respectively.  A data-dependent procedure often known as
the general-to-specific (GTS) algorithm is also permitted, using significance
levels of 5% and 10%, denoted GTS05 and GTS10, respectively; see, for example,
Hall (1994).  Approximate p-values are also calculated.

{pstd}
Both the finite-sample critical values and the p-value are estimated based on
an extensive set of Monte Carlo simulations, summarized by means of response
surface regressions; for more details, see Otero and Baum (2017).


{title:Options}

{phang}
{opt noprint} specifies that the results be returned but not printed.

{phang}
{opt maxlag(integer)} sets the number of lags to be included in the test
regression to account for residual serial correlation.  By default,
{hi:ersur} sets the number of lags following Schwert (1989), with the formula
{cmd:maxlag()}=int{12*(T/100)^0.25}, where T is the total number of
observations.

{phang}
{opt trend} specifies the modeling of intercepts and trends.  By default,
{cmd:ersur} considers {it:varname} to be a nonzero mean stochastic process;
in this case, Elliott, Rothenberg, and Stock (1996) recommend demeaning the data using GLS.  If the {cmd:trend}
option is specified, {cmd:ersur} assumes that {it:varname} is a nonzero trend
stochastic process, in which case Elliott, Rothenberg, and Stock recommend detrending the data using GLS.


{title:Examples}

{pstd}
We illustrate the use of {cmd:ersur} by examining the time-series properties of interest rate spreads, defined as the differences between long-term and short-term interest rates.
The data, which are freely available from the Federal Reserve Economic Data of the Federal Reserve Bank of St. Louis, cover the period between 1993m10 and 2013m3,
for a total of T = 234 time observations for each series.{p_end}

{pstd}
We begin by using the data and verifying that they have a time-series format. If needed, install bcuse from the SSC Archive.{p_end}
{phang2}{bf:. {stata "bcuse usrates":bcuse usrates}}{p_end}
{phang2}{bf:. {stata "tsset date":tsset date}}{p_end}

{pstd}
Then, suppose we want to test whether the interest rate spread
between {cmd:r6} and {cmd:r3} (which we shall denote as {cmd:s6}) contains a
unit root against the alternative, that it is a stationary process.  Given
that {cmd:s6} has a nonzero mean, the relevant ERS statistic is that based on
GLS demeaned data, which is implemented by default.  Initially, the number of
lags is set by the user as p=3.{p_end}
{phang2}{bf:. {stata "ersur s6, maxlag(3)":ersur s6, maxlag(3)}}{p_end}

{pstd}
This second illustration is the same as above, but using a subsample of the
data that starts in January 1997:{p_end}
{phang2}{bf:. {stata "ersur s6 if tin(1997m1,), maxlag(3)":ersur s6 if tin(1997m1,), maxlag(3)}}{p_end}
 
{pstd}
We can perform the ERS test using all the available observations, but with
the number of lags determined based on Schwert's formula:{p_end}
{phang2}{bf:. {stata "ersur s6":ersur s6}}{p_end}

{pstd}Finally, we can also work with a long form of the data, in which a single variable s contains all interest rate spreads, and the sample is restricted to one specific spread:{p_end}

{pstd}First, rename the variables so that they are in a suitable format to apply the command {cmd:reshape}; see {manhelp reshape D}:{p_end}
{phang2}{bf:. {stata "rename r*m r*":rename r*m r*}}{p_end}
{phang2}{bf:. {stata "reshape long r s, i(date) j(matdiff)":reshape long r s, i(date) j(matdiff)}}{p_end}
 
{pstd}Next, declare the dataset as a panel using {opt xtset}; see {manhelp xtset XT}:{p_end}
{phang2}{bf:. {stata "xtset matdiff date":xtset matdiff date}}{p_end}

{pstd}Lastly, apply the command{p_end}
{phang2}{bf:. {stata "ersur s if matdiff==6, maxlag(3)":ersur s if matdiff==6, maxlag(3)}}{p_end}

{title:Stored results}

{pstd}
{cmd:ersur} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(minp)}}first time period used in the test regression{p_end}
{synopt:{cmd:r(maxp)}}last time period used in the test regression{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(varname)}}variable name{p_end}
{synopt:{cmd:r(treat)}}{cmd:demeaned} or {cmd:detrended}, depending on the {cmd:trend} option{p_end}
{synopt:{cmd:r(tsfmt)}}time-series format of the time variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(results)}}results matrix, {cmd:5 x 6}{p_end}

{pstd}
The rows of the results matrix indicate which method of lag length was used: FIX (lag selected by user or using Schwert's formula), AIC, SIC,  GTS05, or
GTS10.{p_end}

{pstd}
The columns of the results matrix contain, for each method: the number of lags
used, the ERS statistic, its p-value, and the critical values at 1%, 5%, and
10%, respectively.{p_end}


{title:References}

{phang}
Elliott, G., T. J. Rothenberg, and J. H. Stock. 1996. Efficient tests for an autoregressive unit root. {it:Econometrica} 64: 813-836.

{phang}
Hall, A. 1994. Testing for a unit root in time series with pretest data-based model selection. {it:Journal of Business and Economic Statistics} 12: 461-470.

{phang}
Otero, J., and C. F. Baum. 2017.
{browse "http://www.stata-journal.com/article.html?article=st0508":Response surface models for the Elliott, Rothenberg, and Stock unit-root test}.
{it:Stata Journal} 17: 985-1002.

{phang}
Schwert, G. W. 1989. Tests for unit roots: A Monte Carlo investigation. {it:Journal of Business and Economic Statistics} 7: 147-159.


{title:Authors}

{pstd}
Jes{c u'}s Otero{break}
Universidad del Rosario{break}
Bogot{c a'}, Colombia{break}
jesus.otero@urosario.edu.co{p_end}

{pstd}
Christopher F. Baum{break}
Boston College{break}
Chestnut Hill, MA{break}
baum@bc.edu{p_end}


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 1: {browse "http://www.stata-journal.com/article.html?article=up0058":st0508_1},{break}
          {it:Stata Journal}, volume 17, number 4: {browse "http://www.stata-journal.com/article.html?article=st0508":st0508}{p_end}
