{smcl}
{hline}
help for {hi:rcentile}{right:(Roger Newson)}
{hline}

{title:Robust confidence intervals for percentiles allowing for clusters and weights}

{p 8 21 2}
{cmd:rcentile} {it:depvar} {weight} {ifin}
[ {cmd:,} {cmdab:ce:ntile}{cmd:(}{it:numlist}{cmd:)} {cmdab:l:evel}{cmd:(}{it:#}{cmd:)}
{cmdab:cl:uster}{cmd:(}{it:varname}{cmd:)}
{cmdab:cfw:eight}{cmd:(}{it:expression}{cmd:)}
{cmdab:td:ist} {cmdab:tr:ansf}{cmd:(}{it:transformation_name}{cmd:)}
{cmd:fast}
]

{pstd}
where {it:transformation_name} is one of

{p 8 21 2}
{cmd:iden} | {cmd:z} | {cmd:asin}

{pstd}
{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see
{help weight}.

{pstd}
{opt bootstrap}, {opt by}, {opt jackknife}, and {opt statsby}
are allowed; see {help prefix}.{p_end}


{title:Description}

{pstd}
{cmd:rcentile} calculates robust confidence intervals for percentiles,
allowing for clustered sampling and/or weighting if necessary.
{cmd:rcentile} requires the {help ssc:SSC} packages {helpb somersd}, {helpb scsomersd} and {helpb expgen} in order to work.


{title:Options for use with rcentile}

{p 4 8 2}
{cmd:centile(}{it:numlist}{cmd:)} specifies a list of percentiles
to be reported and defaults to {cmd:centile(50)} (median only) if not
specified. Specifying {cmd:centile(25 50 75)} will produce the 25th, 50th, and
75th percentiles.

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, as a percentage, for
confidence intervals; see {helpb level}.

{p 4 8 2}
{cmd:cluster(}{it:varname}{cmd:)} specifies the variable that defines sampling clusters.
If {cmd:cluster()} is defined,
then the confidence intervals are calculated
assuming that the data are a sample of clusters from a population of clusters,
rather than a sample of observations from a population of observations.

{p 4 8 2}
{cmd:cfweight(}{it:expression}{cmd:)} specifies an expression giving the
cluster frequency weights.  These cluster frequency weights must have the same
value for all observations in a cluster.  If {cmd:cfweight()} and
{cmd:cluster()} are both specified,
then each cluster in the dataset is
assumed to represent a number of identical clusters
equal to the cluster frequency weight for that cluster.
If {cmd:cfweight()} is specified and {cmd:cluster()} is unspecified,
then each observation in the dataset is treated as a cluster,
and assumed to represent a number of identical one-observation clusters equal to the cluster frequency weight.
For more details on the interpretation of weights,
see {hi:Interpretation of weights} in the help for {helpb somersd}.

{p 4 8 2}
{cmd:tdist} specifies that the standardized Somers' {it:D} estimates are
assumed to be sampled from a {it:t}-distribution with n-1 degrees of freedom,
where n is the number of clusters,
or the number of observations if {cmd:cluster()} is not specified.
If {cmd:tdist} is not specified,
then the standardized Somers' {it:D} estimates are assumed to be sampled from a standard Normal distribution.
Simulation study data suggest that the {cmd:tdist} option should be used.

{p 4 8 2}
{cmd:transf(}{it:transformation_name}{cmd:)} specifies
that the estimates of mean signs are to be transformed,
defining a standard error for the transformed population value,
from which the confidence limits for the percentile differences are calculated.
{cmd:z} (the default) specifies Fisher's {it:z} (the hyperbolic arctangent),
{cmd:asin} specifies Daniels' arcsine,
and {cmd:iden} specifies identity or untransformed.

{p 4 8 2}
{cmd:fast} is a programmer's option.
It specifies that {cmd:rcentile} will not do any work to restore the original dataset
if the user presses {help break:Break}.


{marker rcentile_methods}{...}
{title:Methods and formulas}

{pstd}
{cmd:rcentile} is described in {help rcentile##rcentile_references:Newson (2014)}.
It estimates confidence intervals for percentiles,
using standard errors for mean signs to derive them.
The 100{hi:q}th percentile of a variable {hi:Y} can be defined as a solution, in {hi:theta},
to the equation

{pstd}
{hi:E[sign( Y - theta )] = 1-2q}

{pstd}
where {hi:sign(.)} denotes the sign function (-1 for negative arguments, +1 for positive arguments
and 0 for zero arguments).
At each value of {hi:theta}, the expression {hi:E[sign( Y - theta )]} is known as a mean sign.
More precisely, the 100{hi:q}th percentile of {hi:Y} can be defined
as the mean of the left and right inverse folded reverse ridits (IFRRs) of {hi:q}.
The left IFRR of {hi:q} is defined as

{pstd}
{hi:sup{c -(}theta: E[sign( Y - theta )] > 1-2q {c )-}}

{pstd}
and the right IFRR of {hi:q} is defined as

{pstd}
{hi:inf{c -(}theta: E[sign( Y - theta )] < 1-2q {c )-}}

{pstd}
where the supremum and infimum of an empty set of numbers are set to minus and plus infinity,
respectively.
The mean of a finite number and an infinite number is set to the finite number.

{pstd}
Note that this method,
when applied to the sample distribution of {hi:Y},
produces percentiles defined in the same way
as those produced by {helpb collapse}.
A slightly different definition of percentiles is used by {helpb centile}.
However, if the variable {hi:Y} really is continuous,
then the 2 percentile definitions are consistent estimators of the same parameter.

{pstd}
{cmd:rcentile} produces confidence limits for percentiles using the delta-jackknife standard error of a transformation

{pstd}
{hi:g(E[sign( Y - theta )])}

{pstd}
where {hi:g(.)} is a function, specified by the {cmd:transf()} option,
which may be the hyperbolic arctangent (Fisher's {it:z}),
the arcsine (Daniels' arcsine),
or the identity.
This standard error is used to define lower and upper confidence limits (by end point transformation)
for the mean sign at the chosen percentile {hi:theta}.
These limits, in turn, are used to define lower and upper confidence limits for the percentile,
equal to the sample left IFRR of the upper confidence limit for the mean sign
and to the sample right IFRR of the lower confidence limit for the mean sign,
respectively.

{pstd}
Note that this method uses standard errors for the mean sign,
or for a transformwd mean sign,
instead of using standard errors for the percentile itself.
This is probably a good idea,
because standard errors are usually estimated using mean squared influence functions,
and the central limit theorem works a lot faster
for the influence function of a mean sign
than for the influence function of a percentile.
See {help rcentile##rcentile_references:Hampel (1974) and Hampel {it:et al} (1986)}
for more about influence functions,
for percentiles and other statistics.

{pstd}
{cmd:rcentile} works by calling the {helpb sccendif} module of the {helpb scsomersd} paclage,
which in turn calls the {helpb expgen} package and the {helpb cendif} module of the {helpb somersd} package,
which in turn calls the {helpb somersd} module of the {helpb somersd} package.
This method treats a percentile as a special case of a percentile slope (see {help rcentile##rcentile_references:Newson, 2006a}),
and treats a mean sign as a special case of Somers' {it:D} (see {help rcentile##rcentile_references:Newson, 2006b}).
For a comprehensive review of Kendall's tau-a, Somers' {it:D}, and median differences,
see {help rcentile##rcentile_references:Newson (2002)}.
The packages {helpb scsomersd}, {helpb somersd} and {helpb expgen}
can be downloaded from {help ssc:SSC}.


{title:Examples}

{pstd}
Set-up:

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. gene firm=word(make,1)}{p_end}
{p 4 8 2}{cmd:. label var firm "Firm"}{p_end}
{p 4 8 2}{cmd:. tab firm, m}{p_end}

{pstd}
Simple examples:

{p 4 8 2}{cmd:. rcentile length, tdist}{p_end}

{p 4 8 2}{cmd:. rcentile length, tdist transf(iden)}{p_end}

{p 4 8 2}{cmd:. rcentile length, tdist centile(0(25)100)}{p_end}

{p 4 8 2}{cmd:. rcentile length, tdist centile(0(25)100) cluster(firm)}{p_end}

{p 4 8 2}{cmd:. rcentile length [pweight=price], tdist centile(0(25)100)}{p_end}

{p 4 8 2}{cmd:. rcentile length [pweight=price], tdist centile(0(25)100) cluster(firm)}{p_end}

{p 4 8 2}{cmd:. by foreign: rcentile length [pweight=price], tdist centile(0(25)100) cluster(firm)}{p_end}

{pstd}
Note that some of these examples will produce "infinite" confidence limits,
equal to the {helpb creturn} results {cmd:c(mindouble)} for lower limits
and {cmd:c(maxdouble)} for upper limits.
(See help for {helpb creturn}.)
This is because the correct confidence intervals for percentiles may be infinite,
especially for percentiles 0 and 100.
See {help rcentile##rcentile_references:Newson, 2006a}.


{title:Saved results}

{pstd}
{cmd:rcentile} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(N_clust)}}number of clusters{p_end}
{synopt:{cmd:r(df_r)}}residual degrees of freedom (if {cmd:tdist} present){p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(depvar)}}name of {it:Y}-variable{p_end}
{synopt:{cmd:r(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:r(cfweight)}}{cmd:cfweight()} expression{p_end}
{synopt:{cmd:r(tdist)}}{cmd:tdist} if specified{p_end}
{synopt:{cmd:r(wtype)}}weight type{p_end}
{synopt:{cmd:r(wexp)}}weight expression{p_end}
{synopt:{cmd:r(centiles)}}list of percents for percentiles{p_end}
{synopt:{cmd:r(transf)}}transformation specified by {cmd:transf()}{p_end}
{synopt:{cmd:r(tranlab)}}transformation label in output{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(cimat)}}confidence intervals for percentiles{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker rcentile_references}{...}
{title:References}

{phang}
Hampel, F. R., E. M. Ronchetti, P. J. Rousseeuw, and W. A. Stahel.  1986.
Robust Statistics: The Approach Based on Influence Functions.
New York: Wiley.

{phang}
Hampel, F. R.  1974.
The influence curve and its role in robust estimation.
{it:Journal of the American Statistical Association} 69: 383–393.

{phang}
Newson, R. B.  2014.
Easy-to-use packages for estimating rank and spline parameters.
Presented at the {browse "http://ideas.repec.org/p/boc/usug14/01.html":20th UK Stata User Meeting, 11–12 September, 2014}.

{phang}
Newson, R.  2006a.
Confidence intervals for rank statistics:  Percentile slopes, differences, and ratios.
{it:Stata Journal} 6: 497-520.
Download from {browse "http://www.stata-journal.com/article.html?article=snp15_7":the {it:Stata Journal} website}.

{phang}
Newson, R.  2006b.
Confidence intervals for rank statistics:  Somers' {it:D} and extensions.
{it:Stata Journal} 6: 309-334.
Download from {browse "http://www.stata-journal.com/article.html?article=snp15_6":the {it:Stata Journal} website}.

{phang}
Newson R.  2002.
Parameters behind "nonparametric" statistics:  Kendall's tau, Somers' {it:D} and median differences.
{it:Stata Journal} 2: 45-64.
Download from {browse "http://www.stata-journal.com/article.html?article=st0007":the {it:Stata Journal} website}.


{title:Also see}

{psee}
Manual: {hi:[D] collapse}, {hi:[R] centile}
{p_end}

{psee}
Online: {helpb collapse}, {helpb centile}{break}
        {helpb somersd}, {helpb cendif}, {helpb scsomersd}, {helpb sccendif}, {helpb expgen} (if installed)
{p_end}
