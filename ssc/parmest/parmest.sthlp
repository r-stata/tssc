{smcl}
{hline}
help for {cmd:parmest} and {cmd:parmby}{right:(Roger Newson)}
{hline}


{title:Convert estimation results to a dataset with one observation per parameter}

{pstd}
The {cmd:parmest} package includes 4 modules,
which produce datasets with one observation for each of a set of estimated parameters,
and variables containing estimates, confidence limits, {it:P}-values and other parameter attributes.
The modules are as follows:

{p2colset 4 16 18 2}{...}
{p2col:Module}Description{p_end}
{p2line}
{p2col:{cmd:parmest}}Create dataset from most recent estimation results{p_end}
{p2col:{cmd:parmby}}Create dataset by calling an estimation command once for each by-group{p_end}
{p2col:{helpb parmcip}}Confidence limits and {it:P}-values from estimates and standard errors{p_end}
{p2col:{helpb metaparm}}Confidence limits and {it:P}-values for linear combinations of independent parameters
(as in a meta-analysis)
{p_end}
{p2line}
{p2colreset}

{pstd}
The modules {cmd:parmest} and {cmd:parmby} are documented here.
See {helpb parmcip} and {helpb metaparm} for the other modules.


{title:Syntax for {cmd:parmest} and {cmd:parmby}}

{p 8 21 2}
{cmd:parmest} {cmd:,} [ {it:{help parmest##parmest_outdest_opts:parmest_outdest_opts}}
{it:{help parmest##parmest_ci_opts:parmest_ci_opts}}
{it:{help parmest##parmest_varadd_opts:parmest_varadd_opts}}
{it:{help parmest##parmest_varmod_opts:parmest_varmod_opts}}
]

{p 8 21 2}
{cmd:parmby} [{cmd:`}]{cmd:"}{it:command}{cmd:"}[{cmd:'}] {cmd:,} [ {it:parmest_opts}
{it:{help parmest##parmby_only_opts:parmby_only_opts}}
]

{pstd}
where {it:parmest_opts} are options allowed by {cmd:parmest} and {it:command} is a Stata {help estcom:estimation command}.


{title:Description}

{pstd}
{cmd:parmest} takes, as input, the most recently calculated set of {help return:estimation results},
created by the most recently executed {help est:estimation command}.
It creates, as output, a new dataset, with one observation per estimated parameter, and variables
containing parameter names, estimates, standard errors, {it:z}-test or {it:t}-test statistics,
{it:P}-values, confidence limits, and other estimation results if requested by the user.
{cmd:parmby} executes an {help est:estimation command} for each by-group specified by the by-variables,
and then creates an output dataset with one observation for each estimated parameter
in each by-group for which the command executed successfully, and all the variables in the {cmd:parmest}
output dataset, together with the by-variables.
The output dataset created by {cmd:parmby} or {cmd:parmest}
may be listed to the Stata log, or saved to a  new data frame,
or saved to a disk file, or written to the current data frame
(overwriting any pre-existing dataset).


{title:Output datasets created by {cmd:parmest} and {cmd:parmby}}

{pstd}
These output datasets (or resultssets) are described in detail in {help parmest_resultssets:{it:parmest_resultssets}}.


{title:Options for use with {cmd:parmest} and {cmd:parmby}}

{pstd}
{cmd:parmest} and {cmd:parmby} have a large number of options, which fall into the following 5 groups:

{p2colset 4 26 28 2}{...}
{p2col:Option group}Description{p_end}
{p2line}
{p2col:{it:{help parmest##parmest_outdest_opts:parmest_outdest_opts}}}Output-destination options for {cmd:parmest} and {cmd:parmby}{p_end}
{p2col:{it:{help parmest##parmest_ci_opts:parmest_ci_opts}}}Confidence-interval options for {cmd:parmest} and {cmd:parmby}{p_end}
{p2col:{it:{help parmest##parmest_varadd_opts:parmest_varadd_opts}}}Variable-adding options for {cmd:parmest} and {cmd:parmby}{p_end}
{p2col:{it:{help parmest##parmest_varmod_opts:parmest_varmod_opts}}}Variable-modifying options for {cmd:parmest} and {cmd:parmby}{p_end}
{p2col:{it:{help parmest##parmby_only_opts:parmby_only_opts}}}Options for {cmd:parmby} only{p_end}
{p2line}
{p2colreset}


{marker parmest_outdest_opts}{...}
{title:Output-destination options for {cmd:parmest} and {cmd:parmby}}

{synoptset 32}
{synopthdr}
{synoptline}
{synopt:{opt li:st(list_spec)}}List output dataset to Stata log and/or Results window{p_end}
{synopt:{cmdab:fra:me}{cmd:(}{it:framename}[,replace {cmdab:cha:nge}]{cmd:)}}Save output dataset to a data frame{p_end}
{synopt:{cmdab:sa:ving}{cmd:(}{it:filename}[{cmd:,replace}]{cmd:)}}Save output dataset to a disk file{p_end}
{synopt:{cmdab::no}{cmdab:re:store}}Write output dataset to memory{p_end}
{synopt:{opt fast}}Write output dataset to memory without precautions{p_end}
{synopt:{opt fl:ist(global_macro_name)}}Append output filename to a global macro{p_end}
{synoptline}

{pstd}
where {it:list_spec} is a specification of the form

{pstd}
[{varlist}] {ifin} [ , [{help list:{it:list_options}} ] ]

{pstd}
and {help list:{it:list_options}} is a list of options used by the {helpb list} command.

{pstd}
See {help parmest_outdest_opts:{it:parmest_outdest_opts}} for details of these options.


{marker parmest_ci_opts}{...}
{title:Confidence-interval options for {cmd:parmest} and {cmd:parmby}}

{synoptset 32}
{synopthdr}
{synoptline}
{synopt:{opt ef:orm}}Exponentiate estimates and confidence limits{p_end}
{synopt:{opt d:of(numscalar)}}Scalar degrees of freedom for calculating confidence limits{p_end}
{synopt:{cmdab:le:vel}{cmd:(}{help numlist:{it:numlist}}{cmd:)}}Confidence level(s) for calculating confidence limits{p_end}
{synopt:{opt cln:umber(numbering_rule)}}Numbering rule for naming confidence limit variables{p_end}
{synopt:{cmdab:mcomp:are}{cmd:(}{it:method}{cmd:)}}Multiple-comparison method{p_end}
{synopt:{cmdab:mcomc:i}{cmd:(}{it:method}{cmd:)}}Multiple-comparison method for confidence limits only{p_end}
{synopt:{opt bmat:rix(matrix_expression)}}Matrix from which parameter estimates will be extracted{p_end}
{synopt:{opt vmat:rix(matrix_expression)}}Matrix from which parameter variances will be extracted{p_end}
{synopt:{opt dfmat:rix(matrix_expression)}}Matrix from which parameter degrees of freedom will be extracted{p_end}
{synoptline}

{pstd}
where {it:numscalar} is

{pstd}
# | {help scalar:{it:scalar_name}}

{pstd}
and {it:numbering_rule} is

{pstd}
{cmd:level} | {cmd:rank}

{pstd}
and {it:method} is

{pstd}
{cmdab:noadj:ust} | {cmdab:bonf:erroni} | {cmdab:sid:ak}

{pstd}
See {help parmest_ci_opts:{it:parmest_ci_opts}} for details of these options.


{marker parmest_varadd_opts}{...}
{title:Variable-adding options for {cmd:parmest} and {cmd:parmby}}

{synoptset 16}
{synopthdr}
{synoptline}
{synopt:{opt mset:ype}}Variable containing parameter matrix stripe element type{p_end}
{synopt:{opt om:it}}Variable containing parameter omit status{p_end}
{synopt:{opt emp:ty}}Variable containing parameter empty cell status{p_end}
{synopt:{opt l:abel}}Variable containing {it:X}-variable labels{p_end}
{synopt:{opt yl:abel}}Variable containing {it:Y}-variable labels{p_end}
{synopt:{opt idn:um(#)}}Numeric dataset ID variable{p_end}
{synopt:{opt ids:tr(string)}}String dataset ID variable{p_end}
{synopt:{cmdab:sta:rs}{cmd:(}{help numlist:{it:numlist}})}Variable containing stars for the {it:P}-value{p_end}
{synopt:{opt em:ac(name_list)}}Variables containing macro estimation results{p_end}
{synopt:{opt es:cal(name_list)}}Variables containing scalar estimation results{p_end}
{synopt:{opt er:ows(name_list)}}Variables containing rows of matrix estimation results{p_end}
{synopt:{opt ec:ols(name_list)}}Variables containing columns of matrix estimation results{p_end}
{synopt:{opt ev:ec(name_list)}}Variables containing vectors extracted from matrix estimation results{p_end}
{synoptline}

{pstd}
where {it:name_list} is a list of names of Stata {help estimates:estimation results}.

{pstd}
See {help parmest_varadd_opts:{it:parmest_varadd_opts}} for details of these options.


{marker parmest_varmod_opts}{...}
{title:Variable-modifying options for {cmd:parmest} and {cmd:parmby}}

{synoptset 24}
{synopthdr}
{synoptline}
{synopt:{opt ren:ame(renaming_list)}}Rename variables in the output dataset{p_end}
{synopt:{opt fo:rmat(formatting_list)}}Display formats for variables in the output dataset{p_end}
{synopt:{opt float}}Set storage type of numeric variables to {cmd:float} or lower precision{p_end}
{synopt:{cmdab::no}{cmdab:dou:ble}}Alternative option for specifying {cmd:float}{p_end}
{synopt:{cmdab::no}{cmdab:ze:rop}}Reset zero {it:P}-values to smallest positive double-precision number{p_end}
{synopt:{opt nu:llvalue(#)}}Value of estimated parameters under null hypotheses{p_end}
{synoptline}

{pstd}
where {it:renaming_list} is a list of {help varname: variable names} of form

{pstd}
{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}

{pstd}
and {it:formatting_list} is a list of form

{pstd}
{it:{help varlist:varlist_1} {help format:format_1} ... {help varlist:varlist_n} {help format:format_n}}

{pstd}
See {help parmest_varmod_opts:{it:parmest_varmod_opts}} for details of these options.


{marker parmby_only_opts}{...}
{title:Options for {cmd:parmby} only}

{synoptset 24}
{synopthdr}
{synoptline}
{synopt:{cmd:by(}{varlist}{cmd:)}}Specify variables defining by-groups{p_end}
{synopt:{opt com:mand}}Add a variable containing the command called{p_end}
{synoptline}

{pstd}
See {help parmby_only_opts:{it:parmby_only_opts}} for details of these options.


{title:Remarks}

{pstd}
More information about the use of {cmd:parmest} and {cmd:parmby}
can be found in Newson (2010), Newson (2008), Newson (2006), Newson (2004), Newson (2003) and Newson (2002).
{cmd:parmby} is similar to {helpb statsby}, but it creates a data
set with one observation per parameter per by-group, instead of a dataset with one
observation per by-group.
Also, in default, {cmd:parmby} outputs the estimation output
to the log, although the user can use {helpb quietly} to suppress this.
{cmd:parmby} is a "quasi-byable" front end for {cmd:parmest}.
{cmd:parmest} is frequently used when the user wishes simply to use the {cmd:list()} option to list the estimation
output with user-specified formats or parameter labels, so that the results for each parameter are presented
to a number of decimal places and/or significant figures specified by the user, and may also be labelled
with the variable {hi:label}, corresponding to the parameter.
The {cmd:parmest} command is therefore
used as an alternative version of {helpb est_table:estimates table},
with the added power to calculate confidence limits.
With either {cmd:parmby} or {cmd:parmest},
the user must specify at least one of the four {help parmest_outdest_opts:output-destination options}
{cmd:list()}, {cmd:saving()}, {cmd:norestore} and/or {cmd:fast}.
These options specify whether the output dataset is listed to the Stata log, saved to a disk file,
or written to the memory (overwriting any pre-existing dataset).
{cmd:parmby} works by calling {cmd:parmest}, which in turn works by calling {helpb parmcip}.


{title:Examples}

{pstd}
The following examples use the {cmd:list()} option to list a subset of the output dataset to the Stata log.
After these examples are executed, there is no new dataset either in the memory or on disk.

{p 16 20}{inp:. regr price mpg weight,robust}{p_end}
{p 16 20}{inp:. parmest,format(estimate min95 max95 %8.2f p %8.1e) list(,)}{p_end}

{p 16 20}{inp:. glm mpg foreign,family(gamma) link(power -1)}{p_end}
{p 16 20}{inp:. parmest, label format(estimate min95 max95 p %8.2f p %8.1e) list(parm label estimate min95 max95 p,clean noobs)}{p_end}

{p 16 20}{inp:. regress price mpg weight foreign displacement headroom,robust}{p_end}
{p 16 20}{inp:. parmest,label format(p %8.1e) stars(0.05 0.01 0.001 0.0001) list(parm label estimate min95 max95 p stars,clean noobs)}{p_end}

{p 16 20}{inp:. parmby "qui logit foreign mpg, or", label eform for(estimate min95 max95 %8.2f p %8.1e) li(parm label estimate min95 max95 p)}{p_end}

{p 16 20}{inp:. parmby "qui logit foreign mpg, or", level(95 97.5) cln(rank) label eform for(estimate min* max* %8.2f p %8.1e) li(parm label estimate min2 min1 max1 max2 p,clean noobs)}{p_end}

{p 16 20}{inp:. parmby "regress weight i.foreign#i.rep78", omit empty list(if !empty, abbr(32))}{p_end}

{pstd}
The following examples use the {cmd:norestore} option to create an output dataset in the memory,
overwriting any pre-existing dataset.

{p 16 20}{inp:. parmby "regr mpg weight,robust",by(foreign) label command norestore}{p_end}

{p 16 20}{inp:. gene gpm=1/mpg}{p_end}
{p 16 20}{inp:. rename foreign t}{p_end}
{p 16 20}{inp:. parmby "regr gpm weight",by(t) label rename(t tstat p pvalue) norestore}{p_end}

{p 16 20}{inp:. gene byte pw1=1}{p_end}
{p 16 20}{inp:. svyset [pwei=pw1],clear}{p_end}
{p 16 20}{inp:. parmby "svy :mean mpg weight price, over(foreign)", norestore ylabel ev(_N _N_subp) es(N)}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list eq ylabel parm ev_* es_* estimate min95 max95}{p_end}


{pstd}
The following examples use the {cmd:saving()} option to create an output dataset in a disk file.

{p 16 20}{inp:. parmby "logit foreign mpg, or", label eform saving(parms1.dta)}{p_end}

{p 16 20}{inp:. parmby "regr mpg weight displ,robust",by(foreign) label saving(myparms,replace)}{p_end}

{pstd}
The following example demonstrates the use of {cmd:parmby} with multiple regression commands,
saving the results in multiple temporary datasets. These datasets are then concatenated,
using {helpb append}, to form a single dataset in memory, with one observation
for each parameter in each regression.
This example uses the options {cmd:idnum()}
and {cmd:idstr()} to create analysis identifier variables, which contain information identifying
the regression model for each parameter.

{p 16 20}{inp:. gene gpm=1/mpg}{p_end}
{p 16 20}{inp:. tempfile tf1 tf2 tf3}{p_end}
{p 16 20}{inp:. parmby "regr gpm weight", lab saving(`"`tf1'"',replace) idn(1) ids(Unadjusted)}{p_end}
{p 16 20}{inp:. parmby "regr gpm foreign", lab saving(`"`tf2'"',replace) idn(2) ids(Unadjusted)}{p_end}
{p 16 20}{inp:. parmby "regr gpm weight foreign", lab saving(`"`tf3'"',replace) idn(3) ids(Adjusted)}{p_end}
{p 16 20}{inp:. drop _all}{p_end}
{p 16 20}{inp:. append using `"`tf1'"' `"`tf2'"' `"`tf3'"'}{p_end}
{p 16 20}{inp:. list idnum idstr parm estimate min95 max95 p,noobs nodis}{p_end}

{pstd}
The following advanced example demonstrates the use of the {cmd:flist()} option with {helpb append}.
{cmd:parmby} is used to carry out multiple regression analyses,
storing the results in temporary files, whose names are stored by the {cmd:flist()} option in a
global macro {hi:tflist}.
The files are then concatenated using {helpb append} to create a single
long dataset in memory, with one observation for each parameter of each regression model.
For each parameter, the regression model for that parameter is identified by the string variable
{hi:command} and the numeric analysis identifier variable {hi:idnum}. The dataset is
sorted, described and listed.

{p 16 20}{inp:. global tflist ""}{p_end}
{p 16 20}{inp:. global modseq=0}{p_end}
{p 16 20}{inp:. foreach X of var headroom trunk weight length turn displacement gear_ratio {c -(}}{p_end}
{p 16 20}{inp:. global modseq=$modseq+1}{p_end}
{p 16 20}{inp:. tempfile tfcur}{p_end}
{p 16 20}{inp:. parmby "regr mpg `X'",by(foreign) label command format(estimate min95 max95 %8.2f p %8.1e) idn($modseq) saving(`"`tfcur'"',replace) flist(tflist)}{p_end}
{p 16 20}{inp:. {c )-}}{p_end}
{p 16 20}{inp:. drop _all}{p_end}
{p 16 20}{inp:. append using $tflist}{p_end}
{p 16 20}{inp:. sort idnum command foreign parmseq}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. by idnum command:list foreign parm label estimate min95 max95 p,noobs}{p_end}

{pstd}
The following advanced example demonstrates the use of {cmd:parmest}
with the {helpb mi_estimate:mi estimate} command prefix.
The example is based on an example from the manual entry {manlink MI mi estimate},
using the {help q_mi:Albuquerque Home Prices dataset}.
Note that, if the estimation command is {helpb mi_estimate:mi estimate},
then, by default,
{cmd:parmest} extracts the untransformed parameter estimates, variances and degrees of freedom
from the matrix estimation results {cmd:e(b_mi)}, {cmd:e(V_mi)} and {cmd:e(df_mi)},
respectively.
To extract the transformed parameter estimates, variances and degrees of freedom,
we must specify other matrix estimation results,
using the {cmd:bmatrix()}, {cmd:vmatrix()} and {cmd:dfmatrix()} options, respectively.
We can then concatenate the two sets of parameters into a single output dataset,
using {helpb append}.

{p 16 20}{inp:. use http://www.stata-press.com/data/r11/mhouses1993s30, clear}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. mi estimate (ratio: _b[age]/_b[sqft]): regress price tax sqft age nfeatures ne custom corner}{p_end}
{p 16 20}{inp:. parmest, norestore}{p_end}
{p 16 20}{inp:. tempfile tf1}{p_end}
{p 16 20}{inp:. parmest, bmat(e(b_Q_mi)) vmat(e(V_Q_mi)) dfmat(e(df_Q_mi)) saving(`"`tf1'"', replace)}{p_end}
{p 16 20}{inp:. append using `"`tf1'"', gene(parmtype)}{p_end}
{p 16 20}{inp:. lab def parmtype 0 "Original" 1 "Transformed"}{p_end}
{p 16 20}{inp:. lab val parmtype parmtype}{p_end}
{p 16 20}{inp:. lab var parmtype "Parameter type"}{p_end}
{p 16 20}{inp:. describe}{p_end}
{p 16 20}{inp:. list, sepby(parmtype)}{p_end}

{pstd}
More examples can be found in Newson (2010), Newson (2008), Newson (2006), Newson (2004), Newson (2003) and Newson (2002).


{title:Saved results}

{pstd}
{cmd:parmest} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(dofpres)}}1 if {it:t}-distribution used, 0 otherwise{p_end}
{synopt:{cmd:r(dof)}}scalar degrees of freedom used{p_end}
{synopt:{cmd:r(nparm)}}number of parameters{p_end}
{synopt:{cmd:r(nullvalue)}}value of parameters under null hypotheses{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(level)}}confidence level(s){p_end}
{synopt:{cmd:r(eform)}}{cmd:eform} if specified{p_end}
{synopt:{cmd:r(bmatrix)}}{cmd:bmatrix()} expression used{p_end}
{synopt:{cmd:r(vmatrix)}}{cmd:vmatrix()} expression used{p_end}
{synopt:{cmd:r(dfmatrix)}}{cmd:dfmatrix()} expression used{p_end}
{p2colreset}{...}

{pstd}
Note that {cmd:r(dof)} is set to zero if the standard Normal distribution was used,
set to a missing value if the degrees of freedom used vary between parameters,
and set to a common value if the degrees of freedom used are the same for all parameters.
Note also that {cmd:r(dfmatrix)} is always missing if the user sets the {cmd:dof()} option,
because any {cmd:dfmatrix()} option set by the user is then ignored.

{pstd}
{cmd:parmby} saves the above items in {cmd:r()}
from the last execution of {cmd:parmest} for the last by-group,
and also the following:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(command)}}estimation command{p_end}
{synopt:{cmd:r(by)}}list of by-variables{p_end}
{p2colreset}{...}


{title:Acknowledgments}

{pstd}
I would like to thank Nicholas J. Cox of Durham University, UK,
for coining the word resultsset to describe an output dataset created by a Stata program such as {cmd:parmest}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

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
Download from
{browse "http://www.stata-journal.com/article.html?article=st0043":the {it:Stata Journal} website}.

{phang}
Newson, R.  2002.  Creating plots and tables of estimation results using {cmd:parmest} and friends.
Presented at {browse "http://ideas.repec.org/s/boc/usug02.html" :the 8th United Kingdom Stata Users' Group Meeting, 20-21 May, 2002}.


{title:Also see}

{psee}
Manual:  {findalias frestimate},{break}
{findalias frestadv},{break}
{manlink I estimation commands},{break}
{manlink D append}, {manlink D statsby}, {bf:{mansection R estimatestable:[R] estimates table}}
{p_end}

{psee}
{space 2}Help:  {manhelp estcom U:20 Estimation and postestimation commands},{break}
{manhelp estimation_commands I:estimation commands},{break}
{manhelp append D}, {manhelp statsby D}, {manhelp estimates_table R:estimates table}{break}
{helpb parmcip}, {helpb metaparm},
{help parmest_outdest_opts:{it:parmest_outdest_opts}}, {it:{help parmest_ci_opts}},
{help parmest_varadd_opts:{it:parmest_varadd_opts}}, {help parmest_varmod_opts:{it:parmest_varmod_opts}},
{help parmby_only_opts:{it:parmby_only_opts}}, {help parmest_resultssets:{it:parmest_resultssets}}
{break}{helpb lincomest} if installed
{p_end}
