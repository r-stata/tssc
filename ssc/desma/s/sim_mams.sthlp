{smcl}
{* *! version 0.9 31 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install sim_mams" "ssc install sim_mams"}{...}
{vieweralsosee "Help sim_mams (if installed)" "help sim_mams"}{...}
{viewerjumpto "Syntax" "sim_mams##syntax"}{...}
{viewerjumpto "Description" "sim_mams##description"}{...}
{viewerjumpto "Options" "sim_mams##options"}{...}
{viewerjumpto "Examples" "sim_mams##examples"}{...}
{title:Title}
{phang}
{bf:des_mams} {hline 2} Multi-arm multi-stage trial simulation for normally distributed outcomes

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sim_mams}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt l(numlist)}} Lower stopping boundaries.{p_end}
{synopt:{opt u(numlist)}} Upper stopping boundaries.{p_end}
{syntab:Optional}
{synopt:{opt n(#)}} Stage-wise group size in the control arm. Default value is 38.{p_end}
{synopt:{opt tau(numlist)}} Treatment effects. Default value is (0, 0, 0).{p_end}
{synopt:{opt sd(#)}} Standard deviation of the responses. Default value is 1.{p_end}
{synopt:{opt rat:io(#)}} Allocation ratio between the experimental arms and the shared control arm. Default value is 1.{p_end}
{synopt:{opt sep:arate}} Utilise a separate stopping rule.{p_end}
{synopt:{opt replicates(#)}} Number of replicate simulations. Default value is 10000.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:sim_mams} simulates multi-arm multi-stage trials with {it:K} experimental (see option {opt k}) and a single control treatment, as described by Magirr {it:et al} (2012).
That is, when the outcome variable of interest is assumed to be normally distributed.
For further information on MAMS designs, see Wason and Jaki (2012) and Wason {it:et al} (2016).{p_end}

{pstd}
It is assumed that {it:K} null hypotheses are to be tested, given by {it:H_}{it:k}: {it:τ}_{it:k} = {it:μ}_{it:k} - {it:μ}_0 ≤ 0, {it:k} = 1,..., {it:K}, where {it:μ}_{it:k} is the mean response on arm {it:k}.
Thus, arm 0 is assumed to be the control arm.
At each of at most {it:J} analyses (see option {opt j}), {it:j} = 1,..., {it:J}, a set of computed test statistics are compared to a lower (futility) bound,
with any treatment whose test statistic falls below this bound being dropped from the study.
Similarly, the test statistics are compared to an upper (efficacy) bound.
The null hypotheses corresponding to the test statistics that exceed this upper bound are rejected, with superiority of the relevant experimental treatments over control claimed.
{p_end}

{pstd}
The rules for the termination of the study are dependent upon whether a simultaneous or separate stopping rule is used (see option {opt sep:arate} and Urach and Posch (2016)).
With a simultaneous stopping rule, the trial is terminated as soon as any test statistic crosses an upper bound, or when all experimental arms have been dropped for futility.
That is, the study continues provided at least one test statistic exceeds the lower bound and none exceed the upper bound, with additional patients recruited to all remaining experimental treatments plus the control.
With a separate stopping rule, the study instead continues until all experimental arms have either been dropped for futility or claimed to be superior to the control.
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
{opt l(numlist)} A numlist (vector) giving the lower (futility) stopping boundaries.
Its length indicates the number of stages to the trial.
{p_end}{break}{phang}
{opt u(numlist)} A numlist (vector) giving the upper (efficacy) stopping boundaries.
It must be the same length as option {opt l}, and each upper interim stopping boundary (in option {opt u}) must be strictly greater than the corresponding lower interim stopping boundary (in option {opt l}).
The final upper stopping boundary in option {opt u} must also be equal to the final lower stopping boundary in option {opt l}.         
{p_end}{break}{phang}
{opt n(#)} An integer giving the stage-wise group size in the control arm.
Should be greater than or equal to 1.
The default value is 38.
{p_end}{break}{phang}
{opt tau(#)} A numlist (vector) giving the treatment effects.
Its length indicates the number of initial experimental treatments.
It can be of length 1.
Thus, {cmd:sim_mams} will simulate two-arm group-sequential trials.
However, if such simulations are required, the user is recommended to use {help sim_gs} (available from the author) instead, which is optimised for such scenarios.
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
{opt sep:arate} Indicates that a separate stopping rule should be used, as opposed to the default simultaneous stopping rule. 
Not used when option {opt no:_sample_size} is specified.
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

/// Example 1: Find a 2-stage 3-experimental treatment multi-arm multi-stage
///            design, and simulate its operating characteristics under the
///            global null hypothesis.
{phang}{stata des_mams}{p_end}
{phang}{stata sim_mams, l(-2.28, 2.28) u(2.28, 2.28) n(38)}{p_end}

/// Example 2: Find a 3-stage 2-experimental treatment multi-arm multi-stage
///            design, with unequal allocation to the control arm and
///            experimental arms, and simulate its operating characteristics
///            under the least favourable configuration.
{phang}{stata des_mams, k(2) j(3) ratio(0.5)}{p_end}
{phang}{stata sim_mams, l(-2.27, -2.27, 2.27) u(2.27, 2.27, 2.27) ratio(0.5) tau(0.5, 0)}{p_end}

/// Example 3: Find a 3-stage 3-experimental treatment separate stopping
///            multi-arm multi-stage design, with large assumed standard
///            deviation of the responses, and simulate its operating
///            characteristics under the global null hypothesis.
{phang}{stata des_mams, j(3) sd(2) separate}{p_end}
{phang}{stata sim_mams, l(-2.39, -2.39, 2.39) u(2.39, 2.39, 2.39) n(105) sd(2) separate}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:des_mams} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: scalars:}{p_end}
{synopt:{cmd:r(P_HA)}} Estimated probability that at least one null hypothesis is rejected.{p_end}
{synopt:{cmd:r(P_H1)}} Estimated probability that {it:H}_1 is rejected.{p_end}
{synopt:{cmd:r(ESS)}} Estimated average required sample size.{p_end}
{synopt:{cmd:r(SDSS)}} Estiamted standard deviation of the required sample size.{p_end}
{synopt:{cmd:r(MSS)}} Estimated median required sample size.{p_end}
{synopt:{cmd:r(min_N)}} Minimum required sample size.{p_end}
{synopt:{cmd:r(max_N)}} Maximum required sample size.{p_end}

{title:Author}
{p}

Dr Michael J Grayling
Institute of Health & Society, Newcastle University, UK
Email: {browse "michael.grayling@newcastle.ac.uk":michael.grayling@newcastle.ac.uk}

{title:See also}

{bf:References:}

{phang}
Grayling MJ, Wason JMS, Mander AP (2018) {browse "https://www.stata-journal.com/article.html?article=st0529":Group sequential clinical trial designs for normally distributed outcome variables}. {it:Stata J} {bf:18}(2){bf::}416-31.

{phang}
Jaki T, Magirr D (2013) {browse "https://onlinelibrary.wiley.com/doi/abs/10.1002/sim.5669":Considerations on covariates and endpoints in multi-arm multi-stage clinical trials selecting all promising treatments}. {it:Stat Med} {bf:32}(7){bf::}1150-63.

{phang}
Jennison C, Turnbull BW (2000) {it:Group sequential methods with applications to clinical trials}. Boca Raton: Champan and Hall/CRC.

{phang}
Magirr D, Jaki T, Whitehead J (2012) {browse "https://academic.oup.com/biomet/article/99/2/494/304953":A generalized Dunnett test for multi-arm multi-stage clinical studies with treatment selection}. {it:Biometrika} {bf:99}(2){bf::}494-501.

{phang}
Urach S, Posch M (2016) {browse "https://onlinelibrary.wiley.com/doi/10.1002/sim.7077":Multi-arm group sequential designs with a simultaneous stopping rule}. {it:Stat Med} {bf:35}(30){bf::}5536-50.

{phang}
Wason JMS, Jaki T (2012) {browse "https://onlinelibrary.wiley.com/doi/10.1002/sim.5513":Optimal design of multi-arm multi-stage trials}. {it:Stat Med} {bf:31}(30){bf::}4269-79.

{phang}
Wason J, Magirr D, Law M, Jaki T (2016) {browse "https://doi.org/10.1177/0962280212465498":Some recommendations for multi-arm multi-stage trials}. {it:Stat Meth Med Res} {bf:25}(2){bf::}716-27.

{phang}
Whitehead J (1997) {it:The design and analysis of sequential clinical trials}. Wiley: Chichester, UK.

{bf:Related commands:}

{help des_dtl}  (a command for designing multi-stage drop-the-losers trials)
{help des_ma}   (a command for designing single-stage multi-arm trials)
{help des_mams} (a command for designing multi-arm multi-stage trials)
{help nstage}   (a command that provides functionality for multi-arm
          multi-stage trials with time-to-event outcomes)
{help sim_dtl}  (a command for simulating multi-stage drop-the-losers trials)
{help sim_ma}   (a command for simulating multi-arm trials)
