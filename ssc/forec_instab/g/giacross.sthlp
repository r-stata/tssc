{smcl}

{title:Title}
{phang}
{bf:giacross} {hline 2} Run the Giacomini-Rossi Forecast Comparison test

{synoptline}

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:giacross}
[realized value] 
[forecast1]
[forecast2]
[{cmd:,}
{it:options}]

{synopthdr}
{synoptline}
{synoptset 20 tabbed}{...}
{syntab:Main}
{synopt:{opt window}}Rolling window for the forecast comparison. This option is necessary for the program to run.{p_end }

{synopt:{opt alpha}}The level of the test; either 0.05 or 0.1. This option is necessary for the program to run.{p_end }

{synopt:{opt nw}}Specifies the maximum order of the lag to be used in calculating the Newey-West
    long-run variance of the difference series from its autocovariance function for the Diebold-Mariano test.
    If it is not provided, the maximum lag order will be calculated from the
    Schwert criterion as a function of the sample size.
{p_end}


{synopt:{opt side}} Specifies if the alternative is two-sided or one-sided; either 2 or 1 (select 2 for two-sided tests and 1 for one-sided tests). If not specified, then the default is the two-sided alternative.
Loss differences are calculated as DL=L(1)-L(2) where L(j) is the jth model's forecast loss series.
H0: E(DL)=0 for all time periods, H1(two-sided): E(DL) not equal to 0, H1(one-sided): E(DL)>0.
{p_end}
{synoptline}
{p2colreset}{...}

{title:References}
{pstd}Raffaella Giacomini, Barbara Rossi(2010): Forecast comparisons in unstable environments. Journal of Applied Econometrics (25), pp.595-620.
Critical values can be found in Table I.{p_end}

{title:Compatibility and known issues}
{p 8 8 8}

{pstd}The following are required to run the giacross program: {p_end}
{phang2} . Stata 8.0 or higher {p_end}
{phang2} . The dmariano package. To install the dmariano command, type ssc install dmariano in the command prompt {p_end}
{phang2} . The data must be recognized as time series by Stata with the command tsset timevariable {p_end}

