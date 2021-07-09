{smcl}
{* *! version 1.0.0  15mar2010}{...}
{cmd:help spmat drop}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{cmd:spmat drop} {hline 2}}Drop an {bf:spmat} object from memory
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat drop} {it:objname}


{title:Description}

{pstd}
{opt spmat drop} drops the {cmd:spmat} object {it:objname} from memory.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}

{pstd}Drop the spmat object {cmd:cobj} from memory{p_end}
{phang2}{cmd:. spmat drop cobj}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

