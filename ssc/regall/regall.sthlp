{smcl}
{* *! version 1.2.1  07mar2013}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}

{title:Title}

{phang}
{bf:regall} {hline 2} is a regression utility that runs and compares all regressions derived from complete sets of regressors.

{marker syntax}{...}
{title:Syntax}

{phang}
{bf:regall :} {cmd: command} depvar {varlist} [if] [in] [weight] [, options]

{title:Options}

{phang}
{bf:rs() - R squared :} Use {bf:rs(r2)} for the simple R2, {bf:rs(r2a)} for the adjusted R2 and {bf:rs(r2p)} for the pseudo R2.

{phang}
{bf:ic() - Information Criterion :} Use {bf:ic(aic)} for the Akaike's information criterion and {bf:ic(bic)} for the Bayesian information criterion.

{title:Description}

{pstd}
{cmd:regall} runs all possible regressions derived from {varlist} and compares results with R2 (R2, Adjusted R2 or Pseudo R2) and Information Criteria (AIC or BIC).
For example, a set of 3 regressors A, B and C can generate 3 equations of 1 regressor (A,B,C), 3 equations of 2 regressors 
(AB,BC,AC) and 1 equation of 3 regressors(ABC) for a total of 7 possible equations. In this case, {cmd:regall} runs all 7 equations and compares results.     

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:regall} uses {cmd:regsets} to generate the complete set of regressors and {cmd:estat ic} to generate the information criteria statistics. 

{pstd}
Remember that with logit or probit equations you can only specify the pseudo R2 option and that the pseudo R2 is not produced if you are using the 'no constant' option. 

{pstd}
The command makes use of 'r(table)' and will work with all regression commands that return the r(table) matrix. 

{pstd}
Use {bf:'&'} to keep sets of independent variabels fixed (ex: price&weight).

{title:Saved Results}

Matrices

{phang}
{bf: r(#) :} Returns the post estimation r(table) matrix for equation #.

{marker examples}{...}
{title:Examples}

{phang}{cmd: sysuse auto, clear}{p_end}
{phang}{cmd: regall: logit foreign weight headroom, rs(r2p) ic(bic)}{p_end}
{phang}{cmd: regall: reg headroom price trunk, rs(r2) ic(bic) }{p_end}
{phang}{cmd: regall: reg foreign price trunk, noconst rs(r2a) ic(aic)}{p_end}
{phang}{cmd: regall: reg foreign price trunk headroom&weight, rs(r2a) ic(aic)}{p_end}

{marker author}{...}
{title:Author}

{pstd}
Paolo Verme, World Bank, pverme@worldbank.org.

{marker aknowledgments}{...}
{title:Aknowledgments}

{pstd}
The author is grateful to Aziz Atamanov, Olivier Dupriez and Philippe Van Kerm for useful suggestions.

 


