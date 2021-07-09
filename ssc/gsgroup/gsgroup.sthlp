{smcl}
{hline}
help for {cmd:gsgroup}{right:(Roger Newson)}
{hline}

{title:Create a group variable and optionally an output dataset for a {helpb gsort} key}

{p 8 21 2}
{cmd:gsgroup} {help gsort:{it:gsort_list}} , {opth g:enerate(varname)} [ {cmdab:sa:ving}{cmd:(}{it:filename} [{cmd:, replace}]{cmd:)}
  no{cmdab:miss:ing} {opt m:first}
  ]

{pstd}
where {it:gsort_list} is a list of one or more elements of the form

{p 8 21 2}
[{cmd:+}|{cmd:-}]{varname}

{pstd}
as used by the {helpb gsort} command.


{title:Description}

{pstd}
{cmd:gsgroup} inputs a {helpb gsort} key (a list of elements of the form used by {helpb gsort},
and generates as output a new variable,
indicating the sequential order of the group to which each observation belongs,
and (optionally) an output dataset (or resultsset), with 1 observation per group,
and data on the values of the generated variable,
and the variables of the {helpb gsort} key corresponding to that group.
Unlike {helpb gsort}, {cmd:gsgroup} does not change the sort order of the dataset in memory.
The output dataset can be merged into other datasets,
using the official Stata command {helpb merge} or the {help ssc:SSC} package {helpb addinby}.
{cmd:gsgroup} is typically used together with the {help ssc:SSC} packages {helpb parmest} and {helpb xcontract}.


{title:Options}

{phang}
{opth generate(varname)} must be present.
It specifies the name of an output variable to be generated.
This output variable will contain, in each observation, the group to which that observation belongs,
based on the values of the variables of the {helpb gsort} key in that ovservation.
It will have 1 integer value per combination of values for the input variables in the {varlist},
in ascending order of these values, starting with 1.

{phang}
{cmd: saving}{cmd:(}{it:filename} [{cmd:, replace}]{cmd:)} specifies a file containing an output dataset (or resultsset),
with 1 observation per group specified by the {varlist},
and data on the corresponding value of the new variable specified by the {cmd:generate()} option,
and also on the values of the input variables in the {helpb gsort} key corresponding to that group.
The output dataset is sorted primarily by the grouping variable,
and secondarily by the variables in the {helpb gsort} key in order of appearance.
If {cmd:replace} is specified, then any existing file named {it:filename} will be replaced.

{phang}
{opt nomissing} specifies that observations with missing values in the variables of the input {helpb gsort} key
will have missing values in the generated group variable,
and that these missing values will not be included in the {cmd:saving()} dataset (if specified).
In default, groups with missing values will be included,
both in the group variable and in the output dataset.

{phang}
{opt mfirst} functions as the option of the same name for {helpb gsort}.

{title:Examples}

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gsgroup -foreign rep78, gene(frgroup)}{p_end}

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gsgroup rep78 foreign, g(rfgroup) saving(rfgroup1.dta, replace)}{p_end}

{pstd}
The following advanced example requires {help version:Stata Version} 11 or higher.
It uses {cmd:xgroup} with the packages
{helpb parmest}, {helpb xcontract}, {helpb keyby} and {helpb addinby},
downloadable from {help ssc:SSC}.
It defines a new binary variable {cmd:odd}, indicating that a car is odd-numbered in the sequence of the data.
It then uses {cmd:gsgroup} to create a new variable {cmd:fogroup},
grouping the data by the binary variables {cmd:foreign} and {cmd:odd},
and an output dataset with 1 option per group.
It then fits a regression model predicting fuel efficiency in miles per gallon (mpg)
from car weight in US pounds (lb)
to the data in each group defined by {cmd:fogroup},
and uses {helpb margins} to estimate the expected mileage per gallon, in that group,
of a car weighing 3000 lb.
The estimated mileage for each group, with its confidence limits,
is saved in an output dataset (or resultsset) in a temporary file, using {helpb parmest},
with the {cmd:idstr()} and {cmd:rename()} options to create a numeric identifier variable,
also with the name {cmd:fogroup}.
We then concatenate the {helpb parmest} resultssets into the memory using {helpb append},
and then use {cmd:addinby} to add in the values of the key variables from the {cmd:gsgroup} resultsset.
Finally, we use {helpb keyby} to key the resultsset by the groups and by their defining variables,
and {helpb describe} and {helpb list} the resultsset.
Note that this example uses the {help char:variable characteristic} {cmd:fogroup[varlist]},
documented in {cmd:Saved results},
and containing a list of the variables defining the groups.

{pstd}
Set-up:

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gene byte odd=mod(_n,2)}{p_end}
{phang2}{cmd:.lab var odd "Odd-numbered car"}{p_end}

{pstd}
Calculations:

{phang2}{cmd:.gsgroup -foreign odd, gene(fogroup) saving(fogroup1, replace)}{p_end}
{phang2}{cmd:.global tflist ""}{p_end}
{phang2}{cmd:.levelsof fogroup, lo(fogroups)}{p_end}
{phang2}{cmd:.foreach GP of num `fogroups' {c -(}}{p_end}
{phang2}{cmd:.xcontract fogroup `fogroup[varlist]' if fogroup==`GP', list(,)}{p_end}
{phang2}{cmd:.regress mpg weight if fogroup==`GP'}{p_end}
{phang2}{cmd:.margins, at(weight=3000)}{p_end}
{phang2}{cmd:.tempfile tfcur}{p_end}
{phang2}{cmd:.parmest, bmat(r(b)) vmat(r(V)) idnum(`GP') rename(idnum fogroup) saving(`"`tfcur'"', replace) flis(tflist)}{p_end}
{phang2}{cmd:.{c )-}}{p_end}
{phang2}{cmd:.clear}{p_end}
{phang2}{cmd:.append using $tflist}{p_end}
{phang2}{cmd:.addinby fogroup using fogroup1}{p_end}
{phang2}{cmd:.keyby fogroup `fogroup[varlist]'}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.list}{p_end}


{title:Saved results}

{cmd:gsgroup} assigns to the {cmd:generate()} variable a {help char:variable characteristic} {cmd:varlist},
containing a {varlist} of the variables appearing in the input {helpb gsort} key,
in order of appearance in the key.


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] gsort}, {hi:[D] save}, {hi:[D] sort}, {hi:[D] merge}
{p_end}
{p 4 13 2}
On-line: help for {helpb gsort}, {helpb save}, {helpb sort}, {helpb merge}
{break} help for {helpb addinby}, {helpb keyby}, {helpb parmest}, {helpb xcontract} if installed
{p_end}
