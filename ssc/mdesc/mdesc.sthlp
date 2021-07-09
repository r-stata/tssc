{smcl}
{* 18jan2006}{...}
{cmd:help mdesc}
{hline}

{title:Title}
{p 10}{bf:mdesc} -- Displays the number and proportion of missing values for each variable in {varlist}.{p_end}


{title:Syntax}
{p 10}
{cmd:mdesc}
{varlist}
{ifin}
[,
{cmdab:ab:breviate(#)}
{cmd:any}
{cmd:all}
{cmdab:no:ne}
]
{p_end}

{opt by} may be used with {cmd:mdesc}; see {helpb by}.


{title:Description}

{p}Produces a table with the number of missing values, total number 
of cases, and percent missing for each variable in {varlist}. {cmd:mdesc}
works with both numeric and string variables.{p_end}

{title:Options}

{p 4 8 2}{opt ab:breviate(#)} abbreviate variable names to {it:#} of characters; default is {bf:ab(12)}.{p_end}

{p 4 8 2}{opt any} specifies to check how many observations have at least one missing value for any of the specified variables.{p_end}

{p 4 8 2}{opt all} specifies to check how many observations have missing values for all of the specified variables.{p_end}

{p 4 8 2}{opt no:ne} specifies to check how many observations have no missing values for any of the specified variables.{p_end}

{title:Saved Results}

{p 4 4 2}The {cmd:mdesc} command saves scalars and macros:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(percent)}}percent missing for last variable specified in {cmd:mdesc}{p_end}
{synopt:{cmd:r(total)}}total number of observations submitted to {cmd:mdesc}{p_end}
{synopt:{cmd:r(miss)}}number of missing values for last variable specified in {cmd:mdesc}{p_end}

{p2col 5 20 24 2: Local Macros}{p_end}
{synopt:}(when options {cmd:any}, {cmd:all}, or {cmd:none} are not specified) {p_end}
{synopt:{cmd:r(notmiss_vars)}}list of variables that have no missing values that were specified in {cmd:mdesc}{p_end}
{synopt:{cmd:r(miss_vars)}}list of variables that have missing values that were specified in {cmd:mdesc}{p_end}

{title:Authors}

{pstd}
Rose Anne Medeiros {break}
Department of Sociology {break}
Rice University {break}
rose.a.medeiros@rice.edu {p_end}

{pstd}
Dan Blanchette {break}
The Carolina Population Center {break}
University of North Carolina - Chapel Hill, USA {break}
dan_blanchette@unc.edu {p_end}


{title:Also see}

{psee}
Online: {helpb missing()}, {helpb misstable}, {stata ssc describe nmissing: ssc describe nmissing}
{p_end}
