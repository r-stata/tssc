{smcl}
{* *! version 1.2.1  07mar2013}{...}
{viewerjumpto "Syntax" "tesensitivity##syntax"}{...}
{viewerjumpto "Description" "tesensitivity##description"}{...}
{viewerjumpto "Further Information" "tesensitivity##further_information"}{...}
{title:Title}

{phang}
{bf:tesensitivity} {hline 2} Sensitivity analysis for treatment effect models based on unconfoundedness

{marker syntax}{...}
{title:Syntax}

	{cmd:tesensitivity} {it:subcommand} ... [, {it: options}]

{synoptset 20 tabbed}{...}
{marker subcommand}{...}
{synopthdr:subcommand}
{synoptline}
{synopt :{helpb tesensitivity_cpi:cpi}}conditional partial independence analysis{p_end}
{synopt :{helpb tesensitivity_cscale:cscale}}c-dependence scale analysis{p_end}
{synopt :{helpb tesensitivity_cpiplot:cpiplot}}conditional partial independence analysis plot{p_end}
{synopt :{helpb tesensitivity_cpitable:cpitable}}conditional partial independence analysis table{p_end}
{synoptline}
	
{marker description}{...}
{title:Description}

{pstd}
{cmd:tesensitivity} analyzes the sensitivity of treatment effect estimates to relaxations of the unconfoundedness assumption, also known as selection on observables, exogenous selection, ignorability, or conditional independence.
{cmd:tesensitvity cpi} calculates bounds on treatment effect parameters by relaxing the unconfoundedness assumption to a {it: conditional partial independence} assumption. 
Bounds are calculated for a range of alternative assumptions about the magnitude of selection on unobservables.
The breakdown point for conclusions about these treatment effects is also calculated.
This is defined as the maximum level of selection on unobservables under which a specific conclusion still holds.

{pstd}
Conditional partial independence analysis can be conducted for five treatment
effect parameters: the average treatment effect (ATE), the average treatment effect on the treated (ATET), quantile treatment effects (QTE), conditional average treatment effects (CATE), and conditional quantile treatment effects (CQTE).

{pstd}
{cmd: tesensitivity cpiplot}, {cmd: tesensitivity ctable}, and {cmd: tesensitivity cscale} 
provide tools to visualize the results, compare results from multiple datasets, and interpret the the scale of c-dependence.

{marker further_information}{...}
{title:Further Information}

{p 4 4 4}
This package implements the sensitivity analysis described in {browse "https://dx.doi.org/10.3982/ECTA14481":Masten and Poirier (2018)} 
({browse `"https://arxiv.org/abs/1707.09563"':Preprint}) and
{browse "https://arxiv.org/abs/2012.15716":Masten, Poirier, and Zhang (2020)}.
{browse "https://qeconomics.org/ojs/index.php/qe/article/view/712/0":Masten and Poirier (2020)} discuss the concept of a {it:breakdown point}. 

{p 4 4 4}
This {browse "https://github.com/mattmasten/tesensitivity/blob/master/vignette/vignette.pdf":vignette}
provides a tutorial for use of this package walking through the empirical illustration in
{browse "https://arxiv.org/abs/2012.15716":Masten, Poirier, and Zhang (2020)}
using data from {browse "https://doi.org/10.1080/01621459.1999.10473858": Dehejia and Wahba (1999)}
on a program that provided guaranteed work experience, which is reconstructed from {browse "https://www.jstor.org/stable/1806062": LaLonde (1986)}. If you are new to this package, this vignette is the best place to start.

{marker references}{...}
{title:References}

{marker DW1999}{...}
{phang}
Dehejia and Wahba (1999) Causal Effects in Nonexperimental Studies: Reevaluating the Evaluation of Training Programs, {it:The Journal of the American Statistical Association}

{marker L1986}{...}
{phang}
LaLonde (1986) Evaluating the Econometric Evaluations of Training Programs with Experimental Data, {it:The American Economic Review}

{marker MP2018}{...}
{phang}
Masten and Poirier (2018) Identification of Treatment Effects under Conditional Partial Independence, {it:Econometrica}

{marker MP2020}{...}
{phang}
Masten and Poirier (2020) Inference on Breakdown Frontiers, {it:Quantitative Economics}

{marker MPZ2020}{...}
{phang}
Masten, Poirier, and Zhang (2020) Assessing Sensitivity to Unconfoundedness: Estimation and Inference, arXiv preprint
{p_end}
