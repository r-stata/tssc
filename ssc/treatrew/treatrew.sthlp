{smcl}
{* 30aug2011}{...}
{cmd:help treatrew}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col: {hi:treatrew} {hline 1}}Estimation of Average Treatment Effects by reweighting on propensity score {p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:treatrew}
{it: outcome} 
{it: treatment}
[{it:varlist}]
{ifin}
{weight}{cmd:,}
{cmd:model}{cmd:(}{it:{help treatrew##modeltype:modeltype}}{cmd:)}
[{cmd:GRaphic}
{cmd:conf}{cmd:(}{it:number}{cmd:)}
{cmd:vce(robust)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.



{title:Description}

{pstd}{cmd:treatrew} estimates Average Treatment Effects by reweighting on propensity score
as proposed by Rosenbaum and Rubin (1983) in their seminal article.
Depending on the model specified, {cmd:treatrew} provides consistent estimation of Average Treatment 
Effects under the hypothesis of "selection on observables".
Conditional on a pre-specified set of observable exogenous variables x - thought of as those driving
the non-random assignment to treatment - {cmd:treatrew} estimates the Average Treatment Effect (ATE), 
the Average Treatment Effect on Treated (ATET) and  the Average Treatment Effect on Non-Treated (ATENT), 
as well as the estimates of these parameters conditional on the observable factors x (i.e., ATE(x), ATET(x) and ATENT(x)).
Parameters standard errors are provided either analytically (following Wooldridge, 2010, p. 920-930) and via bootstrapping. 
{cmd:treatrew} assumes that the propensity score specification is correct.

{phang} According to the syntax:

{phang} {it:outcome}: is the target variable over which measuring the impact of the treatment

{phang} {it:treatment}: is the binary treatment variable taking 1 for treated, and 0 for untreated units

{phang} {it:varlist}: is the set of pre-treatment (or observable confounding) variables

     
{title:Options}
    
{phang} {cmd:model}{cmd:(}{it:{help treatrew##modeltype:modeltype}}{cmd:)} specifies the model
for estimating the propensity score, where {it:modeltype} must be one out of these two:
 "probit" or "logit". It is always required to specify one model.   

{phang} {cmd:graphic} allows for a graphical representation of the density distributions of 
ATE(x), ATET(x) and ATENT(x). 

{phang} {cmd:vce(robust)} allows for robust regression standard errors in the probit or logit estimates.

{phang} {cmd:conf}{cmd:(}{it:number}{cmd:)} sets the confidence level of probit or logit estimates equal to the specified {it:number}. 
The default is {it:number}=95. 


{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt probit}}The propensity score is estimated by a probit regression{p_end}
{p2coldent : {opt logit}}The propensity score is estimated by a logit regression{p_end}
{synoptline}


{pstd}
{cmd:treatrew} creates a number of variables:

{pmore}

{pmore}
{inp:ATE_x} is an estimate of the idiosyncratic Average Treatment Effect.

{pmore}
{inp:ATET_x} is an estimate of the idiosyncratic Average Treatment Effect on treated.

{pmore}
{inp:ATENT_x} is an estimate of the idiosyncratic Average Treatment Effect on Non-Treated.



{pstd}
{cmd:treatrew} returns the following scalars:

{pmore}
{inp:e(N)} is the total number of (used) observations.

{pmore}
{inp:e(N1)} is the number of (used) treated units.

{pmore}
{inp:e(N0)} is the number of (used) untreated units.

{pmore}
{inp:e(ate)} is the value of the Average Treatment Effect.

{pmore}
{inp:e(atet)} is the value of the Average Treatment Effect on Treated.

{pmore}
{inp:e(atent)} is the value of the Average Treatment Effect on Non-treated.


{title:Remarks} 

{pstd} The treatment has to be a 0/1 binary variable (1 = treated, 0 = untreated).

{pstd} It is assumed that the probit or logit model is correctly specified.

{pstd} Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.


{title:Examples}

{pstd} {cmd:*** EXAMPLE ON "JTRAIN2.DTA"  ***}

   {inp:. #delimit ;}
   {inp:. xi: treatrew re78 train educ black re75 unem74 unem78 lre74 agesq mosinex ,}
   {inp:. vce(robust) conf(90) model(probit) gr  }
   {inp:. ;}

   {inp:. #delimit ;}
   {inp:. xi: treatrew re78 train educ black re75 unem74 unem78 lre74 agesq mosinex ,}
   {inp:. model(logit) vce(robust) conf(90)  gr }
   {inp:. ;}
   

{pstd} {cmd:*** EXAMPLE ON HOW TO BOOTSTRAP STD. ERR. FOR "ATET" AND "ATENT" ***}

   {inp:. #delimit ;}
   {inp:. xi: bootstrap ate=e(ate)  atet=e(atet)  atent=e(atent), rep(10):}
   {inp:. treatrew re78 train educ black re75 unem74 unem78 lre74 agesq mosinex ,}
   {inp:. model(logit) vce(robust) conf(90)  gr }
   {inp:. ;}

   
{title:References}

{phang}
Cameron, A.C., and P.K. Trivedi. 2005. {it:Microeconometrics: Methods and Applications}. 
Chapter 25. Cambridge University Press, New York.
{p_end}

{phang}
Cerulli, G. 2012. Ivtreatreg: a new STATA routine for estimating binary treatment models with heterogeneous 
response to treatment under observable and unobservable selection, 
{it:Working Paper Cnr-Ceris}, N° 03/2012.

{phang}
Rosenbaum, P., and D.B. Rubin. 1983. The Central Role of the Propensity Score in Observational Studies for Causal Effects. {it:Biometrika}, 70, 41-55.
{p_end}

{phang}
Wooldridge, J.M. 2002. {it: Econometric Analysis of Cross Section and Panel Data}. 
Chapter 18. The MIT Press, Cambridge.
{p_end}

{phang}
Wooldridge, J.M. 2010. {it: Econometric Analysis of Cross Section and Panel Data, 2nd Edition}.
Chapter 21. The MIT Press, Cambridge.
{p_end}


{title:Acknowledgments}

{pstd} 
I wish to thank Enrico Viarisio of the Ceris-CNR technical staff for his help in 
formatting the Technical Report accompanying this routine.
{p_end}


{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}Ceris-CNR{p_end}
{phang}Institute for Economic Research on Firms and Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:g.cerulli@ceris.cnr.it":g.cerulli@ceris.cnr.it}{p_end}



{title:Also see}

{psee}
Online:  {helpb treatreg}, {helpb ivregress}, {helpb ivtreatreg}, {helpb pscore}, {helpb psmatch2}, {helpb nnmatch}
{p_end}
