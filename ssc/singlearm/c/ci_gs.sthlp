{smcl}
{* *! version 1.0 14 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "ci_gs##syntax"}{...}
{viewerjumpto "Description" "ci_gs##description"}{...}
{viewerjumpto "Options" "ci_gs##options"}{...}
{viewerjumpto "Remarks" "ci_gs##remarks"}{...}
{viewerjumpto "Examples" "ci_gs##examples"}{...}
{title:Title}
{phang}
{bf:ci_gs} {hline 2} Determine confidence intervals in a group sequential single-arm trial design for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:ci_gs}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt j(#)}} The maximal number of stages to allow. Defaults to 2.{p_end}
{synopt:{opt n(numlist)}} Numlist of stage-wise sample sizes. Internally defaults to 10,19.{p_end}
{synopt:{opt a(numlist miss)}} Numlist of acceptance boundaries. Internally defaults to 1,5.{p_end}
{synopt:{opt r(numlist miss)}} Numlist of rejection boundaries. Internally defaults to .,6.{p_end}
{synopt:{opt k(numlist)}} Calculations are performed conditional on the trial stopping in one of the stages listed in numlist k. Thus, k should be a numlist of integers, with elements between one and the maximum number of possible stages. If left unspecified, it will internally default to all possible stages.{p_end}
{synopt:{opt alpha(#)}} alpha-level to use in confidence interval construction. Defaults to 0.05.{p_end}
{synopt:{opt pi(numlist)}} Numlist of response probabilities to evaluate the expected performance of the p-value calculation procedures at. This will internally default to 0,0.01,...,1.{p_end}
{synopt:{opt method(string)}} A string indicating which method(s) to use to construct confidence intervals. Currently, support is available to use the naive (naive), exact (exact), and Mid-p (mid_p) approaches. Internally defaults to all available methods.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates whether a plot should be produced. If set to length that the expected length curve will be procedured. If set to coverage then the coverage curve will be produced.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

Determines possible confidence intervals at the end of a group sequential single-
arm trial for a single binary endpoint, as determined using des_gs. Support is
available to compute confidence intervals using the naive (naive), exact (exact),
and Mid-p (mid_p) approaches.

In addition, the performance of the chosen confidence interval determination
procedures (including their coverage and expected length) for each value of pi in
the supplied vector pi, will also be evaluated.

Calculations are performed conditional on the trial stopping in one of the stages
specified using the input (numlist) k.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt j(#)} The maximal number of stages to allow. Defaults to 2.

{phang}
{opt n(numlist)} Numlist of stage-wise sample sizes. Internally defaults to 10,19.

{phang}
{opt a(numlist miss)} Numlist of acceptance boundaries. Internally defaults to 1,5.

{phang}
{opt r(numlist miss)} Numlist of rejection boundaries. Internally defaults to .,6.

{phang}
{opt k(numlist)} Calculations are performed conditional on the trial stopping in one of the stages listed in numlist k. Thus, k should be a numlist of integers, with elements between one and the maximum number of possible stages. If left unspecified, it will internally default to all possible stages.

{phang}
{opt alpha(#)} alpha-level to use in confidence interval construction. Defaults to 0.05.

{phang}
{opt pi(numlist)} Numlist of response probabilities to evaluate the expected performance of the p-value calculation procedures at. This will internally default to 0,0.01,...,1.

{phang}
{opt method(string)} A string indicating which method(s) to use to construct confidence intervals. Currently, support is available to use the naive (naive), exact (exact), and Mid-p (mid_p) approaches. Internally defaults to all available methods.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates whether a plot should be produced. If set to length that the expected length curve will be procedured. If set to coverage then the coverage curve will be produced.

{phang}
{opt *} Additional options to use during plotting.


{marker examples}{...}
{title:Examples}

{phang}
{stata ci_gs}

{phang}
{stata ci_gs, n(15, 10) a(1, 5) r(., 6)}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

Related commands:

{help des_gs} (if installed)
{help opchar_gs} (if installed)
{help est_gs} (if installed)
{help pval_gs} (if installed)
