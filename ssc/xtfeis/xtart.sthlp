{smcl}
{* *! version 1.0  16April2019}{...}
{* *! Author: Volker Ludwig}

{vieweralsosee "[XT] xtset" "help xtset"}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}

{hline}

{title:Title}

{p 8 16 2}
{cmd:xtart} {hline 2} User-written ado for Artificial Regression Test (ART) version of the Hausman test {p_end}


{title:Syntax}


{p 8 16 2}
{cmd:xtart} [{it:Model A}] [{cmd:,}] [{cmd:addvars(}{varlist}{cmd:)}] [{cmd:keepvars(}{varlist}{cmd:)}] [{cmd:fe}] [{cmd:predicted(}{it:stub1 stub2}{cmd:)}] 


{title:Description}

{pstd}
{cmd:xtart} implements the ART version of the Hausman test.
{cmd:xtart} is used after estimation of a linear Fixed-Effects models with Individual-Specific Slopes (FEIS) (Wooldridge 2010, pp. 374-381). 
It tests the Null hypothesis that there are no systematic differences in coefficients between an FEIS and a standard FE model. 
The ART is intended as a test for inconsistency of FE estimates due to heterogeneous slopes of a subset of covariates. 
{cmd:xtart} can also be used to test for differences between standard FE and standard Random-Effects (RE) estimates, a typical application of the ART version of the Hausman test (Arellano 1993), 
and to test for differences between FEIS and RE estimates.

{pstd}
{cmd:xtart} requires estimation of a regression model using {cmd:xtfeis} before the ART test is conducted. 
You may specify the name of {it:Model A} after saving regression results with {cmd:estimates store} (see [XT] estimates). 
If {it:Model A} is not specified, {cmd:xtart} uses regression results of the most recent model estimated by {cmd:xtfeis}. The ART tests for
systematic differences in coefficients between {it:Model A} and a restricted {it:Model B}.

{title:Options}

{dlgtab:Options}

{phang}
{opt fe} requests the ART for comparing coefficients of standard FE and RE models.
By default, coefficients of an FEIS and an FE model are compared. 

{phang}
{opt re} requests the ART for comparing coefficients of an FEIS and an RE model.
By default, coefficients of an FEIS and an FE model are compared. 

{phang}
{opt addvars(varlist)} adds further covariates in varlist to the specification of {it:Model B}.

{phang}
{opt keep(varlist)} requests that the ART be conducted only for the specified subset of common coefficients of {it:Model A} and {it:Model B}.

{phang}
{opt predicted(stub1 stub2)} adds variables to the data set carrying unit-specific means
and predicted values for the dependent variable and covariates of {it:Model A}. 
Names of the variables carrying predicted values are original variable names prefixed by {it:stub1}. 
Variable names for the means are prefixed by {it:stub2}. If {it:stub1} and {it:stub2} are left unspecified, 
default prefixes {it:pred} and {it:mean} are used.


{title:Examples}

{cmd:. webuse nlswork}

Estimate Fixed-Effects model with Individual-specific Slope for total work experience
{cmd:. xtfeis ln_wage msp tenure year, slope(ttl_exp) cluster(idcode)}
{cmd:. estimates store FEIS}

Test for FEIS versus FE model
{cmd:. xtart}

Test for FE versus RE model
{cmd:. xtart FEIS, fe}

Test for FEIS versus RE model
{cmd:. xtart FEIS, re}

Compute test for subset of specified variables
{cmd:. xtart FEIS, keep(msp)}

Add variables with predicted and mean values to current data set
{cmd:. est restore FEIS}
{cmd:. xtart FEIS, predicted(_p_ _m_)}

Compute test "by hand"
{cmd:. return list}
{cmd:. `r(estcmd)'}
{cmd:. test _p_msp _p_tenure _p_year}


{title:References}

Arellano, M. (1993). On the testing of correlated effects with panel data. Journal of Econometrics 59: 87-97.
Wooldridge, J. (2010). Econometrics of Cross Section and Panel Data, Cambridge: MIT Press, 2nd edition.


{title:Author}

Volker Ludwig
Technische Universität Kaiserslautern
ludwig@sowi.uni-kl.de

{title:Citation}

Please cite this software as follows: 

Ludwig, V. (2019). XTFEIS: Stata module to estimate linear Fixed-Effects model with Individual-specific Slopes (FEIS).
https://EconPapers.repec.org/RePEc:boc:bocode:s458045

