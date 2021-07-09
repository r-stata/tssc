{smcl}
{* *! version 1.0.0  3may2010}{...}
{cmd:help reganat}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:reganat} {hline 2}}Graphical inspection of linear multivariate models{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:reganat}
{depvar}
{varlist}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt :{opth dis(varlist)}}graphs only the variables in {varlist} and omits the rest{p_end}
{synopt :{opt biline}}plots a regression line for the bivariate linear model{p_end}
{synopt :{opt biscat}}plots a scatterplot for the bivariate linear model{p_end}
{synopt :{opt reg}}displays the results for the estimation of the multivariate model{p_end}
{synopt :{opt nolegend}}prevents the legend to be displayed{p_end}
{synopt :{opt nocovlist}}prevents the list of covariates to be displayed{p_end}
{synopt :{opt scheme(scheme)}}specifies the graphical scheme{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2} {opt by} is not allowed.


{title:Description}

{pstd}
{cmd:reganat} is a graphical tool for inspecting the effect of a covariate on a dependent variable in the context of multivariate OLS estimation.
The name is an acronym for the expression {it:regression anatomy}, a result in OLS' algebra originally due to Frisch and  Waugh (1933)
and recently revived by Angrist and Pischke's {it:Mostly Harmless Econometrics} (2009).
In a bivariate regression model {it:Y = bx1 + g}, the graphical inspection of the scatterplot provides useful information on the relation between
the independent variable {it:x1} and the dependent variable {it:Y},
but can be highly misleading when the underlying {it:real} model is multivariate of the type {it:Y = X'B + e} where {it:X'} includes also {it:x1}.
In general, the OLS multivariate estimator is not equivalent to an OLS estimator obtained using a 
separate regression on each independent variable since correlation among independent variables must be accounted for.
Angrist and Pischke (2009) show that in a multivariable model, the regression parameter for a given regressor is
{it:the bivariate slope coefficient for the corresponding regressor after partialling out all other covariates}.
Accordingly, this command displays a table of scatterplots, with the dependent variable plotted against the independent variable net of any linear correlation with the other independent variables.
This combined graph can be helpful when inspecting the data for outliers, nonlinearities, and other modelling issues.{p_end}

{title:Options}

{dlgtab:Options}

{phang}{opth dis(varlist)} specifies that the sense only the covariates included in {varlist} will be plotted in the graph.
Nonetheless, the other variables still work as controls.

{phang}{opt biline} specifies that on the graph will also be displayed the fitted regression line for the linear model {it:Y = x1 + g},
where x1 is the variable of interest.

{phang}{opt biscat} specifies that on the graph will also be displayed the scatterplot for {it:(Y,x1)}, where x1 is the variable of interest.

{phang}{opt reg} displays the numerical results for the estimation of the multivariate model {it:Y = X'B + e}.

{phang}{opt nolegend} prevents the legend to be displayed.

{phang}{opt nocovlist} prevents the list of covariates to be displayed.

{phang}{opt scheme(graphical scheme)} can be used to specify the graphical scheme to be applied to the composite graph. By default, the command uses the {it:sj} scheme.

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}

{pstd}Obtain a combined graph of the effect of several regressors{p_end}
{phang2}{cmd:. reganat price length weight headroom mpg}{p_end}

{pstd}Obtain a combined graph of the effect of a subset of the regressors, along with scatterplots and fitted line for the univariate models{p_end}
{phang2}{cmd:. reganat price length weight headroom mpg, dis(weight length) biline}{p_end}

{title:References}

{p 4 8 2}
Angrist, J. and Pischke, J. S. (2009) {it:Mostly Harmless Econometrics}. Princeton University Press.

{p 4 8 2}
Frisch, R. and Waugh, F. W. (1933) Partial Time Regression as Compared with Individual Trends. {it:Econometrica} 1: 387-401.

{title:Acknowledgment}

{p 4 8 0}
The author wishes to express his deep gratitude to Joshua Angrist for a number of insights and advices which have greatly enhanced the scope and the reliability of this command. 

{title:Author}

{pstd}
Valerio Filoso, Department of Economics, University of Naples "Federico II", Italy.{break}
If you observe any problem, please {browse "mailto:filoso@unina.it"}.
