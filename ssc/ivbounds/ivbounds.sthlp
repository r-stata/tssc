{smcl}
{* *! version 1.0 22june2021}{...}
{viewerjumpto "Syntax" "ivbounds##syntax"}{...}
{viewerjumpto "Description" "ivbounds##description"}{...}
{viewerjumpto "Options" "ivbounds##options"}{...}
{viewerjumpto "Examples" "ivbounds##examples"}{...}
{viewerjumpto "Stored results" "ivbounds##results"}{...}
{viewerjumpto "References" "ivbounds##references"}{...}
{p}
{bf:ivbounds} {hline 2} Instrumental variable method to bound treatment-effects estimates with potentially misreported and endogenous 
program participation

{marker syntax}{...}

{title:Syntax}

{p 8 0 0 0}{cmd:ivbounds} {depvar} [{indepvars}] {ifin}{cmd:,} {cmd:treat({help varname:{it:varname_t}})} {cmd:iv({help varname:{it:varname_iv}})} {cmd:strategy(#)} [{it:options}]


{synoptset 20 tabbed}{...}
{synopthdr :required}
{synoptline}
{syntab:Model}
{synopt :{cmd:treat({help varname:{it:varname_t}})}}specify the name of the binary mismeasured treatment indicator{p_end}
{synopt :{cmd:iv({help varname:{it:varname_iv}})}}specify the name of the binary or discrete instrumental variable{p_end}
{synopt :{opt strategy(#)}}specify which partial identification strategy to use in estimation{p_end}
{synoptline}

{marker synoptions}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt order(#)}}positive or negative ascending order in {opt iv(varname_iv)}{p_end}
{synopt :{opt alpha(#)}}significance level of the confidence interval{p_end}
{synopt :{opt lower(#)}}lower bound of the treatment misclassification probability{p_end}
{synopt :{opt upper(#)}}upper bound of the treatment misclassification probability{p_end}
{synopt :{opt strata(#)}}number of strata to discretise the propensity score when covariates are included in {indepvars}{p_end}
{synopt :{opt seed(#)}}set random seed at the beginning of the program{p_end}
{synopt :{opt nboot(#)}}number of bootstraps to compute the critical values when constructing confidence intervals{p_end}
{synopt :{opt kn(#)}}number of partitions of outcome {depvar}{p_end}

{syntab:Survey}
{synopt :{opt survey}}indicate that data are survey data and weights are specified in {cmd:svyset}{p_end}
{synopt :{opt weights(#)}}indicate whether bootstrap weights have already been calculated{p_end}
{synopt :{opt npsu(#)}}value of {cmd:n(#)} passed to the {cmd:bsweights} command{p_end}
{synopt :{opt reps(#)}}number of bootstrap replications passed to the {cmd:bsweights} command{p_end}

{syntab:Reporting/Saving}
{synopt :{opt nodisplay}}suppress the summary results table{p_end}
{synopt :{cmd:saving(}{help filename:{it:filename}}{cmd:)}}specify where to save output results{p_end}
{synopt :{opt replace}}replace results in current {cmd:saving(}{help filename:{it:filename}}{cmd:)}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ivbounds} provides an estimate of the bounds of the average causal effect for compliers (Imbens and Angrist, 1994) when both noncompliance and misreporting of treatment status are present. 
The approach follows the estimation procedure developed in Tommasi and Zhang (2020).
When {opt iv(varname_iv)} is binary, the command estimates the bounds of the local average treatment effect (LATE).
When {opt iv(varname_iv)} is binary and covariates are included, the command estimates the bounds of the unconditional LATE (Frölich, 2007).
In both cases, the estimated bounds coincide with those in Ura (2018). 
When {opt iv(varname_iv)} is discrete, the command estimates the bounds of the weighted average of LATEs (WLATE).
When {opt iv(varname_iv)} is discrete and covariates are included, the command estimates the bounds of the conditional WLATE.
In the latter case, the user must specify the number of strata to discretise the propensity score. The inference procedure follows
Dehejia and Wahba (1999) and Battistin and Sianesi (2011).
{cmd:ivbounds} assumes a binary {opt treat(varname_t)}, a binary or discrete {opt iv(varname_iv)}, and a continuous or discrete {depvar}. 
The bounds can be improved if external information regarding the treatment misclassification probability in {opt treat(varname_t)} is available.


{marker required}{...}
{title:Required}

{phang}
{cmd:treat({help varname:{it:varname_t}})} specifies the name of the binary mismeasured treatment indicator. {opt treat(varname_t)} is required and the variable can only take value 0 and 1 for control and
treatment, respectively.

{phang}
{cmd:iv({help varname:{it:varname_iv}})} specifies the name of the binary or discrete instrumental variable. {opt iv(varname_iv)} is required.

{phang}
{opt strategy(#)} specifies which partial identification strategy to use. {cmd:strategy(1)} provides estimates of the bounds of the target parameter via the bounds of LATEs. 
Prior information about the treatment misclassification probability is not required. {cmd:strategy(2)} provides estimates of the bounds of the target parameter via the bounds of the average treatment misclassification probabilities for compliers. 
Prior information about the treatment misclassification probability is not required. {cmd:strategy(1)} and {cmd:strategy(2)} produce the same result if the instrument is binary. 
{cmd:strategy(3)} provides estimates of the bounds of the target parameter exploiting external sources of information about the treatment misclassification 
probability to further improve the bounds of the second strategy. The quality of the external information is an important identifying assumption and must be well justified in practice. {opt strategy(#)} is required.
 
{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt order(#)} specifies the order of values of the instrumental variable {opt iv(varname_iv)}. In practice, 
the user must specify whether, in population, the instrument positively or negatively affect the true 
treatment variable, which can be obtained by economic theory or linear regression of the observed treatment on the instrument 
(assuming the observed treatment is a good proxy for the true one). If the user specifies {cmd:order(1)}, the ascending order holds 
and hence the effect of {opt iv(varname_iv)} on the true treatment is assumed to be positive. If the user specifies {cmd:order(0)}, 
the descending order holds and hence the effect of {opt iv(varname_iv)} on the true treatment is assumed to be negative. 
The order of instrumental variable is an important identifying assumption and must be well justified in practice. The default is {cmd:order(1)}.

{phang}
{opt alpha(#)} specifies the significance level of confidence interval for any specified strategy. For example, {cmd:alpha(0.05)} means the output is a (1 - 0.05)% = 95% confidence interval of the bound for the target parameter. 
The default is {cmd:alpha(0.05)}.

{phang}
{opt lower(#)} specifies the lower bound of the treatment misclassification probability. For example, {cmd:lower(0.80)} implies that the parameter ξ ≥ 80%. Only available for {cmd:strategy(3)}.

{phang}
{opt upper(#)} specifies the upper bound of the treatment misclassification probability. For example, {cmd:upper(0.80)} implies that the parameter ξ ≤ 80%.  Only available for {cmd:strategy(3)}.

{phang}
{opt strata(#)} specifies the number of strata to discretise the propensity score when covariates are included in the analysis. The inference procedure follows
Dehejia and Wahba (1999) and Battistin and Sianesi (2011). This option can only be specified in the presence of covariates {indepvars}. The default is {cmd: strata(3)}.

{phang}
{opt seed(#)} sets the initial value of the random-number seed used by the randomnumber functions.

{phang}
{opt nboot(#)} specifies the number of bootstraps to compute the critical values when constructing confidence intervals. The default is {cmd:nboot(500)}.

{phang}
{opt kn(#)} specifies the number of partitions of outcome {depvar}. The default is {cmd:kn(3)}.

{dlgtab:Survey}

{phang}
{opt survey} indicates that data are survey data and that survey weights have been assigned with {help svyset:{it:svyset}}.

{phang}
{opt weights(#)} indicates whether bootstrap weights have already been calculated.  The default is {cmd:weights(0)}, which indicates that bootstrap weights
 have not been calculated and will instead be calculated from within the {cmd:ivbounds} command via the program {cmd:bsweights}. The {opt weights(#)} option is intended
 as a programming control to avoid replacing the estimates in {cmd:ereturn} at each iteration of the bootstrap.  Should the user have prespecified bootstrap weights
 available, the weights must be of the form bsw1 bsw2 ...  bswN, where N denotes the number of bootstrap replications.

{phang}
{opt npsu(#)} specifies the value of {opt n(#)} for the {cmd:bsweights} command.  {opt npsu(#)} specifies how the number of primary sampling units per stratum are handled.
 The default is {cmd:npsu(-1)}, which indicates a bootstrap sample of size n_h-1 for all strata h (Kolenikov, 2010). 

{phang}
{opt reps(#)} specifies the value of {opt reps(#)} for the {cmd:bsweights} command.  {opt reps(#)} specifies the number of bootstrap replications to be taken and the
 number of weight variables to be generated. The default is {cmd:reps(100)}.

{dlgtab:Reporting/Saving}

{phang}
{opt nodisplay} suppresses the summary results table. Results are still stored in {cmd:ereturn}.

{phang}
{cmd:saving(}{help filename:{it:filename}}{cmd:)} indicates the location in which to save the output.

{phang}
{opt replace} indicates that the output in {cmd:saving(}{help filename:{it:filename}}{cmd:)} should replace any preexisting file in the same location. 


{marker examples}{...}
{title:Examples}

{pstd}Load the 401ksubs dataset{p_end}
{phang2}{cmd:. bcuse 401ksubs, clear}

{pstd}ivbounds estimation under a default setting{p_end}
{phang2}{cmd:. ivbounds nettfa, treat(p401k) iv(e401k) strategy(1) order(1)}

{pstd}ivbounds estimation including covariates{p_end}
{phang2}{cmd:. ivbounds nettfa inc marr age agesq fsize, treat(p401k) iv(e401k) strategy(1) order(1)}

{pstd}ivbounds estimation with some variations{p_end}
{phang2}{cmd:. ivbounds nettfa inc marr age agesq fsize, treat(p401k) iv(e401k) strategy(2) order(1) seed(123) alpha(0.01)}

{pstd}ivbounds estimation using strategy 3 and approximation on false negative probability. For example, in case the probability of
false negative is approximately 17% (wn=0.17), then one should set lower(max{0, 1-2*wn}) upper(1-wn){p_end}
{phang2}{cmd:. ivbounds nettfa inc marr age agesq fsize, treat(p401k) iv(e401k) strategy(3) strata(3) lower(0.66) upper(0.83)}

{pstd}ivbounds estimation using strategy 3 and approximation on false positive probability. For example, in case the probability of
false positive is approximately 10% (wp=0.10), then one should set lower(0) upper(1-2*wp){p_end}
{phang2}{cmd:. ivbounds nettfa inc marr age agesq fsize, treat(p401k) iv(e401k) strategy(3) strata(3) lower(0) upper(0.80)}

{pstd}ivbounds estimation using strategy 3 and bounds of false positive and false negative probabilities. For example, in case the
bounds are (0.1<=wn<=0.17 & wp=0.10), then one should set lower(1-0.1-0.17) upper(1-0.1-0.1){p_end}
{phang2}{cmd:. ivbounds nettfa inc marr age agesq fsize, treat(p401k) iv(e401k) strategy(3) strata(3) lower(0.73) upper(0.8)}

{pstd}ivbounds estimation using strategy 3 and approximations of false positive and false negative probabilities. For example, in case the
probabilities are wn=0.17 and wp=0.10, then one should set upper(1-wn-wp=0.73) lower(1-wn-wp=0.73){p_end}
{phang2}{cmd:. ivbounds nettfa inc marr age agesq fsize, treat(p401k) iv(e401k) strategy(3) strata(3) lower(0.73) upper(0.73)}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ivbounds} stores the following in {cmd:e()}:

{synoptset 23 tabbed}{...}
{p2col 5 23 26 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(strata)}}number of strata{p_end}
{synopt:{cmd:e(strategy)}}partial identification strategy chosen{p_end}
{synopt:{cmd:e(order)}}order specification{p_end}
{synopt:{cmd:e(lower)}}lower bound of the treatment misclassification probability{p_end}
{synopt:{cmd:e(upper)}}upper bound of the treatment misclassification probability{p_end}

{p2col 5 23 26 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(treat)}}mismeasured treatment variable{p_end}
{synopt:{cmd:e(iv)}}instrumental variable{p_end}

{p2col 5 23 26 2: Matrices}{p_end}
{synopt:{cmd:e(bounds)}}estimated bounds of the LATE or WLATE{p_end}


{marker references}{...}
{title:References}

{phang}
Battistin, E., and B. Sianesi. 2011. Misclassified treatment status and treatment effects: An application to returns to education in the United Kingdom. Review of Economics and Statistics, 93, 495-509.

{phang}
Dehejia, R. H., and S. Wahba. 1999. Causal effects in nonexperimental studies: Reevaluating the evaluation of training programs. Journal of the American statistical Association, 94, 1053-1062.

{phang}
Frölich, M., 2007. Nonparametric IV estimation of local average treatment effects with covariates. Journal of Econometrics, 139(1), 35-75.

{phang}
Imbens, G. W., and J. D. Angrist. 1994. Identification and Estimation of Local Average Treatment Effects. Econometrica 62(2): 467-475.

{phang}
Kolenikov, S.  2010.  Resampling variance estimation for complex survey data.  Stata Journal 10: 165-199.

{phang}
Tommasi, D., and L. Zhang. 2020. Bounding Program Benefits When Participation Is Misreported. IZA Discussion Paper.

{phang}
Ura, T. 2018. Heterogeneous treatment effects with mismeasured endogenous treatment. Quantitative Economics 9(3): 1335-1370.


{marker remarks}{...}
{title:Remarks}

{phang}
This command requires Stata 13. 

{phang}
This is a preliminary version which is currently being updated as we receive comments. Please feel free to share your comments, reports of bugs, and propositions for extensions to 
{browse "mailto:denni.tommasi@monash.edu":denni.tommasi@monash.edu}.

{phang}
If you use this command in your work, please cite Tommasi and Zhang (2020).

{phang}
Help: {help moremata:{it:moremata}}, {help bsweights:{it:bsweights}}, {help bs4rw:{it:bs4rw}} (if installed)


{marker authors}{...}
{title:Authors}

Andy Lin
Institute for Digital Research and Education
USA
{browse "mailto:alin@oit.ucla.edu":alin@oit.ucla.edu}

Denni Tommasi
Monash University
Australia
{browse "mailto:denni.tommasi@monash.edu":denni.tommasi@monash.edu}

Lina Zhang
Monash University
Australia
{browse "mailto:lina.zhang@monash.edu":lina.zhang@monash.edu}

