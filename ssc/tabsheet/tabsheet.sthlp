{smcl}
{* version 1.0.0 16oct2015}
{cmd:help tabsheet}
{hline}
{title:Title}

{p 5}
{cmd:tabsheet} {hline 2} Rapidly outputs cross-tabular statistics to a tab-delimited file, which can be opened in a spreadsheet editor such as Excel.

{title:Process}

{pstd}
{cmd:tabsheet} enables the rapid production of cross-tabular statistics to spreadsheets that may contain hundreds or thousands of rows.
Each row, {it:r = 1, 2, ..., R}, will represent a metric for which point estimates are desired for each of {it:c = 1, 2, ..., C} subpopulations. 
By default, for row {it:r} and subpopulation {it:c}, there will be three columns, representing: (1) the proportion or mean of {it:r} among subpopulation {it:c}; (2) the associated standard error estimate; and (3) the associated {it:n}.
{p_end}

{pstd}
Users may specify their desired outputs across several executions of {cmd:tabsheet}, rather than being required to specify everything in a single (very long) line of code.
Further, instead of requiring users to specify the output filename and use of weights in every {cmd:tabsheet} command, {cmd:tabsheet} requires that the user specifies them a single time upfront.
Specifically, the user opens an output file for writing with the {helpb file open} command and file handle {it:outfile} and specifies the survey weights (or lack thereof) using the {helpb svyset} command.
Next, the user executes {cmd:tabsheet} command(s), after which the file writing process is concluded with a {helpb file close} command. 
Finally, the user opens the output file using spreadsheet software.{p_end}

{pstd}Thus, {cmd:tabsheet} is envisioned as part of the following process:{p_end}

{phang}1. Set up{p_end}
{phang2}a. Open dataset{p_end}
{phang2}b. Specify survey design (or lack thereof) using {helpb svyset}{p_end}
{phang2}c. Conduct recodes (as applicable){p_end}
{phang3}i. Create column variables, i.e., dichotomous variables indicating subpopulations of interest{p_end}
{phang3}ii. Conduct any relevant recodes of row variables for which proportions or means are desired{p_end}
{phang}2. Create output file{p_end}
{phang2}a. Open file for writing using {helpb file open} with file handle {it:outfile}{p_end}
{phang2}b. Run {cmd:tabsheet} commands to output column headers, means, and/or proportions, as applicable{p_end}
{phang2}c. Close output file using {stata file close outfile}{p_end}
{phang}3. Open output file as spreadsheet{p_end}


{title:Syntax}

{p 8}
{cmd:tabsheet} {varlist} {ifin}, {cmdab:sub:pops}({it:subpop_varlist}) {cmd:type}({it:string}) [{cmd:options}]

{phang}
{opt sub:pops(subpop_varlist)} specifies the variable list of subpopulation indicator variables for which you want statistics. 
All values of subpopulation variables should be 1, 0, or missing.
Subpopulation membership is identified by a value of 1.  Cases with missing subpopulation data will be excluded from variance estimates.
{p_end}

{phang}
{opt type(string)} specifies the type of function you would like to call or type of variable for which you want statistics:
{p_end}
{phang2}{bf:type({opt h:eader})} is used for cosmetic purposes in labeling the output.
This type of {cmd:tabsheet} command will output column labels with variable names (i.e., indicating subpopulations), and will distinguish columns containing proportions/means, estimated SEs, and sample sizes, as applicable. 
{it:Note: variables should be placed in 'varlist' rather than in 'subpop_varlist'; the subpops option is not required for commands of type(header).}{p_end}
{phang2}{bf:type({opt p:rop})} outputs proportions for every possible value of the variable(s).{p_end}
{phang2}{bf:type({opt l:ine})} outputs one line with the proportion of cases giving an 
option of '1' for each variable (e.g., for a series of related dichotomous variables; in the survey context, this may be a battery of select-all-that-apply question items).
{it:Note: the denominator is all cases with a non-missing value.}
{p_end}
{phang2}{bf:type({opt m:ean})} outputs a row of means for each variable.{p_end}
	   
{phang}
    NOTE: {cmd:tabsheet} requires that the survey design variables (e.g., weights) be identified using {helpb svyset}. 
	For unweighted estimates, simply run {cmd:svyset} and specify "none" for weights. 
	For example, an unweighted dataset could be specified using: {stata svyset _n, vce(linearized) singleunit(missing)}.
{p_end}
{phang}
	NOTE: {cmd:tabsheet} requires that an output file be open with the handle {bf:outfile}.  For example, this can be done with: {stata file open outfile using "output.txt", write replace}.
	After the conclusion of all {cmd:tabsheet} commands, the user will run the command {stata file close outfile}.
{p_end}
{phang}
	NOTE: Successful {cmd:tabsheet} commands write to the output file, but do not display results in the display window. The display window is reserved by {cmd:tabsheet} for warnings and errors.
{p_end}

{marker options}{...}
{title:Options}

{phang} 
{opt simple} produces streamlined output (one column per subpopulation variable, instead of three columns per subpopulation variable).
This is recommended if it is not necessary to estimate standard errors.  {it:Note: with this option enabled, {cmd:tabsheet} will only output sample sizes for type(prop).}
{p_end}
{phang}
{bf:header(varlabel)} displays headers for each subpopulation, using the subpops' variable labels as column titles.
{p_end}
{phang}
{bf:header(varname)} is similar to {bf:header(varlabel)}, except that the column headers are the unlabeled variable names instead of the variable labels.
{p_end}
{phang}
{opt supp:ress(numbers)} will exclude observations with a particular set of values from the denominator; numbers can be suppressed individually, or a range can be expressed with the "/" symbol, with the lower number listed first.
E.g., if the values between -90 and -100 are reserved for various forms of missing survey data, and responses of "don't know" are given values of 99, then {bf:supp(-100/-90 99)} will exclude all such observations from calculations.
{p_end}
{phang}
{opt lineval(numbers)} allows you to use {bf:type({opt l:ine})} with a custom set of values.  E.g., {bf:lineval(4/5)} outputs a row for each variable with the proportion of values between 4 and 5 for each subpopulation.
{p_end}
{phang}
{opt sort} allows {bf:type({opt l:ine})} commands to be sorted in descending order, based on the percentages for the first listed subpopulation.
{p_end}
{phang}
{opt over:se} causes the standard errors to be calculated via the {bf:over} option rather than via the {bf:subpop} option.
Use of this option does not impact point estimates but, under certain scenarios, can have a minor impact on variance estimates.
{p_end}
{phang}
{opt nobreak} does not output an extra line break after a given command; by default, there is an extra line break at the end of every command, to separate different pieces of output.
{p_end}


{title:Description}

{pstd}
{cmd:tabsheet} facilitates the rapid generation of cross-tabular statistics.  After receiving a list of variables and subpopulations, 
it automatically outputs proportions, means, estimated standard errors, and sample sizes to a tab-delimited file, which can be opened as a 
spreadsheet in software such as Microsoft Excel. {p_end}

{pstd}Compared with other analogous Stata programs, {cmd:tabsheet}'s strengths include:{p_end}
{phang2}-its simplicity and ease of use{p_end}
{phang2}-the ability to "mix-and-match" different types of statistics in a single exported spreadsheet across runs{p_end}
{phang2}-its accommodation of {helpb svy} data{p_end}
{phang2}-its options for computing statistics for several subpopulations simultaneously{p_end}
{phang2}-its novel options for providing consolidated output for a series of dichotomous variables via the {bf:type({opt l:ine})} option{p_end}


{title:Example 1(a): Basic data setup, tabsheet syntax}

{pstd}/* Clear environment, open dataset, and declare the survey design */{p_end}
{phang2}{cmd:clear all}{p_end}
{phang2}{cmd:use http://www.stata-press.com/data/r9/gss1991.dta}{p_end}
{phang2}{cmd:svyset _n, vce(linearized) singleunit(missing)}{p_end}

{pstd}/* Modify the variable labels to include the variable name, to make the output easier to read */{p_end}
{phang2}{cmd:foreach v of varlist sex-work9 {c -(}}{p_end}
{phang2}{cmd:{space 5}label variable `v' "`v'. `:variable label `v''"}{p_end}
{phang2}{cmd:{c )-} }{p_end}

{pstd}/* Create dummy variables to indicate subpopulation membership */{p_end}
{phang2}{cmd:gen total = 1}{p_end}
{phang2}{cmd:gen male = sex==1}{p_end}
{phang2}{cmd:recode age (18/34=1) (else=0), gen(age18to34)}{p_end}
{phang2}{cmd:recode age (35/49=1) (else=0), gen(age35to49)}{p_end}
{phang2}{cmd:recode age (50/64=1) (else=0), gen(age50to64)}{p_end}
{phang2}{cmd:recode age (65/99=1) (else=0), gen(age65plus)}{p_end}

{pstd}/* Create macro listing subpop variables for use */{p_end}
{phang2}{cmd:local subpops "total male female age18to34-age65plus"}{p_end}

{pstd}/* Open the output file */{p_end}
{phang2}{cmd:file open outfile using "myoutput.txt", write replace}{p_end}

{pstd}/* Write the header line listing the subpopulations and labeling columns that have proportions/means, estimated SEs, and sample sizes */{p_end}
{phang2}{cmd:tabsheet `subpops', type(header)}{p_end}

{pstd}/* For each variable educ-speduc, output a line indicating the item mean for every subpopulation, along with estimated SEs and sample sizes */{p_end}
{phang2}{cmd:tabsheet educ-speduc, sub(`subpops') type(mean)}{p_end}

{pstd}/* For the next few variables, output a line with the variable label, then output a line for every value label with the proportions, 
estimated SEs, and sample sizes for that value */{p_end}
{phang2}{cmd:tabsheet tax-helpoth, sub(`subpops') type(prop)}{p_end}

{pstd}/* For each variable hlth1-hlth9, output a line with the proportions that give an option of 1 (e.g., for dichotomous variables) */{p_end}
{phang2}{cmd:tabsheet hlth1-hlth9, sub(`subpops') type(line)}{p_end}

{pstd}/* Do the same as above for the next variable group, but sort it in descending order */{p_end}
{phang2}{cmd:tabsheet work1-work9, sub(`subpops') type(line) sort}{p_end}

{pstd}/* Do the same as the above lines, but with the {bf:simple} option enabled. 
By default, there are three columns for every variable: proportion/mean, estimated SE, and n. 
The {bf:simple} option only displays one column for each subpopulation (with the proportion or mean), and adds a line at the end with the sample sizes. */{p_end}
{phang2}{cmd:tabsheet `subpops', type(header) simple}{p_end}
{phang2}{cmd:tabsheet educ-speduc, sub(`subpops') type(mean) simple}{p_end}
{phang2}{cmd:tabsheet tax-helpoth, sub(`subpops') type(prop) simple}{p_end}
{phang2}{cmd:tabsheet hlth1-hlth9, sub(`subpops') type(line) simple}{p_end}
{phang2}{cmd:tabsheet work1-work9, sub(`subpops') type(line) sort simple}{p_end}

{pstd}/* Close the output file */{p_end}
{phang2}{cmd:file close outfile}{p_end}


{title:Example 1(b): Recodes}
{pstd}Given that tabsheet provides cleaner output if the variables and values are all labeled, the below examples demonstrate the use of basic data cleaning steps in conjunction with tabsheet:{p_end}

{pstd}/* Conduct recodes with value labeling within line */{p_end}
{phang2}{cmd:recode obey-helpoth (1/2=1 "Important") (3=2 "Somewhat important") (4/5=3 "Not important"), pre(r_) label(imp_lbl)}{p_end}

{pstd}/* Conduct recodes with separate value labeling lines */{p_end}
{phang2}{cmd:recode educ-speduc (0/11=1) (12=2) (13/15=3) (16/20=4), pre(r_)}{p_end}
{phang2}{cmd:label define eduLabel 1 "1: Less than HS" 2 "2: HS grad" 3 "3: Some college" 4 "4: College graduate"}{p_end}
{phang2}{cmd:label values r_educ-r_speduc eduLabel}{p_end}

{pstd}/* Create variable labels for the recoded variables */{p_end}
{phang2}{cmd:foreach var of varlist obey-helpoth educ-speduc {c -(}}{p_end}
{phang2}{cmd:{space 5}local varlabel`var': variable label `var'}{p_end}
{phang2}{cmd:{space 5}label variable r_`var' `"r_`varlabel`var''"'}{p_end}
{phang2}{cmd:{c )-} }{p_end}

{pstd}/* Open output file */{p_end}
{phang2}{cmd:file open outfile using "myoutput2", write replace}{p_end}

{pstd}/* Output a header and then proportions for the recoded variables */{p_end}
{phang2}{cmd:tabsheet RegionNE RegionSE, type(header)}{p_end}
{phang2}{cmd:tabsheet r_obey-r_helpoth r_educ-r_speduc, subpops(RegionNE RegionSE) type(prop)}{p_end}

{pstd}/* Close output file */{p_end}
{phang2}{cmd:file close outfile}{p_end}


{title:Example 2: Advanced tabsheet commands}

{pstd}/* Prepare dataset for this example */{p_end}
{phang2}{cmd:clear all}{p_end}
{phang2}{cmd:use http://www.stata-press.com/data/r9/gss1991.dta}{p_end}
{phang2}{cmd:svyset _n, vce(linearized) singleunit(missing)}{p_end}
{phang2}{cmd:cap gen total = 1}{p_end}
{phang2}{cmd:recode hlth* (2=0)}{p_end}
{phang2}{cmd:forval i=1/9 {c -(}}{p_end}
{phang2}{cmd:{space 5}label define hlth1 0 "no", modify}{p_end}
{phang2}{cmd:{c )-} }{p_end}

{pstd}/* Open output file */{p_end}
{phang2}{cmd:file open outfile using "myoutput3", write replace}{p_end}

{pstd}/* Create headers and output proportions the basic way */{p_end}
{phang2}{cmd:tabsheet total hlth1-hlth9, type(header)}{p_end}
{phang2}{cmd:tabsheet obey-helpoth, sub(total hlth1-hlth9) type(prop)}{p_end}

{pstd}/* Do the same as above, but in one line */{p_end}
{phang2}{cmd:tabsheet obey-helpoth, sub(total hlth1-hlth9) type(prop) header(varname)}{p_end}

{pstd}/* Do the same as above, but with headers displaying the variable labels (instead of variable names) */{p_end}
{phang2}{cmd:tabsheet obey-helpoth, sub(total hlth1-hlth9) type(prop) header(varlabel)}{p_end}

{pstd}/* Now, output one line for each item, with the percentage indicating that the item is the most important or second most important */{p_end}
{phang2}{cmd:tabsheet obey-helpoth, sub(total hlth1-hlth9) type(line) header(varlabel) lineval(1/2)}{p_end}

{pstd}/* Do the same as above, but sort the output in a descending fashion, with the highest percentages for the first subpop listed on top */{p_end}
{phang2}{cmd:tabsheet obey-helpoth, sub(total hlth1-hlth9) type(line) header(varlabel) lineval(1/2) sort}{p_end}

{pstd}/* In order to demonstrate the {bf:suppress} option, let's artifically induce some missing data with non-substantive values of -99 and -91... */{p_end}
{phang2}{cmd:foreach v of varlist obey-helpoth {c -(}}{p_end}
{phang2}{cmd:{space 5}replace `v' = -99 if mod(_n,40)==1}{p_end}
{phang2}{cmd:{space 5}replace `v' = -91 if mod(_n,27)==1}{p_end}
{phang2}{cmd:{c )-} }{p_end}

{pstd}/* We could calculate the row percentages of all cases, including missing data in the denominator, via the syntax below, although this will cause some underestimates of population parameters */{p_end}
{phang2}{cmd:tabsheet obey-helpoth, sub(total hlth1-hlth9) type(line) header(varlabel) lineval(1/2) sort}{p_end}

{pstd}/* Alternatively, we can remove the missing values from the denominator, which should produce point estimates similar to those from before the missingness was induced */{p_end}
{phang2}{cmd:tabsheet obey-helpoth, sub(total hlth1-hlth9) type(line) header(varlabel) lineval(1/2) sort suppress(-99 -91)}{p_end}

{pstd}/* Close output file */{p_end}
{phang2}{cmd:file close outfile}{p_end}


{title:Opening Output in Microsoft Excel}

{pstd}First, after running the syntax, ensure that the output file has been properly closed in Stata (e.g., by running the command {cmd:file close outfile}). 
Then, locate the output file in Windows Explorer.  Right click the output file, and click {bf:"Open with-->Excel."} 
If Excel is not listed as an option, click {bf:"Open with-->Choose default program"} and then click {bf:"Browse"} to locate the {bf:Excel.exe} file. 
An example location for the {bf:Excel.exe} file is {bf:C:\Program Files (x86)\Microsoft Office\Office14\Excel.EXE}.
{p_end}


{title:Technical Notes}

{phang}-Proportions and means are all computed using the "subpop" option by default (instead of using the "over" option).{p_end}
{phang}-Option {bf:simple} only outputs sample sizes for {bf:type(prop)}.  This is because {bf:type(line)} and {bf:type(mean)} could potentially have different sample sizes for a set of variables that are displayed together.{p_end}
{phang}-Cases with missing data are {bf:not} removed listwise. 
E.g., with the command {cmd:tabsheet v1-v5, type(prop)}, a case that has missing data for v5 could be included for other items.
By contrast, this is not the case for the command {cmd: svy: proportion v1-v5}.
{p_end}

{title:User Tips}
{phang}-Give careful thought to the handling of invalid values via recoding them to missing or using the {cmd:suppress(numbers)} option, particularly when using the {cmd:type(line)} and {cmd:type(mean)} options.{p_end}
{phang}-Discrepancies in standard errors may come up between different analysts due to inappropriate coding of subpop variables. 
In most cases, subpop variables should be coded as 1 for cases in the subpopulation, 0 for cases outside of the subpopulation, and missing for cases that should be excluded from analysis.
See the 2008 Stata Journal article by West, Berglund, and Heeringa for details.{p_end}
{phang}-Make sure to read your output in the Stata console, in case of warnings for possible user error, such as using {cmd:type(line)} with a variable with more than two nonmissing values.{p_end}
{phang}-Note that due to rounding, Stata's displayed output may differ slightly from {cmd:tabsheet} output.{p_end}
{phang}-One user error could cause entire columns or rows to be incorrect.
Thus, I recommend that you check recodes thoroughly and inspect an entire column and entire row of output using built-in Stata commands to ensure that output is as expected.{p_end}


{title:Acknowledgements}

{pstd}Thank you to Fors Marsh Group (FMG) for support in developing this program, the internal version of which is titled {cmd:topline} and is functionally equivalent.
Thanks also to Joe Luchman for help testing several versions of topline and providing helpful feedback, Jen Gibson for her help testing a previous version, and Sarah Evans for helping to popularize previous versions within FMG.
Thank you to several others at FMG who shared feedback on previous versions, shared project syntax for testing purposes, encouraged a public release of this program, and provided editing support.{p_end}


{title:Author}

{pstd}Jonathan Mendelson, Fors Marsh Group, jmendelson@forsmarshgroup.com{p_end}
