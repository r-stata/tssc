{smcl}
{hline}
help for {cmd:bpmedian} and {cmd:bpdifmed}{right:(Roger Newson)}
{hline}

{title:Bonett-Price confidence intervals for medians and their contrasts}

{p 8 21 2}
{cmd:bpmedian} {varname} {ifin} [ , {opt l:evel(#)} {opt ef:orm} {opt fast} ]

{p 8 21 2}
{cmd:bpdifmed} {varname} {ifin} , {cmd:by(}{help varname:{it:groupvarname}}{cmd:)} [ {opt l:evel(#)} {opt ef:orm} {opt fast} ]

{pstd}
where {help varname:{it:groupvarname}} is the name of a grouping variable,
which should only have two non-missing values.

{pstd}
{cmd:by} is allowed; see {helpb by:[R] by}.


{title:Description}

{pstd}
{cmd:bpmedian} calculates a Bonett-Price confidence interval for a median, using the Bonett-Price standard error,
and saves the results as {help ereturn:estimation results}.
These can then be saved in an output dataset (or resultsset),
using the {helpb parmest} package (downloadable from {help ssc:SSC}),
and then input to the {helpb metaparm} module of the {helpb parmest} package
to calculate Bonett-Price confidence intervals
for a linear contrast between medians of independent groups.
{cmd:bpdifmed} calculates Bonett-Price confidence intervals for the medians of two groups,
defined by a grouping variable,
and also for their difference or ratio.


{title:Options for {cmd:bpmedian} and {cmd:bpdifmed}}

{phang}
{opt level} specifies the {help level:confidence level} to be used for calculating the confidence intervals.

{phang}
{opt eform} specifies that confidence intervals will be calculated for the exponentiated median(s),
and also, in the case of {cmd:bpdifmed}, for the ratio between the first exponentiated median and the second exponentiated median.
The {cmd:eform} option is useful if the input {varname} contains the logarithms of a primary variable,
because, for a continuous positive random variable,
the ratio between two exponentiated subpopulation medians of the logged variable
is then the ratio between the two corresponding unexponentiated subpopulation medians of the unlogged variable.
If {cmd:eform} is not specified,
then confidence intervals are calculated for the unexponentiated median(s),
and also, in the case of {cmd:bpdifmed}, for the difference between the first median and the second median.
Note that, for a real-life variable (which is never perfectly continuous in a finite sample),
the median estimate produced when using the logged variable and specifying {cmd:eform}
may be different from the median estimate produced when using the unlogged variable and not specifying {cmd:eform}.
This is because the unlogged variable may have two mid-range values.
In this case, the median estimate produced using the unlogged variable without {cmd:eform}
is the arithmetic mean of the two mid-range values,
and the median estimate produced using the logged variable with {cmd:eform}
is the geometric mean of the two mid-range values,
and is lower than their arithmetic mean.

{phang}
{opt fast} is an option for programmers.
It specifies that {cmd:bpmedian} and {cmd:bpdifmed} will take no action
to restore the original data if the program fails,
or if the user presses {help break:Break}.


{title:Options for {cmd:bpdifmed} only}

{phang}
{cmd:by(}{help varname:{it:groupvarname}}{cmd:)}
specifies a grouping variable, which must have exactly 2 non-missing values.
{cmd:bpdifmed} will estimate the difference between the medians,
or the ratio between the exponentiated medians,
for the dependent variable specified by the {varname} in the two groups.


{title:Use of {helpb predict} after {cmd:bpmedian}}

{pstd}
If {helpb predict} is used after {cmd:bpmedian},
then the predicted values calculated
(using {helpb predict} with no options or with the {cmd:xb} option)
will be equal to the estimated median,
and the standard errors calculated (using {helpb predict} with the {cmd:stdp} option)
will be equal to the standard error of the estimated median.
The {cmd:score} option of {helpb predict} is not allowed after {cmd:bpmedian}.


{title:Remarks}

{pstd}
The Bonett-Price variance estimator fot the sample median is introduced in Price and Bonett (2001).
The theory behind Bonett-Price confidence intervals for general contrasts of independent sample medians
is introduced in Bonett and Price (2002).
The special case of confidence intervals for the difference or ratio between the medians of two independent groups
is discussed in Price and Bonett (2002).
The formulas for these confidence intervals are related to the confidence interval formulas
used by {helpb centile}, {helpb mean} and {helpb ttest},
but are not the same formulas as used by either of those commands.

{pstd}
Note that the difference (or ratio) between medians
is not the same parameter as the Hodges-Lehmann median pairwise difference (or ratio) between values of a variable in two groups,
which is estimated by the {helpb cendif} module of the {helpb somersd} package,
downloadable from {help ssc:SSC}.
The two population parameters are the same if either the two subpopulation  distributions are symmetrical
or the two subpopulation distributions differ only in location.
The methods of {cmd:bpmeddif} and {helpb cendif} still produce consistent estimates if neither of these assumptions is true.
However, under those circumstances, the two methods are estimating different parameters,
and are not alternative methods for estimating the same parameter.


{title:Examples}

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.bpmedian weight}{p_end}
{phang2}{cmd:.bpdifmed weight, by(foreign)}{p_end}

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gene logweight=log(weight)}{p_end}
{phang2}{cmd:.bpmedian logweight, eform}{p_end}
{phang2}{cmd:.bpdifmed logweight, eform by(foreign)}{p_end}

{pstd}
The following example demonstrates the use of {helpb bpmedian}
with the {helpb parmby} and {helpb metaparm} modules of the {helpb parmest} package,
downloadable from {help ssc:SSC}.
We first estimate medians for length (in inches) in even-numbered US cars, odd-numbered US cars,
even-numbered non-US cars, and odd-numbered non-US cars.
These medians, with their confidence limits and {it:P}-values,
are stored in an output dataset (or resultsset),
with one observation per car group,
which is stored in the memory, overwriting the original input dataset.
The new dataset is listed.
We then use {helpb metaparm} to estimate the difference between differences between non-US cars and US cars
with odd and even sequence numbers.
This difference between differences (or interaction) is listed,
and not saved.

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gene byte odd=mod(_n,2)}{p_end}
{phang2}{cmd:.parmby "bpmedian length", by(foreign odd) norestore}{p_end}
{phang2}{cmd:.list}{p_end}
{phang2}{cmd:.metaparm [iweight=((odd==1)-(odd==0))*((foreign==1)-(foreign==0))], list(,)}{p_end}


{title:Saved results}

{pstd}
{cmd:bpmedian} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(c)}}rank of original upper confidence limit{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:bpmedian}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(properties)}}{hi:b V}{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
The scalar {cmd:e(c)} contains the rank, in the outcome-sorted sample,
of the original upper confidence limit,
denoted as {hi:c} in the equations of Price and Bonett (2001).
The Bonett-Price standard error is an example of a standard error
calculated by the inverse confidence interval method,
using an original confidence interval, defined without using a standard error,
and extending from the {hi:N-c+1}th order statistic to the {hi:c}th order statistic.
The {helpb invcise} package, downloadable from SSC,
is also used to compute standard errors for sample statistics,
using the inverse confidence interval method.

{pstd}
{cmd:bpdifmed} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(N_1)}}first sample size{p_end}
{synopt:{cmd:r(N_2)}}second sample size{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:r(by)}}name of {cmd:by()} variable defining groups){p_end}
{synopt:{cmd:r(eform)}}{cmd:eform} if specified{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(cimat)}}matrix of sample numbers, confidence intervals and {it:P}-values{p_end}
{p2colreset}{...}

{pstd}
The matrix {cmd:r(cimat)} is displayed as output by {cmd:bpdifmed}.
It has 5 columns,
containing sample numbers, estimates, lower and upper confidence limits, and {it:P}-values,
respectively.
It has 3 rows, containing this information on the first sample median, the second sample median,
and the difference (or ratio) between medians, respectively.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Bonett, D. G. and Price, R. M.  2002.
Statistical inference for a linear function of medians:
Confidence intervals, hypothesis testing, and sample size requirements.
{it:Psychological Methods} 7(3): 370-383.

{phang}
Price, R. M. and Bonett, D. G.  2002.
Distribution-free confidence intervals for difference and ratio of medians.
{it:Journal of Statistical Computation and Simulation} 72(2): 119-124.

{phang}
Price, R. M. and Bonett, D. G.  2001.
Estimating the variance of the sample median.
{it:Journal of Statistical Computation and Simulation} 68(3): 295-305.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] centile}, {hi:[R] mean}, {hi:[R] ttest}, {hi:[R] predict}
{p_end}
{p 4 13 2}
On-line: help for {helpb centile}, {helpb mean}, {helpb ttest}, {helpb predict}
{break} help for {helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm}, {helpb somersd}, {helpb cendif}, {helpb censlope}, {helpb invcise}
if installed
{p_end}
