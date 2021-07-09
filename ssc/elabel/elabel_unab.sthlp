{smcl}
{cmd:help elabel unab}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel unab} {hline 2} Unabbreviate value label names


{title:Syntax}

{p 8 12 2}
{cmd:elabel unab}
{it:lmacname} {cmd::} {it:lblnamelist}
[ {cmd:,} {it:options} ]


{title:Description}

{pstd}
{cmd:elabel unab} unabbreviates the value label names in {it:lblnamelist} 
and places the result in the local macro {it:lmacname}. Value label names 
may contain the wildcard characters {cmd:*}, {cmd:~}, and {cmd:?}.


{title:Options}

{phang}
{opt nomem:ory} treats value label names attached to variables but not yet 
defined in memory as existing. The option respects multilingual datasets 
(see {help label language}). 

{phang}
{opt cur:rent} is for use with, and implies, {opt nomemory}; the option 
treats value label names attached to variables in the current label language 
but not yet defined in memory as existing.

{phang}
{opt elbl:namelist} allows {it:{help elabel##elblnamelist:elblnames}} in 
{it:lblnamelist}.

{phang}
{opt abbrev:ok} allows abbreviated value label names in {it:lblnamelist}.


{title:Examples}

{pstd}
Load example dataset

{phang2}
{stata sysuse nlsw88:. sysuse nlsw88}
{p_end}

{pstd}
Unabbreviate some value label names

{phang2}{stata "elabel unab lblnamelist : *r*":. elabel unab lblnamelist : *r*}{p_end}
{phang2}{stata `"display "`lblnamelist'"':. display "`lblnamelist'"}{p_end}


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
