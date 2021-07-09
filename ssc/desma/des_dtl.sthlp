{smcl}
{* *! version 0.9 31 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install des_dtl" "ssc install des_dtl"}{...}
{vieweralsosee "Help des_dtl (if installed)" "help des_dtl"}{...}
{viewerjumpto "Syntax" "des_dtl##syntax"}{...}
{viewerjumpto "Description" "des_dtl##description"}{...}
{viewerjumpto "Options" "des_dtl##options"}{...}
{viewerjumpto "Examples" "des_dtl##examples"}{...}
{title:Title}
{phang}
{bf:des_dtl} {hline 2} Multi-stage drop-the-losers trial design for normally distributed outcomes

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:des_dtl}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt kv(numlist)}} Number of experimental treatments in each stage. Default value is (3, 1).{p_end}
{synopt:{opt alp:ha(#)}} Desired familywise error-rate. Default value is 0.05.{p_end}
{synopt:{opt beta(#)}} Desired type-II error-rate. Default value is 0.2.{p_end}
{synopt:{opt del:ta(#)}} 'Interesting' treatment effect. Default value is 0.5.{p_end}
{synopt:{opt delta0(#)}} 'Uninteresting' treatment effect. Default value is 0.{p_end}
{synopt:{opt sd(#)}} Standard deviation of the responses. Default value is 1.{p_end}
{synopt:{opt rat:io(#)}} Allocation ratio between the experimental arms and the shared control arm. Default value is 1.{p_end}
{synopt:{opt no:_sample_size}} Do not compute the required sample size.{p_end}
{synopt:{opt n_start(#)}} Starting value for finding the required sample size. Default value is 1.{p_end}
{synopt:{opt n_stop(#)}} Stopping value for finding the required sample size. Default value is -1.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:des_dtl} determines the final-stage rejection (efficacy) boundary and required sample size of a multi-stage drop-the-losers trial with {it:K} experimental (see option {opt k}) and a single control treatment,
as described by Wason {it:et al} (2017).
That is, when the outcome variable of interest is assumed to be normally distributed.{p_end}

{pstd}
It is assumed that {it:K} null hypotheses are to be tested, given by {it:H_}{it:k}: {it:τ}_{it:k} = {it:μ}_{it:k} - {it:μ}_0 ≤ 0, {it:k} = 1,..., {it:K}, where {it:μ}_{it:k} is the mean response on arm {it:k}.
Thus, arm 0 is assumed to be the control arm.
At each of {it:J} - 1 interim analyses, {it:j} = 1,..., {it:J} - 1, a set of computed test statistics are ranked to determine which experimental treatments continue to stage {it:j} + 1 (see option {opt kv}) along with the control treatment.
At the final analysis, the test statistic for the remanining experimental treatment is compared to a rejection (efficacy) bound.
If the test statistic exceeds this upper bound, the null hypothesis corresponding to this test statistic is rejected, with superiority of the relevant experimental treatment over control claimed.
{p_end}

{pstd}
Note that it is assumed that in each stage {it:n} patients will be recruited to the control arm, and {it:rn} patients to each present experimental arm (see option {opt rat:io}).
{p_end}

{pstd}
The final-stage rejection boundary will be determined to control the familywise error-rate to level α (see option {opt alp:ha}) under the global null hypothesis, {it:HG}, which is given by:
{p_end}

{pstd}
    {it:HG}: {it:τ}_1 = ... = {it:τ}_{it:K} = 0.
{p_end}

{pstd}
The option {opt no:_sample_size} controls whether the required sample size is computed, with the search controlled when conducted by options {opt n_start} and {opt n_stop}.
When the search is conducted, {cmd:des_dtl} will aim to find the minimal required value of {it:n} to control the type-II error-rate to the desired level, β (see option {opt beta}), under the least favourable configuration, {it:LFC}.
The {it:LFC} requires 'interesting' and 'uninteresting' effect sizes {it:δ} and {it:δ}_0 to be specified (see options {opt del:ta} and {opt delta0}).
Precisely:
{p_end}

{pstd}
    {it:LFC}: {it:τ}_1 = {it:δ}, {it:τ}_2 = ... = {it:τ}_{it:K} = {it:δ}_0.
{p_end}

{pstd}
In this case, {cmd:des_dtl} will return information on the familywise error-rate and power under {it:HG} and the {it:LFC} respectively.
{p_end}

{pstd}
For all calculations of error-rates, the standard deviation of the accrued responses is assumed to be known (see option {opt sd}).
{p_end}

{pstd}
Finally, the required multivariate normal integration is performed using an internal component of the command {help pmvnormal} described in Grayling {it:et al} (2018).
This is included directly in {cmd:des_dtl}.
Similarly, the finaly-stage efficacy boundary is identified using an included implementation of Brent's root finding algorithm (Brent, 1973).
{p_end}

{marker options}{...}
{title:Options}
{break}
{phang}
{opt kv(#)} A numlist (vector) giving the number of experimental treatments that should be present in each stage of the trial.
Its length indicates the number of stages to the trial, and at least one experimental treatment should be dropped at each analysis.
Thus, its length should be greater than or equal to 2, and its elements should be strictly monotonically decreasing.
Its final element must also be 1.
The (internally specified) default value is (3, 1).
{p_end}{break}{phang}
{opt alp:ha(#)} A real giving the desired familywise error-rate.
It should be strictly between 0 and 1.
The default value is 0.05.
{p_end}{break}{phang}
{opt beta(#)} A real giving the desired type-II error-rate under the {it:LFC}.
It should be strictly between 0 and 1.
The default value is 0.2.
Not used when option {opt no:_sample_size} is specified.
{p_end}{break}{phang}
{opt del:ta(#)} A real giving the 'interesting' treatment effect used in the definition of the {it:LFC}.
It should be strictly greater than 0.
The default value is 0.5.
Not used when option {opt no:_sample_size} is specified.
{p_end}{break}{phang}
{opt delta0(#)} A real giving the 'uninteresting' treatment effect used in the definition of the {it:LFC}.
The default value is 0.
Not used when option {opt no:_sample_size} is specified.
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
{opt no:_sample_size} Indicates that the required sample size should not be computed.
Speciying {opt no:_sample_size} will reduce the execution time.
{p_end}{break}{phang}
{opt n_start(#)} An integer giving the starting value in the search for the required sample size.
It should be an integer greater than or equal to 1.
The default value is 1.
Not used when option {opt no:_sample_size} is specified.
{p_end}{break}{phang}
{opt n_stop(#)} An integer giving the stopping value in the search for the required sample size.
It should either be greater than or equal to {opt n_start}, or set to -1, which indicates that {opt n_stop} should be internally allocated as three times the sample size required by the corresponding single-stage design using Dunnett's correction for
the specified input parameters.
The default value is -1.
Not used when option {opt no:_sample_size} is specified.
{p_end}

{marker examples}{...}
{title:Examples}

{phang}
{it:Note:} Depending on the available processing power, each of the following examples could take several minutes to run.
{p_end}

/// Example 1: A 2-stage 3-experimental treatment drop-the-losers design.
{phang}{stata des_dtl}{p_end}

/// Example 2: Modifying the number of treatments in each stage.
{phang}{stata des_dtl, kv(5, 1)}{p_end}

/// Example 3: A 3-stage 6-experimental treatment drop-the-losers design with
///            unequal allocation to the experimental arms and the control arm.
{phang}{stata des_dtl, kv(6, 4, 1) ratio(0.5)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:des_dtl} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: scalars:}{p_end}
{synopt:{cmd:r(u)}} The final-stage rejection (efficacy) boundary.{p_end}
{synopt:{cmd:r(n)}} The required stage-wise group size in the control arm.{p_end}
{synopt:{cmd:r(P_HG)}} The familywise error-rate under {it:HG}.{p_end}
{synopt:{cmd:r(P_LFC)}} The power under the {it:LFC}.{p_end}
{synopt:{cmd:r(N)}} The total required sample size.{p_end}

{title:Author}
{p}

Dr Michael J Grayling
Institute of Health & Society, Newcastle University, UK
Email: {browse "michael.grayling@newcastle.ac.uk":michael.grayling@newcastle.ac.uk}

{title:See also}

{bf:References:}

{phang}
Brent R (1973) {it:Algorithms for minimization without derivatives}. Prentice-Hall: New Jersey, US.

{phang}
Grayling MJ, Mander AP (2018) {browse "https://www.stata-journal.com/article.html?article=st0542":Calculations involving the multivariate normal and multivariate t distributions with and without truncation}. {it:Stata J} {bf:18}(4){bf::}826-43.

{phang}
Jennison C, Turnbull BW (2000) {it:Group sequential methods with applications to clinical trials}. Boca Raton: Champan and Hall/CRC.

{phang}
Wason J, Stallard N, Bowden J, Jennison C (2017) {browse "https://doi.org/10.1177/0962280214550759":A multi-stage drop-the-losers design for multi-arm clinical trials}. {it:Stat Meth Med Res} {bf:26}(1){bf::}508–24. 

{bf:Related commands:}

{help des_ma}    (a command for designing single-stage multi-arm trials)
{help des_mams}  (a command for designing multi-arm multi-stage trials)
{help pmvnormal} (a command used for integration of the multivariate normal
           distribution function)
{help sim_dtl}   (a command for simulating multi-stage drop-the-losers trials)
{help sim_ma}    (a command for simulating multi-arm trials)
{help sim_mams}  (a command for simulating multi-arm multi-stage trials)
