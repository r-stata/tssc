{smcl}
{* 20dec2019}{...}
{cmd:help cub}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:cub}}{hline 1} Ordinal outcome model estimated by a mixture of a Uniform and a shifted Binomial {p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:cub}
{it:outcome} 
{ifin}
{weight}{cmd:,}
[{cmd:pi}{cmd:(}{it:varlist_pi}{cmd:)}
{cmd:xi}{cmd:(}{it:varlist_xi}{cmd:)}
{cmd:shelter}{cmd:(}{it:#}{cmd:)}
{cmd:m}{cmd:(}{it:#}{cmd:)}]

{pstd}{cmd:fweight}s and {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd} {cmd:cub} estimates a probability model for an ordinal {it:outcome} variable, where the probability to observe 
a specific ordinal value (a preference for a given commodity, for instance) is modeled as a mixture of a Uniform and a shifted Binomial distribution.  
The Uniform distribution models individual {it:uncertainty} in setting a preference, whereas the
shifted Binomial distribution is the law of probability governing individual {it:feeling} on the item. 
The user can specify the covariates expected to drive individual uncertainty, as well as those possibly affecting individual feeling.
Furthermore, {cmd:cub} can handle categories presenting an exceptional large frequency (the so-called "shelters") thus
accounting for model inflation. The parameters of the {cmd:cub} model are estimated via maximum likelihood.   


{title:Options}

{phang} {cmd:pi}{cmd:(}{it:varlist_pi}{cmd:)} specifes the covariates explaining the "uncertainty" parameter.

{phang} {cmd:xi}{cmd:(}{it:varlist_xi}{cmd:)} specifes the covariates explaining the "feeling" parameter.

{phang} {cmd:shelter}{cmd:(}{it:#}{cmd:)} specifies the "shelter", i.e. the category presenting an exceptional high frequency. 

{phang} {cmd:m}{cmd:(}{it:#}{cmd:)} specifies the number of categories of the dependent variable, both observed and hidden (whenever hidden categories are present). 
If this option is not specified, only observed categories are considered in the estimation phase.


{title:Example} 

********************************************************************************
* GENERATE A DATASET WITH M=5 (I.E. 5 PREFERENCE LEVELS)
********************************************************************************
. clear 
. set more off
. set obs 3000
. set seed 10101
. global A=5
. gen Y=rpoisson($A)
. keep if Y>0 & Y<=$A
. gen x1=round(runiform(5,8))
. gen x2=round(runiform(1,6))
. gen x3=exp(round(runiform(3,5)))
. gen x4=rnormal(2,5)
********************************************************************************
* ESTIMATE THE MODEL VIA "cub"
********************************************************************************
. cub Y , pi(x3 x2 x1) xi(x3 x4) vce(oim)
********************************************************************************


{title:Remarks} 

{pstd} The {it:outcome} variable has to be coded as an integer taking value as 1, 2, 3,..., M.

  
{title:References}

{phang}
Piccolo, D., and Simone, R. 2019a. The class of CUB models: statistical foundations, inferential issues and empirical evidence. {it:Statistical Methods & Applications}, Vol. 28, pp. 389–435.
{p_end}

{phang}
Piccolo, D., and Simone, R. 2019b. Rejoinder to the discussion of "The class of cub models: statistical foundations, inferential issues and empirical evidence". {it:Statistical Methods & Applications}, Vol. 28, Issue 3, pp. 477–493.
{p_end}

{phang}
Baum, F.C., Cerulli, G., Di Iorio, F., Piccolo, D., Simone, R. 2018, {it:The Stata module CUB for fitting mixture models for ordinal data}. Presented at: "The 2018 Italian Stata Users Group meeting", Bologna, 15 November. 
{p_end}

{phang}
Piccolo, D. 2006. Observed information matrix for cub models. {it:Quaderni di Statistica}, Vol. 8.
{p_end}



{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute for Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Acknowledgements}

{phang}
I wish to thank Kit Baum, Francesca Di Iorio, Domenico Piccolo, and Rosaria Simone for their help and suggestions in improving this work. I am also grateful to the organizers and participants to the 2018 Italian Stata Users Group meeting held in Bologna (Italy) on the 15th of November 2018.  
{p_end}     

{title:Also see}

{psee}
Online: {helpb scattercub} , {helpb pr_prob_cub} , {helpb gr_prob_cub} , {helpb glm}
{p_end}