{smcl}
{hline}
{cmd:help parmest_ci_opts}{right:(Roger Newson)}
{hline}


{title:Confidemce-interval options for {helpb parmest} and {helpb parmby}}


{title:Syntax}

{synoptset 32}
{synopthdr}
{synoptline}
{synopt:{opt ef:orm}}Exponentiate estimates and confidence limits{p_end}
{synopt:{opt d:of(numscalar)}}Scalar degrees of freedom for calculating confidence limits{p_end}
{synopt:{cmdab:le:vel}{cmd:(}{help numlist:{it:numlist}}{cmd:)}}Confidence level(s) for calculating confidence limits{p_end}
{synopt:{opt cln:umber(numbering_rule)}}Numbering rule for naming confidence limit variables{p_end}
{synopt:{cmdab:mcomp:are}{cmd:(}{it:method}{cmd:)}}Multiple-comparison method{p_end}
{synopt:{cmdab:mcomc:i}{cmd:(}{it:method}{cmd:)}}Multiple-comparison method for confidence limits only{p_end}
{synopt:{opt bmat:rix(matrix_expression)}}Matrix from which parameter estimates will be extracted{p_end}
{synopt:{opt vmat:rix(matrix_expression)}}Matrix from which parameter variances will be extracted{p_end}
{synopt:{opt dfmat:rix(matrix_expression)}}Matrix from which parameter degrees of freedom will be extracted{p_end}
{synoptline}

{pstd}
where {it:numscalar} is

{pstd}
# | {help scalar:{it:scalar_name}}

{pstd}
and {it:numbering_rule} is

{pstd}
{cmd:level} | {cmd:rank}

{pstd}
and {it:method} is

{pstd}
{cmdab:noadj:ust} | {cmdab:bonf:erroni} | {cmdab:sid:ak}


{title:Description}

{pstd}
These options allow the user to change the selection of confidence limits and {it:P}-values
in the output dataset (or resultsset) created by {helpb parmest} or {helpb parmby}.


{title:Options}

{p 4 8 2}
{cmd:eform} specifies that the estimates and confidence limits in the output dataset
are to be exponentiated, and the standard errors multiplied by the exponentiated estimates.
This option is usually used if the estimated parameters were calculated on a log scale, as is done by
{helpb logit} and {helpb logistic} with odds ratios, by {helpb glm} and {helpb binreg} with risk ratios,
by {helpb stcox} with hazard ratios, or by {helpb regress} with geometric mean ratios.
Note that, if the user wants exponentiated confidence intervals in the output dataset,
then the {cmd:eform} option must be specified for {helpb parmby} or {helpb parmest}, whether or not
the {cmd:eform} or equivalent option was specified for the {help estcom:estimation command}.

{p 4 8 2}
{cmd:dof(}{it:numscalar}{cmd:)} specifies the scalar degrees of freedom
for {it:t}-distribution-based confidence limits and {it:P}-values.
If {cmd:dof()} is positive, then confidence limits and {it:P}-values for all parameters are calculated using the
{it:t}-distribution with {cmd:dof()} degrees of freedom.
If {cmd:dof()} is zero, then confidence limits are calculated using the standard Normal distribution.
If {cmd:dof()} is absent (or missing or negative),
then confidence limits are calculated from the standard Normal or {it:t}-distribution, as follows.
If the {cmd:dfmatrix()} option specifies a valid degrees of freedom matrix (see below),
then the degrees of freedom are extracted from the specified matrix.
Otherwise, if there is a non-missing {help return:scalar estimation result} {hi:e(df_r)},
then the degrees of freedom for all parameters is set to the value of {hi:e(df_r)}.
Otherwise, the confidence limits and {it:P}-values are calculated using the standard Normal distribution.

{p 4 8 2}
{cmd:level(}{it:numlist}{cmd:)} specifies the confidence levels, in percent, for
the confidence limit variables created in the output dataset.
These levels do not have to be integers, but must be at least 0 and strictly less than 100.
For each level {it:xx}, {helpb parmest} and {helpb parmby} calculate a lower {it:xx} percent confidence
limit variable with a default name of form {hi:min}{it:xx} and an upper {it:xx} percent confidence level
with a default name of form {hi:max}{it:xx}.
The numbering of the confidence limit variable names
can be changed using the {cmd:clnumber} option (see below), and the names of the confidence limits
can be changed using the {cmd:rename} option (see {help parmest_varmod_opts:{it:parmest_varmod_opts}}).
The default is {cmd:level(95)}, or another single number set by {helpb set level}.
Note that the {cmd:level()} option used by {helpb parmby} or {helpb parmest}
is not affected by any {cmd:level()} option specified for the {help estcom:estimation command}.
(See {manhelp estcom U:20 Estimation and postestimation commands}.)

{p 4 8 2}
{cmd:clnumber(}{it:numbering_rule}{cmd:)} specifies the rule used to number the names of the
confidence limit variables created in the output dataset.
The {it:numbering_rule} may be {cmd:level} or {cmd:rank}, and is set in default to {cmd:level}
if the {cmd:clnumber()} option is not specified.
For each confidence level {it:xx} specified by the
{cmd:levels()} option, {helpb parmest} and {helpb parmby} calculate a lower
{it:xx} percent confidence limit with the default name {hi:min}{it:yy}, and an upper {it:xx} percent
confidence limit with the default name {hi:max}{it:yy}, where the number {it:yy} depends on the
confidence level {it:xx} according to a rule specified by the {it:numbering_rule} of the {cmd:clnumber()} option.
If the {it:numbering_rule} is {cmd:rank}, then the number {it:yy} is the rank, in ascending
order, of the confidence level {it:xx} in the set of confidence levels specified by the {cmd:levels()} option.
For instance, if the user specifies {cmd:levels(90 95 99) clnumber(rank)},
then the 90 percent confidence limits are named {hi:min1} and {hi:max1},
the 95 percent confidence limits are named {hi:min2} and {hi:max2},
and the 99 percent confidence limits are named {hi:min3} and {hi:max3}.
If the numbering rule is {cmd:level} (the default), then the number {it:yy} is equal to the confidence level {it:xx}.
For instance, if the user specifies {cmd:levels(90 95 99) clnumber(lewel)},
then the 90 percent confidence limits are named {hi:min90} and {hi:max90},
the 95 percent confidence limits are {hi:min95} and {hi:max95},
and the 99 percent confidence limits are {hi:min99} and {hi:max99}.
If the confidence level {it:xx} contains a decimal point, then the decimal point is replaced with "_"
in the variable names {hi:min}{it:xx} and {hi:max}{it:xx}.
If the confidence level {it:xx} contains "e-" (because of very small e-format confidence levels),
then the "e-" is replaced with "em" in the variable names {hi:min}{it:xx} and {hi:max}{it:xx}.
Therefore, if the user specifies {cmd:level(95 99.99) clnumber(level)}, then the output dataset
contains 95% lower and upper confidence limits in variables
{hi:min95} and {hi:max95}, and 99.99% lower and upper confidence limits in variables {hi:min99_99} and {hi:max99_99}.
The option {cmd:clnumber(rank)} is useful if the confidence levels contain many
numbers after the decimal point, which may be the case if the user specifies Bonferroni-corrected
or Sidak-corrected confidence limits.

{p 4 8 2}
{cmd:mcompare(}{it:method}{cmd:)} specifies a multiple-comparison method
used to adjust the generated confidence limits and {it:P}-values.
This method may be {cmd:noadjust} (the default, indicating no adjustment),
{cmd:bonferroni} (indicating the Bonferroni adjustment),
and {cmd:sidak} (indicating the Sidak adjustment).
The adjustments, if requested, are calculated
for the total number of parameters estimated (in the case of {cmd:parmest}),
or for the number of parameters estimated for the by-group (in the case of {cmd:parmby}).
For this reason,
the {cmd:mcompare()} and {cmd:mcompci()} options are not used very often with {cmd:parmest} and {cmd:parmby},
and are more likely to be used with {helpb parmcip} in a derived resultsset,
containing subsets of parameters from multiple models.

{p 4 8 2}
{cmd:mcomci(}{it:method}{cmd:)} specifies a multiple-comparison method
used to adjust the generated confidence limits only, and not the generated {it:P}-values.
If the user wants to generate adjusted {it:P}-values without adjusting the confidence limits,
or to generate adjusted {it:P}-values using a different method from the one used for adjusting the confidence limits,
then the user is advised to use the {helpb qqvalue} package,
which can be downloaded from {help ssc:SSC}.
Note that the {cmd:mcompci()} and {cmd:mcompare()} options do not affect the names
of the generated variables containing the confidence limits,
only their values.

{p 4 8 2}
{cmd:bmatrix(}{it:matrix_expression}{cmd:)} specifies the matrix from which the parameter estimates will be extracted.
If not set by the user, then it is set to {cmd:e(b)} for most {help estcom:estimation commands},
or to {cmd:e(b_mi)} if the most recent {help estcom:estimation command} is {helpb mi_estimate:mi estimate},
or to {cmd:e(est)} if the most recent {help estcom:estimation command}
is one of the superseded Stata 8 survey commands {helpb svymean}, {helpb svyratio} or {helpb svytotal},
and the command was specified with the {cmd:available} option instead of the {cmd:complete} option.
The matrix specified must have one row, and one column per estimated parameter.
The {help matrix rownames:column names and equations} of the matrix are used as the source
for the parameter names and equations in the output dataset.

{p 4 8 2}
{cmd:vmatrix(}{it:matrix_expression}{cmd:)} specifies the matrix from which the parameter variances will be extracted.
If not set by the user, then it is set to {cmd:e(V)} for most {help estcom:estimation commands},
or to {cmd:e(V_mi)} if the most recent {help estcom:estimation command} is {helpb mi_estimate:mi estimate},
or to {cmd:e(V_db)} if the most recent {help estcom:estimation command}
is one of the superseded Stata 8 survey commands {helpb svymean}, {helpb svyratio} or {helpb svytotal},
and the command was specified with the {cmd:available} option instead of the {cmd:complete} option.
The matrix specified must have as many columns as the matrix specified by {cmd:bmatrix()},
and must either have one row (from which the variances will then be extracted),
or have as many rows as columns (in which case the variances will be extracted from the diagonal).

{p 4 8 2}
{cmd:dfmatrix(}{it:matrix_expression}{cmd:)} specifies the matrix
from which the parameter degrees of freedom will be extracted,
if no {cmd:dof()} option has been specified by the user.
If neither {cmd:dof()} nor {cmd:dfmatrix()} has been specified by the user,
then, for most {help estcom:estimation commands},
the degrees of freedom for all parameters are extracted from the scalar {cmd:e(df_r)} if this result is not missing,
and the standard Normal distribution is used otherwise.
However, {cmd:dfmatrix()} is set in default to {cmd:e(df_mi)} if the most recent {help estcom:estimation command} is {helpb mi_estimate:mi estimate},
or to {cmd:e(_N_psu)-e(_N_str)}
if the most recent {help estcom:estimation command} is one of the superseded Stata 8 survey commands {helpb svymean}, {helpb svyratio} or {helpb svytotal},
and the command was specified with the {cmd:available} option instead of the {cmd:complete} option.
The matrix specified must have one row,
and must have either one column (from which degrees of freedom will be extracted for all parameters),
or as many columns as the matrix specified by {cmd:bmatrix()}.
Note that {cmd:dfmatrix()} is ignored if the user specifies {cmd:dof()}.


{title:Selection of distribution and degrees of freedom}

{pstd}
{helpb parmest} and {helpb parmby} calculate confidence intervals and {it:P}-values
from the parameter estimates and standard errors,
using either the standard Normal distribution or the {it:t}-distribution for all parameters.
If the {it:t}-distribution is used,
then the degrees of freedom may or may not be the same for all parameters.
The distribution, and degrees of freedom, are selected as follows:

{phang}
1. By first preference, the {cmd:dof()} option is used, if specified by the user.

{phang}
2. By second preference, the {cmd:dfmatrix()} option is used, if specified either by the user or by default.

{phang}
3. By third preference, the degrees of freedom are specified by  the {help ereturn:scalar estimation result} {cmd:e(df_r)},
if that result is present.

{phang}
4. If none of the above possibilities are available, then the standard Normal distribution is used.

{pstd}
Note that the user can force the use of the standard Normal distribution by specifying {cmd:dof(0)},
or force the use of {cmd:e(df_r)} (if present) by specifying {cmd:dof(e(df_r))}.

{pstd}
If the {cmd:t}-distribution is used,
then the degrees of freedom for each parameter are stored in the {help parmest_resultssets:output dataset}
in the variable {cmd:dof},
and the {it:t}-test statistics are stored in the variable {cmd:t}.
If the standard Normal distribution is used,
then the {help parmest_resultssets:output variable} {cmd:dof} is not created,
and the {it:z}-test statistics are stored in the {help parmest_resultssets:output variable} {cmd:z}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {findalias frestimate}
{p_end}

{psee}
{space 2}Help:  {manhelp estcom U:20 Estimation and postestimation commands}{break}
{helpb parmest}, {helpb parmby},
{help parmest_outdest_opts:{it:parmest_outdest_opts}}, {help parmest_varadd_opts:{it:parmest_varadd_opts}},
{help parmest_varmod_opts:{it:parmest_varmod_opts}}, {help parmby_only_opts:{it:parmby_only_opts}},
{help parmest_resultssets:{it:parmest_resultssets}}{break}
{helpb qqvalue} if installed
{p_end}
