{smcl}
{* *! version 1.0.2  24jan2012}{...}
{cmd:help spmat getmatrix}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col:{cmd:spmat getmatrix} {hline 2}}Copy a matrix contained in an
{bf:spmat} object to a Mata matrix
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:getmat:rix} {it:objname} [{it:matname}] [{cmd:,} {it:options}]


{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt id(vecname)}}name of a Mata vector to contain IDs{p_end}
{synopt:{opt eig(vecname)}}name of a Mata vector to contain eigenvalues{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{opt spmat getmatrix} copies the spatial-weighting matrix {bf:W} contained in
the {cmd:spmat} object {it:objname} to the Mata matrix {it:matname}.
The place identifiers and the eigenvalues of {cmd:W} can be optionally saved to
Mata vectors.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}

{pstd}Copy the contiguity matrix contained in the spmat object {cmd:cobj} to the 
	Mata matrix {cmd:mymat}{p_end}
{phang2}{cmd:. spmat getmatrix cobj mymat}{p_end}

{pstd}Copy the eigenvalues contained in the spmat object {cmd:cobj} to the 
	Mata vector {cmd:myeig}{p_end}
{phang2}{cmd:. spmat getmatrix cobj, eig(myeig)}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

