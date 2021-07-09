{smcl}
{hline}
help for {cmd:lablist}{right:(Roger Newson)}
{hline}

{title:List value labels (if present) for one or more variables}

{p 8 21 2}
{cmd:lablist} [ {varlist} ] [ , {cmdab:var:label} {cmd:no}{cmdab:un:labelled}
{opt lo:cal(name)} ]


{title:Description}

{pstd}
{cmd:lablist} produces a list of the values and value labels
used by the {help label:value label sets} belonging to each of a list of variables,
if such {help label:value label sets} are defined.
If no {varlist} is specified,
then {cmd:lablist} uses the full list of variables in the dataset currently in the memory.
{cmd:lablist} is therefore similar to {helpb label:label list},
but it requires the user to specify only the variable name(s) in the {varlist},
instead of specifying the {help label:value label set(s)}
belonging to the variable(s).
It is often used with {helpb tabulate}, or with the {help ssc:SSC} package {helpb xcontract}.


{title:Options}

{p 4 8 2}
{cmd:varlabel} specifies that {help label:variable labels} will be printed (if present),
in addition to any value labels.

{p 4 8 2}
{cmd:nounlabelled} specifies that variables in the {varlist} without value labels
will not be included in the printed output.

{p 4 8 2}
{opt lo:cal(name)} specifies the name of a local macro to contain a list of value label names
used by variables in the {varlist}, in alphanumeeric order.


{title:Examples}

{p 8 12 2}{cmd:. lablist}{p_end}

{p 8 12 2}{cmd:. lablist mpg}{p_end}

{p 8 12 2}{cmd:. tab foreign}{p_end}
{p 8 12 2}{cmd:. lablist foreign}{p_end}

{p 8 12 2}{cmd:. lablist, varlabel}{p_end}

{p 8 12 2}{cmd:. lablist foreign, var}{p_end}

{p 8 12 2}{cmd:. lablist, nounlabelled}{p_end}


{title:Saved results}

{pstd}
{cmd:lablist} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(k)}}number of mapped values, including missing{p_end}
{synopt:{cmd:r(min)}}minimum nonmissing value with a label{p_end}
{synopt:{cmd:r(max)}}maximum nonmissing value with a label{p_end}
{synopt:{cmd:r(hasemiss)}}{cmd:1} if extended missing values labeled, {cmd:0}
                 otherwise{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(names)}}list of label names in alphanumeric order{p_end}
{p2colreset}{...}

{pstd}
If multiple variables are specified in the {varlist},
then the saved scalar results are for the last variable in the {varlist} with a value label.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] label}, {hi:[D] tabulate oneway}, {hi:[D] tabulate twoway}
{p_end}
{p 4 13 2}
On-line: help for {helpb label}, {helpb tabulate}, {helpb tabulate oneway}, {helpb tabulate twoway},{break}
         help for {helpb xcontract} if installed
{p_end}
