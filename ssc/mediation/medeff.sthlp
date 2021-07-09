{smcl}
{* 1jun2011}{...}
{hline}
help for {hi:medeff}
{hline}

{title: Function to estimate causal mediation effects.}

{p 8 27}
{cmd:medeff}
{it: (equation 1) (equation 2) } 
[{cmd:if}] [{cmd:in}] [{weight}]
, 
[{cmd:sims}{cmd:(}{it:integer}{cmd:)}
{cmd:seed}{cmd:(}{it:integer}{cmd:)}
{cmd:vce}{cmd:(}{it:vcetype}{cmd:)}
{cmd:Level}{cmd:(}{it:#}{cmd:)}
{cmdab:inte:ract)}{cmd:(}{it:varname}{cmd:)} 
]
{cmdab:med:iate}{cmd:(}{it:varname}{cmd:)}
{cmd:treat}{cmd:(}{it:varname}{cmd:)}


{title:Description}

{p} {cmd:medeff} is the workhorse function for estimating mediation effects for a variety of data types. For a continuous mediator variable and a continuous outcome variable, the results will be identical to the usual Baron and Kenny method. The function can, however, accomodate other data types including binary outcomes and mediators and calculate the correct estimates. 

{title:SE/Robust}

{p 0 4}
{opth vce(vcetype)}{it:vcetype} may be {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, 
   or {opt jack:knife}.

{title:Options}

{p 0 4}  
{cmdab:sims(}{it:integer}{cmd:)} specifies the number of simulations to run for the quasi-Bayesian approximation of parameter uncertainty. The default value is 1000. Higher values will increase the computational time.

{p 0 4}                                                      
{cmd:seed(}{it:integer}{cmd:)} sets the random number seed for precise replicability though with sufficient sims results will be very similar. The default value is the random seed 
 Stata draws when starting a session. 

 {p 0 4}                                                      
{cmd:vcetype(}{it:vcetype}{cmd:)} allows users to specify how the standard errors will be calculated. 

 {p 0 4}                                                      
{cmd:Level(}{it:#}{cmd:)} sets the confidence interval; default is {cmd:level(95)}. 

 {p 0 4}                                                      
{cmdab:inte:ract}{cmd:(}{it:varname}{cmd:)} allows for an interaction between the treatment and mediating variable. Interaction terms must be created prior to running and included in the model for the outcome variable. 

{p 0 4}                                                      
{cmdab:med:iate}{cmd:(}{it:varname}{cmd:)} is required and specifies the mediating variable 
to be used in the analysis

{p 0 4} 
{cmd:treat}{cmd:(}{it:varname} {it:integer} {it:integer}{cmd:)} is also required and specifies the treatment variable used in the analysis. 
The values of the treatment variable can be specified. If no values are specified, values of 0 and 1 are assumed.

{title:Examples}

{p 4 4 2}
{cmd:. medeff (regress M T x) (regress Y T M x) , treat(T) mediate(M) sims(1000) seed(1) }{break}
{cmd:. medeff (probit M T x) (regress Y T M x) , treat(T) mediate(M) sims(1000) }{break}
{cmd:. medeff (regress M T x) (probit Y T M x) , treat(T) mediate(M) sims(1000) }{break}
{cmd:. medeff (regress M T x) (probit Y T M x) if x>0 , treat(T) mediate(M) sims(1000) }{break}

{title:Remarks}

{p} {cmd:medeff} only supports OLS, probit, and logit in either stage of the analysis so far. 
Any estimation technique other than those will produce an error. 
After conducting mediation analysis users should conduct a formal sensitivity analysis and report these results (see {helpb medsens}). 
Currently the mediate function does not handle interactions between pre-treatment x variables and either the treatment or mediator.
A requirement for causal mediation analysis is that the same observations are used in the mediator and outcome regressions. The function will automatically restrict samples in order to do this.

{title:Saved results}

{p} The program stores the Average Causal Mediation Effect (ACME) in the scalars 
{inp:r(delta0)} and {inp:r(delta0)}. The direct effects are stored in {inp:r(zeta0)} and {inp:r(zeta1)} 
and the total effect is stored in {inp:r(tau)}. For each of these, the low and high bounds of the  
confidence interval are stored in the lo and hi scalars.

{title:Authors} 
 
	{browse "rhicks@princeton.edu":Raymond Hicks} 
	Niehaus Center for Globalization and Governance, Princeton University 
  
	{browse "http://scholar.harvard.edu/dtingley":Dustin Tingley} 
	Government Department, Harvard University
  
Email {browse "mailto:rhicks@princeton.edu":rhicks@princeton.edu} or {browse "mailto:dtingley@gov.harvard.edu":dtingley@gov.harvard.edu} if you observe any problems. 
	
{p}Please cite upon use: Hicks, Raymond and Dustin Tingley (2011) mediation: STATA package for causal mediation analysis, 
as well as the below journal articles that form the theoretical basis of the package.	
	
{title:Also see}

{p}Further details on the analytical formulas and on the algorithms 
used in these programs  can be found under  
{browse "http://imai.princeton.edu/projects/mechanisms.html":http://imai.princeton.edu/projects/mechanisms.html} 

{title:Bibliography and Sources}

{p 0 2}
The procedures used for estimation are discussed extensively elsewhere. {p_end}

{p 4 6}Imai, Kosuke, Luke Keele and Dustin Tingley (2010) A General Approach to Causal Mediation Analysis, Psychological Methods 15(4) pp. 309-334. 

{p 4 6}Imai, Kosuke, Luke Keele and Teppei Yamamoto (2010) Identification, Inference, and Sensitivity Analysis for Causal Mediation Effects, Statistical Sciences, 25(1) pp. 51-71. 

{p 4 6}Imai, Kosuke, Luke Keele, Dustin Tingley, and Teppei Yamamoto. (2009) "Causal Mediation Analysis Using R" in Advances in Social Science Research Using R, ed. H. D. Vinod New York: Springer. Forthcoming.
{p_end}
{p 0 2}
{p_end}

{p 0 2}
A companion package in R is available at {browse "http://cran.r-project.org/web/packages/mediation/":http://cran.r-project.org/web/packages/mediation/}. 
{p_end}


