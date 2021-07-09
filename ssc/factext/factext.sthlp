{smcl}
{hline}
help for {cmd:factext} {right:(Roger Newson)}
{hline}


{title:Extract factor values from a {hi:label} variable created by {helpb parmest} or {helpb parmby}}

{p 8 15}{cmd:factext} [{it:newvarlist}] {ifin} [ {cmd:,}
 {cmdab:fr:om}{cmd:(}{it:varlist}{cmd:)} {cmdab:st:ring}
 {cmdab:do:file}{cmd:(}{it:dofilename}{cmd:)}
 {cmdab:pa:rse}{cmd:(}{it:parse_string}{cmd:)} {cmdab:fm:issing}{cmd:(}{it:newvarname}{cmd:)} ]


{title:Description}

{pstd}
{cmd:factext} is intended for use after the programs {helpb parmest} or {helpb parmby}.
These are part of the {helpb parmest} package, which can be downloaded from {help ssc:SSC},
and which create output datasets (or resultssets) with one observation per parameter of the most recently fitted model.
It is used when the fitted model contains factors
(categorical variables), in which case some of the parameters correspond to dummy variables in the
original dataset, indicating individual values of these factors.
These dummy variables are usually created
by {helpb xi}, by {helpb tabulate}, by John Hendrickx's {helpb desmat} package.
For continuous predictor variables, similar dummy-like variables, known as reference splines,
can be created using the {helpb factref} module of the {help ssc:SSC} package {helpb bspline},
with the {helpb labprefix()} option.
{cmd:factext} is used to create new factors with the same names in the new dataset created by {helpb parmest}.
These new factors can be used to make confidence interval plots and/or tables.
Each new factor is assigned the
appropriate value in observations belonging to parameters belonging to the factor, and missing values
in other observations.
The values of these factors are usually extracted from the {hi:label} variable in the dataset
created by {helpb parmby} or {helpb parmest}.
If the model contains categorical factors,
then the {hi:label} variable will
have values of the form

{pstd}
{cmd:"}{it:factor_name}{cmd:==}{it:value}{cmd:"}

{pstd}
in observations belonging to parameters belonging to these factors.
The names of the factors to be
re-created are specified in the {it:newvarlist} if it is present, and otherwise are specified by the
{it:factor_name}s.
The factor values are specified in the {it:value}s.

{pstd}
Users of {help version:Stata versions 11 or above} should probably not use {cmd:factext}.
Instead, they should probably use the {helpb fvregen} package, also downloadable from {help ssc:SSC},
which regenerates factor variables (introduced in Stata version 11) in a {helpb parmest} output dataset
by extracting their names and values from the parameter name variable,
whose default name is {cmd:parm}.


{title:Options}

{p 0 4}{cmd:from(}{it:varlist}{cmd:)} specifies a list of input string variables, from which the factors
and their values are extracted.
If this option is absent, then {cmd:factext} attempts to extract the
factors from a single string variable named {hi:label}.
The {cmd:from()} option is used when the fitted model
contains interactions, in which case the user must create a list of new string variables from {hi:label}
and specify these as the {cmd:from()} option (see Remarks).
Factor values found in later variables in the
{cmd:from()} list overwrite values for the same factors found in earlier variables in the {cmd:from()} list.

{p 0 4}{cmd:string} specifies that the factors generated will be string variables.
Otherwise they will be
numeric variables.

{p 0 4}{cmd:dofile(}{it:dofilename}{cmd:)} specifies a Stata do-file to be called by {cmd:factext} after the
new factors have been created.
This do-file is usually created by {helpb descsave}, and contains commands
to reconstruct the new factors with the storage types, display formats, value labels,
variable labels and selected characteristics of the old factors with the same names in the original dataset.

{p 0 4}{cmd:parse(}{it:parse_string}{cmd:)} specifies the string used to parse the input string variables
specified in the {cmd:from()} option.
This {it:parse_string} separates the {it:factor_name}s from the
{it:value}s.
If absent, it defaults to {cmd:"=="}.

{p 0 4}{cmd:fmissing(}{it:newvarname}{cmd:)} specifies the name of a new binary variable to be generated,
containing missing values for observations excluded by the {helpb if} and {helpb in} qualifiers,
1 for other observations in which all the generated factors are missing, and 0 for other observations
in which at least one of the generated factors is nonmissing.


{title:Remarks}

{pstd}
{cmd:factext} is typically used with the {helpb parmest} and {helpb descsave} packages to create a new dataset
with one observation per parameter of the most recently fitted model,
and data on the estimates, confidence intervals, P-values
and other attributes of these parameters.
These data are used to create tables and/or plots.
Confidence interval plots are often produced using the {helpb eclplot} package,
which can also be downloaded from {help ssc:SSC}.
More information about the use of {cmd:factext} in combination with {helpb parmest}, {helpb descsave} and {helpb eclplot}
can be found in Newson (2003).
In its default setting, with no {cmd:from()} option, {cmd:factext} can only handle labels for dummy variables
corresponding to single factors, and cannot extract higher-order interactions.
If there are higher-order
interactions in the fitted model, then some of the values of {hi:label} may be of a form such as

{pstd}
{cmd:"}{it:factor_name1}{cmd:==}{it:value1}{cmd: & }{it:factor_name2}{cmd:==}{it:value2}{cmd:"}

{pstd}
or

{pstd}
{cmd:"(}{it:factor_name}{cmd:==}{it:value}{cmd:)*}{it:varname}{cmd:"}

{pstd}
(as created by {helpb xi}).
In this case, the user may use the {helpb split} command
to split the variable {hi:label} into two or more string variables,
each possibly containing values of the form

{pstd}
{cmd:"}{it:factor_name}{cmd:==}{it:value}{cmd:"}

{pstd}
These new string variables may then be input as the {cmd:from()} option of {cmd:factext} to extract the
{it:value}s.
(See Examples below.)

{pstd}
If the model contains reference splines
generated using the {helpb flexcurv} module of the {help ssc:SSC} package {helpb bspline},
and the user has used {helpb flexcurv} with the option {cmd:labprefix("}{it:variable_name}{cmd:==")},
where {it:variable_name} is the {it:X}-axis variable input to {helpb flexcurv},
then the {hi:label} variable may contain values of the form

{pstd}
{cmd:"}{it:variable_name}{cmd:==}{it:value}{cmd:"}

{pstd}
and {cmd:factext} can create a variable in the output dataset
with the name and reference values of the {it:X}-axis variable.
See the on-line help for {helpb bspline} if installed.

{pstd}
To add extra observations to the dataset containing reference levels for the factors created by {cmd:factext},
the user may use the {helpb factref} package, or merge in a dataset created using {helpb xcontract}.
To merge multiple factors and generate string variables containing the factor values, names and labels,
use the {helpb factmerg} package.
The {helpb factmerg}, {helpb factref} and {helpb xcontract} packages
can be downloaded from {help ssc:SSC}.


{title:Examples}

{pstd}
The following examples will work with the {hi:auto} data if the {help ssc:SSC} packages {helpb parmest} and {helpb eclplot} are installed.
They will create confidence
interval plots of the parameters corresponding to values of the factor {cmd:rep78}.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. tab rep78, gene(rep_)}{p_end}
{p 16 20}{inp:. parmby "regress mpg rep_*, noconst", label norestore}{p_end}
{p 16 20}{inp:. factext rep78}{p_end}
{p 16 20}{inp:. eclplot estimate min95 max95 rep78}{p_end}

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. xi: regress mpg i.rep78}{p_end}
{p 16 20}{inp:. parmest, label norestore}{p_end}
{p 16 20}{inp:. factext}{p_end}
{p 16 20}{inp:. eclplot estimate min95 max95 rep78, yline(0)}{p_end}

{pstd}
The following example will work with the {hi:auto} data if {helpb descsave} is installed in addition
to {helpb parmest} and {helpb eclplot}.
The reconstructed categorical variables {hi:rep78} and {hi:foreign} will have
the variable and value labels belonging to the variables of the same names in the original dataset.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. tab foreign,gene(orig_) nolab}{p_end}
{p 16 20}{inp:. tempfile tf1}{p_end}
{p 16 20}{inp:. descsave, do(`"`tf1'"', replace)}{p_end}
{p 16 20}{inp:. parmby "xi: regress mpg orig_* i.rep78, noconst", label norestore}{p_end}
{p 16 20}{inp:. factext, do(`"`tf1'"')}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. eclplot estimate min95 max95 rep78, yline(0)}{p_end}
{p 16 20}{inp:. eclplot estimate min95 max95 foreign, xlab(0 1)}{p_end}
{p 16 20}{inp:. list foreign rep78 estimate min95 max95 p}{p_end}

{pstd}
The following example demonstrates higher order interactions.
It will work with the {hi:auto} data
if {helpb descsave} is installed in addition to {helpb parmest}.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. tempfile tf1}{p_end}
{p 16 20}{inp:. descsave, do(`"`tf1'"', replace)}{p_end}
{p 16 20}{inp:. parmby "xi: regress mpg i.foreign*i.rep78", label norestore}{p_end}
{p 16 20}{inp:. split label, parse(" & ") gene(s_)}{p_end}
{p 16 20}{inp:. factext, from(s_*) do(`"`tf1'"')}{p_end}
{p 16 20}{inp:. list foreign rep78 parm estimate min95 max95 p, nodisp}{p_end}

{pstd}
The {helpb parmest}, {helpb descsave} and {helpb eclplot} packages can be installed from {help ssc:SSC}.


{title:Saved results}

{pstd}
{cmd:factext} saves the following results in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(faclist)}}list of factors created{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Newson, R.  2003.
Confidence intervals and {it:p}-values for delivery to the end user.
{it:The Stata Journal} 3(3): 245-269.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0043":the {it:Stata Journal} website}.


{title:Also see}

{p 0 10}
{bind: }Manual:   {hi:[R] describe}, {hi:[R] label}, {hi:[R] tabulate}, {hi:[R] xi}, {hi:[D] split}, {hi:[G] graph}
{p_end}
{p 0 10}
On-line:   help for {helpb describe}, {helpb label}, {helpb tabulate}, {helpb xi}, {helpb split}, {helpb graph}
 {break} help for {helpb parmest}, {helpb descsave}, {helpb desmat}, {helpb factref}, {helpb factmerg},
 {helpb eclplot}, {helpb xcontract}, {helpb fvregen}, {helpb bspline} if installed
{p_end}
