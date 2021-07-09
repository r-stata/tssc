{smcl}
{* *! version 0.1 - 6 Jun 2016}{...}
{cmd:help fqreg}

{hline}

{title:Title}

{p2colset 8 17 19 2}{...}
{p2col :{cmd: fqreg} {hline 2}}Quantile regression for non-negative data with a mass-point at zero and an upper bound{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:fqreg}
{depvar}
{indepvars}
{ifin}
[{cmd:,} {it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt q:uantile(#)}}estimate {it:#} quantile; default is {cmd:quantile(.5)}{p_end}

{synopt:{opt ul(#)}}specifies the upper limit of the dependent variable; by default the upper limit is 1{p_end}

{synopt:{opt g:amma}}starting value for gamma if one is not provided using the {opt from} option (see {help fqreg##maximize_options:maximize_options}); by default gamma is set to 0{p_end}

{synopt :{opt wls:iter(#)}}attempt {it:#} weighted least-squares iterations before doing linear programming iterations for the determination of starting values; default is {cmd:wlsiter(1)}{p_end}

{synopt:{opt cl:uster(clustvar)}}specifies that the standard errors allow for intragroup correlation{p_end}

{synopt:{opt m:argins(varlist)}}compute average marginal effects for {it:varlist}{p_end}

{synopt:{opt n:ose}}suppresses calculation of the VCE and standard errors for the margins{p_end}

{synopt:{opt nowarn:ing}}suppress "convergence not achieved" message of iterate(0)

{synopt :{it:{help fqreg##maximize_options:maximize_options}}}control the maximization process{p_end}


{hline}

{p 4 6 2}
Weights are not allowed. {p_end}
 

{title:Description}

{pstd}
{cmd: fqreg} estimates quantile regression for non-negative data with a mass-point at zero and an upper bound, using 
the specification and method described in Machado, Santos Silva, and Wei (2016). 

{pstd}
Besides the usual table with results, {cmd: fqreg} reports the estimated quantile, the value of the R2 (defined 
as the square of the correlation between the dependent variable and its fitted values), the number of observations,
the percentage of observations for which the estimated quantile is equal to zero, and the value of the objective 
function, which is proportional to the average of the check function. 

{pstd}
The command {cmd: fqreg} uses Stata's {manlink R ml} command to perform the estimation. 
Therefore, {cmd: fqreg} shares many characteristics of the {cmd: ml} command, including its limitations and
benefits. For example, after {cmd: fqreg} is used to estimate a model, it is possible to get predictions or
test hypotheses about the parameters exactly in the same way as it is done after estimation with {cmd: ml}.
Also as with {cmd: ml}, convergence can be difficult if the dependent variable has very large values.

{pstd}
{cmd: fqreg} also has an option to estimate average marginal effects; for dummy variables the marginal effect is the discrete change from the base level, other variables are treated as continuous. If this option is used, it is not 
possible to compute predictions after the command and the tests that are performed are about the marginal
effects, not the parameters.


{title:Options}


{phang}
{opt ul(#)} specifies the upper limit of the dependent variable; by default the upper limit is 1. 
Stata often finds it difficult to estimate models with large values of the dependent variable. 
Therefore, when convergence is difficult to achieve, it may be helpful to rescale the dependent 
variable so that it is bounded between zero and 1. The estimated coefficients will not be affected 
by the rescaling but the estimated marginal effects will be in the scale of the new variable.

{phang}
{opt g:amma} starting value for gamma if one is not provided using the {opt from} option (see 
{help fqreg##maximize_options:maximize_options}); by default gamma is set to 0.

{phang}
{opt cl:uster(clustvar)} by default fqreg computes heteroskedasticity robust standard errors. The cluster 
option specifies that the standard errors also allow for intragroup correlation, relaxing the usual 
requirement that the observations be independent.  That is, the observations are independent across groups 
(clusters) but not necessarily within groups. {it:clustvar} specifies to which group each observation 
belongs. {cmd:cluster(}{it:clustvar}{cmd:)} affects the standard errors and variance-covariance matrix of
the estimators but not the estimated coefficients; see {findalias frrobust}.

{phang}
{opt m:argins(varlist)} compute average marginal effects for {it:varlist}. For dummy variables the marginal effect is the discrete change from the base level, other variables are treated as continuous

{phang}
{opt n:ose} suppresses calculation of the VCE and standard errors for the margins. Note that computation of 
the standard errors for the margins can be very time consuming.


{marker maximize_options}{...}
{phang}
{it:maximize_options}:
{opt tech:nique(string)},
{opt iter:ate(#)},
{opt nolo:g},
{opt tr:ace},
{opt dif:ficult},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance},
{opt from(init_specs)}; see {manhelp maximize R} for more details.


{title:Remarks}

{pstd}
{cmd: fqreg} is not an official Stata command and was written by J.A.F. Machado, J.M.C. Santos Silva, and K. Wei.
For further help and support, please contact {bf: jmcss@surrey.ac.uk}. Please notice that this software is provided 
as is, without warranty of any kind, express or implied, including but not limited to the warranties of 
merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors be liable 
for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, 
out of or in connection with the software or the use or other dealings in the software.



{title:Examples}

{hline}
{pstd}Setup - generate a discrete and a continuous regressor and then generate y bounded between 0 and 1{p_end}

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. set obs 10000}{p_end}
{phang2}{cmd:. set seed 13813}{p_end}
{phang2}{cmd:. g x1=rbinomial(1,0.4)}{p_end}
{phang2}{cmd:. g x2=rnormal(0,1)}{p_end}
{phang2}{cmd:. g y=rbinomial(5000,max(1e-5,((1 + 1)*(exp(1+0.5*x1-1*x2)/(1+exp(1+0.5*x1-1*x2)))-1)))/5000}{p_end}

{pstd}Estimation of the conditional median suppressing the log{p_end}

{phang2}{cmd:. fqreg y x1 x2, nolog}
{p_end}

{pstd}Estimation of the conditional median and compute margins{p_end}

{phang2}{cmd:. fqreg y x1 x2, m(x1 x2)}
{p_end}

{pstd}Estimation of the conditional first quartile{p_end}

{phang2}{cmd:. fqreg y x1 x2, q(.25)}
{p_end}


{title:Saved results}

{pstd}
The output saved in {cmd:e()} by {cmd:fqreg} depends on whether or not the option {opt margins} is used. By default {opt margins} 
is not used and the output saved in {cmd:e()} is essentially the same that is saved by {cmd:ml}. Some of the more relevant 
results are listed below and more details can be seen in {help maximize}. When the option {opt margins} is used the output saved 
in {cmd:e()} is the same that is saved by {cmd:margins}; again, some of the more relevant results are listed below 
and more details can be seen in {help margins}.


{pstd}
By default, the output saved in {cmd:e()} includes:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(k)}}number of parameters (includes the parameters corresponding to the base category of the dummy variables, which are set to zero){p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(ll)}}value of the objective function (times -1){p_end}
{synopt:{cmd:e(r2)}}R-squared, computed as the square of the correlation between the dependent variable and its fitted values{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(q)}}quantile requested{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(cmd)}}{cmd:fqreg}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                         maximization or minimization{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{pstd}
When the option {opt margins} is used, the output saved in {cmd:e()} includes:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:margins}{p_end}
{synopt:{cmd:e(model_vce)}}vcetype from estimation command{p_end}
{synopt:{cmd:e(model_vcetype)}}Std. Err. title from estimation command{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(expression)}}prediction expression{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}          

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}estimates{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimates{p_end}
{synopt:{cmd:e(_N)}}sample size corresponding to each margin estimate{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Reference}

{phang}
Machado, J.A.F., Santos Silva, J.M.C., and Wei, K. (2016), 
"{it:{browse "http://www.sciencedirect.com/science/article/pii/S0014292116301040":Quantiles, Corners, and the Extensive Margin of Trade}}," {it:European Economic Review}, forthcoming.

{title:Also see}

{psee}
Manual:  {manlink R ml} 




{center: Last modified on 6 June 2016}

