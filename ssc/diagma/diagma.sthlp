{smcl}
{* 01aug2020}{...}
{cmd:help diagma}
{hline}

{title:Title}

{pstd} {cmd:diagma} {hline 2} DIAGnostic Meta-Analysis using the split component synthesis method



{title:Syntax}

{p 8 14 2} {cmd: diagma} {it:varlist} {ifin}, [options]
	
{pstd} {it:varlist} must contain the four cells from the 2x2 diagnostic test contingency table and be entered in the following order:{it: tp fp fn tn}

	                   {hline 26}
	                   | disease   | no disease |
	{hline 45}
	| test positive    |    tp     |     fp     |
	{hline 45}
	| test negative    |    fn     |     tn     |
	{hline 45}



{title:Description}

{pstd} {cmd:diagma} generates a summary ROC curve and uses the split component synthesis (SCS) method for meta-analysis of diagnostic accuracy studies. 
The SCS method synthesises the diagnostic odds ratio (DOR) across studies using the inverse variance heterogeneity model (by default).
The pooled DOR is partitioned into its components (summary sensitivity [Se] and specificity [Sp]) using ordinary least squares regression of either study logit Se or logit Sp on the centred study ln DOR.
The study ln DOR is centred on the pooled ln DOR and the regression intercepts indicate the summary logit Se or logit Sp.
This method has no assumption on the outcome distribution and maintains expected performance metrics under considerable heterogeneity.



{title:Modules required}

{pstd} Users need to install {stata ssc install admetan:admetan} and {stata ssc install lfk:lfk}



{title:Meta-anlysis model options}

{pstd} {cmd:Recommended (for routine use)}

{p 8 14 2} {cmd:ivhet} pools the DOR using the inverse variance heterogeneity model (default model).

{p 8 14 2} {cmd:qe}({it:varname}) pools the DOR using the quality effects model. A variable containing quality scores or ranks for each study needs to be specified.

{pstd} {cmd:Use with caution (only for specialist use)}

{p 8 14 2} {cmd:fe} pools the DOR using the fixed effect model.

{p 8 14 2} {cmd:re} pools the DOR using the random effects model.

{p 8 14 2} {cmd:peto} pools the DOR using the method of Peto.



{title:Other options}

{p 8 14 2} {cmd:nograph} suppresses the summary ROC curve.

{p 8 14 2} {cmd:lfk} generates the Doi plot and estimates the LFK index.
Caution is required in interpreting asymmetry when the DOR is high, cut-off value is extreme, or prevalence of disease is low.
These features tend to lead to extreme 2x2 tables with low cell frequencies in which the undesired correlation between DOR and its variance is most apparent.

{p 8 14 2} {cmd:cutplot} plots the logit Se and logit Sp (y-axis) against the centred ln DOR (x-axis) which can assist with assessment of varying thresholds across studies included in the meta-analysis. 



{title:Saved results}

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(logit_sens)}} logit summary sensitivity{p_end}
{synopt:{cmd:r(se_sens)}} standard error of the logit summary sensitivity{p_end}
{synopt:{cmd:r(logit_spec)}} logit summary specificity{p_end}
{synopt:{cmd:r(se_spec)}} standard error of the logit summary specificity{p_end}
{synopt:{cmd:r(ln_pos_lr)}} ln summary positive likelihood ratio{p_end}
{synopt:{cmd:r(se_pos_lr)}} standard error of the ln summary positive likelihood ratio{p_end}
{synopt:{cmd:r(ln_neg_lr)}} ln summary negative likelihood ratio{p_end}
{synopt:{cmd:r(se_neg_lr)}} standard error of the ln summary negative likelihood ratio{p_end}
{synopt:{cmd:r(ln_dor)}} ln summary diagnostic odds ratio{p_end}
{synopt:{cmd:r(se_dor)}} standard error of the ln summary diagnostic odds ratio{p_end}
{synopt:{cmd:r(logit_auc)}} logit summary area under the curve{p_end}
{synopt:{cmd:r(se_auc)}} standard error of the logit summary area under the curve{p_end}
{synopt:{cmd:r(lfk)}} lfk index{p_end}
{synopt:{cmd:r(i_sq)}} heterogeneity I-squared{p_end}
{synopt:{cmd:r(prev_dis)}} prevalence of disease{p_end}
{synopt:{cmd:r(num_participants)}} number of participants included{p_end}
{synopt:{cmd:r(num_studies)}} number of studies included{p_end}



{title:Examples}

{pstd} The data for the example is taken from Whiting et al. Health Technol Assess. 2006 Oct;10(36):iii-iv, xi-xiii, 1-154. doi: 10.3310/hta10360.{p_end}
{phang2} {stata "use http://fmwww.bc.edu/repec/bocode/d/diagma_example_data.dta":. use http://fmwww.bc.edu/repec/bocode/d/diagma_example_data.dta} {p_end}

{pstd} Summary estimates using the inverse variance heterogeneity model and summary ROC curve {p_end}
{phang2} {stata "diagma a b c d":. diagma a b c d}{p_end}

{pstd} Summary estimates using the quality effects model and summary ROC curve {p_end}
{phang2} {stata "diagma a b c d, qe(q2)":. diagma a b c d, qe(q2)}{p_end}

{pstd} Doi plot and LFK index to assess publication bias {p_end}
{phang2} {stata "diagma a b c d, lfk":. diagma a b c d, lfk}{p_end}



{title:Authors}

{pstd} Luis Furuya-Kanamori, Research School of Population Health, Australian National University, Australia {p_end}
{pstd} {browse "mailto:luis.furuya-kanamori@anu.edu.au?subject=DIAGMA Stata enquiry":luis.furuya-kanamori@anu.edu.au} {p_end}

{pstd} Suhail AR Doi, Department of Population Medicine, College of Medicine, Qatar University, Qatar



{title:Funding}

{pstd} This work was supported by Program Grant #NPRP10-0129-170274 from the Qatar National Research Fund (a member of Qatar Foundation). The findings herein reflect the work and are solely the responsibility of the authors.
{pstd} LFK was supported by an Australian National Health and Medical Research Council Fellowship (APP1158469).
