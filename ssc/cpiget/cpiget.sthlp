{smcl}
{* *! version 1.1.0  14aug2019}{...}
{vieweralsosee "[D] import fred" "help import fred"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "freduse" "help freduse"}{...}
{vieweralsosee "cpigen" "help cpigen"}{...}
{viewerjumpto "Syntax" "cpiget##syntax"}{...}
{viewerjumpto "Description" "cpiget##description"}{...}
{viewerjumpto "Options" "cpiget##options"}{...}
{viewerjumpto "Authors" "cpiget##authors"}{...}
{viewerjumpto "References" "cpiget##references"}{...}
{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{cmd:cpiget} {hline 2}}Constructs an annual CPI series based on a user-specified fiscal-year time span.{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2} {cmd:cpiget}
{newvar} {cmd:,} 
{opt ts:tart(yyyy mm)}
{opt te:nd(yyyy mm)}
{opt bs:tart(yyyy mm)}
{opt be:nd(yyyy mm)}
{opt fyms:tart(mm)}
{opt fyme:nd(mm)}
[{help cpiget##options:options}]
{p_end}

{phang}
where where {newvar} is the name of the CPI variable that is generated according to the options below.

{marker opt_summary}{...}
{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{opt ts:tart(yyyy mm)}}beginning year and month of CPI download {p_end}
{synopt :{opt te:nd(yyyy mm)}}end year and month of CPI download{p_end}
{synopt :{opt bs:tart(yyyy mm)}}beginning year and month of CPI re-base period{p_end}
{synopt :{opt be:nd(yyyy mm)}}end year and month of CPI re-base period{p_end}
{synopt :{opt fyms:tart(mm)}}beginning month of fiscal year{p_end}
{synopt :{opt fyme:nd(mm)}}end month of fiscal year{p_end}

{syntab :Output}
{synopt :{opth outdta(filename)}}specifies file to save CPI data (.dta){p_end}

{syntab :Other}
{synopt :{opt clear}}replace data in memory{p_end}
{synopt :{opt preserve}}restore data in memory after retrieving CPI{p_end}
{synopt :{opt fyren:ame(old_fy_name newvar_name)}}renames output variable {it:fystart} or {it:fyend}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:cpiget} constructs an annual CPI data series based on a user-specified
fiscal-year time span. The CPI series is scaled such the monthly period spanned by
{opt bs:tart(yyyy mm)} and {opt be:nd(yyyy mm)} is equal to 100. This program uses
the {cmd:import fred} command introduced in Stata 15 to download monthly CPI data 
from the St. Louis Federal Reserve Bank (FRED) data repository.

{p 10 10}
{it: Motivation}: Although inflation adjustment of annual data (in nominal USD) is often done using
an annual average of monthly CPI data over the calendar year, such an adjustment 
is not necessarily appropriate when the fiscal year does
not align with the calendar year. As an example, annual district-level
school finance data usually span two calendar years: the fiscal year begins in July 
of year {it:t} and ends in June of year {it:t+1}. In such a scenario, one may desire to
construct a CPI index that averages over the fiscal year {c -} not the calendar year {c -}
to transform nominal dollars into so-called real dollars.

{pstd}
In addition to returning a CPI series with name {newvar}, {cmd: cpiget} also generates
two additional variables: {it:fystart} and {it:fyend}. When the fiscal year
spans two calendar years, {it:fystart} corresponds to year {it:t} and {it:fyend}
corresponds to year {it:t+1}. If the fiscal year does not span two calendar years,
then {it:fystart} and {it:fyend} are identical. In an annual data set to which
CPI data are merged, the user decides whether merging on {it:fystart} or {it:fyend} is
appropriate. 

{pstd}
When using {cmd: cpiget} with
option {opth outdta(filename)}, the user will likely want to rename either {it:fystart} or {it:fyend}
to merge the CPI data with the year variable in the user's data set. To facilitate this merge,
use option {opt fyren:ame(old_fy_name newvar_name)}, where {it:old_fy_name} is either
{it:fystart} or {it:fyend}.

{pstd}
Notes: The CPI series obtained in this program is CPIAUCNS, which is the non-seasonally
adjusted CPI-All Urban Consumers series. 

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt ts:tart(yyyy mm)} specifies the start year and month of the CPI series download from FRED. For example,
to request the series begins in January 1985, specify {opt tstart(1985 1)}.

{phang}
{opt te:nd(yyyy mm)} specifies the end year and month of the CPI series download from FRED. For example,
to request the series ends in December 2018, specify {opt tend(2018 12)}.

{phang}
{opt bs:tart(yyyy mm)} specifies the start year and month of CPI re-base period. The start year and month must 
be between the start year and month and end year and month of the CPI series download. 

{phang}
{opt be:nd(yyyy mm)} specifies the end year and month of CPI re-base period. The end year and month must 
be between the start year and month and end year and month of the CPI series download. 

{phang}
{opt fyms:tart(mm)} specifies the beginning month of fiscal year. If the fiscal year begins in July, then 
specify the option as {opt fymstart(7)}.

{phang}
{opt fyme:nd(mm)} specifies the end month of fiscal year. If the fiscal year ends in June, then specify the 
option as {opt fymend(6)}.

{dlgtab:Output}

{phang}
{opth outdta(filename)} saves a dataset of annual CPI according to the user-specified fiscal year. Specifically,
{it:filename.dta} contains three variables: the CPI variable which has name {newvar}; a variable denoting the
fiscal year start; a variable denoting the fiscal year end.

{dlgtab:Other}
{phang}
{opt clear} will replace the current data set in memory with the user-specified CPI series. This 
option can not be specified simultaneously with {opt preserve}. 

{phang}
{opt preserve} obtains the user-specified CPI series without affecting the data in memory. This option 
is best used with {opth output(filename)}; see examples below. 

{phang}
{opt fyren:ame(old_fy_name newvar_name)} renames either {it:fystart} or {it:fyend} to a {it:newvar_name} that is specified by the user. 

{marker examples}{...}
{title:Examples}

{pstd} {it:Example 1}: {p_end}
{pstd}Obtain monthly CPI between January 1990 and December 2016. 
Rebase the CPI such that July 2009 to June 2010 equals 100. Set the fiscal year 
to begin in July (i.e., month 7) and end in June (i.e., month 6). {p_end}
{phang2}{cmd:. cpiget cpi1, tstart(1990 1) tend(2016 12) bstart(2009 7) bend(2010 6) fymstart(7) fymend(6)}{p_end}


{pstd} {it:Example 2}: {p_end}
{pstd}Load the nlswork data set. Then (1) obtain monthly CPI between January 1967 and December 1989; (2) 
rebase the CPI such that July 1979 to June 1980 equals 100; (3) Set the fiscal year 
to begin in July (i.e., month 7) and end in June (i.e., month 6); (4)
rename the fyend variable to year; (5) merge in the fiscal year cpi variable. {p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. replace year = year + 1900}{p_end}
{phang2}{cmd:. tempfile cpitemp}{p_end}
{phang2}{cmd:. cpiget cpi2, tstart(1967 1) tend(1989 12) bstart(1979 7) bend(1980 6) fymstart(7) fymend(6) outdta(`cpitemp') fyren(fyend year) preserve}{p_end}
{phang2}{cmd:. merge m:1 year using `cpitemp'}{p_end}

{marker authors}{...}
{title:Authors}

{p2colset 5 45 45 2}{...}
{p2col :Christopher A. Candelaria}Kenneth A. Shores{p_end}
{p2col :Vanderbilt University}Pennsylvania State University{p_end}
{p2col :chris.candelaria@vanderbilt.edu}kshores@psu.edu{p_end}
{p2colreset}{...}

{pstd}
Note: If you have questions or suggestions about the program, please contact the authors.{p_end}

{marker references}{...}
{title:References}

{p 0 0 0}
If you use this program in your research, please kindly cite
the following:{p_end}

{phang}
Candelaria, C. A. & Shores, K. A. (Forthcoming). "Get Real! Inflation Adjustments of Educational Finance Data." 
{it: Educational Researcher}.
{p_end}

