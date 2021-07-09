{smcl}
{hline}
help for {cmd:regpar}{right:(Roger Newson)}
{hline}

{title:Population attributable and unattributable risks from binary regression models}

{p 8 21 2}
{cmd:regpar} {ifin} {weight} , [ {opt at:spec(atspec)}
  {opt atz:ero(atspec0)} {opt subpop(subspec)} {opt pr:edict(pred_opt)} {opt vce(vcespec)} {opt df(#)} {cmdab::no}{opt e:sample} {opt force}
  {opt iter:ate(#)} {opt l:evel(#)} {opt post}
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
{cmd:regpar} calculates confidence intervals for population attributable risks,
and also for scenario proportions.
{cmd:regpar} can be used after an estimation command whose {help predict:predicted values} are interpreted as conditional proportions,
such as {helpb logit}, {helpb logistic}, {helpb probit}, or {helpb glm}.
It estimates two scenario proportions,
a baseline scenario ("Scenario 0") and a fantasy scenario ("Scenario 1"),
in which one or more exposure variables are assumed to be set to particular values (typically zero),
and any other predictor variables in the model are assumed to remain the same.
It also estimates the difference between the Scenario 0 proportion and the Scenario 1 proportion.
This difference is known as the population attributable risk (PAR),
and represents the amount of risk attributable
to living in Scenario 0 instead of Scenario 1.


{title:Options for {cmd:regpar}}

{phang}
{opt atspec(atspec)} is an at-specification,
allowed as a value of the {cmd:at()} option of {helpb margins}.
This at-specification must specify a single scenario ("Scenario 1"),
defined as a fantasy world in which a subset of the predictor variables in the model
are set to values different from their value in the baseline scenario
(denoted "Scenario 0" and equal to the real-life scenario unless {cmd:atzero()} is specified).
{cmd:regpar} uses the {helpb margins} command to estimate the proportions of outcome values positive
under Scenarios 0 and 1,
and then uses {helpb nlcom} to estimate the logits of these 2 scenario proportions,
and the hyperbolic arctangent (or Fishers's {it:z}-transform)
of the difference between the Scenario 0 proportion and the Scenario 1 proportion,
known as the population attributable risk (PAR).
The proportion positive under Scenario 1 is known as the population unattributable risk (PUR).
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
They specify the subpopulation, the {help predict:predict option(s)}, and the variance-covariance matrix formula, respectively,
used to estimate the scenario proportions,
and therefore to estimate the population attributable risk.

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
of the logits of the scenario proportions and the {it:z}-transform of their difference,
with respect to the original scenario proportions calculated by {helpb margins}.

{phang}
{opt level(#)} specifies the percentage confidence level to be used in calculating the confidence intervals.
If it is not specified, then it is taken from the current value of the {help creturn:c-class value}
{cmd:c(level)},
which is usually 95.

{phang}
{opt post} specifies that {cmd:regpar} will post in {cmd:e()}
the {help estimates:estimation results}
for estimating the logits of the scenario means and the {it:z}-transform of their difference, the PAR.
If {cmd:post} is not specified, then any existing estimation results are left in {cmd:e()}.
Note that the estimation results posted are for the logits of the scenario proportions
and the {it:z}-transform of their difference,
and not for the proportions themselves and their difference.
This is done because the estimation results are intended to define symmetric confidence intervals for the transformed parameters,
which can be back-transformed to define asymmetric confidence intervals for the untransformed parameters.


{title:Remarks}

{pstd}
{cmd:regpar} estimates the population attributable risk,
defined in its simplest unadjusted form by {help regpar##gordis_2000:Gordis (2000)}.
The general principles behind scenario comparisons
for generalized linear models
were introduced in
{help regpar##lane_1982:Lane and Nelder (1982)}.

{pstd}
{cmd:regpar} starts by estimating the logits of the scenario proportions
and the hyperbolic arctangent or Fisher's {it:z}-transform of their difference (the PAR),
using {helpb margins} and {helpb nlcom}.
The results of this estimation are stored in {cmd:e()},
if the option {cmd:post} is specified.
These estimation results may be saved in an output dataset (or resultsset) by the {helpb parmest} package,
which can be downloaded from {help ssc:SSC}.

{pstd}
{cmd:regpar} assumes that the most recent {help estimates:estimation command}
estimates the parameters of a regression model,
whose {help predict:fitted values} are conditional proportions,
which must be bounded between 0 and 1.
It is the user's responsibility to ensure that this is the case.
However, it will be true if the conditional proportions are defined using a {help glm:generalized linear model}
with a Bernoulli variance function
({it:not} a non-Bernoulli binomial variance function),
and a logit, probit or complementary log-log link function.

{pstd}
Note that population attributable and unattributable risks (PARs and PURs)
are not the same parameters as population attributable and unattributable fractions (PAFs and PUFs).
A population attributable risk is a difference between scenario proportions,
a population unattributable fraction is a ratio between scenario proportions (or means),
and a population attributable fraction is the result of subtracting a population unattributable fraction from 1.
Users who need to estimate population unattributable fractions should use either {helpb punaf}
(for cohort or cross-sectional study data)
or {helpb punafcc}
(for case-control or survival study data).
Users who need to estimate between-scenario differences between means
should use {helpb scenttest}.
Users who need to estimate scenario prevalences (without differences)
should use {helpb margprev}.
Users who need to estimate log-transformed scenario means (without ratios)
should use {helpb marglmean}.
The packages {helpb punaf}, {helpb punafcc}, {helpb scenttest}, {helpb margprev} and {helpb marglmean}
are downloadable from {help ssc:SSC}.

{pstd}
Note, also, that {cmd:regpar} estimates population attributable risks (PARs)
using an indirect-standardization method,
based on a regression model.
Alternatively, a user can estimate the PAR using a direct-standardization method,
based on rank statistics.
This can be done using the {helpb scsomersd}, {helpb somersd} and {helpb expgen} packages,
which also are downloadable from {help ssc:SSC}.

{pstd}
More about the programs {helpb punaf}, {helpb punafcc}, {cmd:regpar}, {helpb marglmean} and {helpb margprev}
can be found in
{help regpar##newson_2012:Newson (2012)}
and in
{help regpar##newson_2013:Newson (2013)}.


{title:Examples}

{pstd}
The following examples use the dataset {helpb datasets:lbw.dta},
provided by {help regpar##hosmer_1988:Hosmer and Lemeshow (1988)} and used in {manlink R logistic}
and distributed by {browse "http://www.stata-press.com/":Stata Press}.
This dataset has 1 observation for each of a sample of pregnancies,
and data on the birth weight of the baby
and on a list of predictive variables,
which might be assumed to be causal by some scientists.

{pstd}
Setup

{phang2}{cmd:.use http://www.stata-press.com/data/r11/lbw.dta, clear}{p_end}
{phang2}{cmd:.describe}{p_end}

{pstd}
The following example estimates population unattributable and attributable risks
for maternal smoking during pregnancy as a predictor of low birth weight.
This is done by comparing "Scenario 1" (a fantasy world in which no pregnant women smoke)
with "Scenario 0" (the real world in which the data were collected).

{phang2}{cmd:. logit low i.race i.smoke, or robust}{p_end}
{phang2}{cmd:. regpar, at(smoke=0)}{p_end}

{pstd}
The following example estimates population unattributable and attributable risks
for maternal smoking and non-white race.
This is done by comparing "Scenario 1" (a fantasy world in which all pregnant women are white and no pregnant women smoke)
with "Scenario 0" (the real world in which the data were collected).

{phang2}{cmd:.logit low i.race i.smoke, or robust}{p_end}
{phang2}{cmd:.regpar, at(smoke=0 race=1)}{p_end}

{pstd}
The following example demonstrates the use of {cmd:regpar}
with a univariate model of low birth weight with respect to maternal smoking status,
to estimate total and exposed PARs.
We {helpb logit} to estimate the odds ratio of low birth weight
with respect to maternal smoking,
and use {cmd:regpar} to estimate the scenario proportions and PARs,
first for the total population,
then for the smoking-exposed subpopulation.
Finally, we use {cmd:regpar} with the {cmd:atzero()} option to compare 2 alternative fantasy scenarios,
a "Scenario 0" in which no mothers smoke
and a "Scenario 1" in which all mothers smoke.
Note that, in this comparison, the PAR is negative,
because a world of non-smoking mothers would have fewer low birth weight babies
than a world of smoking mothers.

{phang2}{cmd:.logit low i.smoke, or robust}{p_end}
{phang2}{cmd:.regpar, at(smoke=0)}{p_end}
{phang2}{cmd:.regpar if smoke==1,  at(smoke=0)}{p_end}
{phang2}{cmd:.regpar, at(smoke=1) atzero(smoke=0)}{p_end}

{pstd}
The following example demonstrates the use of {cmd:regpar}
with the {helpb parmest} package,
downloadable from {help ssc:SSC}.
The population unattributable and attributable risks for smoking
are estimated using {cmd:regpar} (with the {cmd:post} option),
and saved (in their transformed versions), using {helpb parmest},
in a dataset in memory,
overwriting the original dataset,
with 1 observation for each of the 3 transformed parameters,
named {cmd:"Scenario_0"}, {cmd:"Scenario_1"} and {cmd:"PAR"},
and data on the estimates, confidence limits, {it:P}-values,
and other parameter attributes.
We then use {helpb replace}
to replace the symmetric confidence intervals for the transformed parameters
with asymmetric confidence intervals for the untransformed parameters,
and {helpb describe} and {helpb list} the new dataset.

{phang2}{cmd:. logit low i.race i.smoke, or robust}{p_end}
{phang2}{cmd:. regpar, at(smoke=0) post}{p_end}
{phang2}{cmd:. parmest, norestore}{p_end}
{phang2}{cmd:. foreach Y of var estimate min* max* {c -(}}{p_end}
{phang2}{cmd:. replace `Y'=invlogit(`Y') if parm!="PAR"}{p_end}
{phang2}{cmd:. replace `Y'=tanh(`Y') if parm=="PAR"}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. describe}{p_end}
{phang2}{cmd:. list}{p_end}

{pstd}
The following advanced example demonstrates the use of {cmd:regpar} after a mixed model,
fitted using the {cmd:towerlondon} dataset
used in the on-line help for {helpb meglm}.
We estimate the population unattributable and attributable fractions,
comparing task completion rates in the real world
to a fantasy scenario,
where all subjects are controls,
and other covariates stay the same.
Note that the fantasy proportion is greater than the real-world proportion and the PAR is negative,
because controls complete the task more often than comparable cases.

{phang2}{cmd:. webuse towerlondon, clear}{p_end}
{phang2}{cmd:. describe, full}{p_end}
{phang2}{cmd:. tab group, m}{p_end}
{phang2}{cmd:. meglm dtlm difficulty i.group || family: || subject:, family(bernoulli) vce(robust) eform}{p_end}
{phang2}{cmd:. regpar, at(group=1)}{p_end}


{title:Saved results}

{pstd}
{cmd:regpar} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(rank)}}rank of {cmd:r(V)}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(N_sub)}}subpopulation observations{p_end}
{synopt:{cmd:r(N_clust)}}number of clusters{p_end}
{synopt:{cmd:r(N_psu)}}number of samples PSUs, survey data only{p_end}
{synopt:{cmd:r(N_strata)}}number of strata, survey data only{p_end}
{synopt:{cmd:r(df_r)}}variance degrees of freedom{p_end}
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
{synopt:{cmd:r(cimat)}}vector containing estimates and confidence limits for the scenario proportions and the PAR{p_end}
{synopt:{cmd:r(b)}}vector of logits of scenario proportions and their {it:z}-transformed difference{p_end}
{synopt:{cmd:r(V)}}estimated variance-covariance matrix of the logits of scenario proportions and their {it:z}-transformed difference{p_end}

{pstd}
If {cmd:post} is specified, {cmd:regpar} also saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_sub)}}subpopulation observations{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(N_psu)}}number of samples PSUs, survey data only{p_end}
{synopt:{cmd:e(N_strata)}}number of strata, survey data only{p_end}
{synopt:{cmd:e(df_r)}}variance degrees of freedom{p_end}
{synopt:{cmd:e(N_poststrata)}}number of post strata, survey data only{p_end}
{synopt:{cmd:e(k_margins)}}number of terms in {it:marginlist}{p_end}
{synopt:{cmd:e(k_by)}}number of subpopulations{p_end}
{synopt:{cmd:e(k_at)}}number of {cmd:at()} options (always 2){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:regpar}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(atzero)}}{cmd:atzero()} option{p_end}
{synopt:{cmd:e(atspec)}}{cmd:atspec()} option{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of logits of scenario proportions and their {it:z}-transformed difference{p_end}
{synopt:{cmd:e(V)}}estimated variance-covariance matrix of the logits of scenario proportions and their {it:z}-transformed difference{p_end}
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

{marker gordis_2000}{...}
{phang}
Gordis, L.
2000.
{it:Epidemiology. 2nd ed.}
Philadelphia, PA: W. B. Saunders.

{marker hosmer_1988}{...}
{phang}
Hosmer Jr., D. W., S. Lemeshow, and J. Klar.
1988.
Goodness-of-fit testing for the logistic regression model when
the estimated probabilities are small.
{it:Biometrical Journal} {bf:30}: 911-924.

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
Manual:  {manlink R margins}, {manlink R nlcom}, {manlink R logistic}, {manlink R logit}, {manlink R probit}, {manlink R glm}, {manlink ME meglm}
{p_end}

{psee}
{space 2}Help:  {manhelp margins R}, {manhelp nlcom R}, {manhelp logistic R}, {manhelp logit R}, {manhelp probit R}, {manhelp glm R}, {manhelp meglm ME}{break}
{helpb punaf}, {helpb punafcc}, {helpb scenttest}, {helpb margprev}, {helpb marglmean},
{helpb parmest}, {helpb scsomersd}, {helpb somersd}, {helpb expgen} if installed
{p_end}
