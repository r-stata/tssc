{smcl}
{* *! version 1.3 03 Jan 2019}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install mvnormalden" "ssc install MVTNORM"}{...}
{vieweralsosee "Help mvnormalden (if installed)" "help mvnormalden"}{...}
{viewerjumpto "Syntax" "mvnormalden##syntax"}{...}
{viewerjumpto "Description" "mvnormalden##description"}{...}
{viewerjumpto "Options" "mvnormalden##options"}{...}
{viewerjumpto "Remarks" "mvnormalden##remarks"}{...}
{viewerjumpto "Examples" "mvnormalden##examples"}{...}
{title:Title}
{phang}
{bf:mvnormalden} {hline 2} Multivariate Normal Density

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:mvnormalden}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt x(numlist)}} Vector of quantiles.{p_end}
{break}
{syntab:Optional}
{synopt:{opt me:an(numlist)}} Mean vector.{p_end}
{synopt:{opt s:igma(string)}} Covariance matrix.{p_end}
{synopt:{opt log:density}} Print the log of the density.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:mvnormalden} evaluates the probability density function of a specified multivariate normal distribution at a given vector of quantiles.
Arbitrary quantiles, means, and covariance matrices are supported.
{p_end}

{pstd}
An official Stata command, {help lnmvnormalden}, is available that provides similar functionality to {cmd:mvnormalden}.
It should in general be preferred; {cmd:mvnormalden} is provided within {bf:mvtnorm} only for completeness.
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Required}
{phang}
{opt x(numlist)} A numlist (vector) of quantiles at which to evaluate the probability density function.
{p_end}

{dlgtab:Optional}
{phang}
{opt me:an(numlist)} A numlist (vector) giving the mean of the multivariate normal distribution under consideration.
If specified, its length must be equal to the length of option {opt x}.
If left unspecified, it will default internally to the zero vector of the correct length.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the covariance matrix of the multivariate normal distribution under consideration.
If specified, It must be symmetric positive-definite, and its number of rows (equivalently columns) must be equal to the length of option {opt x}.
If left unspecified, it will default internally to the identity matrix of the correct dimension.
{p_end}{break}{phang}
{opt log:density} If specified, this indicates that the log of the density (rather than the density itself) should be printed.
{p_end}

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt me:an} or {opt s:igma}
{phang}
{stata mvnormalden, x(0, 0, 0)}

/// Example 2: Specifying {opt me:an} and {opt s:igma}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata mvnormalden, x(0, 0, 0) mean(0.5, 1, 1.5) sigma(Sigma)}

/// Example 3: Requesting the log of the density with {opt log:density}
{phang}
{stata mat Sigma = (1, 0.25 \ 0.25, 1)}

{phang}
{stata mvnormalden, x(1, 1) mean(2, 2) sigma(Sigma) log}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mvnormalden} stores the following in {cmd:r()}:

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
Tong YL (2012) {it:The multivariate normal distribution}. Springer-Verlag: New York, US.
  
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
