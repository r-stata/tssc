{smcl}
{* 14jun2009}{...}
{hline}
help for {hi:fagani}
{hline}

{title:Fagan's bayesian nomogram}

{p 4 8 2}{cmd:fagan} {hi:#prev} {hi:#lrp} {hi:#lrn} [{cmd:,} {it:options}]{p_end}

{p 4 8 2} where  {p_end}
{p 4 8 2}{hi:#prev} is the prior or pretest probability of disease {p_end}
{p 4 8 2}{hi:#lrp} is the likelihood ratio of a positive test result {p_end}
{p 4 8 2}{hi:#lrn} the likelihood ratio of a negative test result {p_end}

{title:Description}

{p 4 8 2}{cmd:fagani} creates a plot showing the relationship between the prior probability, the LR (combination of sensitivity and specificity), and the posterior probability. {p_end} 

{title:Remarks}

{p 4 8 2} It is an immediate command, see help {help immed}. {p_end}
{p 4 8 2} When Bayes theorem is expressed in terms of log-odds, the posterior log-odds are a linear function of the prior log-odds and the log likelihood ratio. {p_end}
{p 4 8 2} {cmd:fagan} plots an axis on the left with the prior log-odds, an axis in the middle representing the log likelihood ratio and an axis on the right representing the posterior log-odds. {p_end}  
{p 4 8 2} Lines are drawn from the prior probability on the left through the LRs in the center and extended to the respective posterior probability on the right. {p_end}

{title:Options}

{p 4 8 2} {cmdab:legend:opts(}{it:#}{cmd:)} specify options that affect the plot legend.  {p_end}
{p 4 8 2} {cmd:ysize()} and {cmd:xsize()} specify the height and width of plot respectively.  {p_end}



{title:Example}

	. {stata "fagani 0.5 14.4 0.25"} 

	. {stata "fagani 0.25 20 0.05, ysize(8) xsize(6)"} 

	. {stata "fagani 0.45 6.4 0.25, scheme(s2mono)"} 


    
{title:Author}

{p 4 4 2} Ben Adarkwa Dwamena, Division of Nuclear Medicine, Department of Radiology, University of Michigan Medical School, Ann Arbor, Michigan. {p_end}
