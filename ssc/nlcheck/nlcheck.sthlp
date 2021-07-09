{smcl}
{* 15oct2008}{...}
{hi:help nlcheck}
{hline}

{title:Title}

{pstd}{hi:nlcheck} {hline 2} Check linearity assumption after model estimation


{title:Syntax}

{p 8 15 2}
    {cmd:nlcheck} {varname} [{varlist}]
    [{cmd:,}
    {help nlcheck##opt:{it:options}}
    ]


{synoptset 22 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{syntab :Main}
{synopt :{opt b:ins(#)}}number of bins for the adaptive fit; default is
    {cmd:bins(10)}
    {p_end}
{synopt :{opt s:pline}}use linear spline instead of bins
    {p_end}
{synopt :{opt k:nots(#)}}number of knots for the spline fit; default is
    {cmd:knots(9)}
    {p_end}
{synopt :{opt eq:freq}}use equal frequency bins
    {p_end}
{synopt :{opt d:iscrete}}treat {it:varname} as a discrete variable
    {p_end}
{synopt :{opt noi:sily}}display adaptive model estimation results
    {p_end}

{syntab :Graph}
{synopt :{opt g:raph}}display graph containing linear predictions
    {p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt step}}use model without linear term to plot the adaptive fit
    {p_end}
{synopt :{opt eq:uation(eqno)}}plot predictions for {it:eqno} equation in a multiple-equation system
    {p_end}
{synopt :{it:{help cline_options}}}affect rendition of the plotted
    predictions
    {p_end}
{synopt :{opth ciopt:s(area_options)}}affect rendition of the plotted confidence interval
    {p_end}
{synopt :{it:{help twoway_options}}}any options other than {cmd:by()}
    documented in {bind:{bf:[G] {it:twoway_options}}}
    {p_end}
{synoptline}


{title:Description}

{pstd}
    {cmd:nlcheck} is a simple diagnostic tool that can be used after
    fitting a model to quickly check the linearity assumption for predictor
    {varname}. {cmd:nlcheck} categorizes the predictor into bins, refits
    the model including dummy variables for the bins, and then performs a
    joint Wald test for the added parameters. A significant test result
    indicates that the linearity assumption is violated. Alternatively, if
    the {cmd:spline} option is specified, {cmd:nlcheck} uses linear splines
    for the adaptive model. Furthermore, support for discrete
    variables is provided (see the {cmd:discrete} option).

{pstd}
    Optionally, {cmd:nlcheck} also displays a graph of the adjusted linear
    predictions from the original model and the adaptive model (setting all
    other variables to the mean). Pointwise confidence intervals are
    plotted for the adaptive fit. Such a linear prediction plot can be
    useful to evaluate the functional form of a relationship.

{pstd}
    If a predictor enters the model repeatedly via different
    transformations (e.g. polynomials), then these additional terms should
    be taken into account when computing the adjusted linear predictions for
    the graph. Use {varlist} to specify such additional variables.

{pstd}
    {cmd:nlcheck} can be used with any estimation command as long as it
    supports {helpb test} (and, if {cmd:graph} is specified, {helpb adjust}), follows the standard syntax

        {it:command} {it:varlist} [{it:if}] [{it:in}] [{it:weight}] [{cmd:,} {it:options} ]

{pstd}
    and stores the command as typed in {cmd:e(cmdline)}. Stata 10 is required.


{title:Options}

{dlgtab:Main}

{phang}
    {opt bins(#)} sets the number of bins used for the adaptive fit (resulting in
    #-1 additional parameters). The default is
    {cmd:bins(10)} or {cmd:knots()}+1 if {cmd:knots()} is specified.

{phang}
    {opt s:pline} causes linear splines to be used for the adaptive fit
    instead of bins.

{phang}
    {opt knots(#)} sets the number of knots for the spline fit. The default is
    {cmd:knots(9)} or {cmd:bins()}-1 if {cmd:bins()} is specified.

{phang}
    {opt eqfreq} causes the bin boundaries to be chosen according to
    quantiles of the empirical distribution of the predictor (i.e. so that
    each bin contains approximately the same number of observations). The
    default is to determine the cut points based on quantiles of the
    distinct values of the predictor (i.e. so that each bin contains
    approximately the same number of distinct values). With {cmd:spline},
    the knots are positioned at equally spaced quantiles (of the distinct
    values or of the empirical distribution, depending on the {cmd:eqfreq}
    option) with half a step before the first knot and after last.

{phang}
    {opt discrete} causes {varname} to be treated as a discrete
    variable and includes one parameter for each distinct value of the
    predictor in the adaptive model. The {cmd:bins()}, {cmd:knots()}, and
    {cmd:spline} options are not allowed with {cmd:discrete}.

{phang}
    {opt noisily} causes the estimation results from the adaptive model to
    be displayed.

{dlgtab:Graph}

{phang}
    {cmd:graph} plots the linear predictions from the base model and the
    adaptive fit against the predictor with all other variables set to
    their mean and including pointwise confidence intervals for the
    adaptive fit.

{phang}
    {opt level(#)} specifies the confidence level, as a percentage,
    for the plotted confidence intervals. The default is {cmd:level(95)} or
    as set by {helpb set level}.

{phang}
    {opt equation(eqno)}, where {it:eqno} is {cmd:#}{it:#} or {it:name}
    specifies the equation in a multiple-equation system for which the
    predictions be plotted. This option is allowed only after
    multiple-equation commands.

{phang}
    {opt step} causes the plotted adaptive fit to be based on a
    model from which the original predictor is excluded. The adjusted
    predictions from such model appear as a step-function and may be easier
    to read. {cmd:step} has no effect with {cmd:spline} or
    {cmd:discrete}. {cmd:step} also has no effect on the performed
    nonlinearity test.

{phang}
    {it:cline_options} affect the rendition of the plotted predictions. See
    help {it:{help cline_options}}.

{phang}
    {opt ciopts(area_options)} specifies details about the rendition of the
    plotted confidence interval. See help {it:{help area_options}}.

{phang}
    {it:twoway_options} are any of the options documented in help
    {it:{help twoway_options}}, excluding {cmd:by()}.


{title:Examples}

{pstd}
Basic usage:

        {com}. {stata "use http://www.stata-press.com/data/r10/nlswork4.dta"}
        . {stata "regress ln_wage ttl_exp msp"}
        . {stata "nlcheck ttl_exp"}
        . {stata "nlcheck ttl_exp, graph step"}
        . {stata "nlcheck ttl_exp, spline graph"}{txt}

{pstd}
Nonlinear effect:

        {com}. {stata "generate ttl_exp2 = ttl_exp^2"}
        . {stata "regress ln_wage ttl_exp ttl_exp2 msp"}
        . {stata "nlcheck ttl_exp ttl_exp2, graph step bin(20)"}{txt}

{pstd}
Discrete predictor:

        {com}. {stata "regress ln_wage ttl_exp msp year"}
        . {stata "nlcheck year, discrete graph"}{txt}

{pstd}
Logit model:

        {com}. {stata "sysuse auto"}
        . {stata "logit foreign price mpg"}
        . {stata "nlcheck price, spline knots(3) graph"}{txt}

{pstd}
Multinomial logit:

        {com}. {stata "mlogit rep78 mpg if rep78>=3"}
        . {stata "nlcheck mpg, bin(4) graph equation(5)"}{txt}


{title:Returned results}

{pstd}Scalars{p_end}
{synoptset 17 tabbed}{...}
{synopt:{cmd:r(p)}}two-sided p-value{p_end}
{synopt:{cmd:r(F)} or {cmd:r(chi2)}}F statistic or chi-squared {p_end}
{synopt:{cmd:r(df)}}degrees of freedom{p_end}
{synopt:{cmd:r(df_r)}}residual degrees of freedom (some models){p_end}
{synopt:{cmd:r(cut}{it:#}{cmd:)}}value of the {it:#}th cut point or spline knot{p_end}
{synopt:{cmd:r(levels)}}list of distinct values of discrete predictor{p_end}


{title:Author}

{pstd}
    Ben Jann, ETH Zurich, jannb@ethz.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B. (2008). nlcheck: Stata module to check linearity assumption
    after model estimation. Available from http://ideas.repec.org/.


{title:Also see}

{psee}
    Online:  help {help estcom}, {helpb test}, {helpb adjust}
