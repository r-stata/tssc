{smcl}
{* 5 Jan 2012}{...}
{viewerjumpto "Methods" "mcmcmixed##methods"}{...}
{hline}
help for {hi:mcmcmixed}
{hline}

{title:Syntax}

{p 8 18 2}
{cmd:mcmcmixed} {depvar} [{it:fe_equation}] [{cmd:||} {it:re_equation}] {cmd:,} {opth saving(filename)} {opt d0(#)} {opt delta0(name)} [{it:options}]

{p 4 4 2}
    where the syntax of {it:fe_equation} is

{p 12 24 2}
	[{indepvars}] {ifin} {weight} [{cmd:,} {opt noconstant}]

{p 4 4 2}
    and the syntax of {it:re_equation} is

{p 12 24 2}
	{it:{help varlist:levelvarlist}}{cmd::} [{varlist}] [{cmd:,} {opt noconstant}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt d0(#)}}prior variance of regression error{p_end}
{synopt :{opt delta0(name)}}scalar or matrix specifying prior variance of random effects; relevant only if {it:re_equation} is specified{p_end}
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
{cmd:aweight}s and {cmd:fweight}s are allowed; see {help weight}, 
and see {help mcmcmixed##methods:methods} for an important note on how {cmd:aweight}s are interpreted.{p_end}

{title:Description}

{p 4 4 2}
{cmd:mcmcmixed} uses Markov chain Monte Carlo (MCMC) to sample from the posterior distribution of a normal linear mixed model. 
If {it:re_equation} is not specified, {cmd:mcmcmixed} is identical to {cmd:mcmcreg}, which estimates a normal linear regression. 
If {it:re_equation} is specified, the model allows the coefficients to vary across groups defined by {it:levelvarlist}.

{p 4 4 2}
{cmd:mcmcmixed} produces a file of draws from the posterior distribution of the model parameters. 
Each observation in the file corresponds to an iteration of the sampler; each variable represents a different scalar parameter. 
These variables are named as follows:

{p2col:{it:beta_*}} Coefficient on independent variable *.{p_end}
{p2col:{it:beta__cons}} Intercept (omitted if {cmd:noconstant} is specified in {it:fe_equation}).{p_end}
{p2col:{it:sigma2}} Variance of regression error.{p_end}
{p2col:{it:theta`i'_*}} Coefficient on independent variable * for group `i' of {it:levelvarlist}.{p_end}
{p2col:{it:theta`i'__cons}} Intercept for group `i' of {it:levelvarlist} (omitted if {cmd:noconstant} is specified in {it:re_equation}).{p_end}
{p2col:{it:Sigma_`j'_`j'}} Variance across groups of the `j'th coefficient in {it:re_equation} (where the constant, if included, is the final coefficient).{p_end}
{p2col:{it:Sigma_`j'_`k'}} Covariance across groups of the `j'th and `k'th coefficients in {it:re_equation}.{p_end}

{p 4 4 2}
The variable {it:iter} in the output file keeps track of iterations; {it:iter}=0 is the initial condition used to start the chain.

{p 4 4 2}
Right-hand-side variables can appear in {it:fe_equation}, {it:re_equation} or both. 
If a variable appears only in {it:fe_equation}, it has the same coefficient for all groups, and this coefficient is reported in {it:beta_*}. 
If a variable appears in both {it:fe_equation} and {it:re_equation}, it has a different coefficient for each group; 
the mean across groups is reported in {it:beta_*}, and the group-specific deviation from the mean is reported in {it:theta`i'_*}. 
If a variable appears only in {it:re_equation}, it has a different coefficient for each group, reported in {it:theta`i'_*}; 
the mean across groups is assumed be zero.

{p 4 4 2}
The group indexes {it:`i'} in {it:theta`i'_*} are obtained from {cmd: egen i=group({it:levelvarlist})}. 

{title:Options}

{dlgtab:Model}

{phang}
{opt d0(#)} sets the prior variance of the regression errors. Because results are potentially sensitive to this prior, you are required to specify it yourself; there is no default value.

{phang}
{opt delta0(name)} sets the prior variance-covariance matrix of the group-specific coefficients. 
Because results are potentially sensitive to this prior, you are required to specify it yourself; there is no default value. 
{it:delta0} must be the name of a scalar, vector or matrix containing the prior. 
If {it:delta0} is a scalar, the prior is {it:delta0}*I({it:Nz}), where {it:Nz} is the number of group-specific coefficients (including the intercept, unless {cmd:noconstant} is specified in {it:re_equation}); {it:delta0} must be positive.
If {it:delta0} is an {it:Nz}x1 or 1x{it:Nz} vector, the prior is {cmd:diag}({it:delta0}); all elements of {it:delta0} must be positive. 
If {it:delta0} is an {it:Nz}x{it:Nz} matrix, the prior is {it:delta0}; this matrix must be symmetric and positive definite. 
It is an error for {it:delta0} to be anything except a positive scalar; an {it:Nz}x1 or 1x{it:Nz} vector containing only positive numbers; or an {it:Nz}x{it:Nz} symmetric, positive-definite matrix. 
The order of elements in {it:delta0} is the same as the order of the {varlist} specified in {it:re_equation}, with the intercept last if there is an intercept.

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

{marker methods}{...}
{title:Methods}

{p 4 4 2}
{cmd:mcmcreg} uses the Gibbs sampler. Standard uninformative conjugate priors are used: The prior for the regression coefficients is uninformative, the prior for the error variance {it:sigma^2} is InverseGamma(1/2, {it:d0}/2), 
and the prior for the variance-covariance matrix of group-specific coefficients {it:Sigma} is InverseWishart(1+{it:Ng},{it:delta0}), where {it:Ng} is the number of groups. 
See Chib (2001, algorithm 16) for a textbook exposition.

{p 4 4 2}
The sampler is initialized with guesses for {it:sigma^2} and {it:Sigma} obtained as follows. 
Let {it:y} be the dependent variable, let {it:x} be the independent variables in {it:fe_equation}, and let {it:z} be the independent variables in {it:re_equation}. 
Let {it:beta} be the estimated coefficient vector in a frequentist pooled least squares regression of {it:y} on {it:x}. 
For each group {it:i}, let {it:theta_i} be the posterior mean of the coefficient vector in a Bayesian least squares regression of {it:y}-{it:x}*{it:beta} on {it:z} 
using the data from group {it:i}, where the prior for {it:theta_i} is N(0,{it:delta0}). 
The initial guess for the inverse of {it:Sigma} is drawn from Wishart(1+{it:Ng},inv(inv({it:delta0})+{it:S}*{it:Ng})), 
where {it:S} is the observed variance-covariance matrix of the {it:theta_i}'s. 
The initial guess for {it:sigma^2} is drawn from InverseGamma((1+{it:df})/2,({it:d0}+{it:SSR})/2), 
where {it:df} is the number of observations (or the sum of weights if you use {cmd:fweight}s) and 
{it:SSR} is the sum of squares of {it:y}-{it:x}*{it:beta}-{it:z}*{it:theta_i}.

{p 4 4 2}
{cmd:aweight}s are interpreted as scaling the variances of the regression error and all of the random effects. 
That is, if you specify {cmd:aweight}s, they apply to both {it:fe_equation} and {it:re_equation}. 
A future version may provide the ability to specify {cmd:aweight}s separately for the two equations.

{title:Examples}

{p 4 4 2}
Manufacturer-specific intercepts:

{phang2}{cmd:. scalar mydelta0=0.01}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. generate manuf=cond(strpos(make," ")>0,substr(make,1,strpos(make," ")-1),make)}{p_end}
{phang2}{cmd:. mcmcmixed mpg weight foreign || manuf:, saving(mcmcmixed_auto1.dta) d0(0.01) delta0(mydelta0)}{p_end}
{phang2}{cmd:. use mcmcmixed_auto1.dta, clear}{p_end}
{phang2}{cmd:. list in 1/5}{p_end}
{phang2}{cmd:. summarize *}{p_end}

{p 4 4 2}
Manufacturer-specific intercept and manufacturer-specific coefficient on {it:weight}, same prior variance on each manufacturer-specific parameter:

{phang2}{cmd:. scalar mydelta0=0.01}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. generate manuf=cond(strpos(make," ")>0,substr(make,1,strpos(make," ")-1),make)}{p_end}
{phang2}{cmd:. mcmcmixed mpg weight foreign || manuf:weight, saving(mcmcmixed_auto2.dta) d0(0.01) delta0(mydelta0)}{p_end}
{phang2}{cmd:. use mcmcmixed_auto2.dta, clear}{p_end}
{phang2}{cmd:. list in 1/5}{p_end}
{phang2}{cmd:. summarize *}{p_end}

{p 4 4 2}
Manufacturer-specific intercept and manufacturer-specific coefficient on {it:weight}, different prior variance on each manufacturer-specific parameter:

{phang2}{cmd:. matrix mydelta0=(1,0.01)}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. generate manuf=cond(strpos(make," ")>0,substr(make,1,strpos(make," ")-1),make)}{p_end}
{phang2}{cmd:. mcmcmixed mpg weight foreign || manuf:weight, saving(mcmcmixed_auto3.dta) d0(0.01) delta0(mydelta0)}{p_end}
{phang2}{cmd:. use mcmcmixed_auto3.dta, clear}{p_end}
{phang2}{cmd:. list in 1/5}{p_end}
{phang2}{cmd:. summarize *}{p_end}

{p 4 4 2}
When estimating models by MCMC, it is good practice to check for convergence by running multiple independent chains. 
{cmd:mcmcmixed} will generate different chains when run repeatedly with different values of {cmd:seed(#)}; 
see {help mcmcreg##examples} for an example of how to run multiple chains, and see {help mcmcconverge}, 
available in the SSC package {cmd:mcmcstats}, for useful statistics for checking convergence once you have run multiple chains.

{p 4 4 2}
It is also good practice to drop early iterations, before convergence was achieved, when describing the posterior distribution. 
See {help mcmcsummarize}, available in the SSC package {cmd:mcmcstats}, for a convenient way to describe the posterior distribution.


{title:Saved results}

{p 4 4 2}
{cmd:mcmcmixed} saves the following in {cmd:e()}:

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


