{smcl}
{* *! version 1.0 14 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "des_admissable##syntax"}{...}
{viewerjumpto "Description" "des_admissable##description"}{...}
{viewerjumpto "Options" "des_admissable##options"}{...}
{viewerjumpto "Remarks" "des_admissable##remarks"}{...}
{viewerjumpto "Examples" "des_admissable##examples"}{...}
{title:Title}
{phang}
{bf:des_admissable} {hline 2} Design an admissable group sequential single-arm trial for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:des_admissable}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt j(#)}} The maximal number of stages to allow. Defaults to 2.{p_end}
{synopt:{opt pi0(#)}} The (undesirable) response probability used in the definition of the null hypothesis. Defaults to 0.1.{p_end}
{synopt:{opt pi1(#)}} The (desirable) response probability at which the trial is powered. Defaults to 0.3.{p_end}
{synopt:{opt a:lpha(#)}} The desired maximal type-I error-rate. Defaults to 0.05.{p_end}
{synopt:{opt b:eta(#)}} The desired maximal type-II error-rate. Defaults to 0.2.{p_end}
{synopt:{opt nmin(#)}} The minimal total sample size to allow in considered designs. Defaults to 1.{p_end}
{synopt:{opt nmax(#)}} The maximal total sample size to allow in considered designs. Defaults to 30.{p_end}
{synopt:{opt fut:ility(#)}} An integer indicating whether early stopping for futility should be allowed (futility = 1). Defaults to 1.{p_end}
{synopt:{opt eff:icacy(#)}} An integer indicating whether early stopping for efficacy should be allowed (efficacy = 1). Defaults to 0.{p_end}
{synopt:{opt eq:ual_n(#)}} An integer indicating that the sample size of each stage should be equal (equal = 1). Default value is 0.{p_end}
{synopt:{opt ens:ign(#)}} An integer indicating that the design of Ensign et al. (1994) should be mimicked, and the first stage futility boundary forced to be 0 (ensign = 1). Defaults to 0.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates that the admissability plot should be produced.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

Determines group sequential single-arm clinical trial designs for a single binary
primary endpoint. In particular, this allows Simon's two-stage designs (Simon,
1989) to be identified.

des_admissable supports the determination of admissable group sequential single-
arm clinical trial designs for a single binary primary endpoint. For all supported
designs, the following hypotheses are tested for the response probability pi

  H0 : pi <= pi0, H1 : pi > pi0.

In each instance, the optimal design is required to meet the following operating
characteristics

P(pi0) <= alpha, P(pi1) <= 1 - \beta,

where P(pi) is the probability of rejecting H0 when the true response probability
is pi. Moreover, pi1 must satisfy pi0 < pi1.

A group sequential single-arm design for a single binary endpoint, with a maximum
of J allowed stages (specifying J through the argument j) is then indexed by three
vectors: a=(a_1,...,a_J), r=(r_1,...,r_J), and n = (n_1,...,n_J).

With these vectors, and denoting the number of responses after m patients have
been observed by s(m), the stopping rules for the trial are then as follows

  - For j = 1, ...,J - 1
    - If s(N_j) <= a_j, then stop the trial and do not reject H0.
    - Else if s(N_j) >= r_j, then stop the trial and reject H0.
    - Else if a_j < s(N_j) < r_j, then continute to stage j + 1.
  - For j = J
    - If s(N_j) <= a_j, then do not reject H0.
    -  Else if s(N_j) >= r_j, then reject H0.

Here, N_j = n_1 + ... + n_j.

The purpose of this function is then to optimise a, r, and n, accounting for the
chosen restrictions placed on these vectors, and the chosen optimality criteria.

The arguments nmin, nmax, and equal_n allow restrictions to be placed on n.
Precisely, nmin and nmax set an inclusive range of allowed N_J. While, if set to
1, equal_n enforces n_1 = ... = n_J.

The arguments futility, efficacy, and ensign allow restrictions to be placed on a
and r. If futility is not set to 1, early stopping for futility (to not reject H0)
is prevented by enforcing a_1 = ... = a_{J-1} = -infty. Similarly, if efficacy is
not set to 1, early stopping for efficacy (to reject H0) is prevented by enforcing
r_1 = ... = r_{J-1} = infty. Finally, if set to 1, ensign enforces the
restriction that a_1 = 0, as suggested in Ensign et al. (1994) for 3-stage
designs.

Note that to ensure a decision is made about H0, this function enforces a_J + 1 =
r_J.

To describe the admissability criteria, denote the expected sample size when the
true response probability is pi by ESS(pi). Then, the following admissability
criteria is currently supported: Admissable designs minimise

  w_0ESS(pi0) + w_1ESS(pi1) + (1 - w_0 - w_1)N_J

for 0 <= w_0 + w_1 <= 1.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt j(#)} The maximal number of stages to allow. Defaults to 2.

{phang}
{opt pi0(#)} The (undesirable) response probability used in the definition of the
null hypothesis. Defaults to 0.1.

{phang}
{opt pi1(#)} The (desirable) response probability at which the trial is powered.
Defaults to 0.3.

{phang}
{opt a:lpha(#)} The desired maximal type-I error-rate. Defaults to 0.05.

{phang}
{opt b:eta(#)} The desired maximal type-II error-rate. Defaults to 0.2.

{phang}
{opt nmin(#)} The minimal total sample size to allow in considered designs.
Defaults to 1.

{phang}
{opt nmax(#)} The maximal total sample size to allow in considered designs.
Defaults to 30.

{phang}
{opt fut:ility(#)} An integer indicating whether early stopping for futility
should be allowed (futility = 1). Defaults to 1.

{phang}
{opt eff:icacy(#)} An integer indicating whether early stopping for efficacy
should be allowed (efficacy = 1). Defaults to 0.

{phang}
{opt eq:ual_n(#)} An integer indicating that the sample size of each stage should
be equal (equal = 1). Default value is 0.

{phang}
{opt ens:ign(#)} An integer indicating that the design of Ensign et al. (1994)
should be mimicked, and the first stage futility boundary forced to be 0 (ensign =
1). Defaults to 0.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's
progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates that the admissability plot should be produced

{phang}
{opt *} Additional options to use during plotting.

{marker examples}{...}
{title:Examples}

{phang}
{stata des_admissable}

{phang}
{stata des_admissable, alpha(0.1) plot}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}
