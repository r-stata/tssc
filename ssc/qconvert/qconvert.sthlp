{smcl}
{* *! Version 1.10 04JUN2019}{...}

{title:Title}

{phang}
{bf:qconvet} {hline 2} Q-sort conversion program
    

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:qcon:vert} {varlist} {ifin}
{cmd:,}
{cmdab:save(string)}  

{p}
{bf:varlist} includes raw Q-sorts that need to be converted to ranks appropriate for factor-analysis.


{title: Description}

{pstd}
{cmd:qconvert} coverts the raw Q-sort file into a new Q-sort file which is ready for analysis by qfactor program. 
The raw data file should include one variable named "{bf:ranking}" which shows the rankings based on the Q-sort table 
from the left (e.g. -4 -4) to the right (e.g. +4 +4). 
This variable should have the same number of entries as the number of statements (Q-sample or Q-set). The other variables are raw Q-sorts.

{pstd}
To create your raw data file in Stata and convert it to a new file ready for Q-analysis by {cmd:qfactor} program follow these steps:  

{phang}
1.	Enter rankings of the q-sort table from left to right into a Stata column as a variable, e.g. 2 times -4, 3 time -3,..., 2 times +4.

{phang}
2.	Then, enter each Q-sort table as one separate variable: Enter the statement numbers in the 
same order as item 1, i.e. as they appear in the Q-sort table from left to right (see the example). 

{phang}
3.	Then, by summarizing all qsorts you can check if they were entered correctly, for instance 
using “sum qsort*” you can check if all qsorts have the same mean, sd, min, and max values; if different, inspect the qsort(s) and fix it.

{phang}
4.	After completing your raw data file you can use qconvert to convert your raw data file into a file usable by {cmd:qfactor}.

{phang}
5.	After running qconvert you need to add another variable into your new generated data file. 
This variable contains the statements and should be named “statement”. 
Then, your new file is ready for Q-analysis using {cmd:qfactor}.


{title:Saved files}

{phang}
{cmd:qconvert} saves the converted data as a new Stata file (as specified in your syntax) in your {ul:working directory}. For example;

{phang2}
{cmd:Qconvert qsort1-qsort25, save(newQsort)}

{phang}
saves the converted data in newQsort.dta file.


{title:Example}

{phang}
1-	rawQsort.dta includes three raw Q-sorts and the ranking table for 40 statements. 
Using the following commands it reads the raw data, coverts, and saves them into 
a new file (called new1.dta: this name is up to you to choose!)

{phang2}
{bf:qconvert qsort*, save(new1)}

{phang2}
or

{phang2}
{bf:qconvert qsort1-qsort3, save(new1)}


{title:Author}

{pstd}
{bf:Noori Akhtar-Danesh} ({ul:daneshn@mcmaster.ca}), McMaster University, Hamilton, CANADA


