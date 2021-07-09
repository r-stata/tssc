
{smcl}
{* *! version 1.00 12june2009}{...}
{hline}
help for {hi:fagan} {right: (Ben Adarkwa Dwamena)}

{hline}

{title:Fagan's bayesian nomogram}

{title:Syntax}

{p 8 18 2}
{opt fagan}
{it:varlist} 
[{opt if} {it:exp}]
[{opt in} {it:range}]
[{opt ,} 
{options} *] 


 
{title:Description}

{p 4 8 2}
{hi:fagan} creates a plot showing the relationship between the prior probability specified by user over the range 0-1,
the likelihood ratio(combination of sensitivity and specificity), and posterior test probability. 
{hi:fagan} plots an axis on the left with the prior log-odds, an axis in the middle representing the log likelihood ratio
and an axis on the right representing the posterior log-odds. 
Lines are then drawn from the prior probability on the left through the likelihood ratios in the center 
and extended to the posterior probabilities on the right. {p_end}

{p 4 8 2}
{hi:fagan} requires a varlist of likelihood ratios positive and negative respectively i.e two or more sets of likelihood ratios.  {p_end}

{title:Options}
{p 4 8 2} {cmd:#prev} is the prior or pretest probability of disease {p_end}
{p 4 8 2}{cmd:grpvar()} subgroup variable name {p_end}
{p 4 8 2} {cmdab:legend:opts(}{it:#}{cmd:)} specify options that affect the plot legend.  {p_end}
{p 4 8 2} {cmd:ysize()} and {cmd:xsize()} specify the height and width of plot respectively.  {p_end}


{title:Remarks}

{p 4 8 2}
The clinical or patient-relevant utility of diagnostic test is evaluated using the likelihood ratios to calculate
post-test probability based on  Bayes' theorem as follows:  {p_end}
{p 4 8 2}
Pretest Probability=Prevalence of target condition {p_end}
{p 4 8 2}
Post-test probability= likelihood ratio x pretest probability/[(1-pretest probability) x (1-likelihood ratio)]  {p_end}


{p 4 8 2}
Assuming that the study samples are representative of the entire population, an estimate of the pretest 
probability of target condition is calculated from the global prevalence of this disorder across the studies.  {p_end}
{p 4 8 2} In this way, likelihood ratios are more clinically meaningful than sensitivities or specificities. 
This approach would be useful for the clinicians who might use the likelihood ratios generated from here to 
calculate the post-test probabilities of nodal disease based on the prevalence rates of their own practice population.  {p_end}

{p 4 8 2} Thus, this approach permits individualization of diagnostic evidence. 
This concept is depicted visually with Fagan's nomograms. When Bayes theorem is expressed in terms of log-odds, 
the posterior log-odds are linear functions of the prior log-odds and the log likelihood ratios.  {p_end}

{p 4 8 2} The farther the likelihood ratio is from 1, the larger the change will be from the pretest to the posttest probability.  {p_end}
{p 4 8 2} One can group likelihood ratios into magnitudes: {p_end}
{p 4 8 2} LR+ > 10 makes large and often conclusive increases in the likelihood of disease {p_end}
{p 4 8 2} LR+ 5-10 makes moderate increases {p_end}
{p 4 8 2} LR+ 2-5 makes small increases {p_end}
{p 4 8 2} LR+ 1-2 makes insignificant increases {p_end}
{p 4 8 2} LR- 0.5-1.0 makes insignificant decreases {p_end}
{p 4 8 2} LR- 0.2-0.5 makes small decreases {p_end}
{p 4 8 2} LR- 0.1-0.2 makes moderate decreases {p_end}
{p 4 8 2} LR- < 0.1 makes large and often conclusive decreases in the likelihood of disease  {p_end}


{title:Examples}

. {stata "use fagan.dta, clear"}

. {stata "fagan lrp lrn, grpvar(test)"}

. {stata "fagan lrp lrn, grpvar(test) pr(0.5)"}

. {stata "fagan lrp lrn, grpvar(test) pr(0.5) scheme(s2color)"}

{title:Author}

{p 4 2 2} Ben A Dwamena, Division of Nuclear Medicine, Department of Radiology, University of Michigan Medical School, Ann Arbor, Michigan. 
Email {browse "mailto:bdwamena@umich.edu":bdwamena@umich.edu}  {p_end}


{title:See Also}
Related commands:

{p 2 2}
{help fagani} (if installed) 

