{smcl}
{* *! version 0.9 31 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install des_ma" "ssc install des_ma"}{...}
{vieweralsosee "Help des_ma (if installed)" "help des_ma"}{...}
{viewerjumpto "Syntax" "des_ma##syntax"}{...}
{viewerjumpto "Description" "des_ma##description"}{...}
{viewerjumpto "Options" "des_ma##options"}{...}
{viewerjumpto "Examples" "des_ma##examples"}{...}
{title:Title}
{phang}
{bf:des_ma} {hline 2} Single-stage multi-arm trial design for normally distributed outcomes

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:des_ma}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt k(#)}} Number of experimental treatments. Default value is 3.{p_end}
{synopt:{opt alp:ha(#)}} Chosen significance level. Default value is 0.05.{p_end}
{synopt:{opt beta(#)}} Desired type-II error-rate. Default value is 0.2.{p_end}
{synopt:{opt del:ta(#)}} 'Interesting' treatment effect. Default value is 0.5.{p_end}
{synopt:{opt delta0(#)}} 'Uninteresting' treatment effect. Default value is 0.{p_end}
{synopt:{opt sd(#)}} Standard deviation of the responses. Default value is 1.{p_end}
{synopt:{opt rat:io(#)}} Allocation ratio between the experimental arms and the shared control arm. Default value is 1.{p_end}
{synopt:{opt cor:rection(string)}} Multiple comparison correction. Default value is dunnett.{p_end}
{synopt:{opt no:_sample_size}} Do not compute the required sample size.{p_end}
{synopt:{opt n_start(#)}} Starting value for finding the required sample size. Default value is 1.{p_end}
{synopt:{opt n_stop(#)}} Stopping value for finding the required sample size. Default value is -1.{p_end}
{synopt:{opt rep:licates(#)}} Number of replicate simulations. Default value is 10000.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:des_ma} determines the rejection rules and required sample size of a multi-arm trial with {it:K} experimental (see option {opt k}) and a single control treatment.
The outcome variable of interest is assumed to be normally distributed.{p_end}

{pstd}
It is assumed that {it:K} null hypotheses are to be tested, given by {it:H_}{it:k}: {it:τ}_{it:k} = {it:μ}_{it:k} - {it:μ}_0 ≤ 0, {it:k} = 1,..., {it:K}, where {it:μ}_{it:k} is the mean response on arm {it:k}.
Thus, arm 0 is assumed to be the control arm.
A set of (computed) p-values are used in combination with a chosen multiple comparison procedure in order to determine which of the null hypotheses to reject.{p_end}

{pstd}
Note that it is assumed {it:n} patients will be recruited to the control arm, and {it:rn} patients to each experimental arm (see option {opt rat:io}).
{p_end}

{pstd}
Several multiple comparison procedures are supported (see {opt cor:rection}), which in general work to control a particular error-rate to a specified significance level, α (see option {opt alp:ha}):
{p_end}

{pstd}
• benjamini: Control the false-discovery rate using the Benjamini-Hochberg procedure (Benjamini and Hochberg, 1995).
{p_end}{pstd}
• bonferroni: Control the familywise error-rate using Bonferroni's correction (Bonferroni, 1936; Dunn, 1958; Dunn, 1961).
{p_end}{pstd}
• dunnett: Control the familywise error-rate using Dunnett's correction (Dunnett, 1955; Dunnett, 1964).
{p_end}{pstd}
• holm: Control the familywise error-rate using the Holm-Bonferroni method (Holm, 1979).
{p_end}{pstd}
• none: Do not apply a multiple comparison procedure (i.e., test each hypothesis at level {opt alp:ha}).
{p_end}{pstd}
• sidak: Control the familywise error-rate using Šidák's correction (Šidák, 1967).
{p_end}{pstd}
• step_down_dunnett: Control the familywise error-rate using the step-down Dunnett correction (Naik, 1975; Marcus {it:et al}, 1976).
{p_end}

{pstd}
The option {opt no:_sample_size} controls whether the required sample size is computed, with the search controlled when conducted by options {opt n_start} and {opt n_stop}.
When the search is conducted, {cmd:des_ma} will aim to find the minimal required value of {it:n} to control the type-II error-rate to the desired level (see option {opt beta}) under the least favourable configuration, {it:LFC}.
The {it:LFC} requires 'interesting' and 'uninteresting' effect sizes {it:δ} and {it:δ}_0 to be specified (see options {opt del:ta} and {opt delta0}).
Precisely:
{p_end}

{pstd}
    {it:LFC}: {it:τ}_1 = {it:δ}, {it:τ}_2 = ... = {it:τ}_{it:K} = {it:δ}_0.
{p_end}

{pstd}
In this case, {cmd:des_ma} will return information on the familywise error-rate and power under {it:HG} and the {it:LFC} respectively, as well as the false discovery rate under {it:HG} and the {it:LFC}.
Here, {it:HG} is the global null hypothesis, given by:
{p_end}

{pstd}
    {it:HG}: {it:τ}_1 = ... = {it:τ}_{it:K} = 0.
{p_end}

{pstd}
For all calculations of error-rates, the standard deviation of the accrued responses is assumed to be known (see option {opt sd}).
{p_end}

{pstd}
Note that all error-rates are computed using multivariate normal integration where possible, otherwise simulation is employed (see option {opt rep:licates}).
In particular, this means that the required sample size is determined using simulation when the multiplicity correction is chosen as Benjamini-Hochberg, Holm-Bonferroni, or step-down Dunnett.
Finally, where required, the multivariate normal integration is performed using an internal component of the command {help pmvnormal} described in Grayling {it:et al} (2018).
This is included directly in {cmd:des_ma}.
{p_end}

{marker options}{...}
{title:Options}
{break}
{phang}
{opt k(#)} An integer giving the number of experimental treatments.
It should be greater than or equal to 1.
Thus, {cmd:des_ma} will compute two-arm trial designs.
However, if such a design is required, the user is recommended to use {help des_fixed} (available from the author) instead, which is optimised for the determination of such designs.
The default value is 3.
{p_end}{break}{phang}
{opt alp:ha(#)} A real giving the chosen significance level to use in the chosen multiple comparison prcoedure (see option {opt cor:rection}).
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
Not used when option {opt no:_sample_size} is specified, or if option {opt cor:rection} is bonferroni, dunnett, holm, none, or sidak.
{p_end}{break}{phang}
{opt sd(#)} A real giving the assumed value of the standard deviation of the responses in the control and experimental arms.
It should be strictly greater than 0.
The default value is 1.
{p_end}{break}{phang}
{opt rat:io(#)} A real giving the allocation ratio between the experimental arms and the shared control arm.
That is, {opt rat:io} patients are allocated to each experimental arm for every one patient allocated to the control arm.
It should be strictly positive.
The default value is 1.
{p_end}{break}{phang}
{opt cor:rection(string)} A string giving the multiple comparison procedure to use.
It should be one of benjamini, bonferroni, dunnett, holm, none, sidak, or step_down_dunnett.
The default value is dunnett.
Note used if option {opt k} is equal to 1.
{p_end}{break}{phang}
{opt no:_sample_size} Indicates that the required sample size should not be computed.
Speciying {opt no:_sample_size} will reduce the execution time.
{p_end}{break}{phang}
{opt n_start(#)} An integer giving the starting value in the search for the required sample size.
It should be an integer greater than or equal to 1.
The default value is 1.
Not used when option {opt no:_sample_size} is specified, or if option {opt cor:rection} is bonferroni, dunnett, holm, none, or sidak.
{p_end}{break}{phang}
{opt n_stop(#)} An integer giving the stopping value in the search for the required sample size.
It should either be greater than or equal to option {opt n_start}, or set to -1, which indicates that {opt n_stop} should be internally allocated as three times the sample size required by the corresponding single-stage design using Dunnett's correction
for the specified input parameters.
The default value is -1.
Not used when option {opt no:_sample_size} is specified, or if option {opt cor:rection} is bonferroni, dunnett, holm, none, or sidak.
{p_end}{break}{phang}
{opt rep:licates(#)} An integer giving the number of replicate simulations to use to evaluate required error-rates and sample sizes.
It should be an integer greater than or equal to 1.
The default value is 10000.
{p_end}

{marker examples}{...}
{title:Examples}

{phang}
{it:Note:} Depending on the available processing power, each of the following examples could take several minutes to run.
{p_end}

/// Example 1: A 3-experimental treatment multi-arm design.
{phang}{stata des_ma}{p_end}

/// Example 2: Modifying the multiplicity correction.
{phang}{stata des_ma, correction(holm)}{p_end}

/// Example 3: A 2-experimental treatment multi-arm design using
///            Bonferroni's correction, with unequal allocation to the
///            experimental and control arms.
{phang}{stata des_ma, k(2) ratio(0.5) correction(bonferroni)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:des_ma} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: scalars:}{p_end}
{synopt:{cmd:r(n)}} The required sample-size in the control arm.{p_end}
{synopt:{cmd:r(P_HG)}} The familywise error-rate under {it:HG}.{p_end}
{synopt:{cmd:r(P_LFC)}} The power under the {it:LFC}.{p_end}
{synopt:{cmd:r(FDR_HG)}} The false discovery rate under {it:HG}.{p_end}
{synopt:{cmd:r(FDR_LFC)}} The false discovery rate under the {it:LFC}.{p_end}
{synopt:{cmd:r(N)}} The total required sample size.{p_end}
{synopt:{cmd:r(u)}} The rejection (efficacy) boundary for the standardised test statistics.{p_end}
{synopt:{cmd:r(p)}} The critical rejection (efficacy) boundary for the p-values.{p_end}
{synopt:{cmd:r(u_O)}} The rejection (efficacy) boundaries for the ordered standardised test statistics.{p_end}
{synopt:{cmd:r(p_O)}} The critical rejection (efficacy) boundaries for the ordered p-values.{p_end}

{title:Author}
{p}

Dr Michael J Grayling
Institute of Health & Society, Newcastle University, UK
Email: {browse "michael.grayling@newcastle.ac.uk":michael.grayling@newcastle.ac.uk}

{title:See also}

{bf:References:}

{phang}
Benjamini Y, Hochberg Y (1995) {browse "https://www.jstor.org/stable/2346101":Controlling the false discovery rate: a practical and powerful approach to multiple testing}. {it:J Roy Stat Soc B} {bf:57}(1){bf::}289–300.

{phang}
Bonferroni CE (1936) Teoria statistica delle classi e calcolo delle probabilità. {it:Pubblicazioni del R Istituto Superiore di Scienze Economiche e Commerciali di Firenze} {bf:8:}3-62.

{phang}
Dunn OJ (1958) {browse "https://www.jstor.org/stable/2236948":Estimation of the means for dependent variables}. {it:Ann Math Stat} {bf:29}(4){bf::}1095–111.

{phang}
Dunn OJ (1961) {browse "http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.309.1277":Multiple comparisons among means}. {it:J Am Stat Assoc} {bf:56}(293){bf::}52–64.

{phang}
Dunnett CW (1955) {browse "https://www.jstor.org/stable/pdf/2281208.pdf":A multiple comparison procedure for comparing several treatments with a control}. {it:J Am Stat Assoc} {bf:50}(272){bf::}1096–121.

{phang}
Dunnett CW (1964) {browse "https://www.jstor.org/stable/2528490#metadata_info_tab_contents":New tables for multiple comparisons with a control}. {it:Biometrics} {bf:20}(3){bf::}482–91.

{phang}
Grayling MJ, Mander AP (2018) {browse "https://www.stata-journal.com/article.html?article=st0542":Calculations involving the multivariate normal and multivariate t distributions with and without truncation}. {it:Stata J} {bf:18}(4){bf::}826-43.

{phang}
Holm S (1979) {browse "https://www.ime.usp.br/~abe/lista/pdf4R8xPVzCnX.pdf":A simple sequentially rejective multiple test procedure}. {it:Scand J Stat} {bf:6}(2){bf::}65–70.

{phang}
Marcus R, Peritz E, Gabriel KR (1976) {browse "https://www.jstor.org/stable/2335748#metadata_info_tab_contents":On closed testing procedures with special reference to ordered analysis of variance}. {it:Biometrika} {bf:63}(3){bf::}655–60.

{phang}
Naik UD (1975) {browse "https://www.tandfonline.com/doi/abs/10.1080/03610927508827267":Some selection rules for comparing p processes with a standard}. {it:Commun Stat A} {bf:4}(6){bf::}519–35.

{phang}
Šidák ZK (1967) {browse "https://www.jstor.org/stable/2283989#metadata_info_tab_contents":Rectangular confidence regions for the means of multivariate normal distributions}. {it:J Am Stat Assoc} {bf:62}(318){bf::}626–33.

{bf:Related commands:}

{help des_dtl}   (a command for designing multi-stage drop-the-losers trials)
{help des_fixed} (a command for designing single-stage two-arm trials)
{help des_mams}  (a command for designing multi-arm multi-stage trials)
{help pmvnormal} (a command used for integration of the multivariate normal
           distribution function)
{help sim_dtl}   (a command for simulating multi-stage drop-the-losers trials)
{help sim_ma}    (a command for simulating multi-arm trials)
{help sim_mams}  (a command for simulating multi-arm multi-stage trials)
