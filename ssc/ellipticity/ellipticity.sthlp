{smcl}
{* *! version 1.1.0  3jan2013}{...}
{cmd:help ellipticity} {right: (Vincenzo Verardi and Catherine Vermandele)}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{cmd:ellipticity} {hline 2}}"Optimal" rank-based multivariate tests of elliptical symmetry and sphericity {p_end}
{p2colreset}{...}


{title:Syntax}

{phang}

{pstd}
{cmd:ellipticity} {varname} {ifin} {cmd:,}  [{opt s:phericity} {opt r:obust} {opt level(#)}]



{title:Description}

{pstd}
{cmd:ellipticity} performs a multivariate elliptical symmetry test using a semiparametrically efficient optimal
(under gaussianity) rank-based procedure as proposed by Cassart (2007).

{pstd}
When testing for multivariate normality, please see {manhelp mvtest R}.


{title:Options}

{dlgtab:Main}

{phang}
{opt sphericity}  Specifies that a sphericity test using a semiparametrically efficient
optimal (under gaussianity) rank-based procedure as proposed by Hallin and Paindaveine (2006)
is used instead of the default ellipticity test.

{phang}
{opt robust}  Specifies that an S-estimator of location and scatter is used
(instead of the sample mean and covariance matrix) as estimator of the location
and scatter parameters. This makes the tests resistant to outlier contamination. 
See Verardi and Croux (2009).
 
{phang}
{opt level(#)} Specifies the confidence level for confidence intervals.  The default
is {cmd:level(0.95)} or as set by {helpb set level}.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{stata "webuse auto"}{p_end}

{pstd}Testing for sphericity{p_end}
{phang2}{stata "ellipticity price mpg headroom weight, sphericity"}{p_end}

{pstd}Testing for ellipticity{p_end}
{phang2}{stata "ellipticity price mpg headroom weight"}{p_end}

{pstd}same as above but robust to outliers{p_end}
{phang2}{stata "ellipticity price mpg headroom weight, robust"}{p_end}


{title:Saved results}

{pstd}
{cmd:ellipticity} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(Q)}}The test statistic{p_end}
{synopt:{cmd:r(crit)}}The critical value{p_end}
{synopt:{cmd:r(df)}}The degrees of freedom{p_end}
{synopt:{cmd:r(p)}}The p-value{p_end}


{title:References}


Cassart, D. (2007). Optimal Tests for Symmetry. PhD dissertation,Université Libre de Bruxelles.

Hallin, M. and Paindaveine D. (2006). Semiparametrically efficient rank-based inference for shape. I. Optimal rank-based tests for 
sphericity. Annals of Statistics 34, 2707-2756.

Verardi, V. and Croux, C. (2009). Robust regression in Stata. Stata Journal 9(3), 439-453.

{title:Also see}

{psee}
Manual:  {manlink R mvtest}  {break}
 {manhelp smultiv R} (if installed) {p_end}
