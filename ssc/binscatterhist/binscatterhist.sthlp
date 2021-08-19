{smcl}
{* *! version 2.1 07jan2020}{...}
{viewerjumpto "Syntax" "binscatterhist##syntax"}{...}
{viewerjumpto "Description" "binscatterhist##description"}{...}
{viewerjumpto "Options" "binscatterhist##options"}{...}
{viewerjumpto "Examples" "binscatterhist##examples"}{...}
{viewerjumpto "Saved results" "binscatterhist##saved_results"}{...}
{viewerjumpto "Author" "binscatterhist##author"}{...}
{viewerjumpto "Acknowledgements" "binscatterhist##acknowledgements"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:binscatterhist} {hline 2}}Binned scatterplots with variables distribution{p_end}
{p2colreset}{...}


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:binscatterhist}
{varlist} {ifin}
{weight}
[{cmd:,} {it:options}]


{pstd}
where {it:varlist} is 
{p_end}
		{it:y_1} [{it:y_2} [...]] {it:x}

{synoptset 26 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{opth by(varname)}}plot separate series for each group (see {help binscatterhist##by_notes:important notes below}){p_end}
{synopt :{opt med:ians}}plot within-bin medians instead of means{p_end}

{syntab :Bins}
{synopt :{opth n:quantiles(#)}}number of equal-sized bins to be created; default is {bf:20}{p_end}
{synopt :{opth gen:xq(varname)}}generate quantile variable containing the bins{p_end}
{synopt :{opt discrete}}each x-value to be used as a separate bin{p_end}
{synopt :{opth xq(varname)}}variable which already contains bins; bins therefore not recomputed{p_end}

{syntab :Residuals Computation}
{synopt :{opth reg:type(regtype)}}can be {bf:reghdfe} or {bf:areg}, requires absorb() to be specified; default is {bf:reghdfe}{p_end}

{syntab :SE/Robust}
{synopt :{opth clust:er(varname)}}clustered s.e. affect both the sample for residualization and the computation of s.e. for slope reporting{p_end}
{synopt :{opt vce(robust)}}robust s.e. affect both the sample for residualization and the computation of s.e. for slope reporting{p_end}

{syntab :Controls}
{synopt :{opth control:s(varlist)}}residualize the x & y variables on controls before plotting{p_end}
{synopt :{opth absorb(varlist)}}residualize the x & y variables on a categorical variable. Can include only one variable, if {bf:regtype(areg)} is specified{p_end}
{synopt :{opt noa:ddmean}}do not add the mean of each variable back to its residuals{p_end}

{syntab :Fit Line}
{synopt :{opth line:type(binscatterhist##linetype:linetype)}}type of fit line; default is {bf:lfit}, may also be {bf:qfit}, {bf:connect}, or {bf:none}{p_end}
{synopt :{opth rd(numlist)}}create regression discontinuity at x-values{p_end}
{synopt :{opt reportreg}}display the regressions used to estimate the fit lines{p_end}

{syntab :Coefficient and Sample Reporting}
{synopt :{opth coef:ficient(#)}}reports the slope of the fitted line with its standard error, rounded at # using round(coef,#). See {help f_round:round}  {p_end}
{synopt :{opt sample}}reports the sample size of the regression on residualized variables{p_end}
{synopt :{opth stars(stars)}}signals p-value using stars; stars can be: {bf:nostars}, {bf:1} (*5% **1%), {bf:2} (+10% *5% **1%), {bf:3} (+10% *5% **1% ***0.1%), {bf:4} (*5% **1% ***0.1%); default is {bf:stars(1)}{p_end}

{syntab :Graph Style}
{synopt :{cmdab:col:ors(}{it:{help colorstyle}list}{cmd:)}}ordered list of colors{p_end}
{synopt :{cmdab:mc:olors(}{it:{help colorstyle}list}{cmd:)}}overriding ordered list of colors for the markers{p_end}
{synopt :{cmdab:lc:olors(}{it:{help colorstyle}list}{cmd:)}}overriding ordered list of colors for the lines{p_end}
{synopt :{cmdab:m:symbols(}{it:{help symbolstyle}list}{cmd:)}}ordered list of symbols{p_end}
{synopt :{it:{help twoway_options}}}{help title options:titles}, {help legend option:legends}, {help axis options:axes}, added {help added line options:lines} and {help added text options:text},
	{help region options:regions}, {help name option:name}, {help aspect option:aspect ratio}, etc.{p_end}

{syntab :Histogram}
{synopt :{opth hist:ogram(varlist)}}plots a histogram for earliest vars {bf:(max=2)}. Selected variables have to be the scattered ones{p_end}
{synopt :{opth xm:in(value)}}sets the base position of the {bf:y} histogram in terms of {bf:xaxis}{p_end}
{synopt :{opth ym:in(value)}}sets the base position of the {bf:x} histogram in terms of {bf:yaxis}{p_end}
{synopt :{opth xhistbarheight(value)}}sets the height of the {bf:x} histogram as a percentage; default is {bf:xhistbarheight(10)}{p_end}
{synopt :{opth yhistbarheight(value)}}sets the height of the {bf:y} histogram as a percentage; default is {bf:yhistbarheight(10)}{p_end}
{synopt :{opth xhistbarwidth(value)}}sets the width of the {bf:x} histogram as a percentage; default is {bf:xhistbarwidth(100)}{p_end}
{synopt :{opth yhistbarwidth(value)}}sets the width of the {bf:y} histogram as a percentage; default is {bf:yhistbarwidth(100)}{p_end}
{synopt :{opth xhistbins(#)}}number of bins to be created; default is {bf:20}{p_end}
{synopt :{opth yhistbins(#)}}number of bins to be created; default is {bf:20}{p_end}

      Following options require axis to be specified: x or y, e.g. xcolor() ycolor()
{synopt :{opth axiscolor(colorstyle)}}outline and fill color and opacity; default is {bf:teal%50} for xcolor() and {bf:maroon%50} for ycolor(){p_end}
{synopt :{opth axisfcolor(colorstyle)}}fill color and opacity{p_end}
{synopt :{opth axisfintensity(intensitystyle)}}fill intensity{p_end}
{synopt :{opth axislcolor(colorstyle)}}outline color and opacity{p_end}
{synopt :{opth axislwidth(linewidthstyle)}}thickness of outline{p_end}
{synopt :{opth axislpattern(linepatternstyle)}}outline pattern (solid, dashed, etc.){p_end}
{synopt :{opth axislalign(linealignmentstyle)}}outline alignment (inside, outside, center){p_end}
{synopt :{opth axislstyle(linestyle)}}overall look of outline{p_end}
{synopt :{opth axisbstyle(areastyle)}}overall look of bar, all settings above{p_end}
{synopt :{opth axispstyle(pstyle)}}overall plot style, including areastyle{p_end}

{syntab :Save Output}
{synopt :{opt savegraph(filename)}}save graph to file; format automatically detected from extension [ex: .gph .jpg .png]{p_end}
{synopt :{opt savedata(filename)}}save {it:filename}.csv containg scatterpoint data, and {it:filename}.do to process data into graph{p_end}
{synopt :{opt replace}}overwrite existing files{p_end}

{syntab :fastxtile options}
{synopt :{opt nofastxtile}}use xtile instead of fastxtile{p_end}
{synopt :{opth randvar(varname)}}use {it:varname} to sample observations when computing quantile boundaries{p_end}
{synopt :{opt randcut(#)}}upper bound on {cmd:randvar()} used to cut the sample; default is {cmd:randcut(1)}{p_end}
{synopt :{opt randn(#)}}number of observations to sample when computing quantile boundaries{p_end}
{synoptline}
{p 4 6 2}
{opt aweight}s and {opt fweight}s are allowed;
see {help weight}.
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt binscatterhist} generates binned scatterplots, with the option to plot the variables underlying distribution and report estimation results.

{pstd}
Binned scatterplots provide a non-parametric way of visualizing the relationship between two variables, 
{cmd:binscatterhist} adds several features to the popular program used to produce such scatterplots, {cmd:binscatter}.
{cmd:Binscatterhist} uses by default {cmd:reghdfe} to calculate residuals, therefore allowing for multiple fixed effects, but keeps {cmd:areg} as an alternative option.
{cmd:Binscatterhist} allows, in addition, to create histograms of the scattered variables, and include them in the
graph for a more complete representation of the data. Finally, it allows for an automatic reporting of the slope and standard error of the fitted
line, with options for robust and clustered standard errors.
As binscatter, {cmd:binscatterhist} solves the problem of scatterplots
with a large number of observations: it groups the x-axis variable into equal-sized bins, computes the
mean of the x-axis and y-axis variables within each bin, then creates a scatterplot of these data points.

{pstd}
{opt Binscatterhist} keeps as a base, the same options as binscatter: it provides built-in options to control for covariates before plotting the relationship
(see {help binscatterhist##controls:Controls}), and will plot fit lines based on the underlying data, and can automatically 
handle regression discontinuities (see {help binscatterhist##fit_line:Fit Line}).


{marker options}{...}
{title:Options}

{dlgtab:Main}

{marker by_notes}{...}
{phang}{opth by(varname)} plots a separate series for each by-value.  Both numeric and string by-variables
are supported, but numeric by-variables will have faster run times.

{pmore}Users should be aware of the two ways in which {cmd:binscatterhist} does not condition on by-values:

{phang3}1) When combined with {opt controls()} or {opt absorb()}, the program residualizes using the restricted model in which each covariate
has the same coefficient in each by-value sample.  It does not run separate regressions for each by-value.  If you wish to control for 
covariates using a different model, you can residualize your x- and y-variables beforehand using your desired model then run {cmd:binscatterhist}
on the residuals you constructed.

{phang3}2) When not combined with {opt discrete} or {opt xq()}, the program constructs a single set of bins
using the unconditional quantiles of the x-variable.  It does not bin the x-variable separately for each by-value.
If you wish to use a different binning procedure (such as constructing equal-sized bins separately for each
by-value), you can construct a variable containing your desired bins beforehand, then run {cmd:binscatterhist} with {opt xq()}.

{phang}{opt med:ians} creates the binned scatterplot using the median x- and y-value within each bin, rather than the mean.
This option only affects the scatter points; it does not, for instance, cause {opt linetype(lfit)}
to use quantile regression instead of OLS when drawing a fit line.

{dlgtab:Bins}

{phang}{opth n:quantiles(#)} specifies the number of equal-sized bins to be created.  This is equivalent to the number of
points in each series.  The default is {bf:20}. If the x-variable has fewer
unique values than the number of bins specified, then {opt discrete} will be automatically invoked, and no
binning will be performed.
This option cannot be combined with {opt discrete} or {opt xq()}.

{pmore}
Binning is performed after residualization when combined with {opt controls()} or {opt absorb()}.
Note that the binning procedure is equivalent to running xtile, which in certain cases will generate
fewer quantile categories than specified. (e.g. {stata sysuse auto}; {stata xtile temp=mpg, nq(20)}; {stata tab temp})
  
{phang}{opth gen:xq(varname)} creates a categorical variable containing the computed bins.
This option cannot be combined with {opt discrete} or {opt xq()}.

{phang}{opt discrete} specifies that the x-variable is discrete and that each x-value is to be treated as
a separate bin. {cmd:binscatterhist} will therefore plot the mean y-value associated with each x-value.
This option cannot be combined with {opt nquantiles()}, {opt genxq()} or {opt xq()}.

{pmore}
In most cases, {opt discrete} should not be combined with {opt controls()} or {opt absorb()}, since residualization occurs before binning,
and in general the residual of a discrete variable will not be discrete.

{phang}{opth xq(varname)} specifies a categorical variable that contains the bins to be used, instead of {cmd:binscatterhist} generating them.
This option is typically used to avoid recomputing the bins needlessly when {cmd:binscatterhist} is being run repeatedly on the same sample
and with the same x-variable.
It may be convenient to use {opt genxq(binvar)} in the first iteration, and specify {opt xq(binvar)} in subsequent iterations.
Computing quantiles is computationally intensive in large datasets, so avoiding repetition can reduce run times considerably.
This option cannot be combined with {opt nquantiles()}, {opt genxq()} or {opt discrete}.

{pmore}
Care should be taken when combining {opt xq()} with {opt controls()} or {opt absorb()}.  Binning takes place after residualization,
so if the sample changes or the control variables change, the bins ought to be recomputed as well.

{marker residuals}{...}
{dlgtab:Residuals Computation}

{phang}{opth reg:type(regtype)}  can be {bf:reghdfe} or {bf:areg}, requires absorb() to be specified; default is {bf:reghdfe}. When {bf:reghdfe} is specified, absorb()
allows for more than one carname, however, interactions are not allowed, including tricks like e.g. one##control, to include controls in the absorb. Such controls
must be included in the controls() option. {bf:reghdfe} drops singleton observations w.r.t. the included fixed effects, therefore sample size might differ between 
{bf:reghdfe} and {bf:areg}.

{marker se/robust}{...}
{dlgtab:SE/Robust}

{phang}{opth clust:er(varname)} clustered s.e. affect both the sample for residualization and the computation of s.e. for slope reporting.

{phang}{opt vce(robust)} robust s.e. affect both the sample for residualization and the computation of s.e. for slope reporting.  

{marker controls}{...}
{dlgtab:Controls}

{phang}{opth control:s(varlist)} residualizes the x-variable and y-variables on the specified controls before binning and plotting.
To do so, {cmd:binscatterhist} runs a regression of each variable on the controls, generates the residuals, and adds the sample mean of
each variable back to its residuals.

{phang}{opth absorb(varname)} absorbs fixed effects in the categorical variable from the x-variable and y-variables before binning and plotting,
To do so, {cmd:binscatterhist} runs an {helpb areg} of each variable with {it:absorb(varname)} and any {opt controls()} specified.  It then generates the
residuals and adds the sample mean of each variable back to its residuals.

{phang}{opt noa:ddmean} prevents the sample mean of each variable from being added back to its residuals, when combined with {opt controls()} or {opt absorb()}.

{marker fit_line}{...}
{dlgtab:Fit Line}

{marker linetype}{...}
{phang}{opth line:type(binscatterhist##linetype:linetype)} specifies the type of line plotted on each series.
The default is {bf:lfit}, which plots a linear fit line.  Other options are {bf:qfit} for a quadratic fit line,
{bf:connect} for connected points, and {bf:none} for no line.

{pmore}Linear or quadratic fit lines are estimated using the underlying data, not the binned scatter points. When combined with
{opt controls()} or {opt absorb()}, the fit line is estimated after the variables have been residualized.

{phang}{opth rd(numlist)} draws a dashed vertical line at the specified x-values and generates regression discontinuities when combined with {opt line(lfit|qfit)}.
Separate fit lines will be estimated below and above each discontinuity.  These estimations are performed using the underlying data, not the binned scatter points.

{pmore}The regression discontinuities do not affect the binned scatter points in any way.
Specifically, a bin may contain a discontinuity within its range, and therefore include data from both sides of the discontinuity.

{phang}{opt reportreg} displays the regressions used to estimate the fit lines in the results window.

{marker chef}{...}
{dlgtab:Coefficient and Sample Reporting}

{phang}{opt coef:ficient} reports the slope of the fitted line with its standard error.

{phang}{opt sample} reports the sample size of the regression on residualized variables.

{phang}{opth stars(stars)} signals p-value using stars; stars can be: {bf:nostars}, {bf:1} (*5% **1%), {bf:2} (+10% *5% **1%), {bf:3} (+10% *5% **1% ***0.1%), {bf:4} (*5% **1% ***0.1%); default is {bf:stars(1)}.


{dlgtab:Graph Style}

{phang}{cmdab:col:ors(}{it:{help colorstyle}list}{cmd:)} specifies an ordered list of colors for each series

{phang}{cmdab:mc:olors(}{it:{help colorstyle}list}{cmd:)} specifies an ordered list of colors for the markers of each series, which overrides any list provided in {opt colors()}

{phang}{cmdab:lc:olors(}{it:{help colorstyle}list}{cmd:)} specifies an ordered list of colors for the line of each series, which overrides any list provided in {opt colors()}

{phang}{cmdab:m:symbols(}{it:{help symbolstyle}list}{cmd:)} specifies an ordered list of symbols for each series

{phang}{it:{help twoway_options}}:

{pmore}Any unrecognized options added to {cmd:binscatterhist} are appended to the end of the twoway command which generates the
binned scatter plot.

{pmore}These can be used to control the graph {help title options:titles},
{help legend option:legends}, {help axis options:axes}, added {help added line options:lines} and {help added text options:text},
{help region options:regions}, {help name option:name}, {help aspect option:aspect ratio}, etc.

{dlgtab:Histogram}

{phang}{opth hist:ogram(varnames)} plots a histogram for each of the selected variables {bf:(max=2)}. Selected variables have to be the scattered ones. Requires {bf:xmin()} if {bf:yvar} is plotted and {bf:ymin()} if {bf:xvar()} is plotted

{phang}{opth xm:in(value)} set as minimum value of the {bf:xaxis} in the binscatterhist without histogram, it correctly positions a ygraph

{phang}{opth ym:in(value)} set as minimum value of the {bf:yaxis} in the binscatterhist without histogram, it correctly positions a xgraph

{phang}{opth xhistbarheight(value)} sets the height of the {bf:x} histogram as a percentage of the binscatterhist main area height; default is {bf:xhistbarheight(10)}

{phang}{opth yhistbarheight(value)} sets the height of the {bf:y} histogram as a percentage of the binscatterhist main area height; default is {bf:yhistbarheight(10)}

{phang}{opth xhistbarwidth(value)} sets the width of the {bf:x} histogram as a percentage; default is {bf:xhistbarwidth(100)}

{phang}{opth yhistbarwidth(value)} sets the width of the {bf:y} histogram as a percentage; default is {bf:xhistbarwidth(100)}

{phang}{opth xhistbins(#)} number of bins to be created; default is {bf:20}

{phang}{opth yhistbins(#)} number of bins to be created; default is {bf:20}


{phang} Following options require axis to be specified: x or y, e.g. xcolor() ycolor()

{phang}{opth axiscolor(colorstyle)} outline and fill color and opacity; default is {bf:teal%50} for xcolor and {bf:maroon%50} for ycolor{p_end}

{phang}{opth axisfcolor(colorstyle)} fill color and opacity

{phang}{opth axisfintensity(intensitystyle)} fill intensity

{phang}{opth axislcolor(colorstyle)} outline color and opacity

{phang}{opth axislwidth(linewidthstyle)} thickness of outline

{phang}{opth axislpattern(linepatternstyle)} outline pattern (solid, dashed, etc.)

{phang}{opth axislalign(linealignmentstyle)} outline alignment (inside, outside, center)

{phang}{opth axislstyle(linestyle)} overall look of outline

{phang}{opth axisbstyle(areastyle)} overall look of bar, all settings above

{phang}{opth axispstyle(pstyle)} overall plot style, including areastyle


{dlgtab:Save Output}

{phang}{opt savegraph(filename)} saves the graph to a file.  The format is automatically detected from the extension specified [ex: {bf:.gph .jpg .png}],
and either {cmd:graph save} or {cmd:graph export} is run.  If no file extension is specified {bf:.gph} is assumed.

{phang}{opt savedata(filename)} saves {it:filename}{bf:.csv} containing the binned scatterpoint data, and {it:filename}{bf:.do} which
loads the scatterpoint data, labels the variables, and plots the binscatterhist graph.

{pmore}Note that the saved result {bf:e(cmd)} provides an alternative way of capturing the binscatterhist graph and editing it.

{phang}{opt replace} specifies that files be overwritten if they alredy exist

{dlgtab:fastxtile options}

{phang}{opt nofastxtile} forces the use of {cmd:xtile} instead of {cmd:fastxtile} to compute bins.  There is no situation where this should
be necessary or useful.  The {cmd:fastxile} program generates identical results to {cmd:xtile}, but runs faster on large datasets, and has
additional options for random sampling which may be useful to increase speed.

{pmore}{cmd:fastxtile} is built into the {cmd:binscatterhist} code, but may also be installed
separately from SSC ({stata ssc install fastxtile:click here to install}) for use outside of {cmd:binscatterhist}.

{phang}{opth randvar(varname)} requests that {it:varname} be used to select a
sample of observations when computing the quantile boundaries.  Sampling increases
the speed of the binning procedure, but generates bins which are only approximately equal-sized
due to sampling error.  It is possible to omit this option and still perform random sampling from U[0,1]
as described below in {opt randcut()} and {opt randn()}.

{phang}{opt randcut(#)} specifies the upper bound on the variable contained
in {opt randvar(varname)}. Quantile boundaries are approximated using observations for which
{opt randvar()} <= #.  If no variable is specified in {opt randvar()},
a standard uniform random variable is generated. The default is {cmd:randcut(1)}.
This option cannot be combined with {opt randn()}.

{phang}{opt randn(#)} specifies an approximate number of observations to sample when
computing the quantile boundaries. Quantile boundaries are approximated using observations
for which a uniform random variable is <= #/N. The exact number of observations
sampled may therefore differ from #, but it equals # in expectation. When this option is
combined with {opth randvar(varname)}, {it:varname} ought to be distributed U[0,1].
Otherwise, a standard uniform random variable is generated. This option cannot be combined
with {opt randcut()}.


{marker examples1}{...}
{title:Examples of main features (Stepner, 2013)}

{pstd}Load the 1988 extract of the National Longitudinal Survey of Young Women and Mature Women.{p_end}
{phang2}. {stata sysuse nlsw88}{p_end}
{phang2}. {stata keep if inrange(age,35,44) & inrange(race,1,2)}{p_end}

{pstd}What is the relationship between job tenure and wages?{p_end}
{phang2}. {stata scatter wage tenure}{p_end}
{phang2}. {stata binscatterhist wage tenure}{p_end}

{pstd}The scatter was too crowded to be easily interpetable. The binscatterhist is cleaner, but a linear fit looks unreasonable.{p_end}

{pstd}Try a quadratic fit.{p_end}
{phang2}. {stata binscatterhist wage tenure, line(qfit)}{p_end}

{pstd}We can also plot a linear regression discontinuity.{p_end}
{phang2}. {stata binscatterhist wage tenure, rd(2.5)}{p_end}

{pstd} What is the relationship between age and wages?{p_end}
{phang2}. {stata scatter wage age}{p_end}
{phang2}. {stata binscatterhist wage age}{p_end}

{pstd} The binscatterhist is again much easier to interpret. (Note that {cmd:binscatterhist} automatically
used each age as a discrete bin, since there are fewer than 20 unique values.){p_end}

{pstd}How does the relationship vary by race?{p_end}
{phang2}. {stata binscatterhist wage age, by(race)}{p_end}

{pstd} The relationship between age and wages is very different for whites and blacks. But what if we control for occupation?{p_end}
{phang2}. {stata binscatterhist wage age, by(race) absorb(occupation)}{p_end}

{pstd} A very different picture emerges.  Let's label this graph nicely.{p_end}
{phang2}. {stata binscatterhist wage age, by(race) absorb(occupation) msymbols(O T) xtitle(Age) ytitle(Hourly Wage) legend(lab(1 White) lab(2 Black))}{p_end}

{marker examples2}{...}
{title:Examples of histogram features}

{pstd}Load the National Longitudinal Survey of Women 1988{p_end}
{phang2}. {stata webuse nlsw88, clear}{p_end}

{pstd}The basic binscatterhist works exactly as binscatter{p_end}
{phang2}. {stata binscatterhist wage tenure}{p_end}

{pstd}Let's add the distribution of the x variable tenure{p_end}
{phang2}. {stata binscatterhist wage tenure, histogram(tenure)}{p_end}

{pstd}The default position of the x graph is not pleasant, let's fix that and add both variables distribution this time{p_end}
{phang2}. {stata binscatterhist wage tenure, histogram(wage tenure) ymin(4)}{p_end}

{pstd}We want to experiment with the look, let's try a simpler look and a smaller width{p_end}
{phang2}. {stata binscatterhist wage tenure, histogram(wage tenure) ymin(4) yhistbarwidth(50) xhistbarwidth(50) ybstyle(outline) xbstyle(outline)}{p_end}

{pstd}Let's now try some further options: increasing number of bins and height of the x and y distribution{p_end}
{phang2}. {stata binscatterhist wage tenure, histogram(wage tenure) ymin(4) xhistbarheight(15) yhistbarheight(15) xhistbins(40) yhistbins(40)}{p_end}

{marker examples3}{...}
{title:Examples of further features}

{pstd}Let's report the estimation results, using robust standard errors and with grade fixed effects{p_end}
{phang2}. {stata binscatterhist wage tenure, absorb(grade) vce(robust) coef(0.01) sample xmin(-2.2) ymin(5) histogram(wage tenure)  xhistbarheight(15) yhistbarheight(15) xhistbins(40) yhistbins(40)}{p_end}

{pstd}Let's use now areg - therefore keeping singleton fixed effects. With a negative slope, the reported coefficient and sample adjust automatically their position{p_end}
{phang2}. {stata replace tenure=-tenure}{p_end}
{phang2}. {stata binscatterhist wage tenure, regtype(areg) absorb(grade) vce(robust) coef(0.01) sample xmin(-22) ymin(5) histogram(wage tenure)  xhistbarheight(15) yhistbarheight(15) xhistbins(40) yhistbins(40)}{p_end}

{marker saved_results}{...}
{title:Saved Results}

{pstd}
{cmd:binscatterhist} keeps in {cmd:e()} the info stored by reg/areg and in {cmd:r()}, the following info:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(graphcmd)}}twoway command used to generate graph, which does not depend on loaded data{p_end}
{p 30 30 2}Note: it is often important to reference this result using `"`{bf:e(graphcmd)}'"'
rather than {bf:r(graphcmd)} in order to avoid truncation due to Stata's character limit for strings.

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(byvalues)}}ordered list of by-values {it:(if numeric by-variable specified)}{p_end}
{synopt:{cmd:r(rdintervals)}}ordered list of rd intervals {it:(if rd specified)}{p_end}
{synopt:{cmd:r(y#_coefs)}}fit line coefficients for #th y-variable {it:(if lfit or qfit specified)}{p_end}


{marker author}{...}
{title:Author}

{pstd}Matteo Pinna{p_end}
{pstd}matteo.pinna@gess.ethz.ch{p_end}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd} The author would like to thank Elliott Ash, Chistopher Baum, Suresh Naidu, Sergio Galletta and Malka Guillot for the useful feedback on first versions of the program.

{pstd}The present version of {cmd:binscatterhist} is based on a program in Michael Stepner (2013): "BINSCATTER: Stata module to generate binned scatterplots" - https://EconPapers.repec.org/RePEc:boc:bocode:s457709 and Ben Jann (2014): "ADDPLOT: Stata module to add twoway plot objects to an existing twoway graph," Statistical Software Components S457917, Boston College Department of Economics, revised 28 Jan 2015 <https://ideas.repec.org/c/boc/bocode/s457917.html>
