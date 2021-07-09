{smcl}
{* 02NOV2011}{...}
{hline}
help for {hi:apch}
{hline}

{title:Generalized linear models for age-period-cohort effects with hysteresis}

{p 4}Syntax

{p 8 14}{cmd:apch} {it:depvar} [{it:indepvars}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{it:weight}]
{cmd:, [}
{cmd:age(}{it:string}{cmd:)}
{cmd:period(}{it:string}{cmd:)}
{bind:{it:glm_options} ]}

{p 4} {cmd:apch} allows all {it:varlists} &  {it:weights}  that {cmd:glm} considers.


{title:Description}

{p} {cmd:apch} estimates age-period-cohort APC-D (detrended) models and provides 
detrended (0 sum and 0 slope) parameters of age, period and cohort effects; 
appropriate constraints offer a unique solution & solve the traditional APC 
identification problem. 
We focus on cohort parameters (DCE=detrended cohort effect) that should be tested 
to be non-zeros across cohort span. 
Their "hysteresis" (durability) over life course is assessed & tested by a coefficient 
h (hysteresis) that is 0 in case of linear stability of cohort effect, -1 in case of vanishing 
of the cohort effect over life span, equal to 1 in case of development from 0 of the cohort effect
over life course. 
Since the cohort parameters and the hysteresis parameter can not be assessed simultaneously, 
the package proposes an iterative strategy that converges to a single stable solution.  
The {cmd:apch} provides Raftery's bics able to assess the interest of cohort effect 
and then of hysteresis effect. 

The user provides a dependant variable, age and period, and controls from a microdata 
series of crossectional surveys. 
The data must be a complete rectangle (age x period) and the pace between periods must 
be fix and equal to the distance between age groups. If not, the procedure will fail.  

The procedure delivers :
(1) An APC-Detrended model with controls, including zero-sum/zero-slope parameters of 
	age, period & cohort effects.
(2) An APC-Hysteresis model with controls, delivering the h-hysteresis parameter of 
	linear stability of the DCE. 
(3) Delta BICs are provided to measure 
	(a) dbic_cohort : the interest of including cohort effects after a AP model and 
	(b) dbic_hyster : the interest of including hysteresis effects to the APC model 


{title:Options}

{p 0 4} {cmd:age(}{it:string}{cmd:)} and {cmd:period(}{it:string}{cmd:)} 
specify the names of age and period variables. They must be given by the user.

{p} Any {it:glm_options} can be valid options for {cmd:apch}. 

{p} Many types of model can be handled by {cmd:apch} : 

{p} 	* the user must call "family(bin) link(logit)" for a logit regression

{p} 	* the user must call "family(poisson) link(log) exposure(pop)", 
	  where pop is the population at risk, for a poisson model

{p} 	* the default "family(gauss) link(id)" will provide a linear regression. 


{p} Since {cmd:apch} makes use of complex constraints, this package should be 
processed on STATA 11.0 or higher.  

{title:example}

{p} {cmd:use "http://www.louischauvel.org/apchexb.dta", clear} 

{p} {cmd:apch mf2 , age(age) period(year)} 

{title:References}

{p 0 4} see http://www.louischauvel.org/apchex.htm for working paper and examples on apch. 

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



