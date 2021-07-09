{smcl}
{* *! version 0.9 31 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install sim_dtl" "ssc install sim_dtl"}{...}
{vieweralsosee "Help sim_dtl (if installed)" "help sim_dtl"}{...}
{viewerjumpto "Syntax" "sim_dtl##syntax"}{...}
{viewerjumpto "Description" "sim_dtl##description"}{...}
{viewerjumpto "Options" "sim_dtl##options"}{...}
{viewerjumpto "Examples" "sim_dtl##examples"}{...}
{title:Title}
{phang}
{bf:des_dtl} {hline 2} Multi-stage drop-the-losers trial simulation for normally distributed outcomes

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sim_dtl}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt Kv(numlist)}} Number of experimental treatments in each stage. Default value is (3, 1).{p_end}
{synopt:{opt u(numlist)}} Final-stage rejection (efficacy) boundary.{p_end}
{synopt:{opt n(#)}} Stage-wise group size in the control arm. Default value is 34.{p_end}
{synopt:{opt tau(numlist)}} Treatment effects. Default value is (0, 0, 0).{p_end}
{synopt:{opt sd(#)}} Standard deviation of the responses. Default value is 1.{p_end}
{synopt:{opt rat:io(#)}} Allocation ratio between the experimental arms and the shared control arm. Default value is 1.{p_end}
{synopt:{opt replicates(#)}} Number of replicate simulations. Default value is 10000.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:sim_dtl} simulates multi-stage drop-the-losers trials with {it:K} experimental (see option {opt k}) and a single control treatment, as described by Wason {it:et al} (2017).
That is, when the outcome variable of interest is assumed to be normally distributed.{p_end}

{pstd}
It is assumed that {it:K} null hypotheses are to be tested, given by {it:H_}{it:k}: {it:τ}_{it:k} = {it:μ}_{it:k} - {it:μ}_0 ≤ 0, {it:k} = 1,..., {it:K}, where {it:μ}_{it:k} is the mean response on arm {it:k}.
Thus, arm 0 is assumed to be the control arm.
At each of {it:J} - 1 interim analyses, {it:j} = 1,..., {it:J} - 1, a set of computed test statistics are ranked to determine which experimental treatments continue to stage {it:j} + 1 (see option {opt kv}) along with the control treatment.
At the final analysis, the test statistic for the remanining experimental treatment is compared to a rejection (efficacy) bound.
If the test statistic exceeds this upper bound, the null hypothesis corresponding to this test statistic is rejected, with superiority of the relevant experimental treatment over control claimed.
{p_end}

{pstd}
Note that it is assumed that in each stage {it:n} patients will be recruited to the control arm, and {it:rn} patients to each present experimental arm (see options {opt n} and {opt rat:io}).
It is also assumed that the standard deviation of the accrued responses is known (see option {opt sd}).
{p_end}

{pstd}
The operating characteristics are evaluated at a specified vector of treatment effects ({it:τ}_1, ..., {it:τ}_{it:K}) (see option {opt tau}), using a particular number of replicate simulations (see option {opt rep:licates}).
{p_end}

{marker options}{...}
{title:Options}
{break}
{phang}
{opt kv(numlist)} A numlist (vector) giving the number of experimental treatments that should be present in each stage of the trial.
Its length indicates the number of stages to the trial, and at least one experimental treatment should be dropped at each analysis.
Thus, its length should be greater than or equal to 2, and its elements should be strictly monotonically decreasing.
Its final element must also be 1.
The (internally specified) default value is (3, 1).
{p_end}{break}{phang}
{opt u(numlist)} A real giving the final-stage rejection (efficacy) boundary.      
{p_end}{break}{phang}
{opt n(#)} An integer giving the stage-wise group size in the control arm.
Should be greater than or equal to 1.
The default value is 34.
{p_end}{break}{phang}
{opt tau(#)} A numlist (vector) giving the treatment effects.
Its length must be equal to the first element of option {opt kv}.
The (internally specified) default value is (0, 0, 0).
{p_end}{break}{phang}
{opt sd(#)} A real giving the assumed value of the standard deviation of the responses in the control and experimental arms.
It should be strictly greater than 0.
The default value is 1.
{p_end}{break}{phang}
{opt rat:io(#)} A real giving the stage-wise allocation ratio between the (remaining) experimental arms and the shared control arm.
That is, {opt rat:io} patients are allocated to each present experimental arm for every one patient allocated to the control arm.
It should be strictly positive.
The default value is 1.
{p_end}{break}{phang}
{opt rep:licates(#)} An integer giving the number of replicate simulations to use to evaluate the operating characteristics.
It should be an integer greater than or equal to 1.
The default value is 10000.
{p_end}

{marker examples}{...}
{title:Examples}

{phang}
{it:Note:} Depending on the available processing power, each of the following examples could take several minutes to run.
{p_end}

{bf:In Stata:}

/// Example 1: Find a 2-stage 3-experimental treatment drop-the-losers design,
///            and simulate its operating characeristics under the global null
///            hypothesis.
{phang}{stata des_dtl}{p_end}
{phang}{stata sim_dtl}{p_end}

/// Example 2: Find a design with modified numbers of treatments in each stage,
///            and simulate its operating characeristics under the least
///            favourable configuration.
{phang}{stata des_dtl, kv(5, 3, 1)}{p_end}
{phang}{stata sim_dtl, kv(5, 3, 1) u(2.15) n(25) tau(0.5, 0, 0, 0, 0)}{p_end}

/// Example 3: Find a 3-stage 6-experimental treatment drop-the-losers design
///            with unequal allocation to the experimental arms and the control
///            arm, and simulate its operating characeristics under the global
///            null hypothesis.
{phang}{stata des_dtl, kv(6, 4, 1) ratio(0.5)}{p_end}
{phang}{stata sim_dtl, kv(6, 4, 1) u(2.26) n(42) tau(0, 0, 0, 0, 0, 0) ratio(0.5)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:des_mams} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: scalars:}{p_end}
{synopt:{cmd:r(P_HA)}} Estimated probability that at least one null hypothesis is rejected.{p_end}
{synopt:{cmd:r(P_H1)}} Estimated probability that {it:H}_1 is rejected.{p_end}

{title:Author}
{p}

Dr Michael J Grayling
Institute of Health & Society, Newcastle University, UK
Email: {browse "michael.grayling@newcastle.ac.uk":michael.grayling@newcastle.ac.uk}

{title:See also}

{bf:References:}

{phang}
Jennison C, Turnbull BW (2000) {it:Group sequential methods with applications to clinical trials}. Boca Raton: Champan and Hall/CRC.

{phang}
Wason J, Stallard N, Bowden J, Jennison C (2017) {browse "https://doi.org/10.1177/0962280214550759":A multi-stage drop-the-losers design for multi-arm clinical trials}. {it:Stat Meth Med Res} {bf:26}(1){bf::}508–24.

{bf:Related commands:}

{help des_dtl}  (a command for designing multi-stage drop-the-losers trials)
{help des_ma}   (a command for designing single-stage multi-arm trials)
{help des_mams} (a command for designing multi-arm multi-stage trials)
{help nstage}   (a command that provides functionality for multi-arm
          multi-stage trials with time-to-event outcomes)
{help sim_dtl}  (a command for simulating multi-stage drop-the-losers trials)
{help sim_ma}   (a command for simulating multi-arm trials)
