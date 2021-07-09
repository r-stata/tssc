{smcl}
{hline}
help for {hi:cpoissone} {right:(Joseph Hilbe)}
{hline}

{title:Censored Poisson regression: econometric}

{p 8 13 2}{cmd:cpoissone}{space 2}{it:depvar} [{it:varlist}] 
	[{cmd:if} {it:exp}] [{cmd:in} {it:range}] {cmd:,}
	{cmdab:cen:sor(}{it:varname}{cmd:)} {cmdab:CLEft()} {cmdab:CRIght()}
        [ {cmdab:off:set(}{it:varname}{cmd:)} {cmdab:exp:osure(}{it:varname}{cmd:)} 
        {cmdab:cl:uster(}{it:varname}{cmd:)} {cmdab:l:evel(}{it:#}{cmd:)} 
        {cmdab:from:(}{it:asis}{cmd:)} {cmdab:ir:r} {cmdab:rob:ust} {cmd:nolog} 
        {it:maximize_options} {it:survey_options}]

{p 8 8 2}Note: the option {it:censor} must be included in the command. A censor variable must 
use the following numbers to indicate the type of censoring: 0 = {it:not censored}, 1 = {it:left censored}, 
-1 = {it:right censored}.

{p 8 8 2}
Note: Type value of left censor site in {it:cleft()}.

              Type value of right censor site in {it:cright()}.

{p 4 4 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are
allowed; see help {help weights}.

{p 4 4 2}
{cmd:cpoissone} provides access to all {it:maximize} options; see help {help maximize}.

{p 4 4 2}
{cmd:cpoissone} provides access to all {it:survey} options; see help {help svy}.


{title:Description}

{p 4 4 2}{cmd:cpoissone} fits a censored Poisson maximum-likelihood regression 
of {it:depvar} on {it:indepvars}, where {it:depvar} is a non-negative count variable.
The censor option is required. If no observations are censored, a censor variable 
with all 1's must be specified. Interpret parameter estimates as one would {cmd:poisson}.

    Values on either side of the site of censoring are revalued to the 
    value of the censor value.

{p 4 4 2}{cmd:cpoissone} accepts all of the {it:help maximize} options, the {it:constraint()} 
option, and all survey options and capabilities documented in {cmd:[SVY]}; including 
multi-level surveys; poststratification; and BRR, jackknife, and linearization VCE estimators.

{p 4 4 2}This program uses {cmd:ml lf} method. 


{title:Options}

{dlgtab:Model}

{phang}
{opth censor(cenvar)} is required. Values of 1 indicate a non-censored, 0 a left 
censored, and -1 a right censored observation. {it:cenvar} may be numeric or a variable.

{phang}
{opth cleft(#)} for left censor site; {opth cright(#)} for right censor site

{phang}
{opth censor(1)} and no {it:cleft} or {it:cright} values declared is a standard Poisson model

{phang}
{opth offset(varname)} specifies a {it:varname} in model with coefficient constrained to 1.

{phang}
{opth exposure(varname)} specifies a {it:ln(varname)} in model with coefficient constrained to 1.

{phang}
{opth constraints(constraints)} apply specified linear constraints.



{dlgtab:SE/Robust}

{phang}
{opth cluster(varname)} 

{p 4 8 2}
{cmd:robust} specifies that the Huber/White/sandwich estimator of
variance is to be used in place of the traditional calculation.  {cmd:robust}
combined with {cmd:cluster}{cmd:(}{cmd:)} allows observations which are not
independent within cluster (although they must be independent between
clusters).  If you specify {cmd:pweight}s, {cmd:robust} is implied.

{phang}
{opth vce(options)} allowed. {cmd:vce}{cmd:(}{cmd:)} supports {it:robust}, {it:opg}, and {it:native}.
{cmd:vce} does not support options {it:bootstrap} or {it:jacknife}, However,  {cmd:cpoisson} does support  
the {cmd:bootstrap} and {cmd:jacknife} commands, so these modeling capabilities are allowed.  


{dlgtab:Reporting}
   
{p 4 8 2}{cmd:level(}{it:#}{cmd:)} specifies the confidence level, in percent,
for confidence intervals of the coefficients; see help {help level}.

{p 4 8 2}
{cmd:nolog} suppresses the iteration log.


{dlgtab:max options}

{phang}

{p 4 8 2}
{it:maximize_options}: technique(algorithm_spec), [no]log, trace, hessian, gradient, showstep, 
shownrtolerance, difficult, iterate(#), tolerance(#), ltolerance(#), gtolerance(#), nrtolerance(#), 
nonrtolerance, from(init_specs); see {help maximize}.  


{dlgtab:svy options}

{phang}
{it:survey_options} are all available. See help {help svy}




{title:Author and support}

{phang}
{cmd: Joseph Hilbe},
{cmd: Arizona State University}:
{cmd: hilbe@asu.edu}


{title:Remarks}

{pstd}
{cmd:cpoissone} is a user authored program. Support is by author. See {cmd: Hilbe}, 
{it:Negative Binomial Regression}, Cambridge University Press, for discussion. Related 
information can also be obtained at {bf:[R] poisson}. Or see {bf: cpoisson}


{title:Examples}

{phang}{cmd:. cpoissone time hmo age, censor(cenvcar) cle(3) nolog irr}

{phang}{cmd:. cpoissone time hmo age, censor(cenvar) cleft(2) cright(30) nolog cluster(provnum)}

{phang}{cmd:. bootstrap: cpoissone deaths smokes a2-a5, censor(cenvar) cright(10) exposure(pyears) irr nolog}

{phang}{cmd:. svyset psuid [pweight=finalwgt], strata(stratid)}

{phang}{cmd:. svy: cpoissone zinc age age2 weight female black orace rural, censor(cv) cright(20) nolog irr}


{title:Also see}

{psee}
Manual:  {bf:[R] Poisson regression}; {bf:[SVY] Svy: poisson}

{psee}
Online:  {helpb help} {helpb cpoisson} {helpb svy: poisson}



