{smcl}
{* *! version 1.0 18 Oct 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "C:\ado\plus\r\reg2logit##syntax"}{...}
{viewerjumpto "Description" "C:\ado\plus\r\reg2logit##description"}{...}
{viewerjumpto "Options" "C:\ado\plus\r\reg2logit##options"}{...}
{viewerjumpto "Remarks" "C:\ado\plus\r\reg2logit##remarks"}{...}
{viewerjumpto "Examples" "C:\ado\plus\r\reg2logit##examples"}{...}
{title:Title}
{phang}
{bf:reg2logit} {hline 2} Approximates logistic regression parameters using OLS linear regression.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:reg2logit}
{{it:yvar}} [{{it:xvars}}] {ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt iter:ate(#)}}  Number of times to iterate after transforming the OLS parameter estimates. Default value is 0.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:reg2logit} estimates the parameters of a logistic regression of {it:yvar} on {it:xvars} by transforming OLS estimates of the linear regression of {it:yvar} on {it:xvars}.
Factor {it:xvars} are allowed.
The transformation formula, first derived by Haggstrom (1983), is discussed by Allison (2020). {p_end}

{pstd}The transformed OLS estimates are fully efficient estimates of the logistic regression under the assumption that the {it:xvars} are multivariate normal conditionally on the value of the {it:yvar}. 
If the {it:xvars} are in fact conditionally multivariate normal, then the estimates produced by {cmd:reg2logit} are more efficient than the "distribution-free" estimates produced by the {cmd:logit} command, 
which assume nothing about the distribution of the {it:xvars}.
If the {it:xvars} are not conditionally multivariate normal, then {cmd:reg2logit} may be more or less efficient than {cmd:logit}, depending on how much the {it:xvars} depart from conditional multivariate normality.
Even when they are less efficient than the {cmd:logit} estimates, the {cmd:reg2logit} estimates are often similar and have the advantage of running more quickly and without iteration. 
In the various conditions that have been tested by simulation, {cmd:reg2logit} produced predicted probabilities that are very similar to those produced by {cmd:logit}, except when the model included strong interactions (Allison 2020).{p_end}

{pstd}By default, {cmd:reg2logit} returns the transformed OLS coefficients. 
If you set the {cmd:iter()} option to a value greater than zero, {cmd:reg2logit} iterates toward the same distribution-free maximum likelihood estimates produced by {cmd:logit}.{p_end}

{pstd}After {cmd:reg2logit}, you can run {cmd:predict} to get predicted probabilities, just as you can after {cmd:logit}.{p_end}


{marker examples}{...}
{title:Examples}
{phang2}{cmd:sysuse auto, clear}{p_end}

{pstd}/* Approximate logistic regression coefficients from the OLS estimates: */{p_end}
{phang2}{cmd:reg2logit foreign weight price }{p_end}

{pstd}/* Iterate toward maximum likelihood estimates of the logistic regression coefficients.... */{p_end}
{phang2}{cmd:reg2logit foreign weight price, iter(200) }{p_end}
{pstd}/* ...which are not terribly different in this example */{p_end}

{title:Applications}
{pstd}{cmd:reg2logit} has several applications.

{pstd}1. In some settings -- e.g., with big data or many correlated {it:xvars} -- iterative commands like {cmd:logit} can be slow to produce maximum likelihood estimates (Minka 2003; Ji & Telgarsky 2018). 
{cmd:reg2logit} produces estimates quickly, without iteration. The estimates are often serviceable, often quite close to the maximum likelihood estimates, 
and in fact are fully efficient estimates if {it:xvars} is conditionally multivariate normal.{p_end}

{pstd}2. If you set the {cmd:iter()} option to a value greater than zero, the transformed OLS estimates provide a plausible starting point for iteration toward maximum likelihood estimates.
Yet suprisingly, convergence is not necessarily faster than it is with the {cmd:logit} command, which starts with slope estimates of zero.
{p_end}

{pstd}3. In some settings, predicted probabilities must be obtained from a linear probability model. {cmd:reg2logit} followed by {cmd:predict} provides the best way of doing this (Allison 2020).
{p_end}

{pstd}4. One application for these predicted probabilities is to impute dummy variables after fitting a multivariate normal imputation model. This is implemented by our {cmd:mi_impute_genmod} command,
which you can install using {cmd:ssc install mi_impute_genmod}.
{p_end}

{title:Technical notes}
{pstd}When run with {cmd:iter()} at the default of 0, {cmd:reg2logit} returns a "Warning: Convergence not achieved." 
You can generally ignore this, as it merely indicates that no iterations have been performed.{p_end}

{pstd}When run with {cmd:iter()} at the default of 0, {cmd:reg2logit} does not require {it:yvar} to be binary 0/1. 
This laxity can be helpful in some problems, such as imputation problems where values of {it:yvar} other than 0 and 1 have previously been imputed by a normal model.
{p_end}

{title:References}
{pstd}
Allison, P.D. (2020, April 24). Better predicted probabilities from linear probability models. Statistical Horizons blog. https://statisticalhorizons.com/better-predicted-probabilities
{p_end}

{pstd}
Haggstrom, G. W. (1983). Logistic regression and discriminant analysis by ordinary least squares. Journal of Business & Economic Statistics, 1(3), 229-238.

{pstd}Ji, Z., & Telgarsky, M. (2018). Risk and parameter convergence of logistic regression. arXiv preprint arXiv:1803.07300.{p_end}

{pstd}Minka, T. P. (2003). A comparison of numerical optimizers for logistic regression. Unpublished manuscript, http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.85.7017&rep=rep1&type=pdf.{p_end}


{title:Authors}
Paul von Hippel <paulvonhippel@utexas.edu>
Rich Williams <Richard.A.Williams.5@nd.edu>
Paul Allison <allison@statisticalhorizons.com>
{p}



