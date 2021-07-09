{smcl}
{hline}
help for {cmd:bmjcip}{right:(Roger Newson)}
{hline}

{title:Format confidence intervals and {it:P}-values for medical journals}

{p 8 21 2}
{cmd:bmjcip} {varlist} {ifin}
[ , {cmdab:cf:ormat(}{it:%fmt}{cmd:)} {cmdab:xmls:ub} {cmdab:es:ub(}{it:esubstitution_rule}{cmd:)} {cmdab:elz:ero}
{cmdab:sta:rvar(}{varname}{cmd:)}
{cmdab:pr:efix(}{it:string}{cmd:)} {cmdab:su:ffix(}{it:string}{cmd:)}
{cmdab:ppr:efix(}{it:string}{cmd:)} {cmdab:psu:ffix(}{it:string}{cmd:)}
{cmdab:ref:exp(}{it:exp}{cmd:)} {cmdab:refl:abel(}{it:string}{cmd:)}
{cmdab:he:adline(}{help char:{it:characteristic_name}} [, {help bmjcip##headline_subopts:{it:headline_suboptions}}]{cmd:)} ]

{pstd}
where {varlist} is a list of 1 to 4 numeric {help varname:variable names}, of the form

{pstd}
{it:pvarname}

{pstd}
or

{pstd}
{it:estvarname} {it:pvarname}

{pstd}
or

{pstd}
{it:estvarname} {it:ciminvarname} {it:cimaxvarname}

{pstd}
or

{pstd}
{it:estvarname} {it:ciminvarname} {it:cimaxvarname} {it:pvarname}

{pstd}
or

{pstd}
{it:estvarname} {it:ciminvarname} {it:cimaxvarname} {it:pvarname} {it:qvarname}

{pstd}
and {it:estvarname} {it:ciminvarname} {it:cimaxvarname}, {it:pvarname} and {it:qvarname}
are the names of the estimate, lower confidence bound, upper confidence bound, {it:P}-value and {it:Q}-value variables,
and {it:%fmt} is a numeric {help format:display format},
and {help char:{it:characteristic_name}} is the name of a {help char:variable characteristic},
and {it:esubstitution_rule} is any one of

{p 8 21 2}
{cmd:none} | {cmd:x10} | {cmd:rtfsuper} | {cmd:texsuper} | {cmd:htmlsuper} | {cmd:smclsuper}

{pstd}
and {help bmjcip##headline_subopts:{it:headline_suboptions}} can be any subset of the {help bmjcip##headline_subopts:headline suboptions}

{p 8 21 2}
{opt e:stimate(string)} {opt l:ower(string)} {opt u:pper(string)} {opt p:value(string)} {opt q:value(string)}


{title:Description}

{pstd}
{cmd:bmjcip} reformats a list of numeric variables,
containing estimates and/or confidence limits, {it:P}-values and/or {it:Q}-values,
to string variables, containing the same values formatted for presentation in medical journals.
The new string variables replace the old numeric variables,
and have the same names, variable labels, {help char:variable characteristics}, and positions in the dataset.
{cmd:bmjcip} is usually used in output datasets (or resultssets) produced by the {helpb parmest} package,
and the reformatted string variables are usually later output using the {helpb listtab} package,
for input to Microsoft Word or other word processors.
It requires the {helpb sdecode} package in order to work.
The {helpb sdecode}, {helpb parmest} and {helpb listtab} packages can all be downloaded from {help ssc:SSC}.


{title:Options for {cmd:bmjcip}}

{phang}
{cmd:cformat(}{it:%fmt}{cmd:)} specifies a {help format:display format},
used for the estimates and confidence limits.
However, {cmd:bmjcip} also adds parentheses and commas to the confidence limits,
as expected by medical journals.
The {it:P}-value and {it:Q}-value are formatted using a separate rule,
not corresponding exactly to any Stata {help format:display format}.
(See {hi:Remarks} below.)

{phang}
{cmd:xmlsub} specifies that, in the decoded string output variables,
the substrings {cmd:"&"}, {cmd:"<"} and {cmd:">"} will be replaced throughout with the XML entity references
{cmd:"&amp;"}, {cmd:"&lt;"} and {cmd:"&gt;"}, respectively.
This is useful if the decoded string output variables are intended for output
to a table in a document in XHTML, or in other XML-based languages.
This substitution, if specified, is performed before any substitution specified by the {cmd:esub()} option.

{phang}
{cmd:esub(}{it:esubstitution_rule}{cmd:)} specifies a rule for substitution of the strings {cmd:"e-"} and {cmd:"e+"}
in decoded estimates, confidence limits, {it:P}-values and {it:Q}-values.
These strings indicate a following exponent (conventionally presented in documents as a superscript),
and are especially important for very small {it:P}-values and {it:Q}-values.
The {it:esubstitution_rule} may be
{cmd:none}, {cmd:x10} (the default), {cmd:rtfsuper}, {cmd:texsuper}, {cmd:htmlsuper}, or {cmd:smclsuper}.
The substitution rules are the same as the ones documented in the help for
the {cmd:esub()} option of {helpb sdecode}.
The {cmd:x10} substitution rule is intended for users
who intend to cut and paste the decoded confidence intervals and {it:P}-values manually into a word processor document,
and then intend to convert superscripts manually to a superscript font in the document.
The {cmd:rtfsuper} substitution rule is intended for users who intend to generate a Rich Text Format (RTF) document,
and to output the decoded confidence intervals and {it:P}-values to that document.
The {cmd:texsuper} substitution rule is intended for users
who intend to output the decoded confidence intervals, {it:P}-values and {it:Q}-values to a TeX document.
The {cmd:htmlsuper} substitution rule is intended for users
who intend to output the decoded confidence intervals, {it:P}-values and {it:Q}-values to a HTML document.
The {cmd:smclsuper} substitution rule is intended for users
who intend to output their confidence intervals to {help graph_text:Stata graphics text},
which is a branch of {help smcl:the Stata Markup and Control Language (SMCL)}.

{phang}
{cmd:elzero} specifies that leading zeros in exponents in decoded estimates, confidence limits and {it:P}-values will not be removed.
If {cmd:elzero} is not specified, then these leading zeros are removed.

{phang}
{cmd:starvar(}{varname}{cmd:)} specifies a string variable,
whose value will be appended to the decoded {it:Q}-value variable (if one exists),
or otherwise to the decoded {it:P}-value variable (if one exists),
or otherwise to the decoded upper confidence limit variable.
Usually, the {cmd:starvar()} variable contains stars or other footnote specifiers.

{phang}
{cmd:prefix(}{it:string}{cmd:)} specifies a prefix, to be added to the left of the decoded string values.

{phang}
{cmd:suffix(}{it:string}{cmd:)} specifies a suffix, to be added to the right of the decoded string values.

{phang}
{cmd:pprefix(}{it:string}{cmd:)} specifies a special prefix,
to be added to the left of the decoded string values of the {it:P}-value and {it:Q}-value variables.
If unset, {cmd:pprefix()} is set to {cmd:prefix()}.

{phang}
{cmd:psuffix(}{it:string}{cmd:)} specifies a suffix,
to be added to the right of the decoded string values of the {it:P}-value and {it:Q}-value variables.
If unset, {cmd:psuffix()} is set to {cmd:suffix()}.

{phang}
{cmd:refexp(}{it:exp}{cmd:)} specifies an expression,
which, when evaluated, should be 1 for observations corresponding to reference parameters,
and 0 for other observations.
In observations where the {cmd:refexp()} expression is true,
{cmd:bmjcip} will assign a value of the {cmd:reflabel()} string to the decoded {it:P}-value variable
(if the {varlist} has 1 or 2 variables),
or to the decoded lower confidence limit variable (if the {varlist} has 3, 4 or 5 variables).
If the {varlist} has 3, 4 or 5 variables,
then, in reference observations, the decoded lower confidence limit variable will be replaced with an empty string ({cmd:""}).
If the {varlist} has 4 or 5 variables,
then, in reference observations, the decoded {it:P}-value will be replaced with an empty string.
If the dataset in memory is an output dataset produced by the {helpb parmest} package,
and the user has specified the {cmd:omit} option for {helpb parmest},
then the user may specify the option {cmd:reflabel(omit)},
and the reference observations will then be those for which the variable {cmd:omit} is equal to 1,
implying that the corresponding parameter is omitted.

{phang}
{cmd:reflabel(}{it:string}{cmd:)} specifies a label for reference observations,
defined using the {cmd:reflabel()} expression.
If {cmd:refexp()} has been specified, and {cmd:reflabel()} has not,
then {cmd:reflabel()} defaults to {cmd:"(ref)"}.
If {cmd:refexp()} is not specified,
then {cmd:reflabel()} is ignored.

{phang}
{cmd:headline(}{help char:{it:characteristic_name}} [, {help bmjcip##headline_subopts:{it:headline_suboptions}}]{cmd:)}
specifies the name of a {help char:variable characteristic} to be set by {cmd:bmjcip}
for each of the variables to be reformatted.
This characteristic will contain, for each variable, a headline string, which might be used when listing the variables.
For instance, if the {help char:{it:characteristic_name}} is {cmd:varname},
then {cmd:bmjcip} sets the characteristic {it:var}{cmd:[varname]} for each of the variables reformatted.
If the user then lists the variables using the {helpb list} command with the {cmd:subvarname} option,
then the variables are listed using the characteristic {it:var}{cmd:[varname]}
in the headline row above each variable,
instead of the variable name.
The character value set by {cmd:headline()} for each of the reformatted variables has a default,
which is typically {cmd:"Estimate"}, {cmd:"(95%"}, {cmd:"CI)"}, {cmd:"P"} and {cmd:"Q"}
for the variables
{it:estvarname}, {it:ciminvarname}, {it:cimaxvarname}, {it:pvarname} and {it:qvarname}, respectively.
However, the user can reset the headline strings,
using the {help bmjcip##headline_subopts:{it:headline_suboptions}}.


{marker headline_subopts}{...}
{title:Suboptions for the {cmd:headline()} option of {cmd:bmjcip}}

{phang}
{opt estimate(string)} specifies a headline string for the variable {it:estvarname},
containing the estimates.
In default, it is set to {cmd:estimate("Estimate")}.
The user may prefer to specify {cmd:estimate("OR")} if the estimates are odds ratios,
or {cmd:estimate("GM")} if the estimates are geometric means.

{phang}
{opt lower(string)} specifies the headline string for the variable {it:ciminvarname},
containing the lower confidence limits.
In default, it is set to {cmd:lower("(}{it:level}{cmd:%")}, where {it:level} is a numeric percentage confidence level.
The value of {it:level} is taken from the {help char:variable characteristic} {it:ciminvarname}{cmd:[level]},
if that characteristic has a numeric value,
and is otherwise taken from the {help creturn:system setting} {cmd:c(level)}, set by {helpb set level}.
For instance, if {it:level} is {cmd:95},
then the {cmd:lower()} option defaults to {cmd:lower("(95%")}.
If {it:ciminvarname} was created as a lower confidence limit by any module of the {helpb parmest} package,
then the {help char:variable characteristic} {it:ciminvarname}{cmd:[level]}
will normally be set correctly.
However, in the general case, it is the responsibility of the user to ensure that this confidence level is the correct confidence level
used for calculating the variables {it:ciminvarname} and {it:cimaxvarname}.

{phang}
{opt upper(string)} specifies the headline string for the variable {it:cimaxvarname},
containing the upper confidence limits.
The default is {cmd:upper("CI)")}.

{phang}
{opt pvalue(string)} specifies the headline string for the variable {it:pvarname},
containing the {it:P}-values.
The default is {cmd:pvalue("P")}.

{phang}
{opt qvalue(string)} specifies the headline string for the variable {it:qvarname},
containing the {it:Q}-values.
The default is {cmd:pvalue("Q")}.


{title:Remarks}

{pstd}
Guidelines for presentation of confidence intervals in medical journals are given in {help bmjcip##references:Altman {it:et al.} (2000)}.
The name {cmd:bmjcip} was chosen because these guidelines were written originally
for the British Medical Journal (BMJ) group of journals.

{pstd}
A {it:Q}-value is a {it:P}-value adjusted for multiple comparisons.
In Stata, they may be generated using the {helpb qqvalue} package,
downloadable from {help ssc:SSC}.

{pstd}
The presentation of {it:P}-values (including {it:Q}-values) is still subject to some controversy, even among statisticians.
However, {cmd:bmjcip} initially converts a {it:P}-value of 1 to {cmd:1.0},
a {it:P}-value less than 1 and no less than .00001 to a left-justified decimal number
with no zero before the decimal point,
a {it:P}-value below 0.00001 and greater than 0 to the format {it:x.y}{cmd:e-}{it:z}
(where {it:x} and {it:y} are digits and {it:z} is an integer),
and a {it:P}-value of 0 to {cmd:0}.
The string {cmd:e-} may then be converted in a way specified by the {cmd:esub()} option,
allowing very small {it:P}-values to be displayed with the exponent as a superscript.
Note that, if the {it:P}-values are output by {helpb listtab} and converted manually into Microsoft Word tables,
then the user must convert each "-{it:z}" to a superscript manually.

{pstd}
If the user wishes to keep the original numeric variables,
then the user may use {helpb clonevar} to make new numeric variables that are copies of the original variables,
and then reformat these to string variables using {cmd:bmjcip}.

{pstd}
For more about the use of {cmd:bmjcip} with {helpb listtab} and other packages to create tables,
see {help bmjcip##references:Newson (2012)}.


{title:Examples}

{pstd}
The following lines of code input the {help dta_examples:auto dataset},
and use {helpb regress} and {helpb parmest} to replace it with an output dataset (or resultsset),
with one observation for each parameter of a model predicting car weight from repair record,
and data on parameter estimates, confidence limits and {it:P}-values.
This resultsset is described and listed.

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. regress weight i.rep78}{p_end}
{p 8 12 2}{cmd:. parmest, norestore omit format(estimate min* max* %8.2f)}{p_end}
{p 8 12 2}{cmd:. describe}{p_end}
{p 8 12 2}{cmd:. list}{p_end}


{pstd}
The following examples demonstrate {cmd:bmjcip} with the dataset created above.
Note that these examples must begin with {helpb preserve} and end with {helpb restore}
in order to restore the original resultsset for the next example.

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. bmjcip p}{p_end}
{p 8 12 2}{cmd:. list parm p}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. bmjcip estimate p}{p_end}
{p 8 12 2}{cmd:. list parm estimate p}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. bmjcip estimate min95 max95 p}{p_end}
{p 8 12 2}{cmd:. list parm estimate min95 max95 p}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. bmjcip estimate min95 max95 p, cformat(%10.3f) refexp(omit)}{p_end}
{p 8 12 2}{cmd:. list parm estimate min95 max95 p}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. bmjcip estimate min95 max95, cf(%10.1f) refexp(omit) reflabel("(Ref.)")}{p_end}
{p 8 12 2}{cmd:. list parm estimate min95 max95}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}

{pstd}
The following examples demonstrate the use of the {cmd:headline()} option
to reset the {help char:characteristic} {it:var}{cmd:[varname]},
used by the {cmd:subvarname} option of the {helpb list} command.

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. bmjcip estimate min95 max95 p, head(varname)}{p_end}
{p 8 12 2}{cmd:. list parm estimate min95 max95 p, abbr(32) subvar}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. bmjcip estimate min95 max95 p, head(varname, e("Coef.") l("[95%") u("CI]") p("P>|t|"))}{p_end}
{p 8 12 2}{cmd:. list parm estimate min95 max95 p, abbr(32) subvar}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}

{pstd}
The following example demonstrates the use of the {cmd:headline()} option
with the {helpb listtab} package.
The {helpb listtab:listtab_vars} module is used to create a {help macro:local macro} {cmd:myhead1},
containing a headline row for an HTML table.
The {helpb listtab} module types the table, complete with its headline row.
The whole table can then be cut and pasted from the Stata results window into Microsoft Word or another word processor,
and then converted from a text form to an HTML table.

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. bmjcip estimate min95 max95 p, esub(htmlsuper) head(varname)}{p_end}
{p 8 12 2}{cmd:. listtab_vars parm estimate min95 max95 p, rstyle(htmlhead) substitute(char varname) local(myhead1)}{p_end}
{p 8 12 2}{cmd:. listtab parm estimate min95 max95 p, rstyle(html) type headlines("<table>" "`myhead1'") footlines("</table>")}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}

{pstd}
The following example demonstrates the standard 20th century practice, in medical journals,
of reporting {it:P}-values below a certain minimum level simply as being less than that minimum level,
which, in this example, is .0005.
This practice removes the problem of formatting very small {it:P}-values,
which would otherwise have to be presented with exponents.
However, in the early 21st century,
biochips with a million (or more) assays became available,
allowing medical scientists to measure the associations of all these assays with a disease.
On average, 500 of these associations will have sample {it:P}-values less than 00005,
even if all associations are null in the population at large.
This implies that a {it:P}-value less than 00005 is not necessarily "as good as zero".
There is still no consensus on the best solution to this problem,
even among medical statisticians.
Note that the {cmd:xmlsub} option is used here,
so that the label {cmd:"<.0005"} is reformatted to {cmd:"&lt;.0005"},
allowing the decoded string variables to be included in a table in an XHTML document.

{p 8 12 2}{cmd:. preserve}{p_end}
{p 8 12 2}{cmd:. replace p=0 if p<.0005}{p_end}
{p 8 12 2}{cmd:. lab def _p 0 "<.0005"}{p_end}
{p 8 12 2}{cmd:. lab val p _p}{p_end}
{p 8 12 2}{cmd:. bmjcip estimate min95 max95 p, xmlsub}{p_end}
{p 8 12 2}{cmd:. describe}{p_end}
{p 8 12 2}{cmd:. list parm estimate min95 max95 p}{p_end}
{p 8 12 2}{cmd:. restore}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker references}{title:References}

{phang}
Altman, D. G., D. Machin, T. N Bryant and M. J Gardner.
2000.
{it:Statistics with Confidence}.
2nd ed.
London, UK: British Medical Journal.

{phang}
Newson, R. B.  2012.
From resultssets to resultstables in Stata.
{it:The Stata Journal} 12(2): 191-213.
Download from {browse "http://www.stata-journal.com/article.html?article=st0254":{it:The Stata Journal} website}.


{title:Also see}

{psee}
Manual:  {manlink D destring}, {manlink D clonevar}, {manlink D format}, {manlink P char}
{p_end}

{psee}
{space 2}Help:  {manhelp tostring D}, {manhelp destring D}, {manhelp clonevar D}, {manhelp format D}, {manhelp char P}{break}
{helpb sdecode}, {helpb parmest}, {helpb listtab}, {helpb qqvalue} if installed
{p_end}
