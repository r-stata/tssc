{smcl}
{cmd:help frontierhtail}
{hline}



{title:Title}

{pstd}
{hi:frontierhtail} fits stochastic production frontier models for heavy tail data



{title:Syntax}

{phang2}
{cmd:frontierhtail}
	{depvar} [{indepvars}]
	{ifin} {weight}
	[{cmd:,} {it:options}]


{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt: {opth het:ero(varlist)}}independent
	variable to model the variance {p_end}
{synopt: {opth c:onstraints(estimation options##constraints():constraints)}}apply specified linear constraints{p_end}
{synopt :{opth e:xposure(varname:varname_e)}}include ln({it:varname_e}) in
model with coefficient constrained to 1{p_end}
{synopt :{opth off:set(varname:varname_o)}}include {it:varname_o} in model with
coefficient constrained to 1{p_end}
{synopt :{opt noc:onstant}}suppress constant term{p_end}
{synopt: {cmd:nolrtest}}report the model Wald test{p_end}

{syntab:Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt ef:orm}}report exponentiated coefficients {p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype}
	may be {opt oim}, {opt r:obust}, or {opt opg}{p_end}
{synopt :{opth cl:uster(varname)}}adjust
	standard errors for intragroup correlation; implies {cmd:vce(robust)}{p_end}

{syntab:Max options}
{synopt :{it:{help maximize:maximize_options}}}control
	the maximization process; seldom used{p_end}
{synoptline}
{phang}
{opt fweight}s and {opt pweight}s are allowed;
see {help weight}.
{p_end}
{p 4 6 2}
{cmd:by} is allowed with {hi:frontierhtail}; see {manhelp by D} for more details on {cmd:by}.{p_end}
{p 4 6 2}
see {hi:predict} below for features available after estimation.  {p_end}
{p 4 6 2} 
{it:indepvars} and the {opth hetero(varlist)} option may contain factor variables; see {help fvvarlist}. {p_end}



{title:Description}

{pstd}
{cmd:frontierhtail} implements stochastic production frontier regression for heavy tail data.
As pointed out by Nguyen (2010), economic and financial data frequently evidence fat tails.
{cmd:frontierhtail} is for use in this case where data evidence heavy tail distribution when
estimating stochastic production frontier. The theory behind the command {cmd:frontierhtail}
is based on the work of Nguyen (2010). {cmd:frontierhtail} estimates a linear model (both 
dependent and independent variables must be in logarithmic form) where the disturbance is 
supposed to be a mixture of two components: the first, the random shock, is assumed to
follow a normal distribution and the, second, the technical inefficiency, is uniformly distributed.



{title:Options}

{dlgtab:Model}

{phang}
{opth hetero(varlist)} specifies variables to model
heteroscedasticity in the idiosyncratic error.  By default {cmd:frontierhtail} fits a
homoscedastic model.

{phang}
{opt constraints(constraints)},
{opth "exposure(varname:varname_e)"},
{opt offset(varname_o)}, and
{opt noconstant};
see {help estimation options}.

{phang}
{cmd:nolrtest} indicates that the model significance test should be a Wald
test instead of a likelihood-ratio test.

{dlgtab:Reporting}

{phang}
{opt level(#)}; set confidence level; default is {cmd:level(95)}.

{phang}
{opt eform} specifies that the coefficient table be
displayed in exponentiated form.

{dlgtab:SE/Robust}

{phang}
{opt vce(vcetype)}; {it:vcetype} may be {opt oim}, observed information matrix (OIM);
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

{phang2}
In addition to these maximization options, you can specify the initial values with the option
{opt init(init_specs)}. Where {it:init_specs} specifies the initial values of the coefficients.
See the examples below. The command {cmd:frontierhtail} automatically seeks the initial values of
the coefficients but you can indicates your own initial values if you desire with the option
{opt init(init_specs)}.


{title:Options for {help predict}}

{p 4 8 2}{cmd:xb}, the default, calculates the linear prediction. {p_end}

{p 4 8 2}{cmd:stdp} calculates the standard error of the linear prediction. {p_end}

{p 4 8 2}{cmd:inef} produces estimates of the technical inefficiency via E(u|e) {p_end}

{p 4 8 2}{cmd:mode} produces estimates of the technical inefficiency via the mode M(u|e) {p_end}

{p 4 8 2}{cmd:teff} produces estimates of the technical efficiency via E{exp(-u)|e} {p_end}

{p 4 8 2}{cmdab:res:iduals} calculates the residuals. {p_end}

{p 4 8 2}{cmdab:lns:igma} calculates the logarithm of the parameter sigma in v~N(0,s^2). {p_end}

{p 4 8 2}{cmdab:sig:ma} calculates the value of the parameter sigma in v~N(0,s^2). {p_end}

{p 4 8 2}{cmdab:lnt:heta} calculates the logarithm of the parameter theta in u~Uniform(0,t). {p_end}

{p 4 8 2}{cmdab:the:ta} calculates the value of the parameter theta in u~Uniform(0,t). {p_end}



{title:Saved results}

{pstd}
{cmd:frontierhtail} saves the following in {cmd:e()}. Note that these saved results are the same as those
returned by the command {manhelp maximize R} since {cmd:frontierhtail} is fitted using {manhelp ml R}:

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



{title:Examples}

{p 4 8 2} Before beginning the estimations, we use the {hi:set more off} instruction to tell
{hi:Stata} not to pause when displaying the output. {p_end}

{p 4 8 2}{stata "set more off"}{p_end}

{p 4 8 2} We first illustrate the use of the command {hi:frontierhtail} with the {hi:Stata}
manual dataset {hi: frontier1}. {p_end}

{p 4 8 2}{stata "use http://www.stata-press.com/data/r11/frontier1, clear"}{p_end}

{p 4 8 2} We estimate a Cobb-Douglas production function by regressing log output on
log labor and log capital. {p_end}

{p 4 8 2}{stata "frontierhtail lnoutput lnlabor lncapital"}{p_end}

{p 4 8 2} To obtain White-corrected standard errors, we specify the {opt vce(robust)} option. {p_end}

{p 4 8 2}{stata "frontierhtail lnoutput lnlabor lncapital, vce(robust)"}{p_end}

{p 4 8 2} If we do not want to have a constant and the display of the iterations
log at the beginning of the regression, we type. {p_end}

{p 4 8 2}{stata "frontierhtail lnoutput lnlabor lncapital, nocons nolog"}{p_end}

{p 4 8 2} We can specify variables to model heteroscedasticity in the idiosyncratic error. To do this
use the {cmd:size} variable with the {opth hetero(varlist)} option. {p_end}

{p 4 8 2}{stata "frontierhtail lnoutput lnlabor lncapital, hetero(size)"}{p_end}

{p 4 8 2} If we want to estimate a Cobb-Douglas production function with constant
returns-to-scale, we type. {p_end}

{p 4 8 2}{stata "constraint 1 _b[lnlabor] + _b[lncapital] = 1"}{p_end}

{p 4 8 2}{stata "frontierhtail lnoutput lnlabor lncapital, constraints(1)"}{p_end}

{p 4 8 2} If we want to specify our own initial values instead of using those automatically provided
by the command {hi:frontierhtail}, we proceed as follows. First, we run an OLS regression of
{hi: lnoutput} on a constant. {p_end}

{p 4 8 2}{stata "regress lnoutput"}{p_end}

{p 4 8 2} Then we put the constant value in the local macro {hi: b0}. {p_end}

{p 4 8 2}{stata "local b0 = _b[_cons]"}{p_end}

{p 4 8 2} Finally, we specify the {opt init(init_specs)} option as follows. {p_end}

{p 4 8 2}{stata " frontierhtail lnoutput lnlabor lncapital, init(/xb=`b0')"}{p_end}

{p 4 8 2} It is important to note that for the intital values, we give only one value to the
equation {hi:/xb}. {p_end}

{p 4 8 2} Let's now illustrate how {hi:frontierhtail} can be used with {hi:predict}. First,
we calculate the fitted values of the dependent variable. {p_end}

{p 4 8 2}{stata "frontierhtail lnoutput lnlabor lncapital"}{p_end}

{p 4 8 2}{stata "predict lnoutputhat, xb"}{p_end}

{p 4 8 2} To calculate the standard error of the linear prediction, we type. {p_end}

{p 4 8 2}{stata "predict serlp, stdp"}{p_end}

{p 4 8 2} To calculate the technical inefficiency via E(u|e), we type. {p_end}

{p 4 8 2}{stata "predict etechinef, inef"}{p_end}

{p 4 8 2} To calculate the technical inefficiency via the mode M(u|e), we type. {p_end}

{p 4 8 2}{stata "predict mtechinef, mode"}{p_end}

{p 4 8 2} To calculate the technical efficiency via E{exp(-u)|e}, we type. {p_end}

{p 4 8 2}{stata "predict techeff, teff"}{p_end}

{p 4 8 2} To calculate the residuals, we type. {p_end}

{p 4 8 2}{stata "predict resids, residuals"}{p_end}

{p 4 8 2} You can calculate the other options of the {hi:predict} command in the
same way as above by specifying: {hi:predict new_variable_name,  option_name}.  {p_end}

{p 4 8 2} Let's now show how to use the command {hi:frontierhtail} with the {hi:Stata}
manual dataset {hi:greene9}. {p_end}

{p 4 8 2}{stata "use http://www.stata-press.com/data/r11/greene9, clear"}{p_end}

{p 4 8 2} We estimate a Cobb-Douglas production function by regressing log value added on
log capital and log labor. We specify the option {opt technique(dfp)} to obtain convergence.  {p_end}

{p 4 8 2}{stata "frontierhtail lnv lnk lnl, technique(dfp) "}{p_end}

{p 4 8 2} If we want to test the constant returns-to-scale hypothesis on this model, we type.  {p_end}

{p 4 8 2}{stata "test _b[lnk]  +  _b[lnl]  =  1"}{p_end}

{p 4 8 2} This result shows that we cannot reject the null hypothesis of constant returns-to-scale
technology in this model. {p_end}



{title:References}

{pstd}
Nguyen, N. B.: 2010, "Estimation of technical efficiency in stochastic frontier analysis"
{it:Dissertation, Graduate College of Bowling Green State University}.
Downloadable at: {browse "http://rave.ohiolink.edu/etdc/view?acc_num=bgsu1275444079"}.
{p_end}



{title:Author}

{p 4}Diallo Ibrahima Amadou, {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online: help for {bf:{help frontier}}, {bf:{help xtfrontier}}, {bf:{help regress}}
{p_end}
