{smcl}
{* *! version 1.0  1dec2008}{...}
{cmd:help mregress} 
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:mcd} {hline 2}}Minimum Covariance Determinant estimator of location and scatter
{p2colreset}{...}


{title:Syntax}
{p 8 14 2}
{cmd:mcd} {varlist} {ifin} 
[{cmd:,} {it:options}] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{synopt :{opt e(#)}}maximal expected proportion of outliers{p_end}
{synopt :{opt proba(#)}}probability of selecting at least one clean sumple in the p-subset algorithm{p_end}
{synopt :{opt trim(#)}}percentage of trimming {p_end}
{synopt :{opt out:lier}}return robust Mahalanobis distances and flag outliers{p_end}
{synopt :{opt best:sampl}}flag oservations used for estimating the trimmed covariance matrix{p_end}
{synopt :{opt raw}}return the raw robust covariance matrix{p_end}
{synopt :{opt setseed(#)}}set the seed{p_end}


{title:Description}

{pstd}
{opt mcd} finds the Minimum Covariance Determinant estimator of location and scatter.
By default, the one step reweighted MCD robust covariance matrix is saved in matrix covRMCD and 
the one step reweighted MCD robust location vector is saved in matrix locationRMCD.

{title:Options}

{dlgtab:Model}

{phang}
{opt e(#)} sets the expected percentage of outliers existing in the dataset. Setting 
it high, slows down the algorithm. It is set by default to 0.2 but can take any value
ranging from 0 to 0.5.

{phang}
{opt proba(#)} sets the probability of having at least one non-corrupt sample among all 
those considered. It is set by default to 0.99 but can take any value ranging from 0 to 0.9999.

{phang}
{opt trim(#)} sets the trimming. It is set by default to 0.5 but can take any value 
ranging from 0 to 0.5.

{phang}
{opt out:lier} creates a dummy identifying multivariate outliers and returns robust distances.

{phang}
{opt best:sample} flags the subsample used for estimating the MCD location vector and scatter matrix.

{phang}
{opt raw} returns the genuine MCD location vector (locationMCD) and covariance matrix (covMCD)
rather than the one step reweighted (the default). The reweighted location vector and covariance
matrix are computed using classical estimators on the dataset cleaned of identified outliers.

{phang}
{opt setseed(#)} allows the user to set a seed. Setting the seed allows to replicate the results.

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse auto}{p_end}
{pstd}Estimate robust Mahalanobis distances{p_end}
{phang2}{cmd:. mcd  mpg headroom trunk weight length turn displacement gear_ratio, outlier}{p_end}
{pstd}Display the robust reweighted covariance matrix and location vector{p_end}
{phang2}{cmd:. matrix list covRMCD}{p_end}
{phang2}{cmd:. matrix list locationRMCD}{p_end}
{pstd}Same as above bust using the raw data{p_end}
{phang2}{cmd:. mcd  mpg headroom trunk weight length turn displacement gear_ratio, outlier raw}{p_end}
{pstd}Display the robust raw covariance matrix and location vector{p_end}
{phang2}{cmd:. matrix list covMCD}{p_end}
{phang2}{cmd:. matrix list locationMCD}{p_end}

{title:References}

{pstd}Rousseeuw, P.J. and Van Driessen, K. (1999). "A fast algorithm for the minimum covariance 
determinant estimator". Technometrics, 41, 212--223.


{title:Also see}

{psee}
Online:  {manhelp qreg R}, {manhelp regress R};{break}
{manhelp rreg R}, {help mmregress}, {help sregress}, {help msregress}, {help mregress}
{p_end}
