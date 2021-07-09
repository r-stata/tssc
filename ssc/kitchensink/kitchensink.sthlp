
{smcl}
{* *! Version 1.1.0 by Francisco Perales 24-April-2013}{...}
{bf:help kitchensink}
{hline}


{title:Title}

    {bf:kitchensink} -  Returns the model with the highest number of statistically significant predictors
	
	
{title:Syntax}

{p 8 12}{cmd:kitchensink} {depvar} {indepvars} {ifin} [, {it:options}]


{it:options}		description
{hline}

Main
 {cmdab:lev:el}({it:real})  	establishes the significance level necessary for a regressor to be considered statistically significant
 {cmdab:log:it} 	   	specifies that the desired model is a logistic regression model for a binary outcome variable
 {cmdab:aic} 	   	additionally gives the best fitting model using Akaike Information Criteria
 
{hline}


{title:Description}

{p 0 4}	{cmd:kitchensink} promotes bad practice amongst the scientific community by returning the regression model with the highest number of
statistically significant regressors using the outcome variable specified in {depvar} and a combination of the explanatory variables specified
in {indepvars}. More 'serious' use of {cmd:kitchensink} can be made by specifying the option {cmd:aic}, which gives the best fitting possible
model as denoted by Akaike's information criteria. Note that {cmd:kitchensink} requires Nicholas Cox's {cmd:tuples} routine to be installed
and allows for a maximum of 10 explanatory variables.

 
{title:Options}
	
{p 0 4}{cmdab:lev:el}({it:number}) establishes the significance level necessary for a regressor to be considered statistically significant.
By default, {cmd:kitchensink} uses the 90% level of statistical significance if {cmdab:lev:el} is not specified.

{p 0 4}{cmdab:log:it} must be used when the desired model is a logistic regression model for a binary outcome variable. If {cmdab:log:it} is not specified, {cmd:kitchensink} fits a linear probability model.

{p 0 4}{cmdab:aic} requests that Akaike's information criteria or AIC (Akaike 1974) be used to determine the best fitting possible model. The best fitting model using AIC and the model with the highest number of statistically significant variables are both returned.


{title:Examples}

{p 4 8}{inp:. webuse auto, clear}

{p 4 8}{inp:. ssc install tuples}

{p 4 8}{inp:. kitchensink price mpg headroom trunk weight length turn displacement gear_ratio foreign}

{p 4 8}{inp:. kitchensink price mpg headroom trunk weight length turn displacement gear_ratio foreign, level(90)}

{p 4 8}{inp:. kitchensink price mpg headroom trunk weight length turn displacement gear_ratio foreign, level(99)}

{p 4 8}{inp:. kitchensink price mpg headroom trunk weight length turn displacement gear_ratio foreign, aic}

{p 4 8}{inp:. quietly summarize price, de}

{p 4 8}{inp:. generate expensive = price > r(p75) }

{p 4 8}{inp:. kitchensink expensive mpg headroom trunk weight length turn displacement gear_ratio, logit}

{p 4 8}{inp:. kitchensink expensive mpg headroom trunk weight length turn displacement gear_ratio, logit level(99) aic}


{title:References}
  
{p 4 8} Akaike, H. (1974) 'A New Look at the Statistical Model Identification' {it:IEEE Transactions on Automatic Control} 19(6): 716–723
 
{p 4 4} Cox, N. (2006, revised 2011) {it:'TUPLES: Stata module for selecting all possible tuples from a list'}
Available online at: econpapers.repec.org/software/bocbocode/s456797.htm
 
 
{title:Author}

    Francisco Perales
    School of Social Science
    The University of Queensland
    Brisbane
    QLD 4072
    Australia
    f.perales@uq.edu.au                 

	
	