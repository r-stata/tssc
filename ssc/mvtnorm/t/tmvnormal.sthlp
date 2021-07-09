{smcl}
{* *! version 1.1 03 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install tmvnormal" "ssc install MVTNORM"}{...}
{vieweralsosee "Help tmvnormal (if installed)" "help tmvnormal"}{...}
{viewerjumpto "Syntax" “tmvnormal##syntax"}{...}
{viewerjumpto "Description" “tmvnormal##description"}{...}
{viewerjumpto "Options" “tmvnormal##options"}{...}
{viewerjumpto "Remarks" “tmvnormal##remarks"}{...}
{viewerjumpto "Examples" “tmvnormal##examples"}{...}
{title:Title}
{phang}
{bf:tmvnormal} {hline 2} Truncated Multivariate Normal Distribution

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:tmvnormal}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt low:er(numlist miss)}} Vector of lower integration limits.{p_end}
{synopt:{opt upp:er(numlist miss)}} Vector of upper integration limits.{p_end}
{synopt:{opt lowert:runcation(numlist miss)}} Vector of lower truncation points.{p_end}
{synopt:{opt uppert:runcation(numlist miss)}} Vector of upper truncation points.{p_end}
{break}
{syntab:Optional}
{synopt:{opt me:an(numlist)}} Mean vector.{p_end}
{synopt:{opt s:igma(string)}} Covariance matrix.{p_end}
{synopt:{opt int:egrator(string)}} Method for evaluating required multivariate normal distribution functions.{p_end}
{synopt:{opt shi:fts(#)}} Number of shifts of the Quasi-Monte Carlo integration algorithm.{p_end}
{synopt:{opt sam:ples(#)}} Number of samples in each shift of the Quasi-Monte Carlo integration algorithm.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:tmvnormal} evaluates the distribution function of a specified truncated multivariate normal distribution.
Arbitrary integration limits, means, covariance matrices, and truncation points are supported.
{p_end}

{pstd}
Support is available to evaluate the requisite multivariate normal distribution functions using the approaches of both {help pmvnormal} and {help mvnormalcv} (see option {opt int:egrator}).
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Required}
{phang}
{opt low:er(numlist miss)} A numlist (vector) giving the lower integration limits.
Missing values are allowed, as . can be used to indicate a value is -Infinity.
{p_end}{break}{phang}
{opt upp:er(numlist miss)} A numlist (vector) giving the upper integration limits.
Its length must be equal to the length of {opt low:er}, and the elements of {opt upp:er} must be strictly greater than the corresponding elements in {opt low:er}.
Missing values are allowed, as . can be used to indicate a value is +Infinity.
{p_end}{break}{phang}
{opt lowert:runcation(numlist miss)} A numlist (vector) giving the lower truncation points for the truncated multivariate normal distribution under consideration.
Its length must be equal to the length of option {opt low:er}.
Missing values are allowed, as . can be used to indicated a value is -Infinity.
{p_end}{break}{phang}
{opt uppert:runcation(numlist miss)} A numlist (vector) giving the upper truncation points for the truncated multivariate normal distribution under consideration.
Its length must be equal to the length of option {opt low:er}, and the elements of {opt uppert:runcation} must be strictly greater than the corresponding elements in {opt lowert:runcation}.
Missing values are allowed, as . can be used to indicated a value is +Infinity.
{p_end}

{dlgtab:Optional}
{phang}
{opt me:an(numlist)} A numlist (vector) giving the mean of the non-truncated multivariate normal distribution from which the truncated multivariate normal distribution under consideration is constructed.
If specified, its length must be equal to the length of option {opt low:er}.
If left unspecified, it will default internally to the zero vector of the correct length.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the covariance matrix of the non-truncated multivariate normal distribution from which the truncated multivariate normal distribution under consideration is constructed.
If specified, It must be symmetric positive-definite, and its number of rows (equivalently columns) must be equal to the length of option {opt low:er}.
If left unspecified, it will default internally to the identity matrix of the correct dimension.
{p_end}{break}{phang}
{opt int:egrator(string)} A string giving the method for evaluating the required multivariate normal distribution functions.
It must be either pmvnormal (to use the method from {help pmvnormal}) or mvnormal (to use {help mvnormalcv} as released in Stata 15).
If left unspecified, it will default internally to pmvnormal.
{p_end}{break}{phang}
{opt shi:fts(#)} Only used when {opt int:egrator} is set to pmvnormal.
It is then an integer giving the number of shifts to use in the Quasi-Monte Carlo integration algorithm.
It must be strictly positive.
Theoretically, increasing {opt shi:fts} will increase run-time but reduce the error in the returned value of the integral.
It defaults to 12.
{p_end}{break}{phang}
{opt sam:ples(#)} Only used when {opt int:egrator} is set to pmvnormal.
It is then an integer giving the number of samples to use in each shift of the Quasi-Monte Carlo integration algorithm.
It must be strictly positive.
Theoretically, increasing {opt sam:ples} will increase run-time but reduce the error in the returned value of the integral.
It defaults to 1000.

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt me:an} or {opt s:igma}
{phang} 
{stata tmvnormal, lower(-1, -1, -1) upper(1, 1, 1) lowertruncation(-2, -2, -2) uppertruncation(2, 2, 2)}

/// Example 2: Specifying {opt me:an} and {opt s:igma}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata tmvnormal, lower(-1, -1, -1) upper(1, 1, 1) lowertruncation(-2, -2, -2) uppertruncation(2, 2, 2) mean(1, 1, 1) sigma(Sigma)}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:tmvnormal} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars:}{p_end}
{synopt:{cmd:r(integral)}} Computed integral.{p_end}

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
Genz A, Bretz F (2009) {it:Computation of multivariate normal and t probabilities}. Lecture Notes in Statistics, Vol 195. Springer-Verlag: Heidelberg, Germany.

{phang}
Gibson GJ, Glasbey CA, Elston DA (1994) Monte Carlo evaluation of multivariate normal integrals and sensitivity to variate ordering.
In {it:Advances in numerical methods and applications}, ed Dimov IT, Sendov B, Vassilevski PS, 120-6. River Edge: World Scientific Publishing.

{phang}
Grayling MJ, Mander AP (2018) {browse "https://www.stata-journal.com/article.html?article=st0542":Calculations involving the multivariate normal and multivariate t distributions with and without truncation}. {it:Stata J} {bf:18}(4){bf::}826-43.

{phang}
Tong YL (2012) {it:The Multivariate Normal Distribution}. Springer-Verlag: New York, US.

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
