{smcl}
{* 11sep2018 Orsini N}{...}
{hline}

{title:Title}

{p2colset 6 20 20 2}{...}
{p2col :{hi: predict} {hline 2}}Obtaining predictions after {cmd:drmeta} command for dose-response meta-analysis{p_end}
{p2colreset}{...}

{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {it:stubname} [ {cmd:,} {it:statistic} ]

{synoptset 18 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt xb}}linear prediction for the fixed portion of the model only; the default{p_end}
{synopt :{opt xbs}}linear prediction using study-specific coefficient vector{p_end}
{synopt :{opt fit:ted}}fitted values, fixed-portion linear prediction plus
contributions based on predicted random effects{p_end}
{synopt :{opt ref:fects}}predicted BLUPs of random effects{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd} The {cmd:predict} command after {cmd:drmeta}  creates a new variable containing the requested predictions using
study-specific reference values.{p_end}

{title:Options}

{phang}
{opt xb} linear prediction for the fixed portion of the model only.

{phang}
{opt xbs} linear prediction using study-specific coefficient vector estimated using generalized least squares; the default. 

{phang}
{opt fitted} fitted values, fixed-portion linear prediction plus contributions based on predicted random effects.

{phang}
{opt ref:fects} predicted BLUPs of random effects.

{title:Examples}

* Read data about alcohol consumption and colorectal cancer risk (Orsini et al. AJE 1992)
 
{stata "use http://www.stats4life.se/data/ex_alcohol_crc.dta, clear"}
 
* Model 1. One-stage random-effects dose-response model assuming a linear trend

{stata "drmeta logrr dose , data(peryears cases) id(study) type(type) se(se) reml"} 

* Prediction 1. Store the  predicted contrasts using the GLS estimates obtained within each study

{stata "predict fit_xbs, xbs"}

* Prediction 2. Store the predicted contrasts using the estimated fixed-effects

{stata "predict fit_xb, xb"}
 
* Prediction 3. Store the predicted contrasts using the estimated fixed-effects plus the random-effects

{stata "predict fit_fitted, fitted"}

* Prediction 4. Store the predicted BLUPs of random-effects

{stata "predict fit_blup, reffect"}

* Examine predicted values 

{stata `"list study dose logrr fit_xb fit_xbs fit_fitted , sepby(study)"'}

* Graphical comparison of dose-response curves estimated separately within each study (xbs) and with random-effects model (fitted)

{stata `"twoway (scatter fit_xbs dose, sort c(ascending) lc(red)) (line fit_fitted dose, sort c(ascending) lc(blue)) , by(study, legend(off))"'}

* Model 2. One-stage random-effects dose-response model using restricted cubic splines

{stata "mkspline doses = dose, nk(3) cubic"}
{stata "drmeta logrr doses1 doses2 , data(peryears cases) id(study) type(type) se(se) reml"} 

* Prediction 1. Store the  predicted contrasts using the GLS estimates obtained within each study

{stata "predict fit2_xbs, xbs"}

* Prediction 2. Store the predicted contrasts using the estimated fixed-effects

{stata "predict fit2_fitted, fitted"}

* Graphical comparison of dose-response curves estimated separately within each study (xbs) and with random-effects model (fitted)
 
{stata `"twoway (line fit2_xbs dose, sort lc(red)) (line fit2_fitted dose, sort lc(blue)) , by(study, legend(off))"'}

{title:Author}

{p 4 8 2}Nicola Orsini, Biostatistics Team,
Department of Public Health Sciences, Karolinska Institutet, Sweden{p_end}

{title:Support}

{p 4 8 2}{browse "http://www.stats4life.se"}{p_end}
{p 4 8 2}{browse "mailto:nicola.orsini@ki.se?subject=drmeta_predict":nicola.orsini@ki.se}{p_end}

{p 7 14 2}Help: {helpb drmeta}{p_end}
