{smcl}
{* *! version 5.0.0 12Jun2020}
{cmd:help summtab}
{hline}

{title:Title}

{p2colset 5 17 17 2}{...}
{p2col :{hi:summtab} {hline 2}}Computes summary statistics overall and/or across levels of a categorical variable 
								(i.e., the results are stratified by this variable), and
								compiles them into a nicely formatted, publication-quality table.

{marker syntax}{...}
{title:Syntax}


{p 8 17 2}
{cmd:summtab}{cmd: [if] [in], }{cmd:contvars(}{it:{help varlist}}) {cmd:catvars(}{it:varlist}) [{cmd:by(}{it:{help varname}})  {it:{other options}}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{cmd:contvars(}{it:varlist})}Specify continuous variables you wish to summarize{p_end}
{synopt :{cmd:catvars(}{it:varlist})}Specify categorical variables you wish to summarize{p_end}

{syntab:Column Options}
{synopt :{cmd:by(}{it:varname})}Variable by which to stratify the summaries; if not specified, defaults to providing only the overall summaries{p_end}
{synopt :{cmd:total}}Display a total (overall) column{p_end}

{syntab:Statistic Options}
{synopt :{cmd:mean}}Display the means and standard deviations for continuous variables{p_end}
{synopt :{cmd:median}}Display the medians and quartiles (25th and 75th percentiles) for continuous variables{p_end}
{synopt :{cmd:range}}Display the the minimum and maximum for continuous variables{p_end}
{synopt :{cmd:pnonmiss}}Display the total number nonmissing and % nonmissing for continuous variables on a separate row{p_end}
{synopt :{cmd:pmiss}}Display the total number nonmissing and % missing for continuous variables on a separate row. May not be specified at the same time as pnonmiss.{p_end}
{synopt :{cmd:rowperc}}Provide row percentages for categorical variables, rather than (the default) column percentages{p_end}
{synopt :{cmd:catmisstype(}{it:string})}How to handle missing values for categorical variables.  Three options, detailed in the explanation section below.{p_end}

{syntab:P-Value Options}
{synopt :{cmd:pval}}Compute and display p-values{p_end}
{synopt :{cmd:contptype(}{it:integer})}Continuous p-value type{p_end}
{synopt :{cmd:catptype(}{it:integer})}Categorical p-value type{p_end}

{syntab:Format Options}
{synopt :{cmd:mnfmt(}{it:integer})}Number of digits to display after the decimal point for means and standard deviations; default is 2; maximum is 8{p_end}
{synopt :{cmd:medfmt(}{it:integer})}Number of digits to display after the decimal point for medians and quartiles; default is 1; maximum is 8{p_end}
{synopt :{cmd:rangefmt(}{it:integer})}Number of digits to display after the decimal point for minimums and maximums; default is 1; maximum is 8{p_end}
{synopt :{cmd:pnonmissfmt(}{it:integer})}Number of digits to display after the decimal point for % non-missing; default is 1; maximum is 8{p_end}
{synopt :{cmd:pmissfmt(}{it:integer})}Number of digits to display after the decimal point for % missing; default is 1; maximum is 8{p_end}
{synopt :{cmd:catfmt(}{it:integer})}Number of digits to display after the decimal point for categorical variable percentages; default is 1; maximum is 8{p_end}
{synopt :{cmd:pfmt(}{it:integer})}Number of digits to display after the decimal point for p-values; default is 3; maximum is 8{p_end}

{syntab:Output Options}
{synopt :{cmd:directory(}{it:string})}The directory in which the results are saved; if not specified, defaults to current working directory{p_end}
{synopt :{cmd:title(}{it:string})}Table title, to put at the top of the output Word document; defaults to Table 1{p_end}
{synopt :{cmd:word}}If specified, a Word document will be output{p_end}
{synopt :{cmd:wordname(}{it:string})}Name of Word document; defaults to table1{p_end}
{synopt :{cmd:excel}}If specified, an Excel document will be output{p_end}
{synopt :{cmd:excelname(}{it:string})}Name of Excel document; defaults to table1{p_end}
{synopt :{cmd:replace}}Specify to overwrite the Word and/or Excel file{p_end}
{synopt :{cmd:append}}Specify to add table to specified Word file; this option is non-functional if only an Excel file is requested{p_end}
{synopt :{cmd:sheetname(}{it:string})}Specify to add sheet to specified Excel file; specifying this option will automatically modify instead of 
										replace the Excel file.  This option is non-functional if only a Word file is requested{p_end}

{syntab:Advanced Options}
{synopt :{cmd:meanrow}}Report mean and standard deviation on the same row as the variable label.  Only works if mean is specified and no other continuous variable summary statistics are specified.{p_end}
{synopt :{cmd:catrow}}Report N (%) of the highest ordered category on the same row as the variable label for binary variables.  Only works if {cmd:catmisstype} is set to none. See options explanations for more details.{p_end}
{synopt :{cmd:clustpval}}Request p-values that take into account clustered nature of data; will only take effect if
							the pval option is also specified.  Clustered p-values are not reported for categorical variables.{p_end}
{synopt :{cmd:clustid(}{it:varname})}Cluster identifier; needed if clustpval is specified{p_end}
{synopt :{cmd:wts(}{it:varname})}Obtain weighted summary statistics{p_end}
{synopt :{cmd:wtfreq(}{it:string})}How frequencies are handled for weighted data.  Three options, detailed in the explanation section below.{p_end}
{synopt :{cmd:fracfmt(}{it:integer})}Number of digits to display after the decimal point for frequencies when weights are specified and the fractional
										option of {cmd:wtfreq(}{it:string}) is specified.  Default is 2 digits. {p_end}


{pstd}
Any additional options will be passed to {cmd:putdocx begin}.  See the help file for {help putdocx}.  
For example, one option, {cmd:landscape}, will change the page orientation from portrait to landscape.

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:summtab} summarizes a list of continuous and/or categorical variables overall and/or by a categorical
stratification variable, and then outputs the results in a nicely-formatted, publication-quality
table in a Word document, using the new Stata command {help putdocx}.  The program can also output
the results to an Excel document using {help putexcel}.  {cmd:summtab} requires
Stata version 15.

{marker options}{...}
{title:Options Explanations}

{phang}
{cmd:contvars(}{it:varlist}) may be specified on its own without {cmd:catvars(}{it:varlist}), if no categorical variables
need to be summarized.  Similarly, {cmd:catvars(}{it:varlist}) may be specified on its own without {cmd:contvars(}{it:varlist}), 
if no continuous variables need to be summarized.  However, one or the other must be specified.

{phang}
{cmd:contptype(}{it:integer}) specifies the continuous p-value type.
The options are 1 = ANOVA; 2 = Kruskall-wallis test;
 default is 1 = ANOVA, if the mean option is selected.
NOTE: If mean is not selected and median is selected, the continuous p-value type
will default to 2 = Kruskall-wallis test.  This cannot be overridden by the 
{cmd:contptype(}{it:integer}) option.{p_end}
 
{phang}
{cmd:catptype(}{it:integer}) specifies the categorical p-value type.
The options are 1 = chi-square test; 2 = Fisher's exact test;
 default is 1 = chi-square test {p_end}
 
 {phang}
{cmd:catmisstype(}{it:string}) specifies how to handle missing values for categorical variables.
The options are "none" = Missing values are not summarized (default); "missperc" = Missing values are treated as another
 category and included in the percent of the total; "missnoperc" = Missing values are treated as another category, but
 are not included in the percent of the total. Note that if your "by" variable contains missing values you would like to 
 summarize, please first reformat them as non-missing values (e.g., change . to 99, and label 99 as missing).{p_end}
 
  {phang}
{cmd:wtfreq(}{it:string}) specifies how to handle cell frequencies for categorical variables when weights are used.
The options are "off" = Frequencies are not reported for weighted data (default); "fractional" = Frequencies are reported,
but are kept in their fractional form; "ceiling" = Frequencies are reported and are rounded up to the nearest whole number. 
{p_end}

  {phang}
{cmd:catrow} specifies that the N (%) of the highest ordered category is reported on the same row as the variable label for binary variables.  
For example, suppose the variable is depression and is coded as 1=yes and 0=no.  This option will report the N (%) for the yes category on the
same row as the variable label "Depression", and will not report the N (%) for the no category. This option only works if {cmd:catmisstype} is set to none.
It is the program user's responsibility to make sure that the meaning of the N (%) for the highest ordered category lines up with the variable label. 
In the previous example, if the variable had been coded as 1=yes and 2=no, then the no category would have been reported on the same line as the variable label.
In this case, the variable label should either be changed to something like "Not Depressed", or the categories should be recoded so that the yes category is the
highest ordered.
{p_end}


{marker example}{...}
{title:Examples}
	
{phang2}{cmd:. sysuse auto, clear}{p_end}
	
	Run summtab, with summaries stratified by the "foreign" variable
{phang2}{cmd:. summtab, by(foreign) contvars(price mpg weight length) catvars(rep78) mean median pval landscape replace} 
 {cmd: word wordname(summary_table) title(My Table 1)}
 
	Run summtab, with overall summaries only
{phang2}{cmd:. summtab, contvars(price mpg weight length) catvars(foreign rep78) word wordname(summary_table)} 
 {cmd:title(My Table 1) mean median replace}
 
	Run summtab, generate Excel file
{phang2}{cmd:. summtab, by(foreign) contvars(price mpg weight length) catvars(rep78) mean median total} 
 {cmd:title(My Table 1) excel excelname(summary_table) replace}
 
	Run summtab, more options
{phang2}{cmd:. summtab, by(foreign) contvars(price mpg weight length) catvars(rep78) mean median range total} 
 {cmd:medfmt(1) mnfmt(2) word wordname(summary_table) title(My Table 1) replace}

{marker author}{...}
{title:Author}
 John A. Gallis
 Duke University Department of Biostatistics and Bioinformatics
 Duke Global Health Institute
 Durham, NC
 john.gallis@duke.edu
 
 Please email John Gallis (john.gallis@duke.edu) to report bugs or provide suggestions for improvement of the program.

{marker acknowledgements}{...}
{title:Acknowledgements}
 Special thanks to members of the Duke Global Health Institute Research Design &
 Analysis Core for testing the code and providing recommendations for improving the program.
 This includes Liz Turner, Alyssa Platt, Joe Egger, Ryan Simmons, and Amy Herring.
 
 To create this program, John modified and added to code provided on statalist.org by William Parker (william.parker@uchospitals.edu).
 John also added the functionality to output results to Excel, and added various other options.
 The orignal program can be found at the following link:
 https://www.statalist.org/forums/forum/general-stata-discussion/general/1402412-user-written-command-using-putdocx
