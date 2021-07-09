{smcl}
{hline}
help for {cmd:xrewide} and {cmd:xrelong} {right:(Roger Newson)}
{hline}


{title:Extended versions of {cmd:reshape wide} and {cmd:reshape long}}

{p 8 21 2}
{cmd:xrewide} [ {it:stubnames} ] [ ,
{break}
{cmdab:cjv:alue}{cmd:(}{help char:{it:charname}}{cmd:)}
{opth vjv:alue(varlist)}
{cmdab:cjl:abel}{cmd:(}{help char:{it:charname}}{cmd:)}
{opth vjl:abel(varlist)}
{break}
{opt pjv:alue(string)}
{opt sjv:alue(string)}
{opt pjl:abel(string)}
{opt sjl:abel(string)}
{break}
{opt xmls:ub}
{cmdab: lxjk(}{help local:{it:local_macro_name}}{cmd:)} {cmdab: lxkj(}{help local:{it:local_macro_name}}{cmd:)}
{break}
{help reshape:{it:reshape_wide_options}} ]

{p 8 21 2}
{cmd:xrelong} [ {it:stubnames} ] [ ,
{cmdab:jla:bel}{cmd:(}{help label:{it:label_name}}{cmd:)}
{help reshape:{it:reshape_long_options}} ]

{pstd}
where {it:stubnames} is a list of stub names as input to {helpb reshape:reshape wide},
{help label:{it:label_name}} is the name of a {help label:value label},
{help reshape:{it:reshape_wide_options}} is a list of options used by {helpb reshape:reshape wide},
and {help reshape:{it:reshape_long_options}} is a list of options used by {helpb reshape:reshape long}.


{title:Description}

{pstd}
The {cmd:xrewide} package contains 2 commands, {cmd:xrewide} and {cmd:xrelong}.
The {cmd:xrewide} commmand is an extended version of {helpb reshape:reshape wide}.
It saves results in {help char:variable characteristics},
in addition to the {help char:dataset characteristics} saved by {helpb reshape}.
This is done using additional options for assigning the values and/or value labels of the {it:j}-variable
to {help char:characteristics} of the corresponding generated output variables.
These characteristics can be useful for defining column headings
if the reshaped output dataset is output to a table using the {helpb listtab} package,
which can be downloaded from {help ssc:SSC}.
The {cmd:xrelong} commmand is an extended version of {helpb reshape:reshape long},
with the option of assigning an existing {help label:value label} to the generated variable
specified by the {cmd:j()} option.
For more about the use of {cmd:xrewide} with {helpb listtab} and other packages to produce tables,
see {help xrewide##references:Newson (2012)}.


{title:Options for use with {cmd:xrewide}}

{p 4 8 2}
{cmd:cjvalue(}{help char:{it:charname}}{cmd:)} specifies thae name of a {help char:variable characteristic},
to be assigned for the generated output variables,
which will contain the corresponding values of the input variable
specified by the {cmd:j()} option of {helpb reshape:reshape wide}.

{p 4 8 2}
{opth vjvalue(varlist)} specifies a subset of the input variables to be reshaped,
whose corresponding reshaped output variables will have the {help char:characteristic}
specified by the {cmd:cjvalue()} option.
If {cmd:vjvalue()} is not specified,
then it is set to the full set of input variables to be reshaped,
and the {help char:characteristic}
specified by the {cmd:cjvalue()} option
will be assigned to all the reshaped output variables.

{p 4 8 2}
{cmd:cjlabel(}{help char:{it:charname}}{cmd:)} specifies thae name of a {help char:variable characteristic},
to be assigned for the generated output variables,
which will contain the corresponding value labels of the input variable
specified by the {cmd:j()} option of {helpb reshape:reshape wide}.

{p 4 8 2}
{opth vjlabel(varlist)} specifies a subset of the input variables to be reshaped,
whose corresponding reshaped output variables will have the {help char:characteristic}
specified by the {cmd:cjlabel()} option.
If {cmd:vjlabel()} is not specified,
then it is set to the full set of input variables to be reshaped,
and the {help char:characteristic}
specified by the {cmd:cjlabel()} option
will be assigned to all the reshaped output variables.

{p 4 8 2}
{opt pjvalue(string)} specifies a prefix,
to be added to the left of {cmd:j()} values when these are assigned
to the {help char:variable characteristic} specified by {cmd:cjvalue()}.

{p 4 8 2}
{opt sjvalue(string)} specifies a suffix,
to be added to the right of {cmd:j()} values when these are assigned
to the {help char:variable characteristic} specified by {cmd:cjvalue()}.

{p 4 8 2}
{opt pjlabel(string)} specifies a prefix,
to be added to the left of {cmd:j()} value labels when these are assigned
to the {help char:variable characteristic} specified by {cmd:cjlabel()}.

{p 4 8 2}
{opt sjlabel(string)} specifies a suffix,
to be added to the right of {cmd:j()} value labels when these are assigned
to the {help char:variable characteristic} specified by {cmd:cjlabel()}.

{p 4 8 2}
{opt xmlsub} specifies that, in the {help char:variable characteristic} specified by {cmd:cjlabel()},
the substrings {cmd:"&"}, {cmd:"<"} and {cmd:">"} will be replaced throughout
with the XML entity references {cmd:"&amp;"}, {cmd:"&lt;"} and {cmd:"&gt;"}, respectively.
This is useful if the {help char:variable characteristic} is intended for output to a table in a document in XHTML,
or in other XML-based languages.

{p 4 8 2}
{cmdab: lxjk(}{help local:{it:local_macro_name}}{cmd:)} specifies the name of a {help local:local macro},
to be assigned a list of the names of the reshaped output variables created by {cmd:xrewide},
sorted primarily in the order of the corresponding {cmd:j()} values
and secondarily in the order of the corresponding input variables specified by the {it:stubnames}.

{p 4 8 2}
{cmdab: lxkj(}{help local:{it:local_macro_name}}{cmd:)} specifies the name of a {help local:local macro},
to be assigned a list of the names of the reshaped output variables created by {cmd:xrewide},
sorted primarily in the order of the corresponding input variables specified by the {it:stubnames}
and secondarily in the order of the corresponding {cmd:j()} values.

{p 4 8 2}
{help reshape:{it:reshape_wide_options}} is a list of options used by {helpb reshape:reshape wide}.


{title:Options for use with {cmd:xrelong}}

{p 4 8 2}
{cmd:jlabel(}{help label:{it:label_name}}{cmd:)} specifies the name of an existing {help label:value label},
to be assigned to the generated variable specified by the {cmd:j()} option of {helpb reshape long}.

{p 4 8 2}
{help reshape:{it:reshape_long_options}} is a list of options used by {helpb reshape:reshape long}.


{title:Examples}

{pstd}
Set-up:

{phang2}{inp:. webuse reshape1, clear}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list}{p_end}
{phang2}{inp:. reshape long inc ue, i(id) j(year)}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. char list}{p_end}
{phang2}{inp:. list, sepby(id)}{p_end}
{phang2}{inp:. lab def yr 80 "Eighty" 81 "Eighty one" 82 "Eighty two"}{p_end}
{phang2}{inp:. lab val year yr}{p_end}
{phang2}{inp:. list, sepby(id)}{p_end}

{pstd}
Simple examples:

{phang2}{inp:. xrewide inc ue, i(id) j(year) cjlabel(varname2) vjlabel(inc) cjval(varseq2) vjval(ue)}{p_end}
{phang2}{inp:. char list}{p_end}

{phang2}{inp:. xrewide, cjlab(head1) vjlab(ue)}{p_end}
{phang2}{inp:. char list}{p_end}

{pstd}
Note that, if the user does not specify the variables to be reshaped
and/or the {cmd:i()} variable list and/or the {cmd:j()} variable,
then {cmd:xrewide} tries to find them in the latest {helpb reshape} estimation results,
which are stored as {help char:dataset characteristics}.

{pstd}
The following example demonstrates the use of {cmd:xrewide},
together with the {helpb chardef} package downloadable from {help ssc:SSC},
to assign {help char:characteristics}.
These characteristics will then be used by the {helpb listtab} package,
also downloadable from {help ssc:SSC},
to define headings in a LaTeX {cmd:tabular} environment
containing a table of the reshaped dataset,
which can be cut and pasted into a LaTeX document.
Note that characteristics assigned by {helpb chardef}
to the input variables to be reshaped
are inherited by the reshaped output variables generated by {cmd:xrewide}.

{phang2}{inp:. chardef id inc ue, char(varname) val("ID" "Income" "UE")}{p_end}
{phang2}{inp:. list, subvar}{p_end}
{phang2}{inp:. xrewide inc ue, i(id) j(year) cjlab(varname2) vjlab(inc) pjlab("\textit{") sjlab("}")}{p_end}
{phang2}{inp:. listtab_vars id *80 *81 *82, sub(char varname) rstyle(tabular) lo(h1)}{p_end}
{phang2}{inp:. listtab_vars id *80 *81 *82, sub(char varname2) rstyle(tabular) lo(h2)}{p_end}
{phang2}{inp:. listtab id *80 *81 *82, type rstyle(tabular) head("\begin{tabular}{rrrrrrr}" "`h2'" "`h1'") foot("\end{tabular}")}{p_end}

{pstd}
The following sequence demonstrates the use of {cmd:xrelong} with the {helpb varlabdef} package,
which can be downloaded from {help ssc:SSC},
and can create a {help label:value label} based on a list of variables,
with 1 value per variable, and value labels copied from the {help label:variable labels},
or from other variable attributes.

{pstd}
Set-up:

{phang2}{inp:. sysuse auto, clear}{p_end}
{phang2}{inp:. keep foreign make mpg weight price}{p_end}
{phang2}{inp:. rename mpg cmval1}{p_end}
{phang2}{inp:. rename weight cmval2}{p_end}
{phang2}{inp:. rename price cmval3}{p_end}
{phang2}{inp:. describe}{p_end}

{pstd}
Reshape from wide to long:

{phang2}{inp:. varlabdef cmlab, vlist(cmval*) from(varlab)}{p_end}
{phang2}{inp:. label list cmlab}{p_end}
{phang2}{inp:. xrelong cmval, i(foreign make) j(carmeas) jlabel(cmlab)}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list, abbr(32) sepby(foreign make)}{p_end}

{pstd}
Reshape from long to wide:

{phang2}{inp:. xrewide cmval, i(foreign make) j(carmeas) cjlab(cmeaslabel)}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list}{p_end}

{pstd}
Reshape from wide to long again:

{phang2}{inp:. varlabdef cmlab2, vlist(cmval*) from(char cmeaslabel)}{p_end}
{phang2}{inp:. label list cmlab2}{p_end}
{phang2}{inp:. xrelong cmval, i(foreign make) j(carmeas) jlabel(cmlab2)}{p_end}
{phang2}{inp:. describe}{p_end}
{phang2}{inp:. list, abbr(32) sepby(foreign make)}{p_end}


{title:Saved results}

{pstd}
{cmd:xrewide} and {cmd:xrelong} save the same {help char:dataset characteristics}
saved by {helpb reshape:reshape wide} and {helpb reshape:reshape long}, respectively.
However, the characteristic {cmd:_dta[ReS_jv]} is always set by {cmd:xrewide},
whether or not the user specifies the values explicitly in the {cmd:j()} option.
Also, the characteristic {cmd:_dta[ReS_Xij]} always contains a stub list complete with the {cmd:@} signs,
whether or not the user explicitly included these {cmd:@} signs in the input stub names.
This makes life simpler for programmers,
who might want to use these characteristics.


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


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] reshape}, {hi:[P] char}
{p_end}
{p 4 13 2}
On-line: help for {helpb reshape}, {helpb char}
{break} help for {helpb listtab}, {helpb chardef}, {helpb varlabdef} if installed
{p_end}
