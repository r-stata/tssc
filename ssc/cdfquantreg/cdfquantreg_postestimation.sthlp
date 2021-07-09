{smcl}
{* *! version 1.0.0  14jul2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerdialog "predict for cdfquantreg" "dialog cdfquantreg_p"}{...}
{viewerjumpto "Syntax for predict" "cdfquantreg postestimation##syntax_predict"}{...}
{viewerjumpto "Options for predict" "cdfquantreg postestimation##options_predict"}{...}
{viewerjumpto "Examples for predict" "cdfquantreg postestimation##examples_predict"}{...}
{viewerjumpto "margins for cdfquantreg" "cdfquantreg##margins"}{...}
{viewerjumpto "Examples" "cdfquantreg_p##examples"}{...}
{viewerjumpto "Author" "cdfquantreg##author"}{...}
{viewerjumpto "References" "cdfquantreg##references"}{...}
{title:Title}

{phang}
{bf:cdfquantreg_p} {hline 2} Postestimation tools for cdfquantreg

{marker description}{...}
{title:Description}

{pstd}
The following postestimation commands are available after {cmd:cdfquantreg}:
 
{synoptset 17 notes}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
INCLUDE help post_estatsum
INCLUDE help post_estatvce
INCLUDE help post_estimates
{synopt :{helpb cdfquantreg postestimation##margins:margins}}margins commands for cdfquantreg {p_end}
{synopt :{helpb cdfquantreg postestimation##predict:predict}}predictions, residuals {p_end}
{synoptline}
{p2colreset}{...}
{phang}

{marker syntax_predict}{...}
{marker predict}{...}
{title:Syntax for predict}

{cmd:predict} {newvar} {ifin} [{cmd:,} [{opt stdp}{c |}{opt qtile}{c |}{opt pctle(real #)}]]

{synoptset 17 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt xb}}linear prediction of the location parameter; the default{p_end}
{synopt :{opt xd}}linear prediction of the dispersion parameter; the default{p_end}
{synopt :{opt seb}}standard error of the location linear prediction{p_end}
{synopt :{opt sed}}standard error of the dispersion linear prediction{p_end}
{synopt :{opt qtile}}either the empirical or requested quantile rank{p_end}
{synopt :{opt fitted}}fitted observations corresponding to {opt qtile}{p_end}
{synopt :{opt residuals}}differences between {opt fitted} and y{p_end}
{synoptline}
{p2colreset}{...}
INCLUDE help esample

{marker options_predict}{...}
{title:Options for predict}

{dlgtab:Main}

{phang}{opt stdp} calculates the standard errors of the linear predictions for 
both the location and dispersion submodels.

{phang}{opt qtile} calculates fitted values for the dependent variable, either 
corresponding to the quantile rank of each observation or (in combination with 
{opt pctle(#)}) corresponding to a specified quantile rank.

{phang}{opt pctle(#)} is allowed only in combination with {opt qtile}, and specifies 
the quantile that {cmd:predict} is to estimate. It expects a number in the 
(0,1) interval.  To estimate the median, for instance, # would be set to 0.5.

{marker examples_predict}{...}
{title:Examples for predict}

{phang}{cmd:/* This example uses testmat1.dta */}{p_end}

{phang}{cmd:. cdfquantreg y i.d1##i.d2, cdf(t2) quantile(t2) zvarlist(d1 d2)}{p_end}

{phang}{cmd:. predict newvar, qtile}{p_end}

{phang}{cmd:. drop newvar xd fitted residuals}{p_end}

{phang}{cmd:. predict newvar, qtile pctle(0.5)}{p_end}

{marker margins}{...}
{title:Margins}

{pstd}
The {cmd: margins} command requires specifying which equation is to be estimated. 
Thus, {cmd:equation(}{it:1}{cmd:)} refers to the location submodel and {cmd:equation(}{it:2}{cmd:)} 
refers to the dispersion submodel. Examples of appropriate syntax are:{p_end}
{cmd:margins} {varname} {cmd:, predict(equation(}{it:eqno}{cmd:))}
{cmd:margins} {cmd:dydx(}{varname}{cmd:)} {cmd:, predict(equation(}{it:eqno}{cmd:))}

{marker examples_margins}{...}
{title:Examples for margins}

{phang}{cmd:/* This example uses testmat1.dta */}{p_end}

{phang}{cmd:. cdfquantreg y i.d1##i.d2, cdf(t2) quantile(t2) zvarlist(d1 d2)}{p_end}

{phang}{cmd:. margins d2, predict(equation(#1))}{p_end}

{phang}{cmd:. margins,  dydx(1.d2)  predict(equation(#1))}{p_end}

{phang}{cmd:. margins d2, expression(exp(predict(equation(#2))))}{p_end}

{marker author}{...}
{title:Author}

{pstd}
Michael Smithson, Research School of Psychology, The Australian National University, 
Canberra, A.C.T. Australia{break}Michael.Smithson@anu.edu.au

{marker references}{...}
{title:References}

{p 4 4 2}
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling random 
variables on the unit interval. {it:British Journal of Mathematical and Statistical Psychology}, 70(3), 412-438.

{p 4 4 2}
Shou, Y. & Smithson, M. (2019). cdfquantreg: An R package for 
CDF-Quantile Regression. {it:Journal of Statistical Software}, 88, 1-30. 

