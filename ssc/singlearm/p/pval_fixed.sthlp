{smcl}
{* *! version 1.0 14 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "pval_fixed##syntax"}{...}
{viewerjumpto "Description" "pval_fixed##description"}{...}
{viewerjumpto "Options" "pval_fixed##options"}{...}
{viewerjumpto "Remarks" "pval_fixed##remarks"}{...}
{viewerjumpto "Examples" "pval_fixed##examples"}{...}
{title:Title}
{phang}
{bf:pval_fixed} {hline 2} Determine p-values in a single-stage single-arm trial design for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:pval_fixed}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt n(#)}} Sample size of the considered design. Defaults to 25.{p_end}
{synopt:{opt pi0(#)}} The (undesirable) response probability used in the definition of the null hypothesis. Defaults to 0.1.{p_end}
{synopt:{opt pi(numlist)}} Numlist of response probabilities to evaluate the expected performance of the p-value calculation procedures at. This will internally default to 0,0.01,...,1.{p_end}
{synopt:{opt method(string)}} A string indicating which method(s) to use to construct p-values. Currently, support is available to use exact binomial tail probabilities (exact) and to use a normal approximation (normal) approach. Defaults to all, which will employ all possible methods.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates whether the expected p-value curve plot should be produced.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

Determines all possible p-values at the end of a single-stage single-arm trial for
a single binary endpoint, as determined using des_fixed. Support is available to
compute p-values using exact binomial tail probabilities, or using a normal
approximation.

In addition, the performance of the chosen p-value calculation procedures
(including their expected value and variance) for each value of pi in the supplied
numlist pi, will also be evaluated.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt n(#)} Sample size of the considered design. Defaults to 25.

{phang}
{opt pi0(#)} The (undesirable) response probability used in the definition of the null hypothesis. Defaults to 0.1.

{phang}
{opt pi(numlist)} Numlist of response probabilities to evaluate the expected performance of the p-value calculation procedures at. This will internally default to 0,0.01,...,1.

{phang}
{opt method(string)} A string indicating which method(s) to use to construct p-values. Currently, support is available to use exact binomial tail probabilities (exact) and to use a normal approximation (normal) approach. Defaults to all, which will employ all possible methods.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates whether the expected p-value curve plot should be produced.

{phang}
{opt *} Additional options to use during plotting.


{marker examples}{...}
{title:Examples}

{phang}
{stata pval_fixed}

{phang}
{stata pval_fixed, n(30)}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

Related commands:

{help des_fixed} (if installed)
{help opchar_fixed} (if installed)
{help est_fixed} (if installed)
{help ci_fixed} (if installed)
