{smcl}
{* *! version 1.0 14 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "ci_fixed##syntax"}{...}
{viewerjumpto "Description" "ci_fixed##description"}{...}
{viewerjumpto "Options" "ci_fixed##options"}{...}
{viewerjumpto "Remarks" "ci_fixed##remarks"}{...}
{viewerjumpto "Examples" "ci_fixed##examples"}{...}
{title:Title}
{phang}
{bf:ci_fixed} {hline 2} Determine confidence intervals in a single-stage single-arm trial design for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:ci_fixed}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt n(#)}} Sample size of the considered design. Defaults to 25.{p_end}
{synopt:{opt pi(numlist)}} Numlist of response probabilities to evaluate the expected performance of the confidence interval determination procedures at. This will internally default to 0,0.01,...,1.{p_end}
{synopt:{opt alpha(#)}} alpha-level to use in confidence interval construction. Defaults to 0.05.{p_end}
{synopt:{opt method(string)}} A string indicating which method(s) to use to construct confidence intervals. Currently, support is available to use the Agresti-Coull (agresti_coull), Clopper-Pearson (clopper_pearson), Jeffreys (jeffreys), Mid-p (mid_p), Wald (wald), and Wilson Score (wilson) approaches to confidence interval determination. Defaults to all, which will employ all possible methods.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates whether a plot should be produced. If set to length that the expected length curve will be procedured. If set to coverage then the coverage curve will be produced.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

Determines all possible confidence intervals at the end of a single-stage single-
arm trial for a single binary endpoint, as determined using des_fixed. Support is
available to compute confidence intervals using the Agresti-Coull, Clopper-
Pearson, Jeffreys, Mid-p, Wald, and Wilson Score approaches.

In addition, the performance of the chosen confidence interval determination
procedures (including their coverage and expected length) for each value of pi in
the supplied numlist pi, will also be evaluated.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt n(#)} Sample size of the considered design. Defaults to 25.

{phang}
{opt pi(numlist)} Numlist of response probabilities to evaluate the expected performance of the confidence interval determination procedures at. This will internally default to 0,0.01,...,1.

{phang}
{opt alpha(#)} alpha-level to use in confidence interval construction. Defaults to 0.05.

{phang}
{opt method(string)} A string indicating which method(s) to use to construct confidence intervals. Currently, support is available to use the Agresti-Coull (agresti_coull), Clopper-Pearson (clopper_pearson), Jeffreys (jeffreys), Mid-p (mid_p), Wald (wald), and Wilson Score (wilson) approaches to confidence interval determination. Defaults to all, which will employ all possible methods.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates whether a plot should be produced. If set to length that the expected length curve will be procedured. If set to coverage then the coverage curve will be produced.

{phang}
{opt *} Additional options to use during plotting.


{marker examples}{...}
{title:Examples}

{phang}
{stata ci_fixed}

{phang}
{stata ci_fixed, n(30)}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

Related commands:

{help des_fixed} (if installed)
{help opchar_fixed} (if installed)
{help est_fixed} (if installed)
{help pval_fixed} (if installed)
