{smcl}
{* *! version 2  21jan2013}{...}
{cmd:help rollstat}

{hline}

{title:Title}

{p2colset 8 20 21 2}{...}
{p2col:{hi:rollstat} {hline 2}}Rolling-window statistics for {it:time series} or {it:panel data}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:rollstat} [{varlist}]
{ifin}
{cmd:,} {cmdab:s:tatistic:(}{it:statname}{cmd:)}
[ {it:options} ]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmdab:s:tatistic:(}{it:statname}{cmd:)}}report specified statistic (required option).
{p_end}

{syntab:Options}
{synopt:{opt w(#)}}number of consecutive data points in each sample (it should be an integer grater than one), default {opt w(3)}.
{p_end}
{synopt:{opt force}}forces results to be computed when some of a particular window's values are missing.
{p_end}
{synoptline}
{p 4 6 2}
User must {bf: tsset} for time series or panel data {it:before} using {cmd:rollstat}; see {helpb tsset:[TS] tsset}.
{p_end}
{p2colreset}{...}



{marker statname}{...}
{synoptset 17}{...}
{synopt:{space 4}{it:statname}}definition{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt mean}} mean{p_end}
{synopt:{space 4}{opt sum}} sum{p_end}
{synopt:{space 4}{opt sd}} standard deviation{p_end}
{synopt:{space 4}{opt Var}} variance{p_end}
{synopt:{space 4}{opt min}} minimum{p_end}
{synopt:{space 4}{opt max}} maximum{p_end}
{synopt:{space 4}{opt N}} count of nonmissing observations{p_end}
{space 4}{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:rollstat} generates a new variable named {bf:_`statistic´`w´_varname} ({it:i.e.} _sd3_gdp for the 3 period standard deviation of GDP) 
containing the rolling calculation of the specified statistic (under the aegis of {cmd:tsset}) with window size defined in option w.
Results are placed at the end of the window. Although {cmd:rollstat} works with unbalanced panels (where the start and/or end points differ across units),
{cmd:rollstat} does not allow gaps within the observations of a time series; that is, the value of an observation for a
given period may be missing, but the observation itself must be defined. Gaps in time series may be dealt with via 
{cmd:tsfill}; see {helpb tsfill:[TS] tsfill}.


{dlgtab:Options}

{phang}
{opt w(#)} defines the window size. If there are missing data, 
the actual number of observations used by {cmd:rollstat} may be less than {opt w(#)}.

{phang}
{opt force} forces results to be computed when some of a particular window's values are missing (and data has at least two observations).
when {opt force} is set, {cmd:rollstat} starts accumulating from the first two observations of the sample until it reaches the desired window size.
Then it continues with the defined window size to the end of sample.  

{title:Examples}

{phang}{cmd:. tsset year, y}{p_end}

{phang}{cmd:. rollstat gdp cpi, s(sd)}{p_end}
{phang}{cmd:. rollstat gdp, s(mean) w(5)}{p_end}
{phang}{cmd:. rollstat gdp, s(sd) force}{p_end}

{title:Acknowledgements}     

We acknowledge useful advice of Christopher F. Baum on previous version of this routine.

{title:Authors}

Maximo Sangiacomo & Demian Panigo
{hi:Email:  {browse "mailto:msangia@hotmail.com":msangia@hotmail.com}}
{hi:Email:  {browse "mailto:panigo@gmail.com":panigo@gmail.com}}
