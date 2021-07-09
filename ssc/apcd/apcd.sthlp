{smcl}
{* 05APR2012}{...}
{hline}
help for {hi:apcd}
{hline}

{title:Generalized linear models for age-period-cohort effects with detrended coefficients}

{p 4}Syntax

{p 8 14}{cmd:apcd} {it:depvar} [{it:indepvars}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{it:weight}]
{cmd:, [}
{cmd:age(}{it:string}{cmd:)}
{cmd:period(}{it:string}{cmd:)}
{bind:{it:glm_options} ]}

{p 4} {cmd:apcd} allows all {it:varlists} &  {it:weights}  that {cmd:glm} accepts.


{title:Description}

{p} {cmd:apcd} estimates age-period-cohort APC-D (detrended) models and provides 
detrended (0 sum and 0 slope) parameters of age, period and cohort effects; 
appropriate constraints offer a unique solution & solve the traditional APC 
identification problem. 
This ado file quotes fractions of the Yang & colleagues (2006) 
apc_ie.ado file (ssc install apc) 
even if the apcd method does not retain the idea of an "intrinsic" "best" trend. 
We focus on cohort parameters (DCE=detrended cohort effect) that should be tested 
to be non-zeros across cohort span. 

The user provides a dependant variable, age and period, and controls from a microdata 
series of crossectional surveys. 
The data must be a complete rectangle (age x period) and the pace between periods must 
be fix and equal to the distance between age groups. If not, the procedure will fail.  

The procedure delivers :
(1) An APC-Detrended model with controls, including zero-sum/zero-slope parameters of 
	age, period & cohort effects.
(2) Delta BICs are provided to perform a diagnosis of the importance of cohort effects  


{title:Options}

{p 0 4} {cmd:age(}{it:string}{cmd:)} and {cmd:period(}{it:string}{cmd:)} 
specify the names of age and period variables. They must be given by the user.

{p} Any {it:glm_options} can be valid options for {cmd:apcd}. 

{p} Many types of model can be handled by {cmd:apcd} : 

{p} 	* the user must call "family(bin) link(logit)" for a logit regression

{p} 	* the user must call "family(poisson) link(log) exposure(pop)", 
	  where pop is the population at risk, for a poisson model

{p} 	* the default "family(gauss) link(id)" will provide a linear regression. 


{p} Since {cmd:apcd} makes use of constraints, this package should be 
processed on STATA 11.0 or higher.  

{title:example}

{p} {cmd:use "http://www.louischauvel.org/apchexb.dta", clear} 

{p} {cmd:apcd mf2 , age(age) period(year)} 

{title:References}

{p 0 4} see http://www.louischauvel.org/apcdex.htm for working paper and examples on apcd. 

{p 0 4} see Yang, Y., Fu, W., and Land, K. 2006. {cmd:apc_ie} and  {cmd:apc_cglm} 
STATA packages.

{title:Author}

Louis Chauvel
Sciences Po Paris
During the completion of the v1.0
Louis Chauvel was also invited Pr at Columbia U 
Dpt of sociology, Knox Hall
chauvel@louischauvel.org

{title:Also see}

{p 0 19} Online: help for {help glm}. {p_end}



