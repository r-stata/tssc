{smcl}
{* *! version 1.0.1  // A METTRE}{...}
{cmd:help tslstarmod}
{hline}

{title:Title}

{pstd}
    {hi: Performs an Estimation of a Logistic Smooth Transition Autoregressive Regression (LSTAR) Model for Time Series Data}



{title:Syntax}

{p 8 17 2}
{cmd:tslstarmod}
{depvar}
{indepvars}
{ifin}
[{cmd:,} {it:options}]



{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt: {opth thresv(varname)}}indicates the threshold variable{p_end}
{synopt: {opth const:raints(estimation options##constraints():constraints)}}apply specified linear constraints{p_end}
{synopt :{opth exp:osure(varname:varname_e)}}include ln({it:varname_e}) in model with coefficient constrained to 1{p_end}
{synopt :{opth off:set(varname:varname_o)}}include {it:varname_o} in model with coefficient constrained to 1{p_end}
{synopt :{opt nocons:tant}}suppress constant term{p_end}
{synopt: {cmd:nolrtest}}report the model Wald test{p_end}
{synopt :{opt init}}specify the computation of the internal initial values{p_end}

{syntab:Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt ef:orm}}report exponentiated coefficients {p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt r:obust}, or {opt opg}{p_end}
{synopt :{opth cl:uster(varname)}}adjust standard errors for intragroup correlation; implies {cmd:vce(robust)}{p_end}

{syntab:Max options}
{synopt :{it:{help maximize:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:tslstarmod}; see {helpb tsset}.{p_end}
{p 4 6 2}
{depvar}, {indepvars} and {opth thresv(varname)} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{cmd:by} is allowed with {hi:tslstarmod}; see {manhelp by D} for more details on {cmd:by}.{p_end}



{title:Description}

{pstd}
{cmd:tslstarmod} performs an estimation of a logistic smooth transition autoregressive regression (LSTAR) model 
for time series data. This command allows estimating an endogenous structural break point in a time series  
data. The endogenous threshold when found is determined smoothly, contrarily to brutal transitions. In  
this regard, the LSTAR model can be considered as a generalization of the usual autoregressive  
process because the transition function is a smooth logistic function. The command allows to  
test the presence of an LSTAR model against a presence of a linear autoregressive model. It  
also handles the determination of the delay parameter. The theory behind the command {cmd:tslstarmod}  
can be found, for instance, in Terasvirta (2004) and Enders (2015).



{title:Econometric Model}

{p 4 6 2}  The estimated econometric model can be written as: {p_end}

{p 4 6 2}  {it:y_t = alpha_0 + alpha_1*y_{t-1} + ... + alpha_p*y_{t-p} + theta*[beta_0 + beta_1*y_{t-1} + ... + beta_p*y_{t-p}] + epsilon_t}   (1) {p_end}

{p 4 6 2}  where {p_end}

{p 4 6 2}  {it:t = 1,...,T} is the time; {p_end}

{p 4 6 2}  {it:y_t} in equation (1), are the time series of interest; {p_end}

{p 4 6 2}  {it:alpha_i, i = 1,...,p} are autoregressive coefficients in the first regime; {p_end}

{p 4 6 2}  {it: beta_i, i = 1,...,p} are autoregressive coefficients in the second regime; {p_end}

{p 4 6 2}  {it:p} specifies the order of the autoregressive process; {p_end}

{p 4 6 2}  {it:epsilon_t} is the error term; {p_end}

{p 4 6 2}  {it:theta = [1 + exp(-gamma*(y_{t-d} - cpar))]^(-1)}   (2); {p_end}

{p 4 6 2}  {it:theta} in equation (2), is the first order logistic function which varies between 0 and 1; {p_end}

{p 4 6 2}  The functional form and the boundedness of {it:theta} make that the estimation becomes a smooth transition between the two 
regimes dynamically rather than a brutal jump from one regime to the other as the value of {it:y_{t-d}} changes; {p_end}

{p 4 6 2}  {it:gamma} indicates the smoothness parameter; {p_end}

{p 4 6 2}  {it:y_{t-d}} specifies the threshold or transition variable; {p_end}

{p 4 6 2}  {it:d} represents the delay parameter; {p_end}

{p 4 6 2}  {it:cpar} designates the threshold parameter; {p_end}



{title:Options}

{dlgtab:Model}

{phang}
{opth thresv(varname)} indicates the threshold variable. To form this option,
you put inside the brackets the variable name representing the threshold variable.
You must specify this option in order to get a result. Hence this option is required.

{phang}
{opth const:raints(estimation options##constraints():constraints)},
{opth exp:osure(varname:varname_e)},
{opth off:set(varname:varname_o)}, and
{opt nocons:tant};
see {help estimation options}.

{phang}
{cmd:nolrtest} indicates that the model significance test should be a Wald
test instead of a likelihood-ratio test.

{phang}
{opt init} specifies the computation of the internal initial values. If you want 
to calculate the initial values, you indicate this, by issuing the option {opt init}. Then 
the command internally computes these initial values for you.

{dlgtab:Reporting}

{phang}
{opt level(#)}; set confidence level; default is {cmd:level(95)}.

{phang}
{opt eform} specifies that the coefficient table be
displayed in exponentiated form.

{dlgtab:SE/Robust}

{phang}
{opth vce(vcetype)}; {it:vcetype} may be {opt oim}, observed information matrix (OIM);
{opt r:obust}, Huber/White/sandwich estimator; or {opt opg}, outer product of the gradient
(OPG) vectors. see {it:{help vce_option}} for more details.

{phang}
{opth cluster(varname)}; adjust standard errors for intragroup correlation; implies {cmd:vce(robust)}.

{dlgtab:Max options}

{phang}
{it:maximize_options}:
{opt dif:ficult},
{opt tech:nique(algorithm_spec)},
{opt iter:ate(#)},
[{cmdab:no:}]{opt lo:g},
{opt tr:ace},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance};
see {manhelp maximize R}.
These options are seldom used.



{title:Syntax for predict}

{phang}
The syntax for predict after the command {cmd:tslstarmod} is:

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:Options_for_predict}]



{title:Options for {help predict}}

{phang}
{cmd:xb}, the default, calculates the prediction from all the equations taken together in equation (1) above. It 
computes: {hi:alpha_0_hat + alpha_1_hat*y_{t-1} + ... + alpha_p_hat*y_{t-p} + theta_hat*[beta_0_hat + beta_1_hat*y_{t-1} + ... + beta_p_hat*y_{t-p}]}.

{phang}
{cmd:lngamma}, calculates the prediction of {it:ln(gamma)} in equation (2) above. It computes: {hi:ln(gamma_hat)}.

{phang}
{cmd:cpar}, calculates the prediction of {it:cpar} in equation (2) above. It computes: {hi:cpar_hat}. 

{phang}
{cmd:lnsigma}, calculates the prediction of {it:ln(sigma)} where {it:sigma} is the standard error of the regression. It computes: {hi:ln(sigma_hat)}.

{phang}
{cmd:gamma}, calculates the prediction of {it:gamma} in equation (2) above. It computes: {hi:gamma_hat}.

{phang}
{cmd:sigma}, calculates the prediction of {it:sigma} where {it:sigma} is the standard error of the regression. It computes: {hi:sigma_hat}.

{phang}
{cmd:stdp} calculates the standard error of the prediction.

{phang}
{cmd:regime1}, calculates the prediction from the {it:Regime1} equation only in equation (1) above. It computes: {hi:alpha_0_hat + alpha_1_hat*y_{t-1} + ... + alpha_p_hat*y_{t-p}}.

{phang}
{cmd:regime2}, calculates the prediction from the {it:Regime2} equation only in equation (1) above. It computes: {hi:beta_0_hat + beta_1_hat*y_{t-1} + ... + beta_p_hat*y_{t-p}}.

{phang}
{cmd:residuals}, calculates the residuals from all the equations taken together in equation (1) above. It 
computes: {hi:epsilon_t_hat = y_t - (alpha_0_hat + alpha_1_hat*y_{t-1} + ... + alpha_p_hat*y_{t-p} + theta_hat*[beta_0_hat + beta_1_hat*y_{t-1} + ... + beta_p_hat*y_{t-p}])}.

{phang}
{cmd:theta}, calculates the prediction of {it:theta} in equation (2) above. It computes: {hi:theta_hat}.



{title:Syntax for tslstarmodtest}

{phang}
This command allows to test for the presence of an LSTAR model against a presence of a linear autoregressive model. It also 
handles the determination of the delay parameter. 

{p 8 17 2}
{cmd:tslstarmodtest}
{depvar}
{indepvars}
{ifin}
{cmd:,} {it:options_for_tslstarmodtest}



{title:Options for tslstarmodtest}

{phang}
{opth thresv(varname)} indicates the threshold variable. To form this option,
you put inside the brackets the variable name representing the threshold variable.
You must specify this option in order to get a result. Hence this option is required.

{phang}
{opt maxlags(integer)} represents the maximum number of lags you indicated for the independent variables. To form 
this option, you put inside the brackets, the maximum number of lags you indicated for the independent 
variables, {indepvars}, you specified for this command. That is, if you specified the command 
as: {hi:tslstarmodtest D.wpi L(1/3)D.wpi, thresv(LD.wpi)},  you must choose {hi:3} for the {opt maxlags(integer)} option 
to get a final result of: {hi:tslstarmodtest D.wpi L(1/3)D.wpi, thresv(LD.wpi) maxlags(3)}. This, because you 
chose {hi:3} lags of the first difference of the variable {hi:wpi} as your independent variables. You must specify 
this option in order to get a result. Hence this option is required.



{title:Return values for tslstarmod}

{pstd}
{cmd:tslstarmod} saves the following in {cmd:e()}. Note that these saved results are almost the same as those
returned by the command {manhelp maximize R} since {cmd:tslstarmod} is fitted using {manhelp ml R}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations; always saved{p_end}
{synopt:{cmd:e(k)}}number of parameters; always saved{p_end}
{synopt:{cmd:e(k_eq)}}number of equations; usually saved{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations to include in a model Wald
                 test; usually saved{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables; usually saved{p_end}
{synopt:{cmd:e(k_autoCns)}}number of base, empty, and omitted constraints; saved if command supports constra
> ints{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom; always saved{p_end}
{synopt:{cmd:e(r2_p)}}pseudo-R-squared; sometimes saved{p_end}
{synopt:{cmd:e(ll)}}log likelihood; always saved{p_end}
{synopt:{cmd:e(ll_0)}}log likelihood, constant-only model; saved when
        constant-only model is fit{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters; saved when {cmd:vce(cluster}
        {it:clustvar}{cmd:)} is specified;
        see {findalias frrobust}{p_end}
{synopt:{cmd:e(chi2)}}chi-squared; usually saved{p_end}
{synopt:{cmd:e(p)}}significance of model of test; usually saved{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}; always saved{p_end}
{synopt:{cmd:e(rank0)}}rank of {cmd:e(V)} for constant-only model; saved
        when constant-only model is fit{p_end}
{synopt:{cmd:e(ic)}}number of iterations; usually saved{p_end}
{synopt:{cmd:e(rc)}}return code; usually saved{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise; usually saved{p_end}
{synopt:{cmd:e(k_aux)}}number of ancillary parameters; always saved{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}name of command; always saved{p_end}
{synopt:{cmd:e(cmdline)}}command as typed; always saved{p_end}
{synopt:{cmd:e(depvar)}}names of dependent variables; always saved{p_end}
{synopt:{cmd:e(wtype)}}weight type; saved when weights are specified or
        implied{p_end}
{synopt:{cmd:e(wexp)}}weight expression; saved when weights are specified or
        implied{p_end}
{synopt:{cmd:e(title)}}title in estimation output; usually saved by commands using {cmd:ml}{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable; saved when
        {cmd:vce(cluster} {it:clustvar}{cmd:)} is specified;
        see {findalias frrobust}{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:Wald} or {cmd:LR}; type of model chi-squared
        test; usually saved{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}; saved when command
        allows {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.; sometimes saved{p_end}
{synopt:{cmd:e(opt)}}type of optimization; always saved{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                         maximization or minimization; always saved{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method; always saved by commands
using {cmd:ml}{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program; always saved{p_end}
{synopt:{cmd:e(technique)}}from {cmd:technique()} option; sometimes saved{p_end}
{synopt:{cmd:e(singularHmethod)}}{cmd:m-marquardt} or {cmd:hybrid}; method used
                          when Hessian is singular; sometimes saved{p_end}
{synopt:{cmd:e(crittype)}}optimization criterion; always saved{p_end}
{synopt:{cmd:e(properties)}}estimator properties; always saved{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}; usually
        saved{p_end}
{synopt:{cmd:e(thresva)}}threshold variable; always saved{p_end}		

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector; always saved{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix; sometimes saved{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations); usually saved{p_end}
{synopt:{cmd:e(gradient)}}gradient vector; usually saved{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators; always
        saved{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance; only saved when {cmd:e(V)}
        is neither the OIM nor OPG variance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample; always saved{p_end}



{title:Return values for tslstarmodtest}

{pstd}
{cmd:tslstarmodtest} saves the following in {cmd:r()}:

{col 4}Scalars
{col 8}{cmd:r(df)}{col 27}degrees of freedom
{col 8}{cmd:r(chi2_p)}{col 27}p-value of the chi-squared statistic
{col 8}{cmd:r(chi2)}{col 27}Chi-squared statistic



{marker remarks1}{...}
{title:Examples}

{p 4 8 2} Before beginning the estimations, we use the {hi:set more off} instruction to tell
{hi:Stata} not to pause when displaying the output. {p_end}

{p 4 8 2}{stata "set more off"}{p_end}

{p 4 8 2} We illustrate the use of the command {cmd:tslstarmod} with the {hi:Stata} manual dataset {hi:wpi1}. {p_end}

{p 4 8 2}{stata "use http://www.stata-press.com/data/r15/wpi1, clear"}{p_end}

{p 4 8 2} We regress the dependent variable ({hi:D.wpi}; here the first difference of {hi:wpi}) on the regressors ({hi:LD.wpi}; 
here the lagged value of the first difference of {hi:wpi}). We specify the threshold variable ({hi:LD.wpi}) in the 
required option {hi: thresv()}. {p_end}

{p 4 8 2}{stata "tslstarmod D.wpi LD.wpi, thresv(LD.wpi)"}{p_end}

{p 4 8 2} Having done that, let us now turn to the explanation of the output of the previous estimation. The table of results 
is divided into four parts: the first part shows the word {hi:Regime1} which specifies the coefficients for the first 
regime. They represent the {hi:alpha_i} in equation {hi:(1)}. Since we have one regressor ({hi:LD.wpi}), we get two coefficients 
in this part of the table if we take the constant term into account. The second part displays the word {hi:Regime2} which 
indicates the coefficients for the second regime. They indicate the {hi:beta_i} in equation {hi:(1)}. Since we have one 
regressor ({hi:LD.wpi}), we get two coefficients in this part of the table if we take the constant term into account. The third 
part displays the parameters {hi:/lngamma}, {hi:/cpar} and {hi:/lnsigma}. They designate the parameters 
{hi:ln(gamma_hat)}, {hi:cpar_hat} and {hi:ln(sigma_hat)} respectively as indicated in equation {hi:(2)} and explained in the 
section {hi:Options for predict}. The fourth part displays the parameters {hi:gamma} and {hi:sigma}. They specify the 
parameters {hi:gamma_hat} and {hi:sigma_hat} respectively as indicated in equation {hi:(2)} and explained in the section 
{hi:Options for predict}.

{p 4 8 2} We illustrate the use of the {opt technique()} option by putting inside the brackets the name {hi:dfp}, which stands 
for the Davidon-Fletcher-Powell (DFP) algorithm. {p_end}

{p 4 8 2}{stata "tslstarmod D.wpi LD.wpi, thresv(LD.wpi) technique(dfp)"}{p_end}

{p 4 8 2} In the next regression, we demonstrate how to compute the robust or sandwich estimator of variance. {p_end}

{p 4 8 2}{stata "tslstarmod D.wpi LD.wpi, thresv(LD.wpi) vce(robust)"}{p_end}

{p 4 8 2} We augment the number of regressors to two, and in addition to the {opt technique(dfp)} option, we specify 
the {opt difficult} option and set the tolerances to 0.05, because the likelihood function becomes harder to maximize. {p_end}

{p 4 8 2}{stata "tslstarmod D.wpi LD.wpi L2D.wpi, thresv(LD.wpi) technique(dfp) difficult tolerance(0.05) ltolerance(0.05) nrtolerance(0.05) vce(robust)"}{p_end}

{p 4 8 2} Now, we increase the number of regressors to three. {p_end}

{p 4 8 2}{stata "tslstarmod D.wpi LD.wpi L2D.wpi L3D.wpi, thresv(LD.wpi) technique(dfp) difficult tolerance(0.05) ltolerance(0.05) nrtolerance(0.05) vce(robust)"}{p_end}

{p 4 8 2} If we do not want to display the iterations log at the beginning of the regression, we type. {p_end}

{p 4 8 2}{stata "tslstarmod D.wpi LD.wpi, thresv(LD.wpi) vce(robust) nolog"}{p_end}

{p 4 8 2} If we want to specify the computation of the internal initial values, we type. {p_end}

{p 4 8 2}{stata "tslstarmod D.wpi LD.wpi, thresv(LD.wpi) vce(robust) init"}{p_end}

{p 4 8 2} Note that specifying the {opt init} option, could in some cases, help us 
to maximize the likelihood function quickly when we are having convergence problems. {p_end}

{p 4 8 2} We now illustrate how to use the command {cmd:tslstarmod} with {bf:{help predict}}. {p_end}

{p 4 8 2} We calculate the prediction of {it:ln(gamma)}. {p_end}

{p 4 8 2}{stata "predict double lngammapred, lngamma"}{p_end}

{p 4 8 2} We calculate the prediction of {it:cpar}. {p_end}

{p 4 8 2}{stata "predict double cparpred, cpar"}{p_end}

{p 4 8 2} We calculate the prediction of {it:ln(sigma)}. {p_end}

{p 4 8 2}{stata "predict double lnsigmapred, lnsigma"}{p_end}

{p 4 8 2} We calculate the prediction of {it:gamma}. {p_end}

{p 4 8 2}{stata "predict double gammapred, gamma"}{p_end}

{p 4 8 2} We calculate the prediction of {it:sigma}. {p_end}

{p 4 8 2}{stata "predict double sigmapred, sigma"}{p_end}

{p 4 8 2} We calculate the prediction from the {it:Regime1} equation only. {p_end}

{p 4 8 2}{stata "predict double regime1pred, regime1"}{p_end}

{p 4 8 2} We calculate the prediction from the {it:Regime2} equation only. {p_end}

{p 4 8 2}{stata "predict double regime2pred, regime2"}{p_end}

{p 4 8 2} We calculate the prediction from all the equations taken together. {p_end}

{p 4 8 2}{stata "predict double xballpred, xb"}{p_end}

{p 4 8 2} We calculate the residuals from all the equations taken together. {p_end}

{p 4 8 2}{stata "predict double residualspred, residuals"}{p_end}

{p 4 8 2} We calculate the prediction of {it:theta}. {p_end}

{p 4 8 2}{stata "predict double thetapred, theta"}{p_end}

{p 4 8 2} We calculate the standard error of the prediction. {p_end}

{p 4 8 2}{stata "predict double stdppred, stdp"}{p_end}

{p 4 8 2} We describe all the previously created variables to see their labels. {p_end}

{p 4 8 2}{stata "describe lngammapred cparpred lnsigmapred gammapred sigmapred regime1pred regime2pred xballpred residualspred thetapred stdppred"}{p_end}

{p 4 8 2} We summarize these variables. {p_end}

{p 4 8 2}{stata "summarize lngammapred cparpred lnsigmapred gammapred sigmapred regime1pred regime2pred xballpred residualspred thetapred stdppred"}{p_end}

{p 4 8 2} Now, we perform the test for the presence of an LSTAR model. Suppose that we have found that the best lag order for 
our autoregressive process is {hi:p = 2}. Hence, in our case here, we form our test by choosing {hi:2} lags of the first 
difference of the variable {hi:wpi} as our independent variables ({hi:L(1/2)D.wpi}). We specify the first lag of the 
first difference of {hi:wpi} as our threshold variable ({hi:thresv(LD.wpi)}). We indicate {hi:2} for the {opt maxlags()} option 
because you chose {hi:2} lags of the first difference of the variable {hi:wpi} as our independent variables. Thus, we 
specify {hi: maxlags(2)} to obtain a final result of: {p_end}

{p 4 8 2}{stata "tslstarmodtest D.wpi L(1/2)D.wpi, thresv(LD.wpi) maxlags(2)"}{p_end}

{p 4 8 2} The p-value of the Lagrange Multiplier Test result illustrates that we reject the null hypothesis of the Presence 
of Linearity at the 5% statistical significance level. Hence, there is a Presence of an LSTAR Model. {p_end}

{p 4 8 2} Next, we run the same test with {hi:L2D.wpi} as our threshold variable. {p_end}

{p 4 8 2}{stata "tslstarmodtest D.wpi L(1/2)D.wpi, thresv(L2D.wpi) maxlags(2)"}{p_end}

{p 4 8 2} We see that we cannot reject the null hypothesis of the Presence of Linearity for this test. {p_end}

{p 4 8 2} We run the same test with {hi:L3D.wpi} as our threshold variable. {p_end}

{p 4 8 2}{stata "tslstarmodtest D.wpi L(1/2)D.wpi, thresv(L3D.wpi) maxlags(2)"}{p_end}

{p 4 8 2} Here also, we see that we cannot reject the null hypothesis of the Presence of Linearity for this test. {p_end}

{p 4 8 2} From these last three tests, we find that the delay parameter {hi:d = 1} and that we have a Presence of an LSTAR 
Model. Hence, the best test is the following: {hi:tslstarmodtest D.wpi L(1/2)D.wpi, thresv(LD.wpi) maxlags(2)}. This, because 
this test gives the smallest and most significant p-value for the test. This p-value also provides the greatest power 
for the test. We reproduce this best test next for convenience. {p_end}

{p 4 8 2}{stata "tslstarmodtest D.wpi L(1/2)D.wpi, thresv(LD.wpi) maxlags(2)"}{p_end}



{title:References}

{pstd}
{hi:Enders, Walter: 2015,} {it:Applied Econometric Time Series}, Fourth Edition, Wiley, Wiley Series in Probability and Statistics.
{p_end}

{pstd}
{hi:Terasvirta, Timo: 2004,} {it:Smooth Transition Regression Modeling}, in {it:Applied Time Series Econometrics}, edited by 
{hi:Lutkepohl, Helmut and Kratzig, Markus}, pp. 222-242, Cambridge University Press, Themes in Modern Econometrics.
{p_end}
 


{title:Author}

{p 4}Diallo Ibrahima Amadou {p_end}
{p 4}CERDI, University of Clermont Auvergne {p_end}
{p 4}26 Avenue Leon Blum  {p_end}
{p 4}63000 Clermont-Ferrand   {p_end}
{p 4}France {p_end}
{p 4}{hi:E-Mail}: {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online:  help for {bf:{manhelp arima TS}}, {bf:{manhelp mswitch TS}}, {bf:{manhelp ml R}}, {manhelp maximize R}
{p_end}


