{smcl}
{hline}
{cmd: help} for tabxml
{hline}

{title:Title}

{cmd:tabxml} - Save results in XML format for use in {it:Microsoft Excel} and
OpenOffice {it: Calc}

{title:Syntax}

{cmd:tabxml} [{cmd:,} {it:{help tabxls14##options:options}}]


{marker options}{...}
{synoptset 27 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:{help xml_tab##variables:variables}}
{synopt:{opt dv}({it:varname})}dependent variable{p_end}
{synopt:{opt ivd}({it:varlist})}independent discrete variables{p_end}
{synopt:{opt ivc}({it:varlist})}independent continuous variables{p_end}
{synopt:{opt split}({it:varname})}split data into subgroups{p_end}

{syntab:{help xml_tab##Output:Output}}
{synopt:{opt save}({it:string})}name of the output file{p_end}
{synopt:{opt options}({it:varlist})}select output for independent variables{p_end}
{synopt:{opt order}({it:varlist})}order of independent variables{p_end}
{synopt:{opt display}}display output{p_end}

{syntab:{help xml_tab##Conditions:Conditions}}
{synopt:{opt cond}({it:string})}condition - modifies total population size{p_end}
{synopt:{opt subcond}({it:string})}sub condition - creates a sub population{p_end}

{syntab:{help xml_tab##Table Formatting:Table Formatting}}
{synopt:{opt percent}({it:string})}select percent type for discrete variables{p_end}
{synopt:{opt tformat}({it:string})}select decimal places for output{p_end}
{synopt:{opt justify}({it:string})}data alignment{p_end}
{synopt:{opt rotate}({it:string})}rotate dependent variable labels{p_end}
{synopt:{opt labrown}({it:string})}determines the way the 'n' counts are displayed 
for the independent variables{p_end}
{synopt:{opt labcoln}({it:string})}determines the way the 'n' counts are displayed 
for the dependent variable{p_end}
{synopt:{opt bold}}make independent variable names bold{p_end}
{synopt:{opt olines}}omit lines between independent variables{p_end}
{synopt:{opt otab}}omit indentations from indepedent variable labels{p_end}
{synopt:{opt sp}}show the % symbol for all percents{p_end}
{synopt:{opt chi2}}display chi2 statistic for all independent variables{p_end}
{synopt:{opt chidec}({it:integer})}number of decimal places for chi2 statistic{p_end}
{synopt:{opt pval}}display p-value for all independent variables{p_end}
{synopt:{opt pdec}({it:integer})}number of decimal places for p-value{p_end}

{syntab:{help xml_tab##Excel/Calc Paths:Excel/Calc Paths}}
{synopt:{opt excelpath}({it:string})} select directory for Excel{p_end}
{synopt:{opt calcpath}({it:string})} select directory for Calc{p_end}

{syntab:{help xml_tab##svy options:svy options}}
{synopt:{opt osvy}} data is not svy {p_end}

{title:Description}

{cmd:tabxml} export Stata output directly into an XML file that could be opened with
{it:Microsoft Excel} or OpenOffice {it: Calc}. The program is relatively flexible and 
produces journal quality tables in {it:Microsoft Excel} or OpenOffice {it: Calc}; and 
allows users to apply different formats to the elements of the output table and 
essentially do everything {it:Microsoft Excel} or OpenOffice {it: Calc} can do in terms 
of formatting from within Stata as oppose to using an external package like LaTex. A key 
feature includes displaying trailing zeros after decimal places.

{cmd:tabxml} can create formatted tables of frequencies and/or percents for discrete 
independent variables, means and standard errors / confidence intervals for continuous 
independent variables. Two-way tables can be ceated by selecting a dependent variable. 
Multiple independent variables are permitted.  

{title:Options}
{* OUTPUT *}
{marker output}{...}
{dlgtab:Output}

{opt save(["]filename["])} specifies a name for XML file where tables are outputted. 
Files are saved in a folder named "Excel" which is created (if missing) in the current
directory. If save(["]filename["]) is omitted, the output will be saved in tab_out.xml 
located in the current working directory.

{opt options}({it:varlist})} modify output type for discrete and continuous independent 
variables. Output type options for discrete independent variables include (n) displayed 
"n" or (per) displayed "per". Note default output is "n (per)". Output type options for 
continuous independent variables include (mean) displayed "mean", or (mean ci) displayed 
"mean (CI)". Note default output is "n (SE)". If {opt split} is specified option(nototal) 
only outputs the subgroups of {opt split} and omits the totals.

{opt order}({it:varlist})} rearrange order of independent variables. Default order of 
independent variables is ivd({it:varlist}) followed by ivc({it:varlist}). To rearrange 
the order of the independent variables write the {it:varlist} of discrete independent
variables and continuous independent variables in the order you wish them to appear.  
  
{opt display} displays the output in Stata.

{* CONDITIONS *}
{dlgtab:Conditions}

{opt cond}({it:string}) reduces the population size of the dataset to meet the condition. 
For example cond(panel==1) reduces the populations size such that the variable panel
equals one.

{opt subcond}({it:string}) creates a sub population of the total population. 
For example subcond(age>30) creates a sub population such that the age of the 
respondents is greater than 30. 

{* TABLE FORMATTING *}
{dlgtab:Table Formatting}

{opt percent}({it:string}) tables for independent discrete variables can be either row 
or column (col) percents. Default is column percents.

{opt tformat}({it:string}) modify the number of decimal places for table percents for discrete
independent variables; and means, confidence intervals and standard errors for continuous 
independent variables. Default is two decimal places. 

{opt justify}({it:string}) justify the output of the data. Left (l), right (r) and centre (c) 
justify. Default justify is left align.

{opt rotate}({it:string}) rotate the variable labels of the dependent variable. For example, 
{opt rotate(60)} produces a pleasing effect. Default is horizontal variable names.

{opt labrown}({it:string}) if this option is specified counts are now included in the 
variable labels of the independent variables. For example, {opt label(n=)} produces 
the variable label followed by (n=#) where # is the count.

{opt labcoln}({it:string}) if this option is specified counts are now included in the variable labels
of the dependent variable. For example, {opt label(n=)} produces the variable label followed by
(n=#) where # is the count.  

{opt bold} makes the independent variable names bold face. 

{opt olines} omit lines between independent variables.

{opt otab} omit indentations from indepedent variable lables.

{opt sp} show the % symbol for all percents.

{opt chi2} display chi2 statistic for all independent variables.

{opt chidec}({it:integer}) number of decimal places for chi2 statistic. Default is 2 decimal 
places.

{opt pval} display p-value for all independent variables.

{opt pdec}({it:integer}) number of decimal places for p-value. Default is 2 decimal 
places.

{* EXCEL/CALC PATHS *}
{dlgtab:Excel/Calc Paths}

{opt excelpath}({it:string}) select the full directory for Excel to open the file from Stata. 
Default is "C:/Program Files/Microsoft Office/office*". Where * represents the current 
version of office. This option is particulary useful when Office is not on the C:\ drive.

{opt calcpath}({it:string}) select the full directory for Calc to open the file from Stata. 
Default is "C:/Program Files/OpenOffice*/program". Where * represents the current 
version of OpenOffice. This option is particulary useful when OpenOffice is not on 
the C:\ drive.

{* SVY OPTIONS *}
{dlgtab:svy options}

{opt osvy} data is not svy. No survey characteristics are set

{title:Examples}

The following uses the sample data set multistage. To access this dataset and declare 
the dataset is survey data use the following code:

{p 6 20 2}{cmd:.use http://www.stata-press.com/data/r10/multistage}{p_end} 
{p 6 20 2}{cmd:.svyset county [pw=sampwgt], strata(state) fpc(ncounties) || school, fpc(nschools)}{p_end} 

{dlgtab:Basic Syntax}

{p 6 20 2}{cmd:.tabxml, dv(county) ivd(race) ivc(weight)}{p_end} 

In this example, {cmd:tabxml} display a cross tab of county against the discrete 
independent variable race and the continuous independent variable weight in that 
specific order. Variable labels for independent variables have indentations and 
there are lines between each independent variable. The output for the discrete 
independent variables is "n (per)", similarily the output for the continuous 
independent variable is "mean (SE)". The percents are column percents and "per", 
"mean" and "SE" are all rounded to two decimal places. All data is left aligned. 
The file is saved as "tab_out.xml". The output is omitted in Stata. 

{it:Extensions:} options {opt split percent tformat save subcond justify}

{p 6 20 2}{cmd:.tabxml, dv(county) ivd(race) split(sex) save(temp) tf(1) subcond(weight>200) justify(r)}{p_end}

In this example, {cmd:tabxml} display a cross tab of county against the discrete 
independent variable race split by sex (female, male and total are the subgroups) 
for the sub population where the weight is greater than 200lbs. Variable labels for 
independent variables have indentations and there are lines between either side 
of the independent variable. The output for the discrete independent variable is 
"n (per)". The "per" is rounded to one decimal place. All data is right aligned. 
The file is saved as "temp.xml". The output is omitted in Stata. 

{it:Extensions:} options {opt options order display bold olines otab}

{p 6 20 2}{cmd:.tabxml, dv(county) ivd(race) ivc(weight) split(sex) cond(height>=400) order(weight race) options(n mean nototal) display bold olines otab}{p_end}

In this example, {cmd:tabxml} display a cross tab of county against the continuous 
independent variable weight and the discrete independent variable race in that 
specific order split by sex (female and male are the subgroups). The dataset is 
reduced where race equals one (white). Variable labels for independent variables 
do not have indentations and there are no lines between each independent variable. 
The independent variable names are bolded. The output for the discrete independent 
variables is "n", similarily the output for the continuous independent variable 
is "mean". The percents are col percents and "per", "mean" are all rounded to two 
decimal place. All data is left aligned. The file is saved as "tab_out.xml". 
The output is omitted in Stata. 

{it:Extensions:} options {opt pval chi2 pdec sp label options excelpath}

{p 6 20 2}{cmd:.tabxml, dv(county) ivd(race) options(per) display pval pdec(3) chi2 sp labrown(sample count=)}{p_end}

In this example, {cmd:tabxml} display a cross tab of county against the discrete 
independent variable race. Variable labels for the independent variable have 
indentations and there are lines either side of the  independent variable. The 
independent variable name is not bolded. The output for the discrete independent 
variable is "per". The percents are col percents and "per" are rounded to two 
decimal places. The percents are followed the % symbol. All data is left aligned. 
The file is saved as "tab_out.xml". The independet variable labels are followed 
by (sample count=#). The p-val statistic is displayed and rounded to 3 decimal 
places. The chi2 statistic is displayed and rounded to 2 decimal places. The output 
is displayed in Stata.  

{title:Authors}

{p 4 4 2}
Richard Ryall ARCSHS (Australian Research Centre in Sex, Health and Society) {break}
Email: {browse "mailto:R.Ryall@latrobe.edu.au":R.Ryall@latrobe.edu.au}

{p 4 4 2}
Jason Ferris ARCSHS (Australian Research Centre in Sex, Health and Society) {break}
Email: {browse "mailto:J.Ferris@latrobe.edu.au":J.Ferris@latrobe.edu.au}





