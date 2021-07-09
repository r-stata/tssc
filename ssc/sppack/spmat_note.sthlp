{smcl}
{* *! version 1.0.1  16mar2010}{...}
{cmd:help spmat note}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{cmd:spmat note} {hline 2}}Manipulate note attached to an {bf:spmat}
object
{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}
Append text to the note in {it:objname}

{p 8 15 2}
{opt spmat note } {it:objname} {cmd:: "}{it:text}{cmd:"}


{phang}
Replace the note associated with {it:objname}

{p 8 15 2}
{opt spmat note } {it:objname} {cmd:: "}{it:text}{cmd:"} {cmd:, replace}


{phang}
Display the note associated with {it:objname}

{p 8 15 2}
{opt spmat note} {it:objname}


{phang}
Drop the note associated with {it:objname}

{p 8 15 2}
{opt spmat note} {it:objname} {cmd:drop}


{title:Description}

{pstd}
{opt spmat note} manipulates the note associated with the {cmd:spmat} object
{it:objname}.  Unlike in Stata datasets, {cmd:spmat} objects can have only one note associated with them.  It is possible to store multiple comments
by repeatedly appending text to the note.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}

{pstd}Add a note to the spmat object {cmd:cobj}{p_end}
{phang2}{cmd:. spmat note cobj: "Simulated data for spmat"}{p_end}

{pstd}Display the note{p_end}
{phang2}{cmd:. spmat note cobj}{p_end}
           Simulated data for spmat

{pstd}Append another comment to the note{p_end}
{phang2}{cmd:. spmat note cobj: "- queen contiguity"}{p_end}

{pstd}Display the note{p_end}
{phang2}{cmd:. spmat note cobj}{p_end}
           Simulated data for spmat - queen contiguity

{pstd}Replace the note{p_end}
{phang2}{cmd:. spmat note cobj: `"Is this "queen" contiguity?"', replace}{p_end}
          
{pstd}Display the note{p_end}
{phang2}{cmd:. spmat note cobj}{p_end}
           Is this "queen" contiguity?

{pstd}Drop the note{p_end}
{phang2}{cmd:. spmat note cobj drop}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

