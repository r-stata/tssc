{smcl}
{* 21aug2014}{...}
{title:Title}

{pstd}{hi:hte sm} {hline 2} Heterogeneous Treatment Effect Analysis: Stratification-Multilevel Method


{title:Syntax}

{p 8 15 2}
    {cmd:hte sm} {it:{help varname:depvar1}} [{it:{help varname:depvar2}} {it:...} {cmd:=}]
    {it:{help varname:treatvar}} {indepvars} {ifin} {weight}
    [{cmd:,}
    {help hte sm##opt:{it:options}}
    ]

{p 8 15 2}
    {cmd:hte sm} {cmdab:gr:aph} [{cmd:,}
    {opt l:evel(#)} {help hte sm##opt:{it:graph_options}}
    ]

{synoptset 20 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{syntab :Main}
{synopt :{opt al:pha(#)}}set significance level for balancing tests
    {p_end}
{synopt :{it:{help pscore:pscore_options}}}options as described in help
    {helpb pscore} (except {cmd:level()}){p_end}
{synopt :{cmd:join(}{it:{help hte sm##join:list}}{cmd:)}}merge specified strata
    {p_end}
{synopt :{cmdab:auto:join}[{cmd:(}{it:#}{cmd:)}]}merge small strata at low end
    or high end
    {p_end}
{synopt :{cmd:by(}{it:{help varname:groupvar}}{cmd:)}}repeat analyses for groups
    defined by {it:groupvar}
    {p_end}
{synopt :{opt sep:arate}}construct propensity score strata separately
    for each by-group
    {p_end}
{synopt :{cmdab:con:trols:(}{it:{help hte sm##controls:clist}}{cmd:)}}control
    variables for within-strata models
    {p_end}
{synopt :{opt est:com(command)}}set estimation command for within
    strata models; default is {helpb regress}
    {p_end}
{synopt :{cmdab:estop:ts(}{it:{help regress:options}}{cmd:)}}options to be
    applied to within-strata models
    {p_end}
{synopt :{opt noi:sily}}display output from {cmd:pscore} and individual models
    {p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is
    {cmd:level(95)}{p_end}
{synopt :{opt list:wise}}use listwise deletion to handle missing values
    {p_end}
{synopt :{opt case:wise}}synonym for {cmd:listwise}
    {p_end}

{syntab :Graph}
{synopt :{opt nogr:aph}}suppress graph
    {p_end}
{synopt :{opth o:utcomes(numlist)}}display results for specified outcomes
    {p_end}
{synopt :{it:{help marker_options}}}change look of markers
    {p_end}
{synopt :{cmdab:lineop:ts(}{it:{help cline_options:options}}{cmd:)}}change look of fitted
    lines
    {p_end}
{synopt :{cmdab:ciop:ts(}{it:{help twoway_rcap:options}}{cmd:)}}change look of confidence
    intervals
    {p_end}
{synopt :{opt noci}}suppress confidence intervals
    {p_end}
{synopt :{cmd:addplot(}{it:{help addplot_option:plot}}{cmd:)}}add other plots to the generated graph
    {p_end}
{synopt :{it:{help twoway_options}}}any options other than {opt by()} documented in
    {bind:{bf:[G] {it:twoway_options}}}{p_end}
{synoptline}
{pstd}
    {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see help {help weight}.


{title:Description}

{pstd}
    {cmd:hte sm} performs heterogeneous treatment effect analysis using the
    stratification-multilevel method as proposed by Xie, Brand, and Jann
    (2012). It first applies {cmd:pscore} (Becker and Ichino 2002) to construct
    balanced propensity score strata and, within each stratum, estimates the
    average treatment effect. {cmd:hte sm} then tests for linear trend in
    treatment effects using variance-weighted least squares. The
    stratum-specific treatment effects and the estimated linear trend are
    displayed in a twoway graph. {it:treatvar} is a dichotomous variable 
    identifying the treatment group (typically coded as 1) and the control 
    group (typically coded as 0).

{pstd}
    {cmd:hte sm} specified without arguments redisplays the results from a
    previous {cmd:hte sm} call (without graph).

{pstd}
    {cmd:hte sm graph} redraws the graph based on the results from a
    previous {cmd:hte sm} call.


{title:Dependencies}

{pstd}
    {cmd:hte sm} requires {cmd:pscore} (Becker and Ichino 2002). To 
    install {cmd:pscore} on your system, type:
    
        . {stata "net install st0026_2, from(http://www.stata-journal.com/software/sj5-3)"}


{title:Options}

{dlgtab:Main}

{phang}
    {opt alpha(#)} sets the significance level for {helpb pscore}'s
    tests of the balancing property. The default is {cmd:alpha(0.01)}.

{phang}
    {it:{help pscore:pscore_options}} are any options as described in help
    {helpb pscore}, except {cmd:level()}.
    {p_end}
{marker join}
{phang}
    {opt join(list)} causes the specified strata to be merged together for
    the treatment effect analysis. The syntax for {it:list} is

            {it:numlist} [{cmd:,} {it:numlist} ...]

{pmore}
    where {it:numlist} is a list of consecutive integers that identify the
    strata to be merged. For example, type {cmd:join(1 2)} to merge the
    first and second stratum. Multiple (disjunctive) {it:numlist}s may be
    specified, separated by a comma, in which case multiple merges are
    applied. After merging, the strata will be renumbered.

{phang}
    {cmd:autojoin}[{cmd:(}{it:#}{cmd:)}] causes small strata at the low and
    high end of the propensity score to be merged with subsequent or
    precedent strata, respectively, so that the number of observations is
    at least {it:#} for both the treated and the untreated ({it:#} defaults
    to {cmd:10}). Only one of {opt join()} and {cmd:autojoin()} may be
    specified.

{phang}
    {cmd:by(}{it:{help varname:groupvar}}{cmd:)} specifies that the analysis be
    repeated for each group defined by the values of {it:groupvar}. The results are
    plotted in a single graph for all by-groups. Common propensity score
    strata are used for all groups unless the {cmd:separate} option is specified.

{phang}
    {opt separate} causes the construction of propensity score strata
    to be repeated for each by-group. The default is to use common strata, that
    is, to construct the strata once, based on the whole sample including all
    groups. {cmd:separate} has an effect only if {cmd:by()} is specified.
    {p_end}
{marker controls}
{phang}
    {opt controls(clist)} specifies control variables to be included in
    the models used to estimate the within-strata treatment effects. {it:clist}
    may be a standard {varlist}, in which case the specified variables are included
    in each within-strata model. Alternatively, use the following syntax to specify
    strata-specific sets:

            [{varlist}] [{it:{help numlist:numlist1}}{cmd::} {it:{help varlist:varlist1}}] [{it:{help numlist:numlist2}}{cmd::} {it:{help varlist:varlist2}}] [{it:...}]

{pmore}
    {it:varlist} applies to all strata, {it:varlist1} applies to the strata specified in
    {it:numlist1}, etc.

{phang}
    {cmd:estcom(}{it:command}{cmd:)} sets the command used to estimate the within
    strata treatment effects. The default is {helpb regress}.

{phang}
    {cmd:estopts(}{it:{help regress:options}}{cmd:)} are options to be
    applied to the models used to estimate the within-strata treatment
    effects. The options are as described in
    help {helpb regress} (or as in help {it:command} where, {it:command}
    is the command specified via the {cmd:estcom()} option).

{phang}
    {opt noisily} displays the output from {cmd:pscore} and the
    treatment effect models. {cmd:pscore}'s {cmd:detail} option
    implies {cmd:noisily}.

{phang}
    {opt level(#)} sets the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)} or as set by
    {helpb set level}.

{phang}
    {opt listwise}
    handles missing values through listwise deletion, meaning that an observation
    is excluded from all computations if any of the specified
    variables is missing for that observation. By default, {cmd:hte sm} uses all
    available observations to compute the propensity strata without regard
    to whether values for the outcome variables (the {it:depvars}) or the variables
    specified in {cmd:controls()} are missing.

{phang}
    {opt casewise} is a synonym for {cmd:listwise}.

{dlgtab:Graph}

{phang}
    {opt nograph} suppresses the graph.

{phang}
    {opth outcomes(numlist)} causes results to be plotted for the
    specified outcomes only. Use this option to select results in
    case of multiple outcome variables or {cmd:by()}-groups. Use numbers 1,
    2, 3, etc. to refer to the different outcomes. By-groups are ordered
    within variables if both multiple outcome variables and the {cmd:by()}
    option are specified. That is, number 1 refers to {it:depvar1} and the
    first by-group, number 2 refers to {it:depvar1} and the second
    by-group, etc.

{phang}
    {it:marker_options} affect the rendition of the plotted markers,
    including their shape, size, color, and outline; see
    {helpb marker_options:{bind:[G] {it:marker_options}}}. In case of multiple outcomes
    you can usually specify lists of elements to be applied to the different
    outcomes. For example, type {cmd:msymbol(D T)} to use diamonds for the
    first outcome and triangles for the second outcome.

{phang}
    {cmd:lineopts(}{it:cline_options}{cmd:)} affects the rendition of the
    plotted lines; see {helpb cline_options:{bind:[G] {it:cline_options}}}. In
    case of multiple outcomes you can usually specify lists of elements to
    be applied to the different outcomes. For example, type
    {cmd:lineopts(lcolor(blue red))} to use blue line color for the first
    outcome and red line color for the second outcome.

{phang}
    {cmd:ciopts(}{it:options}{cmd:)} affects the rendition
    of the capped confidence spikes for the within strata treatment
    effects; see {helpb twoway_rcap:{bind:[G] graph twoway rcap}}.

{phang}
    {opt noci} suppresses the confidence intervals for the within strata
    treatment effects. Confidence intervals are only displayed on plots
    containing a single outcome.

{phang}
    {cmd:addplot(}{it:plot}{cmd:)} provides a way to add other plots to the
    generated graph; see {helpb addplot_option:{bind:[G] {it:addplot_option}}}.

{phang}
    {it:twoway_options} are any options other than {opt by()} documented in
    {helpb twoway_options:{bind:[G] {it:twoway_options}}}.


{title:Examples}

{pstd}
    Treatment effect of college on wages:

        . {stata sysuse nlsw88}
        . {stata generate sq_exp = ttl_exp^2}
        . {stata hte sm wage collgrad ttl_exp sq_exp tenure south smsa}

{pstd}
    Add control variables to within strata treatment effect estimation:

        . {stata hte sm wage collgrad ttl_exp sq_exp tenure south smsa, control(ttl_exp sq_exp)}

{pstd}
    Separate results by {cmd:union}:

        . {stata hte sm wage collgrad ttl_exp sq_exp tenure south smsa, by(union)}

{pstd}
    Redraw graph for second group ({cmd:union}=1):

        . {stata hte sm graph, outcome(2)}


{title:Saved results}

{pstd}
{cmd:hte sm} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(neq)}}number of equations (outcomes){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:hte sm}{p_end}
{synopt:{cmd:e(estcom)}}estimation command as specified by {cmd:estcom()}{p_end}
{synopt:{cmd:e(depvar)}}name(s) of dependent variable(s){p_end}
{synopt:{cmd:e(treatvar)}}name of treatment variable{p_end}
{synopt:{cmd:e(indepvars)}}name(s) of independent variables{p_end}
{synopt:{cmd:e(controls)}}expanded controls option{p_end}
{synopt:{cmd:e(trend)}}note about linear fit{p_end}
{synopt:{cmd:e(byvar)}}name of {cmd:by()} variable{p_end}
{synopt:{cmd:e(depvar#)}}outcome #: name of dependent variable{p_end}
{synopt:{cmd:e(by#)}}outcome #: by-group{p_end}
{synopt:{cmd:e(trend#)}}outcome #: note about linear fit{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(properties)}}{cmd:b}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}results vector{p_end}
{synopt:{cmd:e(se)}}standard errors{p_end}
{synopt:{cmd:e(obs)}}number of observations per stratum{p_end}
{synopt:{cmd:e(block)}}strata ranks{p_end}
{synopt:{cmd:e(lfit)}}linear fit of treatment effect by strata rank{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}
    Becker, Sascha O., Andrea Ichino. 2002. Estimation of average treatment
    effects based on propensity 
    scores. {browse "http://www.stata-journal.com/article.html?article=st0026":The Stata Journal 2(4):358-377}.
    {p_end}

{phang}
    Xie, Yu, Jennie E. Brand, Ben Jann. 2012. Estimating Heterogeneous Treatment 
    Effects with Observational 
    Data. {browse "http://dx.doi.org/10.1177/0081175012452652":Sociological Methodology 42: 314-347}.
    {p_end}


{title:Authors}

{pstd}
    Ben Jann (University of Bern, jann@soz.unibe.ch)
    {p_end}
{pstd}
    Jennie E. Brand (UCLA, brand@soc.ucla.edu)
    {p_end}
{pstd}
    Yu Xie (University of Michigan, yuxie@isr.umich.edu)
    {p_end}

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B., J. E. Brand, Y. Xie. 2010. hte: Stata module to perform
    heterogeneous treatment effect analysis. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s457129.html"}.


{title:Also see}

{psee}
    Online:  help for {helpb hte}, {helpb hte ms}, {helpb hte sd},
    {helpb regress},
    {helpb vwls};
    {helpb pscore} (if installed)
