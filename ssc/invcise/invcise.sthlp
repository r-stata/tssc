{smcl}
{hline}
help for {cmd:invcise}{right:(Roger Newson)}
{hline}

{title:Compute standard errors using the inverse confidence interval method}

{p 8 21 2}
{cmd:invcise} {help varname:{it:lb_varname}} {help varname:{it:ub_varname}} [ {help varname:{it:dof_varname}} ] {ifin} ,
  {opth std:err(newvarname)}
  [ {opth eformestimate(varname)} {opt l:evel(#)} {opt replace} {opt float} {opt fast} ]

{pstd}
where {help varname:{it:lb_varname}}, {help varname:{it:ub_varname}} and {help varname:{it:dof_varname}}
are the names of existing variables,
containing lower confidence bounds, upper confidence bounds, and degrees of freedom, respectively.


{title:Description}

{pstd}
{cmd:invcise} is intended for use in an output  dataset (or resultsset),
with one observation for each of a set of estimated parameters,
and variables containing their confidence limits,
and (optionally) containing the degrees of freedom used to calculate these confidence limits.
Such datasets may be produced using the official Stata {helpb statsby} prefix,
or by the {helpb parmest} package, downloadable from {help ssc:SSC}.
{cmd:invcise} uses the confidence limits to compute a new variable, containing standard errors for the parameters,
using the inverse confidence interval method.
These standard errors, together with parameter estimates in another variable in the dataset,
may be used to calculate standard errors and confidence intervals for linear combinations of these parameters,
using the {helpb metaparm} module of the {helpb parmest} package,
assuming that the parameters are independently estimated.
The inverse confidence interval method is frequently used with rank statistics,
such as medians, median differences, and median slopes,
to compute confidence intervals for linear combinations of these rank statistics,
particularly differences between differences ("interactions")
or weighted means of several differences ("meta-analysis summaries").


{title:Options}

{phang}
{opth stderr(newvarname)} is required.
It specifies the name of a new variable to be created,
containing standard errors computed from the input confidence limit variables
using the inverse confidence interval method.

{phang}
{opth eformestimate(varname)} specifies the name of a variable,
assumed to be an exponentiated estimate corresponding to the input confidence limits,
and implying that the standard error must be calculated from the log ratio of the confidence limits,
multiplied by the {cmd:eformestimate()} variable,
and then scaled inversely by twice the critical {it:t}-value or {it:z}-value
corresponding to the confidence level specified by {cmd:level()}.
If {cmd:eformestimate()} is not specified,
then the standard error is calculated from the difference between the confidence limits,
scaled inversely by twice the critical {it:t}-value or {it:z}-value
corresponding to the confidence level specified by {cmd:level()}.
The {cmd:eformestimate()} option is useful if the standard errors are used with the {cmd:eformestimate()} variable
for input to the {helpb metaparm} or {helpb parmcip} modules of the {helpb parmest} package,
using the {cmd:eform} option of these modules to produce exponentiated confidence intervals.
Such exponentiated confidence intervals may be used to estimate parameters
which are ratios, ratios of ratios, or geometric mean ratios.

{phang}
{opt level(#)} specifies the {help level:confidence level} assumed for the input confidence limits,
expressed as a percentage.
If {cmd:level()} is not specified,
then {cmd:invcise} first attempts to extract the confidence level
from the {help char:variable characteristic} {help varname:{it:lb_varname}}{cmd:[level]},
and then (if this attempt fails) attempts to extract the confidence level from {help varname:{it:ub_varname}}{cmd:[level]},
and then (if this attempt also fails) extracts the confidence level from the {help creturn:c-class value} {cmd:c(level)},
which contains the default {help level:confidence level} in force in Stata at the time,
which is usually set to 95 to specify 95% confidence limits.
The {help char:variable characteristic} {varname}{cmd:[level]} is created,
for a confidence limit variable with the name {varname},
by the modules of the {helpb parmest} package,
which all set this {help char:characteristic} to be equal to the confidence level
used in calculating the confidence limit variable.

{phang}
{opt replace} specifies that any non-input variable
with the same name as the new variable specified by the {cmd:stderr()} option
will be discarded before the new standard error variable is created.

{phang}
{opt float} specifies that {help type:float} is the highest-precision numeric type
to be allowed for the {cmd:stderr()} variable.
If {cmd:float} is not specified,
then the {cmd:stderr()} variable is created as a {help type:double} variable.
Whether or not {cmd:float} is specified,
the {cmd:stderr()} variable is {help compress:compressed} to the lowest precision possible
without loss of informstion.

{phang}
{opt fast} is an option for programmers.
It specifies that {cmd:invcise} will take no action
to restore the existing dataset in memory in the event of failure,
or if the user presses {help break:Break}.
If {cmd:fast} is not specified, then {cmd:invcise} will take this action,
which uses an amount of time depending on the size of the dataset in memory.


{title:Methods and formulas}

{pstd}
{cmd:invcise} computes standard errors using the inverse confidence interval method,
which is an inversion of the method commonly used
to compute confidence limits from estimates and standard errors.

{pstd}
The default formula (if {cmd:eformestimate()} is not specified)
used to derive a standard error {it:SE} by inverting a 100*(1-{it:alpha})% confidence interval
with lower bound {it:lb} and upper bound {it:ub} is

{pstd}
{it:SE = 0.5*(ub - lb)/z(alpha)}

{pstd}
(where {it:z(alpha)} is the result of {cmd:invnorm(1-}{it:alpha}{cmd:/2)}) if no degrees of freedom variable is specified,
and is

{pstd}
{it:SE = 0.5*(ub - lb)/t(df,alpha)}

{pstd}
(where {it:t(df,alpha)} is the result of {cmd:invttail(}{it:df}{cmd:,1-}{it:alpha}{cmd:/2)} and {it:df} is the degrees of freedom)
if a degrees of freedom variable is specified.

{pstd}
If the {cmd:eformestimate()} option is specified, then the formula used is

{pstd}
{it:SE = 0.5*eformestimate*(log(ub) - log(lb))/z(alpha)}

{pstd}
(where {it:eformestimate} is the variable specified by {cmd:eformestimate()}) if no degrees of freedom variable is specified,
and is

{pstd}
{it:SE = 0.5*eformestimate*(log(ub) - log(lb))/t(df,alpha)}

{pstd}
if a degrees of freedom variable is specified.

{pstd}
These formulas are typically used with confidence intervals for rank statistics,
such as percentiles and percentile differences.
Lehmann (1963) discussed a standard error formula of this kind for Hodges-Lehmann median differences.
McKean and Schrader (1984) discussed a standard error formula of this kind for medians,
which was slightly modified by Bonett and Price (2001).

{pstd}
Usually, standard error formulas are a means to the end of calculating confidence intervals.
The reason for inverting the usual practice is to calculate confidence intervals for linear combinations
of independently estimated parameters,
such as medians or median differences from independent subsamples from distinct subpopulations.
These linear combinations are typically either weighted averages,
or differences,
or weighted averages of differences (as in a meta-analysis),
or differences between differences
(known as interactions, and viewed as important by some scientists).
Bonett and Price (2002) discuss the general case of linear combinations of medians,
and Price and Bonett (2002) discuss the special case of differences (and ratios) between two medians.
Given a list of independently-estimated parameters {it:theta_1, ..., theta_N},
with corresponding standard errors {it:se_1, ..., se_N},
and corresponding coefficients {it:a_1, ..., a_N},
we wish to estimate the linear combination

{pstd}
{it:Theta = Sum ( a_j * theta_j )}

{pstd}
and its standard error

{pstd}
{it:SE = sqrt( Sum (a_j * se_j)^2} )

{pstd}
and we can easily do this using the {helpb metaparm} module of the {helpb parmest} package,
once the standard errors have been calculated using {cmd:invcise}.
We usually expect the Central Limit Theorem to work better for the linear combination
than for its component parameters,
which may be better estimated using their original confidence intervals,
which were inverted using {cmd:invcise} to give their standard errors.


{title:Examples}

{pstd}
The following sequence of commands reads in the {cmd:auto} data
and adds a variable {cmd:odd},
indicating whether a car model is odd-numbered or even-numbered.
This dataset is used in the examples,
which compare differences in mileage between non-US cars and US cars
within the odd-numbered and even-numbered groups.

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gene byte odd=mod(_n,2)}{p_end}
{phang2}{cmd:.lab def odd 0 "Even" 1 "Odd"}{p_end}
{phang2}{cmd:.lab val odd odd}{p_end}
{phang2}{cmd:.lab var odd "Odd numbered model"}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.tab foreign odd, m}{p_end}

{pstd}
The following example starts by using {helpb centile}, with the {helpb statsby} prefix,
to replace the dataset in memory with a new dataset,
with one observation for each of 4 groups,
defined by combinations of values for the variables {cmd:odd} and {cmd:foreign},
and variables containing group numbers in {cmd:N},
and estimates and lower and upper confidence bounds for the group medians
in {cmd:median}, {cmd:medmin} and {cmd:medmax}.
We then use {cmd:invcise} to compute a standard error for each median,
and use {helpb metaparm} to replace the new dataset with a third dataset,
with one observation per group defined by a value of {cmd:odd},
and data on confidence intervals and {it:P}-values
for differences between median values in non-US and US cars in the group.
The second {helpb metaparm} command lists a confidence interval for the difference (or interaction)
between the foreign-US difference in odd-numbered models and the foreign-US difference in even-numbered models.
The third {cmd:metaparm} command lists a confidence interval for the weighted mean foreign-US difference,
averaging the differences in odd-numbered and even-numbered cars.

{phang2}{cmd:.preserve}{p_end}
{phang2}{cmd:.statsby N=r(N) median=r(c_1) medmin=r(lb_1) medmax=r(ub_1), by(odd foreign) noisily clear: centile mpg}{p_end}
{phang2}{cmd:.list odd foreign N median medmin medmax}{p_end}
{phang2}{cmd:.invcise medmin medmax, stderr(icse)}{p_end}
{phang2}{cmd:.metaparm [iweight=(foreign==1)-(foreign==0)], by(odd) norestore sumvar(N) estimate(median) stderr(icse)}{p_end}
{phang2}{cmd:.list odd N median min95 max95 p}{p_end}
{phang2}{cmd:.metaparm [iweight=(odd==1)-(odd==0)], sumvar(N) estimate(median) stderr(icse) list(,)}{p_end}
{phang2}{cmd:.metaparm [aweight=N], sumvar(N) estimate(median) stderr(icse) list(,)}{p_end}
{phang2}{cmd:.restore}{p_end}

{pstd}
The following example compares Hodges-Lehmann median foreign-US differences,
which are not necessarily the same parameters as foreign-US differences between medians.
We start by using the {helpb censlope} module of the {helpb somersd} package,
together with the {helpb parmby} module of the {helpb parmest} package,
to replace the dataset in memory with a new dataset,
with one observation per value of {cmd:odd},
and data on confidence intervals and {it:P}-values
for foreign-US median differences.
We then use {cmd:invcise} to compute standard errors inversely from the confidence limits.
The first {helpb metaparm} command lists a confidence interval and a {it:P}-value
for the odd-even difference (or interaction) between foreign-US median differences.
The second {helpb metaparm} command lists a confidence interval for the weighted mean of the two foreign-US median differences,
summarizing the foriegn-US differences in the two groups.
The confidence intervals are slightly slimmer than the corresponding confidence intervals in the previous example,
although they are for different parameters.

{phang2}{cmd:.preserve}{p_end}
{phang2}{cmd:.parmby "censlope mpg foreign, tdist estaddr", by(odd) escal(N) norestore ecol(cimat) rename(es_1 N ec_1_1 percent ec_1_2 meddif ec_1_3 mdmin ec_1_4 mdmax)}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.list odd N dof meddif mdmin mdmax}{p_end}
{phang2}{cmd:.invcise mdmin mdmax dof, stderr(icse)}{p_end}
{phang2}{cmd:.metaparm [iweight=(odd==1)-(odd==0)] , sumvar(N) estimate(meddif) stderr(icse) dof(dof) list(,)}{p_end}
{phang2}{cmd:.metaparm [aweight=N], sumvar(N) estimate(meddif) stderr(icse) dof(dof) list(,)}{p_end}
{phang2}{cmd:.restore}{p_end}

{pstd}
The following example is similar to the previous example,
but compares Hodges-Lehmann median foreign/US ratios instead of Hodges-Lehmann median foreign/US differences.
We start by creating the variable {cmd:logmpg} as the log of {cmd:mpg},
and estimate the Hodges-Lehmann median ratios by exponentiating the Hodges-Lehmann median differences for {cmd:logmpg}.
We then use {cmd:invcise}, with the {cmd:eformestimate()} option,
to calculate inverse confidence interval standard errors for the median ratios.
These are then input into {cmd:metaparm} as before,
except that, this time, we use the {cmd:eform} option of {cmd:metaparm},
to estimate the odd/even ratios between foreign/US ratios,
and to estimate the weighted geometric mean foreign/US ratio.

{phang2}{cmd:.preserve}{p_end}
{phang2}{cmd:.gene logmpg=log(mpg)}{p_end}
{phang2}{cmd:.parmby "censlope logmpg foreign, tdist estaddr eform", eform by(odd) escal(N) norestore ecol(cimat) rename(es_1 N ec_1_1 percent ec_1_2 medrat ec_1_3 mrmin ec_1_4 mrmax)}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.list odd N dof medrat mrmin mrmax}{p_end}
{phang2}{cmd:.invcise mrmin mrmax dof, stderr(icse) eformestimate(medrat)}{p_end}
{phang2}{cmd:.metaparm [iweight=(odd==1)-(odd==0)] , sumvar(N) estimate(medrat) stderr(icse) dof(dof) eform list(,)}{p_end}
{phang2}{cmd:.metaparm [aweight=N], sumvar(N) estimate(medrat) stderr(icse) dof(dof) eform list(,)}{p_end}
{phang2}{cmd:.restore}{p_end}

{pstd}
The {helpb parmest} and {helpb somersd} packages can both be downloaded from {help ssc:SSC}.


{title:Saved results}

{pstd}
{cmd:invcise} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(lb)}}name of lower confidence bound variable{p_end}
{synopt:{cmd:r(ub)}}name of upper confidence bound variable{p_end}
{synopt:{cmd:r(dof)}}name of degrees of freedom variable{p_end}
{synopt:{cmd:r(eformestimate)}}name of {cmd:eformestimate()} variable{p_end}
{synopt:{cmd:r(levelsource)}}source of confidence level{p_end}

{p2colreset}{...}

{pstd}
The returned result {cmd:r(levelsource)} may be {cmd:level()},
{it:lb_varname}{cmd:[level]}, {it:ub_varname}{cmd:[level]},
or {cmd:c(level)},
indicating that the confidence level was derived from the {cmd:level()} option,
from the {cmd:level} {help char:characteristic} of the lower bound variable,
from the {cmd:level} {help char:characteristic} of the upper bound variable,
or from the {help creturn:c-class value} {cmd:c(level)},
respectively.


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
Lehmann, E. L.  1963.
Nonparametric confidence intervals for a shift parameter.
{it:Annals of Mathematical Statistics} 34(4): 1507-1512.

{phang}
McKean, J. W. and Schrader, R. M.  1984.
A comparison of methods for studentizing the sample median.
{it:Communications in Statistics - Simulation and Computation} 13(6): 751-773.

{phang}
Price, R. M. and Bonett, D. G.  2002.
Distribution-free confidence intervals for difference and ratio of medians.
{it:Journal of Statistical Computation and Simulation} 72(2): 119-124.

{phang}
Price, R. M. and Bonett, D. G.  2001.
Estimating the variance of the sample median.
{it:Journal of Statistical Computing and Simulation} 68(3): 295-305.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] centile}, {hi:[D] statsby}
{p_end}
{p 4 13 2}
On-line: help for {helpb centile}, {helpb statsby}
{break} help for {helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm}, {helpb somersd}, {helpb censlope}, {helpb cendif}, {help rcentile} if installed
{p_end}
