{smcl}
{hline}
help for {cmd:prodvars} {right:(Roger Newson)}
{hline}


{title:Create product variables for two lists of input variables}

{p 8 15}{cmd:prodvars} {help varlist:{it:lvarlist}} {ifin} {cmd:,} {cmdab:rv:arlist}{cmd:(}{help varlist:{it:rvarlist}}{cmd:)} [ {break}
 {opt g:enerate(stub)}
 {opt pr:efix(string)} {opt su:ffix(string)} {opt se:parator(string)}
 {break}
 {opt lpr:efix(string)} {opt lsu:ffix(string)} {opt lse:parator(string)}
 {break}
 {opt lln:ame} {opt lrn:ame} {opt nol:abel}
 {break}
 {opt lch:arlist(charlist)} {opt rch:arlist(charlist)} {opt cch:arlist(charlist)}
 {opt ccpr:efix(string)} {opt ccsu:ffix(string)} {opt ccse:parator(string)}
 {break}
 {opt noc:onstant} {opt float} {opt replace} {opt fast} ]

{pstd}
where {help varlist:{it:lvarlist}} and {help varlist:{it:rvarlist}} are the left and right {help varlist:variable lists},
respectively.


{title:Description}

{pstd}
{cmd:prodvars} inputs 2 {help varlist:variable lists}, known as the left variable list and the right variable list.
It produces as output a list of generated variables,
one for each pair of variables from the left and right variable lists,
each with a variable name derived either from a stub or from the names of the pair of input variables,
and values equal to the products of the values of the two input variables.
Optionally, the generated variables may also have {help label:variable labels}
derived from the {help label:variable labels}, or variable names, of the input variables.
{cmd:prodvars} is useful for calculating variables for the design matrix of a multiple-intercept model.
Such a multiple-intercept model is fitted to the data
using an {help estcom:estimation command} with the {opt noconstant} option.
Typically, one of the two input {help varlist:variable lists} is a list of indicator variables (or dummy variables),
each indicating membership of one of several groups, forming a partition of the sample,
and corresponding to group-specific intercepts in the fitted model.
Such a variable list may be produced using {helpb tabulate oneway:tabulate} with the {cmd:generate()} option,
or by {helpb xi} with the {cmd:noomit} option.
The other {help varlist:variable list} is typically a list of variables corresponding to slopes, differences, or ratios in the fitted model.
These variables are usually either quantitative variables,
or group identifier variables corresponding to a factor with an omitted group,
possibly produced using {helpb xi} without the {cmd:noomit} option.
The generated product variables will then be included in the design matrix,
together with the variables in the first input list (corresponding to group-specific intercepts),
and will correspond to group-specific slopes, differences, or ratios.


{title:Options}

{phang}
{cmd:rvarlist}{cmd:(}{help varlist:{it:rvarlist}}{cmd:)}
specifies the right variable list.
The generated variables will correspond to pairs of variables,
the first variable from the left variable list {help varlist:{it:lvarlist}},
and the second variable from the right variable list {help varlist:{it:rvarlist}}.
Each generated variable will contain the product of the corresponding pair of input variables,
at least in observations selected by the {helpb if} and {helpb in} qualifiers.

{phang}
{opt generate(stub)} specifies a stub from which the output variable names will be created.
If {cmd:generate()} is specified, then the output product variables will have names prefixed with the {it:stub},
and suffixed with serial numbers,
ordered primarily by the order of the corresponding input variables in the {help varlist:{it:lvarlist}}
and secondarily by the order of the corresponding input variables specified by {cmd:rvarlist()}.
For instance, if there are 3 variables in the {help varlist:{it:lvarlist}}
and 2 variables in the variable list specified by {cmd:rvarlist()},
and the user specifies {cmd:generate(b_)},
then the output product variables will be named {cmd:b_1}, {cmd:b_2}, {cmd:b_3}, {cmd:b_4}, {cmd:b_5} and {cmd:b_6}.
If the user specifies a {cmd:generate()} option,
then the {cmd:prefix()}, {cmd:suffix()} and {cmd:separator()} options
will be ignored.

{phang}
{opt prefix(string)} specifies a prefix for generating the variable names of the generated product variables.
The name of a product variable,
corresponding to a left variable from the left variable list and a right variable from the right variable list,
is formed by combining the prefix specified by {cmd:prefix()}, the left variable name,
the separator specified by {cmd:separator()}, the right variable name,
and the suffix specified by {cmd:suffix()}.
The prefix and/or the separator and/or the suffix may be empty.

{phang}
{opt suffix(string)} specifies a suffix for generating the variable names of the generated product variables.

{phang}
{opt separator(string)} specifies a separator for generating the variable names of the generated product variables.

{phang}
{opt lprefix(string)} specifies a prefix for generating the {help label:variable labels} of the generated product variables.
The {help label:variable label} of a product variable,
corresponding to a left variable from the left variable list and a right variable from the right variable list,
is formed by combining the prefix specified by {cmd:lprefix()}, the left variable label (or name),
the separator specified by {cmd:lseparator()}, the right variable label (or name),
and the suffix specified by {cmd:lsuffix()}.
The prefix and/or the separator and/or the suffix may be empty.

{phang}
{opt lseparator(string)} specifies a separator for generating the {help label:variable labels} of the generated product variables.

{phang}
{opt lsuffix(string)} specifies a suffix for generating the {help label:variable labels} of the generated product variables.

{phang}
{opt llname} specifies that the {help label:variable labels} of the generated product variables
will be generated using the variable names of the left variables in the list {help varlist:{it:lvarlist}}.
If {opt llname} is not specified, then the {help label:variable label} of a generated product variable
is generated using the {help label:variable label} of the left variable, if this label is not empty,
and using the variable name of the left variable otherwise.

{phang}
{opt lrname} specifies that the {help label:variable labels} of the generated product variables
will be generated using the variable names of the right variables in the list {help varlist:{it:rvarlist}}.
If {opt lrname} is not specified, then the {help label:variable label} of a generated product variable
is generated using the {help label:variable label} of the right variable, if this label is not empty,
and using the variable name of the right variable otherwise.

{phang}
{opt nolabel} specifies that no {help label:variable labels} will be generated
for the generated product variables.
If {opt nolabel} is specified,
then the options {opt lprefix()}, {opt lseparator()}, {opt lsuffix()}, {opt llname}, and {opt lrname} are ignored.

{phang}
{opt lcharlist(charlist)} specifies a list of names of {help char:variable characteristics}
for the generated product variables,
to be inherited from the corresponding left input variables
specified by the {help varlist:{it:lvarlist}}.

{phang}
{opt rcharlist(charlist)} specifies a list of names of {help char:variable characteristics}
for the generated product variables,
to be inherited from the corresponding right input variables
specified by the {cmd:rvarlist()} option.

{phang}
{opt ccharlist(charlist)} specifies a list of names of {help char:variable characteristics}
for the generated product variables,
to be evaluated by combining the characteristics of the same names
from the corresponding left input variables specified by the {help varlist:{it:lvarlist}}
and from the corresponding right input variables specified by the {cmd:rvarlist()} option.

{phang}
{opt ccprefix(string)} specifies a prefix string,
to be used when combining the {help char:variable characteristics} specified by {cmd:ccharlist()}
from the left and right input variables
to form the characteristics of the same names for the generated product variables.

{phang}
{opt ccsuffix(string)} specifies a suffix string,
to be used when combining the {help char:variable characteristics} specified by {cmd:ccharlist()}
from the left and right input variables
to form the characteristics of the same names for the generated product variables.

{phang}
{opt ccseparator(string)} specifies a separator string,
to be used when combining the {help char:variable characteristics} specified by {cmd:ccharlist()}
from the left and right input variables
to form the characteristics of the same names for the generated product variables.

{phang}
{opt noconstant} specifies that generated product variables which are constant in the sample will be dropped.
This option can be useful if the generated product variables are used in a design matrix.

{phang}
{opt float} specifies that the highest precision {help data type:storage type} allowed for a generated product variable
will be {cmd:float}.
If {opt float} is not specified,
then the highest precision {help data type:storage type} allowed for a generated product variable will be {cmd:double}.
Note that, whether or not {opt float} is specified,
all generated product variables are {help compress:compressed} to the lowest precision possible
without losing information.

{phang}
{opt replace} specifies that,
if any existing variables have the same names as those specified for the generated product variables,
then these existing variables will be dropped.
If {opt replace} is not specified,
then {cmd:prodvars} checks whether any such existing variables exist,
and fails if any exist.

{phang}
{opt fast} is an option for programmers.
It specifies that {cmd:prodvars} will do no extra work
to preserve the original data (without any generated product variables)
if the user presses {help break:Break}.


{title:Remarks}

{pstd}
{cmd:prodvars} is intended to produce design matrices for regression models with multiple intercepts,
estimated using {help estcom:estimation commands} with the {cmd:noconstant} option.
This practice is in contrast to the more traditional practice of estimating regression parameters
for models with a single intercept,
which is identified in Stata by the parameter name {hi:_cons},
if the {cmd:noconstant} option is not specified.

{pstd}
The {help label:variable labels} of the generated indicator variables can be made as informative as possible.
They are similar to those generated by {helpb xi} and {helpb tabulate oneway:tabulate},
but a lot more flexible.
In particular, the parameters, and the corresponding {help label:variable labels},
can be output to output datasets (or resultssets) by the {helpb parmest} package,
and the categorical factors can be reconstructed in these resultssets,
using the {helpb descsave} and {helpb factext} packages.
The packages {helpb parmest}, {helpb descsave} and {helpb factext}
can all be downloaded from {help ssc:SSC},
using the {helpb ssc} command in Stata.


{title:Examples}

{pstd}
The following example works if the  {helpb descsave} and {helpb parmest} packages are installed from {help ssc:SSC}.
(This can be done in Stata using the {helpb ssc} command.)
{helpb xi} and {cmd:prodvars} are used together to create a design matrix,
with variables prefixed by {hi:_I}, corresponding to one intercept for each level of the variable {hi:foreign},
and variables prefixed by {hi:_H},
corresponding to one slope of fuel consumption with respect to weight for each level of {hi:foreign}.
These parameters are estimated using {helpb regress}
and displayed using {helpb parmest}.
Note that {helpb descsave} and {helpb parmest} display the variable labels of the product variables
produced by {cmd:prodvars}.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. gene gpm=1/mpg}{p_end}
{p 16 20}{inp:. lab var gpm "Fuel consumption (gallons/mile)"}{p_end}
{p 16 20}{inp:. xi i.foreign, noomit}{p_end}
{p 16 20}{inp:. prodvars _I*, rvar(weight) pre(_H) sep(X) lpre("(") lsep(")*") lrname}{p_end}
{p 16 20}{inp:. descsave, list(, abbr(32) subvar noobs)}{p_end}
{p 16 20}{inp:. regress gpm _I* _H*, noconst}{p_end}
{p 16 20}{inp:. parmest, label list(, abbr(32))}{p_end}

{pstd}
The following example works if the  {helpb descsave} and {helpb parmest} packages are installed from {help ssc:SSC}.
We create a categorical factor {hi:mod3}, containing the sequence order (modulo 3) of the car model in the dataset,
and having values 0, 1 and 2.
We then use {helpb xi}, with the {cmd:noomit} option,
to produce a lst of variables, prefixed by {hi:_I},
indicating membership of groups defined by all values of the variable {hi:foreign}.
We then use {helpb xi}, without the {cmd:noomit} option,
to produce a list of variables, prefixed by {hi:J},
indicating membership of groups defined by all non-zero values of the variable {hi:mod3}.
We then use {cmd:prodvars} to produce product variables, prefixed by {hi:_H},
corresponding to combinations of all values of {hi:foreign}
and non-zero values of {hi:mod3}.
The final regression model contains an intercept for each value of {hi:foreign},
defined as a mean weight for cars with that value of {hi:foreign}
and a baseline zero value of {hi:mod3},
and a weight difference for each combined value of {hi:foreign} and non-zero value of {hi:mod3},
comparing mean car weights with the mean car weight for cars with the same value of {hi:foreign}
and a zero value of {hi:mod3}.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. gene mod3=mod(_n,3)}{p_end}
{p 16 20}{inp:. lab var mod3 "Model sequence (modulo 3)"}{p_end}
{p 16 20}{inp:. xi i.foreign, noomit}{p_end}
{p 16 20}{inp:. xi i.mod3, pref(_J)}{p_end}
{p 16 20}{inp:. prodvars _I*, rvar(_J*) pre(_H) lsep(" & ")}{p_end}
{p 16 20}{inp:. descsave, list(, abbr(32) subvar noobs)}{p_end}
{p 16 20}{inp:. regress weight _I* _H*, noconst}{p_end}
{p 16 20}{inp:. parmest, label list(, abbr(32))}{p_end}


{title:Saved results}

{pstd}
{cmd:prodvars} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(prodvars)}}list of generated product variables{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] tabulate}, {hi:[R] xi}
{p_end}
{p 4 13 2}
On-line: help for {helpb tabulate oneway:tabulate}, {helpb xi}
 {break} help for {helpb parmest}, {helpb descsave}, {helpb factext} if installed
{p_end}
