{smcl}
{* 06Aug2017}{...}
{hline}
help for {hi:svyatk}{right:Biewen and Jenkins (revised August 2017)}
{hline}

{title:Estimation of GE inequality indices from complex survey data} 

{p 4 12}{cmd:svyatk} {it:varname} [{cmd:if} {it:exp}] 
	[{cmd:in} {it:range}] [{cmd:,} {cmdab:e:psilon(}{it:#}{cmd:)} 
	{cmdab:sub:pop(}{it:varname}{cmd:)} 
	{cmdab:l:evel(}{it:#}{cmd:)}


{p}{cmd:svyatk} typed without arguments redisplays the last estimates. 
The level option may be used.

{p}The survey design variables must be set beforehand by {cmd:svyset}, 
see help {help svyset}.

{p}Warning:  Use of {cmd:if} or {cmd:in} restrictions will not 
produce correct variance estimates for subpopulations in many cases.  
To compare estimates for subpopulations, use the {cmd:subpop()} option.


{title:Description}

{p}{cmd:svyatk} provides estimates of finite-population 
Atkinson inequality indices, together with their associated variance 
estimates. The Atkinson class of inequality indices, A(e), 
is characterized by a sensitivity parameter, e (`epsilon'), where e > 0.
The program calculates A(e) for e = 0.5, 1, 1.5, and 2, and for one 
additional value (which defaults to e = 2.5, unless set otherwise 
using the {cmd:epsilon} option). The larger that e is, the more 
sensitive that A(e) becomes to differences at the bottom of 
the distribution of {it:varname}. 

{p}Sampling variances are calculated using a method proposed by 
Woodruff (1971). The derivations assume that the sample under
consideration is sufficiently large that a Taylor series
approximation to the index holds. For full details of the 
derivation of the sampling variances, see Biewen and Jenkins
(2006). 

{p}The program may also be used to calculate sampling variances in the
case where there are i.i.d. observations: see Biewen and Jenkins (2006).

{p}A companion program, {cmd:svygei}, provides estimates of Generalized
Entropy inequality indices, using the same methods. For estimates of the Gini
Coefficient and Lorenz ordinates, see {cmd:svylorenz}. 


{title:Options}

{p 0 4}{cmd:epsilon} allows the user to choose a value of e (default = 2.5).

{p 0 4}{cmd:subpop({it:varname})} specifies that estimates be computed 
for the single subpopulation defined by the observations for 
which {it:varname}!=0.  Typically, {it:varname}=1 defines the 
subpopulation and {it:varname}=0 indicates observations not 
belonging to the subpopulation.  For observations whose 
subpopulation status is uncertain, varname should be set to missing.


{title:Examples}


{p 8 12}{inp:. * (1) Income inequality among individuals using household survey data with obs = individual}

{p 8 12}{inp:. * Weight = individual sample weight}

{p 8 12}{inp:. svyset psu_id [pweight = xewght], strata(strata_id) }

{p 8 12}{inp:. svyatk income}

{p 8 12}{inp:. * (2) Income inequality among individuals using household survey data with obs = individual}

{p 8 12}{inp:. * weight = individual sample weight; survey PSU and strata not provided; household ID known}

{p 8 12}{inp:. use income_ind, clear}

{p 8 12}{inp:. svyset hh_id [pweight = xewght]}

{p 8 12}{inp:. svygei income}

{p 8 12}{inp:. * (3) Income inequality among individuals using survey data with obs = household; }

{p 8 12}{inp:. *   all persons in same household have same income; survey PSU and strata not provided }

{p 8 12}{inp:. * weight = household weight x household size}

{p 8 12}{inp:. use income_hh, clear}

{p 8 12}{inp:. svyset [pweight = xhh_wt] }

{p 8 12}{inp:. svyatk income}


{title:Authors}

{p 4 4}Martin Biewen, University of Tuebingen, Germany{break}
<martin.biewen@uni-tuebingen.de>

{p 4 4}Stephen P. Jenkins, London School of Economics, U.K.{break}
<s.jenkins@lse.ac.uk>


{title:Acknowledgement}

{p 4 4}After we released our program in 2005, the syntax for {cmd:svyset} changed. 
Users could continue to use our program under version control. This update 
makes this redundant. We thank Philipp Poppitz for updating the program 
from version 8.2 to version 10. 

 
{title:References}

{p 4 4} Biewen, M. and S.P. Jenkins 2006. Variance estimation for Generalized 
Entropy and Atkinson inequality indices: the complex survey data case. 
{it: Oxford Bulletin of Economics and Statistics} 68: 371{c -}383 .

{p 4 4}Woodruff, R.S. 1971. A simple method for approximating the
variance of a complicated estimate. 
{it:Journal of the American Statistical Association} 66: 411{c -}4.


{title:Also see}

{p 1 14}Manual:  {hi:[U] 30 Overview of survey estimation}, {hi:[SVY]}{p_end}

{p 0 19}On-line:  help for {help svy} and, if installed, {help svygei},
{help geivars}, {help ineqdeco}, {help svylorenz}.{p_end}
