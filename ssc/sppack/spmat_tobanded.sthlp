{smcl}
{* *! version 1.0.0  15mar2010}{...}
{cmd:help spmat tobanded}
{hline}

{title:Title}

{p2colset 5 23 25 2}{...}
{p2col:{cmd:spmat tobanded} {hline 2}}Store a general spatial-weighting 
matrix {bf:W} in banded form
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:tob:anded} {it:objname1} [{it:objname2}] 
[{cmd:,} {it:options}]

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt btr:uncate(b B)}}bin truncation{p_end}
{p2coldent:* {opt dtr:uncate(l u)}}diagonal truncation{p_end}
{p2coldent:* {opt vtr:uncate(#)}}value truncation{p_end}
{synopt:{opt replace}}replace {it:objname1} or {it:objname2}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* Only one of {cmd:btruncate()}, {cmd:dtruncate()}, or
{cmd:vtruncate()} may be specified.{p_end}


{title:Description}

{pstd}
{opt spmat tobanded} replaces the existing {it:objname1} or creates
the new {it:objname2} with the spatial-weighting matrix {bf:W} stored
in a banded form.  By default, {opt spmat tobanded} assumes that {bf:W} has
already a banded structure and attempts to store {bf:W} in a banded form;
see {help spmat_tobanded##banded_remarks:Remarks} below for a distinction
between a banded structure and a banded form.

{pstd}
If the matrix cannot be stored in a banded form,
{cmd:spmat tobanded} returns appropriate summary statistics.


{title:Options}

{phang}
{opt truncate()} options specify one of the three available truncation criteria.
The values of the spatial-weighting matrix {bf:W} that meet the truncation 
criterion will be changed to zero.

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
{opt replace} allows {it:objname1} or {it:objname2} 
to be overwritten if it already exists.


{marker banded_remarks}{...}
{title:Remarks}

{pstd}
Let W be the spatial-weighting matrix

            {c TLC}{c -}             {c -}{c TRC}
            {c |} {bf:0}  1  0  0  0 {c |}
            {c |} 1  {bf:0}  1  0  0 {c |}
            {c |} 0  1  {bf:0}  1  0 {c |}
            {c |} 0  0  1  {bf:0}  1 {c |}
            {c |} 0  0  0  1  {bf:0} {c |}
            {c BLC}{c -}             {c -}{c BRC}

{pstd}
where we highlighted the main diagonal.  Note that all the 1s are 
clustered around the main diagonal.  A matrix with nonzero elements in the
diagonals close to the main diagonal and zero elements in all the diagonals
away from the main diagonal is called a banded matrix.
Note that although this matrix has a banded structure, it is still stored
in a general ({it:n} x {it:n}) form.
We can store W more efficiently in a banded form as

            {c TLC}{c -}             {c -}{c TRC}
            {c |} 0  1  1  1  1 {c |}
            {c |} {bf:0}  {bf:0}  {bf:0}  {bf:0}  {bf:0} {c |}
            {c |} 1  1  1  1  0 {c |}
            {c BLC}{c -}             {c -}{c BRC}

{pstd}
The row dimension of the banded matrix is {it:b}
= (# of diagonals below the main diagonal + main diagonal
+ # of diagonals above the main diagonal).  The elements 
beyond the upper and lower bands are implied to be zero and need not be stored.

{pstd}
In general,
the spatial-weighting matrix for {it:n} places is an {it:n} x {it:n} matrix,
which implies that memory requirements increase quadratically with data size.
For example, a spatial-weighting matrix for {it:n} = 50,000 requires
(50000*50000*8) / 2^30 or 18.63 GB of storage space.

{pstd}
As discussed in Drukker et al. (2010a, 2010b), many spatial-weighting matrices
can be stored in a banded form {it:b} x {it:n}, {it:b} << {it:n}, if the underlying 
data have been sorted in an ascending order from a corner place for a given
topography.

{pstd}
If we construct a contiguity matrix from the sorted data, most neighboring 
observations will cluster around the main diagonal, which will allow us to
store the matrix in a banded form without any loss of information.

{pstd}
If we construct an inverse-distance matrix from the sorted data, places
that are closer to us will be located closer to the main diagonal and more 
distant places will be located farther away from the main diagonal.
In this case, an inverse-distance matrix can be banded if we assume that
places that lie outside of a certain perimeter are to be treated as
non-neighbors.  {cmd:truncate} options provide three ways to exclude "more
distant" places from our neighborhood.

{pstd}
In either case, the banded matrix will be stored in a banded form, which will
result in substantial storage savings.  For example, if we are
able to squeeze neighborhood information into the bands of width 500, we can
store the 50,000 x 50,000 matrix in a 1,001 x 50,000 form, which
requires only (1001*50000*8) / 2^30 or 0.37 GB of memory.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. sort longitude latitude}{p_end}
{phang2}{cmd:. spmat contiguity cobj using c103xy, id(id) norm(minmax)}{p_end}

{pstd}Summarize the matrix contained in the spmat object {cmd:cobj} to see
that it is stored as a 541 x 541 matrix{p_end}
{phang2}{cmd:. spmat summarize cobj, links}{p_end}

{pstd}Try to band the matrix{p_end}
{phang2}{cmd:. spmat tobanded cobj, replace}{p_end}

{pstd}Summarize the matrix to see that it is stored as a
147 x 541 banded matrix{p_end}
{phang2}{cmd:. spmat summarize cobj, links}{p_end}


{title:References}

{phang}Drukker, D. M., H. Peng, I. R. Prucha, and R. Raciborski. 2011a.
Creating and managing spatial-weighting matrices using the spmat command.
Working paper, University of Maryland, Department of Economics,
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spmat_2011.pdf"}.

{phang}-----. 2011b. Banded spatial-weighting matrices.
Working paper, University of Maryland, Department of Economics,


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

