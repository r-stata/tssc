{smcl}
{* *! version 1.0.0  14jul2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerdialog "predict for cdfquantreg" "dialog cdfquantreg_m"}{...}
{viewerjumpto "Syntax for cdfquantreg_m" "cdfquantreg_m##syntax_cdfquantreg_m"}{...}
{viewerjumpto "Options for cdfquantreg_m" "cdfquantreg_m##options_cdfquantreg_m"}{...}
{viewerjumpto "Examples" "examples_cdfquantreg_m##examples"}{...}
{viewerjumpto "Author" "cdfquantreg##author"}{...}
{viewerjumpto "References" "cdfquantreg##references"}{...}
{title:Title}

{phang}
{bf:cdfquantreg_m} {hline 2} Marginal effects conversion for cdfquantreg

{marker description}{...}
{title:Description}

{pstd}
The following alternative to the {cmd :{helpb cdfquantreg postestimation##margins:margins}} command 
is available after {cmd:cdfquantreg}: {cmd:cdfquantreg_m}.  This command reports 
marginal effects for the location and dispersion parameters, and converts these to 
effects on the quantile specified by the user. The default is the median (the 0.5 quantile).

{marker syntax_cdfquantreg_m}{...}
{marker cdfquantreg_m}{...}
{title:Syntax for cdfquantreg_m}

{cmd:cdfquantreg_m} {varlist} [{cmd:,}{opt pctle(real #)}]]

{marker options_cdfquantreg_m}{...}
{title:Options for cdfquantreg_m}

{dlgtab:Main}

{phang}{opt pctle(#)} specifies the quantile that {cmd:cdfquantreg_m} is to estimate. It expects a number in the 
(0,1) interval.  To estimate the 75th percentile, for instance, # would be set to 0.75. 
The default is 0.5.

{marker examples_cdfquantreg_m}{...}
{title:Examples}

{phang}{cmd:/* This example uses testmat1.dta */}{p_end}

{phang}{cmd:. cdfquantreg y i.d1##i.d2, cdf(t2) quantile(t2) zvarlist(d1 d2)}{p_end}

{phang}{cmd:. cdfquantreg_m d1 d2, pctle(0.75)}{p_end}

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
Shou, Y. & Smithson, M. (2018, in press). cdfquantreg: An R package for 
CDF-Quantile Regression. {it:Journal of Statistical Software}. 

