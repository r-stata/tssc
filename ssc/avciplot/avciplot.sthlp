{smcl}
{* *! version 1.0.0  28aug2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "avciplots" "help avciplots"}{...}
{vieweralsosee "[R] avplot" "help regress_postestimation_plots##avplot"}{...}
{vieweralsosee "xtavplot" "search xtavplot"}{...}
{viewerjumpto "Description" "avciplot##description"}{...}
{viewerjumpto "Options" "avciplot##options"}{...}
{viewerjumpto "Examples" "avciplot##examples"}{...}
{viewerjumpto "Stored values" "avciplot##stored"}{...}
{marker avciplot}{...}
{bf:avciplot} {hline 2} Added-variable plot with confidence intervals

{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:avciplot} {it:{help indepvars:indepvar}} 
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
the ranges of the x and y residuals displayed{p_end}
{synopt :{opt gen:erate(exvar eyvar)}}save the values of x and y residuals 
in new variables 

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
{title:Description of avciplot}

{pstd}
{opt avciplot} creates an added-variable plot ({it:a.k.a.} partial-regression 
leverage plot, partial regression plot, or adjusted partial residual plot) after
{helpb regress}. It differs from {helpb regress postestimation plots##avplot:avplot} 
by adding confidence intervals around the regression line and various options. 

{pstd}
{it:indepvar} is an independent ({it:x}) variable ({it:a.k.a.} predictor, carrier, or 
covariate) that may or may not be included in the preceding regression. The user 
would choose an {it:indepvar} not already in the regression to evaluate whether 
it is worthwhile to include it.

{pstd}
{opt avciplot} shows the partial correlation between one {it:indepvar} and 
the {it:depvar} controlling for all the other regressors in an multiple linear 
regression.

{pstd}
Besides showing the relationship between the {it:indepvar} and the {it:depvar} 
controlling for the other regressors, {cmd:avciplot} is useful for visually 
identifying which outlier observations have a big effect on the estimated 
coefficient.

{pstd}
{opt avciplot} calculates e({it:x}|X),
the residuals from the regression of the {it:indepvar} ({it:x}) 
on the other independent (X) variables, and e({it:y}|X),
the residuals from the regression of the {it:depvar} ({it:y}) 
on the other (X) variables. The graph shows e({it:x}|X) plotted against
e({it:y}|X), that is, the variation in {it:x} not correlated with X plotted against
the variation in {it:y} not correlated with X.

{pstd}
The fitted line shown in the graph is the least squares fit between the  
residuals e({it:x}|X) and e({it:y}|X). The fitted line 
has the same slope as estimated coefficient on the {it:indepvar} in 
the preceding full regression.

{pstd}
By construction, the residuals e({it:x}|X) and e({it:y}|X) each have a mean 
of zero, and the regression line (without a constant term) fitted between them passes 
exactly through e({it:x}|X)=0 and e({it:y}|X)=0. At that point, the confidence 
interval has zero width, giving it an unfamiliar shape. Note that this 
also happens in a conventional regression at the point where all the independent 
variables have a value of zero if there is no constant term.

{marker options}{...}
{title:Options for avciplot}

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
{opt xlim(# [#])}, {opt ylim(# [#])} constrain
the range of the {it:indepvar} and {it:depvar} residuals displayed. If
only one number is specified, residuals with a value below that number will
not be displayed in the scatter plot. If two numbers are specified, residuals
below that first number and above the second number will not be displayed.

{p 8 8}
Excluding observations of the residual does not affect the slope of the regression
line in the graph. The purpose of these options is to avoid situations where
outlying observations cause a lot of extra white space in the graph, obscuring
display of the relationship between the variables. As usual, care should
be taken to make sure that the undisplayed observations are not important
to the estimated relationship.

{phang}
{opt generate(exvar eyvar)} saves the values of the x and y residuals 
in variables named by the user. The user must specify two variable names for 
{it:exvar} and {it:eyvar}. These
residuals can be used for subsequent calculations or graphing commands.{p_end}

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
{pstd}Load the auto dataset and look at a graph of engine displacement versus
fuel efficiency (mpg):{p_end}
{phang2}{bf:{stata "sysuse auto": . sysuse auto}}{p_end}
{phang2}{bf:{stata "twoway lfitci mpg displacement || scatter mpg displacement, msize(vsmall) leg(off)": . twoway lfitci mpg displacement || scatter mpg displacement, msize(vsmall) leg(off)}}

{pstd}Though the correlation of {opt displacement} and {opt mpg} is clearly 
negative, if we also include weight as a regressor in a multiple regression, 
{opt displacement} has a {it:positive} and insignificant partial correlation.

{phang2}{bf:{stata "regress mpg displacement weight": . regress mpg displacement weight}}

{pstd} How can we show this graphically? With an added-variable plot:

{phang2}{bf:{stata "avciplot displacement": . avciplot displacement}}

{pstd}
The added-variable plot shows the correlation of the {it:x} variable, 
{opt displacement}, conditional on all the other independent variables in the
regression, with the {it:y} variable, 
{opt mpg}, also conditional on all the other regressors. That is, it shows the 
the correlation of one {it:x} with {it:y}, netting out the influence of all the 
other independent variables.

{pstd}
The added-variable plot shows a scatter of the values of the residuals e(x|X) 
versus
e(y|X). The solid line is the regression fit of these values and
the dashed lines are the limits of the 95% confidence interval around the
regression fit. The slope of the regression fit in the added-variable plot
is equal to the coefficient on {opt displacement} in the preceding regression
which is also printed at the bottom of the graph.

{pstd}
Unlike {help regress_postestimation_plots##avplot:avplot}, 
{cmd:avciplot} shows the confidence interval around
the linear regression line. We can see that the
partial correlation of {opt displacement} with {opt mpg} is not statistically
significant (at the 5% level) since the confidence interval includes zero.

{pstd}
{opt avciplot} can display the confidence interval as a solid pattern 
(similar to the {help lfitci} graphs) by using the option {opt ciplot(rarea)} 
rather than the default of delineating the interval by two dashed lines. The 
{opt ciunder} option causes the scatter plot to be superimposed on the confidence 
interval rather than vice versa, so that data points within the interval are 
still visible:

{phang2}{bf:{stata "avciplot displacement, ciplot(rarea) ciunder": . avciplot displacement, ciplot(rarea) ciunder}}

{pstd}
Added-variable plots are a good diagnostic for finding outlier 
observations which influence the partial correlation of a regressor of interest,
in this case {opt displacement}. 

{pstd}
There is a clear outlier in the e(mpg|X)
vertical axis with a value of about 14. It is also clear that this outlier
has little affect on the slope of the regression line because it has a 
value e(displacement|X) of about zero. Including this outlier makes the rest 
of the graph smaller. 

{pstd}
We can exclude the display of this observation with the 
option {cmd:ylim(-10 10)} to magnify the rest of the graph. The lower limit of 
{opt ylim} has no affect because there are no e(mpg|X) values below -10. The 
{opt ylim} and {opt xlim} options are not available in 
{help regress_postestimation_plots##avplot:avplot} so this could be a reason
to use {cmd:avciplot} even if you don't want to display a confidence interval.

{pstd}
Another difference between {help regress_postestimation_plots##avplot:avplot} and
{opt avciplot} is the ability to save the values of e(x|X) and e(y|X)
for later use with the {opt generate} option, perhaps to create a 
more complicated graph after running the {opt avciplot} command.

{pstd}
The following command implements the {opt ylim}, {opt generate} and {opt noci} 
(no confidence interval display) options:

{phang2}{bf:{stata "avciplot displacement, ylim(-10 10) noci generate(ex ey)": . avciplot displacement, ylim(-10 10) noci generate(ey ex)}}

{pstd}
The new variables {opt ex} and {opt ey}, containing the residuals of the
{it:x} and {it:y} variables conditional on all the other regressors, 
are added to the dataset in memory.

{pstd}
A simple scatter plot of a dummy variable like {opt foreign} versus {opt mpg} 
only displays two values on the horizontal axis, making it difficult
to discern the relationship visually:
  
{phang2}{bf:{stata "twoway lfitci mpg foreign || scatter mpg foreign, leg(off) xl(0 1) yt(mpg) xt(foreign)": . twoway lfitci mpg foreign || scatter mpg foreign, leg(off) xl(0 1) yt(mpg) xt(foreign)}}{p_end}

{pstd}
In contrast, the added-variable plot of  {opt foreign} versus {opt mpg} graphs
the residual of the dummy variable conditional on the other {it:x} variables,
which is continuous even though the dummy variable itself only has two discrete
values. 
{opt avciplot} can take an {it:indepvar} which  has not yet been included
in the regression, making it a useful tool for exploring the influence of new
variables. To see the partial correlation of the new variable  {opt foreign}
added to the existing regression, use
 
{phang2}{bf:{stata "avciplot foreign": . avciplot foreign}}{p_end}

{pstd}
This controls for all the existing variables in the last regression, which
in our example are {opt displacement}, {opt weight} and an intercept. The 
added-variable plot of {opt foreign} could help the user decide whether
to add it as a new variable to the regression. 

{pstd}
The companion command {helpb avciplots} shows the added-variable plots of 
{it:all} regressors in the preceding regression in a single graph. We include
an interaction term between {opt weight} and {opt foreign} in the regression
and then show all the partial correlations:

{phang2}{bf:{stata "regress mpg displacement weight foreign c.weight#i.foreign": . regress mpg displacement weight foreign c.weight#i.foreign}}

{phang2}{bf:{stata "avciplots, title(All covariates) ": . avciplots, title(All covariates)}}

{pstd}
{helpb avciplots} provides a quick way of understanding the coefficient estimates
after any linear regression. The graph shows the strength and significance
of the partial correlations of all the independent variables, as well as
help to highlight outlier observations which affect each correlation.

{pstd}
The examples above show how {opt avciplot} and {helpb avciplots} can be used
to present the relationship between independent and dependent variables graphically
when there are multiple covariates in a regression. The inclusion of confidence
intervals in the {opt avciplot} graphs makes it possible to see the statistical
significance of the estimated coefficients as well as their magnitude.

{marker stored}{...}
{title:Stored results}

{pstd}
{cmd:avciplot} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(coef)}}the estimated coefficient of the added variable{p_end}
{synopt:{cmd:r(se)}}the standard error of the estimated coefficient{p_end}

{title:Author}

        John Luke Gallup, Portland State University, USA
        jlgallup@pdx.edu
