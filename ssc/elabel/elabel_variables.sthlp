{smcl}
{cmd:help elabel variable}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel variable} {hline 2} Label variables


{title:Syntax}

{p 4 10 2}
Basic syntax

{p 8 12 2}
{cmd:elabel} {cmdab:var:iable} 
{varname} [ {cmd:"}{it:label}{cmd:"} 
[ {varname} [ {cmd:"}{it:label}{cmd:"} 
[ {it:...} ] ] ] ] 


{p 4 10 2}
Extended syntax

{p 8 12 2}
{cmd:elabel} {cmdab:var:iable}
{cmd:(}{varlist}{cmd:)}
{cmd:(}{it:{help elabel_variables##lblspec:lblspec}}{cmd:)}

{p 8 12 2}
{cmd:elabel} {cmdab:var:iable}
{varlist}
{cmd:=}
{helpb elabel_variable##fcn:{it:fcn}}{opt (arguments)}
[ {cmd:,} {it:options} ]


{marker lblspec}{...}
{p 4 10 2}
where {it:lblspec} is one of 
{cmd:"}{it:label}{cmd:"} [ {cmd:"}{it:label}{cmd:"} {it:...} ], or,
{cmd:=}{it:{help elabel##elabel_eexp:eexp}}

{marker fcn}{...}
{p 4 8 2}
{it:fcn}() is an 
{help elabel_functions##fcnsvar:{bf:elabel} (pseudo-)function} and 
{it:arguments} are function specific


{title:Description}

{pstd}
{cmd:elabel variable} attaches variable labels to variables, removes variable 
labels from variables, and modifies variable labels attached to variables.

{pstd}
In the basic syntax, omit the rightmost {it:label} to remove any variable 
label from the rightmost variable. In general, specify {bf:""} as a 
{it:label} to remove a variable label.

{pstd}
In the second (first extended) syntax, specify as many {it:labels} as there 
are variables in {it:varlist}; the mapping of {it:labels} to {it:varlist} is 
one-to-one. If only one {it:label} is specified, this {it:label} is attached 
to all variables in {it:varlist}; this is useful for removing variable 
labels from variables.  

{pstd}
In the second (first extended) syntax, specify an {it:eexp} to modify 
variable labels. In {it:eexp}, the {cmd:@} character is replaced with the 
variable label that is currently attached to the respective variable in 
{it:varlist}. The {cmd:#} character may not be specified.

{pstd}
In the third (second extended) syntax, you specify an 
{help elabel_functions:{bf:elabel} (pseudo-)function} 
to manipulate variable labels. See 
{help elabel_functions##fcnsvar:{bf:elabel} (pseudo-)functions} 
for a list of available (pseudo-)functions.

{pstd}
In the extended syntax, you cannot repeat variable names.


{title:Examples}

{pstd}
Load example dataset

{phang2}{stata sysuse nlsw88:. sysuse nlsw88}{p_end}

{pstd}
Change variable labels for {cmd:age} and {cmd:tenure} 

{phang2}{stata elabel variables age "Age" tenure "Job tenure (in years)":. elabel variable age "Age" tenure "Job tenure (in years)"}{p_end}

{pstd}
Do the same as above

{phang2}{stata elabel variables (age tenure) ("Age" "Job tenure (in years)"):. elabel variable (age tenure) ("Age" "Job tenure (in years)")}{p_end}

{pstd}
Remove variable labels from all variables

{phang2}{stata elabel variables (_all) (""):. elabel variable (_all) ("")}{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb label}
{p_end}

{psee}
if installed: {help elabel}
{p_end}
