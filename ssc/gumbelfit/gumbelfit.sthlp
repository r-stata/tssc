{smcl}
{* 17nov2003/25oct2010/7dec2012}{...}
{hline}
help for {hi:gumbelfit}
{hline}

{title:Fitting a Gumbel distribution by maximum likelihood}

{p 8 17 2}{cmd:gumbelfit} {it:varname} [{it:weight}] [{cmd:if} {it:exp}]
[{cmd:in} {it:range}] [{cmd:,} {cmdab:alpha:var(}{it:varlist1}{cmd:)}
{cmdab:mu:var(}{it:varlist2}{cmd:)} {cmdab:r:obust}
{cmdab:cl:uster(}{it:clustervar}{cmd:)}  {cmdab:l:evel(}{it:#}{cmd:)}
{it:maximize_options} ]

{p 4 4 2}{cmd:by} {it:...} {cmd::} may be used with {cmd:gumbelfit}; see help
{help by}. 

{p 4 4 2}{cmd:fweight}s and {cmd:aweight}s are allowed; see
help {help weights}.


{title:Description}

{p 4 4 2}
{cmd:gumbelfit} fits by maximum likelihood a two-parameter Gumbel
distribution to a distribution of a variable {it:varname}.  The
distribution has probability density function for variable x, scale
parameter alpha > 0 and location parameter mu of (1 / alpha) exp[-(x -
mu) / alpha] exp[-exp(-(x - mu) / alpha)]. Note that x may be negative, 
zero or positive. 


{title:Options}

{p 4 8 2}
{cmd:alphavar(}{it:varlist1}{cmd:)} and {cmd:muvar(}{it:varlist2}{cmd:)}
allow the user to specify each parameter as a function of the covariates
specified in the respective variable list. A constant term is always
included in each equation. 

{p 4 8 2}
{cmd:robust} specifies that the Huber/White/sandwich estimator of
variance is to be used in place of the traditional calculation; see the
manual section in {hi:[U]} on {hi:Obtaining robust variance estimates}.
{cmd:robust} combined with {cmd:cluster()} allows observations which are
not independent within cluster (although they must be independent
between clusters). 

{p 4 8 2}
{cmd:cluster(}{it:clustervar}{cmd:)} specifies that the observations are
independent across groups (clusters) but not necessarily within groups.
{it:clustervar} specifies to which group each observation belongs; e.g.,
{cmd:cluster(personid)} in data with repeated observations on
individuals.  See {hi:[U]} on {hi:Obtaining robust variance estimates}.
Specifying {cmd:cluster()} implies {cmd:robust}.

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, in percent,
for the confidence intervals of the coefficients; see help {help level}.

{p 4 8 2}{cmd:nolog} suppresses the iteration log.

{p 4 8 2}
{it:maximize_options} control the maximization process; see help 
{help maximize}. If you are seeing many "(not concave)" messages in the
log, using the {cmd:difficult} option may help convergence.


{title:Saved results}

{p 4 4 2}
In addition to the usual results saved after {cmd:ml}, {cmd:gumbelfit}
also saves the following, if no covariates have been specified: 

{p 4 4 2}
{cmd:e(alpha)} and {cmd:e(mu)} are the estimated Gumbel parameters.

{p 4 4 2}
The following results are saved regardless of whether covariates have
been specified:

{p 4 4 2}
{cmd:e(b_alpha)} and {cmd:e(b_mu)} are row vectors containing the
parameter estimates from each equation. 

{p 4 4 2}
{cmd:e(length_b_alpha)} and {cmd:e(length_b_mu)} contain the lengths of
these vectors. If no covariates are specified in an equation, the
corresponding vector has length equal to 1 (the constant term);
otherwise, the length is one plus the number of covariates.

	
{title:Examples}

{p 4 8 2}{cmd:. gumbelfit mpg}


{title:Authors}

{p 4 4 2}Nicholas J. Cox, Durham University{break}n.j.cox@durham.ac.uk

{p 4 4 2}Stephen P. Jenkins, London School of Economics{break}s.jenkins@lse.ac.uk


{title:References}

{p 4 8 2}
Forbes, C., Evans, M., Hastings, N. and Peacock, B. 2011. 
{it:Statistical distributions.}
Hoboken, NJ: John Wiley. 

{p 4 8 2} 
Johnson, N.L., Kotz, S. and Balakrishnan, N. 1995. 
{it:Continuous univariate distributions: Volume 2.} New York: John Wiley.


{title:Also see}

{p 4 13 2}
Online: help for {help pgumbel}, {help qgumbel}

