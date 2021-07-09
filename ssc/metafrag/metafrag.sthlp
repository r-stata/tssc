{smcl}
{* *! version 1.0.0 22Nov2019}{...}

{title:Title}

{p2colset 5 18 19 2}{...}
{p2col:{hi:metafrag} {hline 2}} Fragility index for meta-analysis {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:metafrag}
[{cmd:,}
{opt ef:orm}
{opt for:est}[{cmd:(}{it:{help meta_forestplot:forestplot}}{cmd:)}]
]


{pstd}
Before using {cmd:metafrag} you must first use {helpb meta_esize:meta esize} to compute effect sizes for a two-group comparison of binary outcomes


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt ef:orm}}report exponentiated results{p_end}
{synopt:{opt for:est}[{cmd:(}{it:{help meta_forestplot:forestplot}}{cmd:)}]}display a forest plot of the studies after modification. Specifying {cmd:forest} without options uses the default {help meta_forestplot:forestplot} settings.{p_end}
{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{opt metafrag} is an application of the fragility index for single studies with a binary outcome (Walsh et al. 2014) to meta-analysis (Atal et al. 2019). 
The fragility index for meta-analysis is defined as the minimum number of patients from one or more trials included in the meta-analysis for which a modification 
of the event status (ie, changing events to non-events, or non-events to events) would change the statistical significance of the pooled treatment effect (Atal et al. 2019). 
As such, a fragility index score of zero indicates that no modification of the event status is necessary to elicit a non-statistically significant pooled treatment effect. 
Conversely, a large fragility index score indicates that many modifications to the event status are required to change a statistically significant pooled effect to non-significant 
(and thus, the results may be considered more robust). 

{pstd}
{opt metafrag} is a post estimation command for {helpb meta_esize:meta esize}, thereby capitalizing on the comprehensive list of options available in official Stata's {helpb meta:meta} suite for computing effect sizes for binary outcomes.

  

{title:Options}

{p 4 8 2}
{cmd:eform} reports exponentiated effect sizes and transforms their respective confidence intervals, whenever applicable. 
By default, the results are displayed in the metric declared with meta esize such as log odds-ratios and log risk-ratios. 
{cmd:eform} affects how results are displayed, not how they are estimated and stored.

{p 4 8 2}
{opt forest}[{cmd:(}{it:{help meta_forestplot:forestplot}}{cmd:)}] displays a forest plot of the studies after modification to the events and non-events of included studies, to move the pooled effect from statistically significant to non-significant (the user can set the level that "significance" represents using the {cmd:level} option in {helpb meta_esize:meta esize}). 
Specifying {cmd:forest} without options uses the default {help meta_forestplot:forestplot} settings.



{title:Examples}

{pstd}Load example data{p_end}
{p 4 8 2}{stata "use smoking.dta, clear":. use smoking.dta, clear}{p_end}

{pstd}Use {help meta_esize:meta esize} to compute effect sizes for the log risk-ratio using a fixed effects model {p_end}
{p 4 8 2}{stata "meta esize a b c d , fixed(mhaenszel) esize(lnrratio) studylabel(name)": . meta esize a b c d , fixed(mhaenszel) esize(lnrratio) studylabel(name)}{p_end}

{pstd}Generate a forest plot to review the original pooled estimates {p_end}
{p 4 8 2}{stata "meta forestplot, eform  nullrefline": . meta forestplot, eform  nullrefline}{p_end}

{pstd}Compute the fragility index for the meta-analysis, specifying that the results be presented in exponentiated form in a forest plot {p_end}
{p 4 8 2}{stata "metafrag, forest eform":. metafrag, forest eform}{p_end}



{title:Acknowledgments}

{p 4 4 2}
I thank John Moran for advocating that I write this package. 



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:metafrag} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(frag)}}fragility index for meta-analysis{p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Walsh M, Srinathan SK, McAuley DF, Mrkobrada M, Levine O, Ribic C, Molnar AO, Dattani ND, Burke A, Guyatt G et al: 
The statistical significance of randomized controlled trial results is frequently fragile: a case for a Fragility Index.
{it: Journal of Clinical Epidemiology} 2014;67(6):622-628. {p_end}

{p 4 8 2}
Atal I, Porcher R, Boutron I, Ravaud P. The statistical significance of meta-analyses is frequently fragile: definition of a fragility index for meta-analyses.
{it:Journal of Clinical Epidemiology} 2019;111:32-40. {p_end}



{marker citation}{title:Citation of {cmd:metafrag}}

{p 4 8 2}{cmd:metafrag} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). METAFRAG: Stata module for computing the fragility index of meta-analysis.{p_end}



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb meta}, {helpb meta_esize}, {helpb meta_summarize}, {helpb meta_forestplot}, {helpb fragility} (if installed) {p_end}

