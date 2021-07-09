{smcl}
{* *! version 1.3 03 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install rmvt" "ssc install MVTNORM"}{...}
{vieweralsosee "Help rmvt (if installed)" "help rmvt”}{...}
{viewerjumpto "Syntax" "rmvt##syntax"}{...}
{viewerjumpto "Description" "rmvt##description"}{...}
{viewerjumpto "Options" "rmvt##options"}{...}
{viewerjumpto "Remarks" "rmvt##remarks"}{...}
{viewerjumpto "Examples" "rmvt##examples"}{...}
{title:Title}
{phang}
{bf:rmvnormal} {hline 2} Multivariate t Random Deviates

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:rmvt}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt n(#)}} Number of random deviates to generate.{p_end}
{synopt:{opt del:ta(numlist)}} Vector of non-centrality parameters.{p_end}
{synopt:{opt s:igma(string)}} Scale matrix.{p_end}
{synopt:{opt df(#)}} Degrees of freedom.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:rmvt} generates random deviates from a specified multivariate t distribution.
Arbitrary non-centrality parameters, scale matrices, and degrees of freedom are supported.
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Optional}
{phang}
{opt n(#)} An integer giving the number of random deviates to generate from the specified multivariate t distribution.
It must be greater than or equal to one.
It defaults to 1.
{p_end}{break}{phang}
{opt del:ta(numlist)} A numlist (vector) giving the non-centrality parameters of the multivariate t distribution under consideration.
If left unspecified, it will default internally to the zero vector of the correct length when {opt s:igma} is specified, or the zero vector of length two when {opt s:igma} is unspecified.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the scale matrix of the multivariate t distribution under consideration.
If specified, it must be symmetric positive-definite, and if {opt del:ta} is also specified, its number of rows (equivalently columns) must be equal to the length of option {opt del:ta}.
If left unspecified, it will default internally to the identity matrix of the correct dimension when {opt del:ta} is specified, or the identity matrix of dimension two when {opt del:ta} is unspecified.
{p_end}{break}{phang}
{opt df(#)} A real giving the number of degrees of freedom of the multivariate t distribution under consideration.
It must be either greater than or equal to zero, or missing.
Multivariate normal random deviates will be computed when it is equal to zero or is missing, using the method of {help rmvnormal}.
It defaults to 1.
{p_end}

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt del:ta} or {opt s:igma}
{phang}
{stata rmvt, n(10)}

/// Example 2: Specifying {opt del:ta} and {opt s:igma}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata rmvt, n(25) delta(10, 20, 30) sigma(Sigma)}

/// Example 4: Requesting multivariate normal random deviates
{phang}
{stata rmvt, n(20) delta(1, 1, 1) sigma(Sigma) df(0)}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rmvt} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrices:}{p_end}
{synopt:{cmd:r(rmvt)}} Generated random deviates.{p_end}

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
