{smcl}
{* *! version 1 24mar2017}{...}
{cmd:help adfmaxur}{right: ({browse "http://www.stata-journal.com/article.html?article=st0511":SJ18-1: st0511})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:adfmaxur} {hline 2}}Calculate Leybourne (1995) ADFmax unit-root
test statistic along with finite-sample critical values and associated
p-values{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:adfmaxur} {varname} {ifin} [{cmd:,} {cmd:noprint}
{cmdab:maxl:ag(}{it:integer}{cmd:)}
{cmdab:trend}]

{p 4 6 2}
The {cmd:by} prefix is not allowed.  The routine can be applied to a single
unit of a panel.{p_end}
{p 4 6 2}
Before using {opt adfmaxur}, you must {opt tsset} your data;
see {manhelp tsset TS}.{p_end}
{p 4 6 2}
{it:varname} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
Sample may not contain gaps.{p_end}


{title:Description}

{pstd}
{cmd:adfmaxur} computes Leybourne (1995) ADFmax unit-root tests against the
alternative of stationarity.  The command accommodates {varname} with
nonzero mean and nonzero trend.  It also allows for the lag length to
be either fixed ({cmd:FIXED}) or determined endogenously using information
criteria such as Akaike and Schwarz, denoted {cmd:AIC} and {cmd:SIC},
respectively.  A data-dependent procedure often known as the
general-to-specific (GTS) algorithm is also permitted, using significance
levels of 5 and 10%, denoted {cmd:GTS05} and {cmd:GTS10}, respectively; see,
for example, Hall (1994).  Approximate p-values are also calculated.

{pstd}
Both the finite-sample critical values and the p-value are estimated based on
an extensive set of Monte Carlo simulations, summarized by means of response
surface regressions; for more details, see Otero and Smith (2012).


{title:Options}

{phang}
{opt noprint} specifies that the results be returned but not printed.

{phang}
{opt maxlag(integer)} sets the number of lags to be included in the test
regression to account for residual serial correlation.  By default,
{hi:adfmaxur} sets the number of lags following Schwert (1989) with the
formula {cmd:maxlag()}=int{12*(T/100)^0.25}, where T is the total number of
observations.  In either case, the number of lags appears in the row labeled
{cmd:FIXED} of the output table.

{phang}
{opt trend} specifies the modeling of intercepts and trends.  By default,
{cmd:adfmaxur} assumes {varname} is a nonzero mean stochastic process, 
so a constant is included in the test regression.  If, on the other hand, the
{cmd:trend} option is specified, {it:varname} is assumed to be a nonzero trend
stochastic process, in which case a constant and a trend are included in the
test regression.


{title:Examples}

{pstd}
We begin by using the data and verifying that they have a time-series format. If needed, install bcuse from the SSC Archive.{p_end}

{phang2}{bf:. {stata "bcuse usurates":bcuse usurates}}{p_end}

{phang2}{bf:. {stata "tsset date":tsset date}}{p_end}

{pstd}
We would like to test whether the unemployment rate in each state contains a unit root against the alternative that it is a stationary process.
For practical purposes, visual inspection of the time plot of the variable of interest often provides useful guidelines as to whether a linear trend term should be included in the test regressions.
For our purposes, given that each unemployment series has a nonzero mean, but not trending behavior, the relevant test regression includes constant but not trend, which is the default option for {cmd:adfmaxur}

{pstd}
Setting a {opt maxlag} of p=12, the application of {cmd:adfmaxur} to the unemployment rate in the state of, say, Alabama, denoted ALUR, is implemented as follows:

{phang2}{bf:. {stata "adfmaxur ALUR, maxlag(12)":adfmaxur ALUR, maxlag(12)}}{p_end}

{pstd}
This second illustration is the same as above but uses a subsample of the data that starts in the first month of 2000:{p_end}

{phang2}{bf:. {stata "adfmaxur ALUR if tin(2000m1,), maxlag(12)":adfmaxur ALUR if tin(2000m1,), maxlag(12)}}{p_end}
 
{pstd}
We can perform the ADFmax test using all the available observations but with
the number of lags determined based on Schwert's formula:{p_end}

{phang2}{bf:. {stata adfmaxur ALUR:adfmaxur ALUR}}{p_end}

{pstd}Finally, we can also work with a long form of the data, in which a single variable UR contains all states' unemployment rates, and the sample is restricted to one state:

{pstd}First, rename the variables so that they are in a suitable format to apply the command {cmd:reshape}; see {manhelp reshape D}:

{phang2}{bf:. {stata "rename *UR UR*":rename *UR UR*}}{p_end}

{phang2}{bf:. {stata "reshape long UR, i(date) j(state) string":reshape long UR, i(date) j(state) string}}{p_end}

{pstd}Next, {opt encode} the state variable, and declare the dataset as a panel using {opt xtset}; see {manhelp encode D} and {manhelp xtset XT}, respectively:

{phang2}{bf:. {stata "encode state, gen(stcode)":encode state, gen(stcode)}}{p_end}

{phang2}{bf:. {stata "xtset stcode date":xtset stcode date}}{p_end}

{pstd}Lastly, apply the command{p_end}

{phang2}{bf:. {stata "adfmaxur UR if stcode==1, maxlag(12)":adfmaxur UR if stcode==1, maxlag(12)}}{p_end}

{title:Stored results}

{pstd}
{cmd:adfmaxur} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations in the test regression{p_end}
{synopt:{cmd:r(minp)}}first period used in the test regression{p_end}
{synopt:{cmd:r(maxp)}}last period used in the test regression{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(varname)}}variable name{p_end}
{synopt:{cmd:r(treat)}}either {cmd:constant} or {cmd:constant and trend}{p_end}
{synopt:{cmd:r(tsfmt)}}time-series format of the time variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(results)}}results matrix, 5x6{p_end}

{pstd}
The rows of the results matrix indicate which method of lag length was used: 
{cmd:FIXED} (lag selected by user, or using Schwert's formula); {cmd:AIC}; {cmd:SIC};  {cmd:GTS05}; or {cmd:GTS10}.{p_end}

{pstd}
The columns of the results matrix contain, for each method, the number of lags
used; the ADFmax statistic; its p-value; and the critical values at 1%, 5%,
and 10%, respectively.{p_end}


{title:References}

{phang}
Hall, A. 1994. Testing for a unit root in time series with pretest data-based
model selection. {it:Journal of Business and Economic Statistics} 12: 461-470.

{phang}
Leybourne, S. J. 1995. Testing for unit roots using forward and reverse
Dickey-Fuller regressions. {it:Oxford Bulletin of Economics and Statistics}
57: 559-571.

{phang}
Otero, J., and J. Smith. 2012. Response surface models for the Leybourne unit
root tests and lag order dependence. {it:Computational Statistics} 27:
473-486.

{phang}
Schwert, G. W. 1989. Tests for unit roots: A Monte Carlo investigation.
{it:Journal of Business and Economic Statistics} 7: 147-159.


{title:Authors}

{pstd}
Jes{c u'}s Otero {break}
Universidad del Rosario{break}
Bogot{c a'}, Colombia{break}
jesus.otero@urosario.edu.co

{pstd}
Christopher F. Baum {break}
Boston College{break}
Chestnut Hill, MA{break}
baum@bc.edu


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 1: {browse "http://www.stata-journal.com/article.html?article=st0511":st0511}{p_end}
