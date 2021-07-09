{smcl}
{* *! version 1.0  16April2019}{...}
{* *! Author: Volker Ludwig}

{vieweralsosee "[XT] xtset" "help xtset"}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}

{hline}

{title:Title}

{p 8 16 2}
{cmd:xtbsht} {hline 2} User-written ado for Bootstrapped Hausman Test (BSHT) {p_end}


{title:Syntax}


{p 8 16 2}
{cmd:xtbsht} {it:Model A} {it:Model B} [{cmd:,}] [{cmd:keep(}{varlist}{cmd:)}] [{cmd:reps(}{num}{cmd:)}] [{cmd:seed(}{num}{cmd:)}]  


{title:Description}


{pstd}
{cmd:xtbsht} implements the bootstrapped version of the Hausman test, using pairwise clustered sampling (Cameron et al. 2008, Cameron and Miller 2015).
{cmd:xtbsht} compares estimates of two models, {it:Model A} and {it:Model B},
and tests the Null hypothesis that there are no systematic differences in coefficients
that are common to both models. The covariance matrix of coefficients for {it:Model A} and {it:Model B} is
estimated via pairwise-clustered bootstrapping, where R samples of units are randomly
drawn from the estimation sample.

{pstd}
Typically, {cmd:xtbsht} is used to test for bias due to unobserved heterogeneity in linear models for panel data.
Often researchers want to know whether there are differences in coefficients between a standard Fixed-Effects (FE) and Random-Effects (RE) model.
After estimation of a linear Fixed-Effects models with Individual-Specific Slopes (FEIS) (Wooldridge 2010, pp. 374-381),
{cmd:xtbsht} can be used also to test for bias of an FE model, by comparing with FEIS estimates. In this case, {cmd:xtbsht} tests for inconsistency due to heterogeneous slopes of a subset of covariates. 
Similarly, the BSHT can be used to test for a bias of an RE model, by comparing with FEIS estimates.

{title:Options}

{dlgtab:Options}


{phang}
{opt keep(varlist)} requests that the BSHT be conducted only for the specified subset of common coefficients of {it:Model A} and {it:Model B}.

{phang}
{opt reps(num)} specifies R, the number of replications to be used for bootstrapping (default value is 50 replications).

{phang}
{opt seed(num)} optionally sets the seed for drawing random samples used for bootstrapping (recommended for replicability of results).


{title:Examples}

Estimate Fixed-Effects model
{cmd:. xtreg ln_wage ttl_exp msp tenure year, cluster(idcode) fe}
{cmd:. estimates store FE}

Estimate Random-Effects model
{cmd:. xtreg ln_wage ttl_exp msp tenure year, cluster(idcode) re}
{cmd:. estimates store RE}

Test FE versus RE model, 100 replications, set seed for replicability
{cmd:. xtbsht FE RE, reps(100) seed(123)}

Estimate Fixed-Effects model with Individual-specific Slope for total work experience
{cmd:. xtfeis ln_wage msp tenure year, slope(ttl_exp) cluster(idcode)}
{cmd:. estimates store FEIS}

Test FEIS versus FE model  
{cmd:. xtbsht FEIS FE, reps(100) seed(123)}

Test FEIS versus RE model  
{cmd:. xtbsht FEIS RE, reps(100) seed(123)}


{title:References}

{phang}
Cameron, C. A., Gelbach, J. G., Miller, D. L. (2008). Bootstrap-Based Improvements for Inference with Clustered Errors. Review of Economics and Statistics 90: 414-427.

{phang}
Cameron, C. A., Miller, D. L. (2015). A Practitioner’s Guide to Cluster-Robust Inference. Journal of Human Resources 50: 317-372.

{phang}
Wooldridge, J. (2010). Econometrics of Cross Section and Panel Data, Cambridge: MIT Press, 2nd edition.


{title:Author}

Volker Ludwig
Technische Universität Kaiserslautern
ludwig@sowi.uni-kl.de

{title:Citation}

Please cite this software as follows: 

Ludwig, V. (2019). XTFEIS: Stata module to estimate linear Fixed-Effects model with Individual-specific Slopes (FEIS).
https://EconPapers.repec.org/RePEc:boc:bocode:s458045

