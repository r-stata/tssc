{smcl}
{* *! version 0.1.3  05aug2015}{...}
{viewerjumpto "Syntax" "basetable##syntax"}{...}
{viewerjumpto "Basetable varlist" "basetable##varlist"}{...}
{viewerjumpto "Basetable options" "basetable##options"}{...}
{viewerjumpto "Examples" "basetable##examples"}{...}


{title:Title}
{p2colset 5 10 22 2}{...}
{p2col :} Comparing a set of risk factors or effects with respect to a 
categorical variable - basetable{p_end}
{p2colreset}{...}


{title:Summary}
{p2colset 5 10 10 2}{...}
{p2col :}The command basetable is a simpel yet highly efficient tool for 
interactively building the first table required in most medical/epidemiological 
papers.{p_end}

{p2col :}The typical layout of these tables is grouping (categorical) variable 
as column header and then a set of rows of different variables being compared by 
each group in the header and in a total.{p_end}

{p2col :}The tables can of course also be used for survey analysis.{p_end}

{p2col :}When the interactive table building is over, the result can be inserted 
into one or more sheets in a excel workbook.{p_end}
{p2col :}If the labelling of variables and values have been done carefully the 
table outputs in the excel workbooks will be almost publication ready.{p_end}

{p2col :}The command {cmd:basetable} works from Stata 12 and onwards
except for the option toxl. In Stata version 12 use the option {opt s:tyle(csv)} 
and the modifier [help using:using} to specify a csv file to save the csv 
output in.{p_end}

{p2col :}Take a good look at the {help basetable##examples:examples} below to 
see how to use the command.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}{cmd:basetable} {it:column_variable} 
	[{it:{help basetable##summary_variables:summary_variables}}] [if] [in] [using]
	[{cmd:,} {it:{help basetable##options:options}}]
{p_end}

{synoptset 24 tabbed}{...}
{marker summary_variables}{...}
{synopthdr:Arguments}
{synoptline}
	{synopt :{opt column_variable}} The first argument must be a categorical 
	variable with a value label.{p_end}
	{synopt :{opt summary_variables}} The rest of the arguments are variable 
	names followed by with suboptions inside braces. 
	{break}Suboptions:{break}
	* Headers (in square brackets){break}
	  - Header text possibly ending with a hashtag (#) for a subcount separated by 
	    a comma (,) optionally a separator text for the rest of the columns and 
		optionally a local if condition ( The subcount from the hashtag matches 
		the condition){break}
	* Categorical variables:{break}
	  - 0, r, R = Report row percentages in the report table{break}
	  - 1, c, C = Report column percentages in the report table{break}
	  - label value = Show only the row for the selected value in the report table.{break}
	    There can a second argument separated by a comma: 0, r, R, 1, c, C as 
		above or a ci for a Wald confidence interval{break} 
	* continuous variables:{break}
	  - a numeric format(eg %6.2f) and eventually a local report specification (sd, iqr, iqi, ci or pi) separated with a comma {break}
	{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 24 tabbed}{...}
{marker options}{...}
{synopthdr:options}
{synoptline}
	{synopt :{opt l:og}}Show the underlying Stata output{p_end}
	{synopt :{opt n:thousands}}Add thousands separator to n values{p_end}
	{synopt :{opt pc:tformat}}Alter the format used for the percentages for the 
	categorical summary variables. The argument must be a numeric format{p_end}
	{synopt :{opt pv:format}}Alter the format used for the P value. 
	The argument must be a numeric format. There is suboption {opt t:op} placing 
	the p-value at the top{p_end}
	{synopt :{opt c:ontinuousreport}}Specify overall default continuous report. 
				The values must be one of sd, iqr, iqi, ci or pi{p_end}
	{synopt:{opt cap:tion(string)}} Caption for the basetable output.{p_end}
	{synopt:{opt to:p(string)}} String containing text prior to table content.
	Default is dependent of the value of the style option.{p_end}
	{synopt:{opt u:ndertop(string)}} String containing text between header and table 
	content.
	Default is dependent of the value of the style option.{p_end}
	{synopt:{opt b:ottom(string)}} String containing text after to table content.
	Default is dependent of the value of the style option.{p_end}
	{synopt :{opt m:issing}}Show missing report to the right of the table{p_end}
	{synopt :{opt sm:all}}Specify the limit for being small wrt. hidesmall. Default is 5{p_end}
	{synopt :{opt h:idesmall}}Hide data when count values are less than small (default 5). 
		{red: Note that the number less than "small" sometimes can be deduced from surrounding values}{p_end}
	{synopt:{opt smo:othdata}} Option for blurring continuous variables. 
	Blurring is sorting and then averaging over the nearest values.{p_end}
	{synopt :{opt st:yle}}The output can be shown in the formats: smcl, 
		csv, html, latex or tex, or md. The default is smcl{p_end}
	{synopt :{opt r:eplace}}The styled output can be saved into a file specified by using.{break}
	If an existing file should be replaced in the process, replace should be set{p_end}
	
	
{synopthdr:version 13 and up}
	{synopt :{opt t:oxl}}The argument is a string 
	containing 4 values separated by a comma. The values needed are:{break}
	* path and filename on the excel book to use{break}
	* the sheet name to use{break}
	* (Optional) the row number in the sheet to place the table in. Must always appear with the column number{break}
	* (Optional) the column number in the sheet to place the table in. Must always appear with the row number{break}
	* (Optional) replace - replace/overwrite the content in the sheet
	{p_end}
{synoptline}
{p2colreset}{...}


{marker examples}{...}
{title:Examples}

{phang}Retrieve a sample dataset:{p_end}
{phang}{stata `"use low age race ftv smoke using "http://www.stata-press.com/data/r12/hospid2.dta", clear"'}{p_end}
{phang}Variable labels are always required. Value labels are required for a 
categorical presentation:{p_end}
{phang}{stata `"label define low 0 "Normal" 1 "Low""'}{p_end}
{phang}{stata `"label values low low"'}{p_end}
{phang}{stata `"label define ftv 0 "0 visits" 1 "1 visit" 2 "2 visits" 3 "3 visits" 4 "4 visits" 5 "5 visits" 6 "6 visits""'}{p_end}
{phang}{stata `"label values ftv ftv"'}{p_end}
{phang}Creating a sample dataset with labels and missings:{p_end}
{phang}{stata `"replace low = . in 4/6"'}{p_end}
{phang}{stata `"replace age = . in 5/8"'}{p_end}
{phang}{stata `"replace race = . in 3/8"'}{p_end}
{phang}Generate a significant test to demonstrate the use less than signs at 
P values:{p_end}
{phang}{stata `"replace age = age + 2 if !low"'}{p_end}

{phang}A basetable example showing the main features:{p_end}

{phang}basetable low ///{break}
	[** continuous presentation, ***] age(%6.2f) age(%6.2f,sd) age(%6.2f, ci) ///{break}
	[** Categorical presentation, ***] race(c) race(r) race(white) race(white,r) race(white,ci) ///{break}
	[** Hiding small counts, ***] ftv(c) using tmp.smcl, missing toxl(tmp.xls, Table 1, replace) hide
	
---------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                         Normal                   Low                 Total         P-value  Missings / N (Pct)
---------------------------------------------------------------------------------------------------------------------------------------------------------------
n (%)                                                                127 (68.3)             59 (31.7)           186 (100.0)                      3 / 189 (1.59)
** continuous presentation                                                  ***                   ***                   ***             ***                 ***
age of mother, mean (sd)                                           25.66 (5.55)          22.31 (4.51)          24.58 (5.46)            0.01      4 / 189 (2.12)
age of mother, mean (sd)                                           25.66 (5.55)          22.31 (4.51)          24.58 (5.46)            0.01      4 / 189 (2.12)
age of mother, mean (95% ci)                               25.66 (24.68; 26.63)  22.31 (21.15; 23.46)  24.58 (23.79; 25.37)            0.01      4 / 189 (2.12)
** Categorical presentation                                                 ***                   ***                   ***             ***                 ***
race, n (%)                                                                                                                                                    
  white, n (%)                                                        71 (57.3)             23 (39.0)             94 (51.4)                                    
  black, n (%)                                                        14 (11.3)             11 (18.6)             25 (13.7)                                    
  other, n (%)                                                        39 (31.5)             25 (42.4)             64 (35.0)            0.06      6 / 189 (3.17)
race, n (%)                                                                                                                                                    
  white, n (%)                                                        71 (75.5)             23 (24.5)            94 (100.0)                                    
  black, n (%)                                                        14 (56.0)             11 (44.0)            25 (100.0)                                    
  other, n (%)                                                        39 (60.9)             25 (39.1)            64 (100.0)            0.06      6 / 189 (3.17)
race (white), n (%)                                                   71 (57.3)             23 (39.0)             94 (51.4)                      6 / 189 (3.17)
race (white), n (%)                                                   71 (75.5)             23 (24.5)            94 (100.0)                      6 / 189 (3.17)
race (white), % (95% ci)                                      57.3 (48.6; 66.0)     39.0 (26.5; 51.4)     51.4 (44.1; 58.6)  6 / 189 (3.17)      6 / 189 (3.17)
** Hiding small counts                                                      ***                   ***                   ***             ***                 ***
number of visits to physician during 1st trimester, n (%)                                                                                                      
  0 visits, n (%)                                                     62 (48.8)             36 (61.0)             98 (52.7)                                    
  1 visit, n (%)                                                      35 (27.6)             11 (18.6)             46 (24.7)                                    
  2 visits, n (%)                                                     23 (18.1)              7 (11.9)             30 (16.1)                                    
  3 visits, n (%)                                                       < 5 (.)               < 5 (.)              < 10 (.)                                    
  4 visits, n (%)                                                       < 5 (.)               < 5 (.)              < 10 (.)                                    
  6 visits, n (%)                                                       < 5 (.)               0 (0.0)               < 5 (.)            0.30      0 / 189 (0.00)
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Table send to Excel succesfully...

{browse "http://www.bruunisejs.dk/StataHacks/My%20commands/basetable/basetable_demo/":To see more examples}


{title:Authors and support}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	nhbr@ph.au.dk
{p_end}
