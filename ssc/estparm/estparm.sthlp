{smcl}
{hline}
help for {cmd:estparm} and {cmd:estparmtest} {right:(Roger Newson)}
{hline}


{title:Save results from a {helpb parmest} resultsset and test equality}

{p 8 15}{cmd:estparm} {varlist}  {ifin} [ {cmd:,} {cmdab:l:evel}{cmd:(}{it:#}{cmd:)} {cmdab:ef:orm}
  {cmdab:o:bs}{cmd:(}{varname}{cmd:)} {cmdab:eq:}{cmd:(}{varname}{cmd:)}
  {cmdab:dfc:ombine}{cmd:(}{it:combination_rule}{cmd:)}
 ]

{p 8 15}{cmd:estparmtest} {varlist}  {ifin} [ {cmd:,} {cmdab:l:evel}{cmd:(}{it:#}{cmd:)} {cmdab:ef:orm}
  {cmdab:o:bs}{cmd:(}{varname}{cmd:)} {cmdab:eq:}{cmd:(}{varname}{cmd:)}
  {cmdab:dfc:ombine}{cmd:(}{it:combination_rule}{cmd:)}
 ]


{pstd}
where {varlist} is a list of 2 or 3 variables with the syntax

{p 8 15}{it:estimate_varname} {it:stderr_varname} [ {it:dof_varname} ]

{pstd}
and {it:estimate_varname}, {it:stderr_varname} and {it:dof_varname}
are the names of existing variables, containing parameter estimates, standard errors,
and degrees of freedom, respectively.
If the {it:dof_varname} is specified, then the test statistics are assumed to have a {it:t}-distribution,
with degrees of freedom equal to the sum of the variable specified by {it:dof_varname}.
If the {it:dof_varname} is not specified,
then the test statistics are assumed to have a standard Normal sampling distribution.

{pstd}
A {it:combination_rule} is

{pstd}
{cmd:sum} | {cmd:constant}

{pstd}
{opt by} and {opt statsby} are allowed; see {help prefix}.


{title:Description}

{pstd}
{cmd:estparm} is an inverse of {helpb parmest}.
It inputs 2 or 3 variables in the {varlist},
containing parameter estimates, standard errors, and (optionally) degrees of freedom.
It saves a set of {help estimates:estimation results} for the parameters,
assuming that the parameter estimates are statistically uncorrelated.
{cmd:estparmtest} is an extended version of {cmd:estparm},
which also performs a {help test:chi-squared or F test} of the hypothesis that all these parameters are equal.
{cmd:estparmtest} can be used for performing interaction tests,
using data from regression models for multiple subsets,
stored in a {helpb parmest} or {helpb parmby} output dataset (or resultsset).


{title:Options for {cmd:estparm} and {cmd:estparmtest}}

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, as a percentage, for
confidence intervals of the estimates; see {helpb level}.

{p 4 8 2}
{opt eform} indicates that the input estimates are exponentiated,
and that the input standard errors are multiplied by the exponentiated estimate,
as produced by the {cmd:eform} option of {helpb parmest} and {helpb parmby}.
Note that the output confidence limits are not exponentiated,
whether or not {cmd:eform} is specified.
(This is because the column names in the {help estimates:estimation output} matrices
are all set to {cmd:_cons},
and the {helpb ereturn:ereturn display} command of Stata will not print parameters with that name
if the {cmd:eform()} option is specified.)

{p 4 8 2}
{cmd:obs}{cmd:(}{varname}{cmd:)} specifies an existing numeric variable,
whose sum is stored in the {help estimates:estimation results} as {cmd:e(N)}
and reported in the output as the total number of observations.
Such a variable might have been created by {helpb parmest} or {helpb parmby},
using the option {cmd:escal(N)}.

{p 4 8 2}
{cmd:eq}{cmd:(}{varname}{cmd:)} specifies an existing string variable,
whose values are used to specify the {help matrix rownames:equation names}
used in the {help estimates:estimation results}.
It is the responsibility of the user to ensure that values of this variable are unique.
If {cmd:eq()} is not specified,
then the {help matrix rownames:equation names} are set to numbers from 1 to the number of parameters,
in order of appearance in the dataset.
(The {help matrix rownames:column names} used in the {help estimates:estimation results}
are all set to {cmd:_cons}.)

{p 4 8 2}
{cmd:dfcombine(}{it:combination_rule}{cmd:)} specifies a rule for combining the degrees of freedom of the input parameters
to define the combined residual degrees of freedom for the output estimation results,
if a degrees of freedom variable is specified.
This combined residual degrees of freedom is used by {cmd:estparmtest}
as the denominator degrees of freedom in an {it:F}-test.
The value of {cmd:dfcombine()} may be {cmd:sum} (the default),
or {cmd:constant}.
If {cmd:sum} is specified,
then the residual degrees of freedom for the output estimation results
is the sum of the values of the input degrees of freedom variable.
If {cmd:constant} is specified,
then {cmd:estparm} and {cmd:estparmtest} check that the degrees of freedom variable is equal to a constant value in all input observations,
and sets the output residual degrees of freedom to that constant value.
The specification {cmd:dfcombine(constant)} is useful if the input parameters are uncorrelated parameters of the same model,
and that model was estimated with a single estimation command,
using a common degrees of freedom for all parameters.
This will be the case if the parameters are group means,
and the model is a regression model, whose only parameters are group means,
and which was fitted using a single regression command, with a single pooled scalar degrees of freedom.
If there is no input degrees of freedom variable, then the {cmd:dfcombine()} option is ignored.


{title:Remarks}

{pstd}
{cmd:estparm} and {cmd:estparmtest} are designed for use with output datasets (or resultssets)
produced (directly or indirectly) by the {helpb parmest} package,
which can be downloaded from {help ssc:SSC},
and contains the programs {helpb parmest}, {helpb parmby}, {helpb parmcip} and {helpb metaparm}.
They are intended mainly to perform tests of the hypothesis
that several independently estimated parameters are equal.
In particular, if there are multiple subsets of observations in the data,
and a regression model is fitted to each subset,
then {cmd:estparmtest} may be used to test the hypothesis
that all the regression coefficients are equal.
This hypothesis is thought by some scientists to be an interesting hypothesis to test.
For instance, in the medical sector,
if the subsets are defined by genotypes,
and the regression model measures the effect of an exposure variable on levels of a disease,
then a test of the hypothesis of equality between the regression coefficients in the subsets
is known as a test of gene-environment interaction.


{title:Technical note}

{pstd}
If the model fitted to each subset is the same linear regression model,
fitted using {helpb regress} with the {helpb robust} option,
then the {it:F}-test statistic output by {cmd:estparmtest} should be the same
as the corresponding {it:F}-test statistic output by {helpb test}
if those models are fitted as a single regression model to all subsets
(using {helpb regress} with the {helpb robust} option),
with a separate parameter set for each subset.
If the model fitted to each subset is the same {help glm:generalized linear model},
fitted using {helpb glm} with the {cmd:vce(robust)} option,
then the chi-squared test statistic output by {cmd:estparmtest} should be slightly less
than the corresponding chi-squared statistic output by {helpb test}
if those models are fitted as a single regression model to all subsets
(using {helpb glm} with the {cmd:vce(robust)} option),
with a separate parameter set for each subset.
However, the two chi-squared statistics will be asymptotically equivalent in large samples.
This is because the {help robust:Huber variance formula} used by Stata
uses a scale factor of {hi:N/(N-1)} in generalized linear models
and a scale factor of {hi:N/(N-k)} in linear regression models,
where {hi:N} is the number of observations
and {hi:k} is the number of parameters.


{title:Examples}

{pstd}
The following examples use the {cmd:auto} data, with an added variable {cmd:seqgp4},
which groups the dats using groups of 4 successive observations.
In each group of 4 successive observations,
the first, second, third and fourth observation
are assigned to groups 1, 2, 3 and 4, respectively.
In each example,
the {helpb parmby} module of the {help ssc:SSC} package {helpb parmest} is used
to create an output dataset (or resultsset),
with 1 observation per estimated parameter.
In this resultsset, {cmd:estparmtest} is used to test the hypothesis
that the regression slopes or odds ratios in the 4 groups are equal.

{hline}
Setup
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. gene seqgp4=mod(_n,4)+1}{p_end}
{phang2}{cmd:. lab var seqgp4 "Sequential group (of 4)"}{p_end}
{phang2}{cmd:. tab seqgp4}{p_end}

{hline}
Example with {cmd:regress}
{phang2}{cmd:. preserve}{p_end}
{phang2}{cmd:. parmby "regress mpg weight", by(seqgp4) norestore escal(N) ren(es_1 N)}{p_end}
{phang2}{cmd:. estparmtest estimate stderr dof if parm=="weight", obs(N)}{p_end}
{phang2}{cmd:. ereturn list}{p_end}
{phang2}{cmd:. return list}{p_end}
{phang2}{cmd:. restore}{p_end}

{hline}
Example with {cmd:logit}
{phang2}{cmd:. preserve}{p_end}
{phang2}{cmd:. parmby "logit foreign mpg", by(seqgp4) norestore escal(N) ren(es_1 N)}{p_end}
{phang2}{cmd:. estparmtest estimate stderr if parm=="mpg", obs(N)}{p_end}
{phang2}{cmd:. ereturn list}{p_end}
{phang2}{cmd:. return list}{p_end}
{phang2}{cmd:. restore}{p_end}

{hline}
Example with {cmd:logit} and the {cmd:eform} option
{phang2}{cmd:. preserve}{p_end}
{phang2}{cmd:. parmby "logit foreign mpg, or", by(seqgp4) norestore escal(N) ren(es_1 N) eform}{p_end}
{phang2}{cmd:. estparmtest estimate stderr if parm=="mpg", obs(N) eform}{p_end}
{phang2}{cmd:. ereturn list}{p_end}
{phang2}{cmd:. return list}{p_end}
{phang2}{cmd:. restore}{p_end}

{pstd}
The following example illustrates the use of {cmd:estparmtest} with {helpb statsby}.
Note that the {cmd:basepop()} option of {helpb statsby} is used
to prevent the {helpb matsize} from being exceeded.

{phang2}{cmd:. statsby pvalue=r(p), by(snpoly) clear basepop(snpoly==1): estparmtest estimate stderr if parm=="exposure", obs(N) eform}{p_end}


{title:Saved results}

{pstd}
{cmd:estparm} and {cmd:estparmtest} save the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}total number of observations{p_end}
{synopt:{cmd:e(df_r)}}total degrees of freedom{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:estparm}){p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(dfcombine)}}{cmd:dfcombine()} option{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}){p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector){p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(df_estparm)}}parameter-specific degrees of freedom{p_end}
{p2colreset}{...}

{pstd}
The parameter-specific degrees of freedom vector has the dimensions of the coefficient vector,
and contains the contents of the degrees of freedom variable.

{pstd}
{cmd:estparmtest} also saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(p)}}two-sided p-value{p_end}
{synopt:{cmd:r(F)}}F statistic{p_end}
{synopt:{cmd:r(df)}}test constraints degrees of freedom{p_end}
{synopt:{cmd:r(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:r(dropped_i)}}index of {it:i}th constraint dropped{p_end}
{synopt:{cmd:r(chi2)}}chi-squared{p_end}
{synopt:{cmd:r(ss)}}sum of squares (test){p_end}
{synopt:{cmd:r(rss)}}residual sum of squares{p_end}
{synopt:{cmd:r(drop)}}{cmd:1} if constraints were dropped, {cmd:0} otherwise{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {manlink R estimates}, {manlink R test}, {manlink P ereturn}, {manlink D statsby}
{p_end}

{psee}
{space 2}Help:  {manhelp estimates P}, {manhelp test R}, {manhelp ereturn P}, {manhelp statsby D}{break}
{helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm} if installed
{p_end}
