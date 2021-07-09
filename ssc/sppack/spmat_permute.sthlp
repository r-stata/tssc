{smcl}
{* *! version 1.0.1  16mar2010}{...}
{cmd:help spmat permute}
{hline}

{title:Title}

{p2colset 5 22 24 2}{...}
{p2col:{cmd:spmat permute} {hline 2}}Reorder the rows and columns of the 
spatial-weighting matrix {bf:W}
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:per:mute} {it:objname} {it:varname}


{title:Description}

{pstd}
{opt spmat permute} reorders the rows and columns of the spatial-weighting
matrix {bf:W} contained in the {cmd:spmat} object {it:objname}.  {it:varname}
is the Stata variable containing the permutation vector, where the {it:i}th
observation in {it:varname} specifies the new column index of {bf:W}; see
{help m1_permutation:[M-1] permutation} for a detailed discussion.

{pstd}
{opt spmat permute} prepares a general spatial-weighting matrix for
more efficient storage; see {it:Remarks} in
{helpb spmat_tobanded##banded_remarks:spmat tobanded} for details.


{title:Remarks}

{pstd}
We use a simple example to illustrate how {cmd:spmat permute} works.  
Given the spatial-weighting matrix {bf:W},

            {c TLC}{c -}             {c -}{c TRC}
            {c |} 0  1  0  0  1 {c |}
            {c |} 1  0  0  1  0 {c |}
            {c |} 0  0  0  0  1 {c |}
            {c |} 0  1  0  0  0 {c |}
            {c |} 1  0  1  0  0 {c |}
            {c BLC}{c -}             {c -}{c BRC}

{pstd}
and the permutation vector {bf:p} = (3, 5, 1, 2, 4), 
we can use Mata to reorder the rows and columns of {bf:W} by 
performing the operation

            {cmd:W = W[p, p]}

{pstd}
which results in {bf:W} being

            {c TLC}{c -}             {c -}{c TRC}
            {c |} {bf:0}  1  0  0  0 {c |}
            {c |} 1  {bf:0}  1  0  0 {c |}
            {c |} 0  1  {bf:0}  1  0 {c |}
            {c |} 0  0  1  {bf:0}  1 {c |}
            {c |} 0  0  0  1  {bf:0} {c |}
            {c BLC}{c -}             {c -}{c BRC}

{pstd}
where we highlighted the main diagonal.  Note that all the 1s are now
clustered around the main diagonal.  We can now use
{helpb spmat_tobanded:spmat tobanded} to store the permuted
matrix {bf:W} in a banded form.

{pstd}
{cmd:spmat permute} requires that the permutation vector be stored in
the Stata variable {it:varname}.  Assume that we now have the unpermuted matrix {bf:W}
stored in the {bf:spmat} object {bf:cobj}.  The matrix represents 
contiguity information for the following data:

	    {c TLC}{hline 7}{c -}{hline 8}{c TRC}
	    {c |} {res}  id  distance {txt}{c |}
    	    {c LT}{hline 7}{c -}{hline 8}{c RT}
 	    {c |} {res}  79      5.23 {txt}{c |}
 	    {c |} {res}  82     27.56 {txt}{c |}
 	    {c |} {res} 100         0 {txt}{c |}
	    {c |} {res} 114      1.77 {txt}{c |}
	    {c |} {res} 140     20.47 {txt}{c |}
	    {c BLC}{hline 7}{c -}{hline 8}{c BRC}

{pstd}
where the variable {bf:distance} measures the distance from the centroid of
place with {bf:id} = {bf:100} to the centroids of all the other places.  We sort
the data on {bf:distance} and generate the permutation vector {cmd:p = _n},
which is just a running index 1, ..., 5:

	    {c TLC}{hline 7}{c -}{hline 8}{c -}{hline 3}{c TRC}
	    {c |} {res}  id  distance   p {txt}{c |}
    	    {c LT}{hline 7}{c -}{hline 8}{c -}{hline 3}{c RT}
	    {c |} {res} 100         0   1 {txt}{c |}
	    {c |} {res} 114      1.77   2 {txt}{c |}
	    {c |} {res}  79      5.23   3 {txt}{c |}
	    {c |} {res} 140     20.47   4 {txt}{c |}
	    {c |} {res}  82     27.56   5 {txt}{c |}
	    {c BLC}{hline 7}{c -}{hline 8}{c -}{hline 3}{c BRC}

{pstd}
We obtain our permutation vector by sorting the data back to the original order
based on the {cmd:id} variable:

	    {c TLC}{hline 7}{c -}{hline 8}{c -}{hline 3}{c TRC}
	    {c |} {res}  id  distance   p {txt}{c |}
    	    {c LT}{hline 7}{c -}{hline 8}{c -}{hline 3}{c RT}
	    {c |} {res}  79      5.23   3 {txt}{c |}
	    {c |} {res}  82     27.56   5 {txt}{c |}
	    {c |} {res} 100         0   1 {txt}{c |}
	    {c |} {res} 114      1.77   2 {txt}{c |}
	    {c |} {res} 140     20.77   4 {txt}{c |}
	    {c BLC}{hline 7}{c -}{hline 8}{c -}{hline 3}{c BRC}

{pstd}
Now coding {cmd:spmat permute cobj p} will reorder the rows and columns of
{bf:W} in exactly the same way as the Mata code above did.


{title:Example}

    {hline}
{pstd}Setup{p_end}

{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}
{phang2}{cmd:. spmat summarize cobj}{p_end}

{pstd}Create the permutation vector p{p_end}

{phang2}{cmd:. gen p = _n}{p_end}
{phang2}{cmd:. sort longitude latitude}{p_end}
{phang2}{cmd:. gen dist = sqrt( (longitude-longitude[1])^2 + (latitude-latitude[1])^2 )}{p_end}
{phang2}{cmd:. sort dist}{p_end}

{pstd}Permute the matrix{p_end}

{phang2}{cmd:. spmat permute cobj p}{p_end}

{pstd}Band the matrix if possible{p_end}

{phang2}{cmd:. spmat summarize cobj, banded}{p_end}
{phang2}{cmd:. if `r(canband)'==1 spmat tobanded cobj, dtr(`r(lband)' `r(uband)') replace}{p_end}
{phang2}{cmd:. spmat summarize cobj}{p_end}

   {hline}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

