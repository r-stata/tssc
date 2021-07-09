{smcl}
{* *! version 1.1  21dec2016}{...}

{title:Title}

{pstd}
{manlink MI mi impute wlogit} {hline 2} Weighted multiple imputation for binary variables using logistic regression

{marker syntax}{...}
{title:Syntax}

{p 8 19 2}{cmd:mi} {cmdab:imp:ute} {cmd:wlogit} 
{it:ivar} [{it:{help indepvars}}] {cmd:,} {opt md(varname)}
[{it:{help mi_impute_wlogit##options_table:options}}]

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt: {it:impute_options}}any option of {helpb mi_impute##impopts:mi impute} except {cmd:noupdate} and {cmd:by()}.{p_end}
{p2coldent :* {opt md(varname)}}specify variable containing the marginal distribution of {it:ivar}.{p_end}
{synopt: {opt marginal}}use marginal weights in weighted multiple imputation; default is conditional weights.{p_end}
{synoptline}

{p 4 6 2}
* {opt md(varname)} is required.{p_end}
{p 4 6 2}
The data must be {cmd:mi set} before using {cmd:mi impute wlogit};
see {manhelp mi_set MI:mi set}.{p_end}
{p 4 6 2}
{it:ivar} must be {cmd:mi register} as imputed before using {cmd:mi impute wlogit}; see {manhelp mi_set MI:mi set}.{p_end}
{p 4 6 2}
{it:indepvars} may not contain {help factor_variables:factor variables}; dummy variables for {it:indepvars} must be created prior to using {cmd:mi impute wlogit}.

{marker menu}{...}
{title:Menu}

{phang}
{bf:Statistics > Multiple imputation}

{marker description}{...}
{title:Description}

{dlgtab:Population-calibrated inference for incomplete binary/categorical variables via weighted multiple imputation}

{pstd}
{cmd:mi} {cmd:impute} {cmd:wlogit} fills in missing values of a binary variable
{it:ivar} by using a weighted logistic regression imputation method, where weights are calculated 
using the population-level marginal distribution of {it:ivar}. 

{pstd}
For some variables in certain datasets, their corresponding marginal distributions in the population 
can be obtained from external data sources (e.g., population surveys or censuses). If our study samples 
in truth come from such a population, the population information can be fed into the imputation model 
to calibrate inference to the population. In weighted multiple imputation, the population distribution 
of {it:ivar} can be used to calculate probability weights, which are then used in multiple imputation 
such that the post-imputation distribution matches the population level.

{dlgtab:Imputaion procedure}

{pstd}
In the imputation step, marginal/conditional weights calculated using the population marginal distribution of {it:ivar} 
are attached to the complete cases, and a logistic regression model is fitted to the weighted complete 
cases to obtain the maximum likelihood estimates of imputation model parameters {it:theta} and 
their asymptotic sampling variance {it:U}. New parameters are then drawn from the large-sample 
approximation N({it:theta}, {it:U}) to its posterior distribution assuming non-informative priors. 
Finally, imputed values are simulated from the logistic regression using these newly drawn parameters. 

{dlgtab:Derivation of marginal and conditional weights}

{pstd}
Let the dataset of size {it:N} contain {it:n_obs} subjects with observed {it:ivar} and {it:n_mis} subjects with
missing {it:ivar}. The first set of weights is termed {it:marginal weights}, which only depend on the population 
distribution of {it:ivar}. For each category {it:j} of {it:ivar}, the proportion of this category required 
in the imputed data is calculated as {it:p_imp = (p_pop*N - p_obs*n_obs)/n_mis}, where {it:p_pop} and {it:p_obs} 
denote the proportions of category {it:j} in the population and observed in the dataset, respectively. 
Marginal weight for subjects with observed values of {it:ivar} in category {it:j} is therefore given by 
{it:w_m = 1/(p_obs/p_imp)}. 

{pstd}
If there are covariates {it:indepvars} in the imputation model, their associations with {it:ivar} are not
reflected in marginal weights. Alternatively, weights can be calculated such that they account for the 
effects of covariates in the imputation model. These weights are termed {it:conditional weights}, and can be derived 
using the distribution of {it:ivar} obtained after estimating parameters of an imputation model 
assuming MAR using the complete cases. Suppose the estimated proportion of category {it:j} of 
{it:ivar} in the complete data after fitting a MAR imputation model to the complete cases is {it:p_j}, 
then the proportion of this category required in the imputed data is given by {it:p_imp = (p_pop*N - p_j*n_obs)/n_mis}, 
which implies that the conditional weight for this group is given by {it:w_c = 1/(p_j/p_imp)}.

{marker options}{...}
{title:Options}

{phang}
{it:impute_options} include {cmd:add()}, {cmd:replace}, {cmd:rseed()},
{cmd:double}, {cmd:dots}, {cmd:noisily}, {cmd:nolegend}, {cmd:force}; see
{manhelp mi_impute MI:mi impute} for details.

{phang}
{opt md(varname)} specifies the variable containing the marginal distribution of {it:ivar}, which is used to derive marginal/conditional weights in weighted multiple imputation.

{phang}
{opt marginal} specifies that weighted multiple imputation is performed using marginal weights; conditional weights are used by default when {opt marginal} is not stated.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:mi} {cmd:impute} {cmd:wlogit} works by calling the {help uvis:uvis} (univariate imputation 
sampling) command, which imputes missing values in the single variable {it: ivar} based 
on multiple regression on {it: indepvars}. 

{pstd}
{cmd:mi} {cmd:impute} {cmd:wlogit} requires Stata version 14.1 and the {help uvis:ice} command from SSC.

{pstd}
Option {opt replace} currently works only with {help mi_styles:mi styles} {cmd:wide}; data must be {help mi_set:mi set} before using {cmd:mi impute wlogit}.

{pstd}
{it:indepvars} may not contain {help factor_variables:factor variables}; dummy variables for {it:indepvars} must be created prior to using {cmd:mi impute wlogit}.

{marker example}{...}
{title:Example}

{pstd}
Generate full data of binary covariate X and binary outcome Y{p_end}
{phang2}
{cmd:. set seed 715209}
{p_end}
{phang2}
{cmd:. clear}
{p_end}
{phang2}
{cmd:. set obs 100000}
{p_end}
{phang2}
{cmd:. local beta0 = ln(0.5)}
{p_end}
{phang2}
{cmd:. local betax = ln(1.5)}
{p_end}
{phang2}
{cmd:. gen byte x = rbinomial(1, 0.7)}
{p_end}
{phang2}
{cmd:. gen byte y = runiform() < invlogit(`beta0' + `betax'*x)}
{p_end}

{pstd}
Fit the model of interest to full data{p_end}
{phang2}
{cmd:. logit y x}
{p_end}

{pstd}
Population marginal distribution of X is assumed to be the same as full-data distribution{p_end}
{phang2}
{cmd:. gen mdx = 0.7 if x} 
{p_end}
{phang2}
{cmd:. replace mdx = 0.3 if !x}
{p_end}

{pstd}
Generate missing data in X such that X is MNAR conditional on X and Y{p_end}
{phang2}
{cmd:. local phi0 = -0.75}
{p_end}
{phang2}
{cmd:. local phix = -1.5}
{p_end}
{phang2}
{cmd:. local phiy = -1}
{p_end}
{phang2}
{cmd:. gen byte x_mnar = x if runiform() >= invlogit(`phi0' + `phix'*x + `phiy'*y)}
{p_end}

{pstd}
Fit the model of interest to the complete cases{p_end}
{phang2}
{cmd:. logit y x_mnar}
{p_end}

{pstd}
Declare data and register {cmd:x_mnar} as imputed{p_end}
{phang2}
{cmd:. mi set wide}
{p_end}
{phang2}
{cmd:. mi register imputed x_mnar}
{p_end}
{phang2}
{cmd:. mi register regular y}
{p_end}

{pstd}
Impute {cmd:x_mnar} using weighted multiple imputation with marginal weights
{p_end}
{phang2}
{cmd:. mi impute wlogit x_mnar y, md(mdx) marginal add(10) noi dots}
{p_end}

{pstd}
Impute {cmd:x_mnar} using weighted multiple imputation with conditional weights
{p_end}
{phang2}
{cmd:. mi impute wlogit x_mnar y, md(mdx) replace}
{p_end}

{pstd}
Fit the model of interest to each imputed dataset and combine results using Rubin's rules
{p_end}
{phang2}
{cmd:. mi estimate, or: logit y x_mnar}
{p_end}

{pstd}
Check if the post-imputation distribution of {cmd:x_mnar} matches the population level
{p_end}
{phang2}
{cmd:. mi estimate: proportion x_mnar}
{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mi impute wlogit} stores the following in {cmd:r()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:r(negw)}}1 if negative weight is detected; 0 otherwise{p_end}
{synopt:{cmd:r(M)}}total number of imputations{p_end}
{synopt:{cmd:r(M_add)}}number of added imputations{p_end}
{synopt:{cmd:r(M_update)}}number of updated imputations{p_end}
{synopt:{cmd:r(k_ivars)}}number of imputed variables{p_end}
{synopt:{cmd:r(N_g)}}number of imputed groups{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(wtype)}}type of imputation weights used{p_end}
{synopt:{cmd:r(method)}}name of imputation method ({cmd:wlogit}){p_end}
{synopt:{cmd:r(ivars)}}names of imputation variables{p_end}
{synopt:{cmd:r(rngstate)}}random-number state used{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(pwmi)}}imputation weights by categories of {it:ivar}{p_end}
{synopt:{cmd:r(N)}}number of observations in imputation sample{p_end}
{synopt:{cmd:r(N_complete)}}number of complete observations in imputation sample{p_end}
{synopt:{cmd:r(N_incomplete)}}number of incomplete observations in imputation sample{p_end}
{synopt:{cmd:r(N_imputed)}}number of imputed observations in imputation sample{p_end}

{title:Author}

{pstd}
Tra My Pham, University College London, London UK.{break}
tra.pham.09@ucl.ac.uk

{title:Acknowledgement}

{pstd}
I would like to thank Tim Morris for his suggestions to improve this command.

{title:References}

{phang}
Royston P. 2004. Multiple imputation of missing values.  Stata Journal 4(3):227-241.

{title:Also see}

{helpb mi impute}
{helpb mi impute logit}
{helpb mi impute wmlogit}
{helpb mi estimate}

