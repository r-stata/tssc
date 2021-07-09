{smcl}
{cmd:help elabel remove}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel remove} {hline 2} Remove value labels from variables and memory


{title:Syntax}

{p 8 12 2}
{cmd:elabel remove}
{it:{help elabel##elblnamelist:elblnamelist}}
[ {cmd:,} {it:options} ]


{title:Description}

{pstd}
{cmd:elabel remove} removes value labels, i.e., detaches 
value labels from variables and drops value labels from memory. 

{pstd}
The command combines {helpb elabel values}, which detaches value labels 
from variables, with {helpb elabel drop}, which eliminates value labels 
from memory.

{pstd}
Value labels are removed from all {help label language:label languages}.


{title:Options}

{phang}
{opt not} removes all but the specified value labels.

{phang}
{opt nomem:ory} treats value label names attached to variables as if they 
were defined in memory. The option respects multilingual datasets 
(see {help label language}). 


{title:Examples}

{pstd}
Load example data

{phang2}{stata sysuse nlsw88:. sysuse nlsw88}{p_end}
{phang2}{stata describe:. describe}{p_end}
{phang2}{stata elabel dir:. elabel dir}{p_end}

{pstd}
Remove all value labels

{phang2}{stata elabel remove _all:. elabel remove _all}{p_end}
{phang2}{stata describe:. describe}{p_end}
{phang2}{stata elabel dir:. elabel dir}{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}
{p_end}

{psee}
if installed: {help elabel}
{p_end}
