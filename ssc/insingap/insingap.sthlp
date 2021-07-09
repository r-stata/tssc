{smcl}
{.-}
help for {cmd:insingap} {right:(Roger Newson)}
{.-}


{title:Insert a single gap observation at the top of each by-group in a dataset}

{p 8 21 2}
{cmd:insingap} [ {help varlist:{it:byvarlist}} ]
 [ , {opth inn:erorder(varlist)}
   {break}
   {cmdab:newo:rder}{cmd:(}{newvar} [, {cmd:replace}]{cmd:)}
   {break}
   {cmdab:gap:indicator}{cmd:(}{newvar} [, {cmd:replace}]{cmd:)}
   {break}   
   {opth row:label(varname)} {opth grd:ecode(varlist)}
   {break}
   {help msdecode:{it:msdecode_options}}
   {break}
   {cmdab:gro:wlabels}{cmd:(}{it:string}{cmd:)}
   {cmdab:rst:ring}{cmd:(}{it:string_replacement_option}{cmd:)}
   {opt fast}
 ]

{pstd}
where {it:string_replacement_option} can be

{pstd}
{cmd:order} | {cmd:name} | {cmd:type} | {cmd:format} | {cmd:varlab} | {cmd:char} {help char:{it:characteristic_name}} | {cmd:label} | {cmd:labname}

{pstd}
and {help char:{it:characteristic_name}} is the name of a {help char:variable characteristic},
and {help msdecode:{it:msdecode_options}} is a list of any options used by {helpb msdecode},
apart from {cmd:generate()} and {cmd:replace}.


{title:Description}

{pstd}
{cmd:insingap} inputs a dataset and (optionally) a list of by-variables.
It sorts the dataset by these by-variables (if present),
and then inserts a single gap observation at the beginning of each by-group,
or at the top of the dataset if there are no by-variables.
In the gap observations, values of the non-by variables are initialized to missing.
However, the user may specify an existing string variable as a row label variable,
and set its value in the gap observations
to a value derived by decoding a subset of the by-variables,
using the {helpb msdecode} module of the {help ssc:SSC} package {helpb sdecode}.
These gap observations may be useful when presenting the dataset.
For instance, the dataset may be used to produce tables,
using the {help ssc:SSC} package {helpb listtab}.
Alternatively, the dataset may be used to produce plots,
using the {help ssc:SSC} package {helpb sencode} to encode the row variable.
{cmd:insingap} requires the packages {helpb sdecode} and {helpb ingap},
which the user can download from {help ssc:SSC}.


{title:Options}

{phang}
{opth innerorder(varlist)} specifies a list of variables,
used to sort the observations in the dataset,
or in each by-group specified by the {help varlist:{it:byvarlist}},
before the gap observations are inserted.
If {cmd:innerorder()} is not specified,
then the observations are left in the original order.

{phang}
{cmd:neworder(}{help newvarname:{it:newvarname}} [, {cmd:replace}]{cmd:)} specifies the name of a new variable to be generated,
equal to the new sequential order of the observation within the dataset,
or within the by-group if a {help varlist:{it: byvarlist}} is specified,
after the gap observations have been inserted.
The new variable has no missing values.
After execution of {cmd:insingap}, the dataset in memory is sorted primarily by the by-variables (if specified),
and secondarily by the {cmd:neworder()} variable (if specified).
The {cmd:replace} suboption specifies that any existing variable with the same name will be replaced.

{phang}
{cmd:gapindicator(}{help newvarname:{it:newvarname}} [, {cmd:replace}]{cmd:)} specifies the name of a new variable to be generated,
equal to 1 for the newly-inserted gap observations and 0 for all other observations.
The {cmd:replace} suboption specifies that any existing variable with the same name will be replaced.

{phang}
{cmd:rowlabel(}{it:string_varname}{cmd:)} specifies the name of an existing string variable,
used as the row labels for a table whose rows are the observations.
In the gap observations,
this string variable is set by the {cmd:grdecode()} option if specified,
or otherwise by the {cmd:growlabels()} option if specified,
or otherwise to an empty string.
The {cmd:rowlabel()} variable may not be a by-variable.

{pstd}
Note that the {cmd:neworder()}, {cmd:gapindicator()} and {cmd:rowlabel()} options may not specify the same variable names,
and may not specify the names of {help by:by-variables}.
Also, note that the {cmd:neworder()} and {cmd:gapindicator()} variables are always non-missing.

{phang}
{opth grdecode(varlist)} specifies a list of variables,
which must be a subset of the by-variables,
and which are decoded, using the {helpb msdecode} module of the {help ssc:SSC} package {helpb sdecode},
to produce values for the {cmd:rowlabel()} variable in the gap observations.

{phang}
{help msdecode:{it:msdecode_options}} are any options used by {helpb msdecode},
other than {cmd:generate()} and {cmd:replace}.
They specify the way in which the {cmd:grdecode()} variables will be decoded
to produce the gap row label values in the {cmd:rowlabel()} variable.


{phang}
{cmd:growlabels(}{it:string}{cmd:)} specifies a string value for the row label variable in the gap observations,
if these values are not set by the {cmd:grdecode()} option.
If the {cmd:rowlabel()} option is present
and the {cmd:grdecode()} and {cmd:growlabels()} options are absent,
then the {cmd:rowlabel()} variable is initialised to missing in the gap observations.

{phang}
{cmd:rstring(}{it:string_replacement_option}{cmd:)} specifies a rule for replacing the values of
string variables (other than the by-variables and row label variable) in gap observations.
If {cmd:rstring()} is not set,
then these variables will be set to a missing value (an empty string) in the gap observations.
{cmd:rstring()} can be set to
{cmd:order}, {cmd:name}, {cmd:type}, {cmd:format}, {cmd:varlab}, {cmd:char} {help char:{it:characteristic_name}},
{cmd:label}, or {cmd:labname}.
The options {cmd:order}, {cmd:name}, {cmd:type}, {cmd:format}, {cmd:varlab} and {cmd:char} {help char:{it:characteristic_name}}
imply that the value of each string variable, in the gap observations,
will be set to the order of the variable in the existing dataset,
the {help type:storage type} of the variable,
the {help format:display format} of the variable,
the {help label:variable label} of the variable,
or the {help char:ccharacteristic} of the variable with the name {help char:{it:characteristic_name}},
respectively.
The option {cmd:label} is a synonym for {cmd:varlab}.
The option {cmd:labname} specifies that the value of each string variable, in the gap observations,
will be set to its {help label:variable label}, if that label exists,
and to its name otherwise.
(Note that numeric variables that are not by-variables, {cmd:gapindicator()} variables or {cmd:neworder()} variables
are always set to the numeric missing value {cmd:.} in gap observations.)
The {cmd:rstring()} option allows the user to add a row of column headings to a dataset of string variables,
or to add a row of column headings to each by-group of a dataset of string variables.
Note also that numeric variables may be converted to string variables using the {helpb sdecode} package,
downloadable from {help ssc:SSC},
before using {cmd:insingap} and {helpb listtab}.
This allows the user to use the {cmd:rstring()} option,
and also to format numeric variables in ways not possible using Stata formats alone,
such as adding parentheses to confidence limits.

{phang}
{cmd:fast} is an option for programmers.
It specifies that {cmd:insingap} will do no work to ensure
that the original dataset is preserved in the event that {cmd:insingap} fails,
or if the user presses {help break:the Break key}.
If {cmd:fast} is not specified,
and {cmd:insingap} fails, or the user presses {help break:the Break key},
then the original existing dataset is preserved, with no additional gap observations.


{title:Remarks}

{pstd}
{cmd:insingap} is typically used to convert a Stata dataset to a form with 1 observation per table row
(including gap rows), or 1 observation per graph axis label (including gap axis labels).
The user can then list the dataset as a TeX, LaTeX, HTML or Microsoft Word table,
using the {helpb listtab} package (downloadable from {help ssc:SSC}).
Alternatively, for immediate impact, the user can use the {helpb sencode} package
(downloadable from {help ssc:SSC}) to encode the row labels to a numeric variable,
and then plot this numeric variable against other variables using {help graph:Stata graphics programs}.
For instance, a user might use {helpb eclplot} (downloadable from SSC)
to produce horizontal confidence interval plots, with the row labels on the vertical axis.
It is usually advisable for the user to type {helpb preserve} before a sequence of commands including
{cmd:insingap}, and to type {helpb restore} after a sequence of commands using {cmd:insingap},
because {cmd:insingap} modifies the dataset by adding new observations.
It is usually also advisable for the user to place the whole sequence of commands in a {help do:do-file},
and to execute this {help do:do-file},
rather than to type the sequence of commands one by one at the terminal.

{pstd}
The {helpb listtab} package is described in {help insingap##references:Newson (2012)}.
It inputs a list of variables in a Stata dataset,
and outputs a text table, in a file or on the screen,
containing these variables as columns and the observations as rows,
and formatted using a row style.
This row style may correspond to table rows in plain TeX, LaTeX, HTML, XML, or RTF tables,
or to rows of tab-delimited, column-delimited or ampersand-delimited generic text spreadsheets,
or to rows in other styles that may be invented in future.
The row style is defined using a row-beginning string, a row-end string,
and a between-column delimiter string.
{helpb listtab} is a successor to the {helpb listtex} package,
described in {help insingap##references:Newson (2006), Newson (2004) and Newson (2003)}.
The main change introduced in {helpb listtab} is that empty delimiter strings are now allowed.
Users of {help version:Stata versions} 10 and above
are advised to use {helpb listtab} in preference to {helpb listtex},
although both packages are still downloadable from SSC.


{title:Examples}

{pstd}
The following example inputs the {cmd:auto} dataset,
adds a gap observation to the start of each car origin group
defined by the variable {cmd:foreign},
and describes and lists the new dataset.
Note that changes to the dataset are made
between a {helpb preserve} statement and a {helpb restore} statement.
It is usually a good idea to do this,
if the user wants to restore the original dataset after the listing and/or plotting and/or tabulation has been done.

{p 8 16}{cmd:. sysuse auto, clear}{p_end}
{p 8 16}{cmd:. describe}{p_end}
{p 8 16}{cmd:. preserve}{p_end}
{p 8 16}{cmd:. insingap foreign, grdecode(foreign) suffix(" cars:") row(make) neworder(rowseq) gapind(gapstat)}{p_end}
{p 8 16}{cmd:. describe}{p_end}
{p 8 16}{cmd:. list make mpg weight rowseq gapstat, sepby(foreign)}{p_end}
{p 8 16}{cmd:. restore}{p_end}

{pstd}
The following example inputs the {cmd:auto} dataset and keeps every 8th model.
It then adds a gap observation to the start of each car origin group,
uses the {help ssc:SSC} package {helpb sencode}
to encode the row label variable {cmd:make} to a numeric variable {cmd:make2}
(numbered in order of appearance),
lists the variable labels for {cmd:make2},
and plots the weights of US and non-US cars.
Note that the gap observations are labelled in bold type, using {help smcl:SMCL}.
This is done using the {cmd:prefix()} and {cmd:suffix()} options,
which are two of the {help msdecode:{it:msdecode_options}} that {cmd:insingap} inherits from {helpb msdecode},
to define value labels for {cmd:make2} containing {help smcl:SMCL}.
To find more about the use of {help smcl:SMCL} in graph text, see {help graph_text:help for {it:graph_text}}.

{p 8 16}{cmd:. sysuse auto, clear}{p_end}
{p 8 16}{cmd:. preserve}{p_end}
{p 8 16}{cmd:. keep if mod(_n,8)==0}{p_end}
{p 8 16}{cmd:. describe}{p_end}
{p 8 16}{cmd:. insingap foreign, grd(foreign) pref("{c -(}bf:") suff(" cars:{c )-}") row(make) newo(rowseq)}{p_end}
{p 8 16}{cmd:. describe}{p_end}
{p 8 16}{cmd:. list make weight rowseq, sepby(foreign)}{p_end}
{p 8 16}{cmd:. sencode make, many gene(make2)}{p_end}
{p 8 16}{cmd:. label list make2}{p_end}
{p 8 16}{cmd:. twoway spike weight make2, hori ylabel(1(1)11, valuelabel angle(0)) yscale(reverse) xlabel(0(500)5000)}{p_end}
{p 8 16}{cmd:. restore}{p_end}

{pstd}
{cmd:insingap} is designed as an easy-to-use front end for the more comprehensive package {helpb ingap},
which can also be downloaded from {help ssc:SSC}.
Examples of the use of {cmd:ingap}, together with other packages, can be found in
{help ingap##references:Newson (2012), Newson (2006), Newson (2004) and Newson (2003)}.
The {cmd:insingap} package is expected to be preferred to {helpb ingap}
for most applications.


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker references}{title:References}

{phang}
Newson, R. B.  2012.
From resultssets to resultstables in Stata.
{it:The Stata Journal} 12(2): 191-213.
Download from {browse "http://www.stata-journal.com/article.html?article=st0254":{it:The Stata Journal} website}.

{phang}
Newson, R.  2006. 
Resultssets, resultsspreadsheets and resultsplots in Stata.
Presented at the {browse "http://ideas.repec.org/s/boc/dsug06.html" :4th German Stata User Meeting, Mannheim, 31 March, 2006}.

{phang}
Newson, R.  2004.
From datasets to resultssets in Stata.
Presented at the {browse "http://ideas.repec.org/s/boc/usug04.html" :10th United Kingdom Stata Users' Group Meeting, London, 29 June, 2004}.

{phang}
Newson, R.  2003.
Confidence intervals and {it:p}-values for delivery to the end user.
{it:The Stata Journal} 3(3): 245-269.
Download from {browse "http://www.stata-journal.com/article.html?article=st0043" :{it:The Stata Journal} website}


{title:Also see}

{p 0 21}
{bind: }Manual:  {manlink P preserve}, {manlink D encode}, {manlink D label}, {manlink R ssc}
{p_end}
{p 0 21}
On-line:  help for {helpb preserve}, {helpb restore}, {helpb encode}, {helpb decode}, {helpb label}, {helpb ssc}
{p_end}
{p 10 21}
help for {helpb ingap}, {helpb listtab}, {helpb listtex}, {helpb sencode}, {helpb sdecode}, {helpb msdecode} if installed
{p_end}
