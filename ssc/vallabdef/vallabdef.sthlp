{smcl}
{hline}
help for {cmd:vallabdef}{right:(Roger Newson)}
{hline}

{title:Define value labels from label name, value and label variables}

{p 8 21 2}
{cmd:vallabdef} {it:namevar} {it:codevar} {it:labelvar} {ifin}

{pstd}
where {it:namevar} is the name of a string variable containing label names,
{it:codevar} is the name of a numeric variable containing values to be labelled,
and {it:labelvar} is the name of a string variable containing the corresponding labels.


{title:Description}

{pstd}
{cmd:vallabdef} inputs 3 variables in the current dataset,
assumed to contain the names, values and labels
for one or more {help label:value labels},
and defines (or extends) the named {help label:value labels}.
The user can then save the value labels in a label-only dataset on disk,
with no observations and no variables,
which can then be appended to another dataset,
and used as a source of value labels to be allocated to variables.
{cmd:vallabdef} is very useful for defining value labels
which cannot be defined using {helpb label:label define},
because they cannot be surrounded by simple or compound {help quotes}
{for instance, a value label that contains an unpaired right quote at the end).


{title:Remarks}

{pstd}
The traditional way to define value labels in Stata is to use {helpb label:label define}.
And the traditional way to store them on disk is by using {helpb label:label save},
which creates a Stata {help do:do-file} containing a list of {helpb label:label define} commands,
which can be run to re-create those labels.
However, {helpb label:label define} specifies the individual value labels
in {help quote:quotes}.
This implies that, if any of the value labels contains an unpaired right quote (simple or compound),
then those individual value labels cannot be specified using {helpb label:label define}.
An alternative way of specifying one or more value labels
is to store the label names,
numeric values, and string labels in 3 variables in a Stata dataset on disk.
This alternative method
allows value labels to have any possible string values at or below the maximum length
specified by the {helpb creturn} result
{cmd:c(maxvlabellen)}.
To create these value labels in preparation for allocating them to variables in another dataset,
the user needs to load the disk dataset, use {cmd:vallabdef},
and then {helpb save} the new value labels to a label-only dataset on disk.
This label-only dataset can later be appended to a dataset in memory,
and used as a source of value labels to be allocated to variables
in the dataset in memory.

{pstd}
Users may alternatively save the generated value labels in a label-only dataset
using the {help ssc:SSC} package {helpb vallabsave},
which includes a {helpb vallabsave} module for saving label-only datasets
and a {helpb vallabload} module for loading label-only datasets.


{title:Examples}

{pstd}
The following examples demonstrate the creation of a dataset with 1 observation
for each value for a list of value labels,
and 3 variables specifying the label names, numeric values, and string labels,
respectively.
We then demonstrate the use of this dataset to define the value labels,
using {cmd:vallabdef}.
The value labels are then saved to a label-only dataset in the file {cmd:autolabs.dta},
with no observations and no variables,
using the {helpb save} command with the {cmd:orphans} and {cmd:emptyok} options.
We then load the {helpb sysuse:auto} dataset,
{helpb append} the label-only dataset,
and allocate the value labes generated using (cmd:vallabdef}
to integer variables in another dataset.

{pstd}
Set-up:

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. input str32 labelname codeid str32 labeltext}{p_end}
{phang2}{cmd:. cartype 0 "`US made'"}{p_end}
{phang2}{cmd:. cartype 1 "`Non-US made'"}{p_end}
{phang2}{cmd:. reprec 1 "One"}{p_end}
{phang2}{cmd:. reprec 2 "Two"}{p_end}
{phang2}{cmd:. reprec 3 "Three"}{p_end}
{phang2}{cmd:. reprec 4 "Four"}{p_end}
{phang2}{cmd:. reprec 5 "Five"}{p_end}
{phang2}{cmd:. end}{p_end}
{phang2}{cmd:. compress}{p_end}
{phang2}{cmd:. sort labelname codeid}{p_end}
{phang2}{cmd:. describe, full}{p_end}
{phang2}{cmd:. list, abbr(32) sepby(labelname)}{p_end}

{pstd}
Create and list labels:

{phang2}{cmd:. label drop _all}{p_end}
{phang2}{cmd:. vallabdef labelname codeid labeltext}{p_end}
{phang2}{cmd:. label dir}{p_end}
{phang2}{cmd:. label list}{p_end}

{pstd}
Save label-only dataset:

{phang2}{cmd:. drop _all}{p_end}
{phang2}{cmd:. save autolabs.dta, orphans emptyok replace}{p_end}

{pstd}
Load auto data and assign labels from label-only dataset:

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. append using autolabs.dta}{p_end}
{phang2}{cmd:. lab val foreign cartype}{p_end}
{phang2}{cmd:. lab val rep78 reprec}{p_end}
{phang2}{cmd:. describe, full}{p_end}
{phang2}{cmd:. tab foreign, miss}{p_end}
{phang2}{cmd:. tab rep78, miss}{p_end}


{title:Stored results}


{pstd}
{cmd:lablist} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(names)}}list of generated or modified label names in alphanumeric order{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {manhelp label D}, {manhelp save D}, {manhelp append D}
{p_end}
{p 4 13 2}
On-line: help for {helpb label}, {helpb save}, {helpb append}
{break} help for {helpb vallabsave}, {helpb vallabload} if installed.
{p_end}
