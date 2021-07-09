{smcl}
{* 07dec2012}{...}
{cmd:help nonparmde}{right:Version 1.0.0}
{hline}

{title:Title}

{pstd}
{hi:nonparmde} {hline 2} Calculates the minimum detectable effect (MDE) using a Horvitz-Thompson estimator and a size (and covariate) adjusted Raj estimator for cluster randomized controlled experiments. 
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:nonparmde} {it:varlist} {cmd:, }
{opt mtreatment:(clusternum)}
{opt mcontrol:(clusternum)}
[{opt n:(clustersizevar)}
{opt kx:(numlist)}
{opt averages}
{opt power(num)}
{opt ci(num)}
{opt crossfold(num)}
{opt avgclustersize(num)}]

{marker desc}{title:Description}

{pstd} {cmd:nonparmde} is a method for calculating the minimum detectable effect (MDE) using the nonparametric estimators proposed in Middleton & Aronow (2011). This program is for use on cluster-level data to calculate the minimum effect that a cluster randomized experiment would be able to reliably detect at a given level of statistical power. 

{marker opt}{title:Options}

{pstd} {it:varlist} the name of the prior DV variable, optionally followed by a list of covariates that are expected to explain variance in the DV variable (all variables must be either cluster averages or cluster totals){p_end}

{pstd} {opt mtreatment:(clusternum)} number of clusters assigned to treatment group {p_end} 
{pstd} {opt mcontrol:(clusternum)} number of clusters assigned to control group {p_end} 
{pstd} {opt n:(clustersizevar)} name of the variable that denotes cluster size (if left unspecified {opt avgclustersize(num)} must be specified) {p_end} 
{pstd} {opt kx:(numlist)} regression coefficients of covariates regressed on prior DV variable, controlling for cluster size (calculated automatically if left unspecified) {p_end} 
{pstd} {opt averages} forces the program to treat all variables as cluster averages ({opt n:(clustersizevar)} must be specified if this option is used)  {p_end} 
{pstd} {opt power(num)} statistical power (if left unspecified assumes 80% power) {p_end} 
{pstd} {opt ci(num)} confidence interval (if left unspecified assumes 95% CI) {p_end} 
{pstd} {opt crossfold(num)} crossfolds used for the calculation of kx; can be either an integer or a variable specifying cutoffs (if left unspecified no crossfolding is done). The command {cmd:xvalols} must be installed. {p_end} 
{pstd} {opt avgclustersize(num)} average cluster size (use only if {opt n:(clustersizevar)} is left unspecified)  {p_end} 


{marker ex}{title:Examples}

{pstd} {inp:. nonparmde Y_total, mtreatment(50) mcontrol(50) avgclustersize(20.61)}{p_end}

{pstd} {inp:. nonparmde y_avg x_avg n, n(n) averages mtreatment(50) mcontrol(50)}{p_end}

{pstd} {inp:. nonparmde Y_total X_total Z_total, mtreatment(50) mcontrol(50) kx(.2 .1) averageclustersize(20.61)}{p_end}

{pstd} {inp:. nonparmde Y_total X_total Z_total, mtreatment(50) mcontrol(50) averageclustersize(20.61)}{p_end}

{pstd} {inp:. nonparmde Y_total X_total Z_total, mtreatment(50) mcontrol(50) n(n)}{p_end}

{pstd} {inp:. nonparmde Y_total X_total Z_total n, mtreatment(50) mcontrol(50) n(n)}{p_end}

{pstd} {inp:. nonparmde Y_total X_total Z_total n, mtreatment(50) mcontrol(50) n(n) crossfold(cut)}{p_end}

{pstd} {inp:. nonparmde Y_total X_total Z_total n, mtreatment(50) mcontrol(50) n(n) crossfold(2)}{p_end}


{marker res}{title:Saved Results}

{pstd}
{cmd:nonparmde} saves the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:e(Vht)}}Horvitz-Thompson variance{p_end}
{synopt:{cmd:e(Vraj)}}Raj variance{p_end}
{synopt:{cmd:e(Vrajcovars)}}covariate adjusted Raj variance{p_end}

{marker ref}{title:References}
{pstd}Middleton, Joel A. and Aronow, Peter M., Unbiased Estimation of the Average Treatment Effect in Cluster-Randomized Experiments (April 5, 2011). Available at SSRN: http://ssrn.com/abstract=1803849 
{p_end}

{title:Authors}

{pstd}Joel Middleton{p_end}
{pstd} New York University{p_end}
{pstd} {browse "mailto:joel.middleton@gmail.com":joel.middleton@gmail.com}{p_end}

{pstd}John Ternovski{p_end}
{pstd} Analyst Institute{p_end}
{pstd} {browse "mailto:johnt1@gmail.com":johnt1@gmail.com}{p_end}

