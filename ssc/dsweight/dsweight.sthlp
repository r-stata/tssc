{smcl}
{hline}
help for {cmd:dsweight} and {cmd:scdsweight}{right:(Roger Newson)}
{hline}

{title:Generate direct standardization weights for input to estimation commands}

{p 8 21 2}
{cmd:dsweight} {help varlist:{it:stanvarlist}} {ifin} {weight} {cmd:using} {it:filename} ,
  {break}
  {opth g:enerate(newvarname)}
  [ {break}
  {opth gr:oupvars(varlist)} {opth by(varlist)}
  {opt noco:mplete} {opt m:issing} {break}
  {opth tfr:eqvar(varname)} {cmdab:sorted} {cmdab:float} {cmdab:fast}
  ]

{p 8 21 2}
{cmd:scdsweight} {help varlist:{it:stanvarlist}} {ifin} {weight} {cmd:using} {it:filename} ,
  {break}
  {opth g:enerate(newvarname)}
  {opth sc:envar(varname)}
  [ {break}
  {opth by(varlist)}
  {opt noco:mplete} {opt m:issing} {break}
  {opth tfr:eqvar(varname)} {cmdab:sorted} {cmdab:float} {cmdab:fast}
  ]

{pstd}
where {help varlist:{it:stanvarlist}} is a {varlist} specifying a list of standardization variables.


{title:Description}

{pstd}
{cmd:dsweight} generates direct standardization weights for input as {help weight:pweights} to estimation commands,
standardizing the joint distribution of a list of standardization variables
to a standard target population,
possibly within groups defined by value combinations of a list of group variables.
A direct standardization weight is defined as a ratio
between the frequency of a combination of values of standardization variables in a target standard population
and the frequency of the same combination of values of standardization variables in the sample or group.
The standard target population may be the full sample,
or a by-group defined by a combination of values of by-variables,
or it may be defined using a dataset with 1 observation per combination of the group variables,
and data on the frequencies of these combinations in the standard target population.
{cmd:scdsweight} is a version of {cmd:dsweight} for generating scenario direct standardization weights,
which can be input as scenario weights to the {help ssc:SSC} package {helpb scsomersd}.


{title:Options for {cmd:dsweight} and {cmd:scdsweight}}

{phang}
{opth generate(newvarname)} must be present.
It specifies the name of a new variable to be generated,
containing the direct standardization weights.

{phang}
{opth groupvars(varlist)} ({cmd:dsweight} only)
specifies a list of variables,
whose value combinations will be groups,
within which the joint distribution of the standardization variables in the {help varlist:{it:stanvarlist}}
will be standardized, using the sampling probability weights,
to the joint distribution of the standardization variables in the target population.
If {cmd:groupvars()} is absent,
then the standardization weights will standardize the joint distribution of the standardization variables
in the full input sample
to the standard target population.
The full input sample is the set of all observations in the dataset
(or in the by-group if {cmd:by()} is specified)
for which the values of all standardization variables and all group variables are non-missing,
and which are not excluded by the {helpb if} and/or {helpb in} qualifiers.

{phang}
{opth scenvar(varname)} ({cmd:scdsweight} only)
specifies a binary scenario-indicator variable,
with values 0 and 1,
indicating that an observation is present in a scenario,
for which the scenario direct standardization weights will be calculated.
These scenario direct standardization weights are equal to zero for observations not in the scenario,
and equal to direct standardization weights for observations in the scenario,
standardizing the distribution of the standardization variables
for observations in the scenario
to the standard population.
These scenario direct standardization weights may be input,
as scenario-specific weights,
to the {helpb scsomersd} package, downloadable from SSC.
The {helpb scsomersd} package uses rank methods
to compare the distributions of outcomes between scenarios.
An example of a scenario-comparison rank statistic is the population attributwble risk,
which may be either crude or age-standardized.

{phang}
{opth by(varlist)} specifies a list of by-variables,
whose combinations (missing or non-missing) specify the by-groups.
The standardization weights are calculated independently within each by-group.
If a {cmd:using} dataset is specified,
then the by-variables must be present in this {cmd:using} dataset,
and, together with the standardization variables,
they must uniquely identify the observations in the {cmd:using} dataset.
If a {cmd:using} dataset is not specified,
then the generated standardization weights will standardize the joint distribution of the standardization variables
to the subset of the total sample within each by-group.

{phang}
{opt nocomplete} specifies that each group specified by the {opt groupvars()} option
(or the scenario specified by the {cmd:scenvars()} option)
does not have to contain the full list of value combinations of the standardization variables.
If {opt nocomplete} is absent,
then {cmd:dsweight} and {cmd:scdsweight} checks that each combination of values of the standardization variables
(within each by-group if {opt by()} is specified)
is present in each combination of values of the {opt groupvars()} variables,
or in the scenario specified by the {opt scenvar()} variable,
within each by-group if {opt by()} is specified.
If this condition is not met,
then {cmd:dsweight} or {cmd:scdsweight} will fail.

{phang}
{opt missing} specifies that the generated standardization weights,
in the variable named by {opt generate()},
may have missing values in the input sample,
even if the group (or scenario) variables and standardization variables are non-missing.
This may be because the sum of weights in the sample, group or scenario is zero,
or because a {cmd:using} dataset is specified
and does not contain an observation with the current combination of the standardization variables.
If {opt missing} is not specified, and some standardization weights in the input sample are missing,
then {cmd:dsweight} or {cmd:scdsweight} will fail.

{phang}
{opth tfreqvar(varname)} specifies the name of a variable, in the {cmd:using} dataset,
containing the frequencies (or sums of weights) of the corresponding combination of standardization variables
in the standard target population.
If {opt tfreqvar()} is not specified,
and a {cmd:using} dataset is specified,
then {cmd:dsweight} or {cmd:scdsweight} looks for a variable named {cmd:_freq}.
Such a variable will usually be present if the {cmd:using} dataset has been created
by the Stata command {helpb contract},
or by the {help ssc:SSC} package {helpb xcontract}.

{phang}
{opt sorted} functions as the option of the same name for {helpb merge}.
It specifies that the observations in the {cmd:using} dataset are already sorted
by the standardization variables
(or by the by-variables and the standardization variables if {opt by()} is specified),
so there is no need for Stata to sort them before use.
This may save some computational time.

{phang}
{opt float} specifies that the output variable specified by {opt generate()}
will be of {help datatypes:storage type} {cmd:float} or lower.
If {opt float} is not specified,
then the output variable will be generated as type {cmd:double}.
Note that the output variable will be compressed after being generated (using {helpb compress})
to the lowest type possible without loss of precision,
whether or not the user specifies {opt float}.

{phang}
{cmd:fast} is an option for programmers.
It specifies that {cmd:dsweight} or {cmd:scdsweight} will take no action
to restore the existing dataset in memory in the event of failure,
or if the user presses {help break:Break}.
If {cmd:fast} is not specified, then {cmd:dsweight} and {cmd:scdsweight} will take this action,
which uses an amount of time depending on the size of the dataset in memory.


{title:Remarks}

{pstd}
{cmd:dsweight} works on the same principle as {helpb dstdize}.
However, {cmd:dsweight} creates {help weight:weights} that can be input to estimation commands as {helpb weight:pweights},
in order to estimate a wide range of directly-standardized parameters
(not only rates and proportions).
{cmd:scdsweight} is intended for use with the {helpb scsomersd} package,
which the user can download from {help ssc:SSC},
and which calculates rank statistics for comparing scenarios.
The user must also download the {help ssc:SSC} packages {helpb somersd} and {helpb expgen},
if {helpb scsomersd} is to work.


{title:Examples}

{pstd}
The following examples make use of the {helpb xcontract} command,
which can be downloaded from {help ssc:SSC},
and is an extended version of {helpb contract}.

{pstd}
Set-up:

{phang2}{cmd:. use http://www.stata-press.com/data/r11/lbw.dta, clear}{p_end}
{phang2}{cmd:. gene agegp=age}{p_end}
{phang2}{cmd:. recode agegp (0/19=1) (20/29=2) (30/max=3)}{p_end}
{phang2}{cmd:. lab def agegp 1 "<20" 2 "20-29" 3 "30+"}{p_end}
{phang2}{cmd:. lab val agegp agegp}{p_end}
{phang2}{cmd:. lab var agegp "Age group"}{p_end}
{phang2}{cmd:. describe}{p_end}
{phang2}{cmd:. tab agegp, m}{p_end}

{pstd}
The following example creates and lists standardization weights,
standardizing the children of smoking and non-smoking mothers
to the age group distribution in the total sample,
and then uses {cmd:regress},
with the standardization weights as sampling probability weights,
to estimate an effect of maternal smoking on birth weight,
standardized by age group.
We then use {helpb censlope}, part of the {help ssc:SSC} package {helpb somersd},
to estimate an age-standardized median difference in birth weight
between the babies of smoking and non-smoking mothers.

{phang2}{cmd:. dsweight agegp, groupvars(smoke) gene(swei1)}{p_end}
{phang2}{cmd:. xcontract smoke agegp swei1, list(, abbr(32) sepby(smoke))}{p_end}
{phang2}{cmd:. regress bwt smoke [pweight=swei1]}{p_end}
{phang2}{cmd:. censlope bwt smoke [pweight=swei1], transf(z) tdist}{p_end}

{pstd}
The following example creates a dataset {cmd:agpfreq1},
with 1 observation per maternal age group
and data on the frequencies of that maternal age group
in the children of non-smoking mothers.
We then use {cmd:dsweight} to create sampling probability weights,
standardizing the children of smokers and non-smokers
to the maternal age group distribution of non-smokers,
and display these weights using {helpb xcontract}.
We then use {cmd:regress} to estimate the effect of smoking,
in a hypothetical population,
where smoking and non-smoking mothers
have the age distribution of non-smokers in the sample.
Finally, we use {helpb censlope}
to estimate an age-standardized median difference in birth weight
between the babies of smoking and non-smoking mothers.

{phang2}{cmd:. xcontract agegp if smoke==0, list(, abbr(32)) saving(agpfreq1, replace)}{p_end}
{phang2}{cmd:. dsweight agegp using agpfreq1, groupvars(smoke) gene(swei2)}{p_end}
{phang2}{cmd:. xcontract smoke agegp swei2, list(, abbr(32) sepby(smoke))}{p_end}
{phang2}{cmd:. regress bwt smoke [pweight=swei2]}{p_end}
{phang2}{cmd:. censlope bwt smoke [pweight=swei2], transf(z) tdist}{p_end}

{pstd}
The following example demonstrates the use of the {cmd:scdsweight} module
to compute scenario direct standardization weights for use with the {helpb scsomersd} package,
downloadable from {help ssc:SSC}.
We define a scenario indicator variable {cmd:nonsmoke},
indicating that a subject is a non-smoker.
We then use {cmd:scsomersd} to define scenario direct-standardization weights,
stored in a new variable {cmd:swei3},
and equal to age-standardization weights for children of non-smokers
and to zero for children of smokers.
We then use {helpb scsomersd} to compare two scenarios,
the real-world scenario
and a fantasy scenario where all mothers are non-smoking and the age-group distribution stays the same,
and estimate a population attributable risk,
equal to the difference between the proportions of babies with low birth weight
in the real-world scenario and in the fantasy scenario.

{phang2}{cmd:. gene nonsmoke=1-smoke}{p_end}
{phang2}{cmd:. scdsweight agegp, scenvar(nonsmoke) gene(swei3)}{p_end}
{phang2}{cmd:. xcontract smoke nonsmoke agegp swei3, list(, abbr(32) sepby(smoke))}{p_end}
{phang2}{cmd:. scsomersd low [pwei=1], sweight(swei3) transf(z) tdist}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] merge}, {hi:[D] contract}, {hi:[R] dstdize}
{p_end}
{p 4 13 2}
On-line: help for {helpb merge}, {helpb contract}, {helpb dstdize}
{break} help for {helpb xcontract}, {helpb somersd}, {helpb censlope}, {helpb scsomersd}, {helpb expgen} if installed
{p_end}
