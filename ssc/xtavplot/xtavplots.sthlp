{smcl}
{* *! version 1.0.0  5may2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "xtavplot" "help xtavplot"}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}
{vieweralsosee "[XT] xtreg postestimation" "help xtreg postestimation"}{...}
{vieweralsosee "[R] avplots" "help regress_postestimation_plots##avplots"}{...}
{viewerjumpto "Description" "xtavplots####description"}{...}
{viewerjumpto "Options" "xtavplots##options"}{...}
{viewerjumpto "Examples" "xtavplots##examples"}{...}
{marker xtavplots}{...}
{bf:xtavplots} {hline 2} All xtavplots added-variable plots in one image


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:xtavplots} [{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Plot}
{p2col:{it:{help marker_options}}}change look of markers (color, 
        size, etc.){p_end}
{p2col:{it:{help marker_label_options}}}add marker labels; 
        change look or position{p_end}
{synopt :{opt a:ddmeans}}rescale the residuals, regression line 
and confidence intervals to be centered on the means of x and y 
instead of zero{p_end}
{synopt :{help graph_combine:{it:combine_options}}}any of the options
documented in {manhelp graph_combine G-2:graph combine}{p_end}

{syntab:Regression line}
{synopt :{opth rl:opts(cline_options)}}affect rendition of 
the regression line{p_end}
{synopt :{opt noco:ef}}turns off display of coefficent below graph{p_end}

{syntab:Confidence interval}
{synopt :{opt noci}}turns off confidence interval{p_end}
{synopt :{opt ciu:nder}}confidence intervals underneath scatter{p_end}
{synopt :{opth l:evel(level:#)}}specifies the confidence level{p_end}
{synopt :{opth cio:pts(fitarea_options:ci_options)}}affect rendition of 
the confidence{p_end}
{synopt :{opth cip:lot(graph_twoway:plottype)}}how to plot
       CIs; default is {cmd:ciplot({help twoway_rline:rline})}; 
           a common alternative is {cmd:ciplot({help twoway_rline:rarea})}
{p_end}{...}
{syntab:Add plots}
{synopt :{opth "addplot(addplot_option:plot)"}}add other plots to the 
generated graph{p_end}

{syntab:Y axis, X axis, Titles, Legend, Overall}
{synopt :{it:twoway_options}}any options other than {opt by()}
  documented in {manhelpi twoway_options G-3}{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}

{title:Description for xtavplots}

{pstd}
{opt xtavplots} combines {help xtavplot} added-variable graphs 
of all the independent variables into one image, after an 
{help xtreg} regression. It shows the linear correlations of 
each {it:x} variable with the {it:y} variable conditional on all the 
other {it:x} variables.

{marker options}{...}

{title:Options for xtavplot}

{dlgtab:Plot}

{phang}
{it:marker_options}
    affect the rendition of markers drawn at the plotted points, including
    their shape, size, color, and outline; see {manhelpi marker_options G-3}.

{phang}
{it:marker_label_options}
    specify if and how the markers are to be labeled; 
    see {manhelpi marker_label_options G-3}.{p_end}

{phang}
{opt addmeans} rescales the scatterplot values, the regression line and the
confidence intervals to be centered on the mean values of the x and
y variables instead of being centered on zero by default. This may make
the plot more visually intuitive, but it is important to make clear to viewers
that the graph is showing conditioned values rather than the original data.

{phang}
{it:combine_options}
        specify any of the options documented in 
        {manhelp graph_combine G-2:graph combine}
        to control how {cmd:xtavplots} combines 
        muliple {help xtavplot} graphs.{p_end}

{dlgtab:Regression line}

{phang}
{opt rlopts(cline_options)} affects the rendition of the regression
 (fitted) line.  See {manhelpi cline_options G-3}.

{phang}
{opt nocoef} turns off display of the coefficent, standard error and {it:t} 
statistic from the regression line below the graph.

{dlgtab:Confidence interval}

{phang}
{opt noci} turns off display of the confidence interval on the graph.

{phang}
{opt ciunder} confidence interval will be graphed underneath the scatter 
plot (i.e. data scatter is graphed on top of confidence interval). This is 
mainly useful when graphing a solid confidence interval with option
{opt ciplot(rarea)}.{p_end}

{phang}
{opt level(#)} specifies the confidence level, in percent,
for confidence interval of the coefficients; see help {help level}.

{phang}
{opt ciopts(cline_options)} affects how the upper and lower 
confidence interval lines are rendered.  
See {manhelpi cline_options G-3}.
If you specify {opt ciplot()}, then rather than using 
{it:cline_options}, you should specify whatever is appropriate.

{phang}
{cmd:ciplot(}{it:plottype}{cmd:)}
    specifies how the confidence interval is to be plotted.  The
    default is {cmd:ciplot(rline)}, meaning that the prediction will be
    plotted by {cmd:graph} {cmd:twoway} {cmd:rline}.

{p 8 8}
    A common alternative is {cmd:ciplot({help twoway_rarea:rarea})}, which will
    substitute lines around the prediction for shading.
    See {manhelp graph_twoway G-2:graph twoway} for a list of {it:plottype}
    choices.  You may choose any that expect two {it:y} variables and one
    {it:x} variable.{p_end}

{dlgtab:Add plots}

{phang}
{opt addplot(plot)} provides a way to add other plots to the generated graph.
See {manhelpi addplot_option G-3}.

{dlgtab:Y axis, X axis, Titles, Legend, Overall}

{phang}
{it:twoway_options} are any of the options documented in 
{manhelpi twoway_options G-3}, excluding {opt by()}.  These include options
for titling the graph (see {manhelpi title_options G-3}) and for saving
the graph to disk (see {manhelpi saving_option G-3}).

{marker examples}{...}

{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{stata "webuse nlswork": . webuse nlswork}{p_end}
{phang2}{stata "keep in 1/500": . keep in 1/500}{p_end}
{phang2}{stata "xtreg ln_w ttl_exp age c.age#c.age not_smsa south, fe": . xtreg ln_w ttl_exp age c.age#c.age not_smsa south, fe}

{pstd}Create all added-variable plots using the {it:x} variables{p_end}
{phang2}{stata "xtavplots": . xtavplots}{p_end}

{pstd}With solid confidence interval areas{p_end}
{phang2}{stata "xtavplots, ciplot(rarea) ciunder": . xtavplots, ciplot(rarea) ciunder}{p_end}

{pstd}Add title and make gap in graphs below it{p_end}
{phang2}{stata "xtavplots, title(Added-Variable Plots) holes(2)": . xtavplots, title(Added-Variable Plots) holes(2)}{p_end}


{title:Author}

        John Luke Gallup, Portland State University, USA
        jlgallup@pdx.edu
