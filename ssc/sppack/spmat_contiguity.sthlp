{smcl}
{* *! version 1.0.2  28feb2014}{...}
{cmd:help spmat contiguity}
{hline}

{title:Title}

{p2colset 5 25 27 2}{...}
{p2col:{cmd:spmat contiguity} {hline 2}}Create an {bf:spmat} object containing a
contiguity matrix {bf:W}
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:con:tiguity} {it:objname}
{ifin} {cmd:using} {it:filename}{cmd:,} {opt id(varname)} [{it:options}]


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt id(varname)}}ID variable{p_end}
{synopt:{opt rook}}rook contiguity{p_end}
{synopt:{opt norm:alize(norm)}}normalization method{p_end}
{synopt:{opt tol:erance(#)}}numerical tolerance{p_end}
{synopt:{opt band:ed}}banded storage{p_end}
{synopt:{opt replace}}replace {it:objname}{p_end}
{synopt:{opt saving(filename, ...)}}save neighbor info to a text file{p_end}
{synopt:{opt nomat:rix}}do not create {it:objname}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* Required{p_end}


{title:Description}

{pstd}
{opt spmat contiguity} puts a contiguity matrix {bf:W} into the new 
{cmd:spmat} object {it:objname}.  The {it:ij}th element of {bf:W}
is 1 if points {it:i} and {it:j} are neighbors and is 0 otherwise.

{pstd}
{opt spmat contiguity} uses both the dataset in memory and a dataset
containing the coordinates of polygons.  The coordinates dataset must be
in the format created by {help shp2dta} or {help mif2dta}.


{title:Options}

{phang}
{cmd:id(}{it:varname}{cmd:)}
    specifies a numeric variable that contains a unique identifier for each 
    observation.  This option is required.

{phang}
{opt rook} specifies that only points that share a common edge should
    be considered neighbors (rook contiguity).  The default is to 
    include points that share a common vertex (queen contiguity).  
    Rook contiguity is computationally more difficult than queen contiguity.

{phang}
{opt normalize(norm)} specifies the normalization method.
    {it:norm} can be {opt row}, {opt min:max}, or
    {opt spe:ctral}.

{phang}
{opt tolerance(#)} specifies the numerical tolerance used in deciding
    whether two places are rook or queen neighbors.  The default is
    {cmd:tolerance(1e-7)}.

{phang}
{opt banded} instructs {cmd:spmat} to store the contiguity matrix in
a banded form; see {it:Remarks} in {helpb spmat_tobanded##banded_remarks:spmat tobanded}
for details.

{phang}
{opt replace} allows {it:objname} to be overwritten if it already exists.

{phang}
{cmd:saving(}{it:filename} [{cmd:, replace}]{cmd:)} requests that
    the matrix be written to {it:filename} in the neighbor-list format.
    The first line of the file contains the total number
    of places and, if the matrix is banded, the lower and upper band.
    Each remaining line lists a place ID followed by its 
    neighbors, if any.  {cmd:replace} allows {it:filename}
    to be overwritten if it already exists.

{phang}
{cmd:nomatrix} specifies that the {bf:spmat} object {it:objname} and
    spatial-weighting matrix {bf:W} not be created.  In conjunction with
    {bf:saving()}, this option allows for creating a text file containing
    a neighbor list without constructing the underlying contiguity matrix.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. set memory 50m}{p_end}
{phang2}{cmd:. use pollute}{p_end}

{pstd}Create the spmat object {cmd:cobj} containing a minmax-normalized contiguity matrix{p_end}
{phang2}{cmd:. spmat contiguity cobj using pollutexy, id(id) normalize(minmax)}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

