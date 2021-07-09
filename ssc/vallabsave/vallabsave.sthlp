{smcl}
{hline}
help for {cmd:vallabsave}, {cmd:vallabload} and {cmd:vallabtran}{right:(Roger Newson)}
{hline}

{title:Save and load value labels and transfer them between frames}

{p 8 21 2}
{cmd:vallabsave} [ {it:namelist} ] {cmd:using} {help filename:{it:filename}} [, {opt replace} {opth dsl:abel(string)} ]

{p 8 21 2}
{cmd:vallabload}  {cmd:using} {help filename:{it:filename}} [, {opt replace} ]

{p 8 21 2}
{cmd:vallabtran} [ {it:namelist} ] [, {opt f:rom(frame_name)} {opt t:o(frame_name)} {opt replace} ]

{pstd}
where {it:namelist} is a list of names, assumed to belong to {help label:value labels}.


{title:Description}

{pstd}
The {cmd:vallabsave} package contains 3 modules, {cmd:vallabsave}, {cmd:vallabload} and {cmd:vallabtran}.
{cmd:vallabsave} saves a list of {help label:value labels} (defaulting to all value labels in the current dataset)
to a label-only Stata dataset in a disk file, containing no observations and no variables.
{cmd:vallabload} uploads labels from a label-only Stata dataset in a disk file
to the Stata dataset currently in memory.
{cmd:vallabtran} transfers a list of {help label:value labels}
from one frame to another.
Label-only Stata datasets are a sensible way of storing value labels in a disk file,
if the labels may have text values that cannot be enclosed in {help quotes:compound quotes}.
Such labels cannot be stored using {helpb label:label save},
or generated using {helpb label:label define},
but they may be generated using {helpb encode},
or using the {help ssc:SSC} packages {helpb sencode} and {helpb vallabdef}.


{title:Options for {cmd:vallabsave}}

{phang}
{opt replace} specifies that any existing file with the same name as the {helpb using} file
will be overwritten.

{phang}
{opth dslabel(string)} specifies a {help label:dataset label}
for the newly created label-only dataset.


{title:Options for {cmd:vallabload}}

{phang}
{opt replace} specifies that,
if any existing value labels of the same names exist in the current dataset,
then they will be replaced.
If {cmd:replace} is not specified,
then any  existing value labels of the same names will only be modified,
so any values already labelled will retain the old labels if these are not modified.


{title:Options for {cmd:vallabtran}}

{phang}
{opt from(frame_name)} specifies the frame from whch the value labels will be copied.
If absent, then the current frame is assumed.
If the {it:namelist} is absent,
then it is set to the list of all value labels present in the {cmd:from()} frame.

{phang}
{opt to(frame_name)} specifies the frame to whch the value labels will be copied.
If absent, then the current frame is assumed.

{phang}
{opt replace} specifies that,
if any existing value labels of the same names exist in the frame specified by the {cmd:to()} option,
then they will be replaced.
If {cmd:replace} is not specified,
then any  existing value labels of the same names will only be modified,
so any values already labelled will retain the old labels if these are not modified.


{title:Examples}

{pstd}
The following example demonstrates the creation of a value label {cmd:reprec},
which is then saved to a label-only dataset {cmd:myvallabs.dta} using {cmd:vallabsave}.
The value label is then added to the {helpb sysuse:auto} data using {cmd:vallabload},
and then assigned to the variable {cmd:rep78}.

{pstd}
Create the value label:

{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. label define reprec 1 "One" 2 "Two" 3 "Three" 4 "Four" 5 "Five"}{p_end}
{phang2}{cmd:. label dir}{p_end}
{phang2}{cmd:. label list}{p_end}

{pstd}
Save the value label in a label-only dataset:

{phang2}{cmd:. vallabsave reprec using myvallabs.dta, replace}{p_end}

{pstd}
Load the value labels into the {helpb sysuse:auto} dataset:

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. vallabload using myvallabs.dta}{p_end}
{phang2}{cmd:. label dir}{p_end}
{phang2}{cmd:. label list}{p_end}
{phang2}{cmd:. label value rep78 reprec}{p_end}
{phang2}{cmd:. tab rep78, miss}{p_end}

{pstd}
The following example demonstrates an alternative way of creating the value label,
using the {help ssc:SSC} command {helpb vallabdef} in a {help frame:frame} named {cmd:vlframe},
inputting the {helpb sysuse:auto} data into another frame,
and using {helpb vallabtran} to transfer the new label to be assigned to {cmd:rep78}:

{pstd}
Create the value label:

{phang2}{cmd:. frame create vlframe}{p_end}
{phang2}{cmd:. frame change vlframe}{p_end}
{phang2}{cmd:. input str32 labelname codeid str32 labeltext}{p_end}
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
{phang2}{cmd:. vallabdef labelname codeid labeltext}{p_end}
{phang2}{cmd:. label list}{p_end}
{phang2}{cmd:. frame change default}{p_end}

{pstd}
Input auto data and assign label:

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. vallabtran reprec, from(vlframe) replace}{p_end}
{phang2}{cmd:. label list reprec}{p_end}
{phang2}{cmd:. label value rep78 reprec}{p_end}
{phang2}{cmd:. tab rep78, miss}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {manhelp label D}, {manhelp save D}, {manhelp append D}, {manhelp encode D}
{p_end}
{p 4 13 2}
On-line: help for {helpb label}, {helpb save}, {helpb append}, {helpb encode}
{break} help for {helpb sencode}, {helpb vallabdef} if installed
{p_end}
