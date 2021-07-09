{smcl}
{cmd:help elabel varvaluelabel}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel varvaluelabel} {hline 2} Attach value labels to variables


{title:Syntax}

{p 8 12 2}
{cmd:elabel varvaluelabel}
[ {cmd:(} {it:varname} [{it:varname ...}] {it:lblname} {cmd:)} {it:...} ]
[ {cmd:, nofix} ]


{p 4 8 2}
where {it:varname} must be a valid Stata name; wildcard characters are 
not allowed. {it:varname} need not be a variable. If {it:varname} is not 
a variable or {it:varname} is a string variable, it is ignored.

{p 4 8 2}
{it:lblname} must be a valid Stata name. {it:lblname} need not be a value 
label.

{p 4 8 2}
Parentheses must be typed.


{title:Description}

{pstd}
{cmd:elabel varvaluelabel} attaches value labels to variables. Typical 
usage is

{p 10 12 2}
{cmd:program elabel_cmd_{it:cmd}}
{p_end}
{p 14 16 2}
{cmd:version {ccl stata_version}}
{p_end}
{p 14 16 2}
{helpb elabel_parse:elabel parse} {cmd:elblnamelist(varvaluelabel) [ , noFIX ] : `0'}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 14 16 2}
{cmd:elabel varvaluelabel `varvaluelabel' , `fix'}
{p_end}
{p 10 12 2}
{cmd:end}

{title:Options}

{phang}
{opt nofix} is the same as {opt nofix} with {help label:label values}.


{title:Examples}

{pstd}
None.


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}{p_end}

{psee}
if installed: {help elabel}
{p_end}
