{smcl}
{hline}
help for {cmd:scenttest}{right:(Roger Newson)}
{hline}

{title:Scenario arithmetic (or geometric) means and their difference (or ratio)}

{p 8 21 2}
{cmd:scenttest} {ifin} {weight} , [ {opt at:spec(atspec)}
  {opt atz:ero(atspec0)} {opt subpop(subspec)} {opt pr:edict(pred_opt)} {opt vce(vcespec)} {opt df(#)} {cmdab::no}{opt e:sample} {cmd:force}
  {opt iter:ate(#)} {opt ef:orm} {opt l:evel(#)} {opt post}
  ]

{pstd}
where {it:atspec} and {it:atspec0} are at-specifications recognized by the {cmd:at()} option of {helpb margins},
{it:subspec} is a subpopulation specification of the form recognized by the {cmd:subpop()} option of {helpb margins},
and {it:vcespec} is a variance-covariance specification of the form recognized by {helpb margins},
and must have one of the values

{pstd}
{cmd:delta} | {cmd:unconditional}

{pstd}
{cmd:fweight}s, {cmd:aweight}s, {cmd:iweight}s, {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd}
{cmd:scenttest} calculates confidence intervals for 2 scenario arithmetic (or geometric) means,
and for their difference (or ratio).
{cmd:scenttest} can be used after an estimation command whose {help predict:predicted values}
are interpreted as conditional arithmetic means of a {it:Y}-variable,
such as {helpb regress}, {helpb poisson}, or {helpb glm}.
It estimates two scenario means,
a baseline scenario ("Scenario 0") and an alternative scenario ("Scenario 1"),
in which one or more exposure variables are assumed to be set to particular values (typically zero),
and any other predictor variables in the model are assumed to remain the same.
It also estimates the difference between the Scenario 0 mean and the Scenario 1 mean.
This difference represents the increase in the mean {it:Y}-value
attributable to living in Scenario 0 instead of Scenario 1.
If the {it:Y}-variable is derived as the log of a positive-valued original outcome variable,
then the scenario means displayed may be the scenario geometric means of the original outcome variable,
and the comparison displayed may be their ratio.


{title:Options for {cmd:scenttest}}

{phang}
{opt atspec(atspec)} is an at-specification,
allowed as a value of the {cmd:at()} option of {helpb margins}.
This at-specification must specify a single scenario ("Scenario 1"),
defined as a fantasy world in which a subset of the predictor variables in the model
are set to values different from their value in the baseline scenario
(denoted "Scenario 0" and equal to the real-life scenario unless {cmd:atzero()} is specified).
{cmd:scenttest} uses the {helpb margins} command to estimate the means of outcome values
under Scenarios 0 and 1,
and then uses {helpb nlcom} to estimate these 2 scenario means,
together with the difference between the Scenario 0 mean and the Scenario 1 mean.
If {cmd:atspec()} is not specified,
then its default value is {cmd:atspec((asobserved) _all)},
implying that Scenario 1 is the real-life baseline scenario,
represented by the predictor values actually present.

{phang}
{opt atzero(atspec0)} is an at-specification,
allowed as a value of the {cmd:at()} option of {helpb margins}.
This at-specification must specify a single baseline scenario ("Scenario 0"),
defined as an alternative fantasy world in which a subset of predictors in the model
are set to the values specified by {it:atspec0}.
Scenario 0 will then be compared to the "Scenario 1" specified by the {cmd:atspec()} option.
If {cmd:atzero()} is not specified,
then its default value is {cmd:atzero((asobserved) _all)},
implying that Scenario 0 is the real-life baseline scenario,
represented by the predictor values actually present.

{phang}
{opt subpop(subspec)}, {opt predict(pred_opt)} and {opt vce(vcespec)}
have the same form and function as the options of the same names for {helpb margins}.
They specify the subpopulation, the {help predict:predict option(s)}, 
and the variance-covariance matrix formula, respectively,
used to estimate the scenario means and their difference.

{phang}
{opt df(#)} has the same function as the option of the same name for {helpb margins} and {helpb nlcom}.
It specifies the degrees of freedom to be used in calculating confidence intervals.
If absent, it is set to the default used by {helpb margins},
which may be missing, implying the use of the standard Normal distribution.

{phang}
{opt noesample} has the same function as the option of the same name for {helpb margins}.
It specifies that computations will not be restricted to the estimation sample
used by the previous estimation command.

{phang}
{opt force} has the same function as the option of the same name for {helpb margins}.

{phang}
{opt iterate(#)} has the same form and function as the option of the same name for {helpb nlcom}.
It specifies the number of iterations used by {helpb nlcom}
to find the optimal step size to calculate the numerical derivatives
of the scenario means and their difference,
with respect to the original scenario means calculated by {helpb margins}.

{phang}
{opt eform} specifies that {cmd:scenttest} will display estimates, {it:P}-values and confidence limits
for the scenario geometric means of the exponentiated {it:Y}-variable and their ratio.
If {cmd:eform} is not specified,
then confidence intervals are displayed for the scenario arithmetic means of the unexponentiated {it:Y}-variable
and their difference.

{phang}
{opt level(#)} specifies the percentage confidence level to be used in calculating the confidence intervals.
If it is not specified, then it is taken from the current value of the {help creturn:c-class value}
{cmd:c(level)},
which is usually 95.

{phang}
{opt post} specifies that {cmd:scenttest} will post in {cmd:e()}
the {help estimates:estimation results}
for estimating the scenario arithmetic means of the {it:Y}-variable
and their difference.
If {cmd:post} is not specified, then any existing estimation results are left in {cmd:e()}.


{title:Remarks}

{pstd}
{cmd:scenttest} estimates scenario arithmetic means and their difference.
The results of this estimation are stored in {cmd:e()},
if the option {cmd:post} is specified.
These estimation results may be saved in an output dataset (or resultsset) by the {helpb parmest} package,
which can be downloaded from {help ssc:SSC}.
The general principles behind scenario comparisons
for generalized linear models
were introduced in {help scenttest##lane_1982:Lane and Nelder (1982)}.

{pstd}
{cmd:scenttest} assumes that the most recent {help estimates:estimation command}
estimates the parameters of a regression model,
whose {help predict:fitted values} are conditional arithmetic means.
It is the user's responsibility to ensure that this is the case.
However, it will be true if the conditional means are defined using a {help glm:generalized linear model},
which includes linear regression as a special case.

{pstd}
Other scenario comparisons include population attributable and unattributable risks (PARs and PURs)
and population attributable and unattributable fractions (PAFs and PUFs).
A population attributable risk is a difference between scenario proportions,
a population unattributable risk is a senario proportion,
a population unattributable fraction is a ratio between scenario proportions (or means),
and a population attributable fraction is the result of subtracting a population unattributable fraction from 1.
Users who need to estimate population attributable risks should use {helpb regpar}.
Users who need to estimate population unattributable or attributable fractions should use either {helpb punaf}
(for cohort or cross-sectional study data)
or {helpb punafcc}
(for case-control or survival study data).
Users who need to estimate scenario prevalences (without differences)
should use {helpb margprev}.
Users who need to estimate log-transformed scenario means (without ratios)
should use {helpb marglmean}.
Users who need to estimate untransformed scenario means (without differences or ratios)
should use {helpb margins}.
The packages {helpb regpar}, {helpb punaf}, {helpb punafcc}, {helpb margprev} and {helpb marglmean}
are downloadable from {help ssc:SSC}.
More about them can be found in
{help scenttest##newson_2012:Newson (2012)}
and in
{help scenttest##newson_2013:Newson (2013)}


{title:Examples}

{pstd}
The following example uses the {help sysuse:auto} dataset,
distributed with official Stata.
This dataset has 1 observation for each of a sample of car models.
We fit a regression model, predicting mileage from car weight and non-US origin.
We then use {cmd:scenttest} to estimate the difference in mean mileage
between the real-world sample and a fantasy scenario,
where all cars are from non-US companies,
and their weights are the same as in the real world.
We then compare mean mileage between 2 fantasy scenarios,
one where all cars are from non-US companies and one where all cars are from US companies,
with real-world weights in both scenarios.

{pstd}
Setup

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.describe}{p_end}

{pstd}
Scenario comparisons

{phang2}{cmd:.regress mpg weight i.foreign}{p_end}
{phang2}{cmd:.scenttest, at(foreign=1)}{p_end}
{phang2}{cmd:.scenttest, at(foreign=1) atzero(foreign=0)}{p_end}

{pstd}
The following examples use Poisson regression in the {help webuse:dollhill3} dataset,
distributed by StataCorp.
This dataset has 1 observation for each of 10 combinations
of age group and smoking status,
and data on deaths and person-years of exposure.

{pstd}
Setup

{phang2}{cmd:.webuse dollhill3, clear}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.gene thpyears=pyears/1000}{p_end}
{phang2}{cmd:.label variable thpyears "Exposure (thousand person years)"}{p_end}
{phang2}{cmd:.list, sepby(smokes)}{p_end}

{pstd}
The following example fits an interactive Poisson regression model
to the data,
predicting deaths per thousand person-years
from age group and smoking exposure.
We then use {cmd:scenttest),
with the option {cmd:predict(ir)} and {help weight:pweights} equal to exposure,
to compare incidence rates in the real world
with those in a dream scenario,
where the whole world stops smoking.
We then compare this dream scenario with a nightmare scenario,
where the whole world starts smoking.
Note that the Poisson model is interactive,
with parameters equal to the death rates in each combination of smoking status and age group.
The estimated difference between scenarios therefore allows the possibility that the increase in death rate due to smoking
may vary between age groups.

{phang2}{cmd:.poisson deaths ibn.smokes#ibn.agecat, exposure(thpyears) irr noconst}{p_end}
{phang2}{cmd:.scenttest [pweight=thpyears], predict(ir) at(smokes=0)}{p_end}
{phang2}{cmd:.scenttest [pweight=thpyears], predict(ir) at(smokes=0) atzero(smokes=1)}{p_end}

{pstd}
The following example demonstrates an alternative method,
using the {help ssc:SSC} package {helpb parmest}.
This time, we use {cmd:scenttest} to estimate the mean number of deaths
expected in the 10 combinations of age group and smoking,
in the real world and in the dream scenario,
and the between-scenario difference.
We then use {helpb parmest} to save the parameters to a temporary dataset,
where the means, their difference, and their standard errors and confidence limits
are scaled by the number of combinations
to estimate the expected total numbers of deaths in the two scenarios,
and the number of lives saved by eliminating smoking.

{phang2}{cmd:.scenttest, at(smokes=0)}{p_end}
{phang2}{cmd:.preserve}{p_end}
{phang2}{cmd:.parmest, bmatrix(r(b)) vmatrix(r(V)) escal(N) fast}{p_end}
{phang2}{cmd:.foreach Y of var estimate stderr min* max* {c -(}}{p_end}
{phang2}{cmd:.  replace `Y'=`Y'*es_1}{p_end}
{phang2}{cmd:.{c )-}}{p_end}
{phang2}{cmd:.list, abbr(32)}{p_end}
{phang2}{cmd:.restore}{p_end}


{title:Saved results}

{pstd}
{cmd:scenttest} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(rank)}}rank of {cmd:r(V)}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(N_sub)}}subpopulation observations{p_end}
{synopt:{cmd:r(N_clust)}}number of clusters{p_end}
{synopt:{cmd:r(N_psu)}}number of samples PSUs, survey data only{p_end}
{synopt:{cmd:r(N_strata)}}number of strata, survey data only{p_end}
{synopt:{cmd:r(df_r)}}variance degrees of freedom, survey data only{p_end}
{synopt:{cmd:r(N_poststrata)}}number of post strata, survey data only{p_end}
{synopt:{cmd:r(k_margins)}}number of terms in {it:marginlist}{p_end}
{synopt:{cmd:r(k_by)}}number of subpopulations{p_end}
{synopt:{cmd:r(k_at)}}number of {cmd:at()} options (always 2){p_end}
{synopt:{cmd:r(level)}}confidence level of confidence intervals{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(atzero)}}{cmd:atzero()} option{p_end}
{synopt:{cmd:r(atspec)}}{cmd:atspec()} option{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}vector of scenario arithmetic means and their difference{p_end}
{synopt:{cmd:r(V)}}estimated variance-covariance matrix of scenario arithmetic means and their difference{p_end}

{pstd}
If {cmd:post} is specified, {cmd:scenttest} also saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_sub)}}subpopulation observations{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(N_psu)}}number of samples PSUs, survey data only{p_end}
{synopt:{cmd:e(N_strata)}}number of strata, survey data only{p_end}
{synopt:{cmd:e(df_r)}}variance degrees of freedom, survey data only{p_end}
{synopt:{cmd:e(N_poststrata)}}number of post strata, survey data only{p_end}
{synopt:{cmd:e(k_margins)}}number of terms in {it:marginlist}{p_end}
{synopt:{cmd:e(k_by)}}number of subpopulations{p_end}
{synopt:{cmd:e(k_at)}}number of {cmd:at()} options (always 2){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:scenttest}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(atzero)}}{cmd:atzero()} option{p_end}
{synopt:{cmd:e(atspec)}}{cmd:atspec()} option{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of scenario arithmetic means and their difference{p_end}
{synopt:{cmd:e(V)}}estimated variance-covariance matrix of scenario arithmetic means and their difference{p_end}
{synopt:{cmd:e(V_srs)}}simple-random-sampling-without-replacement (co)variance
hat V_srswor, if {cmd:svy}{p_end}
{synopt:{cmd:e(V_srswr)}}simple-random-sampling-with-replacement (co)variance
hat V_srswr, if {cmd:svy} and {cmd:fpc()}{p_end}
{synopt:{cmd:e(V_msp)}}misspecification (co)variance hat V_msp, if {cmd:svy}
and available{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{marker lane_1982}{...}
{phang}
Lane, P. W., and J. A. Nelder.
1982.
Analysis of covariance and standardization as instances of prediction.
{it: Biometrics} {bf:38}: 613-621.

{marker newson_2012}{...}
{phang}
Newson, R. B.
2012.
Scenario comparisons: How much good can we do?
Presented at {browse "http://ideas.repec.org/p/boc/usug12/01.html":the 18th United Kingdom Stata Users' Group Meeting, 13-14 September, 2012}.

{marker newson_2013}{...}
{phang}
Newson, R. B.
2013.
Attributable and unattributable risks and fractions and other scenario comparisons.
{it: The Stata Journal} {bf:13(4)}: 672-698.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0314":the {it:Stata Journal} website}.


{title:Also see}

{psee}
Manual:  {manlink R margins}, {manlink R nlcom}, {manlink R regress}, {manlink R poisson}, {manlink R glm}
{p_end}

{psee}
{space 2}Help:  {manhelp margins R}, {manhelp nlcom R}, {manhelp regress R}, {manhelp poisson R}, {manhelp glm R}{break}
{helpb regpar}, {helpb punaf}, {helpb punafcc}, {helpb margprev}, {helpb marglmean}, {helpb parmest} if installed
{p_end}
