{smcl}
{cmd:help elabel values}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel values} {hline 2} Attach value labels to variables


{title:Syntax}

{p 4 10 2}
Basic syntax

{p 8 12 2}
{cmd:elabel {ul:val}ues}
{varlist}
[ {it:{help elabel##elblnamelist:elblname}}|{cmd:.} ]
[ {cmd:, nofix} ]


{p 4 10 2}
Extended syntax

{p 8 12 2}
{cmd:elabel {ul:val}ues}
{cmd:(}{varlist}{cmd:)}
{cmd:(}{{it:{help elabel##elblnamelist:elblname}}|{cmd:.}}
[ {{it:{help elabel##elblnamelist:elblname}}|{cmd:.}} {it:...} ]{cmd:)}
[ {cmd:, nofix} ]


{title:Description}

{pstd}
{cmd:elabel values} attaches a value label to the variables in 
{it:varlist}. Specifying {cmd:.} instead of {it:elblname} detaches 
any value label from {it:varlist}; value labels are not deleted from 
memory. 

{pstd}
In the basic syntax, if {it:varlist} is a single token, such as {varname}, 
{cmd:_all}, or {it:{help varname:varname{sf:-}varname}}, specifying 
{cmd:.} is the same as omitting {it:elblname}.

{pstd}
In the extended syntax, specify as many {it:elblnames} as there are 
variables in {it:varlist}; the mapping of {it:elblnames} to varlist 
is one-to-one. 


{title:Options}

{phang}
{opt nofix} is the same as {opt nofix} with {help label:label values}.


{title:Examples}

{pstd}
Load example dataset

{phang2}
{stata sysuse nlsw88:. sysuse nlsw88}
{p_end}

{pstd}
Define value label {cmd:yesno}

{phang2}
{stata elabel define yesno 0 "no" 1 "yes":. elabel define yesno 0 "no" 1 "yes"}
{p_end}

{pstd}
Attach value label {cmd:yesno} to variable {cmd:south}

{phang2}
{stata elabel values south yesno:. elabel values south yesno}
{p_end}

{pstd}
Attach the value label associated with {cmd:south} to variable {cmd:c_city}

{phang2}
{stata elabel values c_city (south):. elabel values c_city (south)}
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
if installed: {help elabel}, {help elabel_varvaluelabel:elabel varvaluelabel}
{p_end}
