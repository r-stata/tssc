{smcl}
{hline}
help for {cmd:kmest}{right:(Roger Newson)}
{hline}

{title:Compute Kaplan-Meier survival probabilities and/or percentiles as estimation results}

{p 8 21 2}
{cmd:kmest} {ifin} , [
  {opth t:imes(numlist)} {opth c:entiles(numlist)}
  {opt str:ansform(transform_expression)} {opt ctr:ansform(transform_expression)}
  ]

{pstd}
where {it:transform_expression} is an expression specifying a transformation,
in which the input to the transformation has been substituted by {cmd:@}.


{title:Description}

{pstd}
{cmd:kmest} is intended for use in a survival time dataset set up by {helpb stset}.
It computes Kaplan-Meier survival probabilities (as computed by {helpb sts_generate:sts generate})
for a list of times (sorted in ascending order),
and/or Kaplan-meier percentiles for a list of percents (srted in ascending order),
and saves them as estimation results, without a variance matrix.
{cmd:kmest} is intended for use with the {helpb bootstrap} prefix,
or possibly with the {helpb jackknife} prefix,
to create confidence intervals for the Kaplan-Meier survival probabilities and/or percentiles,
possibly allowing for clustering and/or sampling-probability weighting.


{title:Options}

{phang}
{opth times(numlist)} specifies a list of survival times, for which survival probabilities are estimated.
Note that the times are assumed to be given in the units specified by the {cmd:scale()} option of {helpb stset}.

{phang}
{opth centiles(numlist)} specifies a list of percents, for which survival percentiles are estimated.
Note that the percentiles are computed in the units specified by the {cmd:scale()} option of {helpb stset}.
If a percentile is infinite, then it is set to the {help creturn:c-class value} {cmd:c(maxdouble)}.

{pstd}
Note that one of the options {opt times()} and {opt centiles()} must be present.

{phang}
{opt stransform(transform_expression)} specifies a transform expression for the survival probabilities,
in which the survival probability has been replaced by {cmd:@}.
For instance, if we want to transform the survival probability using the logit transform,
then we use the option {cmd:stransform(logit(@))}.
The default is {cmd:stransform(@)}, implying untransformed survival probabilities.

{phang}
{opt ctransform(transform_expression)} specifies a transform expression for the percentiles,
in which the percentile has been replaced by {cmd:@}.
For instance, if we want to transform the percentile using the log transform,
then we use the option {cmd:ctransform(log(@))}.
The default is {cmd:ctransform(@)}, implying untransformed percentiles.


{title:Examples}

{pstd}
These examples use the {cmd:stan3} dataset,
which the user can download using the {helpb webuse} command,
and which has already been set up as survival time data,
using the {helpb stset} command.

{pstd}
Set-up

{phang2}{cmd:. webuse stan3, clear}{p_end}
{phang2}{cmd:. stset}{p_end}
{phang2}{cmd:. describe, full}{p_end}

{pstd}
Display Kaplan-Meier survival probabilities

{phang2}{cmd:. kmest, times(0(100)2000)}{p_end}

{pstd}
Display Kaplan-Meier percentiles

{phang2}{cmd:. kmest, centiles(0(25)100)}{p_end}

{pstd}
Bootstrap Kaplan-Meier survival probabilities
using the Normal-based and percentile methods

{phang2}{cmd:. bootstrap, reps(1000): kmest, times(0(100)2000)}{p_end}
{phang2}{cmd:. estat bootstrap, percentile}{p_end}

{pstd}
Bootstrap Kaplan-Meier percentiles

{phang2}{cmd:. bootstrap, reps(1000) double: kmest, centiles(0(12.5)100)}{p_end}
{phang2}{cmd:. estat bootstrap, percentile}{p_end}

{pstd}
Note that, in this case, the {helpb bootstrap} command has to have the {cmd:double} option,
and the percentile bootstrap has to be used,
because some of the replications may have infinite percentiles,
represented by the maximum double-precision number {help creturn:c(maxdouble)}.

{pstd}
Bootstrap median using log transform

{phang2}{cmd:. bootstrap, reps(250) double eform(Median): kmest, centiles(50) ctransform(log(@))}{p_end}

{pstd}
Bootstrap survival odds using logit transform

{phang2}{cmd:. bootstrap, reps(250) eform(Survival odds): kmest, times(100(100)2000) stransform(logit(@))}{p_end}


{title:Saved results}

{pstd}
{cmd:kmest} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}Number of observations{p_end}
{synopt:{cmd:e(N_fail)}}Number of failures{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(stransform)}}{cmd:stransform()} option for survival probabilities{p_end}
{synopt:{cmd:e(ctransform)}}{cmd:ctransform()} option for percentiles{p_end}
{synopt:{cmd:e(predict)}}program called by {cmd:predict} ({cmd:kmest_p}){p_end}
{synopt:{cmd:e(properties)}}{cmd:b}{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of survival probability estimates (in ascending order of time){p_end}
{synopt:{cmd:e(times)}}vector of survival times (in ascending order){p_end}
{synopt:{cmd:e(cumfail)}}vector of cumulative failure counts (in ascending order of survival time){p_end}
{synopt:{cmd:e(temat)}}matrix of survival times and survival probability estimates (in ascending order of survival time){p_end}
{synopt:{cmd:e(centiles)}}vector of percents (in ascending order){p_end}
{synopt:{cmd:e(cemat)}}matrix of percents and percentile estimates (in ascending order){p_end}
{synopt:{cmd:e(timcen)}}vector of survval times and/or percents (in ascending order){p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[ST] sts}, {hi:[ST] stset}, {hi:[R] jackknife}, {hi:[R] bootstrap}
{p_end}
{p 4 13 2}
On-line: help for {helpb sts}, {helpb stset}, {helpb jackknife}, {helpb bootstrap}
{p_end}
