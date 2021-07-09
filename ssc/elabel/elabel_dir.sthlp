{smcl}
{cmd:help elabel dir}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel dir} {hline 2} List names of value labels


{title:Syntax}

{p 8 12 2}
{cmd:elabel {ul:di}r} [ {it:pattern} ] [ {cmd:,} {it:options} ]


{p 4 10 2}
where {it:pattern} is a single string, possibly containing the wildcard 
characters {cmd:*} and {cmd:?}.


{title:Description}

{pstd}
{cmd:elabel dir} lists, and returns in {cmd:r()}, the names of value 
labels in memory and, optionally, value labels not in memory but attached 
to variables in the dataset.

{pstd}
If {it:pattern} is specified, only value label names matching {it:pattern} 
are listed and returned; see {helpb strmatch()}.


{title:Options}

{phang}
{opt nomem:ory} additionally lists and returns value label names attached 
to variables but not yet defined in memory. The option respects multilingual 
datasets (see {help label language}). Additional results are returned in 
{cmd:r()}.

{phang}
{opt cur:rent} is for use with, and implies, {opt nomemory} and lists not 
yet defined value labels in the current label language only. 


{title:Examples}

{pstd}
Load example dataset

{phang2}{stata sysuse nlsw88:. sysuse nlsw88}{p_end}

{pstd}
Attach an undefined value label to variable {cmd:age}

{phang2}{stata label values age agelbl:. label values age agelbl}{p_end}

{pstd}
List all value label names

{phang2}{stata elabel dir , nomemory:. elabel dir , nomemory}{p_end}


{title:Saved results}

{pstd}
{cmd:elabel dir} saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(names)}}value label names in memory (same as 
{helpb label:label dir})
{p_end}


{pstd}
With the {opt nomemory} option, {cmd:elabel dir} aditionally 
saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synopt:{cmd:r(used)}}label names in memory and attached to 
at least one variable
{p_end}
{synopt:{cmd:r(undefined)}}label names not in memory but attached to 
at least one variable
{p_end}
{synopt:{cmd:r(orphans)}}label names in memory but not attached 
to any variable
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb label}, {helpb label language}{p_end}

{psee}
if installed: {help elabel}
{p_end}
