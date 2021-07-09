{smcl}
{hline}
help for {cmd:punafcc}{right:(Roger Newson)}
{hline}

{title:Population attributable and unattributable fractions for case-control and survival studies}

{p 8 21 2}
{cmd:punafcc} {ifin} {weight} , [ {opt at:spec(atspec)}
  {opt subpop(subspec)} {opt vce(vcespec)} {opt df(#)} {cmdab::no}{opt e:sample} {opt force}
  {opt iter:ate(#)} {opt ef:orm} {opt l:evel(#)} {opt post}
  ]

{pstd}
where {it:atspec} is an at-specifications recognized by the {cmd:at()} option of {helpb margins},
{it:subspec} is a subpopulation specificarion of the form recognized by the {cmd:subpop()} option of {helpb margins},
and {it:vcespec} is a variance-covariance specification of the form recognized by {helpb margins},
and must have one of the values

{pstd}
{cmd:delta} | {cmd:unconditional}

{pstd}
{cmd:fweight}s, {cmd:aweight}s, {cmd:iweight}s, {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd}
{cmd:punafcc} calculates confidence intervals for population attributable and unattributable fractions
in case-control or survival studies.
{cmd:punafcc} can be used after an estimation command whose parameters are interpreted as log rate ratios,
such as {helpb logit} or {helpb logistic} for case-control data,
or {helpb stcox} or {helpb stcrreg} for survival data.
It estimates the log of the mean rate ratio, in cases or deaths,
between 2 scenarios,
a baseline scenario ("Scenario 0") and a fantasy scenario ("Scenario 1"),
in which one or more exposure variables are assumed to be set to particular values (typically zero),
and any other predictor variables in the model are assumed to remain the same.
This ratio is known as the population unattributable fraction (PUF),
and is subtracted from 1 to derive the population attributable fraction (PAF),
defined as the proportion of the cases or deaths attributable
to living in Scenario 0 instead of Scenario 1.


{title:Options for {cmd:punafcc}}

{phang}
{opt atspec(atspec)} is an at-specification,
allowed as a value of the {cmd:at()} option of {helpb margins}.
This at-specification must specify a single scenario ("Scenario 1"),
defined as a fantasy world in which a subset of the predictor variables in the model
are set to values different from their value in the baseline scenario
(denoted "Scenario 0" and equal to the real-life scenario).
The at-specification may set variables only to values (not to statistics).
{cmd:punafcc} uses the {helpb margins} command to estimate the mean rate ratio, in cases or deaths,
between Scenarios 0 and 1,
and then uses {helpb nlcom} to estimate the log of this ratio,
known as the population unattributable fraction (PUF).
The PUF, and its confidence limits, are subtracted from 1
to calculate a confidence interval for the population attributable fraction (PAF).
If {cmd:atspec()} is not specified,
then its default value is {cmd:atzero((asobserved) _all)},
implying that Scenario 1 is the real-life baseline scenario,
represented by the predictor values actually present.

{phang}
{opt subpop(subspec)} and {opt vce(vcespec)} have the same form and function as the options of the same names for {helpb margins}.
They specify the subpopulation and the variance-covariance matrix formula, respectively,
used to estimate the mean Scenario 0/Scenario 1 rate ratio,
and therefore to estimate the population unattributable and attributable fractions.

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
of the log of the mean Scenario 0/Scenario 1 rate ratio in cases or deaths,
with respect to the rate ratio itself, calculated by {helpb margins}.

{phang}
{opt eform} specifies that {cmd:punafcc} will display an estimate, {it:P}-value and confidence limits
for the population unattributable fraction, instead of for its log.
If {cmd:eform} is not specified, then a confidence interval for the log is displayed.
In either case, {cmd:punafcc} also displays a confidence interval
for the population attributable fraction (PAF).

{phang}
{opt level(#)} specifies the percentage confidence level to be used in calculating the confidence intervals.
If it is not specified, then it is taken from the current value of the {help creturn:c-class value}
{cmd:c(level)},
which is usually 95.

{phang}
{opt post} specifies that {cmd:punafcc} will post in {cmd:e()}
the {help estimates:estimation results}
for estimating the log of the mean Scenario 0/Scenario 1 rate ratio in cases or deaths, the PUF.
If {cmd:post} is not specified, then any existing estimation results are left in {cmd:e()}.
Note that the estimation results posted are for the log of the mean rate ratio in cases or deaths (the PUF),
whether or not {cmd:eform} is specified.


{title:Remarks}

{pstd}
{cmd:punafcc} essentially implements the method for estimating population attributable fractions (PAFs)
recommended by {help punafcc##greenland_1993:Greenland and Drescher (1993)} for case-control studies.
This source recommended the use of the Normalizing and variance-stabilizing transformation

{pstd}
{cmd:log(PUF) = log(1-PAF)}

{pstd}
to define confidence intervals for the PAF.
{cmd:punafcc} starts by estimating the log of the  mean rate ratio in cases or deaths (the PUF),
using {helpb margins} and {helpb nlcom}.
The results of this estimation are stored in {cmd:e()},
if the option {cmd:post} is specified.
These estimation results may be saved in an output dataset (or resultsset) by the {helpb parmest} package,
which can be downloaded from {help ssc:SSC}.

{pstd}
{cmd:punafcc} assumes that the most recent {help estimates:estimation command}
estimates the parameters of a single-equation regression model,
whose parameters are interpreted as log rate ratios.
It is the user's responsibility to ensure that this is the case.
However, it will be true if the model is a logistic regression model on case-control data,
fitted using {helpb logit}, {helpb logistic} or {helpb glm},
or a Cox proportional hazard model or competing risk model on survival data,
fitted using {helpb stcox} or {helpb stcrreg}, respectively.
{cmd:punafcc} estimates the PUF as the Scenario 0/Scenario 1 mean rate ratio,
restricted to observations representing deaths, if the previous command was {helpb stcox} or {helpb stcrreg},
and restricted to observations with a non-missing non-zero value of the dependent variable,
after any other estimation command.

{pstd}
{cmd:punafcc} was written to replace some of the functions of the {helpb aflogit} package
({help punafcc##brady_1998:Brady, 1998}).
{helpb aflogit} was written in {help version:Version 6 of Stata},
and therefore will not work if the user uses long variable names and factor variables,
which were introduced in later {help version:Stata versions}.

{pstd}
Note that {cmd:punafcc} (unlike {helpb aflogit}) does not implement the formulas
for estimating PAFs in cross-sectional and cohort studies,
which can be done using the {helpb punaf} package.
The {helpb punaf} package estimates general scenario means of non-negative variables
and their ratio (the PUF),
and subtracts the estimate from 1 to get the PAF.
The logs of PUFs in case-control and survival studies represent a different kind of parameter
from the logs of PUFs in cohort and cross-sectional studies,
but both can be estimated using {helpb margins} and {helpb nlcom}.
Note, also, that both kinds of PAF are a different parameter from the population attributable risk (PAR),
which can be estimated using the {helpb regpar} package.
Users who need to estimate 2 scenario means and their difference
should probably use {helpb scenttest}.
Users who need to estimate scenario prevalences (without differences)
should use {helpb margprev}.
Users who need to estimate log-transformed scenario means (without ratios)
should use {helpb marglmean}.
The packages {helpb punaf}, {helpb regpar}, {helpb scenttest}, {helpb margprev} and {helpb marglmean}
are downloadable from {help ssc:SSC}.

{pstd}
The general principles behind scenario comparisons in generalized linear models
were introduced by 
{help punafcc##lane_1982:Lane and Nelder (1982)}.
More about the programs {helpb punaf}, {cmd:punafcc}, {helpb regpar}, {helpb marglmean} and {helpb margprev}
can be found in
{help punafcc##newson_2012:Newson (2012)}
and in
{help punafcc##newson_2013:Newson (2013)}.


{title:Examples}

{pstd}
The following examples use the dataset {helpb webuse:ccxmp.dta}.
This dataset has 1 observation for each combination of case status and exposure,
and data on the number of subjects with that case and exposure status.

{pstd}
Setup

{phang2}{cmd:.webuse ccxmpl, clear}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.list}{p_end}

{pstd}
The following example estimates population unattributable and attributable fractions
for exposure as a predictor of case status,
following a logistic regression model.
This is done by comparing "Scenario 1" (a fantasy world in which no subjects are exposed)
with "Scenario 0" (the real world in which the data were collected).
This is done both for all subjects (to get the total-population attributable fraction)
and for exposed subjects (to get the exposed-population attributable fraction).
Note that the point estimators for both these PAFs are the same as those produced by {helpb cc} on the same data.
The option {cmd:vce(unconditional)}, requiring robust variances in the model,
is probably a good idea with case-control or survival studies,
because we might expect covariate values in cases or deaths to be subject to sampling error.
(However, {cmd:vce(unconditional)} should not be used when calculating out-of-sample PAFs
for a second set of case-control or survival data
from a model fitted to a first set of case-control or survival data,
using the {cmd:noesample} option.)

{phang2}{cmd:. cc case exposed [fweight=pop]}{p_end}
{phang2}{cmd:. logit case exposed [fweight=pop], or robust}{p_end}
{phang2}{cmd:. punafcc, at(exposed=0) eform vce(unconditional)}{p_end}
{phang2}{cmd:. punafcc, at(exposed=0) eform vce(unconditional) subpop(exposed)}{p_end}

{pstd}
The following examples use the dataset {helpb webuse:downs.dta}.
This dataset has 1 observation for each combination of case status, exposure and age group,
and data on the number of subjects with that case and exposure status and age group.

{pstd}
Setup

{phang2}{cmd:.webuse downs, clear}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.label list age}{p_end}
{phang2}{cmd:.list, sepby(age)}{p_end}

{pstd}
The following examples estimate age-adjusted exposure effects using logistic regression,
and then estimate the PAF.
This is done by comparing "Scenario 1" (a fantasy world in which no subjects are exposed and the age distribution stays the same)
with "Scenario 0" (the real world in which the data were collected).

{phang2}{cmd:.logit case i.age i.exposed [fweight=pop], or robust}{p_end}
{phang2}{cmd:.punafcc, at(exposed=0) eform vce(unconditional)}{p_end}

{phang2}{cmd:.logit case i.age exposed [fweight=pop], or robust}{p_end}
{phang2}{cmd:.punafcc, at(exposed=0) eform vce(unconditional)}{p_end}

{pstd}
The following example demonstrates the use of {cmd:punafcc} in the same dataset
with an interactive logistic model,
in which exposure effects may vary with age.

{phang2}{cmd:.logit case i.age i.exposed i.age#i.exposed [fweight=pop], or robust}{p_end}
{phang2}{cmd:.punafcc, at(exposed=0) eform vce(unconditional)}{p_end}

{pstd}
The following example demonstrates the use of {cmd:punafcc}
with the {helpb parmest} and {helpb creplace} packages,
downloadable from {help ssc:SSC}.
The population unattributable and attributable fractions for case status
are estimated using {cmd:punafcc} (with the {cmd:post} option),
and saved, using {helpb parmest},
in a dataset in memory,
overwriting the original dataset,
with 1 observation for 1 parameter, the log population unattributable fraction,
named {cmd:"PUF"},
and data on the estimate, confidence limits, {it:P}-value,
and other parameter attributes.
We then use {helpb replace} and {helpb creplace}
to replace the confidence interval for the PUF
with a confidence interval for the PAF,
and {helpb describe} and {helpb list} the new dataset.

{phang2}{cmd:. logit case i.age i.exposed [fweight=pop], or robust}{p_end}
{phang2}{cmd:. punafcc, at(exposed=0) eform vce(unconditional) post}{p_end}
{phang2}{cmd:. parmest, eform norestore}{p_end}
{phang2}{cmd:. foreach Y of var estimate min* max* {c -(}}{p_end}
{phang2}{cmd:. replace `Y'=1-`Y'}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. creplace min* max*}{p_end}
{phang2}{cmd:. replace parm="PAF"}{p_end}
{phang2}{cmd:. describe}{p_end}
{phang2}{cmd:. list}{p_end}

{pstd}
The following example demonstrates the estimation of the PUF and PAF in a Cox regression model
on the {help webuse:drugtr} data,
used as an example for {helpb stcox}.
We estimate a PUF and a PAF comparing the real-world Scenario 0
with a fantasy Scenario 1, in which all subjects receive the drug,
but the subjects' ages are the same as in Scenario 0.

{pstd}
Setup

{phang2}{cmd:. webuse drugtr, clear}{p_end}
{phang2}{cmd:. stset}{p_end}
{phang2}{cmd:. tab drug, m}{p_end}

{pstd}
Example

{phang2}{cmd:. stcox drug age, vce(robust)}{p_end}
{phang2}{cmd:. punafcc, eform at(drug=1) vce(unconditional)}{p_end}


{title:Saved results}

{pstd}
{cmd:punafcc} saves the following in {cmd:r()}:

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
{synopt:{cmd:r(k_at)}}number of {cmd:at()} options (always 0){p_end}
{synopt:{cmd:r(level)}}confidence level of confidence intervals{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(atzero)}}{cmd:at()} option for Scenario 0{p_end}
{synopt:{cmd:r(atspec)}}{cmd:atspec()} option{p_end}
{synopt:{cmd:r(atzero_exp)}}{cmd:expression()} option for Scenario 0/Scenario 0 rate ratio{p_end}
{synopt:{cmd:r(atspec_exp)}}{cmd:expression()} option for Scenario 0/Scenario 1 rate ratio{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(cimat)}}vector containing estimates and confidence limits for the PAF{p_end}
{synopt:{cmd:r(b)}}vector of log Scenario 0/Scenario 1 rate ratio{p_end}
{synopt:{cmd:r(V)}}estimated variance-covariance matrix of log Scenario 0/Scenario 1 rate ratio{p_end}

{pstd}
If {cmd:post} is specified, {cmd:punafcc} also saves the following in {cmd:e()}:

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
{synopt:{cmd:e(k_at)}}number of {cmd:at()} options (always 0){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:punafcc}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(atzero)}}{cmd:at()} option for Scenario 0{p_end}
{synopt:{cmd:e(atspec)}}{cmd:atspec()} option{p_end}
{synopt:{cmd:e(atzero_exp)}}{cmd:expression()} option for Scenario 0/Scenario 0 rate ratio{p_end}
{synopt:{cmd:e(atspec_exp)}}{cmd:expression()} option for Scenario 0/Scenario 1 rate ratio{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of log Scenario 0/Scenario 1 rate ratio{p_end}
{synopt:{cmd:e(V)}}estimated variance-covariance matrix of log Scenario 0/Scenario 1 rate ratio{p_end}
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

{marker brady_1998}{...}
{phang}
Brady A.
1998.
sbe21: Adjusted population attributable fractions from logistic regression.
{it:Stata Technical Bulletin} {bf:STB-42}: 8-12.
Download from {browse "http://www.stata.com/products/stb/journals/stb42.html":the {it:Stata Technical Bulletin} website}.

{marker greenland_1993}{...}
{phang}
Greenland S. and K. Drescher.
1993.
Maximum likelihood estimation of the attributable fraction from logistic models.
{it:Biometrics} {bf:49}: 865-872.

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
Manual:  {manlink R margins}, {manlink R nlcom}, {manlink R logistic}, {manlink R logit}, {manlink ST stcox}, {manlink ST stcrreg}, {manlink R glm}
{p_end}

{psee}
{space 2}Help:  {manhelp margins R}, {manhelp nlcom R}, {manhelp logistic R}, {manhelp logit R}, {manhelp stcox ST}, {manhelp stcrreg ST}, {manhelp glm R}{break}
{helpb punaf}, {helpb regpar}, {helpb scenttest}, {helpb margprev}, {helpb marglmean},
{helpb parmest}, {helpb creplace}, {helpb aflogit} if installed
{p_end}
