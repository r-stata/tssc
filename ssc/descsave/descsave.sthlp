{smcl}
{hline}
help for {cmd:descsave} {right:(Roger Newson)}
{hline}


{title:Save descriptive attributes of variables to a do-file and/or a Stata dataset}

{p 8 15}{cmd:descsave} [{varlist}] [{helpb using} {it:filename}] [ {cmd:,}
 {break}
 {cmdab:do:file}{cmd:(}{it:dofilename} [{cmd:, replace}]{cmd:)}
 {break}
 {cmdab:li:st}{cmd:(} [{varlist}] {ifin} [ , [{it:{help list:list_options}}] ] {cmd:)}
 {break}
 {cmdab:fr:ame}{cmd:(} {it:framename} [ , replace {cmdab:ch:ange} ] {cmd:)}
 {break}
 {cmdab:sa:ving}{cmd:(}{it:datafilename} [{cmd:, replace}]{cmd:)}
 {break}
 {cmdab::no}{cmdab:re:store} {cmd:fast} {cmdab:fl:ist}{cmd:(}{it:global_macro_name}{cmd:)}
 {break}
 {cmdab:don:tdo}{cmd:(}{it:attributes_list}{cmd:)}
 {break}
 {cmdab:ch:arlist}{cmd:(}{it:characteristic_list}{cmd:)}
 {cmdab:idn:um}{cmd:(}{it:#}{cmd:)} {cmdab:ids:tr}{cmd:(}{it:string}{cmd:)}
 {break}
 {cmdab:ren:ame}{cmd:(}{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}{cmd:)}
 {cmdab:gs:ort}{cmd:(}{it:gsort_list}{cmd:)} {cmdab:ke:ep}{cmd:(}{varlist}{cmd:)}
 {break}
 {cmdab:ds:head} {cmdab:d:etail} {cmdab:varl:ist}
 ]

{pstd}
where {it:{help list:list_options}} is a list of options accepted by the {helpb list} command,
{it:characteristic_list} is a list of {it:characteristic_name}s and/or asterisks ({cmd:*}) separated by spaces,
{it:attributes_list} is a list of items from the list

{p 8 18}
{cmd:type} {cmd:format} {cmd:vallab} {cmd:vallabdef} {cmd:varlab}

{pstd}
and {it:gsort_list} is a list of one or more elements of the form

{p 8 15}
[{cmd:+}|{cmd:-}]{it:varname}

{pstd}
as used by the {helpb gsort} command.


{title:Description}

{pstd}
{cmd:descsave} is an extended version of {helpb describe},
which lists descriptive attributes for a list of variables in a dataset given by
{varlist}, or for all variables in the dataset if {varlist} is not specified.
The dataset is the current dataset in memory, unless {helpb using} is used to specify a dataset in a file.
The descriptive attributes are variable names, storage types, display formats, value labels and variable labels
(as output by {helpb describe}),
and also (optionally) a list of {help char:characteristics} specified by the {cmd:charlist()} option.
{cmd:descsave} creates an output Stata dataset (or resultsset) with one observation per variable and data on
these descriptive attributes.
This dataset may be listed using the {cmd:list()} option
and/or saved to a {help frame:data frame} using the {cmd:frame()} option
and/or saved to a file using the {cmd:saving()} option
and/or written to the memory using the {cmd:norestore} or {cmd:fast} option,
overwriting any existing dataset.
The file specified by {cmd:dofile()} is a {help do:do-file}, containing commands which can be run to reconstruct the
descriptive attributes of the variables, assuming that variables of the same names have been created and
are numeric or character as appropriate.
{cmd:descsave} can be used together with {helpb export delimited} to create a definitive generic
spreadsheet version of the current dataset, together with a {help do:Stata do-file} to reconstruct the descriptive
attributes of the variables after the spreadsheet has been input using {helpb import delimited}.


{title:Options}

{pstd}
These options fall into the following 3 groups:

{p2colset 4 26 28 2}{...}
{p2col:Option group}Description{p_end}
{p2line}
{p2col:{it:{help descsave##outdest_opts:outdest_opts}}}Output-destination options for the do-file and/or resultsset{p_end}
{p2col:{it:{help descsave##conspec_opts:conspec_opts}}}Content-specifying options for the do-file and/or resultsset{p_end}
{p2col:{it:{help descsave##other_opts:other_opts}}}Other options{p_end}
{p2line}
{p2colreset}


{marker outdest_opts}{...}
{title:Output-destination options}

{p 4 8 2}
{cmd:dofile(}{it:dofilename} [{cmd:, replace}]{cmd:)} specifies an output {help do:Stata do-file}, with commands
to reconstruct the variable descriptive attributes (storage types, display formats, value labels,
variable labels and selected characteristics), assuming that variables with those names already exist
and are numeric or string-valued as appropriate.
If {cmd:replace} is specified, then any existing file of the same name is overwritten. 

{p 4 8 2}
{cmd:list(}{it:varlist} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [, {it:list_options} ] {cmd:)}
specifies a list of variables in the output dataset,
which will be listed to the Stata log by {cmd:descsave}.
The user may optionally also specify {helpb if} or {helpb in} clauses to list subsets of variables,
or change the display style using a list of {it:list_options} allowed as options by the {helpb list} command.
If the {cmd:rename()} option is specified (see below),
then any variable names specified by the {cmd:list()} option must be the new names.
If the {cmd:list()} option is absent, then nothing is listed.

{p 4 8 2}
{cmd:frame(} {it:name}, [ {cmd:replace} {cmd:change} ] {cmd:)} specifies an output {help frame:data frame},
with one observation per directory entry,
and data on the attributes of the directory entry.
If {cmd:replace} is specified, then any existing data frame of the same name is overwritten. 
If {cmd:change} is specified,
then the current data frame will be changed to the output data frame
after the execution of {cmd:descsave}.
The {cmd:frame()} option may not specify the current data frame.
To do this, use one of the options {cmd:norestore} or {cmd:fast}.

{p 4 8 2}
{cmd:saving(}{it:datafilename} [{cmd:, replace}]{cmd:)} specifies an output file containing a Stata dataset, with one
observation per variable, and data on the descriptive attributes of the variable. If {cmd:replace} is
specified, then any existing file of the same name is overwritten. 

{p 4 8 2}
{cmd:norestore} specifies that the output dataset will be written to the memory,
overwriting any pre-existing dataset.
This option is automatically set if {cmd:fast} is specified.
Otherwise, if {cmd:norestore} is not specified, then the pre-existing dataset is restored
in the memory after the execution of {cmd:descsave}.

{p 4 8 2}
{cmd:fast} is a stronger version of {cmd:norestore}, intended for use by programmers.
It specifies that the pre-existing dataset in the memory will not be restored,
even if the user presses {help break:Break} during the execution of {cmd:descsave}.
If {cmd:norestore} is specified and {cmd:fast} is absent,
then {cmd:descsave} will go to extra work so that
it can restore the original data if the user presses {help break:Break}.

{p 4 8 2}
Note that the user must specify at least one of the 6 options
{cmd:dofile()}, {cmd:list()}, {cmd:frame()}, {cmd:saving()}, {cmd:norestore} and {cmd:fast}.

{p 4 8 2}
{cmd:flist(}{it:global_macro_name}{cmd:)} specifies the name of a {help macro:global macro},
containing a filename list (possibly empty).
If {cmd:saving()} is also specified, then
{cmd:descsave} will append the {it:filename} specified in the
{cmd:saving()} option to the value of the global macro specified in {cmd:flist()}.
This enables the user to build a list of filenames in a global macro, containing the
output of a sequence of estimation result sets saved by {cmd:descsave}.
These files may later be concatenated using {helpb append},
or using {helpb dsconcat} if installed.


{marker conspec_opts}{...}
{title:Content-specifying options}

{p 4 8 2}
{cmd:dontdo(}{it:attributes_list}{cmd:)} specifies a list of variable attributes
that will not be set by the output do-file specified by the {cmd:dofile()} option.
These variable attributes are items in the list {cmd:type}, {cmd:format}, {cmd:vallab}, {cmd:vallabdef} and {cmd:varlab},
specifying variable {help type:types}, {help format:formats}, {help label:value labels},
{help label:value label definitions}, and {help label:variable labels},
respectively.
For instance, {cmd:dontdo(type)} specifies that the output do-file
will reset {help format:formats}, {help label:value labels} and {help label:variable labels},
but not {help type:storage types}.
This option can be useful if the user does not want to lose precision
when running the output do-file in a different dataset.

{p 4 8 2}
{cmd:charlist(}{it:characteristic_list}{cmd:)} specifies a list of characteristic names and/or asterisks ({cmd:*}),
separated by spaces.
The characteristics specified will be reconstructed by the do-file specified by {cmd:dofile()} (if specified),
and be written to variables in the output dataset.
If a characteristic has length greater than the maximum length for a string variable,
which is 244 in {help version:Version 9 of Stata}
(see help for {help data_types}),
then it will be truncated to that maximum length in the output dataset and/or do-file.
(This is not expected to cause problems very often.)
{cmd:descsave} expands the {it:characteristic_list} by replacing each asterisk {cmd:*} with a list of the names
of all characteristics of all variables in the {it:varlist}, and then contracts the {it:characteristic_list}
by removing the rightmost occurrences of all duplicate characteristic names.
Therefore, {cmd:charlist(*)} specifies a list of all characteristics
belonging to all variables in the {it:varlist}, and {cmd:charlist(omit missing *)} specifies a list of the same characteristics,
with {cmd:omit} appearing first and {cmd:missing} appearing second.
In the second case, the output variable {cmd:char1} will contain the {cmd:omit} characteristics,
and the output variable {cmd:char2} will contain the {cmd:missing} characteristic.
(See {cmd:Output dataset created by {cmd:descsave}} below for details on output variables.)

{p 4 8 2}
{cmd:idnum(}{it:#}{cmd:)} specifies an ID number for the output dataset.
It is used to create a numeric variable {cmd:idnum} in the output dataset, with that value for all
observations.
This is useful if the output dataset is concatenated with other {cmd:descsave} output datasets
using {helpb append}, or using {helpb dsconcat} if installed.

{p 4 8 2}
{cmd:idstr(}{it:#}{cmd:)} specifies an ID string for the output dataset.
It is used to create a string variable {cmd:idstr} in the output dataset, with that value for all
observations. (An output dataset may have {cmd:idnum}, {cmd:idstr}, both or neither.)

{p 4 8 2}
{cmd:rename(}{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}{cmd:)} specifies a list
of pairs of variable names. The first variable name of each pair specifies a variable in the output dataset,
which is renamed to the second variable name of the pair.
(See {cmd:Output dataset created by {cmd:descsave}} below for details on output variables.)

{p 4 8 2}
{cmd:gsort(}{it:gsort_list}{cmd:)} specifies a generalized sorting order (as recognised by {helpb gsort})
for the observations in the output dataset.
If {cmd:gsort()} is not specified,
then the output dataset will be sorted by the single variable {cmd:order}.
If {cmd:rename()} is specified, then {cmd:gsort()} must use the new names.

{p 4 8 2}
{cmd:keep(}{it:varlist}{cmd:)} specifies a list of variables to be kept in the output dataset.
If {cmd:keep()} is not specified, then the output dataset contains all the variables listed in the next section.
If {cmd:rename()} is specified, then {cmd:keep()} must use the new names.


{marker other_opts}{...}
{title:Other options}

{p 4 8 2}
{cmd:dshead} specifies that a list of headlines, describing the whole dataset,
is listed, similar to the list produced by {helpb describe:describe, short}.
This list precedes any listing of variable attributes produced by the {cmd:list()} option.

{p 4 8 2}
{cmd:detail} modifies the list of headlines produced by the {cmd:dshead} option
to contain the details added by the option of the same name for {cmd:describe}.
If {cmd:detail} is specified without {cmd:dshead},
then the {cmd:dshead} option is automatically implied.

{p 4 8 2}
{cmd:varlist} is a programmer's option, acting as the option of the same name for {cmd:describe}.
It specifies that, in addition to the usual saved results,
the options {cmd:r(varlist)} and {cmd:r(sortlist)} will also be saved.


{title:Output dataset created by {cmd:descsave}}

{pstd}
The output dataset (or resultsset) created by {cmd:descsave}
has one observation per variable in the {varlist}.
If the {cmd:rename()} option
is not specified, then it contains the following variables:

{p2colset 4 20 22 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{cmd:idnum}}Numeric dataset ID{p_end}
{p2col:{cmd:idstr}}String dataset ID{p_end}
{p2col:{cmd:order}}Variable order{p_end}
{p2col:{cmd:name}}Variable name{p_end}
{p2col:{cmd:type}}Storage type{p_end}
{p2col:{cmd:isnumeric}}Numeric indicator{p_end}
{p2col:{cmd:format}}Display format{p_end}
{p2col:{cmd:vallab}}Value label{p_end}
{p2col:{cmd:varlab}}Variable label{p_end}
{p2col:{cmd:char}{it:n}}Characteristic varname[{it:characteristic_name}]{p_end}
{p2line}
{p2colreset}

{pstd}
The variable {cmd:order} contains the sequential order of the variable in the input {varlist} specified for {cmd:descsave},
or the {help order} of that variable in the dataset, if the user does not specify an input {varlist}.
The variables {cmd:idnum} or {cmd:idstr} are only present if requested in the options of the same names.
The variable {cmd:isnumeric} is 1 if the variable is numeric and 0 if the variable is non-numeric.
There is one {cmd:char}{it:n} variable for each {it:characteristic_name} in the list specified
by the {cmd:charlist()} option. The variable {cmd:char}{it:n} specifies the {it:n}th characteristic
specified in the {cmd:charlist()} option (truncated if necessary to the maximum length for a string variable
under the current version of Stata).
All of these variables can be renamed using the {cmd:rename()} option,
or used by the {cmd:gsort()} option to specify the sorting order.
If the {cmd:keep()} option is used, then the output dataset will contain only the specified subset of these variables.


{title:Remarks}

{pstd}
{cmd:descsave} can be used together with {helpb outsheet} and {helpb insheet} to construct a definitive
generic spreadsheet version of the data. This is useful if the user needs either to convert the data to distant past
{help version:versions of Stata} not produced by {helpb saveold}, or to return to the data decades into the future,
when all proprietary software has evolved beyond recognition. The do-file specified by {cmd:dofile()} can be used
to reconstruct variable attributes after inputting the definitive version of the data using {helpb insheet}, assuming
that the variables are still numeric or string-valued, as specified in the original Stata data.
(The user may need to use {helpb destring} after using {helpb insheet}, if some of the numeric variables in the
definitive generic spreadsheet are formatted in nonstandard ways.)
The output do-file can also be translated manually into other software languages if the user wants to use the data
under other software platforms.
However, {cmd:descsave} can also be used with the {helpb parmest} package,
together with either the Stata 11 {helpb fvregen} package or the Stata 10 {helpb factext} package.
(See help for {helpb parmby}, {helpb parmest}, {helpb fvregen} and {helpb factext} if installed).
Typically, the user uses {cmd:descsave}
to save to a do-file the attributes of variables representing categorical factors, generates dummy variables for
these categorical factors using {helpb tabulate} or {helpb xi}, enters these dummy variables into a regression analysis,
saves the results of the regression to a dataset using {helpb parmby} or {helpb parmest}, and then reconstructs the
categorical factors from the variable {cmd:label} in the {helpb parmest} output dataset,
using the {helpb fvregen} package (in Stata 11) or the {helpb factext} package (in Stata 10).


{title:Examples}

{p 16 20}{inp:. descsave, list(,)}{p_end}

{p 16 20}{inp:. descsave, list(,) dshead}{p_end}

{p 16 20}{inp:. descsave make mpg weight, list(name varlab vallab, clean noobs)}{p_end}

{p 16 20}{inp:. descsave, list(, subvar noobs sepa(0) abbrev(32)) char(omit)}{p_end}

{p 16 20}{inp:. descsave, do(auto.do, replace)}{p_end}

{p 16 20}{inp:. descsave, saving(autodesc.dta, replace)}{p_end}

{p 16 20}{inp:. descsave, list(, noobs abb(32)) do(auto.do, replace) saving(autodesc.dta, replace) rename(varlab variable_label format variable_format)}{p_end}

{p 16 20}{inp:. descsave using auto2, list(,)}{p_end}

{p 16 20}{inp:. descsave model mpg price using auto2, list(,) saving(auto2desc, replace)}{p_end}

{p 16 20}{inp:. descsave, norestore}{p_end}

{pstd}
The following example will work in the {cmd:auto} data. The first part creates a generic text spreadsheet in
{cmd:auto.txt}, with a program to reconstruct the variable attributes in {cmd:auto.do}. The second part reconstructs
the {cmd:auto} data from {cmd:auto.txt}, using {cmd:auto.do}.

{p 16 20}{inp:. descsave, do(auto.do, replace) sa(autodesc.dta, replace) charlist(omit *)}{p_end}
{p 16 20}{inp:. outsheet using auto.txt, nolabel replace}{p_end}

{p 16 20}{inp:. insheet using auto.txt, clear}{p_end}
{p 16 20}{inp:. run auto.do}{p_end}
{p 16 20}{inp:. describe}{p_end}

{pstd}
The following example will work in the {cmd:auto} data
if the packages {helpb parmest}, {helpb factext} and {helpb eclplot} are installed.
All of these packages can be downloaded from {help ssc:SSC}.

{p 16 20}{inp:. tab foreign, gene(type_) nolabel}{p_end}
{p 16 20}{inp:. qui descsave foreign, do(foreign.do, replace)}{p_end}
{p 16 20}{inp:. parmby "regress mpg type_*, noconst robust", label norestore}{p_end}
{p 16 20}{inp:. factext foreign, do(foreign.do)}{p_end}
{p 16 20}{inp:. eclplot estimate min95 max95 foreign, xscal(range(-1 2)) xlab(0 1)}{p_end}

{pstd}
The following advanced example will work under Stata 8 or above in the {cmd:auto} data
if the {helpb dsconcat} and {helpb xcollapse} packages
are installed. Both packages can be downloaded from {help ssc:SSC}.
The example creates a dataset with 1 observation for each of a list of variables
and data on their names and median values, using {helpb xcollapse} and {helpb dsconcat},
and then uses {helpb merge} to merge in a dataset created by {cmd:descsave},
with 1 observation per variable and data on the variable names,
variable labels and display formats.

{p 16 20}{inp:. tempfile tf0}{p_end}
{p 16 20}{inp:. descsave price mpg headroom trunk weight length turn displacement gear_ratio, saving(`tf0', replace) gsort(name) keep(order name varlab format)}{p_end}
{p 16 20}{inp:. global tflist ""}{p_end}
{p 16 20}{inp:. local i1=0}{p_end}
{p 16 20}{inp:. foreach X of var price mpg headroom trunk weight length turn displacement gear_ratio {c -(}}{p_end}
{p 16 20}{inp:.   local i1=`i1'+1}{p_end}
{p 16 20}{inp:.   tempfile tf`i1'}{p_end}
{p 16 20}{inp:.   xcollapse (median) med=`X', idstr("`X'") nidstr(name) saving(`tf`i1'', replace) flist(tflist)}{p_end}
{p 16 20}{inp:. {c )-}}{p_end}
{p 16 20}{inp:. dsconcat {c S|}tflist}{p_end}
{p 16 20}{inp:. sort name}{p_end}
{p 16 20}{inp:. lab var med "Median value"}{p_end}
{p 16 20}{inp:. merge name using `tf0'}{p_end}
{p 16 20}{inp:. sort order}{p_end}
{p 16 20}{inp:. list order name varlab med}{p_end}


{title:Saved results}

{pstd}
{cmd:descsave} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(k)}}number of variables{p_end}
{synopt:{cmd:r(width)}}width of dataset{p_end}
{synopt:{cmd:r(changed)}}flag indicating data have changed since last saved{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(datalabel)}}dataset label){p_end}
{synopt:{cmd:r(varlist)}}variables in dataset (if {cmd:varlist} specified){p_end}
{synopt:{cmd:r(sortlist)}}variables by which data are sorted (if {cmd:varlist} specified){p_end}
{synopt:{cmd:r(charlist)}}Full list of variable characteristic names specified by {cmd:charlist()}{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {cmd:[D] describe}, {cmd:[D] destring}, {cmd: [D] gsort}, {cmd:[D] insheet}, {cmd:[D] label}, {cmd:[D] outsheet}
 {break}{cmd:[R] tabulate}, {cmd:[R] xi}
 {break}{cmd:[U] 12.8 Characteristics}
 {break}{cmd:[P] char}
{p_end}
{p 4 13 2}
On-line: help for {helpb append}, {helpb char}, {helpb describe}, {helpb destring}, {helpb gsort}, {helpb insheet}, {helpb label}, {helpb outsheet},
 {helpb saveold}, {helpb tabulate}, {helpb xi}
 {break} help for {helpb dsconcat}, {helpb eclplot}, {helpb factext}, {helpb fvregen}, {helpb parmby}, {helpb parmest}, {helpb xcollapse} if installed
{p_end}
