{smcl}
{* *! version 1.1 03 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install rtmvnormal" "ssc install MVTNORM"}{...}
{vieweralsosee "Help rtmvnormal (if installed)" "help rtmvnormal"}{...}
{viewerjumpto "Syntax" "rtmvnormal##syntax"}{...}
{viewerjumpto "Description" "rtmvnormal##description"}{...}
{viewerjumpto "Options" "rtmvnormal##options"}{...}
{viewerjumpto "Remarks" "rtmvnormal##remarks"}{...}
{viewerjumpto "Examples" "rtmvnormal##examples"}{...}
{title:Title}
{phang}
{bf:rtmvnormal} {hline 2} Truncated Multivariate Normal Random Deviates

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:rtmvnormal}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt lowert:runcation(numlist miss)}} Vector of lower truncation points.{p_end}
{synopt:{opt uppert:runcation(numlist miss)}} Vector of upper truncation points.{p_end}
{break}
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
{cmd:rtmvnormal} generates random deviates from a specified truncated multivariate normal distribution.
Arbitrary means, covariance matrices, and truncation points are supported.
{p_end}

{pstd}
It achieves the required generation using accept-reject sampling of random values generated from a corresponding multivariate normal distribution, using the method of {help rmvnormal}.
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Required}
{phang}
{opt lowert:runcation(numlist miss)} A numlist (vector) giving the lower truncation points for the truncated multivariate normal distribution under consideration.
Missing values are allowed, as . can be used to indicated a value is -Infinity.
{p_end}{break}{phang}
{opt uppert:runcation(numlist miss)} A numlist (vector) giving the upper truncation points for the truncated multivariate normal distribution under consideration.
Its length must be equal to the length of option {opt lowert:runcation}, and the elements of {opt uppert:runcation} must be strictly greater than the corresponding elements in {opt lowert:runcation}.
Missing values are allowed, as . can be used to indicated a value is +Infinity.

{dlgtab:Optional}
{phang}
{opt n(#)} An integer giving the number of random deviates to generate from the specified truncated multivariate normal distribution.
It must be greater than or equal to one.
It defaults to 1.
{p_end}{break}{phang}
{opt me:an(numlist)} A numlist (vector) giving the mean of the non-truncated multivariate normal distribution from which the truncated multivariate normal distribution under consideration is constructed.
If left unspecified, it will default internally to the zero vector of the correct length when {opt s:igma} is specified, or the zero vector of length two when {opt s:igma} is unspecified.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the covariance matrix of the non-truncated multivariate normal distribution from which the truncated multivariate normal distribution under consideration is constructed.
If specified, it must be symmetric positive-definite, and if {opt me:an} is also specified, its number of rows (equivalently columns) must be equal to the length of option {opt me:an}.
If left unspecified, it will default internally to the identity matrix of the correct dimension when {opt me:an} is specified, or the identity matrix of dimension two when {opt me:an} is unspecified.

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt me:an} or {opt s:igma}
{phang}
{stata rtmvnormal, lowertruncation(-2, -2, -2) uppertruncation(2, 2, 2) n(10)}

/// Example 2: Specifying {opt me:an} and {opt s:igma}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata rtmvnormal, lowertruncation(-2, -2, -2) uppertruncation(2, 2, 2) n(25) mean(1, 2, 3) sigma(Sigma)}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rtmvnormal} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrices:}{p_end}
{synopt:{cmd:r(rtmvnormal)}} Generated random deviates.{p_end}

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
