{smcl}
{* 20APR2012}{...}
{hi:help rpme}
{hline}

{title:Title}

{pstd}{hi:rpme} {hline 2} Robust Pareto midpoint estimator

{title:Syntax}

{pstd}
{cmd:rpme} {cases} {min} {max} {ifin}, [by(id) {it:options}]
{p_end}

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
     
{synopt :{opt by(id)}} The id variable must be numeric.

{synopt :{opt grand_mean()}} If some column in the data contains the grand mean of the income distribution, insert the name of that column here. This improves estimates substantially.

{synopt :{opt saving()}} Name a dataset that will contain the estimates output by the command. This option is most commonly used with {cmd:by()}.

{pstd}The last two options change certain statistical defaults. Most users will not use these options. The defaults are justified in von Hippel, Scarpino, and Holas (2016):  

{synopt :{opt pareto_stat()}} statistic used instead of the midpoint in the top bin. The default is {hi:harmonic}, for harmonic mean.  Alternatives include {hi:arithmetic}, {hi:geometric}, and {hi:median}, for the arithmetic mean, geometric mean, and median, respectively.
{p_end}

{synopt :{opt alpha_min()}} minimum value for the Pareto shape parameter alpha. The default is 1. {p_end} 

	
{title:Description}

{pstd} {cmd:rpme} implements the robust Pareto midpoint estimator described by von Hippel, Hunter, & Drown (2017). 
 {cmd:rpme} takes data that are "binned" (a.k.a. grouped, bracketed, interval-censored) so that each row reports how many {it:cases} have values in the interval ({it:min},{it:max}).
 Binned data are commonly used to summarize the distribution of income or wealth across individuals, households, or families.
 From the binned data, {cmd:rpme} estimates summary statistics including the mean, median, standard deviation, Gini, Theil, 
 and other inequality statistics.

 {pstd} rpme assumes that the commands egen_inequal and _gwtmean and have already been installed. To install those commands, type "ssc install egen_inequal" and "ssc instll _gwtmean".

{title:Estimation Details}

{pstd} {cmd:rpme} is most commonly run with three arguments. The arguments are, in order, cases (number of cases in the bin), min (lower limit of bin), max (upper limit of bin). {cmd:rpme} assigns each case to the midpoint of the interval (min,max). It then calculates income statistics from the bin midpoints.

{pstd} If max is missing (infinite) for the top bin, {cmd:rpme} estimates the mean of the top bin in one of two ways: 

{pstd} (1) If the {cmd:grand_mean()} option is not specified, then the mean of the top bin is calculated by fitting a Pareto curve to the top two populated bins. Because the arithmetic mean of a Pareto distribution can be volatile or undefined, a harmonic mean is used instead.

{pstd} (2) If the {cmd:grand_mean()} option is specified, then the mean of the top bin is calculated so that the mean of the bin midpoints and top bin mean will equal the grand mean. 

{pstd} Method (2), when available, yield much more accurate estimates than method (1). The estimator is described by von Hippel, Hunter, and Drown (2017), who also evaluate its accuracy. 

{pstd} Some data give the bin means in addition to the bin min and max. In such data, {cmd:rpme} can be run with two arguments, where the first is the bin count and the second is the bin mean. 

{title:Example}

{pstd} The following example uses binned data from every US county in 2006-10. It estimates the Gini and other statistics, and then compares the Gini estimates to the "true" Gini values for each county.
For details, see von Hippel, Hunter, and Drown (2017).

. use county_bins, clear
/* Don't save estimates. */
. rpme households bin_min bin_max, by(fips)

/* Now save estimates and compare to true values. */
. rpme households bin_min bin_max, by(fips) saving(county_ests)
. use county_ests, clear
. merge 1:1 fips using county_true 
. twoway scatter gini gini_true  

{title:Saved Results}

{pstd}{cmd:rpme} saves estimates to the output file designated by the saving() option. Estimates include the mean, median, standard deviation, various inequality statistics, and the Pareto shape parameter alpha estimated from the binned data.

{title:Authors}

{p 4 4 2}
Paul T. von Hippel, University of Texas at Austin(paulvonhippel.utaustin@gmail.com).
{p_end}{p 4 4 2}
Daniel A. Powers, University of Texas at Austin(dpowers@austin.utexas.edu).
{p_end}

{title:References}

{p 4 4 2} von Hippel, P. T., Hunter, D. J., & Drown, M. (2017). "Better Estimates from Binned Income Data: Interpolated CDFs and Mean-Matching." Sociological Science, 4(26), 641-655.

{p 4 4 2} von Hippel, Paul T., Samuel V. Scarpino, and Igor Holas. (2016). "Robust estimation of inequality from binned incomes." Sociological Methodology 46.1: 212-251.



