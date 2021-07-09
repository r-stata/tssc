{smcl}
{* *! version 1.0.0  12dec2011}{...}
{cmd:help igencox}{right:also see:  {helpb igencox_postestimation:igencox postestimation}}
{right:{helpb stcox}}
{right:{helpb streg}}
{hline}


{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{cmd:igencox} {hline 2}}Generalized Cox model{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:igencox} [{varlist}] {ifin} [{cmd:,}
{it:options}] 

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt trans:form(trans [#])}}transformation function; default is {cmd:transform(boxcox 1)}{p_end}
{synopt :{bf:baseq(}{it:{help newvar:newvarname}}{bf:)}}save jump sizes of the Lambda function in {it:newvarname}{p_end}
{synopt :{bf:{ul:savesi}gma(}{it:filename} [{bf:, replace}]{bf:)}}save Sigma matrix to {it:filename}{p_end}

{syntab:SE/Robust}
{synopt :{cmd:vce(bootstrap, }{it:{help bootstrap:bootstrap_options}}{cmd:)}}
use a bootstrap to estimate the variance-covariance matrix{p_end}

{syntab:Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt nosh:ow}}do not show st setting information{p_end}
{synopt :{it:{help stcox##display_options:display_options}}}control
INCLUDE help shortdes-displayoptall
INCLUDE help shortdes-coeflegend

{syntab:EM}
{synopt :{opt iter:ate(#)}}perform maximum # of iterations; defalut is {cmd:iterate(1000)}{p_end}
{synopt :{opt tol:erance(#)}}specify tolerance for the coefficient vector; default is {cmd:tolerance(1e-6)}{p_end}
{synopt :{opt nolog}}supress the iteration log{p_end}
{synopt :{opt from(init_specs)}}specify initial values for the coefficients{p_end}

{syntab:Advanced}
{synopt :{opt savesp:ace}}conserve memory during estimation{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stcox}; see
{manhelp stset ST}.{p_end}
{p 4 6 2}
{it:varlist} may contain factor variables; see {help fvvarlist}.
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:igencox} fits, via the EM algorithm, transformation models for failure
time data (Zeng and Lin 2006, 2007).  The transformation models considered are

        {it:Lambda(t|Z) = G{Lambda(t)*e^(beta'*Z)}}

{pstd}
where {it:G()} is a known transformation function and {it:Lambda(t)} is an
unknown increasing function with {it:Lambda(0)=0}.  The available
transformations include the class of Box-Cox transformations,
BoxCox({it:rho}):

        {it:G(x) = {(1+x)^rho - 1}/rho}, {it:rho>=0}

{pstd}
and the class of logarithmic transformations, Logarithmic({it:r}):

        {it:G(x) = {log(1+r*x)}/r}, {it:r>=0}

{pstd}
Special cases of these transformation models correspond to proportional
hazards models (Cox 1972) and proportional odds models (Bennett 1983).
Specifically, BoxCox(1) and Logarithmic(0) reduce to the proportional hazards
model, and BoxCox(0) and Logarithmic(1) reduce to the proportional odds model.

{pstd}
The {cmd:igencox} command allows you to fit more flexible survival models with
non-proportional hazards.  Logarithmic transformation models assume that
covariate effects always decrease over time for any {it:r} whereas Box-Cox
models allow covariate effects to increase over time when {it:rho}>1.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt transform(trans [#])} specifies the transformation function {it:G()} of
the cumulative hazard function {it:Lambda(t|Z)}.  {it:trans} can be 
{opt box:cox} (default) or {opt log:arithmic}.  The optional {it:#} specifies
the value of the transformation parameter {it:rho} for the Box-Cox
transformation and {it:r} for the logarithmic transformation.  By default,
{it:#} is set to 1.

{pmore}
{bf:transform(boxcox 1)} or {bf:transform(logarithmic 0)} corresponds to a
proportional hazards model.
{bf:transform(boxcox 0)} or {bind:{bf:transform(logarithmic 1)}} corresponds
to a proportional odds model.

{phang}
{opt baseq(newvarname)} saves the jump sizes of the {it:Lambda(t)} function in
the new variable {it:newvarname}.  This option is required for later
prediction of the survivor or cumulative hazard functions using {cmd:predict}.

{phang}
{bf:savesigma(}{it:filename} [{bf:, replace}]{bf:)} saves the
{it:(N_f+q)x(N_f+q)} matrix Sigma to {it:filename} in the current directory,
where {it:N_f} is the number of failed observations and {it:q} is the number of
coefficients.  This matrix is required by {bf:predict} for calculating the
standard errors of the survivor function.  {bf:replace} specifies that the file
may be replaced if it already exists.

{dlgtab:SE/Robust}

{phang}
{cmd:vce(bootstrap, }{it:{help bootstrap:bootstrap_options}}{cmd:)} uses a
bootstrap to compute the variance-covariance matrix.  {it:bootstrap_options}
allow you to control the bootstrap process.  The most commonly used
{it:bootstrap_options} is {opt reps(#)}, which controls the number of
replications performed.  The default is {cmd:reps(50)}.

{dlgtab: Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{cmd:noshow} prevents {cmd:igencox} from showing the key st variables.  This
option is seldom used because most people type {cmd:stset, show} or
{cmd:stset, noshow} to set whether they want to see these variables mentioned
at the top of the output of every st command; see {manhelp stset ST}.

{marker display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels},
{opth cformat(%fmt)},
{opt pformat(%fmt)},
{opt sformat(%fmt)}, and
{opt nolstretch};
   see {helpb estimation options##display_options:[R] estimation options}.

{phang}
{opt coeflegend}; see
     {helpb estimation options##coeflegend:[R] estimation options}.

{marker EM}{...}
{dlgtab:EM}
 
{phang}
{opt iter:ate(#)} specifies the maximum number of iterations.  The default is
{bf:iterate(1000)}.

{phang}
{opt tol:erance(#)} specifies the tolerance for the coefficient vector.  The
delault is {cmd:tolerance(1e-6)}.

{phang}
{opt nolog} supresses the iteration log.

{phang}
{opt from(matname)} specifies initial values for the coefficients.
{cmd:from(b0)} causes {cmd:igencox} to begin the optimization algorithm with the
values in {cmd:b0}.  {cmd:b0} must be a row vector, and the number of columns
must be equal to the number of parameters in the model.

{marker Advanced}{...}
{dlgtab:Advanced}

{phang}
{opt savespace} conserves memory during estimation and turns off the calculaton
of the covariance matrix.  If the covariance matrix is desired, it should be
obtained by specifying {cmd:vce(bootstrap)}.


{marker examples}{...}
{title:Examples}

{title:Example of a proportional hazards model}

{pstd}Setup{p_end}
{phang2}{cmd:. use va, clear}{p_end}

{pstd}Show st settings{p_end}
{phang2}{cmd:. stset}{p_end}

{pstd}Fit Cox proportional hazards model{p_end}
{phang2}{cmd:. igencox status type1 type2 type3}{p_end}

{phang2}or, equivalently,{p_end} 
{phang2}{cmd:. igencox status type1 type2 type3, transform(boxcox 1)}{p_end}

{pstd}Replay results with 90% confidence intervals{p_end}
{phang2}{cmd:. igencox, level(90)}{p_end}


{title:Example of a proportional odds model}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse cancer, clear}{p_end}

{pstd}Map values for {bf:drug} into 0 for placebo and 1 for nonplacebo{p_end}
{phang2}{cmd:. replace drug = drug == 2 | drug == 3}

{pstd}Declare data to be survival-time data{p_end}
{phang2}{cmd:. stset studytime, failure(died)}{p_end}

{pstd}Fit a proportional odds model{p_end}
{phang2}{cmd:. igencox drug age, transform(log)}{p_end}

{phang2}or, equivalently,{p_end} 
{phang2}{cmd:. igencox drug age, transform(logarithmic 1)}{p_end}


{title:Saving the jump sizes of Lambda and the Sigma matrix}

{pstd}Setup{p_end}
{phang2}{cmd:. use va, clear}{p_end}

{pstd}Fit Cox proportional hazards model and save jump sizes and Sigma{p_end}
{phang2}{cmd:. igencox status type1 type2 type3, baseq(bq) savesigma(sigma)}{p_end}


{title:{help igencox_postestimation##survivor:Compute estimates of the survivor function and its standard errors}}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:igencox} saves the following in {cmd:e()}:

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_sub)}}number of subjects{p_end}
{synopt:{cmd:e(N_fail)}}number of failures{p_end}
{synopt:{cmd:e(risk)}}total time at risk{p_end}
{synopt:{cmd:e(ties)}}{cmd:1} if there are ties in sample, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in model Wald test{p_end}
{synopt:{cmd:e(d_fm)}}model degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(chi2)}}chi-squared statistic{p_end}
{synopt:{cmd:e(p)}}significance{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(rho)}}transformation parameter{p_end}
{synopt:{cmd:e(iter)}}number of iterations{p_end}
{synopt:{cmd:e(crit)}}convergence criterion{p_end}
{synopt:{cmd:e(tol)}}tolerance for the coefficient vector{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:igencox}{p_end}
{synopt:{cmd:e(depvar)}}{cmd:_t}{p_end}
{synopt:{cmd:e(covariates)}}list of covariates{p_end}
{synopt:{cmd:e(t0)}}{cmd:_t0}{p_end}
{synopt:{cmd:e(transformation)}}transformation used{p_end}
{synopt:{cmd:e(chi2type)}}type of model chi-squared test{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(baseq)}}name of variable specified in {cmd:baseq()}{p_end}
{synopt:{cmd:e(sigma)}}filename specified in {cmd:savesigma()}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the coefficient estimates{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Acknowledgments}

{pstd}
This work was supported by the NIH Phase I SBIR contract “Software for
Modern Extensions of the Cox Model” (HHSN261201000090C) to StataCorp LP.


{title:References}

{phang}Bennett, S. 1983. Analysis of survival data by the proportional odds model.
{it: Statist. Med.}, 2, 273-277.

{phang}Cox, D. R. 1972. Regression models and life-tables (with discussion).
{it: J. R. Statist. Soc. B}, 34, 187-220.

{phang}Zeng, D. and Lin, D. Y. 2006. Efficient estimation of semiparametric
transformation models for counting processes.  {it: Biometrika}, 93, 627-640.

{phang}Zeng, D. and Lin, D. Y. 2007. Maximum likelihood estimation in
semiparametric regression models with censored data (with discussion).
{it: J. R. Statist. Soc. B}, 69, 507-564.


{title:Authors}

{phang}
Rafal Raciborski, StataCorp, College Station, TX.
{browse "mailto:rraciborski@stata.com":rraciborski@stata.com}.

{phang}
Yulia Marchenko, StataCorp, College Station, TX.
{browse "mailto:ymarchenko@stata.com":ymarchenko@stata.com}.


