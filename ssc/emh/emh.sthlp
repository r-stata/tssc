{smcl}
{* *! version 1  2010-10-12}{...}
{cmd:help emh}{right:Version 1.0 2010-10-12}
{hline}

{title:Title}

{phang}
{bf:emh} {hline 2} Extended Mantel-Haenszel Statistics


{title:Syntax}

{p 8 17 2}
{cmd:emh}
{it:var1} {it:var2}
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth s:trata(varlist)}}stratify on {it:varlist}{p_end}
{synopt:{opt c:orrelation}}Correlation Statistic; the default{p_end}
{synopt:{opt a:nova}}ANOVA (Mean Scores) Statistic{p_end}
{synopt:{opt g:eneral}}General Association Statistic{p_end}
{synopt:{opt t:ransformation(scoretype)}}use transformation scores, e.g., ranks{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed; see {manhelp by D}.{p_end}
{p 4 6 2}
{cmd:fweight}s are allowed; see {help weight}.{p_end}
{p 4 6 2}
Only one of {cmd:correlation}, {cmd:anova} and {cmd:general} is permitted at a time.{p_end}


{title:Description}

{pstd}
{cmd:emh} calculates extended Mantel-Haenszel chi-square test statistics (also known as 
Cochran-Mantel-Haenszel Statistics) for stratified tables.  Tables are 
defined by {it:var1} and {it:var2}, both which must be numeric.  Stratification 
is optional.


{title:Options}

{dlgtab:Main}

{phang}
{opth strata(varlist)} specifies variables on which to stratify the analysis.
  Stratification variables may be numeric, string or a mix of the two.

{phang}
{opt correlation}  Correlation Statistic--tests for a linear association 
between {it:var1} and {it:var2}.  Suitable when both are at least ordinal.

{phang}
{opt anova}  ANOVA (Row Mean-score Differences) Statistic--tests for a difference in 
means of {it:var1} between groups that are defined by {it:var2}.  Suitable when 
{it:var1}, the response variable, is at least ordinal.  {it:var2}, the predictor variable, may be 
nominal (unordered).

{phang}
{opt general}  General Association Statistic--most general form of association; of 
interest especially when both {it:var1} and {it:var2} are nominal.

{phang}
{opt transformation(scoretype)}  When {cmd:correlation} is specified, transforms 
both {it:var1} and {it:var2}; when  {cmd:anova} is specified, transforms 
the response variable ({it:var1}).  This option is ignored when {cmd:general} 
is specified.  Available {it:scoretype}s are {it:table} (untransformed--the default), 
{it:integer}, {it:rank}, {it:ridit}, {it:modridit} (standardized midranks), 
{it:savage} (Savage scores), {it:mood} (Mood scores), {it:median} (above or at-or-below 
median), {it:vdw} (van der Waerden scores) and {it:klotz} (Klotz scores).


{title:Remarks}

{pstd}
{cmd:emh} computes chi-square test statistics for association of row and column 
variables in unstratified or stratified tables.  A good introduction to the use 
of these statistics is Chapters 2 through 7 of M. E. Stokes, C. S. Davis and 
G. G. Koch, {it:Categorical Data Analysis Using the SAS(R) System} Second Edition. 
Cary, North Carolina:  SAS Institute, 2000.

{pstd}
{cmd:emh} uses {help tabulate} internally.  The number of levels of {it:var1} and {it:var2} are 
limited to what {cmd:tabulate} can accept.  In order to accommodate an analysis 
with many levels of either or both of these variables, e.g., with continuous 
variables, {help matsize} and {help memory} might need to be set larger.

{pstd}
Computing extended Mantel-Haenszel statistics involves inverting a pooled covariance 
matrix.  For some datasets, the matrix might be singular.  When 
this occurs, a warning is displayed, and the chi-square statistic and associated 
p-value are set to missing.  Such occurrences are more likely when requesting the General 
Association statistic for a dataset with many levels of row and column 
variables and with a substantial amount of missing data.

{pstd}
Some transformation types available in {cmd:emh} have an established use in 
unstratified two-group mean score-difference analysis, e.g., Mood test, van der 
Waerden test, Klotz test.  Their use does not appear so well known in stratified 
analysis of multi-group (>2) datasets.  In this context, such transformations might 
not display the desired sensitivity to location or scale difference.  In general, 
users should exercise care in choosing whether and how to employ various scoring schemes.


{title:Examples}

{phang}{cmd:. sysuse auto}

{phang}{cmd:. emh rep78 price, s(foreign)}


{title:Saved results}

{pstd}
{cmd:emh} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(chi2)}}chi-square test statistic{p_end}
{synopt:{cmd:r(df)}}degrees of freedom for chi-square statistic{p_end}
{synopt:{cmd:r(p)}}p-value for reported chi-square statistic and degrees of freedom{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(scoretype)}}short-name for score type, as specified in {cmd:transformation(}{it:scoretype}{cmd:)}{p_end}
{synopt:{cmd:r(ScoreType)}}formal name for score type, as displayed in output{p_end}


{title:Author}

{p 4 4 2}
J. Coveney  E-mail {browse "mailto:jcoveney@bigplanet.com":jcoveney@bigplanet.com}
if you observe any problems.


{title:Also see}

{psee}
{space 2}Help:  {manhelp epitab ST}; 
{help vanelteren} (if installed), {help somersd} (if installed),
{manhelp tabulate_twoway R:tabulate twoway}
{p_end}
