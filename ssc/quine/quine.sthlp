{smcl}
{* 2Feb2013}{...}
{cmd:help quine}
{hline}

{title:Title}

{p2colset 5 20 29 2}{...}
{p2col :{hi:quine} {hline 2}}A quine in Stata{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:quine}

{title:Description}

{pstd}
A {bf:quine} is a computer program that prints itself out when run. A quine is not allowed to load any data and must contain any data that it uses. Hence, entering
 the command {bf:quine} at the Stata command prompt results in the {bf:quine} command reproducing itself. 

{title:Comments}

{pstd}
The {browse "http://en.wikipedia.org/wiki/Quine_(computing)":Wikipedia entry for quines} has some historical information on quines, including the origins
of the term "quine." Creating a quine takes a little finesse, but the basic idea can be summed up by the psuedo-code: 

{pstd}
{it: Print whatever follows this statement in quotes twice, the second time in quotes: "Print whatever follows this statement in quotes twice, the second time in quotes:"}

{title:Examples}

{cmd:quine}

{cmd:viewsource quine.ado}

{pstd}
Examples from a long and varied list of computer languages can be found at {browse "http://www.nyx.net/~gthompso/quine.htm":The Quine Page}. 

{title:Author} 

{phang}This command was written by Matthew J. Baker (matthew.baker@hunter.cuny.edu), Hunter College and The Graduate Center, CUNY. Comments, criticisms, and suggestions for improvement are welcome. {p_end}

