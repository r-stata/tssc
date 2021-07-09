{smcl}
{hline}
help for {cmd:multproc} and {cmd:smileplot} {right:(Roger Newson)}
{hline}


{title:Multiple test procedures and smile plots}

{p 8 15} {cmd:multproc} {ifin} [ ,
 {break}
 {cmdab:pu:ncor}{cmd:(} {c -(} {it:#} | {it:scalarname} | {it:varname} {c )-} {cmd:)}
 {break}
 {cmdab:pc:or}{cmd:(} {c -(} {it:#} | {it:scalarname} | {it:varname} {c )-} {cmd:)}
 {break}
 {cmdab:me:thod}{cmd:(}{it:method_name}{cmd:)} {cmdab:pv:alue}{cmd:(}{it:varname}{cmd:)}
 {cmdab:ra:nk}{cmd:(}{it:newvarname}{cmd:)} {cmdab:gpu:ncor}{cmd:(}{it:newvarname}{cmd:)}
 {cmdab:cr:itical}{cmd:(}{it:newvarname}{cmd:)} {cmdab:gpc:or}{cmd:(}{it:newvarname}{cmd:)}
 {cmdab:nh:cred}{cmd:(}{it:newvarname}{cmd:)} {cmdab:rej:ect}{cmd:(}{it:newvarname}{cmd:)}
 {cmd:float} {cmd:fast} ]

{p 8 15}{cmd:smileplot} {ifin} [ ,
 {break}
 {cmdab:es:timate}{cmd:(}{it:varname}{cmd:)}
 {cmdab:logb:ase}{cmd:(}{it:#}{cmd:)} {cmd:maxylabs(}{it:#}{cmd:)}
 {cmd:xlog} {cmdab:nl:ine}{cmd:(}{it:#}{cmd:)}
 {cmdab:pts:ymbol}{cmd:(}{it:symbol}{cmd:)} {cmdab:ptl:abel}{cmd:(}{it:varname}{cmd:)}
 {cmd:scatteropts(}{it:scatter_options}{cmd:)}
 {cmd:refopts(}{it:added_line_options_1}{cmd:)} {cmd:nrefopts(}{it:added_line_options_2}{cmd:)}
 {cmd:urefopts(}{it:added_line_options_3}{cmd:)} {cmd:crefopts(}{it:added_line_options_4}{cmd:)}
 {cmd:addplot(}{it:plot}{cmd:)} {cmd:plot(}{it:plot}{cmd:)}
 {cmd:by(}{it:varlist}{cmd:)}
 {it:multproc_options} {it:twoway_options} ]

{pstd}
where {it:multproc_options} is a list of options recognised by {cmd:multproc}, and
{it:twoway_options} is a list of options recognised by {helpb twoway}
(see help for {help twoway_options:{it:twoway_options}}).

{pstd}
{cmd:by} {it:varlist}{cmd::} can be used with {cmd:multproc} and {cmd:smileplot}.
(See help for {helpb by}.) If {cmd:by} {it:varlist}{cmd::} is used, then the log output,
and all generated variables, are calculated using the specified multiple test procedure
within each by-group defined by the variables in the {it:varlist}.


{title:Description}

{pstd}
{cmd:multproc} takes, as input, a dataset with one value for each of a set of multiple statistical
tests of multiple null hypotheses, including a variable containing {it:P}-values for these tests, and an
uncorrected overall critical {it:P}-value specified by the user, and carries out a multiple test procedure.
A multiple test procedure calculates a corrected overall critical {it:P}-value,
which has the feature that an individual null hypothesis is considered to be acceptable
if and only if its corresponding {it:P}-value is greater than the corrected overall critical {it:P}-value.
{cmd:smileplot} takes, as input, a dataset with one observation for each of a set of estimated parameters,
and data on their estimates and {it:P}-values.
{cmd:smileplot} calls {cmd:multproc} to carry out a multiple
test procedure, and then creates a smile plot, with data points corresponding
to estimated parameters, the corresponding {it:P}-values (on a reverse log scale) on the {it:Y}-axis, and
another variable (usually the corresponding parameter estimates) on the {it:X}-axis.
There are {it:Y}-axis reference lines corresponding to the uncorrected and corrected overall critical {it:P}-values.
The {it:Y}-axis reference line corresponding to the corrected overall critical {it:P}-value is known as the parapet line.
Data points on or above the parapet line correspond to rejected null hypotheses.
There may be a reference line on the {it:X}-axis corresponding to the value of the parameter under a
null hypothesis (defaulting to 1 if the {it:X}-axis is logged, 0 otherwise).
The user can therefore see, at a glance,
both the statistical significance and the practical significance of each parameter estimate,
and can also see the parapet line as an "upper confidence bound" on the {it:Y}-axis for how many of the
corresponding null hypotheses are true.
{cmd:multproc} and {cmd:smileplot} are usually used on datasets
with one observation per parameter estimate and data on estimates and their {it:P}-values.
Such datasets may be created (directly or indirectly) by {helpb postfile}, {helpb statsby}, {helpb parmby} or {helpb parmest}.

{pstd}
{cmd:smileplot} changed markedly in style in the transition from Stata Version 7 to Stata Version 8.
Users who prefer to use the Stata 7 version can still do so by using {helpb smileplot7}.


{title:Options for {cmd:multproc} and {cmd:smileplot}}

{p 4 8 2}{cmd:puncor(} {c -(} {it:#} | {it:scalarname} | {it:varname} {c )-} {cmd:)} specifies the uncorrected overall
critical {it:P}-value for statistical significance.
This option may be specified either as a number, or as a scalar, or as a variable
(in which case the variable is expected to contain only one non-missing value in the sample or by-group).
If absent, this option is set to 1-{hi:$S_level}/100, where {hi:$S_level}
is the value of the currently set default confidence level.

{p 4 8 2}{cmd:pcor(} {c -(} {it:#} | {it:scalarname} | {it:varname} {c )-} {cmd:)} specifies the corrected overall
critical {it:P}-value for statistical significance.
This option may be specified either as a number, or as a scalar, or as a variable
(in which case the variable is expected to contain only one non-missing value in the sample or by-group).
 If absent, this option is set by the method specified in the {cmd:method} option
(see below).

{p 4 8 2}{cmd:method(}{it:method_name}{cmd:)} specifies the multiple test procedure method to be used for deriving
the corrected {it:P}-value threshold from the uncorrected {it:P}-value threshold.
This option is ignored, and set to {cmd:userspecified}, if the {cmd:pcor} option is specified and in the range 0 <= {cmd:pcor} <= 1.
Otherwise, if {cmd:method} is absent, then it is set to {cmd:bonferroni}.

{p 4 8 2}{cmd:pvalue(}{it:varname}{cmd:)} is the name of the variable containing the {it:P}-values.
If this option is absent, then {cmd:multproc} looks for a variable named {hi:p} (as created by {helpb parmby} or {helpb parmest}).
{cmd:multproc} carries out a multiple test procedure on all observations selected by
the {helpb if} and/or {helpb in} qualifiers which also have non-missing values for the variable containing
the {it:P}-values.

{p 4 8 2}{cmd:rank(}{it:newvarname}{cmd:)} is the name of a new variable to be generated, containing, in each observation,
the rank of the corresponding {it:P}-value, from the lowest to the highest.
Tied {it:P}-values are ranked according to their position in the input dataset.
If {cmd:by} {it:varlist}{cmd::} is specified with {cmd:multproc},
then the ranks are defined within the by-group.

{p 4 8 2}{cmd:gpuncor(}{it:newvarname}{cmd:)} is the name of a new variable to be generated, containing, in each observation,
the uncorrected overall critical {it:P}-value, as specified by the {cmd:puncor} option, or by the standard default if the
{cmd:puncor} option is not specified.
This new variable will have the same value for all observations in the sample of
observations used by {cmd:multproc} or {cmd:smileplot}.

{p 4 8 2}{cmd:critical(}{it:newvarname}{cmd:)} is the name of a new variable to be generated, containing, in each observation,
an individual critical {it:P}-value corresponding to the original {it:P}-value in the variable specified by {cmd:pvalue}.
The values of the individual critical {it:P}-values are defined by a non-decreasing function (specified by the {cmd:method}
option) of the ranks of the corresponding original {it:P}-values (generated by the {cmd:rank} option).
The corrected overall critical {it:P}-value is selected from the individual critical {it:P}-values
in a way specified by the {cmd:method} option,
depending on whether the method specified is a one-step method, a step-down method, or a step-up method.

{p 4 8 2}{cmd:gpcor(}{it:newvarname}{cmd:)} is the name of a new variable to be generated, containing, in each observation,
the corrected overall critical {it:P}-value, as specified by the {cmd:pcor} option, or by the {cmd:method} option
if the {cmd:pcor} option is not specified.
If {cmd:by} {it:varlist}{cmd::} is specified with {cmd:multproc},
then the value of this new variable will be the same in all observations within each by-group, but may be different for
observations in different by-groups, if a step-up or step-down procedure is specified by the {cmd:method} option.

{p 4 8 2}{cmd:nhcred(}{it:newvarname}{cmd:)} is the name of a new variable to be generated, containing, for each observation,
an indicator of the credibility of the corresponding null hypothesis under the method specified by the {cmd:method} option.
This indicator is 1 if the null hypothesis is credible, and 0 otherwise.
A null hypothesis is said to be credible if its {it:P}-value is greater than the corrected overall critical {it:P}-value.
The set of observations with a value of 1 corresponds to a set of credible null hypotheses.
The exact interpretation of the set of credible null hypotheses depends on whether
the method specified controls the family-wise error rate (FWER) or the false discovery rate (FDR).

{p 4 8 2}{cmd:reject(}{it:newvarname}{cmd:)} is the name of a new variable to be generated, containing, for each observation,
an indicator of the rejection of the corresponding null hypothesis under the method specified by the {cmd:method} option.
This indicator is 1 if the null hypothesis is rejected, and 0 otherwise.
The new variable generated by the {cmd:reject} option is therefore the negation
of the new variable generated by the {cmd:nhcred} option.

{p 4 8 2}{cmd:float} specifies that the individual critical {it:P}-value variable specified by {cmd:critical()} (if requested)
will be created as a {cmd:float} variable.
If {cmd:float} is absent, then the {cmd:critical()} variable is created as a {cmd:double} variable.
Whether or not {cmd:float} is specified, all generated variables are stored to the lowest
precision possible without loss of information.

{p 4 8 2}{cmd:fast} is an option for programmers.
It specifies that {cmd:multproc} and {cmd:smileplot} will not take any action
so that it can restore the original data if the user presses {cmd:Break}.


{title:Options available for {cmd:smileplot} only}

{p 4 8 2}{cmd:estimate(}{it:varname}{cmd:)} is the name of the variable to be plotted on the {it:X}-axis,
usually containing the parameter estimates corresponding to the {it:P}-values specified by the {cmd:pvalue} option.
If this option is absent, then {cmd:smileplot} looks for a variable named {hi:estimate} (as created by
{helpb parmby} or {helpb parmest}).
{cmd:smileplot} carries out a multiple test procedure by calling
{cmd:multproc} for observations with non-missing values for the variables specified by the {cmd:estimate}
and {cmd:pvalue} options, using the {helpb if} and/or {helpb in} qualifiers if these are supplied by the user.
Note that the variable specified by {cmd:estimate} may contain values that are not parameter estimates.
For instance, the observations may correspond to genes in a genome scan, the {it:P}-values may be derived
from tests for associations of those genes with a disease, and the {it:X}-axis
variable specified by the {cmd:estimate} option may contain the positions of those genes on a chromosome map.

{p 4 8 2}{cmd:logbase(}{it:#}{cmd:)} specifies a log base used to define the {it:Y}-axis labels.
This log base is a factor by which each {it:Y}-axis label is divided to arrive at the next
{it:Y}-axis label, where the {it:Y}-axis labels are ordered from the highest {it:P}-value to the lowest {it:P}-value.
If absent, this option is set to 10, so the Y-labels are set to non-positive powers of 10.
If this rule defines too many {it:Y}-axis labels, then the {it:Y}-axis labels are set to be every {it:k}th
member of the logarithmic series, where {it:k} is the minimum positive integer such that
the number of {it:Y}-axis labels defined in this way is not too large.

{p 4 8 2}{cmd:maxylabs(}{it:#}{cmd:)} specifies the maximum number of {it:Y}-axis labels allowed.
If this option is not specified, then it is set to 25, so as to be similar to the Stata 7 version of
{cmd:smileplot}, which the user can still use by using {helpb smileplot7}.
{cmd:maxylabs} is used with {cmd:logbase} to decide the default sequence of labels on the left {it:Y}-axis.
These are chosen to be spaced exponentially, separated by a factor equal to the smallest possible
power of {cmd:logbase} such that the number of labels is no more than {cmd:maxylabs}.
This is usually a sensible default, but it can be overridden by the {it:{help twoway_options}}.

{p 4 8 2}{cmd:xlog} specifies that the {it:X}-axis must have a log scale.
It is typically used if the parameters estimated are odds ratios or geometric mean ratios.
It affects the default value of the {cmd:nline} option (see below).
It may be overridden by specifications in an {help axis_scale_options:xscale} option in the {it:twoway_options}
(see help for {it:{help axis_scale_options}} or {it:{help twoway_options}}).

{p 4 8 2}{cmd:nline(}{it:#}{cmd:)} specifies the position, on the {it:X}-axis, of the reference line
indicating the value of the estimated parameters under the null hypothesis.
If {cmd:nline} is unspecified, then it is set to 1 if {cmd:xlog} is specified and to 0 otherwise.
This option allows the user to plot odds ratios and geometric mean ratios on a linear scale, instead of on the more usual log scale.
If {cmd:nline} is set to a missing value by specifying {cmd:nline(.)}, then the null reference line is suppressed.
This is useful for creating "smile plots" for which the {it:X}-axis variable specified by the {cmd:estimate}
option contains values other than parameter estimates, such as positions of genes on a chromosome map.

{p 4 8 2}{cmd:ptsymbol(}{it:symbol}{cmd:)} specifies a graph marker symbol for the data points of the smile plot.
This may be any one of the marker symbols named in the help for {it:{help symbolstyle}}.
If absent, it is set to {hi:Th} (hollow triangles).
This option may be overridden by the option {cmd:scatteropts} (see below).

{p 4 8 2}{cmd:ptlabel(}{it:varname}{cmd:)} specifies a variable to be used to label the data points
in the manner specified by the {cmd:mlabel} graph option (see help for {it:{help marker_label_options}}).
If this option is absent, then there are no data point labels, only unlabelled data points.
This option may be overridden by the option {cmd:scatteropts} (see below).

{p 4 8 2}{cmd:scatteropts(}{it:scatter_options}{cmd:)} specifies a sequence of options for the
{help scatter:twoway scatter} plot type.
These options may include {cmd:msymbol} and {cmd:mlabel} options, which override the {cmd:ptsymbol} and {cmd:ptlabel} options,
respectively, and other options specifying non-default attributes for the symbols and/or labels, such as size and color.
(See help for {helpb scatter}).
The user may specify any of these options except for {cmd:xaxis} or {cmd:yaxis}, because
{cmd:smileplot} automatically sets the first {it:X}-axis to be the $X$-axis of the smile plot (specified by the {cmd:estimate}
option) and the first and second {it:Y}-axes to be the left and right {it:Y}-axes used by the smile plot
(corresponding to the {cmd:pvalue} option).
The second {it:Y}-axis is used to display the values of
the uncorrected and corrected overall critical {it:P}-values.

{p 4 8 2}{cmd:refopts(}{it:added_line_options_1}{cmd:)} specifies a list of {help added_line_options:added line suboptions},
as allowed for the {cmd:xline} or {cmd:yline} options.
These options control the style of the {it:X}-axis and {it:Y}-axis
reference lines of the smile plot, corresponding to the null hypothesis, the uncorrected overall critical {it:P}-value,
and the corrected overall critical {it:P}-value, respectively.
The options specified by {cmd:refopts}
apply to all 3 of these reference lines, except if overridden by the {cmd:nrefopts}, {cmd:urefopts}
and/or {cmd:crefopts} options (see below).
If {cmd:refopts} is absent, then it is set to a default, namely {cmd:refopts(lstyle(xyline))}.
This causes the lines to have a default style depending on the scheme.
(See help for {helpb schemes} and {helpb linestyle}.)

{p 4 8 2}{cmd:nrefopts(}{it:added_line_options_2}{cmd:)} specifies a list of {help added_line_options:added line suboptions},
as allowed for the {cmd:xline} or {cmd:yline} options.
These options control the style of the {it:X}-axis
reference line of the smile plot, corresponding to the null hypothesis.
The options specified by {cmd:nrefopts} override those specified by {cmd:refopts},
allowing the null hypothesis reference line to have a different style from the other reference lines.

{p 4 8 2}{cmd:urefopts(}{it:added_line_options_3}{cmd:)} specifies a list of {help added_line_options:added line suboptions},
as allowed for the {cmd:xline} or {cmd:yline} options.
These options control the style of the {it:Y}-axis
reference line of the smile plot indicating the uncorrected overall critical {it:P}-value.
The options specified by {cmd:urefopts} override those specified by {cmd:refopts},
allowing the uncorrected {it:P}-value reference line to have a different style from the other reference lines.

{p 4 8 2}{cmd:crefopts(}{it:added_line_options_4}{cmd:)} specifies a list of {help added_line_options:added line suboptions},
as allowed for the {cmd:xline} or {cmd:yline} options.
These options control the style of the {it:Y}-axis reference line of the smile plot indicating the corrected overall critical {it:P}-value.
The options specified by {cmd:crefopts} override those specified by {cmd:refopts},
allowing the uncorrected {it:P}-value reference line to have a different style from the other reference lines.

{p 4 8 2}{cmd:addplot(}{it:plot}{cmd:)} provides a way to add other plots to the generated graph.
See help for {it:{help addplot_option}}.

{p 4 8 2}
{cmd:plot(}{it:plot}{cmd:)} is an obsolete alternative name for the {cmd:addplot()} option,
used by earlier versions of {cmd:smileplot}.
It is provided so that old do-files will still run.

{p 4 8 2}{cmd:by(}{it:varlist}{cmd:)} is a {help twoway_options:graph twoway option}, and works as for {help twoway:graph twoway},
creating one subplot for each by-group, arranged in an array as specified by the user.
(See help for the {help by_option:by-option}.)
The corrected overall critical {it:P}-value, indicated by a line at the same level on all the subplots,
is calculated from all the {it:P}-values from all the
by-groups pooled together, not for the subset of {it:P}-values in each by-group individually.
(This is in contrast to the use of {cmd:by} {it:varlist}{cmd::}, which causes corrected individual
and overall critical {it:P}-values to be calculated only from the subset of {it:P}-values in each by-group.)


{title:Remarks}

{pstd}
Multiple test procedures and smile plots are reviewed in Newson {it:et al.} (2003).
An alternative method, for some multiple-test procedures, is the method of frequentist {it:q}-values,
implemented using the {help ssc:SSC} package {helpb qqvalue} and described in Newson (2010).

{pstd}
The smile plot is so named because, if the standard errors
of the parameters are similar, then the data points fall along a curve shaped like a smile.
It summarises a set of multiple parameter estimates graphically, in the way that a Cochrane forest plot summarises a meta-analysis.
The {it:Y}-axis reference line corresponding to the corrected overall critical {it:P}-value is known as the parapet line.
Data points on or above the parapet line correspond to
parameters for which we can reject the null hypotheses under the specified multiple test procedure.
Data points below the parapet line correspond to parameters for which the null hypotheses
are credible (acceptable).

{pstd}
The methods specified by the {cmd:method} option are multiple test procedures for
defining an upper confidence bound for the set of null hypotheses that are true, given
multiple parameter estimates with multiple {it:P}-values.
More formally, each method defines a set of credible (or acceptable) null hypotheses and a set of incredible (rejected) null hypotheses,
whose exact interpretation depends on the method.
The uncorrected overall {it:P}-value may either be treated as an upper bound for the family-wise
error rate (FWER), or be treated as an upper bound for the false discovery rate (FDR).

{pstd}
The FWER is the probability that at least one true null hypothesis is rejected.
If a method controls the FWER, then the power set of the set of credible null hypotheses
is a power-set-valued confidence region for a set-valued parameter, namely the set of null hypotheses which are true.
We can therefore say, with a confidence level of
100*(1-{cmd:puncor}) percent, that the set of null hypotheses that are true is some subset
(possibly empty) of the set of credible null hypotheses.
In other words, we are 100*(1-{cmd:puncor}) percent confident that all the rejected null hypotheses are false.
FWER-controlling procedures are reviewed in Wright (1992).

{pstd}
The FDR is defined as follows.
Let {it:V} denote the number of true null hypotheses rejected, and let
{it:R} denote the total number of null hypotheses rejected.
Then the FDR is equal to the expectation
of {it:Q}, where {it:Q} is defined to be equal to {it:V/R} if {it:R>0}, and equal to zero if {it:R=0}.
The probability that {it:Q=1} can be no more than the FDR.
Therefore, if the method controls the FDR, then we can say, with 100*(1-{cmd:puncor}) percent confidence,
that the set of null hypotheses that are true is a subset of null hypotheses (possibly empty)
which does not contain the rejected set as a non-empty subset.
In other words, we are 100*(1-{cmd:puncor}) percent confident that at least some of the rejected null hypotheses are false.
If the number of null hypotheses tested is very large indeed, then,
arguably, we may be 100 percent confident that 100*(1-{cmd:puncor}) percent of the rejected null
hypotheses are false.

{pstd}
The methods may also be classified into one-step, step-down and step-up procedures.
All three classes of methods work by defining a list of {it:m} individual critical {it:P}-values
{it:C_1,...,C_m}, one for each of the {it:m} individual input {it:P}-values {it:P_1,...,P_m},
ranked from the lowest to the highest.
These individual critical {it:P}-values can be saved as output
using the {cmd:critical} option, and are defined as a non-decreasing function of the ranks of the
original {it:P}-values, which can be saved as output using the {cmd:rank} option.
An overall corrected critical {it:P}-value {cmd:pcor} is selected from the individual critical {it:P}-values.
A null hypothesis is acceptable if and only if its {it:P}-value is greater than the overall corrected critical {it:P}-value.
For a one-step procedure, the {it:C_i} are all equal to the overall corrected critical {it:P}-value {cmd:pcor},
which is defined as a function of the uncorrected critical {it:P}-value {cmd:puncor}.
For a step-down procedure, {cmd:pcor} is equal to the lowest {it:C_i} such that {it:P_i > Ci}, if such a {it:C_i} exists,
and equal to {it:C_m} otherwise.
For a step-up procedure, {cmd:pcor} is equal to the highest {it:C_i} such that {it:P_i <= C_i}, if such a {it:C_i} exists,
and equal to {it:C_1} otherwise.

{pstd}
The different methods use different assumptions.
Some assume that the different {it:P}-values are statistically
independent, others allow the different {it:P}-values to be non-negatively correlated, and others allow
the different {it:P}-values to be arbitrarily correlated.
The more recently developed methods are documented
in their original source papers.
The available methods are as follows:


{cmd:Method}          {cmd:Step type}   {cmd:FWER/FDR}    {cmd:Definition or source}
userspecified   One-step    Either      {cmd:pcor} option
bonferroni      One-step    FWER        {cmd:pcor=puncor/m}
sidak           One-step    FWER        {cmd:pcor=1-(1-puncor)^(1/m)}
                                        (or Sidak, 1967)
holm            Step-down   FWER        Holm, 1979
holland         Step-down   FWER        Holland and Copenhaver, 1987
liu1            Step-down   FDR         Benjamini and Liu, 1999a
liu2            Step-down   FDR         Benjamini and Liu, 1999b
hochberg        Step-up     FWER        Hochberg, 1988
rom             Step-up     FWER        Rom, 1990
simes           Step-up     FDR         Benjamini and Hochberg, 1995 (or
                                        Benjamini and Yekutieli, 2001
                                        (first method))
yekutieli       Step-up     FDR         Benjamini and Yekutieli, 2001
                                        (second method)
krieger         Step-up     FDR         Benjamini, Krieger and Yekutieli, 2001

{pstd}
Note that, in the case of the {cmd:holland} method, the procedure used is the simplified
(and less powerful) version of the procedure of Holland and Copenhaver (1987), which takes
no account of logical dependencies between the null hypotheses, although it takes advantage of non-negative
dependencies between the {it:P}-values.
The {cmd:simes} method is so named because it was proposed in Simes (1986),
although its justification in terms of the FDR was presented in the references indicated above.


{title:Technical note}

{pstd}
If the user specifies {cmd:method(sidak)},
then {cmd:multproc} and {cmd:smileplot) use the formula for {cmd:method(bonferroni)}
to calculate the corrected critical {it:P}-values
when the Sidak formula gives a corrected critical {it:P}-value of 0.
Similarly, if the user specifies {cmd:method(holland)},
then {cmd:multproc} and {cmd:smileplot) use the formula for {cmd:method(holm)}
to calculate the corrected critical {it:P}-values
when the Holland-Copenhaver formula gives a corrected critical {it:P}-value of 0.
This practice works because the Sidak correction converges in ratio to the Bonferroni correction
in the limit as the uncorrected {it:P}-value tends to zero.
This approximation makes {cmd:multproc} and {cmd:smileplot} conservative
when the uncorrected {it:P}-value is not very small and the number of comparisons is very large.
However, it is less conservative than setting the corrected critical {it:P}-value to 0.
This technical issue might be a reason for using the {help ssc:SSC} package {helpb qqvalue} (Newson, 2010),
instead of {cmd:multproc} and {cmd:smileplot).


{title:Examples}

{pstd}
If we type the following example, which uses the {hi:auto} data,
then a smile plot will be produced with 1 observation per parameter of the fitted model.
The corrected {it:P}-value defines an upper confidence bound
for how many of these parameters are 0 in the population from which these cars were sampled.

{p 16 20}{inp:. sysuse auto,clear}{p_end}
{p 16 20}{inp:. parmby "xi:regress mpg i.rep78 i.foreign",label norestore}{p_end}
{p 16 20}{inp:. smileplot if parm!="_cons",me(holm) ptl(label)}{p_end}

{pstd}
If we type the following example, which uses the {hi:auto} data,
then a pair of smile plots will be created,
one for US-made cars and one for non-US cars, with one data point for each parameter
of the model (other than the intercept).
The corrected {it:P}-value is corrected for the total number of parameters for both car types (US and non-US).
The pair of smile plots is created in two ways, first with the default options,
then with a large number of non-default options specified by the {cmd:scatteropts} and {cmd:refopts} options
and the {it:{help twoway_options}}.

{p 16 20}{inp:. sysuse auto,clear}{p_end}
{p 16 20}{inp:. parmby "xi:regress mpg weight i.rep78",label norestore by(foreign)}{p_end}
{p 16 20}{inp:. smileplot if parm!="_cons",ptl(parm) by(foreign)}{p_end}
{p 16 20}{inp:. smileplot if parm!="_cons",ptl(parm) scatteropts(mlabsize(medlarge)) refopts(lpattern(shortdash)) by(foreign) subtitle(,bfcolor(white)) ylabel(,axis(1) labsize(medlarge)) ylabel(,axis(2) labsize(medlarge))}{p_end}

{pstd}
The following advanced example demonstrates the use of {cmd:by} {it:varlist}{cmd::}
together with the {cmd:by} option of {cmd:smileplot}.
The example assumes that there is a dataset in memory, with 1 observation per parameter estimate.
The dataset contains variables {hi:or} and {hi:siglev},
containing estimated odds ratios and {it:P}-values respectively, and also identifier variables
{hi:outcome}, {hi:exposure}, {hi:subset} and {hi:adjusted}.
The program {cmd:multproc} is used to carry out the Simes method on each subset defined by the variable {hi:adjusted},
storing the uncorrected and corrected overall critical {it:P}-values in new variables
{hi:uncp} and {hi:corp}, and a hypothesis rejection indicator in a new variable {hi:signif}.
We then use {cmd:smileplot} to create, for each combination of values of {hi:adjusted} and {hi:outcome},
an array of smile plots for each value of {hi:subset}, with data points labelled by the value of {hi:exposure}.
Finally, the rejected null hypotheses are listed.

{p 16 20}{inp:. sort adjusted outcome subset exposure}{p_end}
{p 16 20}{inp:. by adjusted:multproc,pval(siglev) meth(simes) gpunc(uncp) gpcor(corp) rej(signif)}{p_end}
{p 16 20}{inp:. by adjusted outcome:smileplot,est(or) pval(siglev) punc(uncp) pcor(corp) by(subset) ptl(exposure) xlog t1(" ")}{p_end}
{p 16 20}{inp:. by adjusted outcome:list if signif,nodisp}{p_end}


{title:Saved results}

{pstd}
{cmd:multproc} and {cmd:smileplot} save the following results in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(puncor)}}uncorrected critical {it:P}-value{p_end}
{synopt:{cmd:r(pcor)}}corrected critical {it:P}-value{p_end}
{synopt:{cmd:r(npvalues)}}number of {it:P}-values{p_end}
{synopt:{cmd:r(nreject)}}number of {it:P}-values rejected{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(method)}}the {cmd:method()} option{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References} 

{phang}
Benjamini, Y. and Y. Hochberg.  1995.
Controlling the false discovery rate: a practical and powerful
approach to multiple testing. {it:Journal of the Royal Statistical Society B} 57: 289-300.

{phang}
Benjamini Y., A. Krieger, and D. Yekutieli.  2001.
Two staged linear step-up FDR controlling procedure.
Pre-publication draft downloadable from
{browse "http://www.math.tau.ac.il/~ybenja/":Yoav Benjamini's website at http://www.math.tau.ac.il/~ybenja/}.

{phang}
Benjamini, Y. and W. Liu.  1999a.
A step-down multiple hypotheses testing procedure that controls
the false discovery rate under independence.
{it:Journal of Statistical Planning and Inference} 82: 163-170.
Pre-publication draft downloadable from
{browse "http://www.math.tau.ac.il/~ybenja/":Yoav Benjamini's website at http://www.math.tau.ac.il/~ybenja/}.

{phang}
Benjamini, Y. and W. Liu.  1999b.
A distribution-free multiple-test procedure that controls the false discovery rate.
Report, Dept. of Statistics and OR, Tel Aviv University, RP-SOR-99-3.
Pre-publication draft downloadable from
{browse "http://www.math.tau.ac.il/~ybenja/":Yoav Benjamini's website at http://www.math.tau.ac.il/~ybenja/}.

{phang}
Benjamini, Y. and D. Yekutieli.  2001.
The control of the false discovery rate in multiple testing under dependency.
{it:Annals of Statistics} 29: 1165-1188.
Pre-publication draft downloadable from
{browse "http://www.math.tau.ac.il/~ybenja/":Yoav Benjamini's website at http://www.math.tau.ac.il/~ybenja/}.

{phang}
Hochberg, Y.  1988.
A sharper Bonferroni procedure for multiple tests of significance.
{it:Biometrika} 75: 800-802.

{phang}
Holland, B. S. and Copenhaver, M. D.  1987.
An improved sequentially rejective Bonferroni test procedure.
{it:Biometrics} 43: 417-423.

{phang}
Holm, S.  1979.
A simple sequentially rejective multiple test procedure.
{it:Scandinavian Journal of Statistics} 6: 65-70.

{phang}
Newson, R. B.  2010.
Frequentist {it:q}-values for multiple-test procedures.
{it:The Stata Journal} 10(4): 568-584.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0209":{it:The Stata Journal} website}.

{phang}
Newson, R. and the ALSPAC Study Team.  2003.
Multiple-test procedures and smile plots.
{it:The Stata Journal} 3(2): 109-132.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0035":{it:The Stata Journal} website}.

{phang}
Rom, D. M.  1990.
A sequentially rejective test procedure based on a modified Bonferroni inequality.
{it:Biometrika} 77: 663-665.

{phang}
Sidak, Z.  1967.
Rectangular confidence regions for the means of multivariate normal distributions.
{it:Journal of the American Statistical Association} 62: 626-633.

{phang}
Simes, R. J.  1986.
An improved Bonferroni procedure for multiple tests of significance.
{it:Biometrika} 73: 751-754.

{phang}
Wright, S. P.  1992.
Adjusted {it:P}-values for simultaneous inference.
{it:Biometrics} 48: 1005-1013.


{title:Also see}

{p 0 10}
{bind: }Manual:   {hi:[R] by}, {hi:[R] statsby}, {hi:[G] symbol},
          {hi:[G] graph},
          {hi:[G] graph options}.
{p_end}
{p 0 10}
On-line:  help for {helpb by}, {helpb statsby}, {helpb postfile}, {helpb graph}, {it:{help graph_twoway}}
 {break} help for {helpb smileplot7}, {helpb parmby}, {helpb parmest}, {helpb qqvalue} if installed
{p_end}
