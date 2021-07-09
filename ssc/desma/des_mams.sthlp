{smcl}
{* *! version 0.9 31 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install des_mams" "ssc install des_mams"}{...}
{vieweralsosee "Help des_mams (if installed)" "help des_mams"}{...}
{viewerjumpto "Syntax" "des_mams##syntax"}{...}
{viewerjumpto "Description" "des_mams##description"}{...}
{viewerjumpto "Options" "des_mams##options"}{...}
{viewerjumpto "Examples" "des_mams##examples"}{...}
{title:Title}
{phang}
{bf:des_mams} {hline 2} Multi-arm multi-stage trial design for normally distributed outcomes

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:des_mams}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt k(#)}} Initial number of experimental treatments. Default value is 3.{p_end}
{synopt:{opt j(#)}} Maximum number of stages. Default value is 2.{p_end}
{synopt:{opt alp:ha(#)}} Desired familywise error-rate. Default value is 0.05.{p_end}
{synopt:{opt beta(#)}} Permitted type-II error-rate. Default value is 0.2.{p_end}
{synopt:{opt del:ta(#)}} 'Interesting' treatment effect. Default value is 0.5.{p_end}
{synopt:{opt delta0(#)}} 'Uninteresting' treatment effect. Default value is 0.{p_end}
{synopt:{opt sd(#)}} Standard deviation of the responses. Default value is 1.{p_end}
{synopt:{opt rat:io(#)}} Allocation ratio between the experimental arms and the shared control arm. Default value is 1.{p_end}
{synopt:{opt es:hape(string)}} Shape of upper (efficacy) stopping boundary. Default value is pocock.{p_end}
{synopt:{opt fs:hape(string)}} Shape of lower (futility) stopping boundary. Must be one of fixed, obf, pocock, and triangular. Default value is {opt es:hape}.{p_end}
{synopt:{opt ef:ix(#)}} Fixed upper (efficacy) stopping boundary value. Default value is 2.{p_end}
{synopt:{opt ff:ix(#)}} Fixed lower (futility) stopping boundary value. Default value is 0.{p_end}
{synopt:{opt sep:arate}} Utilise a separate stopping rule.{p_end}
{synopt:{opt no:_sample_size}} Do not compute the required sample size.{p_end}
{synopt:{opt n_start(#)}} Starting value for finding the required sample size. Default value is 1.{p_end}
{synopt:{opt n_stop(#)}} Stopping value for finding the required sample size. Default value is -1.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:des_mams} determines the stopping boundaries and required sample size of a multi-arm multi-stage trial with {it:K} experimental (see option {opt k}) and a single control treatment, as described by Magirr {it:et al} (2012).
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
Note that it is assumed that in each stage {it:n} patients will be recruited to the control arm, and {it:rn} patients to each present experimental arm (see option {opt rat:io}).
{p_end}

{pstd}
The stopping boundaries are determined to control the familywise error-rate to level α (see option {opt alp:ha}) under the global null hypothesis, {it:HG}, given by:
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
In this case, {cmd:des_mams} will return information on the familywise error-rate and power under {it:HG} and the {it:LFC} respectively, as well
as the expected required sample size (ESS), standard deviation of the required sample size (SDSS), and median required sample size (MSS), under {it:HG} and the {it:LFC}.
{p_end}

{pstd}
For all calculations of error-rates, the standard deviation of the accrued responses is assumed to be known (see option {opt sd}).
{p_end}

{pstd}
A selection of possible stopping boundary shapes are supported (see options {opt es:hape} and {opt fs:hape}): Pocock (1977), O'Brien & Fleming (1979), the triangular test (Whitehead, 1997), and constant boundaries
(see options {opt ef:ix} and {opt ff:ix}).
{p_end}

{pstd}Note that the functionality and syntax of {cmd:des_mams} is deliberately similar to MAMS::mams() in R (Magirr {it:et al}, 2012), in order to facilitate the comparison of outputs for validation purposes.
Accordingly, examples provided below are also supplemented with equivalent R code where possible.
{p_end}

{pstd}
Finally, the required multivariate normal integration is performed using an internal component of the command {help pmvnormal} described in Grayling {it:et al} (2018).
This is included directly in {cmd:des_mams}.
Similarly, stopping boundaries are identified using an included implementation of Brent's root finding algorithm (Brent, 1973).
{p_end}

{marker options}{...}
{title:Options}
{break}
{phang}
{opt k(#)} An integer giving the initial number of experimental treatments.
It should be greater than or equal to 1.
Thus, {cmd:des_mams} will compute conventional two-arm group-sequential trial designs.
However, if such a design is required, the user is recommended to use {help des_gs} instead (available from the author), which is optimised for the determination of such designs.
The default value is 3.
{p_end}{break}{phang}
{opt j(#)} An integer giving the maximum allowed number of stages.
It should be greater than or equal to 2.
Thus, {cmd:des_mams} will not compute single-stage designs; for this functionality see {help des_ma}.
The default value is 2.
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
The default value is 1.
Not used when option {opt no:_sample_size} is specified.
{p_end}{break}{phang}
{opt delta0(#)} A real giving the 'uninteresting' treatment effect used in the definition of the {it:LFC}.
The default value is 0.
Not used when option {opt no:_sample_size} or option {sep:arate} is specified.
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
{opt es:hape(string)} A string giving the shape of the upper (efficacy) stopping boundary.
It must be one of fixed, obf, pocock, and triangular.
The (internally specified) default value is pocock.
{p_end}{break}{phang}
{opt fs:hape(string)} A string giving the shape of the futility (lower) stopping boundary.
It must be one of fixed, obf, pocock, and triangular.
The (internally specified) default value is the value of option {opt es:hape}.
{p_end}{break}{phang}
{opt ef:ix(#)} Only used if option {opt es:hape} is equal to fixed.
It is then a real giving the fixed upper (efficacy) stopping boundary value for the interim analyses.
The default value is 2.
{p_end}{break}{phang}
{opt ff:ix(#)} Only used if option {opt fs:hape} is equal to fixed.
It is then a real giving the fixed lower (futility) stopping boundary value for the interim analyses.
It should be strictly less than the value of {opt ef:ix} when {opt es:hape} is equal to fixed.
The default value is 0.
{p_end}{break}{phang}
{opt sep:arate} Indicates that a separate stopping rule should be used, as opposed to the default simultaneous stopping rule. 
Not used when option {opt no:_sample_size} is specified.
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

{bf:In Stata:}

/// Example 1: A 2-stage 3-experimental treatment MAMS design.
{phang}{stata des_mams}{p_end}

/// Example 2: Modifying the stopping boundary shape.
{phang}{stata des_mams, eshape(obf) fshape(triangular)}{p_end}

/// Example 3: A 3-stage 2-experimental treatment MAMS design with unequal
///            allocation to the experimental arms and the control arm.
{phang}{stata des_mams, k(2) j(3) ratio(0.5)}{p_end}

/// Example 4: A 3-stage 3-experimental treatment separate stopping MAMS
///            design, with larger assumed standard deviation of the responses.
{phang}{stata des_mams, j(3) sd(2) separate}{p_end}

{bf:Replication in R:}

### Install the MAMS package
install.packages("MAMS")

### Example 1: A 2-stage 3-experimental treatment MAMS design.
MAMS::mams(K = 3, power = 0.8, p = NULL, p0 = NULL, delta = 1, delta0 = 0,
           sd = 1, ushape = "pocock", lshape = "pocock")

### Example 2: Modifying the stopping boundary shape.
MAMS::mams(K = 3, power = 0.8, p = NULL, p0 = NULL, delta = 1, delta0 = 0,
           sd = 1, ushape = "obf", lshape = "triangular")

### Example 3: A 3-stage 2-experimental treatment MAMS design with unequal
###            allocation to the experimental arms and the control arm.
MAMS::mams(K = 2, J = 3, power = 0.8, r = c(0.5, 1, 1.5), r0 = 1:3, p = NULL,
           p0 = NULL, delta = 1, delta0 = 0, sd = 1, ushape = "pocock",
           lshape = "pocock")

### Example 4: A 3-stage 3-experimental treatment separate stopping MAMS
###            design, with large assumed standard deviation of the responses.
{it:Not currently supported}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:des_mams} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: scalars:}{p_end}
{synopt:{cmd:r(n)}} The required stage-wise group size in the control arm.{p_end}
{synopt:{cmd:r(P_HG)}} The familywise error-rate under {it:HG}.{p_end}
{synopt:{cmd:r(P_LFC)}} The power under the {it:LFC}.{p_end}
{synopt:{cmd:r(ESS_HG)}} The expected required sample size under {it:HG}.{p_end}
{synopt:{cmd:r(ESS_LFC)}} The expected required sample size under the {it:LFC}.{p_end}
{synopt:{cmd:r(SDSS_HG)}} The standard deviation of the required sample size under {it:HG}.{p_end}
{synopt:{cmd:r(SDSS_LFC)}} The standard deviation of the required sample size under the {it:LFC}.{p_end}
{synopt:{cmd:r(MSS_HG)}} The median required sample size under {it:HG}.{p_end}
{synopt:{cmd:r(MSS_LFC)}} The median required sample size under the {it:LFC}.{p_end}
{synopt:{cmd:r(min_N)}} The minimum possible required sample size.{p_end}
{synopt:{cmd:r(max_N)}} The maximum possible required sample size.{p_end}
{break}
{p2col 5 15 19 2: matrices:}{p_end}
{synopt:{cmd:r(l)}} The lower (futility) stopping boundaries.{p_end}
{synopt:{cmd:r(u)}} The upper (efficacy) stopping boundaries. {p_end}

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
Grayling MJ, Wason JMS, Mander AP (2018) {browse "https://www.stata-journal.com/article.html?article=st0529":Group sequential clinical trial designs for normally distributed outcome variables}. {it:Stata J} {bf:18}(2){bf::}416-31.

{phang}
Jaki T, Magirr D (2013) {browse "https://onlinelibrary.wiley.com/doi/abs/10.1002/sim.5669":Considerations on covariates and endpoints in multi-arm multi-stage clinical trials selecting all promising treatments}. {it:Stat Med}
{bf:32}(7){bf::}1150-63.

{phang}
Jennison C, Turnbull BW (2000) {it:Group sequential methods with applications to clinical trials}. Boca Raton: Champan and Hall/CRC.

{phang}
Magirr D, Jaki T, Whitehead J (2012) {browse "https://academic.oup.com/biomet/article/99/2/494/304953":A generalized Dunnett test for multi-arm multi-stage clinical studies with treatment selection}. {it:Biometrika} {bf:99}(2){bf::}494-501.

{phang}
O'Brien PC, Fleming TR (1979) {browse "https://www.ncbi.nlm.nih.gov/pubmed/497341":A multiple testing procedure for clinical trials}. {it:Biometrics} {bf:35}(3){bf::}549-56.

{phang}
Pocock SJ (1977) {browse "https://academic.oup.com/biomet/article/64/2/191/384776":Group sequential methods in the design and analysis of clinical trials}. {it:Biometrika} {bf:64}(2){bf::}191-9.

{phang}
Urach S, Posch M (2016) {browse "https://onlinelibrary.wiley.com/doi/10.1002/sim.7077":Multi-arm group sequential designs with a simultaneous stopping rule}. {it:Stat Med} {bf:35}(30){bf::}5536-50.

{phang}
Wason JMS, Jaki T (2012) {browse "https://onlinelibrary.wiley.com/doi/10.1002/sim.5513":Optimal design of multi-arm multi-stage trials}. {it:Stat Med} {bf:31}(30){bf::}4269-79.

{phang}
Wason J, Magirr D, Law M, Jaki T (2016) {browse "https://doi.org/10.1177/0962280212465498":Some recommendations for multi-arm multi-stage trials}. {it:Stat Meth Med Res} {bf:25}(2){bf::}716-27.

{phang}
Whitehead J (1997) {it:The design and analysis of sequential clinical trials}. Wiley: Chichester, UK.

{phang}
Whitehead J, Stratton I (1983) {browse "https://www.ncbi.nlm.nih.gov/pubmed/6871351":Group sequential clinical trials with triangular continuation regions}. {it:Biometrics} {bf:39}(1){bf::}227-36.

{bf:Related commands:}

{help des_dtl}   (a command for designing multi-stage drop-the-losers trials)
{help des_ma}    (a command for designing single-stage multi-arm trials)
{help nstage}    (a command that provides functionality for multi-arm
           multi-stage trials with time-to-event outcomes)
{help pmvnormal} (a command used for integration of the multivariate normal
           distribution function)
{help sim_dtl}   (a command for simulating multi-stage drop-the-losers trials)
{help sim_ma}    (a command for simulating multi-arm trials)
{help sim_mams}  (a command for simulating multi-arm multi-stage trials)
