{smcl}
{* *! version 1.0.0  15mar2010}{...}
{cmd:help spmat idistance}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col:{cmd:spmat idistance} {hline 2}}Create an {bf:spmat} object containing
an inverse-distance spatial-weighting matrix {bf:W}
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:idist:ance} {it:objname} {it:varlist}
{ifin}{cmd:,} {opt id(varname)} [{it:options}]


{synoptset 33 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt id(varname)}}ID variable{p_end}
{synopt:{opt df:unction}({it:function}[{bf:, miles}])}distance function{p_end}
{synopt:{opt norm:alize(norm)}}normalization method{p_end}
{synopt:{opt btr:uncate(b B)}}bin truncation{p_end}
{synopt:{opt dtr:uncate(l u)}}diagonal truncation{p_end}
{synopt:{opt vtr:uncate(#)}}value truncation{p_end}
{synopt:{opt band:ed}}banded storage{p_end}
{synopt:{opt replace}}replace {it:objname}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* Required{p_end}
{p 4 6 2}
Only one of {cmd:btruncate()}, {cmd:dtruncate()}, or {cmd:vtruncate()} may be
specified.{p_end}


{title:Description}

{pstd}
{opt spmat idistance} puts an inverse-distance spatial-weighting matrix
{bf:W} into the new {cmd:spmat} object {it:objname}.
The {it:ij}th element of {bf:W} contains the inverse of the distance
between points {it:i} and {it:j} calculated from the coordinate variables
specified in {it:varlist}.  Longitude must be specified first if coordinate
variables represent longitude and latitude.


{title:Options}

{phang}
{cmd:id(}{it:varname}{cmd:)}
    specifies a numeric variable that contains a unique identifier for each 
    observation. This option is required.   

{phang}
{bf:dfunction(}{it:function}[{bf:, miles}]{bf:)} specifies the distance function.
    {it:function} may be one of {opt euc:lidean} (default), {opt dhav:ersine}, 
    {opt rhav:ersine}, or the Minkowski distance of order {it:p} where {it:p}
    is an integer greater than or equal to 1.

{pmore}
Use {bf:dhaversine} when your coordinate variables are in degrees;
    use {bf:rhaversine} when your coordinate variables are in radians.
    By default, the distances are calculated in kilometers; specify the optional
    {bf:miles} argument if you want the distances to be calculated in miles.
    
{phang}
{opt normalize(norm)} specifies the normalization method.
    {it:norm} may be one of {opt row}, {opt min:max}, or
    {opt spe:ctral}.

{phang}
{opt truncate()} options specify one of the three available 
truncation criteria.  The values of the spatial-weighting 
matrix {bf:W} that meet the truncation criterion will be
changed to zero.

{pmore}
{opt btruncate(b B)} partitions the value of {bf:W} into
    {it:B} bins and truncates to zero entries that fall
    into bin {it:b} or below.

{pmore}
{opt dtruncate(l u)} truncates to zero the values of {bf:W}
    that fall {it:l} diagonals below and {it:u} diagonals
    above the main diagonal.  Neither value can be greater
    than {cmd:floor((cols(W)-1)/4)}.
    
{pmore}
{opt vtruncate(#)} truncates to zero the values of {bf:W}
    that are less than or equal to #.

{phang}
{opt banded} instructs {cmd:spmat} to store the truncated
inverse-distance matrix in a banded form;
see {it:Remarks} in {helpb spmat_tobanded##banded_remarks:spmat tobanded} for details.

{phang}
{opt replace} allows {it:objname} to be overwritten if it already exists.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. use pollute}{p_end}

{pstd}Create the spmat object {cmd:dobj} containing an inverse-distance matrix{p_end}
{phang2}{cmd:. spmat idistance dobj longitude latitude, id(id) dfunction(dhaversine)}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

