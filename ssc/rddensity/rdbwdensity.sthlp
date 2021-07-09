{smcl}
{* *! version 1.0 14-Jul-2019}{...}
{viewerjumpto "Syntax" "rdrobust##syntax"}{...}
{viewerjumpto "Description" "rdrobust##description"}{...}
{viewerjumpto "Options" "rdrobust##options"}{...}
{viewerjumpto "Examples" "rdrobust##examples"}{...}
{viewerjumpto "Saved results" "rdrobust##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:rdbwdensity} {hline 2} Bandwidth Selection for Manipulation Testing using Local-Polynomial Density Estimation.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdbwdensity} {it:var} {ifin} 
[{cmd:,} 
{cmd:c(}{it:#}{cmd:)} 
{cmd:p(}{it:#}{cmd:)} 
{cmd:kernel(}{it:kernelfn}{cmd:)}
{cmd:fitselect(}{it:fitmethod}{cmd:)}
{cmd:vce(}{it:vcemethod}{cmd:)}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdbwdensity} implements several data-driven bandwidth selection methods useful to construct manipulation testing procedures using the local polynomial density estimators proposed in
{browse "https://sites.google.com/site/rdpackages/rddensity/Cattaneo-Jansson-Ma_2019_JASA.pdf":Cattaneo, Jansson and Ma (2019)}.{p_end}

{p 4 8}This command is used by {help rddensity:rddensity}.{p_end}

{p 4 8}A detailed introduction to this Stata command is given in {browse "https://sites.google.com/site/rdpackages/rddensity/Cattaneo-Jansson-Ma_2018_Stata.pdf":Cattaneo, Jansson and Ma (2018)}.{p_end}
{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://sites.google.com/site/rdpackages/rddensity":here}.{p_end}

{p 4 8}Related Stata and R packages useful for inference in regression discontinuity (RD) designs are described in the following website:{p_end}

{p 8 8}{browse "https://sites.google.com/site/rdpackages/":https://sites.google.com/site/rdpackages/}{p_end}


{marker options}{...}
{title:Options}

{p 4 8}{cmd:c(}{it:#}{cmd:)} specifies the threshold or cutoff value in the support of in {it:indepvar}, which determes the two samples (e.g., control and treatment units in RD settings).
Default is {cmd:c(0)}.{p_end}

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the local-polynomial used to construct the density estimators.
Default is {cmd:p(2)} (local quadratic approximation).{p_end}

{p 4 8}{cmd:fitselect(}{it:fitmethod}{cmd:)} specifies the order of the local-polynomial used to construct the bias-correction for the density estimators.
Options are:{p_end}
{p 8 12}{opt unrestricted} for density estimation without any restrictions (two-sample, unrestricted inference). This is the default option.{p_end}
{p 8 12}{opt restricted} for density estimation assuming equal c.d.f. and higher-order derivatives.{p_end}

{p 4 8}{cmd:kernel(}{it:kernelfn}{cmd:)} specifies the kernel function used to construct the local-polynomial estimator(s). Options are: {opt triangular}, {opt epanechnikov}, and {opt uniform}.
Default is {opt triangular}.{p_end}

{p 4 8}{cmd:vce(}{it:vcemethod}{cmd:)} specifies the procedure used to compute the variance-covariance matrix estimator.
Options are:{p_end}
{p 8 12}{opt plugin} for asymptotic plug-in standard errors.{p_end}
{p 8 12}{opt jackknife} for jackknife standard errors. This is the default option.{p_end}

    {hline}
	
		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}.

{p 4 8}Load dataset (cutoff is 0 in this dataset):{p_end}
{p 8 8}{cmd:. use rddensity_senate.dta}{p_end}

{p 4 8}Bandwidth selection for manipulation test using default options: {p_end}
{p 8 8}{cmd:. rdbwdensity margin}{p_end}

{p 4 8}Bandwidth selection for manipulation test using plug-in standard errors:{p_end}
{p 8 8}{cmd:. rdbwdensity margin, vce(plugin)}{p_end}


{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rddensity} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(c)}}cutoff value{p_end}
{synopt:{cmd:e(p)}}order of the polynomial used for density estimation{p_end}
{synopt:{cmd:e(N_l)}}sample size to the left of the cutoff{p_end}
{synopt:{cmd:e(N_r)}}sample size to the right of the cutoff{p_end}
{synopt:{cmd:e(h)}}matrix of estimated bandwidth (including underlying estimated constants){p_end}
{synopt:{cmd:e(runningvar)}}running variable used{p_end}
{synopt:{cmd:e(kernel)}}kernel used{p_end}
{synopt:{cmd:e(fitmethod)}}model used{p_end}
{synopt:{cmd:e(vce)}}standard errors estimator used{p_end}


{title:References}

{p 4 8}Cattaneo, M. D., Frandsen, B., and R. Titiunik. 2015.
{browse "https://sites.google.com/site/rdpackages/rdlocrand/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Randomization Inference in the Regression Discontinuity Design: An Application to the Study of Party Advantages in the U.S. Senate}.{p_end}
{p 8 8}{it:Journal of Causal Inference} 3(1): 1-24.{p_end}

{p 4 8}Cattaneo, M. D., Michael Jansson, and Xinwei Ma. 2018. {browse "https://sites.google.com/site/rdpackages/rddensity/Cattaneo-Jansson-Ma_2018_Stata.pdf": Manipulation Testing based on Density Discontinuity}.{p_end}
{p 8 8}{it:Stata Journal} 18(1): 234-261.{p_end}

{p 4 8}Cattaneo, M. D., Michael Jansson, and Xinwei Ma. 2019. {browse "https://sites.google.com/site/rdpackages/rddensity/Cattaneo-Jansson-Ma_2019_JASA.pdf":Simple Local Polynomial Density Estimators}.{p_end}
{p 8 8}{it:Journal of the American Statistical Association}, forthcoming.{p_end}


{title:Authors}

{p 4 8}Matias D. Cattaneo, Princeton University, Princeton, NJ.
{browse "mailto:cattaneo@princeton.edu":cattaneo@princeton.edu}.

{p 4 8}Michael Jansson, University of California Berkeley, Berkeley, CA.
{browse "mailto:mjansson@econ.berkeley.edu":mjansson@econ.berkeley.edu}.

{p 4 8}Xinwei Ma, University of California San Diego, La Jolla, CA.
{browse "mailto:x1ma@ucsd.edu":x1ma@ucsd.edu}.

