{smcl}
{* *! version 1.0.1  16mar2010}{...}
{cmd:help spmat import}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col:{cmd:spmat import} {hline 2}}Create an {bf:spmat} object from a
text file
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:im:port} {it:objname} {cmd:using} {it:filename}
[{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt noid}}{it:filename} does not contain unique IDs{p_end}
{synopt:{opt nlist}}{it:filename} contains a neighbor list{p_end}
{synopt:{opt geoda}}{it:filename} was created by the GeoDa (TM) software{p_end}
{synopt:{opt idist:ance}}convert distance data to inverse distances{p_end}
{synopt:{opt norm:alize(norm)}}normalization method{p_end}
{synopt:{opt replace}}replace {it:objname}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{opt spmat import} creates the {cmd:spmat} object {it:objname} from the text
file {it:filename}.  

{pstd}
By default, {cmd:spmat import} imports data from a space-delimited text file
in which the first line contains the number of columns of the spatial-weighting
matrix and, if applicable, the lower and upper band, followed by the matrix
stored row-by-row with unique place identifiers recorded in the first
column.


{title:Options}

{phang}
{cmd:noid} alerts {cmd:spmat import} that {it:filename} does not 
    contain unique place identifiers.  If so, Stata will create 
    IDs {cmd:1}, ..., {it:n}.

{phang}
{cmd:nlist} specifies that the text file is in the neighbor-list format.  
    The first line of the file must contain the total number
    of places and, if the matrix is banded, the lower and upper band.
    Each remaining line lists a place ID followed by its neighbors, if any. 
    
{phang}
{opt geoda} specifes that {it:filename} is in the {cmd:.gwt} or {cmd:.gal}
format created by the GeoDa (TM) software.

{phang}
{opt idistance} tells {cmd:spmat} that the data be converted to inverse
    distances.  The value d will be converted to 1/d with the exception
    of the main diagonal, which will contain zero entries.

{phang}
{opt normalize(norm)} specifies the normalization method.
    {it:norm} can be {opt row}, {opt min:max}, or {opt spe:ctral}.

{phang}
{opt replace} allows {it:objname} to be overwritten if it already exists.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. set memory 50m}{p_end}
{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. spmat contiguity cobj using pollutexy, id(id) normalize(minmax)}{p_end}
{phang2}{cmd:. spmat export cobj using cobj.txt}{p_end}
{phang2}{cmd:. spmat drop cobj}{p_end}

{pstd}Create the spmat object {cmd:cobj} from the file {cmd:cobj.txt}{p_end}
{phang2}{cmd:. spmat import cobj using cobj.txt}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

