{smcl}
{* *! version 1.0.1  16mar2010}{...}
{cmd:help spmat export}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col:{cmd:spmat export} {hline 2}}Save the spatial-weighting matrix {bf:W}
contained in an {bf:spmat} object to disk as a space-delimited text file
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:ex:port} {it:objname}
{cmd:using} {it:filename} [{cmd:,} {it:options}]


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt noid}}do not save place IDs{p_end}
{synopt:{opt nlist}}save the matrix as a neighbor list{p_end}
{synopt:{opt replace}}replace {it:filename}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{opt spmat export} saves the spatial-weighting matrix {bf:W} contained in the
{cmd:spmat} object {it:objname} to disk as a space-delimited text file.  
The first line of the file contains the number of columns of {bf:W} and,
if applicable, the lower and upper band.  The spatial-weighting matrix
is then written row-by-row, with the place identifiers recorded in the first
column.


{title:Options}

{phang}
{cmd:noid} specifies that place identifiers not be saved.

{phang}
{opt nlist} specifies that the matrix be written in the neighbor-list format.
    The first line of the file will contain the total number of places and,
    if the matrix is banded, the lower and upper band.  Each remaining line will
    list a place ID followed by its neighbors, if any.

{phang}
{opt replace} allows {it:filename} to be overwritten if it already exists.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}

{pstd}Save the spmat object {cmd:cobj} to disk{p_end}
{phang2}{cmd:. spmat export cobj using cobj.txt}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

