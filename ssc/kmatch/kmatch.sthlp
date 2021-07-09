{smcl}
{* 11mar2020}{...}
{hi:help kmatch}{...}
{right:{help kmatch##syntax:Syntax} - {help kmatch##desc:Description} - {help kmatch##mdoptions:Options} - {help kmatch##ex:Examples} - {help kmatch##eret:Stored results} - {help kmatch##refs:References}}
{hline}

{title:Title}

{p 4 14 2}{hi:kmatch} {hline 2} Multivariate-distance and propensity-score matching, including
    entropy balancing, inverse probability weighting, (coarsened) exact matching,
    and regression adjustment


{marker syntax}{...}
{title:Syntax}

{pstd}
    Multivariate-distance matching

{p 8 15 2}
    {cmd:kmatch md}
    {help varname:{it:tvar}} [{help varlist:{it:xvars}}]
    [{cmd:(}{help varlist:{it:ovars}} [{cmd:=} {help varlist:{it:avars}}]{cmd:)} ...]
    {ifin} {weight}
    [{cmd:,}
    {help kmatch##mdopts:{it:md_options}}
    ]

{pstd}
    Propensity-score matching

{p 8 15 2}
    {cmd:kmatch ps}
    {help varname:{it:tvar}} [{help varlist:{it:xvars}}]
    [{cmd:(}{help varlist:{it:ovars}} [{cmd:=} {help varlist:{it:avars}}]{cmd:)} ...]
    {ifin} {weight}
    [{cmd:,}
    {help kmatch##psopts:{it:ps_options}}
    ]

{pstd}
    (Coarsened) Exact matching

{p 8 15 2}
    {cmd:kmatch em}
    {help varname:{it:tvar}} [{help kmatch##ematch:{it:emvars}}]
    [{cmd:(}{help varlist:{it:ovars}} [{cmd:=} {help varlist:{it:avars}}]{cmd:)} ...]
    {ifin} {weight}
    [{cmd:,}
    {help kmatch##emopts:{it:em_options}}
    ]

{pstd}
    Entropy balancing

{p 8 15 2}
    {cmd:kmatch eb}
    {help varname:{it:tvar}} [{help varlist:{it:xvars}}]
    [{cmd:(}{help varlist:{it:ovars}} [{cmd:=} {help varlist:{it:avars}}]{cmd:)} ...]
    {ifin} {weight}
    [{cmd:,}
    {help kmatch##ebopts:{it:eb_options}}
    ]

{pstd}
    Inverse probability weighting (IPW)

{p 8 15 2}
    {cmd:kmatch ipw}
    {help varname:{it:tvar}} [{help varlist:{it:xvars}}]
    [{cmd:(}{help varlist:{it:ovars}} [{cmd:=} {help varlist:{it:avars}}]{cmd:)} ...]
    {ifin} {weight}
    [{cmd:,}
    {help kmatch##ipwopts:{it:ipw_options}}
    ]

{pstd}
    Regression adjustment (RA)

{p 8 15 2}
    {cmd:kmatch ra}
    {help varname:{it:tvar}}
    [{cmd:(}{help varlist:{it:ovars}} [{cmd:=} {help varlist:{it:avars}}]{cmd:)} ...]
    {ifin} {weight}
    [{cmd:,}
    {help kmatch##raopts:{it:ra_options}}
    ]

{pstd}
    {help varname:{it:tvar}} is the treatment variable; {help varlist:{it:xvars}}
    and {help kmatch##ematch:{it:emvars}}
    are covariates to be matched/balanced; {help varlist:{it:ovars}} are outcome
    variables; {help varlist:{it:avars}} are adjustment variables. Multiple
    outcome equations may be specified. {help varlist:{it:xvars}} and {help varlist:{it:avars}} may
    contain {help fvvarlist:factor variables}; {help kmatch##ematch:{it:emvars}}
    may contain {help kmatch##ematch:coarsening rules}; {cmd:pweight}s, {cmd:iweight}s,
    and {cmd:fweight}s are allowed, see help {help weight}.

{pstd}
    Bandwidth selection plot

{p2colset 9 50 50 2}{...}
{p2col:{cmd:kmatch} {opt cv:plot} [{it:{help numlist}}] [, {help kmatch##cvplotopts:{it:cvplotopts}}]}(display
    MISE by evaluation points)

{pmore}
    where {it:{help numlist}} specifies the values of the over-groups to be included
    in the graph. The default is to include all over-groups.

{pstd}
    Balancing diagnostics

{p2colset 9 50 50 2}{...}
{p2col:{cmd:kmatch} {opt su:mmarize} [{varlist}] [, {help kmatch##sumopts:{it:sumopts}}]}(means
    and variances in raw and balanced data)

{p2col:{cmd:kmatch} {opt dens:ity} [{varlist}] [, {help kmatch##gropts:{it:gropts}}]}(kernel
    density plots for raw and balanced data)

{p2col:{cmd:kmatch} {opt cum:ul} [{varlist}] [, {help kmatch##gropts:{it:gropts}}]}(cumulative
    distribution plots for raw and balanced data)

{p2col:{cmd:kmatch box} [{varlist}] [, {help kmatch##gropts:{it:gropts}}]}(box plots
     for raw and balanced data)

{pstd}
    Common-support diagnostics

{p2colset 9 50 50 2}{...}
{p2col:{cmd:kmatch} {opt csu:mmarize} [{varlist}] [, {help kmatch##sumopts:{it:sumopts}}]}(common-support
    means and variances)

{p2col:{cmd:kmatch} {opt cdens:ity} [{varlist}] [, {help kmatch##gropts:{it:gropts}}]}(common-support
    kernel density plots)

{p2col:{cmd:kmatch} {opt ccum:ul} [{varlist}] [, {help kmatch##gropts:{it:gropts}}]}(common-support
    cumulative distribution plots)

{p2col:{cmd:kmatch cbox} [{varlist}] [, {help kmatch##gropts:{it:gropts}}]}(common-support
    box plots)


{synoptset 21 tabbed}{...}
{marker mdopts}{col 5}{help kmatch##mdoptions:{it:md_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{cmdab:m:etric(}{help kmatch##metric:{it:metric}}{cmd:)}}distance metric for covariates
    {p_end}
{synopt :{help kmatch##matchopts:{it:matching_options}}}matching options
    {p_end}
{synopt :{help kmatch##gopts:{it:general_options}}}estimands, standard errors, reporting, etc.
    {p_end}

{syntab :Propensity score}
{synopt :{opth psv:ars(varlist)}}include propensity score estimated from {it:varlist}
    {p_end}
{synopt :{opth pscore(varname)}}include propensity score contained in {it:varname}
    {p_end}
{synopt :{opt psw:eight(#)}}weight given to the propensity score
    {p_end}
{synopt :{cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}]}restrict common support of
    propensity score
    {p_end}
{synopt :{help kmatch##pscoreopts:{it:pscore_options}}}propensity score estimation options
    {p_end}

{syntab :Entropy balancing}
{synopt :{opt eb:alance}[{opth (varlist)}]}apply entropy balancing to the matched sample
    {p_end}
{synopt :{opt cso:nly}}only use common support information and ignore matching weights
    {p_end}
{synopt :{help kmatch##ebalopts:{it:ebalance_options}}}other entropy balancing options
    {p_end}
{synoptline}

{marker psopts}{col 5}{help kmatch##psoptions:{it:ps_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}]}restrict common support of
    propensity score
    {p_end}
{synopt :{opth pscore(varname)}}variable providing the propensity score
    {p_end}
{synopt :{help kmatch##pscoreopts:{it:pscore_options}}}propensity score estimation options
    {p_end}
{synopt :{help kmatch##matchopts:{it:matching_options}}}matching options
    {p_end}
{synopt :{help kmatch##gopts:{it:general_options}}}estimands, standard errors, reporting, etc.
    {p_end}

{syntab :Entropy balancing}
{synopt :{opt eb:alance}[{opth (varlist)}]}apply entropy balancing to the matched sample
    {p_end}
{synopt :{opt cso:nly}}only use common support information and ignore matching weights
    {p_end}
{synopt :{help kmatch##ebalopts:{it:ebalance_option}}}other entropy balancing options
    {p_end}
{synoptline}

{marker emopts}{col 5}{help kmatch##emoptions:{it:em_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{help kmatch##gopts:{it:general_options}}}estimands, standard errors, reporting, etc.
    {p_end}

{syntab :Entropy balancing}
{synopt :{opth eb:alance(varlist)}}apply entropy balancing to the matched sample
    {p_end}
{synopt :{opt cso:nly}}only use common support information and ignore matching weights
    {p_end}
{synopt :{help kmatch##ebalopts:{it:ebalance_options}}}other entropy balancing options
    {p_end}
{synoptline}

{marker ebopts}{col 5}{help kmatch##eboptions:{it:eb_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{help kmatch##ebalopts:{it:ebalance_options}}}entropy balancing options
    {p_end}
{synopt :{help kmatch##gopts:{it:general_options}}}estimands, standard errors, reporting, etc.
    {p_end}

{syntab :Propensity score}
{synopt :{cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}]}restrict common support based on
    propensity score
    {p_end}
{synopt :{opth psv:ars(varlist)}}estimate propensity score from {it:varlist}
    {p_end}
{synopt :{opth pscore(varname)}}variable providing the propensity score
    {p_end}
{synopt :{help kmatch##pscoreopts:{it:pscore_options}}}propensity score estimation options
    {p_end}
{synoptline}

{marker ipwopts}{col 5}{help kmatch##ipwoptions:{it:ipw_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}]}restrict common support of
    propensity score
    {p_end}
{synopt :{opth pscore(varname)}}variable providing the propensity score
    {p_end}
{synopt :{help kmatch##pscoreopts:{it:pscore_options}}}propensity score estimation options
    {p_end}
{synopt :{opt nonorm:alize}}do not normalize the weights
    {p_end}
{synopt :{help kmatch##gopts:{it:general_options}}}estimands, standard errors, reporting, etc.
    {p_end}

{syntab :Entropy balancing}
{synopt :{opt eb:alance}[{opth (varlist)}]}apply entropy balancing to the reweighted sample
    {p_end}
{synopt :{opt cso:nly}}only use common support information and ignore the IPWs
    {p_end}
{synopt :{help kmatch##ebalopts:{it:ebalance_options}}}other entropy balancing options
    {p_end}
{synoptline}

{marker raopts}{col 5}{help kmatch##raoptions:{it:ra_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{help kmatch##gopts:{it:general_options}}}estimands, standard errors, reporting, etc.
    {p_end}

{syntab :Propensity score}
{synopt :{cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}]}restrict common support based on
    propensity score
    {p_end}
{synopt :{opth psv:ars(varlist)}}estimate propensity score from {it:varlist}
    {p_end}
{synopt :{opth pscore(varname)}}variable providing the propensity score
    {p_end}
{synopt :{help kmatch##pscoreopts:{it:pscore_options}}}propensity score estimation options
    {p_end}
{synoptline}

{marker matchopts}{col 5}{help kmatch##matchoptions:{it:matching_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt nn}[{cmd:(}{it:#}{cmd:)}]}use nearest-neighbor matching instead of kernel matching
    {p_end}
{synopt :{opt keepall}}do not enforce minimum number of nearest neighbors
    {p_end}
{synopt :{opt wor}}apply nearest-neighbor matching without replacement
    {p_end}
{synopt :{opt ridge}}use ridge matching instead of kernel matching
    {p_end}
{synopt :{cmdab:k:ernel(}{help kmatch##kernel:{it:kernel}}{cmd:)}}kernel
    function; default is {cmd:kernel(epan)}
    {p_end}
{synopt :{cmd:ematch(}{help kmatch##ematch:{it:emvars}}{cmd:)}}match exactly on the
    specified variables (after optional coarsening)
    {p_end}

{syntab :Bandwidth/Caliper}
{synopt :{cmdab:bw:idth(}{help kmatch##bwidth:{it:bwspec}}{cmd:)}}half-width of
    kernel/caliper for nn-matching
    {p_end}
{synopt :{opth cal:iper(numlist)}}synonym for {cmd:bwidth(}{it:numlist}{cmd:)}
    {p_end}
{synopt :{opt sh:aredbwidth}}use same bandwidth/caliper for both matching directions
    {p_end}
{synopt :{opth bwadj:ust(numlist)}}adjust bandwidth/caliper by specified factor
    {p_end}
{synoptline}

{marker pscoreopts}{col 5}{help kmatch##pscoreoptions:{it:pscore_options}}{col 28}Description
{synoptline}
{synopt :{opt pscmd(command)}}command used to estimate the propensity score;
    default is {helpb logit}
    {p_end}
{synopt :{opt psopt:s(options)}}options passed through to the propensity
    score estimation command
    {p_end}
{synopt :{opt maxi:ter(#)}}set maximum number of iterations for propensity
    score estimation; default is {it:#} = {cmd:min(50,c(maxiter))}
    {p_end}
{synopt :{opt pspr:edict(options)}}options passed through to {helpb predict};
    default is {cmd:pspredict(pr)}
    {p_end}
{synoptline}

{marker ebalopts}{col 5}{help kmatch##ebaloptions:{it:ebalance_options}}{col 28}Description
{synoptline}
{synopt :{opth tar:gets(numlist)}}specify
    target moments to be balanced; default is {cmd:targets(1)} (means)
    {p_end}
{synopt :{opt cov:ariances}}additionally balance covariances
    {p_end}
{synopt :{opt btol:erance(#)}}balancing tolerance; default is {cmd:btolerance(1e-5)}
    {p_end}
{synopt :{cmdab:fit:opts(}{help kmatch##fitopts:{it:options}}{cmd:)}}details of the balancing algorithm
    {p_end}
{synoptline}

{marker gopts}{col 5}{help kmatch##goptions:{it:general_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt tval:ue(#)}}value of {it:tvar} that is the treatment; default is
    {cmd:tvalue(1)}
    {p_end}
{synopt :{opth over(varname)}}compute results for subpopulations defined by the
    values of {it:varname}
    {p_end}

{syntab :Estimands}
{synopt :{opt ate}}average treatment effect; the default
        {p_end}
{synopt :{opt att}}average treatment effect on the treated
        {p_end}
{synopt :{opt atc}}average treatment effect on the untreated
        {p_end}
{synopt :{opt nate}}naive average treatment effect
        {p_end}
{synopt :{opt po}}potential outcome averages
        {p_end}

{syntab :SE/CI}
{synopt :{cmd:vce(}{help kmatch##vce:{it:vcetype}}{cmd:)}}{it:vcetype} may
    be {cmd:analytic} (the default), {cmdab:cl:uster} {it:clustvar}, {cmdab:boot:strap}, or {cmdab:jack:knife}
    {p_end}
{synopt :{opt svy}}use survey variance estimation as set by {helpb svyset}
    {p_end}
{synopt :{opt subp:op(subpop)}}restrict survey estimation to a subpopulation
    {p_end}
{synopt :{opt nose}}do not compute standard errors
    {p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt noi:sily}}display auxiliary results
    {p_end}
{synopt :{opt nohe:ader}}suppress output header
    {p_end}
{synopt :{opt nomtab:le}}suppress matching statistics
    {p_end}
{synopt :{opt notab:le}}suppress coefficients table (treatment effects)
    {p_end}
{synopt :{help estimation options:{it:display_options}}}standard
    reporting options
    {p_end}

{syntab :Generate}
{synopt :{cmdab:gen:erate}[{cmd:(}{it:{help kmatch##gen:spec}}{cmd:)}]}generate variables
    containing matching results
    {p_end}
{synopt :{cmdab:wgen:erate}[{cmd:(}{it:{help kmatch##wgen:spec}}{cmd:)}]}generate
    variables containing ready-to-use matching weights
    {p_end}
{synopt :{cmdab:dy:generate}[{cmd:(}{it:{help kmatch##dygen:spec}}{cmd:)}]}generate variables
    containing potential outcome differences
    {p_end}
{synopt :{cmdab:idgen:erate}[{cmd:(}{it:prefix}{cmd:)}]}generate variables
    containing IDs of the matched controls (matching only)
    {p_end}
{synopt :{opth id:var(varname)}}provide custom IDs to be used by {cmd:idgenerate()} (matching only)
    {p_end}
{synopt :{cmdab:dxgen:erate}[{cmd:(}{it:prefix}{cmd:)}]}generate variables
    containing distances to the matched controls (matching only)
    {p_end}
{synopt :{cmdab:cemgen:erate}[{cmd:(}{it:{help kmatch##cemgen:spec}}{cmd:)}]}generate variables
    containing coarsened covariates (matching only)
    {p_end}
{synopt :{cmdab:ifgen:erate}[{cmd:(}{it:{help kmatch##ifgen:spec}}{cmd:)}]}generate variables
    containing the influence functions
    {p_end}
{synopt :{opt replace}}allow overwriting existing variables
    {p_end}
{synoptline}

{marker cvplotopts}{col 5}{help kmatch##cvplotoptions:{it:cvplotopts}}{col 28}Description
{synoptline}
{synopt :{opt i:ndex}}display index using marker labels
    {p_end}
{synopt :{cmdab:r:ange(}{it:lb} [{it:ub}]{cmd:)}}restrict results to bandwidths within [{it:lb}, {it:ub}]
    {p_end}
{synopt :{opt not:reated}}omit results for treated
    {p_end}
{synopt :{opt nou:ntreated}}omit results for untreated
    {p_end}
{synopt :{it:{help scatter:scatter_options}}}any options allowed by
    {helpb graph twoway scatter} {p_end}
{synopt :{cmdab:comb:opts(}{help graph combine:{it:options}}{cmd:)}}options passed
    through to {helpb graph combine}
    {p_end}
{synopt :{opt ti:tles(strlist)}}titles for subgraphs
    {p_end}
{synoptline}

{marker sumopts}{col 5}{help kmatch##sumoptions:{it:sumopts}}{col 28}Description
{synoptline}
{synopt :{cmd:ate} | {cmd:att} | {cmd:atc}}report results corresponding to
    specified estimand
    {p_end}
{synopt :{opt sd}}report standard deviations instead of variances
    {p_end}
{synopt :{opt skew:ness}}additionally report skewnesses
    {p_end}
{synopt :{opt meanonly}}display table reporting means only
    {p_end}
{synopt :{opt varonly}}display table reporting variances only
    {p_end}
{synopt :{opt skewonly}}display table reporting skewnesses only
    {p_end}
{synoptline}

{marker gropts}{col 5}{help kmatch##groptions:{it:gropts}}{col 28}Description
{synoptline}
{syntab :Common options}
{synopt :{cmd:ate} | {cmd:att} | {cmd:atc}}report results corresponding to
    specified estimand
    {p_end}
{synopt :{opth o:verlevels(numlist)}}report results for selected subpopulations
    {p_end}
{synopt :{cmdab:comb:opts(}{help graph combine:{it:options}}{cmd:)}}options passed
    through to {helpb graph combine}
    {p_end}
{synopt :{opt ti:tles(strlist)}}titles for subgraphs
    {p_end}
{synopt :{opt lab:els(strlist)}}(balancing plots only) subgraph labels for raw and
    matched samples
    {p_end}
{synopt :{cmdab:byopt:s(}{help by_option:{it:byopts}}{cmd:)}}(balancing plots
    only) options passed through to {cmd:by()}
    {p_end}
{synopt :{opt nom:atched}}(common-support plots only) omit results for matched observations
    {p_end}
{synopt :{opt nou:nmatched}}(common-support plots only) omit results for unmatched observations
    {p_end}
{synopt :{opt notot:al}}(common-support plots only) omit results for combined sample
    {p_end}

{syntab :All but box/cbox}
{synopt :{it:{help line:line_options}}}any options allowed by
    {helpb graph twoway line}
    {p_end}

{syntab :For box/cbox}
{synopt :{it:{help legend_options:legend_options}}}options controlling the
    legend
    {p_end}
{synopt :{it:{help graph_box##boxlook_options:boxlook_options}}}{cmd:graph box}
    options controlling the look of the boxes
    {p_end}
{synopt :{it:{help graph_box##axis_options:axis_options}}}{cmd:graph box}
    options controlling rendering of the y axis
    {p_end}
{synopt :{it:{help graph_box##title_and_other_options:other_options}}}{cmd:graph box}
    options controlling titles, added text, aspect ratio, etc.
    {p_end}

{syntab :For density/cdensity}
{synopt :{opt n(#)}}estimate density using # points; default is {cmd:n(512)}
    {p_end}
{synopt :{cmdab:bw:idth(}{it:#}|{it:{help kmatch##bwtype:type}}{cmd:)}}set bandwidth to {it:#} or
    specify automatic bandwidth selector
    {p_end}
{synopt :{opt adj:ust(#)}}scale bandwidth by {it:#}
    {p_end}
{synopt :{cmdab:a:daptive}[{cmd:(}{it:#}{cmd:)}]}use the adaptive
    kernel density estimator
    {p_end}
{synopt :{opt ll(#)}}value of lower boundary of the domain of the variable
    {p_end}
{synopt :{opt ul(#)}}value of upper boundary of the domain of the variable
    {p_end}
{synopt :{opt refl:ection} | {opt lc}}select the boundary correction technique;
    default is renormalization
    {p_end}
{synopt :{opt k:ernel(kernel)}}type of kernel function; see {helpb kdens}
    {p_end}
{synoptline}


{marker desc}{...}
{title:Description}

{pstd}
    {cmd:kmatch} matches or balances treated and untreated observations with
    respect to covariates and, if outcome variables are provided, estimates
    treatment effects based on the matched/balanced observations, possibly
    including post-matching regression adjustment. Several matching or balancing
    commands are available:

{pmore}
    {cmd:kmatch md} applies multivariate-distance matching (Mahalanobis
    matching by default). A kernel function will be used to
    determine and weight the matches (see, e.g., Heckman et al. 1998a, 1998b).
    Alternatively, if the {helpb kmatch##nn:nn()} option is specified,
    nearest-neighbor matching will be applied. For kernel matching, several
    methods for data-driven bandwidth selection are offered; see the
    {helpb kmatch##bwidth:bwidth()} option. If covariates ({it:avars})
    are specified for the outcome variables, treatment effects estimation will
    include regression adjustment (equivalent to the bias-correction proposed
    by Abadie and Imbens 2011).

{pmore}
    {cmd:kmatch ps} applies propensity-score matching, using kernel matching or
    nearest-neighbor matching and possibly including regression adjustment
    as described for {cmd:kmatch md}.

{pmore}
    {cmd:kmatch em} applies exact matching or coarsened exact matching
    (Iacus et al. 2012). See below for information on how to specify
    {help kmatch##ematch:coarsening rules} for the covariates. Exact matching is
    also available with {cmd:kmatch md} and {cmd:kmatch ps} through the
    {helpb kmatch##ematch:ematch()} option.

{pmore}
    {cmd:kmatch eb} applies entropy balancing (Hainmueller 2012). Entropy balancing
    is also available as a refinement in {cmd:kmatch md}, {cmd:kmatch ps}, {cmd:kmatch em},
    and {cmd:kmatch ipw} through the {cmd:ebalance()} option.

{pmore}
    {cmd:kmatch ipw} applies inverse probability weighting (IPW).

{pmore}
    {cmd:kmatch ra} applies regression adjustment. Regression adjustment is
    also supported by all of the above commands. Use {cmd:kmatch ra} only if
    you want to compute raw regression-adjustment estimates without matching or
    reweighting.

{pstd}
    After running one of the above commands, several post-estimation commands
    are available. A first set of commands can be used to evaluate the
    balancing of the data:

{pmore}
    {cmd:kmatch summarize} reports means and variances (and, optionally,
    skewnesses) of the covariates for the treated and the untreated before
    and after matching.

{pmore}
    {cmd:kmatch density} displays kernel density estimates of the specified
    variable(s) before and after matching. For {cmd:kmatch ps} and
    {cmd:kmatch ipw}, the density of the propensity score is displayed by
    default.

{pmore}
    {cmd:kmatch cumul} is like {cmd:kmatch density}, but displays cumulative
    distributions.

{pmore}
    {cmd:kmatch box} is like {cmd:kmatch density}, but displays box plots.

{pstd}
    A second set of post-estimation commands can be used to evaluate how the
    common support deviates from the overall sample. If some of the
    observations have been excluded from the matching solution due to lack of
    common support, generalizability of the obtained results may be
    compromised. The following commands are helpful to compare matched and
    unmatched observations in such a situation:

{pmore}
    {cmd:kmatch csummarize} reports means and variances (and, optionally,
    skewnesses) of the covariates in the matched sample, the unmatched sample,
    and the overall sample.

{pmore}
    {cmd:kmatch cdensity} displays kernel density estimates of the specified
    variable(s) in the matched sample, the unmatched sample,
    and the overall sample. For {cmd:kmatch ps} and
    {cmd:kmatch ipw}, the density of the propensity score is displayed by
    default.

{pmore}
    {cmd:kmatch ccumul} is like {cmd:kmatch cdensity}, but displays cumulative
    distributions.

{pmore}
    {cmd:kmatch cbox} is like {cmd:kmatch cdensity}, but displays box plots.

{pstd}
    Finally, post-estimation command {cmd:kmatch cvplot} can be used
    to display the trace of the search algorithm after {cmd:kmatch md} or
    {cmd:kmatch ps} if cross-validation has been employed for
    bandwidth selection.

{pstd}
    {cmd:kmatch} requires {cmd:kdens} and {cmd:moremata}
    to be installed on the system. See
    {net "describe kdens, from(http://fmwww.bc.edu/repec/bocode/k/)":{bf:ssc describe kdens}}
    and
    {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":{bf:ssc describe moremata}}.


{marker mdoptions}{...}
{title:Options for kmatch md}

{dlgtab:Main}

{marker metric}{...}
{phang}
    {opt metric(metric)} specifies the scaling matrix used to compute the
    multivariate distances. Option {cmd:metric()} is only allowed for
    {cmd:kmatch md}. {it:metric} may be:

{p 12 14 4}
    {opt maha:lanobis} [{help numlist:{it:units}}] [, {opth w:eights(numlist)} ]
    {p_end}
{p 12 14 4}
    {opt ivar:iance} [{help numlist:{it:units}}] [, {opth w:eights(numlist)} ]
    {p_end}
{p 12 14 4}
    {opt eucl:idean}
    {p_end}
{p 12 14 4}
    {opt mat:rix} {help matrix:{it:matname}}
    {p_end}

{pmore}
    {cmd:mahalanobis} sets the scaling matrix to the sample covariate
    covariance matrix (separately for each over group). If {it:units} is
    provided, the matrix is transformed in a way such that its diagonal
    elements are equal to the squares of the specified values (while preserving
    the correlation structure). That is, if V is the sample covariance matrix
    and {it:sd} is the vector of sample standard deviations, the scaling matrix
    is defined as S = diag({it:units}:/{it:sd}) * V *
    diag({it:units}:/{it:sd}). The rational behind such a transformation is a
    follows. The Mahalanobis distance can be interpreted as measuring the
    distance between observations in terms of standard deviations of the
    covariates (while additionally taking into account the correlation
    structure). Instead of using standard deviations as relevant units, you may
    want to specify your own units. {it:units} must contain one value for each
    covariate (plus an additional value for the propensity score, if option
    {cmd:psvars()} or option {cmd:pscore()} has been specified). If option
    {cmd:weights()} is specified, the scaling matrix is defined as S =
    diag(1:/{it:w}) * V * diag(1:/{it:w}), where {it:w} is the vector of the specified
    weights (this is equivalent to reweighing as suggested by Greevy et al.
    2012). {it:w} must contain as many values as there are covariates. The
    default is to give each covariate a weight of one. If {cmd:psvars()} or
    {cmd:pscore()} has been specified, you can use option {cmd:psweight()} to
    assign a weight to the propensity score. If {cmd:psweight()} is omitted,
    the propensity score receives a weight of one. If both, {it:units} and
    weights, are provided, both transformations are applied.

{pmore}
    {cmd:ivariance} sets the scaling matrix to a diagonal matrix with the
    sample covariate variances on the diagonal (separately for each over
    group). Argument {it:units} and option {cmd:weights()} are as above.

{pmore}
    {cmd:euclidean} sets the scaling matrix to the identity matrix.

{pmore}
    {cmd:matrix} uses the provided matrix as scaling matrix.

{phang}
    {help kmatch##matchoptions:{it:matching_options}} select the type of matching
    procedure and set the details of the matching algorithm and
    bandwidth selection.

{phang}
    {help kmatch##goptions:{it:general_options}} select the estimands to be
    computed and set the details about standard errors, reporting, and results to
    be returned.

{dlgtab:Propensity score}

{phang}
    {opth psvars(varlist)} specifies that the propensity score estimated from
    {it:varlist} is to be included as an additional variable
    in the computation of the distances. {it:varlist}
    may contain {help fvvarlist:factor variables}. Only one of {cmd:psvars()} and
    {cmd:pscore()} is allowed.

{phang}
    {opth pscore(varname)} specifies that the propensity score contained in
    {it:varname} is to be included as an additional variable
    in the computation of the distances. Only one of {cmd:psvars()} and
    {cmd:pscore()} is allowed.

{phang}
    {opt psweight(#)} specifies the weight given to the propensity score when
    computing distances; see the {cmd:metric()} option above. The
    default is {cmd:psweight(1)}.

{phang}
    {cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}] restricts the range of observations
    that are treated as potential matches. If {cmd:comsup} is specified without
    argument, observations outside the common range of the propensity score
    will not be matched. The common range is defined as the range between
    max(min({it:ps}|{it:treatment}), min({it:ps}|{it:control})) and
    min(max({it:ps}|{it:treatment}), max({it:ps}|{it:control})), where {it:ps}
    is the propensity score. Alternatively, observations with a propensity
    score smaller than {it:lb} or, if {it:ub} is also specified, a propensity
    score larger than {it:ub} will be excluded. {cmd:comsup()} only has an
    effect if {cmd:psvars()} or {cmd:pscore()} is specified.

{phang}
    {help kmatch##pscoreoptions:{it:pscore_options}} set the details
    of the propensity score estimation.

{dlgtab:Entropy balancing}

{phang}
    {opt ebalance}[{opth (varlist)}] refines the matching weights by applying
    entropy balancing after running the matching procedure. The variables specified
    in {it:varlist} will be included in the entropy balancing procedure. {it:varlist}
    may contain {help fvvarlist:factor variables}. If
    {it:varlist} is omitted, the default is to include the main covariates ({it:xvars}).

{phang}
    {opt csonly} causes entropy balancing to be based on common
    support information only, ignoring the matching weights. By default, entropy
    balancing will use the matching weights as base weights and refine
    these weights until balance is achieved within the sample of matched
    observations. If {cmd:csonly} is specified, entropy balancing will balance
    the sample of matched observations starting from scratch, that is, ignoring the
    matching weights.

{phang}
    {help kmatch##ebaloptions:{it:ebalance_options}} select the target moments to be
    balanced and set the details of the entropy balancing algorithm.


{marker psoptions}{...}
{title:Options for kmatch ps}

{dlgtab:Main}

{phang}
    {cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}] restricts the range of observations
    that are treated as potential matches. If {cmd:comsup} is specified without
    argument, observations outside the common range of the propensity score
    will not be matched. The common range is defined as the range between
    max(min({it:ps}|{it:treatment}), min({it:ps}|{it:control})) and
    min(max({it:ps}|{it:treatment}), max({it:ps}|{it:control})), where {it:ps}
    is the propensity score. Alternatively, observations with a propensity
    score smaller than {it:lb} or, if {it:ub} is also specified, a propensity
    score larger than {it:ub} will be excluded.

{phang}
    {opth pscore(varname)} provides a variable containing the propensity score.
    No propensity score model will be estimated in this case.

{phang}
    {help kmatch##pscoreoptions:{it:pscore_options}} set the details
    of the propensity score estimation.

{phang}
    {help kmatch##matchoptions:{it:matching_options}} select the type of matching
    procedure and set the details of the matching algorithm and
    bandwidth selection.

{phang}
    {help kmatch##goptions:{it:general_options}} select the estimands to be
    computed and set the details about standard errors, reporting, and results to
    be returned.

{dlgtab:Entropy balancing}

{phang}
    {opt ebalance}[{opth (varlist)}] refines the matching weights by applying
    entropy balancing after running the matching procedure. The variables specified
    in {it:varlist} will be included in the entropy balancing procedure. {it:varlist}
    may contain {help fvvarlist:factor variables}. If
    {it:varlist} is omitted, the default is to include the main covariates ({it:xvars}).

{phang}
    {opt csonly} causes entropy balancing to be based on common
    support information only, ignoring the matching weights. By default, entropy
    balancing will use the matching weights as base weights and refine
    these weights until balance is achieved within the sample of matched
    observations. If {cmd:csonly} is specified, entropy balancing will balance
    the sample of matched observations starting from scratch, that is, ignoring the
    matching weights.

{phang}
    {help kmatch##ebaloptions:{it:ebalance_options}} select the target moments to be
    balanced and set the details of the entropy balancing algorithm.


{marker emoptions}{...}
{title:Options for kmatch em}

{dlgtab:Main}

{phang}
    {help kmatch##goptions:{it:general_options}} select the estimands to be
    computed and set the details about standard errors, reporting, and results to
    be returned.

{dlgtab:Entropy balancing}

{phang}
    {opt ebalance}[{opth (varlist)}] refines the matching weights by applying
    entropy balancing after running the matching procedure. The variables specified
    in {it:varlist} will be included in the entropy balancing procedure. {it:varlist}
    may contain {help fvvarlist:factor variables}.

{phang}
    {opt csonly} causes entropy balancing to be based on common
    support information only, ignoring the matching weights. By default, entropy
    balancing will use the matching weights as base weights and refine
    these weights until balance is achieved within the sample of matched
    observations. If {cmd:csonly} is specified, entropy balancing will balance
    the sample of matched observations starting from scratch, that is, ignoring the
    matching weights.

{phang}
    {help kmatch##ebaloptions:{it:ebalance_options}} select the target moments to be
    balanced and set the details of the entropy balancing algorithm.


{marker eboptions}{...}
{title:Options for kmatch eb}

{dlgtab:Main}

{phang}
    {help kmatch##ebaloptions:{it:ebalance_options}} select the target moments to be
    balanced and set the details of the entropy balancing algorithm.

{phang}
    {help kmatch##goptions:{it:general_options}} select the estimands to be
    computed and set the details about standard errors, reporting, and results to
    be returned.

{dlgtab:Propensity score}

{phang}
    {cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}] restricts the range of observations
    that are included in the entropy balancing. If {cmd:comsup} is specified without
    argument, observations outside the common range of the propensity score
    will not be included. The common range is defined as the range between
    max(min({it:ps}|{it:treatment}), min({it:ps}|{it:control})) and
    min(max({it:ps}|{it:treatment}), max({it:ps}|{it:control})), where {it:ps}
    is the propensity score. Alternatively, observations with a propensity
    score smaller than {it:lb} or, if {it:ub} is also specified, a propensity
    score larger than {it:ub} will be excluded.

{phang}
    {opth psvars(varlist)} specifies the variables to be used for propensity
    score estimation. {it:varlist} may contain {help fvvarlist:factor variables}. The
    default is to use the main covariates ({it:xvars}). {cmd:psvars()}
    only has an effect if {cmd:comsup()} is specified. Only one of {cmd:psvars()} and
    {cmd:pscore()} is allowed.

{phang}
    {opth pscore(varname)} provides a variable containing the propensity
    score. No propensity score model will be estimated in this case. {cmd:pscore()}
    only has an effect if {cmd:comsup()} is specified. Only one of {cmd:psvars()} and
    {cmd:pscore()} is allowed.

{phang}
    {help kmatch##pscoreoptions:{it:pscore_options}} set the details
    of the propensity score estimation.


{marker ipwoptions}{...}
{title:Options for kmatch ipw}

{dlgtab:Main}

{phang}
    {cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}] restricts the range of observations
    that are included in the inverse probability weighting. If {cmd:comsup} is specified without
    argument, observations outside the common range of the propensity score
    will not be included. The common range is defined as the range between
    max(min({it:ps}|{it:treatment}), min({it:ps}|{it:control})) and
    min(max({it:ps}|{it:treatment}), max({it:ps}|{it:control})), where {it:ps}
    is the propensity score. Alternatively, observations with a propensity
    score smaller than {it:lb} or, if {it:ub} is also specified, a propensity
    score larger than {it:ub} will be excluded.

{phang}
    {opth pscore(varname)} provides a variable containing the propensity score.
    No propensity score model will be estimated in this case.

{phang}
    {help kmatch##pscoreoptions:{it:pscore_options}} set the details
    of the propensity score estimation.

{phang}
    {cmd:nonormalize} omits the normalization of the weights computed from the
    propensity score. The default is to rescale the weights such that their sum
    equals the size of the matched group. If {cmd:nonormalize} is specified the
    equality only holds approximately.

{phang}
    {help kmatch##goptions:{it:general_options}} select the estimands to be
    computed and set the details about standard errors, reporting, and results to
    be returned.

{dlgtab:Entropy balancing}

{phang}
    {opt ebalance}[{opth (varlist)}] refines the weights by applying
    entropy balancing after running the IPW procedure. The variables specified
    in {it:varlist} will be included in the entropy balancing procedure. {it:varlist}
    may contain {help fvvarlist:factor variables}. If
    {it:varlist} is omitted, the default is to include the main covariates ({it:xvars}).

{phang}
    {opt csonly} causes entropy balancing to be based on common
    support information only, ignoring the IPWs. By default, entropy
    balancing will use the IPWs as base weights and refine
    these weights until balance is achieved within the common-support sample. If
    {cmd:csonly} is specified, entropy balancing will balance
    the common-support sample starting from scratch, that is, ignoring the
    IPWs.

{phang}
    {help kmatch##ebaloptions:{it:ebalance_options}} select the target moments to be
    balanced and set the details of the entropy balancing algorithm.


{marker raoptions}{...}
{title:Options for kmatch ra}

{dlgtab:Main}

{phang}
    {help kmatch##goptions:{it:general_options}} select the estimands to be
    computed and set the details about standard errors, reporting, and results to
    be returned.

{dlgtab:Propensity score}

{phang}
    {cmd:comsup}[{cmd:(}{it:lb} [{it:ub}]{cmd:)}] restricts the range of observations
    that are included in the regression adjustment. If {cmd:comsup} is specified without
    argument, observations outside the common range of the propensity score
    will not be included. The common range is defined as the range between
    max(min({it:ps}|{it:treatment}), min({it:ps}|{it:control})) and
    min(max({it:ps}|{it:treatment}), max({it:ps}|{it:control})), where {it:ps}
    is the propensity score. Alternatively, observations with a propensity
    score smaller than {it:lb} or, if {it:ub} is also specified, a propensity
    score larger than {it:ub} will be excluded. {cmd:comsup()} only has an effect
    if {cmd:psvars()} or {cmd:pscore()} is specified.

{phang}
    {opth psvars(varlist)} specifies the variables to be used for propensity
    score estimation. {it:varlist} may contain {help fvvarlist:factor variables}. {cmd:psvars()}
    only has an effect if {cmd:comsup()} is specified. Only one of {cmd:psvars()} and
    {cmd:pscore()} is allowed.

{phang}
    {opth pscore(varname)} provides a variable containing the propensity
    score. No propensity score model will be estimated in this case. {cmd:pscore()}
    only has an effect if {cmd:comsup()} is specified. Only one of {cmd:psvars()} and
    {cmd:pscore()} is allowed.

{phang}
    {help kmatch##pscoreoptions:{it:pscore_options}} set the details
    of the propensity score estimation.


{marker matchoptions}{...}
{title:Matching options}

{dlgtab:Main}

{marker nn}{...}
{phang}
    {opt nn}[{cmd:(}{it:#}{cmd:)}] requests that nearest-neighbor matching
    (with replacement) is used instead of kernel matching or ridge matching,
    where {it:#} specifies the (minimum) number of matches per observation. The
    default is {cmd:nn(1)} (one-to-one matching with replacement).

{phang}
    {opt keepall} causes observations to be treated as matched even if the
    minimum number of nearest neighbors is not reached. The default, unless
    {cmd:wor} is specified, is to treat such observations as unmatched. {opt keepall}
    is only relevant if {cmd:nn()}>1 is specified.

{phang}
    {opt wor} applies nearest-neighbor matching without replacement. {cmd:wor} is
    only allowed if {cmd:nn()} is specified. A greedy matching algorithm is
    used that assigns matches in ascending order of the distances between the
    observations (where "distance" is either the multivariate distance or the
    absolute difference in propensity score); see
    {helpb mf_mm_greedy:mm_greedy()}. Ties will be processed in random order; for
    stable results set the sort seed (see {helpb set sortseed}). The algorithm
    is computationally intensive and will be slow in large datasets. Speed can
    usually be increased substantially by matching some of the covariates
    exactly using the {cmd:ematch()} option. {cmd:wor} implies {cmd:keepall}.
    {cmd:fweight}s are not supported by {cmd:wor}.

{phang}
    {opt ridge}[{cmd:(}{it:#}{cmd:)}] requests that ridge matching is used
    instead of standard kernel matching, where {it:#} is the ridge parameter
    (see Frölich 2004, 2005). Specifying {it:#} is not necessary
    as {cmd:kmatch} picks a parameter appropriate for the chosen kernel. However,
    you can type {cmd:ridge(0)} if you want to apply standard local-linear
    matching.

{marker kernel}{...}
{phang}
    {opt kernel(kernel)} specifies the kernel
    function for kernel matching and ridge matching. {it:kernel} may be:

            {opt e:pan}        Epanechnikov kernel function; the default
            {opt r:ectangle}   rectangle kernel function
            {opt u:niform}     synonym for {cmd:rectangle}
            {opt t:riangle}    triangle kernel function
            {opt b:iweight}    biweight kernel function
            {opt triw:eight}   triweight kernel function
            {opt c:osine}      cosine trace kernel function
            {opt p:arzen}      Parzen kernel function

{pmore}
    All kernels are defined such that they have a support of +/- 1.

{marker ematch}{...}
{phang}
    {opth ematch(emvars)} requests that the specified variables are matched
    exactly. Factor variables are not allowed in {it:emvars}, but you may
    include coarsening rules to transform the variables before matching (as
    proposed by Blackwell et al. 2009, Iacus et al. 2012). The
    syntax of {it:emvars} is

            [{cmd:(}{it:rule}{cmd:)}] {it:varlist} [ {cmd:(}{it:rule}{cmd:)} {it:varlist} ... ]

{pmore}
    where {it:rule} will be applied to each variable of the subsequent
    {it:varlist} up to the next rule specification. Omitting the initial rule
    is equivalent to setting the rule to {cmd:asis}. {it:rule} may be:

{p2colset 13 25 27 2}{...}
{p2col:{cmd:asis}}do not coarsen; synonyms for {cmd:(asis)} are {cmd:(#0)}, {cmd:(.)}, and {cmd:()}{p_end}
{p2col:{it:{help numlist}}}coarsen at specified cutpoints{p_end}
{p2col:{cmd:#}{it:c}}coarsen at {it:c} equally spaced cutpoints{p_end}
{p2col:{cmd:hist}}use cutpoints based on the rule used by {helpb histogram}{p_end}
{p2col:{cmd:sturges}}use cutpoints based on Sturges' formula{p_end}
{p2col:{cmd:rice}}use cutpoints based on the Rice Rule{p_end}
{p2col:{cmd:doane}}use cutpoints based on Doane's formula{p_end}
{p2col:{cmd:scott}}use cutpoints based on Scott's normal reference rule{p_end}
{p2col:{cmd:fd}}use cutpoints based on Freedman–Diaconis' choice{p_end}

{pmore}
    The named rules above are methods for determining the number of bins or the bin
    width in a histogram; for {cmd:hist} see help {helpb histogram}; for the
    other rules see {browse "http://en.wikipedia.org/wiki/Histogram"}. Let
    {it:c} be the number of cutpoints and {it:h} be the bin
    width. {cmd:kmatch} sets the cutpoints such that the range of x is divided
    into {it:c}+1 equally spaced bins. For methods that determine {it:h},
    {it:c} is computed as ceil(range(x)/{it:h}); the resulting bin width may thus
    be different from the initial {it:h}. Furthermore, {it:c} is restricted to
    a minimum of one (at least two bins).

{dlgtab:Bandwidth/Caliper}

{marker bwidth}{...}
{phang}
    {opt bwidth(bwspec)} specifies the half-width of the kernel for kernel and
    ridge matching or sets a caliper for nearest-neighbor matching. If the
    distance between two observations is larger (or, for kernel and ridge
    matching, larger-or-equal) than the specified bandwidth or caliper they are
    not considered as a (potential) match. For nearest-neighbor matching, the
    default is to allow all observations as potential matches regardless of
    distance. For kernel and ridge matching the default is to select a
    bandwidth based on the pair-matching algorithm described below. {it:bwspec}
    may be

{p 12 14 4}
            {it:{help numlist}}

{pmore}
    to provide a specific bandwidth or caliper. If multiple values are specified,
    different bandwidths are used for the different matching directions and over
    groups (each over group consumes one or two values depending on whether
    one-sided or two-sided matching has been requested and depending
    on whether {cmd:sharedbwidth} has been specified; values will be recycled
    if {it:{help numlist}} contains fewer values than matching directions
    times over groups). For kernel and ridge matching, {it:bwspec} may also be

{p 12 14 4}
            {cmd:pm} [{it:q} [{it:f}]] [{cmd:,} {opt qui:etly}]

{pmore}
    to select a bandwidth based on a pair-matching algorithm similar to the proposal by
    Huber et al. (2013, 2015). The algorithm sets the bandwidth to {it:f} times
    the {it:q}-quantile of the distribution of (non-zero) distances between
    observations in one-to-one matching (1-nearest-neighbor matching
    with replacement). Factor {it:f} defaults to 1.5, quantile {it:q} defaults
    to 0.90. Option {opt quietly} suppresses the output of the algorithm.
    Alternatively, for kernel and ridge matching, {it:bwspec} may be

{p 12 14 4}
            {cmd:cv} [{help varname:{it:cvvar}}] [{cmd:,}
            {opt w:eighted}
            {opt nop:enalty}
            {opt nol:imit}
            {opt q:uantile(#)}
            {opt f:actor(#)}
            {opt sf:actor(#)}
            {opt n(#)}
            {opt r:ange(lb ub)}
            {opth g:rid(numlist)}
            {opt exact}
            {opt qui:etly} ]

{pmore}
    to determine the bandwidth by cross-validation. If outcome variable
    {it:cvvar} is provided, cross-validation with respect to {it:cvvar} as
    suggested by Frölich (2004, 2005) is performed. If, in addition, option
    {cmd:weighted} is specified, weighted cross-validation with respect to
    {it:cvvar} as suggested by Galdo et al. (2008; Section 4.2) is
    performed. Deviating from the literature, a correction is applied for loss of
    observations if there is lack of common support. Specify option
    {cmd:nopenalty} to skip the correction. If {it:cvvar} is omitted,
    cross-validation is performed with respect to the mean of the propensity
    score (in case of {cmd:kmatch ps}) or the means of the covariates (in case
    of {cmd:kmatch md}). Option {cmd:nopenalty} has no effect in this
    case. Occasionally, cross-validation can yield excessively large bandwidth
    estimates. To limit such behavior, a penalty is applied to the cross-validation
    criterion for bandwidths larger than the standard deviation of the
    propensity score (in case of {cmd:kmatch ps}) or the square-root of the number
    of covariates (in case of {cmd:kmatch ps}). Specify option {cmd:nolimit}
    to omit the penalty.

{pmore}
    By default, the cross-validation search algorithm starts at the bandwidth
    determined by the pair-matching method described above and leaps up or down
    until a local minimum is encountered. The local minimum is then further
    refined until the maximum number of steps is reached. Options
    {cmd:quantile()} and {cmd:factor()} set the parameters for the initial
    pair-matching bandwidth (see above). Option {cmd:sfactor()} sets the
    relative step size for the first phase of the search algorithm. The default
    is 1.5, meaning that the bandwidth is either multiplied by 1.5 or divided by
    1.5 from one step to the next, depending on search direction. The default
    is to start the algorithm with a step up; set {cmd:sfactor()}
    to a value between 0 and 1 to start with a step down. Option {cmd:n()}
    sets the total number of steps; default is 15. Alternatively, specify
    {cmd:range()} to use an equally-spaced evaluation
    grid between {it:lb} and {it:ub}, or provide a custom evaluation grid using
    the {cmd:grid()} option. For ridge matching, cross-validation without
    {it:cvvar} is only approximate for reasons of speed; specify option
    {cmd:exact} to request exact computations ({cmd:exact} has no effect
    if {it:cvvar} is provided). Furthermore, specify option
    {cmd:quietly} to suppress the output of the algorithm.

{phang}
    {opth caliper(numlist)} is a synonym for {helpb kmatch##bwidth:bwidth({it:numlist})}.

{phang}
    {opt sharedbwidth} requests that the same bandwidth is used for both matching
    directions. By default, bandwidth search will be run separately for the treated
    and for the untreated. If {cmd:sharedbwidth} is specified, bandwidth search will
    be run jointly across both groups. Option {cmd:sharedbwidth} has no effect
    if only one matching direction has been requested.

{phang}
    {opth bwadjust(numlist)} adjusts the bandwidth or caliper by multiplying it by the
    specified factor. If multiple values are specified, different adjustments
    are used for the different matching directions and over groups (each over
    group consumes one or two values depending on whether one-sided or
    two-sided matching has been requested; values will be recycled if
    {it:{help numlist}} contains fewer values than matching directions times
    over groups).


{marker pscoreoptions}{...}
{title:Propensity score estimation options}

{phang}
    {opt pscmd(command)} specifies the command used to estimate the propensity
    score. The the default command is {helpb logit}. For example, specify
    {cmd:pscmd(probit)} to use a {helpb probit} model.

{phang}
    {opt psopts(options)} provides options to be passed through to the
    propensity score estimation command.

{marker maxiter}{...}
{phang}
    {opt maxiter(#)} sets the maximum number of iterations for the propensity
    score estimation command, where # can be between 0 and 16000. The default is
    {it:#} = {cmd:min(50,c(maxiter))} (standard commands such as {helpb logit} or {helpb probit}
    typically converge within just a handful of iterations if a solution exists).
    {cmd:maxiter()} temporarily resets {helpb set maxiter}; commands
    that are not sensitive to this setting will not be affected.

{phang}
    {opt pspredict(options)} provides options to be passed through to the call
    to {helpb predict} that generates the propensity scores after model
    estimation. The default is {cmd:pspredict(pr)} so that probabilities are
    generated. For example, specify {cmd:pspredict(xb)} to use the liner
    predictor instead of probabilities. Options allowed in {opt pspredict()}
    depend on the command used for model estimation; see {cmd:pscmd()} above.


{marker ebaloptions}{...}
{title:Entropy balancing options}

{phang}
    {opth targets(numlist)} specifies the target moments to be balanced. {it:numlist} may contain
    values {cmd:1} (balance mean), {cmd:2} (balance mean and variance), and
    {cmd:3} (balance mean, variance, and skewness). The elements of {it:numlist} will
    be applied to the covariates one after the other. If {it:numlist} is shorter
    then the number of covariates, the element will be recycled. For example,
    {cmd:targets(2)} will balance all means and all variances; {cmd:targets(1 2)} will balance
    the mean of the first (and 3rd, 5th, etc.) variable and the mean and variance of the
    second (and 4th, 6th, etc.) variable. Higher order moments that
    are collinear with lower order moments will be omitted automatically. The default is
    {cmd:targets(1)} (balance all means).

{phang}
    {opt covariances} additionally balances all covariances between the covariates.

{phang}
    {opt btolerance(#)}, #>0, sets the balancing tolerance. Balancing is achieved if the
    balancing loss is smaller than {opt btolerance()}. Treatment effects estimates
    based on solutions that do not achieve balance are set to 0 and flagged as
    omitted.

{marker fitopts}{...}
{phang}
    {opt fitopts(options)} set the details of the balancing algorithm. {it:options}
    are as follows:

{phang2}
    {opt dfc:orrection} applies degrees-of-freedom correction to balancing
    constraints for variances and covariances. The default balancing
    constraints are consistent with computing variances and covariances in the
    reweighted group based on weights that are normalized to sum to the size of
    the target group (or with variance formulas that ignore degrees-of-freedom
    adjustment in the denominator). If {cmd:dfcorrection} is specified, the
    results are consistent with weights normalized to the size of the
    reweighted group (which is equivalent to how {helpb summarize} with
    {cmd:aweight}s computes variances). {cmd:dfcorrection} only affects
    variances and covariances that are not collinear with lower moments.

{phang2}
    {opt nc:onstraint} includes the normalization constraint (target sum of weights)
    in the optimization problem, rather than rescaling the weights ex
    ante. In this case, if perfect balance is not possible, the sum of the
    balancing weights is no longer guaranteed to be equal to the size of the
    target group.

{phang2}
    {opt nost:andardize} suppresses standardization of the constraint matrix. By
    default, the columns of the constraint matrix are divided by the
    standard deviations of the corresponding terms in the target group (if the
    standard deviations exist). This should make the optimization more stable
    as all constraints have a similar scaling and the balancing loss is
    expressed in terms of standardized differences.

{phang2}
    {opt dif:ficult} causes an alternative stepping algorithm to be used in
    nonconcave regions of the optimization problem. See the {cmd:difficult} option
    in {helpb maximize} for more information.

{phang2}
    {opt maxi:ter(#)}, # in [0,16000], sets the maximum
    number of iterations. The default is {cmd:c(maxiter)} as set by
    {helpb set maxiter}.

{phang2}
    {opt ptol:erance(#)} and {opt vtol:erance(#)} set the convergence tolerances
    for the parameter vector (lambda coefficients) and the balancing loss,
    respectively. The defaults are {cmd:ptolerance(1e-6)} and
    {cmd:vtolerance(1e-7)}. Convergence is reached if the maximum relative change in
    the parameter vector is smaller than {cmd:ptolerance()} or if the
    relative change in the balancing loss is smaller than {cmd:vtolerance()}.


{marker goptions}{...}
{title:General options (estimands, standard errors, reporting, etc.)}

{dlgtab:Main}

{phang}
    {opt tvalue(#)} specifies the value of {it:tvar} that is the treatment. The
    default is {cmd:tvalue(1)}.

{phang}
    {opth over(varname)} computes results for each subpopulation defined
    by the values of {it:varname}. Matching is performed separately for each
    group.

{dlgtab:Estimands}

{phang}
    {opt ate} requests that average treatment effects are reported. This is
    the default unless {cmd:att} and/or {cmd:atc} is specified. If you want to
    report results for multiple estimands, type several of these options. The options also
    affect whether two-sided or only one-sided matching is performed. {cmd:ate}
    requires matching in both directions; {cmd:att} requires matching
    the treated; {cmd:atc} requires matching the untreated.

{phang}
    {opt att} requests that average treatment effects on the
    treated are reported.

{phang}
    {opt atc} requests that average treatment effects on the
    untreated are reported.

{phang}
    {opt nate} requests that naive average treatment effects
    (unconditional mean differences; without regression adjustment) are reported
    in addition to the matched treatment effects.

{phang}
    {opt po} requests that potential outcome averages are reported in addition
    to the treatment effects.

{dlgtab:SE/CI}

{marker vce}{...}
{phang}
    {opth vce(vcetype)} determines how standard errors and confidence intervals
    are computed. {it:vcetype} may be:

            {cmd:analytic}
            {cmd:cluster} {it:clustvar}
            {cmd:bootstrap} [{cmd:,} {help bootstrap:{it:bootstrap_options}}]
            {cmd:jackknife} [{cmd:,} {help jackknife:{it:jackknife_options}}]

{pmore}
    The default is {cmd:analytic}. If {cmd:vce()} is {cmd:analytic} or
    {cmd:cluster}, the standard errors are estimated based on influence functions
    (see {browse "http://ideas.repec.org/p/bss/wpaper/32.html":Jann 2019}),
    assuming the matching or balancing weights to be fixed. Assuming the weights
    to be fixed is an oversimplification that may bias the results. My experience
    from some limited simulations is that the influence-function
    standard errors will tend to be conservative (i.e. to large; except for
    {cmd:kmatch ra}, for which the influence-function standard errors are
    consistent). However, applying post-matching regression adjustment seems to
    help a lot, at least in my simulations. Not only did regression adjustment
    reduce the bias in the treatment effect estimates (due to exploitation of the
    double-robust property), it also made the influence-function standard
    errors consistent in most cases.

{pmore}
    To get better standard errors I suggest to rely on {helpb teffects}
    whenever possible and use {cmd:vce(bootstrap)} in other cases. In my
    simulations, the bootstrap generally produced good results, with the
    exception of nearest-neighbor matching, where the bootstrap standard errors
    tended to be conservative. For nearest-neighbor matching it has also been
    shown theoretically that the boostrap is not consistent (Abadie and Imbens
    2008). Official Stata's {helpb teffetcs nnmatch} and
    {helpb teffetcs psmatch} will produce consistent standard errors for nearest-neighbor
    matching.

{pmore}
    In case of kernel and Ridge matching with automatic bandwidth selection,
    the bandwidth is held fixed across bootstrap or jackknife
    replications. If you want to repeat bandwidth search in each
    replication, use the {helpb bootstrap} or {helpb jackknife} prefix
    command.

{pmore}
    In small samples it may happen that some estimates cannot be
    computed in a specific replication (for example, because the treatment
    does not vary). {cmd:kmatch} returns such estimates as 0 and sets
    {cmd:e(k_omit)} to the number of estimates that could not be
    computed. To prevent {helpb bootstrap} and {helpb jackknife}
    from using these estimates, add option {cmd:reject(e(k_omit))} to the
    {helpb bootstrap} or {helpb jackknife} command. That is, for example, type

            {cmd: bootstrap, reject(e(k_omit)): kmatch} {it:...}

{pmore}
    When using {cmd:bootstrap} or {cmd:jackknife} via the {cmd:vce()} option,
    such estimates are excluded automatically.

{pmore}
    {cmd:vce(bootstrap)} and {cmd:vce(jackknife)} require that at least one
    outcome variable has been specified.

{phang}
    {cmd:svy} causes the survey design to be taken into account for variance
    estimation, using the estimation method as set in {helpb svyset}. This option may 
    not be specified with {cmd:vce()} or weights, and it requires that at least one 
    outcome variable has been specified. Taylor-linearized variance estimation will 
    be based on influence functions assuming balancing weights as fixed; see the 
    {cmd:vce()} option.

{phang}
    {cmd:subpop(}{it:subpop}{cmd:)} restricts survey estimation to a single
    subpopulation identified by {it:subpop}, which is

            [{varname}] [{it:{help if}}]

{pmore}
    The subpopulation is defined by observations for which {it:varname}!=0 and
    for which the {cmd:if} condition is met. See help {helpb svy} and
    {manlink SVY subpopulation estimation} for more information on subpopulation
    estimation. {cmd:subpop()} requires the {cmd:svy} option.

{phang}
    {cmd:nose} suppresses the computation of standard errors. Use this option 
    if you want to save computer time, for example, in simulations. {cmd:nose} may not be 
    specified with {cmd:vce()} or {cmd:svy}.

{dlgtab:Reporting}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)} or as set by
    {helpb set level}.

{phang}
    {opt noisily} displays auxiliary results such as the output from propensity
    score estimation or the output from regression adjustment.

{phang}
    {opt noheader} suppresses the output header.

{phang}
    {opt nomtable} suppress the table containing the matching statistics.

{phang}
    {opt notable} suppresses the coefficients table containing the
    treatment effects.

{phang}
    {it:display_options} are standard reporting options as described in
    {helpb estimation options:[R] estimation options}.

{dlgtab:Generate}

{marker gen}{...}
{phang}
    {opt generate}[{cmd:(}{it:spec}{cmd:)}] generates a number of variables
    containing the matching results. {it:spec} may either be
    {help newvarlist:{it:newvarlist}} to provide explicit names for the generated
    variables or {it:prefix}{cmd:*} to provide a prefix for the variable names.
    The default prefix is {cmd:_KM_}. The following variables will be generated:

{p2colset 13 25 27 2}{...}
{p2col:{cmd:_KM_treat}}treatment indicator{p_end}
{p2col:{cmd:_KM_nc}}number of matched controls{p_end}
{p2col:{cmd:_KM_nm}}number of times used as a match{p_end}
{p2col:{cmd:_KM_mw}}matching weight{p_end}
{p2col:{cmd:_KM_ps}}propensity score (only if a propensity has been estimated){p_end}
{p2col:{cmd:_KM_strata}}matching stratum ({cmd:kmatch md}, {cmd:kmatch ps}, and {cmd:kmatch em} only){p_end}

{marker wgen}{...}
{phang}
    {opt wgenerate}[{cmd:(}{it:spec}{cmd:)}] generates variables
    containing the ready-to-use matching weights. {it:spec} may either be
    {help newvarlist:{it:newvarlist}} to provide explicit names for the
    generated variables or {it:prefix}{cmd:*} to provide a prefix for the
    variable names. The default prefix is {cmd:_W_}. A selection of the
    following variables will be generated:

{p2colset 13 25 27 2}{...}
{p2col:{cmd:_W_ATE}}weights for computing the ATE (if {cmd:ate} or none of {cmd:ate}, {cmd:att}, and {cmd:atc} is specified){p_end}
{p2col:{cmd:_W_ATT}}weights for computing the ATT (if {cmd:att} is specified){p_end}
{p2col:{cmd:_W_ATC}}weights for computing the ATC (if {cmd:atc} is specified){p_end}

{pmore}
    Variable {cmd:_KM_mw} stored by {cmd:generate()} contains raw control observation
    matching weights that need to be modified if you want
    to use them to estimate a treatment effect. In contrast, {cmd:wgenerate()}
    stores weights to which the necessary modifications have been applied. The
    definitions are

            {cmd:_W_ATE} = {it:w} + {cmd:_KM_mw} * {it:fw}
            {cmd:_W_ATT} = cond({cmd:_KM_treat}==1, {it:w}, {cmd:_KM_mw} * {it:fw})
            {cmd:_W_ATC} = cond({cmd:_KM_treat}==0, {it:w}, {cmd:_KM_mw} * {it:fw})

{pmore}
    where {it:w} are the base weights (or 1 if no weights have been specified)
    and {it:fw} = {it:w} in case of {cmd:fweight}s and 1 else. In addition, the
    stored weights take into account whether an observation could be matched or was used
    as a match (the weights will be zero for observations that could neither be matched
    nor were used as a match). The weights stored by {cmd:wgenerate()} can be used
    as is in commands such as {helpb regress} or {helpb teffects ra} to reproduce
    the estimates reported by {cmd:kmatch} (although standard errors will not be
    exactly the same). Here is an example:

{p 12 16 2}. {stata sysuse nlsw88, clear}{p_end}
{p 12 16 2}. {stata kmatch md union age married grade south smsa (wage), att wgenerate(W)}{p_end}
{p 12 16 2}. {stata regress wage union [pweight = W]}{p_end}
{p 12 16 2}. {stata kmatch md union age married grade south smsa (wage = age married grade south smsa), att wgenerate(W) replace}{p_end}
{p 12 16 2}. {stata teffects ra (wage age married grade south smsa) (union) [pweight = W], atet}{p_end}

{marker dygen}{...}
{phang}
    {opt dygenerate}[{cmd:(}{it:spec}{cmd:)}] generates variables containing potential
    outcome differences. {it:spec} may either be
    {help newvarlist:{it:newvarlist}} to provide explicit names for the generated
    variables or {it:prefix}{cmd:*} to provide a prefix for the variable names.
    The variables will then be named as {it:prefix}{it:ovar}, where {it:ovar}
    is the name of the outcome variable. The default prefix is {cmd:_DY_}. If
    regression adjustment is applied, potential outcomes will be computed as
    predictions from the regression adjustment equation plus the residuals from
    a regression of the unadjusted potential outcomes on the adjustment
    variables.

{phang}
    {opt idgenerate}[{cmd:(}{it:prefix}{cmd:)}] generates variables containing
    the IDs (observations numbers) of the matched controls. The variables will
    be named as {it:prefix}#, where # is an index for the number of the
    control. The default prefix is {cmd:_ID_}. {cmd:idgenerate()} is only
    allowed with {cmd:kmatch md}, {cmd:kmatch ps}, and {cmd:kmatch em}.

{phang}
    {opth idvar(varname)} provides custom IDs to be used by {cmd:idgenerate()}.
    {it:varname} may be numeric or string. The default is to use the
    observation numbers as IDs (based on the sort order at the time when
    {cmd:kmatch} is called). {cmd:idvar()} is only
    allowed with {cmd:kmatch md}, {cmd:kmatch ps}, and {cmd:kmatch em}.

{phang}
    {cmd:dxgenerate}[{cmd:(}{it:prefix}{cmd:)}] generates variables containing
    the individual distances to the matched controls (Mahalanobis distances or propensity
    score differences, depending on context). The variables will be named as
    {it:prefix}#, where # is an index for the number of the control. The
    default prefix is {cmd:_DX_}. {cmd:dxgenerate()} is only
    allowed with {cmd:kmatch md}, {cmd:kmatch ps}, and {cmd:kmatch em}.

{marker cemgen}{...}
{phang}
    {opt cemgenerate}[{cmd:(}{it:spec}{cmd:)}] stores the coarsened variables
    resulting from {help kmatch##ematch:{it:emvars}}. {it:spec} may either be
    {help newvarlist:{it:newvarlist}} to provide explicit names for the
    generated variables or {it:prefix}{cmd:*} to provide a prefix for the
    variable names. Unless {it:newvarlist} is specified, the generated
    variables will be named as {it:prefix}{it:varname}, where {it:varname}
    is the name of the coarsened variable. {cmd:cemgenerate()} is only
    allowed with {cmd:kmatch md}, {cmd:kmatch ps}, and {cmd:kmatch em}.

{marker ifgen}{...}
{phang}
    {opt ifgenerate}[{cmd:(}{it:spec}{cmd:)}] generates variables
    containing the influence functions that were used to estimate the
    standard errors. {cmd:ifgenerate()} only has an effect if {cmd:vce()}
    is {cmd:analytic} or {cmd:cluster}. {it:spec} may either be
    {help newvarlist:{it:newvarlist}} to provide explicit names for the generated
    variables or {it:prefix}{cmd:*} to provide a prefix for the variable names. The
    default prefix is {cmd:_IF_}.

{phang}
    {opt replace} allows {cmd:generate()}, {cmd:dygenerate()},
    {cmd:idgenerate()}, {cmd:dxgenerate()}, and {cmd:ifgenerate()} to overwrite
    existing variables.


{marker cvplotoptions}{...}
{title:Options for kmatch cvplot}

{phang}
    {opt index} displays index numbers for the steps of the search algorithm
    as marker labels. Use {it:{help marker_label_options}} to change the position
    and style of the marker labels.

{phang}
    {opt range(lb ub)} restricts the displayed results to bandwidths within the
    specified range.

{phang}
    {opt notreated} omits the results of the bandwidth search for matching the
    treated and {opt nountreated} omits the results of the bandwidth search for
    matching the untreated. These options only have an effect if separate results
    for the treated and the untreated are available. Only one of
    {cmd:notreated} and {cmd:nountreated} is allowed.

{phang}
    {it:{help scatter:scatter_options}} are any options allowed by
    {helpb graph twoway scatter}.

{phang}
    {cmd:combopts(}{help graph combine:{it:options}}{cmd:)} are options passed
    through to {helpb graph combine}. This is only relevant when plotting results from
    multiple over-groups.

{phang}
    {opt titles(strlist)} provides titles for the subgraphs. This is only
    relevant when plotting results from multiple over-groups. Enclose the
    titles in double quotes if they contain spaces, e.g.,
    {cmd:titels({bind:"Title 1"} {bind:"Title 2"} ...)}.


{marker sumoptions}{...}
{title:Options for kmatch summarize and kmatch csummarize}

{phang}
    {cmd:ate}, {cmd:att}, and {cmd:atc} select the results to be reported. Only
    one of {cmd:ate}, {cmd:att}, and {cmd:atc} is allowed. {cmd:ate} reports
    results corresponding to the ATE; {cmd:att} reports results corresponding
    to the ATT; {cmd:atc} reports results corresponding to the ATC. Whether a
    specific option is allowed depends context.

{phang}
    {opt sd} reports standard deviations instead of variances.

{phang}
    {opt skewness} requests that skewnesses be computed in addition to means and variances.

{phang}
    {opt meanonly} displays only the table reporting means.

{phang}
    {opt varonly}  displays only the table reporting variances or standard deviations.

{phang}
    {opt skewonly}  displays only the table reporting skewnesses.


{marker groptions}{...}
{title:Options for balancing plots and common-support plots}

{dlgtab:Common options}

{phang}
    {cmd:ate}, {cmd:att}, and {cmd:atc} select the results to be reported. Only
    one of {cmd:ate}, {cmd:att}, and {cmd:atc} is allowed. {cmd:ate} reports
    results corresponding to the ATE; {cmd:att} reports results corresponding
    to the ATT; {cmd:atc} reports results corresponding to the ATC. Whether a
    specific option is allowed depends context.

{phang}
    {opth overlevels(numlist)} specifies the values of the over-groups
    to be included in the graph. The default is to include all over-groups.

{phang}
    {cmd:combopts(}{help graph combine:{it:options}}{cmd:)} are options passed
    through to {helpb graph combine}. This is only relevant when plotting results from
    multiple over-groups.

{phang}
    {opt titles(strlist)} provides titles for the subgraphs. This is only
    relevant when plotting results from multiple over-groups. Enclose the
    titles in double quotes if they contain spaces, e.g.,
    {cmd:titels({bind:"Title 1"} {bind:"Title 2"} ...)}.

{phang}
    {opt labels(strlist)} specifies labels for the subgraphs by raw and
    matched samples. The default is {cmd:labels("Raw" "Matched")}. Option
    {cmd:labels()} is only allowed for balancing plots.

{phang}
    {cmdab:byopts(}{help by_option:{it:byopts}}{cmd:)}
    are options controlling how the subgraphs by raw and matched samples
    are combined. Option {cmd:byopts()} is only allowed for balancing plots.

{phang}
    {opt nomatched} omits the results for matched observations. Option
    {cmd:nomatched} is only allowed for common-support plots.

{phang}
    {opt nounmatched} omits the results for unmatched observations. Option
    {cmd:nounmatched} is only allowed for common-support plots.

{phang}
    {opt nototal} omits the results for the combined sample. Option
    {cmd:nototal} is only allowed for common-support plots.

{dlgtab:For all but kmatch box and kmatch cbox}

{phang}
    {it:{help line:line_options}} are any options allowed by
    {helpb graph twoway line}

{dlgtab:For kmatch box and kmatch cbox}

{phang}
    {it:{help legend_options:legend_options}} are options controlling the
    legend.

{phang}
    {it:{help graph_box##boxlook_options:boxlook_options}} are {helpb graph box}
    options controlling the look of the boxes.

{phang}
    {it:{help graph_box##axis_options:axis_options}} are {helpb graph box}
    options controlling the rendering of the y axis.

{phang}
    {it:{help graph_box##title_and_other_options:other_options}} are {helpb graph box}
    options controlling titles, added text, aspect ratio, etc.

{dlgtab:For kmatch density and kmatch cdensity}

{phang}
    {opt n(#)} specifies the number of evaluation points used to estimate the
    density. The default is {cmd:n(512)}.

{marker bwtype}{...}
{phang}
    {opt bw:idth(#|type)} sets the bandwidth to {it:#} or
    specifies the automatic bandwidth selector,
    where {it:type} is {cmdab:s:ilverman} (the default),
    {cmdab:n:ormalscale}, {cmdab:o:versmoothed}, {opt sj:pi}, or
    {cmdab:d:pi}[{cmd:(}{it:#}{cmd:)}]. See {helpb kdens} for details.

{phang}
    {opt adjust(#)} causes the bandwidth to be multiplied by
    {it:#}. Default is {cmd:adjust(1)}.

{phang}
    {cmd:adaptive}[{cmd:(}{it:#}{cmd:)}] causes the adaptive kernel density
    estimator to be used. See {helpb kdens} for details.

{phang}
    {opt ll(#)} and {opt ul(#)} specify the lower and upper boundary of the
    domain of the plotted variable. {cmd:ll()} must be lower than or equal to
    the minimum observed value; {cmd:ul()} must be larger than or equal to the
    maximum observed value. If plotting the propensity score, {cmd:ll()} and
    {cmd:ul()} will be set to 0 and 1.

{phang}
    {opt reflection} and {opt lc} select the boundary
    correction technique to be used for variables with bounded support. The default
    technique is renormalization. See {helpb kdens} for details.

{phang}
    {opt kernel(kernel)} specifies the kernel function. See {helpb kdens} for
    available kernels.


{marker ex}{...}
{title:Examples}

        {help kmatch##exmd:Multivariate-distance matching}
        {help kmatch##exps:Propensity-score matching}
        {help kmatch##exem:Coarsened exact matching}
        {help kmatch##exeb:Entropy balancing}
        {help kmatch##exipw:Inverse probability weighting}
        {help kmatch##exra:Regression adjustment}

        {help kmatch##exmdv:Multiple outcome variables}
        {help kmatch##exte:ATE, ATT, ATC, NATE, and potential outcome means}
        {help kmatch##exsubpop:Results by subpopulations}
        {help kmatch##exbal:Balancing diagnostics}
        {help kmatch##excomsup:Common support diagnostics}
        {help kmatch##exbw:Bandwidth selection}

{dlgtab:Load example data}

{p 8 12 2}. {stata webuse cattaneo2, clear}{p_end}

{marker exmd}{...}
{dlgtab:Multivariate-distance matching}

{pstd}
    Average treatment effect on the treated of {cmd:mbsmoke} on {cmd:bweight} using
    Mahalanobis-distance kernel matching

{p 8 12 2}. {stata kmatch md mbsmoke mage prenatal1 mmarried fbaby (bweight), att}{p_end}

{pstd}
    Refit the above model, but require exact matches on the binary variables

{p 8 12 2}. {stata kmatch md mbsmoke mage (bweight), ematch(prenatal1 mmarried fbaby) att}{p_end}

{pstd}
    Match on two continuous variables, {cmd:mage} and {cmd:fage}, and apply post-matching
    regression adjustment

{p 8 12 2}. {stata kmatch md mbsmoke mage fage (bweight = mage fage), ematch(prenatal1 mmarried fbaby) att}{p_end}

{pstd}
    Use nearest-neighbor matching (5 neighbors; with replacement) instead of kernel matching

{p 8 12 2}. {stata kmatch md mbsmoke mage fage (bweight = mage fage), ematch(prenatal1 mmarried fbaby) att nn(5)}{p_end}

{pstd}
    Compare results to {helpb teffects nnmatch}

{p 8 12 2}. {stata teffects nnmatch (bweight mage fage) (mbsmoke), ematch(prenatal1 mmarried fbaby) biasadj(mage fage) atet nn(5)}

{pstd}
    Use nearest-neighbor matching without replacement (1 neighbor)

{p 8 12 2}. {stata kmatch md mbsmoke mage fage (bweight = mage fage), ematch(prenatal1 mmarried fbaby) att nn(1) wor}{p_end}

{pstd}
    Use kernel matching including a doubly-weighted propensity score in the Mahalanobis distances

{p 8 12 2}. {stata kmatch md mbsmoke mage prenatal1 mmarried fbaby (bweight), att psvars(fage fedu) psweight(2)}{p_end}

{marker exps}{...}
{dlgtab:Propensity-score matching}

{pstd}
    Average treatment effect on the treated of {cmd:mbsmoke} on {cmd:bweight} using kernel matching
    based on a logistic model (the default) to predict
    each subject's propensity score

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight), att}{p_end}

{pstd}
    Refit the above model, but require exact matches on the binary variables

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage (bweight), ematch(prenatal1 mmarried fbaby) att}{p_end}

{pstd}
    Include post-matching regression adjustment for the continuous covariates

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage (bweight = mage fage), ematch(prenatal1 mmarried fbaby) att}{p_end}

{pstd}
    Use nearest-neighbor matching (5 neighbors; with replacement) instead of kernel matching

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight), att nn(5)}{p_end}

{pstd}
    Compare results to {helpb teffects nnmatch}

{p 8 12 2}. {stata teffects psmatch (bweight) (mbsmoke mage fage prenatal1 mmarried fbaby), atet nn(5)}

{pstd}
    Use nearest-neighbor matching, but only consider a pair of observations a
    match if the absolute difference in the propensity score is less than 0.005
    (half a percentage point)

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight), att nn(5) caliper(0.005)}{p_end}

{pstd}
    Use ridge matching

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight), att ridge}{p_end}

{pstd}
    Use local-linear matching (set the ridge parameter to 0)

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight), att ridge(0)}{p_end}

{marker exem}{...}
{dlgtab:Coarsened exact matching}

{pstd}
    Coarsen the continuous covariates using Sturges' formula

{p 8 12 2}. {stata kmatch em mbsmoke (sturges) mage fage (asis) prenatal1 mmarried fbaby (bweight), att}{p_end}

{pstd}
    The used cutpoints are stored in {cmd:e(C_}{it:varname}{it:)}

{p 8 12 2}. {stata matrix list e(C_mage)}{p_end}
{p 8 12 2}. {stata matrix list e(C_fage)}{p_end}

{pstd}
    Coarsen the continuous covariates using 9 equally-spaced
    cutpoints

{p 8 12 2}. {stata kmatch em mbsmoke (#9) mage fage (asis) prenatal1 mmarried fbaby (bweight), att}{p_end}

{pstd}
    Coarsen the continuous covariates using predefined cutpoints

{p 8 12 2}. {stata kmatch em mbsmoke (10(5)40) mage (0(5)60) fage (asis) prenatal1 mmarried fbaby (bweight), att}{p_end}

{marker exeb}{...}
{dlgtab:Entropy balancing}

{pstd}
    Balance first moments (means)

{p 8 12 2}. {stata kmatch eb mbsmoke mage fage prenatal1 mmarried fbaby (bweight), att}{p_end}

{pstd}
    If successful, entropy balancing perfectly balances the moments (apart from
    roundoff error), as can be confirmed by the following command

{p 8 12 2}. {stata kmatch summarize, meanonly}{p_end}

{pstd}
    Balance first moments (means), second moments (variances), and covariances

{p 8 12 2}. {stata kmatch eb mbsmoke mage fage prenatal1 mmarried fbaby (bweight), att targets(2) covariances}{p_end}

{pstd}
    Treatment effect estimates will be set to 0 and flagged as omitted if
    the balancing tolerance cannot be met

{p 8 12 2}. {stata kmatch eb mbsmoke mage fage prenatal1 mmarried fbaby (bweight) if !(prenatal1==0&mbsmoke==0), att}{p_end}

{marker exipw}{...}
{dlgtab:Inverse probability weighting (IPW)}

{pstd}
    Inverse probability weighting based on a probit model to predict
    each subject's propensity score

{p 8 12 2}. {stata kmatch ipw mbsmoke mage fage prenatal1 mmarried fbaby (bweight), pscmd(probit) att}{p_end}

{pstd}
    Compare to {helpb teffects ipw}

{p 8 12 2}. {stata teffects ipw (bweight) (mbsmoke mage fage prenatal1 mmarried fbaby, probit), atet}{p_end}

{pstd}
     Inverse-probability-weighted regression adjustment

{p 8 12 2}. {stata kmatch ipw mbsmoke mage fage prenatal1 mmarried fbaby (bweight = mage fage prenatal1 mmarried fbaby), pscmd(probit) att}{p_end}

{pstd}
    Compare to {helpb teffects ipwra}

{p 8 12 2}. {stata teffects ipwra (bweight mage fage prenatal1 mmarried fbaby) (mbsmoke mage fage prenatal1 mmarried fbaby, probit), atet}{p_end}

{marker exra}{...}
{dlgtab:Regression adjustment}

{pstd}
    Regression adjustment without matching or reweighting

{p 8 12 2}. {stata kmatch ra mbsmoke (bweight = mage fage prenatal1 mmarried fbaby), att}{p_end}

{pstd}
    Compare to {helpb teffects ra}

{p 8 12 2}. {stata teffects ra (bweight mage fage prenatal1 mmarried fbaby) (mbsmoke), atet}{p_end}

{marker exmdv}{...}
{dlgtab:Multiple outcome variables}

{pstd}
    Multiple outcome variables or, more generally, multiple outcome equations
    can be specified in a single call to {cmd:kmatch}. Here is an example
    in which the same outcome variable is used twice, once without
    regression adjustment and once with regression adjustment:

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight) (bweight = mage fage prenatal1 mmarried fbaby), att}{p_end}

{pstd}
    Within each outcome equation multiple outcomes can be specified to reduce
    the amount of typing. Here is an example with two outcome variables that are both used
    with and without regression adjustment:

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight lbweight = mage fage prenatal1 mmarried fbaby) (bweight lbweight), att}{p_end}

{pstd}
    Evaluate balancing by including the covariates as outcomes

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (mage fage prenatal1 mmarried fbaby), att}{p_end}

{marker exte}{...}
{dlgtab:ATE, ATT, ATC, NATE, and potential outcome means}

{pstd}
    In the above examples, the average treatment effect on the treated (ATT) was
    reported. {cmd:kmatch} can also report the average treatment effect (ATE;
    the default), the average treatment effect on the untreated (ATC), the
    naive average treatment effect (NATE; i.e. the raw mean difference), as
    well as the potential outcome means that stand behind there
    quantities. Here is an example in which all of these quantities are
    computed in a single call:

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight), ate att atc nate po}{p_end}

{pstd}
    Having all quantities in a single estimation set is convenient if you want
    to make comparisons:

{p 8 12 2}. {stata test ATT = ATC}{p_end}
{p 8 12 2}. {stata lincom ATE - NATE}{p_end}

{marker exsubpop}{...}
{dlgtab:Results by subpopulations}

{pstd}
    Use the {cmd:over()} option to compute results by subpopulations. The
    matching/balancing will be performed individually within each subpopulation.

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried (bweight), att over(fbaby)}{p_end}
{p 8 12 2}. {stata test [0]ATT = [1]ATT}{p_end}
{p 8 12 2}. {stata lincom [0]ATT - [1]ATT}{p_end}

{marker exbal}{...}
{dlgtab:Balancing diagnostics}

{p 8 12 2}. {stata kmatch md mbsmoke mage prenatal1 mmarried fbaby (bweight), att}{p_end}
{p 8 12 2}. {stata kmatch summarize}{p_end}
{p 8 12 2}. {stata kmatch density mage}{p_end}
{p 8 12 2}. {stata kmatch cumul mage}{p_end}
{p 8 12 2}. {stata kmatch box mage}{p_end}

{p 8 12 2}. {stata kmatch ps mbsmoke mage prenatal1 mmarried fbaby (bweight), att}{p_end}
{p 8 12 2}. {stata kmatch density}{p_end}
{p 8 12 2}. {stata kmatch cumul}{p_end}
{p 8 12 2}. {stata kmatch box}{p_end}

{marker excomsup}{...}
{dlgtab:Common support diagnostics}

{pstd}
    Depending on situation, not all observations can be matched. Commands
    {cmd:kmatch csummarize}, {cmd:kmatch cdensity}, {cmd:kmatch ccumul},
    {cmd:kmatch cbox} can be used to evaluate how matched, unmatched, and the
    total sample differ.

{p 8 12 2}. {stata kmatch ps mbsmoke mage fage prenatal1 mmarried fbaby (bweight), att bwidth(0.0005)}{p_end}
{p 8 12 2}. {stata kmatch csummarize}{p_end}
{p 8 12 2}. {stata kmatch cdensity}{p_end}
{p 8 12 2}. {stata kmatch ccumul}{p_end}
{p 8 12 2}. {stata kmatch cbox}{p_end}

{marker exbw}{...}
{dlgtab:Bandwidth selection}

{pstd}
    Option {helpb kmatch##bwidth:bwidth()} offers several automatic bandwidth selection
    methods for kernel matching in {cmd:kmatch md} and
    {cmd:kmatch ps}. The default is {cmd:bwidth(pm)}, a pair-matching algorithm
    as proposed by Huber et al. (2013, 2015). The algorithm typically leads to
    rather small bandwidths.

{p 8 12 2}. {stata kmatch ps mbsmoke mmarried mage fbaby medu (bweight), att atc}{p_end}

{pstd}
    Typing {cmd:bwidth(cv)} will determine the bandwidth by cross-validation with
    respect to the mean of the propensity score (in case of {cmd:kmatch ps})
    or with respect to the means of the covariates (in case of
    {cmd:kmatch md}).

{p 8 12 2}. {stata kmatch ps mbsmoke mmarried mage fbaby medu (bweight), att atc bwidth(cv)}{p_end}

{pstd}
    Furthermore, {cmd:bwidth(cv} {it:cvvar}{cmd:)} will use cross-validation
    with respect to {it:cvvar} as suggested by Frölich (2004, 2005) and
    {cmd:bwidth(cv} {it:cvvar}{cmd:, weighted)} will use weighted
    cross-validation as suggested by Galdo et al. (2008; Section 4.2). Here is
    an example of the former:

{p 8 12 2}. {stata kmatch ps mbsmoke mmarried mage fbaby medu (bweight), att atc bwidth(cv bweight)}{p_end}

{pstd}
    The cross-validation algorithm is not guaranteed to find the MISE minimizing
    bandwidth as there might be local minima or flat regions. You can use command
    {cmd:kmatch cvplot} to view the trace of the search algorithm:

{p 8 12 2}. {stata kmatch cvplot, ms(o o) index mlabposition(1 1) sort}{p_end}


{marker eret}{...}
{title:Stored results}

{pstd}
    {cmd:kmatch md} and {cmd:kmatch ps} store the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(tval)}}value of {it:tvar} that is the treatment{p_end}
{synopt:{cmd:e(N_ovars)}}number of outcome variables{p_end}
{synopt:{cmd:e(k_omit)}}number of omitted estimates{p_end}
{synopt:{cmd:e(N_over)}}number over-groups{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters (or undefined){p_end}
{synopt:{cmd:e(N_outsup)}}number of obs out of support due to {cmd:comsup} option (or undefined){p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom (or undefined){p_end}
{synopt:{cmd:e(ridge)}}value of ridge parameter (or undefined){p_end}
{synopt:{cmd:e(nn)}}number of requested neighbors (or undefined){p_end}
{synopt:{cmd:e(nn_min)}}minimum number of neighbors (or undefined){p_end}
{synopt:{cmd:e(nn_max)}}maximum number of neighbors (or undefined){p_end}
{synopt:{cmd:e(pm_quantile)}}{it:q} of PM bandwidth algorithm (or undefined){p_end}
{synopt:{cmd:e(pm_factor)}}{it:f} of PM bandwidth algorithm (or undefined){p_end}
{synopt:{cmd:e(cv_factor)}}step size of CV bandwidth algorithm (or undefined){p_end}
{synopt:{cmd:e(maxiter)}}maximum number of iterations for PS estimation (or undefined){p_end}
{synopt:{cmd:e(btolerance)}}balancing tolerance (or undefined){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:kmatch}{p_end}
{synopt:{cmd:e(subcmd)}}{cmd:md}, {cmd:ps}, {cmd:em}, {cmd:eb}, {cmd:ipw}, or {cmd:ra}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(tvar)}}name of treatment variable{p_end}
{synopt:{cmd:e(xvars)}}names of main covariates{p_end}
{synopt:{cmd:e(ematch)}}{it:emvars} from {cmd:ematch()} or {cmd:kmatch em}{p_end}
{synopt:{cmd:e(emxvars)}}exact matching covariates (coarsened variables in brackets){p_end}
{synopt:{cmd:e(psvars)}}variable names from {cmd:psvars()}{p_end}
{synopt:{cmd:e(pscore)}}variable names from {cmd:pscore()}{p_end}
{synopt:{cmd:e(comsup)}}{cmd:comsup} or contents from {cmd:comsup()} or empty{p_end}
{synopt:{cmd:e(over)}}name of over variable{p_end}
{synopt:{cmd:e(over_labels)}}values over variable{p_end}
{synopt:{cmd:e(over_namelist)}}values over variable{p_end}
{synopt:{cmd:e(ovar#)}}name of outcome variable #{p_end}
{synopt:{cmd:e(avars#)}}names of adjustment variables for outcome #{p_end}
{synopt:{cmd:e(generate)}}names of variables generated by {cmd:generate()}{p_end}
{synopt:{cmd:e(wgenerate)}}names of variables generated by {cmd:wgenerate()}{p_end}
{synopt:{cmd:e(dygenerate)}}names of variables generated by {cmd:dygenerate()}{p_end}
{synopt:{cmd:e(idgenerate)}}names of variables generated by {cmd:idgenerate()}{p_end}
{synopt:{cmd:e(dxgenerate)}}names of variables generated by {cmd:dxgenerate()}{p_end}
{synopt:{cmd:e(cemgenerate)}}names of variables generated by {cmd:cemgenerate()}{p_end}
{synopt:{cmd:e(ifgenerate)}}names of variables generated by {cmd:ifgenerate()}{p_end}
{synopt:{cmd:e(metric)}}type of multivariate distance metric{p_end}
{synopt:{cmd:e(kernel)}}type of kernel{p_end}
{synopt:{cmd:e(keepall)}}{cmd:keepall} or empty{p_end}
{synopt:{cmd:e(wor)}}{cmd:wor} or empty{p_end}
{synopt:{cmd:e(pscmd)}}command used for propensity score estimation{p_end}
{synopt:{cmd:e(psopts)}}options passed through to propensity score estimation{p_end}
{synopt:{cmd:e(pspredict)}}predict options for propensity score estimation{p_end}
{synopt:{cmd:e(bw_method)}}bandwidth selection method{p_end}
{synopt:{cmd:e(cv_outcome)}}name of cross-validation outcome variable{p_end}
{synopt:{cmd:e(cv_weighted)}}{cmd:weighted} or empty{p_end}
{synopt:{cmd:e(cv_nopenalty)}}{cmd:nopenalty} or empty{p_end}
{synopt:{cmd:e(cv_nolimit)}}{cmd:nolimit} or empty{p_end}
{synopt:{cmd:e(cv_exact)}}{cmd:exact} or empty{p_end}
{synopt:{cmd:e(ebalance)}}{cmd:ebalance} or empty{p_end}
{synopt:{cmd:e(ebvars)}}variable names from {cmd:ebalance()}{p_end}
{synopt:{cmd:e(csonly)}}{cmd:csonly} or empty{p_end}
{synopt:{cmd:e(targets)}}entropy balancing targets{p_end}
{synopt:{cmd:e(covariances)}}{cmd:covariances} or empty{p_end}
{synopt:{cmd:e(nconstraint)}}{cmd:nconstraint} or empty{p_end}
{synopt:{cmd:e(fitopts)}}entropy balancing options{p_end}
{synopt:{cmd:e(ate)}}{cmd:ate} or empty{p_end}
{synopt:{cmd:e(att)}}{cmd:att} or empty{p_end}
{synopt:{cmd:e(atc)}}{cmd:atc} or empty{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} from {cmd:vce()}{p_end}
{synopt:{cmd:e(clustvar)}}{it:clustvar} from {cmd:vce()}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b} or {cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}treatment effect estimates{p_end}
{synopt:{cmd:e(_N)}}numbers of observations in over-groups{p_end}
{synopt:{cmd:e(bwidth)}}bandwidths (or undefined){p_end}
{synopt:{cmd:e(S)}}multivariate distance scaling matrix (or undefined){p_end}
{synopt:{cmd:e(cv)}}cross-validation results (or undefined){p_end}
{synopt:{cmd:e(balanced)}}entropy balancing indicator (or undefined){p_end}
{synopt:{cmd:e(loss)}}entropy balancing loss (or undefined){p_end}
{synopt:{cmd:e(iterations)}}number of entropy balancing iterations (or undefined){p_end}
{synopt:{cmd:e(C_}{it:varname}{cmd:)}}cutpoints used to coarsen {it:varname}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
    If {cmd:vce()} is {cmd:bootstrap} or {cmd:jackknife}, additional results as described
    in help {helpb bootstrap} and {helpb jackknife} are stored in {cmd:e()}. If option {cmd:svy}
    option is specified, additional results as described
    in help {helpb svy} are stored in {cmd:e()}.

{pstd}
    {cmd:kmatch summarize}, {cmd:kmatch csummarize}, {cmd:kmatch density}, {cmd:kmatch cdensity},
    {cmd:kmatch cumul}, {cmd:kmatch ccumul}, {cmd:kmatch box}, {cmd:kmatch cbox} return
    macro {cmd:r(refstat)} equal to {cmd:ate}, {cmd:att}, or {cmd:atc}. Additionally,
    {cmd:kmatch summarize} and {cmd:kmatch csummarize} store the following matrices in {cmd:r()}:

{synoptset 8 tabbed}{...}
{synopt:{cmd:r(M)}}table of means and standardized differences{p_end}
{synopt:{cmd:r(V)}}table of variances and their ratios; unless {cmd:sd} is specified{p_end}
{synopt:{cmd:r(SD)}}table of standard deviations and their ratios; if {cmd:sd} is specified{p_end}
{synopt:{cmd:r(SK)}}table of skewnesses and their differences; if {cmd:skewness} is specified{p_end}
{synopt:{cmd:r(S)}}vector of standard deviations used for standardization{p_end}


{marker refs}{...}
{title:References}

{phang}
    Abadie, A., G.W. Imbens. 2008. On the Failure of the Bootstrap for Matching
    Estimators. {it:Econometrica} 76(6):1537–1557.
    {p_end}
{phang}
    Abadie, A., G.W. Imbens. 2011. Bias-Corrected Matching Estimators for
    Average Treatment Effects. {it:Journal of Business & Economic Statistics}
    29(1):1-11.
    {p_end}
{phang}
    Blackwell, M., S. Iacus, G. King, G. Porro. 2009. cem: Coarsened exact
    matching in Stata. {it:The Stata Journal} 9(4): 524-546.
    {p_end}
{phang}
    Frölich, M. 2004. Finite-sample properties of propensity-score matching and
    weighting estimators. {it:The Review of Economics and Statistics} 86(1):77-90.
    {p_end}
{phang}
    Frölich, M. 2005. Matching estimators and optimal bandwidth choice.
    {it:Statistics and Computing} 15:197-215.
    {p_end}
{phang}
    Galdo, J.C., J. Smith, D. Black. 2008. Bandwidth selection and the estimation
    of treatment effects with unbalanced data. {it:Annales d'Économie et de Statistique}
    91/92:89-216.
    {p_end}
{phang}
    Greevy, R.A., Jr., C.G. Grijalva, C.L. Roumie, C. Beck, A.M. Hung, H.J.
    Murff, X. Liu, M.R. Griffin. 2012. Reweighted Mahalanobis Distance Matching
    for Cluster Randomized Trials with Missing
    Data. {it:Pharmacoepidemiology and Drug Safety} 21(S2):148–154.
    {p_end}
{phang}
    Hainmueller, J. (2012). Entropy Balancing for Causal Effects: A
    Multivariate Reweighting Method to Produce Balanced Samples in
    Observational Studies. {it:Political Analysis}
    20(1): 25-46. DOI: {browse "http://doi.org/10.1093/pan/mpr025":10.1093/pan/mpr025}
    {p_end}
{phang}
    Heckman, J.J., H. Ichimura, P. Todd. 1998. Matching as an Econometric
    Evaluation Estimator. {it:The Review of Economic Studies} 65(2):261-294.
    {p_end}
{phang}
    Heckman, J.J., H. Ichimura, J. Smith, P. Todd. 1998. Characterizing Selection
    Bias Using Experimental Data. {it:Econometrica} 66(5):1017-1098.
    {p_end}
{phang}
    Huber, M., M. Lechner, A. Steinmayr. 2015. Radius matching on the propensity score with
    bias adjustment: tuning parameters and finite sample behaviour. {it:Empirical Economics}
    49:1-31.
    {p_end}
{phang}
    Huber, M., M. Lechner, C. Wunsch. 2013. The performance of estimators based on the
    propensity score. {it:Journal of Econometrics} 175:1-21.
    {p_end}
{phang}
    Iacus, S.M., G. King, G. Porro. 2012. Causal Inference without Balance
    Checking: Coarsened Exact Matching. {it:Political Analysis}
    20(1): 1–24. DOI: {browse "http://doi.org/10.1093/pan/mpr013":10.1093/pan/mpr013}
    {p_end}
{phang}
    Jann, B. 2019. Influence functions for linear regression (with an application
    to regression adjustment). University of Bern Social Sciences Working Papers
    32. Available from {browse "http://ideas.repec.org/p/bss/wpaper/32.html"}.
    {p_end}

{title:Author}

{pstd}
    Ben Jann, University of Bern, jann@soz.unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B. (2017). kmatch: Stata module for multivariate-distance and
    propensity-score matching, including entropy balancing, inverse probability
    weighting, (coarsened) exact matching, and regression adjustment. Available from
    {browse "https://ideas.repec.org/c/boc/bocode/s458346.html"}.


{title:Also see}

{psee}
    Online:  help for {helpb teffects}
