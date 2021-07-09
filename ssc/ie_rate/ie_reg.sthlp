{smcl}
{* 20APR2012}{...}
{hi:help ie_reg}
{hline}

{title:Title}

{pstd}{hi:ie_reg} {hline 2} intrinsic estimator for age, period, cohort (APC) applications

{title:Syntax}
{p 8 16 2}
{cmd:ie_reg} {depvar} [{indepvars}] {ifin} {weight} [, {it: options}]
{p_end}

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt :{opt irr}} eform results
    {p_end}
  	
{title:Description}

{pstd} {helpb ie_reg} computes coefficients from an APC analysis characterized by a design matrix that is not full rank
due to perfect linear dependence between age, period, and cohort. However, {helpb ie_reg} does not require strict linear dependence 
to estimate APC parameters. 

{pstd} The dependent variable is assumed to be in the form of a log rate or rate.  
In order to obtain APC estimates that are normalized according to conventional applications (i.e., {helpb apc_ie}), 
it is necessary that an ANOVA design matrix be constructed using the {it:last} factor level of each 
APC factor as  the reference as shown below. Optionally, the user may request the full set of ANOVA normalized estimates 
that include the reference category which are obtained using {cmd:ie_norm}, a modified version of Ben Jann's {helpb devcon} utility with 
exactly the same syntax.

{title:Example code for ANOVA design coding}

qui tab age, gen(a)
scal arow = r(r)
qui tab period, gen(p)
scal prow = r(r)
qui gen cohort = period - age
qui tab cohort, gen(c)
scal crow = r(r) 

* construct ANOVA normalization using last category as reference

forval i = 1/`=arow' {
 gen aC`i' = a`i' - a`=arow'
 }

forval i = 1/`=prow' {
 gen pC`i' = p`i' - p`=prow'
 }
 
forval i = 1/`=crow' {
 gen cC`i' = c`i' - c`=crow'
}


{title:Examples}

{p 0 15 2}
{bf:APC regression model}
{p_end}

{pstd} ie_reg logr aC1-aC6 pC1-pC3 cC1-cC9

{p 0 15 2}
{bf:fully normalized solution}
{p_end}

{pstd} ie_norm, groups(aC1-aC7, pC1-pC4, cC1-cC10)

{title:Estimation Details}

{p 0 15 2}
{cmd:ie_reg} employes a generalized inverse.  
{p_end}

{title:Saved Results}

{p 0 15 2}
{cmd:ie_reg} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of cells
    {p_end}
{synopt:{cmd:e(ll)}}MSE
    {p_end}
{synopt:{cmd:e(k)}}number of estimated parameters
    {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable
    {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(Coef)}}1 X {it:K} vector of estimates
    {p_end}
{synopt:{cmd:e(Var)}}{it:K} X {it:K} variance-covariance matrix
    {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}} marks estimation sample
    {p_end}

{title:References}

{phang} Daniel A. Powers (2012). "Black-White Differences in Maternal Age, Maternal Birth Cohort, and 
Period Effects on Infant Mortality in the U.S. (1983-2002)." Presented at the annual meetings of the Population
Research Association of America, San Francisco, CA, May 4 2012.
{p_end}

{title:Author}

{p 4 4 2}Daniel A. Powers, University of Texas at Austin, dpowers@austin.utexas.edu
{p_end}

{title:Also see}

{p 4 13 2}
Online:  help for {helpb devcon} and help for {helpb ie_rate}
