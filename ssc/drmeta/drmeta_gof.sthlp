{smcl}
{* 18sep2018 Orsini N}{...}
{hline}

{title:Title}

{p2colset 6 20 20 2}{...}
{p2col :{hi: drmeta_gof} {hline 2}}Goodness-of-fit after dose-response meta-analysis{p_end}
{p2colreset}{...}

{title:Syntax for predict}

{p 8 16 2}
{cmd:drmeta_gof} [ {cmd:,} {opt r2s} {opt opvd:plot(dosevar, [xb|xbs|fitted])} {opt drvd:plot(dosevar)} {opt dovp:plot} {it:{help twoway_options:twoway_options}} ]

{title:Description}

{pstd} The {cmd:drmeta_gof} command provides tools (deviance test, R-squared)
to evaluate the goodness-of-fit in dose-response meta-analysis. 
It is a post-estimation tool of the {helpb drmeta:drmeta} command.{p_end}

{title:Options}

{phang}
{opt r2s} shows study-specific coefficient of determination (R-squared).

{phang}
{opt opvd:plot(dosevar, [xb|xbs|fitted])} plots the observed and specified predicted values vs the specified dose. 
The default is to use study-specific predictions using generalized least squares (xbs). 
See {helpb drmeta_predict:drmeta_predict}.

{phang}
{opt drvd:plot(dosevar)} plots the decorrelated residuals vs the specified dose. 

{phang}
{opt dovp:plot} plots decorrelated observed contrasts vs predicted contrasts.
 
{title:Examples}

* Read data from 7 simulated studies with a common underlying linear dose-response relationship. 
* The true value of the slope is 0.1 (RR=1.11).    

{stata "use http://www.stats4life.se/data/table1sim.dta, clear"}
 
* One-stage random-effects dose-response model assuming a linear trend

{stata "drmeta logor  dose ,  se(selogor)  data(n case)  id(id) type(study)  reml"} 
{stata "drmeta_gof"}
{stata "drmeta_gof, r2s"}
{stata "drmeta_gof, opvd(dose)"}
{stata "drmeta_gof, opvd(dose, fitted)"}
{stata "drmeta_gof, dovp"}

* One-stage random-effects dose-response model using restricted cubic splines

{stata "mkspline doses = dose, nk(3) cubic"}
{stata "drmeta logor  doses1 doses2 ,  se(selogor)  data(n case)  id(id) type(study)  reml"} 
{stata "drmeta_gof, r2s"}
{stata "drmeta_gof, drvd(dose)"}
{stata "drmeta_gof, opvd(dose)"}
{stata "drmeta_gof, dovp"}

{title:Reference}

{p 4 8 2}Discacciati A, Crippa A, Orsini N. Goodness of fit tools for dose-response meta-analysis of binary outcomes. {it:Research Synthesis Methods}. 2017 Jun;8(2):149-160.{p_end}

{title:Author}

{p 4 8 2}Nicola Orsini, Biostatistics Team,
Department of Public Health Sciences, Karolinska Institutet, Sweden{p_end}

{title:Support}

{p 4 8 2}{browse "http://www.stats4life.se"}{p_end}
{p 4 8 2}{browse "mailto:nicola.orsini@ki.se?subject=drmeta_gof":nicola.orsini@ki.se}{p_end}

{p 7 14 2}Help: {helpb drmeta}{p_end}
