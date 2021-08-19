{smcl}
{* *! version 1.0.0 07Sep2020}{...}

{title:Title}

{p2colset 5 19 20 2}{...}
{p2col:{hi:metastrong} {hline 2}} Estimate the proportion of true effect sizes above or below a threshold in random-effects meta-analysis {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 19 2}
{cmd:metastrong} 
{it:#q} 
[{cmd:,} 
{opt exp}
{opt above}  
{opt para:metric} 
{opt boot:strap}[{cmd:(}{it:{help bootstrap##options:bootstrap_options}}{cmd:)}] ]


{pstd}
{it:q} represents the true effect size that is the threshold for "scientific importance"

{pstd}
Before using {cmd:metastrong}, the data must be declared with {helpb meta_set:meta set} or {helpb meta_esize:meta esize}



{marker option}{...}
{synoptset 32 tabbed}{...}
{synopthdr:option}
{synoptline}
{synopt :{opt exp}}specify that {it:q} is exponentiated {p_end}
{synopt :{opt above}}estimate the proportion of effects above {it:q}; default is the proportion of effects {opt below} {it:q} {p_end}
{synopt :{opt para:metric}}compute the proportion of true effects above (or below) {it:q} using the parametric method; default is to 
calibrate estimates and then compute proportions non-parametrically{p_end}
{synopt:{opt boot:strap}[{cmd:(}{it:{help bootstrap##options:bootstrap_options}}{cmd:)]}}specify bootstrap options for estimating the 
proportion (and CIs) of true effects above (or below) {it:}. All {helpb bootstrap} options are available {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
[{it:if}][{it:in}] qualifiers can be specified when meta setting the data using {helpb meta_set:meta set} or {helpb meta_esize:meta esize}.{p_end}



{marker description}{...}
{title:Description}

{pstd}
{opt metastrong} estimates evidence strength for scientifically meaningful effects in meta-analyses under effect heterogeneity 
(ie, a nonzero estimated variance of the true effect distribution) as proposed by Mathur and VanderWeele (2019; 2020). {opt metastrong}
reports the estimated proportion of true effect sizes above or below a chosen threshold of a meaningful effect size {it:q}, together with confidence
intervals derived via the bootstrap.

{pstd}
These metrics could help identify if (1) there are few effects of scientifically meaningful size despite a “statistically
significant” pooled point estimate, (2) there are some large effects despite an apparently null point estimate, or (3) 
strong effects in the direction opposite the pooled estimate also regularly occur (and thus, potential effect modifiers
should be examined) (Mathur and VanderWeele 2019).

{pstd}
By default, {opt metastrong} performs estimation using the "calibrated" method (Mathur and VanderWeele 2020) that extends work by Wang and Lee (2019). 
{opt metastrong} first calibrates the effect estimates and then computes the proportion of studies above (or below) {it:q}. This method makes no assumptions 
about the distribution of true effects and performs well in meta-analyses with as few as 10 studies.

{pstd}
When the {opt parametric} option is specified, {opt metastrong} estimates the proportion of studies above (or below) {it:q} using the formulae devised
by Mathur and VanderWeele (2019). This estimate is then bootstrapped to derive confidence intervals. As with the calibrated method, at least 10 individual 
studies should be available in the meta-analysis for these estimates to provide valid results.

{pstd}
Point estimates produced by {opt metastrong} correspond to those produced by the function prop_stronger in the R package MetaUtility as of version 2.0.0. 
Confidence intervals will likely differ between packages given that Stata and R use different random number seeds for determining which studies to include 
in each bootstrap repetition. 




{title:Options}

{dlgtab:Main}


{phang}
{opt exp} specifies that {it:q} is exponentiated. For example, if {it:q} is 0.70 and represents a risk-ratio, then the user must specify {opt exp}. Conversely,
if the user specifies that {it:q} is -.35667494 (the log of 0.70), then {opt exp} should not be specified.

{phang}
{opt above} specifies that the proportion of effects {opt above} {it:q} should be estimated. The default is to estimate the proportion of effects {opt below} {it:q}.

{phang}
{opt parametric} specifies that the proportion of true effects above (or below) {it:q} should be estimated using the parametric method. The default is to 
calibrate all effect estimates and then compute proportions non-parametrically.

{phang}
{opt bootstrap}[{cmd:(}{it:{help bootstrap##options:bootstrap_options}}{cmd:)]} specifies bootstrap options for estimating confidence intervals. 
All {helpb bootstrap} options are available.{p_end}



{title:Examples}

{pstd}
{opt 1) {opt metastrong} with a binary outcome:} {p_end}

{pstd}Load example data{p_end}
{p 4 8 2}{stata "webuse bcgset, clear":. webuse bcgset, clear}{p_end}

{pstd}Use {help meta_esize:meta esize} to compute effect sizes for the log risk-ratio using a random effects(REML) model {p_end}
{p 4 8 2}{stata "meta esize npost nnegt nposc nnegc, esize(lnrratio) studylabel(studylbl)": . meta esize npost nnegt nposc nnegc, esize(lnrratio) studylabel(studylbl)}{p_end}

{pstd}Generate a forest plot to review the individual studies and pooled estimates {p_end}
{p 4 8 2}{stata "meta forestplot, eform  nullrefline ": . meta forestplot, eform  nullrefline}{p_end}

{pstd}We now use {opt metastrong} to estimate the proportion of true effect sizes {it:above} a threshold of 0.70 (risk-ratio) using the parametric method. 
Additionally, we specify that that bootstrap should execute 1000 repetitions and employ the BCA method. {p_end}
{p 4 8 2}{stata "metastrong 0.70, exp above parametric boot(reps(1000) bca)": . metastrong 0.70, exp above parametric boot(reps(1000) bca)}{p_end}

{pstd}Same as before, but we now estimate the proportion of true effect sizes {it:below} the same threshold of 0.70 (risk-ratio). {p_end}
{p 4 8 2}{stata "metastrong 0.70, exp below parametric boot(reps(1000) bca)": . metastrong 0.70, exp below parametric boot(reps(1000) bca)}{p_end}

{pstd}We review all bootstrap estimates. {p_end}
{p 4 8 2}{stata "estat boot, all": . estat boot, all}{p_end}

{pstd}We now estimate the proportion of true effect sizes above a threshold of 0.70 (risk-ratio) using the "calibrated" method. 
We do not specify that that bootstrap should employ the BCA method because it will produce an error. {p_end}
{p 4 8 2}{stata "metastrong 0.70, exp above boot(reps(1000))": . metastrong 0.70, exp above boot(reps(1000))}{p_end}

{pstd}We review all bootstrap estimates. {p_end}
{p 4 8 2}{stata "estat boot, all": . estat boot, all}{p_end}

{pstd}
{opt 2) {opt metastrong} with a continuous outcome:} {p_end}

{pstd}Load example data{p_end}
{p 4 8 2}{stata "use https://www.stata-press.com/data/r16/pupiliq, clear": . use https://www.stata-press.com/data/r16/pupiliq, clear}{p_end}

{pstd} {help meta_set:meta set} the data {p_end}
{p 4 8 2}{stata "meta set stdmdiff se, studylabel(studylbl) eslabel(Std. Mean Diff.)": . meta set stdmdiff se, studylabel(studylbl) eslabel(Std. Mean Diff.)}{p_end}

{pstd} {help meta_set:meta summarize} the data to review the individual studies and pooled estimates {p_end}
{p 4 8 2}{stata "meta summarize": . meta summarize}{p_end}

{pstd}We use {opt metastrong} to estimate the proportion of true effect sizes above a threshold of 0.20 (considered a small effect on the standardized mean difference scale) 
using the parametric method. We also specify that that bootstrap should execute 1000 repetitions and employ the BCA method. {p_end}
{p 4 8 2}{stata "metastrong 0.20, above parametric boot(reps(1000) bca)": . metastrong 0.20, above parametric boot(reps(1000) bca)}{p_end}

{pstd}We now use the "calibrated" method. We do not specify that that bootstrap should employ the BCA method because it will produce an error. {p_end}
{p 4 8 2}{stata "metastrong 0.20, above boot(reps(1000))": . metastrong 0.20, above boot(reps(1000))}{p_end}

{pstd}We review all bootstrap estimates. {p_end}
{p 4 8 2}{stata "estat boot, all": . estat boot, all}{p_end}



{title:Acknowledgments}

{p 4 4 2}
I thank John Moran for advocating that I write this package.



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:metastrong} stores the following in {cmd:r()}:

{synoptset 10 tabbed}{...}
{p2col 5 10 12 2: Scalars}{p_end}
{synopt:{cmd:r(phat)}}estimated proportion of studies above (or below) threshold {it:q}{p_end}
{p2colreset}{...}



{title:References}

{p 4 8 2}
Mathur,  M. B. and T. J. VanderWeele. 2019. New metrics for meta-analyses of heterogeneous effects. {it:Statistics in Medicine} 38: 1336–1342.

{p 4 8 2}
Mathur, M. B. and T. J. VanderWeele. 2020. Robust metrics and sensitivity analyses for meta-analyses of heterogeneous effects. {it:Epidemiology} 31: 356-358.

{p 4 8 2}
Wang, C. C. and W. C. Lee. 2019. A simple method to estimate prediction intervals and predictive distributions: Summarizing meta‐analyses beyond means and confidence intervals. 
{it:Research Synthesis Methods} 10: 255-266.



{marker citation}{title:Citation of {cmd:metastrong}}

{p 4 8 2}{cmd:metastrong} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2020). METASTRONG: Stata module for estimating the proportion of true effect sizes above or below a threshold in random-effects meta-analysis.{p_end}



{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb meta}, {helpb meta_set:meta set}, {helpb meta_regress:meta regress}, {helpb metafrag} (if installed) {p_end}

