{smcl}
{* *! version 1.0.0  05-26-2019}{...}
{viewerjumpto "Data" "ikbw##data"}{...}
{viewerjumpto "Syntax" "ikbw##syntax"}{...}
{viewerjumpto "Examples" "ikbw##examples"}{...}

{title:Title}

{p 4 8}{cmd:ikbw} {hline 2} computes optimal bandwidth for sharp RD, with local linear regressions and triangular kernel, following   
Imbens and Kalyanaraman(2012).{p_end}


{marker data}{...}
{title:Data}

{p 4 8}You need to have a dataset with one outcome variable (Y) and one forcing variable (X).{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:ikbw } {it:varlist(numeric)} {ifin}{cmd:,} 
[CUToff(numlist)]
{p_end}

{p 4 8} where the capital letters indicate how you can abbreviate option names.{p_end}

{p 8 12}{cmd:varlist}: (required) enter the list of variables you want to regress in this order: outcome variable (Y) and forcing variable (X). {p_end}

{p 8 12}{cmd:[if]} or {cmd:[in]}: (optional) like in any other STATA command, to restrict the sample you want to obtain your estimates from. {p_end}

{p 8 12}{cmd:cutoff(numlist)} or {cmd:cut(numlist)}: (optional) the threshold that determines sharp assignment of treatment.
Individuals with forcing variable greater than or equal to the threshold are treated; otherwise, they are untreated.
The default value for cutoff is zero.{p_end}

{p 4 8}The code returns the scalars e(hwid): the optimal bandwidth; 
and e(flag): number of singular matrices encountered during execution, in which case a pseudo-inverse is used.{p_end}

{marker examples}{...}
{title:Example}

    
{p 4 8}Estimate the optimal IK bandwidth{p_end}
{p 8 8}{cmd:. ikbw Y X}{p_end}

{p 4 8}Estimate the optimal IK bandwidth using the specified threshold c{p_end}
{p 8 8}{cmd:. ikbw Y X, cut(c)}{p_end}

{title:References}

{p 4 8}Imbens, G., and Kalyanaraman, K. (2012),
Optimal Bandwidth Choice for the Regression Discontinuity Estimator.
{it:The Review of Economic Studies,} Volume 79, Issue 3, Pages 933-959.


{title:Contributor to this Code:} Wei Qian, University of Notre Dame.



