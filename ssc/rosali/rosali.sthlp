{smcl}
{* june2020}{...}
{hline}
help for {hi:rosali}{right:Myriam Blanchin - Priscilla Brisson}
{hline}

{title:Detection of response shift at item-level between 2 times of measurement}

{p 4}{cmd:rosali} {it:varlist} [{it:if}] [{it:in}] [, {cmdab:group}({it:string}) {cmdab:nodif} {cmdab:detail}]

{p 4 4 4 140}{it:varlist} contains the list of items: the first part of the list is composed of the items at time 1 and the second part of the items at time 2, in the same order.

{title:Description}

{p 4 12 2 140}{cmd:rosali} performs the {bf:R}esp{bf:O}nse {bf:S}hift {bf:AL}gorithm at {bf:I}tem-level (ROSALI) based on partial credit models 
between two times of measurement, time 1 and time 2. Only uniform or non-uniform {bf:r}e{bf:c}alibration can be detected. Response shift detection is performed at item-level assuming all individuals of the sample are affected the same way by default. A dichotomous group variable can be specified with the {cmd:group} option to assess its impact on latent variable, item functioning and response shift. {bf:D}ifferential {bf:I}tem {bf:F}unctionning (DIF) refers to a constant difference of item difficulties between groups over time. 

{title:Options}

{p 4 12 2 140}{cmd:group}({it:string}) specifies a binary group variable that can affect item functioning, the estimation of the latent variable means (group effect) 
and response shift. Response shift can be common to both groups or differential (occuring in only one group or affecting both groups differentially). By default, response shift detection is performed assuming all individuals are affected in the same way.

{phang}{cmd:nodif} assumes no DIF occurs in the sample and skips DIF detection. Only response shift detection is performed. {it:Use only with group option.}

{phang}{cmd:detail} displays results of each step of ROSALI.  

{title:Remarks}

{p 4} {it:Data} must be in wide format, one row per individual.

{p 4} At least two items per time of measurement are required.

{p 4 12 2 140} {cmd:automatic recoding for response categories}
{break} Response categories are automatically recoded to start from 0.
{break} If a response category is not used at one time of measurement, this category is automatically recoded at both times of measurement (for each group if group option).
{break} Rules for automatic recoding: 
{break} - 0 response category: merged with response category 1.
{break} - most difficult response category: merged with the previous one.
{break} - other response categories: randomly merged with the next or previous adjacent one.
 
{title:Outputs}

{p 4 12 2 140}{bf:Matrix:}

{phang}{cmd:r(test_model)}: Result of LRT between models A/B and models 1/2: chi-square statistic, DF and p-value.

{phang}{cmd:r(model_#)}: Item difficulties and latent trait distribution parameters of models #2 or #4 : Estimates, standard errors, 95% confidence interval, chi-square statistics, DF and p-values. 

{title:Examples}

{phang}{cmd: . rosali m0gh1 m0gh2 m0gh3 m0gh4 m0gh5 m6gh1 m6gh2 m6gh3 m6gh4 m6gh5, detail } 

{phang}{cmd: . rosali it1_t1-it9_t2 , group(cancer_site) } 

{title:Reference}

{p} Blanchin, M., Guilleux, A., Hardouin, J.-B., & Sébille, V. (2020). Comparison of structural equation modelling, item response theory and Rasch measurement theory-based methods for response shift detection at item level: A simulation study: Statistical Methods in Medical Research, 19(4), 1015–1029. https://doi.org/10.1177/0962280219884574

{title:Authors}

{p}Myriam Blanchin, Research engineer, PhD, SPHERE - UMR INSERM U1246, "methodS in Patient-centered outcomes and HEalth ResEarch", University of Nantes, France {browse "mailto:myriam.blanchin@univ-nantes.fr":myriam.blanchin@univ-nantes.fr}
{break}Priscilla Brisson, SPHERE - UMR INSERM U1246, "methodS in Patient-centered outcomes and HEalth ResEarch", University of Nantes, France


