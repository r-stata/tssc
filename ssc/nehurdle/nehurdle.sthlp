{smcl}
{* *! Version 1.0.0 09 August 2017}{...}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:nehurdle} {hline 2}}estimation command for data with corner solutions.{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 2 6 2}
	General Syntax:
{p_end}

{phang}
	{cmd:nehurdle} {depvar} [{indepvars}] {ifin}
	[{it:{help nehurdle##weight:weight}}] [{cmd:,}
	{{opt he:ckman}|{opt to:bit}|{opt tr:unc}} {it:shared_options}
	{it:specific_options} ]
{p_end}

{p 2 6 2}
	Tobit's Syntax:
{p_end}

{phang}
	{cmd:nehurdle} {depvar} [{indepvars}] {ifin}
	[{it:{help nehurdle##weight:weight}}] {cmd:,} {opt to:bit}
	[ {it:shared_options} ]
{p_end}

{p 2 6 2}
	Truncated Hurdle's Syntax:
{p_end}

{phang}
	{cmd:nehurdle} {depvar} [{indepvars}] {ifin}
	[{it:{help nehurdle##weight:weight}}] [{cmd:,} {opt tr:unc}
	{it:shared_options} {it:specific_options} ]
{p_end}

{p 2 6 2}
	Type II Tobit's Syntax:
{p_end}

{phang}
	{cmd:nehurdle} {depvar} [{indepvars}] {ifin}
	[{it:{help nehurdle##weight:weight}}] {cmd:,} {opt he:ckman}
	[ {it:shared_options} {it:specific_options} ]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Estimator}
{synopt:{opt he:ckman}}required to use the Type II Tobit estimator{p_end}
{synopt:{opt to:bit}}required to use the Tobit estimator{p_end}
{synopt:{opt tr:unc}}optional to use the truncated hurdle estimator; this is
the default if no estimator option is specified{p_end}

{syntab:Shared Options}
{synopt:{opt coefl:egend}}display legend instead of statistics{p_end}
{synopt:{opt expon:ential}}specifies the value equation to be exponential{p_end}
{synopt:{opth exp:osure(varname)}}include ln({it:varname}) in the value equation
with coefficient constrained to 1{p_end}
{synopt:{opt het}{bf:(}{help nehurdle##hetspec:{it:hetspec}}{opt )}}specifies
	the functional form of the value's heteroskedasticity{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{help nehurdle##mlopts:{it:ml options}}}options that work with {cmd:ml}{p_end}
{synopt:{opt nocon:stant}}suppress constant term in the value equation{p_end}
{synopt:{opt nolo:g}}do not display the iteration log of the log likelihood{p_end}
{synopt:{opth off:set(varname)}}include {it:varname} in value equation with
coefficient constrained to 1{p_end}
{synopt :{opth vce(vcetype)}}specifies the method to estimator for the variance
covariance matrix. {it:vcetype} may be {opt cl:uster} {it:clustvar}, {opt oim},
{opt opg}, or {opt r:obust}{p_end}

{syntab:Specific Options}
{synopt:The following can also be used with either {opt trunc} or {opt heckman} estimators}

{synopt:{opt sel:ect}{bf:(}{help nehurdle##selspec:selspec}{bf:)}}specify the independent variables and options for
the selection equation{p_end}
{synoptline}
{marker hetspec}{...}
{p 4 6 2}
	{it:hetspec} for {opt het()} is {indepvars}, {opt nocons:tant}
{p_end}

{marker selspec}{...}
{p 4 6 2}
	{it:selspec} for {opt select()} is {indepvars}, {opth het(indepvars)}
	{opt nocons:tant} {opth exp:osure(varname)} {opth off:set(varname)}
{p_end}

{p 4 6 2}
	{it:indepvars} may contain factor variables; see {manhelp fvvarlist U}.
{p_end}
{marker weight}{...}
{p 4 6 2}
	{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see
	{manhelp weight U}.
{p_end}
{p 4 6 2}
	{cmd:bootstrap}, {cmd:by}, {cmd:fp}, {cmd:jacknife}, {cmd:statsby}, and
	{cmd:svy} are allowed; see {manhelp prefix U}.
{p_end}
{p 4 6 2}
	Weights are not allowed with either the {manhelp bootstrap R} prefix or the 
	{manhelp svy SVY} prefix.
{p_end}
{p 4 6 2}
	{cmd:vce()} not allowed with the {manhelp svy SVY} prefix.
{p_end}
{p 4 6 2}
	See {helpb nehurdle_postestimation} for features available after estimation.
{p_end}

 
{title:Description}

{pstd}{cmd:nehurdle} estimates models for dependent variables with corner
	solutions at 0. It collects the following maximum-likelihood estimators: Tobit
	({help nehurdle##tobin:Tobin (1958)}), Truncated Hurdle
	({help nehurdle##cragg:Cragg (1971)}), and Type II Tobit. It allows for both
	linear and exponential specification of the value equation, as well as for
	modeling exponential (multiplicative) heteroskedasticity, like in
	{help nehurdle##harvey:Harvey (1976)}, in both the selection and value
	processes where appropriate.

{pstd} In version 14, {cmd:Stata} introduced {cmd:churdle}, a command that
	allows estimations of models with bounded dependent variables. {cmd:churdle}
	is, in fact a Truncated Hurdle estimator that allows linear and exponential
	specifications of the value equation, as well as modeling heteroskedasticity
	both in the selection and the value equation. {cmd:nehurdle} differs from
	{cmd:churdle} in that {cmd:nehurdle} works on versions 11 and later, not
	just 14 and later, in that {cmd:nehurlde} only works on variables that are
	bounded from below 	at zero, a subset of variables on which {cmd:churdle}
	works, and in that {cmd:nehurdle} also has the Tobit and Type II Tobit
	estimators for linear and exponential specifications of the value equation
	that allows modeling of heteroskedasticity in the value and selection
	processes, while {cmd:churdle} only does this with the Truncated Hurdle
	estimator.

{marker options}{...}
{title:Options}

{dlgtab:Estimator}

{p 4 4 2}
	These options are mutually exclusive, i.e. only one may be used at a time,
	since they specify the estimator to be used.
{p_end}

{phang}{opt heckman} is required to tell {cmd: nehurdle} to use the Type II Tobit
	estimator.
	
{phang}{opt tobit} is required to tell {cmd: nehurdle} to use the Tobit estimator.

{phang}{opt trunc} is optional to tell {cmd: nehurdle} to use the Truncated
	Hurdle estimator. This is {cmd: nehurdle}'s default estimator, which is why
	it is optional to specify it.

{dlgtab:Shared Options}

{p 4 6 2}
	These options can be used with all estimators.
{p_end}

{phang}{opt coeflegend}; see
     {helpb estimation options##coeflegend:[R] estimation options}.

{phang}{opt exponential} tells {cmd:nehurdle} to estimate an exponential value
	equation. {cmd:nehurdle} will estimate a linear in parameters equation with
	the dependent variable being the natural logarithm of the actual variable.

{phang}{opth exposure(varname)} includes ln({it:varname}) in the model for the
	value equation with its coefficient constrained to 1.

{phang}{opt het}{bf:({indepvars},} {opt nocons:tant)} lets you specify the functional
	form of the value process heteroskedasticity. {cmd: nehurdle} models
	multiplicative heteroskedasticity, by specifying the standard deviation of
	the value process as an exponential process. It, thus, models the natural
	logarithm of the standard deviation of the value process.

{phang}{opt level(#)}; see
	{helpb estimation options##level():[R] estimation options}.

{marker mlopts}{...}
{phang}{it:ml options}. {cmd:nehurdle} accepts the following maximum likelihood
options:

{pmore}{opt collinear} tells the maximum-likelihood estimator to keep collinear
variables. This is useful if you know that there are no collinear variables, and
thus, want to save the estimator time by not checking if there are any.

{pmore}{cmd:constraints(}{it:{help numlist}}|{it:matname}{cmd:)} specifies the
linear constraints to be applied during estimation. {opt constraints(numlist)}
specifies the constraints by number. Constraints are defined using the {cmd:constraint}
command. {opt constraint(matname)} specifies a matrix that contains the
constraints. See {manhelp constraint R}.

{pmore}{opt difficult} is sometimes helpful when you get the message
"not concave" in many of the iterations of the maximization process (when you
don't specify {opt nolog} as an option). This may be a sign that {cmd:ml}'s
standard stepping algorithm may not be working well. {opt difficult} specifies
that a different stepping algorithm be used in these non-concave regions.
Notice that this may not help, since there is no guarantee that {opt difficult}
will make things better than the default. See
{helpb ml##noninteractive_maxopts:[R] ml maximize options}.

{pmore}{opt gradient} displays the gradient vector after each iteration if the
log is being displayed, i.e. you have not specified {opt nolog}.

{pmore}{opt hessian} displays the negative hessian matrix after each iteration
if the log is being displayed, i.e. you have not specified {opt nolog}.

{pmore}{opt iterate(#)} specifies the maximum number of iterations to be used.
If convergence is achieved before reaching that maximum number, the optimizer
stops when convergence is declared. If the maximum number of iterations is
reached before achieving convergence, the optimizer stops as well and presents
the results it has at that iteration number. The default maximum number of
iterations is 16,000. You can change the default maximum number of iterations
with {cmd:set maxiter}.

{pmore}{opt ltolerance(#)} sets the level for log-likelihood tolerance
convergence. When the change in log-likelihood is less than that level,
log-likelihood convergence is achieved. The default is {bf:tolerance(1e-6)}.

{pmore}{opt nocnsnotes} prevents notes on contraints-related errors from
displaying above the estimation results. Sometimes these errors cause constraints
to be dropped, but others the constraint is still applied to the estimation.

{pmore}{opt nonrtolerance} turns off the default {opt nrtolerance()} criterion.

{pmore}{opt nrtolerance(#)} specifies the level for scaled graident tolerance.
When the scaled gradient, g*inv(H)*g', has a value that is less than the level
scaled gradient convergence is achieved. The default is {cmd:nrtolerance(1e-5)}.

{pmore}{opt qtolerance(#)} sets the level of convergene for the q-H matrix. It
works when specified with algorithms {cmd:bhhh}, {cmd:dfp}, or
{cmd:bfgs}, and tells the otpimizer to uses the q-H matrix as the final check
for convergence rather than scaled gradient and the H matrix.

{pmore}{opt shownrtolerance} is a synonim for {opt showtolerance}.

{pmore}{opt showstep} shows information about the steps within an interation in
the iteration log, and shows the log even if you have specified {opt nolog}.

{pmore}{opt showtolerance} shows the log-likelihood tolerance in each step in
the iteration log until the log-likelihood convergence criterion has been met.
It then shows the scaled gradient g*inv(H)*g'. It does so even if you have
specified {opt nolog}.

{pmore}{opt technique(algorithm_spec)} specifies the algorithm(s) used and when
they are used in the maximization of the log likelihood. The possible algorithms
are: {opt nr}, Newton-Raphson algorithm, {opt bhhh}, Brendt-Hall-Hall-Hausman
algorithm, {opt dfp}, Davidon-Fletcher-Powell (DFP) algorithm, and {opt bfgs},
Broyden-Fletcher-Goldfarb-Shanno algorithm. The default algorithm is {opt nr}.
You can specify different algorithms to be used at different intervals of the
iterations. {it:algorithm_spec} is {it:algorithm} [ {it:#} [ {it:algorithm}
	[{it:#}] ] ... ] where {it:algorithm} is
	{{opt nr}|{opt bhhh}|{opt dfp}|{opt bfgs}}. For details, see
	{help nehurdle##gould:Gould, Pitblado, and Poi (2010)}.

{pmore}{opt tolerance(#)} sets the level for the coefficient vector tolerance.
When the relative change in the coefficient vector is less than the specified
level, coefficient vector convergence is achieved. The default is 
{bf:tolerance(1e-6)}. 

{pmore}{opt trace} displays the vector of the current estimates of the
coefficients after the each iteration in the iteration log, even if you have
specified {opt nolog}.

{phang}{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}{opt nolog} tells {cmd:nehurdle} to hide the iteration information of the
	maximum-likelihood estiamtor.
	
{phang}{opth offset(varname)} adds {it:varname} to the model of the value equation
with its coefficient constrained to 1.

{phang}{opt vce(vcetype)} specifies the type of standard error reported, which
includes types that are robust to some kinds of misspecification
({cmd:robust}), that allow for intragroup correlation ({cmd:cluster}
{it:clustvar}), and that are derived from asymptotic theory
({cmd:oim}, {cmd:opg}); see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Specific Options}

{phang}
{opt select(:}{bf:{indepvars}, het({indepvars}) noconstant exposure({varname}) offset({varname}))}
specifies the composition of the explanatory variables in the selection equation
as well as whether to model heteroskedasticity in the selection equation. This
is an optional option (all of it).

{pmore}{opt select()} only works when using either the Truncated Hurdle estimator
or the Type II Tobit estimator. It doesn't work with the Tobit estimator because
the Tobit estimator doesn't have separate selection and value processes.

{pmore}The first {it:{indepvars}} sets the independent variables of the selection equation.
If you don't include it {cmd:nehurdle} assumes that the independent variables for
the selection equation are the same as those of the value equation.

{pmore}{opth het(indepvars)} sets the independent variables of the heteroskedasticity
in the selection equation. Like with the value equation, {cmd:nehurdle} models
multiplicative heteroskedasticity in the value equation, so the independent variables
will help explain the natural logarithm of the standard deviation of the selection
process.

{pmore}{opt noconstant} tells {cmd:nehurdle} to not include a constant in the
selection equation.

{pmore}{opt exposure(varname)} adds ln({it:varname}) to the model of the selection
equation and constraints its coefficient to 1.

{pmore}{opt offset(varname)} adds {it:varname} to the model of the selection
equation and constraints its coefficient to 1.

{pmore}You can specify options for the selection equation without specifying
the independent variables of that equation. If you do that {cmd:nehurdle} will
use the same independent variables as for the value equation. For example
{bf: select(, noconstant)} will use the same independent variables as in the
value equation and not include a constant term in the selection equation.

{pmore}Since {cmd:nehurdle} assumes normality of the errors in the selection
process, the estimator for the selection equation is actually a Probit estimator,
like {cmd:probit}. When modeling heteroskedasticity in the selection process, it
is the heteroskedastic Probit estimator, like {cmd:hetprobit}.

{marker examples}{...}
{title:Examples}

{pstd}Data Setup{p_end}
{phang2}. {stata "webuse womenwk, clear"}{p_end}
{phang2}. {stata "replace wage = 0 if missing(wage)"}{p_end}
{phang2}. {stata "global xvars i.married children educ age"}{p_end}

{pstd}Homoskedastic Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, tobit nolog"}{p_end}
{phang2}. {stata "tobit wage $xvars, ll"}{p_end}

{pstd}Homoskedastic Exponential Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, tobit expon nolog"}{p_end}
{phang2}. {stata "gen double lny = ln(wage)"}{p_end}
{phang2}. {stata "summarize lny, mean"}{p_end}
{phang2}. {stata "replace lny = (r(min) - 1e-7) if missing(lny)"}{p_end}
{phang2}. {stata "tobit lny $xvars, ll"}{p_end}
{phang2}. {stata "drop lny"}{p_end}

{pstd}Heteroskedastic Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, tobit het($xvars) offset(age) nolog"}{p_end}

{pstd}Heteroskedastic Exponential Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, tobit expon het($xvars) nolog"}{p_end}

{pstd}Homoskedastic Truncated Hurdle{p_end}
{phang2}. {stata "nehurdle wage $xvars, nolog"}{p_end}

{pstd}Homoskedastic Exponential Truncated Hurdle{p_end}
{phang2}. {stata "nehurdle wage $xvars, expon nolog"}{p_end}

{pstd}Heteroskedastic Value Truncated Hurdle{p_end}
{phang2}. {stata "nehurdle wage $xvars, het($xvars) nolog"}{p_end}

{pstd}Heteroskedastic Selection and Value Truncated Hurdle{p_end}
{phang2}. {stata "nehurdle wage $xvars, het($xvars) sel(, het($xvars)) nolog"}{p_end}

{pstd}Heteroskedastic Value Exponential Truncated Hurdle{p_end}
{phang2}. {stata "nehurdle wage $xvars, expon het($xvars) nolog"}{p_end}

{pstd}Homoskedastic Type II Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, heck nolog"}{p_end}
{phang2}. {stata "gen byte dy = wage > 0"}{p_end}
{phang2}. {stata "heckman wage $xvars, sel(dy = $xvars) nolog"}{p_end}
{phang2}. {stata "drop dy"}{p_end}

{pstd}Homoskedastic Exponential Type II Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, heck expon nolog"}{p_end}
{phang2}. {stata "gen double lny = ln(wage)"}{p_end}
{phang2}. {stata "heckman lny $xvars, sel($xvars) nolog"}{p_end}
{phang2}. {stata "drop lny"}{p_end}

{pstd}Heteroskedastic Value Type II Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, heck het($xvars) nolog"}{p_end}

{pstd}Heteroskedastic Selection and Value Type II Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, heck het($xvars) sel(, het($xvars)) nolog"}{p_end}

{pstd}Heteroskedastic Value Exponential Type II Tobit:{p_end}
{phang2}. {stata "nehurdle wage $xvars, heck expon het($xvars) nolog"}{p_end}

{title:Stored Results}
{pstd}
{cmd:nehurdle} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}total number of observations{p_end}
{synopt:{cmd:e(N_c)}}number of censored observations{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters; reported when {cmd:vce(cluster}
	{it:clustvar}{cmd:)} is specified; see {findalias frrobust}{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_aux)}}number of auxiliary parameters{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in overall model test{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(df_m)}}number of non-constant parameters estimated (degrees of
	freedom of the overall significance test){p_end}
{synopt:{cmd:e(chi2)}}overall significance test Wald chi-squared{p_end}
{synopt:{cmd:e(p)}}overall significance test significance{p_end}
{synopt:{cmd:e(sel_df)}}number of non-constant parameters in the selection
	equation (degrees of freedom of the joint significance test for the
	selection equation); reported for Truncated Hurdle, and Type II Tobit
	estimations{p_end}
{synopt:{cmd:e(sel_chi2)}}selection equation joint significance test Wald
	chi-squared; reported for Truncated Hurdle, and Type II Tobit estimations{p_end}
{synopt:{cmd:e(sel_p)}}selection equation joint significance test significance;
	reported for Truncated Hurdle, and Type II Tobit estimations{p_end}
{synopt:{cmd:e(val_df)}}number of non-constant parameters in the value equation
	(degrees of freedom of the joint significance test for the value equation);
	reported for all Truncated Hurdle, and Type II Tobit estimations, as well as
	for heteroskedastic Tobit estimations{p_end}
{synopt:{cmd:e(val_chi2)}}value equation joint significance test Wald 
	chi-squared; reported for all Truncated Hurdle, and Type II Tobit
	estimations, as well as for heteroskedastic Tobit estimations{p_end}
{synopt:{cmd:e(val_p)}}value equation joint significance test significance;
	reported for Truncated Hurdle, and Type II Tobit estimations, as well as for
	heteroskedastic Tobit estimations{p_end}
{synopt:{cmd:e(het_df)}}number of non-constant parameters in the value
	hetersokedasticity equation (degrees of freedom of the joint significance
	test for value heteroskedasticity); reported for all estimations that
	model the value heteroksedasticity{p_end}
{synopt:{cmd:e(het_chi2)}}value heteroskedasticity equation joint significance
	test Wald chi-squared; reported for all estimations that model the value
	heteroksedasticity{p_end}
{synopt:{cmd:e(het_p)}}value heteroskedasticity equation joint significance test
	significance; reported for all estimations that model the value
	heteroksedasticity{p_end}
{synopt:{cmd:e(selhet_df)}}number of non-constant parameters in the selection
	hetersokedasticity equation (degrees of freedom of the joint significance
	test for selection heteroskedasticity); reported for all estimations that
	model the selection heteroksedasticity{p_end}
{synopt:{cmd:e(selhet_chi2)}}selection heteroskedasticity equation joint
	significance test Wald chi-squared; reported for all estimations that model
	the selection heteroksedasticity{p_end}
{synopt:{cmd:e(selhet_p)}}selection heteroskedasticity equation joint
	significance test significance; reported for all estimations that model the
	selection heteroksedasticity{p_end}
{synopt:{cmd:e(chi2_c)}}chi-squared of LR test against Truncated Hurdle;
	reported for Type II Tobit estimations{p_end}
{synopt:{cmd:e(p_c)}}LR test against Truncated Hurdle significance{p_end}
{synopt:{cmd:e(r2)}}pseudo r-squared{p_end}
{synopt:{cmd:e(gamma)}}lowest value of the natural logarithm of the dependent
	variable in the value equation; reported for exponential models{p_end}
{synopt:{cmd:e(sigma)}}standard deviation of the value process; reported for
	homoskedastic estimations{p_end}
{synopt:{cmd:e(rho)}}correlation between selection and value errors; reported
	for Type II Tobit estimations{p_end}
{synopt:{cmd:e(lambda)}}lambda; reported for Type II Tobit estimations{p_end}
	
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:nehurdle}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd_opt)}}the estimator option: {opt heckman}, {opt tobit} or
	{opt trunc}{p_end}
{synopt:{cmd:e(depvar)}}the dependent variable{p_end}
{synopt:{cmd:e(wtype)}}type of weight; reported for estimations using weights{p_end}
{synopt:{cmd:e(wexp)}}weight expression; reported for estimations using weights{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {opt vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable; reported for estimations
	with clustered standard errors{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(which)}}{opt max} or {opt min}; whether the optimizer is to
	perform maximization or minimization{p_end}
{synopt:{cmd:e(method)}}{cmd:ml}{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(properties)}}{opt b} {opt V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(asbalanced)}}factor variables {opt fvset} as {opt asbalanced}{p_end}
{synopt:{cmd:e(asbobserved)}}factor variables {opt fvset} as {opt asobserved}{p_end}
{synopt:{cmd:e(chi2type)}}{opt Wald}; type of model chi-squred test{p_end}
			
{title:References}

{marker cragg}{...}
{phang}
	Cragg John G. 1971. Some Statistical Models for Limited Dependent Variables
	with Application to the Demand for Durable Goods. {it:Econometrica} 39(5):
	829-844
{p_end}

{marker gould}{...}
{phang}
	Gould, William W., Jeffrey Pitblado, and Brian P. Poi. 2010.
	{browse "http://www.stata-press.com/books/ml4.html":{it:Maximum Likelihood Estimation with Stata}. 4th ed.}
	College Station, TX: Stata Press.
{p_end}

{marker harvey}{...}
{phang}
	Harvey, Andrew C. 1976. Estimating Regression Models with Multiplicative
	Heteroskedasticity. {it:Econometrica} 44(3): 461-465
{p_end}

{marker tobin}{...}
{phang}
	Tobin, James. 1958. Estimation of Relationships for Limited Dependent
	Variables. {it:Econometrica} 26(1): 24-36
{p_end}

{title:Acknowledgements}

{p 4 4 2}
	I would like to thank Isabel Canette from StataCorp LLC for her patience and
	her insightful comments that helped me debug much of {cmd: nehurdle}'s predict
	functionality.
{p_end}

{title:Author}

{phang}Alfonso S{c a'}nchez-Pe{c n~}alver{p_end}
{phang}University of South Florida{p_end}
{phang}Tampa, FL USA{p_end}
{phang}alfonsos1@usf.edu{p_end}

{title:Also See}

{psee}
Manual: {manlink R heckman}, {manlink R hetprobit}, {manlink R probit},
{manlink R tobit}
{p_end}
