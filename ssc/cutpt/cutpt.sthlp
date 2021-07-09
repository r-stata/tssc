{smcl}
{* *! version 1.3  29apr2013}
{hline}
help for {cmd:cutpt}{right:Version 1.3, April 29 2013}
{hline}

{title:Title}

{phang}
{bf:cutpt} {hline 2} Empirical estimation of cutpoint for a diagnostic test

{title:Syntax}

{p 8 18 2}
{opt cutpt} {it: refvar classvar} {ifin}, [{it:method} {opt noadj:ust}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{it:method}}{opt liu} (the default), {opt youden} or {opt near:est}{p_end}
{synopt:{opt noadj:ust}}do not empirically adjust the cutpoint{p_end}


{title:Description}

{pstd}
{opt cutpt} estimates the optimal cutpoint for a diagnostic test. The Liu method maximises the
product of the sensitivity and specificity; the Youden method maximises the sum. The nearest to
(0,1) method finds the cutpoint on the ROC curve closest to (0,1) (the point with perfect
sensitivity and specificity).{p_end}

{pstd}The test is considered positive if {it:classvar} is greater than the cutpoint.{p_end}

{pstd}The syntax is derived from the official Stata command {help roctab}, so to quote the help for
{bf:roctab}:{p_end}

{pmore}The two variables {it:refvar} and {it:classvar} must be numeric. The reference
variable indicates the true state of the observation, such as diseased
and nondiseased or normal and abnormal, and must be coded as 0 and 1.
The rating or outcome of the diagnostic test or test modality is recorded
in {it:classvar}, which must be at least ordinal, with higher values
indicating higher risk.{p_end}

{pstd}By default the {it:classvar} is assumed to be continous and the estimated cutpoint is adjusted
according to the method suggested by Fluss et al. The theory is that the value that we're trying to
maximise (product (Liu) or sum (Youden) of sensitivity and specificity) is maximal at one particular
value of {it:classvar}, but also in the interval between that value and the next observed value of
{it:classvar}. The adjustment takes the mean of those two values of {it:classvar} to be the best
estimate of the cutpoint. This adjustment is recommended for a continuous {it:classvar}. For an
ordinal {it:classvar} it is recommended not to use this adjustment by specifying the {opt noadj:ust}
option.

{pstd}The estimated cutpoint is returned in e(cutpoint) and can be bootstrapped to estimate
confidence intervals.{p_end}


{title:Examples}

{pstd}{ul:Basic usage}{p_end}
{phang}{cmd:. webuse hanley}{p_end}
{phang}{cmd:. cutpt disease rating, noadjust}{p_end}

{pstd}{ul:Graphical demonstration of estimated cutpoint}{p_end}
{phang}{cmd:. webuse hanley}{p_end}
{phang}{cmd:. cutpt disease rating, noadjust}{p_end}
{phang}{cmd:. roctab disease rating, graph msymbol(none) addplot(scatteri `e(sens)' `=1 - e(spec)') legend(label(3 "Cutpoint"))}{p_end}

{pstd}{ul:Bootstrapping the estimated cutpoint}{p_end}
{phang}{cmd:. webuse hanley}{p_end}
{phang}{cmd:. bootstrap e(cutpoint), rep(100): cutpt disease rating, noadjust}{p_end}


{title:Saved results}

{pstd}
{cmd:cutpt} saves the following in {bf:e()}:

{synoptset 15 tabbed}{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{bf:e(cutpoint)}}estimated cutpoint{p_end}
{synopt:{bf:e(sens)}}sensitivity at cutpoint{p_end}
{synopt:{bf:e(spec)}}specificity at cutpoint{p_end}
{synopt:{bf:e(auc)}}area under ROC curve at cutpoint{p_end}
{synopt:{bf:e(j)}}Youden index (if Youden method used){p_end}
{synopt:{bf:e(sej)}}standard error for Youden index{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{bf:e(method)}}method used{p_end}

{p2col 5 15 19 2: Functions}{p_end}
{synopt:{bf:e(sample)}}marks estimation sample{p_end}


{title:Author}

{p 4 4 2}
Phil Clayton, ANZDATA Registry, Australia, phil@anzdata.org.au


{title:References}

{phang}Fluss R, Faraggi D, Reiser B. Estimation of the Youden Index and its associated cutoff point. Biom J. 2005 Aug;47(4):458-72.{p_end}

{phang}Liu X. Classification accuracy and cut point selection. Stat Med. 2012 Oct 15;31(23):2676-86.{p_end}

{phang}Youden WJ. Index for rating diagnostic tests. Cancer 1950; 3:32-35.{p_end}


