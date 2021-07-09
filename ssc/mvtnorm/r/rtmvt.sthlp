{smcl}
{* *! version 1.1 03 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install rtmvt" "ssc install MVTNORM"}{...}
{vieweralsosee "Help rtmvt (if installed)" "help rtmvt"}{...}
{viewerjumpto "Syntax" "rtmvt##syntax"}{...}
{viewerjumpto "Description" "rtmvt##description"}{...}
{viewerjumpto "Options" "rtmvt##options"}{...}
{viewerjumpto "Remarks" "rtmvt##remarks"}{...}
{viewerjumpto "Examples" "rtmvt##examples"}{...}
{title:Title}
{phang}
{bf:rtmvt} {hline 2} Truncated Multivariate t Random Deviates

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:rtmvt}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt lowert:runcation(numlist miss)}} Vector of lower truncation points.{p_end}
{synopt:{opt uppert:runcation(numlist miss)}} Vector of upper truncation points.{p_end}
{break}
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
{cmd:rtmvt} generates random deviates from a specified truncated multivariate t distribution.
Arbitrary non-centrality parameters, scale matrices, degrees of freedom, and truncation points are supported.
{p_end}

{pstd}
It achieves the required generation using accept-reject sampling of random values generated from a corresponding multivariate t distribution, using the method of {help rmvt}.
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Required}
{phang}
{opt lowert:runcation(numlist miss)} A numlist (vector) giving the lower truncation points for the truncated multivariate t distribution under consideration. 
Missing values are allowed, as . can be used to indicated a value is -Infinity.
{p_end}{break}{phang}
{opt uppert:runcation(numlist miss)} A numlist (vector) giving the upper truncation points for the truncated multivariate t distribution under consideration. 
Its length must be equal to the length of option {opt lowert:runcation}, and the elements of {opt uppert:runcation} must be strictly greater than the corresponding elements in {opt lowert:runcation}.
Missing values are allowed, as . can be used to indicated a value is +Infinity.

{dlgtab:Optional}
{phang}
{opt n(#)} An integer giving the number of random deviates to generate from the specified truncated multivariate t distribution.
It must be greater than or equal to one.
It defaults to 1.
{p_end}{break}{phang}
{opt del:ta(numlist)} A numlist (vector) giving the non-centrality parameters of the non-truncated multivariate t distribution from which the truncated multivariate t distribution under consideration is constructed.
If specified, its length must be equal to the length of option {opt lowert:runcation}.
If left unspecified, it will default internally to the zero vector of the correct length.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the scale matrix of the non-truncated multivariate t distribution from which the truncated multivariate t distribution under consideration is constructed.
If specified, it must be symmetric positive-definite, and its number of rows (equivalently columns) must be equal to the length of option {opt lowert:runcation}.
If left unspecified, it will default internally to the identity matrix of the correct dimension.
{p_end}{break}{phang}
{opt df(#)} A real giving the number of degrees of freedom of the non-truncated multivariate t distribution from which the truncated multivariate t distribution under consideration is constructed.
It must be either greater than or equal to zero, or missing.
Truncated multivariate normal random deviates will be computed when it is equal to zero or is missing, using the method of {help tmvnormalden}.
It defaults to 1.
{p_end}

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt del:ta} or {opt s:igma}
{phang}
{stata rtmvt, lowertruncation(-2, -2, -2) uppertruncation(2, 2, 2) n(10)}

/// Example 2: Specifying {opt del:ta} and {opt s:igma}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata rtmvt, lowertruncation(-2, -2, -2) uppertruncation(2, 2, 2) n(25) delta(1, 2, 3) sigma(Sigma)}

/// Example 4: Requesting truncated multivariate normal random deviates
{phang}
{stata rtmvt, lowertruncation(-2, -2, -2) uppertruncation(2, 2, 2) n(20) delta(1, 1, 1) sigma(Sigma) df(0)}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rtmvt} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrices:}{p_end}
{synopt:{cmd:r(rtmvt)}} Generated random deviates.{p_end}

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
