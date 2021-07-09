{smcl}
{* *! version 1.4 03 Jan 2019}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install mvtden" "ssc install MVTNORM"}{...}
{vieweralsosee "Help mvtden (if installed)" "help mvtden"}{...}
{viewerjumpto "Syntax" "mvtden##syntax"}{...}
{viewerjumpto "Description" "mvtden##description"}{...}
{viewerjumpto "Options" "mvtden##options"}{...}
{viewerjumpto "Remarks" "mvtden##remarks"}{...}
{viewerjumpto "Examples" "mvtden##examples"}{...}
{title:Title}
{phang}
{bf:mvtden} {hline 2} Multivariate t Density

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:mvtden}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt x(numlist)}} Vector of quantiles.{p_end}
{break}
{syntab:Optional}
{synopt:{opt del:ta(numlist)}} Vector of non-centrality parameters.{p_end}
{synopt:{opt s:igma(string)}} Scale matrix.{p_end}
{synopt:{opt df(#)}} Degrees of freedom.{p_end}
{synopt:{opt log:density}} Print the log of the density.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:mvtden} evaluates the probability density function of a specified multivariate t distribution at a given vector of quantiles.
Arbitrary quantiles, non-centrality parameters, scale matrices, and degrees of freedom are supported.
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Required}
{phang}
{opt x(numlist)} A numlist (vector) of quantiles at which to evaluate the probability density function.
{p_end}

{dlgtab:Optional}
{phang}
{opt del:ta(numlist)} A numlist (vector) giving the non-centrality parameters of the multivariate t distribution under consideration.
If specified, its length must be equal to the length of option {opt x}.
If left unspecified, it will default internally to the zero vector of the correct length.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the scale matrix of the multivariate t distribution under consideration.
If specified, It must be symmetric positive-definite,
and its number of rows (equivalently columns) must be equal to the length of option {opt x}.
If left unspecified, it will default internally to the identity matrix of the correct dimension.
{p_end}{break}{phang}
{opt df(#)} A real giving the number of degrees of freedom of the multivariate t distribution under consideration.
It must be either greater than or equal to zero, or missing.
Multivariate normal densities will be computed when it is equal to zero or is missing, using the method of {help mvnormalden}.
It defaults to 1.
{p_end}{break}{phang}
{opt log:density} If specified, this indicates that the log of the density (rather than the density itself) should be printed.
{p_end}

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt del:ta} or {opt s:igma}
{phang}
{stata mvtden, x(0, 0, 0)}

/// Example 2: Specifying {opt del:ta} and {opt s:igma}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata mvtden, x(0, 0, 0) delta(0.5, 1, 1.5) sigma(Sigma)}

/// Example 3: Requesting the log of the density with {opt log:density}
{phang}
{stata mat Sigma = (1, 0.25 \ 0.25, 1)}

{phang}
{stata mvtden, x(1, 1) delta(2, 2) sigma(Sigma) log}

/// Example 4: Requesting a multivariate normal density
{phang}
{stata mvtden, x(1, 1) delta(2, 2) sigma(Sigma) df(0) log}

{phang}
{stata mvnormalden, x(1, 1) mean(2, 2) sigma(Sigma) log}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mvtden} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars:}{p_end}
{synopt:{cmd:r(density)}} Computed density.{p_end}
{synopt:{cmd:r(log_density)}} Log of the computed density.{p_end}

{title:Authors}
{p}

Dr Michael J Grayling
Institute of Health & Society, Newcastle University, UK
Email: {browse "michael.grayling@newcastle.ac.uk":michael.grayling@newcastle.ac.uk}

Dr Adrian P Mander
MRC Biostatistics Unit, University of Cambridge, Cambridge, UK

{title:See also}

{bf:References:}

{phang}
Grayling MJ, Mander AP (2018) {browse "https://www.stata-journal.com/article.html?article=st0542":Calculations involving the multivariate normal and multivariate t distributions with and without truncation}. {it:Stata J} {bf:18}(4){bf::}826-43.

{phang}
Kotz S, Nadarajah S (2004) {it:Multivariate t distributions and their applications}. Cambridge University Press: Cambridge, UK.
  
{bf:Related commands:}

{help mvtnorm}       (for an overview of the functionality provided by {bf:mvtnorm})

Multivariate normal distribution

{help drawnorm}      (an official Stata command for multivariate normal random deviates)
{help invmvnormal}   ({bf:mvtnorm} command for multivariate normal quantiles)
{help lnmvnormalden} (an official Stata command for multivariate normal densities)
{help mvnormalcv}    (an official Stata command for the multivariate normal distribution function)
{help mvnormalden}   ({bf:mvtnorm} command for multivariate normal densities)
{help pmvnormal}     ({bf:mvtnorm} command for the multivariate normal distribution function)
{help rmvnormal}     ({bf:mvtnorm} command for multivariate normal random deviates)

Multivariate t distribution

{help invmvt}        ({bf:mvtnorm} command for multivariate t quantiles)
{help mvtden}        ({bf:mvtnorm} command for multivariate t densities)
{help mvt}           ({bf:mvtnorm} command for the multivariate t distribution function)
{help rmvt}          ({bf:mvtnorm} command for multivariate t random deviates)

Truncated multivariate normal distribution

{help invtmvnormal}  ({bf:mvtnorm} command for truncated multivariate normal quantiles)
{help rtmvnormal}    ({bf:mvtnorm} command for truncated multivariate normal random deviates)
{help tmvnormal}     ({bf:mvtnorm} command for the truncated multivariate normal distribution function)
{help tmvnormalden}  ({bf:mvtnorm} command for truncated multivariate normal densities)

Truncated multivariate t distribution

{help invtmvt}       ({bf:mvtnorm} command for truncated multivariate t quantiles)
{help rtmvt}         ({bf:mvtnorm} command for truncated multivariate t random deviates)
{help tmvt}          ({bf:mvtnorm} command for the truncated multivariate t distribution function)
{help tmvtden}       ({bf:mvtnorm} command for truncated multivariate t densities)
