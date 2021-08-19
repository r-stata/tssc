{smcl}
{* 20Oct2020}{...}
{title:Title}

{phang}
{bf:psreg} {hline 2} blocking with regression adjustments
 

{title:Syntax}

{p 4 6 2}
{cmd:psreg} depvar treatment indepvars [{cmd:if} {it:exp}] [{cmd:,} {cmd:logit} {cmd:ate} 
{cmdab:groups}{cmd:(}{it:integer}{cmd:)}   {cmdab:com:mon}  {cmdab:qui:etly} ]

{title:Description}

{pstd}
This command implements the blocking with regression adjustments, proposed by Imbens (2015). It relies on the estimate of the propensity score and uses regressions in subclasses (blocks) of the propensity score.  
The ATT is given by estimates within-block averaged for the number of treated units in each block. 
In the case of ATE the estimates are averaged for the number of units (treated and untreated) in each block.
The treatment is identified by the variable treatment, which takes value 1 if the unit is treated and value 0 for the untreated unit.
This version of the command does not allow for interaction between the treatment and other variables.

{pstd}{cmd: psreg} reports the number of blocks and the number of observations (treated and controls) used in the analysis. 

{pstd}{cmd: psreg} creates the variable {cmd:_blockgroup} that indicates to which group each observation belongs.

{title:Options}

{phang}
{cmd:logit} uses logit instead of the default probit to estimate the propensity score.

{phang}
{cmd:ate} computes the ATE instead of the default ATT.

{phang}
{cmd:common} restricts analysis to the common support dropping treated observations whose propensity score is higher than the maximum or lower than the minimum propensity score of the untreated observations.
In the case of ATE it also drops untreated observations whose propensity score is higher than the maximum or lower than the minimum propensity score of the treated.

{phang}
{cmd:groups} defines a specific number of blocks, with an equal number of units in each block. The number of units refers to the number of treated in the case of ATT and to the number of observations (treated and untreated) in the case of ATE.
The default is the optimal number of blocks according to the algorithm presented by Imbens (2015).

{phang}
{cmd:quietly} does not print the regressions within each block.


{title:Examples}

Define the optimal number of blocks. Compute ATT.
    {inp: . psreg employed treatment female native age emp_status12 emp_status24}

Use logit instead of probit. Compute ATT. Restrict analysis to common support. Do not print the regressions results.
    {inp: . psreg employed treatment female native age emp_status12 emp_status24, logit common quietly}

Define a specific number of blocks using the option group(). Compute ATE instead of ATT.
    {inp: . psreg employed treatment female native age emp_status12 emp_status24, groups(3) ate}


{title:Stored results}

    {inp: psreg} stores the following in {inp:r()}:
	{inp:r(att)}	the average treatment effect on treated (ATT)
	{inp:r(seatt)} 	the standard error of att
	{inp:r(ate)}  	the average treatment effect (ATE)
	{inp:r(seate)} 	the standard error of ate


{title:References}

Imbens, G. W. (2015). Matching methods in practice: Three examples. Journal of Human Resources, 50(2), 373-419.

Caliendo, M., & Kopeinig, S. (2008). Some practical guidance for the implementation of propensity score matching. Journal of economic surveys, 22(1), 31-72.

Rosenbaum, P. R., & Rubin, D. B. (1983). The central role of the propensity score in observational studies for causal effects. Biometrika, 41-55.

{title:Author}

{pstd}
Martina Bazzoli, FBK-IRVAPP.

{pstd}
Silvia De Poli, JRC-Seville.

{pstd}
Daniela Piazzalunga, FBK-IRVAPP.

PSREG IS IN ITS FIRST RELEASE. THE AUTHORS ASSUME NO RESPONSIBILITY FOR THE RESULTS AND THE COMMAND IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.

Psreg is not an official stata command. It is a free contribution to the research community. Please cite as: "Bazzoli, M., De Poli, S., Piazzalunga, D. (2020). PSREG: Stata module for blocking with regression adjustments".

If you observe any problems {browse "mailto:bazzoli@irvapp.it"} {browse "mailto:silvia.de-poli@ec.europa.eu"} {browse "mailto:piazzalunga@irvapp.it"}
