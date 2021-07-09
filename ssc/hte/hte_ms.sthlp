{smcl}
{* 21aug2014}{...}
{title:Title}

{pstd}{hi:hte ms} {hline 2} Heterogeneous Treatment Effect Analysis: Matching-Smoothing Method


{title:Syntax}

{p 8 15 2}
    {cmd:hte ms} {it:{help varname:depvar1}} [{it:{help varname:depvar2}} {it:...} {cmd:=}]
    {it:{help varname:treatvar}} {indepvars} {ifin} 
    [{cmd:,}
    {help hte ms##opt:{it:options}}
    ]

{synoptset 20 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt :{it:{help psmatch2:psmatch2_options}}}options as described in help
    {helpb psmatch2}; excluding {cmd:outcome()}, {cmd:mahalanobis()}, {cmd:add}, {cmd:pcaliper()}, 
    {cmd:w()}, {cmd:ate}
    {p_end}
{synopt :{cmd:tt}}condition on treated
    {p_end}
{synopt :{cmd:tc}}condition on untreated
    {p_end}
{synopt :{cmdab:ttopt:s(}{it:{help scatter:options}}{cmd:)}}change look of markers for treated
    {p_end}
{synopt :{cmdab:tcopt:s(}{it:{help scatter:options}}{cmd:)}}change look of markers for untreated
    {p_end}
{synopt :{cmdab:nosc:atter}}suppress scatterplot
    {p_end}
{synopt :{cmdab:lpoly}[{cmd:(}{it:{help twoway_lpoly:options}}{cmd:)}]}add a local polynomial
    smooth; the default
    {p_end}
{synopt :{cmdab:lpolyci}[{cmd:(}{it:{help twoway_lpolyci:options}}{cmd:)}]}add a local polynomial
    smooth with CI
    {p_end}
{synopt :{cmdab:lowess}[{cmd:(}{it:{help twoway_lowess:options}}{cmd:)}]}add a lowess smooth
    {p_end}
{synopt :{opt overlay}}include results for all dependent variables in one plot; 
    the default is to use separate plots and combine them into one graph 
    using {helpb graph combine}; {opt overlay} implies {cmd:noscatter}
    {p_end}
{synopt :{cmd:combine(}{it:{help graph_combine:options}}{cmd:)}}option passed through to 
    {helpb graph combine} in case of multiple {it:depvars}  (unless {cmd:overlay} is specified)
    {p_end}
{synopt :{it:{help twoway_options}}}any options other than {opt by()} documented in
    {bind:{bf:[G] {it:twoway_options}}}{p_end}
{synoptline}


{title:Description}

{pstd}
    {cmd:hte ms} performs heterogeneous treatment effect analysis using the
    matching-smoothing method as proposed by Xie, Brand, and Jann
    (2012). It first applies {helpb psmatch2} (Leuven and Sianesi 2003) to compute counterfactual 
    outcomes and then plots the treatment effect against the propensity score.
    {it:treatvar} is a dichotomous variable identifying the treatment group 
    (typically coded as 1) and the control group (typically coded as 0).
    
{pstd}
    If multiple dependent variables are specified, then multiple sets of options 
    may be specified in {cmd:lpoly()}, {cmd:lpolyci()}, and {cmd:lowess()}. Use a comma
    separate the sets, as in {cmd:lpoly(}{it:set 1}{cmd:,} {it:set 2}{cmd:,} {it:...}{cmd:)}.
    The same options are used for all dependent variables if only one set is specified.


{title:Dependencies}

{pstd}
    {cmd:hte ms} requires {cmd:psmatch2} (Leuven and Sianesi 2003). To 
    install {cmd:psmatch2} on your system, type:
    
        . {stata "ssc install psmatch2"}


{title:Options}

{phang}
    {it:psmatch2_options} are options as described in help {helpb psmatch2}. Options 
    {cmd:outcome()}, {cmd:mahalanobis()}, {cmd:add}, {cmd:pcaliper()}, 
    {cmd:w()}, and {cmd:ate} are not allowed.
    
{phang}
    {cmd:tt} conditions on the treated. That is, only the treatment effect estimates from the 
    treated are included in the plot and are used for the computation of the 
    smoothed curve. The default is to include treatment effect estimates from both the treated
    and the untreated. Results are asymptotically equivalent, whether you
    include only the treated or include both the treated and the untreated.
    
{phang}
    {cmd:tc} conditions on the untreated. That is, only the treatment effect estimates from the 
    untreated are included in the plot and are used for the computation of the 
    smoothed curve. The default is to include treatment effect estimates from both the treated
    and the untreated. Results are asymptotically equivalent, whether you
    include only the untreated or include both the treated and the untreated.
    
{phang}
    {cmd:ttopts(}{it:options}{cmd:)} specifies options that
    affect the rendition of the markers for the treatment effect estimates from 
    the treated. See help {helpb scatter} for available {it:options}.
    
{phang}
    {cmd:tcopts(}{it:options}{cmd:)} specifies options that
    affect the rendition of the markers for the treatment effect estimates from 
    the untreated. See help {helpb scatter} for available {it:options}.

{phang}
    {cmd:noscatter} suppress the markers for the treatment effect estimates 
    in the plot. Option {opt overlay} implies {cmd:noscatter}.

{phang}
    {cmd:lpoly}[{cmd:(}{it:options}{cmd:)}] adds a local
    polynomial smooth of the treatment effect against the propensity score.
    This is the default. If no options are specified, a local polynomial fit
    of degree 0 (local-mean smoothing) is used. It is strongly advised to
    specify {cmd:lpoly(degree(1))} so that a local polynomial fit of degree 1
    (local-linear smoothing) is used, as local-linear smoothing has better 
    properties at the boundaries than local-mean smoothing. For further 
    available {it:options}, e.g. {cmd:bwidth()} to set the bandwidth, 
    see help {helpb lpoly}.
    
{phang}
    {cmd:lpolyci}[{cmd:(}{it:options}{cmd:)}] adds a local 
    polynomial smooth including including point-wise confidence intervals. See 
    help {helpb lpoly} for available {it:options}.
    
{phang}
    {cmd:lowess}[{cmd:(}{it:options}{cmd:)}] adds a lowess 
    smooth of the treatment effect against the propensity score. See 
    help {helpb lowess} for available {it:options}.

{phang}
    {cmd:overlay} includes the curves for all dependent variables in one plot. 
    The default is to draw a separate plot for each dependent variable and 
    combine the single plots into one graph 
    using {helpb graph combine}. {cmd:overlay} implies {cmd:noscatter}, that is,
    markers for treatment effect estimates are omitted.
    
{phang}
    {cmd:combine(}{it:options}{cmd:)} specifies options to 
    be passed through to {helpb graph combine} in case of multiple 
    {it:depvars}. See help {helpb graph combine} for available 
    {it:options}. {cmd:combine()} has no effect if {cmd:overlay} is specified.
    
{phang}
    {it:twoway_options} are general twoway options, other than 
    {cmd:by()}, as documented in help {it:{help twoway_options}}.


{title:Examples}

{pstd}
    Treatment effect of college on wages:

        . {stata sysuse nlsw88}
        . {stata generate sq_exp = ttl_exp^2}
        . {stata hte ms wage collgrad ttl_exp sq_exp tenure south smsa, lpoly(degree(1))}


{title:Saved results}

{pstd}
    {cmd:hte ms} leaves behind in {cmd:e()} the results from the treatment
    assignment model estimated by {helpb psmatch2}. It also leaves behind the
    results variables generated by {helpb psmatch2}.


{title:References}

{phang}
    Leuven, E. and B. Sianesi. 2003. PSMATCH2: Stata module to perform full Mahalanobis and
    propensity score matching, common support graphing, and covariate imbalance testing.
    Available from {browse "http://ideas.repec.org/c/boc/bocode/s432001.html"}.
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
    Online:  help for
    {helpb hte}, {helpb hte sm}, {helpb hte sd};
    {helpb psmatch} (if installed)
