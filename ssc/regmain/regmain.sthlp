{smcl}
{* *! version 1.0  03aug2015}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{viewerjumpto "References" "references##references"}{...}
{title:Title}

{phang}
{bf:regmain} {hline 2} Regression Specifying a Specific Error Term Distribution


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:regmain}
{depvar}
{indepvars}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt dist:ribution}}which distribution to use{p_end}
{synopt:{opt init:ial}}initial values for the coefficients{p_end}
{synopt:{opt nog:raph}}supresses the output of graphs{p_end}
{synopt:{opt fam:ily}}allows you to compare all of the members in a distributio family. Either sgt or gb2.{p_end}
{synopt:{it:{help ml##noninteractive_maxopts:maximize_options}}}control the
maximization process{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:regmain} fits a model of {depvar} on {indepvars} using maximum likelihood with an error term distribution specified


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt distribution} 
SGT FAMILY: sgt, gt, st, sged, ged, t, normal, snormal, cauchy, scauchy, laplace, slaplace
GB2 FAMILY: gb2, gg, ln, lt, lcauchy, gamma, exp
Other: ols, lad, egb2, segb2


{phang}
{opt initial} list of numbers that specifies the initial values of the coefficients.

{phang}
{opt nograph} supresses the output of post estimation graphs.

{phang}
{opt family} Select gb2 or sgt, cannot be used with distribution. This option will
run MLE regression with each distribution in the family and return a table of 
log-likelihood values

{phang}{marker noninteractive_maxopts}
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
{opt nrtol:erance(#)}; see {manhelp maximize R}.

{marker distributions}{...}
{title:Distributions}

{pstd}
The following distributions or regression specifications can be used in the distribution option:


{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: SGT Family}{p_end}
{synopt:{cmd:sgt}}Skewed Generalized T distribution (parameters: sigma lambda p q){p_end}
{synopt:{cmd:gt}}Generalized T distribution (parameters: sigma p q){p_end}
{synopt:{cmd:st}}Skewed T distribution (parameters: sigma lambda q){p_end}
{synopt:{cmd:sged}}Skewed Generalized Error Distribution (parameters: sigma lambda p){p_end}
{synopt:{cmd:ged}}Generalized Error Distribution (parameters: sigma p){p_end}
{synopt:{cmd:t}}T distribution (parameters: sigma q){p_end}
{synopt:{cmd:snormal}}Skewed Normal Distribution (parameters: sigma lambda ){p_end}
{synopt:{cmd:normal}}Normal Distribution (parameters: sigma ){p_end}
{synopt:{cmd:scauchy}}Skewed Cauchy Distribution (parameters: sigma lambda ){p_end}
{synopt:{cmd:cauchy}}Cauchy Distribution (parameters: sigma ){p_end}
{synopt:{cmd:slaplace}}Skewed Laplace Distribution (parameters: sigma lambda ){p_end}
{synopt:{cmd:laplace}}LaplaceDistribution (parameters: sigma){p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: GB2 Family}{p_end}
{synopt:{cmd:gb2}}Generalized Beta Distribution of the 2nd Kind (parameters: sigma p q){p_end}
{synopt:{cmd:gg}}Generalized Gamma Distribution(parameters: sigma p ){p_end}
{synopt:{cmd:ln}}Log-Normal Distribution(parameters: sigma){p_end}
{synopt:{cmd:lt}}Log-T Distribution(parameters: sigma q){p_end}
{synopt:{cmd:lcauchy}}Log-Cauchy Distribution(parameters: sigma ){p_end}
{synopt:{cmd:gamma}}Gamma Distribution(parameters: p ){p_end}
{synopt:{cmd:exp}}Exponential Distribution(parameters: none ){p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Other options}{p_end}
{synopt:{cmd:ols}}Default, same as reg command {p_end}
{synopt:{cmd:lad}}least absolute deviations, same as qreg command{p_end}
{synopt:{cmd:egb2}}exponential GB2 distribution(parameters: sigma delta p q){p_end}
{synopt:{cmd:segb2}}Symmetric EGB2 distribution(parameters: sigma delta q){p_end}


{p2colreset}{...}

{marker remarks}{...}
{title:Remarks}

{pstd}
In cases where the convergence is difficult, try to use the option {cmd: technique(bfgs)}, or the other {cmd: technique} options. {cmd: technique(bfgs)} is often more robust than the default {cmd: technique(nr)}. 

{pstd}
The default maximum number of iterations is 1000.

{pstd}
When specifying initial values, include values for estimation parameters as well as distributional parameters. The number of distributional parameters varies depending on which distribution is selected. 

{marker examples}{...}
{title:Examples}

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. set obs 1000}{p_end}
{phang}{cmd:. set seed 1234}{p_end}
{phang}{cmd:. gen x1 = rnormal(2,3)}{p_end}
{phang}{cmd:. gen x2 = runiform(1,2)}{p_end}
{phang}{cmd:. gen y = 1 + x1 + x2 + rt(5)}{p_end}

{phang}{cmd:. regmain y x1 x2, dist(st) initial(1 1 1 3) nograph}{p_end}

{marker author}{...}
{title:Author}{...}

{phang}
Authored by James McDonald and Jonathan Jensen at Brigham Young University. For
support contact Jonathan at jonathanjens@gmail.com.


{marker references}{...}
{title:References}
{phang}
Hansen, C., J. McDonald, and P. Theodossiou (2007) "Some Flexible Parametric Models for Partially Adaptive Estimators of Econometric Models" Economics: The Open-Access, Open-Assessment E-Journal
{p_end}
{phang}
McDonald J., R. Michelfelder, and P. Theodossiou (2010) "Robust Estimation with Flexible Parametric Distributions: Estimation of Utility Stock Betas" Quantitative Finance 375-387
{p_end}
{phang}
McDonald, J.; Newey, W. (1998). "Partially Adaptive Estimation of Regression Models via the Generalized t Distribution". Econometric Theory. 4 (3): 428–457
{p_end}
{phang}
McDonald, J.B. (1984) "Some generalized functions for the size distributions of income", Econometrica 52, 647–663.
{p_end}

{title:Also see}

{phang}
https://en.wikipedia.org/wiki/Generalized_beta_distribution
{p_end}

{phang}
https://en.wikipedia.org/wiki/Skewed_generalized_t_distribution
{p_end}