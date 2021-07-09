{smcl}
{* *! version 1.3  15oct2014}{...}
{hline}
help for {cmd:table1}{right:Version 1.3, 15 October 2014}
{hline}

{title:Title}

{p2colset 5 14 21 2}{...}
{p2col: {bf:table1}}{hline 2} Create "table 1" of baseline characteristics for a manuscript

{title:Syntax}

{p 8 18 2}
{opt table1} {ifin} {weight}, {opt vars(var_spec)} [{it:options}]

{phang}{it:var_spec} = {it: varname vartype} [{it:varformat}] [ \ {it:varname vartype} [{it:varformat}] \ ...]

{phang}Supported variable types:{p_end}
{tab}contn - continuous, normally distributed
{tab}conts - continuous, skew
{tab}cat   - categorical, groups compared using Pearson's chi-squared
{tab}cate  - categorical, groups compared using Fisher's exact test
{tab}bin   - binary, groups compared using Pearson's chi-squared
{tab}bine  - binary, groups compared using Fisher's exact test

{phang}{opt fweight}s are allowed; see {help weight}


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Group options}
{synopt:{opt by(varname)}}group observations by {it:varname}{p_end}
{synopt:{opt test}}include column describing the significance test used{p_end}
{synopt:{opt pdp(#)}}max number of decimal places in p-value; default is pdp(3){p_end}

{syntab:Contents of rows}
{synopt:{opt one:col}}report categorical variable levels underneath variable name instead of in
separate column{p_end}
{synopt:{cmdab:f:ormat(%}{it:{help fmt}}{cmd:)}}default display format for contn and conts variables{p_end}
{synopt:{cmdab:cf:ormat(%}{it:{help fmt}}{cmd:)}}default display format for cat and bin variables{p_end}
{synopt:{opt plusminus}}report contn variables as mean ± sd rather than mean (sd){p_end}
{synopt:{opt percent}}report categorical values as % rather than N (%){p_end}
{synopt:{opt mis:sing}}don't exclude missing values from categorical variables{p_end}
{synopt:{opt cmis:sing}}report number of non-missing continuous variables{p_end}

{syntab:Output options}
{synopt:{opt sav:ing(file_spec)}}save table to Excel file{p_end}
{synopt:{opt clear}}replace the dataset in memory with the table{p_end}


{title:Description}

{pstd}
{opt table1} generates a "table 1" of characteristics for a manuscript. Such a table generally
includes a collection of baseline characteristics which may be either continuous or categorical. The
observations are often grouped, with a "p-value" column on the right comparing the characteristics
between groups.{p_end}

{pstd}The {bf:vars} option is required and contains a list of the variable/s to be included as
rows in the table. Each variable must also have a type specified ({it:contn}, {it:conts}, {it:cat},
{it:cate}, {it:bin} or {it:bine} - see above). If the observations are grouped using {bf:by()}, a
significance test is performed to compare each characteristic between groups. {it:contn} variables
are compared using ANOVA, {it:conts} variables are compared using the Wilcoxon rank-sum (2 groups)
or Kruskal-Wallis (>2 groups) test, {it:cat} and {it:bin} variables are compared using Pearson's
chi-squared and {it:cate} and {it:bine} variables are compared using Fisher's exact test. Specifying
the {bf:test} option adds a column to the table describing the test used.{p_end}

{pstd}The display format of each variable in the table depends on the variable type. For continuous
variables the default display format is the same as that variable's current display format. You can
change the table's default display format for continuous variables using the {bf:format()} option.
For categorical variables (including {it:cat}, {it:cate}, {it:bin}, {it:bine}) the default is to
display the proportion using either 0 or 1 decimal place depending on the total frequency. You
can change this default using the {bf:cformat()} option. After each variable's type you may
optionally specify a display format to override the table's default.{p_end}

{pstd}The list of variables is delimited using a backslash (\).{p_end}

{pstd}The resulting table may be saved to an Excel file using the {bf:saving()} option. The
{it:file_spec} contains the file path and optionally "{bf:, replace}" to replace any existing file.
You can also specify the sheet of the Excel file using "{bf:, sheet(sheetname)}".{p_end}

{pstd}The resulting table can  be kept in memory, replacing the original dataset, using the
{bf:clear} option.{p_end}


{title:Example}

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. table1, by(foreign) vars(price conts \ weight contn %2.1f \ rep78 cat)}{p_end}
{phang}{cmd:. table1, by(foreign) vars(price conts \ weight contn \ rep78 cat) format(%2.1f)}{p_end}
{phang}{cmd:. table1, by(foreign) vars(price conts \ weight contn \ rep78 cat) format(%2.1f) saving(auto.xls, replace)}{p_end}


{title:Author}

{p 4 4 2}
Phil Clayton, ANZDATA Registry, Australia, phil@anzdata.org.au

