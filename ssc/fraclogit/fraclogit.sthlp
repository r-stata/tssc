{smcl}
{* 20APR2012}{...}
{hi:help fraclogit}
{hline}

{title:Title}


{pstd}{hi:fraclogit} {hline 2} Fractional logit model as implemented in Wedderburn (1974) and generalized by McCullagh (1983).

{title:Syntax}
{p 8 16 2}
{cmd:fraclogit} {depvar} {indepvars} {ifin} {weight}, [{it:options}]
{p_end}

{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt :{opt eform}} relative proportion ratio form results
    {p_end} 
     
	
{title:Description}

{pstd} {helpb fraclogit} carries out a quasi-likelihood estimation of a fractional logit model using iteratively reweighted
least squares (irls) as described Wedderburn (1974) and generalized
by McCullah (1983). The dependent variable for {cmd:fraclogit} is assumed to a proportion in the (0,1) interval. 
Papke and Wooldridge (1996) provide a quasi-ML approach to this problem and a Stata implementation using -glm- is described 
in Hardin and Hilbe(2012). 
   

{pstd} 


{title:Example (from Wedderburn 1974)}

. use wedderburn, clear	
. fraclogit yield i.site i.variety
. margins variety

{title:Estimation Details}

{pstd} {cmd:fraclogit} uses iteratively reweighted least squares in repeated calls to {helpb glm}. 


{title:Saved Results}

{p 0 15 2}
{cmd:fraclogit} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations
{p_end}
{synopt:{cmd:e(df)}}number of model parameters
{p_end}
{synopt:{cmd:e(dev)}}pearson chi-square statistic
{p_end}
{synopt:{cmd:e(rmse)}}root mse (dispersion)
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


{title:Authors}

{p 4 4 2}Daniel A. Powers, University of Texas at Austin(dpowers@austin.utexas.edu).
{p_end}

{title:References}

{p 4 4 2} Hardin, J.W. and J.M. Hilbe  {it: Generalized Linear Models and Extensions}, Third Edition, Stata Press

{p 4 4 2} McCullagh, P. (1983) "Quasi-Likelihood Functions," {it: Annals of Statistics}. Vol. 11, No. 1, pp. 59-67.

{p 4 4 2} Papke, L.E. and J.W. Wooldridge (1996) "Econometric Methods for Fractional Response Variables With an Application to 401 (K) Plan
Participation Rates," {it: Journal of Applied Econometrics}. Vol 11, No. 6, pp. 619-632.

{p 4 4 2} Wedderburn, R.M.W. (1974) "Quasi-Likelihood Functions, Generalized Linear Models, and the Gauss-Newton Method," {it: Biometrika}, Vol. 61, No. 3, pp. 439-447.



{title:Also see}

{p 4 13 2}
Online:  help for {helpb glm}.
