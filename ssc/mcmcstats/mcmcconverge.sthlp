{smcl}
{* 1 Dec 2011}{...}
{cmd:help mcmcconverge}
{hline}

{title:Syntax}

{p 8 12 2}
{cmd:mcmcconverge} {varlist} {ifin}{cmd:,} {opth iter(varname)} {opth chain(varname)} {opth saving(filename)} [{opt replace}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth iter(varname)}}variable identifying iterations of each Markov chain{p_end}
{synopt :{opth chain(varname)}}variable identifying independent Markov chains{p_end}
{synopt :{opth saving(filename)}}location to save file of results{p_end}
{synopt :{opt replace}}overwrite existing results file{p_end}

{title:Description}

{p 4 4 2}
{cmd:mcmcconverge} is a command for assessing the convergence of Markov chains in Markov Chain Monte Carlo (MCMC) estimation. 
It calculates the convergence statistics described in section 11.6 of Gelman et al. (2003). 

{p 4 4 2}
The command assumes that you begin with a dataset in memory containing sequences of draws from two or more Markov chains. 
The variable specified in the {cmd:chain()} option should identify chains, and the variable specified in the {cmd:iter()} option should identify iterations within each chain. 
Each variable in {varlist} should contain draws of a different scalar estimand.
The data should be arranged as a panel in long form, where {it:chain} identifies panels and {it:iter} identifies observations within panels. 
This panel is required to be balanced after any restrictions specified in the {it:if/in} option are applied.

{p 4 4 2}
The command saves results in the file specified by {opth saving(filename)}.
Each observation in the results file corresponds to a different scalar estimand. 
Each variable in the results file contains a different convergence statistic.

{p 4 4 2}
The convergence statistics are:

{p2col:{it:B}} The between-sequence variance.{p_end}
{p2col:{it:W}} The within-sequence variance.{p_end}
{p2col:{it:varplus}} The marginal posterior variance of the estimand.{p_end}
{p2col:{it:Rhat}} The potential scale reduction from further simulations; convergence is achieved when {it:Rhat} is near 1.{p_end}
{p2col:{it:neff}} The effective number of independent draws.{p_end}
{p2col:{it:neffmin}} min({it:neffmin},{it:mn}), where {it:m} is the number of chains and {it:n} is the number of iterations per chain.{p_end}

{title:Author}

{p 4 4 2}
Sam Schulhofer-Wohl, Federal Reserve Bank of Minneapolis, sschulh1.work@gmail.com. 
The views expressed herein are those of the author and not necessarily those of the Federal Reserve Bank of Minneapolis or the Federal Reserve System. 

{title:Reference}

{phang}
Gelman, Andrew, John B. Carlin, Hal S. Stern and Donald B. Rubin, 2003. {it: Bayesian Data Analysis,} 2nd ed. New York: Chapman & Hall.

