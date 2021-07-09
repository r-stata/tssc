{smcl}
{cmd:help elabel drop}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel drop} {hline 2} Drop value labels


{title:Syntax}

{p 4 8 2}
Drop value labels

{p 8 12 2}
{cmd:elabel drop}
{it:{help elabel##elblnamelist:elblnamelist}}


{p 4 8 2}
Keep value labels

{p 8 12 2}
{cmd:elabel keep}
{it:{help elabel##elblnamelist:elblnamelist}}


{title:Description}

{pstd}
{cmd:elabel drop} eliminates value labels from memory. 

{pstd}
{cmd:elabel keep} does the reverse: it keeps only the 
specified value labels in memory.


{title:Examples}

{pstd}
Load example dataset

{phang2}
{stata sysuse nlsw88:. sysuse nlsw88}
{p_end}

{pstd}
Drop value label {cmd:occlbl}

{phang2}
{stata elabel drop occlbl:. elabel drop occlbl}
{p_end}

{pstd}
Keep only the value label attached to {cmd:collgrad}

{phang2}
{stata elabel keep (collgrad):. elabel keep (collgrad)}
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
