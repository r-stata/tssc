{smcl}
{* Juin 2014}{...}
{hline}
help for {hi:pcmdif}
{hline}


{title:Diagnosing and considering Differential Item Functioning when analysing Patient Reported Outcomes using Partial Credit Models}

{p 8 14 2}{cmd:pcmdif} (varlist) , 
{cmdab:cov:}({it:variable})
[{cmdab:it:erate}(#)
{cmdab:ad:apt} 
{cmdab:ro:bust}
{cmdab:bic:}
{cmdab:h:omo}
{cmdab:all:}]


{title:Description}

{p 8 14 2}{cmd:pcmdif} allows studying the effect of a categorical covariate 
on a latent trait. Several effects are simultaneously considered: {p_end}
{p 14 16 2}- An direct effect of the covariate on the latent trait (corresponding 
to a variation of the average latent trait value depending on the status defined 
by the considered covariate) This effect is studied by including a group covariate 
associated with the latent trait in a partial credit model (PCM). It is referred to 
"covariate effect".{p_end}
{p 14 16 2}- An effect of the covariate on the interpretation of items 
(corresponding to a differential item functioning: DIF). This effect is studied by 
including interactions between the items difficulties parameters and the group 
covariate in the PCM. It is referred to "DIF effect"{p_end}

{p 14 14 2}The identification of items with DIF ("DIF effect") and the 
"covariate effect" are performed using an iterative ascending process 
by minimizing the Akaike criterion or the Bayesian Information Criterion, 
depending on the selected option.{p_end}

{p 14 14 2}At each step of the iterative ascending process, models summaries are 
produced containing the list of the included effects (a "covariate effect" and/or 
each of the possible "DIF effects") and the AIC and BIC criteria values. At the end of the 
iterative process, the estimated parameters of the most relevant model are activated. 
To make active the associated estimate another model, use the command 
{help estimates_replay:estimate replay}.{p_end}

{title:Options}

{p 8 14 2}{cmd:cov} identifies the covariate possibly responsible for a 
"covariate" or a "DIF" effect.

{p 8 14 2}{cmd:iterate} specifies the (maximum) number of iterations. With the
 adapt option, use of the iterate(#) option will cause pcmodel to skip the
  "Newton Raphson" iterations usually performed at the end without updating
   the quadrature locations.

{p 8 14 2}{cmd:adapt} causes adaptive quadrature to be used instead of
 ordinary quadrature.

{p 8 14 2}{cmd:robust} specifies that the Huber/White/sandwich estimator of the
 covariance matrix of the parameter estimates is to be used. 

{p 8 14 2}{cmd:bic} selection of the model by minimizing the Bayesian 
Information Criterion (BIC) rather that the AIC criterion (by default, 
minimization of AIC)

{p 8 14 2}{cmd:homo} considers a homogeneous rather than nonhomogeneous DIF
 (ie: for a given item, the difference between the difficulty of a given
  response category depending on the considered covariate is the same for
   all the item response categories. This assumption can refer to the  case
    that the DIF is related to the understanding of the item utterance rather 
    than the response categories utterance).

{p 8 14 2}{cmd:all} allows to perform all the possible models rather than thoses
selected by an iterative ascending process for selecting the best model (and 
thus identifying items presenting a potential DIF phenomenum).

{marker example}{...}
{title:Example}

{pstd}
Simulating the data (using {help simirt}). 5 items are simulated, the last presenting a DIF phenomenum:

	. {cmd:simirt, dim(6) group(0.5) deltagroup(0.5) clear}{right:(1)    }
	. {cmd:replace item5=item6 if group==1}{right:(2)    }
	. {cmd:drop item6}{right:(3)    }
	. {cmd:rename item5 item5dif}{right:(4)    }

{pstd}
Analysing the data using pcmdif:

	. {cmd:pcmdif item1 item2 item3 item4 item5dif, cov(group) aic }{right:(5)    }

{pstd}
Displaying the results of the selected model:

	. {cmd:estimates replay }{right:(6)    }

{pstd}
Displaying the results of the first performed model:

	. {cmd:estimates replay m_1 }{right:(7)    }

{title:Author}

{p 8 14 2}Jean-François Hamel{p_end}
{p 8 14 2}Email:
{browse "mailto:jeanfrancois.hamel@chu-angers.fr":jeanfrancois.hamel@chu-angers.fr}{p_end}


{title:Also see}

{p 4 13 2}Online: help for {help pcmodel}, {help pcmtest}, {help gllamm}, {help simirt},
 {help raschtest}.{p_end}
