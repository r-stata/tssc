{smcl}
{* 30jan2014}{...}
{hline}
help for {cmd:predxcat}
{hline}

{title:Predicted means, medians, or probabilities for nominal X's}   

{p 6 21 2} 
{cmdab:predxcat} {it:yvar} [{cmd:if} {it:exp}] [{cmd:in} {it:range}]{cmd:,}
   {cmd:xvar(}{it:xvar1} [{it:xvar2}]{cmd:)}
   [ {cmdab:adj:ust(}{it:covlist}{cmd:)} 
   {cmdab:mod:el} 
   {cmdab:l:evel(}#{cmd:)}
   {cmdab:lin:ear} 
   {cmdab:med:ian} 
   {cmdab:g:raph} 
   {cmdab:b:ar}
   {cmdab:xsec:tional}
   {cmdab:cl:uster(}{it:cluster_var}{cmd:)}
   {cmdab:sav:epred(}{it:filename}{cmd:)}
   {it:graph_options}
   ]


{title:Description}

{p 4 8 4}
{cmd:predxcat} calculates and optionally graphs means from linear regression
   models, medians from quantile regression models, or probabilities / proportions
   from logistic regression models for one or two nominal X variables, adjusted
   for covariates. If a second X is specified, means, medians, or probabilities /
   proportions are calculated for all possible combinations of X categories, and an
   interaction effect is tested. Optionally, model estimates and/or a graph
   may be displayed. Indicator variables are created for {it:xvar1}. The lowest
   indicator variable defaults to the reference group. If {it:xvar2} is specified,
   indicator variables are created for it, as well as interaction terms.
   (Alternative to {help margins} command.)

 
{title:Variables and options required}

{p 4}{it:yvar} is the dependent variable

{p 8 8 2}If {it:yvar} is continuous, defaults to linear regression

{p 8 8 2}If {it:yvar} is binary (0,1), defaults to logistic regression


{p 4 8 2}
{cmd:xvar(}{it:xvar1}{cmd:)} is the nominal variable for categories of estimated
  means, medians, or probabilities

{p 4 8 2}
{cmd:xvar(}{it:xvar1 xvar2}{cmd:)} gives categories of all combinations of 
  {it:xvar1} and {it:xvar2}; interaction between {it:xvar1} and {it:xvar2} is
  tested (Partial F for linear or quantile regression and likelihood ratio test
  for logistic regression)

        
{title:Options} 

{p 4 8 2}   
{cmd:adjust(}{it:covlist}{cmd:)} lists any covariates. If none are specified,
   unadjusted means, medians, or probabilities are reported. Covariates are set
   to their mean, based on observations used in the analysis, or can be set to
   user specified values (e.g., age=50 gender=1). (Note: if an {cmd:adjust}
   variable is nominal with more than 2 categories, it must be defined with
   indicator variables in the {cmd:adjust} list, whereas indicator variables
   are created automatically in the {cmd:xvar} option)

{p 4 8 2}   
{cmd:model} -- for display purposes only, this option prints the regression table

{p 4 8 2}   
{cmd:level(}#{cmd:)} -- specifies the confidence level, in percent, for
   calculation of confidence intervals (default=95%)

{p 4 8 2}   
{cmd:graph} -- if one X ({it:xvar1}), graphs means, medians, or probabilities and
   confidence intervals; if both {it:xvar1} and {it:xvar2} are specified, points
   are graphed for each mean, median, or probability, but confidence intervals are
   not graphed; {it:xvar1} is used for the x-axis with separate points for
   categories of {it:xvar2}

{p 4 8 2}
{cmd:xsectional} -- option for y axis label on graph for cross-sectional studies; 
   does not use the term "probabilties" in the label on the y axis

{p 4 8 2}   
{cmd:bar} -- can be used with the {cmd:graph} option to display a bar graph
  instead of points

{p 4 8 2}   
{cmd:linear} -- requests linear regression when {it:yvar} is binary (0,1); if not 
    specified, logistic regression is assumed

{p 4 8 2}   
{cmd:median} -- requests quantile regression when {it:yvar} is continuous

{p 4 8 2}
{cmdab:cluster(}{it:cluster_var}{cmd:)} -- Name of cluster variable; adjusts standard
     errors for intraclass correlation
  
{p 4 8 2}   
{cmd:savepred(}{it:filename}{cmd:)} -- saves adjusted values and CI's to a Stata file


{title:Examples}

{p 4 8 2}{cmd:. predxcat chol, xvar(race) adjust(sbp age=50) model}

{p 8 8 2}
Uses linear regression to calculate mean cholesterol level by race category,
  adjusted for mean sbp and age=50; displays model

{p 4 8 2}{cmd:. predxcat chol, xvar(ses) adjust(sbp age) graph}

{p 8 8 2}
Uses linear regression to calculate mean cholesterol by levels of
  socio-economic status, adjusted for sbp and age; displays graph

{p 4 8 2}{cmd:. predxcat htn, xvar(gender race) adjust(age smoke etoh) graph bar xsectional}

{p 8 8 2}
Uses logistic regression to calculate proportion of hypertensives for all
  combinations of gender (2 categories) and race (4 categories) for a total
  of 8 proportions, adjusted for age, smoking status, and alcohol consumption;
  tests for interaction between gender and race

{p 4 8 2}{cmd:. predxcat htn, xvar(race gender) adjust(age smoke etoh) graph bar}

{p 8 8 2}
Uses logistic regression to calculate the adjusted probabilities of hypertension
  for all combinations of gender and race; bar graph of probabilities with race
  on the x-axis


{title:Also see}

{p 4 13 2}
Manual:  {hi:[U] 23 Estimation and post-estimation commands},{break}
{bf:[R] margins}


{title:Author}

{p 4 8 2}
{hi:J.Garrett}, Professor, School of Medicine, University of North Carolina,
  Chapel Hill, NC. 
  Email: {browse "mailto:joanne_garrett@med.unc.edu":joanne_garrett@med.unc.edu}
