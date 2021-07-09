{smcl}
{* 1jun2011}{...}
{hline}
help for {hi:medsens}
{hline}

{title: Function to estimate sensitivity analysis for causal mediation effects.}

{p 8 27}
{cmd:medsens}
{it: (equation 1) (equation 2) } 
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[, 
{cmd:sims}{cmd:(}{it:integer}{cmd:)}
{cmd:seed}{cmd:(}{it:integer} {cmd:)}
{cmd:Level}{cmd:(}{it:#}{cmd:)}
{cmdab:gr:aph}]
{cmdab:med:iate}{cmd:(}{it:varname}{cmd:)}
{cmd:treat}{cmd:(}{it:varname}{cmd:)}


{title:Description}

{p} {cmd:medsens} is the workhorse function for conducting sensitivity analyses for mediation effects. The analysis proceeds by quantifying the degree of sequantial ignorability violation as
the correlation between the error terms of the mediator and outcome models, and then calculating
the true values of the average causal mediation effect for given values of this sensitivity parameter,
rho. The original findings are deemed sensitive if the true effects are found to vary widely as
function of rho. Sensitivity analysis for mediation is highly recommended in the case of the single-experiment design where only the treatment variable is randomized (or ignorable conditional on covariates).
Currently the medsens function handles three common cases. 1) both the outcome and mediator are continuous, 2) the mediator is binary and the outcome is continuous, and 3) the mediator is continuous and outcome binary. 

{title:Options}

{p 0 4}                                                      
{cmdab:med:iate}{cmd:(}{it:varname}{cmd:)} is required and specifies the mediating variable 
to be used in the analysis.

{p 0 4} 
{cmd:treat}{cmd:(}{it:varname}{cmd:)} is also required and specifies the treatment variable used in the analysis. 
Values of 0 and 1 are used.

{p 0 4}  
{cmdab:sims(}{it:integer}{cmd:)} specifies the number of simulations to run. The default value is 100. For final production runs this should be set higher (~500) but note this will take longer.

{p 0 4}                                                      
{cmd:seed(}{it:integer}{cmd:)} sets the random number seed for precise replicability though with sufficient sims results will be very similar. The default value is the random seed 
 Stata draws when starting a session. 

{p 0 4} 
{cmd:eps}{cmd:(}{it:integer}{cmd:)} convergence tolerance parameter for the iterative FGLS. Only used when both
the mediator and outcome models are linear. The default value is .01. Typically users will not change this, and if so only will decrease it.

{p 0 4}  
{cmdab:gr:aph}, if specified, produces a graph of the results with the confidence intervals.

{p 0 4}                                                      
{cmd:Level(}{it:#}{cmd:)} sets the confidence interval; default is {cmd:level(95)}. 


{title:Examples}

{p 4 4 2}

{cmd:. medsens (regress M T x) (regress Y T M x), eps(.01) med(M) treat(T) sims(1000)}{break}
{cmd:. medsens (probit M T x) (regress Y T M x), eps(.01) med(M) treat(T) sims(1000) }{break}
{cmd:. medsens (regress M T x) (probit Y T M x), eps(.01) med(M) treat(T) sims(1000) }{break}

{p}{cmd:. twoway rarea  _med_updelta0 _med_lodelta0 _med_rho, bcolor(gs14) || line  _med_delta0 _med_rho , lcolor(black) ytitle("Average mediation effect") xtitle("Sensitivity parameter: p") legend(off) title("ACME(p)")} {break}

{title:Remarks}

{p} {cmd:medsens} only supports OLS and probit because sensitivity formula must be worked out on a case by case basis. 
Any estimation technique other than those will produce an error. In the case of a binary mediator and continuous outcome, the sensitivity analysis can take a long time especially with larger data sets. The estimate of the ACME as a function of rho may also be plotted with corresponding 95% confidence intervals. An example is given above of plotting delta(0).)

{title:Requires}

{p} {cmd:medsens} requires the moremata package. In not already installed then enter "net install moremata.pkg" into the command line.

{title:Saved results}

{p} The program stores the rho (the correlation in error terms) at which the ACME=0 in the scalar:
{inp:r(errcr)} . In addition, the product of R^2 for the mediator and outcome model at which the ACME=0 is also stored. 
This can be done using the proportions of residual variance in the mediator and outcome explained by the hypothesized unobserved confounder ({inp:r(r2s_thresh)}) or the proportions of total variance in the mediator and outcome explained by the hypothesized unobserved confounder ({inp:r(r2t_thresh)}).

{p} The program also creates variables for the Average Causal Mediation Effect (ACME) 
({inp:_med_delta0} and {inp:_med_delta1}) at each value of rho ({inp:_med_rho}). For both deltas, the low and high bounds of the 95% 
confidence interval are stored in the lo and hi variables. Each time the command is run, the existing created variables are dropped and new ones created.

{title:Authors} 
 
	{browse "rhicks@princeton.edu":Raymond Hicks} 
	Niehaus Center for Globalization and Governance, Princeton University 
  
	{browse "http://scholar.harvard.edu/dtingley":Dustin Tingley} 
	Government Department, Harvard University
  
{p}Email {browse "mailto:rhicks@princeton.edu":rhicks@princeton.edu} or {browse "mailto:dtingley@gov.harvard.edu":dtingley@gov.harvard.edu} if you observe any problems. 
			
{p}Please cite upon use: Hicks, Raymond and Dustin Tingley (2011) mediation: STATA package for causal mediation analysis, 
as well as the below journal articles that form the theoretical basis of the package.	

{title:Also see}

{p}Further details on the analytical formulas and on the algorithms 
used in these programs can be found under  
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


