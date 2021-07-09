{smcl}
{* *! version 1.0.0  15mar2010}{...}
{cmd:help spmat summarize}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col:{cmd:spmat summarize} {hline 2}}Summarize the spatial-weighting
matrix {bf:W} contained in an {bf:spmat} object
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:su:mmarize} {it:objname} [{cmd:,} {it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt li:nks}}report links{p_end}
{synopt:{opt det:ail}}display detailed summary of links{p_end}
{synopt:{opt band:ed}}display banded information{p_end}
{synopt:{opt btr:uncate(b B)}}bin truncation{p_end}
{synopt:{opt dtr:uncate(l u)}}diagonal truncation{p_end}
{synopt:{opt vtr:uncate(#)}}value truncation{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Only one of {cmd:banded}, {cmd:btruncate()}, {cmd:dtruncate()}, or 
{cmd:vtruncate()} may be specified.{p_end}


{title:Description}

{pstd}
{opt spmat summarize} summarizes the spatial-weighting
matrix {bf:W} contained in the {cmd:spmat} object {it:objname}.
If the object contains an {it:n} x {it:n} matrix, the user can optionally
request summary statistics that show whether the matrix can be
stored in a banded form.


{title:Options}

{phang}
{opt links} requests that {opt spmat summarize} reports links rather than the
    default values.  This option is useful for summarizing contiguity matrices.

{phang}
{opt detail} requests a detailed tabulation of links.
    {opt detail} will also display IDs of observations with the minimum and
    maximum number of links.

{phang}
{opt banded} reports the bands for the matrix that has already a (possibly)
banded structure but is stored in an {it:n} x {it:n} form.

{phang}
{opt truncate()} options report the bands for the matrix after its values have
been changed to zero according to one of the truncation criterion.

{pmore}
{opt btruncate(b B)} partitions the values of {bf:W} into
    {it:B} bins and truncates to zero those entries that fall
    into bin {it:b} or below.

{pmore}
{opt dtruncate(l u)} truncates to zero the values of {bf:W}
    that fall {it:l} diagonals below and {it:u} diagonals
    above the main diagonal.  Neither value can be greater
    than {cmd:floor((cols(W)-1)/4)}.
    
{pmore}
{opt vtruncate(#)} truncates to zero the values of {bf:W}
    that are less than or equal to #.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}

{pstd}Summarize the contiguity matrix contained in the spmat object {cmd:cobj}{p_end}
{phang2}{cmd:. spmat summarize cobj, links}{p_end}


{title:Saved results}{marker saved_results}

{pstd}
{cmd:spmat summarize} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(b)}}number of rows in {bf:W}{p_end}
{synopt:{cmd:r(n)}}number of columns in {bf:W}{p_end}
{synopt:{cmd:r(lband)}}lower band of {bf:W}{p_end}
{synopt:{cmd:r(uband)}}upper band of {bf:W}{p_end}
{synopt:{cmd:r(min)}}minimum of {bf:W}{p_end}
{synopt:{cmd:r(min0)}}minimum element > 0 in {bf:W}{p_end}
{synopt:{cmd:r(mean)}}mean of {bf:W}{p_end}
{synopt:{cmd:r(max)}}maximum of {bf:W}{p_end}
{synopt:{cmd:r(lmin)}}minimum number of neighbors in {bf:W}{p_end}
{synopt:{cmd:r(lmean)}}mean number of neighbors in {bf:W}{p_end}
{synopt:{cmd:r(lmax)}}maximum number of neighbors in {bf:W}{p_end}
{synopt:{cmd:r(ltotal)}}total number of neighbors in {bf:W}{p_end}
{synopt:{cmd:r(eig)}}{cmd:1} if object contains eigenvalues, {cmd:0} otherwise{p_end}
{synopt:{cmd:r(canband)}}{cmd:1} if {bf:W} can be banded based on {cmd:r(lband)}
and {cmd:r(uband)}, {cmd:0} otherwise{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

