{smcl}
{* 18mar2021}{...}
{hline}
{cmd:help myaxis}
{hline}

{title:Title}

{p 8 8 2}
{hi:myaxis} {hline 2}  Reorder categorical variable by specified sort criterion 

{title:Syntax}

{p 8 17 2}{cmd:myaxis} {it:newvar}{cmd:=}{it:varname}
{ifin}
{cmd:,} 
{opt sort(criterion)} 
[
{opt subset(true_or_false_condition)} 
{opt miss:ing} 
{opt desc:ending} 
{opt varlabel(string)} 
{opt valuelabelname(string)} 
]


{title:Description}

{p 4 4 2}{cmd:myaxis} maps an existing "categorical" variable, meaning
usually a numeric variable with integer codes and value labels, or
equivalently a string variable, to a new variable with integer values 1
up and with value labels, sorted according to a specified criterion.


{title:Remarks}  

{p 4 4 2}The command name {cmd:myaxis} is to be parsed "my axis". The
second element "axis" arises from a leading application of the command.
You have a categorical variable that would define an axis of a graph, or
one dimension of a table (the rows, or the columns, say), but the
existing order of categories is not ideal. Some graph and table commands
offer sorting on the fly, but this command may help wherever other
commands do not offer that.

{p 4 4 2}The first element "my" is at best harmless whimsy, but arises
because a command named just {cmd:axis} would be harder to spot among
other uses of the term. If you find it irritating or annoying, clone and
rename the command. Now it's yours, modulo your use of my work. 

{p 4 4 2}The problem is split by {cmd:myaxis} into these parts: 

{p 8 8 2}1. Calculation of a numeric variable on which to sort
categories.  {cmd:myaxis} treats this as an application of {help egen}.
Note: If a variable already exists that defines the sort order and is
constant within categories, then asking for (say) its minimum, mean, or
maximum within each category will suffice. 

{p 8 8 2}2. Deciding whether you want ascending order (the default) or
descending order (highest value goes first). Descending order requires
negation of the variable from #1. 

{p 8 8 2}3. Mapping your categorical variable to integers 1 up. The
{cmd:group()} function of {help egen} does the work here, but
{cmd:myaxis} is careful to split ties according to the original
variable. (For example: suppose nominal categories A, B, C, D, E have
frequencies 7, 7, 42, 3, 1 and you want them sorted by frequency. You
don't want A and B lumped together because they have the same
frequency.) 

{p 8 8 2}4. Fixing a variable label. {cmd:myaxis} uses a new variable
label if supplied; otherwise, the original variable label; and, if that
does not exist, the original variable name. 

{p 8 8 2}5. Fixing value labels. This is even more important than #4 for
helpful display in a graph or table. 
{cmd:myaxis} uses the original value labels if defined and otherwise the
original string or numeric values.  


{title:Options} 

{p 4 4 2}{cmd:sort()} specifies the criterion for sorting. It is a
required option. The criterion should always include the name of an
{help egen} function. The function may be community-contributed so long
as the code is visible along your {help adopath}. The criterion may also
include the name of an existing variable and that is essential whenever
the sort criterion is not based on {it:varname}.  

{p 4 4 2}{cmd:subset()} specifies a subset of the data on which the sort
criterion should be calculated. Concretely, imagine two variables that
define {it:y} and {it:x} axes of a graph or rows and columns of
a table. You might want rows to be sorted by values calculated for a particular
column, or columns to be sorted by values calculated for a particular
row. 

{p 4 4 2}{cmd:missing} specifies that missing values of {it:varname} are to be
included. The default is to ignore them. 

{p 4 4 2}{cmd:descending} specifies sorting with highest value first. 
The default sort order is ascending, with lowest value first.  

{p 4 4 2}{cmd:varlabel()} specifies a variable label for the new
variable. Otherwise see #4 in the Remarks. 

{p 4 4 2}{cmd:valuelabelname()} specifies a new value label name for the
value labels of the new variable. This will be needed if there is
already a set of value labels called {it:newvar}. 
 

{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}

{p 4 8 2}{cmd:. myaxis wanted=rep78, sort(count) descending}{p_end}
{p 4 8 2}{cmd:. tab wanted}{p_end}
{p 4 8 2}{cmd:. tab wanted, nola}{p_end}

{p 4 8 2}{cmd:. myaxis wanted2=rep78, sort(mean mpg) descending}{p_end}
{p 4 8 2}{cmd:. format mpg %2.1f}{p_end}
{p 4 8 2}{cmd:. tab wanted2, su(mpg)}{p_end}

{p 4 8 2}{cmd:. myaxis wanted3=rep78, sort(mean mpg) subset(foreign==1) descending}{p_end}
{p 4 8 2}{cmd:. tab wanted3 foreign , su(mpg) nost nofreq}{p_end}

{p 4 8 2}{cmd:. webuse nlsw88, clear}{p_end}

{p 4 8 2}{cmd:. myaxis wanted=industry, sort(median wage) descending}{p_end}
{p 4 8 2}{cmd:. tabstat wage, s(median mean) by(wanted) format(%3.2f)}{p_end}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, UK{break}
n.j.cox@durham.ac.uk


{title:Also see}

{psee}
Online:
{manhelp egen D}, 
{manhelp tabulate_oneway R}, 
{manhelp tabulate_twoway R}, 
{manhelp graph_dot G-2}, 
{manhelp graph_bar G-2}, 
{help labmask} ({it:Stata Journal}; if installed),
{help egenmore} (SSC; if installed), 
{help tabplot} ({it:Stata Journal}; if installed),
{help stripplot} (SSC; if installed)  
{p_end}

