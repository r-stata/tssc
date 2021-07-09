{smcl}
{* *! version 1.0 14 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "des_fixed##syntax"}{...}
{viewerjumpto "Description" "des_fixed##description"}{...}
{viewerjumpto "Options" "des_fixed##options"}{...}
{viewerjumpto "Remarks" "des_fixed##remarks"}{...}
{viewerjumpto "Examples" "des_fixed##examples"}{...}
{title:Title}
{phang}
{bf:des_fixed} {hline 2} Design a single-stage single-arm trial for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:des_fixed}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt pi0(#)}} The (undesirable) response probability used in the definition of the null hypothesis. Defaults to 0.1.{p_end}
{synopt:{opt pi1(#)}} The (desirable) response probability at which the trial is powered. Defaults to 0.3.{p_end}
{synopt:{opt a:lpha(#)}} The desired maximal type-I error rate. Defaults to 0.05.{p_end}
{synopt:{opt b:eta(#)}} The desired maximal type-II error rate. Defaults to 0.2.{p_end}
{synopt:{opt nmin(#)}} The minimal sample size to allow in considered designs. Defaults to 1.{p_end}
{synopt:{opt nmax(#)}} The maximal sample size to allow in considered designs. Defaults to 30.{p_end}
{synopt:{opt ex:act(#)}} An integer indicating whether exact binomial calculations (exact = 1) or a normal approximation approach (exact ~= 1) should be used to determine the optimal design. Defaults to 1.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates that the stopping boundaries of the identified optimal design should be plotted.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

Supports the determination of single-stage single-arm clinical trial designs for a
single binary primary endpoint. The following hypotheses are tested for the
response probability pi

  H0 : pi <= pi0, H1 : pi > pi0.

In each instance, the optimal design is required to meet the following operating
characteristics

  P(pi0) <= alpha, P(pi1) >= 1 - beta,

where P(pi) is the probability of rejecting H0 when the true response probability
is pi. Moreover, pi1 must satisfy pi0 < pi1.

A single-stage single-arm design for a single binary endpoint is ultimately
indexed by three parameters: a, r, and n.

With these parameters, and denoting the number of responses after m outcomes have
been observed by s(m), the testing rules for the trial are as follows

  - If s(n) <= a, then do not reject H0.
  - Else if s(n) >= r, then reject H0.

The purpose of this function is then to determine (optimise) a, r, and n,
accounting for the chosen restrictions placed on these parameters.

The arguments nmin and nmax allow restrictions to be placed on n.
Precisely, nmin and nmax set an inclusive range of allowed values for n.

Note that to ensure a decision is made about H0, this function always enforces a +
1 = r.

The optimal design is then the one that minimises n. In the case where there are
multiple feasible designs with the same minimal value of n, the optimal design is
the one amongst these which maximises P(pi1).

If exact = 1 then exact binomial probability calculations are used to
identify the optimal design. Otherwise, a normal approximation approach is used.
Note that setting exact = 1 is recommended.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt pi0(#)} The (undesirable) response probability used in the definition of the null hypothesis. Defaults to 0.1.

{phang}
{opt pi1(#)} The (desirable) response probability at which the trial is powered. Defaults to 0.3.

{phang}
{opt a:lpha(#)} The desired maximal type-I error rate. Defaults to 0.05.

{phang}
{opt b:eta(#)} The desired maximal type-II error rate. Defaults to 0.2.

{phang}
{opt nmin(#)} The minimal sample size to allow in considered designs. Defaults to 1.

{phang}
{opt nmax(#)} The maximal sample size to allow in considered designs. Defaults to 30.

{phang}
{opt ex:act(#)} An integer indicating whether exact binomial calculations (exact = 1) or a normal approximation approach (exact ~= 1) should be used to determine the optimal design. Defaults to 1.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates that the stopping boundaries of the identified optimal design should be plotted.

{phang}
{opt *} Additional options to use during plotting.


{marker examples}{...}
{title:Examples}

{phang}
{stata des_fixed}

{phang}
{stata des_fixed, alpha(0.1)}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

Related commands:

{help opchar_fixed} (if installed)
{help est_fixed} (if installed)
{help ci_fixed} (if installed)
{help pval_fixed} (if installed)
