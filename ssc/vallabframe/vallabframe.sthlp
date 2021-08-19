{smcl}
{hline}
help for {cmd:vallabframe}{right:(Roger Newson)}
{hline}

{title:Convert a list of value labels to variables in a new data frame}

{p 8 21 2}
{cmd:vallabframe} [ {it:namelist} ] , {cmdab:fr:ame}{cmd:(}{it:framename}[,replace {cmdab:cha:nge}]{cmd:)}
  {break}
  [ {opth na:mevar(newvarname)} {opth va:luevar(newvarname)} {opth la:belvar(newvarname)} ]

{pstd}
where {it:namelist} is a list of names, assumed to belong to {help label:value labels},
and set to the list of all value labels in the current {help frame:data frame}
if not specified.


{title:Description}

{pstd}
The {cmd:vallabframe} package inputs a list of {help label:value label} names,
and outputs a new {help frame:data frame},
containing a dataset with 1 observation per value label per value,
and data on the label specified by the value label for the value.
This dataset may then be listed, stored,
or exported to a generic (or proprietary) format
of the user's choice.


{title:Options for {cmd:vallabframe}}

{phang}
{cmd:frame(} {it:name}, [ {cmd:replace} {cmd:change} ] {cmd:)} is compulsory.
It specifies an output {help frame:data frame},
to be generated to contain the output data set,
which will have 1 observation per {help label:value label} per value,
and data on the label specified by the value label for the value.
The dataset will have 3 variables,
containing, respectively, the value label name, the value, and the label,
with names specified by the options {cmd:namevar()}, {cmd:valuevar()} and {cmd:labelvar()},
respectively.
It will be sorted primarily by the {cmd:namevar()} variable,
and secondarily by the {cmd:valuevar()} variable.
If {cmd:replace} is specified, then any existing data frame of the same name is overwritten. 
If {cmd:change} is specified,
then the current data frame will be changed to the output data frame
after the execution of {cmd:vallabframe}.
The {cmd:frame()} option may not specify the current data frame.

{phang}
{opth namevar(newvarname)} specifies the name of the variable in the output data frame
containing the value label names.
It is set to {cmd:name} if not specified.

{phang}
{opth valuevar(newvarname)} specifies the name of the variable in the output data frame
containing the values.
It is set to {cmd:value} if not specified.

{phang}
{opth labelvar(newvarname)} specifies the name of the variable in the output data frame
containing the label specified by the value label for the value.
It is set to {cmd:value} if not specified.


{title:Remarks}

{pstd}
The {cmd:vallabframe} package is an inverse of the {help ssc:SSC} packege {helpb varlabdef},
which converts from a list of 3 variables in the current {help frame:data frame},
specifying value label names, values and labels, respectively,
to a list of {help label:value labels}.
{helpb vallabframe} is especially useful if the input value labels
have been created using the official Stata {cmd:encode} command,
or the {help ssc:SSC} package {helpb sencode}.
It is also especially useful
if the user wants to {help export:export} the value labels from the output frame
to a non-Stata format.
For instance, we can use {helpb export delimited} to export them to a generic worksheet,
or {helpb export excel} to export them to a proprietary Microsoft Excel worksheet.


{title:Examples}

{pstd}
The following examples use the {help ssc:SSC} package {helpb xauto},
which creates an extemded version of the {cmd:auto} data distributed with official Stata,
with multiple value labels.

{pstd}
Set-up:

{phang2}{cmd:. xauto, clear}{p_end}
{phang2}{cmd:. describe, full}{p_end}

{pstd}
Simple example:

{phang2}{cmd:. vallabframe, frame(frankie, replace)}{p_end}
{phang2}{cmd:. frame frankie: list, abbr(32) sepby(name)}{p_end}

{pstd}
Complicated example:

{phang2}{cmd:. vallabframe odd us, frame(frieda, replace) name(nana) value(valerie) label(lana)}{p_end}
{phang2}{cmd:. frame frieda: list, abbr(32) sepby(nana)}{p_end}

{pstd}
Drop created frames:

{phang2}{cmd:. capture noisily frame drop frankie}{p_end}
{phang2}{cmd:. capture noisily frame drop frieda}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {manhelp label D}, {manhelp encode D},
{manhelp export D}, {manhelp export_delimited D:export delimited}, {manhelp export_excel D:export excel}, {manhelp capture P}
{p_end}
{p 4 13 2}
On-line: help for {helpb label}, {helpb export}, {helpb export delimited}, {helpb export excel}, {helpb capture}
{break} help for {helpb sencode}, {helpb vallabdef} if installed
{p_end}
