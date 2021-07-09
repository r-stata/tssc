{smcl}
{* *! version 1.2O - 28 Aug 2013}{...}
{cmd: help flex}

{hline}

{title:Title}

{p2colset 8 16 18 2}{...}
{p2col :{cmd: flex} {hline 2}}Flexible pseudo maximum likelihood estimation of models for doubly-bounded data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:flex}
{depvar}
{indepvars}
{ifin}
[{cmd:,} {it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt ul(#)}}specifies the upper limit of the dependent variable; by default the upper limit is 1{p_end}

{synopt:{opt ext:ended}}estimates an extended model with two shape parameters{p_end}

{synopt:{opt o:mega}}starting value for omega if one is not provided using the {opt from} option (see {help flex##maximize_options:maximize_options}); by default omega is set to 1{p_end}

{synopt:{opt d:elta}}starting value for delta when the {opt ext:ended} option is used; by default delta is set to 1{p_end}

{synopt:{opt st:rict}}selects the method to exclude regressors that may cause convergence problems{p_end}

{synopt:{opt k:eep}}keeps the observations that would be perfectly predicted by excluded regressors{p_end}

{synopt:{opt cl:uster(clustvar)}}specifies that the standard errors allow for intragroup correlation{p_end}

{synopt:{opt m:argins(varlist)}}compute average marginal effects for {it:varlist}{p_end}

{synopt:{opt n:ose}}suppresses calculation of the VCE and standard errors for the margins{p_end}

{synopt :{it:{help flex##maximize_options:maximize_options}}}control the maximization process{p_end}


{hline}

{p 4 6 2}
{opt fweight}s and {opt aweight}s are allowed; {opt pweight}s and {opt iweight}s are not allowed. 
See {help weight} for details.{p_end}
 

{title:Description}

{pstd}
{cmd: flex} estimates flexible models for doubly-bounded data using Bernoulli pseudo maximum likelihood.
The models may have one or two shape parameters and generalize the logit specification for fractional 
data suggested by Papke and Wooldridge (1996). For further details, see Santos Silva, Tenreyro, and Wei
(2012). 

{pstd}
{cmd: flex} uses a simplified version of the method of Santos Silva and Tenreyro (2010) to identify and drop 
regressors that may cause the non-existence of the (pseudo) maximum likelihood estimates. Notice that the user 
should carefully check whether the specification resulting from dropping the problematic regressors is interesting. 
If any of the regressors that are dropped is a dummy variable, by default {cmd: flex} will drop the observations 
with the less frequent value of the excluded dummy. This is done to prevent the observations identified by the 
dropped dummy from being treated as part of the base category. (This procedure can be overridden with the 
option {opt k:eep}.) The user should ensure that this procedure is appropriate and should consider alternatives 
like dropping the entire set of dummies, or recoding the variable in fewer categories. Because {cmd: flex} does 
not check for the presence of problematic regressors after dropping these observations, there may be rare cases 
in which {cmd: flex} tries to find estimates that actually do not exist. In these situations the estimation 
procedure will not converge, or convergence is spurious. 

{pstd}
Besides the usual table with results, {cmd: flex} 
reports the value of the R2 (defined as the square of the correlation between the dependent variable and its 
fitted values) and the log of the pseudo likelihood function evaluated at the estimates. Notice, however, that 
the Log pseudo-likelihood is not particularly meaningful and cannot be used, for example, to perform likelihood 
ratio tests. The command {cmd: flex} uses Stata's {manlink R ml} command to perform the estimation. 
Therefore, {cmd: flex} shares many characteristics of the {cmd: ml} command, including its limitations and
benefits. For example, after {cmd: flex} is used to estimate a model, it is possible to get predictions or
test hypotheses about the parameters exactly in the same way as it is done after estimation with {cmd: ml}.
Also as with {cmd: ml}, convergence can be difficult if the dependent variable has very large values.

{pstd}
{cmd: flex} also has an option to estimate average marginal effects. If this option is used, it is not 
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
{opt ext:ended} estimates an extended model with two shape parameters. A test for the validity 
of the simpler model with just one shape parameter can be performed by testing whether the second 
parameter (delta) is equal to 1.

{phang}
{opt o:mega} starting value for omega if one is not provided using the {opt from} option (see 
{help flex##maximize_options:maximize_options}); by default omega is set to 1.

{phang}
{opt d:elta} starting value for delta when the {opt ext:ended} option is used; by default delta is 
set to 1. The starting value of delta cannot be set using the {opt from} option (see 
{help flex##maximize_options:maximize_options}).

{phang}
{opt st:rict} by default flex uses a conservative method to exclude regressors that may cause convergence 
problems. The strict option forces the exclusion of all variables that are potentially problematic. The 
strict option should not be used unless convergence cannot be achieved otherwise, or if there is a warning 
that the model may be overfitting observations with {depvar}=0. 

{phang}
{opt k:eep} if any of the regressors that are dropped to ensure the existence of the estimates is a dummy 
variable, by default {cmd: flex} will drop the observations with the less frequent value of the excluded 
dummy. The option keep overrides this and does not drop any observation

{phang}
{opt cl:uster(clustvar)} by default flex computes heteroskedasticity robust standard errors. The cluster 
option specifies that the standard errors also allow for intragroup correlation, relaxing the usual 
requirement that the observations be independent.  That is, the observations are independent across groups 
(clusters) but not necessarily within groups.  {it:clustvar} specifies to which group each observation 
belongs. {cmd:cluster(}{it:clustvar}{cmd:)} affects the standard errors and variance-covariance matrix of
the estimators but not the estimated coefficients; see {findalias frrobust}.

{phang}
{opt m:argins(varlist)} compute average marginal effects for {it:varlist}. See the examples below to see how
to compute the partial effects for dummy variables.

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
{cmd: flex} is not an official Stata command and was written by J.M.C. Santos Silva, S. Tenreyro, & K. Wei.
For further help and support, please contact jmcss@surrey.ac.uk. Please notice that this software is provided 
as is, without warranty of any kind, express or implied, including but not limited to the warranties of 
merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors be liable 
for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, 
out of or in connection with the software or the use or other dealings in the software.



{title:Examples}

    {hline}
{pstd}Setup - generate a discrete and a continuous regressor and then generate y bounded between 0 and 50{p_end}

{phang2}{cmd:. clear all}{p_end}
{phang2}{cmd:. set obs 10000}{p_end}
{phang2}{cmd:. set seed 13813}{p_end}
{phang2}{cmd:. g x1=rbinomial(1,0.4)}{p_end}
{phang2}{cmd:. g x2=rnormal(0,1)}{p_end}
{phang2}{cmd:. g y=rbinomial(50,((1 - (1 + [2.5]*exp(0.25*x1+1*x2))^(-1/[2.5]))^(1)))}{p_end}

{pstd}{cmd: flex} estimation (notice that estimation with just the dummy variable is not possible because the shape parameters are not identified){p_end}

{phang2}{cmd:. flex y x1 x2, ul(50)}
{p_end}

{pstd}Test the validity of the logit specification){p_end}

{phang2}{cmd:. test [omega]_cons==1}
{p_end}

{pstd}{cmd: flex} estimation with the {opt margins} option (notice that for the partial effect of the dummy variable to be
computed correctly it is necessary to use the factor notation in the list of regressors, but not in the list of variables for which
the partial effects will be computed){p_end}

{phang2}{cmd:. flex y i.x1 x2, ul(50) margins(x1 x2)}
{p_end}

{pstd}{cmd: flex} estimation of the model with two shape parameters){p_end}

{phang2}{cmd:. flex y x1 x2, ul(50) ext}
{p_end}

{pstd}Test the validity of the one-parameter model){p_end}

{phang2}{cmd:. test [delta]_cons==1}
{p_end}


{title:Saved results}

{pstd}
The output saved in {cmd:e()} by {cmd:flex} depends on whether or not the option {opt margins} is used. By default {opt margins} 
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
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(r2)}}R-squared, computed as the square of the correlation between the dependent variable and its fitted values{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ml}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                         maximization or minimization{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(singularHmethod)}}{cmd:m-marquardt} or {cmd:hybrid}; method used
                          when Hessian is singular{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}

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


{title:References}

{phang}
Santos Silva, J.M.C. and Tenreyro, Silvana (2010), "{browse "http://dx.doi.org/10.1016/j.econlet.2010.02.020":On the Existence of the Maximum Likelihood Estimates in Poisson Regression}," {it:Economics Letters}, 
107(2), pp. 310-312. 

{phang}
Santos Silva, J.M.C., Tenreyro, S., and Wei, K.  (2012), 
"{browse "http://www.sciencedirect.com/science/article/pii/S002219961300130X":Estimating the Extensive Margin of Trade}," 
{it: Journal of International Economics}, 93(1), pp. 67-75.

{phang}
Papke, L.E. and Wooldridge, J.M. (1996), "Econometric Methods for Fractional Response Variables with an Application to 401(k) Plan Participation Rates," 
{it:{browse "http://onlinelibrary.wiley.com/journal/10.1002/%28ISSN%291099-1255":Journal of Applied Econometrics}}, 11, 619-632.


{title:Also see}

{psee}
Manual:  {manlink R ml} 




{center: Last modified on 28 August 2013}

