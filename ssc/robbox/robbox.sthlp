{smcl}
{* 10may2019}{...}
{hi:help robbox}
{hline}

{title:Title}

{pstd}{hi:robbox} {hline 2} Generalized box plots


{title:Syntax}

{pstd}
    Estimation:

{p 8 15 2}
    {cmd:robbox} {varlist} {ifin} {weight}
    [{cmd:,}
    {help robbox##opts:{it:options}}
    ]

{pstd}
    Replay graph:

{p 8 15 2}
    {cmd:robbox} [{cmd:,} {help robbox##gropts:{it:graph_options}} ]

{pstd}
    Replay table:

{p 8 15 2}
    {cmd:robbox}{cmd:,} {opt tab:le}

{pstd}
    Generate variable(s) flagging outside values:

{p 8 15 2}
    {cmd:robbox}{cmd:,} {opt flag}[{cmd:(}{it:prefix or namelist}{cmd:)}] [ {opt replace} ]

{pstd}
    Generate variables containing results:

{p 8 15 2}
    {cmd:robbox}{cmd:,} {opt gen:erate}[{cmd:(}{it:prefix or namelist}{cmd:)}] [ {opt nolab:el} {opt replace} ]

{pstd}
    Store outside values in matrix {cmd:e(outsides)}:

{p 8 15 2}
    {cmd:robbox}{cmd:,} {opt postout:sides}


{synoptset 23 tabbed}{...}
{marker opts}{col 5}{help robbox##options:{it:options}}{col 30}Description
{synoptline}
{syntab :Main}
{synopt :{opt st:andard}}standard box plot
    {p_end}
{synopt :{opt adj:usted}}skewness-adjusted box plot
    {p_end}
{synopt :{opt general}}generalized box plot; the default
    {p_end}
{synopt :{opt alpha(#)}}outside value percentage; not allowed with {cmd:adjusted}
    {p_end}
{synopt :{opt bp(#)}}breakdown point in percent; only
    allowed with {cmd:general}
    {p_end}
{synopt :{opt delta(#)}}shifting constant; only
    allowed with {cmd:general}
    {p_end}
{synopt :{opth over(varname)}}compute results for subpopulations defined by
    {it:varname}
    {p_end}
{synopt :{opt cw}}perform casewise deletion of observations
    {p_end}

{syntab :Graph}
{synopt :{opt nogr:aph}}do not draw a graph
    {p_end}
{synopt :{help robbox##gropts:{it:graph_options}}}graph options
    {p_end}

{syntab :Reporting}
{synopt :{opt notab:le}}suppress output table
    {p_end}

{syntab :Returns}
{synopt :{opt flag}[{cmd:(}{it:spec}{cmd:)}]}store variables flagging outside values
    {p_end}
{synopt :{opt gen:erate}[{cmd:(}{it:spec}{cmd:)}]}store variables containing
    results
    {p_end}
{synopt :{opt replace}}allow overwriting existing variables
    {p_end}
{synopt :{opt postout:sides}}store outside values in {cmd:e(outsides)}
    {p_end}
{synoptline}
{p 4 6 2}
{opt pweight}s, {opt iweight}s, and {opt fweight}s are allowed; see {help weight}.


{synoptset 23 tabbed}{...}
{marker gropts}{col 5}{help robbox##groptions:{it:graph_options}}{col 30}Description
{synoptline}
{syntab :Main}
{synopt :{opt vert:ical}}vertical box plot; the default
    {p_end}
{synopt :{opt hor:izontal}}horizontal box plot
    {p_end}
{synopt :{opt noout:sides}}do not show outside values
    {p_end}
{synopt :{opt sort}[{opt (index)}]}sort boxes by median
    {p_end}
{synopt :{opt des:cending}}use descending sort order
    {p_end}

{syntab :Labels}
{synopt :{opt nolab:el}}use names/values in default labels
    {p_end}
{synopt :{opt lab:els(strlist)}}override default tick labels
    {p_end}
{synopt :{opt llab:els(strlist)}}override default legend labels
    {p_end}

{syntab :Rendering}
{synopt :{opt boxw:idth(#)}}width of boxes
    {p_end}
{synopt :{opt overg:ap(#)}}extra gap between groups of boxes
    {p_end}
{synopt :{opt med:marker}}indicate median by a marker instead of a line
    {p_end}
{synopt :{ul:{cmd:med}[{it:#}]}{opt opts(options)}}affect rendering of medians
    {p_end}
{synopt :{ul:{cmd:box}[{it:#}]}{opt opts(options)}}affect rendering of boxes
    {p_end}
{synopt :{ul:{cmd:whisk}[{it:#}]}{opt opts(options)}}affect rendering of whiskers
    {p_end}
{synopt :{ul:{cmd:out}[{it:#}]}{opt opts(options)}}affect rendering of outside values
    {p_end}
{synopt :{ul:{cmd:plot}[{it:#}]}{opt opts(options)}}affect rendering of all box plot elements
    {p_end}

{syntab :Other}
{synopt :{opt addplot(plots)}}add other plots to the graph
    {p_end}
{synopt :{it:{help twoway_options}}}general twoway options, other than {cmd:by()}
    {p_end}
{synoptline}


{title:Description}

{pstd}
    {cmd:robbox} is a command to produce (robust) box plots. Supported are the
    standard box plot (equivalent to {helpb graph box}), the skewness-adjusted box
    plot based on the medcouple by Hubert and Vandervieren (2008), and the
    generalized box plot based on Tukey's g-and-h distribution by Bruffaerts et
    al. (2014). By default, {cmd:robbox} computes the generalized box plot.

{pstd}
    The {cmd:adjusted} option of {cmd:robbox} requires {helpb robstat} to be
    installed; type {cmd:ssc install robstat}.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
    {opt standard} computes the standard box plot. This is equivalent to 
    {helpb graph box}, as long as {cmd:alpha()} is not changed. Only one
    of {cmd:standard}, {cmd:adjusted}, and {cmd:general} is allowed.

{phang}
    {opt adjusted} computes the skewness-adjusted box plot based on the medcouple,
    as proposed by Hubert and Vandervieren (2008). {cmd:boxplot} calls
    {helpb robstat} to compute the medcouple. Only one of {cmd:standard},
    {cmd:adjusted}, and {cmd:general} is allowed.

{phang}
    {opt general} computes the generalized box plot based on Tukey's g-and-h
    distribution, as proposed by Bruffaerts et al. (2014). This is the default.
    Only one of {cmd:standard}, {cmd:adjusted}, and {cmd:general} is allowed.

{phang}
    {opt alpha(#)} specifies the outside value percentage, that is, the percentage
    of observations classified as outside values under normal conditions. The default is

            alpha = 200 * (1 - normal(z_0.75 + 1.5 * (z_0.75 - z_0.25)))

{pmore}
    where z_p is the p-quantile of the standard normal distribution; this is
    approximately equal to {cmd:alpha(0.7)}. Option {cmd:alpha()} is not allowed
    with {cmd:adjusted}.

{phang}
    {opt bp(#)} sets the breakdown point, in percent, that is used when fitting
    the g-and-h distribution. The default is {cmd:bp(10)}. Option
    {cmd:bp()} is only allowed with {cmd:general}.

{phang}
    {opt delta(#)} sets the shifting constant used in the algorithm to fit the
    g-and-h distribution. The default is {cmd:delta(0.1)}. There is not much
    reason to change this default. Option {cmd:delta()} is only allowed with
    {cmd:general}.

{phang}
    {opth over(varname)} repeats the computations for each subpopulation defined by the
    values of {it:varname}.

{phang}
    {opt cw} specifies casewise deletion of observations. Results will then be 
    be computed for the sample that is not missing for any of the variables in 
    {it:varlist}. The default is to use all the nonmissing values for each 
    variable.

{dlgtab:Graph}

{phang}
    {opt nograph} suppresses the graph.

{phang}
    {help robbox##groptions:{it:graph_options}} are graph options as described below.

{dlgtab:Reporting}

{phang}
    {opt notable} suppresses the output tables.

{dlgtab:Returns}

{phang}
    {opt flag}[{cmd:(}{it:spec}{cmd:)}] creates variable(s) that flag the
    outside values (1 = outside value, 0 else). {it:spec} is either a prefix
    specified as {it:prefix}{bf:*} or a space-separated list of names to be
    used as variable names for the flag variables (the list must contain the
    same number of names as {it:varlist}). If {it:spec} is
    omitted, {cmd:_flag_} is used as prefix.

{phang}
    {opt generate}[{cmd:(}{it:spec}{cmd:)}] creates 8 variables containing the
    box plot results. This is useful if you want to create a custom graph of
    the results. The 8 variables provide a group ID ("equation"), a within-group
    ID ("coefficient"), the median, the lower hinge (lower edge of the box), the
    upper hinge (upper edge of the box), the lower adjacent value (lower
    whisker), the upper adjacent value (upper whisker), and the number of 
    observations. {it:spec} is either a prefix specified as {it:prefix}{bf:*}
    or a space-separated list of 7 names. If {it:spec} is omitted, the
    following names will be used: {cmd:_box_gid}, {cmd:_box_id},
    {cmd:_box_med}, {cmd:_box_lbox}, {cmd:_box_ubox}, {cmd:_box_lav},
    {cmd:_box_uav}, and {cmd:_box_N}. If a prefix is specified, {it:prefix}
    will be used instead of {cmd:_box_}.

{phang}
    {opt replace} allows {cmd:flag()} and {cmd:generate()} to overwrite existing
    variables.

{phang}
    {opt postoutsides} stores the outside values in matrix
    {cmd:e(outsides)}.


{marker groptions}{...}
{title:Graph options}

{dlgtab:Main}

{phang}
    {opt vertical} causes a vertical box plot to be drawn. This is the default.

{phang}
    {opt horizontal} causes a horizontal box plot to be drawn.

{phang}
    {opt nooutsides} omits the markers displaying the outside values.

{phang}
    {opt sort}[{opt (index)}] sorts the boxes by the value of the median. If
    {it:varlist} contains multiple variables and {cmd:over()} has been
    specified, you can provide {it:index} to select the variable determining
    the sort order. For example, {cmd:sort(2)} would sort the over-groups
    according to the medians of the second variable. If {it:index} is omitted, the
    average over all variables is used.

{phang}
    {opt descending} uses descending sort order. The default is to use ascending
    sort order. {opt descending} only has an effect if {cmd:sort} has been specified.

{dlgtab:Labels}

{phang}
    {opt nolabel} specifies that variable names and over-group values be used
    as labels. The default is to use variable labels and value labels, if
    such labels are available.

{phang}
    {opt labels(strlist)} specifies a space-separated list of custom tick labels to
    be used instead of the default labels. Enclose
    labels that contain spaces in double quotes,
    e.g. {cmd:labels("label 1" "label 2" ...)}. Default labels are used for
    remaining ticks if the list contains less labels than there are ticks. Within
    the list, you can specify {cmd:""} to use a default label.

{phang}
    {opt llabels(strlist)} specifies custom legend-key labels. Enclose
    labels that contain spaces in double quotes,
    e.g. {cmd:llabels("label 1" "label 2" ...)}. Default labels are used for
    remaining keys if the list contains less labels than there are keys. Within
    the list, you can specify {cmd:""} to use a default label.

{dlgtab:Rendering}

{phang}
    {opt boxwidth(#)} sets the width of the boxes in percent of the available
    space. The default is {cmd:boxwidth(50)}. In this case, the space between
    boxes will be equal to the box width; if you specify {cmd:boxwidth(100)}
    there will be no space between boxes.

{phang}
    {opt overgap(#)} sets the extra gap that is inserted between groups of boxes
    if {it:varlist} contains multiple variables and {cmd:over()} is
    specified. The default is {cmd:overgap(10)}, meaning that the extra space is set
    to 10 percent of the distance between group centers. Specify {cmd:overgap(0)}
    to omit the extra space.

{phang}
    {opt medmarker} causes the median to be indicated by a marker symbol inside the
    box. The default is to indicate median by line.

{phang}
    {ul:{cmd:med}[{it:#}]}{opt opts(options)} provides options that affect the
    rendering of median lines or, if {cmd:medmarker} has been specified, median
    markers; candidate {it:options} are {it:{help line_options}} or
    {it:{help marker_options}}, respectively. Option {cmd:medopts()} will affect all
    medians. If {cmd:over()} has been specified, you may additionally use {cmd:med1opts()},
    {cmd:med2opts()}, etc. to affect only the medians of the 1st, 2nd, etc. variable.

{phang}
    {ul:{cmd:box}[{it:#}]}{opth opts(barlook_options)} provides options that affect the
    rendering of the boxes. Option {cmd:boxopts()} will affect all
    boxes. If {cmd:over()} has been specified, you may additionally use {cmd:box1opts()},
    {cmd:box2opts()}, etc. to affect only the boxes of the 1st, 2nd, etc. variable.

{phang}
    {ul:{cmd:whisk}[{it:#}]}{opt opts(options)} provides options that affect the
    rendering of the whiskers; candidate {it:options} are {it:{help line_options}} and {cmd:msize()}
    as described in {helpb twoway rcap}. Option {cmd:whiskopts()} will affect all
    whiskers. If {cmd:over()} has been specified, you may additionally use {cmd:whisk1opts()},
    {cmd:whisk2opts()}, etc. to affect only the whiskers of the 1st, 2nd, etc. variable.

{phang}
    {ul:{cmd:out}[{it:#}]}{opth opts(marker_options)} provides options that affect the
    rendering of the outside value markers. Option {cmd:outopts()} will affect all
    outside value markers. If {cmd:over()} has been specified, you may additionally use {cmd:out1opts()},
    {cmd:out2opts()}, etc. to affect only the outside value markers of the 1st, 2nd, etc. variable.

{phang}
    {ul:{cmd:plot}[{it:#}]}{opt opts(options)} provides options that affect the
    rendering of all box plot elements; see, e.g., {it:{help marker_options}},
    {it:{help line_options}}, and {it:{help barlook_options}} for candidate
    options. Option {cmd:plotopts()} will affect all
    plots. If {cmd:over()} has been specified, you may additionally use {cmd:plot1opts()},
    {cmd:plot2opts()}, etc. to affect only the plots of the 1st, 2nd, etc. variable.

{dlgtab:Other}

{phang}
    {opt addplot(plot)} provides a way to add other plots to the generated graph; see help
    {it:{help addplot_option}}.

{phang}
    {it:twoway_options} are any options documented in help {it:{help twoway_options}}, other
    than {cmd:by()}.


{title:Examples}

{pstd}
    Standard box plot

        . {stata sysuse nlsw88, clear}
        . {stata robbox wage ttl_exp tenure, standard outopts(ms(oh))}

{pstd}
    Skewness-adjusted box plot

        . {stata robbox wage ttl_exp tenure, adjusted outopts(ms(oh))}

{pstd}
    Generalized box plot

        . {stata robbox wage ttl_exp tenure, outopts(ms(oh))}

{pstd}
    Horizontal orientation

        . {stata robbox wage ttl_exp tenure, outopts(ms(oh)) horizontal}

{pstd}
    Box plots by subpopulations (output table suppressed)

        . {stata robbox wage, over(industry) notable outopts(ms(oh)) horizontal}

{pstd}
    Remove outside values and sort by median

        . {stata robbox wage, over(industry) notable horizontal sort nooutsides}

{pstd}
    Multiple variables by subpopulations

{p 8 12 2}
        . {stata robbox wage tenure, over(race) notable horizontal outopts(ms(oh))}

{pstd}
    Multiple variables by subpopulations: change rendering for specific variable

{p 8 12 2}
        . {stata robbox wage tenure, over(race) notable horizontal outopts(ms(oh)) plot2opts(pstyle(p3)) out2opts(ms(x))}

{pstd}
    Change cap width of whiskers ...

{p 8 12 2}
        . {stata robbox wage ttl_exp tenure, outopts(ms(oh)) horizontal whiskopts(msize(ehuge))}

{pstd}
    ... and use marker symbols for the median

{p 8 12 2}
        . {stata robbox wage ttl_exp tenure, outopts(ms(oh)) horizontal whiskopts(msize(ehuge)) medmarker medopts(ms(D) mcolor(white))}

{pstd}
    Label the outside values

        . {stata robbox tenure, over(race) outopts(mlabel(idcode))}

{pstd}
    Label only selected outside values

        . {stata generate str ID = string(idcode) if tenure>15}
        . {stata robbox tenure, over(race) outopts(mlabel(ID))}

{pstd}
    Superimpose a density estimate using {cmd:addplot()}

{p 8 12 2}
        . {stata robbox wage, xtitle(wage) horizontal yscale(range(-3) off) ytitle(density, axis(2)) addplot(kdensity wage, lwidth(*2) yaxis(2) yscale(alt axis(2)))}

{pmore}
    The trick is to place the box plot and the density estimate on different Y-axes. Option
    {cmd:yscale(range(-4) off)} suppresses the Y axis created by {cmd:robbox} and
    adds space at the top by increasing the range.

{pstd}
    Draw plot using {helpb coefplot} (see {cmd:ssc describe coefplot}) ...

        . {stata robbox wage ttl_exp tenure, nograph notable}
{p 8 12 2}
        . {stata coefplot, ms(d) ci(whiskers box) ciopts(recast(rcap rbar) fintensity(. 50) barwidth(. .5)) label}

{pstd}
    ... including outside values

        . {stata robbox, postoutsides}
{p 8 12 2}
        . {stata coefplot (., ms(d) ci(whiskers box) ciopts(recast(rcap rbar) fintensity(. 50) barwidth(. .5))) (., b(outsides) noci pstyle(p1) ms(oh)), nooffsets legend(off) label}


{title:Stored results}

{pstd}
    {cmd:robbox} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_vars)}}number of variables{p_end}
{synopt:{cmd:e(N_over)}}number of subpopulations{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(alpha)}}alpha parameter ({cmd:general} and {cmd:standard} only){p_end}
{synopt:{cmd:e(bp)}}breakdown point ({cmd:general} only){p_end}
{synopt:{cmd:e(delta)}}delta parameter ({cmd:general} only){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:robbox}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(method)}}{cmd:standard}, {cmd:adjusted}, or {cmd:general}{p_end}
{synopt:{cmd:e(depvar)}}variable names{p_end}
{synopt:{cmd:e(over)}}name of {cmd:over()} variable{p_end}
{synopt:{cmd:e(over_namelist)}}values from {cmd:over()} variable{p_end}
{synopt:{cmd:e(over_labels)}}labels from {cmd:over()} variable{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(properties)}}{cmd:b}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}medians{p_end}
{synopt:{cmd:e(box)}}lower and upper hinges{p_end}
{synopt:{cmd:e(whiskers)}}lower and upper adjacent values{p_end}
{synopt:{cmd:e(whiskers0)}}initial values of whiskers{p_end}
{synopt:{cmd:e(N_out)}}number outside values{p_end}
{synopt:{cmd:e(g)}}estimated g parameters ({cmd:general} only){p_end}
{synopt:{cmd:e(h)}}estimated h parameters ({cmd:general} only){p_end}
{synopt:{cmd:e(_N)}}numbers of observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
    If {cmd:postoutsides} is specified, {cmd:robbox} will additionally
    store matrix {cmd:e(outsides)} containing the outside values.


{title:References}

{phang}
    Bruffaerts, C., V. Verardi, and C. Vermandele. 2014. A generalized boxplot for skewed
    and heavy-tailed distributions. Statistics and Probability Letters 95: 110-117.
    {p_end}
{phang}
    Hubert, M., and E. Vandervieren. 2008. An adjusted boxplot for skewed
    distributions. Computational Statistics and Data Analysis 52: 5186-5201.
    {p_end}


{title:Authors}

{pstd}
    Ben Jann (University of Bern),
    Vincenzo Verardi (University of Namur and Universite libre de Bruxelles),
    Catherine Vermandele (Universite libre de Bruxelles)

{pstd}
    Support: ben.jann@soz.unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B., V. Verardi, C. Vermandele (2019). robbox: Stata module to compute
    generalized box plots. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458620.html"}.


{title:Also see}

{psee}
    Online:  help for
    {helpb graph box}

{psee}
    From the SSC Archive:
    {stata ssc describe robreg:{bf:robreg}},
    {stata ssc describe robstat:{bf:robstat}}

