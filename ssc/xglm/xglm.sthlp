{smcl}
{hline}
help for {cmd:xglm}{right:(Roger Newson)}
{hline}

{title:Extended version of {helpb glm}}

{p 8 21 2}
{cmd:xglm} [ {varlist} ] {ifin} {weight} [, {help glm:{it:glm_options}} ]

{pstd}
where {help glm:{it:glm_options}} is a list of options used by {helpb glm}.


{title:Description}

{pstd}
{cmd:xglm} is an extended version of {helpb glm},
designed mostly for use with the {helpb parmby} module of the {helpb parmest} package,
downloadable from {help ssc:SSC}.


{title:Remarks}

{pstd}
{cmd:xglm} currently saves only 2 extra results, {cmd:e(depvarsum)} and {cmd:e(msum)},
containing the sum of the dependent variable specified in {cmd:e(depvar)}
and the sum of the binomial total specified in {cmd:e(m)},
respectively,
limited to the estimation sample specified in {cmd:e(sample)}.
This allows users of the {helpb parmby} module of the {helpb parmest} package
to output these sums to the output dataset (or resultsset) as an additional variable.
This is especially useful for models with a binomial or Poisson variance function,
because the user can then use these extra variables to produce diagnostic variables,
such as the number of events or non-events per estimated parameter,
which can then inform the user regarding whether the Central Limit Theorem is likely to work
for a binomial or Poisson generalized linear model
in an estimation sample of the size available.


{title:Examples}

{pstd}
The following example illustrates the use of  {cmd:e(depvarsum)}
to store an event count in a {helpb parmby} resultsset
containing the parameters of 2 logistic regression models of non-US origin with respect to repair record,
one in even-numbered models, one in odd-numbered models.
In the resultsset, the diagnostic indicator variable {cmd:epparm}
contains the number of events or nonevents (whichever is smaller)
per estimated parameter.
The values of this diagnostic variable are well below 5,
indicate that the Central Limit Theorem will not work very well for the parameter estimates.
Note that the number of estimated parameters is stored in {cmd:e(df_m)},
because we are using the {cmd:noconst} option, and the variable {cmd:baseline},
to cause the baseline odds to be displayed by {helpb glm} with the {cmd:eform} option.

{pstd}
Set-up:

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gene byte odd=mod(_n,2)}{p_end}
{phang2}{cmd:.lab var odd "Oddness of model sequence number"}{p_end}
{phang2}{cmd:.lab def odd 0 "Even" 1 "Odd"}{p_end}
{phang2}{cmd:.lab val odd odd}{p_end}
{phang2}{cmd:.gene byte baseline=1}{p_end}
{phang2}{cmd:.lab var baseline "Baseline"}{p_end}
{phang2}{cmd:.describe}{p_end}

{pstd}
Estimation and diagnostics:

{phang2}{cmd:.parmby "xglm foreign baseline i.rep78, family(bin) link(logit) eform noconst robust", eform omit escal(df_m N depvarsum) rename(es_1 Nparm es_2 N es_3 Nforeign) by(odd) norestore}{p_end}
{phang2}{cmd:.gene enevents=min(Nforeign,N-Nforeign)}{p_end}
{phang2}{cmd:.gene nepparm=enevents/Nparm}{p_end}
{phang2}{cmd:.lab var enevents "Events or non-events"}{p_end}
{phang2}{cmd:.lab var nepparm "Events or non-events per parameter"}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.by odd: list parm N Nparm Nforeign enevents nepparm omit estimate min* max* p}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Saved results}

{pstd}
{cmd:xglm} saves in {cmd:e()} all results saved by {helpb glm},
and also the following:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(depvarsum)}}sum of dependent variable in estimation sample{p_end}
{synopt:{cmd:e(msum)}}sum of binomial trials {cmd:e(m)} in estimation sample{p_end}
{p2colreset}{...}


{title:Also see}

{psee}
Manual:  {manlink R glm}
{p_end}

{psee}
{space 2}Help:  {manhelp glm R}{break}
{helpb parmest}, {helpb parmby} if installed
{p_end}
