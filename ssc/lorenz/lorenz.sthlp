{smcl}
{* 08aug2016}{...}
{hi:help lorenz}
{hline}

{title:Title}

{pstd}{hi:lorenz} {hline 2} Lorenz and concentration curves


{title:Syntax}

{pstd}
    Estimating Lorenz and concentration curves:

{p 8 15 2}
    {cmd:lorenz} [{cmdab:e:stimate}] {varlist} {ifin} {weight}
    [{cmd:,}
    {help lorenz##estopt:{it:estimate_options}}
    ]

{pstd}
    Computing contrasts between outcome variables or subgroups:

{p 8 15 2}
    {cmd:lorenz} {cmdab:c:ontrast} [{help lorenz##contrast:{it:base}}]
    [{cmd:,}
    {help lorenz##contopt:{it:contrast_options}}
    ]

{p 8 8 2}
    where {it:base} is the name of the outcome variable or the value of the
    subpopulation to be used as base. {it:base} may also be {cmd:#1}, {cmd:#2},
    or {cmd:#3}, etc. to refer to the 1st, 2nd, or 3rd, etc. outcome variable
    or subpopulation. See the {helpb lorenz##contrast:contrast()} option of
    {cmd:lorenz estimate} for more details

{pstd}
    Drawing a line graph of the results:

{p 8 15 2}
    {cmd:lorenz} {cmdab:g:raph}
    [{cmd:,}
    {help lorenz##grtopt:{it:graph_options}}
    ]


{synoptset 22 tabbed}{...}
{marker estopt}{col 5}{help lorenz##estoptions:{it:estimate_options}}{col 29}Description
{synoptline}
{syntab :Main}
{synopt :{opt gap}}compute equality gap curves
    {p_end}
{synopt :{opt sum}}compute total (unnormalized) Lorenz curves
    {p_end}
{synopt :{opt general:ized}}compute generalized Lorenz curves
    {p_end}
{synopt :{opt abs:olute}}compute absolute Lorenz curves
    {p_end}
{synopt :{opt percent}}report Lorenz ordinates as percentages
    {p_end}
{synopt :{cmdab:norm:alize(}{help lorenz##normalize:{it:spec}}{cmd:)}}normalize
    Lorenz curves with respect to the specified total
    {p_end}
{synopt :{opt gini}}also report Gini coefficient(s)
    {p_end}

{syntab :Percentiles}
{synopt :{opt n:quantiles(#)}}use # equally spaced percentiles (plus an additional 
    point at the origin); default is {cmd:nquantiles(20)}
    {p_end}
{synopt :{cmdab:p:ercentiles(}{help lorenz##percentiles:{it:numlist}}{cmd:)}}use 
    percentiles corresponding to the specified percentages
    {p_end}
{synopt :{cmd:pvar(}{help varname:{it:pvar}}{cmd:)}}compute concentration curves 
    with respect to {it:pvar}
    {p_end}
{synopt :{opt step}}determine Lorenz ordinates from step function; the default
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
{synopt :{cmdab:c:ontrast}[{cmd:(}{help lorenz##contrast:{it:spec}}{cmd:)}]}compute 
    differences in Lorenz curves between outcome variables or subpopulations
    {p_end}
{synopt :{cmdab:g:raph}[{cmd:(}{help lorenz##gropt:{it:options}}{cmd:)}]}draw
    line graph of the results; {it:options} are 
    {help lorenz##gropt:{it:graph_options}} as described below  
    {p_end}

{syntab :SE/SVY}
{synopt :{cmd:vce(}{help lorenz##vcetype:{it:vcetype}}{cmd:)}}{it:vcetype} may
    be {cmd:analytic} (the default), {cmdab:cl:uster} {it:clustvar},
    {cmdab:boot:strap} or {cmdab:jack:knife}
    {p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for 
    {cmd:vce(cluster} {it:clustvar}{cmd:)}
    {p_end}
{synopt :{cmd:svy}[{cmd:(}{help lorenz##svy:{it:subpop}}{cmd:)}]}take account
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
{synopt :{help lorenz##displayopts:{it:display_options}}}standard 
    reporting options as described in 
    {helpb estimation options:[R] estimation options}
    {p_end}
{synoptline}
{p 4 6 2}
{opt pweight}s, {opt iweight}s, and {opt fweight}s are allowed; see {help weight}.


{synoptset 22 tabbed}{...}
{marker contopt}{col 5}{help lorenz##contoptions:{it:contrast_options}}{col 29}Description
{synoptline}
{synopt :{opt r:atio}}compute ratios instead of differences
    {p_end}
{synopt :{opt lnr:atio}}compute logarithms of ratios instead of differences
    {p_end}
{synopt :{cmdab:g:raph}[{cmd:(}{help lorenz##gropt:{it:options}}{cmd:)}]}draw
    line graph of the results;  {it:options} are 
    {help lorenz##gropt:{it:graph_options}} as described below  
    {p_end}
{synopt :{help lorenz##displayopts:{it:display_options}}}standard 
    reporting options as described in 
    {helpb estimation options:[R] estimation options}
    {p_end}
{synoptline}


{synoptset 22 tabbed}{...}
{marker gropt}{col 5}{help lorenz##groptions:{it:graph_options}}{col 29}Description
{synoptline}
{syntab :Main}
{synopt :{opt prop:ortion}}population axis in proportion, not percent
    {p_end}
{synopt :{opt nodiag:onal}}omit the equal distribution diagonal
    {p_end}
{synopt :{cmdab:diag:onal(}{help line_options:{it:options}}{cmd:)}}affect rendition 
    of the equal distribution diagonal
    {p_end}
{synopt :{cmd:keep(}{help lorenz##keep:{it:list}}{cmd:)}}select and order 
    results to be included as subgraphs
    {p_end}
{synopt :{cmd:prange(}{it:min} {it:max}{cmd:)}}restrict range of percentiles 
    to be included in the graph
    {p_end}
{synopt :{cmdab:g:ini(}{help format:{it:%fmt}}{cmd:)}}specify format for Gini
    coefficients; default format is {cmd:%9.3g}
    {p_end}
{synopt :{opt nog:ini}}omit Gini coefficients from subgraph labels
    {p_end}

{syntab :Labels/Rendering}
{synopt :{it:{help connect_options}}}affect rendition of the plotted lines
    {p_end}
{synopt :{cmdab:lab:els(}{help lorenz##labels:{it:labels}}{cmd:)}}specify 
    custom labels for subgraphs
    {p_end}
{synopt :{cmdab:byopt:s(}{help by_option:{it:byopts}}{cmd:)}}specify how 
    subgraphs are combined
    {p_end}
{synopt :{opt over:lay}}combine results in single graph instead of using 
    subgraphs
    {p_end}
{synopt :{cmd:o#(}{help lorenz##oopts:{it:options}}{cmd:)}}affect rendition 
    of #th plot; for use with {cmd:overlay}
    {p_end}

{syntab :Confidence intervals}
{synopt :{opt l:evel(#)}}set confidence level; not allowed if {cmd:ci()} is 
    {cmd:bc}, {cmd:bca}, or {cmd:percentile}
    {p_end}
{synopt :{cmd:ci(}{help lorenz##citype:{it:citype}}{cmd:)}}choose type of 
    bootstrap CI; {it:citype} may be {cmdab:nor:mal} (the default), {cmd:bc}, 
    {cmd:bca}, or {cmdab:p:ercentile}
    {p_end}
{synopt :{cmdab:ciopt:s(}{help area_options:{it:options}}{cmd:)}}affect 
    rendition of the plotted confidence areas; see help 
    {helpb graph twoway rarea}
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
    {cmd:lorenz estimate} computes Lorenz and concentration curves from
    individual-level data. The default is to compute standardized (relative)
    Lorenz/concentration curves, but generalized and absolute
    Lorenz/concentration curves are also supported. Furthermore, unnormalized
    Lorenz/concentration curves (such that the estimates reflect cumulative
    totals) or Lorenz/concentration curves that are normalized to a specified
    total can be computed. Variance estimation for complex samples is
    supported; for methodological details see 
    {help lorenz##jann2016:Jann (2016)}.

{pstd}
    Given the results form {cmd:lorenz estimate} for several outcome variables
    or subpopulations, {cmd:lorenz contrast} computes differences in
    Lorenz/concentration curves between outcome variables or subpopulations.

{pstd}
    {cmd:lorenz graph} plots the results from {cmd:lorenz estimate} or 
    {cmd:lorenz contrast} as a line diagram. Confidence intervals are included 
    as shaded areas.

{pstd}
    {cmd:lorenz} without arguments replays the previous results. Reporting
    options may be applied.


{marker estoptions}{...}
{title:Options for lorenz estimate}

{dlgtab:Main}

{phang}
    {cmd:gap} causes equality gap curves to be computed. Equality gap curves are 
    defined as EG(p) = p - L(p) where L(p) is the ordinate of
    the (relative) Lorenz curve at percentile p. Only one
    of {cmd:gap}, {cmd:sum}, {cmd:generalized}, and {cmd:absolute} is allowed.

{phang}
    {cmd:sum} causes unnormalized Lorenz curves to be computed such that the
    Lorenz ordinates reflect cumulative sums of the outcome variable. Only one
    of {cmd:gap}, {cmd:sum}, {cmd:generalized}, and {cmd:absolute} is allowed.

{phang}
    {cmd:generalized} causes generalized Lorenz curves to be computed. Only one
    of {cmd:gap}, {cmd:sum}, {cmd:generalized}, and {cmd:absolute} is allowed.

{phang}
    {cmd:absolute} causes absolute Lorenz curves to be computed. Only one
    of {cmd:gap}, {cmd:sum}, {cmd:generalized}, and {cmd:absolute} is allowed.

{phang}
    {cmd:percent} causes results to be expressed as percentages
    instead of proportions. {cmd:percent} is not allowed in combination with
    {cmd:sum}, {cmd:generalized}, and {cmd:absolute}.

{marker normalize}{...}
{phang}
    {cmd:normalize(}{it:spec}{cmd:)} causes Lorenz ordinates to be normalized
    with respect to the specified total (not allowed in combination with
    {cmd:sum}, {cmd:generalized}, or {cmd:absolute} ). {it:spec} is

            [{it:over}{cmd::}] [{it:total}] [, {opt a:verage}]

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
    been specified (see below). Suboption {cmd:average} causes subpopulation 
    sizes (sum of weights) to be taken into account, so that the results are 
    relative to the average outcome in the reference population; this is only
    relevant if {it:over} is provided.

{phang}
    {cmd:gini} causes Gini coefficients (a.k.a. concentration indices if
    {cmd:pvar()} is specified) to be computed and reported in a separate table.
    Variance estimation for Gini coefficients is not supported.

{dlgtab:Percentiles}

{phang}
    {opt nquantiles(#)} specifies the number of (equally spaced) percentiles
    to be used to determine the Lorenz ordinates (plus an additional point 
    at the origin). The default is {cmd:nquantiles(20)}. This is equivalent to 
    typing {cmd:percentiles(0(5)100)}.

{marker percentiles}{...}
{phang}
    {opth percentiles(numlist)} specifies, as percentages, the percentiles for
    which the Lorenz ordinates are to be computed. The numbers in {it:numlist}
    must be within 0 and 100. Shorthand conventions as described in help
    {it:{help numlist}} may be applied. For example, to compute Lorenz
    ordinates from 0 to 100% in steps of 1 percentage point, type
    {cmd:percentiles(0(1)100)}. The numbers provided in {cmd:percentiles()} do
    not need to be equally spaced and do not need to cover the whole
    distribution. For example, to focus on the top 10% and use an increased
    resolution for the top 1% you could type 
    {cmd:percentiles(90(1)98 99(0.1)100)}.

{phang}
    {cmd:pvar(}{help varname:{it:pvar}}{cmd:)} causes concentration curves with
    respect to variable {it:pvar} to be computed. That is, the ordinates of the curves
    will be determined from observations sorted in ascending order of {it:pvar}
    instead of the outcome variable. Values of the outcome variable will be
    averaged within ties of {it:pvar}.

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
    {cmd:contrast}[{cmd:(}{it:spec}{cmd:)}] causes differences in Lorenz curves
    to be computed between outcome variables or between subpopulations, 
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

            {com}. lorenz estimate y1990 y2000 y2010, contrast(y1990){txt}

{pmore}
    computes differences in Lorenz curves with respect to {cmd:y1990}.
    Likewise, if {cmd:over()} is specified, {it:base} is the value of the
    subpopulation to be used as base. For example,

            {com}. lorenz estimate wage, over(race) contrast(1){txt}

{pmore}
    computes differences with respect to {cmd:race}==1. Alternatively, {it:base}
    may also be {cmd:#1}, {cmd:#2}, {cmd:#3}, etc. to use the 1st, 2nd, 3rd,
    etc. outcome variable or subpopulation as the base for the contrasts. For 
    example,

            {com}. lorenz estimate wage, over(race) contrast(#2){txt}

{pmore}
    uses the second subpopulation as base for the contrasts.

{phang}
    {cmd:graph}[{cmd:(}{help lorenz##groptions:{it:options}}{cmd:)}] draws
    a line graph of the results. {it:options} are as described for
    {helpb lorenz##groptions:lorenz graph} below.

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
    The {cmd:svy} option of {cmd:lorenz} only works if the variance
    estimation method is set to Taylor linearization by {helpb svyset} (the
    default). For other variance estimation methods you can use the usual {helpb svy}
    prefix command. For example, you could type {cmd:svy brr: lorenz ...} to
    use BRR variance estimation. {cmd:lorenz} does not allow the {helpb svy}
    prefix for Taylor linearization due to technical reasons. This is why the
    {cmd:svy} option is provided.

{phang}
    {opt nose} suppresses the computation of standard errors and confidence
    intervals. Use the {cmd:nose} option to speed-up computations, for example,
    when applying a prefix command that uses replication techniques for variance
    estimation, such as, e.g., {helpb svy jackknife}. Option {cmd:nose}
    is not allowed together with {cmd:vce()}, {cmd:cluster()}, or {cmd:svy}.

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
{title:Options for lorenz contrast}

{phang}
    {cmd:ratio} causes contrasts to be reported as ratios. The default is to 
    report contrasts as differences.
    
{phang}
    {cmd:lnratio} causes contrasts to be reported as logarithms of ratios. The
    default is to report contrasts as differences.

{phang}
    {cmd:graph}[{cmd:(}{help lorenz##groptions:{it:options}}{cmd:)}] draws
    a line graph of the results. {it:options} are as described for
    {helpb lorenz##groptions:lorenz graph} below.

{phang}
    {it:display_options} are standard reporting options such as {cmd:cformat()}, 
    {cmd:pformat()}, {cmd:sformat()}, or {cmd:coeflegend}. See 
    {helpb estimation options:[R] estimation options}.

{marker groptions}
{title:Options for lorenz graph}

{dlgtab:Main}

{phang}
    {opt proportion} scales the population axis in terms of proportions
    (0 to 1). The default is to scale the axis in terms of percentages (0 to 
    100).

{phang}
    {opt nodiagonal} omits the equal distribution diagonal that is included by
    default if graphing relative Lorenz or concentration curves. No equal 
    distribution diagonal is included if graphing equality gap curves or 
    total, generalized, or absolute Lorenz/concentration curves 
    or if graphing contrasts.

{marker diagonal}{...}
{phang}
    {opt diagonal(options)} affects the rendition of the equal distribution 
    diagonal. {it:options} are {it:line_options} as described in 
    {helpb line_options:[G] {it:line_options}}.

{marker keep}{...}
{phang}
    {opt keep(list)} selects and orders the results to be included as
    subgraphs. Use {cmd:keep()} if {cmd:lorenz estimate} has been applied to
    multiple outcome variables or subpopulations. In case of multiple outcome
    variables, {it:list} is a list of the names of the outcome variables to be
    included. Example:

            {com}. lorenz estimate y1990 y2000 y2010
            {com}. lorenz graph, keep(y2010 y1990){txt}

{pmore}
    In case of {cmd:over()}, {it:list} is a list of the values of the
    subpopulations to be included. {it:list} may also contain {cmdab:t:otal} for
    the overall results (if overall results were requested). Example:

           {com}. lorenz estimate wage, over(race) total
           {com}. lorenz graph, keep(total 1 2){txt}

{pmore}
    Furthermore, {it:list} may also contain elements such as {cmd:#1},
    {cmd:#2}, {cmd:#3}, etc. to refer to the 1st, 2nd, 3rd, etc. outcome
    variable or subpopulation. Example:

           {com}. lorenz estimate wage, over(race)
           {com}. lorenz graph, keep(#1 #3){txt}

{phang}
    {cmd:prange(}{it:min} {it:max}{cmd:)} restricts the range of the points
    to be included in the graph. Points whose abscissae lie outside  
    {it:min} and {it:max} will be omitted. {it:min} and {it:max} must 
    be within [0,100]. For example, to include only the upper half of the 
    distribution, type {cmd:prange(50 100)}.

{phang}
    {opt gini(%fmt)} sets the format for the Gini coefficients included in the
    subgraph or legend labels; see help {helpb format}. The default format is
    {cmd:%9.3g}. Gini coefficients will only be included if information on Gini
    coefficients is available in the provided results (i.e. if the {cmd:gini}
    option has been applied to {cmd:lorenz estimate}).

{phang}
    {cmd:nogini} suppresses the Gini coefficients. This is only relevant if the
    {cmd:gini} option has been specified when calling {cmd:lorenz estimate}.

{dlgtab:Labels/Rendering}

{phang}
    {it:connect_options} are options that affect the rendition of the plotted 
    lines. See {helpb connect_options:[G] {it:connect_options}}.

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
    subgraphs.

{marker oopts}{...}
{phang}
    {opt o#(options)} affects the rendition of the line of the #th outcome 
    variable or subpopulation if {cmd:overlay} has been specified. {it:options} are:

            {it:{help connect_options}}  rendition of the plotted line
            [{cmd:no}]{cmd:ci}           whether to draw the confidence interval
            {cmd:ciopts(}{help lorenz##ciopts:{it:options}}{cmd:)}  rendition of confidence interval (see below)

{dlgtab:Confidence intervals}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is the level that has been used when
    running {cmd:lorenz estimate}. {cmd:level()} cannot be used together
    with {cmd:ci(bc)}, {cmd:ci(bca)}, or {cmd:ci(percentile)}. To change the
    level for these confidence intervals, you need to specify {cmd:level()}
    when running {cmd:lorenz estimate}.

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
    when running {cmd:lorenz estimate}.

{marker ciopts}{...}
{phang}
    {opt ciopts(options)} specifies options that affect the rendition of the 
    plotted confidence areas. {it:options} are {it:area_options} as described in
    {helpb area_options:[G] {it:area_options}}.

{phang}
    {opt noci} omits confidence intervals from the plot.

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
        . {stata lorenz estimate wage}
        . {stata lorenz graph, aspectratio(1)}
        
        . {stata lorenz estimate wage, over(union)}
        . {stata lorenz graph, aspectratio(1) overlay}
        
        . {stata lorenz estimate wage, over(union) generalized}
        . {stata lorenz graph, overlay}

        . {stata lorenz estimate wage, over(union) generalized contrast(1)}
        . {stata lorenz graph, yline(0)}

{pstd}
    For further examples see {help lorenz##jann2016:Jann (2016)}.


{title:Stored results}

{pstd}
{cmd:lorenz estimate} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_over)}}number of subpopulations{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(ngrid)}}number of points in estimation grid{p_end}
{synopt:{cmd:e(df_r)}}sample degrees of freedom{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(level)}}confidence level for CIs{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:lorenz}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name(s) of outcome variable(s){p_end}
{synopt:{cmd:e(pvar)}}name of variable specified in {cmd:pvar()}{p_end}
{synopt:{cmd:e(type)}}{cmd:gap}, {cmd:sum}, {cmd:generalized}, {cmd:absolute} or empty{p_end}
{synopt:{cmd:e(percent)}}{cmd:percent} or empty{p_end}
{synopt:{cmd:e(norm)}}{it:#} or names of reference variables or empty{p_end}
{synopt:{cmd:e(normpop)}}{cmd:total} or {it:overvar} {cmd:=} {it:#} or empty{p_end}
{synopt:{cmd:e(normavg)}}{cmd:average} or empty{p_end}
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
{synopt:{cmd:e(b)}}estimates (Lorenz ordinates){p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of estimates{p_end}
{synopt:{cmd:e(p)}}population percentages (Lorenz abscissae){p_end}
{synopt:{cmd:e(_N)}}numbers of observations in subpopulations{p_end}
{synopt:{cmd:e(G)}}Gini coefficients (if {cmd:gini} is specified){p_end}

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
    Jann, B. (2016). {browse "https://www.stata-journal.com/article.html?article=st0457":Estimating Lorenz and concentration curves}. The
    Stata Journal 16(4):837–866. ({browse "http://ideas.repec.org/p/bss/wpaper/15.html":working paper})

{phang}
    Kovacevic, M. S., D. A. Binder (1997). Variance Estimation for 
    Measures of Income Inequality and Polarization - The Estimating Equations 
    Approach. Journal of Offcial Statistics 13(1): 41-58.


{title:Author}

{pstd}
    Ben Jann, University of Bern, ben.jann@soz.unibe.ch
    
{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B. (2016). lorenz: Stata module to estimate and display lorenz 
    curves and concentration curves. Available from 
    {browse "http://ideas.repec.org/c/boc/bocode/s458133.html"}.


{title:Also see}

{psee}
    Online:  help for 
    {helpb graph twoway line}

{psee}
    From the SSC Archive: 
    {stata ssc describe pshare:{bf:pshare}},
    {stata ssc describe svylorenz:{bf:svylorenz}},
    {stata ssc describe alorenz:{bf:alorenz}},
    {stata ssc describe clorenz:{bf:clorenz}},
    {stata ssc describe glcurve:{bf:glcurve}},
    {stata ssc describe ldtest:{bf:ldtest}}

