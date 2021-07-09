{smcl}
{* *! version 1.0.1  16mar2010}{...}
{cmd:help spmat eigenvalues}
{hline}

{title:Title}

{p2colset 5 26 28 2}{...}
{p2col:{cmd:spmat eigenvalues} {hline 2}}Add eigenvalues of the
spatial-weighting matrix {bf:W} to an {bf:spmat} object
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:eig:envalues} {it:objname} [{cmd:,} {it:options}]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt eig:envalues(vecname)}}Mata vector containing eigenvalues{p_end}
{synopt:{opt replace}}replace existing eigenvalues{p_end}
{synoptline}
{p2colreset}{...}

    
{title:Description}

{pstd}
{opt spmat eigenvalues} calculates the eigenvalues of the spatial-weighting
matrix {bf:W} contained in the {cmd:spmat} object {it:objname} and stores
them in {it:objname}.  Having precomputed eigenvalues in {it:objname} will
speed up the estimation command {helpb spreg:spreg ml}.


{title:Options}

{phang}
{cmd:eigenvalues(}{it:vecname}{cmd:)} specifies a Mata vector containing the
    eigenvalues of {bf:W}.  The vector must be stored as a
    {cmd:complex rowvector}.

{phang}
{cmd:replace} allows the existing eigenvalues to be overwritten.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}

{pstd}Add eigenvalues to the spmat object {cmd:cobj}{p_end}
{phang2}{cmd:. spmat eigenvalues cobj}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

