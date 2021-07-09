{smcl}
{* Sep 10, 2019}{...}
{cmd:help cqiv}
{hline}

{title:Title}

{p 4 8 2}
{bf:Censored quantile instrumental variable (regression)}


{title:Syntax}

{p 8 17 2}
{cmdab:cqiv} {depvar} [{it:varlist}] {cmd:(}{it:endogvar} {cmd:=} {it:instrument}{cmd:)} {ifin} {weight} [{cmd:,} {it:options}]


{synoptset 25 tabbed}{...}
{synopthdr :options}
{synoptline}

{syntab:Model}
{synopt:{opt q:uantiles(numlist)}}sets the quantile(s) (values between 0 to 100) at which the model is estimated.{p_end}
{synopt:{opt c:ensorpt(#)}}fixed censoring point of the dependent variable; default is 0.{p_end}
{synopt:{opt censorvar(varname)}}random censoring variable of the dependent variable.{p_end}
{synopt:{opt t:op}}right censoring of the dependent variable; otherwise, left censoring as default.{p_end}
{synopt:{opt u:ncensored}}uncensored quantile IV (QIV) estimation.{p_end}
{synopt:{opt e:xogenous}}censored quantile regression (CQR) with no endogeneity.{p_end}
{synopt:{opt f:irststage(string)}}determine the first stage estimation procedure, where {it:string} is
  {opt quantile} (default),
  {opt distribution},
  {opt ols}.{p_end}
{synopt:{opt firstvar(varlist)}specifies the list of variables other than instruments that are included in the first stage estimation.{p_end}
{synopt:{opt nquant(#)}}determines the number of quantiles used in the first stage estimation when the estimation procedure is {opt quantile};
 default is 50; it is advisable to choose a value between 20 to 100.{p_end}
{synopt:{opt nthresh(#)}}determines the number of thresholds used in the first stage estimation when the estimation procedure is {opt distribution};
 default is 50; it is advisable to choose a value between 20 up to the value of the sample size.{p_end}
{synopt:{opt ldv1(string)}}determines the limited dependent variable (LDV) model used in the first stage estimation when the estimation procedure is {opt distribution}, where {it:string} is
{opt probit} (default),
{opt logit}.{p_end}
{synopt:{opt ldv2(string)}}determines the LDV model used in the first step of the second stage estimation, where {it:string} is
{opt probit} (default),
{opt logit}.{p_end}

{syntab:CQIV estimation}
{synopt:{opt cor:ner}}calculates the (average) marginal quantile effects for censored dependent variable when the censoring is due to
 economic reasons such are corner solutions; only applicable to linear models.{p_end}
{synopt:{opt drop1(#)}}sets the proportion of observations {it:q0} with probabilities of censoring above the quantile index that are dropped in the first step
 of the second stage (See Chernozhukov, Fernandez-Val and Kowalski (2010) for details); default is 10.{p_end}
{synopt:{opt drop2(#)}}sets the proportion of observations {it:q1} with estimate of the conditional quantile above (below for right censoring) that are dropped
 in the second step of the second stage (See Chernozhukov, Fernandez-Val and Kowalski (2010) for details); default is 3.{p_end}
{synopt:{opt viewl:og}}shows the intermediate estimation results; default is no log.{p_end}

{syntab:Inference}
{synopt:{opt co:nfidence(string)}}type of confidence intervals, where {it:string} is
  {opt no} (no confidence intervals, the default),
  {opt boot},
  {opt weightboot}.{p_end}
{synopt:{opt clu:ster(string)}} implements a cluster bootstrap procedure for clustered data when {cmd:confidence(weightboot)} is selected, with {it:string} specifying the variable that defines the group or cluster.{p_end}
{synopt:{opt b:ootreps(#)}}number of repetition of bootstrap or weighted bootstrap; default is 100.{p_end}
{synopt:{opt s:etseed(#)}}initial seed number in repetition of bootstrap or weighted bootstrap; default is 777.{p_end}
{synopt:{opt le:vel(#)}}sets confidence level; default is 95.{p_end}

{syntab:Robustness check}
{synopt:{opt no:robust}}suppresses the robustness diagnostic test results.{p_end}
{synoptline}
{p2colreset}{...}

{phang}{cmd:cqiv} allows {cmd:weight}s, {cmd:aweight}s and {cmd:pweight}s; see {help weight}. No matter which weights are specified by the users,
 note that {cmd:pweight} is automatically forced for the probit or logit estimation in the procedure, and {cmd:aweight} for the quantile regression estimation.
 When {cmd:confidence(weightboot)} is implemented the multiplication of the bootstrap weights and the user-specified weights is used as the weights
  in the bootstrap procedure.{p_end}
 
{phang}{cmd:break} command pressed in the middle of the execution may not restore the original dataset.{p_end}


{title:Description}

{p 4 4 2}
{cmd:cqiv} conducts censored quantile instrumental variable (CQIV) estimation. 
This command can implement both censored and uncensored quantile IV estimation either under exogeneity or endogeneity. 
The estimator proposed by Chernozhukov, Fernandez-Val and Kowalski (2010) is used if CQIV estimation is implemented. A parametric version of the estimator proposed by Lee (2007) is used if quantile IV estimation without censoring is implemented. 
The estimator proposed by Chernozhukov and Hong (2002) is used if censored quantile regression (CQR) is estimated without endogeneity.
Note that all the variables in the parentheses of the syntax are those involved in the first stage estimation of CQIV and QIV.


{title:Options}

{dlgtab:Model}

{phang}
{opt quantiles(numlist)} specifies the quantiles at which the model is 
estimated and should contain percentage numbers between 0 and 100. 
Note that this is not the list of quantiles for the first stage estimation with quantile specification. 

{phang}
{opt censorpt(#)} specifies the censoring point of the dependent variable, where the default is 0; inappropriately specified censoring point will generate errors in estimation.

{phang}
{opt censorvar(varname)} specifies the censoring variable (i.e., the random censoring point) of the dependent variable.

{phang}
{opt top} sets right censoring of the dependent variable; otherwise, left censoring is assumed as default.

{phang}
{opt uncensored} selects uncensored quantile IV (QIV) estimation.

{phang}
{opt exogenous} selects censored quantile regression (CQR) with no endogeneity, which is proposed by Chernozhukov and Hong (2002).

{phang}
{opt firststage(string)} determines the first stage estimation procedure, where {it:string} is either
 {opt quantile} for quantile regression (the default), {opt distribution} for distribution regression (either probit or logit), or
 {opt ols} for ols estimation. Note that {cmd:firststage(distribution)} can take a considerable amount of time to execute.

{phang}
{opt firstvar(varlist)} specifies the list of variables other than instruments that are included in the first stage estimation; default is all the variables that are included in the second stage estimation.
 
{phang}
{opt nquant(#)} determines the number of quantiles used in the first stage estimation when the estimation procedure is {opt quantile};
 default is 50, that is, total 50 evenly-spaced quantiles are chosen in the estimation; it is advisable to choose a value between 20 to 100.

{phang}
 {opt nthresh(#)} determines the number of thresholds used in the first stage estimation when the estimation procedure is {opt distribution};
 default is 50, that is, total 50 evenly-spaced thresholds are chosen in the estimation;
 it is advisable to choose a value between 20 and the value of the sample size;
 when the value is smaller than this range, the estimation may be subject to multicollinearity.
 
{phang}
{opt ldv1(string)} determines the LDV model used in the first stage estimation when the estimation procedure is {opt distribution}, where {it:string} is either
 {opt probit} for probit estimation (the default), or {opt logit} for logit estimation.

{phang}
{opt ldv2(string)} determines the LDV model used in the first step of the second stage estimation, where {it:string} is either
 {opt probit} (the default), or {opt logit}.
  

{dlgtab:CQIV estimation}

{phang}
{opt corner} calculates the (average) marginal quantile effects for censored dependent variable when the censoring is due to
 economic reasons such are corner solutions. Under this option, the reported coefficients are the average corner solution marginal effects
 if the underlying function is linear in the endogenous variable. For each observation, if the predicted value of depvar is beyond the censoring point,
 the marginal effect is set to zero; otherwise, it is set to the coefficient. The reported average corner solution marginal effect
 averages the marginal effects over all observations. If the underlying function is nonlinear in the endogenous variable,
 average marginal effects must be calculated directly from the coefficients without {opt corner} option. For details of the related concepts,
 see Section 2.1 of Chernozhukov, Fernandez-Val and Kowalski (2010). The relevant example can be found in the examples section of this help file.

{phang}
{opt drop1(#)} sets the proportion of observations {it:q0} with probabilities of censoring above the quantile index that are dropped in the first step
 of the second stage (See Chernozhukov, Fernandez-Val and Kowalski (2010) for details); default is 10.
 
{phang}
{opt drop2(#)} sets the proportion of observations {it:q1} with estimate of the conditional quantile above (below for right censoring) that are dropped
 in the second step of the second stage (See Chernozhukov, Fernandez-Val and Kowalski (2010) for details); default is 3.

{phang}
{opt viewlog} shows the intermediate estimation results; the default is no log.


{dlgtab:Inference}

{phang}
{opt confidence(string)} specifies the type of confidence intervals. With {it:string} being
 {opt no}, which is the default, no confidence intervals are calculated. With {it:string} being {opt b:oot} or {opt w:eightedboot},
either nonparametric bootstrap or weighted bootstrap (respectively) t-percentile symmetric confidence intervals are calculated. The weights of the weighted bootstrap
 are generated from the standard exponential distribution. Note that {cmd:confidence(boot)} and {cmd:confidence(weightboot)}
 can take a considerable amount of time to execute.

{phang}
{opt bootreps(#)} sets the number of repetitions of bootstrap or weighted bootstrap if the {cmd:confidence(boot)} or {cmd:confidence(weightboot)}
is selected. The default number of repetitions is 100.

{phang}
{opt setseed(#)} sets the initial seed number in repetition of bootstrap or weighted bootstrap; the default is 777.

{phang}
{opt level(#)} sets confidence level, and default is 95.


{dlgtab:Robustness check}

{phang}
{opt norobust} suppresses the robustness diagnostic test results.  No diagnostic test results to suppress when {cmd:uncensored} is employed.


{title:Saved results}

{phang}{cmd:cqiv} saves the following results in {cmd:e()}:

{phang}Scalars{p_end}
{col 10}{cmd:e(obs)}{col 25}Number of observations
{col 10}{cmd:e(censorpt)}{col 25}Censoring point
{col 10}{cmd:e(drop1)}{col 25}{it:q0}
{col 10}{cmd:e(drop2)}{col 25}{it:q1}
{col 10}{cmd:e(bootreps)}{col 25}Number of bootstrap or weighted bootstrap repetitions
{col 10}{cmd:e(level)}{col 25}Significance level of confidence interval

{phang}Macros{p_end}
{col 10}{cmd:e(command)}{col 25}Name of the command: cqiv
{col 10}{cmd:e(regression)}{col 25}Name of the implemented regression: either cqiv, qiv, or cqr
{col 10}{cmd:e(depvar)}{col 25}Name of the dependent variable
{col 10}{cmd:e(endogvar)}{col 25}Name of the endogenous regressor
{col 10}{cmd:e(instrument)}{col 25}Names of the instrumental variables
{col 10}{cmd:e(censorvar)}{col 25}Name of the censoring variable
{col 10}{cmd:e(regressors)}{col 25}Names of the regressors
{col 10}{cmd:e(firststage)}{col 25}Type of the first stage estimation
{col 10}{cmd:e(confidence)}{col 25}Type of confidence intervals

{phang}Matrices{p_end}
{col 10}{cmd:e(results)}{col 25}Matrix containing the estimated coefficients, means, standard errors, and lower and upper bounds of confidence intervals.
{col 10}{cmd:e(quantiles)}{col 25}Row vector containing the quantiles at which CQIV have been estimated.
{col 10}{cmd:e(robustcheck)}{col 25}Matrix containing the results for the robustness diagnostic test results. (See Table B1 of Chernozhukov, Fernandez-Val and Kowalski (2010).)
{col 10}Note that the entry {it:complete} denotes whether all the steps are included in the procedure; 1 when they are, and 0 otherwise. For other entries consult the paper.

{title:Examples}

{phang}{cmd:. ssc describe cqiv} {space 13} (This line will show the dataset as accessible via the next line of the command.){p_end}
{phang}{cmd:. net get cqiv}
{p_end}
{phang}{cmd:. use alcoholengel.dta} {space 29} (This line will download {cmd:alcoholengel.dta} to the current working directory; See Blundell, Chen and Kristensen (2007) for data descriptions.)
{p_end}
{phang}{cmd:. cqiv alcohol logexp2 nkids (logexp = logwages nkids), quantiles(25 50 75)} {space 1} (This generates part of the empirical results of Chernozhukov, Fernandez-Val and Kowalski (2010).)

{phang}
{cmd:. cqiv alcohol logexp2 (logexp = logwages), quantiles(20 25 70(5)90) firststage(ols)}

{phang}
{cmd:. cqiv alcohol (logexp = logwages), firststage(distribution) ldv1(logit)}

{phang}
{cmd:. cqiv alcohol logexp2 nkids (logexp = logwages nkids), uncensored} {space 3} (to run QIV)

{phang}
{cmd:. cqiv alcohol logexp logexp2 nkids, exogenous} {space 23} (to run CQR)

{phang}
{cmd:. cqiv alcohol logexp2 nkids (logexp = logwages nkids), confidence(weightboot) bootreps(10)}

{phang}
{cmd:. cqiv alcohol nkids (logexp = logwages nkids), corner} {space 7}


{title:Version requirements}

{p 4 4 2}This command requires Stata 10 or upper. 


{title:Methods and Formulas}

{p 4 6} See Chernozhukov, Fernandez-Val and Kowalski (2010).


{title:References}

{p 4 6} Blundell, Chen and Kristensen (2007): Semi-nonparametric IV Estimation of Shape-Invariant Engel Curves, Econometrica, 75(6), 1613-1669.

{p 4 6} Chernozhukov, Fernandez-Val and Kowalski (2015): Quantile Regression with Censoring and Endogeneity, Journal of Econometrics, 186(1), 201-221.

{p 4 6} Chernozhukov and Hong (2002): Three-Step Censored Quantile Regression and Extramarital Affairs, Journal of the American Statistical Association, 97, 872-882.

{p 4 6} Kowalski (2016): Censored Quantile Instrumental Variable Estimates of the Price Elasticity of Expenditure on Medical Care, Journal of Business & Economic Statistics, 34(1), 107-117.
 
{p 4 6} Lee (2007): Endogeneity in Quantile Regression Models: A Control Function Approach, Journal of Econometrics, 141, 1131-1158.


{title:Remarks}

{p 4 4}This is a preliminary version. Please feel free to share your comments, reports of bugs and
propositions for extensions. We thank Richard Blundell for sharing the data used in the examples above. 
The data were derived by Richard Blundell from the 1995 U.K. Family Expenditure Survey (FES), 
following the criteria set forth in Blundell, Chen and Kristensen (2007).


{title:Disclaimer}

{p 4 4 2}THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. 
SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

{p 4 4 2}IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY OTHER PARTY WHO
MAY MODIFY AND/OR REDISTRIBUTE THIS SOFTWARE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY 
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM.


{title:Authors}

{p 4 6}Victor Chernozhukov, Ivan Fernandez-Val, Sukjin Han, and Amanda Kowalski{p_end}
{p 4 6}MIT, Boston University, UT Austin, and University of Michigan{p_end}
{p 4 6}vchern@mit.edu / ivanf@bu.edu / sukjin.han@austin.utexas.edu / aekowals@umich.edu{p_end}
{p 4 6}Latest Version: April 2019 / First Version: December 2010{p_end}

