{smcl}
{* *! version 1.0.1  16mar2010}{...}
{cmd:help spmat use}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{cmd:spmat use} {hline 2}}Load an {bf:spmat} object into memory
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat use} {it:objname} {cmd:using} {it:filename} [{cmd:, replace}]


{title:Description}

{pstd}
{opt spmat use} creates the {cmd:spmat} object {it:objname} from the file
{it:filename} previously saved with {cmd:spmat save}.  {cmd:replace}
permits {cmd:spmat use} to overwrite {it:objname} if it already exists.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. set memory 50m}{p_end}
{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. spmat contiguity cobj using pollutexy, id(id) normalize(minmax)}{p_end}
{phang2}{cmd:. spmat save cobj using cobj.spmat}{p_end}
{phang2}{cmd:. spmat drop cobj}{p_end}

{pstd}Create the spmat object {cmd:cobj} from the file {cmd:cobj.spmat}{p_end}
{phang2}{cmd:. spmat use cobj using cobj.spmat}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

