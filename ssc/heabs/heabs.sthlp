{smcl}
{* 31jan2017}{...}
{cmd:help heabs}
{hline}

{title:Title}
{p}{bf:heabs} Calculates the ICER and Net Benefit for up to two datasets, and produces an assessment of the agreement of the datasets.
Requires paired individual level cost and effect data from a two arm trial or equivalent. {p_end}


{title:Syntax}
{p 4}
{cmd:heabs} {it:cost1} {it:effect1} [{it:cost2} {it:effect2}],
{cmdab:int:ervention(varname)}
{cmdab:resp:onse(str)}
[{cmd:w2p(real)}]
{p_end}


{title:Description}

{p}Returns a range of estimates including ICER, Net Benefit. If two datasets are presented, Lin's CCC is also calculated.
Designed to be used for bootstrapping, to allow the calculation of the probability of miscoverage and probability of cost effectiveness.

{p}If response is {bf:bene} (meaning a higher score is beneficial to the individual), ICER is calculated as:

{p 4} (meanCost[intervention=1] - meanCost[intervention=0]) / (meanEffect[intervention=1] - meanEffect[intervention=0])

{p}If response is {bf:detr} (meaning a higher score is detrimental), ICER is calculated as:

{p 4} (meanCost[intervention=1] - meanCost[intervention=0]) / (meanEffect[intervention=0] - meanEffect[intervention=1])

{p} Net benefit is calculated following the same relative logic.

{title:Options}

{p 4}{opt int:ervention(var)} used to indicate which treatment group patients are allocated to. Must be encoded 0 and 1.

{p 4}{opt resp:onse(str)} specifies whether a higher effect score is positive ({it:bene}) or negative ({it:detr})

{p 4}{opt w2p(#)} the  willing-to-pay level to be examined, must be real and positive, default 0.




{title:Stored Results}


{synoptset 20 tabbed}{...}

{synopt:{cmd: SCALARS}}


{synopt:{cmd:r(NB1)}} Incremental Net Benefit calculated from the first dataset. 

{synopt:{cmd:r(seNB1)}} Standard Error of the Incremental Net Benefit from the first dataset.

{synopt:{cmd:r(loCINB1)}} Lower 95% Confidence Interval of the Incremental Net Benefit from the first dataset.

{synopt:{cmd:r(upCINB1)}} Upper 95% Confidence Interval of the Incremental Net Benefit from the first dataset.

{synopt:{cmd:r(ICER1)}} Incremental Cost Effectiveness Ratio from the first dataset.

{synopt:{cmd:r(NB2)}} Incremental Net Benefit calculated from the second dataset.

{synopt:{cmd:r(seNB2)}} Standard Error of the Incremental Net Benefit from the second dataset.

{synopt:{cmd:r(loCINB2)}} Lower 95% Confidence Interval of the Incremental Net Benefit from the second dataset.

{synopt:{cmd:r(upCINB2)}} Upper 95% Confidence Interval of the Incremental Net Benefit from the second dataset.

{synopt:{cmd:r(ICER2)}} Incremental Cost Effectiveness Ratio from the second dataset.

{synopt:{cmd:r(diffNB)}} Difference in Incremental Net Benefit Scores between the two datasets. (NB2 - NB1)

{synopt:{cmd:r(cccNB)}} Lin's Concordance Correlation Coefficient for the Incremental Net Benefit of the two datasets.

{synopt:{cmd:r(zcccNB)}} Z Score of the Concordance Correlation Coefficient.{p_end}



{title:Examples}

{p}{bf:heabs} cost1 effect1,  res(bene) int(treatID) d w2p(5000)

{bf:heabs} cost1 effect1 cost2 effect2, res(detr) int(treatID)  w2p(5000) 

{bf:bootstrap} DiffNetben=r(diffNB) cost1=r(cost1) cost2=r(cost2) effect1=r(outcome1) effect2=r(outcome2) NB1=r(NB1) NB2=r(NB2) ICER1=r(ICER1) ICER2=r(ICER2)  ///
			 NB1Lo=r(loCINB1) NB1Up=r(upCINB1) NB2Lo=r(loCINB2) NB2Up=r(upCINB2) ///
			, saving(BSoutput, replace)  reps(1000) seed(24): ///
			{bf:heabs} cost1 effect1 cost2 effect2,  w2p(0) intervention(allocation) response(detr)


{title:Authors}

{pstd}
Daniel Gallacher {break}
Warwick Clinical Trials Unit {break}
University of Warwick {break}
D.Gallacher@Warwick.ac.uk {p_end}



