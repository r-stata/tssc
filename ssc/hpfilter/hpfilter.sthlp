{smcl}
{* *! version 1.0.0  27sep2019}{...}
{vieweralsosee "[TS] tsfilter hp" "mansection TS tsfilterhp"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[TS] tsset" "help tsset"}{...}
{vieweralsosee "[XT] xtset" "help xtset"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[TS] tsfilter" "help tsfilter"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] format" "help format"}{...}
{vieweralsosee "[TS] tssmooth" "help tssmooth"}{...}
{viewerjumpto "Syntax" "hpfilter##syntax"}{...}
{viewerjumpto "Description" "hpfilter##description"}{...}
{viewerjumpto "Options" "hpfilter##options"}{...}
{viewerjumpto "Example" "hpfilter##example"}{...}
{viewerjumpto "Stored results" "hpfilter##results"}{...}
{viewerjumpto "Author" "hpfilter##author"}{...}
{p2colset 1 18 23 2}{...}
{p2col:{bf:[TS] hpfilter} {hline 2}}Hodrick-Prescott time-series filter{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
Filter one variable

{p 8 18 2}
{cmd:hpfilter}
{help varname:{it:varname}}
{ifin} [{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:New variables}
{p2col 7 32 32 2:{cmdab:tr:end(}{newvar})}save the trend component in new variable{p_end}
{p2col 7 32 32 2:{cmdab:cy:cle(}{newvar})}save the cyclical component in new variable{p_end}

{syntab:Parameters}
{synopt:{opt sm:ooth(#)}}smoothing parameter for the Hodrick-Prescott filter{p_end}
{synopt:{opt opt:imal}}use optimal smoothing parameter for the Hodrick-Prescott filter{p_end}
{synopt:{opt two:sided}}option for twosided filter (default){p_end}
{synopt:{opt one:sided}}option for onesided filter{p_end}
{synopt:{opt for:cast(#)}}number of periods for trend forcast{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {opt tsset} your data before using {opt hpfilter};
see {manhelp tsset TS}.{p_end}
{p 4 6 2}
{it:varname} may contain time-series operators; see
{help tsvarlist}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:hpfilter} uses the Hodrick-Prescott high-pass filter to separate a
time series into trend and cyclical components.  The trend component may
contain a deterministic or a stochastic trend.  The smoothing parameter
determines the periods of the stochastic cycles that drive the stationary cyclical
component.

{marker options}{...}
{title:Options}

{dlgtab:New variables}

{phang}
{cmd:trend({newvar})} saves the trend component in the new variable specified by {it:newvar}.

{phang}
{cmd:cycle({newvar})} saves the cyclical component in the new variable specified by {it:newvar}.

{dlgtab:Options}

{phang}
{opt smooth(#)} sets the smoothing parameter for the Hodrick-Prescott filter.
By default, if the units of the time variable are set to daily, weekly, monthly,
quarterly, half-yearly, or yearly, then the Ravn-Uhlig rule is used to set the
smoothing parameter; otherwise, the default value is {cmd:smooth(1600)}.  The
Ravn-Uhlig rule sets {it:#} to 1600p^4, where p is the number of periods per
quarter. The smoothing parameter must be greater than 0.

{phang}
{opt optimal} finds the optimal smoothing paramter as the ratio of variances of innovations to the series and innovations to the trend.

{phang}
{opt twosided} uses the full sample to get estimates of the trend. This is the default option if none of {opt twosided} and {opt onesided} options are specified.

{phang}
{opt onesided} uses the only the current and past values of the series to get estimates of the trend.

{phang}
{opt forecast(#)} number of periods to forcast the trend. The forecast option must be greater than 0.

{marker example}{...}
{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse gdp2}{p_end}

{pstd}Use the Hodrick-Prescott high-pass filter to estimate the trend and cyclical components of the log of quarterly U.S. GDP{p_end}
{phang2}{cmd:. hpfilter gdp_ln, trend(gdp_trend) cycle(gdp_cycle)}{p_end}

{pstd}Plot the cyclical component{p_end}
{phang2}{cmd:. tsline gdp_hp}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:hpfilter} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(smooth)}}smoothing parameter lambda{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varname)}}original time-series variables{p_end}
{synopt:{cmd:r(trendname)}}variables containing estimates of the trend components, if {cmd:trend()} was specified{p_end}
{synopt:{cmd:r(cyclename)}}variables containing estimates of the cyclical components, if {cmd:cycle()} was specified{p_end}
{synopt:{cmd:r(method)}}Hodrick-Prescott (onesided or twosided){p_end}
{synopt:{cmd:r(unit)}}units of time variable set using {cmd:tsset} or {cmd:xtset}{p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd}
Narek Ohanyan{p_end}
{pstd}
Universitat Pompeu Fabra{p_end}
{pstd}
Email: narek.ohanyan@upf.edu{p_end}

{p2colreset}{...}
