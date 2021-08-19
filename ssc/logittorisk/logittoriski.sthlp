{smcl}
{* 01dec2020}{...}
{cmd:help LogitToRisk}
{hline}

{title:Title}

{pstd} {cmd:logittorisk} {hline 2} Stata module for conversion of logistic regression output to differences and ratios of risk



{title:Syntax}

{pstd} Post-estimation command after a {cmd:logit} or {cmd:logistic} regression.

{p 8 14 2} {cmd: logittorisk}, [r0(#) cat(#)]
	
{p 15 14 2} When using {cmd:logit}, specify the option {cmd:or} {p_end}
{p 15 14 2} When using {cmd:logistic}, do not specify the option {cmd:coef} {p_end}
{p 15 14 2} Please ensure that the first variable is not a product term {p_end}


{pstd} Immediate form of the post-estimation command.

{p 8 14 2} {cmd: logittoriski} {it:#OR} {it:#LCI} {it:#UCI}, [r0(#)]



{title:Description}

{pstd} 
{cmd:logittorisk} computes the exposure/intervention group risk (r1) and a table of differences and ratios of risk from the baseline odds (constant) and odds ratio (from the first explanatory variable) obtained from a prior logistic regression.
This conversion is aimed at facilitating use of the OR in the reporting of clinical trials and meta-analyses because the OR is the “portable” effect measure, while the RR varies with baseline risk. {p_end}



{title:Modules required}

{pstd} Users need to install {stata ssc install indeplist:indeplist}



{title:Options}

{pstd} {cmd:r0(#)} specifies a baseline risk other than the one from the dataset used in the logit/logistic regression. 
With {cmd: logittoriski} (immediate form) r0 must be specified, if not, then r0 = 0.5 is applied.
The value should range from 0.01 to 0.99.

{pstd} {cmd:cat(#)} indicates the category of interest for a categorical exposure variable. If not specified, the first category is returned. 
This does not apply to {cmd: logittoriski} (immediate form). 


{title:Saved results}

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(r0)}} baseline risk{p_end}
{synopt:{cmd:r(r1)}} post-exposure risk based on the OR and r0 {p_end}
{synopt:{cmd:r(rr)}} risk ratio at the specified r0 for the variable of interest {p_end}
{synopt:{cmd:r(rr_lci)}} lower confidence interval of the risk ratio {p_end}
{synopt:{cmd:r(rr_uci)}} upper confidence interval of the risk ratio {p_end}
{synopt:{cmd:r(rd)}} risk difference at the specified r0 for the variable of interest {p_end}
{synopt:{cmd:r(rd_lci)}} lower confidence interval of the risk difference {p_end}
{synopt:{cmd:r(rd_uci)}} upper confidence interval of the risk difference {p_end}
{synopt:{cmd:r(nnt)}} number needed to treat at the specified r0 for the variable of interest {p_end}
{synopt:{cmd:r(nnt_lci)}} lower confidence interval of the number neeed to treat {p_end}
{synopt:{cmd:r(nnt_uci)}} upper confidence interval of the number neeed to treat {p_end}



{title:Examples}

{pstd} {bf: Example 1:} {p_end}
{pstd} The data for the example is taken from Greenland et al. Stat Sci. 1999;14(1):29-46. doi: 10.1214/SS/1009211805.{p_end}
{phang2} {stata "use http://fmwww.bc.edu/repec/bocode/l/logittorisk_example_data.dta":. use http://fmwww.bc.edu/repec/bocode/l/logittorisk_example_data.dta} {p_end}

{pstd} Logit or logistic regression model {p_end}
{phang2} {stata "logit y x z, or":. logit y x z, or}{p_end}
{phang2} {stata "logistic y x z":. logistic y x z}{p_end}

{pstd} Regression model with interaction {p_end}
{phang2} {stata "logit y x z x#z, or":. logit y x z x#z, or}{p_end}
{phang2} {stata "logit y x##z, or":. logit y x##z, or}{p_end}
{phang2} {stata "logit y x#z x z, or":. logit y x#z x z, or} - this is not allowed as product term comes first{p_end}

{pstd} Conversion of the logit/logistic regression output to differences and ratios of risk, and baseline risk of 0.1 {p_end}
{phang2} {stata "logittorisk, r0(0.1)":. logittorisk, r0(0.1)}{p_end}

{pstd} Immediate form using an OR, its confidence interval, and baseline risk of 0.1 {p_end}
{phang2} {stata "logittoriski 2.667 1.705 4.171, r0(0.1)":. logittoriski 2.667 1.705 4.171, r0(0.1)}{p_end}


{pstd} {bf:Example 2:} {p_end}
{pstd} The data for the example is taken from Stata (Hosmer & Lemeshow data) {p_end}
{phang2} {stata "webuse lbw":. webuse lbw} {p_end}

{pstd} Logit regression model - variable 'race' has three categories (white, black, other) {p_end}
{phang2} {stata "logit low i.race smoke, or":. logit low i.race smoke, or} {p_end}

{pstd} Conversion of the logit/logistic regression output for variable 'race' and category 'other' {p_end}
{phang2} {stata "logittorisk, cat(3)":. logittorisk, cat(3)} {p_end}



{title:Authors}

{pstd} Luis Furuya-Kanamori, Research School of Population Health, Australian National University, Australia {p_end}
{pstd} {browse "mailto:luis.furuya-kanamori@anu.edu.au?subject=LogitToRisk Stata enquiry":luis.furuya-kanamori@anu.edu.au} {p_end}

{pstd} Suhail AR Doi, Department of Population Medicine, College of Medicine, Qatar University, Qatar {p_end}



{title:Reference}

{pstd} Doi SA, Furuya-Kanamori L, Xu C, Lin L, Chivese T, Thalib L. Questionable utility of the relative risk in clinical research: A call for change to practice. J Clin Epidemiol. 2020 7:S0895-4356(20)31171-9. doi:10.1016/j.jclinepi.2020.08.019. {p_end}



{title:Funding}

{pstd} This work was supported by Program Grant #NPRP10-0129-170274 from the Qatar National Research Fund (a member of Qatar Foundation). The findings herein reflect the work and are solely the responsibility of the authors.
{pstd} LFK was supported by an Australian National Health and Medical Research Council Fellowship (APP1158469).
