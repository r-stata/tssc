{smcl}
{* *! version 2.0.1 2020.03.28}{...}
{viewerjumpto "Syntax" "uirt##syntax"}{...}
{viewerjumpto "Description" "uirt##description"}{...}
{viewerjumpto "Options" "uirt##options"}{...}
{viewerjumpto "Examples" "uirt##examples"}{...}
{viewerjumpto "Stored results" "uirt##results"}{...}
{viewerjumpto "References" "uirt##references"}{...}
{cmd:help uirt}
{hline}

{title:Title}

{phang}
{bf:uirt} {hline 2} Stata module to fit unidimensional Item Response Theory models

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:uirt} {varlist} {ifin} [{cmd:,} {it:{help uirt##options:options}}]


{synoptset 24 tabbed}
{p2colset 7 32 34 4}
{marker options}{...}
{synopthdr :Options}
{synoptline}

{syntab:Multi-group}
{synopt:{opt gr:oupvar(varname)}} set the group membership variable {p_end}
{synopt:{opt ref:erence(#)}} set the value of the reference group {p_end}
{synopt:{opt dif(varlist)}} items to test for differential item functioning (DIF) {p_end}
{synopt:{opt dist}} free the estimation of parameters of reference group {p_end}


{syntab:Models}
{synopt:{opt pcm(varlist)}} items to fit with the Partial Credit Model {p_end}
{synopt:{opt gpcm(varlist)}} items to fit with the Generalized Partial Credit Model{p_end}
{synopt:{opt gue:ssing(varlist)}} items to attempt fitting with the 3-Parameter Logistic Model{p_end}
{synopt:{opt guessing_attempts(#)}} maximum number of attempts to fit a 3PLM; default: guessing_attempts(5) {p_end}
{synopt:{opt guessing_lrcrit(#)}} significance level for LR test comparing 2PLM against 3PLM; default: guessing_lrcrit(0.05) {p_end}

{syntab:ICC}
{synopt:{opt icc}} create ICC graphs for all items and save them in current working directory{p_end}
{synopt:{opt icc_vars(varlist)}} create ICC graphs for selected items and save them in current working directory{p_end}
{synopt:{opt icc_format(str)}} file format for ICC graphs (png|gph|eps); default: icc_format(png) {p_end}
{synopt:{opt icc_bins(#)}} number of ability intervals for observed proportions; default: icc_bins(100) {p_end}
{synopt:{opt icc_pv}} use plausible values to compute observed proportions; default behavior is to use numerical integration {p_end}
{synopt:{opt icc_pvbin(#)}} number of plausible values in each bin; default: icc_pvbin(10000) {p_end}
{synopt:{opt icc_noobs}} suppress plotting observed proportions{p_end}

{syntab:Item-fit}
{synopt:{opt fit}} compute chi2W item-fit statistic for all items{p_end}
{synopt:{opt fit_vars(varlist)}} compute chi2W item-fit statistic for selected items{p_end}
{synopt:{opt fit_sx2}} compute S-X2 item-fit statistic for all dichotomous items{p_end}
{synopt:{opt fit_sx2_vars(varlist)}} compute S-X2 item-fit statistic for selected dichotomous items{p_end}

{syntab:Theta & PVs}
{synopt:{opt th:eta}} create EAP estimator of theta and its standard error {p_end}
{synopt:{opt pv(#)}} number of plausible values added to the dataset, default is pv(0) (no PVs added){p_end}
{synopt:{opt pvreg(str)}} define regression for conditioning PVs {p_end}
{synopt:{opt thn:ame(name)}} specify a suffix used in naming EAP, PVs and ICC graphs {p_end}

{syntab:Fixed and starting values}
{synopt:{opt fixim:atrix(name)}} matrix with item parameters to be fixed during estimation {p_end}
{synopt:{opt initim:atrix(name)}} matrix with starting values for item parameters {p_end}
{synopt:{opt initdm:atrix(name)}} matrix with starting values for distribution parameters {p_end}

{syntab:EM control}
{synopt:{opt nip(#)}} number of GH quadrature points used in EM algorithm; default: nip(51){p_end}
{synopt:{opt theta_nip(#)}} number of GH quadrature points used when calculating EAP and its SE; default: theta_nip(195){p_end}
{synopt:{opt nit(#)}} maximum number of iterations of EM algorithm; default: nit(100) {p_end}
{synopt:{opt crit_ll(#)}} stopping rule - relative change in logL between EM iterations; default: crit_ll(1e-9) {p_end}
{synopt:{opt crit_par(#)}} stopping rule - maximum absolute change in parameter values between EM iterations; default: crit_par(1e-4) {p_end}
{synopt:{opt err:or(str)}} method for computation of standard errors (cdm|rem|sem|cp); default: error(cdm){p_end}
{synopt:{opt noupd:_quad_betw_em}} suppress a speed-up of EM for the multi-group estimation{p_end}

{syntab:Reporting}
{synopt:{opt not:able}} suppress coefficient table{p_end}
{synopt:{opt tr:ace(#)}} control log display after each iteration; 0 - suppress; 1 - normal (default); 2 - detailed{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:uirt} is a Stata module for estimating variety of unidimensional IRT models (2PLM, 3PLM, GRM, PCM and GPCM).
It features multi-group modelling, DIF analysis, item-fit analysis 
and generating plausible values (PVs) conditioned via latent regression.
{cmd:uirt} implements the EM algorithm (Dempster, Laird & Rubin, 1977) 
in the form of marginal maximum likelihood estimation (MML) proposed by Bock & Aitkin (1981) 
with normal Gauss-Hermite quadrature.
LR test is used for DIF testing and model based P-DIF effect size measures are provided (Wainer, 1993).
Generating PVs is performed by adapting a MCMC method 
developed for IRT models by Patz & Junker (1999).
Observed response proportions are plotted against the item characteristic curves to allow for detailed graphical item fit analysis.
Two item-fit statistics are available: S-X2 by Orlando and Thissen (2000) and chi2W developed by the author (Kondratek, 2020).


{marker options}{...}
{title:Options}


{dlgtab:Multi-group}

{phang}
{opt groupvar(varname)} sets the variable defining group membership for multi-group IRT models. 
Must be numeric.

{phang}
{opt reference(#)} sets the reference group value. 
If not specified {opt reference}=min({opt groupvar}). 

{phang}
{opt dist} frees the estimation of parameters of reference group. 
Using this option requires fixing parameters of at least one item in order to identify the model.

{phang}
{opt dif(varlist)} is used to provide the list of items to test for differential item functioning (DIF).
For each of the items specified in dif() a 2-group model with common item parameters in both groups
is compared against a model with group-specific parameters for the item under scrutiny.
Statistical significance of DIF is verified by a LR test.
Effect measures are computed on the observed score metric (P-DIF) by subtracting expected mean scores of an item
under each of the group-specific item parameter estimates (Wainer, 1993).
Namely, P-DIF|G1=E(par1,G1)-E(par2,G1), where G1 indicates that the reference group distribution was used for integration
and par1 and par2 stand for item parameters estimated in G1 and G2 respectively. Analogous P-DIF|G2 measure is also computed.
DIF significance and effect size information is stored in {cmd:e(dif_results)}.
Calling dif() will also result in plotting graphs with group-specific ICCs, which are saved in the working directory.
The format of DIF graph files is controlled by icc_format().



{dlgtab:Models}

{pstd}
By default {cmd:uirt} will fit the 2-Parameter Logistic Model to all items that are detected to be dichotomous,
and the Samejima's Graded Response Model to all items that are detected to have more than two responses.
Options {opt pcm()}, {opt gpcm()}, {opt guessing()} are used if one wishes to use other models. Hybrid models are allowed.

{phang}
{opt pcm(varlist)} is used to provide a list of items to fit with the Partial Credit Model.
If PCM is used a common discrimination parameter is estimated for all PCM items.

{phang}
{opt gpcm(varlist)} is used to provide a list of items to fit with the Generalized Partial Credit Model.
If item is dichotomous it will be reported as 2PLM in the output (2PLM and GPCM are the same for dichotomous items).

{phang}
{opt guessing(varlist)} is used to provide a list of items to attempt fitting a 3-Parameter Logistic Model. 
Items which are detected to have more than two response categories are automatically excluded from the list.
The pseudo-guessing parameter of the 3PL model is hard to estimate
(especially for easy items or small sample sizes)
and often leads to convergence problems.
In order to circumvent this, for each 3PL-candidate item {cmd:uirt} starts with a 2PL model and
performs multiple attempts of fitting the 3PL model instead of 2PL.
The 3PL attempts are followed by checks on parameter behavior
with two criteria for deciding whether to keep the item 2PLM or to go with 3PLM.
The first criterion is convergence - an item stays 2PL if the parameter estimates change to rapidly,
the pseudo-guessing goes negative,
the discrimination parameter goes to 0 or negative etc. 
The second criterion is a result of a "LR test" after single EM iteration
- if the model likelihood does not improve significantly the item stays 2PL.
During each attempt {cmd:uirt} will print a note if either LR or convergence criterion resulted in an item staying 2PL.
Number of attempts of fitting a 3PL model is controlled by {opt guessing_attempts()}
and the LR sensitivity is controlled by {opt guessing_lrcrit()}.
Note that this is an exploratory procedure.

{phang}
{opt guessing_attempts(#)} maximum number of attempts to fit a 3PLM model to items specified in {opt guessing()}. 
The default value is guessing_attempts(5).

{phang}
{opt guessing_lrcrit(#)} significance level criterion for "LR test" verifying whether 3PLM fits better than 2PLM on item level.
If test is negative the item stays 2PLM and a note is printed. Default value is guessing_lrcrit(0.05).
Specifying value of 1 will suppress LR testing and rejection of 3PLM on the basis of such procedure will not be performed.
Note that "LR test" is performed after only one EM cycle hence not being a "proper" LR test.
This procedure is more conservative that the actual LR test (performed after complete convergence of the EM algorithm) would be.


{dlgtab:ICC}

{pstd}
If {cmd:uirt} is asked to plot ICCs it will, by default, superimpose observed proportions against the ICC curves to enable a graphical item-fit assessment.
The observed proportions are computed after quantile-based division of the distribution of latent variable.
Item response of a single person is included simultaneously into many intervals (bins) of theta with probability
proportional to the density of {it: a posteriori} latent trait distribution of that person in each bin.
Default method uses definite numerical integration, but after choosing {opt icc_pv}, plausible values (PVs) will be employed to achieve this task.
Plotting observed proportions is controlled by {opt icc_bins()} and {opt icc_pvbin()}, it can be also turned off by {opt icc_noobs} option.

{phang}
{opt icc} creates ICC graphs for all items and saves them in current working directory.
Note that if ICC graphs for such items are already saved in the working directory under default names they will be overwritten.
If you do not want to overwrite previous ICCs change the working directory or rename the existing files.

{phang}
{opt icc_vars(varlist)} does the same as simple {opt icc} but you can choose the items for which the ICCs are plotted.

{phang}
{opt icc_format(str)} specifies the file format in which the ICC graphs are saved (png|gph|eps).
Default value is icc_format(png).
This option influences also the graphs created after asking for DIF analysis.

{phang}
{opt icc_bins(#)} sets the number of intervals the distribution of ability is split into
when calculating observed proportions of responses. Default value is icc_bins(100).

{phang}
{opt icc_pv} changes the default method of computing observed proportions from definite numerical integration to Monte Carlo integration
with unconditioned PVs. It involves more CPU time, introduces variance due to sampling of PVs, 
but takes the uncertainty in estimation of IRT model parameters into account.

{phang}
{opt icc_pvbin(#)} sets the number of plausible values used for computing observed proportions of responses
within each interval of theta. Default value is icc_pvbin(10000).

{phang}
{opt icc_noobs} suppress plotting observed proportions.


{dlgtab:Item-fit}

{pstd}
{cmd:uirt} allows computing two types of item fit statistics. In single group setting, when there is enough dichotomously scored items with no missing responses,
item-fit can be assessed with classical S-X2 statistic proposed by Orlando and Thissen (2000).
The second available item-fit statistic, chi2W, is more general and can be applied to incomplete data and all IRT models handled by {cmd:uirt}.

{phang}
{opt fit} computes chi2W item-fit statistic for all items.
chi2W is a Wald-type test statistic that compares the observed and expected item mean scores over a set of ability bins.
The observed and expected scores are weighted means with weights being {it: a posteriori} density of person's ability within the bin 
- likewise as in the approach used to compute observed proportions in ICC plots.
Properties of chi2W have been examined for dichotomous items, Type I error rate was close to nominal and it exceeded S-X2 in statistical power (Kondratek, 2020).
Behavior of chi2W in case of polytomous items, as for the time of this {cmd:uirt} release, has not been researched. The results are stored in {cmd:e(item_fit_chi2W)}.

{phang}
{opt icc_vars(varlist)} does the same as simple {opt fit} but you can choose the items for which the fit statistic is computed. 

{phang}
{opt fit_sx2} computes S-X2 item-fit statistic for all dichotomous items, as described in Orlando and Thissen (2000). S-X2 cannot be used in multigroup setting. 
The number-correct score used for grouping is obtained from dichotomous items - if polytomous items are present, they are ignored in computation of S-X2.
If a dichotomous item has missing responses it is also ignored in computation of S-X2. The results are stored in {cmd:e(item_fit_SX2)}.

{phang}
{opt fit_sx2_vars(varlist)} does the same as simple {opt fit_sx2} but you can choose the items for which the fit statistic is computed.


{dlgtab:Theta & PVs}

{phang}
{opt theta} will add the Expected a Posteriori (EAP) estimator of theta and its standard error at the end of the dataset.
These will be named "theta" and "se_theta" unless {opt thname()} is specified.

{phang}
{opt pv(#)} sets the number of plausible values added to the dataset. 
Default value is 0 (no PVs added). 
The PVs will be named "pv_1",..., "pv_#" unless {opt thname()} is specified.
The PVs are generated after the estimation is completed.
The general procedure involves two steps.
In the first step, # random draws, b*, of model parameters are taken from MVN distribution with means vector {cmd:e(b)} and covariance matrix {cmd:e(V)}.
In the second step, for each person, # independent MCMC chains are run according to procedure described by 
Patz & Junker (1999) with b* parameter draws treated as fixed. 
Finally, after a burn-in period, each of the PVs is drawn from a different MCMC chain.
Such procedure allows incorporating IRT model uncertainty in PV generation without the need of multilevel-structured MCMC, 
thus reducing the computational expense and avoiding the use of Bayesian priors for item parameters. 
Note that if some of the item parameters are fixed with {opt fiximatrix()} option the PVs will take no account 
of the uncertainty of estimation of these fixed parameters.
Additional {opt pvreg()} option allows to modify the procedure so that it includes conditioning by a latent regression.

{phang}
{opt pvreg(str)} is used to perform conditioning of plausible values on ancillary variables.
If other variables, than the ones used in defining the IRT model,
are to be used in the analyses performed with PVs, these variables need to be included in {opt pvreg()} option. 
Otherwise, the analyses will produce effects which are biased towards 0.
The syntax for {opt pvreg()} is the same as in defining the regression term in {helpb xtmixed},  e.g. pvreg(ses ||school:).
Note that multilevel modelling is allowed here.
If {opt pv()} is called without {opt pvreg()} the PVs for all observations within a group are generated with the same
normal prior distribution of ability with parameters taken from {cmd:e(group_par)}.
By including the {opt pvreg()} option the procedure of generating PVs is modified in such a way that after each MCMC step 
a regression of the ability on the variables provided by the user is performed by {cmd:xtmixed}. The {cmd:xtmixed}
model estimates are then used to recompute the priors.
Note that if some observations are excluded from {cmd:xtmixed} run (for example due to missing cases on any of the regressors)
these observations will not be conditioned.

{phang}
{opt thname(name)} specifies a suffix used in naming new EAP and PVs variables. Also influences naming of the x-axis in ICC graphs.


{dlgtab:Fixed and starting values}

{phang}
{opt fiximatrix(name)} keeps item parameters fixed at values stored in a Stata matrix.
The matrix with item parameters should be in the same form as {cmd:e(item_par)}.
If some item names are not found in {opt fiximatrix()} these items will be estimated.

{phang}
{opt initimatrix(name)} initializes item parameters at values stored in a Stata matrix.
The matrix with item parameters should be in the same form as {cmd:e(item_par)}.

{phang}
{opt initdmatrix(name)} initializes distribution parameters at values stored in a Stata matrix.
The matrix with distribution parameters should be in the same form as {cmd:e(group_par)}.
In a single group model it will make sense only together with {opt dist} option (otherwise distribution is fixed at m=0 and sd=1).


{dlgtab:EM control}

{phang}
{opt nip(#)} sets the number of Gauss-Hermite quadrature points used in EM algorithm. 
Default value is 51.

{phang}
{opt theta_nip(#)} sets the number of Gauss-Hermite quadrature points used when calculating EAP estimator of theta and its SE.
Default value is 195 which is an obvious overkill, but it does not consume much resources while
too low {opt theta_nip()} values may lead to inadequate estimate of standard errors of EAP.

{phang}
{opt nit(#)} sets the maximum number of iterations of EM algorithm.
Default value is 100.

{phang}
{opt ninrf(#)} sets the maximum number of iterations of Newton-Raphson-Fisher algorithm within M-step. 
Default value is 20. This option is rarely used.

{phang}
{opt crit_ll(#)} sets a stopping rule - relative change in log-likelihood between EM iterations.
Default value is 1e-9.

{phang}
{opt crit_par(#)} sets a stopping rule - maximum absolute change in parameter values between EM iterations.
Default value is 1e-4.

{phang}
{opt error(str)} is used to choose a method for computation of standard errors of estimated parameters. 
There are four methods available. Three methods (CDM,REM,SEM) are taking the approach of differentiation of the EM mapping
and one (CP) is based on Louis's (1982) cross-product approach. 
The methods will be briefly described in order of recommendation.
See Jamshidian & Jennrich (2000) for a general overview of these methods.
CDM (centered difference method) for numerical differentiation of EM mapping is the default option and is recommended for reporting standard errors.
CP (cross-product) by Louis's method is considerably faster but biased - use it when errors are of lesser importance and want to speed up the computation.
REM (Richardson extrapolation method) for differentiation of EM mapping is (unnecessarily) more precise that CDM, at cost of doubling the computational expense.
SEM (supplemented EM) for differentiation of EM mapping usually takes the most time and is unstable - not recommended, included for research purposes.

{phang}
{opt noupd_quad_betw_em} suppresses a speed-up of EM for the multi-group estimation.
By default the GH quadrature in {cmd:uirt} is updated within the EM cycle, just after iteration of group parameters is done.
This speeds-up the convergence of the algorithm but, in some cases, may lead to log-likelihood increase. 
Try using this option if you encounter such a problem in a muli-group model.


{dlgtab:Reporting}

{phang}
{opt notable} suppresses display of coefficient table.
Default coefficient table may be large and provides information which is often not useful in context of IRT analysis
(we are usually not interested if IRT parameters differ from 0). 
Parameters and their errors are accessible in a compact form in {cmd:e()} matrices
so you may wish not to see the default coefficient table at all. 

{phang}
{opt trace(#)} allows for controlling how log is printed after iterations.
0 - no log (except warnings); 1 - limited log (default option); 2 - detailed log.



{marker examples}{...}
{title:Examples}

{pstd}The simplest case (one group, 2PLM for 0-1 items, GRM for 0-k items, default settings){p_end}
{phang2}{cmd:. uirt item*} {p_end}

{pstd} 3PLM (3PLM for specified items, 2 attempts of estimating c parameter){p_end}
{phang2}{cmd:. uirt item*,gue(item1 item10-item20) att(2)} {p_end}

{pstd} multi-group analysis with reference group at gender==2 {p_end}
{phang2}{cmd:. uirt item*,gr(gender) ref(2)} {p_end}

{pstd} DIF analysis starting from previous estimates stored in prev_items and prev_dist matrices {p_end}
{phang2}{cmd:. uirt item*,gr(gender) ref(2) dif(item1-item20) initim(prev_items) initdm(prev_dist)} {p_end}

{pstd} Generating EAP estimates and 10 plausible values conditioned on school clustering and ses variable {p_end}
{phang2}{cmd:. uirt item*,theta pv(10) pvreg(ses ||school:)} {p_end}

{pstd} All above options combined together with plot of estimated ICCs against observed proportions, the PVs are not conditioned by external variables {p_end}
{phang2}{cmd:. uirt item*,gue(item1 item10-item20) att(2) gr(gender) ref(2) dif(item1-item20) theta thname(math) pv(10) icc} {p_end}


{marker results}{...}
{title:Stored results}

{syntab: {cmd: uirt} stores the following in e():}

{p2col 5 17 21 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(ll)}}log (restricted) likelihood{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(N_items)}}number of items in the model{p_end}
{synopt:{cmd:e(N_gr)}}number of groups in the model{p_end}
{synopt:{cmd:e(converged)}}1 if converged, 0 otherwise{p_end}

{p2col 5 17 21 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variables (items){p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(cmd)}}{cmd:uirt}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{p2col 5 17 21 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(item_par)}}estimated item parameters{p_end}
{synopt:{cmd:e(item_par_se)}}standard errors of estimated item parameters{p_end}
{synopt:{cmd:e(group_par)}}estimated group parameters{p_end}
{synopt:{cmd:e(group_par_se)}}standard errors of estimated group parameters{p_end}
{synopt:{cmd:e(group_ll)}}log likelihood by group{p_end}
{synopt:{cmd:e(group_N)}}number of observations by group{p_end}
{synopt:{cmd:e(item_group_N)}}number of observations for each item by group{p_end}
{synopt:{cmd:e(item_cats)}}item categories{p_end}
{synopt:{cmd:e(dif_results)}}LR test results and effect size measures after DIF analysis{p_end}
{synopt:{cmd:e(item_fit_chi2W)}}item-fit results for chi2W statistic{p_end}
{synopt:{cmd:e(item_fit_SX2)}}item-fit results for S-X2 statistic{p_end}


{title:Author}

Bartosz Kondratek
everythingthatcounts@gmail.com

{title:Acknowledgement}

{phang}
I wish to thank Cees Glas who provided me with invaluable consultancy on many parts of the estimation algorithms used in {cmd:uirt} 
and Mateusz Zoltak for very helpful hints on Mata pointers which led to significant boost in efficiency of {cmd:uirt}.
Many thanks to all of my colleagues at the Institute of Educational Research in Warsaw for using {cmd:uirt} at the early stages of its development
and providing me with feedback and encouragement to continue with this endeavor. I am also grateful to numerous Stata users 
who contacted me with ideas on how to improve the software after its first release.

{title:Funding}
Preparation of modules of {cmd:uirt} related to item-fit analysis was funded by the National Science Center research grant number 2015/17/N/HS6/02965.

{marker references}{...}
{title:References}

{phang}
Bock, R. D., Aitkin, M. 1981.
Marginal Maximum Likelihood Estimation of Item Parameters: Application of an EM algorithm.
{it:Psychometrika}, 46, 443{c -}459; 47, 369 (Errata)

{phang}
Dempster, A. P., Laird, N. M., Rubin, D. B. 1977. 
Maximum Likelihood from Incomplete Data via the EM Algorithm.
{it:Journal of the Royal Statistical Society}, Series B 39(1), 1{c -}38.

{phang}
Jamshidian, M., Jennrich, R.I. 2000.
Standard Errors for EM Estimation. 
{it:Journal of the Royal Statistical Society}, Series B, 62, 257{c -}270.

{phang}
Kondratek, B., 2020.
{it:Item-Fit Statistic Based on Posterior Probabilities of Membership in Ability Groups.}
Manuscript submitted for publication.

{phang}
Louis, T. A. 1982.
Finding the Observed Information Matrix When Using the EM Algorithm.
{it:Journal of the Royal Statistical Society}, Series B, 44, 226{c -}233.

{phang}
Orlando, M., & Thissen, D. 2000. 
Likelihood-based item-fit indices for dichotomous item response theory models.
{it:Applied Psychological Measurement}, 24, 50{c -}64.

{phang}
Patz, R. J., Junker, B. W. 1999.
A Straightforward Approach to Markov Chain Monte Carlo Methods for Item Response Models.
{it:Journal of Educational and Behavioral Statistics}, 24(2), 146{c -}178.

{phang}
Wainer, H. 1993.
Model-Based Standardized Measurement of an Item's Differential Impact. 
In: {it:Differential Item Functioning.}
ed. Holland, P. W. & Wainer, H., 123{c -}136.
Hillsdale: Lawrence Earlbaum.