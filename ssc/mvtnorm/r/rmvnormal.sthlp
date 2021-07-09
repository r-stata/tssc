{smcl}
{* *! version 1.2 03 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install rmvnormal" "ssc install MVTNORM"}{...}
{vieweralsosee "Help rmvnormal (if installed)" "help rmvnormal"}{...}
{viewerjumpto "Syntax" "rmvnormal##syntax"}{...}
{viewerjumpto "Description" "rmvnormal##description"}{...}
{viewerjumpto "Options" "rmvnormal##options"}{...}
{viewerjumpto "Remarks" "rmvnormal##remarks"}{...}
{viewerjumpto "Examples" "rmvnormal##examples"}{...}
{title:Title}
{phang}
{bf:rmvnormal} {hline 2} Multivariate Normal Random Deviates

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:rmvnormal}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt n(#)}} Number of random deviates to generate.{p_end}
{synopt:{opt me:an(numlist)}} Mean vector.{p_end}
{synopt:{opt s:igma(string)}} Covariance matrix.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:rmvnormal} generates random deviates from a specified multivariate normal distribution.
Arbitrary means and covariance matrices are supported.
{p_end}

{pstd}
An official Stata command, {help drawnorm}, is available that provides similar functionality to {cmd:rmvnormal}.
It should in general be preferred; {cmd:rmvnormal} is provided within {bf:mvtnorm} only for completeness.
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Optional}
{phang}
{opt n(#)} An integer giving the number of random deviates to generate from the specified multivariate normal distribution.
It must be greater than or equal to one.
It defaults to 1.
{p_end}{break}{phang}
{opt me:an(numlist)} A numlist (vector) giving the mean of the multivariate normal distribution under consideration.
If left unspecified, it will default internally to the zero vector of the correct length when {opt s:igma} is specified, or the zero vector of length two when {opt s:igma} is unspecified.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the covariance matrix of the multivariate normal distribution under consideration.
If specified, it must be symmetric positive-definite, and if {opt me:an} is also specified, its number of rows (equivalently columns) must be equal to the length of option {opt me:an}.
If left unspecified, it will default internally to the identity matrix of the correct dimension when {opt me:an} is specified, or the identity matrix of dimension two when {opt me:an} is unspecified.
{p_end}

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt me:an} or {opt s:igma}
{phang}
{stata rmvnormal, n(10)}

/// Example 2: Specifying {opt me:an} and {opt s:igma}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata rmvnormal, n(25) mean(10, 20, 30) sigma(Sigma)}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rmvnormal} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrices:}{p_end}
{synopt:{cmd:r(rmvnormal)}} Generated random deviates.{p_end}

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
