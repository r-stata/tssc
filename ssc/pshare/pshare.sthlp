{smcl}
{* 14jun2018}{...}
{hi:help pshare}
{hline}

{title:Title}

{pstd}{hi:pshare} {hline 2} Compute and graph percentile shares


{title:Syntax}

{pstd}
    Percentile share estimation:

{p 8 15 2}
    {cmd:pshare} [{cmdab:e:stimate}] {varlist} {ifin} {weight}
    [{cmd:,}
    {help pshare##estopt:{it:estimate_options}}
    ]

{pstd}
    Computing contrasts between outcome variables or subgroups:

{p 8 15 2}
    {cmd:pshare} {cmdab:c:ontrast} [{help pshare##contrast:{it:base}}]
    [{cmd:,}
    {help pshare##contopt:{it:contrast_options}}
    ]

{p 8 8 2}
    where {it:base} is the name of the outcome variable or the value of the
    subpopulation to be used as base. {it:base} may also be {cmd:#1}, {cmd:#2},
    or {cmd:#3}, etc. to refer to the 1st, 2nd, or 3rd, etc. outcome variable
    or subpopulation. See the {helpb pshare##contrast:contrast()} option of
    {cmd:pshare estimate} for more details

{pstd}
    Drawing a stacked bar chart of the results:

{p 8 15 2}
    {cmd:pshare} {cmdab:s:tack}
    [{cmd:,}
    {help pshare##stackopt:{it:stack_options}}
    ]

{pstd}
    Drawing a histogram of the results:

{p 8 15 2}
    {cmd:pshare} {cmdab:h:istogram}
    [{cmd:,}
    {help pshare##histopt:{it:histogram_options}}
    ]


{synoptset 22 tabbed}{...}
{marker estopt}{col 5}{help pshare##estoptions:{it:estimate_options}}{col 29}Description
{synoptline}
{syntab :Main}
{synopt :{opt pr:oportion}}report shares as proportions; the default
    {p_end}
{synopt :{opt percent}}report shares as percentages
    {p_end}
{synopt :{opt den:sity}}report shares as densities
    {p_end}
{synopt :{opt sum}}report shares as sums (outcome totals)
    {p_end}
{synopt :{opt ave:rage}}report shares as averages
    {p_end}
{synopt :{opt general:ized}}report generalized shares
    {p_end}
{synopt :{cmdab:norm:alize(}{help pshare##normalize:{it:spec}}{cmd:)}}normalize
    results with respect to the specified total
    {p_end}
{synopt :{opt gini}}also report Gini coefficient(s)
    {p_end}

{syntab :Percentiles}
{synopt :{opt n:quantiles(#)}}use # percentile groups of equal size; default
    is {cmd:nquantiles(5)} (quintiles)
    {p_end}
{synopt :{opth p:ercentiles(numlist)}}use percentile groups corresponding to the
    specified cumulative percentages
    {p_end}
{synopt :{cmd:pvar(}{help varname:{it:pvar}}{cmd:)}}base percentile groups on
    {it:pvar} instead of the outcome variable
    {p_end}
{synopt :{opt step}}determine lorenz ordinates from step function; the default
    is to employ linear interpolation
    {p_end}

{syntab :Over}
{synopt :{opth over(varname)}}compute results for subpopulations defined by
    the values of {it:varname}
    {p_end}
{synopt :{opt t:otal}}include overall results across all subpopulations; only
    allowed with {cmd:over()}
    {p_end}

{syntab :Contrast/Graph}
{synopt :{cmdab:c:ontrast}[{cmd:(}{help pshare##contrast:{it:spec}}{cmd:)}]}compute
    differences in percentile shares between outcome variables or subpopulations
    {p_end}
{synopt :{cmdab:s:tack}[{cmd:(}{help pshare##stackopt:{it:options}}{cmd:)}]}draw
    a stacked bar chart of the results; {it:options} are
    {help pshare##stackopt:{it:stack_options}} as described below
    {p_end}
{synopt :{cmdab:h:istogram}[{cmd:(}{help pshare##histopt:{it:options}}{cmd:)}]}draw
    a histogram of the results; {it:options} are
    {help pshare##histopt:{it:histogram_options}} as described below
    {p_end}

{syntab :SE/SVY}
{synopt :{cmd:vce(}{help pshare##vcetype:{it:vcetype}}{cmd:)}}{it:vcetype} may
    be {cmd:analytic} (the default), {cmdab:cl:uster} {it:clustvar},
    {cmdab:boot:strap} or {cmdab:jack:knife}
    {p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for
    {cmd:vce(cluster} {it:clustvar}{cmd:)}
    {p_end}
{synopt :{cmd:svy}[{cmd:(}{help pshare##svy:{it:subpop}}{cmd:)}]}take account
    of survey design as set by {helpb svyset}, optionally restricting
    computations to {it:subpop}
    {p_end}
{synopt :{opt nose}}supress computation of standard errors and confidence
    intervals
    {p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt nohe:ader}}suppress output header
    {p_end}
{synopt :{opt notab:le}}suppress output table
    {p_end}
{synopt :{opt nogtab:le}}suppress table of Gini coefficients
    {p_end}
{synopt :{help pshare##displayopts:{it:display_options}}}standard
    reporting options as described in
    {helpb estimation options:[R] estimation options}
    {p_end}
{synoptline}
{p 4 6 2}
{opt pweight}s, {opt iweight}s, and {opt fweight}s are allowed; see {help weight}.


{synoptset 22 tabbed}{...}
{marker contopt}{col 5}{help pshare##contoptions:{it:contrast_options}}{col 29}Description
{synoptline}
{synopt :{opt r:atio}}compute ratios instead of differences
    {p_end}
{synopt :{opt lnr:atio}}compute logarithms of ratios instead of differences
    {p_end}
{synopt :{cmdab:s:tack}[{cmd:(}{help pshare##stackopt:{it:options}}{cmd:)}]}draw
    a stacked bar chart of the results; {it:options} are
    {help pshare##stackopt:{it:stack_options}} as described below
    {p_end}
{synopt :{cmdab:h:istogram}[{cmd:(}{help pshare##histopt:{it:options}}{cmd:)}]}draw
    a histogram of the results; {it:options} are
    {help pshare##histopt:{it:histogram_options}} as described below
    {p_end}
{synopt :{help pshare##displayopts:{it:display_options}}}standard
    reporting options as described in
    {helpb estimation options:[R] estimation options}
    {p_end}
{synoptline}


{synoptset 22 tabbed}{...}
{marker stackopt}{col 5}{help pshare##stackoptions:{it:stack_options}}{col 29}Description
{synoptline}
{syntab :Main}
{synopt :{opt vert:ical}}vertical bar plot
    {p_end}
{synopt :{opt hor:izontal}}horizontal bar plot; the default
    {p_end}
{synopt :{opt prop:ortion}}population axis displays proportion, not percent
    {p_end}
{synopt :{opt rev:erse}}order percentile groups from top to bottom, not from
    bottom to top
    {p_end}
{synopt :{cmd:keep(}{help pshare##stackkeep:{it:list}}{cmd:)}}select and order
    outcome variables or subpopulations to be included in the graph
    {p_end}
{synopt :{cmdab:s:ort}[{cmd:(}{help pshare##sortopts:{it:options}}{cmd:)}]}order
    outcome variables or subpopulation by size of top share or as specified by
    {it:options}
    {p_end}
{synopt :{cmdab:g:ini(}{help format:{it:%fmt}}{cmd:)}}specify format for Gini
    coefficients; default format is {cmd:%9.3g}
    {p_end}
{synopt :{opt nog:ini}}omit Gini coefficients
    {p_end}

{syntab :Labels/Rendering}
{synopt :{cmdab:lab:els(}{help pshare##stacklabels:{it:labels}}{cmd:)}}specify
    custom axis labels for outcome variables/subpopulations
    {p_end}
{synopt :{cmdab:plab:els(}{help pshare##plabels:{it:labels}}{cmd:)}}specify
    custom legend labels for percentile groups
    {p_end}
{synopt :{opt barw:idth(#)}}set width of bars; default is {cmd:barwidth(0.75)}
    {p_end}
{synopt :{it:{help barlook_options}}}affect rendition of the plotted bars
    {p_end}
{synopt :{opth p#(barlook_options)}}affect rendition of #th segment of the stacked bars
    {p_end}
{synopt :{cmdab:v:alues}[{cmd:(}{help format:{it:%fmt}}{cmd:)}]}include
    values of percentile shares as marker labels
    {p_end}
{synopt :{it:{help marker_label_options}}}affect rendition of the values included as marker labels
    {p_end}

{syntab :Add plots}
{synopt :{opth "addplot(addplot_option:plot)"}}add other plots to the graph
    {p_end}

{syntab :Y-Axis, X-Axis, Title, Caption, Legend, Overall}
{synopt :{it:{help twoway_options}}}any options other than {cmd:by()}
    documented in {helpb twoway_options:[G] {it:twoway_options}}
    {p_end}
{synoptline}


{synoptset 22 tabbed}{...}
{marker histopt}{col 5}{help pshare##histoptions:{it:histogram_options}}{col 29}Description
{synoptline}
{syntab :Main}
{synopt :{opt vert:ical}}vertical bar plot; the default
    {p_end}
{synopt :{opt hor:izontal}}horizontal bar plot
    {p_end}
{synopt :{opt prop:ortion}}population axis in proportion, not percent
    {p_end}
{synopt :{cmd:keep(}{help pshare##keep:{it:list}}{cmd:)}}select and order
    results to be included as subgraphs
    {p_end}
{synopt :{cmd:max(}{it:#}[, {help pshare##maxmin:{it:options}}]{cmd:)}}truncate
    bars from above
    {p_end}
{synopt :{cmd:min(}{it:#}[, {help pshare##maxmin:{it:options}}]{cmd:)}}truncate
    bars from below
    {p_end}
{synopt :{cmd:prange(}{it:min} {it:max}{cmd:)}}restrict range of percentile
    groups to be included in the graph
    {p_end}
{synopt :{cmdab:g:ini(}{help format:{it:%fmt}}{cmd:)}}specify format for Gini
    coefficients; default format is {cmd:%9.3g}
    {p_end}
{synopt :{opt nog:ini}}omit Gini coefficients from subgraph labels
    {p_end}

{syntab :Labels/Rendering}
{synopt :{it:{help barlook_options}}}affect rendition of the plotted bars
    {p_end}
{synopt :{opt step}}draw results as step function instead of bars
    {p_end}
{synopt :{cmdab:adds:tep}[{cmd:(}{it:{help line_options:line_opts}}{cmd:)}]}draw results as step function in addition to bars
    {p_end}
{synopt :{cmdab:spike:s}[{cmd:(}{it:#}{cmd:)}]}draw a series of spikes instead
    of bars; implies {cmd:noci}
    {p_end}
{synopt :{cmdab:lab:els(}{help pshare##labels:{it:labels}}{cmd:)}}specify
    custom labels for subgraphs
    {p_end}
{synopt :{cmdab:byopt:s(}{help by_option:{it:byopts}}{cmd:)}}specify how
    subgraphs are combined
    {p_end}
{synopt :{opt over:lay}}combine results in single plot instead of using
    subgraphs; implies {cmd:noci}
    {p_end}
{synopt :{cmd:o#(}{help pshare##oopts:{it:options}}{cmd:)}}affect rendition
    of #th plot; for use with {cmd:overlay}
    {p_end}
{synopt :{cmd:psep}[{cmd:(}{help pshare##psep:{it:labels}}{cmd:)}]}use different
    styling for each percentile group
    {p_end}
{synopt :{cmd:p#(}{help pshare##popts:{it:options}}{cmd:)}}affect rendition
    of #th plot; for use with {cmd:psep()}
    {p_end}

{syntab :Confidence intervals}
{synopt :{opt l:evel(#)}}set confidence level; not allowed if {cmd:ci()} is
    {cmd:bc}, {cmd:bca}, or {cmd:percentile}
    {p_end}
{synopt :{cmd:ci(}{help pshare##citype:{it:citype}}{cmd:)}}choose type of
    bootstrap CI; {it:citype} may be {cmdab:nor:mal} (the default), {cmd:bc},
    {cmd:bca}, or {cmdab:p:ercentile}
    {p_end}
{synopt :{cmdab:ciopt:s(}{help pshare##ciopts:{it:options}}{cmd:)}}affect
    rendition of the plotted confidence spikes; see help
    {helpb graph twoway rcap}
    {p_end}
{synopt :{opt cib:elow}}place the confidence interval spikes behind the
    plotted bars
    {p_end}
{synopt :{opt noci}}omit confidence intervals
    {p_end}

{syntab :Add plots}
{synopt :{opth "addplot(addplot_option:plot)"}}add other plots to the graph
    {p_end}

{syntab :Y-Axis, X-Axis, Title, Caption, Legend, Overall}
{synopt :{it:{help twoway_options}}}any options other than {cmd:by()}
    documented in {helpb twoway_options:[G] {it:twoway_options}}
    {p_end}
{synoptline}


{title:Description}

{pstd}
    {cmd:pshare estimate} computes percentile shares or, more generally,
    quantile shares for one or several outcome variables or subpopulations from
    individual level data (grouped data is not supported). Percentile shares
    are often used in inequality research to study the distribution of income
    or wealth. They are defined as differences between Lorenz ordinates of the
    outcome variable. Technically, the observations are sorted in increasing
    order of the outcome variable and the specified percentiles (quintiles by
    default) are computed from the running sum of the outcomes. Percentile
    shares are then computed as differences between percentiles, divided by
    total outcome (for methodological details see {help pshare##jann2016:Jann 2016}).

{pstd}
    Given the results form {cmd:pshare estimate} for several outcome variables
    or subpopulations, {cmd:pshare contrast} computes differences in
    percentile shares between outcome variables or subpopulations.

{pstd}
    {cmd:pshare stack} draws a stacked bar chart of the results from
    {cmd:pshare estimate} or {cmd:pshare contrast}. One stacked bar is drawn
    for each outcome variable or subpopulation.

{pstd}
    {cmd:pshare histogram} plots the results from {cmd:pshare estimate} or
    {cmd:pshare contrast} as a histogram. In case of multiple outcome
    variables or multiple subpopulations, several subgraphs are
    drawn. Confidence intervals are included as capped spikes.

{pstd}
    {cmd:pshare} without arguments replays the previous results. Reporting
    options may be applied.


{marker estoptions}{...}
{title:Options for pshare estimate}

{dlgtab:Main}

{phang}
    {cmd:proportion}, {cmd:percent}, {cmd:density}, {cmd:sum}, {cmd:average},
    and {cmd:generalized} select the type of results to be computed. The
    default is {cmd:proportion}, that is, to report percentile shares as
    proportions. Use option {cmd:percent} to report percentile shares as
    percentages. Furthermore, use option {cmd:density} to report densities,
    defined as outcome shares divided by population shares (so that in a bar
    chart the areas of the bars are proportional to the outcome shares).
    Outcome sums (totals) and average outcomes can be requested by options
    {cmd:sum} and {cmd:average}, respectively. Finally, use option
    {cmd:generalized} to report generalized percentile shares, defined as
    differences between generalized Lorenz ordinates. Only one of
    {cmd:proportion}, {cmd:percent}, {cmd:density}, {cmd:sum}, {cmd:average},
    or {cmd:generalized} is allowed.

{marker normalize}{...}
{phang}
    {cmd:normalize(}{it:spec}{cmd:)} causes results to be normalized with
    respect to the specified total (not allowed in combination with {cmd:sum},
    {cmd:average}, or {cmd:generalized}). {it:spec} is

            [{it:over}{cmd::}][{it:total}]

{pmore}
    where {it:over} may be

            {cmd:.}      the subpopulation at hand (the default)
            {it:#}      the subpopulation identified by value {it:#}
            {cmd:#}{it:#}     the {it:#}th subpopulation
            {cmdab:t:otal}  the total across all subpopulations

{pmore}
    and {it:total} may be

            {cmd:.}        the total of the variable at hand (the default)
            {cmd:*}        the total of the sum across all analyzed outcome variables
            {varlist}  the total of the sum across the variables in {varlist}
            {it:#}        a total equal to {it:#}

{pmore}
    {it:total} specifies the variable(s) from which the total is to be
    computed, or sets the total to a fixed value. If multiple variables are
    specified, the total across all specified variables is used ({varlist} may
    contain external variables that are not among the list of analyzed outcome
    variables). {it:over} selects the reference population from which the total
    is to be computed; {it:over} is only allowed if the {cmd:over()} option has
    been specified (see below). Subpopulation sizes (sum of weights) are taken
    into account for the computation of densities (option {cmd:density}) if
    {it:over} is provided, so that the densities reflect
    multiples of the average outcome in the reference population.

{phang}
    {cmd:gini} causes Gini coefficients (a.k.a. concentration indices if
    {cmd:pvar()} is specified) to be computed and reported in a separate table.
    Variance estimation for Gini coefficients is not supported.

{dlgtab:Percentiles}

{phang}
    {opt nquantiles(#)} specifies the number of (equally sized) percentile
    groups to be used. The default is to use quintiles, that is,
    {cmd:nquantiles(5)}. This is equivalent to typing
    {cmd:percentiles(20 40 60 80)}.

{phang}
    {opth percentiles(numlist)} specifies, as percentages, the percentiles to
    be used as threshold for the percentile groups. For example, for deciles
    type {cmd:percentiles(10 20 30 40 50 60 70 80 90)}, or, as a shorthand,
    {cmd:percentiles(10(10)90)}. To compute shares of the bottom 50%, 50-90%,
    90-95%, 95-99%, 99-99.9%, and the top 0.1%, for example, you could type
    {cmd:percentiles(50 90 95 99 99.9)}.

{phang}
    {cmd:pvar(}{help varname:{it:pvar}}{cmd:)} causes the percentile groups to
    be based on variable {it:pvar} instead of the outcome variable. That is,
    observations will be sorted in increasing order of {it:pvar} and
    percentiles will be determined from the running sum of the outcome variable
    across this sort order (using averaged values within ties of {it:pvar}).
    Use this option to analyze relations between different variables (e.g. how
    wealth is distributed across different income groups). If {opt pvar()} is
    specified, the computed percentile shares correspond to differences between
    ordinates of the "concentration curve" of the outcome variable with respect
    to {it:pvar}.

{phang}
    {opt step} causes the Lorenz ordinates to be determined from the step
    function of cumulative outcomes. The default is to employ linear
    interpolation in regions where the step function is flat.

{dlgtab:Over}

{phang}
    {opth over(varname)} reports results for each subpopulation defined by the
    values of {it:varname}. Only one outcome variable is allowed if
    {cmd:over()} is specified.

{phang}
    {opt total} causes additional overall results across all subpopulations to
    be reported. {cmd:total} is only allowed if {cmd:over()} is specified.

{dlgtab:Contrast/Graph}

{marker contrast}{...}
{phang}
    {cmd:contrast}[{cmd:(}{it:spec}{cmd:)}] causes differences in percentile
    shares to be computed between outcome variables or between subpopulations,
    where {it:spec} is

            [{it:base}] [, {cmdab:r:atio} {cmdab:lnr:atio} ]

{pmore}
    To report contrasts as ratios instead of differences, specify the {cmd:ratio}
    suboption; to report contrast as  logarithms of ratios, specify the
    {cmd:lnratio} suboption.

{pmore}
    If {cmd:over()} is specified together with {cmd:total}, the default is to
    use the overall total across subpopulations as base for the contrasts. In all
    other cases, the default is to compute adjacent contrasts (i.e. using the
    preceding outcome variable or subpopulation as base). Alternatively,
    specify {it:base} to select the base for the contrasts.

{pmore}
    In case of multiple outcome variables, {it:base} is the name of the outcome
    variable to be used as base. For example,

            {com}. pshare estimate y1990 y2000 y2010, contrast(y1990){txt}

{pmore}
    computes differences in percentile shares with respect to {cmd:y1990}.
    Likewise, if {cmd:over()} is specified, {it:base} is the value of the
    subpopulation to be used as base. For example,

            {com}. pshare estimate wage, over(race) contrast(1){txt}

{pmore}
    computes differences with respect to {cmd:race}==1. Alternatively, {it:base}
    may also be {cmd:#1}, {cmd:#2}, {cmd:#3}, etc. to use the 1st, 2nd, 3rd,
    etc. outcome variable or subpopulation as the base for the contrasts. For
    example,

            {com}. pshare estimate wage, over(race) contrast(#2){txt}

{pmore}
    uses the second subpopulation as base for the contrasts.

{phang}
    {cmd:stack}[{cmd:(}{help pshare##stackoptions:{it:options}}{cmd:)}] draws
    a stacked bar chart of the results. {it:options} are as described for
    {helpb pshare##stackoptions:pshare stack} below.

{phang}
    {cmd:histogram}[{cmd:(}{help pshare##histoptions:{it:options}}{cmd:)}] draws
    a histogram of the results. {it:options} are as described for
    {helpb pshare##histoptions:pshare histogram} below.

{dlgtab:SE/SVY}

{marker vcetype}{...}
{phang}
    {opth vce(vcetype)} determines how standard errors and confidence intervals
    are computed. {it:vcetype} may be:

            {cmd:analytic}
            {cmd:cluster} {it:clustvar}
            {cmd:bootstrap} [{cmd:,} {help bootstrap:{it:bootstrap_options}}]
            {cmd:jackknife} [{cmd:,} {help jackknife:{it:jackknife_options}}]

{pmore}
    The default is {cmd:vce(analytic)}, using approximate formulas for variance
    estimation assuming independent data. For clustered data, specify
    {cmd:vce(cluster} {it:clustvar}{cmd:)}, where {it:clustvar} is the variable
    identifying the clusters. Methods and formulas are based on Binder and
    Kovacevic (1995; also see Kovacevic and Binder 1997). For bootstrap and
    jackknife estimation, see help {it:{help vce_option}}. Variance estimation
    is not supported if {cmd:iweights} or {cmd:fweights} are specified.

{phang}
    {opt cluster(clustvar)} is a synonym for {cmd:vce(cluster} {it:clustvar}{cmd:)}.

{marker svy}{...}
{phang}
    {cmd:svy}[{cmd:(}{it:subpop}{cmd:)}] causes the survey design to be taken
    into account for variance estimation. Methods and formulas are based on
    Binder and Kovacevic (1995). The data need to be set up for survey
    estimation; see help {helpb svyset}. Specify {it:subpop} to restrict survey
    estimation to a subpopulation, where {it:subpop} is

            [{varname}] [{it:{help if}}]

{pmore}
    The subpopulation is defined by observations for which {it:varname}!=0 and
    for which the {cmd:if} condition is met. See help {helpb svy} and
    {manlink SVY subpopulation estimation} for more information on subpopulation
    estimation.

{pmore}
    The {cmd:svy} option of {cmd:pshare} only works if the variance
    estimation method is set to Taylor linearization by {helpb svyset} (the
    default). For other variance estimation methods you may use the usual {helpb svy}
    prefix command. For example, you could type {cmd:svy brr: pshare ...} to
    use BRR variance estimation. {cmd:pshare} does not allow the {helpb svy}
    prefix for Taylor linearization due to technical reasons. This is why the
    {cmd:svy} option is provided.

{phang}
    {opt nose} suppresses the computation of standard errors and confidence
    intervals. Use the {cmd:nose} option to speed-up computations when analyzing
    population data. The {cmd:nose} option may also be useful to speed-up computations with
    prefix commands that use replication techniques for variance estimation,
    such as, e.g., {helpb svy jackknife}. Options {cmd:vce(bootstrap)} and
    {cmd:vce(jackknife)} imply {cmd:nose}.

{dlgtab:Reporting}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)} or as set by
    {helpb set level}.

{phang}
    {opt noheader} suppresses the output header; only the coefficient table is
    displayed.

{phang}
    {opt notable} suppresses the coefficient table.

{phang}
    {opt nogtable} suppresses the table containing Gini coefficients.

{marker displayopts}{...}
{phang}
    {it:display_options} are standard reporting options such as {cmd:cformat()},
    {cmd:pformat()}, {cmd:sformat()}, or {cmd:coeflegend}. See
    {helpb estimation options:[R] estimation options}.

{marker contoptions}
{title:Options for pshare contrast}

{phang}
    {cmd:ratio} causes contrasts to be reported as ratios. The default is to
    report contrasts as differences.

{phang}
    {cmd:lnratio} causes contrasts to be reported as logarithms of ratios. The
    default is to report contrasts as differences.

{phang}
    {cmd:stack}[{cmd:(}{help pshare##stackoptions:{it:options}}{cmd:)}] draws
    a stacked bar chart of the results. {it:options} are as described for
    {helpb pshare##stackoptions:pshare stack} below.

{phang}
    {cmd:histogram}[{cmd:(}{help pshare##histoptions:{it:options}}{cmd:)}] draws
    a histogram of the results. {it:options} are as described for
    {helpb pshare##histoptions:pshare histogram} below.

{phang}
    {it:display_options} are standard reporting options such as {cmd:cformat()},
    {cmd:pformat()}, {cmd:sformat()}, or {cmd:coeflegend}. See
    {helpb estimation options:[R] estimation options}.

{marker stackoptions}
{title:Options for pshare stack}

{dlgtab:Main}

{phang}
    {opt vertical} and {opt horizontal} specify whether a vertical or a
    horizontal bar plot is drawn. The default is to draw a horizontal bar plot.

{phang}
    {opt proportion} scales the population axis as proportion
    (0 to 1). The default is to scale the axis as percentage (0 to
    100).

{phang}
    {cmd:reverse} orders percentile groups from top to bottom (the richest
    are leftmost, the poorest are rightmost). The default is to
    order percentile groups from bottom to top (the poorest
    are leftmost, the richest are rightmost).

{marker stackkeep}{...}
{phang}
    {opt keep(list)} selects and orders the results to be included as
    separate bars. Use {cmd:keep()} with multiple outcome variables or
    subpopulations. In case of multiple outcome variables, {it:spec} is a list
    of the names of the outcome variables to be included. In case of
    {cmd:over()}, {it:list} is a list of the values of the subpopulations to be
    included. {it:list} may also contain {cmdab:t:otal} for the overall results
    (if overall results were requested). Furthermore, {it:list} may also
    contain elements such as {cmd:#1}, {cmd:#2}, {cmd:#3}, etc. to refer to the
    1st, 2nd, 3rd, etc. outcome variable or subpopulation. See the
    {helpb pshare##keep:keep()} option of {cmd:pshare histogram} for examples.

{marker sortopts}{...}
{phang}
    {cmdab:s:ort}[{cmd:(}{it:options}{cmd:)}] orders the bars for the
    different outcome variables or subpopulation by the level of inequality.
    If {cmd:sort} is specified without argument, the bars are sorted in
    ascending order of the outcome shares of the top percentile group. The
    {it:options} for alternative sorting are:

            {cmdab:g:ini}        sort by Gini coefficients
            {cmdab:d:escending}  sort in descending order
            {cmdab:tl:ast}       place total last
            {cmdab:tf:irst}      place total first

{phang}
    {cmd:gini(}{it:%fmt}{cmd:)} sets the format for the Gini coefficients
    included in the graph as secondary axis labels; see help {helpb format}. The
    default format is {cmd:%9.3g}. Gini coefficients will only
    be included if information on Gini coefficients is available in the
    provided results (i.e. if the {cmd:gini} option has been applied to
    {cmd:pshare estimate}).

{phang}
    {cmd:nogini} suppresses the Gini coefficients. This is only relevant if the
    {cmd:gini} option has been specified when calling {cmd:pshare estimate}.

{dlgtab:Labels/Rendering}

{marker stacklabels}{...}
{phang}
    {opt labels(labels)} specifies custom axis labels for the included outcome
    variables or subpopulations. The default is to use the variable labels of
    the outcome variables or the value labels of the subpopulations,
    respectively. {it:spec} is a list of labels that are applied one-by-one to
    the displayed bars (from top to bottom, or left to right). Use quotes if a
    label contains spaces, e.g. {cmd:labels("label one" "label two" ...)}. Type
    empty string to use the default label for a specific bar. For example,
    {cmd:labels("label 1" "" "label 3")} specifies custom labels for the first
    and third bars, and uses default labels for the other bars.

{marker plabels}{...}
{phang}
    {opt plabels(labels)} specifies custom labels for percentile groups in the
    legend. The default is to use labels composed of the values of
    the lower bound and the upper bound of the group. {it:spec} is a list of
    labels that are applied one-by-one to the groups (from left to right, or
    bottom to top). Use quotes if a label contains spaces,
    e.g. {cmd:labels("label one" "label two" ...)}. Type empty
    string to use the default label for a specific group. For example,
    {cmd:labels("label 1" "" "label 3")} specifies custom labels for the first
    and third groups, and uses default labels for the other groups.

{phang}
    {opt barwidth(#)} sets the width of the bars as proportion of the spacing
    between bar positions. The default is {cmd:barwidth(0.75)}, leaving white
    space of 1/3 barwidth between the bars.

{phang}
    {it:barlook_options} are options that affect the rendition of the plotted
    bars. See {helpb barlook_options:[G] {it:barlook_options}}.

{phang}
    {opt p#(barlook_options)} affects the rendition of #th segment of the
    stacked bars (corresponding to the #th percentile group). {it:barlook_options}
    are as described in {helpb barlook_options:[G] {it:barlook_options}}. For
    example, to use khaki colored bars for the 3rd percentile group, type
    {cmd:p3(color(khaki))}, or, to print a thick red border around the bars of the 5th
    percentile group, type {cmd:p5(lcolor(red) lwidth(thick))}. If the {cmd:values()}
    option has been specified, {it:{help marker_label_options}} are allowed
    within {cmd:p#()}.

{phang}
    {cmd:values}[{cmd:(}{it:%fmt}{cmd:)}] prints the values of the percentile
    shares as marker labels at the center of the bar segments and, optionally,
    set the display format for the values; see help {helpb format}. The
    default format is {cmd:%9.3g}. Use {it:{help marker_label_options}} to
    affect the rendition of the labels. To use differential rendition by bar
    segment, specify {it:marker_label_options} within the {cmd:p#()} options
    (see above).

{phang}
    {it:marker_label_options} are options that affect the rendition of the values
    included as marker labels using the {cmd:values()} option. See
    {helpb marker_label_options:[G] {it:marker_label_options}}. Do not use
    {cmd:mlabel()} or {cmd:mlabvposition()}.

{dlgtab:Add plots}

{phang}
    {opt addplot(plot)} provides a way to add other plots to the generated
    graph. See {helpb addplot_option:[G] {it:addplot_option}}.

{dlgtab:Y-Axis, X-Axis, Title, Caption, Legend, Overall}

{phang}
    {it:twoway_options} are general twoway options, other than {cmd:by()}, as
    documented in {helpb twoway_options:[G] {it:twoway_options}}.

{marker histoptions}
{title:Options for pshare histogram}

{dlgtab:Main}

{phang}
    {opt vertical} and {opt horizontal} specify whether a vertical or a
    horizontal bar plot is drawn. The default is to draw a vertical bar plot.

{phang}
    {opt proportion} scales the population axis in terms of proportions
    (0 to 1). The default is to scale the axis in terms of percentages (0 to
    100).

{marker keep}{...}
{phang}
    {opt keep(list)} selects and orders the results to be included as
    subgraphs. Use {cmd:keep()} if {cmd:pshare estimate} has been applied to
    multiple outcome variables or subpopulations. In case of multiple outcome
    variables, {it:list} is a list of the names of the outcome variables to be
    included. Example:

            {com}. pshare estimate y1990 y2000 y2010
            {com}. pshare graph, keep(y2010 y1990){txt}

{pmore}
    In case of {cmd:over()}, {it:list} is a list of the values of the
    subpopulations to be included. {it:list} may also contain {cmdab:t:otal} for
    the overall results (if overall results were requested). Example:

           {com}. pshare estimate wage, over(race) total
           {com}. pshare graph, keep(total 1 2){txt}

{pmore}
    Furthermore, {it:list} may also contain elements such as {cmd:#1},
    {cmd:#2}, {cmd:#3}, etc. to refer to the 1st, 2nd, 3rd, etc. outcome
    variable or subpopulation. Example:

           {com}. pshare estimate wage, over(race)
           {com}. pshare graph, keep(#1 #3){txt}

{marker maxmin}{...}
{phang}
    {cmd:max(}{it:#}[, {it:options}]{cmd:)} top-codes results at {it:#}
    (i.e. truncates the bars from above);
    {cmd:min(}{it:#}[, {it:options}]{cmd:)} bottom-codes results at {it:#}
    (i.e. truncates the bars from below). This is useful if there are large
    differences in the plotted values and you want to restrict the axis
    range. The truncated values will be included in the graph as marker
    labels. {it:options} are:

            {cmdab:f:ormat(}{help format:{it:%fmt}}{cmd:)}          set the format (default is {cmd:%9.3g})
            {it:{help marker_label_options}}  affect rendition of the labels
            {opt nolab:els}              omit the marker labels

{phang}
    {cmd:prange(}{it:min} {it:max}{cmd:)} restricts the range of the percentile
    groups to be included in the graph. Only results for percentile groups
    whose lower and upper cumulative population bounds (in percent) are within
    {it:min} and {it:max} will be plotted. {it:min} and {it:max} must
    be within [0,100]. For example, to include only the lower half of the
    distribution, type {cmd:prange(0 50)}.

{phang}
    {opt gini(%fmt)} sets the format for the Gini coefficients included in the
    subgraph labels; see help {helpb format}. The default format is
    {cmd:%9.3g}. Gini coefficients will only be included if information on Gini
    coefficients is available in the provided results (i.e. if the {cmd:gini}
    option has been applied to {cmd:pshare estimate}).

{phang}
    {cmd:nogini} suppresses the Gini coefficients. This is only relevant if the
    {cmd:gini} option has been specified when calling {cmd:pshare estimate}.

{dlgtab:Labels/Rendering}

{phang}
    {it:barlook_options} are options that affect the rendition of the plotted
    bars. See {helpb barlook_options:[G] {it:barlook_options}}.

{phang}
    {cmd:step} causes a step function to be drawn instead of histogram bars.

{phang}
    {cmd:addstep}[{cmd:(}{it:line_options}{cmd:)}]
    causes a step function to be drawn on top of the histogram bars. Specify
    {it:line_options} to affect the rendering of the step function line; see
    {helpb line_options:[G] {it:line_options}}.

{phang}
    {cmd:spikes}[{cmd:(}{it:#}{cmd:)}] causes (equally spaced) spikes to be
    drawn instead of histogram bars. {it:#} specifies the number of spikes. The
    default is to draw 100 spikes, one for each percentile. Specifying
    {cmd:spikes} implies {cmd:noci} (see below).

{marker labels}{...}
{phang}
    {opt labels(labels)} specifies custom labels for the included subgraphs.
    The default is to use the variable labels of the outcome variables or the
    value labels of the subpopulations, respectively. {it:labels} is a list of
    labels that are applied one-by-one to the subgraphs. Use quotes if a label
    contains spaces, e.g. {cmd:labels("label one" "label two" ...)}. Type
    empty string to use the default label for a specific subgraph. For example,
    {cmd:labels("label 1" "" "label 3")} specifies custom labels for the
    first and third subgraphs, and uses default labels for the other subgraphs.

{phang}
    {opt byopts(byopts)} determines how subgraphs are combined. {it:byopts}
    are as described in {helpb by_option:[G] {it:by_option}}.

{phang}
    {cmd:overlay} causes results from the different outcome variables or
    subpopulations to be included in the same graph instead of using separate
    subgraphs. {cmd:overlay} and {cmd:psep()} are not both allowed. Specifying
    {cmd:overlay} implies {cmd:noci} (see below).

{marker oopts}{...}
{phang}
    {opt o#(options)} affects the rendition of the bars of the #th outcome
    variable or subpopulation if {cmd:overlay} has been specified. {it:options} are:

            {cmd:step}                  draw step function instead of bars
            {cmdab:adds:tep}[{cmd:(}{it:{help line_options:line_opts}}{cmd:)}]  draw step function in addition to bars
            {it:{help barlook_options}}       affect rendition of the plotted bars

{marker psep}{...}
{phang}
    {cmd:psep}[{cmd:(}{it:labels}{cmd:)}] causes different rendering to be used
    for each percentile group and includes a corresponding legend in the
    graph. The default is to draw all bars in the same style. {cmd:psep()} and
    {cmd:overlay} are not both allowed.

{marker popts}{...}
{phang}
    {opt p#(options)} affects the rendition of the bars of the #th
    percentile group if {cmd:psep()} has been specified. {it:options} are:

            {it:{help barlook_options}}  affect rendition of the plotted bars
            {cmdab:ciopt:s(}{help pshare##ciopts:{it:options}}{cmd:)}  affect rendition of the confidence spikes

{dlgtab:Confidence intervals}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is the level that has been used for
    computing the {cmd:pshare} results. {cmd:level()} cannot be used together
    with {cmd:ci(bc)}, {cmd:ci(bca)}, or {cmd:ci(percentile)}. To change the
    level for these confidence intervals, you need to specify {cmd:level()}
    when computing the results.

{marker citype}{...}
{phang}
    {opt ci(citype)} chooses the type of CI to be plotted for results that have
    been computed using the bootstrap technique. {it:citype} may be:

            {cmdab:nor:mal}{col 25}normal-based CIs; the default
            {cmd:bc}{col 25}bias-corrected CIs
            {cmd:bca}{col 25}bias-corrected and accelerated CIs
            {cmdab:p:ercentile}{col 25}percentile CIs

{pmore}
    {cmd:bca} is only available if BCa confidence intervals have been requested
    when running {cmd:pshare estimate}.

{marker ciopts}{...}
{phang}
    {opt ciopts(options)} specifies options that affect the rendition of the
    plotted confidence spikes, e.g. {it:{help line_options}}. The available set
    of options depends on plot type. The default plot type is capped spikes; see
    help {helpb graph twoway rcap}. Use the {cmd:recast()} option to
    change the plot type. For example, type {cmd:ciopts(recast(rspike))} for
    (uncapped) spikes; see {helpb graph twoway rspike}. Available plot types are
    range plots as listed in {helpb twoway}.

{phang}
    {opt cibelow} causes the confidence interval spikes to be placed behind the
    plotted bars. The default is to draw the spikes in front of the bars.

{phang}
    {opt noci} omits confidence interval spikes from the plot.

{dlgtab:Add plots}

{phang}
    {opt addplot(plot)} provides a way to add other plots to the generated
    graph. See {helpb addplot_option:[G] {it:addplot_option}}.

{dlgtab:Y-Axis, X-Axis, Title, Caption, Legend, Overall}

{phang}
    {it:twoway_options} are general twoway options, other than {cmd:by()}, as
    documented in {helpb twoway_options:[G] {it:twoway_options}}.


{title:Examples}

        . {stata sysuse nlsw88}
        . {stata pshare estimate wage}
        . {stata pshare histogram}

        . {stata pshare estimate wage, percentiles(20 40 60 70 80 90 95 97 99) density}
        . {stata pshare histogram, yline(1)}

        . {stata pshare estimate wage, percentiles(20 40 60 70 80 90 95 97 99) density vce(bootstrap)}
        . {stata pshare histogram, yline(1)}

        . {stata pshare estimate wage, over(union)}
        . {stata pshare histogram, yline(1)}

        . {stata pshare estimate wage, over(union)}
        . {stata pshare contrast 0}
        . {stata pshare histogram, yline(0)}

        . {stata pshare estimate wage, over(industry) total gini}
        . {stata pshare stack, sort(gini tlast descending)}

{pstd}
    For further examples see {help pshare##jann2016:Jann (2016)}.


{title:Stored results}

{pstd}
{cmd:pshare estimate} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_over)}}number of subpopulations{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(bins)}}number of bins (percentile groups) per equation{p_end}
{synopt:{cmd:e(df_r)}}sample degrees of freedom{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(level)}}confidence level for CIs{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:pshare}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name(s) of outcome variable(s){p_end}
{synopt:{cmd:e(pvar)}}name of variable specified in {cmd:pvar()}{p_end}
{synopt:{cmd:e(type)}}{cmd:proportion}, {cmd:percent}, {cmd:density}, {cmd:sum}, {cmd:average}, or {cmd:generalized}{p_end}
{synopt:{cmd:e(norm)}}{it:#} or names of reference variables or empty{p_end}
{synopt:{cmd:e(normpop)}}{cmd:total} or {it:overvar} {cmd:=} {it:#} or empty{p_end}
{synopt:{cmd:e(percentiles)}}percentile thresholds{p_end}
{synopt:{cmd:e(step)}}{cmd:step} or empty{p_end}
{synopt:{cmd:e(gini)}}{cmd:gini} or empty{p_end}
{synopt:{cmd:e(over)}}name of {cmd:over()} variable{p_end}
{synopt:{cmd:e(over_namelist)}}values from {cmd:over()} variable{p_end}
{synopt:{cmd:e(over_labels)}}labels from {cmd:over()} variable{p_end}
{synopt:{cmd:e(total)}}{cmd:total} or empty{p_end}
{synopt:{cmd:e(contrast)}}{cmd:contrast} or empty{p_end}
{synopt:{cmd:e(baseval)}}{cmd:+} or value/name of base for contrasts{p_end}
{synopt:{cmd:e(ratio)}}{cmd:ratio} or empty{p_end}
{synopt:{cmd:e(lnratio)}}{cmd:lnratio} or empty{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V} or {cmd:b}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}estimates (proportions, percent, densities, sums, or averages){p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of estimates{p_end}
{synopt:{cmd:e(_N)}}numbers of observations in subpopulations{p_end}
{synopt:{cmd:e(G)}}Gini coefficients (if {cmd:gini} is specified){p_end}
{synopt:{cmd:e(L_ul)}}upper bounds of Lorenz ordinates{p_end}
{synopt:{cmd:e(L_ll)}}lower bounds of Lorenz ordinates{p_end}
{synopt:{cmd:e(prop)}}population proportions{p_end}
{synopt:{cmd:e(ul)}}upper bounds of cumulative population percentages{p_end}
{synopt:{cmd:e(ll)}}lower bounds of cumulative population percentages{p_end}
{synopt:{cmd:e(mid)}}midpoints of cumulative population percentages{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
    If the {cmd:svy} option is specified, various additional results as described
    in help {helpb svy} are stored in {cmd:e()}.


{title:References}

{phang}
    Binder, D. A., M. S. Kovacevic (1995). Estimating Some Measures of Income
    Inequality from Survey Data: An Application of the Estimating Equations
    Approach. Survey Methodology 21(2): 137-145.

{marker jann2016}{...}
{phang}
    Jann, B. (2016). {browse "https://www.stata-journal.com/article.html?article=st0432":Assessing inequality using percentile shares}. The
    Stata Journal 16(2): 264–300. ({browse "http://ideas.repec.org/p/bss/wpaper/13.html":working paper})

{phang}
    Kovacevic, M. S., D. A. Binder (1997). Variance Estimation for
    Measures of Income Inequality and Polarization - The Estimating Equations
    Approach. Journal of Offcial Statistics 13(1): 41-58.


{title:Author}

{pstd}
    Ben Jann, University of Bern, jann@soz.unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B. (2015). pshare: Stata module to compute and graph percentile shares. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458036.html"}.


{title:Also see}

{psee}
    Online:  help for
    {helpb pctile},
    {helpb graph twoway bar}

{psee}
    From the SSC Archive:
    {stata ssc describe lorenz:{bf:lorenz}},
    {stata ssc describe sumdist:{bf:sumdist}},
    {stata ssc describe svylorenz:{bf:svylorenz}}
