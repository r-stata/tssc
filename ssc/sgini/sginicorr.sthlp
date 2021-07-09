{smcl}
{* Help file 2020-04-21,2010-03-09}{...}
{hline}
help for {hi:sginicorr}{right:P. Van Kerm (April 2020, March 2010)}
{hline}

{title:Title}

{pstd}{hi:sginicorr} {hline 2} Generalized Gini correlations


{title:Syntax}

{p 8 15 2}
{cmd:sginicorr}
{it:varlist} 
[{it:weight}] 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[{cmd:,} {it:options}]

{synoptset 22 tabbed}
{synopthdr}
{synoptline}
{synopt :{opth p:arameter(real)}}specifies Gini sensitivity parameter{p_end}
{synopt :{opth for:mat(%fmt)}}display format; default is {cmd:format(%5.4f)}{p_end}
{synoptline}

                  
{p 4 8 2}
  {it:varlist} may contain time-series operators; see {help tsvarlist}.
{p_end}
{p 4 6 2}{cmd:bootstrap}, {cmd:jackknife}, {cmd:svy bootstrap}, and {cmd:svy jackknife} prefixes are allowed; see {help prefix}.{p_end}
{p 4 6 2}{cmd:fweight}, {cmd:aweight} and {cmd:pweight} are allowed; see help {help weights:weights}.
{p_end}


{title:Description}

{pstd}
{hi:sginicorr} computes generalized Gini correlations for all pairs of variables in {it:varlist}.
Gini correlation coefficients are developed and discussed in Schechtman and Yitzhaki (1987, 1999, 2003).
{p_end}

{pstd}
The Gini correlation between two random variables X and Y is defined as R(X,Y)=Cov(X,1-G(Y))/Cov(X,1-F(X))
where F() and G() denote the cumulative distribution functions of X and Y, respectively. 
The generalized Gini correlation coefficient replaces 1-G(Y) and 1-F(X) by (1-G(Y))^(v-1) and (1-F(X))^(v-1)
where v is a fixed parameter.
Their properties can be understood as a mixture of Pearson's and Spearman's correlations. 
Note that unlike these two correlation measures, Gini correlation coefficients are not symmetric: R(X,Y) is 
not equal to R(Y,X).
{p_end}

{pstd} 
All pairwise correlations for the variables in {it:varlist} are computed, but {hi:sginicorr} will 
discard observations with missing data on {it:any} of the input variables and compute all coefficients on the 
resulting sample.
{p_end}
 
{pstd}
An accompanying {browse "http://www.vankerm.net/stata/manuals/sgini.pdf":online manual} provides details on formulas and usage examples.
{p_end}


{title:Options}

{phang}
{opth p:arameter(real)} specifies the sensitivity parameter v. Default is 2 leading to the Gini correlation.
{p_end}

{phang}
{opth format(%fmt)} controls the display format; default is {cmd:format(%5.4f)}.
{p_end}


{title:Saved Results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(Rho)}}correlation matrix{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(sum_w)}}sum of weights{p_end}
{synopt:{cmd:r(rho)}}correlation R(X,Y) between first variable in {it:varlist} (X) and second variable in {it:varlist} (Y){p_end}
{synopt:{cmd:r(param)}}value of the v parameter{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}{it:varlist}{p_end}


{title:Dependencies}

{pstd}
{hi:sginicorr} requires installation of the companion package {hi:sgini}.
{p_end}


{title:Example}

{p 8 12 2}{inp:. sysuse auto , clear }

{p 8 12 2}{inp:. sginicorr price turn weight mpg}


{title:References}

{p 4 8 2}Schechtman, E. & Yitzhaki, S. (1987), A measure of association based on Gini's mean difference, Communications in Statistics - Theory and Methods, 16(1): 207{c -}231.

{p 4 8 2}Schechtman, E. & Yitzhaki, S. (1999), On the proper bounds of the Gini correlation, Economics Letters, 63(2): 133{c -}138.

{p 4 8 2}Schechtman, E. & Yitzhaki, S. (2003), A family of correlation coefficients based on the extended Gini index, Journal of Economic
Inequality, 1(2): 129{c -}146.


{title:Also see}

{psee}
Manual:  {bf:[R] correlate}, {bf:[R] spearman}

{psee}
Online:  {helpb sgini} (if installed)


{title:Author}

{pstd}Philippe Van Kerm, CEPS/INSTEAD, Lux{pstd}Philippe Van Kerm, Luxembourg Institute of Socio-Economic Research (LISER) and University of Luxembourg, philippe.vankerm@liser.luembourg, philippe.vankerm@ceps.lu


{title:Acknowledgments}

{pstd}
This package was originally written for the MeDIM project 
({it:Advances in the Measurement of Discrimination, Inequality and Mobility}) 
supported by the Luxembourg Fonds National de la Recherche (contract FNR/06/15/08) 
and by core funding for CEPS/INSTEAD by the
Ministry of Culture, Higher Education and Research of Luxembourg. 


{* Version 2.0 ,2020-04-21, 2010-03-09}
