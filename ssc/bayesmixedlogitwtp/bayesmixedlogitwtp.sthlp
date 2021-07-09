{smcl}
{* 2Feb2013}{...}
{cmd:help bayesmixedlogitwtp}{right: ({browse "http://www.stata-journal.com/article.html?article=st0001":SJ14-3: st0001})}
{hline}

{title:Title}

{p2colset 5 20 29 2}{...}
{p2col :{hi:bayesmixedlogitwtp} {hline 2}}Bayesian mixed logit model in WTP space{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:bayesmixedlogitwtp}
{depvar}
[{indepvars}] {ifin}{cmd:,}
{cmdab:gr:oup(}{varname}{cmd:)}
{cmdab:id:entifier(}{varname}{cmd:)}
{cmd:price(}{varname}{cmd:)}
{cmd:rand(}{varlist}{cmd:)}
[{opt draw:s(#)}
 {opt drawsr:andom(#)}
 {opt drawsf:ixed(#)}
 {opt burn(#)}
 {opt thin(#)}
 {opt arater:andom(#)}
 {opt aratef:ixed(#)}
 {opt samplerr:andom(string)}
 {opt samplerf:ixed(string)}
 {opt dampparmf:ixed(#)}
 {opt dampparmr:andom(#)} 
 {opt from(rowvector)}
 {opt fromv:ariance(matrix)}
 {opt jumble}
 {opt noisy}
 {opt saving(filename)}
 {opt replace} 
 {opt append}
 {opt ind:save(string)}
 {opt indk:eep(#)}
 {opt indwide}
 {opt replacei:nd}
 {opt appendi:nd}]

{title:Description}

{pstd}
{cmd:bayesmixedlogitwtp} can be used to fit mixed logit models using Bayesian
methods in willingness-to-pay (WTP) space. 
{cmd:bayesmixedlogitwtp} functions in the same way as {cmd:bayesmixedlogit}; the command
 produces draws from the
posterior parameter distribution and then presents summary and other
statistics describing the results of the drawing. Detailed analysis of
the draws is left to the discretion of the user.

{pstd}
Implementation of {cmd:bayesmixedlogitwtp} is essentially the same as {cmd:bayesmixedlogit},
(if not
installed, {net search bayesmixedlogit:search} online)
following the methods described in Train (2009, chap. 12),
and mechanics described in Baker (2014).  A
diffuse prior for the mean values of the random coefficients is assumed,
and the prior distribution on the covariance matrix of random
coefficients is taken to be an identity inverse Wishart.  {cmd:bayesmixedlogitwtp} 
uses the Mata routines {helpb mf_amcmc:amcmc()} (if not
installed, {net search amcmc():search} online) for adaptive Markov chain
Monte Carlo sampling from the posterior distribution of individual level
coefficients and fixed coefficients.  The data setup for
{cmd:bayesmixedlogitwtp} is the same as for {cmd:clogit}.  Much of the syntax
follows that used by Hole (2007) in development of the command
{cmd:mixlogit} and {cmd:mixlogitwtp}.

{pstd}
The defining characteristic of the WTP-space mixed logit model 
is normalization of coefficients using the
(random) coefficient on a designated price variable, as described in Train and Weeks (2005), Scarpa, Thiene, and 
Train (2008), and Hole and Kolstad (2012). 

{pstd}
The model assumes that the coefficient on the price variable follows (the negative of) a log-normal distribution. 
Hence, if the estimated parameter is {bf:b}, the price variable has coefficient {bf:-exp(b)}. The transformed coefficient
is saved and displayed as part of the output, but as presented the saved and display value is the negative of the exponentiated
average value of b, not the average of the value -exp(b).   

{title:Options}

{phang}
{opt group(varname)} specifies a numeric identifier variable
for choice occasions.  {cmd:group()} is required.

{phang}
{opt identifier(varname)} identifies coefficient sets
(those observations for which a set of coefficients apply).  Thus,
when a person is observed making choices over multiple
occasions, one would use {opt group(varname)} to specify the choice
occasions, while {opt identifier(varname)} would identify the person.
{cmd:identifier()} is required.

{phang}
{opt rand(varlist)} specifies independent variables
with random coefficients.  The variables immediately following the
dependent variable in the syntax are considered to have fixed
coefficients (see the examples below).  While a model can be run without
any independent variables with fixed coefficients, at least one
random-coefficient independent variable is required for
{cmd:bayesmixedlogitwtp} to work.  {cmd:rand()} is required. In the event that one wishes to estimate
a mixed logit model with just a price variable, no normalization is required so {cmd:bayesmixedlogit} should suffice.

{phang}
{ opt price(varname)} designates the price variable and is required. 

{pstd}
Subsequent options exactly mirror the options of {cmd:bayesmixedlogit} and provide
control over how drawing from the posterior occurs. 

{phang}
{opt draws(#)} specifies the number of draws that are to be taken from the posterior 
distribution of the parameters.  The default is {cmd:draws(1000)}.

{phang}
{opt drawsrandom(#)} is an advanced option.  The drawing algorithm
treats each set of random coefficients as a Gibbs step in sampling from
the joint posterior distribution of parameters.  In difficult,
large-dimensional problems, it might be desirable to let individual Gibbs
steps run for more than one draw to achieve better mixing and
convergence of the algorithm.

{phang}
{opt drawsfixed(#)} is a more advanced option.  The drawing algorithm treats
fixed coefficients as a Gibbs step in sampling from the joint posterior
distribution of parameters.  In difficult, large-dimensional problems, it
might be desirable to let this step in Gibbs sampling run for more than a
single draw.  The default is {cmd:drawsfixed(1)}.

{phang}
{opt burn(#)} specifies the length of the burn-in period; the first
{it:#} draws are discarded upon completion of the algorithm and before
further results are computed.

{phang}
{opt thin(#)} specifies that only every {it:#}th draw is to be retained, so
if {cmd:thin(3)} is specified, only every third draw is retained.  This
option is designed to help ease autocorrelation in the resulting draws,
as is the option {opt jumble}, which randomly mixes draws.  Both options
may be applied.

{phang}
{opt araterandom(#)} specifies the desired acceptance rate for random
coefficients and should be a number between zero and one.  Because an
adaptive acceptance-rejection method is used to sample random
coefficients, by specifying the desired acceptance rate, the user has
some control over adaptation of the algorithm to the problem.  The
default is {cmd:araterandom(.234)}.

{phang}
{opt aratefixed(#)} specifies the desired acceptance rate for fixed
coefficients and works in the same fashion as {opt araterandom(#)}.

{phang}
{opt samplerrandom(string)} specifies the type of sampler that is to be
used when random parameters are drawn.  It may be set to either
{cmd:global} or {cmd:mwg}.  The default is {cmd:samplerrandom(global)},
which means that proposed changes to random parameters are drawn all at
once.  If {cmd:mwg} -- an acronym for "Metropolis within Gibbs" -- is
instead chosen, each random parameter is drawn separately as an
independent step conditional on other random parameters in a nested
Gibbs step.  The default is {cmd:samplerrandom(global)}, but {cmd:mwg}
might be useful in situations in which initial values are poorly scaled.
The workings of these options are described in greater detail in Baker
(2014).

{phang}
{opt samplerfixed(string)} specifies the type of sampler that is used
when fixed parameters are drawn.  Options are exactly as those described
under {opt samplerrandom(string)}.

{phang}
{opt dampparmfixed(#)} works exactly as option {opt dampparmrandom(#)}
but is applied to drawing fixed parameters.

{phang}
{opt dampparmrandom(#)} is a parameter that controls how aggressively
the proposal distributions for random parameters are adapted as drawing
continues.  If the parameter is set close to one, adaptation is
aggressive in its early phase of trying to achieve the acceptance rate
specified in {opt araterandom(#)}.  If the parameter is set closer to
zero, adaptation is more gradual.

{phang}
{opt from(rowvector)} specifies a row vector of starting values for all
parameters in order.  If these are not specified, starting
values are obtained via estimation of a conditional logit model via
{helpb clogit}.

{phang}
{opt fromvariance(matrix)} specifies a matrix of starting values for the
random parameters.

{phang}
{cmd:jumble} specifies to randomly mix draws.

{phang}
{opt noisy} specifies that a dot be produced every time a complete pass
through the algorithm is finished.  After 50 iterations, a function
value ln_fc(p) will be produced, which gives the joint log of the
value of the posterior choice probabilities evaluated at the latest
parameters.  While ln_fc(p) is not an objective function per se, the author has found
that drift in the value of this function indicates that the algorithm
has not yet converged or has other problems.

{phang}
{opt saving(filename)} specifies a location to store the draws from the
distribution.  The file will contain just the draws after any burn-in
period or thinning of values is applied.  

{phang}
{opt replace} specifies that an
existing file is to be overwritten.

{phang}
{opt append} specifies that an existing file is to be appended, which
might be useful if multiple runs need to be combined.

{phang}
{opt indsave(filename)} specifies a file to which individual-level random
parameters are to be saved. More precisely, {opt indsave(filename)} saves
the draws of the individual-level parameters. {it:Caution:} For long runs and models 
with large numbers of individuals, specifying this option can cause memory problems. Users
should be careful how it is used and consult some of the examples before employing the
option.

{phang}
{opt indkeep(#)} is for use with {opt indsave} and specifies that only the last # draws of
the individual-level random parameters be kept. This helps avoid excessive memory consumption.

{phang}
{opt indwide} is for use with {opt indsave} and affords the user a degree of control over how
individual-level parameters are saved. By default, individual-level parameters are saved in a panel form,
meaning that each random parameter draw is saved in a row, where draws are marked by the {opt group} identifier.
If instead the user would prefer that each row contain draws of each parameter, one could specify the {opt indwide} 
option, which saves all draws in a single row, with the first entry of the row being the {opt group} identifier. 
By analogy with {helpb reshape}, by default draws are saved in "long" format, whereas {opt indwide} stores the draws
in "wide" format. 

{phang}
{opt replaceind} functions in the same way as {opt replace}, but in reference to
the file specified in {opt indsave}. 

{phang}
{opt appendind} functions in the same way as {opt append}, but in reference to the
file specified in {opt indsave}.

{title:Examples}

{pstd}
The following example mirrors examples provided of usage of the {cmd:mixlogitwtp} command (with thanks to Arne Rise Hole for
allowing use of the example):

{phang2}{cmd:. use http://fmwww.bc.edu/repec/bocode/t/traindata.dta}{p_end}

{phang2}{cmd:. bayesmixedlogitwtp y contract local wknown, group(gid) id(pid) price(price) rand(seasonal tod) draws(4000) burn(1000) thin(5) arater(.4) saving(draws) replace noisy}

{pstd}
A case in which all coefficients are random: 

{phang2}{cmd:. bayesmixedlogitwtp y, group(gid) id(pid) price(price) rand(seasonal tod wknown) draws(2000) burn(1000) thin(5) arater(.4) saving(draws) replace}

{title:Stored results}

{pstd}
{cmd:bayesmixedlogitwtp} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_r)}}degrees of freedom for summarizing draws (equal to number of retained draws){p_end}
{synopt:{cmd:e(krnd)}}number of random parameters{p_end}
{synopt:{cmd:e(kfix)}}number of fixed parameters{p_end}
{synopt:{cmd:e(draws)}}number of draws{p_end}
{synopt:{cmd:e(burn)}}burn-in observations{p_end}
{synopt:{cmd:e(thin)}}thinning parameter{p_end}
{synopt:{cmd:e(random_draws)}}number of draws of each set of random parameters per pass{p_end}
{synopt:{cmd:e(fixed_draws)}}number of draws of fixed parameters per pass{p_end}
{synopt:{cmd:e(damper_fixed)}}damping parameter -- fixed parameters{p_end}
{synopt:{cmd:e(price_coef)}}-exponent of mean of estimated coefficient on price variable{p_end}
{synopt:{cmd:e(damper_random)}}damping parameter -- random parameters{p_end}
{synopt:{cmd:e(opt_arate_fixed)}}desired acceptance rate -- fixed parameters{p_end}
{synopt:{cmd:e(opt_arate_random)}}desired acceptance rate -- random parameters{p_end}
{synopt:{cmd:e(N_groups)}}number of groups{p_end}
{synopt:{cmd:e(N_choices)}}number of choice occasions{p_end}
{synopt:{cmd:e(arates_fa)}}acceptance rate -- fixed parameters{p_end}
{synopt:{cmd:e(arates_ra)}}average acceptance rate -- random parameters{p_end}
{synopt:{cmd:e(arates_rmax)}}maximum acceptance rate -- random parameters{p_end}
{synopt:{cmd:e(arates_rmin)}}minimum acceptance rate -- random parameters{p_end}
{synopt:{cmd:e(inddraws)}}draws of individual parameters kept{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:bayesmixedlogitwtp}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(pricevar)}}name of price variable{p_end}
{synopt:{cmd:e(indepvars)}}independent variables{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(saving)}}file containing results{p_end}
{synopt:{cmd:e(fixed_sampler)}}sampler type for fixed parameters{p_end}
{synopt:{cmd:e(random_sampler)}}sampler type for random parameters{p_end}
{synopt:{cmd:e(random)}}random parameter names{p_end}
{synopt:{cmd:e(fixed)}}fixed parameter names{p_end}
{synopt:{cmd:e(identifier)}}identifier for individuals{p_end}
{synopt:{cmd:e(group)}}identifier for choice occasions{p_end}
{synopt:{cmd:e(indsave)}}file holding individual-level parameter draws{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}mean parameter values{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of parameters{p_end}
{synopt:{cmd:e(V_init)}}initial variance-covariance matrix of random parameters{p_end}
{synopt:{cmd:e(b_init)}}initial mean vector of random parameters{p_end}
{synopt:{cmd:e(arates_fixed)}}row vector of acceptance rates of fixed parameters{p_end}
{synopt:{cmd:e(arates_rand)}}vector or matrix of acceptance rates of random parameters{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}
	
{title:Comments}

{pstd}
The basic algorithms used in drawing are described in detail in
Baker (2014).  The user might gain a fuller understanding of the options
{cmd:aratefixed()}, {cmd:araterandom()}, {cmd:dampparmfixed()},
{cmd:dampparmrandom()}, and other options controlling adaptation of the
proposal distribution from a reading of this document.

{pstd}
{cmd:bayesmixedlogitwtp} requires that the package of Mata functions
{cmd:amcmc()} be installed and also requires installation of Ben Jann's
{cmd:moremata} set of extended Mata functions.

{pstd}
Caution -- While summary statistics of the results of a
drawing are presented in the usual Stata format, {cmd:bayesmixedlogitwtp}
provides no guidance as to how one should actually select
the number of draws, how one should process the draws, how one should monitor
convergence of the algorithm, or how one should present and interpret results.
One would do well to consult Train (2009) and a good source on Bayesian
methods, such as Gelman et al. (2009).  Fortunately, Stata provides many
tools for summarizing and plotting the results of a drawing.


{title:References}

{phang}Baker, M. J. 2014. {browse "http://www.stata-journal.com/article.html?article=st0001":Adaptive Markov chain Monte Carlo sampling and estimation in Mata}. {it:Stata Journal} 14: 623-61. 

{phang}Gelman, A., J. B. Carlin, H. S. Stern, and D. B. Rubin. 2009. {it:Bayesian data analysis}. 2nd. ed. Boca Raton, FL: Chapman & Hall/CRC. 

{phang}Hole, A. R. 2007. {browse "http://www.stata-journal.com/article.html?article=st0133":Fitting mixed logit models by using maximum simulated likelihood}. {it:Stata Journal} 7: 388-401.

{phang}Hole, A. R. and J. R. Kolstad. 2012. Mixed logit estimation of willingness to pay distributions: 
a comparison of models in preference and WTP space using data
from a health-related choice experiment. {it:Empirical Economics} 42: 445-469.

{phang}Long, J. S., and J. Freese. 2006. {browse "http://www.stata.com/bookstore/regression-models-categorical-dependent-variables/":{it:Regression Models for Categorical Dependent Variables Using Stata}}. 2nd ed. College Station, TX: Stata Press. 

{phang}R. Scarpa, M. Thiene, and K. Train. 2008. Utility in willingness to pay space: A tool to
address confounding random scale effects in destination choice to the Alps.
{it:American Journal of Agricultural Economics} 90: 994-1010.

{phang}Train, K. E. 2009. {it:Discrete Choice Methods with Simulation}. 2nd
ed. Cambridge: Cambridge University Press.

{phang}Train, K. E. and M. Weeks. 2005. Discrete choice models in preference space and
willingness-to-pay space. In: Scarpa R, Alberini A (eds) {it:Application of
simulation methods in environmental and resource economics}. Springer,
Dordrecht, pp 1-16.

{title:Author} 

{pstd}Matthew J. Baker{p_end}
{pstd}Hunter College and the Graduate Center, CUNY{p_end}
{pstd}New York, NY{p_end}
{pstd}matthew.baker@hunter.cuny.edu{p_end}

{title:Acknowledgements}

{pstd}
Thanks to Kenneth Train for suggesting this command, and thanks to Arne Rise Hole for permission to use
examples.

{pstd}
Comments, criticisms, and suggestions for improvement are welcome.{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 14, number 2: {browse "http://www.stata-journal.com/article.html?article=st0354":st0354}

{p 5 14 2}
Manual:  {manlink R clogit}

{p 7 14 2}Help:  {helpb mf_amcmc:amcmc()}, {helpb bayesmixedlogit}, {helpb mixlogit}, {helpb mixlogitwtp}, {helpb moremata} (if installed){p_end}
