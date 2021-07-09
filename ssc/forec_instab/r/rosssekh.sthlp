{smcl}

{title:Title}
{phang}
{bf:rosssekh} {hline 2} Run the Rossi-Sekhposyan Forecast Rationality test

{synoptline}

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:rosssekh}
[realized value] 
[forecast]
[{cmd:,}
{it:options}]

{synopthdr}
{synoptline}
{synoptset 20 tabbed}{...}
{syntab:Main}
{synopt:{opt window}}Rolling window for the forecast comparison. This option is necessary for the program to run.{p_end }
{synopt:{opt alpha}}Significance level (possible values are 0.01, 0.05 and 0.10) for the Rossi-Sekhposyan test. This option is necessary for the program to run.{p_end }

{synopt:{opt nw}}Force the lag length used in the Newey-West estimator for the variance. With a value 0, the test will assume a lag length of the integer part of (w^(0.25)), where w is the size of the rolling window.
When no value is specified, the RS test statistic will be computed using the non-HAC variance.{p_end}
{synoptline}
{p2colreset}{...}

{title:References}
{pstd}Barbara Rossi, Tatevik Sekhposyan(2016): Forecast rationality tests in the presence of instabilities, with applications to Federal Reserve and survey forecasts. Journal of Applied Econometrics (31), pp.507-532.
Critical values can be found in Panel C, Table II and the Online Appendix.{p_end}

{title:Compatibility and known issues}
{p 8 8 8}

{pstd}The following are required to run the giacross program: {p_end}
{phang2} . Stata 8.0 or higher {p_end}
{phang2} . The data must be recognized as time series by Stata with the command tsset timevariable {p_end}

{pstd}The rosssekh command uses the {help newey} package to estimate the variance matrix used in the Wald test. It is hence sensitive to issues inherent to the {help newey} command.
In particular, Newey-West estimators should not be calculated on a time series that are not evenly spaced. (The {help rosssekh} command forces the Newey-West estimator anyhow.){p_end}
