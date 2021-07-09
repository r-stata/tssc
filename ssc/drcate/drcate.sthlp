{smcl}

{title:Title}

{p2colset 9 19 20 2}{...}
{p2col :{opt drcate} {hline 2}}Doubly robust uniform confidence band for conditional average treatment effect function {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt drcate} {varlist} [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab: varlist} {pstd} 
1. The first argument is the dependent variable. 
2. The second argument is the treatment variable. 
3. The third argument is the covariate for which the conditional average treatment is estimated. 
4. The remaining arguments are other covariates which are added to satisfy the unconfoundedness assumption.

{syntab:Method}
{synopt :{opth ps:(strings:string)}}must be either "logit" or "probit" {p_end}
{synopt :{opt alpha(#)}}set the confidence level; the default is 0.05.{p_end}
{synopt :{opt bwidth(#)}}set the bandwidth for local linear regression to #. The default is the rule-of-thumb bandwidth multiplied by n^(1/5)*n^(-2/7). {p_end}

{syntab:Graph}
{synopt :{opth graph:(strings:string)}}{it:string} must be either "on" or "off"; the default is "on".{p_end}
{synopt :{opth ci:(strings:string)}}{it:string} must be either "on" or "off"; the default is "on".{p_end}
{synopt :{opth ate:(strings:string)}}{it:string} must be either "on" or "off"; the default is "on".{p_end}

{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:drcate} performs the doubly robust conditional average treatment effect estimation proposed by Lee, Okui and Whang (2017). 
This program calculates and plots the augmented inverse probability weighting estimator of the conditional average treatment effect function given the covariate of interest. 
The propensity score is modeled as either logit or probit and the regression functions for the potential outcomes are modeled as linear regressions.
The local linear regression is used to estimate the conditional average treatment effect function. 
See {browse "https://doi.org/10.1002/jae.2574":Lee, Okui and Whang (2017)} for details.
		
{marker options}{...}
{title:Options}

{dlgtab:Method}

{phang}
{opth ps:(strings:string)} specifies the method to estimate the propensity score. 

{phang}
{opt alpha} is a real number between 0 and 1. The default is 0.05. 

{phang}
{opt bwidth} is a positive real number. If not specified, the rule-of-thumb bandwidth  multiplied by n^(1/5)*n^(-2/7) is used.


{dlgtab:Graph}

{phang}
{opth graph:(strings:string)} specifies whether to make a graph or not. 

{phang}
{opth ci:(strings:string)} specifies whether to present the confidence interval on the graph or not.

{phang}
{opth ate:(strings:string)} specifies whether to present the average treatment effect on the graph or not.

{marker results}
{title:Results} 

{pstd}{cmd:drcate} gives a graph of the doubly robust conditional average treatment effect function and uniform confidence bands. 


{marker example}{...}
{title:Examples:  CATE function estimation}

{pstd}Set up{p_end}
{phang2}{cmd:. webuse set http://www.stata-press.com/data/r13} {p_end}
{phang2}{cmd:. webuse cattaneo2}{p_end}

{pstd} Estimating the conditional average treatment effect of "alcohol" on "bweight" given "mage" and plotting it with uniform confidence bands {p_end}
{phang2}{cmd:. drcate bweight alcohol mage medu fage, ps("logit") bwidth(.781) graph("on") ci("on") ate("on")}{p_end}

{pstd} Using the default bandwidth by rule-of-thumb {p_end}
{phang2}{cmd:. drcate bweight alcohol mage medu fage, ps("logit") graph("on") ci("on") ate("on")}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:drcate} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalar}{p_end}
{synopt:{cmd:e(bwidth)}}value of bandwidth{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(treatment)}}name of treatment variable{p_end}
{synopt:{cmd:e(covint)}}name of covariate of interest{p_end}
{synopt:{cmd:e(remainings)}}names of remaining covariates{p_end}


{marker references}{...}
{title:References}

{marker R2016}{...}
{phang}
Lee, S., Okui, R., and Whang, Y. 2017.
{browse "https://doi.org/10.1002/jae.2574":{it:Doubly robust uniform confidence band for the conditional average treatment effect function}.}
{it:Journal of Applied Econometrics}, 32:1207--1225.
{p_end}
