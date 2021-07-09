{smcl}
{cmd:help elabel save}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel save} {hline 2} Save value labels in do-file


{title:Syntax}

{p 8 12 2}
{cmd:elabel save}
[ {it:{help elabel##elblnamelist:elblnamelist}} ]
[ {helpb elabel##iffeexp:iff {it:eexp}} ]
{helpb using} {it:{help filename}}
[ {cmd:,} {it:options} ]


{title:Description}

{pstd}
{cmd:elabel save} saves value label definitions in a do-file. 


{title:Options}

{phang}
{opt replace} allows {it:filename} to be overwritten if it already exists.

{phang}
{cmd:option(}{{opt a:dd}|{opt modify}|{opt replace}|{opt none}}{cmd:)} 
specifies the option to be added to the {helpb label:label define} 
commands in {it:filename}; default is {opt modify}. 


{title:Examples}

{pstd}
Load example dataset

{phang2}
{stata sysuse nlsw88:. sysuse nlsw88}
{p_end}

{pstd}
Save value label {cmd:occlbl} to {cmd:labels.do}

{phang2}
{stata elabel save occlbl using labels:. elabel save occlbl using labels}
{p_end}

{pstd}
Save the value label attached to {cmd:collgrad} to {cmd:labels}

{phang2}
{stata elabel save (collgrad) using labels , replace:. elabel save (collgrad) using labels , replace}
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
