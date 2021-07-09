{smcl}
{* 29APR2016}{...}
{hi:help mgbe}
{hline}

{title:Title}


{pstd}{hi:mgbe} {hline 2} Multimodel Generalized Beta Estimator

{title:Syntax}
{p 8 16 2}
{cmd:mgbe} cases min max {if} [, DISTribution(string) AIC BIC AVERAGE SAVing(string) BY(id)]
{p_end}

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt :{opt DISTribution(string)}} Distributions can be chosen from the following: {cmd:GB2}(Generalized Beta Type 2), {cmd:DAGUM}, {cmd:SM}(Singh-Maddala), {cmd:BETA2}, {cmd:LOGLOG}(Loglogistic), {cmd:GG}(Generalized Gamma), {cmd:GA}(Gamma), 
{cmd:WEI}(Weibull), {cmd:PARETO2}, {cmd:LN}(Lognormal). If no distribution is specified, the program will run over all ten distributions.
{p_end} 
{synopt :{opt aic}} The best-fitting distribution will be selected according to the Akaike information criterion (AIC). AIC is the default criterion.
{p_end} 
{synopt :{opt bic}} The best-fitting distribution will be selected according to the Bayesian information criterion (BIC).
{p_end} 
{synopt :{opt average}} Estimates will be averaged across distributions, with the average weighted according to the AIC (by default) or BIC. 
{p_end}
{synopt :{opt SAVing(outfile)}} Save statistics to the output file designated by the saving() option. 
Statistics include the mean, median, variance, and various inequality statistics.
Under AIC or BIC model selection, statistics also include the log likelihood (ll), AIC, BIC of the best-fitting model, as well as a likelihood ratio test of fit (G2), with degrees of freedom (df) and p value.
The null hypothesis that the distribution fits the data is typically rejected (p<.05), especially in large datasets, but the distribution can still be a useful approximation.
{p_end}
{synopt :{opt BY(id)}} Estimate binned data grouped by {it:id}.
{p_end}


     
	
{title:Description}

{pstd} {cmd:mgbe} implements 10 Generalized Beta family distributions and uses multimodel inference to obtain estiamtes from the best fitting models.
 {cmd:mgbe} assumes that the data are "binned" (a.k.a. grouped, bracketed, interval-censored) so that each row reports how many cases have values in the interval (min,max).
 Binned data are commonly used to summarize the distribution of income or wealth across individuals, households, or families.
 From the binned data, {cmd:mgbe} estimates summary statistics including the mean, median, standard deviation, Gini, Theil, and other inequality statistics.

 {pstd} mgbe requires Stata/IC or Stata/MP and assumes that the commands savesome and egen_inequal have already been installed. To install those commands, type "ssc install egen_inequal" and "ssc install savesome".

{title:Estimation Details}

{pstd} {cmd:mgbe} accepts three arguments, in order: cases (number of cases per bin), min (lower limit of bin) and max (upper limit of bin).

{pstd} Only the rightmost bound of each bin can be missing (infinite).

{pstd} The estimator is described by von Hippel, Scarpino, and Holas (2016).

{title:Example}

{pstd} The following example uses binned data from every US county in 2006-10. It estimates the Gini and other statistics.

use county_bins, clear
keep if fips <= 2000 /* Fit data from Alabama */
by fips: mgbe households bin_min bin_max, dist(DAGUM GG) aic average

{title:Saved Results}

{pstd}{cmd:mgbe} saves estimates to the output file designated by the saving() option. Estimates include the mean, median, variance, various inequality statistics, and quantiles 1-999 from the binned data.

{title:Notes}

{pstd}
1. Running over all 10 distributions can be slow. Use fewer distributions for faster runtime. Start by eliminating the Pareto2, Lognormal, and Loglogistic, which are almost never the best-fitting distributions. 
{p_end}
{pstd}
2. Running very large datafiles can be slow. Consider breaking large datafiles into smaller pieces. 
{p_end}
{pstd}
3. mgbe borrows some code from three programs by Austin Nichols: {help gbgfit}, {help smgfit}, and {help dagfit}. All errors and enhancements are our own.
{p_end}


{title:Authors}

{p 4 4 2}
Yutong Duan, University of Texas at Austin (yduan@utexas.edu).
{p_end}
{p 4 4 2}
Paul T. von Hippel, University of Texas at Austin (paulvonhippel.utaustin@gmail.com).
{p_end}

{title:References}

{p 4 4 2} von Hippel, P.T., †Scarpino, S.V., & †Holas, I. (2016). “Robust estimation of inequality from binned incomes.” Sociological Methodology, accepted and published online ahead of print. Also available as arXiv e-print 1402.4061.
 http://arxiv.org/abs/1402.4061.

