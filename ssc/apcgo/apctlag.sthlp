{smcl}
{* 05APR2012}{...}
{hline}
help for {hi:apctlag}
{hline}

{title:Generalized linear models for age-period-cohort effects including trends for each parameter}

{p 4}Syntax

{p 8 14}{cmd:apctlag} {it:depvar} [{it:indepvars}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{it:weight}]
{cmd:, [} 
{cmd:age(}{it:varname}{cmd:)}
{cmd:period(}{it:varname}{cmd:)} {cmd:rep(}{it:real}{cmd:)}{bind:{it: glm_options} ]}

{p 4} {cmd:apctlag} allows all {it:varlists} &  {it:weights}  that {cmd:glm} accepts.


{title:Description}

{cmd:apctlag} estimates age-period-cohort APC-T (trended) models and provides trended parameters of age,
 period and cohort effects (The trend in age is set to be the average effect of ageing of cohorts observed
 in the window of observation); appropriate constraints offer a unique solution & solve the traditional 
 APC identification problem. The user provides a dependant variable, age and period, and controls from 
 a microdata series of crossectional surveys. It is possible to obtain confidence intervals using bootstap, 
 by providing the number of repetitions (the rep argument). The data must be a complete rectangle (age x period) 
 and the pace between periods must be fix and equal to the distance between age groups. If not, the procedure 
 will fail.  


This ado file quotes fractions of the Yang & colleagues (2006) 
apc_ie.ado file (ssc install apc) and chauvel (2012) apcd.ado
 

{title:Options}

{p 0 4} {cmd:age(}{it:string}{cmd:)} and {cmd:period(}{it:string}{cmd:)} 
specify the names of age and period variables. They must be given by the user.

{p}  {cmd:rep(}{it:real}{cmd:)}
Number of repetitions for bootstrap. When set to zero (default), no confidence interval will be provided.

{p} Any {it:glm_options} can be valid options for {cmd:apctlag}. Poisson models are not recommened for bootstrap.

{p} Many types of model can be handled by {cmd:apctlag} : 

{p} 	* the user must call "family(bin) link(logit)" for a logit regression

{p} 	* the user must call "family(poisson) link(log) exposure(pop)", 
	  where pop is the population at risk, for a poisson model

{p} 	* the default is "family(gauss) link(id)" and will provide a linear regression. 


{p} Since {cmd:apctlag} makes use of constraints, this package should be 
processed on STATA 11.0 or higher.  


{title:example}

{p} {cmd:use "http://www.louischauvel.org/apcgoex.dta", clear } 

{p} {cmd:	keep if fem==0  & a5<65} 

{p} {cmd:		apctlag vet [w=pwei], age(a5) period(y5) f(bin) l(logit) }

{p} {cmd:		apctlag vet [w=pwei], age(a5) period(y5) rep(10) f(bin) l(logit) } 
 

{title:References}


{p 0 4} Chauvel, L., Hartung, A., & Bar-Haim, E. 2016. Closing or Persisting Gender Gap? A Cohort Analysis of Education and Wages in the US and Europe.

{p 0 4} see Yang, Y., Fu, W., and Land, K. 2006. {cmd:apc_ie} and  {cmd:apc_cglm} 
STATA packages.

{title:Author}
   Louis Chauvel,
   louis.chauvel@uni.lu
   Anne Hartung
   anne.hartung@uni.lu
   Eyal Bar-Haim
   eyal.bar-haim@uni.lu
   PEARL Institute for Research on Socio-Economic Inequality (IRSEI), University of Luxembourg  


{title:Also see}

{p 0 19} Online: help for {help glm}. {p_end}
{p 0 19} Online: help for {help apcgo}. {p_end}
{p 0 19} Online: help for {help apcd}. {p_end}



