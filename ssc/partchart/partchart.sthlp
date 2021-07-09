{smcl}
{* *! version 2.0.0 10oct2013}
{cmd:help partchart}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:partchart} {hline 2}}participant characteristics table export{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:partchart} {it:varlist} [{it:if}] [{it:in}]
 {cmd:,} {cmd:file(}{it:string}{cmd:)} 
[{cmd:sheet(}{it:string}{cmd:)}
 {cmd:catcut(}{it:integer}{cmd:)} 
 {cmd:catsep(}{it:"string"}{cmd:, nopercent)} 
 {cmd:cattest(}{cmd:exact}{cmd:)} 
 {cmd:constats(}{it:string}{cmd:)} 
 {cmd:conprec(}{it:integer}{cmd:)} 
 {cmd:consep(}{it:"string"}{cmd:)} 
 {cmd:contest(}{cmd:kwallis}{cmd:)}
 {cmd:nobase(}{it:varlist}{cmd:)}
 {cmd:by(}{it:varname}{cmd:)}]

{title:Description}

{pstd}
{cmd:partchart} exports a "raw" "Participant Characteristics" table into a specified file format. 
This "raw" table can then be formatted into a publication quality table. {cmd:partchart} eases
the burden of either entering summary statistics by hand or using multiple lines of code to 
automate the process. {cmd:partchart} allows the user to export a table very close to publication
quality with one command.

{pstd}
{cmd:partchart} automatically parses the {it:varlist} into continuous variables and categorical variables,
but offers the user the ability to control these as well. The output table contains means and standard deviations by
default for continuous variables, but will output user defined summary statistics with the {cmd:constats}
option. Counts and percentages are output for categorical variables. Sample sizes are displayed in the last
row of the table. With the {cmd:by(}{it:varname}{cmd:)} invoked,
the numeric suffix on the column headers corresponds to the numeric values of {it:varname}.


{title:Options}

{phang}{opt file(string)} is required and indicates the filename that is output to the active directory.
Subdirectories are also supported. This file must be closed before running {cmd:partchart}.
Supported file formats include: .xlsx, .xls, .csv, .txt (tab-delimited), and .tex, with .xlsx being the default. 

{phang}{opt sheet(string)} indicates the sheet name in {it:filename} for the output if .xlsx or .xls file
formats are used. If sheet is not specified, the sheet will be named "partchartraw". 

{phang}{cmd:catcut(}{it:integer}{cmd:)} specifies the cutoff number of categories for {cmd:partchart}
to separate continuous variables from categorical variables. This is usually only a problem for small 
datasets (missclassifying continuous as categorical) or when categoricals variables have a large number
of categories. For example, with the default (10), any variable with less than 10 unique values is 
considered categorical. 

{phang}{cmd:catsep(}{it:"string"}{cmd:, nopercent)} specifies the string used to encapsulate 
categorical variables. The string must be surrounded by quotation marks, and only string lengths of
1 or 2 are valid. The default is "()". {opt , nopercent} tells {cmd:partchart} to not include the "%" 
in the output. 

{phang}{opt cattest(exact)} tells {cmd:partchart} that instead of performing a chi-square test for differences in 
categorical variables, perform Fisher's exact test and report the corresponding p-values.
This option is only valid if the option {cmd:by(}{it:varname}{cmd:)} is invoked.

{phang}{cmd:constats(}{it:string}{cmd:)} tells {cmd:partchart} what descriptive statistics to report
for continuous variables. It must be specified in the form {cmd:constats(}{it:stat1 stat2}{cmd:)},
where {it:stat1} and {it:stat2} can be anything from the list of statistics from {cmd:tabstat}, 
excluding "q". The default is {cmd:constats(mean sd)}.

{phang}{cmd:conprec(}{it:integer}{cmd:)} specifies the precision for continuous variables indicated as number
of decimal places. Only positive integers are valid and the default is 2.

{phang}{cmd:consep(}{it:"string"}{cmd:)} functions the same as {opt catsep} except {opt nopercent} isn't valid.

{phang}{opt contest(kwallis)} tells {cmd:partchart} that instead of performing ANOVA (t test) for differences in 
continuous variables, perform a Kruskal-Wallis (Mann-Whitney U) test and report the corresponding p-values.
This option is only valid if the option {cmd:by(}{it:varname}{cmd:)} is invoked.

{phang}{opt nobase(varlist)} provides the user the opportunity to exclude rows from the table. The base level of any variable in 
{cmd:nobase}'s {it:varlist} will be excluded from the table. This only applies to categorical variables. 

{phang}{opt by(varname)} splits the table into a twoway table, by {it:varname}. If the {opt by}
option is not included, {cmd:partchart} outputs a oneway table. 
The {it:varname} must be categorical with a reasonably small number of categories. In addition, values for {it:varname}
must be sequential integers starting with either 0 or 1. Also, the
{opt by} option outputs p-values for differences. These p-values are based on ANOVA or t tests for continuous
variables and chi-square tests for categorical variables (unless otherwise specified by 
{opt contest(kwallis)} or {opt cattest(exact)}).

{title:Comments}

It is always a good idea to know what directory you are working from.

The following are .ado files needed to run {cmd:partchart} and can be downloaded and installed with 
  ssc install:
              unique
              mat2txt
              lstrfun
	      tabcount
	      dataout

{title:Examples}

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. partchart price mpg foreign trunk rep78, file(partchart) sheet(onewayref)}{p_end}
{phang}{cmd:. partchart price mpg rep78 trunk, by(foreign) file(partchart) sheet(twowayref)}{p_end}
{phang}{cmd:. partchart price mpg foreign  trunk, by(rep78) file(partchart) sheet(twowaynonpararef2) cattest(exact) contest(kwallis)}{p_end}
{phang}{cmd:. partchart price rep78 mpg foreign, file(tablestest.txt) sheet(partchart-ref1) catcut(4) conprec(1) nobase(rep78 foreign)}{p_end}
{phang}{cmd:. partchart price rep78 mpg foreign, file(tablestest) sheet(partchart-ref1) consep("--") catsep("{}", nopercent)}{p_end}
{phang}{cmd:. partchart price rep78 mpg foreign, file(tablestest) sheet(partchart-ref1) consep("`=char(177)'") catsep("_")}{p_end}

{title:Author}

{phang}Seth T. Lirette, University of Mississippi Medical Center{break}
slirette2@umc.edu{p_end}

