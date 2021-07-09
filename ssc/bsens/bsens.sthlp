{smcl}
{* 1aug2005/10apr2006/15feb2007}{...}
{hline}
help for {hi:bsens}
{hline}

{title:Help for  bsens - Sensitivity metric using McNemar's test}

{p 8 14}{cmd:bsens} {it:cntdiscordant1} {it:cntdiscordant2}  {it:gamma_min} {it:gamma_increment} {it:gamma_max}

{title:Description}
{p}{cmd:bsens} is used for calculating the Rosenbaum sensitivity metric (gamma) using McNemar's statistic for analyses which have binary outcomes.  (Ref: Rosenbaum, Paul R(2002) Observational studies. Springer-Verlag). There are 5 input parameters for this command: cntdiscordant1, cntdiscordant2,  gamma_min , gamma_increment and gamma_max.

{it:cntdiscordant1} is the number of discordant pairs of control and treated with outcome variable 1 in the control group.
{it:cntdiscordant2} is the number of discordant pairs of control and treated values with outcome variable 1 in the treated group.
{it:gamma_min}is the initial value of gamma.
{it:gamma_increment} is the increments in which gamma would change.
{it:gamma_max} is the maximum value of gamma.

{title:Acknowledgements}
{p}The program is named binary sensitivity and is written by Hemang C Subramanian and Eric Overby at the Georgia Institute of Technology.

{title:Limitations}
{p}The counts are used for k2k matches only, meaning strata which have 1 treated and 1 control observation. but  may fail to report accurately if discordant_count1 is greater than discordant_count2. 


{title:Examples}
{p 8 12}{stata "bsens 100 146 1 0.5 2" }

{title:Author}
Hemang C Subramanian
hemang.subramanian@scheller.gatech.edu
Eric Overby 
eric.overby@scheller.gatech.edu







