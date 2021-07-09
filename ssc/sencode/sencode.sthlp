{smcl}
{hline}
help for {cmd:sencode} {right:(Roger Newson)}
{hline}


{title:Encode string into numeric in a sequential or other non-alphanumeric order}

{p 8 21 2}
{cmd:sencode} {varname} {ifin} ,
 [ {cmdab:g:enerate}{cmd:(}{newvar}{cmd:)} | {cmd:replace} ] [
 {break}
 {cmdab:l:abel}{cmd:(}[{it:name}] [, [{cmd:replace}]]{cmd:)} {cmd:no}{cmdab:e:xtend}
 {break}
 {cmdab:gs:ort}{cmd:(}{it:gsort_list} [, {cmd:mfirst}]{cmd:)}
 {break}
 {cmdab:man:yto1} {cmd:fast}
 {break}
 ]

{pstd}
where {it:gsort_list} is a list of one or more elements of the form

{p 8 21 2}
[{cmd:+}|{cmd:-}]{varname}

{pstd}
as used by the {helpb gsort} command.


{title:Description}

{pstd}
{cmd:sencode} ("super {helpb encode}") creates an output numeric variable, with {help label:labels} from
the input string variable {varname}.
The output numeric variable may either replace the input
string variable or be generated as a new variable named {newvar}.
The labels are specified
by creating, adding to, or just using (as necessary)
the value label {newvar}, or, if specified, the value label {it:name}.
Unlike {helpb encode},
{cmd:sencode} can order the numeric values corresponding to the string values in a logical
order, instead of ordering them in alphanumeric order of the string value, as {helpb encode} does.
This logical order defaults to the order of appearance of the string values in the dataset,
but may be an alternative order specified by the user in the {cmd:gsort} option.
The mapping of
numeric code values to string values may be one-to-one, so that each string value has a single
numeric code, or many-to-one, so that each string value may have multiple numeric codes,
corresponding to multiple appearances of the string value in the dataset.
{cmd:sencode} may be useful when the input string variable is used as a source of axis
labels in a {help graph:Stata graph} and the output numeric variable is used as the
{it:X}-variable or {it:Y}-variable.


{title:Options}

{phang}
Either {cmd:generate()} or {cmd:replace} must be specified, but both options may not be specified
at the same time.

{phang}{cmd:generate(}{newvar}{cmd:)} specifies the name of a new output numeric variable to be
created.

{phang}{cmd:replace} specifies that the output numeric variable will replace the input
string variable, and have the same name, the same {help order:position in the dataset},
and the same {help label:variable label} and {help char:characteristics} if present.

{phang}{cmd:label(}[{it:name}] [, [{cmd:replace}]]{cmd:)} is optional.
It specifies the name of the {help label:value label} to be created,
or, if the named value label already exists, used and added to as necessary.
If {cmd:label()} is not specified, or is specified without the {it:name},
then {cmd:sencode} uses the same name for the label as it uses for the new variable,
as specified by the {cmd:generate()} or {cmd:replace} option.
If the {cmd:replace} suboption of the {cmd:label()} option is specified,
then any existing value label with the indicated value label name is dropped before the new values are added,
and the added values range from 1 to the number of distinct new labels.

{phang}{cmd:noextend} specifies that {varname} will not be encoded
if there are values contained in {varname} that are not present
in the value label specified by the {cmd:label()} option.
By default, any values not present in that value label will be added to that label.
The {cmd:noextend} option may only be specified if the {cmd:label()} option specifies an existing label,
and may not be specified with the {cmd:manyto1} option, or with the {cmd:replace} suboption of {cmd:label()}.

{phang}{cmd:gsort(}{it:gsort_list} [, {cmd:mfirst}]{cmd:)} is optional.
It specifies a generalized sorting order for the allocation
of code numbers to the non-missing values of the input string variable.
If the {cmd:gsort()} option is not specified, then it is set
to the sequential order of the observation in the dataset.
The {it:gsort_list} is interpreted in the way used by the {helpb gsort} command.
Observations are grouped in ascending or descending order of the specified {varname}s.
Each {varname} in the {cmd:gsort()} option can be numeric or string.
Observations are grouped in ascending order of {varname} if {cmd:+}
or nothing is typed in front of the name, and in descending order of {varname} if {cmd:-} is typed
in front of the name.
The {cmd:mfirst} suboption specifies that missing values will be placed first in descending orderings,
rather than last.
If there are multiple non-missing values of the input string variable
in a group specified by the {cmd:gsort()} option,
then the group is split into subgroups, one subgroup for each non-missing input string value,
and these subgroups are ordered alphanumerically within the group by the input string values.
If there are multiple groups with the same input string value,
and the {cmd:manyto1} option is not specified,
then multiple groups with the same input string value are combined into the first group with that input string value.
The ordered groups are then allocated integer code values,
and these values are stored in the output variable specified by the {cmd:generate()} or {cmd:replace} option.
Note that the dataset remains sorted in its original order, even if the user specifies the {cmd:gsort()} option.

{phang}{cmd:manyto1} is optional. It specifies that the mapping from the numeric codes to the
possible values of the input string variable {varname} may be many-to-one,
so that each string value may have multiple numeric codes,
corresponding to multiple positions of that string value in the dataset.
These multiple positions may correspond to multiple observations (if {cmd:gsort()} is not specified),
or to multiple groups of observations specified by {cmd:gsort()}.
If {cmd:manyto1} is not specified, then each string value will have one numeric code,
and these numeric codes are usually ordered by the position of the first appearance of the string value in the dataset.
The {cmd:manyto1} option may not be specified with the {cmd:noextend} option.

{phang}{cmd:fast} is a programmers' option.
It specifies that no action will be taken to restore the original data in the memory,
if the user presses the {helpb break:Break} key.


{title:Technical note}

{pstd}
{cmd:sencode} encodes the string values in the string input variable as follows.
First, {cmd:sencode} selects observations in the dataset with non-missing values of the input string variable.
If {helpb if} and/or {helpb in} is specified,
then {cmd:sencode} selects the subset of those observations selected by {helpb if} and/or {helpb in}.
Then, these observations are grouped into ordered groups,
ordered primarily by the {cmd:gsort()} option and secondarily by the value of the input string variable.
(If the {cmd:gsort()} option is not specified, then it is set to a single temporary variable,
with values set to the expression {cmd:_n},
equal in each observation to the sequential order of that observation in the dataset,
and there is therefore only one observation per {cmd:gsort()} group.)
Then, if {cmd:manyto1} is not specified,
then any set of multiple ordered groups with the same value of the input string variable
is combined into the first group in that set of groups.
Each of the ordered groups existing at this stage is then allocated an integer code value.
These integer code values are usually ordered primarily by the {cmd:gsort()} option,
and secondarily by the alphanumeric order of the input string variable.
The code values are then stored in the new variable
specified by the {cmd:generate()} or {cmd:replace} option.

{pstd}
Usually, the code values range from one to the final number of groups.
Exceptions arise when the
{help label:value label} implied by the {cmd:label()} option of {cmd:sencode} is a pre-existing
{help label:value label},
with pre-existing associations between numeric code values and string labels already defined,
and the {cmd:replace} suboption of the {cmd:label()} option is not specified.
In this case, {cmd:sencode} does not modify existing associations.
The consequences of this policy depend on whether or not {cmd:manyto1} is specified.
If {cmd:manyto1} is not specified,
and the input string value of an ordered group has a pre-existing numeric code,
then that pre-existing numeric code continues to be used for that group,
and new numeric codes are generated for any input string values without existing numeric codes
(unless {cmd:noextend} is specified).
If {cmd:manyto1} is specified, and there are existing associations,
then a new numeric code is generated for each ordered group,
whether or not the input string value for that ordered group has a pre-existing numeric code.
In both cases, newly-generated numeric codes are ordered by {cmd:gsort()} group,
and are chosen to be consecutive integers,
starting either from 1 or from the smallest integer greater than any pre-existing positive non-missing numeric code,
whichever is greater.

{pstd}
These features of {cmd:sencode} may cause problems.
Fortunately, these problems can be avoided
if a value label name is specified (by the {cmd:label()} option)
to be different from any pre-existing value label name,
or if the {cmd:replace} suboption of the {cmd:label()} option is used.


{title:Remarks}

{pstd}
{cmd:sencode} is a separate package from {helpb sdecode} ("super {helpb decode}"),
which is also downloadable from {help ssc:SSC}.
However, the two packages both have the alternative
{cmd:generate} and {cmd:replace} options.
They are complementary to the {helpb destring} command (which is part of official Stata)
and the {helpb tostring} command (which became part of official Stata in Version 8.1).
{helpb tostring} and {helpb destring}
convert numeric values to and from their formatted string values, respectively,
but they do not use {help label:value labels},
and they do contain precautionary features to prevent the loss of information.
{helpb sdecode} and {cmd:sencode}, on the other hand, do use {help label:value labels},
and allow the possibility that the mapping from numeric values to string values can be many-to-one.

{pstd}
More about the use of {cmd:sencode} with {helpb sdecode} and other conversion packages
can be found in
{help sencode##newson_2013:Newson (2013)}.


{title:Examples}

{pstd}
If we type this example in the {hi:auto} data, then all US-made cars will be ordered before all
cars from the rest of the world, and each car type (US and non-US) will be ordered
alphanumerically.
If we used {helpb encode} instead of {cmd:sencode}, then cars would be ordered
alphanumerically by make (so Audi cars would appear before Ford cars).

{p 8 12 2}{cmd:. sort foreign make}{p_end}
{p 8 12 2}{cmd:. sencode make, replace}{p_end}
{p 8 12 2}{cmd:. tab make}{p_end}

{pstd}
If we type this in the {hi:auto} data, then a new variable {hi:origseq} will created,
with a value for each observation equal to the sequential order of that observation
in the dataset, and a value label for each value {hi:i} equal to the car origin type
({hi:Domestic} or {hi:Foreign}) for the {hi:i}th car.

{p 8 12 2}{cmd:. decode foreign, gene(orig)}{p_end}
{p 8 12 2}{cmd:. sencode orig, gene(origseq) many}{p_end}
{p 8 12 2}{cmd:. lab list origseq}{p_end}
{p 8 12 2}{cmd:. tab origseq}{p_end}
{p 8 12 2}{cmd:. list foreign origseq, nolab}{p_end}

{pstd}
If we type this in the {hi:auto} data, then we will encode {hi:make} so that
all non-US cars have lower codes than all US cars (so Volvo cars have lower codes than AMC cars),
but the data remain sorted as before:

{p 8 12 2}{cmd:. sencode make, gene(makeseq) gsort(-foreign)}{p_end}
{p 8 12 2}{cmd:. tab makeseq, m}{p_end}
{p 8 12 2}{cmd:. lab list makeseq}{p_end}
{p 8 12 2}{cmd:. list make makeseq, nolab}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{marker newson_2013}{...}
{phang}
Newson, R. B.
2013.
Creating factor variables in resultssets and other datasets.
Presented at {browse "http://ideas.repec.org/p/boc/usug13/01.html":the 19th United Kingdom Stata Users' Group Meeting, 12–13 September, 2013}.


{title:Acknowledgement}

{pstd}
This program has benefitted from advice from Nicholas J. Cox, of the University of Durham, U.K.,
and from Patrick Joly of Industry Canada, Ontario, Canada.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] compress}, {hi:[D] destring}, {hi:[D] encode}, {hi:[D] generate}, {hi:[D] gsort}, {hi:[D]label}
{p_end}
{p 4 13 2}
Online:  help for {helpb compress}, {helpb decode}, {helpb destring}, {helpb encode}, {helpb generate}, {helpb gsort}, {helpb label}, {helpb tostring}
{break} help for {helpb sdecode} if installed
{p_end}
