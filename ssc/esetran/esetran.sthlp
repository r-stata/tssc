{smcl}
{hline}
help for {cmd:esetran} {right:(Roger Newson)}
{hline}


{title:Transforming estimates and standard errors in {helpb parmest} resultssets}

{p 8 21 2}
{cmd:esetran} {help varname:{it:est_varname}} {help varname:{it:se_varname}}
{ifin} [ {cmd:,}
{opt tr:ansformation(transformation_name)}
]

{pstd}
where {help varname:{it:est_varname}} and {help varname:{it:se_varname}} are existing numeric variables
containing the estimates and standard errors,
respectively,
and {it:transformation_name} can be one of

{pstd}
{cmd:log} | {cmd:logit} | {cmd:loglog} | {cmd:cloglog} | {cmd:atanh} | {cmd:asin}


{title:Description}

{pstd}
{cmd:esetran} is designed for use in {helpb parmest} resultssets,
which have one observation per estimated parameter and data on parameter estimates.
It inputs 2 user-specified variables,
containing the estimates and the standard errors,
and replaces them with the estimates and standard errors
of the same parameters after a user-specified transformation,
promoting their {help data_type:storage types} to double precision if necessary.
Parameter values at the boundaries of the parameter range
(such as the logit of 1 or 0 or the hyperbolic arctangent of 1 or -1)
are set to sensible non-missing boundary values.
The user can then use the {helpb parmcip} option of the {helpb parmest} package
to recalculate the {it:t}- and {it:z}-statistics, symmetric confidence limits and {it:P}-values
for the transformed parameters,
and use endpoint transformations on the estimates and confidence limits
to produce asymmetric confidence intervals for back-transformed parameters.
This practice is especially useful
if the user has produced symmetric confidence intervals
for scenario proportions and their differences,
using {helpb margins} after a logistic regression,
and needs to replace them with asymmetric confidence intervals,
which are more likely to have the correct coverage probability.


{title:Options}

{p 4 8 2}
{opt transformation(transformation_name)} must be specified.
It can be one of {cmd:log}, {cmd:logit}, {cmd:loglog}, {cmd:cloglog}, {cmd:atanh} or {cmd:asin},
specifying the log, the logit, the log-log, the complementary log-log,
the hyperbolic arctangent (Fisher's {it:z}), or the arcsine, respectively.
These are all standard Normalizing and/or variance-stabilizing transformations,
used for a variety of parameters.
Typically, we use the log transform for arithmetic means of non-negative-valued variables,
the logit, log-log and complementary log-log transform for proportions,
and the hyperbolic arctangent and arcsine parameters
for differences between proportions.


{title:Methods and formulas}

{pstd}
The log-log transform of {cmd:transformation(loglog)} is defined by the Stata formula

{pstd}
{cmd:y=cloglog(1-x)}

{pstd}
where {cmd:x} is a variable that should have values in the open interval between 0 and 1.
The log-log transform is widely used in survival analysis
to calculate confidence intervals for Kaplan-Meier survival probabilities
(see help for {helpb sts}).
The {cmd:transformation()} values {cmd:log}, {cmd:logit}, {cmd:cloglog}, {cmd:atanh} and {cmd:asin}
are defined using the {help functions:Stata functions} of the same names.

{pstd}
{cmd:esetran} computes the transformed standard errors using the delta method.
For each transformation,
the standard error is computed by multiplying the untransformed standard error by the absolute derivative of the transformation
at the value specified by the estimate.
Before this is done, {cmd:esetran} promotes the estimate and standard errors to double precision if necessary,
and then converts boundary parameter values to sensible boundary values.
Boundary parameter values are non-missing values for the parameter estimates,
indistinguishable, under double precision,
from the values at the boundary of the parameter domain.
These boundary values are 0 and infinity for the log transformation,
0 and 1 for the logit transformation,
and -1 and 1 for the hyperbolic arctangent and arcsine transformations.
They are replaced by double-precisiuon boundary values,
defined using the numeric system limits specified by {helpb creturn}.
These are {cmd:c(smallestdouble)} and {cmd:c(maxdouble)} for the log transformation,
{cmd:c(smallestdouble)} and {cmd:1-c(epsdouble)} for the logit transformation,
and {cmd:c(epsdouble)-1} and {cmd:1-c(epsdouble)} for the hyperbolic arctangent and arcsine transformations.
These substituted values have valid non-missing values for the transformation, and for its derivative,
which is multiplied by the untransformed standard error to give the transformed standard error.
Symmetric confidence intervals for the transformed parameter can then be computed,
assuming the Normal distribution or the {it:t}-distribution,
using the {helpb parmcip} module of the {helpb parmest} package.

{pstd}
The estimates and symmetric confidence limits for the transformed parameter
can then be transformed back, using {helpb replace},
to derive asymmetric confidence intervals for the untransformed parameter.

{pstd}
The {helpb parmest} package can be downloaded from {help ssc:SSC}.
More information about the production and use of {helpb parmest} resultssets
can be found in Newson (2010), Newson (2008),  Newson (2006), Newson (2004), Newson (2003) and Newson (2002).


{title:Examples}

{pstd}
The following examples use the {helpb webuse} command to load the {cmd:lbw} dataset,
with 1 observation for each of 189 pregnancies.
We fit an interactive logistic regression model for low birth weight
with respect to maternal race and smoking during pregnancy.
This produces odds and odds ratios,
which few readers will understand.
So, we use {helpb margins} to compute confidence intervals
for the scenario prevalences of low birthweight in two scenarios,
a dream scenario where all mothers stop smoking and a nightmare scenario where all mothers start smoking,
in which the distribution of race is as in the real-world sample.
We also use {helpb margins} with the {cmd:pwcompare} option
to estimate a difference in prevalences of low birthweight
between the nightmare scenario and the dream scenario.
This difference is interpreted as a causal effect of smoking
in the population as a whole.
We use {cmd:esetran},
together with the {helpb parmest} and {helpb parmcip} modules of the {help ssc:SSC} package {helpb parmest},
to replace the symmetric confidence intervals produced by {helpb margins}
with asymmetric confidence intervals,
derived using Normalizing transformations and back-transformations.

{pstd}
Set-up

{phang2}{inp:. webuse lbw, clear}{p_end}
{phang2}{inp:. describe, full}{p_end}
{phang2}{inp:. tab race smoke, miss}{p_end}
{phang2}{inp:. logit low i.smoke#i.race, or vce(robust) asis}{p_end}

{pstd}
The following example uses {helpb margins} to estimate the scenario prevalences
for the dream scenario where no mothers smoke and for the nightmare scenario where all mothers smoke,
and {helpb parmest} to save the results to a temporary dataset in memory
(temporarily overwriting the original dataset),
with 1 observation per estimated scenario prevalence.
We then use {cmd:esetran} to convert the estimates and standard errors for the prevalences
to estimates and standard errors for the logit prevalences,
{helpb parmcip} to update the {it:z}-statistics, {it:P}-values and confidence limits,
and a {helpb foreach} loop to back-transform the estimates and their confidence limits
to prevalences again.
These results (with asymmetric confidence limits) are then listed,
and the original dataset restored.

{phang2}{inp:. margins i.smoke}{p_end}
{phang2}{inp:. preserve}{p_end}
{phang2}{inp:. parmest, bmat(r(b)) vmat(r(V)) fast}{p_end}
{phang2}{inp:. esetran estimate stderr, transform(logit)}{p_end}
{phang2}{inp:. parmcip, replace}{p_end}
{phang2}{inp:. foreach Y of var estimate min* max* {c -(}}{p_end}
{phang2}{inp:.   replace `Y'=invlogit(`Y')}{p_end}
{phang2}{inp:. {c )-}}{p_end}
{phang2}{inp:. list, abbr(32)}{p_end}
{phang2}{inp:. restore}{p_end}

{pstd}
The following example is like the previous example,
except that it uses the log transform with {cmd:esetran},
and back-transforms the confidence intervals using the {cmd:exp()} function.

{phang2}{inp:. margins i.smoke}{p_end}
{phang2}{inp:. preserve}{p_end}
{phang2}{inp:. parmest, bmat(r(b)) vmat(r(V)) fast}{p_end}
{phang2}{inp:. esetran estimate stderr, transform(log)}{p_end}
{phang2}{inp:. parmcip, replace}{p_end}
{phang2}{inp:. foreach Y of var estimate min* max* {c -(}}{p_end}
{phang2}{inp:.   replace `Y'=exp(`Y')}{p_end}
{phang2}{inp:. {c )-}}{p_end}
{phang2}{inp:. list, abbr(32)}{p_end}
{phang2}{inp:. restore}{p_end}

{pstd}
The following example also uses {helpb margins},
this time with the {cmd:pwcompare} option
to create a confidence interval for the difference between the 2 scenario prevalences.
We then use {helpb parmest} to save the parameter to a temporary dataset in memory,
{cmd:esetran} to convert the estimates and standard errors to the hyperbolic arctangent scale,
{helpb parmcip} to update the other statistics,
and a {helpb foreach} loop to back-transform to the original prevalence difference,
using the {cmd:tanh()} function.
We then list the prevalence differences with their new asymmetric confidence limits
and restore the old dataset.

{phang2}{inp:. margins i.smoke, pwcompare}{p_end}
{phang2}{inp:. preserve}{p_end}
{phang2}{inp:. parmest, bmat(r(b_vs)) vmat(r(V_vs)) fast}{p_end}
{phang2}{inp:. esetran estimate stderr, transform(atanh)}{p_end}
{phang2}{inp:. parmcip, replace}{p_end}
{phang2}{inp:. foreach Y of var estimate min* max* {c -(}}{p_end}
{phang2}{inp:.   replace `Y'=tanh(`Y')}{p_end}
{phang2}{inp:. {c )-}}{p_end}
{phang2}{inp:. list, abbr(32)}{p_end}
{phang2}{inp:. restore}{p_end}

{pstd}
The following example is like the previous example,
except that it uses the arcsine transform with {cmd:esetran},
and back-transforms using the {cmd:sin()} function.

{phang2}{inp:. margins i.smoke, pwcompare}{p_end}
{phang2}{inp:. preserve}{p_end}
{phang2}{inp:. parmest, bmat(r(b_vs)) vmat(r(V_vs)) fast}{p_end}
{phang2}{inp:. esetran estimate stderr, transform(asin)}{p_end}
{phang2}{inp:. parmcip, replace}{p_end}
{phang2}{inp:. foreach Y of var estimate min* max* {c -(}}{p_end}
{phang2}{inp:.   replace `Y'=sin(`Y')}{p_end}
{phang2}{inp:. {c )-}}{p_end}
{phang2}{inp:. list, abbr(32)}{p_end}
{phang2}{inp:. restore}{p_end}

{pstd}
The following example uses {helpb margins} and {helpb parmest}
to create a dataset with 1 observation per smoking status
and data on probabilities of low birthweight.
We then use {cmd:esetran} to transform the estimates and standard errors,
using the decreasing log-log transform.
We then create the confidence limits using {helpb parmcip},
back-transform the estimates and confidence limits,
and use the {help ssc:SSC} package {helpb creplace}
to exchange values between the back-transformed confidence limits.

{phang2}{inp:. margins i.smoke}{p_end}
{phang2}{inp:. preserve}{p_end}
{phang2}{inp:. parmest, bmat(r(b)) vmat(r(V)) fast}{p_end}
{phang2}{inp:. esetran estimate stderr, transform(loglog)}{p_end}
{phang2}{inp:. parmcip, replace}{p_end}
{phang2}{inp:. foreach Y of var estimate min* max* {c -(}}{p_end}
{phang2}{inp:.   replace `Y'=1-invcloglog(`Y')}{p_end}
{phang2}{inp:. {c )-}}{p_end}
{phang2}{inp:. creplace min* max*}{p_end}
{phang2}{inp:. list, abbr(32)}{p_end}
{phang2}{inp:. restore}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Newson, R. B.  2010.  Post-{cmd:parmest} peripherals: {cmd:fvregen}, {cmd:invcise}, and {cmd:qqvalue}.
Presented at {browse "http://ideas.repec.org/s/boc/usug10.html" :the 16th United Kingdom Stata Users' Group Meeting, London, 9-10 September, 2010}.

{phang}
Newson, R. B.  2008.  {cmd:parmest} and extensions.
Presented at {browse "http://ideas.repec.org/s/boc/usug08.html" :the 14th United Kingdom Stata Users' Group Meeting, London, 8-9 September, 2008}.

{phang}
Newson, R.  2006.  Resultssets, resultsspreadsheets, and resultsplots in Stata.
Presented at {browse "http://ideas.repec.org/s/boc/dsug06.html" :the 4th German Stata Users' Group Meeting, Mannheim, 31 March, 2006}.

{phang}
Newson, R.  2004.  From datasets to resultssets in Stata.
Presented at {browse "http://ideas.repec.org/s/boc/usug04.html" :the 10th United Kingdom Stata Users' Group Meeting, London, 29-30 June, 2004}.

{phang}
Newson, R.  2003.  Confidence intervals and {it:p}-values for delivery to the end user.
{it:The Stata Journal} 3(3): 245-269.
Download from {browse "http://www.stata-journal.com/article.html?article=st0043":{it:The Stata Journal} website}.

{phang}
Newson, R.  2002.  Creating plots and tables of estimation results using {cmd:parmest} and friends.
Presented at {browse "http://ideas.repec.org/s/boc/usug02.html" :the 8th United Kingdom Stata Users' Group Meeting, 20-21 May, 2002}.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] data types}, {hi:[P] creturn}, {hi:[R] margins}
{p_end}
{p 4 13 2}
On-line: help for {help data_types}, {helpb creturn}, {helpb margins}
{break} help for {helpb parmest}, {helpb parmcip}, {helpb creplace} if installed
{p_end}
