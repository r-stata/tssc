{smcl}
{* *! version 1.0.0  // A METTRE}{...}
{cmd:help xtfixedcoeftvcu}
{hline}

{title:Title}

{pstd}
    {hi: Performs Estimations of Panel Data Models with Coefficients that Vary over Time and Cross-sectional Units}



{title:Syntax}

{p 8 17 2}
{cmd:xtfixedcoeftvcu}
{depvar}
{indepvars}
{ifin}
[{cmd:,} {it:options}]



{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt forcereg}}this option explicitly balances the panel data before the estimation {p_end}
{synopt:{opt maxnbiter(#)}}perform maximum of {it:#} iterations; default is {cmd:maxnbiter(500000)}{p_end}
{synopt:{opt ptoler(#)}}tolerance for the coefficient vector; default is {cmd:ptoler(1e-5)}{p_end}
{synopt:{opt vtoler(#)}}tolerance for the Residual Sum of Squares; default is {cmd:vtoler(1e-5)}{p_end}
{synopt:{opt nrtoler(#)}}tolerance for the scaled gradient; default is {cmd:nrtoler(1e-5)}{p_end}
{synopt:{opt ignrtoler}}ignore the {opt nrtoler()} option{p_end}
{synopt:[{opt no}]{opt displogs}}display an iteration log of the Residual Sum of Squares; typically, the default{p_end}
{synopt:{opt difficult}}use a different stepping algorithm in nonconcave regions{p_end}
{synopt:{opt technique(algorithm_spec)}}maximization technique{p_end}
{synopt:{opt vce(robust)}}Huber/White/sandwich estimator{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:xtfixedcoeftvcu}; see {helpb tsset}.{p_end}
{p 4 6 2}
{indepvars} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{cmd:by} is allowed with {hi:xtfixedcoeftvcu}; see {manhelp by D} for more details on {cmd:by}.{p_end}



{title:Description}

{pstd}
{cmd:xtfixedcoeftvcu} performs estimations of panel data models with coefficients that vary over time and 
cross-sectional units. This command allows estimation of: firstly coefficients that are common to all 
cross-sectional units and time, secondly parameters that vary over cross-sectional units, and thirdly 
coefficients that change over time. All three parameter groups previously cited are considered 
fixed, hence the command {cmd:xtfixedcoeftvcu} estimates a fixed-effects model. It is specifically 
called the Fixed-Coefficient Model or Fixed-Effects ANOVA Model. The theory behind the 
command {cmd:xtfixedcoeftvcu} is provided by {hi:Hsiao (2014)}.



{title:Econometric Model}

{p 4 6 2}  The estimated econometric model can be written as: {p_end}

{p 4 6 2}  y_it = sum_{k = 1}^{K}(betabar_k + alpha_ki + lambda_kt) * x_kit + u_it  (6.3.1) {p_end}

{p 4 6 2}  where {p_end}

{p 4 6 2}  i = 1,...,N {space 3}  and {space 3}  t = 1,...,T; {p_end}

{p 4 6 2}  {it:betabar_k} specifies the coefficients that are constant; {p_end}

{p 4 6 2}  {it:alpha_ki} indicates the coefficients that vary over cross-sectional units; {p_end}

{p 4 6 2}  {it:lambda_kt} designates the coefficients that vary over Time; {p_end}

{p 4 6 2}  {it:y_it} is the dependent variable; {p_end}

{p 4 6 2}  {it:x_kit} are the regressors; {p_end}

{p 4 6 2}  {it:u_it}  is the error term; {p_end}

{p 4 6 2}  the number {hi:(6.3.1)} is the equation number in {hi:Hsiao (2014)} for ease of reference, page 181; {p_end}

{p 4 6 2}  Equation {hi:(6.3.1)} can be written in matrix form as: {p_end}

{p 4 6 2}  y = X * betabar + XTILDE * alpha + XINF * lambda + u {space 4} (6.3.2) {p_end}

{p 4 6 2}  where {p_end}

{p 4 6 2}  {hi:betabar} specifies the vector of coefficients that are constant. In the regression table, the vector  {hi:betabar}  is named {hi:ConstantCoefs}; {p_end}

{p 4 6 2}  {hi:alpha}  indicates the vector of coefficients that vary over cross-sectional units. In the regression table, the vector {hi:alpha} is named {hi:GroupSpecCoefs}; {p_end}

{p 4 6 2}  {hi:lambda} designates the vector of coefficients that vary over Time. In the regression table, the vector {hi:lambda} is named {hi:TimeSpecCoefs}; {p_end}

{p 4 6 2}  the number {hi:(6.3.2)} is the equation number in {hi:Hsiao (2014)} for ease of reference, page 181; {p_end}

{p 4 6 2}  As mentioned previously, when {hi:betabar}, {hi:alpha_k} and {hi:lambda_k} are treated as fixed, the model is a fixed-effects model. The model can then be seen 
as a fixed-effects ANOVA model. Nevertheless, as mentioned by {hi:Hsiao (2014)} (page 182), the matrix of regressors is of 
dimension NT * (T + N + 1) K, but its rank is only (T + N - 1) K. Thus we need to impose 2K independent linear restrictions on the 
coefficients {hi:alpha_k} and {hi:lambda_k} in order to estimate our model (see {hi:Hsiao (2014)}, page 182 for more details). The 
command {cmd:xtfixedcoeftvcu} automatically includes these restrictions internally. You do not have to specify them. {p_end}



{title:Options}

{phang}
{opt forcereg} explicitly balances the panel data before the estimation. The command {cmd:xtfixedcoeftvcu} works
only on strongly balanced panel data. Hence if your data are not balanced, you should find a way to obtain a 
balanced panel by choosing an appropriate econometric method or any technique that you find convenient 
before employing the command; or else use this option to explicitly do it for you.

{phang}
{opt maxnbiter(#)} specifies the maximum number of iterations. When the number of iterations equals 
{cmd:maxnbiter()}, the optimizer stops and presents the current results. If convergence is declared 
before this threshold is reached, it will stop when convergence is declared. Specifying {cmd:maxnbiter(0)} 
is useful for viewing results evaluated at the initial value of the coefficient vector. The default value 
of {opt maxnbiter(#)} is {cmd:maxnbiter(500000)}.

{phang}
{opt ptoler(#)} specifies the tolerance for the coefficient vector. When the relative change in the coefficient 
vector from one iteration to the next is less than or equal to {opt ptoler()}, the {opt ptoler()} convergence 
criterion is satisfied. {cmd:ptoler(1e-5)} is the default.

{phang}
{opt vtoler(#)} specifies the tolerance for the Residual Sum of Squares (Residual SS).  When the relative change 
in the Residual SS from one iteration to the next is less than or equal to {opt vtoler()}, the  {opt vtoler()} 
convergence is satisfied. {cmd:vtoler(1e-5)} is the default.

{phang}
{opt nrtoler(#)} specifies the tolerance for the scaled gradient. Convergence is declared 
when g * invsym(-H) * g' <  {opt nrtoler()}. The default is {cmd:nrtoler(1e-5)}.

{phang}
{opt ignrtoler} specifies that the default {opt nrtoler()} criterion be turned off.

{phang}
{opt displogs} and {opt nodisplogs} specify whether an iteration log showing the progress of the Residual 
Sum of Squares is to be displayed.  The log is displayed by default, and {opt nodisplogs} suppresses it.  

{phang}
{opt difficult} specifies that the Residual Sum of Squares function is likely to be difficult to minimize because 
of  nonconcave regions.  When the message "not concave" appears repeatedly, {opt xtfixedcoeftvcu}'s standard 
stepping algorithm may not be working well.  {opt difficult} specifies that a different stepping algorithm be 
used in nonconcave regions.  There is no guarantee that {opt difficult} will work better than the default; sometimes 
it is better and sometimes it is worse.  You should use the {opt difficult} option only when the default stepper 
declares convergence and the last iteration is "not concave" or when the default stepper is repeatedly 
issuing "not concave" messages and producing only tiny improvements in the Residual Sum of Squares. Since we 
are dealing with a minimization problem, think of the preceding discussion in terms of maximization of -f(p).

{phang}
{opt technique(algorithm_spec)} specifies how the Residual Sum of Squares function is to be minimized.  The following algorithms are allowed.
For details, see 
{help maximize##GPP2010:Gould, Pitblado, and Poi (2010)}.

{pmore}
        {cmd:technique(nr)} specifies Stata's modified Newton-Raphson (NR)
        algorithm.

{pmore}
        {cmd:technique(bhhh)} specifies the Berndt-Hall-Hall-Hausman (BHHH)
        algorithm.

{pmore}
        {cmd:technique(dfp)} specifies the Davidon-Fletcher-Powell (DFP)
        algorithm.

{pmore}
        {cmd:technique(bfgs)} specifies the Broyden-Fletcher-Goldfarb-Shanno
        (BFGS) algorithm.

{pmore}The default is {cmd:technique(nr)}.

{pmore}
    You can switch between algorithms by specifying more than one in the {opt technique()} option.  By default, an 
	algorithm is used for five iterations before switching to the next algorithm.  To specify a different number of 
	iterations, include the number after the technique in the option.  For example, specifying {cmd:technique(bhhh 10 nr 1000)} 
	requests that {cmd:xtfixedcoeftvcu} perform 10 iterations with the BHHH algorithm followed by 1000 iterations with the 
	NR algorithm, and then switch back to BHHH for 10 iterations, and so on.  The process continues until convergence or 
	until the maximum number of iterations is reached.

{phang}
{cmd:vce(robust)} uses the robust or sandwich estimator of variance. This estimator is robust to some types of misspecification 
so long as the observations are independent; see {findalias frrobust}.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals.  The default 
is {cmd:level(95)} or as set by {bf:{help level}}.



{title:Syntax for predict}

{phang}
The syntax for predict after the command {cmd:xtfixedcoeftvcu} is:

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:Options_for_predict}]



{title:Options for {help predict}}

{phang}
{cmd:xball}, the default, calculates the linear prediction from all the equations taken together. It 
computes: {hi:X * betabar_hat + XTILDE * alpha_hat + XINF * lambda_hat}.

{phang}
{cmd:xbeta}, calculates the linear prediction from the ConstantCoefs equation only. It computes: {hi:X * betabar_hat}.  

{phang}
{cmd:xalpha}, calculates the linear prediction from the GroupSpecCoefs equation only. It computes: {hi:XTILDE * alpha_hat}.   

{phang}
{cmd:xlambda}, calculates the linear prediction from the TimeSpecCoefs equation only. It computes: {hi:XINF * lambda_hat}.

{phang}
{cmd:fcresids}, calculates the residuals from all the equations taken together. It 
computes: {hi:u_hat = y - (X * betabar_hat + XTILDE * alpha_hat + XINF * lambda_hat)}.



{title:Return values}

{pstd}

The command {cmd:xtfixedcoeftvcu} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(rank)}}Rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic)}}Number of iterations{p_end}
{synopt:{cmd:e(k)}}Number of parameters{p_end}
{synopt:{cmd:e(k_eq)}}Number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_dv)}}Number of dependent variables{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(rc)}}Return code{p_end}
{synopt:{cmd:e(chi2)}}Chi-squared{p_end}
{synopt:{cmd:e(chi2_p)}}P-value of the chi-squared statistic{p_end}
{synopt:{cmd:e(N)}}Number of observations{p_end}
{synopt:{cmd:e(T)}}Time used{p_end}
{synopt:{cmd:e(N_g)}}Number of included individuals{p_end}
{synopt:{cmd:e(g_avg)}}Average number of observations per included individual{p_end}
{synopt:{cmd:e(g_min)}}Lowest number of observations in an included individual{p_end}
{synopt:{cmd:e(g_max)}}Highest number of observations in an included individual{p_end}
{synopt:{cmd:e(r2)}}R-squared{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}Command as typed{p_end}
{synopt:{cmd:e(cmd)}}Name of command{p_end}
{synopt:{cmd:e(predict)}}Program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(tvar)}}Name of time variable{p_end}
{synopt:{cmd:e(ivar)}}Name of panel variable{p_end}
{synopt:{cmd:e(effectvar)}}Effective times used for the calculation and the display of the coefficients{p_end}
{synopt:{cmd:e(effecpvar)}}Effective panels used for the calculation and the display of the coefficients{p_end}
{synopt:{cmd:e(xvars)}}Names of the regressors{p_end}
{synopt:{cmd:e(depvar)}}Name of the dependent variable{p_end}
{synopt:{cmd:e(opt)}}Type of optimization{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(user)}}Name of the evaluator program{p_end}
{synopt:{cmd:e(ml_method)}}Type of {cmd:moptimize()} method{p_end}
{synopt:{cmd:e(technique)}}From {cmd:technique()} option{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform maximization or minimization; minimization in our case{p_end}
{synopt:{cmd:e(properties)}}Estimator properties{p_end}
{synopt:{cmd:e(singularHmethod)}}{cmd:m-marquardt} or {cmd:hybrid}; method used when Hessian is singular; sometimes stored{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}Coefficient vector{p_end}
{synopt:{cmd:e(V)}}Variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(Cns)}}Constraints matrix{p_end}
{synopt:{cmd:e(ilog)}}Iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}Gradient vector{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}Marks estimation sample{p_end}



{marker remarks1}{...}
{title:Examples}

{p 4 8 2} Before beginning the estimations, we use the {hi:set more off} instruction to tell
{hi:Stata} not to pause when displaying the output. {p_end}

{p 4 8 2}{stata "set more off"}{p_end}

{p 4 8 2} We illustrate the use of the command {cmd:xtfixedcoeftvcu} with the {hi:Stata} manual dataset {hi:invest2}. {p_end}

{p 4 8 2}{stata "webuse invest2, clear"}{p_end}

{p 4 8 2} We regress the dependent variable (invest) on the regressors (market stock). {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock"}{p_end}

{p 4 8 2} Next we display the {it:Return Values} of the previous regression. This will helps us in understanding the results. {p_end}

{p 4 8 2}{stata "ereturn list"}{p_end}

{p 4 8 2} As we explained in the section {hi:Return values}, the macro {hi:e(effecpvar)} contains the effective panels used for the 
calculation and the display of the coefficients and the macro {hi:e(effectvar)} contains the effective times used for the 
calculation and the display of the coefficients. Next we display the content of both of these macros. {p_end}

{p 4 8 2}{stata "display e(effecpvar)"}{p_end}

{p 4 8 2}{stata "display e(effectvar)"}{p_end}

{p 4 8 2} Having done that, let us now turn to the explanation of the output of the previous estimation. The table of results is divided 
into three parts: the first part shows the word {hi:ConstantCoefs} which specifies the coefficients that  are constant. It is 
the {hi:betabar} in equation {hi:(6.3.2)}. Since we have two regressors (market stock), we get three coefficients in this part of 
the table if we take the constant term into account. The second part displays the word {hi:GroupSpecCoefs} which indicates the 
coefficients that vary over cross-sectional units. It is the {hi:alpha} in equation {hi:(6.3.2)}. Since we have two 
regressors (market stock), and 5 panels (cross-sectional units) as illustrated by the content of the macro {hi:e(effecpvar)}, the 
coefficients of our regressors (market stock) are displayed for each panel we have. This is why the words (market and stock) are 
repeated in the part containing the Group Specific Coefficients. They correspond to each and every cross-sectional units actually 
used internally in our estimation. The third part exhibits the word {hi:TimeSpecCoefs} which designates the coefficients that 
vary over time. It is the {hi:lambda} in equation {hi:(6.3.2)}. Since we have two regressors (market stock), and 20 time periods (time) 
as demonstrated by the content of the macro {hi:e(effectvar)}, the coefficients of our regressors (market stock) are displayed for 
each time we have. This is why the words (market and stock) are repeated in the part containing the Time Specific Coefficients. They 
correspond to each and every time period actually used internally in our estimation. I suggest you to use the contents of the 
macros {hi:e(effecpvar)} and {hi:e(effectvar)} to see which cross-sectional units and time period are included in your regression 
and the display of the output. Last but not least, a {hi:Legend} after the table of results also helps you in the interpretation 
of the output. {p_end}

{p 4 8 2} In the next regression, we demonstrate how to compute the robust or sandwich estimator of variance. {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, vce(robust)"}{p_end}

{p 4 8 2} We illustrate the use of the {opt technique()} option by putting inside the brackets the name {hi:bfgs}, which stands 
for the Broyden-Fletcher-Goldfarb-Shanno algorithm. {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, technique(bfgs)"}{p_end}

{p 4 8 2} Now we specify {hi:technique(dfp 10 bfgs 50)} which requests that {cmd:xtfixedcoeftvcu} perform 10 iterations with 
the {hi:dfp} (Davidon-Fletcher-Powell) algorithm followed by 50 iterations with the {hi:bfgs} (Broyden-Fletcher-Goldfarb-Shanno) 
algorithm, and then switch back to {hi:dfp} for 10 iterations, and so on.  The process continues until convergence or until 
the maximum number of iterations is reached. {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, technique(dfp 10 bfgs 50)"}{p_end}

{p 4 8 2} The maximum number of iterations is controlled by the {opt maxnbiter(#)} option. You can increase or decrease 
the maximum number of iterations according to the model you are estimating. Next we choose to decrease it to 1000 iterations. {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, maxnbiter(1000)"}{p_end}

{p 4 8 2} We augment the tolerance for the coefficient vector {opt ptoler(#)}, the tolerance for the Residual Sum of 
Squares {opt vtoler(#)} and the tolerance for the scaled gradient {opt nrtoler(#)} to 10^(-6). {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, ptoler(1e-6) vtoler(1e-6) nrtoler(1e-6)"}{p_end}

{p 4 8 2} Here we reduce the previous tolerances to 10^(-4). {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, ptoler(1e-4) vtoler(1e-4) nrtoler(1e-4)"}{p_end}

{p 4 8 2} If we do not want to display an iteration log of the Residual Sum of Squares, we type: {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, nodisplogs"}{p_end}

{p 4 8 2} If we want to specify the {opt difficult} option, we write: {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, difficult"}{p_end}

{p 4 8 2} Now, we change the confidence intervals level to 90% by typing: {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, level(90)"}{p_end}

{p 4 8 2} Next, we illustrate how to use time-series operators with the command {cmd:xtfixedcoeftvcu}. First, we 
restore the original ordering of the dataset by writing: {p_end}

{p 4 8 2}{stata "tsset"}{p_end}

{p 4 8 2} Second, we perform the estimation by including the lagged value of the variable {hi:market}. {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market L.market stock, technique(dfp)"}{p_end}

{p 4 8 2} Let us demonstrate how to employ the {opt forcereg} option. Initially, we replace the second and third 
observations of the variable {hi:invest} with missing values. {p_end}

{p 4 8 2}{stata "replace invest = . in 2/3"}{p_end}

{p 4 8 2} Then, we run the following regression {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock"}{p_end}

{p 4 8 2} Finally, we obtained an error message telling us that the command {cmd:xtfixedcoeftvcu} requires strongly balanced 
data. At this point we could either find a way to get a balanced panel data on our own or use the option {opt forcereg} 
to explicitly do it for us. Here we choose to employ the option {opt forcereg}. {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock, forcereg technique(dfp)"}{p_end}

{p 4 8 2} To finish this {hi:Examples} section, we now illustrate how to use the command {cmd:xtfixedcoeftvcu} 
with {bf:{help predict}}. We start by reloading the original balanced panel data.  {p_end}

{p 4 8 2}{stata "webuse invest2, clear"}{p_end}

{p 4 8 2} We run the following regression. {p_end}

{p 4 8 2}{stata "xtfixedcoeftvcu invest market stock"}{p_end}

{p 4 8 2} We calculate the linear prediction from all the equations taken together. {p_end}

{p 4 8 2}{stata "predict predofxboverall, xball"}{p_end}

{p 4 8 2} We calculate the linear prediction from the ConstantCoefs equation only. {p_end}

{p 4 8 2}{stata "predict predofxbeta, xbeta"}{p_end}

{p 4 8 2} We calculate the linear prediction from the GroupSpecCoefs equation only. {p_end}

{p 4 8 2}{stata "predict predofxalpha, xalpha"}{p_end}

{p 4 8 2} We calculate the linear prediction from the TimeSpecCoefs equation only. {p_end}

{p 4 8 2}{stata "predict predofxlambda, xlambda"}{p_end}

{p 4 8 2} We calculate the residuals from all the equations taken together. {p_end}

{p 4 8 2}{stata "predict predoffcresids, fcresids"}{p_end}

{p 4 8 2} We describe all the previously created variables to see their labels. {p_end}

{p 4 8 2}{stata "describe predofxboverall predofxbeta predofxalpha predofxlambda predoffcresids"}{p_end}

{p 4 8 2} Finally, we summarize these variables. {p_end}

{p 4 8 2}{stata "summarize predofxboverall predofxbeta predofxalpha predofxlambda predoffcresids"}{p_end}



{title:References}

{pstd}
{hi:Hsiao, Cheng: 2014,} {it:Analysis of Panel Data}, Third Edition, Cambridge University Press.
{p_end}



{title:Author}

{p 4}Diallo Ibrahima Amadou {p_end}
{p 4}CERDI, University of Auvergne {p_end}
{p 4}65 bd Francois Mitterrand  {p_end}
{p 4}63000 Clermont-Ferrand   {p_end}
{p 4}France {p_end}
{p 4}{hi:E-Mail}: {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online:  help for {bf:{help xtrc}}, {bf:{help xtreg}}, {bf:{help maximize}}
{p_end}


