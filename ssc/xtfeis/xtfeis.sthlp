{smcl}
{* *! version 1.0  15July2015}{...}
{* *! version 1.1  17July2018}{...}
{* *! version 2.0  16April2019}{...}
{* *! Author: Volker Ludwig}

{vieweralsosee "[XT] xtset" "help xtset"}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}

{hline}

{title:Title}

{p 8 16 2}
{cmd:xtfeis} {hline 2} User-written ado to estimate linear Fixed-Effects model with Individual-specific Slopes (FEIS) {p_end}


{title:Syntax}


{p 8 16 2}
{cmd:xtfeis} {depvar} {indepvars} {ifin} [{cmd:,}] [{cmd:slope(}{it:slopevars}{cmd:)}] [{cmd:noconstant}] [{cmd:cluster(}{it:clustvar}{cmd:)}] [{cmd:addsp(}{it:stub1}{cmd:)}] [{cmd:sp}] [{cmd:transformed(}{it:stub2}{cmd:)}] 



{title:Description}

{pstd}
{cmd:xtfeis} estimates linear Fixed-Effects models with Individual-Specific Slopes (Wooldridge 2010, pp. 374-381). 
You need to declare the current data set to be panel data before using this command, see help {helpb xtset}.
Estimation requires at least J+1 observations per unit where J is the number of variables with individual-specific slopes (including usually a constant).
{cmd:xtfeis} automatically selects only those units from the current data set with at least J+1 observations.


{title:Options}

{dlgtab:Options}

{phang}
{opt slope(slopevars)} specifies the names of variables that interact with time-constant individual heterogeneity, i.e. variables with individual-specific slopes.
Often, these variables are some function of time to allow for heterogeneous growth.
By default, individual-specific constants are included as {it:slopevar}. Specify {opt noconstant} to omit them.   

{pmore}
If {opt slope()} is not specified, the model collapses to the standard linear Fixed-Effects model, see help {helpb xtreg}.

{phang}
{opt noconstant} requests estimation of a model with individual-specific slopes only (i.e., individual-specific constants are omitted).

{phang}
{opt cluster(clustvar)} requests panel-robust standard errors. 
Panel-robust standard errors are robust to arbitrary forms of serial correlation within groups 
formed by {it:clustvar} as well as heteroscedasticity across groups. 

{phang}
{opt sp} shows estimates of the Average Partial Effects (APE) for the specified {it:slopevars}.

{phang}
{opt addsp(stub1)} adds variables carrying estimates of individual-specific slope parameters 
(by default, including a constant) to the current data set. 
The variables get the names of the specified {it:slopevars} prefixed by {it:stub1}.
Specifying option {opt addsp()} requires option {opt sp}. 

{phang}
{opt transformed(stub2)} requests within-transformed variables are added to the current data set. 
Added variables are named as the untransformed variables prefixed by {it:stub2}. 


{title:Examples}

{cmd:. webuse nlswork} 

Estimate standard Fixed-Effects model with panel-robust standard errors
{cmd:. xtfeis ln_wage msp tenure ttl_exp year, cluster(idcode)} 

Estimate Fixed-Effects model with Individual-specific Slope for total work experience
{cmd:. xtfeis ln_wage msp tenure year, slope(ttl_exp) cluster(idcode)}

Estimate Fixed-Effects model with Individual-specific Slope, add transformed variables to current data set
{cmd:. xtfeis ln_wage msp tenure year, slope(ttl_exp) cluster(idcode) transformed(t_)} 


{title:References}

Wooldridge, J. (2010). Econometrics of Cross Section and Panel Data, Cambridge: MIT Press, 2nd edition.


{title:Author}

Volker Ludwig
Technische Universität Kaiserslautern
ludwig@sowi.uni-kl.de

{title:Citation}

Please cite this software as follows: 

Ludwig, V. (2019). XTFEIS: Stata module to estimate linear Fixed-Effects model with Individual-specific Slopes (FEIS).
https://EconPapers.repec.org/RePEc:boc:bocode:s458045


