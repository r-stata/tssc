{smcl}
{hline}
help for {cmd:varlabdef}{right:(Roger Newson)}
{hline}

{title:Define a value label with values corresponding to variables}

{p 8 21 2}
{cmd:varlabdef} {help label:{it:labelname}} [ , {opth vl:ist(varlist)} {opt fr:om(from_option)} {opt replace} {opt nofix} ]

{pstd}
where {help label:{it:labelname}} is a name for a {help label:value label},
and {it:from_option} is one of

{pstd}
{cmd:order} | {cmd:name} | {cmd:type} | {cmd:format} | {cmd:vallab} | {cmd:varlab} | {cmd:char} {help char:{it:characteristic_name}}

{pstd}
and  {help char:{it:characteristic_name}} is the name of a {help char:variable characteristic}.


{title:Description}

{pstd}
{cmd:varlabdef} creates (or extends) a {help label:value label},
with one value for each of a list of variables,
and labels copied from the {help label:variable labels}, variable names, or other variable attributes.
This {help label:value label} may be re-used in output datasets (or resultssets),
with observations corresponding to the variables.
Such output datasets may be created using packages such as {helpb parmest},
downloadable from {help ssc:SSC}.


{title:Options}

{phang}
{opt vlist(varlist)} specifies the list of variables corresponding to the new values of the {help label:value label}.
If {cmd:vlist()} is absent, then the full list of variables in the current datasetr is used,
unless there are no variables in the memory,
in which case {cmd:varlabdef} fails.

{phang}
{opt from(from_option)} specifies the source of the labels corresponding to the new values corresponding to the variables.
The possible values of the {it:from_option} are
{cmd:order}, {cmd:name}, {cmd:type}, {cmd:format}, {cmd:vallab}, {cmd:varlab}, or {cmd:char} {help char:{it:characteristic_name}}.
These imply that the labels corresponding to the variables will be copied, respectively,
from the order of the variable in the {varlist} specified by {cmd:vlist()},
the {help varname:variable name},
the {help type:variable storage type}, the {help format:variable format},
the {help label:value label}, the {help label:variable label},
or the {help char:named characteristic} of the variable.
If {cmd:from()} is not specified,
then the default is {cmd:varlab},
implying that the value label for each new value is copied from the {help label:variable label} of the corresponding variable.
The values of the {cmd:from()} option correspond to the variable names of the output dataset (or resultsset)
produced by the {helpb descsave} package, which can be downloaded from {help ssc:SSC}.

{phang}
{opt replace} specifies that, if a {help label:value label} with the specified {it:labelname} already exists,
then that label will be dropped before a new label with the same name is created.
If {cmd:replace} is specified, or if no {help label:value label} with the specified {it:labelname} already exists,
then the new values are defined as consecutive integers starting with 1.
If {cmd:replace} is not specified, and a {help label:value label} with the specified {it:labelname} already exists,
then the new labelled values are added to the existing labelled values,
and are defined as consecutive integers,
starting from 1 or from the lowest positive integer above any existing non-missing labelled value,
whichever is higher.

{phang}
{opt nofix} acts as the {cmd:nofix} option of the {helpb label:label define} command.
It defines the action of {cmd:varlabdef}
when a {help label:value label} with the specified {it:labelname} already exists,
and is the {help label:value label} for one or more existing variables in the dataset.
Without the {cmd:nofix} option,
{cmd:varlabdef} finds all the variables that use this {help label:value label},
and widens their {help format:display formats}, if necessary,
to be wide enough for the longest of the new labels.
{cmd:nofix} prevents this.


{title:Remarks}

{pstd}
{cmd:varlabdef} was designed to be used with output datasets (or resultssets)
created by the {helpb parmest} package, which can be downloaded from {help ssc:SSC}.
The {helpb parmest} package creates datasets with 1 observation for each of a set of estimated parameters.
These datasets sometimes include string variables containing the names or {help label:labels}
of the {it:Y}-variables and/or {it:X}-variables corresponding to these estimated parameters.
{cmd:varlabdef} can be used in the original dataset, containing the data from which the parameters are estimated,
to create a {help label:value label},
with a value for each of a list of variables,
and labels containing the names or {help label:variable labels} of these variables.
This {help label:value label} can then be saved to a do-file,
using the {helpb label:label save} command.
When the estimation commands have been executed,
and the output datasets (or resultssets) have been created,
the user can execute the saved do-file to re-create the value label in the new output dataset.
It is then possible to use the official Stata {helpb encode} command,
or the {helpb sencode} command downloadable from {help ssc:SSC},
to input the string variables containing the names and/or labels
of the {it:Y}-variables and/or {it:X}-variables,
and to create new numeric variables,
with the string values as labels.
These new numeric variables are useful if the user wants to produce plots of confidence intervals,
which may be produced using the {helpb eclplot} package, downloadable from {help ssc:SSC}.

{pstd}
The {helpb parmest}, {helpb sencode}, {helpb sdecode} and {helpb eclplot} packages can all be downloaded from {help ssc:SSC}.
So can the {helpb descsave} package,
which is also useful for passing information about variables from one dataset to another.
For more about resultsset processing,
see the References in the on-line help for {helpb parmest}.


{title:Examples}

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. varlabdef mylabs}{p_end}
{phang2}{cmd:. lab list mylabs}{p_end}
{phang2}{cmd:. varlabdef yvarlab, vlist(length weight mpg price)}{p_end}
{phang2}{cmd:. lab list yvarlab}{p_end}
{phang2}{cmd:. varlabdef yvarlab, replace}{p_end}
{phang2}{cmd:. lab list yvarlab}{p_end}
{phang2}{cmd:. varlabdef yvarname, vlist(length weight mpg price) from(name)}{p_end}
{phang2}{cmd:. lab list yvarname}{p_end}


{title:Saved results}

{pstd}
{cmd:varlabdef} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(firstval)}}first value added by {cmd:varlabdef}{p_end}
{synopt:{cmd:r(lastval)}}last value added by {cmd:varlabdef}{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(vlist)}}variables specified by {cmd:vlist()}{p_end}
{synopt:{cmd:r(from)}}{cmd:from()} option{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] label}, {hi:[D] encode}, {hi:[D] decode}, {hi:[P] char}
{p_end}
{p 4 13 2}
On-line: help for {helpb label}, {helpb encode}, {helpb decode}, {helpb char}
{break} help for {helpb parmest}, {helpb sencode}, {helpb sdecode}, {helpb descsave}, {helpb eclplot} if installed
{p_end}
