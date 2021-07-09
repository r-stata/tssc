{smcl}
{hline}
help for {cmd:parmparse} {right:(Roger Newson)}
{hline}


{title:Parse a parameter name variable in a {helpb parmest} resultsset}

{p 8 15}{cmd:parmparse} {varname} {ifin} [ {cmd:,}
 {cmdab:om:it}{cmd:(}{help varname:{it:newvarname}}{cmd:)}
 {cmdab:ty:pe}{cmd:(}{help varname:{it:newvarname}}{cmd:)}
 {cmdab:na:me}{cmd:(}{help varname:{it:newvarname}}{cmd:)}
 {cmdab:ba:se}{cmd:(}{help varname:{it:newvarname}}{cmd:)}
 {cmdab:le:vel}{cmd:(}{help varname:{it:newvarname}}{cmd:)}
 {cmdab:op}{cmd:(}{help varname:{it:newvarname}}{cmd:)}
 {cmdab:ts:op}{cmd:(}{help varname:{it:newvarname}}{cmd:)}
 {cmdab:de:limiter}{cmd:(}{it:string}{cmd:)}
 {cmd:fast}
 ]


{title:Description}

{pstd}
{cmd:parmparse} is intended for use in output datasets (or resultssets) created by the programs {helpb parmest} or {helpb parmby}.
These are part of the {helpb parmest} package, which can be downloaded from {help ssc:SSC},
and which create output datasets (or resultssets),
with one observation per estimated parameter of a model fitted to an original dataset.
{cmd:parmparse} inputs a string variable containing parameter names,
usually named {cmd:parm} in a {helpb parmest} resultsset,
and outputs one or more variables, containing parameter attributes which can be inferred from the parameter name.
These attributes include the parameter omit status,
the parameter type,
a list of the variable names for the factors and other variables whose effects are measured by the parameter,
and lists of the corresponding base statuses, factor levels, full operator portions, and time series operator portions.
These lists can be delimited by a user-specified delimiter string,
allowing the output list variables to be input to the {helpb split} command for further processing.


{title:Options}

{phang}
{cmd:omit}{cmd:(}{help varname:{it:newvarname}}{cmd:)} specifies an output numeric variable,
indicating, in each observation, the omit status of the corresponding parameter.
Parameters may be omitted because of collinearity,
or because they correspond to base levels of {help fvvarlist:factor variables}.

{phang}
{cmd:type}{cmd:(}{help varname:{it:newvarname}}{cmd:)} specifies an output string variable,
containing, in each observation, the matrix stripe element type of the corresponding parameter.
This type may be {cmd:variable}, {cmd:error}, {cmd:factor}, {cmd:interaction}, or {cmd:product}.

{phang}
{cmd:name}{cmd:(}{help varname:{it:newvarname}}{cmd:)} specifies an output string variable,
containing, in each observation,
a delimited list of the names of the variables whose effects are measured by the corresponding parameter.

{phang}
{cmd:base}{cmd:(}{help varname:{it:newvarname}}{cmd:)} specifies an output string variable,
containing, in each observation,
a delimited list of the baseline statuses of the corresponding parameter,
with respect to the corresponding variables whose names are listed in the {cmd:name()} output variable.
These statuses are string representations of numeric values.
These numeric values can be {cmd:0} if the parameter represents a non-baseline level of the corresponding variable,
{cmd:1} if the parameter represents a baseline level of the corresponding variable,
or the missing value {cmd:.} if the parameter does not represent a level of the corresponding variable.

{phang}
{cmd:level}{cmd:(}{help varname:{it:newvarname}}{cmd:)} specifies an output string variable,
containing, in each observation,
a delimited list of the {help fvvarlist:factor levels} represented by the corresponding parameter,
with respect to the corresponding variables whose names are listed in the {cmd:name()} output variable.
These levels are string representations of numeric values,
equal, in each case, to the value of the corresponding variable represented by the parameter,
or to the missing value {cmd:.} if the parameter does not represent a level of the corresponding variable.

{phang}
{cmd:op}{cmd:(}{help varname:{it:newvarname}}{cmd:)} specifies an output string variable,
containing, in each observation,
a delimited list of the full operator portions represented by the corresponding parameter,
with respect to the corresponding variables whose names are listed in the {cmd:name()} output variable.
These operator portions are described in the documentation
for {help fvvarlist:factor variables} and {help varlist:{it:varlist}s}.

{phang}
{cmd:tsop}{cmd:(}{help varname:{it:newvarname}}{cmd:)} specifies an output string variable,
containing, in each observation,
a delimited list of the time series operator portions represented by the corresponding parameter,
with respect to the corresponding variables whose names are listed in the {cmd:name()} output variable.
These time series operator portions are described in the documentation for {help varlist:{it:varlist}s}.

{phang}
{cmd:delimiter}{cmd:(}{it:string}{cmd:)} specifies a delimiter string,
to be used in the output string variables containing delimited lists.
If {cmd:delimiter()} is not specified,
then the blank space delimiter string {cmd:" "} is used.
Other delimiter strings can be useful,
if the user intends to input the output string list variables to {helpb split},
which outputs a list of new string variables, containing the individual list elements,
which can in turn be input to further processing steps.

{phang}
{cmd:fast} is an option for programmers.
It specifies that {cmd:parmparse} will not restore the original data in memory
in the event of failure,
or if the user presses {help break:Break}.


{title:Remarks}

{pstd}
{cmd:parmparse} is a front end for the {help undocumented:undocumented} Stata command {helpb _ms_parse_parts}.
This undocumented command is also used by the {helpb fvregen} package, downloadable from {help ssc:SSC},
which reconstructs the factor variables in a {helpb parmest} resultsset..


{title:Examples}

{pstd}
The following examples will work with the {hi:auto} data if the {help ssc:SSC} package {helpb parmest} is installed.

{pstd}
Set-up:

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. regress mpg i.foreign##i.rep78}{p_end}
{p 16 20}{inp:. parmest, norestore}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list}{p_end}

{pstd}
Simple example:

{p 16 20}{inp:. parmparse parm, omit(omitstat) type(ptype) name(names) base(basestat) level(flevels) op(oppor) tsop(tsoppor)}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list parm estimate p omitstat ptype names basestat flevels oppor tsoppor}{p_end}

{pstd}
The following example illustrates the use of {cmd:parmparse},
with a non-default {cmd:delimiter()} option,
to produce ampersand-delimited string output variables.
These output variables can then processed further, using {helpb split},
to produce additional output variables,
containing the individual list elements.

{p 16 20}{inp:. parmparse parm, omit(omitstat) type(ptype) name(names) base(basestat) level(flevels) op(oppor) tsop(tsoppor) delimiter(&)}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list parm estimate p omitstat ptype names basestat flevels oppor tsoppor}{p_end}
{p 16 20}{inp:. split names, parse(&) gene(S_)}{p_end}
{p 16 20}{inp:. list parm estimate p omitstat ptype basestat flevels oppor tsoppor S_*}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {findalias frfvvarlists}, {manlink P fvexpand}, {manlink D split}
{p_end}

{psee}
{space 2}Help:  {manhelp fvvarlist U:11.4.3 Factor variables}, {manhelp fvexpand P}, {manhelp split D}{break}
{helpb parmest}, {helpb fvregen} if installed
{p_end}
