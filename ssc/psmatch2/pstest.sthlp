{smcl}
{hline}
help for {hi:pstest}
{hline}

{title:Covariate imbalance testing and graphing}

{p 4 4 2}Main syntax:

{p 8 21 2}{cmdab:pstest}
{cmd:[}{it:varlist}{cmd:]}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
{cmd:[,}
	{cmd:both}
	{cmd:raw}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
	{cmdab:mw:eight}{cmd:(}{it:varname}{cmd:)}
	{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)}
	{cmdab:rub:in}
	{cmdab:not:able}
	{cmdab:lab:el}
	{cmdab:only:sig}
	{cmdab:dis:t}
	{cmd:atu}
	{cmdab:gr:aph}
	{cmd:hist}
	{cmdab:sc:atter}
	{it:graph_options} {cmd:]}

{p 8 21 2}where {it:varlist} may contain factor variables; see {cmd:fvvarlist}.

{p 4 4 2}Additionally, {cmd:pstest} allows closer inspection of the extent of balancing of individual continuous covariates using densities or box plots:

{p 8 21 2}{cmdab:pstest}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]{cmd:,}
	{cmdab:dens:ity}{cmd:|}{cmd:box}
{cmd:[}
	{cmd:both}
	{cmd:raw}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
	{cmdab:mw:eight}{cmd:(}{it:varname}{cmd:)}
	{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)}
	{cmdab:out:lier}
	{cmd:title}{cmd:(}{it:string}{cmd:)}
	{cmd:saving}{cmd:(}{it:filename}{cmd:[, replace]}{cmd:)}
	{cmd:atu}
	{cmd:]}

{p 8 21 2}where {it:varname} is a continuous variable.

{title:Description - Main syntax}

{p 4 4 2}{cmd:pstest} calculates and optionally graphs several measures of the extent of balancing of the variables in {it:varlist}
between two groups (if {it:varlist} is not specified, {cmd:pstest} will look for the variables that were
specified in the latest call of {cmd:psmatch2} or of {cmd:pstest}). In particular it can be used to gauge comparability in terms of {it:varlist} between:

{p 4 4 2}1. Two matched samples (the default).

{p 7 7 2}{cmd:pstest} can be called directly after {cmd:psmatch2}, or
it can be fed matching weights via option {cmd:mweight} to assess the extent of balancing achieved
on the two matched samples. A particularly useful way to use {cmd:pstest} is in search of a matching method and set
of matching parameters that achieves good balancing; {cmd:psmatch2} can be called repeatedly prefixed by {cmd:quietly}
and the extent of corresponding balancing can each time be displayed by calling {cmd:pstest}.

{p 4 4 2}2. Any two samples (option {cmd:raw}).

{p 7 7 2}{cmd:pstest} can be called to assess the comparability of {it:any} two groups. This may be
before performing matching, or completely unrelated to matching purposes. (The groups are in any case
referred to as Treated and Controls, but they could be males and females, employed and non-employed etc.).

{p 4 4 2}3. Two samples before and after having performed matching (option {cmd:both}).

{p 7 7 2}In this case {cmd:pstest} compares the extent of balancing between the two samples before
and after having performed matching.

{p 4 4 2}For each variable in {it:varlist} it calculates the following indicators (before
and after matching if option {cmd:both} is specified):

{p 8 8 2}(a) t-tests for equality of means in the two samples. T-tests are based on a regression of the variable on a treatment indicator.
Before matching or on {cmd:raw} samples this is an unweighted regression on the whole sample, after matching the regression is weighted using the
matching weight variable _weight or user-given weight variable in {cmd:mweight} and based on the on-support sample;

{p 8 8 2}(b) the standardised percentage bias. If option {cmd:both} is specified, the standardised percentage bias is shown before and after matching,
together with the achieved percentage reduction in abs(bias).
The standardised % bias is the % difference of the sample means in the treated and non-treated (full or
matched) sub-samples as a percentage of the square root of the average of the
sample variances in the treated and non-treated groups (formulae from Rosenbaum and Rubin, 1985).

{p 8 8 2}(c) the variance ratio (for continuous covariates) of treated over non-treated. This ratio should equal 1 if there is perfect balance. An asterisk
is displayed for variables that have variance ratios that exceed the 2.5th and 97.5th percentiles of
the F-distribution with (number of [matched] treated minus 1) and (number of [matched] treated minus 1) degrees of freedom.
These F-percentiles only offer a rough guide and are reported at the bottom of the table (see Austin, 2009). 
Alternatively, if option {cmd:rubin} is specified, the ratio of the variance of the residuals orthogonal to the linear index of the
propensity score in the treated group over the non-treated group is shown for each covariate. One asterisk is displayed for variables "of concern" -
ratio in [0.5, 0.8) or (1.25, 2]; two asterisks are displayed for "bad" variables - ratio <0.5 or >2 (see Rubin, 2001).

{p 4 4 2}It also calculates the following overall measures of covariate imbalance, where if option {cmd:both} is specified,
the indicators are shown both before and after matching (note that these measures are only meaningful if {it:varlist} contains the full
set of covariates of interest):

{p 8 8 2}(a) Pseudo R2 from probit estimation of the conditional treatment probability (propensity score)
on all the variables in {it:varlist} on {cmd:raw} samples, matched samples (default) or {cmd:both} before and
after matching. Also displayed are the corresponding P-values of the likelihood-ratio test of the joint insignificance of all the regressors (before and after matching
if option {cmd:both} is specified);

{p 8 8 2}(b) the mean and median bias as summary indicators of the distribution of the abs(bias);

{p 8 8 2}(c) the percentage of continuous variables that have variance ratios that exceed the 2.5th and 97.5th percentiles of the F-distribution, or,
if option {cmd:rubin} is specified, the percentage of all covariates orthogonal to the propensity score with the specified
variance ratios (% of concern and % bad, with % good being the complement to 100); 

{p 8 8 2}(d) Rubins' B (the absolute standardized difference of the means of the linear index of the propensity score in the treated and
(matched) non-treated group) and Rubin's R (the ratio of treated to (matched) non-treated variances of the propensity score index).
Rubin (2001) recommends that B be less than 25 and that R be between 0.5 and 2 for the samples to be considered sufficiently balanced.
An asterisk is displayed next to B and R values that fall outside those limits.

{p 4 4 2}Optionally {cmd:pstest} graphs the extent of covariate imbalance in terms of standardised
percentage differences using dot charts (option {cmd:graph}) or histograms (option {cmd:hist}).	Alternatively, option {cmd:scatter}
draws a scatterplot of the standardised differences vs Rubin's residual variance ratios, offering an at-a-glance picture of covariate
imbalance in terms of these two indicators.

{p 4 4 2}One only need type {cmd:pstest[, both]} directly after {cmd:psmatch2} to inspect the extent of covariate balancing
in matched samples if {cmd:psmatch2} has been called with a {it:varlist}.

{p 4 4 2}If option {cmd:both} is specified, {cmd:pstest} returns the following diagnostics of
covariate balancing before and after matching: {it:r(meanbiasbef)} and {it:r(meanbiasaft)} the mean absolute standardised bias;  
{it:r(medbiasbef)} and {it:r(medbiasaft)} the median absolute standardised bias;  
{it:r(r2bef)} and {it:r(r2aft)} the pseudo R2 from probit estimation; 
{it:r(chiprobbef)} and {it:r(chiprobaft)} the P-value of the likelihood-ratio test;	{it:r(Bbef)} and {it:r(Baft)} Rubin's B; and 
{it:r(Rbef)} and {it:r(Raft)} Rubin's R. If the two groups
are compared only once (matched samples as default or two unmatched samples if option {cmd:raw} is specified),
{cmd:pstest} returns {it:r(meanbias)}, {it:r(medbias)}, {it:r(r2)}, {it:r(chiprob)}, {it:r(B)} and {it:r(R)}.
{cmd:pstest} always returns in {it:r(exog)} the names of the variables for which it has tested
the extent of balancing.

{title:Description - Syntax to assess balancing of individual continuous covariates}

{p 4 4 2}Calling {cmd:pstest} {it:varname}{cmd:,} {cmd:density}{cmd:|}{cmd:box} displays the density or box plot of the specified
continous variable {it:varname}.

{p 4 4 2}As in the main syntax, {cmd:pstest} can be used this way to inspect the density/box plot of a variable for any two groups (option {cmd:raw}),
for matched samples (default) and both before and after matching (option {cmd:both}).

{p 4 4 2}This calling of {cmd:pstest} does not return any indicator (and indeed clears any indicator returned in {cmd:r()} left behind
from the main syntax). 

	
{title:Important notes}

{p 4 4 2}{cmd:pstest} by default considers balancing for the ATT (Average Treatment Effect on the Treated),
where the treated are the reference group. If called after
{cmd:psmatch2, ate} one can specify the option {cmd:atu} to consider balancing for the ATU 
(Average Treatment Effect on the Untreated), where the non-treated are the reference group.

{p 4 4 2}Spline matching as in {cmd:psmatch2, spline} as well as the default (epanechnikov) local
linear regression matching as in {cmd:psmatch2, llr} first smooth the outcome and then perform
nearest neighbor matching. {cmd:pstest} does not make sense in these cases since
more non-treated are used to calculate the counterfactual outcome than the nearest neighbor only.


{title:Detailed Syntax}

{phang}
{bf:Matched samples:}

{p 8 21 2}{cmdab:pstest}
{cmd:[}{it:varlist}{cmd:]}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
{cmd:[,}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
	{cmdab:mw:eight}{cmd:(}{it:varname}{cmd:)}
	{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)}
	{cmdab:rub:in}
	{cmdab:not:able}
	{cmdab:dis:t}
	{cmdab:lab:el}
	{cmdab:only:sig}
	{cmd:atu}
	{cmdab:gr:aph}
	{cmd:hist}
	{cmdab:sc:atter}
	{it:graph_options} {cmd:]}

{p 8 21 2}{cmdab:pstest}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]{cmd:,}
	{cmdab:dens:ity}{cmd:|}{cmd:box}
{cmd:[}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
	{cmdab:mw:eight}{cmd:(}{it:varname}{cmd:)}
	{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)}
	{cmdab:out:lier}
	{cmd:title}{cmd:(}{it:string}{cmd:)}
	{cmd:saving}{cmd:(}{it:filename}{cmd:[, replace]}{cmd:)}
	{cmd:atu}
	{cmd:]}

{phang}
{bf:Raw samples:}

{p 8 21 2}{cmdab:pstest}
{cmd:[}{it:varlist}{cmd:]}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]{cmd:,}
	{cmd:raw}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
	{cmd:[}
	{cmdab:rub:in}
	{cmdab:not:able}
	{cmdab:dis:t}
	{cmdab:lab:el}
	{cmdab:only:sig}
	{cmdab:gr:aph}
	{cmd:hist}
	{cmdab:sc:atter}
	{it:graph_options} {cmd:]}

{p 8 21 2}{cmdab:pstest}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]{cmd:,}
	{cmdab:dens:ity}{cmd:|}{cmd:box}
	{cmd:raw}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
{cmd:[}
	{cmdab:out:lier}
	{cmd:title}{cmd:(}{it:string}{cmd:)}
	{cmd:saving}{cmd:(}{it:filename}{cmd:[, replace]}{cmd:)}
	{cmd:]}

{phang}
{bf:Before and after matching:}

{p 8 21 2}{cmdab:pstest}
{cmd:[}{it:varlist}{cmd:]}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]{cmd:,}
	{cmd:both}
	{cmd:[}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
	{cmdab:mw:eight}{cmd:(}{it:varname}{cmd:)}
	{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)}
	{cmdab:rub:in}
	{cmdab:not:able}
	{cmdab:dis:t}
	{cmdab:lab:el}
	{cmd:atu}
	{cmdab:gr:aph}
	{cmd:hist}
	{cmdab:sc:atter}
	{it:graph_options} {cmd:]}

{p 8 21 2}{cmdab:pstest}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]{cmd:,}
	{cmdab:dens:ity}{cmd:|}{cmd:box}
	{cmd:both}
{cmd:[}
	{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)}
	{cmdab:mw:eight}{cmd:(}{it:varname}{cmd:)}
	{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)}
	{cmdab:out:lier}
	{cmd:title}{cmd:(}{it:string}{cmd:)}
	{cmd:saving}{cmd:(}{it:filename}{cmd:[, replace]}{cmd:)}
	{cmd:atu}
	{cmd:]}
	
{title:Options}

{p 4 8 2}{cmd:both} Requires comparability to be assessed both before and after matching.
Default is only after matching.

{p 4 8 2}{cmd:raw} Requires comparability to be assessed between any two (unweighted) groups.
This can be before wishing to perform matching, but also unrelated to matching purposes, e.g.
to quickly assess how randomisation has worked.

{p 4 8 2}{cmdab:t:reated}{cmd:(}{it:varname}{cmd:)} Treatment (or group) indicator (0/1).
If option {cmd:raw} is not specified, default is _treated left behind from the latest {cmd:psmatch2} call.

{p 4 8 2}{cmdab:mw:eight}{cmd:(}{it:varname}{cmd:)} Weight of matches.
If option {cmd:raw} is not specified, default is _weight left behind from the latest {cmd:psmatch2} call.

{p 4 8 2}{cmdab:sup:port}{cmd:(}{it:varname}{cmd:)} Common support indicator (0/1).
If option {cmd:raw} is not specified, default is _support left behind from the latest {cmd:psmatch2} call.

{p 4 8 2}{cmdab:rub:in} Display Rubin's (2001) ratio of the variance of the covariates orthogonal to the propensity score
(instead of the standard variance ratios) in the variable-by-variable table and the percentage of all covariates
orthogonal to the propensity score (instead of the percentage of continuous covariates) with the specified variance ratios in the overall table.

{p 4 8 2}{cmdab:not:able} Do not display the table with the individual covariate imbalance
indicators (standardised percentage bias, t-tests, if option {cmd:both} is specified
achieved percentage reduction in absolute bias) and variance ratios for each variable in {it:varlist}.

{p 4 8 2}{cmdab:lab:el} Display variable labels instead of variable names in the variable-by-variable
table.

{p 4 8 2}{cmdab:only:sig} In the variable-by-variable table only display those variables
which are significantly unbalanced (p<=0.10). This option is ignored if option {cmd:both} is specified.

{p 4 8 2}{cmdab:dis:t} Display the distribution summary of the absolute standardised percentage
bias across all variables in {it:varlist}.

{p 4 8 2}{cmdab:gr:aph} Display a graphical summary of covariate imbalance via a dot chart, showing the
standardised percentage bias for each covariate. If option {cmd:both} is specified, information
before and after matching is displayed in the same dot chart. If more than 30 covariates are specified, they are not labelled.  

{p 4 8 2}{cmdab:hist} Display a graphical summary of covariate imbalance via a histogram,
showing the distribution of the standardised percentage bias across covariates. If option {cmd:both} is specified,
imbalance before and after matching is displayed in two histograms forced to have the same x-axis. Recommended for a large number of covariates.

{p 4 8 2}{cmdab:sc:atter} Display a graphical summary of covariate imbalance via a scatter plot of
standardised percentage bias vs residual variance ratio. If option {cmd:both} is specified,
imbalance before and after matching is displayed in two scatterplots forced to have the same x-axis.
Note that specifying {cmd:scatter} implicitly specifies {cmd:rubin}, so that information on Rubin's (2001) ratio of the variance of the
covariates orthogonal to the propensity score is displayed in the tables. 
  
{p 4 8 2}{it:graph_options} Additional options can be specified for the relevant graph type
(dot graph or histogram). Useful examples are {cmd:saving}{cmd:(}{it:filename}{cmd:[, replace]}{cmd:)}; {cmd:yscale(range(}{it:numlist}{cmd:))},
{cmd:ylabel(}{it:numlist}{cmd:))} or {cmd:legend(off)} for dot graphs; and {cmd:bin(}#{cmd:)} for histograms.

{p 4 8 2}{cmd:atu} After {cmd:psmatch2, ate} one can specify this option to consider balancing when the untreated make up the reference group.

{p 4 4 2}Options specific to the second syntax:

{p 4 8 2}{cmdab:dens:ity} or {cmd:box} One of these options has to be specified in this case. If {cmdab:dens:ity} is 
specified, the kernel density of {it:varname} is estimated and plotted, if {cmd:box} is specified, the box plot of {it:varname} is displayed.
A box plot displays the following, from top to bottom: the top outside values (if option {cmdab:out:lier} is specified),
the upper adjacent value, the 75th percentile, the median, the 25th percentile, the lower adjacent value
and (if option {cmdab:out:lier} is specified) the bottom outside values of the variable {it:varname}.

{p 4 8 2}{cmdab:out:lier} In a {cmd:box} plot, display the outside values.  

{p 4 8 2}{cmd:title}{cmd:(}{it:string}{cmd:)} For either {cmdab:dens:ity} or {cmd:box} plots, specify this option
to override the default title (given by the label of {it:varname}, and in the absence of a label, the name of {it:varname}).
Do NOT contain the title in quotes, e.g. a title could be: title(Kernel density estimate of real wages).

{p 4 8 2}{cmd:saving}{cmd:(}{it:filename}{cmd:[, replace]}{cmd:)} To save the graph produced by {cmdab:dens:ity} or {cmd:box}.

	
{title:Examples}

    {inp: . pstest age gender foreign exper, t(training) mw(_weight) onlysig graph}
    {inp: . pstest foreign##c.age married##c.exper if district==1, raw t(male) label scatter}
	
    {inp: . psmatch2 treated age gender foreign exper, outcome(wage) ate}
    {inp: . pstest}
    {inp: . pstest, both}
    {inp: . pstest, both atu}

    {inp: . pstest age, box out raw t(treated) saving(age_raw, replace)}
    {inp: . pstest earn if earn<40000, density both title(Balancing of earnings before and after matching)}

	
{title:Also see}

{p 4 4 2}The commands {help psmatch2}, {help psgraph}.

{title:References}

{p 0 2}Austin, P.C. (2009), "Balance Diagnostics for Comparing the Distribution of Baseline Covariates Between Treatment Groups in Propensity Score Matched Samples." {it:Statistics in Medicine 28(25)}, 3083-3107.

{p 0 2}Rosenbaum, P.R. and Rubin, D.B. (1985), "Constructing a Control Group Using Multivariate Matched Sampling Methods that Incorporate the Propensity Score", {it:The American Statistician 39(1)}, 33-38.

{p 0 2}Rubin, D.B. (2001), "Using Propensity Scores to Help Design Observational Studies: Application to the Tobacco Litigation", {it:Health Services & Outcomes Research Methodology 2}, 169-188.

{title:Authors}

{p 4 4 2}Edwin Leuven, University of Oslo. If you observe any problems {browse "mailto:e.leuven@gmail.com"}.

{p 4 4 2}Barbara Sianesi, Institute for Fiscal Studies, London, UK.
