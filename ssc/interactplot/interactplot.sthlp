{smcl}
{* 24jun2018}{...}
{hi:help interactplot}
{hline}

{title:Title}

{phang}
{bf:interactplot} {hline 2} Generate plots for interaction terms of multiplicative regressions


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:interactplot}
[{cmd:,} {it:options}]

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth fy:size(relativesize)}}relative size of subplot{p_end}
{synopt:{opth l:evel(cilevel)}}specify confidence interval{p_end}
{synopt:{opt name(name[, replace])}}specify name for graph{p_end}
{synopt:{opt rev:erse}}interchange xvar1 and xvar2{p_end}
{synopt:{opt t:erm(#)}}specify which interaction term is used{p_end}

{syntab:General Appearance}
{synopt:{opt int:ersteps(#)}}enter number of steps for calculation of margins{p_end}
{synopt:{opth sch:eme(scheme)}}set scheme for graph{p_end}
{synopt:{opth yline(#)}}include horizontal line for y-axis{p_end}
{synopt:{opt xlab:num(#)}}enter number of major ticks for x-axis in margins plot and subplot{p_end}
{synopt:{opt ylab:num(#)}}enter number of major ticks for y-axis in margins plot{p_end}

{synoptline}

{syntab:Graph of an interaction containing at least one factor variable}

{synopt:{opt byplot}}show separate plots for factors/indicators{p_end}

{synoptline}

{syntab:Graph of an interaction of two continuous variables}

{synopt:{opt add:scatter(string)}}add scatterplot to marginsplot; predicted values (predict) or observed values (observed){p_end}
{synopt:{opt cme}}estimate conditional marginal effect of moderator variable{p_end}
{synopt:{opt sub:plot(string)}}specify type of subplot (hist or kdens){p_end}


{syntab:Histogram appearance}
{synopt:{opt bars(#)}}enter number of bars{p_end}

{syntab:Kernel density plot appearance}
{synopt:{opt kernel(function)}}enter kernel function{p_end}
{synopt:{opt kda:rea}}recast kernel density plot line as area{p_end}
{synopt:{opt fint:ensity(#)}}specify filling intensity of area{p_end}

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:interactplot} is a tool for generating plots of predicted values or marginal effects for polynomials or interaction terms after a multiplicative regression.
The program detects multiplicative terms within the last estimated regression model, automatically calculates statistics calculated from predictions and automatically generates a combined graph.
That combined graph contains 1) a adjusted predictions or conditional marginal effect plot and 2) a subplot with the frequency/density of the predictor variable.
By default, the first variable in the multiplicative term is treated as the main variable and the second variable is treated as the moderator variable.
Since both variables are mathematically indistinguishable, this distinction is a theoretical one and has to be carried out by the researcher (Brambor et al. 2005; Lohmann 2015).

{phang}Since Stata can distinguish between factor variables and continuous variables, four possible combinations of effect variable and moderator variable can be realised. The default plots and their characteristics are listed below:{p_end}

{phang}1. {it: Factor # factor}{p_end}
{pmore}{bf: Default}: predicted values (main) with stacked bar plot (subplot){p_end}
{pmore}{bf: Byplot}: separate plots for each category of the moderator variable{p_end}

{phang}2. {it: Factor # continuous}{p_end}
{pmore}{bf: Default}: predicted values (main) over range of continuous variable with overlaid density plots (subplot){p_end}
{pmore}{bf: Byplot}: separate plots over range of continuous variable for each category of the factor variable{p_end}

{phang}3. {it: Continuous # factor}{p_end}
{pmore}{bf: Default}: predicted values (main) for categories of factor variable with stacked bar plot (subplot){p_end}
{pmore}{bf: Byplot}: separate plots for categories of factor variable {p_end}
{pmore}{bf: cme}: conditional marginal effects plot of effect variable with derivatives of the response with respect to moderator variable{p_end}


{phang}4. {it: Continuous # continuous}{p_end}
{pmore}{bf: Default}: predicted values (main) of effect variable with density plot (subplot){p_end}
{pmore}{bf: cme}: conditional marginal effects plot of effect variable with derivatives of the response with respect to moderator variable{p_end}

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}{opt byplot} show separate plots for factor/indicator variables. This option can exclusively be applied to interactions containing at least one factor variable.{p_end}

{phang}{opth fy:size(relativesize)} specifies the relative size of the subplot to the marginsplot in percent. The default value is 25.{p_end}

{phang}{opth l:evel(cilevel)} specifies the confidence interval. The default value is set in Stata and can be changed with {help set level}.{p_end}

{phang}{opt name(name[, replace])}} specify name for combined graph and optionally replace it.{p_end}

{phang}{opt rev:erse} interchange the order of the variables within the specified interaction term. The second variable is treated as effect variable and the first variable is treated as moderator variable.{p_end}

{phang}{opt t:erm(#)} specify which interaction term should be used. By default, the first interaction term that occurs in the last estimated model is used.{p_end}

{dlgtab:General appearance}

{phang}{opt int:ersteps(#)} enter number of steps for calculation of margins. Change this option if you want the lines and curves in the plots to be more rough or fine-grained. The default value is 30.{p_end}

{phang}{opth sch:eme(scheme)} set scheme for graph. You can permanently change your graph style with {help set scheme}.{p_end}

{phang}{opt yline(#)}} include horizontal line for y-axis to easier identfiy the treshold at which an effect gets significant. In conditional marginal effect plots, this is usually the value of zero.{p_end}

{phang}{opt xlab:num(#)} enter number of major ticks for abscissa (x-axis) in margins plot and subplot. Changing this parameter helps with loosing empty areas within in the plot area. The default value is 5.{p_end}

{phang}{opt ylab:num(#)} enter number of major ticks for ordinate (y-axis) in margins plot. Changing this parameter helps with loosing empty areas within in the plot area. The default value is 5.{p_end}

{dlgtab:One/two factor variables}

{phang}{opt byplot} show separate plots for factors/indicators. The corresponding number of subgraphs will be drawn, depending on much categories a variable has.{p_end}

{dlgtab:Two continuous variables}

{phang}{opt add:scatter(string)} add scatterplot to marginsplot. Additional plot can either display predicted values ({bf:predict}) or observed values ({bf:observed}) of the dependent variable.{p_end}

{phang}{opt cme} estimate conditional marginal effect of moderator variable. This is identical to use the dydx()-option for the moderator variable in the {cmd: margins} command.{p_end}

{phang}{opt sub:plot(string)} specify if the subplot is a {help histogram} ({bf:hist}) or a {help kdensity} ({bf:kdens}) plot.{p_end}

{phang}{opt bars(#)} if a histogram is specified, enter the number of bars it should contain. The default value is 100.{p_end}

{phang}{opt kernel(function)} enter kernel function for kernel density plot. For possible inputs, see {help kdensity##kernel}. The default kernel function being used is {opt epanechnikov}.{p_end}

{phang}{opt kda:rea} recast kernel density plot line as an area plot.{p_end}

{phang}{opt fint:ensity(#)} specify filling intensity of area plot in percent. The default value is 90.{p_end}


{marker Remarks}{...}
{title:Remarks}

{pstd}
For {cmd: interactplot} to properly work, the package {cmd: catplot} has to be installed.
This can be done with {stata ssc install catplot}.
{cmd: interactplot} does not work properly if you use prefixes other than {bf: i.} or {bf: c.}, i.e. the capitalized variants {bf:I.} or {bf:C.}, and other coding-related prefixes.
The program can handle simple time-series operators ({bf:l., L., d., D., L1., L2.}, etc.), however, more complex constructs (e.g. DL(1/4).xvar) can lead to erroneous output.
In such cases it is therefore necessary to generate the lagged or differenced instances of the variables beforehand and run the regression model with the newly generated variables in a second step before executing {cmd: interactplot}.
{p_end}

{marker examples}{...}
{title:Examples}

{phang}{it: 1st example: Factor x factor (i.xvar1#i.xvar2)}

	Load dataset
	{cmd:. }{stata sysuse auto, clear}

	Estimate model
	{cmd:. }{stata regress mpg i.foreign i.rep78 price weight i.foreign#i.rep78}

	Overlaid plot
	{cmd:. }{stata interactplot}

	By-plot
	{cmd:. }{stata interactplot, byplot}

{phang}{it: 2nd example: Factor x Continuous (i.xvar1#c.xvar2)}

	Load dataset
	{cmd:. }{stata sysuse auto, clear}

	Estimate model
	{cmd:. }{stata regress mpg i.foreign i.rep78 price weight i.foreign#c.price}

	Overlaid plot
	{cmd:. }{stata interactplot}

	By-plot
	{cmd:. }{stata interactplot, byplot}

{phang}{it: 3rd example: Continuous x factor (c.xvar1#i.xvar2)}

	Load dataset
	{cmd:. }{stata sysuse auto, clear}

	Estimate model
	{cmd:. }{stata regress mpg i.foreign i.rep78 price weight c.price#i.foreign}

	Overlaid plot
	{cmd:. }{stata interactplot}

	Conditional marginal effect plot
	{cmd:. }{stata interactplot, cme}

	Conditional marginal effect plot and by-plot
	{cmd:. }{stata interactplot, cme byplot}

{phang}{it: 4th example: Continuous x continuous (c.xvar1#c.var2)}

	Load dataset
	{cmd:. }{stata sysuse auto, clear}

	Estimate model
	{cmd:. }{stata regress price c.mpg c.weight c.mpg#c.weight}

	Plot conditional marginal effect
	{cmd:. }{stata interactplot, cme}

	Plot conditional marginal effect with interchanged moderator variable
	{cmd:. }{stata interactplot, cme reverse}

	Plot linear prediction with observed values
	{cmd:. }{stata interactplot, addscatter(observed)}

	Plot linear prediction with predicted values
	{cmd:. }{stata interactplot, addscatter(predict)}

{phang}{ul:Additional examples}

{phang}A1: Estimate model with multiple interaction terms

	Load dataset
	{cmd:. }{stata sysuse auto, clear}

	Estimate model
	{cmd:. }{stata regress price c.weight i.foreign c.weight#c.weight i.foreign#c.weight}

	Plots for interaction terms
	{cmd:. }{stata interactplot, term(1) name(term1, replace)}

	{cmd:. }{stata interactplot, term(2) name(term2, replace)}


{phang}A2: Estimate model with 3rd order polynomial and interaction with factor variable

	Load dataset
	{cmd:. }{stata sysuse auto, clear}

	Estimate model
	{cmd:. }{stata regress length c.turn i.foreign c.turn#c.turn c.turn#c.turn#c.turn i.foreign#c.turn}

	Plot cubic prediction for categories
	{cmd:. }{stata interactplot, term(3)}

{phang}A3: Estimate model with variable prefixes and regression command options

	Load dataset
	{cmd:. }{stata webuse grunfeld, clear}

	Estimate model
	{cmd:. }{stata xtpcse D1.invest c.D1.mvalue c.D1.kstock c.D1.mvalue#c.D1.kstock, corr(ar1)}

	Plot conditional marginal effects
	{cmd:. }{stata interactplot, cme}

{pstd}

{marker References}{...}
{title:References}

{phang}Brambor, T., Clark, W. R., & Golder, M. (2006). Understanding interaction models: Improving empirical analyses. Political analysis, 14(1), 63–82. doi:10.1093/pan/mpi014{p_end}

{phang}Lohmann, H. (2015). Non-linear and non-additive effects in linear regression. In: Best, H., & Wolf, C. (eds.). The SAGE Handbook of Regression Analysis and Causal Inference. 1st edition, Sage. Part II, Chapter 6, pp. 111–132.{p_end}

{marker Author}{...}
{title:Author}

{phang}Jan Helmdag, Department of Political Science, University of Greifswald, Germany
