{smcl}
{* 4may19 Orsini N}{...}
{hline}

{title:Title}

{p2colset 6 24 24 2}{...}
{p2col :{hi: drmeta_graph} {hline 2}}Plot the estimated dose-response meta-analysis model{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 20 2}
{cmd:drmeta_graph} [ {cmd:,} {opt d:ose(numlist)} {opt r:ef(#)}  
{opt eq:uation(string)}  {opt matk:nots(matname)} {opt k:nots(numlist)} {opt blup} {opt gls} {opt level(#)} {opt eform} 
{opt scatter} {opt list} {opt addplot:(string)} {opt plotopts(string)} {it:twoway_options} ] 

{title:Description}

{pstd} The {cmd:drmeta_graph} command greatly facilitates the visualization of the estimated dose-response model. 
It is a postestimation of the {cmd:drmeta} command. 
{cmd:drmeta_graph} plots the average dose-response relationship together with confidence intervals upon 
indication of a list of dose/exposure values, a referent, and the types of transformations used
to model the quantitative predictor. It is particularly convenient when modelling the dose
with splines.{p_end}

{title:Options}

{phang}
{opt matk:nots(matname)} specifies the matrix of knots used to create restricted cubic splines. 
This can be easily obtained from the saved results of the {cmd:mkspline} command.

{phang}{opt k:nots(numlist)} specifies a list knots used to create the restricted cubic splines. 
It is an alternative to the option {opt matk:nots(matname)}.

{phang}
{opt d:ose(numlist)} specifies the values of the dose at which estimate differences in predicted responses.

{phang}
{opt r:ef(#)} specifies the reference value of the dose (not necessarily included in {opt d:ose(numlist)}). 

{phang}
{opt eq:uation(string)} specifies the mathematical transformations of the dose {it:d} used in the previously fitted 
dose-response model. It is relevant only if the options {opt matknots(matname)} or {opt knots(numlist)} has not been specified. 
Example 1: equation(d) means that the dose was modelled assuming 
a linear function. Example 2: equation(d d^2) means that the dose was modelled with a quadratic function. 
Example 3: eq(d ln(d)) means that the dose was modelled with {it:d} and the natural logarithm of {it:d}. 

{phang}
{opt addplot:(string)} specifies the equation of the model to be plotted in terms of the dose {it:d}. 
It can be useful to overlay a line/curve on the graph of the previously fitted model. 
Example 1: previously fit a spline model and wanted to add a line addplot({it:b1}*(d-10)), 
representing the change in predicted outcome relative to the dose value of 10 according to 
a linear function. 
Example 2: previously fit a linear-response model and wanted to add a curve addplot({it:b1}*(d-10)+{it:b2}*(d^2-100)), 
representing the change in predicted outcome relative to the dose value of 10 according
to a quadratic function. 

{phang}
{opt plotopts(string)} controls the {help line} options affecting the added plot with the option {opt addplot:(string)}.

{phang}
{opt blup} shows conditional study-specific lines arising from the
estimated random-effects model (Best Linear Unbiased Prediction). 

{phang}
{opt gls} shows study-specific lines estimated separately using Generalized Least Squares.

{phang}
{opt eform} exponentiate the estimated differences in predicted responses. 

{phang}
{opt list} list the estimated differences in predicted responses. 

{phang}
{opt scatter} shows a scatter plot rather than a line plot (default). 
 
{phang}
{cmdab:f:ormat(%}{it:fmt}{cmd:)} specifies the display format for presenting numbers.
{cmd:format(%3.2f)} is the default; see help {help format}.{p_end}

{phang}
{opt level(#)}  specifies a confidence level to use for confidence 
intervals. The default is 95%. See help on {help level}.

{title:Examples}

* Read data about alcohol consumption and colorectal cancer risk (Orsini et al. AJE 1992)
 
{stata "use http://www.stats4life.se/data/ex_alcohol_crc.dta, clear"}
 
* Model 1. One-stage random-effects dose-response model assuming a linear trend

{stata "drmeta logrr dose , data(peryears cases) id(study) type(type) se(se) reml"} 

/* Graph the colorectal cancer relative risk as linear function of alcohol consumption 
ranging from 0 to 60 (step by 1) grams/day using 10 grams/day as referent. */

{stata "drmeta_graph , dose(0(1)60) ref(10) equation(d) list eform"}

* Model 2. One-stage random-effects dose-response model assuming a quadratic trend

{stata "gen dosesq = dose^2"} 
{stata "drmeta logrr dose dosesq, data(peryears cases)id(study) type(type) se(se) reml"} 

/* Graph the colorectal cancer relative risk as quadratic function of alcohol consumption 
ranging from 0 to 60 (step by 1) grams/day using 10 grams/day as referent. */

{stata "drmeta_graph , dose(0(1)60) ref(10) equation(d d^2) eform"}

* Overlay the linear trend with the previously fit quadratic trend

{stata "drmeta_graph , dose(0(1)60) ref(10) equation(d d^2) addplot(.0064376*(d-10)) plotopts(lc(red) lw(thick)) eform"}

* Model 3. One-stage random-effects dose-response model using restricted cubic splines
	
{stata "mkspline doses = dose, nk(3) cubic"}
{stata "mat knots = r(knots)"}
{stata "drmeta logrr doses1 doses2 , data(peryears cases) id(study) type(type) se(se) reml"} 

/* Graph the colorectal cancer relative risk as function of alcohol consumption 
ranging from 0 to 60 (step by 1) grams/day using 10 grams/day as referent. 
Passing the matrix of knots allows the command to reconstruct the restricted cubic splines 
at the specified values.*/
	
{stata "drmeta_graph , dose(0(1)60) ref(10) matk(knots) eform"}

* Improve the graph specifying common -twoway- options

{stata `"drmeta_graph , dose(0(1)60) ref(10) matk(knots) eform ytitle("Relative Risk") xtitle("Alcohol consumption, grams/day")"'}

* Add conditional study-specific lines (BLUP)

{stata `"drmeta_graph , dose(0(1)60) ref(10) matk(knots) blup eform ytitle("Relative Risk") xtitle("Alcohol consumption, grams/day")"'}

* Add study-specific lines estimated separately within each study using GLS 

{stata `"drmeta_graph , dose(0(1)60) ref(10) matk(knots) gls eform ytitle("Relative Risk") xtitle("Alcohol consumption, grams/day")"'}

* Overlay the quadratic trend with the previously fit spline model

{stata `"drmeta_graph , dose(0(1)60) ref(10) matk(knots) ytitle("Relative Risk") xtitle("Alcohol consumption, grams/day") addplot(-.0015682*(d-10)+.0001636*(d^2-100)) plotopts(lc(red) lw(thick)) eform"'}

* Shows a scatter plot rather than a line plot

{stata `"drmeta_graph , dose(0(5)60) ref(10) matk(knots) xlabel(0(5)60, grid) yline(1, lp(-)) ytitle("Relative Risk") xtitle("Alcohol consumption, grams/day") scatter eform"'}

{title:Author}

{p 4 8 2}Nicola Orsini, Biostatistics Team,
Department of Public Health Sciences, Karolinska Institutet, Sweden{p_end}

{title:Support}

{p 4 8 2}{browse "http://www.stats4life.se"}{p_end}
{p 4 8 2}{browse "mailto:nicola.orsini@ki.se?subject=drmeta_graph":nicola.orsini@ki.se}{p_end}

{p 7 14 2}Help: {helpb drmeta}{p_end}
