{smcl}
{cmd:help elabel copy}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel copy} {hline 2} Copy value label


{title:Syntax}

{p 8 12 2}
{cmd:elabel copy}
{it:{help elabel##elblnamelist:oldlblname}}
{it:{help elabel##elblnamelist:newlblname}}
[ {helpb elabel##iffeexp:iff {it:eexp}} ]
[ {cmd:,} {it:options} ]


{p 4 10 2}
where both {it:oldlblname} and {it:newlblname} are elements of an 
{it:{help elabel##elblnamelist:elblnamelist}} and may 
be {help elabel##varvaluelabel:{it:varname}{bf::}{it:elblname}}

{p 4 10 2}
{cmd:iff} {it:eexp} always refers to {it:oldlblname}


{title:Description}

{pstd}
{cmd:elabel copy} copies an existing value label. 


{title:Options}

{phang}
{opt a:dd} is the same as with {help label##options:label define}, 
and adds integer to text mappings to {it:newlblname} if it 
already exists.

{phang}
{opt modify} is the same as with {help label##options:label define}, 
and modifies {it:newlblname} if it already exists.

{phang}
{opt replace} is the same as with {help label##options:label define}, 
and redefines {it:newlblname}.

{pstd}
{opt nofix} is the same as with {help label##options:label define}.


{title:Examples}

{pstd}
Load example dataset

{phang2}
{stata sysuse nlsw88:. sysuse nlsw88}
{p_end}

{pstd}
Copy value label {cmd:occlbl} to {cmd:newlbl}

{phang2}
{stata elabel copy occlbl newlbl:. elabel copy occlbl newlbl}
{p_end}

{pstd}
Copy the value label attached to {cmd:collgrad} to {cmd:gradlbl2}

{phang2}
{stata elabel copy (collgrad) gradlbl2:. elabel copy (collgrad) gradlbl2}
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
