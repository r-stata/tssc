{smcl}
{* 20Apr2009}{...}
{hline}
help for {hi:metaan}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:metaan} {hline 2}}Module for performing fixed- or random-effects meta-analyses{p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 8 2}
{cmd:metaan} {it:varname1} {it:varname2} [{it:varname3} {it:varname4}] {ifin} [{cmd:,} {it:{help collapse##options:options}}]

{p 4 4 2}where:{p_end}
{p 6 6 2}{it:varvame1} the study effect sizes{p_end}
{p 6 6 2}{it:varvame2} the study effect variation, with standard error used as default

{p 4 4 2}Or, for meta-analysis of proportions:{p_end}
{p 6 6 2}{it:varvame1} numerators{p_end}
{p 6 6 2}{it:varvame2} denominators

{p 4 4 2}Or, for binary outcomes with event data:{p_end}
{p 6 6 2}{it:varvame1} number of events in group 1{p_end}
{p 6 6 2}{it:varvame2} number of non-events in group 1{p_end}
{p 6 6 2}{it:varvame3} number of events in group 2{p_end}
{p 6 6 2}{it:varvame4} number of non-events in group 2

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt fe}}Fixed-effect model
{p_end}
{synopt :{opt dl}}DerSimonian-Laird random-effects model
{p_end}
{synopt :{opt bdl}}Bootstrapped DerSimonian-Laird random-effects model
{p_end}
{synopt :{opt ml}}Maximum likelihood random-effects model
{p_end}
{synopt :{opt reml}}Restricted maximum likelihood random-effects model
{p_end}
{synopt :{opt pl}}Profile likelihood random-effects model
{p_end}
{synopt :{opt pe}}Permutations random-effects model
{p_end}
{synopt :{opt sa}}Sensitivity analysis model
{p_end}
{synopt :{opt peo}}Peto fixed-effect O-E model
{p_end}
{synopt :{opt prp}}Meta-analysis of proportions
{p_end}
{synopt :{opt exp}}Results transformed from log-scale for binary outcomes
{p_end}
{synopt :{opth backt(varname)}}Back-transform from logit scale to percentages
{p_end}
{synopt :{opt pscl}}Scale to 0-100% when using the {opt prp} or {opt backt} options
{p_end}
{synopt :{opt varc}}Variances provided instead of the standard errors/deviations
{p_end}
{synopt :{opt mhor}}Mantel-Haenszel odds-ratio model
{p_end}
{synopt :{opt mhrr}}Mantel-Haenszel risk-ratio model
{p_end}
{synopt :{opt mhrd}}Mantel-Haenszel risk-difference model
{p_end}
{synopt :{opt por}}Peto "odds-ratio" model
{p_end}
{synopt :{opth grpby(varname)}}Grouping variable for subgroup analyses
{p_end}
{synopt :{opth label(varname)}}Study label variable(s)
{p_end}
{synopt :{opt reps(#)}}Number of bootstrap replications
{p_end}
{synopt :{opt seed(#)}}Seed number
{p_end}
{synopt :{opt sens(#)}}Sensitivity analysis pre-set heterogeneity (I^2) level
{p_end}
{synopt :{opt plplot(string)}}Likelihood plot for the mu or tau^2 estimate in the maximum-likelihood models (ml, pl, reml)
{p_end}
{synopt :{opt forest}}Forest plot. This has been completely changed and numerous options have been added (see further below).
{p_end}

{title:Description}

{p 4 4 2}
The {cmd:metaan} command performs a meta-analysis on a set of studies and calculates the overall effect and a confidence interval for
the effect. The command also displays various heterogeneity measures: Cochrane's Q, I^2 (in the 0-100% range with larger scores indicating higher heterogeneity levels),
H^2 (equals 1 in the case of homogeneity) and the between-study variance estimate. Cochrane's Q is the same across all methods, but the
between-study variance estimate (and hence I^2 and H^2) can vary between the {opt dl} and {opt ml} methods. Only one method option must
be selected, with the exception of the four methods for event data ({opt mhor}, {opt mhrr}, {opt mhrd} and {opt por}) each one of which can be combined
with the other models for different weighting and random-effects options. For calculating the effects and variance of the effects, for a group of studies,
from various statistical parameters please see {cmd:{help metaeff}}. The command will automatically detect the alpha level in the environment and use it
(edit by typing {cmd:.set level 99}, for example). More details and examples have been provided in an accompanying paper, published in the Stata Journal
({browse "http://www.stata-journal.com/article.html?article=st0201":http://www.stata-journal.com/article.html?article=st0201})

{p 4 4 2}
The syntax that uses two variables (the effect and its variability) calls standard fixed-effect or one of many inverse variance weighting methods, which can
account for heterogeneity. Binary outcomes can still be implemented using this syntax, provided the effect and its variability are available. In this case the
command expects as input the log() of the measure (odds-ratio, risk-ratio or hazard-ratio) in {it:varname1} and its standard error in {it:varname2}
(see Appendix tables in {browse "http://www.jstatsoft.org/v30/i07/":http://www.jstatsoft.org/v30/i07/} regarding relevant methods,
which are available in {cmd:{help metaeff}}). The default output in that case is the overall log() of the measure, unless the user specifies the {opt exp} option
which returns the exponentiated results (to ORs, RRs, HRs etc). The name of the measure can be inputted with the forest plot {opt effect()} option, the default being odds-ratio.

{p 4 4 2}
The syntax that uses four variables (events and non-events in two comparison groups) calls Mantel-Haenszel and Peto fixed-effect meta-analysis methods for
binary outcomes. These methods necessarily ignore heterogeneity but have been shown to work well in rare (Mantel-Haenszel) and very rare (Peto) event settings - where 
heterogeneity is very difficult to measure anyway. Three Mantel-Haenszel approaches are provided, in terms of the effect calculation: odds-ratio, risk-ratio and
risk-difference. The Peto "odds-ratio" is not really an odds-ratio but it has come to be known as that. For the Mantel-Haenszel approaches, zero-cell corrections are
applied (adding 0.5 to events of both groups if one of them is zero - if both are zero the study is necessarily dropped). Corrections are not needed for Peto, due to the way the
effects are calculated. Weightings with these approaches differ to standard inverse-variance weighting and are closer, but not the same, to fixed-effect weighting, where the size
of the study is the primary determinant (Peto uses an inverse variance approach but different weights and a different estimand). Each of these four methods can be combined with
any of the inverse-variance models or the fixed-effect approach. In that case, the effect and its variance are calculated using the respective method for event data
(one of {opt mhor}, {opt mhrr}, {opt mhrd} or {opt por}) which are then meta-analysed. This approach allows for modelling heterogeneity, but the weighting can be very
different, as previously mentioned (these "hybrid" methods are provided in Cochrane's RevMan). The command always meta-analyses the odds-ratios and risk-ratios on the
log() scale and, by default, returns results on that scale. Users can specify the {opt exp} option to obtain exponentiated results of these (Note that risk-difference
is not a ratio, and the log() scale and {opt exp} option do not apply).

{p 4 4 2}
For meta-analyses of time-to-event outcomes, the use of adjusted Hazard Ratios (HRs) are advised, with the first syntax (two variables).
A reasonable alternative is the calculation of the log hazard ratio, from a logrank analysis. The log hazard ratio is estimated by (O–E)/V, which has standard error 1/sqrt(V),
where O is the observed number of events on the intervention, E is the logrank expected number of events on the intervention, O–E is the logrank statistic and V is the
variance of the logrank statistic ({browse "https://en.wikipedia.org/wiki/Logrank_test":https://en.wikipedia.org/wiki/Logrank_test}). The Peto method can also be used in this
context, since it is O-E based, to pool HRs (or ORs) with option {opt poe}, which is equivalent to a fixed-effect approach. Dichotomous data approaches ({opt mhor}, {opt mhrr},
{opt mhrd} or {opt por}) are not advised here, even if the follow-up times are identical across studies, since these methods cannot account for censored data. 

{title:Options}

{dlgtab:Meta-analysis model}

{phang}
{opt fe} Fixed-model that assumes there is no heterogeneity between the studies. The model assumes
that within-study variances may differ, but that there is homogeneity of effect size across allstudies.
Often the homogeneity assumption is unlikely and variation in the true effect across studies is to be expected.
Therefore, caution is required when using this model. Reported heterogeneity measures are estimated using inverse-variance weighting and the {opt dl} model.

{phang}
{opt dl} DerSimonian-Laird (DL), the most commonly used random-effects model. Models heterogeneity between the studies i.e. assumes that the true
effect can be different for each study. The method assumes that the individual study true effects are distributed with variance tau^2, around an
"overall" true effect, but makes no assumptions about the form of the distribution of either the within- or between-study effects. Inverse-variance
weighting is used, very different to fixed-effect weighting which is based on study size, and small studies may be given disproportionally
large weights. Reported heterogeneity measures are estimated using the {opt dl} model.

{phang}
{opt bdl} Bootstrapped DerSimonian-Laird, similar approach to DL but better performing, especially for small meta-analyses. Uses a non-parametric bootstrap
to estimate the between-study variance and other heterogeneity parameters. Reported heterogeneity measures are estimated using the {opt bdl} model.

{phang}
{opt ml} Maximum likelihood random-effects model. Makes the additional assumption (necessary to derive the log-likelihood function, and also true for
{opt reml} and {opt pl} below) that both the within-study and between-study effects are normally distributed. It solves the log-likelihood function
iteratively to produce an estimate of the between-study variance. However, the method does not always converge while in some cases the between-study
variance estimate is negative and set to zero (in which case the model is reduced to the {opt fe} model). Estimates are reported as missing in the
event of non-convergence. Reported heterogeneity measures are estimated using the {opt ml} model.

{phang}
{opt reml} Restricted maximum-likelihood random-effects model. Similar method to {opt ml} and using the same assumptions. The log-likelihood
function is maximized iteratively to provide estimates as in {opt ml}. However, under {opt reml} only the part of the likelihood function which is location
invariant is maximized (i.e. maximizing the portion of the likelihood that does not involve mu, if estimating tau^2, and vice versa).
The method does not always converge while in some cases the between-study variance estimate is negative and set to zero (in which case the model is
reduced to the {opt fe} model). Estimates are reported as missing in the event of non-convergence. Reported heterogeneity measures are estimated using
the {opt reml} model.

{phang}
{opt pl} Profile likelihood random-effects model. Profile likelihood uses the same likelihood function as {opt ml}, but takes into account the
uncertainty associated with the between-study variance estimate when calculating an overall effect, by using nested iterations to converge to an
maximum. The confidence intervals provided by the method are asymmetric and hence so is the the diamond in the forest plot. However, the
method does not always converge. Values that were not computed are reported as missing. Reported heterogeneity measures are estimated using the
{opt ml} model (the effect and tau^2 estimates are the same, only the confidence intervals are re-estimated) but also provides a confidence interval
for the between-study variance estimate.

{phang}
{opt pe} Permutations random-effects model. A non-parametric random-effects method, which can be described in three steps. First, in line with a Null
hypothesis that all true study effects are zero and observed effects are due to random variation, a dataset of all possible combinations of observed
study outcomes is created by permuting the sign of each observed effect. Then the {opt dl} method is used to compute an overall effect for each
combination. Finally, the resulting distribution of overall effect sizes is used to derive a confidence interval for the observed overall effect.
The confidence interval provided by the method is asymmetric and hence so is the diamond in the forest plot. Study weights and reported heterogeneity measures are
estimated using the {opt dl} model.

{phang}
{opt sa} Sensitivity analysis model. Allows sensitivity analyses to be performed by varying the level of heterogeneity, with I^2 taking values in the
[0,100) range. Undetected heterogeneity is the norm rather than the exception and we encourage users to test the sensitivity of their results in the
presence of moderate (50%) and high (80-90%) levels of heterogeneity (please see Kontopantelis et al, 2013).
Reported heterogeneity measures are based on the preset I^2 level.

{phang}
{opt poe} Peto fixed-effect approach for time-to-event O - E (observed minus expected) data. By default, the log() of hazard-ratios (HR) are assumed to be provided for meta-analysis, 
which can be exponentiated to HRs with the {opt exp} option. Odds-ratios (OR) can also be meta-analysed (again, expecting log(OR) as input and the variance
of the effect); in this case, if a forest plot is requested, the outcome label should be edited with the {opt effect()} option. The method is identical to 
{opt fe} and is only provided for completeness and clarity. 

{dlgtab:Binary outcome data with the four variable syntax}

{phang}
{opt mhor} Mantel-Haenszel fixed-effect model, with effect calculation based on odds-ratio (OR). It can be combined with inverse-variance models to account for
heterogeneity or a fixed-effect model, for different weighting approaches. If a random-effects or fixed-effect approach is used in combination with the {opt mhor} option, weighting
follows the random-effects or fixed-effect approach used and Mantel-Haenszel is only relevant in the way the effect is calculated within each study from events. The {opt exp} option needs
to be used to report effects as ORs, and not on the log() scale. 

{phang}
{opt mhrr} Mantel-Haenszel fixed-effect model, with effect calculation based on risk-ratio (RR). It can be combined with inverse-variance models to account for
heterogeneity or a fixed-effect model, for different weighting approaches. If a random-effects or fixed-effect approach is used in combination with the {opt mhrr} option, weighting
follows the random-effects or fixed-effect approach used and Mantel-Haenszel is only relevant in the way the effect is calculated within each study from events.
The {opt exp} option needs to be used to report effects as RRs, and not on the log() scale. 

{phang}
{opt mhrd} Mantel-Haenszel fixed-effect model, with effect calculation based on risk-difference (RD). It can be combined with inverse-variance models to account for
heterogeneity or a fixed-effect model, for different weighting approaches. If a random-effects or fixed-effect approach is used in combination with the {opt mhrd} option, weighting
follows the random-effects or fixed-effect approach used and Mantel-Haenszel is only relevant in the way the effect is calculated within each study from events.

{phang}
{opt por} Peto "odds-ratio" (OR) fixed-effect model. It can be combined with inverse-variance models to account for heterogeneity or a fixed-effect model,
for different weighting approaches. In that case the {opt por} option is only relevant to the effect calculation (which is technically not an odds-ratio, but the name
has stuck). The {opt exp} option needs to be used to report effects as ORs, and not on the log() scale. 

{dlgtab:General modelling options}

{phang}
{opth grpby(varname)} Grouping variable for subgroup analyses.
Integer numeric variable expected, ideally with appropriate value labels see {help label define}. The groups will be ordered according to the variable provided, and headers for the results
and the forest plot (if requested) will be obtained from the variable's value labels (if no labels are present, the relevant numbers will be used). All analyses are repeated for each group
category and overall. Results are presented as separate analyses in the results window, but are all aggregated into a single forest plot (if one is requested). 

{phang}
{opth label(varname)} Selects labels for the studies.
Up to two variables can be selected and converted to strings. If two variables are selected they will be separated by a comma. Usually,
the author names and the year of study are selected as labels. The final string is truncated to 20 characters.

{phang}
{opt varc} Informs the program that the study effect variation variable ({it:varname2}) holds variance values. If this option is
omitted the program assumes the variable contains standard error values (the default)

{phang}
{opt prp} Informs the program that numerators ({it:varname1}) and denominators ({it:varname2}) are provided and a meta-analysis of proportions will be
executed. The Freeman-Tukey arcsine transformation is used, variance is calculated as 1/({it:varname2}+1) and effects and confidence intervals (study and overall)
are back-transformed using (sin(x/2))^2.

{phang}
{opt exp} Informs the program that the results will be exponentiated, for dichotomous outcomes. For dichotomous outcomes the log() of the measure (Odds Ratio, Risk Ratio or Hazard Ratio)  and its
standard error is expected as input and the overall log() of the measure is returned by default, unless this option is specified. If it is, the input is
still expected to be the log() of the measure in {it:varname1} but results are exponentiated.

{phang}
{opth backt(varname)} Back-transformation to percentages, from simple or empirical logit ({browse "https://www.bmj.com/content/352/bmj.i1114":https://www.bmj.com/content/352/bmj.i1114}).
Up to two variables can be selected. The first holds the study "anchor" percentages which are essential for the back-transformation to take place. The second holds the relevant denominators.
If only percentages are provided, they need to be in the (0,1) range for back-transformation from simple empirical logit. If any zeros or ones are present in the percentages variable, however,
the empirical logit will need to be employed and in this case the denominatos are needed as well. The overall effect is back-transformed using the mean percentage across all
studies as "anchor". If denominators are provided then the mean percentage is weighted on denominators, if not it is unweighted.

{phang}
{opt pscl} Scale to [0%-100%] when using the {opt prp} or {opt backt} options. The default display for percentages in the output and forest plot is in the [0,1] range.

{dlgtab:Bootstrapped DerSimonian-Laird options}

{phang}
{opt reps(#)} Integer number of repetition for the bootstrapped DerSimonian-Laird method. Fewer than 100 repetitions are not permitted.

{phang}
{opt seed(#)} Seed number to be used in the bootstrapped DerSimonian-Laird method, if requested.

{dlgtab:Sensitivity analysis options}

{phang}
{opt sens(#)} Preset heterogeneity level, with I^2 taking values in the [0,100) range. The default value is 80%.

{dlgtab:Graphs}

{p 4 4 2}
Only one graph output is allowed in each execution

{phang}
{opt plplot(string)} Requests a plot of the likelihood function for the mu or tau^2 estimates of the {opt ml}, {opt pl} or {opt reml} models.
Option {opt plplot(mu)} fixes mu to its model estimate, in the likelihood function, and creates a two way plot of tau^2 vs the likelihood function.
Option {opt plplot(tsq)} fixes tau^2 to its model estimate, in the likelihood function, and creates a two way plot of mu vs the likelihood function.

{phang}
{opt forest} Requests a forest plot. The weights from the specified analysis are used for plotting symbol sizes. The
command has been edited to use the popular _dispgby program by Ross Harris and Mike Bradburn, which is integrated with other popular meta-analysis
commands (e.g. metan). We allow all relevant options (see below).

{dlgtab:Forest plot options}

{phang}
{opt dp(#)} Decimal points for the reported effects. The default value is 2.

{phang}
{opt effect(string)} This allows the graph to name the summary statistic used (e.g. OR, RR, SMD).

{phang}
{opt favours(string # string)} Applies a label saying something about the treatment effect to either
side of the graph (strings are separated by the # symbol).

{phang}
{opt null(#)} Displays the null line at a user-defined value rather than 0 or 1.

{phang}
{opt nulloff} Removes the null hypothesis line from the graph.

{phang}
{opt nooverall} Prevents display of overall effect size on graph (automatically enforces the {opt nowt} option).

{phang}
{opt nowt} Prevents display of study weights on the graph.

{phang}
{opt nostats} Prevents display of study statistics on graph.

{phang}
{opt nowarning} Switches off the default display of a note warning that studies are
weighted from random-effects analyses.

{phang}
{opt nohet} Prevents display of heterogeneity statistics in the graph.

{phang}
{opt nobox} Prevents a weighted box being drawn for each study and markers for point estimates are only shown.

{phang}
{opt boxsca(#)} Controls box scaling. The default is 100 (as in a percentage) and may be increased or decreased
as such (e.g., 80 or 120 for 20% smaller or larger respectively)

{phang}
{opth xlabel(numlist)} Defines x-axis labels. Any number of points may defined and the range can be enforced
with the use of the {opt force} option. Points must be comma separated.

{phang}
{opth xtick(numlist)} Adds tick marks to the x-axis. Points must be comma separated.

{phang}
{opt force} Forces the x-axis scale to be in the range specified by {opt xlabel()}.

{phang}
{opt texts(#)} Specifies font size for text display on graph. The default is 100 (as in a
percentage) and may be increased or decreased as such (e.g., 80 or 120 for 20% smaller or larger respectively)

{phang}
{opt astext(#)} Specifies the percentage of the graph to be taken up by text. The default is 50
and the percentage must be in the range 10-90.

{phang}
{opt summaryonly} Shows only summary estimates in the graph.

{phang}
{opt classic} Specifies that solid black boxes without point estimate markers are used as in previous versions.

{phang}
{opth lcols(varlist)}, {opth rcols(varlist)} Define columns of additional data to the left or right of the graph.
The first two columns on the right are automatically set to effect size and weight, unless suppressed using 
the options {opt nostats} and {opt nowt}. {opt textsize()} can be used to fine-tune the size of the text
in order to achieve a satisfactory appearance. The columns are labelled with the variable label, or the variable name
if this is not defined. The first variable specified in {opt lcols()} is assumed to be the study identifier and this
is used in the table output.

{phang}
{opt double} Allows variables specified in {opt lcols()} and {opt rcols()} to run over two lines in the plot.
This may be of use if long strings are to be used.

{phang}
{opt boxopt()}, {opt diamopt()}, {opt pointopt()}, {opt ciopt()}, {opt olineopt()}
Specify options for the graph routines within the program, allowing the user to alter the appearance of the graph.
Any options associated with a particular graph command may be used, except some that would cause incorrect graph appearance.

{p 8 8 2}
{opt boxopt()} controls the boxes and uses options for a weighted marker
(e.g., shape, colour; but not size). See {help marker options}.

{p 8 8 2}
{opt diamopt()} controls the diamonds and uses options for pcspike (not horizontal/vertical).
See {help line options}.

{p 8 8 2}
{opt pointopt()} controls the point estimate using marker options.
See {help marker options} and {help marker label options}.

{p 8 8 2}
{opt ciopt()} controls the confidence intervals for studies using options
for pcspike (not horizontal/vertical). See {help line options}.

{p 8 8 2}
{opt olineopt()} controls the overall effect line with options for an additional 
line (not position). See {help line options}.

{phang}
Various graph options can be used to specify overall graph options that would appear at the end of a {cmd:twoway}
graph command. This allows the addition of titles, subtitles, captions etc., control of margins, plot regions, graph size,
aspect ratio and the use of schemes. See {search graph options}.


{title:Remarks}
{p 4 4 2}
For a detailed description of the methods see Brockwell & Gorndon (methods {opt fe}, {opt dl}, {opt pl}, {opt ml}) and
Follmann & Proschan ({opt pe}). Method performance investigated by Kontopantelis & Reeves and Brockwell & Gorndon. Performance of
the bootstrapped DerSimonian-Laird ({opt bdl}) investigated by Kontopantelis, Springate and Reeves. Confidence intervals for I^2 and H^2
are calculated using the test-based method (Higgins & Thompson). Confidence intervals for tau^2 are only calculated under the PL method.
Details on the Mantel-Haenszel and Peto methods are provided in the Cochrane handbook and numerous other publications.

{title:Examples}
{p 4 4 2}Two-variable syntax:{p_end}
{phang2}{cmd:. metaan eff SEeff, ml}{p_end}
{phang2}{cmd:. metaan eff SEeff, pl forest}{p_end}
{phang2}{cmd:. metaan eff effvar, varc pe}{p_end}
{phang2}{cmd:. metaan eff effvar, bdl reps(10000) seed(123) label(study)}{p_end}
{phang2}{cmd:. metaan eff effvar, sa sens(50) label(study)}

{p 4 4 2}Four-variable syntax:{p_end}
{phang2}{cmd:. metaan Ie Ine Ce Cne, exp mhrr label(title year) forest}{p_end}
{phang2}{cmd:. metaan Ie Ine Ce Cne, exp mhrr fe label(title year) forest}{p_end}
{phang2}{cmd:. metaan Ie Ine Ce Cne, exp mhrr dl label(title year) forest}

{p 4 4 2}
More examples provided in the Stata Journal papers. The data files used for the examples can be obtained directly from:{p_end}
{phang2}{browse "http://www.statanalysis.co.uk/netStata/metaan_example_2var.dta":http://www.statanalysis.co.uk/netStata/metaan_example_2var.dta}{p_end}
{phang2}{browse "http://www.statanalysis.co.uk/netStata/metaan_example_4var.dta":http://www.statanalysis.co.uk/netStata/metaan_example_4var.dta}{p_end}
{p 4 4 2}
Or, from within Stata, type:{p_end}
{phang2}{cmd:. net from {browse "http://statanalysis.co.uk":http://statanalysis.co.uk}}{p_end}
{phang2}{cmd:. net describe metaan}{p_end}
{phang2}{cmd:. net get metaan}

{title:Saved results}

{pstd}
{cmd:metaan} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(eff)}}Overall effect size{p_end}
{synopt:{cmd:r(effvar)}}Variance of the overall effect{p_end}
{synopt:{cmd:r(efflo)}}Lower confidence interval for the overall effect{p_end}
{synopt:{cmd:r(effup)}}Upper confidence interval for the overall effect{p_end}
{synopt:{cmd:r(Q)}}Cochrane's Q statistic{p_end}
{synopt:{cmd:r(df)}}Degrees of freedom{p_end}
{synopt:{cmd:r(Qpval)}}P-value for Cochrane's Q statistic{p_end}
{synopt:{cmd:r(Isq)}}I^2 statistic{p_end}
{synopt:{cmd:r(Isq_lo)}}Lower confidence interval for I^2 statistic{p_end}
{synopt:{cmd:r(Isq_up)}}Upper confidence interval for I^2 statistic{p_end}
{synopt:{cmd:r(Hsq)}}H^2 statistic{p_end}
{synopt:{cmd:r(Hsq_lo)}}Lower confidence interval for H^2 statistic{p_end}
{synopt:{cmd:r(Hsq_up)}}Upper confidence interval for H^2 statistic{p_end}
{synopt:{cmd:r(tausq_dl)}}Between-study variance estimated using the DerSimonian-Laird model{p_end}

{pstd}
If  random-effects models except DerSimonian-Laird are requested:

{synopt:{cmd:r(tausq_bdl)}}Between-study variance estimated using the Bootstrapped DerSimonian-Laird model{p_end}
{synopt:{cmd:r(tausq_ml)}}Between-study variance estimated using the maximum likelihood model{p_end}
{synopt:{cmd:r(conv_ml)}}Convergence of the maximum likelihood model{p_end}
{synopt:{cmd:r(tausq_reml)}}Between-study variance estimated using the REML model{p_end}
{synopt:{cmd:r(conv_reml)}}Convergence of the REML model{p_end}
{synopt:{cmd:r(tausq_pl)}}Between-study variance estimated using the profile likelihood model{p_end}
{synopt:{cmd:r(tausqlo_pl)}}Lower confidence interval for between-study variance estimated using the profile likelihood model{p_end}
{synopt:{cmd:r(tausqup_pl)}}Upper confidence interval for between-study variance estimated using the profile likelihood model{p_end}
{synopt:{cmd:r(cloeff_pl)}}Convergence for lower confidence interval of the overall effect using the profile likelihood model{p_end}
{synopt:{cmd:r(cupeff_pl)}}Convergence for upper confidence interval of the overall effect using the profile likelihood model{p_end}
{synopt:{cmd:r(ctausqlo_pl)}}Convergence for lower confidence interval of between-study variance using the profile likelihood model{p_end}
{synopt:{cmd:r(ctausqup_pl)}}Convergence for upper confidence interval of between-study variance using the profile likelihood model{p_end}
{synopt:{cmd:r(exec_pe)}}Permutations method successfully executed{p_end}
{synopt:{cmd:r(tausq_sa)}}Between-study variance assumed using a sensitivity analysis{p_end}


{title:Author}
{p 4 4 2}Evangelos Kontopantelis{p_end}
{p 4 4 2}Division of Informatics, Imaging and Data Sciences{p_end}
{p 4 4 2}Faculty of Biology, Medicine and Health (FBMH){p_end}
{p 4 4 2}University of Manchester{p_end}
{p 4 4 2}email: e.kontopantelis@manchester.ac.uk

{title:Contributors}
{p 4 4 2}David Reeves, Centre for Biostatistics, FBMH, University of Manchester{p_end}
{p 4 4 2}Mike Bradburn, Clinical Trials Research Unit, University of Sheffield{p_end}
{p 4 4 2}Ross Harris, Public Health England

{title:Please cite as}
{phang}
Kontopantelis and Reeves D. 2010. {it:metaan: Random-effects meta-analysis}. The Stata Journal; 10(3): 395-407.
{browse "https://www.researchgate.net/publication/227629391_metaan_Random-effects_meta-analysis":http://www.stata-journal.com/article.html?article=st0201}

{title:Relevant references}
{phang}
Petropoulou M and Mavridis D. 2017.
{it:A comparison of 20 heterogeneity variance estimators in statistical synthesis of results from studies: a simulation study}.
Statistics in Medicine.{p_end}
{phang}
Kontopantelis E, Springate D and Reeves D. 2013.
{it:A re-analysis of the Cochrane Library data: the dangers of unobserved heterogeneity in meta-analyses}.
PLoS ONE.{p_end}
{phang}
Kontopantelis E and Reeves D. 2010.
{it:The Robustness of Statistical Methods for Meta-Analysis when Study Effects are Non-Normally Distributed: A Simulation Study}.
Statistical Methods in Medical Research.{p_end}
{phang}
Kontopantelis E and Reeves D. 2009.
{it:A Meta-Analysis add-in for Microsoft Excel}.
Journal of Statistical Software.{p_end}
{phang}
Mittlbock M and Heinzl H. 2006.
{it:A Simulation Study Comparing Properties of Heterogeneity Measures in Meta-Analyses}.
Statistics in Medicine.{p_end}
{phang}
Higgins JP and Thompson SG. 2002.
{it:Quantifying Heterogeneity in a Meta-Analysis}.
Statistics in Medicine.{p_end}
{phang}
Brockwell SE and Gordon IR. 2001.
{it:A Comparison of Statistical Methods for Meta-Analysis}.
Statistics in Medicine.{p_end}
{phang}
Follmann DA and Proschan MA. 1999.
{it:Valid Inference in Random Effects Meta-Analysis}.
Biometrics.

{title:Also see}

{p 4 4 2}
STB: STB-44 sbe24{p_end}
{p 4 4 2}
help for {help metaeff}, {help metan} (if installed){p_end}
{p 4 4 2}
{help metannt} (if installed), {help meta} (if installed){p_end}
{p 4 4 2}
{help metacum} (if installed), {help metareg} (if installed){p_end}
{p 4 4 2}
{help metabias} (if installed), {help metatrim} (if installed){p_end}
{p 4 4 2}
{help metainf} (if installed), {help galbr} (if installed){p_end}
{p 4 4 2}
{help metafunnel} (if installed) , {help ipdforest} (if installed)
