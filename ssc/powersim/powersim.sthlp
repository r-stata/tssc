{smcl}
{* *! Help for -powersim- version 1.0.0  26July2013}{...}
{hline}
help {hi: powersim}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
Simulation-based power analysis for linear and generalized linear models
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:powersim}
[{cmd:using} {it:filename}] {it:options}
[{cmd:,} {it:options}] : {it:model_cmd}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Power}
{synopt :{opth b(numlist)}} List of effect sizes, required{p_end}
{synopt :{opt null(#)}} Value of the null hypothesis, defaults to zero{p_end}
{synopt :{opth sample:size(numlist)}} List of sample sizes, required{p_end}
{synopt :{opt a:lpha(#)}} alpha value, defaults to alpha = 0.05{p_end}
{synopt :{opt pos:ition(#)}} column position of b in matrix e(b) of the analysis model, required{p_end}

{syntab :Data generating model}
{synopt :{opth f:amily(powersim##familyname:familyname)}} error distribution, required{p_end}
{synopt :{opth l:ink(powersim##linkname:linkname)}} link function, required* {p_end}
{synopt :{opt cov1(n b d # [#])}} covariate specifications, covariate 1 {p_end}
{synopt :{opt cov2(n b d # [#])}} covariate specifications, covariate 2 {p_end}
{synopt :{opt cov3(n b d # [#])}} covariate specifications, covariate 3 {p_end}
{synopt :{opt block22(b1 n1 b2 n2 [ b3 ])}} binary variables for 2x2 block design {p_end}
{synopt :{opt cons(b)}} constant term {p_end}
{synopt :{opt corr12(#)}} Pearson correlation between cov1 and cov2 {p_end}
{synopt :{opt corr13(#)}} Pearson correlation between cov1 and cov3 {p_end}
{synopt :{opt corr23(#)}} Pearson correlation between cov2 and cov3 {p_end}
{synopt :{opt inter1(# n*n)}} Interaction effect specification {p_end}
{synopt :{opt inter2(# n*n)}} Interaction effect specification {p_end}
{synopt :{opt inter3(# n*n)}} Interaction effect specification {p_end}

{syntab :Simulation}
{synopt :{opt nreps(#)}} number of Monte Carlo replications {p_end}
{synopt :{opt inside}} Generate predictor data inside simulation loop  {p_end}
{synopt :{opt dry:run}} Dry run {p_end}
{synopt :{opt det:ail}} Detailed output for dry run {p_end}
{synopt :{opt gen:data}} create a single dataset {p_end}
{synopt :{opt nobs(#)}} Number of observations for created dataset {p_end}
{synopt :{opt seed(#)}} Set random-number seed {p_end}
{synopt :{opt expb}} Interpret effect sizes b as exp(b) {p_end}
{synopt :{opt nodots}} Suppress replication dots {p_end}
{synopt :{opt sil:ent}} Suppress any intermediate output (implies {opt nodots}) {p_end}
{synopt :{opt add:scalar(string)}} Fetch scalar stored in e() of analysis model {p_end}
{synopt :{opt maxiter(#)}} Set maximum number of iterations for the analysis model {p_end}
{synopt :{opt force}} Allow analysis model command other then {cmd: regress} or {cmd: glm} {p_end}
{synopt :{opt df(string)}} Use Students t-distribution for significance tests with df stored in {opt e(string)} of the analysis model {p_end}

{syntab :Saving}
{synopt :{opt do:file(filename[,replace])}} Save do-file to {it:filename} {p_end}
{synopt :{opt sav:ing(filename[,replace])}} Save simulation results to {it:filename} {p_end}

{synoptline}
{p 4 6 2}
* specification of a link function is only required if the do-file is generated via command options;
if an existing do-file is provided, the link function must be defined in that do-file.

{synoptline}
{p2colreset}{...}

{marker familyname}{...}
{synoptset 23}{...}
{synopthdr :familyname}
{synoptline}
{synopt :{opt gaussian} [{it:#}]}Gaussian (normal), with SD of Gaussian error {it:#}; defaults to 1{p_end}
{synopt :{opt igaussian} [{it:#}]}inverse Gaussian, with scale parameter {it:#}; defaults to 0.25{p_end}
{synopt :{opt binomial} [{it:#}]}Binomial, with number of trials {it:#}; defaults to 1 (i.e., Bernoulli){p_end}
{synopt :{opt poisson}}Poisson{p_end}
{synopt :{opt nbinomial} [{it:#}]}negative binomial, with overdispersion {it:#}; defaults to 1{p_end}
{synopt :{opt gamma} [{it:#}]}gamma, with scale parameter {it:#}; defaults to 1 {p_end}
{synoptline}
{p2colreset}{...}

{marker linkname}{...}
{synoptset 23}{...}
{synopthdr :linkname}
{synoptline}
{synopt :{opt identity}}identity{p_end}
{synopt :{opt log}}log{p_end}
{synopt :{opt logit}}logit{p_end}
{synopt :{opt probit}}probit{p_end}
{synopt :{opt cloglog}}cloglog{p_end}
{synopt :{opt power} {it:#}}power{p_end}
{synopt :{opt opower} {it:#}}odds power{p_end}
{synopt :{opt nbinomial}}negative binomial{p_end}
{synopt :{opt loglog}}log-log{p_end}
{synopt :{opt logc}}log-complement{p_end}
{synoptline}
{p2colreset}{...}

{marker covariate_distributions}{...}
{synoptset 23}{...}
{synopthdr :covariate_distributions}
{synoptline}
{synopt :{opt normal} {it:a#} {it:b#}}Gaussian, with M {it:a#} and SD {it:b#} {p_end}
{synopt :{opt poisson} {it:a#}}Poisson, with mean {it:a#}{p_end}
{synopt :{opt uniform} {it:a#} {it:b#}}uniform, ranging from {it:a#} to {it:b#}{p_end}
{synopt :{opt binomial} {it:a#}}bernoulli, i.e. binomial(1, {it:a#})  {p_end}
{synopt :{opt chi2} {it:a#}}chi-square, with {it:a#} df{p_end}
{synopt :{opt studentt} {it:a#}}Student's t, with {it:a#} df{p_end}
{synopt :{opt beta} {it:a#} {it:b#}}beta, with shape parameters {it:a#} and {it:b#}{p_end}
{synopt :{opt gamma} {it:a#} {it:b#}}gamma, with shape parameter {it:a#} and scale parameter {it:b#}{p_end}
{synopt :{opt nbinomial} {it:a#} {it:b#}}negative binomial, with number of failures {it:a#} and success probability {it:b#}{p_end}
{synopt :{opt block} {it:a#}}equally sized groups, with number of groups {it:a#} (2-4 groups) {p_end}

{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{opt powersim} performs power analysis Monte Carlo simulations for linear and 
generalized linear models. Data will be generated according to a model that 
is specified via command options. Predictor data can be generated by either 
using command options or by providing an existing do-file. Stata's {help regress}
and {help glm} commands can be used for specifying the analysis model. See
the accompanying tutorial for a more detailed introduction.


{title:Options}

{dlgtab:Power}

{phang}
{opth b(numlist)} List of the true population parameters.

{phang}
{opt null(#)} Value of the null hypothesis; if the {opt expb} option is specified,
the value will be interpreted as exponentiated value.

{phang}
{opth sample:size(numlist)} List of sample sizes.

{phang}
{opt a:lpha(#)} alpha level, default is alpha = 0.05.

{phang}
{opt pos:ition(#)} column position of the coefficient in matrix e(b) (see {help ereturn list})
of the analysis model for which power wants to be estimated.


{dlgtab:Data generating model}

{phang}
{opt f:amily(familyname)} specifies the (conditional) distribution of the outcome.

{phang}
{opt l:ink(linkname)} specifies the link function.

{phang}
{opt cov1(n b d # [#])} covariate specifications for covariate 1, where 
n is the name of the covariate, b its effect size, and d its distribution, followed 
by one or two parameter values, depending on the distribution 
(see {help powersim##covariate_distributions:covariate_distributions)}. 
Type {cmd: _bp} instead of an effect size value in case of the covariate for 
which the power wants to be simulated.

{phang}
{opt cov2(n b d # [#])} covariate specifications as described above, covariate 2.

{phang}
{opt cov3(n b d # [#])} covariate specifications as described above, covariate 3.

{phang}
{opt block22(b1 n1 b2 n2 [b3])} creates two binary variables for a 2x2 block design
with balanced group sizes; n1 and n2 are the names of the two variables and b1 and b2 are 
its coefficients; a coefficient for an interaction effect of the two variables can be specified
with b3.

{phang}
{opt constant(b)} b is the coefficient for the constant term; if this option is omitted,
the constant is assumed to equal zero.

{phang}
{opt corr12(#)} specifies Pearson correlation coefficient for cov1 and cov2, applicable only to
normally distributed covariates; if this option is omitted, cov1 and cov2 are assumed to be 
uncorrelated (orthogonal).

{phang}
{opt corr13(#)} specifies Pearson correlation coefficient for cov1 and cov3, applicable only to
normally distributed covariates; if this option is omitted, cov1 and cov3 are assumed to be 
uncorrelated (orthogonal).

{phang}
{opt corr23(#)} specifies Pearson correlation coefficient for cov2 and cov3, applicable only to
normally distributed covariates; if this option is omitted, cov2 and cov3 are assumed to be 
uncorrelated (orthogonal).

{phang}
{opt inter1(# n*n)} specifies an interaction effect; for example, to generate data 
with an interaction effect of 0.5 for cov2 and cov3 with names foo and bar, 
type {cmd:inter1(0.5 foo*bar)}.

{phang}
{opt inter2(# n*n)} specifies an additional interaction effect. 

{phang}
{opt inter3(# n*n)} specifies an additional interaction effect.


{dlgtab:Simulation}

{phang}
{opt nreps(#)} number of Monte Carlo replications. 

{phang}
{opt inside} Generates predictor data inside the simulation loop; should be
specified if the predictor data itself is regarded as a stochastic component.

{phang} 
{opt dry:run} Performs a dry run in order to check command inputs before running the simulations.

{phang}
{opt det:ail} Additionally prints the contents of the data generating do-file on the screen
if the {opt dryrun} option is specified.

{phang}
{opt gen:data} creates a single realization of the data. 

{phang}
{opt nobs(#)} Determines the number of observations for the dataset requested with 
the {opt gendata} option; defaults to N = 10,000. 

{phang}
{opt seed(#)} Sets the initial random-number seed.

{phang}
{opt expb} Effect sizes specified in option {opt b()} are interpreted as exp(b); for example, this could be
useful if the power wants to be determined in the context of a logistic regression and the user wants 
to specify effect sizes as odds ratios, rather than as log odds ratios.

{phang}
{opt nodots} Suppresses the replication dots during the simulations. By default, one dot character is
displayed for each successful replication.  A red `x' is displayed if {it:model_cmd} returns
an error (for example, if an analysis model does not converge within the specified maximum
number of iterations).

{phang}
{opt sil:ent} Suppresses any intermediate output during simulations (implies {opt nodots}).

{phang}
{opt add:scalar} Specifies to fetch a scalar that is available in {opt e()} of the analysis 
model from each MC replication; for example, if you would like to record the value of the 
log-likelihood from each replication of a {opt glm}, the option would be specified as addscalar(ll); 
the scalar will then be appended to the resulting dataset which contains results from each replication.

{phang}
{opt maxiter(#)} Specifies the number of maximum iterations for the analysis model, defaults to maxiter = 200;
 will be ignored for model commands other than {cmd: glm}. 

{phang}
{opt force} Allow analysis model command other then {cmd: regress} or {cmd: glm}. 

{phang}
{opt df(string)} Use Students t-distribution for significance tests with df 
stored in {opt e(string)} of the analysis model.


{dlgtab:Saving}

{phang}
{opt do:file(filename[,replace])} Save do-file to {it:filename}; if no existing do file is provided via 
{opt using} then this option is required. {p_end}

{phang}
{opt sav:ing(filename[,replace])} Save simulation results from each replication to {it:filename};  {p_end}


{title:Remarks}

{pstd}
Stata's {help regress} and {help glm} commands can be used to specify an analysis model under 
{opt model_cmd} after the colon of the {opt powersim} command. The outcome variable in
model_cmd must be named y. With {opt regress},
a t-distribution is used for siginificance testing and a normal distribution is used with 
{opt glm}. Note that {opt powersim} removes the current data in memory and replaces 
it with simulation results; make sure to save your data before running powersim. Also note
that {opt powersim} is creating a scalar with the name _bp. In case that a scalar with
the same name already exists, it will be overwritten. If multivariate
normal data is requested, Stata matrices with the names __M, __SD, and
__C are created which would replace any existing matrices with these names.


{pstd}
Note that both, distributional family and link function, need to be specified
for the data generating model. The available link functions are

{center:Link function            {cmd:powersim} option}
{center:{hline 40}}
{center:identity                 {cmd:link(identity)} }
{center:log                      {cmd:link(log)}      }
{center:logit                    {cmd:link(logit)}    }
{center:probit                   {cmd:link(probit)}   }
{center:complementary log-log    {cmd:link(cloglog)}  }
{center:odds power               {cmd:link(opower} {it:#}{cmd:)} }
{center:power                    {cmd:link(power} {it:#}{cmd:)}  }
{center:negative binomial        {cmd:link(nbinomial)}}
{center:log-log                  {cmd:link(loglog)}   }
{center:log-complement           {cmd:link(logc)}     }

{pstd}
If an existing do-file is provided, the link function
must be defined in that do-file and only the distributional family
has to be specified. Available distributional families are

{center:Family                   {cmd:powersim} option}
{center:{hline 40}}
{center:Gaussian(normal)   {cmd:family(gaussian} {it:[#]}{cmd:)} } 
{center:inverse Gaussian   {cmd:family(igaussian} {it:[#]}{cmd:)}}
{center:Binomial           {cmd:family(binomial} {it:[#]}{cmd:)} }
{center:Poisson            {cmd:family(poisson)}      }
{center:negative binomial  {cmd:family(nbinomial} {it:[#]}{cmd:)}}
{center:gamma              {cmd:family(gamma} {it:[#]}{cmd:)}    }


{pstd}
As it is also stated in {help glm}, not all family/link
combinations make sense.  You may choose from the following combinations:

          {c |} id  log  logit  probit  clog  pow  opower  nbinomial  loglog  logc
{hline 10}{c +}{hline 67}
Gaussian  {c |}  x   x                         x
inv. Gau. {c |}  x   x                         x
binomial  {c |}  x   x     x      x       x    x     x                  x      x
Poisson   {c |}  x   x                         x
neg. bin. {c |}  x   x                         x              x
gamma     {c |}  x   x                         x


{title:Examples}

{hline}

{pstd}Estimating power for various effect and sample sizes for a linear effect of
a normally ditributed predictor variable which is correlated
with another predictor variable in a linear model: {p_end}

{phang2}{cmd: powersim , 				///} {p_end}
{phang2}{cmd: b(0.1(0.1)0.3) 			///} {p_end}
{phang2}{cmd: alpha(0.05) 				///} {p_end}
{phang2}{cmd: pos(1)					///} {p_end}
{phang2}{cmd: sample(100(20)300)		///} {p_end}
{phang2}{cmd: nreps(500) 				///} {p_end}
{phang2}{cmd: family(gaussian) 			///} {p_end}
{phang2}{cmd: link(identity) 			///} {p_end}
{phang2}{cmd: cov1(x1 _bp normal 0 1)  	///} {p_end}
{phang2}{cmd: cov2(x2 0.3 normal 0 1)  	///} {p_end}
{phang2}{cmd: corr12(0.5)				///} {p_end}
{phang2}{cmd: inside 					///} {p_end}
{phang2}{cmd: saving(psim_results)		///} {p_end}
{phang2}{cmd: dofile(psim_dofile) : reg y x1 x2 } {p_end}

{pstd}The assumed model in the above call to {cmd:powersim} can be expressed as: {p_end}
{pstd}y = _bp*x1 + 0.3*x2 + e, e ~ N(0,1) {p_end}
{pstd}where _bp is a placeholder for the effect sizes specified in {opt b()};  
x1 and x2 are drawn from a multivariate normal distribution with rho = 0.5. {p_end}

{hline}

{pstd}Using an existing do-file (here, the one that was created with the above example):{p_end}

{phang2}{cmd: powersim using psim_dofile, 	///} {p_end}
{phang2}{cmd: b(0.1(0.1)0.3) 				///} {p_end}
{phang2}{cmd: alpha(0.05) 					///} {p_end}
{phang2}{cmd: pos(1)						///} {p_end}
{phang2}{cmd: sample(100(20)300)			///} {p_end}
{phang2}{cmd: nreps(500) 					///} {p_end}
{phang2}{cmd: family(gaussian) 				///} {p_end}
{phang2}{cmd: inside 						///} {p_end}
{phang2}{cmd: saving(psim_results, replace) : reg y x1 x2 } {p_end}

{hline}

{pstd}Poisson model with two correlated predictor variables and power estimated  
for the interaction effect:{p_end}

{phang2}{cmd: powersim , 					///} {p_end}
{phang2}{cmd: b(0.1) 						///} {p_end}
{phang2}{cmd: alpha(0.05) 					///} {p_end}
{phang2}{cmd: pos(3)						///} {p_end}
{phang2}{cmd: sample(300)					///} {p_end}
{phang2}{cmd: nreps(500) 					///} {p_end}
{phang2}{cmd: family(poisson) 				///} {p_end}
{phang2}{cmd: link(log) 					///} {p_end}
{phang2}{cmd: cov1(x1 -0.25 normal 0 1)  	///} {p_end}
{phang2}{cmd: cov2(x2 0.4 normal 0 1)  		///} {p_end}
{phang2}{cmd: inter1(_bp x1*x2)				///} {p_end}
{phang2}{cmd: cons(0.5)						///} {p_end}
{phang2}{cmd: corr12(0.5)					///} {p_end}
{phang2}{cmd: inside 						///} {p_end}
{phang2}{cmd: dofile(psim_dofile, replace) : ///} {p_end}
{phang2}{cmd: glm y c.x1##c.x2, family(poisson) link(log) } {p_end}

{hline}

{pstd}Logistic regression model for a 2x2 balanced block design with an interaction effect, 
for which the statistical power is simulated:{p_end}

{phang2}{cmd: powersim , 					///} {p_end}
{phang2}{cmd: b(0.3) 						///} {p_end}
{phang2}{cmd: alpha(0.05) 					///} {p_end}
{phang2}{cmd: pos(8)						///} {p_end}
{phang2}{cmd: sample(2000)					///} {p_end}
{phang2}{cmd: nreps(500) 					///} {p_end}
{phang2}{cmd: family(binomial) 				///} {p_end}
{phang2}{cmd: link(logit) 					///} {p_end}
{phang2}{cmd: block22(0.5 x1 0.5 x2 _bp)	///} {p_end}
{phang2}{cmd: cons(0.5)						///} {p_end}
{phang2}{cmd: dofile(psim_dofile, replace) : ///} {p_end}
{phang2}{cmd: glm y i.x1##i.x2, family(binomial) link(logit)} {p_end}

{hline}

{pstd}If power is estimated for several effect and/or sample sizes, power 
can be plotted as a function of sample size (by effect sizes) after
simulations are completed (see {help powersimplot}): {p_end}

{phang2}{cmd: powersimplot} {p_end}

{hline}

{pstd}Power can also be plotted as a function of effect size if power is simulated
for varying effect sizes (see {help powersimplot}). The following simulation
assumes a negative binomial model with overdispersion parameter alpha = 0.5 
(note that if alpha does not equal 1, {opt ml} must be specified in the {opt family()} 
option of {cmd: glm} in the analysis model command), log link function,
and a single binomial predictor variable, distributed Bi(1,0.5), for a fixed sample
size of N = 500; effect sizes here are specified as incidence rate ratios
via usage of the {opt expb} option: {p_end}

{phang2}{cmd: powersim , 				///} {p_end}
{phang2}{cmd: b(1(.05)1.5) 				///} {p_end}
{phang2}{cmd: expb 						///} {p_end}
{phang2}{cmd: alpha(0.05) 				///} {p_end}
{phang2}{cmd: pos(1)					///} {p_end}
{phang2}{cmd: sample(500)				///} {p_end}
{phang2}{cmd: nreps(500) 				///} {p_end}
{phang2}{cmd: family(nbinomial 0.5) 	///} {p_end}
{phang2}{cmd: link(log) 				///} {p_end}
{phang2}{cmd: cov1(x1 _bp binomial 0.5)	///} {p_end}
{phang2}{cmd: inside 					///} {p_end}
{phang2}{cmd: dofile(psim_dofile, replace) : ///} {p_end}
{phang2}{cmd: glm y x1, family(nbinomial ml) link(log) } {p_end}

{pstd}Now plot the power curve as power vs. effect size: {p_end}

{phang2}{cmd: powersimplot, e } {p_end}

{hline}

{pstd}Simulating power for various effect and sample sizes for
the difference between two equally sized groups in an inverse
Gaussian model with scale parameter sigma = 0.5 and canonical
link function: {p_end}

{phang2}{cmd: powersim , 				///} {p_end}
{phang2}{cmd: b(0.2(0.1)0.5) 			///} {p_end}
{phang2}{cmd: alpha(0.05) 				///} {p_end}
{phang2}{cmd: pos(2) 					///} {p_end}
{phang2}{cmd: sample(300(100)500) 		///} {p_end}
{phang2}{cmd: nreps(250) 				///} {p_end}
{phang2}{cmd: family(igaussian 0.5) 	///} {p_end}
{phang2}{cmd: link(power -2) 			///} {p_end}
{phang2}{cmd: cov1(x1 _bp block 2) 		///} {p_end}
{phang2}{cmd: cons(1) 					///} {p_end}
{phang2}{cmd: dofile(psim_dofile, replace) : ///} {p_end}
{phang2}{cmd: glm y i.x1, fam(igaussian) link(power -2)} {p_end}

{pstd}Note that the random number generator for the inverse Gaussian distribution 
may become slow, depending on specified predictor and scale parameters.{p_end}

{hline}


{title:Saved results}

{pstd}
{cmd:powersim} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(niter)}}number of MC replications (requested, per sample/effect size combination){p_end}
{synopt:{cmd:r(alpha)}}alpha level{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(model)}}analysis model command line{p_end}
{synopt:{cmd:r(cmd)}}{cmd:powersim}{p_end}
{synopt:{cmd:r(effects)}}effect sizes{p_end}
{synopt:{cmd:r(samples)}}sample sizes{p_end}
{synopt:{cmd:r(iseed)}}initial random number seed{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(power)}}results matrix{p_end}

{p2colreset}{...}


{title:Acknowledgment}

{p 4 4 2}Ariel Linden suggested the {opt silent} option.


{title:Author}

{p 4 4 2}Joerg Luedicke{break}
Yale University and University of Florida{break}
United States{break} 
email: joerg.luedicke@ufl.edu


{title:Also see}

{psee}
Manual:  {manlink R glm}
{p_end}

{psee}
Manual:  {manlink R regress}
{p_end}

{psee}
{space 2}Help:  {help powersimplot}
{p_end}
