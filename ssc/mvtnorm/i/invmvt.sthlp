{smcl}
{* *! version 1.4 03 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install invmvt" "ssc install MVTNORM"}{...}
{vieweralsosee "Help invmvt (if installed)" "help invmvt"}{...}
{viewerjumpto "Syntax" "invmvt##syntax"}{...}
{viewerjumpto "Description" "invmvt##description"}{...}
{viewerjumpto "Options" "invmvt##options"}{...}
{viewerjumpto "Remarks" "invmvt##remarks"}{...}
{viewerjumpto "Examples" "invmvt##examples"}{...}
{title:Title}
{phang}
{bf:invmvt} {hline 2} Quantiles of the Multivariate t Distribution

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:invmvt}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt p(#)}} Probability.{p_end}
{break}
{syntab:Optional}
{synopt:{opt del:ta(numlist)}} Vector of non-centrality parameters.{p_end}
{synopt:{opt s:igma(string)}} Covariance matrix.{p_end}
{synopt:{opt df(#)}} Degrees of freedom.{p_end}
{synopt:{opt t:ail(string)}} Which type of quantile should be computed.{p_end}
{synopt:{opt max:_iter(string)}} Maximum number of allowed iterations in the root-finding algorithm.{p_end}
{synopt:{opt tol:erance(string)}} Desired tolerance in the root-finding algorithm.{p_end}
{synopt:{opt int:egrator(string)}} Method for evaluating required multivariate normal distribution functions.{p_end}
{synopt:{opt shi:fts(#)}} Number of shifts of the Quasi-Monte Carlo integration algorithm.{p_end}
{synopt:{opt sam:ples(#)}} Number of samples in each shift of the Quasi-Monte Carlo integration algorithm.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:invmvt} computes equicoordinate quantiles of a specified multivariate t distribution through Brent's root finding algorithm (Brent, 1973).
Arbitrary non-centrality parameters, scale matrices, and degrees of freedom are supported.
{p_end}

{pstd}
For one-dimensional multivariate t distributions it makes use of the functionality provided by {help invt}.
For multivariate t distributions of dimension two or more, it evaluates requisite multivariate t distribution functions using the approach of {help mvt}.
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Required}
{phang}
{opt p(#)} A real giving the desired tail probability. It must be between zero and one inclusive.

{dlgtab:Optional}
{phang}
{opt del:ta(numlist)} A numlist (vector) giving the non-centrality parameters of the multivariate t distribution under consideration.
If left unspecified, it will default internally to the zero vector of the correct length when {opt s:igma} is specified, or the zero vector of length two when {opt s:igma} is unspecified.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the scale matrix of the multivariate t distribution under consideration.
If specified, it must be symmetric positive-definite, and if {opt del:ta} is also specified, its number of rows (equivalently columns) must be equal to the length of option {opt me:an}.
If left unspecified, it will default internally to the identity matrix of the correct dimension when {opt del:ta} is specified, or the identity matrix of dimension two when {opt del:ta} is unspecified.
{p_end}{break}{phang}
{opt df(#)} A real giving the number of degrees of freedom of the multivariate t distribution under consideration.
It must be either greater than or equal to zero, or missing.
Multivariate normal distribution functions will be computed when it is equal to zero or is missing, using the method of {help invmvnormal}.
{p_end}{break}{phang}
{opt t:ail(string)} A string specifying which type of quantile should be computed.
It must be either lower, upper, or both.
lower gives the x such that P(X <= x) = p, upper such that P(X >= x) = p, and both such that P(-x <= X <= x) = p.
It left unspecified, it defaults internally to lower.
{p_end}{break}{phang}
{opt max:_iter(#)} An integer giving the maximum allowed number of iterations in the root-finding algorithm.
It must be greater than or equal to one.
It defaults to 1000000.
{p_end}{break}{phang}
{opt tol:erance(#)} A real giving the desired tolerance in the root-finding algorithm.
It must be strictly positive.
It defaults to 0.000001.
{p_end}{break}{phang}
{opt int:egrator(string)} Only used when {opt df} is equal to zero or is missing.
It is then a string giving the method for evaluating the required multivariate normal distribution functions.
It must be either pmvnormal (to use the method from {help pmvnormal}) or mvnormal (to use {help mvnormalcv} as released in Stata 15).
If left unspecified, it will default internally to pmvnormal.
{p_end}{break}{phang}
{opt shi:fts(#)} Not used when {opt df} is equal to zero or missing and {opt int:egrator} is equal to mvnormalcv.
It is an integer giving the number of shifts to use in the Quasi-Monte Carlo integration algorithm.
It must be strictly positive.
Theoretically, increasing {opt shi:fts} will increase run-time but reduce the error in the returned value of the integral.
It defaults to 12.
{p_end}{break}{phang}
{opt sam:ples(#)} Not used when {opt df} is equal to zero or missing and {opt int:egrator} is equal to mvnormalcv.
It is an integer giving the number of samples to use in each shift of the Quasi-Monte Carlo integration algorithm.
It must be greater than or equal to 1.
Theoretically, increasing {opt sam:ples} will increase run-time but reduce the error in the returned value of the integral.
It defaults to 1000.
{p_end}

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt del:ta} or {opt s:igma}
{phang} 
{stata invmvt, p(0.95)}

/// Example 2: Specifying {opt del:ta}, {opt s:igma}, and {opt t:ail}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata invmvt, p(0.95) delta(1, 1, 1) sigma(Sigma) tail(upper)}

/// Example 2: Requesting multivariate normal quantile
{phang} 
{stata invmvt, p(0.95) delta(1, 1, 1) sigma(Sigma) tail(upper) df(0)}

{phang} 
{stata invmvnormal, p(0.95) mean(1, 1, 1) sigma(Sigma) tail(upper)}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:invmvt} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars:}{p_end}
{synopt:{cmd:r(quantile)}} Computed quantile.{p_end}
{synopt:{cmd:r(error)}} Estimated error in the computed quantile.{p_end}
{synopt:{cmd:r(flag)}} Flag indicating the progress of the root-finding algorithm. Non-zero values indicate a potential problem.{p_end}
{synopt:{cmd:r(fquantile)}} Value of the objective function at the computed quantile.{p_end}
{synopt:{cmd:r(iterations)}} Number of iterations used by the root-finding algorithm.{p_end}

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
Brent R (1973) {it:Algorithms for minimization without derivatives}. Prentice-Hall: New Jersey, US.

{phang}
Genz A, Bretz F (2009) {it:Computation of multivariate normal and t probabilities}. Lecture Notes in Statistics, Vol 195. Springer-Verlag: Heidelberg, Germany.

{phang}
Gibson GJ, Glasbey CA, Elston DA (1994) Monte Carlo evaluation of multivariate normal integrals and sensitivity to variate ordering.
In {it:Advances in numerical methods and applications}, ed Dimov IT, Sendov B, Vassilevski PS, 120-6. River Edge: World Scientific Publishing.

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
