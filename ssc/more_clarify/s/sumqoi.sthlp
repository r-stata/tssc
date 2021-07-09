{smcl}
{* *! version 1.0}{...}
{cmd:help sumqoi}
{hline}

{title:Title}

{phang}
{bf:sumqoi} {hline 2} Summarize quantities of interest


{title:Syntax}

{p 8 18 2}
{cmd:sumqoi}
[{varlist}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmdab:s:tatistics:(}{it:{help tabstat##statname:statname}} [{it:...}]{cmd:)}}
report specified statistics
{p_end}

{syntab:Options}
{synopt:{opt f:ormat}[{cmd:(%}{it:{help format:fmt}}{cmd:)}]}
display format for statistics; default format is {cmd:%9.0g}
{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt cent:ile}}compute centile-based confidence intervals; the default{p_end}
{synopt:{opt norm:al}}compute normal-based confidence intervals{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
{opt by} is allowed; see {manhelp by D}.
{p_end}


{title:Description}

{pstd}
{cmd:sumqoi} summarizes quantities of interest that have been stored as variables in
memory.
By default, {cmd:sumqoi} reports the mean, standard deviation, and a centile-based
confidence interval for the simulated quantities of interest.


{title:Options}

{dlgtab:Main}

{phang}
{cmd:statistics(}{it:statname} [{it:...}]{cmd:)}
   specifies the statistics to be displayed.  ({opt stats()} is a synonym for
   {opt statistics()}.)  Multiple statistics may be specified
   and are separated by white space, such as {cmd:statistics(mean sd)}.
   Available statistics are

{marker statname}{...}
{synoptset 17}{...}
{synopt:{space 4}{it:statname}}Definition{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt me:an}} mean{p_end}
{synopt:{space 4}{opt co:unt}} count of nonmissing observations{p_end}
{synopt:{space 4}{opt n}} same as {cmd:count}{p_end}
{synopt:{space 4}{opt su:m}} sum{p_end}
{synopt:{space 4}{opt ma:x}} maximum{p_end}
{synopt:{space 4}{opt mi:n}} minimum{p_end}
{synopt:{space 4}{opt r:ange}} range = {opt max} - {opt min}{p_end}
{synopt:{space 4}{opt sd}} standard deviation{p_end}
{synopt:{space 4}{opt v:ariance}} variance{p_end}
{synopt:{space 4}{opt cv}} coefficient of variation ({cmd:sd/mean}){p_end}
{synopt:{space 4}{opt sem:ean}} standard error of mean ({cmd:sd/sqrt(n)}){p_end}
{synopt:{space 4}{opt sk:ewness}} skewness{p_end}
{synopt:{space 4}{opt k:urtosis}} kurtosis{p_end}
{synopt:{space 4}{opt p1}} 1st percentile{p_end}
{synopt:{space 4}{opt p5}} 5th percentile{p_end}
{synopt:{space 4}{opt p10}} 10th percentile{p_end}
{synopt:{space 4}{opt p25}} 25th percentile{p_end}
{synopt:{space 4}{opt med:ian}} median (same as {opt p50}){p_end}
{synopt:{space 4}{opt p50}} 50th percentile (same as {opt median}){p_end}
{synopt:{space 4}{opt p75}} 75th percentile{p_end}
{synopt:{space 4}{opt p90}} 90th percentile{p_end}
{synopt:{space 4}{opt p95}} 95th percentile{p_end}
{synopt:{space 4}{opt p99}} 99th percentile{p_end}
{synopt:{space 4}{opt iqr}} interquartile range = {opt p75} - {opt p25}{p_end}
{synopt:{space 4}{opt q}} equivalent to specifying {cmd:p25 p50 p75}{p_end}
{space 4}{synoptline}
{p2colreset}{...}

{dlgtab:Options}

{phang}
{opt format} and {cmd:format(%}{it:{help format:fmt}}{cmd:)} specify how the
   statistics are to be formatted.  The default is to use a {cmd:%9.0g}
   format.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt centile} specifies calculation of centile-based confidence intervals; the default.

{phang}
{opt normal} specifies calculation of normal-based confidence intervals.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Simulate parameters via Post-estimation Simulation{p_end}
{phang2}{cmd:. {helpb postsim}, saving(myfile): regress mpg weight foreign}{p_end}

{pstd}Simulate expected values at specific values of covariates{p_end}
{phang2}{cmd:. {helpb simqoi} using myfile, at( foreign=(0 1) ) gen(foo)}{p_end}

{pstd}Compute first difference{p_end}
{phang2}{cmd:. generate diff =  foo_at_2-foo_at_1}{p_end}

{pstd}Summarize quantity of interest{p_end}
{phang2}{cmd:. sumqoi diff}{p_end}
{phang2}{cmd:. sumqoi diff, statistics(median iqr)}{p_end}
{phang2}{cmd:. sumqoi diff, normal}{p_end}


{title:Saved results}

{pstd}
{cmd:sumqoi} saves the following in {cmd:r()}:

{synoptset 13 tabbed}{...}
{p2col 5 13 17 2: Matrices}{p_end}
{synopt:{cmd:r(sims)}}number of observations{p_end}
{synopt:{cmd:r(mean)}}mean{p_end}
{synopt:{cmd:r(se)}}standard deviation{p_end}
{synopt:{cmd:r(lb)}}lower confidence bound{p_end}
{synopt:{cmd:r(ub)}}upper confidence bound{p_end}
{synopt:{cmd:r(Results)}}Results{p_end}


{title:Author}

{phang}
Javier M{c a'}rquez Pe{c n~}a,{break}
Buend{c i'}a & Laredo, Mexico City.{break}
javier.marquez@buendiaylaredo.com{break}
{browse "http://javier-marquez.com/software/moreclarify"}


{title:Also see}

{psee}
{space 2}Help:  {cmd:{help sumqi}} (if installed);{break}
{manhelp summarize R}, {manhelp tabstat R}
{p_end}