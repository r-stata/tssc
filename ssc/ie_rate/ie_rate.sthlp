{smcl}
{* 20APR2012}{...}
{hi:help ie_rate}
{hline}

{title:Title}

{pstd}{hi:ie_rate} {hline 2} intrinsic estimator for age, period, cohort (APC) applications

{title:Syntax}
{p 8 16 2}
{cmd:ie_rate} {depvar} [{indepvars}] {ifin} {weight} [,{it:options}]
{p_end}

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt :{opt eform}} exp(b) results
{p_end}
{synopt :{opt offset(logn)}} log of exposure for rate parameterization 
{p_end}
{synopt :{opt scale(dev)}} calculate std. errors using deviance-based mse
{p_end}
{synopt :{opt logit}} fit logit model (requires binom(n))
{p_end}
{synopt :{opt binom(n)}} binomial denominator for logit parameterization
{p_end}  
	
{title:Description}

{pstd} {helpb ie_rate} computes coefficients from an APC analysis characterized by a design matrix that is not full rank due to the perfect linear dependence between age, period, and cohort. However, unlike {helpb apc_ie}, {helpb ie_rate} 
does not require strict linear dependence to estimate the APC model. However, it does require care in inputting the proper APC design 
matrix (described below). 

{pstd} The dependent variable for {cmd:ie_rate} is assumed to be in the form of counts. An offset (log exposure) should be specified in order to estimate a rate model. If an offset is not specified, it defaults to 0 resulting in a standard 
Poisson regression. 
Alternatively, the logit option can be specified with binomial denominator n to fit a logit model. Initial values are obtained using {helpb ie_reg}, which is a companion routine for linear regression on the log rates or empirical logits.

{pstd} In order to obtain APC estimates normalized according to conventional applications (i.e., {helpb apc_ie}),  it is necessary that an ANOVA design matrix be constructed using the {it:last} factor level of each  APC factor 
as the reference as shown below. 

{pstd} After estimation the user may request the display of the 
full set of ANOVA normalized estimates, including those pertaining to the reference categories. The renormalized estimates are obtained using {cmd:ie_norm}, which is a modified version of Ben Jann's {helpb devcon} utility and follows
 exactly the same syntax. 
As mentioned above, it is important to code the APC design with the last category as reference.  Additionally, the model must include a constant term. 

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
{bf:APC loglinear rate model}
{p_end}

{pstd} . ie_rate d aC1-aC6 pC1-pC3 cC1-cC9, offset(logn)
{p_end}

{p 0 15 2}
{bf:APC logit model}
{p_end}

{pstd} . ie_rate d aC1-aC6 pC1-pC3 cC1-cC9, logit binom(n)
{p_end}

{p 0 15 2}
{bf:fully normalized solution}
{p_end}

{pstd} . ie_norm, groups(aC1-aC7, pC1-pC4, cC1-cC10)
{p_end}

{title:Estimation Details}

{pstd} {cmd:ie_rate} uses a Newton-Raphson algorithm and employes the method outlined in Fu (2000). 
Starting values are obtained from a linear regression using the empirical logits or log rates via
 {helpb ie_reg},  which may also be used as a standalone program for a analysis of empirical log rates or logits.   

{title:Saved Results}

{p 0 15 2}
{cmd:ie_rate} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of cells
    {p_end}
{synopt:{cmd:e(ll)}}deviance
    {p_end}
{synopt:{cmd:e(k)}}number of estimated parameters
    {p_end}
	
{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable
    {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}1 X {it:K} vector of estimates
    {p_end}
{synopt:{cmd:e(V)}}{it:K} X {it:K} variance-covariance matrix
    {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}} marks estimation sample
    {p_end}

{title:References}

{phang} Wenjiang Fu (2000). "Ridge Estimator in Singular Design with Application to Age-Period-Cohort Analysis of Disease 
Rates, {it: Communications in Statistics - Theory and Methods}, 29:2, 263-278
{p_end}

{phang} Daniel A. Powers (2012). "Black-White Differences in Maternal Age, Maternal Birth Cohort, and 
Period Effects on Infant Mortality in the U.S. (1983-2002)." {it: Social Science Research}, 42: 1033-1045.
{p_end}


{title:Author}

{p 4 4 2}Daniel A. Powers, University of Texas at Austin, dpowers@austin.utexas.edu
{p_end}

{title:Also see}

{p 4 13 2}
Online:  help for {helpb devcon} and help for  {helpb apc_ie} if installed.
