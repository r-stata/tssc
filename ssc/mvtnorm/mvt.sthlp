{smcl}
{* *! version 1.7 03 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install mvt" "ssc install MVTNORM"}{...}
{vieweralsosee "Help mvt (if installed)" "help mvt"}{...}
{viewerjumpto "Syntax" "mvt##syntax"}{...}
{viewerjumpto "Description" "mvt##description"}{...}
{viewerjumpto "Options" "mvt##options"}{...}
{viewerjumpto "Remarks" "mvt##remarks"}{...}
{viewerjumpto "Examples" "mvt##examples"}{...}
{title:Title}
{title:Title}
{phang}
{bf:mvt} {hline 2} Multivariate t Distribution

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:mvt}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt low:er(numlist miss)}} Vector of lower integration limits.{p_end}
{synopt:{opt upp:er(numlist miss)}} Vector of upper integration limits.{p_end}
{synopt:{opt del:ta(numlist)}} Vector of non-centrality parameters.{p_end}
{synopt:{opt s:igma(string)}} Covariance matrix.{p_end}
{synopt:{opt df(#)}} Degrees of freedom.{p_end}
{synopt:{opt int:egrator(string)}} Method for evaluating required multivariate normal distribution function.{p_end}
{synopt:{opt shi:fts(#)}} Number of shifts of the Quasi-Monte Carlo integration algorithm.{p_end}
{synopt:{opt sam:ples(#)}} Number of samples in each shift of the Quasi-Monte Carlo integration algorithm.{p_end}
{synopt:{opt alp:ha(#)}} Value of the Monte Carlo confidence factor.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:mvt} computes the distribution function of the multivariate t distribution. Arbitrary integration limits, non-centrality parameters, scale matrices, and degrees of freedom are supported.
{p_end}

{pstd}
For one-dimensional multivariate t distributions it makes use of the functionality provided by {help t}. 
For multivariate t distributions of dimension two or more it utilises a Stata implementation of the algorithm given on page 50 of Genz and Bretz (2009):
a quasi-Monte Carlo integration algorithm over a randomised lattice after separation-of-variables has been performed.
In addition, it employs variable re-ordering in order to improve efficiency as suggested by Gibson {it:et al} (1994).
Note that unlike {help pmvnormal}, {cmd:mvt} is not yet vectorised, which may make its run time long compared to the corresponding multivariate normal command.
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

{dlgtab:Optional}
{phang}
{opt del:ta(numlist)} A numlist (vector) giving the non-centrality parameters of the multivariate t distribution under consideration.
If specified, its length must be equal to the length of option {opt low:er}.
If left unspecified, it will default internally to the zero vector of the correct length.
{p_end}{break}{phang}
{opt s:igma(string)} A string (matrix) giving the scale matrix of the multivariate t distribution under consideration.
If specified, it must be symmetric positive-definite, and its number of rows (equivalently columns) must be equal to the length of option {opt low:er}.
If left unspecified, it will default internally to the identity matrix of the correct dimension.
{p_end}{break}{phang}
{opt df(#)} A real giving the number of degrees of freedom of the multivariate t distribution under consideration.
It must be either greater than or equal to zero, or missing.
Multivariate normal distribution functions will be computed when it is equal to zero or is missing, using the method of {help pmvnormal} or {help mvnormalcv} depending on the value of {opt int:egrator}.
It defaults to 1.
{p_end}{break}{phang}
{opt int:egrator(string)} Only used when {opt df} is equal to zero or is missing.
It is then a string giving the method for evaluating the required multivariate normal distribution function.
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
{p_end}{break}{phang}
{opt alp:ha(#)} Not used when {opt df} is equal to zero or missing and {opt int:egrator} is equal to mvnormalcv.
It is a real giving the value of the Monte Carlo confidence factor, used to provide an estimate of the error in returned integral value.
It must be strictly positive.
Defaults to 3.
{p_end}

{marker examples}{...}
{title:Examples}

/// Example 1: Without specifying {opt del:ta} or {opt s:igma}
{phang} 
{stata mvt, lower(-2, -2, -2) upper(2, 2, 2)}

/// Example 2: Specifying {opt del:ta} and {opt s:igma}
{phang} 
{stata mat Sigma = (1, 0.5, 0.5 \ 0.5, 1, 0.5 \ 0.5, 0.5, 1)}

{phang} 
{stata mvt, lower(-2, -2, -2) upper(2, 2, 2) delta(0, 0, 0) sigma(Sigma)}

/// Example 3: Reducing the error using {opt sam:ples}
{phang} 
{stata mvt, lower(-2, -2, -2) upper(2, 2, 2) delta(0, 0, 0) sigma(Sigma) samples(10000)}

/// Example 4: Requesting multivariate normal distribution function
{phang}
{stata mvt, lower(-2, -2, -2) upper(2, 2, 2) delta(0, 0, 0) sigma(Sigma) df(0)}

{phang}
{stata pmvnormal, lower(-2, -2, -2) upper(2, 2, 2) mean(0, 0, 0) sigma(Sigma)}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mvt} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: scalars:}{p_end}
{synopt:{cmd:r(integral)}} Computed integral.{p_end}
{synopt:{cmd:r(error)}} Estimated error in the computed integral.{p_end}

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
