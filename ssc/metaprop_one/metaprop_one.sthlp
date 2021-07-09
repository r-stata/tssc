{smcl}

{* 27-10-2014}

{hline}
{cmd:help metaprop_one (version 1.2)}
{hline}


{title:Fixed- and random-effects meta-analysis of proportions}

{p 8 12 2}
{cmd:metaprop_one}
{varlist}
{ifin}
{weight}
[{cmd:,}
{it:measure_and_model_options}
{it:output_options}
{it:forest_plot_options}
]

{p 12 12 2}
where {it:measure_and_model_options} may be

{p 12 12 2}
{cmd: logit}
{cmd: ftt}
{cmd:cimethod(}{it:string}{cmd:)}
{cmd:fixed}
{cmd:random}
{cmd:cc(}{it:#}{cmd:)}
{cmd:wgt(}{it:weightvar}{cmd:)}
{cmd:second(}{it:model} or {it:estimates and description}{cmd:)}
{cmd:first(}{it:estimates and description}{cmd:)}

{p 12 12 2}
and where {it:output_options} may be

{p 12 12 2}
{cmd:dp(#)}
{cmd:power(#)}
{cmd:by(}{it:byvar}{cmd:)}
{cmd:nosubgroup}
{cmd:sgweight}
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
{cmd:force}

{p 12 12 2}
{cmd:lcols(}{it:varlist}{cmd:)}
{cmd:rcols(}{it:varlist}{cmd:)}
{cmd:astext(}{it:#}{cmd:)}
{cmd:double}
{cmd:nohet}
{cmd:summaryonly}
{cmd:rfdist}
{cmdab:rfl:evel(}{it:#}{cmd:)}
{cmd:boxopt(}{it:}{cmd:)}
{cmd:diamopt(}{it:}{cmd:)}
{cmd:pointopt(}{it:}{cmd:)}
{cmd:ciopt(}{it:}{cmd:)}
{cmd:olineopt(}{it:}{cmd:)}
{cmd:classic}
{cmd:nowarning}
{it:graph_options}

{title:Description}

{p 4 4 2}
This routine provides procedures for pooling proportions in a meta-analysis of 
multiple studies study and/or displays the results in a forest plot. The pooled estimate
is obtained as a weighted average, by fitting the Logistic regression model 
without covariate but an intercept, or by fitting the logistic-Normal random-effects 
model without covariates but random intercepts. The confidence 
intervals are based on score(Wilson) (Newcombe, R. G. 1998) or 
exact binomial(Clopper-Pearson) (Newcombe, R. G. 1998) procedures.
A test of whether the summary measure is equal to the zero is given,
as well as a test for heterogeneity, i.e., whether the true proportion in all
studies is the same. Heterogeneity can also quantified using the I-squared
measure (Higgins et al. 2003).

{p 4 4 2}
{cmd:metaprop_one} requires two variables in the format {n, N}; such that p = n/N,
to be declared. 

{p 4 4 2}
Note that the {cmd:metaprop_one} command requires Stata 13.1 or later versions.

{title:Options for metaprop_one}

{dlgtab:Specifying the measure and model}

{p 4 8 2}
{cmd:logit} Specificies that the binomial distribution is used to model the within-study variability (Hamza et al. 2008). Studies 
will less variability have more influence in the pooled estimate since they contribute more to the likelihhod function. The 
weighting is not explicit because parameter estimation is an iterative procedure. Therefore, even though the forest plot displays
equal weights for the individual studies, weighting is indeed done. The logistic regression requires at least two studies to run.

{p 4 8 2}
{cmd:ftt} Calculate the pooled estimate after Freeman-Tukey Double Arcsine 
Transformation (Freeman, M. F. , and Tukey, J. W. 1950) to stabilize the variances. {cmd:ftt} and {cmd:logit} cannot be used together, 
only either needs to be specified.

{p 4 8 2}
{cmd:cimethod} Specifies the method to compute the confidence intervals for the individual studies. By default,
the Score(Wilson) confidence intervals are computed. Available option is "exact". When the {cmd:logit} is enabled,
the confidence intervals for the individual studies are exact.

{p 4 8 2}
{cmd:fixed} specifies a fixed-effect model using the inverse variance method. When {cmd:logit} option is enabled, a
logistic model with intercept is fitted.

{p 4 8 2}
{cmd:random} specifies a random-effects model using the method of 
    DerSimonian and Laird, with the estimate of heterogeneity being taken from
    the inverse-variance fixed-effect model. The method of DerSimonia and Laird requires at least two(2) studies to run
	the model.
	When {cmd:logit} option is enabled, a logistic model with
	random intercept is fitted. The variability of the random intercepts estimates heterogeneity. The logistic model with
	random intercept requires at least 3 studies.


{p 4 8 2}
{cmd:cc(}{it:#}{cmd:)} defines a fixed continuity correction to add in the case where 
    a study has zero success. By default, {cmd:metaprop_one}
    excludes studies with zero success. The {cmd:cc()} option allows the use of
	non-negative constants. This option is not necessary
	when the Freeman-Tukey Double Arcsine transformation is performed.

{p 4 8 2}
{cmd:wgt(}{it:weightvar}{cmd:)} specifies alternative weighting
    for any data type. The pooled estimate size is to be computed by assigning 
    a weight of {it:weightvar} to the studies. You should only use this option if you are
    satisfied that the weights are meaningful. 
	
{p 4 8 2}
{cmd:second({it:model})} 
    A second analysis may be performed using another method, using {cmd:fixed} or
    {cmd:random}. Note that if {cmd:by} is used then sub-estimates
    from the second method are not displayed with user defined estimates.

{dlgtab:Output}

{p 4 8 2}
{cmd:power(#)} indicates the power of ten with which to multiply the estimates. # is any real
value. The default is 0 which reports proportions, power(2) would report proportion*100=percentages.
The x-axis labels should be adjusted accordingly when power(#) is adjusted.

{p 4 8 2}
{cmd:dp(#)} indicates the number of decimal places to display in the table and graph.

{p 4 8 2}
{opt by(byvar)} specifies that the meta-analysis is to be stratified
    according to the variable declared.

{p 4 8 2}
{cmd:sgweight} specifies that the display is to present the percentage
    weights within each subgroup separately. By default {cmd:metaprop_one} presents
    weights as a percentage of the overall total.

{p 4 8 2}
{cmd:nosubgroup} indicates that within-group pooled results are to be ommitted when 
    {cmd:by()} is used. By default {cmd:metaprop_one} presents both within group and overall 
    pooled results.

{p 4 8 2}
{cmd:ilevel(}{it:#}{cmd:)} specifies the confidence interval level (e.g., 90, 95, 99 percent) for the 
    individual study confidence intervals.  The default is {cmd:$S_level}.
    {cmd:ilevel()} and {cmd:olevel()} need not be the same. See {helpb set level}.

{p 4 8 2}
{cmd:olevel(}{it:#}{cmd:)} specifies the confidence interval level (e.g., 90, 95, 99 percent) for the 
    overall (pooled) study confidence intervals. The default is {cmd:$S_level}.
    {cmd:ilevel()} and {cmd:olevel()} need not be the same. See {helpb set level}.

{p 4 8 2}
{cmd:sortby(}{it:varlist}{cmd:)} sorts by variable(s) in {it:varlist}.

{p 4 8 2}
{cmd:label([namevar=}{it:namevar}{cmd:], [yearvar=}{it:yearvar}{cmd:])}
    labels the data by its name, year, or both. Either or both option/s 
    may be left blank. For the table display, the overall length of the
    label is restricted to 20 characters. The {cmd:lcols()} option will
    override this if specified.

{p 4 8 2}
{cmd:nokeep} prevents the retention of study parameters in permanent 
    variables (see saved results below).

{p 4 8 2}
{cmd:notable} prevents display of table of results.

{p 4 8 2}
{cmd:nograph} prevents display of graph.

{p 4 8 2}
{cmd:nosecsub} ({it:v9 update}) prevents the display of subestimates
    using the second method if {cmd:second()}
    is used. Note that this is invoked automatically with user-defined
    estimates.

{dlgtab:Forest plot}

{p 4 8 2}
{cmd:nooverall} prevents display of overall estimate size on graph 
    (automatically enforces the {cmd:nowt} option).

{p 4 8 2}
{cmd:nowt} prevents display of study weight on the graph.

{p 4 8 2}
{cmd:nostats} prevents display of individual study statistics on graph.

{p 4 8 2}
{cmd:xlabel()} defines x-axis labels. No checks are made as to whether these points are sensible. So the
    user may define anything if the {cmd:force} option is used. Points must
    be comma separated.

{p 4 8 2}
{cmd:xtick()} adds tick marks to the x-axis. Points must
    be comma separated.

{p 4 8 2}
{cmd:force} forces the x-axis scale to be in the range specified
    by {cmd:xlabel()}.

{p 4 8 2}
{cmd:boxsca()} controls "weighted box" scaling. 
    The default is 100 (as in a 
    percentage) and may be increased or decreased as such (e.g., 80 or 120 for
    20% smaller or larger respectively).

{p 4 8 2}
{cmd:nobox} prevents a "weighted box" being drawn for each study
    and markers for point estimates only are shown.

{dlgtab:Further options for the forest plot}

{p 4 8 2}
{cmd:lcols(}{it:varlist}{cmd:)}, {cmd:rcols(}{it:varlist}{cmd:)} 
    define columns of additional data to 
    the left or right of the graph. The first two columns on the right are 
    automatically set to the estimate and weight, unless suppressed using 
    the options {cmd:nostats} and {cmd:nowt}. {cmd:texts()} can be used to fine-tune 
    the size of the text in order to achieve a satisfactory appearance. 
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
    subgroup analyses).

{p 4 8 2}
{cmd:rfdist}
    displays the confidence interval of the approximate predictive
    distribution of a future study, based on the extent of heterogeneity in the random-effects model.
    This incorporates uncertainty in the location and spread of the random-
    effects distribution using the formula {cmd: t(df) x sqrt(se2 + tau2)}
    where t is the t-distribution with k-2 degrees of freedom, se2 is the
    squared standard error and tau2 the heterogeneity statistic.
    The CI is then displayed with lines extending from the diamond. Note that
    with <3 studies the distribution is inestimable and effectively infinite, thus
    displayed with dotted lines, and where heterogeneity is zero there is still
    a slight extension as the t-statistic is always greater than the corresponding
    normal deviate. For further information, see Higgins and Thompson (2001).

{p 4 8 2}
{cmd:rflevel(}{it:#}{cmd:)} specifies the level (e.g., 90, 95, 99 percent)
of the confidence interval of the predictive distribution.  The default is
{cmd:$S_level}.  See {helpb set level}.

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
    such as {cmd:pcspike(y1 x1 y2 x2, lcolor(green) lwidth(thick))}.

{p 8 8 2}
{cmd:boxopt()} controls the boxes and uses options for a weighted marker
(e.g., shape, colour, but not size). See {it:{help marker_options}}.

{p 8 8 2}
{cmd:diamopt()} controls the diamonds and uses options for pcspike (not
horizontal/vertical).  See {it:{help line_options}}.

{p 8 8 2}
{cmd:pointopt()} controls the point estimate using marker options.
See {it:{help marker_options}} and {it:{help marker_label_options}}.

{p 8 8 2}
{cmd:ciopt()} controls the confidence intervals for studies using options
for pcspike (not horizontal/vertical). See {it:{help line_options}}.

{p 8 8 2}
{cmd:olineopt()} controls the overall estimate line with options for an
additional line (not position). See {it:{help line_options}}.

{p 4 8 2}
{cmd:classic} specifies that solid black boxes without point estimate markers
are used.

{p 4 8 2}
{cmd:nowarning} switches off the default display of a note warning that studies
are weighted from random-effects anaylses.

{p 4 8 2}
{it:graph_options}
    specifies overall graph options that would appear at the end of a
{cmd:twoway} graph command. This allows the addition of titles, subtitles,
captions, etc., control of margins, plot regions, graph size, aspect ratio, and
the use of schemes. See
{it:{help twoway_options}}.

{p 4 8 2}
{cmd:wgt(}{it:weightvar}{cmd:)} specifies alternative weighting by the
specified variable (default is inverse of the variance).

{p 4 8 2}
{cmd:texts(}{it:#}{cmd:)} increases or decreases the text size of the
label by specifying {it:#} to be more or less than unity. The default is
usually satisfactory but may need to be adjusted.

{title:Stored}

By default, {cmd:metaprop_one} adds the following new variables to the dataset:
	_ES      Estimated proportiop/prevalence (ES).
	_seES    Standard error of ES.
	_LCI     Lower confidence limit for ES.
	_UCI     Upper confidence limit for ES.
	_WT      Study percentage weight.

{title:Examples}

{p 4 8 2}
Pooling proportions from raw cell counts, grouped by triage group,
with "label" specification,  x-axis label set, ticks on x-axis added,
suppressed weights, increased text size, a red diamond for the confidence intervals of the pooled estimate,
a vertical line at zero, a red dashed line,
for the pooled estimate, e.t.c.

{p 4 8 2}
The dataset used in this example has been to produce figure one in
Marc Arbyn et al. (2009).

{p 8 12 2}
{stata "use http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta":. use http://fmwww.bc.edu/repec/bocode/a/arbyn2009jcellmolmedfig1.dta}

{p 8 12 2}
{cmd:. metaprop_one num denom, random by(tgroup) cimethod(exact)}
{p_end}
{p 12 12 2}
{cmd: label(namevar=author, yearvar=year)}
{p_end}
{p 12 12 2}
{cmd: xlab(.25,0.5,.75,1)xline(0, lcolor(black)) }
{p_end}
{p 12 12 2}
{cmd: subti("Atypical cervical cytology", size(4)) }
{p_end}
{p 12 12 2}
{cmd: xtitle("Proportion",size(2)) nowt }
{p_end}
{p 12 12 2}
{cmd: olineopt(lcolor(red)lpattern(shortdash)) }
{p_end}
{p 12 12 2}
{cmd: plotregion(icolor(ltbluishgray)) } 
{p_end}
{p 12 12 2}
{cmd: diamopt(lcolor(red)) }
{p_end}
{p 12 12 2}
{cmd: pointopt(msymbol(x)msize(0))boxopt(msymbol(S) mcolor(black)) } 
{p_end}
{p 12 12 2}
{cmd: astext(70) texts(150)}
{p_end}
{p 12 12 2}
{it:({stata "metaprop_one_examples metaprop_one_example_one":click to run})}


{p 4 8 2}
Pooling proportions from raw cell counts with Freeman-Tukey double arcsine transformation and exact confidence intervals
for the individual studies.

{p 4 8 2}
The dataset used in this example produced the top-left graph in figure one in
Ioanna Tsoumpou et al. (2009).

{p 8 12 2}
{stata "use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta":. use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2WNL.dta}

{p 8 12 2}
{cmd:.	metaprop_one p16p p16tot, random ftt cimethod(exact)}
{p_end}
{p 12 12 2}
{cmd: label(namevar=author, yearvar=year) sortby(year author)}
{p_end}
{p 12 12 2}
{cmd: xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) xline(0, lcolor(black)) }
{p_end}
{p 12 12 2}	
{cmd:  ti(Positivity of p16 immunostaining, size(4) color(blue)) }
{p_end}
{p 12 12 2}
{cmd:  subti("Cytology = WNL", size(4) color(blue)) }
{p_end}
{p 12 12 2}
{cmd:  xtitle(Proportion,size(3)) nowt nostats }
{p_end}
{p 12 12 2}
{cmd:  olineopt(lcolor(red) lpattern(shortdash)) }
{p_end}
{p 12 12 2}
{cmd:  diamopt(lcolor(black)) }
{p_end}
{p 12 12 2}
{cmd:  pointopt(msymbol(x)msize(0)) boxopt(msymbol(S) mcolor(black))  }
{p_end}
{p 12 12 2}
{cmd:  astext(70)  texts(100)}
{p_end}
{p 12 12 2}
{it:({stata "metaprop_one_examples metaprop_one_example_two":click to run})}


{p 4 8 2}
The dataset used in this example produced the top-left graph in figure one in
Ioanna Tsoumpou et al. (2009).

{p 8 12 2}
{stata "use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2HSIL.dta":. use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2HSIL.dta}

{p 8 12 2}
{cmd:.	metaprop_one p16p p16tot, random ftt cimethod(exact)}
{p_end}
{p 12 12 2}
{cmd:  label(namevar=author, yearvar=year) sortby(year author)}
{p_end}
{p 12 12 2}
{cmd:  xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) xline(0, lcolor(black)) }
{p_end}
{p 12 12 2}	
{cmd:  ti(Positivity of p16 immunostaining, size(4) color(blue)) }
{p_end}
{p 12 12 2}
{cmd:  subti("Cytology = HSIL", size(4) color(blue)) }
{p_end}
{p 12 12 2}
{cmd:  xtitle(Proportion,size(3)) nowt nostats }
{p_end}
{p 12 12 2}
{cmd:  olineopt(lcolor(red) lpattern(shortdash)) }
{p_end}
{p 12 12 2}
{cmd:  diamopt(lcolor(black)) }
{p_end}
{p 12 12 2}
{cmd:  pointopt(msymbol(x)msize(0)) boxopt(msymbol(S) mcolor(black))  }
{p_end}
{p 12 12 2}
{cmd:  astext(70)  texts(100)}
{p_end}
{p 12 12 2}
{it:({stata "metaprop_one_examples metaprop_one_example_three":click to run})}


{p 4 8 2}
Pooling proportions using the Logistic-Normal random-effects model and exact confidence intervals
for the individual studies.

{p 4 8 2}
The dataset used in this example produced the top-left graph in figure one in
Ioanna Tsoumpou et al. (2009).

{p 8 12 2}
{stata "use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2HSIL.dta":. use http://fmwww.bc.edu/repec/bocode/t/tsoumpou2009cancertreatrevfig2HSIL.dta}

{p 8 12 2}
{cmd:.	metaprop_one p16p total, random  groupid(study) logit}
{p_end}
{p 12 12 2}
{cmd:  label(namevar=author, yearvar=year) sortby(year author)}
{p_end}
{p 12 12 2}
{cmd:  xlab(0.1,.2, 0.3,0.4,0.5,0.6,.7,0.8, 0.9, 1) xline(0, lcolor(black)) }
{p_end}
{p 12 12 2}	
{cmd:  ti(Positivity of p16 immunostaining, size(4) color(blue)) }
{p_end}
{p 12 12 2}
{cmd:  subti("Cytology = HSIL", size(4) color(blue)) }
{p_end}
{p 12 12 2}
{cmd:  xtitle(Proportion,size(3)) nowt nostats }
{p_end}
{p 12 12 2}
{cmd:  olineopt(lcolor(red) lpattern(shortdash)) }
{p_end}
{p 12 12 2}
{cmd:  diamopt(lcolor(black)) }
{p_end}
{p 12 12 2}
{cmd:  pointopt(msymbol(s)msize(2)) }
{p_end}
{p 12 12 2}
{cmd:  astext(70)  texts(100)}
{p_end}
{p 12 12 2}
{it:({stata "metaprop_one_examples metaprop_one_example_four":click to run})}


{title:Authors}

{p 4 4 2}
Victoria Nyaga, Marc Arbyn. 
Unit of Cancer Epidemiology,
Scientific Institute of Public Health,
Juliette Wytsmanstreet 14, B1050 Brussels,
Belgium.

{p 4 4 2}
Marc Aerts.
Center for Statistics, Hasselt University,
Agoralaan Building D, 3590 Diepenbeek,
Belgium.


{title:Acknowledgements}

{p 4 4 2}
Edited code from metan.ado by Michael J Bradburn, Jonathan J Deeks, Douglas G Altman.
Centre for Statistics in Medicine, University of Oxford,
Wolfson College Annexe, Linton Road, Oxford, OX2 6UD, UK

{title:References}

{phang}
Higgins, J. P. T., S. G. Thompson, J. J. Deeks, and D. G. Altman.
2003.  Measuring inconsistency in meta-analyses.  
{it:British Medical Journal} 327: 557-560.

{phang}
Higgins, J. P. T., and S. G. Thompson.  2001. Presenting random-effects
meta-analyses: Where we are going wrong?  9th International Cochrane
Colloquium, Lyon, France.

{phang}
Miller, J. J. 1978. The inverse of the Freeman-Tukey double arcsine 
transformation. {it:The American Statistician} 32: 138.

{phang}
Freeman, M. F., and Tukey, J. W. 1950. Transformations related to 
the angular and the square root. 
{it: Annals of Mathematical Statistics} 21: 607-611.

{phang}
Newcombe, R. G. 1998. Two-sided confidence intervals for 
the single proportion: comparison of seven methods. 
{it:Statistics in Medicine} 17: 857-872.

{phang}
Arbyn, M., et al. 2009. Triage of women with equivocal
or low-grade cervical cytology results.  A meta-analysis
of the HPV test positivity rate.
{it:Journal for Cellular and Molecular Medicine} 13.4: 648-59.

{phang}
Tsoumpou, I., et al. 2009. p16INK4a immunostaining in 
cytological and histological specimens from the uterine 
cervix: a systematic review and meta-analysis. 
{it:Cancer Treatment Reviews} 35: 210-20.

{phang}
Hamza et al. 2008. The binomial distribution of meta-analysis was preferred to model within-study variability. 
{it:Journal of Clinical Epidemiology} 61: 41-51.



{title:Also see}

{psee}
Online:  {help metan} (if installed), {help metannt}(if installed)
         {help metareg} (if installed), {help metabias} (if installed), 
         {help metatrim} (if installed), {help metainf} (if installed), 
         {help galbr} (if installed), {help metafunnel} (if installed)
		 

