{smcl}
{hline}
help for {cmd:margprev}{right:(Roger Newson)}
{hline}

{title:Marginal prevalences from binary regression models}

{p 8 21 2}
{cmd:margprev} {ifin} {weight} , [ {opt at:spec(atspec)}
  {opt subpop(subspec)} {opt pr:edict(pred_opt)} {opt vce(vcespec)} {opt df(#)} {cmdab::no}{opt e:sample} {opt force}
  {opt iter:ate(#)} {opt ef:orm} {opt l:evel(#)} {opt post}
  ]

{pstd}
where {it:atspec} is an at-specification recognized by the {cmd:at()} option of {helpb margins},
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
{cmd:margprev} calculates confidence intervals for marginal prevalences,
also known as scenario proportions.
{cmd:margprev} can be used after an estimation command whose {help predict:predicted values} are interpreted as conditional proportions,
such as {helpb logit}, {helpb logistic}, {helpb probit}, or {helpb glm}.
It estimates a marginal prevalence for a scenario ("Scenario 1"),
in which one or more predictor variables may be assumed to be set to particular values,
and any other predictor variables in the model are assumed to remain the same.


{title:Options for {cmd:margprev}}

{phang}
{opt atspec(atspec)} is an at-specification,
allowed as a value of the {cmd:at()} option of {helpb margins}.
This at-specification must specify a single scenario ("Scenario 1"),
defined as a fantasy world in which a subset of the predictor variables in the model
are set to specified values.
{cmd:margprev} uses the {helpb margins} command to estimate the proportion of outcome values positive
under Scenario 1,
and then uses {helpb nlcom} to estimate the logit of this scenario proportion,
known as the marginal prevalence.
If {cmd:atspec()} is not specified,
then its default value is {cmd:atspec((asobserved) _all)},
implying that Scenario 1 is the real-life baseline scenario,
represented by the predictor values actually present.

{phang}
{opt subpop(subspec)}, {opt predict(pred_opt)} and {opt vce(vcespec)}
have the same form and function as the options of the same names for {helpb margins}.
They specify the subpopulation, the {help predict:predict option(s)}, and the variance-covariance matrix formula, respectively,
used to estimate the logit of the marginal prevalence.

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
to find the optimal step size to calculate the numerical derivative
of the logit of the marginal prevalence,
with respect to the original marginal prevalence calculated by {helpb margins}.

{phang}
{opt eform} specifies that {cmd:margprev} will display an estimate, {it:P}-value and confidence limits
for the marginal odds,
instead of for the log marginal odds (the logit of the marginal prevalence).
If {cmd:eform} is not specified,
then a confidence interval for the log marginal odds is displayed.
In either case, {cmd:margprev} also displays an asymmetric confidence interval
for the untransformed marginal prevalence.

{phang}
{opt level(#)} specifies the percentage confidence level to be used in calculating the confidence interval.
If it is not specified, then it is taken from the current value of the {help creturn:c-class value}
{cmd:c(level)},
which is usually 95.

{phang}
{opt post} specifies that {cmd:margprev} will post in {cmd:e()}
the {help estimates:estimation results}
for estimating the logit of the marginal prevalence.
If {cmd:post} is not specified, then any existing estimation results are left in {cmd:e()}.
Note that the estimation results posted are for the logit of the marginal prevalence,
and not for the marginal prevalence itself.
This is done because the estimation results are intended to define a symmetric confidence interval
for the logit marginal prevalence,
which can be back-transformed to define an asymmetric confidence interval for the untransformed marginal prevalence.


{title:Remarks}

{pstd}
{cmd:margprev} estimates the marginal prevalence, which is a scenario proportion,
which is a special case of a scenario mean.
The general principles behind scenario means
for generalized linear models
were introduced in
{help margprev##lane_1982:Lane and Nelder (1982)}.

{pstd}
{cmd:margprev} starts by estimating the logit of the scenario proportion,
using {helpb margins} and {helpb nlcom}.
The results of this estimation are stored in {cmd:e()},
if the option {cmd:post} is specified.
These estimation results may be saved in an output dataset (or resultsset) by the {helpb parmest} package,
which can be downloaded from {help ssc:SSC}.

{pstd}
{cmd:margprev} assumes that the most recent {help estimates:estimation command}
estimates the parameters of a regression model,
whose {help predict:fitted values} are conditional proportions,
which must be bounded between 0 and 1.
It is the user's responsibility to ensure that this is the case.
However, it will be true if the conditional proportions are defined using a {help glm:generalized linear model}
with a Bernoulli variance function
({it:not} a non-Bernoulli binomial variance function),
and a logit, probit or complementary log-log link function.

{pstd}
Note that {cmd:margprev} estimates a single marginal prevalence,
and does not compare 2 marginal prevalences using differences or ratios.
Users who need to estimate differences between scenario proportions
(population attributable risks)
should use {helpb regpar}.
Users who need to estimate ratios between scenario proportions
(population unattributable fractions)
should use either {helpb punaf}
(for cohort or cross-sectional study data)
or {helpb punafcc}
(for case-control or survival study data).
Users who need to estimate general marginal means
for general non-negative outcomes,
instead of marginal prevalences for outcomes bounded between 0 and 1,
should probably use {helpb marglmean}.
Users who need to estimate marginal means for 2 scenarios and their difference
should probably use {helpb scenttest}.
The packages {helpb marglmean}, {helpb scenttest}, {helpb regpar}, {helpb punaf} and {helpb punafcc} are downloadable from {help ssc:SSC}.

{pstd}
More about the programs {helpb punaf}, {helpb punafcc}, {helpb regpar}, {helpb marglmean} and {cmd:margprev}
can be found in
{help margprev##newson_2012:Newson (2012)}
and in
{help margprev##newson_2013:Newson (2013)}.


{title:Examples}

{pstd}
The following examples use the dataset {helpb datasets:lbw.dta},
provided by {help margprev##hosmer_1988:Hosmer and Lemeshow (1988)} and used in {manlink R logistic}
and distributed by {browse "http://www.stata-press.com/":Stata Press}.
This dataset has 1 observation for each of a sample of pregnancies,
and data on the birth weight of the baby
and on a list of predictive variables,
which might be assumed to be causal by some scientists.

{pstd}
Setup

{phang2}{cmd:. use http://www.stata-press.com/data/r11/lbw.dta, clear}{p_end}
{phang2}{cmd:. describe}{p_end}

{pstd}
The following example estimates marginal prevalences of low birth weight under the existing scenario
and under a fantasy scenario where no mothers smoke.

{phang2}{cmd:. logit low i.race i.smoke, or robust}{p_end}
{phang2}{cmd:. margprev}{p_end}
{phang2}{cmd:. margprev, at(smoke=0)}{p_end}

{pstd}
The following example demonstrates the use of {cmd:margprev}
with the {helpb parmest} package,
downloadable from {help ssc:SSC}.
The marginal prevalence of low birth weight
is estimated using {cmd:margprev} (with the {cmd:post} option),
and saved (in its logit-transformed version), using {helpb parmest},
in a dataset in memory,
overwriting the original dataset,
with 1 observation for the 1 transformed parameter,
named {cmd:"Scenario_1"},
and data on the estimate, confidence limits, {it:P}-value,
and other parameter attributes.
We then use {helpb replace}
to replace the symmetric confidence interval for the transformed parameter
with an asymmetric confidence interval for the untransformed parameter,
and {helpb describe} and {helpb list} the new dataset.

{phang2}{cmd:. logit low i.race i.smoke, or robust}{p_end}
{phang2}{cmd:. margprev, eform post}{p_end}
{phang2}{cmd:. parmest, norestore}{p_end}
{phang2}{cmd:. foreach Y of var estimate min* max* {c -(}}{p_end}
{phang2}{cmd:. replace `Y'=invlogit(`Y')}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. describe}{p_end}
{phang2}{cmd:. list}{p_end}


{title:Saved results}

{pstd}
{cmd:margprev} saves the following in {cmd:r()}:

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
{synopt:{cmd:r(k_at)}}number of {cmd:at()} options (always 1){p_end}
{synopt:{cmd:r(level)}}confidence level of confidence intervals{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(atspec)}}{cmd:atspec()} option{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(cimat)}}row vector containing estimates and confidence limits for the untransformed marginal prevalence{p_end}
{synopt:{cmd:r(b)}}vector of the logit of the marginal prevalence{p_end}
{synopt:{cmd:r(V)}}estimated variance-covariance matrix of the logit of the marginal prevalence{p_end}

{pstd}
If {cmd:post} is specified, {cmd:margprev} also saves the following in {cmd:e()}:

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
{synopt:{cmd:e(k_at)}}number of {cmd:at()} options (always 1){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:margprev}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(atspec)}}{cmd:atspec()} option{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of the logit of the marginal prevalence{p_end}
{synopt:{cmd:e(V)}}estimated variance-covariance matrix of the logit of the marginal prevalence{p_end}
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
Manual:  {manlink R margins}, {manlink R nlcom}, {manlink R logistic}, {manlink R logit}, {manlink R probit}, {manlink R glm}
{p_end}

{psee}
{space 2}Help:  {manhelp margins R}, {manhelp nlcom R}, {manhelp logistic R}, {manhelp logit R}, {manhelp probit R}, {manhelp glm R}{break}
{helpb marglmean}, {helpb regpar}, {help scenttest}, {helpb punaf}, {helpb punafcc}, {helpb parmest} if installed
{p_end}
