{smcl}
{* *! version 1.4.0 23Aug2019}{...}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col:{hi:evalue} {hline 2}} Sensitivity analyses for unmeasured confounding in observational studies  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
E-value for risk ratio and rate ratio:

{p 8 14 2}
{cmd:evalue} {opt rr}
{it: point estimate}
[{cmd:,}
{opt l:cl(#)}
{opt u:cl(#)}
{opt tr:ue(#)}
{opt fig:ure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]
]


{pstd}
E-value for odds ratio:

{p 8 14 2}
{cmd:evalue} {opt or}
{it: point estimate}
[{cmd:,} 
{opt l:cl(#)}
{opt u:cl(#)}
{opt tr:ue(#)}
{opt comm:on}
{opt fig:ure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]
]


{pstd}
E-value for hazard ratio:

{p 8 14 2}
{cmd:evalue} {opt hr}
{it: point estimate}
[{cmd:,} 
{opt l:cl(#)}
{opt u:cl(#)}
{opt tr:ue(#)}
{opt comm:on}
{opt fig:ure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]
]


{pstd}
E-value for standardized mean difference:

{p 8 14 2}
{cmd:evalue} {opt smd}
{it: point estimate}
[{cmd:,} 
{opt se(#)}
{opt tr:ue(#)}
{opt fig:ure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]
]


{pstd}
E-value for risk difference:

{p 8 14 2}
{cmd:evalue} {opt rd}
{it:#a #b #c #d}
[{cmd:,}
{opt lev:el(#)}
{opt tr:ue(#)}
{opt gr:id(#)}
{opt fig:ure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}]
]


{pstd}
In the syntax for {cmd:evalue} {opt rd}, {it:#a} is the number of exposed, diseased individuals (E=1, D=1); {it:#b} is the number of exposed, non-diseased individuals (E=1, D=0);
{it:#c} is the number of unexposed, diseased individuals (E=0, D=1); and {it:#d} is the number of unexposed, non-diseased individuals (E=0, D=0). If the observed risk difference 
is negative, the exposure coding should first be reversed to yield a positive risk difference.


{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt l:cl(#)}}the lower limit of the confidence interval around the point estimate. Available for RR, OR and HR models{p_end}
{synopt :{opt u:cl(#)}}the upper limit of the confidence interval around the point estimate. Available for RR, OR and HR models{p_end}
{synopt:{opt se(#)}}the standard error of the point estimate of the standardized mean difference. Available for SMD model{p_end}
{synopt:{opt tr:ue(#)}}the treatment effect value to which to shift the observed point estimate; default is {cmd: true(0)} for RD and SMD models and {cmd: true(1)} for all others {p_end}
{synopt:{opt comm:on}}specify that the outcome is between 15 and 85 percent at end of follow-up, for OR and HR models; default is rare {p_end}
{synopt:{opt lev:el(#)}}set confidence level for RD model; default is {cmd:level(95)}{p_end}
{synopt:{opt gr:id(#)}}spacing (tolerance) for grid search of E-value for RD model; default is {cmd: grid(0.0001)}{p_end}
{synopt:{opt fig:ure}}produces a curve depicting the range of joint confounder associations for the point estimate, and CI when applicable. All {help twoway_options:twoway_options} are available. {p_end}
{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{opt evalue} performs sensitivity analyses for unmeasured confounding in observational studies using the methodology proposed by VanderWeele and Ding (2017). 
{opt evalue} reports E-values, defined as the minimum strength of association on the risk ratio scale that an unmeasured confounder would need to have 
with both the treatment and the outcome to fully explain away a specific treatment-outcome association, conditional on the measured covariates. 
{opt evalue} computes E-values for point estimates (and optionally, confidence limits) for several common outcome types, including risk and rate ratios, odds ratios 
with common or rare outcomes, hazard ratios with common or rare outcomes, standardized mean differences in outcomes, and risk differences. {opt evalue} 
produces identical results to those computed in the EValue package for R ({browse "https://cran.r-project.org/web/packages/EValue/index.html"}) and the web-based 
graphical interface ({browse "https://evalue.hmdc.harvard.edu"}).



{title:Options}

{p 4 8 2}
{cmd:lcl(}{it:#}{cmd:)} specifies the lower limit of the confidence interval around the point estimate. {opt evalue} will use {opt lcl()} to compute an E-value 
for the confidence interval limit, if it is closer to the null than {opt ucl()}. Available for RR, OR and HR models. 

{p 4 8 2}
{cmd:ucl(}{it:#}{cmd:)} specifies the upper limit of the confidence interval around the point estimate. {opt evalue} will use {opt ucl()} to compute an E-value 
for the confidence interval limit, if it is closer to the null than {opt lcl()}. Available for RR, OR and HR models.

{p 4 8 2}
{cmd:se(}{it:#}{cmd:)} specifies the standard error of the point estimate of the standardized mean difference (e.g. Cohen's D) (see {helpb esize:[R] esize}).
{opt evalue} will use {opt se()} to compute an E-value for the confidence interval limit closest to the null. Available for SMD model.

{p 4 8 2}
{cmd:true(}{it:#}{cmd:)} specifies a treatment effect value to which to shift the observed point estimate other than the null effect. A null true effect (default values in {opt evalue}) is 0 in RD and SMD models and 1 in all ratio type models.

{p 4 8 2}
{cmd:common} specifies that the outcome prevalence is between 15% and 85% at the end of the follow-up, for OR and HR models. 
When the {cmd:common} option is specified, an approximate E-value is obtained by replacing the RR with the square root of OR. 
It should be noted that when the outcome is rare, the square root transformation provides a poor approximation, and thus the 
calculation under the rare outcome assumption should be used (by not specifying {cmd:common}). However, when the outcome 
prevalence is between 15% and 85%, the square root transformation works quite well (Ding and VanderWeele 2016).  

{p 4 8 2}
{cmd:level(}{it:#}{cmd:)} specifies the confidence level, as a percentage, for the confidence interval used for producing RD estimates. The default is {cmd:level(95)}. 

{p 4 8 2}
{cmd:grid(}{it:#}{cmd:)} specifies the tolerance for the grid search of the E-value for an RD estimate. The default is {cmd: grid(0.0001)}.                

{p 4 8 2}
{cmd:figure}[{cmd:(}{it:{help twoway_options:twoway_options}}{cmd:)}] produces a curve depicting the range of joint relationships 
(exposure-confounder and exposure-disease) that may explain away the estimated effect with the computed E-value highlighted. A curve for the E-value of the CI is also displayed in the 
the figure under the following conditions:
(1) for RR, OR, and HR models, the user must specify {cmd:lcl(#)} when the point estimate is greater than 1.0 or {cmd:ucl(#)} when the estimate is lower than 1.0; 
(2) for an SMD model, the user must specify {opt se(#)};
(3) for an RD model, a CI curve is always produced; and 
(4) the computed E-value for the CI does not equal 1. Specifying {cmd:figure} without options uses the default graph settings.



{title:Remarks} 

{pstd}
The interpretation of the E-value is straightforward. In the first example below, the risk ratio estimate is 3.9, which produces an E-value of 7.263. The interpretation 
is as follows: "the observed risk ratio of 3.9 could be explained away by an unmeasured confounder that was associated with both the treatment and outcome by a risk ratio 
of 7.26-fold each, above and beyond the measured confounders, but weaker confounding could not do so." The higher the E-value, the stronger the confounder associations 
must be to explain away an effect (VanderWeele and Ding, 2017). 

{pstd}
To account for the statistical uncertainty of the point estimate, an E-value can also be computed for the confidence limit closest to the null. In the first example below, 
the LCL is 1.8 which is closer to the null (1.0) than the UCL (8.7). Thus, the E-value for the lower limit is 3.0, which can be interpreted as "an unmeasured confounder associated
with infant respiratory death and breast feeding by a risk ratio of 3.0-fold each could explain away the lower confidence limit, but weaker confounding could not." (VanderWeele
and Ding, 2017).

{pstd}
E-values can also be computed to assesss the minimum strength of the association of an unmeasured confounder would need to have with both the treatment and outcome to move the
point estimate to some other value of the risk ratio (which is represented by the {opt true()} option in {opt evalue}). In the third example below, we want to determine the 
amount of unmeasured confounding that would be necessary to shift the RR point estimate (0.80) to an RR of 0.90. The resulting E-value is 1.50, which can be interpreted as 
"for an unmeasured confounder to shift the observed estimate of RR = 0.80 to an estimate of RR = 0.90, an unmeasured confounder that was associated with both breast-feeding 
and childhood leukemia by a risk ratio of 1.0-fold each could do so, but weaker confounding could not." (VanderWeele and Ding, 2017).



{title:Examples}

{pstd}
{opt 1) E-value for a risk ratio:}{p_end}

{pmore} breast-feeding and infant respiratory death example in VanderWeele and Ding (2017) {p_end}
{pmore2}{bf:{stata "evalue rr 3.9, lcl(1.8) u(8.7) fig": . evalue rr 3.9, lcl(1.8) u(8.7) fig}} {p_end}

{pmore} breast-feeding and childhood leukemia example in VanderWeele and Ding (2017) {p_end}
{pmore2}{bf:{stata "evalue rr 0.80, lcl(0.71) u(0.91) fig": . evalue rr 0.80, lcl(0.71) u(0.91) fig}} {p_end}

{pmore} same as above but assessing the amount of confounding needed to shift the estimate from 0.80 to 0.90. {p_end}
{pmore2}{bf:{stata "evalue rr 0.80, lcl(0.71) u(0.91) true(0.90) fig": . evalue rr 0.80, lcl(0.71) u(0.91) true(0.90) fig}} {p_end}

{pmore} same as above but assessing the amount of confounding needed to shift the estimate from 0.80 to 1.20 (other side of null hypothesis) {p_end}
{pmore2}{bf:{stata "evalue rr 0.80, lcl(0.71) u(0.91) true(1.20) fig": . evalue rr 0.80, lcl(0.71) u(0.91) true(1.20) fig}} {p_end}

{pmore} anti-depressants use during pregnancy and infact cardiac defects example in VanderWeele and Ding (2017) {p_end}
{pmore2}{bf:{stata "evalue rr 1.06, lcl(0.93) u(1.22) true(1.20) fig": . evalue rr 1.06, lcl(0.93) u(1.22) true(1.20) fig}} {p_end}


{pstd}
{opt 2) E-value for an odds ratio:}{p_end}

{pmore} ovarian cancer example (with rare outcome) in VanderWeele and Ding (2017) {p_end}
{pmore2}{bf:{stata "evalue or 0.5, lcl(0.3) u(0.8) fig": . evalue or 0.5, lcl(0.3) u(0.8) fig}} {p_end}

{pmore} breast-feeding and child obesity example (with common outcome) in VanderWeele and Ding (2017) {p_end}
{pmore2}{bf:{stata "evalue or 1.47, lcl(1.12) u(1.93) common fig": . evalue or 1.47, lcl(1.12) u(1.93) common fig}} {p_end}


{pstd}
{opt 3) E-value for a hazard ratio:}{p_end}

{pmore} example with a common outcome {p_end}
{pmore2}{bf:{stata "evalue hr 0.56, l(0.46) u(0.69) common fig": . evalue hr 0.56, l(0.46) u(0.69) common fig}} {p_end}

{pmore} example with a rare outcome and true effect of 0.9. Additionally, we modify the X and Y labels (scale values) on the figure{p_end}
{pmore2}{bf:{stata "evalue hr 0.60, l(0.50) u(0.70) true(0.85) fig(xlabel(0(2)6) ylabel(0(2)6))": . evalue hr 0.60, l(0.50) u(0.70) true(0.85) fig(xlabel(0(2)6) ylabel(0(2)6))}} {p_end}


{pstd}
{opt 4) E-value for a standardized mean difference:}{p_end}

{pmore} phenobarbital and intelligence example in VanderWeele and Ding (2017)  {p_end}
{pmore2}{bf:{stata "evalue smd -0.42, se(0.14)": . evalue smd -0.42, se(0.14)}} {p_end}

{pmore} example with a shift to true estimate  {p_end}
{pmore2}{bf:{stata "evalue smd 0.5, se(0.2) true(0.1) fig": . evalue smd 0.5, se(0.2) true(0.1) fig}} {p_end}

{pmore} example using {helpb esizeregi} to first compute the SMD and SE from a regression model and then plug the respective values into {cmd: evalue}  {p_end}
{pmore2}{bf:{stata "esizeregi -224.422, sdy(578.8196) n1(864) n2(3778)": . esizeregi -224.422, sdy(578.8196) n1(864) n2(3778)}} {p_end}
{pmore2}{bf:{stata "evalue smd -0.383382, se(0.037920)": . evalue smd -0.383382, se(0.037920)}} {p_end}

{pmore} or alternatively,  {p_end}
{pmore2}{bf:{stata "evalue smd `d', se(`se')": . evalue smd `d', se(`se')}} {p_end}


{pstd}
{opt 5) E-value for a risk difference:}{p_end}

{pmore} smoking and lung cancer deaths example in VanderWeele and Ding (2017)  {p_end}
{pmore2}{bf:{stata "evalue rd 397 78557 51 108778": . evalue rd 397 78557 51 108778}} {p_end}

{pmore} same as above but assessing the amount of confounding needed to shift the observed risk difference (0.00456) to the value of 0.001 {p_end}
{pmore2}{bf:{stata "evalue rd 397 78557 51 108778, true(0.001) fig": . evalue rd 397 78557 51 108778, true(0.001) fig}} {p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:evalue} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(eval_est)}}E-value for the point estimate{p_end}
{synopt:{cmd:r(eval_ci)}}E-value for the confidence interval{p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Linden, A., Mathur, M.B., and T. J. VanderWeele. Conducting Sensitivity Analysis for Unmeasured Confounding in Observational Studies using E-values: The evalue package. 
{it: Stata Journal}, Forthcoming. 

{p 4 8 2}
Ding, P. and T. J. VanderWeele. (2016). Sensitivity analysis without assumptions. {it: Epidemiology}, 27: 368-377.{p_end}

{p 4 8 2}
VanderWeele, T. J. and P. Ding. (2017). Sensitivity analysis in observational research: introducing the E-value. {it: Annals of Internal Medicine}, 167(4): 268-274.{p_end}

{p 4 8 2}
Mathur, M.B., Ding, P., Riddell, C.A. and T. J. VanderWeele. (2018). Website and R package for computing E-values. {it: Epidemiology}, 29(5): e45-e47.{p_end}



{marker citation}{title:Citation of {cmd:evalue}}

{p 4 8 2}{cmd:evalue} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A, Mathur M. B., VanderWeele, T. J. (2019). EVALUE: Stata module for conducting sensitivity analyses for unmeasured confounding in observational studies.
{browse "http://ideas.repec.org/c/boc/bocode/s458592.html":http://ideas.repec.org/c/boc/bocode/s458592.html}{p_end}


{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}


{p 4 4 2}
Maya B. Mathur{break}
Department of Epidemiology{break}
Harvard University {break}
mmathur@stanford.edu{break}


{p 4 4 2}
Tyler J. VanderWeele{break}
Department of Epidemiology{break}
Harvard University {break}
tvanderw@hsph.harvard.edu{break}



{title:Also see}

{p 4 8 2} Online: {helpb cs}, {helpb esize}, {helpb esizereg} if installed {p_end}

