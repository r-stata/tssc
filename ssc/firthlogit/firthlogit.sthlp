{smcl}
{* 2015-07-17}{...}
{cmd:help firthlogit} {right:Version 1.1 2015-07-17}

{hline}

{title:Title}

{p2colset 9 23 25 2}{...}
{p2col: {hi:firthlogit} {hline 2}}Penalized maximum likelihood logistic regression{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmdab:firthlogit}
{depvar} [{indepvars}]
{ifin}
{weight}
[{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt l:evel(#)}}set confidence level; default is prevailing setting (see {help creturn}){p_end}
{synopt:{opt or}}report odds ratios{p_end}
{synopt:{it:maximize_options}}maximization options{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{cmd:by} may be used with {cmd:firthlogit}; see {helpb by}.{p_end}
{p 4 6 2}
{cmd:fweight}s are allowed with {cmd:firthlogit}; see {help weight}.


{title:Description}

{pstd}
{cmd:firthlogit} fits logistic models by penalized maximum likelihood 
regression. The method originally was proposed to reduce bias in maximum likelihood
estimates in generalized linear models. It also has utility in logistic regression 
in circumstances in which "separation" is problematic.


{title:Options}

{dlgtab:Main}

{phang}
{cmd:level} set confidence level; default is the Stata {help level} setting.

{phang}
{cmd:or} is another reporting option, displaying coefficients as odds ratios.

{phang}
{it:maximize_options} many of the conventional {cmd:ml} options are available, the most important 
of which is {cmd:constraint()}, which is used in penalized likelihood ratio tests.  Options 
not available with {it:d0} estimators are not available; see {help ml}.


{title:Remarks}

{pstd}
Firth (1993) suggested a modification of the score equations in order to reduce 
bias seen in generalized linear models.  Heinze and Schemper (2002) suggested using Firth's 
method to overcome the problem of "separation" in logistic regression, a condition in the data 
in which maximum likelihood estimates tend to infinity (become inestimable). The method  
allows convergence to finite estimates in cases of separation in logistic regression.

{pstd}
The method penalizes the log-likelihood with one-half of the logarithm of the determinant of the 
information matrix.  {cmd:firthlogit} uses {cmd:ml} with a {it:d0} log-likelihood estimator 
program. {it:d0} estimators use numerical derivatives, and so are slower and slightly less 
accurate than linear form {it:lf}, {it:d1} or {it:d2} estimator types.  Nevertheless, 
differences in standard errors of the estimates between {cmd:firthlogit} and other 
software packages are very minor. At least one of the latter uses the {it:unpenalized} 
Hessian in the Newton-Raphson algorithm in order to avoid resorting to numerical derivatives 
there.

{pstd}
When the method is used in fitting logistic models in datasets giving rise to separation, the 
affected estimate is typically approaching a boundary condition.  As a result, the likelihood 
profile is often asymmetric under these conditions; Wald tests and confidence intervals are 
liable to be inaccurate. In these circumstances, Heinze and coworkers recommend using 
likelihood ratio tests and profile likelihood confidence intervals in lieu of Wald-based 
statistics. Calculation of likelihood ratio test statistics with the method is done differently 
by Heinze and coworkers from what is conventionally done: instead of omitting the variable of 
interest and refitting the reduced model, the coefficient of interest is constrained to zero 
and left in the model in order to allow its contributing to the penalization. The test statistic 
is then computed as twice the difference in penalized log likelihood values of the unconstrained 
and constrained models by {cmd:lrtest} in a manner directly analogous to that of conventional 
likelihood ratio tests.

{pstd}
The penalization that allows for convergence to finite estimates in conditions of separation 
also allows convergence to finite estimates with very sparse data.  In these circumstances, 
the penalization tends to over-correct for bias.


{title:Examples}

{phang}{cmd:. webuse hiv1}

{phang}{cmd:. firthlogit hiv cd4 cd8}

{phang}{cmd:. firthlogit, or}

{phang}{cmd:. estimates store Full}

{phang}{cmd:. constraint define 1 cd4}

{phang}{cmd:. firthlogit hiv cd4 cd8, constraint(1)}

{phang}{cmd:. lrtest Full .}


{title:References}

{pstd}
Firth, D. 1993. Bias reduction of maximum likelihood estimates. {it:Biometrika} {bf:80}:27{c -}38. 

{pstd}
Heinze, G. and Schemper, M. 2002. A solution to the problem of separation in 
logistic regression. {it:Statistics in Medicine} {bf:21}:2409{c -}19.


{title:Acknowledgements}

{pstd}
Jeff Pitblado provided a valuable pointer in displaying the results correctly. The command is named 
so as to acknowledge David Firth as the source of the method.  Note that Professor Firth 
is not otherwise associated with or responsible for this command: contact the author (below) 
to report bugs or other problems with the command.


{title:Author}

{pstd}
Joseph Coveney jcoveney@bigplanet.com


{title:Also see}

{psee}
Manual:  {bf:[R] exlogistic}

{psee}
Online:  {helpb ml}, {helpb exlogistic}
