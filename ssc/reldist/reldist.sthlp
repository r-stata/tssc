{smcl}
{* 05jun2020}{...}
{viewerjumpto "Syntax" "reldist##syntax"}{...}
{viewerjumpto "Description" "reldist##description"}{...}
{viewerjumpto "Options" "reldist##options"}{...}
{viewerjumpto "Examples" "reldist##examples"}{...}
{viewerjumpto "Methods and formulas" "reldist##methods"}{...}
{viewerjumpto "Saved results" "reldist##saved_results"}{...}
{viewerjumpto "References" "reldist##references"}{...}
{hline}
help for {hi:reldist}
{hline}

{title:Title}

{pstd}{hi:reldist} {hline 2} Relative distribution analysis


{marker syntax}{...}
{title:Syntax}

{pstd}
    Estimation

{pmore}Two-sample relative distribution (syntax 1)

{p 12 21 2}
{cmd:reldist} {it:subcmd}
    {varname}
    {ifin} {weight}{cmd:,}  {cmd:by(}{help varname:{it:groupvar}}{cmd:)}
    [ {help reldist##opts:{it:options}} ]

{pmore}Paired relative distribution (syntax 2)

{p 12 21 2}
{cmd:reldist} {it:subcmd}
    {varname} {help varname:{it:refvar}} {ifin} {weight}
    [{cmd:,} {help reldist##opts:{it:options}} ]

{marker subcmd}{...}
{pmore}
    where {it:subcmd} is

{p2colset 13 24 26 2}{...}
{p2col:{opt pdf}}compute relative density{p_end}
{p2col:{opt hist:ogram}}compute relative histogram{p_end}
{p2col:{opt cdf}}compute cumulative relative distribution{p_end}
{p2col:{opt mrp}}compute median relative polarization{p_end}
{p2col:{opt su:mmarize}}summarize relative ranks{p_end}

{pstd}
    Replay results

{p 8 17 2}
{cmd:reldist} [{cmd:,} {opt nohead:er} {opt notab:le} {help reldist##display_opts:{it:display_options}} ]

{pstd}
    Draw graph after estimation

{p 8 17 2}
{cmd:reldist} {cmdab:gr:aph}
    [{cmd:,} {help reldist##graph_opts:{it:graph_options}} ]


{synoptset 26 tabbed}{...}
{marker opts}{col 5}{help reldist##options:{it:options}}{col 33}Description
{synoptline}
{syntab:{help reldist##mainopts:Main}}
{synopt:{opth by(groupvar)}}binary variable that identifies the groups (syntax 1 only)
    {p_end}
{synopt:{opt swap}}reverse order of groups (syntax 1 only)
    {p_end}
{synopt:{opt nobr:eak}}do not break ties when computing relative ranks
    {p_end}
{synopt:{opt nomid}}do not use midpoints when computing relative ranks
    {p_end}
{synopt:{opt pool:ed}}use pooled distribution as reference distribution
    {p_end}
{synopt:{cmdab:adj:ust(}{help reldist##adjust:{it:spec}}{cmd:)}}location and scale adjustment (not allowed for {cmd:mrp})
    {p_end}
{synopt:{cmdab:bal:ance(}{it:{help varlist:xvars}}[{cmd:,} {help reldist##balance:{it:opts}}]{cmd:)}}balance covariates (syntax 1 only)
    {p_end}

{syntab:{help reldist##pdfopts:Subcommand {bf:pdf}}}
{synopt:{opt n(#)}}number of evaluation points; default is {cmd:n(101)}
    {p_end}
{synopt:{cmd:at(}{help numlist:{it:numlist}}|{it:matname}{cmd:)}}use custom evaluation grid on probability scale
    {p_end}
{synopt:{cmd:atx}[{cmd:(}{help numlist:{it:numlist}}|{it:matname}{cmd:)}]}evaluate relative density at outcome values
    {p_end}
{synopt:{opt discr:ete}}treat data as discrete
    {p_end}
{synopt:{opt cat:egorical}}treat data as categorical
    {p_end}
{synopt:{cmdab:hist:ogram}[{cmd:(}{it:#}{cmd:)}]}include
    histogram using {it:#} bins; default is {it:#} = 10
    {p_end}
{synopt:{help reldist##density_opts:{it:density_options}}}density estimation options
    {p_end}
{synopt:{opt graph}[{cmd:(}{help reldist##graph_opts:{it:graph_options}}{cmd:)}]}display graph
    {p_end}
{synopt:{opt ogrid(#)} | {opt noogrid}}set size of outcome label approximation grid
    {p_end}

{syntab:{help reldist##histopts:Subcommand {bf:histogram}}}
{synopt:{opt n(#)}}number of histogram bins; default is {cmd:n(10)}
    {p_end}
{synopt:{opt graph}[{cmd:(}{help reldist##graph_opts:{it:graph_options}}{cmd:)}]}display graph
    {p_end}
{synopt:{opt ogrid(#)} | {opt noogrid}}set size of outcome label approximation grid
    {p_end}

{syntab:{help reldist##cdfopts:Subcommand {bf:cdf}}}
{synopt:{opt n(#)}}number of evaluation points; default is {cmd:n(101)}
    {p_end}
{synopt:{cmd:at(}{help numlist:{it:numlist}}|{it:matname}{cmd:)}}use custom evaluation grid on probability scale
    {p_end}
{synopt:{cmd:atx}[{cmd:(}{help numlist:{it:numlist}}|{it:matname}{cmd:)}]}evaluate relative CDF at outcome values
    {p_end}
{synopt:{opt discr:ete}}treat data as discrete
    {p_end}
{synopt:{opt cat:egorical}}treat data as categorical
    {p_end}
{synopt:{opt graph}[{cmd:(}{help reldist##graph_opts:{it:graph_options}}{cmd:)}]}display graph
    {p_end}
{synopt:{opt ogrid(#)} | {opt noogrid}}set size of outcome label approximation grid
    {p_end}

{syntab:{help reldist##mrpopts:Subcommand {bf:mrp}}}
{synopt:{cmd:over(}{help varname:{it:overvar}}{cmd:)}}compute results for subpopulations defined by {it:overvar}
    {p_end}
{synopt:{opt mult:iplicative}}use multiplicative (instead of additive) adjustment
    {p_end}
{synopt:{opt log:arithmic}}use logarithmic (instead of linear) adjustment
    {p_end}
{synopt:{opt sc:ale}[{cmd:(sd)}]}adjust scale between groups
    {p_end}

{syntab:{help reldist##sumopts:Subcommand {bf:summarize}}}
{synopt:{cmd:over(}{help varname:{it:overvar}}{cmd:)}}compute results for subpopulations defined by {it:overvar}
    {p_end}
{synopt:{cmdab:s:tatistics(}{help tabstat##statname:{it:statnames}}{cmd:)}}report
    specified statistics
    {p_end}
{synopt:{opth g:enerate(newvar)}}store the relative ranks in {it:newvar}
    {p_end}
{synopt:{opt r:eplace}}replace existing variable
    {p_end}

{syntab:{help reldist##seopts:SE/CI}}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt:{cmd:vce(}{help reldist##vce:{it:vcetype}}{cmd:)}}variance estimation method;
    {it:vcetype} may be {bf:bootstrap} or {bf:jackknife}
    {p_end}
{synopt:{opt nose}}do not compute standard errors
    {p_end}

{syntab:{help reldist##reprtopts:Reporting}}
{synopt:{opt nohead:er}}suppress display of output header
    {p_end}
{synopt:[{cmd:{ul:no}}]{cmdab:tab:le}}suppress/enforce display of coefficients table
    {p_end}
{synopt:{help reldist##display_opts:{it: display_options}}}standard reporting options
    {p_end}
{synoptline}
{pstd}
{cmd:fweight}s, {cmd:aweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see {help weight}.


{marker density_opts}{col 5}{help reldist##density_options:{it:density_options}}{col 33}Description
{synoptline}
{synopt:{cmdab:bw:idth(}{it:#}|{help reldist##bwidth:{it:method}}{cmd:)}}set bandwidth
    to {it:#}, {it:#} > 0, or choose bandwidth selection method; default is {cmd:bwidth(sjpi)}
    {p_end}
{synopt:{opt bwadj:ust(#)}}rescale bandwidth by {it:#}, {it:#} > 0
    {p_end}
{synopt:{opt adapt:ive(#)}}number of iterations of the adaptive
    density estimator; default is {cmd:adaptive(1)}
    {p_end}
{synopt:{cmdab:bo:undary(}{help reldist##boundary:{it:method}}{cmd:)}}boundary correction method;
    default is {cmd:boundary(renorm)}{p_end}
{synopt:{cmdab:k:ernel(}{help reldist##kernel:{it:kernel}}{cmd:)}}type of kernel function; default is
    {cmd:kernel(epan2)}
    {p_end}
{synopt:{opt na:pprox(#)}}set grid size of approximation estimator; default
    is {cmd:max(512,n())}
    {p_end}
{synopt:{opt exact}}use the exact density estimator
    {p_end}
{synoptline}


{marker graph_opts}{col 5}{help reldist##graph_options:{it:graph_options}}{col 33}Description
{synoptline}
{syntab:Main}
{synopt:{opth ref:line(line_options)}}affect rendition
    of parity line
    {p_end}
{synopt:{opt noref:line}}suppress the parity line
    {p_end}

{syntab:After subcommand {cmd:pdf}}
{synopt:{it:{help cline_options}}}affect rendition of PDF line
  {p_end}
{synopt:{cmdab:hist:opts(}{help reldist##histopts:{it:options}}{cmd:)}}affect
    rendition of histogram bars
    {p_end}
{synopt:{opt nohist:ogram}}omit histogram bars
    {p_end}

{syntab:After subcommand {cmd:histogram}}
{synopt:{it:{help barlook_options}}}affect rendition of histogram bars
    {p_end}

{syntab:After subcommand {cmd:cdf}}
{synopt:{opt noorig:in}}do not add (0,0) coordinate
    {p_end}
{synopt:{it:{help cline_options}}}affect rendition of CDF line
    {p_end}

{syntab:Confidence intervals}
{synopt:{opt l:evel(#)}}set confidence level; default is as set during estimation
    {p_end}
{synopt:{opt ci(name)}}obtain confidence intervals from {cmd:e(}{it:name}{cmd:)}
    {p_end}
{synopt:{opth ciopt:s(area_options)}}affect rendition of confidence intervals
    {p_end}
{synopt:{opt noci}}omit confidence intervals
    {p_end}

{syntab:Outcome labels}
{synopt:[{cmd:y}]{cmdab:olab:el:(}{help reldist##olabel:{it:spec}}{cmd:)}}add outcome labels
    on secondary axis
    {p_end}
{synopt:[{cmd:y}]{cmdab:otic:k:(}{help reldist##otick:{it:spec}}{cmd:)}}add outcome ticks
    on secondary axis
    {p_end}
{synopt:[{cmd:y}]{cmdab:oti:tle(}{help title_options:{it:tinfo}}{cmd:)}}title for outcome scale axis
    {p_end}

{syntab:General graph options}
{synopt:{cmd:addplot(}{it:{help addplot_option:plot}}{cmd:)}}add other plots to the generated graph
  {p_end}
{synopt:{it:{help twoway_options}}}any options other than {cmd:by()} documented in help
    {it:{help twoway_options}}
  {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
    {cmd:reldist} provides a set of tools for relative distribution analysis. For
    background information and details see Handcock and Morris (1998, 1999).

{phang}
    o  Command {cmd:reldist pdf} estimates the density function of the
    relative distribution, possibly including a histogram of the relative density.

{phang}
    o  Command {cmd:reldist histogram} estimates a histogram of the relative density.

{phang}
    o  Command {cmd:reldist cdf} estimates the relatibe distribution function. This is
    equivalent to a so-called probability-probability plot
     (see {helpb ppplot} from {stata ssc describe ppplot:SSC}).

{phang}
    o  Command {cmd:reldist mrp} estimates the
    median relative polarization index (MRP), as well as its decomposition into a
    lower and and upper polarization index (LRP and URP).

{phang}
    o  Command {cmd:reldist summarize} computes summary measures such as the mean
    and median of the relative data, and can also be used to store the relative
    ranks in a new variable.

{phang}
    o  Command {cmd:reldist graph} can be used after {cmd:reldist pdf},
    {cmd:reldist histogram}, or {cmd:reldist cdf} to plot the results.

{pstd}
    There are two syntaxes:

{phang}
    o  In syntax 1, the distribution of {it:depvar} is
    compared between two groups defined by the {cmd:by()} option
    (two-sample relative distribution).

{phang}
    o  In syntax 2, the distribution of
    {it:depvar} is compared to the distribution of {it:refvar} within the same
    sample (paired relative distribution).

{pstd}
    {cmd:reldist} requires {cmd:kdens}, {cmd:kmatch}, and {cmd:moremata}
    to be installed on the system. See
    {net "describe kdens, from(http://fmwww.bc.edu/repec/bocode/k/)":{bf:ssc describe kdens}},
    {net "describe kmatch, from(http://fmwww.bc.edu/repec/bocode/k/)":{bf:ssc describe kmatch}},
    and
    {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":{bf:ssc describe moremata}}.


{marker options}{...}
{title:Options}

{marker mainopts}{...}
{dlgtab:Main}

{phang}
    {opt by(groupvar)} specifies a binary variable that identifies the two groups
    to be compared. By default, the group with the lower value will be used as
    the reference group. {cmd:by()} is required in syntax 1 and not allowed
    in syntax 2.

{phang}
    {opt swap} reverses the order of the groups identified by {cmd:by()}. {opt swap} is
    only allowed in syntax 1.

{phang}
    {opt nobreak} changes how the relative ranks are computed in case of ties. By
    default, {cmd:reldist} breaks ties randomly for comparison values that have
    ties in the reference distribution (in ascending order of weights, if
    weights have been specified). This leads to improved results if there is
    heaping in the data. Specify {cmd:nobreak} to omit breaking ties. Option
    {cmd:nobreak} has no effect for {cmd:reldist cdf}.

{phang}
    {opt nomid} changes how the relative ranks are computed in case of ties. By
    default, {cmd:reldist} uses midpoints of the steps in the cumulative
    distribution for comparison values that have ties in the
    reference distribution. This ensures that the average
    relative rank is equal to 0.5 if the comparison and reference distributions
    are identical. Specify {cmd:nomid} to assign relative ranks based on full
    steps in the CDF. Option {cmd:nomid} has no effect for {cmd:reldist cdf}.

{phang}
    {opt pooled} uses the pooled distribution across both groups (syntax 1) or
    across both variables (syntax 2) as the reference distribution.

{pmore}
    Note that {helpb reldist##adjust:shape} adjustment of the comparison
    distribution is not supported by {cmd:reldist sum} in syntax 2 if option
    {cmd:pooled} is specified (because the resulting relative ranks cannot
    be stored without changing the data structure in this case). Use syntax 1
    on reshaped data to perform such an analysis; see help {helpb reshape}.

{marker adjust}{...}
{phang}
    {opt adjust(spec)} applies location, scale, and shape adjustments to
    the comparison and reference distributions. {cmd:adjust()} is not allowed
    with {cmd:reldist mrp}. The syntax of {it:spec} is

            [{it:adjust}] [{cmd::} {it:refadjust}] [{cmd:,} {it:options}]

{pmore}
    where {it:adjust} specifies the adjustments to be applied to the
    comparison distribution and {it:refadjust} specifies the adjustments to be applied to the
    reference distribution. {it:adjust} and {it:refadjust} may contain any combination of

            {cmdab:l:ocation}   adjust location
            {cmdab:sc:ale}      adjust scale
            {cmdab:sh:ape}      adjust shape

{pmore}
    For example, type {cmd:adjust(location scale)} to adjust the location and scale
    of the comparison distribution to the corresponding values of the reference
    distribution. Likewise, you could type {cmd:adjust(:location scale)} to adjust
    the reference distribution. Furthermore, {cmd:adjust(location : shape)} would
    adjust the location of the comparison distribution and the shape of the
    reference distribution. {it:options} are as follows:

{phang2}
    {opt mean} uses the mean for the location adjustment. The default is to
    use the median.

{phang2}
    {opt sd} uses the standard deviation for the scale adjustment. The default is
    to use the IQR (interquartile range).

{phang2}
    {opt mult:iplicative} uses a multiplicative adjustment instead of an additive
    adjustment. {cmd:scale} is not allowed in this case.

{phang2}
    {opt log:arithmic} performs the adjustments on logarithmically transformed
    data. The data must be strictly positive in this case.

{marker balance}{...}
{phang}
    {cmd:balance(}{it:{help varlist:xvars}}[{cmd:,} {it:options}{cmd:)} balances covariate
    distributions between the comparison group and the reference group using
    reweighting, where {it:xvars} specifies the list of covariates to be
    balanced (only allowed in syntax 1). The balancing weights are obtained
    using command {helpb kmatch}. {it:options} are as follows:

{phang2}
    {opt m:ethod(method)} specifies the estimation method to be used. Available
    methods are {cmd:ipw} (inverse probability weighting), {cmd:eb} (entropy balancing),
    {cmd:ps} (propensity score matching), {cmd:md} (multivariate distance matching), and
    {cmd:em} (exact matching). The default is {cmd:method(ipw)}. See {helpb kmatch}
    for details on the different methods.

{phang2}
    {it:{help kmatch:kmatch_options}} are options to be passed through to
    {helpb kmatch}. Available options depend on the chosen {it:method}.

{phang2}
    {opt ref:erence} reweights the covariate distribution of the reference group. The
    default is to reweight the covariate distribution of the comparison group. Option
    {cmd:pooled} is not allowed with {cmd:balance(, reference)}.

{phang2}
    {opt name(name)} stores the results from {helpb kmatch} under {it:name} using
    {helpb estimates store}.

{phang2}
    {opt nowarn} suppresses the warning message that is displayed if not all observations
    of the relevant target group can be matched due to lack of common support.

{phang2}
    {opt noi:sily} displays the output from {helpb kmatch}. Specifying {cmd:noisily} twice will
    display verbose output from {helpb kmatch}.

{marker pdfopts}{...}
{dlgtab:For subcommand -pdf-}

{phang}
    {opt n(#)} sets the number of evaluation points for which the PDF is to
    be computed. A regular grid of {it:#} evaluation points between 0 and 1 will
    be used. The default is {cmd:n(101)} (unless option {cmd:discrete}
    or {cmd:categorical} is specified, in which case {cmd:n()} has no
    default). Only one of {cmd:n()}, {cmd:at()}, and {cmd:atx()} is allowed.

{phang}
    {cmd:at(}{it:numlist}|{it:matname}{cmd:)} specifies a custom grid of
    evaluation points between 0 and 1, either by providing a
    {help numlist:{it:numlist}} or the name of a matrix containing the values
    (the values will be taken from the first row or the first column of the matrix,
    depending on which is larger). Only
    one of {cmd:n()}, {cmd:at()}, and {cmd:atx()} is allowed.

{phang}
    {cmd:atx}[{cmd:(}{it:numlist}|{it:matname}{cmd:)}], specified without argument,
    causes the relative PDF to be evaluated at each existing outcome value (possibly
    after applying {cmd:adjust()}), instead of using a regular evaluation grid
    on the probability scale. As an alternative to using the observed outcome values,
    it is also possible to specify a grid of custom values, either by providing a
    {help numlist:{it:numlist}} or the name of a matrix containing the values (the
    values will be taken from the first row or the first column of the matrix,
    depending on which is larger). Only one of {cmd:n()}, {cmd:at()},
    and {cmd:atx()} is allowed. The {cmd:vce()} option is not
    allowed if {cmd:atx()} is specified (unless {cmd:categorical} is also
    specified).

{phang}
    {cmd:discrete} causes the data to be treated as discrete. The relative PDF
    will then be evaluated at each level of the data as the ratio of the
    level's frequency between the comparison distribution and the reference
    distribution instead of using kernel density estimation, and the result
    will be displayed as a step function. If option {cmd:n()} or {cmd:at()} is
    specified, the step function will be evaluated at the points of the
    corresponding probability grid instead of returning the relative density
    for each outcome level. Options {cmd:nobreak}, {cmd:nomid} and
    {help reldist##density_options:{it:density_options}} have no effect if
    {cmd:discrete} is specified. Furthermore, options {cmd:histogram()} and
    {cmd:adjust()} are not allowed, and option {cmd:vce()} is only allowed if
    {cmd:n()}, {cmd:at()}, or {cmd:categorical} is specified in addition
    to {cmd:discrete}.

{phang}
    {cmd:categorical} has the same effect as {cmd:discrete}, but requests that
    the data only contains positive integers and uses factor-variable notation to
    label the coefficient in the output table.

{phang}
    {cmd:histogram}[{cmd:(}{it:#}{cmd:)}] requests that a histogram is computed in
    addition to the PDF, where {it:#} is the number of bins. If {it:#} is omitted,
    10 bins will be used.

{marker density_options}{...}
{phang}
    {it:density_options} set the details of the the kernel density estimation. The options
    are as follows:

{marker bwidth}{...}
{phang2}
    {opt bwidth(#|method)} determines the bandwidth of the kernel, the
    halfwidth of the estimation window around each evaluation point. Use
    {opt bwidth(#)}, {it:#} > 0, to set the bandwidth to a specific value. Alternatively,
    type {opt bwidth(method)} to choose an automatic bandwidth selection
    method. Choices are {cmdab:s:ilverman} (optimal of Silverman),
    {cmdab:n:ormalscale} (normal scale rule), {cmdab:o:versmoothed}
    (oversmoothed rule), {opt sj:pi} (Sheather-Jones plug-in estimate), and
    {cmdab:d:pi}[{cmd:(}{it:#}{cmd:)}] (a variant of the Sheather-Jones
    plug-in estimate called the direct plug-in estimate; {it:#}
    specifies the number of stages of functional estimation and defaults to 2). The default
    is {cmd:bw(sjpi)}. Note that the bandwidth
    selectors used by {cmd:reldist} have been modified for the purpose of relative
    density estimation (that is, they are different from their equivalents in regular
    density estimation).

{phang2}
    {opt bwadjust(#)} multiplies the bandwidth by
    {it:#}, where {it:#} > 0. Default is {cmd:bwadjust(1)}.

{marker boundary}{...}
{phang2}
    {opt boundary(method)} sets the type of boundary correction method. Choices are
    {opt ren:orm} (renormalization method), {opt refl:ect} (reflection method), or
    {opt lc} (linear combination technique).

{phang2}
    {opt adaptive(#)} specifies the number of iterations used by the adaptive
    kernel density estimator. The default is {cmd:adaptive(1)}. Specify
    {cmd:adaptive(0)} to use a non-adaptive density estimator.

{marker kernel}{...}
{phang2}
    {opt kernel(kernel)} specifies the kernel function to be used. {it:kernel} may
    be {opt e:panechnikov} (Epanechnikov kernel function),
    {opt epan2} (alternative Epanechnikov kernel function),
    {opt b:iweight} (biweight kernel function),
    {opt triw:eight} (triweight kernel function),
    {opt c:osine} (cosine trace),
    {opt g:aussian} (Gaussian kernel function),
    {opt p:arzen} (Parzen kernel function),
    {opt r:ectangle} (rectangle kernel function)
    or {opt t:riangle} (triangle kernel function). The default is
    {cmd:kernel(epan2)}.

{phang2}
    {opt napprox(#)} specifies the grid size used by the binned approximation
    density estimator (and by the data-driven bandwidth selectors). The default
    is {cmd:napprox(512)}, or the number of evaluation points requested
    by {cmd:n()}, {cmd:at()}, or {cmd:atx()}, if the latter is larger than
    the former.

{phang2}
    {cmd:exact} causes the exact kernel density estimator to be used instead
    of the binned approximation estimator. The exact estimator can be slow in large
    datasets. The Kullback-Leibler divergence and the Chi-squared
    divergence will not be computed if {cmd:exact} is specified.

{phang}
    {opt graph}[{cmd:(}{help reldist##graph_opts:{it:graph_options}}{cmd:)}]
    displays the results in a graph. The coefficients table will be suppressed
    in this case (unless option {cmd:table} is specified). Alternatively, use
    command {cmd:reldist graph} to display the graph after estimation.

{phang}
    {opt ogrid(#)} sets the size of the approximation grid for outcome
    labels. The default is {cmd:ogrid(201)}. The grid is stored in
    {cmd:e(ogrid)} and will be used by graph option
    {helpb reldist##olabel:olabel()} to determine the positions of outcome
    labels. Type {cmd:noogrid} to omit the computation of the grid (no outcome
    labels will then be available for the graph). Option {cmd:ogrid()} is only
    allowed if the relative density is computed with respect an evaluation grid
    on the probability scale. If the relative density is evaluated with respect to
    specific outcome values (e.g. if {cmd:atx()} is specified), the outcome
    labels will be obtained from the information stored in {cmd:e(at)}.

{marker histopts}{...}
{dlgtab:For subcommand -histogram-}

{phang}
    {opt n(#)} specifies the number of histogram bars. The reference distribution
    will be divided into {it:#} bins of equal width. That is, each bin will
    cover 1/{it:#}th of the reference distribution. The default is {cmd:n(10)}.

{phang}
    {opt graph}[{cmd:(}{help reldist##graph_opts:{it:graph_options}}{cmd:)}]
    displays the results in a graph. The coefficients table will be suppressed
    in this case (unless option {cmd:table} is specified). Alternatively, use
    command {cmd:reldist graph} to display the graph after estimation.

{phang}
    {opt ogrid(#)} sets the size of the approximation grid for outcome
    labels. The default is {cmd:ogrid(201)}. The grid is stored in {cmd:e(ogrid)} and
    will be used by graph option {helpb reldist##olabel:olabel()} to determine
    the positions of outcome labels. Type {cmd:noogrid} to omit the computation
    of the grid (no outcome labels will then be available for the graph).

{marker cdfopts}{...}
{dlgtab:Subcommand -cdf-}

{phang}
    {opt n(#)} sets the number of evaluation points for which the CDF is to
    be computed. A regular grid of {it:#} evaluation points between 0 and 1 will
    be used. The default is {cmd:n(101)} (unless option {cmd:discrete}
    or {cmd:categorical} is specified, in which case {cmd:n()} has no
    default). Only one of {cmd:n()}, {cmd:at()}, and
    {cmd:atx()} is allowed.

{phang}
    {cmd:at(}{it:numlist}|{it:matname}{cmd:)} specifies a custom grid of
    evaluation points between 0 and 1, either by providing a
    {help numlist:{it:numlist}} or the name of a matrix containing the values
    (the values will be taken from the first row or the first column of the matrix,
    depending on which is larger). Only one of {cmd:n()}, {cmd:at()}, and {cmd:atx()}
    is allowed.

{phang}
    {cmd:atx}[{cmd:(}{it:numlist}|{it:matname}{cmd:)}], specified without argument,
    causes the relative CDF to be evaluated at each existing outcome value (possibly
    after applying {cmd:adjust()}), instead of using a regular evaluation grid
    on the probability scale. As an alternative to using the observed
    outcome values, it is also possible to specify a grid of custom values,
    either by providing a {help numlist:{it:numlist}} or the name of a matrix
    containing the values (the values will be taken from the first row or the
    first column of the matrix, depending on which is larger). Only one of
    {cmd:n()}, {cmd:at()}, and {cmd:atx()} is allowed. The {cmd:vce()} option
    is not allowed if {cmd:atx()} is specified (unless {cmd:categorical} is also
    specified).

{phang}
    {cmd:discrete} causes the data to be treated as discrete. The relative CDF
    will then be evaluated at each observed outcome value instead of using an
    evaluation grid on the probability scale. Option {cmd:discrete} leads to the
    same result as specifying {cmd:atx}. Option {cmd:adjust()} is not allowed
    if {cmd:discrete} is specified. Furthermore, option {cmd:vce()} is only allowed if
    {cmd:n()}, {cmd:at()}, or {cmd:categorical} is specified in addition
    to {cmd:discrete}.

{phang}
    {cmd:categorical} has the same effect as {cmd:discrete}, but requests that
    the data only contains positive integers and uses factor-variable notation to
    label the coefficient in the output table.

{phang}
    {opt graph}[{cmd:(}{help reldist##graph_opts:{it:graph_options}}{cmd:)}]
    displays the results in a graph. The coefficients table will be suppressed
    in this case (unless option {cmd:table} is specified). Alternatively, use
    command {cmd:reldist graph} to display the graph after estimation.

{phang}
    {opt ogrid(#)} sets the size of the approximation grid for outcome
    labels. The default is {cmd:ogrid(201)}. The grid is stored in
    {cmd:e(ogrid)} and will be used by graph option
    {helpb reldist##olabel:olabel()} to determine the positions of outcome
    labels. Type {cmd:noogrid} to omit the computation of the grid (no outcome
    labels will then be available for the graph). Option {cmd:ogrid()} is only
    allowed if the relative CDF is computed with respect an evaluation grid
    on the probability scale. If the relative CDF is evaluated with respect to
    specific outcome values (e.g. if {cmd:atx()} is specified), the outcome
    labels will be obtained from the information stored in {cmd:e(at)}.

{marker mrpopts}{...}
{dlgtab:For subcommand -mrp-}

{phang}
    {cmd:over(}{help varname:{it:overvar}}{cmd:)} computes results for each subpopulation defined
    by the values of {it:overvar}.

{phang}
    {opt multiplicative} applies a multiplicative location adjustment. The
    default is to use an additive adjustment. Only one of
    {cmd:logarithmic} and {cmd:multiplicative} is allowed.

{phang}
    {opt logarithmic} causes the location (and, optionally, scale)
    adjustment to be performed on the logarithmic scale. Only one of
    {cmd:logarithmic} and {cmd:multiplicative} is allowed.

{phang}
    {opt scale}[{cmd:(sd)}] adjusts the scale of the data before
    computing the polarization indices. If {cmd:scale} is specified without argument,
    the IQR (interquartile range) is used; that is, the scale of the data in the
    comparison group/variable is adjusted such that the IQR is the same as in the
    reference group/variable. Specify
    {cmd:scale(sd)} to use the standard deviation instead of the IQR. {cmd:scale}
    is not allowed if {cmd:multiplicative} is specified.

{marker sumopts}{...}
{dlgtab:For subcommand -summarize-}

{phang}
    {cmd:over(}{help varname:{it:overvar}}{cmd:)} computes results for each subpopulation defined
    by the values of {it:overvar}.

{phang}
    {cmd:statistics(}{help tabstat##statname:{it:statnames}}{cmd:)} selects the
    summary statistics to be reported. All statistics supported by {helpb tabstat}
    are allowed. The default is {cmd:statistics(mean)}.

{phang}
    {opth generate(newvar)} stores the relative ranks (based on adjusted data) in
    variable {it:newvar}. Depending on {cmd:adjust()}, different observations
    may be filled in.

{phang}
    {opt replace} allows replacing an existing variable.

{marker seopts}{...}
{dlgtab:SE/CI}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)} or as set by
    {helpb set level}.

{marker vce}{...}
{phang}
    {opth vce(vcetype)} determines how standard errors and confidence intervals
    are computed. {it:vcetype} may be:

            {cmd:bootstrap} [{cmd:,} {help bootstrap:{it:bootstrap_options}}]
            {cmd:jackknife} [{cmd:,} {help jackknife:{it:jackknife_options}}]

{pmore}
    By default, {cmd:reldist pdf} computes standard errors for the density estimates
    using analytic formulas. These standard errors may not be reliable in all
    situations and it may be better to resort to
    {cmd:bootstrap} or {cmd:jackknife}. Note that {cmd:reldist} also allows
    replication-based survey estimation using the {helpb svy} prefix,
    e.g. {cmd:svy brr}.

{pmore}
    All other subcommands do not compute standard errors by
    default.

{pmore}
    In case of density estimation with automatic bandwidth selection,
    the bandwidth is held fixed across bootstrap or jackknife
    replications invoked by {cmd:vce()}. If you want to repeat bandwidth
    search in each replication, use the {helpb bootstrap} or {helpb jackknife}
    prefix command.

{phang}
    {opt nose} prevents {cmd:reldist pdf} from computing standard errors for the
    density estimates. This may save some computer time.

{marker reprtopts}{...}
{dlgtab:Reporting}

{phang}
    {opt noheader} suppress the output header.

{phang}
    {cmd:notable} suppresses the output table containing the estimated
    coefficients. {cmd:table} enforces displaying the table.

{marker display_opts}{...}
{phang}
    {it: display_options} are standard reporting options such as {cmd:cformat()} or
    {cmd:coeflegend}; see the Reporting options
    in {helpb estimation options:[R] Estimation options}.


{marker graph_options}{...}
{title:Options for reldist graph}

{dlgtab:Main}

{phang}
    {opt refline(line_options)} specifies options to affect
    the rendition of parity line. See help {it:{help line_options}}.

{phang}
    {opt norefline} suppresses the parity  line.

{dlgtab:After subcommand -pdf-}

{phang}
    {it:cline_options} affect the rendition of the PDF line. See
    help {it:{help cline_options}}.

{phang}
    {opt hist:opts(options)} specifies options to affect the
    rendition of the histogram bars (if a histogram was computed) and the
    corresponding confidence spikes. {it:options} are as follows:

{phang2}
    {it:barlook_options} affect the rendition of the histogram bars. See
    help {it:{help barlook_options}}.

{phang2}
    {opt ciopts(rcap_options)} specifies options to affect the
    rendition of the confidence spikes of the histogram bars (if
    histogram standard errors were computed). See help
    {it:{help rcap_options}}.

{phang2}
    {opt noci} omits the confidence spikes of the histogram bars.

{phang}
    {opt nohistogram} omits the histogram bars.

{dlgtab:After subcommand -histogram-}

{phang}
    {it:barlook_options} affect the rendition of the histogram bars. See
    help {it:{help barlook_options}}.

{dlgtab:After subcommand -cdf-}

{phang}
    {opt noorigin} prevents adding a (0,0) coordinate to the plotted
    line. If the first Y-coordinate of the CDF is larger
    than zero and the range of the CDF has not been restricted by {cmd:at()} or
    {cmd:atx()}, {cmd:reldist graph} will automatically add a
    (0,0) coordinate to the plot. Type {opt noorigin}
    to override this behavior.

{phang}
    {it:cline_options} affect the rendition of the CDF line. See
    help {it:{help cline_options}}.

{dlgtab:Confidence intervals}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default level is as set during estimation.

{phang}
    {opt ci(name)} obtains the confidence intervals from
    {cmd:e(}{it:name}{cmd:)} instead of computing them from {cmd:e(V)} or
    {cmd:e(se)}. {cmd:e(}{it:name}{cmd:)} must contain two rows and
    the same number of columns as {cmd:e(b)}. For example, after
    bootstrap estimation, you could use {cmd:ci(ci_percentile)} to plot
    percentile confidence intervals. {cmd:ci()} and
    {cmd:level()} are not both allowed.

{phang}
    {opt ciopts(options)} specifies options to affect the
    rendition of the confidence intervals. See
    help {it:{help area_options}} or, after, {cmd:reldist histogram}
    help {it:{help rcap_options}}. Use option {cmd:recast()} to change the
    plot type used for confidence intervals. For example, type
    {cmd:ciopts(recast(rline))} to use two lines instead of an area.

{phang}
    {opt noci} omits the confidence intervals.

{marker olabel}{...}
{dlgtab:Outcome labels}

{phang}
    [{cmd:y}]{opt olabel(spec)} adds outcome labels on a secondary
    axis. The syntax of {it:spec} is

            {it:{help numlist}} [{cmd:,} {it:suboptions} ]

{pmore}
    where {it:suboptions} are as described in help
    {it:{help axis_label_options}}. Depending on context, the positions of
    the outcome labels are obtained form the quantiles stored
    in {cmd:e(ogrid)} or from the values stored in
    {cmd:e(at)}.

{pmore}
    {cmd:olabel()} adds outcome labels for the reference distribution; {cmd:yolabel()}
    adds outcome labels for the comparison distribution (only allowed after
    {cmd:reldist cdf}).

{phang}
    [{cmd:y}]{opt otick(spec)} adds outcome ticks on a secondary axis. Syntax
    and computation is as for {cmd:olabel()}. {cmd:otick()} adds
    outcome ticks for the reference distribution; {cmd:yotick()} adds outcome
    ticks for the comparison distribution (only allowed after
    {cmd:reldist cdf}).

{phang}
    [{cmd:y}]{opt otitle(tinfo)} provides a title for the outcome scale
    axis; see help {it:{help title_options}}. {cmd:otitle()} is for the reference
    distribution; {cmd:yotitle()} is for the comparison distribution (only
    allowed after {cmd:reldist cdf}).

{pstd}
    Technical note: There is an undocumented command called {cmd:reldist olabel} that can be
    used to compute label positions after the relative distribution has been
    estimated. Use this command, for example, if you want to draw a custom
    graph from the stored results without applying {cmd:reldist graph}. The
    syntax is as follows:

{p 8 17 2}
    {cmd:reldist} {opt olab:el} [{it:{help numlist}}] [{cmd:,}
        {opth for:mat(%fmt)} {opth otic:k(numlist)} {opt y} ]

{pstd}
    where {it:numlist} specifies values for which labels be generated,
    {cmd:format()} specifies the display format for the labels, {cmd:otick()}
    specifies values for which ticks be generated, and {cmd:y} request outcome labels
    for the Y axis of the relative CDF (only allowed after
    {cmd:reldist cdf}). The command returns the following macros in {cmd:r()}:

{p2colset 9 22 22 2}{...}
{p2col:{cmd:r(label)}}label specification for use in an {helpb axis_label_options:xlabel()} option
    {p_end}
{p2col:{cmd:r(label_x)}}expanded and sorted {it:numlist}
    {p_end}
{p2col:{cmd:r(tick)}}tick specification for use in an {helpb axis_label_options:xtick()} option
    {p_end}
{p2col:{cmd:r(tick_x)}}expanded and sorted {it:numlist} from {cmd:otick()}
    {p_end}

{dlgtab:General graph options}

{phang}
    {opt addplot(plot)} provides a way to add other plots to the
    generated graph. See help {it:{help addplot_option}}.

{phang}
    {it:twoway_options} are any options other than {cmd:by()} documented in help
    {it:{help twoway_options}}.


{marker examples}{...}
{title:Examples}

{dlgtab:Relative density and histogram}

{pstd}
    Compare the wages of unionized and non-unionized workers:

        . {stata sysuse nlsw88, clear}
        . {stata reldist pdf wage, by(union)}
{p 8 12 2}
        . {stata reldist graph, ciopts(recast(rline) lp(dash) pstyle(p1))}

{pstd}
    To get an idea of the hourly wages that correspond to different positions in
    the reference distribution, we can add some outcome labels using the {cmd:olabel()}
    option:

{p 8 12 2}
        . {stata reldist graph, olabel(2(1)8 10 12 20) otitle(hourly wage)}

{pstd}
    To include a histogram in addition to the density curve, type:

{p 8 12 2}
        . {stata reldist pdf wage, by(union) histogram}
        {p_end}
{p 8 12 2}
        . {stata reldist graph, ciopts(recast(rline) lp(dash) pstyle(p1))}

{pstd}
    Or, to display only the histogram:

        . {stata reldist histogram wage, by(union) vce(bootstrap, reps(100))}
        . {stata reldist graph}

{pstd}
    Since unionized workers have, on average, higher wages than non-unionized workers,
    we might want to adjust the location of their wage distribution to see
    the difference in the distributional shape between the two groups, net of the
    difference in location:

{p 8 12 2}
        . {stata reldist pdf wage, by(union) adjust(location) notable}
        {p_end}
{p 8 12 2}
        . {stata reldist graph, ciopts(recast(rline) lp(dash) pstyle(p1))}

{pstd}
    Interestingly, the distribution among unionized workers appears more polarized, at
    least in the lower part of the distribution. However, this may be a
    misleading result because, by default, {cmd:reldist} performs an
    additive location shift (pushing low-wage earners among the unionized
    to the very bottom of the distribution). Since wages can only be positive,
    it probably makes more sense to use a multiplicative shift (i.e., rescale the
    wages proportionally):

{p 8 12 2}
        . {stata reldist pdf wage, by(union) adjust(location, multiplicative) notable}
        {p_end}
{p 8 12 2}
        . {stata reldist graph, ciopts(recast(rline) lp(dash) pstyle(p1))}

{pstd}
    We now see that the distribution among the unionized is less polarized than the
    distribution among non-unionized workers, especially in the upper part of the
    distribution.

{dlgtab:Cumulative distribution}

{pstd}
    The cumulative relative distribution can be graphed as follows:

        . {stata sysuse nlsw88, clear}
        . {stata reldist cdf wage, by(union) graph}

{pstd}
    After applying a multiplicative location shift, the relative distribution
    looks as follows:

{p 8 12 2}
        . {stata reldist cdf wage, by(union) adjust(location, multiplicative) graph}

{dlgtab:Median relative polarization}

{pstd}
    An analysis of relative polarization between unionized and non-unionized workers by
    qualification leads to the following results:

        . {stata sysuse nlsw88, clear}
{p 8 12 2}
        . {stata reldist mrp wage, by(union) over(collgrad) vce(bootstrap, reps(100))}

{pstd}
    It appears that wage polarization is more pronounced among unionized workers than among the
    non-unionized workers in the group of people without college degree. In the group of
    people with college degree, polarization is higher among non-unionized workers. Again, this might
    be an artifact due to the default additive location adjustment imposed by the MRP. A multiplicative
    adjustment (i.e. rescaling wages proportionally) makes more sense:

{p 8 12 2}
        . {stata reldist mrp wage, by(union) over(collgrad) multiplicative vce(bootstrap, reps(100))}

{pstd}
    We now see that polarization is generally larger among the non-unionized workers, but there
    are still some interesting differences. For people without college degree the wage distribution
    is compressed mostly at the top, for people with college degree the
    compression appears more pronounced in the lower part of the distribution.

{dlgtab:Summary statistics}

{pstd}
    To obtain the mean an median rank of unionized workers in the
    wage distribution of non-unionized workers by
    qualification, type:

        . {stata sysuse nlsw88, clear}
{p 8 12 2}
        . {stata reldist summarize wage, by(union) over(collgrad) stat(mean median) vce(bootstrap, reps(100))}
        {p_end}

{pstd}
    Being unionized seems to pay off more for people without college degree than for
    people with college degree.

{dlgtab:Paired data relative distribution (syntax 2)}

{pstd}
    {cmd:reldist} can also be used to compare the distributions of two variables within the
    same sample of observations:

        . {stata webuse nlswork, clear}
        . {stata keep idcode year ln_wage}
        . {stata reshape wide ln_wage, i(idcode) j(year)}
        . {stata reldist pdf ln_wage88 ln_wage78, graph}

{pstd}
    It appears that log wages in 1988 have been more
    polarized than in 1978, which might be due to an age effect or a general increase
    in wage inequality. The result is confirmed by the MRP:

        . {stata reldist mrp ln_wage88 ln_wage78, vce(bootstrap, reps(100))}

{dlgtab:Covariate balancing}

{pstd}
    The {helpb reldist##balance:balance()} option can be used to balance covariate
    distributions before computing the relative distribution. Example:

        . {stata sysuse nlsw88, clear}
{p 8 12 2}
        . {stata reldist pdf wage, by(union) balance(grade i.race ttl_exp) notable}
        {p_end}
        . {stata estimates store balanced}
{p 8 12 2}
        . {stata reldist pdf wage if e(sample), by(union) notable}
        {p_end}
        . {stata estimates store raw}
{p 8 12 2}
        . {stata coefplot raw balanced, at(at) noci recast(line) lw(*2) yline(1)}
        {p_end}

{pstd}
    We see that balancing the specified covariances makes the wage distribution between
    unionized and non-unionized workers somewhat more similar, but not very much.

{pstd}
    By default, inverse-probability weighting is used to balance the
    covariates. However, you may also use more sophisticated methods such as
    entropy balancing or nearest-neighbor matching; see the {helpb reldist##balance:balance()}
    option above.

{dlgtab:Location and shape decompositions}

{pstd}
    Handcock and Morris (1999) discuss location and shape decompositions defined in
    a way such that for each outcome value the product of the location component
    and the shape component equals the overall relative density. For example,
    let {it:f}({it:y}) be the density
    of {it:y} in the comparison distribution, {it:f0}({it:y}) be the
    density of {it:y} in the reference distribution, {it:f0L}({it:y}) be the
    density of {it:y} in the location-adjusted reference distribution. The relative
    density can then be written as

        {it:f}({it:y})      {it:f0L}({it:y})      {it:f}({it:y})
        -----  =  ------  x  ------
        {it:f0}({it:y})     {it:f0}({it:y})      {it:f0L}({it:y})

{pstd}
    where the first term is the location component and the second term is the
    shape component of the decomposition. The components of such a decomposition
    can be computed by {cmd:reldist} using the {cmd:adjust()} option. It can be
    tricky, however, to figure out how exactly the option has to be specified.
    In the first term of the above decomposition (location component), we have to
    compare the location-adjusted reference distribution with the unadjusted
    reference distribution. Note that the location adjusted reference
    distribution is the same as the shape (and scale) adjusted comparison
    distribution. Hence, the first term can be computed using option
    {cmd:adjust(shape scale)}. For the second term, we compare the (unadjusted)
    comparison distribution with the location-adjusted reference
    distribution. This can be accomplished specifying {cmd:adjust(:location)}
    (note the colon; see the description of the
    {helpb reldist##adjust:adjust()} option above). Example:

        . {stata sysuse nlsw88, clear}
{p 8 12 2}
        . {stata reldist pdf wage, by(union) adjust(shape scale) graph}
        {p_end}
{p 8 12 2}
        . {stata "reldist pdf wage, by(union) adjust(: location) graph"}

{pstd}
    Similarly, to make the adjustments on the logarithmic scale, we could type

{p 8 12 2}
        . {stata reldist pdf wage, by(union) adjust(shape scale, logarithmic) graph}
        {p_end}
{p 8 12 2}
        . {stata "reldist pdf wage, by(union) adjust(: location, logarithmic) graph"}

{pstd}
    In the multiplicative case, no distinction is made between
    scale and shape (i.e. the shape adjustment includes the scale), so that the
    syntax would be:

{p 8 12 2}
        . {stata reldist pdf wage, by(union) adjust(shape, multiplicative) graph}
        {p_end}
{p 8 12 2}
        . {stata "reldist pdf wage, by(union) adjust(: location, multiplicative) graph"}

{pstd}
    In this situation, the multiplicative approach and the logarithmic approach lead to
    equivalent results. The logarithmic approach, however, provides more flexibility because
    it is possible to control the shape, net of scale. This is useful for more complicated
    decompositions.

{pstd}
    Note that the above decomposition might as well have been written as

        {it:f}({it:y})      {it:f}({it:y})      {it:fL}({it:y})
        -----  =  -----  x  -----
        {it:f0}({it:y})     {it:fL}({it:y})     {it:f0}({it:y})

{pstd}
    where {it:fL}({it:y}) is the density of {it:y} in the location-adjusted
    comparison distribution. To obtain this variant of the decomposition specify
    {cmd:adjust(:shape scale)} for the first term (location component)
    and {cmd:adjust(location)} for the second term (shape component).


{marker methods}{...}
{title:Methods and formulas}

{pstd}
    For methodological details on the relative distribution see
    Handcock and Morris (1999). The relative density is estimated by
    kernel density methods; see
    {browse "http://boris.unibe.ch/69421/2/kdens.pdf":Jann (2007)}. The statistics
    labeled "Divergence" and "Chi-squared" in the output of
    {cmd:reldist pdf} are estimates of the Kullback-Leibler divergence defined as

        {it:D} = int_0^1 {it:p}({it:r}) ln({it:p}({it:r})) d{it:r}

{pstd}
    and the Chi-squared divergence defined as

        {it:Chi2} = int_0^1 ({it:p}({it:r}) - 1)^2 d{it:r}

{pstd}
    where where {it:p}({it:r}) is the relative density.


{marker saved_results}{...}
{title:Saved results}

{pstd}
    {cmd:reldist} stores the following results in {cmd:e()}.

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N1)}}number of observations in comparison group (syntax 1 only){p_end}
{synopt:{cmd:e(N0)}}number of observations in reference group (syntax 1 only){p_end}
{synopt:{cmd:e(by1)}}value of comparison group (syntax 1 only){p_end}
{synopt:{cmd:e(by0)}}value of reference group (syntax 1 only){p_end}
{synopt:{cmd:e(Nout)}}number of unmatched observations (if {cmd:balance()} has been specified){p_end}
{synopt:{cmd:e(N_over)}}number over-groups (if {cmd:over()} has been specified){p_end}
{synopt:{cmd:e(n)}}number of evaluation points ({cmd:pdf} and {cmd:cdf} only){p_end}
{synopt:{cmd:e(bwidth)}}bandwidth of kernel ({cmd:pdf} only){p_end}
{synopt:{cmd:e(bwadjust)}}bandwidth adjustment factor ({cmd:pdf} only){p_end}
{synopt:{cmd:e(adaptive)}}number of iterations of adaptive estimator ({cmd:pdf} only){p_end}
{synopt:{cmd:e(napprox)}}size of approximation grid ({cmd:pdf} only){p_end}
{synopt:{cmd:e(divergence)}}value of Kullback-Leibler divergence ({cmd:pdf} only){p_end}
{synopt:{cmd:e(chi2)}}value of Chi-squared divergence ({cmd:pdf} only){p_end}
{synopt:{cmd:e(n_hist)}}number of histogram bins ({cmd:pdf} and {cmd:histogram} only){p_end}
{synopt:{cmd:e(hwidth)}}width of histogram bins ({cmd:pdf} and {cmd:histogram} only){p_end}
{synopt:{cmd:e(k_omit)}}number of omitted estimates{p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:reldist}{p_end}
{synopt:{cmd:e(subcmd)}}{cmd:pdf}, {cmd:histogram}, {cmd:cdf}, {cmd:mrp}, or {cmd:summarize}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(by)}}name of {it:groupvar} (syntax 1 only){p_end}
{synopt:{cmd:e(by1lab)}}label of comparison group (syntax 1 only){p_end}
{synopt:{cmd:e(by0lab)}}label of reference group (syntax 1 only){p_end}
{synopt:{cmd:e(refvar)}}name of {it:refvar} (syntax 2 only){p_end}
{synopt:{cmd:e(nobreak)}}{cmd:nobreak} or empty{p_end}
{synopt:{cmd:e(nomid)}}{cmd:nomid} or empty{p_end}
{synopt:{cmd:e(atx)}}{cmd:atx} or empty{p_end}
{synopt:{cmd:e(discrete)}}{cmd:discrete} or empty{p_end}
{synopt:{cmd:e(categorical)}}{cmd:categorical} or empty{p_end}
{synopt:{cmd:e(origin)}}{cmd:origin} or empty{p_end}
{synopt:{cmd:e(pooled)}}{cmd:pooled} or empty{p_end}
{synopt:{cmd:e(adjust)}}list of comparison distribution adjustments{p_end}
{synopt:{cmd:e(refadjust)}}list of reference distribution adjustments{p_end}
{synopt:{cmd:e(adjmean)}}{cmd:mean} or empty{p_end}
{synopt:{cmd:e(adjsd)}}{cmd:sd} or empty{p_end}
{synopt:{cmd:e(adjlog)}}{cmd:logarithmic} or empty{p_end}
{synopt:{cmd:e(adjmult)}}{cmd:multiplicative} or empty{p_end}
{synopt:{cmd:e(balance)}}list of balancing variables{p_end}
{synopt:{cmd:e(balmethod)}}balancing method{p_end}
{synopt:{cmd:e(balref)}}{cmd:reference} or empty{p_end}
{synopt:{cmd:e(balopts)}}options passed through to {cmd:kmatch}{p_end}
{synopt:{cmd:e(over)}}name of {it:overvar}{p_end}
{synopt:{cmd:e(over_namelist)}}values of over variable{p_end}
{synopt:{cmd:e(over_labels)}}values of over variable{p_end}
{synopt:{cmd:e(boundary)}}boundary correction method ({cmd:pdf} only){p_end}
{synopt:{cmd:e(bwmethod)}}bandwidth selection method ({cmd:pdf} only){p_end}
{synopt:{cmd:e(kernel)}}kernel function ({cmd:pdf} only){p_end}
{synopt:{cmd:e(exact)}}{cmd:exact} or empty ({cmd:pdf} only){p_end}
{synopt:{cmd:e(statistics)}}names of reported statistics ({cmd:summarize} only){p_end}
{synopt:{cmd:e(generate)}}name of generated variable ({cmd:summarize} only){p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b} or {cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}estimates{p_end}
{synopt:{cmd:e(se)}}standard errors ({cmd:pdf} only){p_end}
{synopt:{cmd:e(at)}}evaluation points ({cmd:pdf}, {cmd:histogram}, and {cmd:cdf} only){p_end}
{synopt:{cmd:e(ogrid)}}outcome label approximation grid ({cmd:pdf}, {cmd:histogram}, and {cmd:cdf} only){p_end}
{synopt:{cmd:e(_N)}}numbers of obs per over-group (if {cmd:over()} had been specified){p_end}
{synopt:{cmd:e(_N1)}}numbers of obs per over-group in comparison group (syntax 1 only){p_end}
{synopt:{cmd:e(_N0)}}numbers of obs per over-group in reference group (syntax 1 only){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}
{p2colreset}{...}

{pstd}
    If {cmd:vce()} is {cmd:bootstrap} or {cmd:jackknife}, additional results as described
    in help {helpb bootstrap} and {helpb jackknife} are stored in {cmd:e()}.


{marker references}{...}
{title:References}

{phang}
    Handcock, Mark S., Martina Morris (1998). Relative Distribution Methods.
    Sociological Methodology 28: 53-97.
    {p_end}
{phang}
    Handcock, Mark S., Martina Morris (1999). Relative Distribution Methods
    in the Social Sciences. New York: Springer.
    {p_end}
{phang}
    Jann, B. (2007). Univariate kernel density
    estimation. DOI: {browse "http://boris.unibe.ch/69421/2/kdens.pdf":10.7892/boris.69421}.
    {p_end}


{marker author}{...}
{title:Author}

{pstd}
    Ben Jann, University of Bern, ben.jann@soz.unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B. (2020). reldist: Stata module for relative distribution analysis. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458775.html"}.


{marker also_see}{...}
{title:Also see}

{psee}
    Online: help for {helpb cumul}, {helpb kmatch}, {helpb kdens}, {helpb moremata}

