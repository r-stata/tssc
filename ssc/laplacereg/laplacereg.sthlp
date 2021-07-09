{smcl}
{* *! version 1.0.0 24apr13}{...}
{cmd:help laplacereg}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:laplacereg} {hline 2}}Laplace regression{p_end}
{p2colreset}{...}

{title:Syntax}
{phang}

{p 8 13 2}
{cmd:laplacereg} {depvar} [{indepvars}] {ifin} {weight}
	[{cmd:,} {it:{help laplacereg##laplace_options:laplace_options}}]

{synoptset 25 tabbed}{...}
{marker laplace_options}{...}
{synopthdr :laplace_options}
{synoptline}
{syntab :Model} 
{synopt :{opt q:uantiles}({it:{help numlist}})}specifies the quantiles; default is {cmd:quantiles(.5)}{p_end}
{synopt :{opt f:ailure}({it:{help varname}})}specifies the failure variable{p_end}
{synopt :{opt sigma}({it:{help varlist}})}specifies the variables to be included in the scale parameter model; default is constant only{p_end}

{syntab :Estimation}
{synopt :{opt r:eps(#)}}perform {it:#} bootstrap replications; default is {cmd:reps(20)}{p_end}
{synopt :{opt seed(#)}}set random-number seed to {it:#}{p_end}
{synopt:{opt tol:erance(#)}}tolerance for the log-likelihood; default is {cmd:tolerance(1e-10)}{p_end}
{synopt:{opt max:iter(#)}}perform maximum of # iterations; default is {cmd:maxiter(2000)}{p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p2colreset}{...}

{phang}{cmd:by}, {cmd:statsby}, and {cmd:xi} are allowed with
{cmd:laplacereg}; see {help prefix}.{p_end}
{phang}{cmd:laplacereg}  allow {cmd:fweight}s and {cmd:pweight}s; see {help weight}.{p_end}
{phang}See {manhelp sqreg_postestimation R:sqreg postestimation} for features
available after estimation.

{title:Description}

{pstd}
{cmd:laplacereg} estimates Laplace regression models for percentiles of a response variable with possibly censored data.
Typical applications are in time-to-event or survival analysis. For example, Laplace regression can estimate and 
compare median survival across treatment or exposure groups. 

{title:Options for laplacereg}

{dlgtab:Model}

{phang}{opt q:uantiles}({it:{help numlist}}) specifies the quantiles as numbers between 0 and 1; 
numbers larger than 1 are interpreted as percentages. The default value is 0.5, which corresponds to the median. 

{phang}{opt f:ailure}({it:{help varname}}) specifies the failure event; 
the value 0 indicates censored observations. If {opt failure()} is not specified, all observations are assumed to be uncensored. 

{phang}{opt sigma}({it:{help varlist}}) specifies the variables to be included in the scale parameter model. Default is constant only.

{dlgtab:Estimation}

{phang}{opt reps(#)} specifies the number of bootstrap replications for estimating 
variance-covariance matrix and standard errors of the regression coefficients.   

{phang}
{opt seed(#)} sets the initial value of the random-number seed used by the bootstrap. If {opt seed(#)} is specified the bootstrapped estimates are reproducible (see {helpb set seed:set seed}).

{phang}
{opt tol:erance(#)} specifies the tolerance for the coefficient vector.  When the absolute change in the log-likelihood from
        one iteration to the next is less than or equal to {opt tolerance()}, the {opt tolerance()} convergence criterion is satisfied.
        {opt tolerance(1e-10)} is the default.

{phang}
{opt max:iter(#)} specifies the maximum number of iterations.  When the number of iterations equals {opt maxiter()}, the optimizer stops, 
        displays an "x" and presents the current results. {opt maxiter(2000)} is the default. 

{dlgtab:Reporting}

{phang}{opt level(#)}; see 
{helpb estimation options##level():[R] estimation options}.
 
{title:Examples}

{hline}

{pstd}Use the cancer trial dataset{p_end}
{phang2}{stata "sysuse cancer, clear"}{p_end}
{pstd}Estimate median survival by drug assuming no censored observations{p_end}
{phang2}{stata "xi: laplacereg studytime i.drug"}{p_end}
{pstd}Estimate median survival by drug with censored observations{p_end}
{phang2}{stata "xi: laplacereg studytime i.drug, fail(died)"}{p_end}
{pstd}Estimate the 25th, 50th (i.e. median), and 75th percentile{p_end}
{phang2}{stata "xi: laplacereg  studytime i.drug, q(.25 .5 .75) fail(died)"}{p_end}
{pstd}Estimate the 50th percentile in drug groups 2 and 3{p_end}
{phang2}{stata "lincom [q50]_cons + [q50]_Idrug_2"}{p_end}
{phang2}{stata "lincom [q50]_cons + [q50]_Idrug_3"}{p_end}
{pstd}Test equality of median survival across drug groups{p_end}
{phang2}{stata "testparm _Idrug_2 _Idrug_3, eq(q50)"}{p_end}
{pstd}Adjust for age{p_end}
{phang2}{stata "xi: laplacereg  studytime i.drug age, q(.25 .5 .75) fail(died)"}{p_end}
 
{title:Reference}

{phang2}Bottai, M. and Zhang, J. (2010), Laplace regression with censored data. Biometrical Journal, 52: 487-503{p_end}

{title:Authors}

{pstd}Matteo Bottai{p_end}
{pstd}Unit of Biostatistics{p_end}
{pstd}{browse "http://ki.se/imm":Institute of Environmental Medicine, Karolinska Institutet}{p_end}
{pstd}Stockholm, Sweden{p_end}
 
{pstd}Nicola Orsini{p_end}
{pstd}Unit of Nutritional Epidemiology{p_end}
{pstd}Unit of Biostatistics{p_end}
{pstd}{browse "http://ki.se/imm":Institute of Environmental Medicine, Karolinska Institutet}{p_end}
{pstd}Stockholm, Sweden{p_end}

{hline}

{title:Saved results}

{pstd}
{cmd:laplacereg} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_fail)}}number of failures{p_end}
{synopt:{cmd:e(n_q)}}number of estimated quantiles{p_end}
{synopt:{cmd:e(reps)}}number of bootstrap replications{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:laplacereg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(eqnames)}}names of equations{p_end}
{synopt:{cmd:e(qlist)}}requested quantiles{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{title:Also see}

{psee}
Manual:  {bf:[R] qreg}

{psee}
Online:  {manhelp qreg_postestimation R:qreg postestimation};{break}
{manhelp bootstrap R}
{p_end}
