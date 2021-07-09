{smcl}

{right:Aarhus University}
{right: Support: mark.soe558@gmail.com}
help for {cmd:niceest} {right:Authors: Mark Soe and Henrik Stovring}
{hline}

{title:Title}

	{cmd:niceest} - Export regression table to excel or word


{title:Syntax}

	{cmd:niceest} {cmd: ,} outfile{cmd:(}{it:filename}[, replace]{cmd:)}[{it: word}] [{it: excel}] [{it: options}]




{synoptset 32 tabbed}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{cmdab: outfile}{cmd:(}{it:filename}[{cmd:, replace}]{cmd:)}}Save a formatted regression table to an Excel file (default) or Word.{p_end}

{syntab:Fileformat}
{synopt:{cmdab: word}}Exports regression results into a word file.{p_end}
{synopt:{cmdab: excel}}Exports regression results into a excel file.{p_end}


{syntab:Model}
{synopt:{cmdab: pvalues}{cmd:(}{help string:{it:string}}{cmd:)}}{it:P}-values are displayed with label defined as{it: string}{p_end}
{synopt:{cmdab: se}{cmd:(}{help string:{it:string}}{cmd:)}}Standard errors are displayed with label defined as{it: string}{p_end}
{synopt:{cmdab: df}{cmd:(}{help string:{it:string}}{cmd:)}}Degrees of freedom is displayed with label defined as{it: string}{p_end}
{synopt:{cmdab: intercept}{cmd:(}{help string:{it:string}}{cmd:)}}Label intercept defined as{it: string}; default is {bf:Intercept}{p_end}

{syntab:Reporting}
{synopt:{cmdab: format}{cmd:(}{help %fmt:{it:%fmt}}{cmd:)}}Display format for variables; default is {bf:%6.2f}{p_end}
{synopt:{cmdab: pformat}{cmd:(}{help %fmt:{it:%fmt}}{cmd:)}}Display format for {it:P}-values; default is {cmd:format}{p_end}
{synopt:{cmdab: eform}}Exponentiate estimates and confidence limits{p_end}
{synopt:{cmdab: cidelims}{cmd:(}{help string:{it:string}}{cmd:)}}Set appearance for confidence interval; default is {bf:[;]}{p_end}
{synopt:{cmdab: level}{cmd:(}{help numlist:{it:#}}{cmd:)}}Confidence level for calculating confidence limits; default is {bf:level(95)}{p_end}
{synopt:{cmdab: addspace}}Adds space between the explanatory variables{p_end}
{synopt:{cmdab: raw}}Displays the table in its raw format, without changes to the layout{p_end}
{synoptline}
{p 4 4 2 0}
{dup 4: }The options {cmdab:word} and {cmdab:excel} are mutually exclusive
as only one output file is allowed.
{cmdab:excel} is the default if neither is specified.
{dup 4: }Note that it is not allowed to combine {cmdab:word} and {cmdab:addspace}. 

{title:Description}
{p 4 4 2 0}
{cmd:niceest} relies on {cmd:parmest} to export regression results into a formatted table in either Excel or Word. As input {cmd:niceest} takes the most recently executed regression analysis and as ouput creates a table in excel or word with labeled regression coefficients, estimates and confidence intervals. If requested by the user, p-values, standard errors and degrees of freedom will be included in the table. 

{dup 4: }Excel 2007/2010(.xlsx) files are supported. 
{dup 4: }Microsoft Word Open XML(.docx) files are supported.


{bf:*Note*}
{p 4 8 30 0}
{cmd:parmest} has to be installed before running {cmd:niceest}.  {cmd:parmest} can be installed from: {net search st0043_2:parmest}



{title:Options}

{dup 9: }{c TLC}{hline 10}{c TRC}
{dup 4: }{hline 5}{c BRC} Required {c BLC}{hline}

{p 4 8 2 0}
{cmd:outfile}{cmd:(}{it:filename}[{cmd:, replace}]{cmd:)} is required. If there is no file named {it:filename} with the same fileformat as defined, it creates a new file named {it:filename}. If a file named {it:filename} with the same fileformat already exists, an error will be displayed unless the replace option is used. 

{p 8 8 2 0}
{cmd:replace} overwrites an existing file. If the file does not exist, a new file will be created irrespective of replace being specified or not.

{dup 9: }{c TLC}{hline 12}{c TRC}
{dup 4: }{hline 5}{c BRC} Fileformat {c BLC}{hline}

{p 4 8 2 0}
{cmd: word} defines .docx to be used as the {cmd:outfile}-format. The regression results will be exported to a table in an word-file named {it:filename}.docx. If neither{cmd: word} nor{cmd: excel} is defined,{cmd: excel} is assumed

{p 4 8 2 0}
{cmd: excel} defines .xlsx to be used as the {cmd:outfile}-format. The regression results will be exported to a table in an excel-file named {it:filename}.xlsx. If neither{cmd: word} nor{cmd: excel} is defined,{cmd: excel} is assumed 


{dup 9: }{c TLC}{hline 7}{c TRC}
{dup 4: }{hline 5}{c BRC} Model {c BLC}{hline}

{p 4 8 2 0}
{cmd: pvalues}{cmd:(}{help string:{it:string}}{cmd:)} includes p-values for each variable and the intercept in the excel file. {it:string} is used as the column header.

{p 4 8 2 0}
{cmd: se}{cmd:(}{help string:{it:string}}{cmd:)} includes standard error for each variable and the intercept in the excel file. Displays {it:string} as the column header.

{p 4 8 2 0}
{cmd: df}{cmd:(}{help string:{it:string}}{cmd:)} includes degrees of freedom for each variable and the intercept in the excel file. Displays {it:string} as the column header.

{p 4 8 2 0}
{cmd: intercept}{cmd:(}{help string:{it:string}}{cmd:)} labels the intercept as {it:string}. If omitted the intercept will be labeled "Intercept".


{dup 9: }{c TLC}{hline 11}{c TRC}
{dup 4: }{hline 5}{c BRC} Reporting {c BLC}{hline}

{p 4 8 2 0}
{cmd: format}{cmd:(}{help %fmt:{it:%fmt}}{cmd:)} specifies how numbers from regression output are to be displayed in the excel file. Only numerical formats are allowed; see: {help %fmt: [D] format}

{p 4 8 2 0}
{cmd: pformat}{cmd:(}{help %fmt:{it:%fmt}}{cmd:)} specifies how p-values from regression output are to be displayed in the Excel file. If both {cmd:pformat} and {cmd:format} are specified, the p-values will be formatted as specified by {cmd:pformat}. If {cmd:pformat} is not specified, the p-values will be formatted as specified by {cmd:format}.

{p 4 8 2 0}
{cmd:eform} exponentiates coefficients and associated intervals in the output.  

{p 4 8 2 0}
{cmd: cidelims}{cmd:(}{help string:{it:string}}{cmd:)} sets the appearance of delimiters of confidence intervals as {it:string}. The available sets of delimiters are {bf:(:)}, {bf:[:]}, {bf:(-)}, {bf:[-]}, {bf:(;)} or {bf:[;]}.

{p 4 8 2 0}
{cmd: level}{cmd:(}{help numlist:{it:#}}{cmd:)} sets the confidence level at {it:#}. If {cmd: level} is not specified, the default confidence level of {it:95%} is used.

{p 4 8 2 0}
{cmd:addspace} adds an empty row between the explanatory variables in the excel file.


{title:Remarks}
{p 4 4 2 0}
The regression tables produced by Stata are typically not in a format desired by users for inclusion in reports and manuscripts ready for submission. Several user-written packages are available for more polished presentation of estimates and associated statistics. {cmd:niceest} is an extension of {cmd:parmest} as it export results to a formatted Excel-file in which variable and value labels (if present) are used. Further the package allows for flexible specification of confidence intervals, inclusion of p-values, degrees-of-freedom and standard errors. The code was first developed for an introductory regression course for students in public health, and is aimed at providing a minimal and yet nicely formatted table, which can be directly included in Word-documents (or similar word processors).

{title:Examples}

{space 4}Start by opening a dataset
{space 8}{bf:. sysuse auto}

{space 2}{ul:Example 1} - How to use niceest with no options

{space 4}First run the regression that you wish to export
{space 8}{bf:. regress price b0.foreign weight}

{space 4}Next run the niceest command 
{space 8}{bf:. niceest, outfile(table1)}

{p 4 4 2}
In this example the regression will be exported to an excel-file named {it:table1.xlsx}. The replace option can be added, if an excel-file with the same name exists, and you wish to replace it. 

{space 2}{ul:Example 2} - How to use the model-otions

{space 4}If you wish to add to/change what will be displayed in the excel-file, you can add one or more of the 
{space 4}model-options
{space 8}{bf:. niceest, outfile(table1, replace) pvalues(p) intercept(Reference)}

{space 4}In this example the outputtable will display the pvalues as {it:p} and change the name of the intercept to
{space 4}{it:Reference}. If you wish to also add degrees of freedom to the table, add it as an option
{space 8}{bf:. niceest, outfile(table1, replace) pvalues(p) intercept(Reference) df(dof)}


{space 2}{ul:Example 3} - How to use the reporting-otions

{p 4 4 2 0}
If you wish to change how the numbers in the table are to be displayed in the excel-file, you can add one or more of the repoting-options. A few examples are shown below:

{space 8}{bf:. niceest, outfile(table1, replace) cidelims([:])}
{space 8}{bf:. niceest, outfile(table1, replace) cidelims([:]) format(%7.3f)}
{space 8}{bf:. niceest, outfile(table1, replace) format(%7.3f) se(Standard Error)}


{space 2}{ul:Example 4} - How to export to word

{p 4 4 2 0}
If you wish to export the regression table to word, add the word-option when running the niceest command. Examples are shown below:
 
{space 8}{bf:. niceest, outfile(table1) word}
{space 8}{bf:. niceest, outfile(table1, replace) cidelims([:]) format(%7.3f) word}
{space 8}{bf:. niceest, outfile(table1, replace) pvalues(p) intercept(Reference) word}


{title:Also see}

Parmest helpfile - {help parmest:{it:help parmest}}


