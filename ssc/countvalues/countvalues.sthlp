{smcl}
{* 7mar2021}{...}
{hline}
{cmd:help countvalues}
{hline}

{title:Title}

{p 8 8 2}
{hi:countvalues} {hline 2}  List counts of integer values across variables

{title:Syntax}

{p 8 17 2}{cmd:countvalues} [{varlist}]
{ifin}
{cmd:,} 
{opt val:ues(numlist)}
[
{opt variablelabels}
{opt sort(specification)}
{opt rowspos:itive} 
{opt colspos:itive} 
{opt saving(filespec)}                
{it:list_options}
]  


{title:Description}

{p 4 4 2}{cmd:countvalues} lists counts of specified integer values
across one or more numeric variables. Missing values may be specified. 

{p 4 4 2}{cmd:countvalues} ignores any string variables specified,
whether directly or indirectly.


{title:Options} 

{p 4 4 2}{cmd:values()} specifies distinct integer values that are to be
counted. It is a required option. 

{p 4 4 2}{cmd:variablelabels} specifies display of variable labels
rather than variable names. If no variable label has been defined, the
variable name is shown instead.

{p 4 4 2}{opt sort(specification)} specifies that output is to be
displayed sorted. The {it:specification} may include the keywords
{cmd:names}, {cmd:labels} and {cmd:descending},  either in full or as
any abbreviation. The {it:specification} may also include any one of the
values specified in {cmd:values()} to stipulate that output should be
sorted on the column containing counts of that value.   

{p 8 8 2}{cmd:names} specifies sorting on variable names. 

{p 8 8 2}{cmd:labels} specifies sorting on variable labels. 

{p 8 8 2}{cmd:descending} specifies that output is to be displayed
sorted, but in reverse order. Hence for example if sorting is by counts
of a specified value, the largest number will be first, which may be
useful; if sorting is on variable names or variable labels, ordering is
(for example) z before a before _ before Z before A, which seems less
likely to be useful but is allowed any way.

{p 4 4 2}{cmd:rowspositive} specifies that only rows containing one or
more positive counts for the variable concerned should be displayed.
Note that this may result in no list being displayed. 

{p 4 4 2}{cmd:colspositive} specifies that only columns containing one
or more positive counts for the value concerned should be displayed.
Note that this may result in no list being displayed. 

{p 4 4 2}{cmd:saving()} specifies that the data listed should be {help save}d
as a Stata dataset. To overwrite an existing dataset, use
{cmd:saving(}{it:filename}{cmd:, replace)}. The dataset will include both
variable names and variable labels, regardless of whether
{cmd:variablelabels} has been specified. 

{p 4 4 2}{it:list_options} are options of {help list}, which is used to
display results. Defaults include {cmd:separator(0) noobs}. 


{title:Remarks} 

{p 4 4 2}Possible applicatios include summary tabulation of 

{p 8 8 2}* indicator variables, say those with values 0, 1 or missing 

{p 8 8 2}* grade variables, say those with responses from 1 to 5  

{p 8 8 2}* missing values, whether orthodox system missing . or any of
.a to .z or idiosyncratic codes for missings such as -999  


{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. countvalues, values(.)}{p_end}
{p 4 8 2}{cmd:. countvalues, values(.) rowspos}{p_end}

{p 4 8 2}{cmd:. webuse nlswork, clear}{p_end}
{p 4 8 2}{cmd:. findname, all(inlist(@, 0, 1, .)) local(myvars)}{p_end}
{p 4 8 2}{cmd:. countvalues `myvars', values(0 1 .)}{p_end}
{p 4 8 2}{cmd:. countvalues `myvars', values(0 1 .) variablelabels sort(1 desc)}{p_end}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, UK{break}
n.j.cox@durham.ac.uk


{title:Also see}

{psee}
Online:
{manhelp tabulate_oneway R}, 
{manhelp tabulate_twoway R}, 
{manhelp table R}, 
{help findname} ({it:Stata Journal}; if installed),
{help groups} ({it:Stata Journal}; if installed),
{help missings} ({it:Stata Journal}; if installed),
{help tabcount} (SSC; if installed),
{help tabm} (SSC; if installed) 
{p_end}

