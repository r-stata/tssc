{smcl}
{* 9Feb2007}{...}
{hline}
help for {hi:metan}, {hi:labbe}
{hline}


{title:Fixed and random effects meta-analysis}

{p 8 12 2}
{cmd:metan}
{it:varlist}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{it:weight}]
[{cmd:,}
{it:measure_and_model_options}
{it:options_for_continuous_data}
{it:output_options}
{it:forest_plot_options}
]

{p 12 12 2}
where {it:measure_and_model_options} may be

{p 12 12 2}
{cmd:or}
{cmd:rr}
{cmd:rd}
{cmd:fixed}
{cmd:random}
{cmd:fixedi}
{cmd:peto}
{cmd:cornfield}
{cmd:chi2}
{cmd:breslow}
{cmdab:noint:eger}
{cmd:cc(}{it:#}{cmd:)}
{cmd:wgt(}{it:weightvar}{cmd:)}
{cmd:second(}{it:model} or {it:estimates and description}{cmd:)}
{cmd:first(}{it:estimates and description}{cmd:)}

{p 12 12 2}
and where {it:options_for_continuous_data} may be

{p 12 12 2}
{cmd:cohen}
{cmd:hedges}
{cmd:glass}
{cmd:nostandard}
{cmd:fixed}
{cmd:random}

{p 12 12 2}
and where {it:output_options} may be

{p 12 12 2}
{cmd:by(}{it:byvar}{cmd:)}
{cmd:nosubgroup}
{cmd:sgweight}
{cmd:log}
{cmd:eform}
{cmd:efficacy}
{cmdab:il:evel(}{it:#}{cmd:)}
{cmdab:ol:evel(}{it:#}{cmd:)}
{cmd:sortby(}{it:varlist}{cmd:)}
{cmd:label(}{it:namevar yearvar}{cmd:)}
{cmd:nokeep}
{cmd:notable}
{cmd:nograph}
{cmd:nosecsub}

{p 12 12 2}
and where {it:forest_plot_options} may be

{p 12 12 2}
{cmd:legend(}{it:string}{cmd:)}
{cmdab:xla:bel(}{it:#},...{cmd:)}
{cmdab:xt:ick(}{it:#},...{cmd:)}
{cmd:boxsca(}{it:#}{cmd:)}
{cmd:nobox}
{cmd:nooverall}
{cmd:nowt}
{cmd:nostats}
{cmd:group1(}{it:string}{cmd:)}
{cmd:group2(}{it:string}{cmd:)}
{cmd:effect(}{it:string}{cmd:)}
{cmd:force}

{p 12 12 2}
...with further {it:forest_plot_options} in the version 9 update 

{p 12 12 2}
{cmd:lcols(}{it:varlist}{cmd:)}
{cmd:rcols(}{it:varlist}{cmd:)}
{cmd:astext(}{it:#}{cmd:)}
{cmd:double}
{cmd:nohet}
{cmd:summaryonly}
{cmd:rfdist}
{cmdab:rfl:evel(}{it:#}{cmd:)}
{cmd:null(}{it:#}{cmd:)}
{cmd:nulloff}
{cmd:favours(}{it:string} # {it:string}{cmd:)}
{cmd:firststats(}{it:string}{cmd:)}
{cmd:secondstats(}{it:string}{cmd:)}
{cmd:boxopt(}{it:}{cmd:)}
{cmd:diamopt(}{it:}{cmd:)}
{cmd:pointopt(}{it:}{cmd:)}
{cmd:ciopt(}{it:}{cmd:)}
{cmd:olineopt(}{it:}{cmd:)}
{cmd:classic}
{cmd:nowarning}
{it:graph_options}


{p 8 12 2}
{cmd:labbe}
{it:varlist}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{it:weight}]
[{cmd:,}
{cmd:nowt}
{cmdab:per:cent}
{cmd:or(}{it:#}{cmd:)}
{cmd:rr(}{it:#}{cmd:)}
{cmd:rd(}{it:#}{cmd:)}
{cmd:null}
{cmd:logit}
{cmd:wgt(}{it:weightvar}{cmd:)}
{cmd:symbol(}{it:symbolstyle}{cmd:)}
{cmd:nolegend}
{cmd:id(}{it:idvar}{cmd:)}
{cmd:textsize(}{it:#}{cmd:)} 
{cmd:clockvar(}{it:clockvar}{cmd:)}
{cmd:gap(}{it:#}{cmd:)}
{it:graph_options}


{title:Description}

{p 4 4 2}
These routines provide facilities to conduct meta-analyses of data from
more than one study and to graph the results. Either binary (event) or
continuous data from two groups may be combined using the {cmd:metan}
command. Additionally, intervention effect estimates with corresponding
standard errors or confidence intervals may be meta-analysed. Several
meta-analytic methods are available, and the results may be displayed
graphically in a Forest plot. A test of whether
the summary effect measure is equal to the null is given,
as well as a test for heterogeneity, i.e., whether the true effect in all
studies is the same. Heterogeneity is also quantified using the I-squared
measure (Higgins et al 2003).

{p 4 4 2}
{cmd:metan} (the main meta-analysis routine) requires either two, three, four 
or six variables to be declared. When four variables are specified
these correspond to the number of events and non-events in the experimental group
followed by those of the control group, and
analysis of binary data is performed on the 2x2 table.
With six variables, the data are assumed
continuous and to be the sample size, mean and standard deviation of
the experimental group followed by those of the control group.
If three variables are specified these are assumed to be the effect estimate and
its lower and upper confidence interval, and it is suggested that these are
log transformed for odds ratios or risk ratios and the {cmd: eform} option used.
If two variables are specified these are assumed to be the effect estimate and standard
error; again, it is recommended that odds ratios or risk ratios are log transformed.

{p 4 4 2}
{cmd:labbe} draws a L'Abbe plot for event data (proportion of successes in the 
two groups). This is an alternative to the graph produced by {cmd:metan8}.

{p 4 4 2}
Note that the {cmd:metan} command now requires
Stata version 9 and has been updated 
with several new options. Changes are mainly to graphics options which
are collected in the section {it: Further options in the v9 update for metan: Forest plot},
or otherwise marked {it:v9 update}. The previous version is still available under
the name -metan7-


{title:Remarks on funnel (discontinued)}

{p 4 4 2}
The {cmd:metafunnel} command has more options for
funnel plots and version 8 graphics; as such {cmd:funnel} has been removed.
See {help metafunnel} (if installed)



{title:Options for metan}

{dlgtab:Specifying the measure and model}

{p 4 4 2}
These options apply to binary data.

{p 4 8 2}
{cmd:rr} pools risk ratios (the default).

{p 4 8 2}
{cmd:or} pools odds ratios.

{p 4 8 2}
{cmd:rd} pools risk differences.

{p 4 8 2}
{cmd:fixed} specifies a fixed effect model using the method of 
    Mantel and Haenszel (the default).

{p 4 8 2}
{cmd:fixedi} specifies a fixed effect model using the inverse variance method.

{p 4 8 2}
{cmd:peto} specifies that Peto's method is used to pool odds ratios.

{p 4 8 2}
{cmd:random} specifies a random effects model using the method of 
    DerSimonian & Laird, with the estimate of heterogeneity being taken from the
    from the Mantel-Haenszel model.

{p 4 8 2}
{cmd:randomi} specifies a random effects model using the method of 
    DerSimonian & Laird, with the estimate of heterogeneity being taken from the
    inverse-variance fixed-effect model.

{p 4 8 2}
{cmd:cornfield} computes confidence intervals for odds ratios by method of 
    Cornfield, rather than the (default) Woolf method.

{p 4 8 2}
{cmd:chi2} displays chi-squared statistic (instead of z) for the test 
    of significance of the pooled effect size. This is available only for 
    odds ratios pooled using Peto or Mantel-Haenszel methods.

{p 4 8 2}
{cmd:breslow} produces Breslow-Day test for homogeneity of ORs.

{p 4 8 2}
{cmd:cc(}{it:#}{cmd:)} defines a fixed continuity correction to add in the case where 
    a study contains a zero cell. By default, {cmd:metan8}
    adds 0.5 to each cell of a trial where a zero is encountered when
    using Inverse-Variance, Der-Simonian & Laird or Mantel-Haenszel
    weighting to enable finite variance estimators to be derived.
    However, the {cmd:cc()} option allows the use of other constants
    (including none). See also the {cmd:nointeger} option.

{p 4 8 2}
{cmd:nointeger} allows the cell counts to be non-integers. This may be useful
    when a variable continuity correction is sought for studies containing 
    zero cells, but also may be used in other circumstances, such as where a 
    cluster-randomised trial is to be incorporated and the "effective sample 
    size" is less than the total number of observations.

{p 4 8 2}
{cmd:wgt(}{it:weightvar}{cmd:)} specifies alternative weighting
    for any data type. The effect size is to be computed by assigning 
    a weight of {it:weightvar} to the studies. When RRs or ORs are declared,
    their logarithms are weighted. You should only use this option if you are
    satisfied that the weights are meaningful. 

{p 4 8 2}
{cmd:second(}{it:model} or {it:estimates and description}{cmd:)} ({it:v9 update})
    A second analysis may be performed using another method, using {cmd:fixed},
    {cmd:random} or {cmd:peto}.  Alternatively, the user may define their own
    estimate and 95% CI based on calculations performed externally to {cmd:metan}, 
    along with a description of their method, in the format 
    {it: es lci uci description}. The results of this analysis are then displayed
    in the table and forest plot. Note that if {cmd:by} is used then sub-estimates
    from the second method are not displayed with user defined estimates, for 
    obvious reasons.

{p 4 8 2}
{cmd:first(}{it:estimates and description}{cmd:)} ({it:v9 update})
    Use of this command completely changes the way {cmd:metan} operates, as results
    are no longer based on any standard methods. The user defines their own
    estimate, 95% CI and description as in the above, and must supply their own
    weightings using {cmd:wgt(}{it:weightvar}{cmd:)} to control display of box sizes. Note
    that data must be supplied in the 2 or 3 variable syntax
    ({it:theta se_theta} or {it:es lci uci}) and
    {cmd:by} may not be used used for obvious reasons.

{dlgtab:Continuous data}

{p 4 8 2}
{cmd:cohen} pools standardised mean differences by the method of Cohen 
    (the default).

{p 4 8 2}
{cmd:hedges} pools standardised mean differences by the method of Hedges.

{p 4 8 2}
{cmd:glass} pools standardised mean differences by the method of Glass.

{p 4 8 2}
{cmd:nostandard} pools unstandardised mean differences.

{p 4 8 2}
{cmd:fixed} specifies a fixed effect model using the inverse variance method
    (the default).

{p 4 8 2}
{cmd:random} specifies a random effects model using the DerSimonian & Laird 
    method.

{p 4 8 2}
{cmd:nointeger} denotes that the number of observations in each arm does not 
    need to be an integer. By default, the first and fourth variables specified 
    (containing N_intervention and N_control respectively) may occasionally be 
    non-integer (see entry for {cmd:nointeger} under binary data).

{dlgtab:Output}

{p 4 8 2}
{cmd:by()} specifies that the meta-analysis is to be stratified
    according to the variable declared.

{p 4 8 2}
{cmd:sgweight} specifies that the display is to present the percentage
    weights within each subgroup separately. By default {cmd:metan} presents
    weights as a percentage of the overall total.

{p 4 8 2}
{cmd:log} reports the results on the log scale 
    (valid for OR and RR analyses from raw data counts only).

{p 4 8 2}
{cmd:nosubgroup} indicates that no within-group results are to be 
    presented.  By default {cmd:metan} pools trials both within and across 
    all studies.

{p 4 8 2}
{cmd:eform} exponentiates all effect sizes and confidence intervals  
    (valid only when the input variables are log odds ratios or log
    hazard ratios with standard error or confidence intervals).

{p 4 8 2}
{cmd:efficacy} expresses results as the vaccine efficacy (the proportion 
    of cases that would have been prevented in the placebo group that 
    would have been prevented had they received the vaccination). 
    Only available with odds ratios (OR) or risk ratios (RR).

{p 4 8 2}
{cmd:ilevel(}{it:#}{cmd:)} specifies the coverage (eg 90,95,99 percent) for the 
    individual trial confidence intervals. Default: {cmd:$S_level}.
    {cmd:ilevel()} and {cmd:olevel()} need not be the same. See {help set level}.

{p 4 8 2}
{cmd:olevel(}{it:#}{cmd:)} specifies the coverage (eg 90,95,99 percent) for the 
    overall (pooled) trial confidence intervals. Default: {cmd:$S_level}.
    {cmd:ilevel()} and {cmd:olevel()} need not be the same. See {help set level}.

{p 4 8 2}
{cmd:sortby(}{it:varlist}{cmd:)} sorts by variable(s) in {it:varlist}

{p 4 8 2}
{cmd:label([namevar=}{it:namevar}{cmd:], [yearvar=}{it:yearvar}{cmd:])}
    labels the data by its name, year or both. Either or both option/s 
    may be left blank. For the table display the overall length of the
    label is restricted to 20 characters. The option {cmd:lcols()} will
    override this if invoked.

{p 4 8 2}
{cmd:nokeep} prevents the retention of study parameters in permanent 
    variables (see saved results below).

{p 4 8 2}
{cmd:notable} prevents display of table of results.

{p 4 8 2}
{cmd:nograph} prevents display of graph.

{p 4 8 2}
{cmd:nosecsub} ({it:v9 update}) prevents the display of sub-estimates
    using the second method if {cmd:second()}
    is used. Note that this is invoked automatically with user-defined
    estimates.

{dlgtab:Forest plot}

{p 4 8 2}
{cmd:effect()} may be used when the effect size and its standard error 
    are declared. This allows the graph to name the summary statistic used.

{p 4 8 2}
{cmd:nooverall} revents display of overall effect size on graph 
    (automatically enforces the {cmd:nowt} option).

{p 4 8 2}
{cmd:nowt} prevents display of study weight on the graph.

{p 4 8 2}
{cmd:nostats} prevents display of study statistics on graph.

{p 4 8 2}
{cmd:counts} ({it:v9 update}) displays data counts (n/N) for each group when using
    binary data, or the sample size, mean and SD for each group if mean
    differences are used (the latter is a new feature).

{p 4 8 2}
{cmd:group1(}{it:string}{cmd:)}, {cmd:group2(}{it:string}{cmd:)} may be
    used with the {cmd:counts} option: the text should contain the
    names of the two groups.

{p 4 8 2}
{cmd:xlabel()} ({it:v9 update}) defines x-axis labels. This has been modified
    so that any number of points may defined. Also, there are no
    longer any checks made as to whether these points are sensible, so the
    user may define anything if the {cmd:force} option is used. Points must
    be comma separated.

{p 4 8 2}
{cmd:xtick()} adds tick marks to the x-axis. Points must
    be comma separated.

{p 4 8 2}
{cmd:force} forces the x-axis scale to be in the range specified
    by {cmd:xlabel()}.

{p 4 8 2}
{cmd:boxsca()} ({it:v9 update}) controls box scaling. 
    This has been modified slightly so that the default is 100 (as in a 
    percentage) and may be increased or decreased as such (e.g., 80 or 120 for
    20% smaller or larger respectively)

{p 4 8 2}
{cmd:nobox} prevents a "weighted box" being drawn for each study
    and markers for point estimates only are shown.

{p 4 8 2}
{cmd:texts()} ({it:v9 update}) specifies font size for text display on graph. 
    This has been modified slightly so that the default is 100 (as in a 
    percentage) and may be increased or decreased as such (e.g., 80 or 120 for
    20% smaller or larger respectively)

{dlgtab:Further options for the forest plot in the v9 update}

{p 4 8 2}
{cmd:lcols(}{it:varlist}{cmd:)}, {cmd:rcols(}{it:varlist}{cmd:)} 
    define columns of additional data to 
    the left or right of the graph. The first two columns on the right are 
    automatically set to effect size and weight, unless suppressed using 
    the options {cmd:nostats} and {cmd:nowt}. If {cmd:counts} is used this
    will be set as the third column. {cmd:textsize()} can be used to fine-tune 
    the size of the text in order to acheive a satisfactory appearance. 
    The columns are labelled with the variable label, or the variable name 
    if this is not defined. The first variable specified in {cmd:lcols()} is assumed to be
    the study identifier and this is used in the table output.

{p 4 8 2}
{cmd:astext(}{it:#}{cmd:)}
    specifies the percentage of the graph to be taken up by text.
    The default is 50 and the percentage must be in the range 10-90.

{p 4 8 2}
{cmd:double}
    allows variables specified in {cmd:lcols} and {cmd:rcols} to run over two
    lines in the plot. This may be of use if long strings are to be used.

{p 4 8 2}
{cmd:nohet}
    prevents display of heterogeneity statistics in the graph.

{p 4 8 2}
{cmd:summaryonly}
    shows only summary estimates in the graph (may be of use for multiple
    subgroup analyses)

{p 4 8 2}
{cmd:rfdist}
    displays the confidence interval of the approximate predictive
    distribution of a future trial, based on the extent of heterogeneity.
    This incorporates uncertainty in the location and spread of the random
    effects distribution using the formula {cmd: t(df) x sqrt(se2 + tau2)}
    where t is the t-distribution with k-2 degrees of freedom, se2 is the
    squared standard error and tau2 the heterogeneity statistic.
    The CI is then displayed with lines extending from the diamond. Note that
    with <3 studies the distribution is inestimable and effectively infinite, thus
    displayed with dotted lines, and where heterogeneity is zero there is still
    a slight extension as the t-statistic is always greater than the corresponding
    normal deviate. For further information see Higgins JPT, Thompson SG (2006)

{p 4 8 2}
{cmd:rflevel(}{it:#}{cmd:)} specifies the coverage (eg 90,95,99 percent) for the 
    confidence interval of the predictive distribution. Default: {cmd:$S_level}.
    See {help set level}.

{p 4 8 2}
{cmd:null(}{it:#}{cmd:)}
    displays the null line at a user-defined value rather than 0 or 1. 

{p 4 8 2}
{cmd:nulloff}
    removes the null hypothesis line from the graph

{p 4 8 2}
{cmd:favours(}{it:string} # {it:string}{cmd:)}
    applies a label saying something about the treatment effect to either
    side of the graph (strings are separated by the # symbol). This replaces
    the feature available in {cmd:b1title} in the previous version of metan.

{p 4 8 2}
{cmd:firststats(}{it:string}{cmd:)}, {cmd:secondstats(}{it:string}{cmd:)}
    labels overall user-defined estimates when these have been specified.
    Labels are displayed in the position usually given to the heterogeneity
    statistics.

{p 4 8 2}
{cmd:boxopt()}, {cmd:diamopt()}, {cmd:pointopt()}, {cmd:ciopt()}, {cmd:olineopt()}
    specify options for the graph routines within the program, allowing the
    user to alter the appearance of the graph. Any options associated with a
    particular graph command may be used, except some that would cause incorrect
    graph appearance. For example, diamonds are plotted using the {help twoway pcspike}
    command, so options for line styles are available (see {help line options});
    however, altering the x-y
    orientation with the option {cmd:horizontal} or {cmd:vertical} is not
    allowed. So, {cmd:diamopt(lcolor(green) lwidth(thick))} feeds into a command
    such as {cmd:pcspike(y1 x1 y2 x2, lcolor(green) lwidth(thick))}

{p 8 8 2}
{cmd:boxopt()} controls the boxes and uses options for a weighted marker
(e.g., shape, colour; but not size). See {help marker options}

{p 8 8 2}
{cmd:diamopt()} controls the diamonds and uses options for pcspike (not horizontal/vertical).
See {help line options}

{p 8 8 2}
{cmd:pointopt()} controls the point estimate using marker options.
See {help marker options} and {help marker label options}

{p 8 8 2}
{cmd:ciopt()} controls the confidence intervals for studies using options
for pcspike (not horizontal/vertical). See {help line options}

{p 8 8 2}
{cmd:olineopt()} controls the overall effect line with options for an additional 
line (not position). See {help line options}

{p 4 8 2}
{cmd:classic} specifies that solid black boxes without point estimate markers are used as
in the previous version of metan.

{p 4 8 2}
{cmd:nowarning} switches off the default display of a note warning that studies are
weighted from random effects anaylses.

{p 4 8 2}
{it:graph_options}
    specifies overall graph options that would appear at the end of a {cmd:twoway}
    graph command. This allows the addition of titles, subtitles, captions etc.,
    control of margins, plot regions, graph size, aspect ratio and the use of schemes.
    As titles may be added in this way previous options {cmd:b2title} etc. are no
    longer necessary. See {search graph options}


{title:Options for labbe}

{p 4 8 2}
{cmd:nowt} declares that the plotted data points are to be the same size.

{p 4 8 2}
{cmd:percent} displays the event rates as percentages rather than proportions.

{p 4 8 2}
{cmd:null} draws a line corresponding to a null effect (ie p1=p2).

{p 4 8 2}
{cmd:or(}{it:#}{cmd:)} draws a line corresponding to a fixed odds ratio of
    {it:#}.

{p 4 8 2}
{cmd:rd(}{it:#}{cmd:)} draws a line corresponding to a fixed risk difference of
    {it:#}.

{p 4 8 2}
{cmd:rr(}{it:#}{cmd:)} draws a line corresponding to a fixed risk ratio
    of {it:#}. See also the {cmd:rrn()} option.

{p 4 8 2}
{cmd:rrn(}{it:#}{cmd:)} draws a line corresponding to a fixed risk ratio
    (for the non-event) of {it:#}.
    The {cmd:rr()} and {cmd:rrn()} options may require explanation.
    Whereas the OR and RD are invariant to the definition of which of
    the binary outcomes is the "event" and which is the "non-event",
    the RR is not.  That is, while the command {cmd:metan a b c d , or}
    gives the same result as {cmd:metan b a d c , or} (with direction
    changed), an RR analysis does not.  The L'Abbe plot allows the display
    of either or both to be superimposed risk difference.

{p 4 8 2}
{cmd:logit} is for use with the {cmd:or()} option; it displays the
    probabilities on the logit scale ie log(p/1-p). On the logit scale the  
    odds ratio is a linear effect, and so this makes it easier to assess the 
    "fit" of the line. 

{p 4 8 2}
{cmd:wgt(}{it:weightvar}{cmd:)} specifies alternative weighting by the specified variable
(default is sample size).

{p 4 8 2}
{cmd:symbol(}{it:symbolstyle}{cmd:)} allows the symbol to be changed (see help {help symbolstyle}) the
default being hollow circles (or points if weights are not used).

{p 4 8 2}
{cmd:nolegend} suppresses a legend being displayed (the default if more than one
line corresponding to effect measures are specified).

{p 4 8 2}
{cmd:id(}{it:idvar}{cmd:)} displays marker labels with the specified ID variable {it:idvar}.
{cmd:clockvar()} and {cmd:gap()} may be used to fine-tune the display, which may become
unreadable if studies are clustered together in the graph.

{p 4 8 2}
{cmd:textsize(}{it:#}{cmd:)} increases or decreases the text size of the id label by specifying
{it:#} to be more or less than unity. The default is usually satisfactory, but may need to be adjusted.

{p 4 8 2}
{cmd:clockvar(}{it:clockvar}{cmd:)} specifies the position of {it:idvar} around the
study point, as if it were a clock face (values must be integers- see {help clockposstyle}).
This may be used to organise labels where studies are clustered together. By default, labels are positioned
to the left (9 o'clock) if above the null and to the right (3 o'clock) if below. Missing values
in {it:clockvar} will be assigned the default position, so this need not be specified for all observations.

{p 4 8 2}
{cmd:gap(}{it:#}{cmd:)} increases or decreases the gap between the study marker and the id label by specifying
{it:#} to be more or less than unity. The default is usually satisfactory, but may need to be adjusted.

{p 4 8 2}
{it:graph_options} are options for Stata 8 graphs (see help on {help graph}).


{title:Remarks on metan}

{p 4 4 2}
For two or three variables, a variance-weighted analysis is performed in 
a similar fashion to the {help meta} command; the two variable syntax
is {it:theta} and {it:SE(theta)}. The 3 variable syntax is {it:theta},
{it:lower ci (theta)}, {it:upper ci (theta)}. Note that in this situation
"{it:theta}" is taken to be the logarithm of the effect size if the odds
ratio or risk ratio is used. {hi:This differs from the equivalent in the {cmd:meta} command}.
This program does not assume the three variables need log transformation:
if odds ratios or risk ratios are combined, it is up to the user to
log-transform them first. The {cmd:eform} option may be used to change
back to the original scale if needed. By default the confidence
intervals are assumed symmetric, and the studies are pooled by taking
the variance to be equal to (CI width)/2z. 

{p 4 4 2}
Note that for graphs on the log scale (that is, ORs or RRs), values
outside the range [10e-8,10e8] are not displayed, and similarly graphs of
other measures (log ORs, RDs, SMDs) are restricted to the range [-10e8,10e8].
A confidence interval which extends beyond this, or the specified scale
if {cmd:force} is used, will have an arrow added at the end of the range.

{p 4 4 2}
{hi: Further notes on v9 update:} If {cmd:by} is used with a string variable the
stratification variable is not sorted alpha-numerically and the original
order that the groups appear in the data is preserved. This may be of use if
a particular display order is required; if not, {cmd:sortby} may be used.
The option {cmd:counts} is now available for continuous data and displays
sample size, mean and SD in each group. The estimate for heterogeneity between
groups from a stratified analysis using the Mantel-Haenszel method, and
arguably the Peto method, is invalid. Therefore this is not displayed in the
output for either of these methods.


{title:Remarks on labbe}

{p 4 4 2}
By default the size of the plotting symbol is proportional to the sample 
size of the study. If weights are specified the plotting size will be 
proportional to the weight variable. Note that {cmd:labbe} has now been updated to version 8 graphics.
All options work the same as in the previous version, and some minor graphics options have been added.



{title:Stored}

By default, {cmd:metan} adds the following new variables to the data set:

      _ES        Effect size (ES)
      _seES      Standard error of ES 
                 or, when OR or RR are specfied: 
      _selogES   the standard error of its logarithm 
      _LCI       Lower confidence limit for ES
      _UCI       Upper confidence limit for ES
      _WT        Study percentage weight
      _SS        Study sample size


{title:Examples}

{p 4 8 2}
All examples use a simulated example dataset (Ross Harris 2006)

{p 8 12 2}
{stata "use http://fmwww.bc.edu/repec/bocode/m/metan_example_data":. use http://fmwww.bc.edu/repec/bocode/m/metan_example_data}

{p 4 8 2}
Risk difference from raw cell counts, random effects model, "label" specification with counts displayed

{p 8 12 2}
{cmd:. metan tdeath tnodeath cdeath cnodeath, }
{p_end}
{p 12 12 2}
{cmd:rd random label(namevar=id, yearid=year) counts}
{p_end}
{p 12 12 2}
{it:({stata "metan_examples metan_example_basic":click to run})}

{p 4 8 2}
Sort by year, use data columns syntax. Text size increased, specify percentage of graph as text and
two lines per study; suppress stats, weight, heterogeneity stats and table.


{p 8 12 2}
{cmd:. metan tdeath tnodeath cdeath cnodeath, }
{p_end}
{p 12 12 2}
{cmd:sortby(year) lcols(id year country) rcols (population) }
{p_end}
{p 12 12 2}
{cmd:textsize(110) astext(60) double nostats nowt nohet notable}
{p_end}
{p 12 12 2}
{it:({stata "metan_examples metan_example_cols":click to run})}

{p 4 8 2}
Analyse continuous data (6 parameter syntax), stratify by type of study, with weights summing to 100 within sub group,
second analysis specified, display random effects distribution, show raw data counts, display
"favours treatment vs. favours control" labels

{p 8 12 2}
{cmd:. metan tsample tmean tsd csample cmean csd, }
{p_end}
{p 12 12 2}
{cmd:by(type_study) sgweight fixed second(random) rfdist }
{p_end}
{p 12 12 2}
{cmd:counts label(namevar = id) }
{p_end}
{p 12 12 2}
{cmd:favours(Treatment reduces blood pressure # Treatment increases blood pressure)}
{p_end}
{p 12 12 2}
{it:({stata "metan_examples metan_example_by":click to run})}

{p 4 8 2}
Generate log odds ratio and standard error, analyse with 2 parameter syntax. Graph has exponential form,
scale is forced within set limits and ticks added, effect label specified.

{p 8 12 2}
{cmd:. gen logor = ln( (tdeath*cnodeath)/(tnodeath*cdeath) )}

{p 8 12 2}
{cmd:. gen selogor = sqrt( (1/tdeath) + (1/tnodeath) + (1/cdeath) + (1/cnodeath) )}

{p 8 12 2}
{cmd:. metan logor selogor, eform xlabel(0.5, 1, 1.5, 2, 2.5) }
{p_end}
{p 12 12 2}
{cmd:force xtick(0.75, 1.25, 1.75, 2.25) effect(Odds ratio)}
{p_end}
{p 12 12 2}
{it:({stata "metan_examples metan_example_2param":click to run})}

{p 4 8 2}
Display diagnostic test data with 3 parameter syntax. Weight is number of positive diagnoses, axis label set
and null specified at 50%. Overall effect estimate is not displayed, graph for visual examination only.

{p 8 12 2}
{cmd:. metan percent lowerci upperci, wgt(n_positives) }
{p_end}
{p 12 12 2}
{cmd:xlabel(0,10,20,30,40,50,60,70,80,90,100) force }
{p_end}
{p 12 12 2}
{cmd:null(50) label(namevar=id) nooverall notable }
{p_end}
{p 12 12 2}
{cmd:title(Sensitivity, position(6))}
{p_end}
{p 12 12 2}
{it:({stata "metan_examples metan_example_diag":click to run})}

{p 4 8 2}
User has analysed data with a non-standard technique and supplied effect estimates, weights and description of statistics.
The scheme "Economist" has been used.

{p 8 12 2}
{cmd:. metan OR ORlci ORuci, wgt(bweight) }
{p_end}
{p 12 12 2}
{cmd:first(0.924 0.753 1.095  Bayesian) }
{p_end}
{p 12 12 2}
{cmd:firststats(param V=3.86, p=0.012) }
{p_end}
{p 12 12 2}
{cmd:label(namevar=id) }
{p_end}
{p 12 12 2}
{cmd:xlabel(0.25, 0.5, 1, 2, 4) force }
{p_end}
{p 12 12 2}
{cmd:null(1) aspect(1.2) scheme(economist)}
{p_end}
{p 12 12 2}
{it:({stata "metan_examples metan_example_user":click to run})}

{p 4 8 2}
Variable "counts" defined showing raw data. Options to change the box, effect estimate marker and confidence interval used,
and the counts variable has been attached to the estimate marker as a label.

{p 8 12 2}
{cmd:. gen counts = ". " + string(tdeath) + "/" + string(tdeath+tnodeath) }
{p_end}
{p 12 12 2}
{cmd:+ ", " + string(cdeath) + "/" + string(cdeath+cnodeath)}

{p 8 12 2}
{cmd: . metan tdeath tnodeath cdeath cnodeath, }
{p_end}
{p 12 12 2}
{cmd:lcols(id year) notable }
{p_end}
{p 12 12 2}
{cmd:boxopt( mcolor(forest_green) msymbol(triangle) ) }
{p_end}
{p 12 12 2}
{cmd:pointopt( msymbol(triangle) mcolor(gold) msize(tiny) }
{p_end}
{p 12 12 2}
{cmd:mlabel(counts) mlabsize(vsmall) mlabcolor(forest_green) mlabposition(1) ) }
{p_end}
{p 12 12 2}
{cmd:ciopt( lcolor(sienna) lwidth(medium) )}
{p_end}
{p 12 12 2}
{it:({stata "metan_examples metan_example_custom":click to run})}

{p 4 8 2}
L'Abbe plot with labelled axes and display of risk ratio and risk difference.

{p 8 12 2}
{cmd:. labbe tdeath tnodeath cdeath cnodeath, }
{p_end}
{p 12 12 2}
{cmd:xlabel(0,0.25,0.5,0.75,1) ylabel(0,0.25,0.5,0.75,1) }
{p_end}
{p 12 12 2}
{cmd:rr(1.029) rd(0.014) null}
{p_end}
{p 12 12 2}
{it:({stata "metan_examples labbe_example":click to run})}



{title:Authors}

{p 4 4 0}
Michael J Bradburn, Jonathan J Deeks, Douglas G Altman.
Centre for Statistics in Medicine, University of Oxford,
Wolfson College Annexe, Linton Road, Oxford, OX2 6UD, UK

{title:Version 9 update}

{p 4 4 0}
Ross J Harris ({browse "mailto:rossharris1978@yahoo.co.uk":rossharris1978@yahoo.co.uk}), Roger M Harbord, Jonathan A C Sterne.
Department of Social Medicine, University of Bristol,
Canynge Hall, Whiteladies Road, Bristol BS8 2PR, UK

{title:Other updates and improvements to code and help file}

{p 4 4 0}
Patrick Royston. MRC Clinical Trials Unit, 222 Euston Road,
London, NW1 2DA

{title:Acknowledgements}

{p 4 4 0}
Thanks to Vince Wiggins, Kit Baum and Jeff Pitblado of Statacorp
who offered advice and helped facilitate the version 9 update.
Thanks also to all the people who helped with beta-testing and
made comments and suggested improvements.

{title:References}

{p 4 4 0}
Higgins JPT, Thompson SG, Deeks JJ,
Altman DG.  Measuring inconsistency in meta-analyses.  BMJ
2003; 327:557-560. {browse "http://dx.doi.org/10.1136/bmj.327.7414.557":http://dx.doi.org/10.1136/bmj.327.7414.557}

{p 4 4 0}
Higgins JPT, Thompson SG (2006) Presenting random effects meta-analyses:
where we are going wrong? (from presentation, work in preparation)


{title:Also see}

    STB: STB-44 sbe24
On-line: help for {help metan7}, {help metannt}
         {help meta} (if installed), {help metacum} (if installed),
         {help metareg} (if installed), {help metabias} (if installed), 
         {help metatrim} (if installed), {help metainf} (if installed), 
         {help galbr} (if installed), {help metafunnel} (if installed)

