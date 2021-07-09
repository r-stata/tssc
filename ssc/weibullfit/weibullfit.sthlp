{smcl}
{* 15nov2007/25sep2014}{...}
{hline}
help for {hi:weibullfit}
{hline}

{title:Fitting a two-parameter Weibull distribution by maximum likelihood}

{p 8 17 2}{cmd:weibullfit} {it:varname} [{it:weight}] [{cmd:if} {it:exp}]
[{cmd:in} {it:range}] [{cmd:,} {cmdab:b:var(}{it:varlist1}{cmd:)}
{cmdab:c:var(}{it:varlist2}{cmd:)} {cmdab:r:obust}
{cmdab:cl:uster(}{it:clustervar}{cmd:)}  {cmdab:l:evel(}{it:#}{cmd:)}
{it:maximize_options} ]

{p 4 4 2}{cmd:by} {it:...} {cmd::} may be used with {cmd:weibullfit}; see help
{help by}. 

{p 4 4 2}{cmd:fweight}s and {cmd:aweight}s are allowed; see help {help weights}.


{title:Description}

{p 4 4 2} {cmd:weibullfit} fits by maximum likelihood a two-parameter Weibull 
distribution to a distribution of a variable {it:varname}. The distribution has
probability density function for variable {it:x} >= 0,
scale parameter {it:b} > 0 and 
shape parameter {it:c} > 0
of ({it:c}/{it:b}) ({it:x}/{it:b})^({it:c} - 1) exp(-({it:x}/{it:b})^{it:c}).


{title:Options}

{p 4 8 2}{cmd:bvar(}{it:varlist1}{cmd:)} and
{cmd:cvar(}{it:varlist2}{cmd:)} allow the user to specify each parameter as
a function of the covariates specified in the respective variable list. A
constant term is always included in each equation. 

{p 4 8 2}{cmd:robust} specifies that the Huber/White/sandwich estimator of
variance is to be used in place of the traditional calculation.  {cmd:robust} combined with
{cmd:cluster()} allows observations which are not independent within cluster
(although they must be independent between clusters). 

{p 4 8 2}{cmd:cluster(}{it:clustervar}{cmd:)} specifies that the observations
are independent across groups (clusters) but not necessarily within groups.
{it:clustervar} specifies to which group each observation belongs; e.g.,
{cmd:cluster(personid)} in data with repeated observations on individuals.  
Specifying {cmd:cluster()} implies {cmd:robust}.

{p 4 8 2}{cmd:level(}{it:#}{cmd:)} specifies the confidence level, in percent,
for the confidence intervals of the coefficients; see help {help level}.

{p 4 8 2}{cmd:nolog} suppresses the iteration log.

{p 4 8 2}{it:maximize_options} control the maximization process; see 
help {help maximize}. If you are seeing many "(not concave)" messages in the 
log, using the {cmd:difficult} option may help convergence.


{title:Saved results}

{p 4 4 2}In addition to the usual results saved after {cmd:ml}, {cmd:weibullfit}
also saves the following, if no covariates have been specified: 

{p 4 4 2}{cmd:e(bpar)} and {cmd:e(cpar)} are the estimated Weibull parameters.

{p 4 4 2}The following results are saved regardless of whether covariates have
been specified:

{p 4 4 2}{cmd:e(b_b)} and {cmd:e(b_c)} are row vectors containing the
parameter estimates from each equation. 

{p 4 4 2}{cmd:e(length_b_b)} and {cmd:e(length_b_c)} contain the lengths
of these vectors. If no covariates are specified in an equation, the
corresponding vector has length equal to 1 (the constant term); otherwise, the
length is one plus the number of covariates.


{title:Note September 2014} 

{p 4 4 2}The parameters denoted {it:b} and {it:c} above are now denoted
{cmd:bpar} and {cmd:cpar} in program output and the saved results
{cmd:e(bpar)} and {cmd:e(cpar)}.  This is to avoid being bitten as a
side-effect of changes in Stata official code.  In essence, a
user-written program of this kind cannot name a parameter {cmd:b}
without a collision in name space.  We thank Zarek C. Brot-Goldberg for
alerting us to the problem and Isabel Ca{c n~}ette of StataCorp for
confirmation of its diagnosis.  We understand that StataCorp intend to
fix the problem in a future update. 

	
{title:Examples}

{p 4 8 2}{cmd:. weibullfit mpg}


{title:Authors}

{p 4 4 2}Nicholas J. Cox, Durham University{break}n.j.cox@durham.ac.uk

{p 4 4 2}Stephen P. Jenkins, London School of Economics{break}s.jenkins@lse.ac.uk


{title:References}

{p 4 4 2}
Evans, M., Hastings, N. and Peacock, B. 2000. {it:Statistical distributions.}
New York: John Wiley.

{p 4 4 2} 
Johnson, N.L., Kotz, S. and Balakrishnan, N. 1994. 
{it:Continuous univariate distributions: Volume 1.} New York: John Wiley.

{p 4 4 2}
Kleiber, C. and Kotz, S. 2003. 
{it:Statistical size distributions in economics and actuarial sciences.} 
Hoboken, NJ: John Wiley. 


{title:Also see}

{p 4 13 2}
Online: help for {help pweibull} (if installed), {help qweibull} (if installed) 

