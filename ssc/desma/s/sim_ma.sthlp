{smcl}
{* *! version 0.9 31 Jan 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install sim_ma" "ssc install des_ma"}{...}
{vieweralsosee "Help des_ma (if installed)" "help des_ma"}{...}
{viewerjumpto "Syntax" "des_ma##syntax"}{...}
{viewerjumpto "Description" "des_ma##description"}{...}
{viewerjumpto "Options" "des_ma##options"}{...}
{viewerjumpto "Examples" "des_ma##examples"}{...}
{title:Title}
{phang}
{bf:des_ma} {hline 2} Single-stage multi-arm trial simulation for normally distributed outcomes

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:des_ma}{cmd:,} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt n(#)}} Stage-wise group size in the control arm. Default value is 34.{p_end}
{synopt:{opt tau(numlist)}} Treatment effects. Default value is (0, 0, 0).{p_end}
{synopt:{opt sd(#)}} Standard deviation of the responses. Default value is 1.{p_end}
{synopt:{opt rat:io(#)}} Allocation ratio between the experimental arms and the shared control arm. Default value is 1.{p_end}
{synopt:{opt alp:ha(#)}} Chosen significance level. Default value is 0.05.{p_end}
{synopt:{opt cor:rection(string)}} Multiple comparison correction. Default value is dunnett.{p_end}
{synopt:{opt replicates(#)}} Number of replicate simulations. Default value is 10000.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:sim_ma} simulated multi-arm trials with {it:K} experimental (see option {opt k}) and a single control treatment.
The outcome variable of interest is assumed to be normally distributed.{p_end}

{pstd}
It is assumed that {it:K} null hypotheses are to be tested, given by {it:H_}{it:k}: {it:τ}_{it:k} = {it:μ}_{it:k} - {it:μ}_0 ≤ 0, {it:k} = 1,..., {it:K}, where {it:μ}_{it:k} is the mean response on arm {it:k}.
Thus, arm 0 is assumed to be the control arm.
A set of (computed) p-values are used in combination with a chosen multiple comparison procedure in order to determine which of the null hypotheses to reject.{p_end}

{pstd}
Note that it is assumed {it:n} patients will be recruited to the control arm, and {it:rn} patients to each experimental arm (see option {opt rat:io}).
It is also assumed that the standard deviation of the accrued responses is known (see option {opt sd}).
{p_end}

{pstd}
The operating characteristics are evaluated at a specified vector of treatment effects ({it:τ}_1, ..., {it:τ}_{it:K}) (see option {opt tau}), using a particular number of replicate simulations (see option {opt rep:licates}).
{p_end}

{pstd}
Several multiple comparison procedures are supported (see {opt cor:rection}), which in general work to control a particular error-rate to a specified significance level (see option {opt a:lpha}):
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

{marker options}{...}
{title:Options}
{break}
{phang}
{opt n(#)} An integer giving the group size in the control arm.
Should be greater than or equal to 1.
The default value is 68.
{p_end}{break}{phang}
{opt tau(#)} A numlist (vector) giving the treatment effects.
It can be of length 1.
Thus, {cmd:sim_ma} will simulate single-stage two-arm trials.
However, if such simulations are required, the user is recommended to use {help sim_fixed} (available from the author) instead, which is optimised for such scenarios.
The (internally specified) default value is (0, 0, 0).
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
{opt alp:ha(#)} A real giving the chosen significance level to use in the chosen multiple comparison procedure (see option {opt cor:rection}).
It should be strictly between 0 and 1.
The default value is 0.05.
{p_end}{break}{phang}
{opt cor:rection(string)} A string giving the multiple comparison procedure to use.
It should be one of benjamini, bonferroni, dunnett, holm, none, sidak, or step_down_dunnett.
The default value is dunnett.
Note used if option {opt k} is equal to 1.
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

/// Example 1: Find a 3-experimental treatment multi-arm design, and simulate
///            its operating characteristics under the global null hypothesis.
{phang}{stata des_ma}{p_end}
{phang}{stata sim_ma}{p_end}

/// Example 2: Find a design with modified multiplicity correction, and
///            simulate its operating characteristics under the least
///            favourable configuration.
{phang}{stata des_ma, correction(holm)}{p_end}
{phang}{stata sim_ma, n(71) tau(0.5, 0, 0) correction(holm)}{p_end}

/// Example 3: Find a 2-experimental treatment multi-arm design using
///            Bonferroni's correction, with unequal allocation to the
///            experimental and control arms, and simulate its operating
///            characteristics under the global null hypothesis.
{phang}{stata des_ma, k(2) ratio(0.5) correction(bonferroni)}{p_end}
{phang}{stata sim_ma, n(96) tau(0, 0) ratio(0.5) correction(bonferroni)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:des_ma} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: scalars:}{p_end}
{synopt:{cmd:r(P_HA)}} Estimated probability that at least one null hypothesis is rejected.{p_end}
{synopt:{cmd:r(P_H1)}} Estimated probability that {it:H}_1 is rejected.{p_end}
{synopt:{cmd:r(FDR_HG)}} Estimated false discovery rate.{p_end}

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
Holm S (1979) {browse "https://www.ime.usp.br/~abe/lista/pdf4R8xPVzCnX.pdf":A simple sequentially rejective multiple test procedure}. {it:Scand J Stat} {bf:6}(2){bf::}65–70.

{phang}
Marcus R, Peritz E, Gabriel KR (1976) {browse "https://www.jstor.org/stable/2335748#metadata_info_tab_contents":On closed testing procedures with special reference to ordered analysis of variance}. {it:Biometrika} {bf:63}(3){bf::}655–60.

{phang}
Naik UD (1975) {browse "https://www.tandfonline.com/doi/abs/10.1080/03610927508827267":Some selection rules for comparing p processes with a standard}. {it:Commun Stat A} {bf:4}(6){bf::}519–35.

{phang}
Šidák ZK (1967) {browse "https://www.jstor.org/stable/2283989#metadata_info_tab_contents":Rectangular confidence regions for the means of multivariate normal distributions}. {it:J Am Stat Assoc} {bf:62}(318){bf::}626–33.

{bf:Related commands:}

{help des_dtl}   (a command for designing multi-stage drop-the-losers trials)
{help des_ma}    (a command for designing single-stage multi-arm trials)
{help des_mams}  (a command for designing multi-arm multi-stage trials)
{help sim_dtl}   (a command for simulating multi-stage drop-the-losers trials)
{help sim_fixed} (a command for simulating single-stage two-arm trials)
{help sim_mams}  (a command for simulating multi-arm multi-stage trials)
