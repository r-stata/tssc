{smcl}
{* 15apr2005}{...}
{hline}
help for {cmd:predxcon}
{hline}

{title:Predicted means, medians, or proportions for a continuous X variable}   
15
{p 8 23 2} 
{cmdab:predxcon} {it:yvar} [{cmd:if} {it:exp}] [{cmd:in} {it:range}]{cmd:,}
   {cmdab:x:var(}{it:xvar}{cmd:)}
   {cmdab:f:rom(}#{cmd:)}
   {cmdab:t:o(}#{cmd:)}
   {cmdab:i:nc(}#{cmd:)}
   [ {cmdab:adj:ust(}{it:covlist}{cmd:)} 
   {cmdab:p:oly(}#{cmd:)}
   {cmdab:cl:ass(}{it:classvar}{cmd:)}
   {cmdab:mod:el} 
   {cmdab:gr:aph}
   {cmdab:xsec:tional} 
   {cmdab:l:evel(}#{cmd:)}
   {cmdab:lin:ear} 
   {cmdab:med:ian}
   {cmdab:nol:ist}
   {cmdab:cl:uster(}{it:cluster_var}{cmd:)}
   {cmdab:sav:epred(}{it:filename}{cmd:)}
   {it:graph_options} ]


{title:Description}

{p 4 8 4}
{cmd:predxcon} calculates and prints predicted values (or proportions) and 95% 
   confidence intervals for linear, quantile, or logistic model estimates for a
   continuous X variable, adjusted for covariates.  Default prints predicted values
   and confidence intervals; model estimates and graph can be shown. Optionally a
   quadradic or a quadratic and cubic term can be added to the model. An
   interaction between X and a nominal variable can be estimated and graphed.
   Indicator variables are created for the nominal class variable with the lowest
   category defaulting to the reference group.


{title:Variables and options required}

{p 4}{it:yvar} is the dependent variable

{p 8 8 2}If {it:yvar} is continuous, defaults to linear regression

{p 8 8 2}If {it:yvar} is binary (0,1), defaults to logistic regression


{p 4 8 2}
{cmd:xvar(}{it:xvar}{cmd:)} -- continuous independent variable (interval or ordinal)

{p 4}{cmd:from(}#{cmd:)} -- bottom value for {it:xvar}

{p 4}{cmd:to(}#{cmd:)} -- top value for {it:xvar}

{p 4 8 2}
{cmd:inc(}#{cmd:)} -- increment size between bottom and top values (defaults to 1)


{title:Options} 

{p 4 8 2}   
{cmd:adjust(}{it:covlist}{cmd:)} lists any covariates. If none are specified,
   unadjusted means, medians, or probabilities/proportions are reported.
   Covariates are set to their mean, based on observations used in the analysis,
   or can be set to user specified values (e.g., age=50 gender=1). (Note: if
   an {cmd:adjust} variable is nominal with more than 2 categories, it must be
   defined with indicator variables in the {cmd:adjust} list, whereas indicator
   variables are created automatically in the {cmd:class} option)

{p 4 8 2}   
{cmd:poly(}2 or 3{cmd:)} -- polynomial terms added: 2=quadratic 3=quadradic and cubic
   (will not work with the {cmd:median} option)

{p 4 8 2}
{cmd:class(}{it:classvar}{cmd:)} -- nominal variable for an {it:xvar} by 
   {it:classvar} interaction

{p 4 8 2}   
{cmd:model} -- for display purposes only, this option prints the regression table

{p 4 8 2}   
{cmd:graph} -- displays graph of predicted values (or proportions) and 95% confidence
    intervals; if {cmd:class()} is requested, confidence intervals are not displayed

{p 4 8 2}
{cmd:xsectional} -- option for y axis label on graph for cross-sectional studies; 
   does not use the term "probabilties" in the label on the y axis

{p 4 8 2}   
{cmd:level(}#{cmd:)} -- specifies the confidence level, in percent, for
   calculation of confidence intervals (default=95%)

{p 4 8 2}   
{cmd:linear} -- requests linear regression when {it:yvar} is binary (0,1); if not 
    specified, logistic regression is assumed

{p 4 8 2}   
{cmd:median} -- requests quantile regression when {it:yvar} is continuous

{p 4 8 2}   
{cmd:nolist} -- does not print list of predicted values and 95% CIs

{p 4 8 2}
{cmdab:cluster(}{it:cluster_var}{cmd:)} -- Name of cluster variable; adjusts standard
     errors for intraclass correlation
  
{p 4 8 2}   
{cmd:savepred(}{it:filename}{cmd:)} -- saves adjusted values and CI's to a Stata file

    
{title:Examples}

{p 4 8 2}
{cmd:. predxcon chol, xvar(age) from(20) to(80) inc(5) adjust(sys hra)}

{p 8 8 2}
Using linear regression, calculates the predicted cholesterol values for
5-year increments of age from 20 years to 80 years (i.e., age=20,25,30,...,80)
adjusted for systolic blood pressure and heart rate; displays predicted values,
but does not display model or graph

{p 4 8 2}
{cmd:. predxcon chol, xvar(sys) f(60) t(280) i(20) adj(hra) graph class(race)}

{p 8 8 2}
Using linear regression, calculates the predicted cholesterol values for
systolic blood pressure readings from 60 to 280 in 20mm/hg increments by
categories of race, adjusted for heart rate; tests for an age by race
interaction; displays graph and list of predicted values

{p 4 8 2}
{cmd:. predxcon htn, xvar(chol) f(100) t(300) i(20) class(race) graph xsectional}

{p 8 8 2}
Using logistic regression, calculates the unadjusted proportion of hypertension
for cholesterol from 100 to 300 in 20-unit increments, by categories of race; 
displays a likelihood ratio test for interaction; graphs the results

{p 4 8 2}
{cmd:. predxcon htn, xvar(age) f(40) t(80) poly(3) adj(chol=250) graph}

{p 8 8 2}
Using logistic regression, estimates the probability of hypertension for 
1-yr increments of age; terms for age-squared and age-cubed included in model
using the poly(3) option; also adjusted to a cholesterol level of 250; displays
graph


{title:Author}

{p 4 8 2}
{hi:J.Garrett}, Professor, School of Medicine, University of North Carolina,
  Chapel Hill, NC. 
  Email: {browse "mailto:joanne_garrett@med.unc.edu":joanne_garrett@med.unc.edu}
      

