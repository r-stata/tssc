{smcl}
{* 05APR2012}{...}
{hline}
help for {hi:apcgo}
{hline}

{title:Calculates age-period-cohort effects for the gap between two groups (based on a Blinder-Oaxaca decomposition), including trends for each parameter}

{p 4}Syntax

{p 8 14}{cmd:apcgo} {it:depvar} [{it:indepvars}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{it:weight}]
{cmd:, }
{cmd:age(}{it:varname}{cmd:)}
{cmd:period(}{it:varname}{cmd:)} {cmd:gap(}{it:varname}{cmd:)} [{cmd:rep(}{it:real}{cmd:)}]


{p 4} {cmd:apcgo} allows all {it:varlists} &  {it:weights}  that {cmd:oaxaca} accepts, and some options (see below).


{title:Description}

{cmd:apcgo} The procedure calculates the blinder-oaxaca decomposition for each periodXage group context and 
 estimates age-period-cohort APC-T (trended) models for the explained and unexplained gap. It provides trended 
 parameters of age, period and cohort effects (The trend in age is set to be the average effect of ageing 
 of cohorts observed in the window of observation); appropriate constraints offer a unique solution & solve the traditional 
 APC identification problem. The user provides a dependent variable, a binary gruop varaible (gap), age and period, and controls from 
 a microdata series of crossectional surveys. It is possible to obtain confidence intervals using bootstrap, 
 by providing the number of repetitions (the rep argument). The data must be a complete rectangle (age x period) 
 and the pace between periods must be fix and equal to the distance between age groups. If not, the procedure 
 will fail.  


This ado file quotes fractions of the Yang & colleagues (2006) 
apc_ie.ado file (ssc install apc) and chauvel (2012) apcd.ado
 

{title:Options}

{p 0 4} {cmd:age(}{it:string}{cmd:)} and {cmd:period(}{it:string}{cmd:)} 
specify the names of age and period variables. They must be given by the user.

{p}  {cmd:gap(}{it:string}{cmd:)}
The independent dichotomous  variable. Must be provided by the user.

{p}  {cmd:rep(}{it:real}{cmd:)}
Number of repetitions for bootstrap. When set to zero (default), no confidence interval will be provided.

{p}  {cmd:logit}
logit decomposition

{p}  {cmd:probit}
probit decomposition


{p} Since {cmd:apcgo} makes use of constraints, this package should be 
processed on STATA 11.0 or higher.  


{title:example}

{p} {cmd:use "http://www.louischauvel.org/apcgoex.dta", clear } 

{p} {cmd:*	        race / 1=caucasian AA=2}

{p} {cmd:*	          a5 / age }

{p} {cmd:*	          y5 / year}

{p} {cmd:*	   labincome / medianized labor personal income}

{p} {cmd:*	     pweight / sampling weight}

{p} {cmd:*	         vet / 1=veteran 0=no veteran satus}

{p} {cmd:*	          ED / level of education 6=drop out 7=ged 8=comunity coll ... 11=Ba 12=Ma+}

{p} {cmd:*	      female / male=0 female = 1}

{p} {cmd:*	       lnlab / ln of labincome}

{p} {cmd:keep if female==0  & a5<65}

{p} {cmd:* how the veteran premium changed?}

{p} {cmd:apcgo lnlab [w=pweight], gap(vet) age(a5) period(y5)  }

{p} {cmd:* what is the role of education in the veteran premium change? }

{p} {cmd:xi: apcgo lnlab i.ED if fem==0 [w=pwei], gap(vet) age(a5) period(y5) rep(1)}

	
	

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
{p 0 19} Online: help for {help oaxaca}. {p_end}
{p 0 19} Online: help for {help apctlag}. {p_end}
{p 0 19} Online: help for {help apcd}. {p_end}




