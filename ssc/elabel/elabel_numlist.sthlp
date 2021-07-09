{smcl}
{cmd:help elabel numlist}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel numlist} {hline 2} Parse numeric list


{title:Syntax}

{p 8 12 2}
{cmd:elabel numlist} 
{cmd:"}{it:{help numlist}}{cmd:"} [ {cmd:,} {it:options} ]


{p 4 10 2}
where {it:numlist} contains {it:{help numlist:numlist_elements}} 
and may contain sequences of missing value codes, such as 
{cmd:.a/.c} and {cmd:.a(3).o}.


{title:Description}

{pstd}
{cmd:elabel numlist} expands a numeric list including sequence 
operators. The command is similar to Stata's {helpb nlist:numlist} 
command but additionally expands sequences of (extended) missing value 
codes, such as {cmd:.a/.c}, treating the distance between successive 
missing value codes as 1. 

{pstd}
Only integer values or extended missing values are allowed in 
{it:numlist}; real values and system missing values ({cmd:.}) are 
not allowed.


{title:Options}

{phang}
{opt real:ok} allows real values in {it:numlist}.

{phang}
{opt sysmis:sok} allows system missing values in {it:numlist}.

{phang}
{opt l:ocal(lmacname)} stores the expanded {it:numlist} in local macro 
{it:lmacname}; nothing is returned in {cmd:r()}.


{title:Examples}

{phang2}
{stata elabel numlist "42 .a/.c":. elabel numlist "42 .a/.c"}
{p_end}
{phang2}
{stata display "`r(numlist)'":. display "`r(numlist)'"}
{p_end}


{title:Saved results}

{pstd}
{cmd:elabel numlist} saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(numlist)}}expanded {it:numlist}
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}, {help label language}{p_end}

{psee}
if installed: {help elabel}
{p_end}
