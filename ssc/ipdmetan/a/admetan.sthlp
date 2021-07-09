{smcl}
{* *! version 3.2  David Fisher  28jan2019}{...}
{vieweralsosee "admetani" "help admetani"}{...}
{vieweralsosee "ipdmetan" "help ipdmetan"}{...}
{vieweralsosee "ipdover" "help ipdover"}{...}
{vieweralsosee "forestplot" "help forestplot"}{...}
{vieweralsosee "metan" "help metan"}{...}
{vieweralsosee "metaan" "help metaan"}{...}
{viewerjumpto "Syntax" "admetan##syntax"}{...}
{viewerjumpto "Description" "admetan##description"}{...}
{viewerjumpto "Options" "admetan##options"}{...}
{viewerjumpto "Saved results" "admetan##saved_results"}{...}
{viewerjumpto "Saved datasets" "admetan##saved_datasets"}{...}
{viewerjumpto "Note: differences from metan" "admetan##diffs_metan"}{...}
{viewerjumpto "Examples" "admetan##examples"}{...}
{viewerjumpto "References" "admetan##refs"}{...}
{title:Title}

{phang}
{cmd:admetan} {hline 2} Perform meta-analysis of aggregate (summary) data


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:admetan} {it:varlist} {ifin}
[{cmd:,} {it:options}]

{pstd}
where {it:varlist} is one of the following:

{pstd}
Generic effect measures:

{p2col 9 42 44 2:{it:ES} {it:seES}}effect size and standard error{p_end}
{p2col 9 42 44 2:{it:ES} {it:lci} {it:uci}}effect size and 95% confidence limits{p_end}

{pstd}
Specific effect measures:

{p2col 9 42 44 2:{it:event_treat} {it:noevent_treat} {it:event_ctrl} {it:noevent_ctrl}} cell counts from 2x2 contingency table{p_end}
{p2col 9 42 44 2:{it:n_treat} {it:mean_treat} {it:sd_treat} {it:n_ctrl} {it:mean_ctrl} {it:sd_ctrl}}sample size, mean and standard deviation
in treatment and control groups{p_end}

{pstd}
Log-rank {it:O-E} and {it:V}:

{p2col 9 42 44 2:{it:O_E} {it:V}}observed minus expected number of events, and variance, from the control arm of a log-rank survival analysis
(must also specify {opt logrank} option; see below){p_end}

{pstd}
The terms "generic effect measure" and "specific effect measure", corresponding to Syntaxes 1 and 2 respectively in the {bf:{help ipdmetan}} documentation,
differentiate between input of an effect size and standard error that may be associated with any effect measure,
and which may only be analysed with inverse-variance based models and Cochran Q or I-squared heterogeneity statistics ("generic");
and input of cell counts from a 2x2 contingency table, means and SDs by treatment arm, or log-rank estimates of {it:O-E} and {it:V}
which allow for additional methods and statistics such as Mantel-Haenszel methods or Standardised Mean Differences ("specific").
For both {cmd:admetan} and {bf:{help ipdmetan}}, certain options are limited to "specific effect measure" input only.


{synoptset 34 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{cmd:study(}{it:varname} [{cmd:, {ul:m}issing}]{cmd:)}}study (trial) identifier{p_end}
{synopt :{cmd:by(}{it:varname} [{cmd:, {ul:m}issing}]{cmd:)}}group the studies in the output{p_end}
{synopt :{opt ci:type(string)}}method of constructing confidence intervals for individual studies ({ul:not} pooled results){p_end}
{synopt :{opt cumul:ative}}cumulative meta-analysis{p_end}
{synopt :{opt inf:luence}}investigate influence of each study in turn on the overall estimate{p_end}
{synopt :{opt altw:t}}(with {opt cumulative} or {opt influence} only) display study weights from the standard (non-cumulative or influence) model{p_end}
{synopt :{opt coef}, {opt log}}display log effect sizes and confidence limits{p_end}
{synopt :{it:{help eform_option}}}display exponentiated (antilog) effect sizes and confidence limits{p_end}
{synopt :{opt eff:ect(string)}}title for "effect size" column in the output{p_end}
{synopt :{opt keepa:ll}}display all studies in the output, even those for which no effect could be estimated{p_end}
{synopt :{opt keepo:rder}}display "no effect" studies in the order in which they would otherwise appear (by default these are moved to the end){p_end}
{synopt :{cmd:model(}{help admetan##model:{it:model}}{cmd:)}}alternative models (random-effects etc.) for meta-analytic pooling{p_end}
{synopt :{opt nogr:aph}}suppress the forest plot{p_end}
{synopt :{opt nohet}}suppress all heterogeneity statistics{p_end}
{synopt :{opt nokeepv:ars}}do not add {help admetan##saved_results:new variables} to the dataset{p_end}
{synopt :{opt nors:ample}}do not even add new variable {bf:_rsample} recording which observations were used (cf. {help f_e:e(sample)}){p_end}
{synopt :{opt noov:erall} {opt nosu:bgroup}}suppress overall pooling, or pooling within subgroups{p_end}
{synopt :{opt notab:le}}suppress printing the table of effect sizes to screen; see also {opt summaryonly}{p_end}
{synopt :{opt ovwt sgwt}}override default choice of whether to display overall weights or subgroup weights{p_end}
{synopt :{opt qe(varname)}}variable containing Quality Effects ({help admetan##refs:Doi et al 2015b}; see also {help admetan##model:{it:model}}){p_end}
{synopt :{opt re} | {opt random}}specify the standard DerSimonian & Laird random-effects model{p_end}
{synopt :{opt t}}use a {it:t}-distribution on {it:k-1} degrees of freedom to calculate confidence intervals for pooled results{p_end}
{synopt :{cmd:sortby(}{it:varname}|{cmd:_n)}}ordering of studies in table and forest plot{p_end}
{synopt :{opt wgt(varname)}}specify a variable containing user-defined weights{p_end}
{synopt :{opt npts(varname)}}(generic effect measures only) specify variable containing participant numbers, to be displayed in forest plot if applicable{p_end}

{syntab :Specific effect measures only}
{synopt :{opt bre:slow}}display Breslow-Day test for homogeneity of odds ratios{p_end}
{synopt :{cmd:cc(}[{cmd:#}] [{cmd:,} {it:cc_options}]{cmd:)}}use continuity correction value other than 0.5 for zero cells;
implement alternative methods of {help admetan##refs:Sweeting (2004)}{p_end}
{synopt :{opt nocc}}suppress continuity correction entirely{p_end}
{synopt :{opt chi2}}test significance of pooled odds ratio using chi-squared statistic (instead of z){p_end}
{synopt :{opt coch:ranq}}display Cochran's Q heterogeneity statistic (default is Mantel-Haenszel){p_end}
{synopt :{opt cor:nfield}}compute confidence intervals for odds ratios by method of Cornfield{p_end}
{synopt :{opt noint:eger}}allow cell counts to be non-integers{p_end}
{synopt :{opt iv}}use inverse-variance pooling (default is Mantel-Haenszel){p_end}
{synopt :{opt peto}}use Peto's method to pool odds ratios{p_end}

{synopt :{opt coh:en}}pool standardised mean differences (SMDs) by the method of Cohen (default){p_end}
{synopt :{opt hed:ges}}pool SMDs by the method of Hedges{p_end}
{synopt :{opt gla:ss}}pool SMDs by the method of Glass{p_end}
{synopt :{opt md}, {opt wmd}, {opt nostan:dard}}pool unstandardised ("weighted") mean differences (WMDs){p_end}

{syntab :Log-rank {it:O-E} and {it:V} only}
{synopt :{opt logr:ank}}specify that {it:varlist} contains {it:O_E V} rather than {it:ES seES}{p_end}


{syntab :Forest plot and/or saved data}
{synopt :{opt effi:cacy}}additionally display odds ratios or risk ratios expressed in terms of vaccine efficacy{p_end}
{synopt :{opt hets:tat(string)}}override default display of I-squared statistic on the forest plot;
display heterogeneity p-value{p_end}
{synopt :{opt rfdist}, {opt rflevel(#)}}display approximate predictive interval, with optional coverage level{p_end}
{synopt :{opt lcol:s(varlist)}, {opt rcol:s(varlist)}}display (and/or save) columns of additional data{p_end}
{synopt :{opt plotid(varname)}}define groups of observations in which to apply specific plot rendition options{p_end}
{synopt :{opt summaryonly}}show only summary estimates (diamonds) in the forest plot and on screen{p_end}
{synopt :{cmdab:sa:ving(}{it:saving_option}{cmd:)}}save data in the form of a "forestplot results set" to {it:filename}{p_end}
{synopt :{opt nowarn:ing}}suppress the default display of a note warning that studies are weighted from random effects anaylses{p_end}

{synopt :{opt co:unts}}(specific effect measures only) display data counts ({it:n}/{it:N} or {it:N}, {it:mean}, {it:SD}) for treatment and control group{p_end}
{synopt :{opt group1(string)}, {opt group2(string)}}(specific effect measures only) specify title text for the two columns created by {opt counts}{p_end}
{synopt :{opt npts}}(specific effect measures only) display participant numbers in the forest plot{p_end}
{synopt :{opt oev}}(log-rank {it:O-E} and {it:V} only) display columns containing {it:O_E} and {it:V}{p_end}

{synopt	:{cmd:{ul:forest}plot(}{help forestplot##options:{it:forestplot_options}}{cmd:)}}other options as described under {bf:{help forestplot}}{p_end}
{synoptline}

{pstd}
where {it:model} is {it:model_name} [{cmd:,} {it:model_opts}]

{pstd}
and where {it:saving_option} is {it:{help filename}} [{cmd:, replace} {cmdab:stack:label}].


{marker model}{...}
{synopthdr :model_name}
{synoptline}
{pstd}
Note: references for particular models may be found in {help admetan##refs:Fisher 2015}
if not specifically referenced below.{p_end}

{syntab :tau-squared estimators for standard inverse-variance random-effects model}
{synopt :{opt dl}}DerSimonian-Laird estimator (equivalent to specifying {opt re} alone, with no sub-option){p_end}
{synopt :{opt bdl} | {opt dlb}}Bootstrap DerSimonian-Laird estimator{p_end}
{synopt :{opt ca} | {opt he} | {opt vc}}Cochran ANOVA-like estimator aka Hedges aka "variance component" estimator{p_end}
{synopt :{opt eb} | {opt gq} | {opt mp}}Mandel-Paule aka Generalised Q aka "empirical Bayes" estimator{p_end}
{synopt :{opt ml}}Maximum likelihood (ML) estimator{p_end}
{synopt :{opt reml}}Restricted maximum likelihood (REML) estimator{p_end}
{synopt :{opt hm}}Hartung-Makambi estimator ({help admetan##refs:Hartung and Makambi 2003}){p_end}
{synopt :{opt b0} {opt bp}}Rukhin B0 and BP estimators{p_end}
{synopt :{opt sj2s} [{cmd:, init(}{it:model_name}{cmd:)}]}Sidik-Jonkman two-step estimator, with initial estimate of tau-squared using {it:model_name} (default is {opt vc}){p_end}
{synopt :{opt dk2s} [{cmd:, init(vc | dl)}]}DerSimonian-Kacker two-step estimator ({help admetan##refs:DerSimonian and Kacker 2007}),
with initial estimate {opt vc} (default) or {opt dl}{p_end}
{synopt :{opt sa} [{cmd:, isq(}{it:real}{cmd:) tausq(}{it:real}{cmd:)}]}Sensitivity analysis with user-defined I-squared
(taking values between 0 and 100; default is 80%) or tau-squared (>=0){p_end}

{syntab :non-standard models, or modifications to standard model}
{synopt :{opt hk:sj} [{cmd:, {ul:notru}ncate}]}Hartung-Knapp-Sidik-Jonkman variance correction
applied to the standard DerSimonian-Laird model;
optionally {ul:without} truncation of correction factor at 1 ({help admetan##refs:R{c o:}ver et al 2015}){p_end}
{synopt :{opt pl} [{cmd:, {ul:ba}rtlett {ul:sk}ovgaard z}]}Estimation using profile likelihood,
optionally with Bartlett's ({help admetan##refs:Huizenga et al 2011}) or Skovgaard's ({help admetan##refs:Guolo 2012}) correction.
Option {opt z} displays the signed (square-root) log-likelihood statistic compared to a standard normal distribution, instead of the default
log-likelihood statistic compared to a chi-squared distribution.{p_end}
{synopt :{opt kr} [{cmd:, eim oim}]}Kenward-Roger variance correction, 
using expected (default) or observed information matrix to compute degrees of freedom ({help admetan##refs:Morris et al 2018}){p_end}
{synopt :{opt bt}}Biggerstaff-Tweedie approximate Gamma model{p_end}
{synopt :{opt hc}}Henmi-Copas approximate Gamma model ({help admetan##refs:Henmi and Copas 2010}){p_end}
{synopt :{opt ivh:et}}"Inverse-variance heterogeneity" (IVHet) model ({help admetan##refs:Doi et al 2015a}){p_end}
{synopt :{opt mu:lt}}Multiplicative heterogeneity model ({help admetan##refs:Thompson and Sharp 1999}){p_end}
{synoptline}


{marker model_opts}{...}
{synopthdr :model_opts}
{synoptline}
{synopt :{opt hk:sj} [{cmdab:notru:ncate}]}The Hartung-Knapp-Sidik-Jonkman variance correction (see above)
may also be applied to any other standard model involving a tau-squared estimator; e.g. {cmd:re(reml, hksj)}{p_end}
{synopt :{opt qp:rofile}}Request a confidence interval for tau-squared using Q Profile method ({help admetan##refs:Viechtbauer 2007});
note that most {ul:iterative} tau-squared estimators produce their own confidence intervals, which are otherwise reported by default{p_end}
{synopt :{opt ro:bust}}Use the Sidik-Jonkman robust (sandwich-like) variance estimator ({help admetan##refs:Sidik and Jonkman 2006}){p_end}

{syntab :options for iteration, replication or numerical integration}
{synopt :{opt itol(#)}}Tolerance for iteration convergence (with {opt eb}, {opt ml}, {opt reml}, {opt pl}, {opt kr}, {opt bt} or {opt hc}){p_end}
{synopt :{opt maxit:er(#)}}Maximum number of iterations (as above){p_end}
{synopt :{opt maxt:ausq(#)}}Upper bound of search interval; may need to be raised in extreme cases (as above){p_end}
{synopt :{opt quadpts(#)}}Number of quadrature points to use in numerical integration (with {opt bt} or {opt hc}; see {help integrate}){p_end}
{synopt :{opt reps(#)}}Number of replications for Bootstrap DerSimonian-Laird estimator (with {opt bdl}){p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:admetan} performs meta-analysis of aggregate (summary) data, in contrast to {bf:{help ipdmetan}} which performs meta-analysis of individual participant data (IPD).
It has all the functionality of the popular {bf:{help metan}} package, and includes many additional features.
As such, it may be seen as a direct update of {cmd:metan}.
In particular, the syntax of {cmd:admetan} has been deliberately kept similar to that of {cmd:metan}; any differences are noted {help admetan##options:below}.

{pstd}
{it:varlist} must be supplied, and (as with {cmd:metan}) may contain two, three, four or six variables.
As noted in the {help admetan##syntax:Syntax} section, these alternatives are categorised into syntaxes concerned with "generic effect measures"
and "specific effect measures". This is done for two reasons: to clarify certain options which are only permissible with specific effect measures; 
and for consistency with the documentation for {bf:{help ipdmetan}} where there are substantial differences in command syntax.

{pstd}
"Specific effect measures" require a four- or a six-element {it:varlist}.
When four variables are supplied, these correspond to the number of events and non-events in the experimental group followed by those of the control group,
and analysis of binary data is performed on the 2x2 table.
With six variables, the data are assumed continuous and to be the sample size,
mean and standard deviation of the experimental group followed by those of the control group.

{pstd}
"Generic effect measures" require a two- or a three-element {it:varlist}.
If three variables are specified these are assumed to be the effect estimate and its lower and upper confidence interval.
Confidence intervals are assumed to be symmetric, and the standard error is derived as (CI width)/2z.
Hence, supplied confidence limits must be based on a Normal distribution, or the pooled result will not be accurate.
Finally, if two variables are specified, by default these are assumed to be the effect estimate and standard error.
However, for time-to-event data, the observed minus expected number of control-arm events ({it:O}-{it:E}) and variance ({it:V}) may instead be supplied.
In this case, the {opt logrank} option must also be supplied in order for {cmd:admetan} to interpret {it:varlist} correctly.

{pstd}
Most {cmd:admetan} {help admetan##options:options} are also applicable to {cmd:ipdmetan}.
However, some options are only applicable to the "specific effect measure" syntax (Syntax 2) of {cmd:ipdmetan}
in which the IPD is directly {bf:{help collapse}}d into aggregate data.
Conversely, {cmd:ipdmetan} has options which are only applicable to "generic effect measures" (Syntax 1) and which are not applicable at all with {cmd:admetan}.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:study(}{it:study_ID} [{cmd:, missing}]{cmd:)} specifies the variable containing the study identifier,
which must be either integer-valued or string.
Alternatively, the {cmd:metan} syntax {bf:label(}[{bf:namevar=}{it:namevar}]{bf:,} [{bf:yearvar=}{it:yearvar}]{bf:)} may be used.
If none of these are supplied, studies will simply be labelled sequentially as "1", "2", etc.
In the absence of {ifin}, the entire dataset in memory will be included
except observations for which {it:varlist} is entirely {help missing:system missing}.

{pmore}
{opt missing} requests that missing values be treated as potential study identifiers; the default is to exclude them.

{phang}
{cmd:by(}{it:subgroup_ID} [{cmd:, missing}]{cmd:)} specifies a variable identifying subgroups of studies (and must therefore be constant within studies),
which must be either integer-valued or string.

{pmore}
{opt missing} requests that missing values be treated as potential subgroup identifiers; the default is to exclude them.

{phang}
{opt citype(string)} specifies how confidence limits are constructed for individual studies.
Note that confidence limits for {ul:pooled} results are calculated separately:
either consistently with the specified {help admetan##model:{it:model}},
or using the Normal (by default) or {it:t} (see the {bf:t} option) distributions.

{phang2}
{cmd:citype(normal)} or {cmd:citype(z)} is the default, specifying use of the Normal distribution (i.e. a {it:z}-statistic)

{phang2}
{cmd:citype(t)} specifies use of the ("Student's") {it:t} distribution.
Degrees of freedom may be specified using the {opt df(varname)} option;
otherwise {cmd:admetan} will assume degrees of freedom of {it:n-2} where {it:n} is the study sample size.

{phang2}
{cmd:citype(logit)} recreates the logit-transformed confidence limits outputted by default (as of {help whatsnew12to13:Stata 13}) by {bf:{help proportion}}.

{phang}
{opt cumulative} requests that the meta-analysis be performed cumulatively; that is, performed repeatedly with one study being added each time, in the order specified by {cmd:sortby()}.
Pooled effect information (tests of {it:z} = 0, heterogeneity etc.) will be based on the model following the addition of the final study.

{phang}
{opt influence} requests that each study in turn is removed from the meta-analysis to investigate its influence on the overall result.
Pooled effect information remains identical to that if {opt influence} were not specified.

{pmore}
Note that for both {opt cumulative} and {opt influence}, use of random-effects and variance-correction models
may result in weights greater than 100%, since weights are expressed relative to the total weight in the model with all studies included.

{phang2}
{opt altwt} does not alter the effect estimates, but presents the original weights (and participant numbers in the forest plot, if applicable)
corresponding to each individual study, rather than the relative weights of each fitted {opt cumulative} or {opt influence} model.
In other words, presented weights are as if {opt cumulative} or {opt influence} were not specified.

{phang}
{it:{help eform_option}} specifies that effect sizes and confidence limits should be exponentiated in the table and forest plot.
The option also generates a heading for the effect size column.

{phang}
{opt coef} or {opt log} are synonyms, and report results on the log scale (valid for ratio statistics only, that is OR, RR, HR etc).
If both {it:eform_option} and {opt log} are supplied, {opt log} takes priority.

{phang}
{opt effect(string)} specifies a heading for the effect size column in the output.
This overrides any heading generated by {it:{help eform_option}}.

{phang}
{opt keepall}, {opt keeporder} request that all values of {it:study_ID} should be visible in the table and forest plot,
even if no effect could be estimated (e.g. due to insufficient observations or missing data).
For such studies, "(Insufficient data)" will appear in place of effect estimates and weights.

{pmore}
{opt keeporder} requests such studies are displayed in their "natural" sort order.
By default, such studies are moved to the end.

{phang}
{cmd:model(}{help admetan##model:{it:model_name}} [{cmd:,} {help admetan##model:{it:model_opts}}]{cmd:)}
specifies a model for meta-analytic pooling other than the standard DerSimonian-Laird random-effects model.

{pmore}
This includes a range of alternative estimators for the between-study heterogeneity (tau-squared),
but also models which correct the variance of the pooled estimate, or use alternative weighting systems, or something else.
Such models are often proposed to improve statistical performance under conditions such as a limited number of studies,
or the suspected presence of publication bias.

{pmore}
See also the {opt qe(varname)} option.

{phang}
{opt nograph}, {opt notable} request the suppression of, respectively,
construction of the forest plot and the table of effect sizes.
Additionally, the forest plot option {opt summaryonly} has a similar effect to {opt notable} on the printed output.

{phang}
{opt nohet} suppresses heterogeneity statistics in both table and forest plot.

{phang}
{opt nokeepvars}, {opt norsample} specify that {help admetan##saved_results:new variables}
should {ul:not} be added to the dataset upon conclusion of the routine.

{pmore}
{opt nokeepvars} suppresses the addition of effect statistics such as {bf:_ES}, {bf:_seES} and {bf:_NN} but retains {bf:_rsample}.
Effect statistics are instead returned in the matrix {cmd:r(coeffs)} (see {help ipdmetan##saved_results:{bf:ipdmetan}}).

{pmore}
{opt norsample} further suppresses the addition of the variable {bf:_rsample},
an analogue of {help f_e:e(sample)} which identifies which observations were included in the analysis.
Therefore, {opt norsample} requests that the data in memory not be changed {ul:in any way}
upon conclusion of the routine.

{phang}
{opt nooverall}, {opt nosubgroup} affect which groups of data are pooled, thus affecting both the table of effect sizes
and the forest plot (if applicable).

{pmore}
{opt nooverall} suppresses the overall pooled effect, so that (for instance) subgroups are considered entirely
independently. Between-subgroup heterogeneity statistics are also suppressed.

{pmore}
{opt nosubgroup} suppresses the within-subgroup pooled effects, so that subgroups are displayed
separately but with a single overall pooled effect with associated heterogeneity statistics.

{phang}
{opt npts(varname)} specifies a variable containing numbers of participants in each study, for display in tables and forest plots.

{phang}
{opt ovwt}, {opt sgwt} override the default choice of whether to display overall weights or within-subgroup weights
in the screen output and forest plot. Note that this makes no difference to calculations of pooled effect estimates,
as weights are normalised anyway.

{phang}
{opt qe(varname)} specifies a variable, containing quality scores for each study, 
with which to run the Quality Effects model ({help admetan##refs:Doi et al 2015b}).

{phang}
{opt re} | {opt random} specify the standard DerSimonian and Laird random-effects model;
see also {cmd:model(}{help admetan##model:{it:model_name}}{cmd:)}

{phang}
{opt t} requests that a ("Student's") {it:t} distribution with {it:k-1} degrees of freedom be used to calculate confidence intervals
for pooled results, where {it:k} is the number of studies. Intervals will be at least as wide as using a Normal distribution.
Note that certain random-effects and variance-correction models (e.g. Hartung-Knapp-Sidik-Jonkman) use a {it:t} distribution by default.

{pmore}
See also the {opt citype()} option, which requests alternative confidence intervals for individual studies
but {ul:not} the pooled result.

{phang}
{opt sortby(varname)} allows user-specified ordering of studies in the table and forest plot,
without altering the data in memory.

{phang}
{opt wgt(varname)} specifies user-defined weighting for any data type. You should only use this option if you are satisfied that the weights are meaningful.

{pmore}
Regardless of whether a fixed- or random-effects model is specified, pooled effects are calculated as:

{pmore2}
{it:theta} = {bf:sum(}{it:w_i y_i}{bf:)} / {bf:sum(}{it:w_i}{bf:)}

{pmore}
For a fixed-effect model, pooled effect variances are calculated as:

{pmore2}
{bf:Var(}{it:theta}{bf:)} = {bf:sum(}{it:w_i^2} {it:v_i}{bf:)} / {bf:sum(}{it:w_i}{bf:)}^2

{pmore}
and for a random-effects model:

{pmore2}
{bf:Var(}{it:theta}{bf:)} = {bf:sum(}{it:w_i^2} ({it:v_i} + {it:tau}^2){bf:)} / {bf:sum(}{it:w_i}{bf:)}^2

{pmore}
where {it:v_i} are the individual study variances and {it:w_i} are the user-defined weights.

{pmore}
Note that the scale of user-defined weights is immaterial, since individual weights are normalised.
Hence, once run, an analysis may be recreated using the option {cmd:wgt(_WT)}. This also applies to datasets created using {opt saving()}.
(If the raw numbers stored in {it:varname} are important, they may be saved and displayed using the forest plot options {bf:lcols()} or {bf:rcols()}.)


{dlgtab:Specific effect measures only}

{pstd}
For cell counts from 2x2 contingency tables (that is, a four-element {it:varlist}),
the default outcome is a Risk Ratio (Relative Risk), pooled using the Mantel-Haenszel method
with the associated Mantel-Haenszel heterogeneity statistic.
For sample sizes, means and SDs (that is, a six-element {it:varlist}),
the default outcome is a Standardised Mean Difference (SMD) pooled using the method of Cohen.
The following options act with respect to these defaults, over-riding them if appropriate.

{phang}
{opt breslow} requests the Breslow-Day test for homogeneity of Odds Ratios ({help admetan##refs:Breslow and Day 1980}).

{phang}
{cmd:cc(}[{cmd:#}] [{cmd:,} {it:cc_options}]{cmd:)} controls continuity correction in the case where studies contain zero cells.

{pmore}
By default (unless using Peto odds ratios) {cmd:admetan} adds 0.5 to each cell of a trial where a zero is encountered
to enable finite variance estimators to be derived.
However, the {opt cc(#)} option allows the use of other constants (including none). See also the {opt nointeger} option.

{pmore2}
{opt nocc} is synonymous with {bf:cc(0)}, and suppresses continuity correction.
Studies containing zero cells are likely to be excluded from the analysis.

{pmore}
{help admetan##refs:Sweeting (2004)} discusses the issue of continuity correction, and suggested two alternative approaches.
In both cases a constant of proportionality is required, which defaults to 0.5 but may be chosen by the user:

{pmore2}
{cmd:cc(}[{cmd:#}]{cmd:, {ul:opp}osite)} uses the reciprocal of the opposite group arm size as the correction term.

{pmore2}
{cmd:cc(}[{cmd:#}]{cmd:, {ul:emp}irical)} uses an empirical estimate for the correction term, derived from the remaining studies.
This approach requires that at least one study does {ul:not} contain zero cells.

{phang}
{opt chi2} displays the chi-squared statistic (instead of z) for the test of significance of the pooled effect size.
This is available only for odds ratios pooled using Peto or Mantel-Haenszel methods.

{phang}
{opt cochranq} requests that Cochran's Q heterogeneity statistic be reported.

{phang}
{opt cornfield} computes confidence intervals for odds ratios by method of Cornfield, rather than the (default) Woolf method
(see help for {bf:{help cc}}; not to be confused with {cmd:admetan}'s {cmd:cc()} option!).

{phang}
{opt nointeger} allows cell counts or sample sizes to be non-integers.
This may be useful when a variable continuity correction is sought for studies containing zero cells;
but may also be used in other circumstances, such as where a cluster-randomised trial is to be incorporated
and the "effective sample size" is less than the total number of observations.

{phang}
{opt iv} requests that pooled analysis is done using the inverse-variance method.

{phang}
{opt peto} requests that pooling of Odds Ratios is done using the method of Peto.

{phang}
{opt cohen}, {opt hedges}, {opt glass} pool standardised mean differences by the methods of Cohen (default),
Hedges and Glass respectively ({help admetan##refs:Deeks, Altman and Bradburn 2001}).
Only appropriate with continuous data; that is, a six-element {it:varlist}.

{phang}
{opt md}, {opt wmd}, {opt nostandard} are synonyms, and pool unstandardised ("weighted") mean differences.
Only appropriate with continuous data; that is, a six-element {it:varlist}.

{phang}
{opt logrank} specifies that a two-element {it:varlist} supplied to {cmd:admetan} contains the statistics {it:O-E} and {it:V}
rather than the default {it:ES} and {it:seES}. See also the {opt oev} option.


{marker fplotopts}{...}
{dlgtab:Forest plot and/or saved data}

{phang}
{opt efficacy} expresses results as the vaccine efficacy (the proportion of cases that would have been prevented
in the placebo group that would have been prevented had they received the vaccination).
Only available with odds ratios (OR) or risk ratios (RR).

{phang}
{opt hetstat(string)} alters the default heterogeneity information displayed on the forest plot. {it:string} can be either, or both, of:

{pmore}
{opt p:value} requests that the p-value associated with the relevant heterogeneity test be displayed.

{pmore}
{opt q} (inverse-variance models only) or {opt isq} (other models only) changes the heterogeneity statistic that appears on the forest plot.
For inverse-variance models, the default is I-squared which can optionally be changed to Cochran's Q statistic.
Otherwise, the default is the Cochran, Mantel-Haenszel or Peto Q statistic (as appropriate), from which I-squared can optionally be derived
as ({it:Q} - {it:Qdf})/{it:Q}.

{phang}
{opt rfdist} displays the confidence interval of the approximate predictive distribution of a future trial, based on the extent of heterogeneity.
This incorporates uncertainty in the location and spread of the random effects distribution
using the formula {bf:t(df) * sqrt(se2 + tau2)} where {bf:t} is the t-distribution with {it:k}-2 degrees of freedom,
{bf:se2} is the squared standard error and {bf:tau2} the heterogeneity statistic.
The CI is then displayed with lines extending from the diamond.
Note that with <3 studies the distribution is inestimable and thus not displayed (this behaviour differs from that in {bf:{help metan}})
and where heterogeneity is zero there is still a slight extension as the t-statistic is always greater than the corresponding normal deviate.
For further information see {help admetan##refs:Higgins and Thompson (2009)}.

{pmore}
{opt rflevel(#)} specifies the coverage (e.g. 95 percent) for the confidence interval of the predictive distribution.
Default is {help creturn##output:c_level}.  See {help set level}.

{phang}
{opt lcols(varlist)}, {opt rcols(varlist)} define columns of additional data to the left or right of the graph.
By default, the first two columns on the right contain the effect size and weight. If {opt counts} is used this will be set as the third column.
Columns are labelled with the variable label, or the variable name if this is not defined.

{pmore}
Note: for compatibility with {bf:{help metan}}, the first variable specified in {opt lcols()} is assumed to be the study identifier
if one is not otherwise specified with {opt study()} or {opt label()}.

{phang}
{opt summaryonly} shows only summary estimates in the graph.
This may be of use for multiple subgroup analyses; see also {opt stacklabel}.

{phang}
{cmd:saving(}{it:{help filename}} [{cmd:, replace} {cmd:stacklabel}]{cmd:)} saves the forestplot "results set" created by
{cmd:ipdmetan} in a Stata data file for further use or manipulation; see {help admetan##saved_datasets:saved datasets}.

{pmore}
{opt replace} overwrites {it:filename}

{pmore}
{opt stacklabel} takes the {help label:variable label} of the left-most column variable (usually {it:study_ID}),
which would usually appear outside the plot region as the column heading, and instead stores it in the first observation of {bf:_LABELS}.
This allows multiple such datasets to be {bf:{help append}}ed without this information being lost.

{phang}
{opt counts} (specific effect measures only) displays data counts (n/N) for each group when using binary data;
or the sample size, mean and SD for each group if mean differences are used.

{pmore}
{opt group1(string)}, {opt group2(string)} are for use with the {opt counts} option, and contain names for the two groups.
If these are not supplied, the default names "Treatment" and "Control" are used.

{phang}
{opt npts} (specific effect measures only) displays participant numbers in a column to the left of the graph.
(Note that for generic effect measures, participant numbers need instead to be supplied using the {opt npts(varname)} option.)

{phang}
{opt oev} (only appropriate with {opt logrank}) displays the statistics {it:O-E} and {it:V} in columns to the right of the graph.


{marker saved_results}{...}
{title:Saved results}

{pstd}
By default, {cmd:admetan} adds new variables to the dataset corresponding to the individual study effect sizes,
standard errors, confidence intervals and weights used by the program.
Amongst other things, this provides a method of obtaining effect sizes and standard errors from other data structures such as 2x2 cell counts.
These new variables may be suppressed using the {opt nokeepvars} or {opt norsample} options.

{pstd}
(Note that, if {opt cumulative} or {opt influence}, these variables will still contain 
individual study characteristics, which will therefore {ul:not} agree with the results table shown on-screen,
except for the first iteration of a {opt cumulative} analysis.)

{pstd}
The following new variables may be added:

{p2col 7 32 36 2:{bf:_ES}}Effect size (ES) on the interval scale (e.g. log odds ratio){p_end}
{p2col 7 32 36 2:{bf:_seES}}Standard error of ES{p_end}
{p2col 7 32 36 2:{bf:_LCI}}Lower confidence limit for ES{p_end}
{p2col 7 32 36 2:{bf:_UCI}}Upper confidence limit for ES{p_end}
{p2col 7 32 36 2:{bf:_WT}}Study percentage weight (between 0 and 100){p_end}
{p2col 7 32 36 2:{bf:_NN}}Study sample size{p_end}
{p2col 7 32 36 2:{bf:_rsample}}Marker of which observations were used in the analysis{p_end}


{pstd}{cmd:admetan} also saves the following in {cmd:r()}:{p_end}
{pstd}(with some variation, and in addition to any scalars saved by {bf:{help forestplot}}){p_end}

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(k)}}Number of included studies {it:k}{p_end}
{synopt:{cmd:r(n)}}Number of included participants{p_end}
{synopt:{cmd:r(eff)}}Overall pooled effect size{p_end}
{synopt:{cmd:r(se_eff)}}Standard error of overall pooled effect size{p_end}
{synopt:{cmd:r(Q)}}Q statistic of heterogeneity (with degrees of freedom {it:k-1}){p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(citype)}}Method of constructing study-level confidence intervals{p_end}
{synopt:{cmd:r(method)}}Method of constructing study-level effect estimates{p_end}
{synopt:{cmd:r(model)}}Pooling method used (e.g. Mantel-Haenszel, fixed-effect, DerSimonian-Laird){p_end}
{synopt:{cmd:r(measure)}}Name of effect measure{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(ovstats)}}Matrix of overall effects, test statistics, heterogeneity statistics, p-values etc.{p_end}
{synopt:{cmd:r(bystats)}}Matrix of effects, heterogeneity statistics etc. by subgroup{p_end}


{pstd}
The following results may also be saved, depending on the combination of effect measure and model:

{p2col 5 20 24 2: Scalars (specific effect measures only)}{p_end}
{synopt:{cmd:r(OR)}, {cmd:r(RR)}}Mantel-Haenszel estimates of Odds Ratio or Risk Ratio (if appropriate){p_end}
{synopt:{cmd:r(chi2)}}Chi-squared test statistic (if requested){p_end}
{synopt:{cmd:r(OE)}, {cmd:r(V)}}Overall pooled {it:OE} and {it:V} statistics (if appropriate){p_end}
{synopt:{cmd:r(cger)}, {cmd:r(tger)}}Average event rate in control and treatment groups{p_end}

{p2col 5 20 24 2: Scalars (inverse-variance models only)}{p_end}
{synopt:{cmd:r(tausq)}}Between-study variance tau-squared{p_end}
{synopt:{cmd:r(sigmasq)}}Average within-study variance{p_end}
{synopt:{cmd:r(Isq)}}Heterogeneity measure I-squared{p_end}
{synopt:{cmd:r(HsqM)}}Heterogeneity measure H-squared (Mittlb{c o:}ck modification){p_end}
{synopt:{cmd:r(Qr)}}"Generalised" Q, i.e. Cochran's Q calculated using random-effects weights and pooled estimate{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars (iterative random-effects models only; see {help mf_mm_root} for interpretations of convergence success values)}{p_end}
{synopt:{cmd:r(tsq_var)}}Estimated variance of tau-squared{p_end}
{synopt:{cmd:r(tsq_lci)}}Lower confidence limit for tau-squared{p_end}
{synopt:{cmd:r(tsq_uci)}}Upper confidence limit for tau-squared{p_end}
{synopt:{cmd:r(rc_tausq)}}Whether tau-squared point estimate converged successfully{p_end}
{synopt:{cmd:r(rc_tsq_lci)}}Whether tau-squared lower confidence limit converged successfully{p_end}
{synopt:{cmd:r(rc_tsq_uci)}}Whether tau-squared upper confidence limit converged successfully{p_end}
{synopt:{cmd:r(rc_eff_lci)}}Whether effect estimate lower confidence limit converged successfully{p_end}
{synopt:{cmd:r(rc_eff_uci)}}Whether effect estimate upper confidence limit converged successfully{p_end}


{marker saved_datasets}{...}
{title:Saved datasets}

{pstd}
In order to construct a forest plot, {cmd:admetan} manipulates the data originally in memory into a format that {cmd:forestplot} understands.
This "forestplot results set" can be saved in a Stata data file using the {opt saving()} option, allowing the user to further manipulate it and
hence create highly customised forest plots.

{pstd}
The structure of these "results sets" is such that each row of data will appear in the plot, in the same order (top to bottom).
Variable labels will appear above columns of data within the {help region_options:plot region}; value labels and formats (including string justification)
are honoured where possible. See {bf:{help forestplot}} for further details of how such data is interpreted, and for additional options.

{pstd}
Variables specified in {opt lcols()} or {opt rcols()} will have their variable names, labels and formats preserved within "results sets".
Otherwise, variables are given standardised names, as follows:

{p2col 5 20 24 2: Core variables}{p_end}
{synopt:{cmd:_USE}}Indicates the type of content in each observation (e.g. study effect, pooled effect); see {bf:{help forestplot}}{p_end}
{synopt:{cmd:_STUDY}}Value-labelled numeric variable identifying the studies{p_end}
{synopt:{cmd:_LABELS}}String containing general information to be displayed on the left-hand side of the forestplot, including study names{p_end}
{synopt:{cmd:_ES}}Effect size (ES) on the interval scale (see {help admetan##saved_results:saved results}){p_end}
{synopt:{cmd:_seES}}Standard error of ES (see {help admetan##saved_results:saved results}){p_end}
{synopt:{cmd:_LCI}}Lower confidence limit for ES (see {help admetan##saved_results:saved results}){p_end}
{synopt:{cmd:_UCI}}Upper confidence limit for ES (see {help admetan##saved_results:saved results}){p_end}
{synopt:{cmd:_NN}}Study sample size (see {help admetan##saved_results:saved results}){p_end}
{synopt:{cmd:_WT}}Study percentage weight (see {help admetan##saved_results:saved results}){p_end}
{synopt:{cmd:_EFFECT}}String containing the effect size and confidence limits together, on the display scale (i.e. exponentiated if specified){p_end}

{p2col 5 20 24 2: Option-dependent variables}{p_end}
{synopt:{cmd:_BY}}Value-labelled numeric variable identifying study subgroups (see {opt by()} option){p_end}
{synopt:{cmd:_CC}}Marker of whether continuity correction was applied (see {opt cc} option){p_end}
{synopt:{cmd:_counts1}}String containing "events/total" numbers in the research arm (see {opt counts} option){p_end}
{synopt:{cmd:_counts0}}String containing "events/total" numbers in the control arm (see {opt counts} option){p_end}
{synopt:{cmd:_counts1msd}}String containing "mean (SD)" in the research arm (see {opt counts} option){p_end}
{synopt:{cmd:_counts0msd}}String containing "mean (SD)" in the control arm (see {opt counts} option){p_end}
{synopt:{cmd:_OE}}Logrank {it:O-E} (see {opt logrank} option){p_end}
{synopt:{cmd:_V}}Logrank {it:V} (see {opt logrank} option){p_end}
{synopt:{cmd:_VE}}String containing vaccine efficacy and confidence limits (see {opt efficacy} option){p_end}
{synopt:{cmd:_rfLCI}}Lower confidence limit of approximate predictive distribution (see {opt rfdist} option){p_end}
{synopt:{cmd:_rfUCI}}Upper confidence limit of approximate predictive distribution (see {opt rfdist} option){p_end}

{pstd}
Some of these variables have associated characteristics; type {bf:{help char:char list}} to see these.


{marker diffs_metan}{...}
{title:Note: Differences from {bf:{help metan}}}

{p}
This version of {cmd:admetan} has been designed so that most syntaxes and options valid with {bf:{help metan}} will also work with {cmd:admetan}.
However, there are some exceptions.  In particular, with {cmd:admetan}:

{phang}
Options {opt first()}, {opt firststats()}, {opt second()}, {opt secondstats()} and {opt nosecsub} are not currently implemented (as of {cmd:admetan} v3.0);
the results of these options may instead be recreated using the {opt saving()} option and manipulating the saved dataset

{phang}
Similarly, the forest plot option {opt double} is not currently implemented.

{phang}
Most options specific to the forest plot (i.e. those that do not affect the results appearing in the Results Window)
need to be placed within the {opt forestplot()} option rather than directly to {cmd:admetan}. This includes {opt nostats} and {opt nowt}.

{phang}
{opt nooverall} does not automatically enforce {opt nowt}

{phang}
Prediction intervals ({opt rfdist}) are not displayed with dotted lines if the number of studies is less than three;
instead, the interval is simply not displayed at all. A message is printed in the Results Window explaining this.

{phang}
If {opt wgt()} is supplied, the displayed Q statistic will still be based on the inverse-variance fixed-effect model.
{cmd:metan} here uses a statistic based on fixed-effect weights but the newly-weighted pooled effect size, which is just confusing.
Instead, {cmd:admetan} returns the "generalised Q" based on the new weights (scaled by the pooled variance), and the newly-weighted pooled effect size,
in {bf:r(Qr)}; whilst {bf:r(Q)} contains the standard Cochran Q based on inverse-variance weights (i.e. ignoring {opt wgt()} in its calculation).
Note that the fixed-effect Q statistic is also displayed when a random-effects model is specified, so this behaviour is entirely consistent.


{marker examples}{...}
{title:Examples}

{pstd}
All examples are taken directly from {bf:{help metan}}, and use a simulated example dataset (Ross Harris 2006)

{pmore}
{stata "use http://fmwww.bc.edu/repec/bocode/m/metan_example_data, clear":. use http://fmwww.bc.edu/repec/bocode/m/metan_example_data, clear}


{pstd}
Risk difference from raw cell counts, random effects model, "label" specification with counts displayed
(demonstrating a direct port of {cmd:metan} syntax to {cmd:admetan} with no changes)

{cmd}{...}
{* example_start - admetan_ex1}{...}
{pmore}
. admetan tdeath tnodeath cdeath cnodeath,{* ///}{p_end}
{p 16 20 2}
rd random label(namevar=id, yearvar=year) counts{p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run admetan_ex1 using admetan.sthlp, restpres:click to run})}{p_end}


{pstd}
Sort by year, use data columns syntax with all column data left-justified. Specify percentage of graph as text;
 suppress stats, weight, heterogeneity stats and table.

{cmd}{...}
{* example_start - admetan_ex2}{...}
{phang2}
. admetan tdeath tnodeath cdeath cnodeath, notable{* ///}{p_end}
{p 16 20 2}
sortby(year) lcols(id year country) rcols(population){* ///}{p_end}
{p 16 20 2}
forestplot(astext(60) nostats nowt nohet leftjustify){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run admetan_ex2 using admetan.sthlp, restpres:click to run})}{p_end}


{pstd}
Analyse continuous data (six-parameter syntax), stratify by type of study, with weights summing to 100% within sub group,
display random-effects predictive distribution, show raw data counts, display "favours treatment vs. favours control" labels

{cmd}{...}
{* example_start - admetan_ex3}{...}
{phang2}
. admetan tsample tmean tsd csample cmean csd,{* ///}{p_end}
{p 16 20 2}
study(id) by(type_study) sgwt random rfdist counts{* ///}{p_end}
{p 16 20 2}
forestplot(favours(Treatment reduces blood pressure # Treatment increases blood pressure)){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run admetan_ex3 using admetan.sthlp, restpres:click to run})}{p_end}


{pstd}
Use {cmd:admetan} to generate log odds ratio and standard error from the raw cell counts,
then analyse with two-parameter syntax. Graph has exponential form,
scale is forced within set limits and ticks added, effect label specified.

{cmd}{...}
{* example_start - admetan_ex4}{...}
{phang2}
. admetan tdeath tnodeath cdeath cnodeath, or nograph nooverall notable{p_end}
{phang2}
. rename _ES logor{p_end}
{phang2}
. rename _seES selogor{p_end}
{phang2}
. admetan logor selogor, or {* ///}{p_end}
{p 16 20 2}
forestplot(xlabel(0.5 1 1.5 2 2.5, force) xtick(0.75 1.25 1.75 2.25)){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run admetan_ex4 using admetan.sthlp, restpres:click to run})}{p_end}


{pstd}
Display diagnostic test data with three-parameter syntax. Weight is number of positive diagnoses, axis label set
and null specified at 50%. Overall effect estimate is not displayed, graph for visual examination only.

{cmd}{...}
{* example_start - admetan_ex5}{...}
{phang2}
. admetan percent lowerci upperci, wgt(n_positives) study(id) nooverall notable {* ///}{p_end}
{p 16 20 2}
forestplot( xlabel(0(10)100, force) null(50) title(Sensitivity, position(6)) ){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run admetan_ex5 using admetan.sthlp, restpres:click to run})}{p_end}


{pstd}
User has analysed data with a non-standard technique. User-defined weights are supplied,
and the "results set" is saved and loaded (see {help admetan##saved_datasets:saved datasets}).
User-defined effect estimates are then substituted for those generated by {cmd:admetan},
before finally generating the forest plot.

{pstd}
(Note that this example could be run in one line using {bf:{help metan}},
but {cmd:admetan} allows for a far greater flexibility in the look of the final forest plot
for only a little additional work.)

{cmd}{...}
{* example_start - admetan_ex6}{...}
{phang2}
. tempfile myfile{p_end}
{phang2}
. admetan OR ORlci ORuci, wgt(bweight) study(id) nogr saving(`myfile'){p_end}
{phang2}
. preserve{p_end}
{phang2}
. use `myfile', clear{p_end}
{phang2}
. replace _ES  = 0.924 if _USE == 5{p_end}
{phang2}
. replace _LCI = 0.753 if _USE == 5{p_end}
{phang2}
. replace _UCI = 1.095 if _USE == 5{p_end}
{phang2}
. replace _LABELS = "Bayesian Overall (param V=3.86, p=0.012)" if _USE == 5{p_end}
{phang2}
. forestplot, xlabel(0.25 0.5 1 2 4, force) null(1) aspect(1.2) scheme(economist){p_end}
{phang2}
. restore{p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run admetan_ex6 using admetan.sthlp, restpres:click to run})}{p_end}


{pstd}
Variable "counts" defined showing raw data. Options to change the box, effect estimate marker and confidence interval are used,
and the counts variable has been attached to the estimate marker as a label.

{cmd}{...}
{* example_start - admetan_ex7}{...}
{phang2}
. gen counts = ". " + string(tdeath) + "/" + string(tdeath+tnodeath){* ///}{p_end}
{p 16 20 2}
+ ", " + string(cdeath) + "/" + string(cdeath+cnodeath){p_end}
{phang2}
. admetan tdeath tnodeath cdeath cnodeath, lcols(id year) notable{* ///}{p_end}
{p 16 20 2}
forestplot(range(.3 3) boxopt( mcolor(forest_green) msymbol(triangle)){* ///}{p_end}
{p 16 20 2}
pointopt( msymbol(triangle) mcolor(gold) msize(tiny){* ///}{...}
mlabel(counts) mlabsize(vsmall) mlabcolor(forest_green) mlabposition(1)){* ///}{p_end}
{p 16 20 2}
ciopt( lcolor(sienna) lwidth(medium))){p_end}
{* example_end}{...}
{txt}{...}
{pmore}
{it:({stata admetan_hlp_run admetan_ex7 using admetan.sthlp, restpres:click to run})}{p_end}



{title:Author}

{pstd}
David Fisher, MRC Clinical Trials Unit at UCL, London, UK.

{pstd}
Email {browse "mailto:d.fisher@ucl.ac.uk":d.fisher@ucl.ac.uk}



{title:Acknowledgments}

{pstd}
Many thanks to the authors of {bf:{help metan}}, upon which this code is based;
particularly Ross Harris for his comments and good wishes.

{pstd}
The "click to run" element of the examples in this document is handled using an idea originally developed by Robert Picard.



{marker refs}{...}
{title:References}

{phang}
Breslow NE, Day NE. 1980. Statistical Methods in Cancer Research: Vol. I - The Analysis of Case-Control Studies.
Lyon: International Agency for Research on Cancer.

{phang}
Deeks JJ, Altman DG, Bradburn MJ. 2001.
Statistical methods for examining heterogeneity and combining results from several studies in meta-analysis.
In Systematic Reviews in Health Care: Meta-analysis in Context, ed. Egger M, Davey Smith G, Altman DG, 2nd ed., 285-312. London: BMJ Books.

{phang}
DerSimonian R, Kacker R. 2007.
Random-effects model for meta-analysis of clinical trials: An update.
Contemporary Clinical Trials 28: 105-114. doi: 10.1016/j.cct.2006.04.004

{phang}
Doi SAR, Barendregt JJ, Khan S, Thalib L, Williams GM. 2015a.
Advances in the meta-analysis of heterogeneous clinical trials I: The inverse variance heterogeneity model.
Contemporary Clinical Trials 45: 130-138

{phang}
Doi SAR, Barendregt JJ, Khan S, Thalib L, Williams GM. 2015b.
Advances in the meta-analysis of heterogeneous clinical trials II: The quality effects model.
Contemporary Clinical Trials 45: 123-129

{phang}
Fisher DJ. 2015.
Two-stage individual participant data meta-analysis and generalized forest plots.
Stata Journal 15: 369-396

{phang}
Guolo A. 2012.
Higher-order likelihood inference in meta-analysis and meta-regression.
Statistics in Medicine 31: 313-327. doi: 10.1002/sim.4451

{phang}
Hartung J, Makambi KH. 2003.
Reducing the number of unjustified significant results in meta-analysis.
Communications in Statistics - Simulation and Computation 32: 1179-1190. doi: 10.1081/SAC-120023884

{phang}
Henmi M, Copas JB. 2010.
Confidence intervals for random effects meta-analysis and robustness to publication bias.
Statistics in Medicine 29: 2969-2983. doi: 10.1002/sim.4029

{phang}
Higgins JPT, Thompson SG, Spiegelhalter DJ. 2009.
A re-evaluation of random-effects meta-analysis.
JRSS Series A 172: 137-159

{phang}
Huizenga HM, Visser I, Dolan CV. 2011.
Testing overall and moderator effects in random effects meta-regression.
British Journal of Mathematical and Statistical Psychology 64: 1-19

{phang}
Morris TP, Fisher DJ, Kenward MG, Carpenter JR. 2018.
Meta-analysis of quantitative individual patient data: two stage or not two stage?
Statistics in Medicine. doi: 10.1002/sim.7589

{phang}
R{c o:}ver C, Knapp G, Friede T. 2015.
Hartung-Knapp-Sidik-Jonkman approach and its modification for random-effects meta-analysis with few studies.
BMC Medical Research Methodology 15: 99-105

{phang}
Sidik K, Jonkman JN. 2006.
Robust variance estimation for random effects meta-analysis.
Computational Statistics & Data Analysis 50: 3681-3701. doi: 10.1016/j.csda.2005.07.019

{phang}
Sweeting MJ, Sutton AJ, Lambert PC. 2004.
What to add to nothing? Use and avoidance of continuity corrections in meta-analysis of sparse data.
Statistics in Medicine 23: 1351-1375. doi: 10.1002/sim.1761

{phang}
Thompson SG, Sharp SJ. 1999.
Explaining heterogeneity in meta-analysis: a comparison of methods.
Statistics in Medicine 18: 2693-2708

{phang}
Viechtbauer W. 2007.
Confidence intervals for the amount of heterogeneity in meta-analysis.
Statistics in Medicine 26: 37-52. doi: 10.1002/sim.2514
