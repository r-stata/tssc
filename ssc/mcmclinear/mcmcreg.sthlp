{smcl}
{* 5 Jan 2012}{...}
{viewerjumpto "Examples" "mcmcreg##examples"}{...}
{hline}
help for {hi:mcmcreg}
{hline}

{title:Syntax}

{p 8 12 2}
{cmd:mcmcreg} {depvar} [{indepvars}] {ifin} {weight} {cmd:,} {opth saving(filename)} {opt d0(#)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt d0(#)}}prior variance of regression error{p_end}
{synopt :{opt noconstant}}suppress constant term{p_end}

{syntab:Results}
{synopt :{opth saving(filename)}}filename where results should be stored{p_end}
{synopt :{opt replace}}overwrite existing {it:{help filename}}{p_end}

{syntab:Markov chain}
{synopt :{opt iterate(#)}}number of iterations in chain; default is {cmd:iterate(100)}{p_end}
{synopt :{opt seed(#)}}random number generator seed; default is {cmd:seed(12345)}{p_end}
{synopt :{opt nolog}}suppress iteration log{p_end}
{synoptline}

{p 4 6 2}
{cmd:aweight}s and {cmd:fweight}s are allowed; see {help weight}.{p_end}

{title:Description}

{p 4 4 2}
{cmd:mcmcreg} uses Markov chain Monte Carlo (MCMC) to sample from the posterior distribution of a normal linear regression model of {depvar} on {indepvars}.

{p 4 4 2}
{cmd:mcmcreg} produces a file of draws from the posterior distribution of the model parameters. 
Each observation in the file corresponds to an iteration of the sampler; each variable represents a different scalar parameter. 
These variables are named as follows:

{p2col:{it:beta_*}} Coefficient on independent variable *.{p_end}
{p2col:{it:beta__cons}} Intercept (omitted if {cmd:noconstant} is specified).{p_end}
{p2col:{it:sigma2}} Variance of regression error.{p_end}

{p 4 4 2}
The variable {it:iter} in the output file keeps track of iterations; {it:iter}=0 is the initial condition used to start the chain.

{title:Options}

{dlgtab:Model}

{phang}
{opt d0(#)} sets the prior variance of the regression errors. Because results are potentially sensitive to this prior, you are required to specify it yourself; there is no default value.

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}. If {cmd:noconstant} is specified, there must be at least one independent variable.

{dlgtab:Results}

{phang}
{opth saving(filename)} designates the location where the results should be saved.

{phang}
{opt replace} specifies that you want to overwrite {it:{help filename}} if it already exists.

{dlgtab:Markov chain}

{phang}
{opt iterate(#)} specifies how many iterations the chain should continue for.

{phang}
{opt seed(#)} sets the random number generator seed. Random numbers are used to initialize the sampler; thus, multiple independent chains can be obtained by running {cmd:mcmcreg} with different values of {cmd:seed}.

{phang}
{opt nolog} suppresses printing of an iteration log.

{title:Methods}

{p 4 4 2}
{cmd:mcmcreg} uses the Gibbs sampler. Standard uninformative conjugate priors are used: The prior for the regression coefficients is uninformative, while the prior for the error variance {it:sigma^2} is InverseGamma(1/2, {it:d0}/2). 
See Chib (2001, algorithm 5) for a textbook exposition.

{p 4 4 2}
The sampler is initialized with a guess for {it:sigma^2} drawn from InverseGamma((1+{it:df})/2,({it:d0}+{it:SSR})/2), 
where {it:df} is the number of observations (or the sum of weights if you use {cmd:fweight}s) and 
{it:SSR} is the sum of squared residuals from the frequentist least squares regression of {depvar} on {indepvars}. 

{marker examples}{...}
{title:Examples}

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. mcmcreg mpg weight foreign, saving(mcmcreg_auto.dta) d0(0.01)}{p_end}
{phang2}{cmd:. use mcmcreg_auto.dta, clear}{p_end}
{phang2}{cmd:. list in 1/5}{p_end}
{phang2}{cmd:. summarize *}{p_end}

{p 4 4 2}
When estimating models by MCMC, it is good practice to check for convergence by running multiple independent chains. {cmd:mcmcreg} will generate different chains when run repeatedly with different values of {cmd:seed(#)}. 

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. tempfile temp}{p_end}
{phang2}{cmd:. mcmcreg mpg weight foreign, saving(`temp') d0(0.01) seed(12345)}{p_end}
{phang2}{cmd:. use `temp', clear}{p_end}
{phang2}{cmd:. gen byte chain=1}{p_end}
{phang2}{cmd:. save mcmcreg_auto.dta}{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. mcmcreg mpg weight foreign, saving(`temp') d0(0.01) seed(54321) replace}{p_end}
{phang2}{cmd:. use `temp', clear}{p_end}
{phang2}{cmd:. gen byte chain=2}{p_end}
{phang2}{cmd:. append using mcmcreg_auto.dta}{p_end}
{phang2}{cmd:. save mcmcreg_auto.dta, replace}{p_end}
{phang2}{cmd:. by chain, sort: summarize *}{p_end}

{p 4 4 2}
See {help mcmcconverge}, available in the SSC package {cmd:mcmcstats}, for useful statistics for checking convergence once you have run multiple chains.

{p 4 4 2}
It is also good practice to drop early iterations, before convergence was achieved, when describing the posterior distribution. 
See {help mcmcsummarize}, available in the SSC package {cmd:mcmcstats}, for a convenient way to describe the posterior distribution.

{title:Saved results}

{p 4 4 2}
{cmd:mcmcreg} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mcmcreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Author}

{p 4 4 2}
Sam Schulhofer-Wohl, Federal Reserve Bank of Minneapolis, sschulh1.work@gmail.com. 
The views expressed herein are those of the author and not necessarily those of the Federal Reserve Bank of Minneapolis or the Federal Reserve System. 

{title:Reference}

{phang}
Chib, Siddhartha, 2001. "Markov Chain Monte Carlo Methods: Computation and Inference." In {it:Handbook of Econometrics}, vol. 5, ed. James J. Heckman and Edward Leamer, 3569-649. Amsterdam: Elsevier.{p_end}


