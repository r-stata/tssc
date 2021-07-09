{smcl}
{cmd:help elabel rename}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel rename} {hline 2} Rename value labels


{title:Syntax}

{p 4 10 2}
Rename single value label

{p 8 12 2}
{cmd:elabel {ul:ren}ame}
{it:oldlblname}
{it:newlblname}
[ {cmd:,} {it:options} ]


{p 4 10 2}
Rename groups of value labels

{p 8 12 2}
{cmd:elabel {ul:ren}ame}
{cmd:(}{it:oldlbl1} [ {it:oldlbl2 ...} ]{cmd:)}
{cmd:(}{it:newlbl1} [ {it:newlbl2 ...} ]{cmd:)}
[ {cmd:,} {it:options} ]

{p 8 12 2}
{cmd:elabel {ul:ren}ame}
{it:oldlblnamelist}
[ {cmd:,} {{opt upper}|{opt lower}|{opt proper}} {it:options} ]


{p 4 10 2}
where {it:oldlblname} and {it:oldlbl1}, {it:oldlbl2}, {it:...} may 
contain the wildcard characters {cmd:*}, {cmd:?}, and {cmd:#}; these 
wildcards are explained 
{help elabel_rename##wildcards:below}.

{p 4 10 2}
{it:newlblname} and {it:newlbl1}, {it:newlbl2}, {it:...}  may 
contain the wildcard characters {cmd:*}, {cmd:?}, {cmd:#}, 
{cmd:.}, and {cmd:=}; these wildcards are explained 
{help elabel_rename##wildcards:below}.


{marker wildcards}{...}
{p 4 10 2}
The wildcard characters in {it:oldlblname} and {it:newlblname} have 
the following meaning

{col 11}wildcard{col 28}means in{col 55}means in
{col 11}character{col 28}{it:oldlblname}{col 55}{it:newlblname}
{col 11}{hline 67}
{...}
{col 11}{cmd:*}{col 28}0 or more characters{...}
{col 55}copy matched characters
{...}
{col 11}{cmd:?}{col 28}exactly one character{...}
{col 55}copy matched character
{col 11}{cmd:#}{col 28}1 or more digits{...}
{col 55}copy matched digits
{...}
{col 11}{cmd:(#}[{cmd:#}{it:...}]{cmd:)}{col 28}exactly one{...} 
[two, {it:...}]{col 55}copy matched digits and
{...}
{col 29}digit(s){col 56}possibly reformat
{...}
{col 11}{cmd:.}{...}
{col 55}skip corresponding
{col 56}wildcard in {it:oldlblname}
{...}
{...}
{col 11}{cmd:=}{...}
{col 55}copy {it:oldlblname}
{col 11}{hline 67}


{title:Description}

{pstd}
{cmd:elabel rename} changes the names of value labels; the 
integer-to-text mappings in value labels remain unchanged; new 
value label names are attached to all variables that previously 
had old value label names attached. 

{pstd}
{cmd:elabel rename} follows rules 1-14 described in 
{helpb rename_group:rename group} (Stata release 12 or higher).


{title:Options}

{phang}
{opt nomem:ory} treats old value label names attached to variables 
as if they were defined in memory.  

{phang}
{opt force} allows {it:oldlblname} to be renamed {it:newlblname} 
even if {it:newlblname} is already attached to variables in the 
dataset. {it:newlblname} must not be defined in memory.

{phang}
{opt u:pper}, {opt l:ower}, and {opt p:roper} change value label names 
to be all lowercase, all uppercase, or the first letter uppercase and 
the remaining letters lowercase.

{phang}
{opt d:ryrun} does not rename value labels but shows the mapping of 
old label names to new label names.


{title:Technical note}

{pstd}
If the wildcard character {cmd:#} is specified or if any wildcard characters 
are used in {it:newlbl1}, {it:newlbl2}, {it:...}, the respective wildcard 
characters in {it:oldlbl1}, {it:oldlbl2}, {it:...} are internally matched 
using {help f_regexm:regular expressions}. The mapping from wildcards to 
regular expressions is as follows

{col 11}wildcard{col 28}regular
{col 11}character{col 28}expression
{col 11}{hline 48}
{col 11}{cmd:*}{col 28}{cmd:.*}{col 44}if no {cmd:#} follows
{col 28}{cmd:[^0-9]*} {col 44}if    {cmd:#} follows
{col 11}{cmd:?}{col 28}{cmd:.}{col 44}if no {cmd:#} follows
{col 28}{cmd:[^0-9]}  {col 44}if    {cmd:#} follows
{col 11}{cmd:#}{col 28}{cmd:[0-9]+}
{col 11}{cmd:(#}[{cmd:#}{it:...}]{cmd:)}{col 28}{cmd:[0-9]}[{cmd:[0-9]}{it:...}]
{col 11}{hline 48}


{title:Examples}

{pstd}
Load example dataset

{phang2}
{stata sysuse nlsw88:. sysuse nlsw88}
{p_end}

{pstd}
Change the value label name {cmd:occlbl} to {cmd:occup}

{phang2}
{stata elabel rename occlbl occup:. elabel rename occlbl occup}
{p_end}

{pstd}
Remove the suffix {cmd:lbl} from all value label names

{phang2}
{stata elabel rename (*lbl) (*):. elabel rename (*lbl) (*)}
{p_end}

{pstd}
Change all value label names starting with {cmd:occ} to all uppercase letters

{phang2}
{stata elabel rename occ* , upper:. elabel rename occ* , upper}
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}, {help label language}, 
{help rename}, {help rename group}{p_end}

{psee}
if installed: {help elabel}, {help labelrename}
{p_end}
