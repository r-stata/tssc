{smcl}
{...}
{hline}
help for {cmd:scsomersd}, {cmd:sccendif} and {cmd:sccenslope}{right:(Roger Newson)}
{hline}

{title:Rank statistics for scenario comparisons}

{p 8 21 2}
{cmd:scsomersd} {it:y0} [ {it:y1} ] {weight} {ifin} [{cmd:,}
{cmdab:swe:ight}{cmd:(}{it:expression}{cmd:)}
{cmdab:nyv:ar}{cmd:(}{newvar}{cmd:)}
{cmdab:nwei:ght}{cmd:(}{newvar}{cmd:)}
{cmdab:ncfw:eight}{cmd:(}{newvar}{cmd:)}
{cmdab:nobs}{cmd:(}{newvar}{cmd:)}
{cmdab:nsce:n}{cmd:(}{newvar}{cmd:)}
{it:somersd_options}

{p 8 21 2}
{cmd:sccendif} {it:y0} [ {it:y1} ] {weight} {ifin} [{cmd:,}
{cmdab:swe:ight}{cmd:(}{it:expression}{cmd:)}
{cmdab:nyv:ar}{cmd:(}{newvar}{cmd:)}
{cmdab:nwei:ght}{cmd:(}{newvar}{cmd:)}
{cmdab:ncfw:eight}{cmd:(}{newvar}{cmd:)}
{cmdab:nobs}{cmd:(}{newvar}{cmd:)}
{cmdab:nsce:n}{cmd:(}{newvar}{cmd:)}
{it:cendif_options}

{p 8 21 2}
{cmd:sccenslope} {it:y0} [ {it:y1} ] {weight} {ifin} [{cmd:,}
{cmdab:swe:ight}{cmd:(}{it:expression}{cmd:)}
{cmdab:nyv:ar}{cmd:(}{newvar}{cmd:)}
{cmdab:nwei:ght}{cmd:(}{newvar}{cmd:)}
{cmdab:ncfw:eight}{cmd:(}{newvar}{cmd:)}
{cmdab:nobs}{cmd:(}{newvar}{cmd:)}
{cmdab:nsce:n}{cmd:(}{newvar}{cmd:)}
{it:censlope_options}

{pstd}
where {it:y0} and {it:y1} are either {help varname:{it:varname}}s or numbers,
{it:somersd_options} is a list of options for {helpb somersd} other than {cmd:funtype()},
{it:cendif_options} is a list of options for {helpb cendif} other than {cmd:funtype()} and {cmd:by()},
and {it:censlope_options} is a list of options for {helpb censlope} other than {cmd:funtype()}.

{pstd}
{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see
{help weight}.
However, cluster frequency weights must be specified using the {cmd:cfweight()} option
of {helpb somersd}, {helpb cendif} and {helpb censlope}.

{pstd}
{helpb bootstrap}, {helpb by}, {helpb jackknife}, and {helpb statsby} are allowed.
See {help prefix}.


{title:Description}

{pstd}
{cmd:scsomersd}, {cmd:sccendif} and {cmd:sccenclope} compute confidence intervals
for rank statistics comparing scenarios.
Scenarios are alternative versions of the data,
differing in the values of sampling probability weights
and/or in the values of an outcome variable.
The scenario-comparison rank statistics compare 2 scenarios,
denoted Scenario 0 and Scenario 1,
derived from the dataset in the memory,
in a temporary extended dataset with 1 observation per original observation per scenario.
{cmd:scsomersd} estimates the Somers' {it:D} or Kendall tau-a of the outcome variable,
and {cmd:sccendif} and {cmd:sccenslope} estimate the Hodges-Lehmann percentile differences of the outcome variable,
with respect to scenario membership.
Examples of between-scenario rank statistics
include the Gini coefficient of inequality,
the population attributable risk (PAR),
percentiles of weighted and/or clustered samples,
and Hodges-Lehmann percentile differences between paired samples.
{cmd:scsomersd}, {cmd:sccendif} and {cmd:sccenclope}
use the packages {helpb somersd} and {helpb expgen},
which must be installed in order for the programs to work,
and can be downloaded from {help ssc:SSC}.


{title:Options for use with {cmd:scsomersd}, {cmd:sccendif} and {cmd:sccenslope}}

{p 4 8 2}
{cmd:sweight(}{it:expression}{cmd:)} specifies the {help weight:weight expression} for use in Scenario 1.
The type of weights ({cmd:fweight}s, {cmd:pweight}s or {cmd:iweight}s),
and the weight expression for use in Scenario 0,
are specified in the {help weight:weight expression} supplied to the command.
If {cmd:sweight()} is not specified,
then the weight expression for Scenario 1 is set to the weight expression for Scenario 0.
Note that both scenario weight expressions are interpreted as importance weights,
and that cluster frequency weights must be specified using the {cmd:cfweight()} option
of {helpb somersd}, {helpb cendif} and {helpb censlope}.

{p 4 8 2}
{cmd:nyvar(}{newvar}{cmd:)} specifies the name of the temporary variable,
in the expanded dataset with 1 observation per original observation per scenario,
containing the outcome or {it:Y}-values for use in the scenario comparison.
In observations in Scenario 0,
the value of this variable is equal to the variable (or number) {it:y0}.
In observations in Scenario 1,
the value of this variable is equal to the variable (or number) {it:y1}.
In default, the name is set to {cmd:_yvar}.

{p 4 8 2}
{cmd:nweight(}{newvar}{cmd:)} specifies the name of the temporary variable,
in the expanded dataset with 1 observation per original observation per scenario,
containing the scenario-specific weights for use in the scenario comparison.
These weights are equal to the weight expression passed to the command,
in observations in Scenario 0,
and equal to the weight expression specified by {cmd:sweight()},
in observations in Scenario 1.
In default, the name is set to {cmd:_weight}.

{p 4 8 2}
{cmd:ncfweight(}{newvar}{cmd:)} specifies the name of the temporary variable,
in the expanded dataset with 1 observation per original observation per scenario,
containing the cluster frequency weights for use in the scenario comparison,
specified in the {cmd:cfweight()} option
of {helpb somersd}, {helpb cendif} and {helpb censlope}.
These cluster frequency weights belong to clusters in the original dataset,
if a {cmd:cluster()} option is specified.
Otherwise, they belong to clusters in the extended two-scenario dataset
corresponding to the observations in the original dataset.
In default, the name is set to {cmd:_cfweight}.

{p 4 8 2}
{cmd:nobs(}{newvar}{cmd:)} specifies the name of the temporary variable,
in the expanded dataset with 1 observation per original observation per scenario,
containing the sequential order of the observation, in the original dataset,
corresponding to each observation in the extended dataset.
In default, the name is set to {cmd:_obs}.

{p 4 8 2}
{cmd:nscen(}{newvar}{cmd:)} specifies the name of the temporary variable,
in the expanded dataset with 1 observation per original observation per scenario,
containing the scenario indicator of each observation in the extended dataset.
In the case of {cmd:scsomersd} and {cmd:sccenslope},
this temporary variable is an indicator of membership of Scenario 0,
equal to 0 for observations in Scenario 1,
and 1 for observations in Scenario 0.
In the case of {cmd:sccendif},
this temporary variable is an indication of membership of Scenario 1,
equal to 0 for observations in Scenario 0,
and 1 for observations in Scenario 1.
In default, the name is set to {cmd:_scen0} by {cmd:scsomersd} and {cmd:sccenslope},
and to {cmd:_scen1} by {cmd:sccendif}.

{p 4 8 2}
{it:somersd_options}, {it:cendif_options} and {it:censlope_options}
specify lists of options,
to be passed to {helpb somersd}, {helpb cendif} and {helpb censlope},
respectively.
These options must not include the {cmd:funtype()} option,
which is set automatically to {cmd:funtype(vonmises)}.
In the case of {cmd:sccendif},
these options must not include the {cmd:by()} option,
which is set automatically to the name of the Scenario 1 membership indicator variable
specified by the {cmd:nsscen()} option.


{title:Remarks}

{pstd}
{cmd:scsomersd}, {cmd:sccendif} and {cmd:sccenslope}
work by calling {helpb somersd}, {helpb cendif} and {helpb censlope}, respectively,
in a temporary extended dataset,
with 1 observation per original observation per scenario.
This temporary dataset is generated using the {helpb expgen} package,
downloadable from {help ssc:SSC}.
It contains temporary variables,
which are the outcome variable, scenario-specific weight variable,
cluster frequency weight variable,
observation sequence variable, and scenario membership indicator variable.
The outcome variable is equal to the input variable (or number) {it:y0}
for observations in scenario 0.
For observations in Scenario 1,
the outcome variable is equal to the input variable (or number) {it:y1},
if specified,
and otherwise is equal to the input variable (or number) {it:y0}.
{cmd:sccomersd} calls {helpb somersd} to estimate the Somers' {it:D},
or Kendall's tau-a,
of the outcome variable,
with respect to membership of Scenario 0 instead of Scenario 1.
{cmd:sccendif} and {cmd:sccenslope} call {cmd:cendif} and {cmd:censlope}, respectively,
to estimate the Hodges-Lehmann percentile differences
between observations in Scenario 0 and observations in Scenario 1.
In all cases, the observations of the temporary extended dataset are clustered,
and the confidence interval calculation assumes
that clusters are sampled from a population of clusters,
instead of assuming that observations are sampled from a population of observations.
Clusters are defined using the variable specified by the input {cmd:cluster()} option,
if one is supplied,
and otherwise are defined using the original-observation sequence variable
specified by the {cmd:nobs()} option.

{pstd}
Scenario comparison statistics include a large number of commonly used statistics as special cases.
Examples include the Gini inequality coefficient,
the population attributable risk (PAR),
percentiles estimated from samples which may be clustered
and/or weighted by sampling probability,
and Hodges-Lehmann percentile differences between paired samples.

{pstd}
The commands {cmd:sccenslope} and {cmd:sccendif} estimate the same parameters
{Hodges-Lehmann percentile differences),
with confidence intervals calculated by the same formulas.
However, {cmd:sccendif} uses the {helpb cendif} algorithm,
which uses less computer time in small samples,
and {cmd:sccenslope} uses the {helpb censlope} algorithm,
which uses less computer time in large samples.
For more details on the formulas,
see the on-line and .pdf documentation
for {helpb cendif} and {helpb censlope}.

{pstd}
The {helpb somersd}, {helpb cendif} and {helpb censlope} commands
are part of the {helpb somersd} package.
The {helpb somersd} and {helpb expgen} packages
are downloadable from {help ssc:SSC}.


{title:Examples}

{pstd}
The following example estimates the Gini inequality coefficient for wages in the {cmd:womenwage} data.
In this case,
Scenario 0 is a fantasy lottery in which each woman has a number of tickets proportional to her wage,
and Scenario 1 is a second fantasy lottery in which each woman has one ticket,
whatever her wage, even if it is zero.
The Gini inequality coefficient is reported as Somers' {it:D},
and is the difference between 2 probabilities,
namely the probability that the winner of the first lottery
has a higher wage than the winner of the second lottery
and the probability that the winner of the second lottery
has a higher wage than the winner of the first lottery.
This difference is always non-negative,
but is higher in populations with more unequal wage distributions.

{p 8 12 2}{cmd:. webuse womenwage, clear}{p_end}
{p 8 12 2}{cmd:. describe}{p_end}
{p 8 12 2}{cmd:. scsomersd wage [pwei=wage], swei(1) transf(z) tdist}{p_end}

{pstd}
The following example estimates the unstandardized population attributable risk (PAR)
of case status with respect to exposure
in the {cmd:ugdp} data.
In this case, Scenario 0 is the sample we have, in which some subjects are exposed,
and Scenario 1 is a fantasy sample, in which no subjects are exposed.
The PAR is then the difference between the proportion of subjects which are cases in Scenario 0
and the proportion of subjects which are cases in Scenario 1.
This difference between proportions is reported as Somers' {it:D}.
Note that the population attributable risk (PAR) is a between-scenario difference,
and is not the same parameter as a population attributable fraction (PAF),
which is equal to one minus a between-scenario ratio,
and which can be estimated using the {helpb punaf} package,
downloadable from {help ssc:SSC}.

{p 8 12 2}{cmd:. webuse ugdp, clear}{p_end}
{p 8 12 2}{cmd:. sort age exposed case}{p_end}
{p 8 12 2}{cmd:. describe}{p_end}
{p 8 12 2}{cmd:. list, sepby(age)}{p_end}
{p 8 12 2}{cmd:. scsomersd case [pwei=1], sweight(exposed==0) cfwei(pop) tdist transf(z)}{p_end}

{pstd}
The following example estimates the age-standardized population attributable risk (PAR)
in the {cmd:ugdp} data.
We first define the total numbers of subjects by age group, and by age group and exposure,
in the variables {cmd:wfreq} and {cmd:wxfreq}, respectively.
The ratio {cmd:dswei=wfreq/wxfreq} is a direct standardization weight,
standardizing from the sampled population at each exposure level
to a target population,
with the same age distribution as the total dataset at all exposure levels combined.
We then input these direct standardization weights to {cmd:scsomersd}
to define a difference between the prevalences of case status
between Scenario 0 (the existing sample)
and Scenario 1 (a fantasy sample with the same age distribution and no exposure).

{p 8 12 2}{cmd:. webuse ugdp, clear}{p_end}
{p 8 12 2}{cmd:. sort age exposed case}{p_end}
{p 8 12 2}{cmd:. by age: egen wfreq=total(pop)}{p_end}
{p 8 12 2}{cmd:. by age exposed: egen wxfreq=total(pop)}{p_end}
{p 8 12 2}{cmd:. gene dswei=wfreq/wxfreq}{p_end}
{p 8 12 2}{cmd:. describe}{p_end}
{p 8 12 2}{cmd:. list, sepby(age exposed)}{p_end}
{p 8 12 2}{cmd:. scsomersd case [pwei=1], sweight(dswei*(exposed==0)) cfwei(pop) tdist transf(z)}{p_end}

{pstd}
The following example measures percentile prices (in dollars)
of cars in the {cmd:auto} data.
First, we define a string variable {cmd:firm},
containing, for each car, the firm that made the car.
We then calculate 2 sets of percentile car prices
(the 25th percentile, the median and the 75th percentile),
each defined as a percentile difference between car prices under Scenario 0
(the sample of cars in the dataset)
and Scenario 1 (a fantasy scenario in which all cars have zero price).
The first set of percentiles are unweighted,
with confidence intervals calculated assuming that car models have been sampled
from a population of car models.
The second set of percentiles are weighted
by the car's volume in cubic inches ({cmd:displacement}),
with confidence intervals calculated using the option {cmd:cluster(firm)},
assuming that firms have been sampled from a population of firms.

{p 8 12 2}{cmd:. webuse auto, clear}{p_end}
{p 8 12 2}{cmd:. gene firm=word(make,1)}{p_end}
{p 8 12 2}{cmd:. lab var firm "Firm"}{p_end}
{p 8 12 2}{cmd:. sort foreign firm make}{p_end}
{p 8 12 2}{cmd:. describe}{p_end}
{p 8 12 2}{cmd:. tab firm, m}{p_end}
{p 8 12 2}{cmd:. sccendif price 0, tdist centile(25(25)75)}{p_end}
{p 8 12 2}{cmd:. sccendif price 0 [pwei=displacement], tdist centile(25(25)75) cluster(firm)}{p_end}

{pstd}
The following example uses the {cmd:bpwide} data,
with 1 observation for each of a sample of fictional patients,
and data on blood pressures before and after an unidentified treatment.
We measure the Hodges-Lehmann median difference
between post-treatment and pre-treatment blood pressures in the paired sample,
with confidence intervals calculated to allow for the non-independence
of paired blood pressures from the same patient.
This median difference is reported as a median slope,
together with the mean sign of all treated-untreated differences
(between the same or different patients),
which is reported as Somers' {it:D}.

{p 8 12 2}{cmd:. webuse bpwide, clear}{p_end}
{p 8 12 2}{cmd:. sccenslope bp_after bp_before, tdist}{p_end}

{pstd}
The following example uses the same {cmd:bpwide} data,
and calculates the median pairwise difference
between post-treatment and pre-treatment blood pressures from the same patient
(reported as a median slope),
together with the mean sign of those differences
(reported as Somers' {it:D}).

{p 8 12 2}{cmd:. webuse bpwide, clear}{p_end}
{p 8 12 2}{cmd:. gene bp_diff=bp_after-bp_before}{p_end}
{p 8 12 2}{cmd:. lab var bp_diff "After-before blood pressure difference"}{p_end}
{p 8 12 2}{cmd:. sccenslope bp_diff 0, tdist}{p_end}


{title:Saved results}

{pstd}
{cmd:scsomersd} saves in {cmd:e()}
the estimation results from the {helpb somersd} command that it calls.
{cmd:sccendif} saves in {cmd:r()}, and optionally in {cmd:e()},
the results from the {helpb cendif} command that it calls.
{cmd:sccenslope} saves in {cmd:r()}, and in {cmd:e()},
the results from the {helpb censlope} command that it calls.
However, in all cases, the estimation sample indicator {cmd:e()}
indicates, in each observation,
the presence of that observation in Scenario 0,
and is not affected by the presence of the same observation in Scenario 1.
Observations present in one scenario may be absent in the other,
due to zero sampling probability weights.


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] spearman}, {hi:[R] ranksum}, {hi:[R] signrank}, {hi:[R] roc}, {hi:[R] centile}
{p_end}
{p 4 13 2}
Online:  {helpb ktau}, {helpb ranksum}, {helpb signrank}, {helpb roc}, {helpb centile}{break}
         {helpb somersd}, {helpb cendif}, {helpb censlope}, {helpb expgen}, {helpb punaf} if installed
{p_end}
