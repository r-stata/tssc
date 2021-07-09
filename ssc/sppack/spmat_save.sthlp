{smcl}
{* *! version 1.0.0  15mar2010}{...}
{cmd:help spmat save}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{cmd:spmat save} {hline 2}}Save an {bf:spmat} object in memory
to disk in Stata's native format
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:sa:ve} {it:objname} {cmd:using} {it:filename}
[{cmd:, replace}]


{title:Description}

{pstd}
{opt spmat save} saves the {cmd:spmat} object {it:objname} in memory
to disk in Stata's native format.  {cmd:replace} requests that {it:filename}
be overwritten if it already exists.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. set memory 50m}{p_end}
{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. spmat contiguity cobj using pollutexy, id(id) normalize(minmax)}{p_end}

{pstd}Save the spmat object {cmd:cobj} to disk{p_end}
{phang2}{cmd:. spmat save cobj using cobj.spmat}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

