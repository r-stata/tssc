{smcl}
{hline}
help for {cmd:factmerg} {right:(Roger Newson)}
{hline}


{title:Merge factors to create string variables containing values, names and labels}

{p 8 15}{cmd:factmerg} [{it:varlist}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [ {cmd:,}
 {break}
 {cmdab:fv:alue}{cmd:(}{it:newvarname} [, {help msdecode:{it:msdecode_options}}]{cmd:)}
 {break}
 {cmdab:fn:ame}{cmd:(}{it:newvarname}{cmd:)} {cmdab:fl:abel}{cmd:(}{it:newvarname}{cmd:)}
 {cmdab:mv:alue}{cmd:(}{it:string_expression}{cmd:)}
 {cmdab:mn:ame}{cmd:(}{it:string_expression}{cmd:)} {cmdab:ml:abel}{cmd:(}{it:string_expression}{cmd:)}
 {cmdab:fm:issing}{cmd:(}{it:newvarname}{cmd:)}
 {cmdab:xmls:ub}
 {cmdab:pv:alue}{cmd:(}{it:string}{cmd:)} {cmdab:pn:ame}{cmd:(}{it:string}{cmd:)} {cmdab:pl:abel}{cmd:(}{it:string}{cmd:)}
 {cmdab:sv:alue}{cmd:(}{it:string}{cmd:)} {cmdab:sn:ame}{cmd:(}{it:string}{cmd:)} {cmdab:sl:abel}{cmd:(}{it:string}{cmd:)}
 ]

{pstd}
where {help msdecode:{it:msdecode_options}} is a list of any options
used by the {helpb msdecode} module of the {helpb sdecode} package,
apart from {cmd:generate()}, {cmd:replace} and {cmd:delimiters()}.


{title:Description}

{pstd}
{cmd:factmerg} takes, as input, a list of variables (numeric or string), representing discrete factors in a model.
It creates, as output, one to three string variables, containing, in each observation,
a value, a factor name or a factor variable label, respectively,
copied from the first factor variable in the input variable list with a non-missing value for that observation.
{cmd:factmerg} requires the {help ssc:SSC} package {helpb sdecode} in order to work.


{title:Options}

{phang}
{cmd:fvalue(}{it:newvarname} [, {help msdecode:{it:msdecode_options}}]{cmd:)} specifies a string output variable,
containing, in each observation,
a value derived from the first variable in the input {it:varlist} with a non-missing value
for that observation.
These values are derived by the rules used by the {helpb msdecode} module of the {help ssc:SSC} package {help sdecode},
specified in the {help msdecode:{it:msdecode_options}}.
Values from string input variables are copied.
Values from numeric input variables are decoded.

{phang}
{cmd:fname(}{it:newvarname}{cmd:)} specifies a string output variable containing, in each observation,
the name of the input variable from which the value of the {cmd:fvalue()} variable is copied for that observation.

{phang}
{cmd:flabel(}{it:newvarname}{cmd:)} specifies a string output variable containing, in each observation,
the variable label of the input variable from which the value of the {cmd:fvalue()} variable is copied
for that observation.

{phang}
{cmd:mvalue(}{it:string_expression}{cmd:)} specifies a string expression, used to define values for the
{cmd:fvalue()} variable for observations with missing values for all variables in the input {it:varlist}.

{phang}
{cmd:mname(}{it:string_expression}{cmd:)} specifies a string expression, used to define values for the
{cmd:fname()} variable for observations with missing values for all variables in the input {it:varlist}.

{phang}
{cmd:mlabel(}{it:string_expression}{cmd:)} specifies a string expression, used to define values for the
{cmd:flabel()} variable for observations with missing values for all variables in the input {it:varlist}.

{phang}
{cmd:fmissing(}{it:newvarname}{cmd:)} specifies the name of a new binary variable to be generated,
containing missing values for observations excluded by the {helpb if} and {helpb in} qualifiers,
1 for other observations in which all the input factors are missing, and 0 for other observations
in which at least one of the input factors is nonmissing.

{phang}
{cmd:xmlsub} specifies that,
in the string output variables indicated by the options {cmd:fname()}, {cmd:flabel()} and {cmd:fvalue()},
the substrings {cmd:"&"}, {cmd:"<"} and {cmd:">"} will be replaced throughout with the XML entity references
{cmd:"&amp;"}, {cmd:"&lt;"} and {cmd:"&gt;"}, respectively.
This is useful if the string output variables are intended for output
to a table in a document in XHTML, or in other XML-based languages.

{phang}
{cmd:pvalue(}{it:string}{cmd:)} specifies a prefix to be added to the {cmd:fvalue()} output variable.

{phang}
{cmd:pname(}{it:string}{cmd:)} specifies a prefix to be added to the {cmd:fname()} output variable.

{phang}
{cmd:plabel(}{it:string}{cmd:)} specifies a prefix to be added to the {cmd:flabel()} output variable.

{phang}
{cmd:svalue(}{it:string}{cmd:)} specifies a suffix to be added to the {cmd:fvalue()} output variable.

{phang}
{cmd:sname(}{it:string}{cmd:)} specifies a suffix to be added to the {cmd:fname()} output variable.

{phang}
{cmd:slabel(}{it:string}{cmd:)} specifies a suffix to be added to the {cmd:flabel()} output variable.


{title:Remarks}

{pstd}
{cmd:factmerg} is typically used with {helpb fvregen} or {helpb factext},
which are used with {helpb parmby}, {helpb parmest} and {helpb descsave}
to create a list of factors in the output dataset (or resultsset).
The output {cmd:fvalue()} variable created by {cmd:factmerg}
may be output using {helpb outsheet} or {helpb listtab} to create a table with one row per model parameter and data
on the estimates, confidence limits and/or {it:P}-values.
Alternatively, the {cmd:fvalue()} variable may be encoded to
a numeric variable using {helpb sencode},
and then plotted, using {helpb graph} or {helpb eclplot},
to create a confidence interval plot with one axis label per model parameter.
The {cmd:fvalue}, {cmd:fname} and/or {cmd:flabel}
variables may be used in string expressions to generate labels for the rows of the table,
or for positions on the axis of a confidence interval plot, specifying the parameters in a
human-readable format.
The packages {helpb descsave}, {helpb eclplot}, {helpb fvregen}, {helpb factext}, {helpb listtab},
{helpb parmby}, {helpb parmest}, {helpb sencode} and {helpb sdecode}
can be installed from {help ssc:SSC}.

{pstd}
For more about the use of {cmd:factmerg} with these {help ssc:SSC} packages to create tables and plots,
see {help factmerg##references:Newson (2012), Newson(2010), Newson (2008), Newson (2006), Newson (2004), Newson (2003) and Newson (2002)}.


{title:Examples}

{pstd}
The following example will work with the {helpb sysuse:auto} data,
if the {help ssc:SSC} packages {helpb descsave}, {helpb parmest}
and {helpb fvregen} are installed.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. tempfile tf0}{p_end}
{p 16 20}{inp:. descsave rep78 foreign, do(`"`tf0'"',replace)}{p_end}
{p 16 20}{inp:. parmby "regress mpg i.rep78 i.foreign, robust", norestore omit format(estimate min* max* %8.2f p %8.2g)}{p_end}
{p 16 20}{inp:. fvregen, do(`"`tf0'"')}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list}{p_end}
{p 16 20}{inp:. factmerg foreign rep78, fn(faname) fl(falab) fv(faval)}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list parm rep78 foreign faname falab faval, abbr(32) noobs sepby(falab)}{p_end}

{pstd}
The following example will work with the {helpb sysuse:auto} data,
if the {help ssc:SSC} package {helpb xcontract} is installed.
It creates an output dataset (or resultsset) in the memory,
with 1 observation per value per factor,
and data on frequencies of the value for the factor,
overwriting the original dataset.
It then uses {cmd:factmerg} to create string variables,
containing, in each observation, the name, label and value of the factor.

{p 16 20}{inp:. sysuse auto, clear}{p_end}
{p 16 20}{inp:. tempfile tf1 tf2}{p_end}
{p 16 20}{inp:. xcontract foreign, nomiss saving(`"`tf1'"', replace)}{p_end}
{p 16 20}{inp:. xcontract rep78, nomiss saving(`"`tf2'"', replace)}{p_end}
{p 16 20}{inp:. clear}{p_end}
{p 16 20}{inp:. append using `"`tf1'"' `"`tf2'"'}{p_end}
{p 16 20}{inp:. sort foreign rep78}{p_end}
{p 16 20}{inp:. order foreign rep78}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list}{p_end}
{p 16 20}{inp:. factmerg foreign rep78, fname(myfaname) flab(myfalab) fval(myfaval)}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list myfaname myfalab myfaval _freq _percent, abbr(32) sepby(myfaname)}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker references}{title:References}

{phang}
Newson, R. B.  2012.
From resultssets to resultstables in Stata.
{it:The Stata Journal} 12(2): 191-213.
Download from {browse "http://www.stata-journal.com/article.html?article=st0254":{it:The Stata Journal} website}.

{phang}
Newson, R. B.  2010.  Post-{cmd:parmest} peripherals: {cmd:fvregen}, {cmd:invcise}, and {cmd:qqvalue}.
Presented at {browse "http://ideas.repec.org/s/boc/usug10.html" :the 16th United Kingdom Stata Users' Group Meeting, London, 9-10 September, 2010}.

{phang}
Newson, R. B.  2008.  {cmd:parmest} and extensions.
Presented at {browse "http://ideas.repec.org/s/boc/usug08.html" :the 14th United Kingdom Stata Users' Group Meeting, London, 8-9 September, 2008}.

{phang}
Newson, R.  2006.  Resultssets, resultsspreadsheets, and resultsplots in Stata.
Presented at {browse "http://ideas.repec.org/s/boc/dsug06.html" :the 4th German Stata Users' Group Meeting, Mannheim, 31 March, 2006}.

{phang}
Newson, R.  2004.  From datasets to resultssets in Stata.
Presented at {browse "http://ideas.repec.org/s/boc/usug04.html" :the 10th United Kingdom Stata Users' Group Meeting, London, 29-30 June, 2004}.

{phang}
Newson, R.  2003.  Confidence intervals and {it:p}-values for delivery to the end user.
{it:The Stata Journal} 3(3): 245-269.

{phang}
Newson, R.  2002.  Creating plots and tables of estimation results using {cmd:parmest} and friends.
Presented at {browse "http://ideas.repec.org/s/boc/usug02.html" :the 8th United Kingdom Stata Users' Group Meeting, 20-21 May, 2002}.


{title:Also see}

{p 0 10}
On-line:   help for {helpb describe}, {helpb list}, {helpb sort}, {helpb order}
 {break}   help for {helpb descsave}, {helpb eclplot}, {helpb factext}, {helpb fvregen}, {helpb listtab}, {helpb parmby}, {helpb parmest}, {helpb sdecode}, {helpb sencode}, {helpb xcontract} if installed
{p_end}
