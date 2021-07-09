{smcl}
{hline}
help for {cmd:cgroup}{right:(Roger Newson)}
{hline}

{title:Group contiguous observations with identical values of a {varlist}}

{p 8 21 2}
{cmd:cgroup} {varlist} , {opth g:enerate(newvarname)}


{title:Description}

{pstd}
{cmd:cgroup} inputs a list of variables specified by a {varlist},
and generates, as output, a new integer-valued variable,
indicating, in each observation, membership of a group of contiguous observations
with identical values of the {varlist}.
It is therefore a non-sorting version of {helpb gsort}.


{title:Options}

{phang}
{opth generate(varname)} is required,
and specifies the name of an output variable to be generated.
This output variable will contain, in each observation, the group to which that observation belongs.
It will have 1 integer value per contiguous group of observations with identical values for the variables in the {varlist},
in ascending order of appearance in the dataset, starting with 1.


{title:Examples}

{pstd}
The following example demonstrates the use of {cmd:cgroup} with the {helpb sencode} package,
downloadable from {help ssc:SSC}.

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gene firm=word(make,1)}{p_end}
{phang2}{cmd:.cgroup foreign firm, gene(firmseq)}{p_end}
{phang2}{cmd:.sencode firm, replace manyto1 gsort(firmseq)}{p_end}
{phang2}{cmd:.tab firm, missing}{p_end}

{pstd}
The following example demonstrates the use of {cmd:cgroup} with the {cmd:group()} function of {helpb egen}.
Alternatively, we could have used the {helpb xgroup} package,
downloadable from {help ssc:SSC}.

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gene firm=word(make,1)}{p_end}
{phang2}{cmd:.cgroup foreign firm, gene(firmseq)}{p_end}
{phang2}{cmd:.egen firmord=group(firmseq foreign firm), label}{p_end}
{phang2}{cmd:.tab firmord, m}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] egen}, {hi:[D] gsort}
{p_end}
{p 4 13 2}
On-line: help for {helpb egen}, {helpb gsort}
{break} help for {helpb sencode}, {helpb xgroup} if installed
{p_end}
