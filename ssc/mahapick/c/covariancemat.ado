/*
ado\covariancemat.ado  12-31-2007
David Kantor

Based somewhat on variancemat.ado, but this also is similar to corrmat.ado,
as will be explained below.

This is to create a matrix of covariances.
This replicates part of the functionality of corrmat.ado, by
Shannon Driver of Stata Corporation; the difference is that this does only
one of the functions (covariance) and it allows -if- and -in- qualifiers.

This was written for use by enhamcemants to mahapick & mahascore,

We will include the possibility of weights.  There may be no need for them,
but it is easy to program; might as well do it.


Comparison to variancemat:
variancemat gives a column-matrix (or vector) of variances.
This gives the whole square symmetrical matrix.  So the result of variancemat
should be the diagonal of the result of the present routine.

Also it uses built-in Stata functionality, using -matrix accum-, rather than
directly calculating each cell of the matrix.  As such it assumes the
functionality of the -common- option of variancemat.

When used in a distance measure, this will yield the true Mahalanobis measure,
rather than the normalized Euclidean measure, as was the case with variancemat.

1-1-2008: edited comments.
Also changed matname(string) to matname(name) in the -syntax-.

2-12-2008: made it quiet.

3-8-2007: change name matname to covarmat.
3-30-2008: edited comments.
*/


*! version 1.0.3 3-31-2008

/*
prior version 
1.0.0 12-31-2007
*/



prog def covariancemat
version 8.2

syntax varlist [if] [in] [aw fw pw iw], covarmat(name)


quietly matrix accum `covarmat' = `varlist' `if' `in' [`weight'`exp'], deviations noconstant 
matrix `covarmat' = `covarmat'/(r(N)-1)

end

