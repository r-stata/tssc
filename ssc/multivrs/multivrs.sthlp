{smcl}
{* *! version 1.0.0 7jul2020}{...}
{title:Title}

{phang}{hi:MULTIVRS} {hline 2} Module to conduct multiverse analysis{p_end}

{title:Syntax}

{p 8 17 2}
{cmd:multivrs} {it:{help estimation_command}} {it:{help depvar}} {it:indepvar} {it:controlterm} [{it:controlterm ...}] 
{ifin} [{it:, options}] 

{pstd}
where {it:estimation_command} defines the estimation command to be executed.  The following
Stata commands are supported by {cmd:multivrs}:

{pmore}
{help regress}, {help logit}, {help logistic}, {help probit},
{help poisson}, {help nbreg}, {help areg}, {help rreg}, {help xtreg}

{pstd}
{it:indepvar} is the independent variable of interest.  All of the estimates reported by {cmd:multivrs} are performed
with respect to {it:indepvar}.

{title:Description}

{pstd}
{cmd: multivrs} allows users to conduct a ‘many worlds’ or multiverse analysis of modeling assumptions. 
Users specify a preferred model, as well as alternative estimation commands, control variables, variable coding, 
and standard error calculations that reflect different plausible assumptions. The model specification set is all possible combinations of these inputs. 
After estimating each specification, results are reported as a distribution of estimates. 

{pstd}
{cmd: multivrs} also conducts an analysis of which model ingredients are most influential for the results. 

{pstd}
{cmd: multivrs} can report marginal effects from nonlinear models, allow different treatments for missing data, 
and can weight the modeling distribution by different criteria of model fit.

{pstd}
{cmd:multivrs} depends upon the following packages: 

{pmore}{cmd:moremata} (Ben Jann, 2005. "MOREMATA: Stata module (Mata) to provide various functions," Statistical Software Components S455001, Boston College Department of Economics, revised 06 Dec 2020.)

{pmore}{cmd:valuesof} (Ben Jann, 2006. "VALUESOF: Stata module to return the contents of a variable in a macro," Statistical Software Components S456705, Boston College Department of Economics, revised 26 May 2008.)

{title:Options}

{dlgtab:Grouping and Either|Or}

{phang}{opt Grouping} is specified such that each {it:controlterm} is either {varname} or ({varlist}). A {it:varlist} in parentheses indicates that this group of variables is to be included or excluded together.
This is useful for categorical variables. {it:varlist} can be grouped with {it:indepvar} if {it:a priori} beliefs require {it:varlist} to be included as a control in {it:all} models.

{phang}{opt Either|Or} is specified such that a {it:varlist} in the form (d1|d2|...) treats  d1, d2. etc. as incompatible terms where both cannot be included in the same model.
This option can be used when there is uncertainty over the functional form of {it:varname} (x|x^2|ln(x)) or if there are highly collinear measures of the same latent variable.

{pstd}
Both {opt grouping} and {opt either|or} syntax can be specified for even more flexibility. For example, {it:((x1|x1^2) x2)} specifies that x1 and x1^2 will not be included in the same model but x2 will be included in all models with either.

{smcl}

{dlgtab:Functional Form Robustness}

{phang}{opt Either|Or} syntax can be used within {it:estimation_command} to pool results across different functional forms.
An {it:estimation_command} of the form (m1|m2|...) will generate pooled results from running multivrs
over each of the model types m1, m2, etc.  For example, for binary data one could use ({help reg} | {help logit} | {help probit}),
or for count data ({help reg} | {help poisson} | {help nbreg}).  Options specific to one functional form can be specified as (m1(m1_options)|m2(m2_options)|...).

{dlgtab:Special Regression Options}

{phang}{opt vce(vcetype)} specifies the standard error calculations.  {it:vcetype} may be {cmd:robust} or {cmd:cluster} {it:clustervar}.
See {help vce_option}.

{phang}{opt irr} displays the beta coefficients as incidence rate ratios for poisson or negative binomial regression models.

{phang}{opt exposure(varname)} corrects for unequal exposure times to {it:varname} for observations in poisson or negative binomial regression models; specifies that ln({it:varname}) be included in the model with coefficient constrained to 1 in the log-link function

{phang}{opt offset(varname)} specifies that {it:varname} be included in the poisson or negative binomial regression models with the coefficient constrained to be 1.

{phang}{opt absorb(varname)} for {help areg}, categorical variable to be absorbed. This option is required when areg is in the {it:estimation_command}.

{dlgtab:Other Estimation Options}

{phang}{opt margins} estimates average marginal effects (dydx) for the variable of interest, saves these estimates (and the associated standard errors and p-values)
rather than the regression coefficients, and summarizes and plots them.  See {help margins}.

{phang}{opt nolistwise} turns off the default listwise delete based on the full list of variables, and instead executes listwise delete for each model separately. 

{phang}{opt other(other_option)} permits any syntax allowed as an option for the estimation command. 

{dlgtab:Model Space}

{phang}{opt sample(percent)} randomly samples the given percentage of possible models.  Percent may be an integer 1-99.

{phang}{opt size(#)} constrains the number of covariates in the models according to one of the following specifications:

{synoptset 24}{...}
{synopthdr}
{synoptline}
{synopt:{opt size(#)}} exactly # control terms{p_end}
{synopt:{opt size(#min, #max)}} between #min and #max control terms inclusive {p_end}
{synopt:{opt size(#min, .)}} greater than or equal to #min control terms {p_end}
{synopt:{opt size(., #max)}} less than or equal to #max control terms {p_end}
{synoptline}
{p2colreset}{...}

{pstd} For example, for k = 25, specifying {opt size(4,8)} would reduce the model space from 33,554,432 to 1,805,155, specifying {opt size(.,7)} would reduce the model space to 726,206,
and specifying {opt size(7)} would reduce the model space to 480,700.

{dlgtab:Weighting of Estimates}

{phang}{opt weights(weight_type)} specifies the weighting method for summarizing the model results (i.e., calculating means and standard errors). 
The default is {it:uniform} which assigns
equal weight to each model.  Alternatively, {it:weight_type} may be {cmd:bic} for BIC weighting (an approximation to the posterior probabilities)
or {cmd:inf} for weighting by model influence, or {cmd:r2} for weighting by the R2. By default each of these 3 weights is saved in the results file.
If the {it:weight_type} is specified as {cmd:no} then no weights are calculated.

{dlgtab:Reporting}

{phang}{opt alpha(#)} sets # as the significance threshold.  Coefficients with p-value <= # are categorized as statistically significant.  Default alpha = .05.

{phang}{opt pref(estimate, SE)} plots the user's preferred estimate as a red line in the distribution of coefficients,
and calculates model robustness statistics with the SE associated with the preferred estimate.

{smcl}
{phang}{opt sig_only} suppresses the coefficient summary statistics to only report sign and significance statistics.
This option is often used along with the either|or syntax for {it:estimation_command} to pool results across different functional forms.
When sig_only is specified, the influence statistics are reported as marginal effect on probability of significant (or positive) coefficient.

{phang}{opt nosig} overrides the default switch to sig_only when different functional forms
are specified, allowing full standard output.

{phang}{opt noinfluence} suppresses the control variable influence statistics.

{phang} {opt inf_means} for each control variable considered, displays the mean coefficient estimate 
from all models including that variable, in addition to the standard influence statistics. 

{phang}{opt normal} overlays a normal distribution on the graph of the empirical modeling distribution.

{phang}{opt nozero} relaxes the default constraint that the graph includes zero.

{phang}{opt noplot} suppresses the plot of the coefficient of interest.

{dlgtab:Saved Results}

{phang}{opt saveas(file_name)} saves the model results in file_name.dta, and the list of estimated models in file_name.do.  Default is for no results to be saved. 
The .dta file contains coefficient estimates for the variable of interest from each of the models run. The .do file provides an easy way to see which models the program ran. 

{phang}{opt replace} permits {opt saveas} to overwrite existing file_name.dta and/or file_name.do.

{smcl}
{dlgtab:Advanced}

{phang}{opt bs(bs_type)} performs resampling of the data or estimate to generate a sampling distribution of size B = 50
for the parameter of interest for each of the J models.  These B*J bootstrapped estimates are saved in the results file, composing the
total sampling+modeling distribution, which is used to calculate the total SE and the robustness intervals.
{it:bs_type} may be {cmd:par} (parametric) or {cmd:nonpar} (nonparametric).

{pmore}
When {it:bs_type} = {cmd:par}, the B estimates for each model come from the normal distribution with
mean = point estimate of the parameter of interest for that model and se = SE of the point estimate.
{pmore}
When {it:bs_type} = {cmd:nonpar(}{it:bs_options}{cmd:)}, Stata's {help bootstrap} command is executed on each model,
resampling the actual data points and re-estimating the model B times to generate B parameter estimates.  {it:bs_options}
are available to accomodate data-specific resampling requirements such as strata({help varlist}) or cluster({help varlist})), and
are passed in directly to {help bootstrap} on each iteration.

{smcl}
{phang}{opt intervals} prints the modeling distribution 95% confidence interval cut points and extreme bounds,
and 95% and parametric intervals for the full bootstrapped sampling+modeling distribution.
If {opt bs(bs_type)} is not specified,
the total distribution is generated by the parametric bootstrap.

{title:{ul:Examples: Basic}}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse nlsw88}{p_end}

{pstd}Use OLS{p_end}
{phang2}{cmd:. multivrs regress union hours age grade collgrad married south smsa c_city ttl_exp tenure}{p_end}

{pstd}Use logit model{p_end}
{phang2}{cmd:. multivrs logit union hours age grade collgrad married south smsa c_city ttl_exp tenure}{p_end}

{pstd}Use either|or syntax to assess functional form robustness{p_end}
{phang2}{cmd:. multivrs (logit|probit|regress) union hours age grade collgrad married south smsa c_city ttl_exp tenure}

{pstd}Treat the two education variables (highest grade completed, and dummy for college graduation) as a single term{p_end}
{phang2}{cmd:. multivrs logit union hours age (grade collgrad) married south smsa c_city ttl_exp tenure}
	
{pstd}Keep age and tenure as covariates in every model, along with the variable of interest (hours){p_end}
{phang2}{cmd:. multivrs logit union (hours age tenure) grade collgrad married south smsa c_city ttl_exp}
	
{title:{ul:Examples: Special Regression Options}}

{pstd}Use robust standard errors{p_end}
{phang2}{cmd:. multivrs regress union hours age grade collgrad married south smsa c_city ttl_exp tenure, vce(robust)}{p_end}

{pstd}Convert {cmd: poisson} or {cmd: nbreg} coefficients to incidence rate ratios{p_end}
{phang2}{cmd:. multivrs poisson tenure union hours age grade south smsa c_city ttl_exp, irr}{p_end}

{pstd}Correct for unequal exposure times measured by the variable ttl_exp{p_end}
{phang2}{cmd:. multivrs poisson tenure union hours age grade south smsa c_city, exposure(ttl_exp)}{p_end}

{title:{ul:Examples: Other Estimation Options}}

{pstd}Estimate and plot marginal effects to directly compare effects across different functional forms{p_end}
{phang2}{cmd:. multivrs (logit|probit|regress) union hours age grade smsa c_city ttl_exp tenure, margins}
	
{pstd}Execute listwise delete separately within each model, which allows the sample size to vary across models{p_end}
{phang2}{cmd:. multivrs regress wage age hours union grade smsa c_city ttl_exp tenure, nolistwise}
	
{pstd}For {cmd: rreg}, specify a biweight tuning parameter of 9{p_end}
{phang2}{cmd:. multivrs rreg wage age hours union grade smsa c_city ttl_exp tenure, other(tune(9))}
	
{title:{ul:Examples: Weighting of Estimates}}

{pstd}Weight each estimate using BIC weights{p_end}
{phang2}{cmd:. multivrs regress union hours south smsa c_city ttl_exp tenure, weights(bic)}{p_end}

{pstd}Weight each estimate by the R2 value of its model{p_end}
{phang2}{cmd:. multivrs regress union hours south smsa c_city ttl_exp tenure, weights(r2)}{p_end}

{pstd}Weight each estimate by the absolute value of its influence regression coefficient{p_end}
{phang2}{cmd:. multivrs regress union hours south smsa c_city ttl_exp tenure, weights(inf)}{p_end}
	
{title:{ul:Examples: Model Space}}

{pstd}Sample 50 percent of the possible models (usually used for very long lists of control variables){p_end}
{phang2}{cmd:. multivrs regress union hours age grade collgrad married south smsa c_city ttl_exp tenure, sample(50)}{p_end}

{pstd}Restrict the model space to models with exactly 4 total covariates{p_end}
{phang2}{cmd:. multivrs regress union hours age grade collgrad married south smsa c_city ttl_exp tenure, size(4)}{p_end}

{pstd}Restrict the model space to models with at least 4 total covariates{p_end}
{phang2}{cmd:. multivrs regress union hours age grade collgrad married south smsa c_city ttl_exp tenure, size(4, .)}{p_end}

{pstd}Restrict the model space to models with no more than 4 total covariates{p_end}
{phang2}{cmd:. multivrs regress union hours age grade collgrad married south smsa c_city ttl_exp tenure, size(., 4)}{p_end}

{title:{ul:Examples: Reporting}}

{pstd}Set the alpha (significance threshold) to 0.1 rather than the default 0.05{p_end}
{phang2}{cmd:. multivrs regress wage age hours union grade smsa c_city ttl_exp tenure, alpha(0.1)}{p_end}

{pstd}Overlay a normal distribution on the plot{p_end}
{phang2}{cmd:. multivrs regress wage age hours union grade smsa c_city ttl_exp tenure, normal}{p_end}

{pstd}Compare multiverse results to a preferred estimate (0.003) and SE (0.001) {p_end}
{phang2}{cmd:. multivrs regress union hours age grade collgrad married south smsa c_city ttl_exp tenure, pref(0.003 0.001)}{p_end}

{pstd}Replay results of significance testing broken down by functional form{p_end}
{phang2}{cmd:. multivrs, more}{p_end}

{pstd}Replay full results including coefficient summary statistics (regardless of prior sig_only specification){p_end}
{phang2}{cmd:. multivrs, full}{p_end}

{title:{ul:Examples: Multiple Options}}

{pstd}Use logit model, robust standard errors, and 50 percent sampling{p_end}
{phang2}{cmd:. multivrs logit union hours age grade collgrad married south smsa c_city ttl_exp tenure, vce(robust) sample(50)}{p_end}

{pstd}Use either logit or regress, estimate marginal effects, and use BIC weights{p_end}
{phang2}{cmd:. multivrs (logit|regress) union hours age grade collgrad ttl_exp tenure, margins weights(bic)}{p_end}

{pstd}Restrict to models with at least 3 independent variables and execute listwise delete separately for each model{p_end}
{phang2}{cmd:. multivrs regress wage age hours union grade smsa c_city ttl_exp tenure, size(3,.) nolistwise}{p_end}

{title:Saved results}

{pstd}
{cmd:multivrs} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(Nmin)}}minimum number of observations across all models (equal to {cmd:r(N)} under the default listwise delete){p_end}
{synopt:{cmd:r(Nmax)}}maximum number of observations across all models (equal to {cmd:r(N)} under the default listwise delete){p_end}
{synopt:{cmd:r(nvars)}}number of independent variables{p_end}
{synopt:{cmd:r(nterms)}}number of grouped control terms{p_end}
{synopt:{cmd:r(nmodels)}}number of models calculated{p_end}
{synopt:{cmd:r(meanr2)}}simple average of the R-squared values of the models{p_end}
{synopt:{cmd:r(meanb)}}simple average of the estimates{p_end}
{synopt:{cmd:r(samplingSE)}}mean of the standard errors for the estimates{p_end}
{synopt:{cmd:r(modelingSE)}}standard deviation of the estimates{p_end}
{synopt:{cmd:r(totalSE)}}standard error of the sampling+modeling distribution{p_end}
{synopt:{cmd:r(rratio)}}mean estimate divided by total standard error{p_end}
{synopt:{cmd:r(skewness)}}skew of the distribution of estimates{p_end}
{synopt:{cmd:r(kurtosis)}}kurtosis of the distribution of estimates{p_end}
{synopt:{cmd:r(extremeUB)}}maximum of the modeling distribution{p_end}
{synopt:{cmd:r(extremeLB)}}minimum of the modeling distribution{p_end}
{synopt:{cmd:r(modeling95UB)}}upper bound for 95% interval (97.5 percentile) for modeling distribution{p_end}
{synopt:{cmd:r(modeling95LB)}}lower bound for 95% interval (2.5 percentile) for modeling distribution{p_end}
{synopt:{cmd:r(total95UB)}}upper bound for 95% interval (97.5 percentile) for sampling+modeling distribution{p_end}
{synopt:{cmd:r(total95LB)}}lower bound for 95% interval (2.5 percentile) for sampling+modeling distribution{p_end}
{synopt:{cmd:r(totalParUB)}}upper bound for parametric interval for sampling + modeling distribution (meanb + 2*totalSE){p_end}
{synopt:{cmd:r(totalParLB)}}lower bound for parametric interval for sampling + modeling distribution (meanb - 2*totalSE){p_end}
{synopt:{cmd:r(sdintvar)}}standard deviation of the variable of interest (the observations of the variable, not its modeling distribution){p_end}
{synopt:{cmd:r(mc)}}multicollinearity of variable of interest{p_end}
{synopt:{cmd:r(prefb)}}preferred estimate{p_end}
{synopt:{cmd:r(prefse)}}preferred sampling standard error{p_end}
{synopt:{cmd:r(preftotalse)}}standard error of the sampling+modeling distribution using prefse as the sampling standard error{p_end}
{synopt:{cmd:r(prefpctile)}}percentile of modeling distribution for preferred estimate{p_end}
{synopt:{cmd:r(prefUB)}}upper bound for parametric interval centered on preferred estimate (prefb + 2*preftotalSE) {p_end}
{synopt:{cmd:r(prefLB)}}lower bound for parametric interval centered on preferred estimate (prefb - 2*preftotalSE) {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}multivrs{p_end}
{synopt:{cmd:r(model)}}estimation command(s) specified{p_end}
{synopt:{cmd:r(modeli_name)}}the ith estimation command specified{p_end}
{synopt:{cmd:r(modeli_opts)}}options specified for the ith estimation command{p_end}
{synopt:{cmd:r(depvar)}}name of the outcome variable(s){p_end}
{synopt:{cmd:r(varint)}}name of the interest variable(s){p_end}
{synopt:{cmd:r(title)}}type(s) of regression model{p_end}
{synopt:{cmd:r(opts_multivrs)}}multivrs options specified{p_end}
{synopt:{cmd:r(opts_command)}}options specified to pass in to every estimation command{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(infstats_sig)}}influence statistics for sign and significance{p_end}
{synopt:{cmd:r(infstats_coef)}}influence statistics for value of estimate{p_end}
{synopt:{cmd:r(sigrates)}}significance and sign rates{p_end}

{phang} Additional items not listed here may appear among the saved results.
These results are recorded for use by the {cmd:multivrs} program in case the user chooses to replay the results of the command.

{title:Authors}

{phang}Cristobal Young (Cornell University) and Katherine Holsteen (Stanford University){p_end}
{phang}cristobal.young@cornell.edu{p_end}
