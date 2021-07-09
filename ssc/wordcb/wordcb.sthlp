{smcl}
{* *! version 1.2  3 dec 2019}{...}

{title:Title}

{phang}
{bf:wordcb} {hline 2} Create Microsoft Word formatted codebook


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:wordcb}
[{varlist}]
{cmd: using,}
[{it:, options}]

{cmd:using} {it:filename} specifies the output Microsoft Word file and is required.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt varlist}}any Stata variable list; default is all variables{p_end}
{synopt:{cmdab:val:ues(#)}}number of unique values to display in tables; default is 5. Zero is allowed and omits values from the output {p_end}

{syntab:Control sort order}
{synopt:{cmdab:sortf:req}({it:varlist})}sort frequency distribution table descending by frequency for specified {it:varlist}; must be either the same as the main {it:varlist} or a subset of the main {it:varlist}{p_end}
{synopt:{cmdab:sortv:alues}({it:varlist})}sort frequency distribution table ascending by values for specified {it:varlist}; must be either the same as the main {it:varlist} or a subset of the main {it:varlist}{p_end}

{syntab:Suppress elements in output file}
{synopt:{opt nodta}}suppress display of file metadata{p_end}
{synopt:{cmdab:f:reqonly}({it:varlist})}suppress display of mean, standard deviation, and percentiles
for specified {it:varlist}; must be either the same as the main {it:varlist} or a subset of the main {it:varlist}{p_end}

{syntab:Output file save options}
{synopt:{opt replace}}replaces destination Microsoft Word file{p_end}
{synopt:{opt append}}appends result to destination Microsoft Word file{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:wordcb} Creates a Microsoft Word file similar to output from the the built-in command
{cmd:codebook}.  The output file is useful for deposit in data archives or for initial data exploration.


{marker remarks}{...}
{title:Remarks}

{pstd}
This command aids in creating documentation suitable for archiving datates.
{cmd:wordcb} uses {cmd:putdocx}, new in Stata 15, to create a Microsoft Word 
formatted codebook of the dataset im memory.  {p_end}

{pstd}
The resulting Word file includes metadata about the data file including 
the data file name, data label, and data notes, followed by a pagebreak. {p_end}

{pstd}
For each variable specified in the varlist, {cmd:wordcb} creates a table containing a header with 
the varname, type, label, format, number of unique values, number of observations
with missing values, and variable notes (if present).  

{pstd}
A frequency distribution for each variable specified in 
the varlist is also displayed.  The number of values displayed in the frequency distribution
can be limited by the {cmdab:val:ues(#)} option.  By default, five random values are shown.  
When {cmdab:val:ues(#)} is zero, values, mean, standard deviation, and percentiles are omitted. {p_end}

{pstd}
What is displayed in the frequency distribution is controlled by  either the {cmdab:sortf:req}({it:varlist}) or the {cmdab:sortv:alues}({it:varlist}) 
option.  Variables in the {cmdab:sortf:req}({it:varlist}) option are sorted descending by frequency; variables in the 
{cmdab:sortv:alues}({it:varlist}) option are sorted ascending by value.

{marker Limits}{...}
{title:Limits}
{pstd}
Users wanting different numbers of {cmdab:val:ues(#)} for different variables should invoke
{cmd:wordcb} multiple times, with the {opt nodta} option and {opt append} option on the second and 
subsequent runs. {p_end}

{pstd}
{cmd:wordcb} uses {cmd:putdocx}, and is therefore subject to the same limitations as {cmd:putdocx}, most
importantly, the amount of RAM allocated to Java in Stata.  Java heap limits and other out of memory 
errors will occur when a large number of values, and/or a large number of variables are specified, and/or
a large or complex Microsoft Word file is appended to.  {p_end}

{pstd} 
The suggested workaround is to invoke {cmd:wordcb} multiple times, with the {opt nodta} option on the second and 
subsequent runs, then combine the output in Microsoft Word.  
{p_end}

{marker Author}{...}
{title:Author}
{pstd}
Troy Payne {p_end}
{pstd}
Alaska Justice Information Center and University of Alaska Anchorage {p_end}
{pstd}
tpayne9@alaska.edu {p_end}

{pstd}
Thanks to Andrew Gonzalez & Araceli Valle at the Alaska Justice Information Center and 
Winnie Hua at Corrona for testing and early comments. {p_end}

