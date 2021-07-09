{smcl}
{* *! version 1.0  November2012}{...}
{hline}
{vieweralsosee "spmlreg" "help spmlreg"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "estat" "help estat"}{...}
{vieweralsosee "" "--"}{...}
{cmd: Help for spmlreg postestimation}
{hline}


{title:Title}

{p 4 16 2}
{cmd:spmlreg postestimation} {hline 2} Postestimation tools for spmlreg{p_end}


{marker description}{title:Description}

{pstd}
{cmd:spmlreg} allows the following postestimation commands:

{synoptset 13 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_estat
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{synopt :{helpb spmlreg postestimation##predict:predict}}predicted values{p_end}
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}

{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {stub* | {newvar} | {help newvarlist}} {ifin} [{cmd:,} {it:statistic}]

{synoptset 28 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt xb(redform|naive)}}predicted values based on reduced-form or observed values of {bf:y}; default is xb(naive){p_end}
{synopt :{opt resid:uals}}residuals based on observed values of {bf:y}{p_end}
{synopt :{opt sc:ore}}request equation-level score variables{p_end}
{synopt :{opt replace}}overwrite existing variables{p_end}
{synoptline}
{p2colreset}{...}

{marker option}{title:Options for predict}

{dlgtab:Main}

{phang}
{opt xb(reform|naive)} requests that predicted values be calculated. Specifying {bf:xb(redform)} generates predicted values
 based on the reduced-form equation, {bf:y} = ({bf:I}-{it:rho}*{bf:W})^(-1)*{bf:X}*{bf:b}. When {bf:xb(naive)} is specified, 
 predicted values are generated based on the observed values of {bf:y}: {it:rho}*{bf:W}*{bf:y} + {bf:X}*{bf:b}.

{phang}
{opt residuals} requests that residuals be calculated. Calculations are based on observed values of {bf:y}:

{pmore}{bf:e} = {bf:y} - {it:rho}*{bf:W}*{bf:y} + {bf:X}*{bf:b} + {bf:u}{p_end}

{phang}
{opt score} calculates equation-level score variables. If {opt score} is specified without {opt stub*} only a variable 
containing the first derivative of the log likelihood with respect to the linear prediction based on the observed values 
of {bf:y} will be calculated. Otherwise, depending on the spatial model estimated, new variables containing the derivative of the log likelihood with respect to rho, 
lambda, and sigma will also be calculated.

{phang}
{opt replace} overwrites existing {newvar}.

{marker examples}{dlgtab:Examples}

{phang}
Load the Columbus crime dataset

{pmore}{stata "use http://fmwww.bc.edu/repec/bocode/c/columbus_dataset, clear" :. use http://fmwww.bc.edu/repec/bocode/c/columbus_dataset, clear} 

{phang}
Import the first order contiguity spatial weights matrix, columbus.gal, created in GeoDa

{pmore}{stata "spwmatrix import using http://fmwww.bc.edu/repec/bocode/c/columbus.gal, wn(W) eignvar(eigvarW) rowstand mataf" :. spwmatrix import using http://fmwww.bc.edu/repec/bocode/c/columbus.gal, wn(W) eignvar(eigvarW) row mataf}{p_end}

{synoptline}

{phang} 
1) Obtain predictions and total impact after the spatial lag model 

{pmore}{stata "spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(lag)" :. spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(lag)}{p_end}

{pmore}a) Predictions based on reduced form{p_end}

{pmore}{stata "predict yp, xb(redform)" :. predict yp, xb(redform)}{p_end}

{pmore}b) Total impact

{pmore}{stata "nlcom (inc: _b[inc]*(1/(1-[rho]_cons))) (hoval: _b[hoval]*(1/(1-[rho]_cons)))" : . nlcom (inc: _b[inc]*(1/(1-[rho]_cons))) (hoval: _b[hoval]*(1/(1-[rho]_cons)))}{p_end}

{synoptline}


{phang}
2) Obtain Linear predictions and information criteria after the spatial error model 

{pmore}{stata "spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(error)" :. spmlreg crime inc hoval, weights(W) wfrom(Mata) eignvar(eigvarW) model(error)}{p_end}

{pmore}{stata "predict yp, replace" :. predict yp, replace}{p_end}

{pmore}{stata "estat ic" :. estat ic}{p_end}

{synoptline}


{marker author}{title:Author}

{p 4 4 2}{hi: P. Wilner Jeanty}, Rice University 
	   
{p 4 4 2}Email to {browse "mailto:pwjeanty@rice.edu":pwjeanty@rice.edu}


{marker citation}{title:Citation}

Users should please cite {cmd:spmlreg} as follows:

Jeanty, P.W., 2010. {cmd:spmlreg}: Stata module to estimate the spatial lag, the spatial error, the spatial durbin, and the general spatial models.



