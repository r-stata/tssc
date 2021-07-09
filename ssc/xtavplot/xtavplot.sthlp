{smcl}
{* *! version 1.0.0  5may2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "xtavplots" "help xtavplots"}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}
{vieweralsosee "[XT] xtreg postestimation" "help xtreg postestimation"}{...}
{vieweralsosee "[R] avplot" "help regress_postestimation_plots##avplot"}{...}
{vieweralsosee "avciplot" "search avciplot"}{...}
{viewerjumpto "Description" "xtavplot##description"}{...}
{viewerjumpto "Options" "xtavplot##options"}{...}
{viewerjumpto "Examples" "xtavplot##examples"}{...}
{viewerjumpto "Stored values" "xtavplot##stored"}{...}
{marker xtavplot}{...}
{bf:xtavplot} {hline 2} Added-variable plots for panel data estimation

{marker syntax_xtavplot}{...}
{title:Syntax}

{p 8 18 2}
{cmd:xtavplot} {it:{help indepvars:indepvar}} 
[{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Plot}
{p2col:{it:{help marker_options}}}change look of markers (color, 
        size, etc.){p_end}
{p2col:{it:{help marker_label_options}}}add marker labels; 
        change look or position{p_end}
{synopt :{opt xl:im(# [#])}, {opt yl:im(# [#])}}limit
the ranges of the x and y residuals displayed {p_end}
{synopt :{opt a:ddmeans}}rescale the residuals, regression line 
and confidence intervals to be centered on the means of x and y 
instead of zero{p_end}
{synopt :{opt gen:erate(exvar eyvar)}}save the values of x and y residuals 
in new variables {p_end}
{synopt :{opt nod:isplay}}suppress display of plot

{syntab:Regression line}
{synopt :{opth rl:opts(cline_options)}}affect rendition of 
the regression line{p_end}
{synopt :{opt noco:ef}}turns off display of coefficent below graph{p_end}

{syntab:Confidence interval}
{synopt :{opt noci}}turns off confidence interval{p_end}
{synopt :{opt ciu:nder}}puts confidence intervals underneath scatter{p_end}
{synopt :{opth l:evel(level:#)}}specifies the confidence level{p_end}
{synopt :{opth cio:pts(fitarea_options:ci_options)}}affect rendition of 
the confidence{p_end}
{synopt :{opth cip:lot(graph_twoway:plottype)}}how to plot CIs; 
		default is {cmd:ciplot({help twoway_rline:rline})}; 
		a common alternative is {cmd:ciplot({help twoway_rline:rarea})}
{p_end}{...}
{syntab:Add plots}
{synopt :{opth "addplot(addplot_option:plot)"}}add other plots to the 
generated graph{p_end}

{syntab:Y axis, X axis, Titles, Legend, Overall}
{synopt :{it:twoway_options}}any options documented in 
	{manhelpi twoway_options G-3}, except for {opt by()}{p_end}
  
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description of xtavplot}

{pstd}
{opt xtavplot} creates an added-variable plot ({it:a.k.a.} partial-regression leverage
plot, partial regression plot, or adjusted partial residual plot) after
{cmd:xtreg, fe} (fixed-effects estimation), {cmd:xtreg, re} (random-effects
estimation) or {cmd:xtreg, be} (between-effects
estimation). {opt xtavplot} cannot be used after {opt xtreg, mle} or 
{opt xtreg, pa}.

{pstd}
{it:indepvar} is an independent ({it:x}) variable ({it:a.k.a.} predictor, carrier, or 
covariate) that may or may not be included in the preceding estimation. 

{pstd}
{opt xtavplot} shows the partial correlation between one {it:indepvar} and 
the {it:depvar} from a multivariate panel regression.

{pstd}
Besides showing the relationship between the {it:indepvar} and the {it:depvar} 
controlling for the other regressors, {cmd:xtavplot} is useful for visually 
identifying which outlier observations have a big effect on the estimated 
coefficient.

{pstd}
After fixed-effects estimation, the plotted e({it:x}|X) values are the 
residuals from the 
regression of {it:x} on the other X variables in the original 
regression, and the plotted e({it:y}|X) values are the residuals 
from the regression of {it:y} on the other X variables. 

{pstd}
After between-effects estimation, e(av.{it:x}|av.X) and 
e(av.{it:y}|av.X) are the residuals from the 
regression of per-unit means of the {it:indepvar} (av.{it:x}) and 
{it:depvar} (av.{it:y}) on the per-unit means of the other 
independent (av.X) variables. 

{pstd}
After random-effects estimation, e({it:x}*|X*) and e({it:y}*|X*) 
are the residuals from the 
regression of heteroskedasticity-corrected {it:indepvar} ({it:x}*) 
and heteroskedasticity-corrected {it:depvar} ({it:y}*) on the other 
heteroskedasticity-corrected independent (X*) variables. 

{pstd}
The fitted line shown in the graph is the least squares fit between the  
residuals. For each of the three panel data estimation methods, the fitted line 
has the same slope as estimated coefficient on the {it:indepvar} in 
the preceding regression.

{pstd}
By construction, the residuals e({it:x}|X) and e({it:y}|X) each have a mean 
of zero, and the regression line fitted between them passes exactly 
through e({it:x}|X)=0 and e({it:y}|X)=0. At that point, the confidence 
interval has zero width, giving it an unfamiliar shape. Note that this 
also happens in a conventional regression when all the independent variables 
have a value of zero and there is no constant term.
{marker options}{...}

{title:Options for xtavplot}

{dlgtab:Plot}

{phang}
{it:marker_options}
    affect the rendition of markers drawn at the plotted points, including
    their shape, size, color, and outline; see {manhelpi marker_options G-3}.

{phang}
{it:marker_label_options}
    specify whether and how markers are to be labeled; 
    see {manhelpi marker_label_options G-3}.{p_end}

{phang}
{opt xlim(# [#])}, {opt ylim(# [#])} limit
the range of the {it:indepvar} and {it:depvar} residuals displayed. If
only one number is specified, residuals with a value below that number will
not be displayed in the scatter plot. If two numbers are specified, residuals
below that first number and above the second number will not be displayed.

{p 8 8}
Excluding observations of the residual does not affect the slope of the regression
line in the graph. The purpose of these options is to avoid situations where
outlying observations cause a lot of extra white space in the graph, obscuring
display of the relationship between the variables. Make sure that the undisplayed observations are not important
to the estimated relationship. Since panel datasets are typically large,
it is common to have one or more distant outliers which don't significantly affect
the estimates.

{phang}
{opt addmeans} rescales the scatterplot values, the regression line and the
confidence intervals to be centered on the mean values of the x and
y variables instead of being centered on zero by default. This may make
the plot more visually intuitive, but it is important to make clear to viewers
that the graph is showing conditioned values rather than the original data.

{phang}
{opt generate(exvar eyvar)} saves the values of the x and y residuals 
in variables named by the user. The user must specify two variable names for 
{it:exvar} and {it:eyvar}. These
residuals can be used for subsequent calculations or graphing commands.{p_end}

{phang}
{opt nodisplay} suppresses display of the plot. This is mainly useful
for users creating their own plots with {opt generate(exvar eyvar)}.

{dlgtab:Regression line}

{phang}
{opt rlopts(cline_options)} affects the rendition of the regression
 (fitted) line.  See {manhelpi cline_options G-3}.

{phang}
{opt nocoef} turns off display below the graph of the regression coefficent, 
	standard error and {it:t} statistic.

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
{opt ciopts(line_options)} affects how the upper and lower 
confidence interval lines are rendered.  
See {manhelpi cline_options G-3}.
If you specify {opt ciplot()}, then rather than using 
{it:cline_options}, you should specify whichever options are appropriate for 
the {it:plottype}.

{phang}
{cmd:ciplot(}{it:plottype}{cmd:)}
    specifies how the confidence interval is to be plotted.  The
    default is {cmd:ciplot(rline)}, meaning that the prediction will be
    plotted by {cmd:graph} {cmd:twoway} {cmd:rline}.

{p 8 8}
    A common alternative is {cmd:ciplot({help twoway_rarea:rarea})}, which will
    substitute lines around the prediction for shading.
    See {manhelp graph_twoway G-2:graph twoway} for a list of {it:plottype}
    choices.  You may choose any {it:plottypes} that expect two {it:y} variables 
	and one {it:x} variable.{p_end}

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
{phang2}{stata "keep in 1/1000": . keep in 1/1000}{p_end}
{phang2}{stata "xtreg ln_w ttl_exp age c.age#c.age not_smsa south, fe": . xtreg ln_w ttl_exp age c.age#c.age not_smsa south, fe}

{pstd}Added-variable plot{p_end}
{phang2}{stata "xtavplot ttl_exp": . xtavplot ttl_exp}{p_end}

{pstd}With solid confidence interval area{p_end}
{phang2}{stata "xtavplot ttl_exp, ciplot(rarea) ciunder": . xtavplot ttl_exp, ciplot(rarea) ciunder}{p_end}

{pstd}With +'s as marker symbols, no confidence interval and no coefficient reporting{p_end}
{phang2}{stata "xtavplot ttl_exp, msymbol(+) noci nocoef": . xtavplot ttl_exp, msymbol(+) noci nocoef}{p_end}

{marker stored}{...}
{title:Stored results}

{pstd}
{cmd:xtavplot} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(coef)}}the estimated coefficient of the added variable{p_end}
{synopt:{cmd:r(se)}}the standard error of the estimated coefficient{p_end}

{title:Author}

        John Luke Gallup, Portland State University, USA
        jlgallup@pdx.edu
