{smcl}
{* *! Help file version 1.7 written by Mead Over (mover@cgdev.org) 17Feb2019}{...}
{* *! Based on the help file for scatter_hist by Keith Kranker.}{...}
{viewerdialog superscatter "dialog superscatter"}{...}
{vieweralsosee "[G-2] graph twoway scatter" "mansection G-2 graphtwowayscatter"}{...}
{vieweralsosee "[G-2] graph combine" "mansection G-2 graphcombine"}{...}
{vieweralsosee "[G-2] twoway histogram" "mansection G-2 graphtwowayhistogram"}{...}
{vieweralsosee "[G-2] twoway kdensity" "mansection G-2 graphtwowaykdensity"}{...}
{vieweralsosee "[R] kdensity" "mansection R kdensity"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[G-2] scatter" "help scatter"}{...}
{vieweralsosee "[G-2] gr combine" "help gr_combine##remarks4"}{...}
{vieweralsosee "[G-2] twoway histogram" "help twoway_histogram"}{...}
{vieweralsosee "[G-2] twoway kdensity" "help twoway_kdensity"}{...}
{vieweralsosee "[G-2] twoway lfit" "help twoway_lfit"}{...}
{vieweralsosee "[G-2] twoway qfit" "help twoway_qfit"}{...}
{vieweralsosee "[SJ] ellip by Anders Alexandersson" "search ellip"}{...}
{vieweralsosee "scatter_hist by Keith Kranker" "search scatter_hist"}{...}
{viewerjumpto "Syntax" "superscatter##syntax"}{...}
{viewerjumpto "Description" "superscatter##description"}{...}
{viewerjumpto "Options" "superscatter##options"}{...}
{viewerjumpto "Examples" "superscatter##examples"}{...}
{viewerjumpto "Stored results" "superscatter##results"}{...}
{viewerjumpto "Authors" "superscatter##author"}{...}
{title:Title}

{p2colset 5 22 26 2}{...}
{p2col :{cmd:superscatter} {hline 2}}Scatter plot with marginal distributions and other enhancements{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:superscatter}
{it:y_variable x_variable} {ifin}
[{cmd:,}
{it:options}]

{marker options}{...}
{title:Options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Combined Plot}
{synopt:{opt det:ail}}display additional statistics{p_end}
{synopt:{opt iscale([*]#)}}size of text and markers{p_end}
{synopt:{opt altshrink}}alternative scaling of text, etc.{p_end}
{synopt:{opt {help title_options}}}titles to appear on combined graph{p_end}
{synopt:{opt {help region_options}}}outlining, shading, aspect ratio{p_end}
{synopt:{opt com:monscheme}}put graphs on common scheme{p_end}
{synopt:{opt sch:eme(schemename)}}overall look {p_end}
{synopt:{helpb nodraw_option:nodraw}}suppress display of combined graph{p_end}
{synopt:{helpb name_option:name()}}specify name for combined graph{p_end}
{synopt:{helpb saving_option:saving()}}save combined graph in file{p_end}

{syntab:Shared X- and Y- axes}
{synopt:{c -(}y|x{c )-}{helpb axis_scale_options:scale()}}log scales, range, appearance{p_end}
{synopt:{c -(}y|x{c )-}{helpb axis_label_options:label()}}major ticks plus labels{p_end}
{synopt:{c -(}y|x{c )-}{helpb axis_label_options:tick()}}major ticks only{p_end}
{synopt:{c -(}y|x{c )-}{helpb axis_label_options:mlabel()}}minor ticks plus labels{p_end}
{synopt:{c -(}y|x{c )-}{helpb axis_label_options:mtick()}}minor ticks only{p_end}
{synopt:{c -(}y|x{c )-}{helpb axis_title_options:title()}}specify axis title{p_end}

{syntab:Histogram}
{synopt:{cmd: {it: hist_method}}}the method used to draw histogram, where {it: hist_method} 
is one of {c -(}{bf:density|fraction|frequency|percent}{c )-}{p_end}
INCLUDE help gr_baropt

{syntab:Kernel}
{synopt:{opt kdens:ity}}display the kernel density (and suppress the histogram){p_end}
{synopt:{opt kdxopt:ions(options)}}specify any options specific to the {help twoway kdensity} on the x-axis{p_end}
{synopt:{opt kdyopt:ions(options)}}specify any options specific to the {help twoway kdensity} on the x-axis{p_end}

{syntab:Lines}
{synopt:{opt mean:s}}quarter the scatter plot into four quadrants defined by the means of the x and y variables{p_end}
{synopt:{opt med:ians}}quarter the scatter plot into four quadrants defined by the medians of the x and y variables{p_end}
{synopt:{opt ter:ciles}}overlay a 3 by 3 grid on the scatter plot, with cells defined by the terciles of the x and y variables{p_end}
{synopt:{opt quar:tiles}}overlay a 4 by 4 grid on the scatter plot, with cells defined by the quartiles of the x and y variables{p_end}
{synopt:{opt line45}}overlay a 45 degree line on the scatter plot{p_end}
{synopt:{opt opt45(options)}}Only relevant if {opt line45} is specified.  
Allows options to control the look of the 45 degree line.  See {help connect_options}.{p_end}

{syntab:Tabulate}
{synopt:{opt tab:ulate(statistic)}}the {it:statistic} is one of {c -(}{bf:count|cell|row|col}{c )-}{p_end}
{synopt:{opt tabfor:mat(format)}}the numerical format for the displayed statistics.{p_end}
{synopt:{opt matn:ame(name)}}The displayed statistics are returned in a matrix called r({it:name}){p_end}
{synopt:{opt textplace(compass_direction)}}Specifies a location for statistic placement within each grid cell.
Default is {it:c} for center.  Possible alternative locations are the compass directions: {it:n, s, e, w}.
See {help compassdirstyle}{p_end}
{synopt:{opt textsize(size)}}Specifies the size of the text within each grid cell. 
See {help textsizestyle}{p_end}

{syntab:Subset options}
{synopt:{opt hil:ite(condition)}}Observations meeting the logical {it:condition} 
are highlighted by superimposing a second plot of only that subset of observations
using a different symbol or color. {p_end}
{synopt:{opt hiliteo:ptions(string)}}Specify {help scatter##marker_options:msymbol and mcolor}
options specific to the highlighted observations. {p_end}
{synopt:{opt hid:e(condition)}}From the primary scatter plot, suppress observations
that meet the logical {it:condition}.{p_end}
{synopt:{opt samp:le(percentage)}}Randomly select a percentage of the observations 
for display.  The default is 100.{p_end}

{syntab:Fit type}
{synopt:{opt fitt:ype(fittype)}}Add a plot of a fitted regression line to the scatter plot.{p_end}
{synopt:{opt fito:ptions(string)}}Specify options for the fitted regression plot.
	Only relevant if {opt fitt:ype(fittype)} is specified.{p_end}
		
{syntab:Ellipse}
{synopt:{opt ell:ipse}}Add a plot of a confidence ellipse to the scatter plot.{p_end}
{synopt:{opt elev:el(real)}}Specify a confidence level as a percentage.  Default is {cmd:50}.{p_end}
{synopt:{opt esta:t(stat)}}Map the confidence level into the size of the confidence ellipse 
using either an F-statistic (the default) or a Chi^2 statistic by specifying 
either of {c -(}{bf:Chi2|Fstat}{c )-}.{p_end}
{synopt:{opt epat:tern(pattern)}}Specify a {help linepatternstyle:pattern} for the line defining the ellipse.  
Default is {cmd:solid}.{p_end}
{synopt:{opt ec:olor(color)}}Specify a {help colorstyle:color} of the line defining the ellipse.{p_end}
{synopt:{opt ew:idth(width)}}Specify the {help linewidthstyle:thickness} of the line defining the ellipse.{p_end}
		
{syntab:Scaling both axes}
{synopt:{opt sqrt}}Scale both axes on a square-root scale, with appropriate axis labels.{p_end}
{synopt:{opt log10pluszero}}Scale both axes on a log10 scale, with appropriate axis labels.{p_end}
{synopt:{opt log10plusone}}Add 1.0 to both the x and y values before taking their logarithms to the base 10
and scaling the axes accordingly. This option allows the display of zero values on a log scale at the cost
of possibly distorting the rest of the data.{p_end}

{syntab:Other twoway scatter options}
{synopt: *}Other options may (optionally) be declared.  These will be passed to the {helpb scatter} command. {p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:superscatter} creates a graph that is a scatter plot of the {it:y_variable} against the {it:x_variable}.
On the margins of the scatter plot are displayed graphs of the marginal distributions of the two
variables.  The user can choose to display the marginal distributions
as either histograms (the default) or as kernel densities. The {opt hil:ite} and
{opt hid:e} options used together allow the user to plot selected observations using
a different marker symbol or color.

{pstd}
Optionally the user can also overlay the marginal distributions and the scatter plots with lines 
drawn at the {opt mean:s}, {opt med:ians} or {opt quar:tiles} of the two distributions.  These lines form a grid of
four cells (if the option {opt med:ians} or {opt mean:s} is chosen) or 16 cells (if the option {opt quar:tiles} is chosen).

{pstd}
If one of the {opt mean:s}, {opt med:ians} or {opt quar:tiles} option has been selected, the user can specify the 
{opt tab:ulate(statistic)} option which displays the specified {it:statistic} as added text wihin each cell 
of the grid formed by the lines.  
The statistic can be a count of the observations in each cell of the grid or the percentage of observations
in the cell with respect to the row, column or all the data.

{pstd}{ul on}Axis scaling:{ul off} {cmd:Superscatter} offers three options for scaling the axes, 
{opt log10pluszero}, {opt log10plusone} and {opt sqrt}. {cmd:superscatter}'s approach to scaling 
the axes of this scatter plot is to first generate temporary transformations of the x- and y-variables that have
been transformed according to the chosen scaling rule, to construct the scatter plot
and the marginal distributions of these transformed variables and then to adorn the graph with
axis tick marks and labels that correspond to the untransformed variables.

{pstd}
By choosing the {opt fitt:ype(fittype)} option, the user can superimpose the scatter plot on a fitted line
with or without a confidence interval. If one of the axis scaling options 
{opt log10pluszero}, {opt log10plusone} or {opt sqrt} has also been specified,
this line is fitted to the transformmed data, not to the raw data.  {cmd:Superscatter}
thus avoids the {help help twoway lfit##remarks2:annoyingly kinked or otherwise deformed} 
fitted line that can occur when combining a fitted line with Stata's standard axis scaling options.   

{pstd}
Use of some of these options will generate a legend which distorts the shape of the
the main plotregion.  (This happens, because the default placement of the legend
squeezes the vertical dimension of the scatter plot.)  
To fix this problem, either suppress the legend by specifying {cmd:legend(off)} 
or specify that the legend be displayed inside the plotregion by specifying 
{cmd:legend(ring(0))}.

{pstd}
This command automates the process outlined in the help file of {help graph combine} (see "Advanced use").
It offers the user the additional options for scaling the axes and for adding grid lines, grid statistics, 
a fitted regression line or an ellipse to the scatter plot and for highlighting observations.


{title:Options}

{dlgtab:Combined Plot}

{phang}See {help graph combine} for option descriptions.  The options {it:imargin} and {it:graphregion} 
should not be declared.	

{dlgtab:Shared X- and Y- axes}

{phang} See {help axis options} for option descriptions.  The sub-options {it:nogrid} and {it:gmax} 
should not be declared as sub-options for {it:xlabel()}. 
The sub-options {it:alt} and {it:reverse} should not be declared as sub-options 
for {it:xlabel()} or {it:ylabel()}

{dlgtab:Histogram}

{phang}Select the method used to draw histogram.  Declare at most one of the following options:{break}
		{opt density} - draw as density; the default{break}
		{opt fraction} - draw as fractions{break}
		{opt frequency} - draw as frequencies{break}
		{opt percent} - draw as percents

{phang} See {help twoway histogram} for option descriptions.

{dlgtab:Kernel Density}

{phang}Display kernel density estimates of the marginal distributions instead of histograms.{break}
		{opt kdensity} - display the kernel density (and suppress the histogram){break}
		{opt kdxopt:ions(options)} - specify any options specific to the {help twoway kdensity} command on the x-axis{break}
		{opt kdyopt:ions(options)} - specify any options specific to the {help twoway kdensity} command on the y-axis{break}

{phang} See {help twoway kdensity} for option descriptions.

{dlgtab:Line options}

{phang}Overlay on the scatter plot a grid of lines which partition the observations 
	into bins:{break}
	{opt mean:s} - quarter the scatter plot into four quadrants defined by the means of the x and y variables{break}
	{opt med:ians} - quarter the scatter plot into four quadrants defined by the medians of the x and y variables{break}
	{opt ter:ciles} - overlay a 3 by 3 grid on the scatter plot, with cells defined by the terciles of the x and y variables{break}
	{opt quar:tiles} - overlay a 4 by 4 grid on the scatter plot, with cells defined by the quartiles of the x and y variables{break}

{phang} The means, medians or quartiles are computed by the {help summarize} command, while
	the terciles are computes with the {help centile} command.{break}
	{opt det:ail} - report the results of the {help summarize} and {help centile} commands.{p_end}

{dlgtab:Tabulate options}

{phang}Combined with one of the line options, the {opt tabulate(statistic)} option
	computes and displays within each grid cell one of four statistics. 
	{cmd:superscatter} then returns these 
	statistics on the x- and y-variables in {help return:r()} macros where 
	they can be retrieved by the user. The option {opt det:ail} shows the 
	same information in Stata's results window.{break}
	{opt det:ail} - output the statistics displayed in the cells of the grid
	to the Stata results window (and to a log, if one is open){p_end}

{phang}The four statistics available for each cell are::{break}
	{opt tab:ulate(count)} - display the number of observations in the cell of the grid{break}
	{opt tab:ulate(cell)} - display the percentage of all the observations in this cell of the grid{break}
	{opt tab:ulate(row)} - display the percentage of the row observations in this cell of the grid{break}
	{opt tab:ulate(col)} - display the percentage of the column observations in this cell of the grid{p_end}

{phang}The following options control the appearance of the tabulate statistics overlaid on the scatter plot:{break}
	{opt tabfor:mat(format)} - the numerical format for the displayed statistics. 
		The default format for the {opt tab:ulate(count)} option is %~15s, which centers the frequency count within the cell.
		Otherwise, the default format for the percentages is %4.1f, which the user might want to override to display more or fewer decimals.{break}
	{opt matn:ame(name)} - The displayed statistics are returned in a matrix called r({it:name}){break}
	{opt textplace(compass_direction)} - Specifies a location for text placement wihin each grid cell.
	Default is {it:c} for center.  Possible alternative locations are the compass directions: {it:n, s, e, w}{break}
	{opt textsize(size)} - Specifies the size of the text wihin each grid cell{p_end}

{dlgtab:Subset options}

{pstd}
Several options are available for hiding, highlighting or selecting subsets of 
observations in the scatter plot.  The options {opt hil:ite(condition)} and
{opt hid:e(condition)} can be used separately or together. Using only {opt hil:ite(condition)}
without {opt hid:e(condition)} will superimpose a second marker on
the selected observations.  Specifying the {opt hid:e(condition)}  option 
with the same logical {it:condition} suppresses the primary marker 
so that the selected observations are plotted with only the highlighting 
marker.{p_end}

{phang}
{opt samp:le(percentage)} - When the number of observations is so large that points
are indistinguishable in the scatter plot, this option randomly selects a percentage of the 
observations for display.  If the option is omitted all observations are displayed. 
(That is the default for this option is 100%.)  Since the subset of observations 
displayed by the {opt samp:le(percentage)} option is random, 
selecting this option may distort the shape of the scatter plot. 
Furthermore, unless Stata's {help set seed} option is used to specify the seed 
for the random selection process, {opt samp:le(percentage)} will alter the 
scatter randomly on each execution. Selecting this option has no effect,
however, on the shapes of either of the marginal distributions.{p_end}

{dlgtab:Fit type options}

{phang}Add a plot of a fitted regression line to the scatter plot.  The syntax is {opt fitt:ype(fittype)}
where {it:fittype} must be one of the following:{break}
		{helpb twoway lfit:lfit} - a linear regression of the y variable on the x variable{break}
		{helpb twoway lfitci:lfitci} - a linear regression of the y variable on the x variable, with confidence interval{break}
		{helpb twoway qfit:qfit} - a quadratic regression of the y variable on the x variable{break}
		{helpb twoway qfitci:qfitci} - a quadratic regression of the y variable on the x variable, with confidence interval{break}
		{helpb twoway fpfit:fpfit} - a fractional polynomial regression of the y variable on the x variable{break}
		{helpb twoway fpfitci:fpfitci} - a fractional polynomial regression of the y variable on the x variable, with confidence interval{break}
		{helpb twoway mspline:mspline} - a median spline regression of the y variable on the x variable{break}
		{helpb twoway lowess:lowess} - a lowess regression of the y variable on the x variable{break}
		{opt fito:ptions(string)} to control the look of any of the above fitted lines.  To pass options to the {help regress} 
			or other estimation command, place them within {opt est:opt(regress options)}.  For example, to fit a linear regression
			without a constant, and depict the fitted line with a thick line, specify 
			{opt fito:ptions(estopt(noconst) lwidth(vthick))}.  See {help twoway_lfit:lfit}.

{dlgtab:Ellipse options}

{phang}By specifying the option {opt ell:ipse}, the user can overlay a confidence ellipse on the scatter plot. 
Under the assumption that the joint distribution of the two variables in {cmd:varlist} 
is bivariate normal, the ellipse includes {opt elev:el} percent of the probability mass
of the joint distribution.  The area encompassed by the ellipse can be expanded 
either by using option {opt esta:t(string)} to select the Chi^2 statistic instead of the F-statistic
or by using the {opt elev:el(real)} option to specify a confidence level higher than the default of 50%.{break} 

{phang}The option {opt ell:ipse} returns statistics on the x- and y-variables
in {cmd:r()} macros where they can be retrieved by the user.{break}

{phang}Options {opt ell:ipse} and {opt fitt:ype(fittype)} can be combined. 
Both of these options generate default legends.  The user can override these defaults by specifying 
customized legends on the command line. When specifying a legend, use the {opt ring(0)} option
in order to keep the frequencey distribution for the y-variable aligned with 
the vertical dimension of the scatter plot.{break}

{dlgtab:Scaling both axes}

{phang}Since economic variables often have skewed distributions, a convex transformation
of the variables such as the logarithm or the square root can be a useful technique
for revealing more information about the variables in a scatter plot.
The standard {opt xscale(log)} is available for 
expressing one axis on a log scale.  The option {opt log10pluszero}
produces the same result as specifying both of these two options.  The option {opt log10plusone}
adds 1.0 to the values of the variables on the x- and y-axes in order to display points that
have a zero value on one of the two axes.  A third option in this group, the option {opt sqrt},
also displays the zero values, with the axes scaled as the square-root of the original variables.

{dlgtab:Other twoway scatter options}

{phang}Other options may (optionally) be declared.  
These will be passed to the {helpb scatter} command.  For example, you might declare
{help scatter##marker_options:marker_options}, 
{help scatter##marker_label_options:marker_label_options}, or 
{help scatter##jitter_options:jitter_options}.  

{phang}See {help twoway scatter} for a complete list of options.

{phang}These options are not restricted by the program; 
however, some (such as {opt by}) will cause major problems 
and some should not be used. Use these at your own risk!{p_end}


{marker examples}{...}
{title:Examples}

{pstd}First set up the data by clicking on "click to set up data".  Then
click on any of the examples for a demonstration of that feature of
superscatter.{p_end}

{phang}{cmd:. set more off }{p_end}
{phang}{cmd:. sysuse lifeexp, clear}{p_end}
{phang}{cmd:. qui gen loggnp = log10(gnppc)}{p_end}
{phang}{cmd:. label var loggnp "Log base 10 of GNP per capita"}{p_end}
{phang}{cmd:. qui gen us_gnp0 = country if country=="United States" | country=="Haiti" | gnppc>=.}{p_end}
{phang}{cmd:. label var us_gnp0 "Labels of selected countries"}{p_end}
{phang}{cmd:. describe}{p_end}
{phang}{cmd:. summarize, detail}{p_end}
{it:({stata superscatter_example setup:click to set up data})}

{pstd}Now that the data has been prepared, execute any of the following examples by clicking on the 
associated hotlink.  The first example recreates an example in Stata's manual entry for 
{help graph_combine}.{p_end}

{phang}{cmd:. *      Border the scatter plot with histograms.}{p_end}
{phang}{cmd:. superscatter lexp loggnp, name(_example1, replace)}{p_end}
{it:({stata superscatter_example example1:click to run example 1})}

{phang}{cmd:. *      Same plot with various optional cosmetic touches.}{p_end}
{phang}{cmd:. superscatter lexp loggnp, percent color(dkorange) mlabel(us_gnp0) m(s) msize(small)  xtitle("GNP per capita (log)") name(_example2, replace)}{p_end}
{it:({stata superscatter_example example2:click to run example 2})}

{pstd}Example 3 demonstrates the use of the {opt med:ians} and {opt tab:ulate(count)} options.
The {opt med:ians} option divides the data into four quadrants, each of which in principle
contains a quarter of the observations.  The {opt tab:ulate(count)} option gives the number
of observations in each quarter.  Surprisingly, the number in the top half is much less
than the number in the bottom half of the scatter plot.{p_end}

{pstd}In this atypical data, nine observations on the variable life-expectancy 
in the complete sample and 8 of those used in the scatterplot are exactly equal 
to the median value of 73 years. In computing the cell counts,
superscatter arbitrarily assigns the observations exactly at the median value to cells below the median.
In this situation, this assignment leads to a marked imbalance, with 38 observations below
median life-expectancy and only 25 above it.  The marginal distributions
are unaffected by this imbalance.{p_end}

{pstd}This issue is unlikely to arise with variables measured with more precision,
because with more preciely measured variables there is unlikely to be
more than one observation at the median value. For example, 
loggnp on the horizontal dimension of the plots in this example has only one median value.{p_end}

{phang}{cmd:. *      Replace the histograms with kernel density plots and add median lines and cell counts.}{p_end}
{phang}{cmd:. superscatter lexp loggnp, kdensity medians tabulate(count) matname(tabout) detail name(_example3, replace) }{p_end}

{phang}{cmd:. *      List the statistics used to construct the tabulations.}{p_end}
{phang}{cmd:. return list}{p_end}
{phang}{cmd:. matrix list r(tabout)}{p_end}
{it:({stata superscatter_example example3:click to run example 3})}

{pstd}Superscatter offers multiple options for superimposing information on the scatter plot,
several of which generate a legend. Without user intervention, the legend so generated 
appears immediately below the scatter plot, shortening its vertical dimension
so that it no longer aligns with the marginal distribution depicted to the left of
the vertical axis. Example 4 shows how the user can move the legend to the interior
of the scatter plot and restore its alignment with the marginal distribution. {p_end}

{phang}{cmd:. *      To the bordered plot of example 1, add the fitted regression line and position the legend.}{p_end}
{phang}{cmd:. superscatter lexp loggnp, means fittype(lfitci) fitoptions(lwidth(vthick)) legend(ring(0) cols(1) pos(5)) ytitle(Life Expectancy) name(_example4, replace) }{p_end}
{it:({stata superscatter_example example4:click to run example 4})}

{phang}{cmd:. *      Overlay the scatter plot with a bivariate normal confidence ellipse.}{p_end}
{phang}{cmd:. superscatter lexp loggnp, ellipse quartiles ytitle(Life Expectancy) name(_example5, replace) }{p_end}

{phang}{cmd:. *      List the descriptive statistics used to construct the ellipse.}{p_end}
{phang}{cmd:. return list}{p_end}
{it:({stata superscatter_example example5:click to run example 5})}

{phang}{cmd:. *      Overlay the scatter plot with both an ellipse and a fitted line.}{p_end}
{phang}{cmd:. superscatter lexp loggnp, means fittype(lfit) fitoptions(lwidth(vthick)) ellipse ytitle(Life Expectancy) name(_example6, replace) }{p_end}
{it:({stata superscatter_example example6:click to run example 6})}

{pstd}A scatter plot is a useful way of comparing two versions of the same variable. Using this 
demonstration data, we compare the life-expectancy a country might be expected to have based on its GNP per capita
(it's "predicted" life expectancy) to its actual life-expectancy.
First, we estimate a regression of 1998 life-expectancy on the log of 1998 GNP per capita and use
Stata's {help predict} command to estimate each country's predicted 1998 life-expectancy.
Then we use {cmd:superscatter} with the {opt line45} option to compare each country's 
prediected 1998 life-expectancy to its actual 1998 life-expectancy.  Countries above the 
45 degree line had disappointing health sector performance in 1998, because their life-expectancies
were lower than would have been predicted based on their GNP.  Haiti is a particularly striking outlier.
While it is one of the poorest countries in the world, its low GNP would predict 
a life expectancy of about 66 years.  In contrast its actual life expectancy was 
only 55 in 1988, 11 years lower than would be predicted from its poverty alone. 
(In 1988, Haiti's estimated life expectancy was reduced by the worst AIDS epidemic
in the western hemisphere.){p_end}

{phang}{cmd:.  *	Use a 45 degree line to compare observed to predicted life expectancy.}{p_end}
{phang}{cmd:.  regress lexp loggnp}{p_end}
{phang}{cmd:.  predict lexp_hat, xb}{p_end}
{phang}{cmd:.  lab var lexp_hat "Fitted value of life expectancy"}{p_end}
{phang}{cmd:.  local textadds `"text(68 82 "Predicted less" "than observed") text(78 68 "Predicted greater" "than observed") "'}{p_end}
{phang}{cmd:.  superscatter lexp_hat lexp, line45 opt45(lwidth(vthick)) legend(off) mlabel(us_gnp0) ytitle(Predicted Life Expectancy) xtitle(Observed Life Expectancy) xlabel(55(5)90) \`textadds' name(_example7, replace) }{p_end}
{it:({stata superscatter_example example7:click to run example 7})}

{pstd}When plotting skewed distributions, it is often useful to transform the axis
scales in order to spread out the data points at the end of the scale where most of the data
is concentrated. In examples 1 through 5 this is achieved by plotting the
logarithm of GNP rather than its actual value on the horizontal axis.  
Instead of transforming the skewed GNP per capita variable, 
as is done above, one could instead specify the option {opt xsc:ale(log)}, but 
the resulting histogram of the marginal distribution on the x-axis is distorted
by the stretching.  The analagous option for the y-axis, {opt ysc:ale(log)}, has no effect on 
{cmd:superscatter}, because Stata has
{browse "https://www.stata.com/statalist/archive/2003-02/msg00912.html":disabled}
this option for histograms.{p_end}

{pstd}Superscatter provides three convex transformation options all of 
which apply the same transformation to both the variables being plotted.
These three options are most useful when both plotted variables are non-negative
and right-skewed, as is often the case with economic data.  The three additional 
options are {opt sqrt}, {opt log10pluszero} and {opt log10plusone}.  
Of these, the {opt sqrt}
option and the {opt log10plusone} both accommodate zeros in the underlying data. 
Here's an example of the application of the {opt sqrt} option.{p_end}

{phang}{cmd:. *    Scale both axes by the square-root.}{p_end}
{phang}{cmd:. superscatter lexp gnppc, sqrt ytitle(Life Expectancy on square-root scale) xtitle(GNP per capita on square-root scale) name(_example8, replace)}{p_end}
{it:({stata superscatter_example example8:click to run example 8})}

{pstd}{cmd:superscatter} emulates {help scatter}'s {opt xsc:ale(log)} and {opt ysc:ale(log)} options in 
labeling the scaled axes with the appropriate unscaled values of the plotted variables.
For the {opt sqrt} option, axis labels are rounded to values with integer square roots.
For the {opt log10pluszero} and {opt log10plusone} options, axis labels 
are rounded to powers of 10.  
With the {opt sqrt} option, {cmd:superscatter} will properly relabel the axes 
when the maximum of each of the two plotted variables 
exceeds the minimum by at least a factor of 4.  
For the two options that transform using the base 10 logarithm, 
{opt log10pluszero} and {opt log10plusone},
{cmd:superscatter} will produce the most pleasing axis labels 
when the maxima of the two variables exceed their minima by several orders of magnitude.{p_end}

{pstd}The choice between the {opt log10pluszero} and {opt log10plusone} options
is guided by whether the user needs to display values that are equal to, or slightly 
less than, zero.  In the example data the variable {cmd:popgrowth} ranges from 
-0.5 to 3.0, with 8 of its 68 values non-positive. Of these 8 observations,
all but one is non-missing for the x-axis variable, {cmd:gnppc}.  Thus, 
with the {opt log10pluszero} option, 7 countries are omitted from the plot
constructed by {cmd:superscatter}. 

{phang}{cmd:. *	Scaling both axes using the option -logh10pluszero- omits 7 observations.}{p_end}
{phang}{cmd:. superscatter popgrowth gnppc, log10pluszero ytitle(Population growth rates > 0 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9a, replace)}{p_end}
{it:({stata superscatter_example example9a:click to run example 9a})}

{pstd}The graph shows that the population growth rate for the United States 
in 1988 was 1.0 percent per year.{p_end}

{pstd}Now in order to display the other seven observations, while retaining
the logarithmic scaling, we instead use the option {opt log10plus0ne}.{p_end}

{phang}{cmd:. *    Scale both axes by log to the base 10 after adding 1.0 to the variable.}{p_end}
{phang}{cmd:. superscatter popgrowth gnppc, log10plusone ytitle(Population growth rates > -1 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9b, replace)}{p_end}
{it:({stata superscatter_example example9b:click to run example 9b})}

{pstd}The {opt log10plus0ne} is also useful for revealing observations with
zero values.{p_end}

{phang}{cmd:. *	Create a version of gnppc with zeros replacing missing values.}{p_end}
{phang}{cmd:. gen gnp0 = gnppc}{p_end}
{phang}{cmd:. replace gnp0 = 0 if gnppc >=.}{p_end}
{phang}{cmd:. label var gnp0 "Zero-filled GNP per capita"}{p_end}

{phang}{cmd:. *    Scale both axes by log to the base 10 after adding 1.0 to the variable.}{p_end}
{phang}{cmd:. superscatter popgrowth gnppc, log10plusone ytitle(Population growth rates > -1 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9b, replace)}{p_end}
{it:({stata superscatter_example example9c:click to run example 9c})}

{pstd}The option {opt hilite} can be combined with the option {opt hide} to display
a subset of the points using a different symbol.  As noted above, to prevent the
legend from interfering with the alignment of the y-axis and the marginal distribution 
of the y-variable, either suppress the legend with {cmd:legend(off}} or
specify that it appear within the plot area using the option {opt ring(0)}.{p_end}

{phang}{cmd:. *    Highlight the North American countries, add a legend and custom yaxis labels.}{p_end}
{phang}{cmd:.  superscatter lexp gnp0, hilite(region==2) hide(region==2) legend(order(1 "North America" 2 "Other regions") ring(0) pos(4) col(1)) name(_example10, replace)}{p_end}
{it:({stata superscatter_example example10:click to run example 10})}


{marker results}{...}
{title:Stored results}

{dlgtab:Ellipse results}

{pstd}
If option {cmd:ellipse} is specified, {cmd:superscatter} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(estat)}}User-selected test statistic used to determine the size 
of the ellipse for a selected value of {cmd:elevel}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations in scatter and in computation of the ellipse properties{p_end}
{synopt:{cmd:r(y_mean)}}mean of y-variable{p_end}
{synopt:{cmd:r(y_sd)}}standard deviation of y-variable{p_end}
{synopt:{cmd:r(x_mean)}}mean of x-variable{p_end}
{synopt:{cmd:r(x_sd)}}standard deviation of x-variable{p_end}
{synopt:{cmd:r(rho)}}correlation coefficient{p_end}
{synopt:{cmd:r(elevel)}}confidence level for construction of the ellipse{p_end}
{synopt:{cmd:r(ndf)}}numerator degrees-of-freedom for F- or Chi^2 statistic{p_end}
{synopt:{cmd:r(ddf)}}denominator degrees-of-freedom for F- or Chi^2 statistic{p_end}
{synopt:{cmd:r(critval)}}for the selected test-statistic and the selected confidence level,
this critical value determines the size of the constructed ellipse{p_end}

{dlgtab:Tabulate results}

{pstd}
If option {cmd:tabulate} is specified, {cmd:superscatter} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(cells2text)}}Text of the option used internally by {cmd:superscatter} to add tabulated statistics 
to the {cmd:graph twoway scatter} command.{p_end}

{p2col 5 15 19 2: Matrices (returned only if option {cmd:matname} is specified)}{p_end}
{synopt:{cmd:r({it:name})}}Statistics displayed by {cmd:tabulate} option{p_end}

{p2colreset}{...}


{marker author}{...}
{title:Authors}

{phang}Keith Kranker coded {help scatter_hist} and posted it at Boston College.{p_end}

{phang}{browse "http://www.cgdev.org/expert/mead-over/":Mead Over} added additional 
functionality in May, 2015 - August, 2017.  Contact him at
{browse "mailto:mover@cgdev.org":MOver@CGDev.Org} if you observe any
problems. {p_end}

{* Version History of this help file}
{* Version 1.0	15May2015}
{* Version 1.01	30Jul2015	Fixed the -Jump To- directives}
{* Version 1.1 	19Aug2015	Added documentation for the ellipse options}
{* Version 1.2 	17Oct2015	Added documentation of stored results}
{* Version 1.3 	23Oct2015	Document change in option from estyle to epattern}
{* Version 1.4 	29Jun2017	Revise examples and description of option fitoptions() }
{* Version 1.5 	24Aug2017	Add Example 10 demonstratng -hilite-.  Other edits. }
{* Version 1.6 	25Jan2019	Enhance discussion of the options fittype and fitoptions. }
{* Version 1.7 	17Feb2019	Add -terciles- and improve -dfltfrmt-. }
