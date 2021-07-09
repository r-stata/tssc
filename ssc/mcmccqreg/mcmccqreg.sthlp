{smcl}
{* 29May2013}{...}
{cmd:help mcmccqreg}
{hline}

{title:Title}

{p2colset 5 20 29 2}{...}
{p2col :{hi:mcmccqreg} {hline 2}}Powell's mcmc-simulated censored quantile regression{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:mcmccqreg}
{depvar}
[{indepvars}] {ifin} {cmd:,}
[{opth censor:var(varname)}
 {opt tau(#)}
 {opt draws(#)}
 {opt burn(#)}
 {opt thin(#)}
 {opt arate(#)}
 {opt sampler(string)}
 {opt dampparm(#)}
 {opt from(rowvector)}
 {opt fromv:ariance(matrix)}
 {opt jumble}
 {opt noisy}
 {opt saving(filename)}
 {opt replace}
 {opt median}
 ]

{title:Description}

{pstd}
{cmd:mcmccqreg} can be used to "fit" Powell's (1984, 1986) censored median regression model, or, in more general terms
censored quantile models, using adaptive Markov chain Monte Carlo sampling from the conditional parameter
distribution. The basis for the method is discussed in some detail in 
Chernozhukov and Hong (2003), and an intuitive, low-level sketch is given in Baker (2013). 

{pstd} {cmd:mcmccqreg} allows construction of what Chernozhukov and Hong (2003) refer to as
a Laplacian estimator of the censored quantile regression model. The joint distribution of the parameters
is simulated using adaptive MCMC (Markov chain Monte Carlo) methods through application of the mata package {cmd: amcmc()}
({help mf_amcmc:help mf_amcmc} or {help mata amcmc(): help mata amcmc()} from within the Mata system if installed). 
{cmd:mcmccqreg} produces parameter estimates, but these
"estimates" are in fact summary statistics from draws from the distribution. 
Detailed analysis of the draws remains in the hands of the user. 

{title:Syntax}

{pstd}
{cmd:mcmccqreg} is invoked in the usual way - the command name, followed by the 
dependent variable, followed by the independent variables.
No further information need be specified, but users will in virtually every case want to change default settings for the adaptive 
Markov Chain Monte Carlo draws - information pertaining to the number of draws, how frequently draws are accepted,
which draws are to be retained upon completion of the algorithm, etc. Default values are described below.

{title:Options}

{phang}
{opth censor:var(varname)} Specifies the name of the (left) censoring variable. The censoring variable can vary by observation. If this option
is not specified, it is assumed that the censoring point for all observations is zero. 

{phang}
{opth tau(#)} specifies the quantile of interest and should be between zero and one. In the event that the user chooses a value of {opt tau(#)}
that is too low, in the sense that all observations at this quantile are censored, a cautioning message is produced, but
drawing nonetheless proceeds. The mnemonic "tau" is used in analogy to the ancillary argument of the check function used to define the 
objective function in Chernozhukov and Hong (2003). 

{phang}
{opth draws(#)} specifies the number of draws that are to be taken from the joint parameter distribution implied by the model.
The default is 1000.

{phang}
{opth burn(#)} specifies the length of the burn-in period; the first # draws are discarded upon completion 
of the algorithm and before further results
are computed. The default is 0.

{phang}
{opth thin(#)} specifies that only every #th draw is to be retained, so if {cmd:thin(3)} is specified, only every third draw is retained.
This option can be used to ease autocorrelation in the resulting draws, as can the option {opt jumble}, which randomly mixes draws. 
Both options may be applied.

{phang}
{opth arate(#)} specifies the desired acceptance rate of the adaptive MCMC drawing, and should be a number between zero and one, but 
is typically in the range .234 to .4 - see Baker (2013) for details. The default is .234. 

{phang}
{opth sampler(string)} specifies the type of sampler used. It may be set to either
{it:global} or {it:mwg}. The default is {it:global}, which means that proposed draws
are drawn all at once; if {it:mwg} - an acronym for "metropolis within Gibbs" - is instead chosen, 
each random parameter is drawn separately as an independent
step conditional on other random parameters in a nested Gibbs step. The default is {it:global}, but 
{it:mwg} might be useful in situations in which initial values are poorly scaled. The workings of 
these options are described in greater detail
in Baker (2013).

{phang}
{opt dampparm(#)} is a parameter that controls how aggressively the proposal distribution is adapted
as the adaptive MCMC drawing continues. If set close to one, adaptation is agressive in its early phases 
in trying to achieve the acceptance rate specified
in {opt arate(#)}. If set closer to zero, adaptation is more gradual. 

{phang}
{opth from(string)} specifies a row vector of starting values for parameters in order. 
In the even that these are not specified, starting
values are obtained via linear regression {manhelp R regress}. 

{phang}
{opth fromv:ariance(string)} specifies a covariance matrix for the draws. {opth from(string)} can be specified without this,
in which event a covariance matrix scaled to initial regression parameters is used.  

{phang}
{opth saving(string)} specifies a location to store the draws from the distribution. The file will contain just the draws after any burn in period
or thinning of values is applied. {opt replace} specifies that an existing file is to be overwritten, while {opt append} specifies that
an existing file is to be appended, which might be useful if the user wishes to combine results from multiple runs from different
starting points. 

{phang}
{opt noisy} specifies that a dot be produced every time a complete pass through the algorithm is finished. After 50 iterations, a "function value"
{it:ln_fc(p)} will be produced, which gives the joint log of the value of the posterior choice probabilities evaluated at the latest parameters. While
not an objective function per se, the author has found that drift in the value of this function indicates that the algorithm has not yet converged
or other problems.

{phang}
{opt median} specifies that the criterion function described in Powell (1984) be used instead of the more general form described in 
Chernozhukov and Hong (2003). Results are the same as if tau(.5) had been specified and the more complex objective function had been multiplied
by a factor of two. 

{title:Examples}

{phang}
Estimating a censored quantile model at the 60% quantile. 
The censoring value defaults to zero. 20000 draws are taken, the first 999 draws are dropped, results are jumbled, and every fifth draw is kept.   
The first 1000 draws are dropped, and then every fifth draw is retained. Draws are saved as {bf: draws.dta}:{p_end}

     {cmd}. webuse laborsub, clear
	 {res}{txt}
     {cmd}. mcmccqreg whrs kl6 k618, tau(.6) saving(draws) replace thin(5) burn(999) draws(20000) jumble
	 {res}{txt}
	 
Same as above, using a metropolis-within-gibbs sampler, and with an explicit censoring variable:

     {cmd}. webuse laborsub, clear
	 {res}{txt}
	 {cmd}. gen c=0
	 {rest}{txt}
     {cmd}. mcmccqreg whrs kl6 k618, tau(.6) sampler("mwg") censorvar(c) saving(draws) replace thin(5) burn(999) draws(20000) jumble
	 {res}{txt}
	 
Powell's (1984) median estimator:

     {cmd}. webuse laborsub, clear
	 {res}{txt}
     {cmd}. mcmccqreg whrs kl6 k618, median sampler("mwg") censorvar(c) saving(draws) replace thin(5) burn(999) draws(20000) jumble
	 {res}{txt}

As a last example, it is sometimes useful to estimate a preliminary model using metropolis-within-gibbs sampling, which can often
find the right range for parameters from not-necessarily-great starting values, and then proceed
using a global sampler, which can be much faster. These general ideas are sketched in Baker (2013):

     {cmd}. webuse laborsub, clear
     {res}{txt}
     {cmd}. quietly mcmccqreg whrs kl6 k618, median sampler("mwg") saving(draws) replace thin(5) burn(999) draws(20000) jumble
	 {res}{txt}
     {cmd}. mat beta=e(b)
	 {res}{txt}
     {cmd}. mat V=e(V)
     {res}{txt}
     {cmd}. mcmccqreg whrs kl6 k618, median from(beta) fromv(V) sampler("global") saving(draws) replace thin(5) burn(999) draws(20000) jumble
	 
{title:Saved results}

{pstd}
{cmd:mcmccqreg} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}{txt}number of observations{p_end}
{synopt:{cmd:e(df_r)}}{txt}Degrees of freedom {p_end}
{synopt:{cmd:e(draws)}}{txt}Number of draws{p_end}
{synopt:{cmd:e(burn)}}{txt}Burn-in observations{p_end}
{synopt:{cmd:e(thin)}}{txt}Thinning parameter{p_end}
{synopt:{cmd:e(damper)}}{txt}Damping parameter {p_end}
{synopt:{cmd:e(opt_arate)}}{txt}Desired acceptance rate{p_end}
{synopt:{cmd:e(arates_mean)}}{txt}Acceptance rate average (multiple rates only if mwg sampler used){p_end}
{synopt:{cmd:e(arates_max)}}{txt}Max. acceptance rate for parameters{p_end}
{synopt:{cmd:e(arates_min)}}{txt}Min. acceptance rate for parameters{p_end}
{synopt:{cmd:e(draws_retained)}}{txt}Draws retained after burn-in and thinning {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(saving)}}{txt}File containing results{p_end}
{synopt:{cmd:e(sampler)}}{txt}Sampler type {p_end}
{synopt:{cmd:e(depvar)}}Dependent variable{p_end}
{synopt:{cmd:e(indepvars)}}Independent variables{p_end}
{synopt:{cmd:e(cmd)}}"mcmccqreg"{p_end}
{synopt:{cmd:e(title)}}"Powell's mcmc-estimated censored quantile estimator"{p_end}
{synopt:{cmd:e(properties)}}"b V"{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}mean parameter values{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of parameters{p_end}
{synopt:{cmd:e(V_init)}}Initial variance covariance matrix of random parameters{p_end}
{synopt:{cmd:e(b_init)}}Initial mean vector of random parameters{p_end}
{synopt:{cmd:e(arates)}}Row vector of acceptance rates of fixed parameters{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}
		
{title:Comments}

{pstd}
The basic algorithms used in drawing are described in some detail in Baker (2013). The user might gain a fuller understanding of the options
{opt arate}, {opt damper}, {opt draws}, {opt burn} and other options controlling adaptation of the proposal distribution
from a reading of this document. 

{cmd:mcmccqreg} requires that the package of Mata functions {cmd:amcmc} be installed, and also requires installation of Ben Jann's {cmd:moremata}
set of extended Mata functions. 

{pstd}
{bf:{it:Caution!!!}} - While summary statistics of the results of a drawing are presented in the usual Stata format, 
{cmd:mcmccqreg}  provides no guidance as to how one should actually go about selecting the number of draws, how draws should be processed,
monitoring convergence of the algorithm, or presenting and interpreting results. Even though the methods are technically not Bayesian
, one would do well to consult 
a good source on Bayesian methods such as Gelman et. al. (2009) concerning the practical aspects of 
processing results from draws. Of course, Stata provides a wealth of tools for summarizing and plotting
the results of a drawing. 

{title:Reference}

{phang}Baker, M. J. 2013. {it:Adaptive Markov chain Monte Carlo sampling and estimation in Mata}. {browse " http://EconPapers.repec.org/RePEc:htr:hcecon:440":Hunter College working paper 440}.

{phang}Chernozhukov, V. and H. Hong. 2003. An MCMC approach to classical estimation. {it: Journal of Econometrics} 115, 293-346.

{phang}Gelman, A., J. B. Carlin, H. S. Stern, and D. B. Rubin. 2009. {it:Bayesian data analysis, 2nd. ed.} Boca Raton: Chapman and Hall. 

{phang}Powell, J. L. 1984. Least absolute deviations estimation for the censored regression model
{it:Journal of Econometrics} 25, 303-25. 

{phang}Powell, J. L. 1986. Censored regression quantiles. {it:Journal of Econometrics} 32, 143-55.

{title:Author}

{phang}This command was written by Matthew J. Baker (matthew.baker@hunter.cuny.edu),
Hunter College and The Graduate Center, CUNY. Comments, criticisms, and suggestions for improvement are welcome. {p_end}

{title:Also see}

{psee}
Manual:  {help qreg:{bf:qreg}}, {help quantile:{bf:quantile}} 

{psee}
Online: {net search amcmc:{bf:amcmc}}, {net search moremata:{bf:moremata}}

{psee}
Other: (if installed)
{help mf_amcmc:{bf: mf_amcmc}}, {help moremata:{bf:moremata}}.
