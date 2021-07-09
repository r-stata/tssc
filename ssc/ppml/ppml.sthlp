{smcl}
{* *! version 2.2.2 - 20 October 2015}{...}
{cmd: help ppml}

{hline}

{title:Title}

{p2colset 8 16 18 2}{...}
{p2col :{cmd: ppml} {hline 2}}Poisson pseudo maximum likelihood{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:ppml}
{depvar}
{indepvars}
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt st:rict}}selects the method to exclude regressors that may cause convergence problems{p_end}

{synopt:{opt k:eep}}keeps the observations that would be perfectly predicted by excluded regressors{p_end}

{synopt:{opt check:only}}checks for the presence of regressors that may cause convergence problems but does 
not perform the estimation{p_end}

{synopt:{opt nocon:stant}}suppress constant term{p_end}

{synopt:{opth off:set(varname)}}include {it:varname} in model with coefficient constrained to 1{p_end}

{synopt:{opt cl:uster(clustvar)}}specifies that the standard errors allow for intragroup correlation{p_end}

{synopt:{opt tech:nique(algorithm_spec)}}maximization technique{p_end}

{synopt:{opth mu(varname)}}use {it:varname} as the initial estimate for the mean of {help depvar}{p_end}

{synopt :{it:{help ppml##maximize_options:maximize_options}}}control the maximization process{p_end}


{hline}

{p 4 6 2}
{opt fweight}s, {opt aweight}s, {opt iweight}s, and {opt pweight}s are allowed; see {help weight}.{p_end}

{p 4 6 2}
See {manhelp glm_postestimation R:glm postestimation} for features available after estimation.{p_end}


{title:Description}

{pstd}
{cmd: ppml} estimates Poisson regression by pseudo maximum likelihood. It differs from {manlink R poisson} 
because it uses the method of Santos Silva and Tenreyro (2010) to identify and drop regressors that may 
cause the non-existence of the (pseudo) maximum likelihood estimates. Notice that the user should carefully
check whether the specification resulting from dropping the problematic regressors is interesting. If any of 
the regressors that are dropped is a dummy variable, by default {cmd: ppml} will drop the observations with 
the less frequent value of the excluded dummy. This is done to prevent the observations identified by the 
dropped dummy from being treated as part of the base category. (This procedure can be overridden with the 
option {opt k:eep}.) The user should ensure that this procedure is appropriate and should consider alternatives 
such as dropping the entire set of dummies, or recoding the variable in fewer categories. Because {cmd: ppml} does 
not check for the presence of problematic regressors after dropping these observations, there may be rare cases 
in which {cmd: ppml} tries to find estimates that actually do not exist. In these situations the estimation 
procedure will not converge, or convergence is spurious. In the latter case, {cmd: ppml} issues a warning that 
the model is overfitting the observations with {depvar}=0. {cmd: ppml} also issues a warning if the dependent 
variable or any of the regressors has large values that are likely to cause numerical problems and lead to 
convergence difficulties. Once the subset of regressors and observations to be used is defined, {cmd: ppml} uses 
the {manlink R glm} command to perform the estimation. Therefore, {cmd: ppml} shares many characteristics of the 
{cmd: glm} command, including its limitations.


{title:Options}

{phang}
{opt st:rict} by default ppml uses a conservative method to exclude regressors that may cause convergence 
problems. The {opt strict} option forces the exclusion of all variables that are potentially problematic. The 
{opt strict} option should be used with great caution. 

{phang}
{opt k:eep} if any of the regressors that are dropped to ensure the existence of the estimates is a dummy 
variable, by default {cmd: ppml} will drop the observations with the less frequent value of the excluded 
dummy. The option {opt keep} overrides this and does not drop any observation

{phang}
{opt check:only} with this option, {cmd: ppml} checks for the presence of regressors that may cause convergence 
problems but does not perform the estimation. The list of regressors that do not cause convergence problems and 
the list of regressors that do are saved in e(included) and e(excluded). The observations that can be used 
in the estimation are saved in e(sample). This option can be useful to detect and solve convergence issues with 
other commands for limited dependent variables, such as {cmd: nbreg} and {cmd: tobit}; see examples below. 

{phang}
{opt nocon:stant} suppresses the constant term (intercept) in the model. This option should be used with great
caution, but can be useful in some rare cases (e.g., if one wants to estimate models where the coefficients satisfy
certain linear restrictions).

{phang}
{opth off:set(varname)} specifies that {it:varname} be included in the model with the coefficient constrained to be 1.

{phang}
{opt cl:uster(clustvar)} by default {cmd: ppml} computes heteroskedasticity robust standard errors. The {opt cluster(clustvar)} 
option specifies that the standard errors also allow for intragroup correlation, relaxing the usual 
requirement that the observations be independent.  That is, the observations are independent across groups 
(clusters) but not necessarily within groups.  {it:clustvar} specifies to which group each observation 
belongs; {it:clustvar} can be a string variable. {cmd:cluster(}{it:clustvar}{cmd:)} affects the standard errors 
and variance-covariance matrix of the estimators but not the estimated coefficients; see {findalias frrobust}.

{phang}
{opt tech:nique(algorithm_spec)} specifies how the objective function is to be maximized.  The following 
algorithms are allowed:

{pmore}
        {opt tech:nique(irls)} specifies the irls algorithm used by {manlink R glm}. This is the default option 
        because this method appears to be more robust to numerical problems than the alternative options.

{pmore}
        {opt tech:nique(nr)} specifies Stata's modified Newton-Raphson (NR) algorithm.

{pmore}
        {opt tech:nique(bhhh)} specifies the Berndt-Hall-Hall-Hausman (BHHH) algorithm.

{pmore}
	      {opt tech:nique(dfp)} specifies the Davidon-Fletcher-Powell (DFP) algorithm.

{pmore}
        {opt tech:nique(bfgs)} specifies the Broyden-Fletcher-Goldfarb-Shanno
        (BFGS) algorithm.



{phang}
{opth mu(varname)} specifies {it:varname} as the initial estimate for the mean of {depvar}. This option 
can be used only with default option {cmd:technique(}{it:irls}{cmd:)} and can be useful with models that 
experience convergence difficulties. 

{marker maximize_options}{...}
{phang}
{it:maximize_options}:
{opt iter:ate(#)},
{opt tr:ace},
{opt search},
{opt dif:ficult},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt fisher(#)},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance},
{opt from(init_specs)}; see {manhelp maximize R} and {manhelp glm R}. Notes: Only the first two options can 
be used with {cmd:technique(}{it:irls}{cmd:)}; When other techniques are used, the option {opt dif:ficult} is 
highly recommended.


{title:Remarks}

{pstd}
{cmd: ppml} is not an official Stata command and was written by J.M.C. Santos Silva & Silvana Tenreyro.
We are greatful to Markus Baldauf for the help in developing this code. For further help and support,
please contact jmcss@surrey.ac.uk. Please notice that this software is provided as is, without warranty 
of any kind, express or implied, including but not limited to the warranties of merchantability, fitness 
for a particular purpose and noninfringement. In no event shall the authors be liable for any claim, damages 
or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
connection with the software or the use or other dealings in the software.




{title:Examples}

    {hline}
{pstd}Setup{p_end}

{phang2}{cmd:. use http://personal.lse.ac.uk/tenreyro/mock}{p_end}

{pstd}{cmd: ppml} estimation (the dummy z is correctly dropped, the observations with z=1 are also dropped){p_end}

{phang2}{cmd:. ppml y x w z}
{p_end}

{pstd}{cmd: ppml} estimation with the {opt k:eep} option (the dummy z is correctly dropped but no observations are dropped; this is equivalent to not conditioning on z){p_end}

{phang2}{cmd:. ppml y x w z, k}
{p_end}

{pstd}{cmd: ppml} estimation (v is correctly dropped, no observations are dropped because v is not a dummy){p_end}

{phang2}{cmd:. ppml y x w v}
{p_end}

{pstd}{cmd: ppml} estimation with the {opt st:rict} option (w will be incorrectly dropped){p_end}

{phang2}{cmd:. ppml y x w z v, st}
{p_end}

{pstd}{cmd: ppml} with the {opt check:only} option is used to solve convergence problems with {cmd: nbreg} (the dummy 
z is correctly dropped, the observations with z=1 are also dropped) {p_end}

{phang2}{cmd:. ppml y x z, check}
{p_end}
{phang2}{cmd:. nbreg y `e(included)' if e(sample)==1}
{p_end}

{pstd}{cmd: ppml} with the {opt check:only} option is used to solve convergence problems with {cmd: tobit} (the dummy 
z is correctly dropped, the observations with z=1 are also dropped) {p_end}

{phang2}{cmd:. ppml y x z, check}
{p_end}
{phang2}{cmd:. tobit y `e(included)' if e(sample)==1, ll(0)}
{p_end}



{title:Saved results}

{pstd}
By default, or with the option {opt tech:nique(irls)}, {cmd:ppml} saves the following output 
in {cmd:e()} (see {cmd:glm} for further details):

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_omitted)}}number of variables omitted due to collinearity {p_end}
{synopt:{cmd:e(k_excluded)}}number of variables excluded{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in model Wald test{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(phi)}}scale parameter{p_end}
{synopt:{cmd:e(disp)}}dispersion parameter{p_end}
{synopt:{cmd:e(bic)}}model BIC{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(r2)}}R-squared, computed as the square of the correlation between the dependent variable and its fitted values{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(deviance)}}deviance{p_end}
{synopt:{cmd:e(deviance_s)}}scaled deviance{p_end}
{synopt:{cmd:e(deviance_p)}}Pearson deviance{p_end}
{synopt:{cmd:e(deviance_ps)}}scaled Pearson deviance{p_end}
{synopt:{cmd:e(dispers)}}dispersion{p_end}
{synopt:{cmd:e(dispers_s)}}scaled dispersion{p_end}
{synopt:{cmd:e(dispers_p)}}Pearson dispersion{p_end}
{synopt:{cmd:e(dispers_ps)}}scaled Pearson dispersion{p_end}
{synopt:{cmd:e(nbml)}}{cmd:1} if negative binomial parameter estimated via ML,
	{cmd:0} otherwise{p_end}
{synopt:{cmd:e(vf)}}factor set by {cmd:vfactor()}, {cmd:1} if not set{p_end}
{synopt:{cmd:e(power)}}power set by {cmd:power()}, {cmd:opower()}{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ppml}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(varfunc)}}name of variance function used{p_end}
{synopt:{cmd:e(varfunct)}}Poisson{p_end}
{synopt:{cmd:e(varfuncf)}}variance function{p_end}
{synopt:{cmd:e(link)}}name of link function used{p_end}
{synopt:{cmd:e(linkt)}}link title{p_end}
{synopt:{cmd:e(linkf)}}link form{p_end}
{synopt:{cmd:e(m)}}number of binomial trials{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(hac_lag)}}HAC lag{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(opt)}}irls{p_end}
{synopt:{cmd:e(opt1)}}optimization title, line 1{p_end}
{synopt:{cmd:e(opt2)}}optimization title, line 2{p_end}
{synopt:{cmd:e(crittype)}}optimization criterion{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(marginsnotok)}}predictions disallowed by {cmd:margins}{p_end}
{synopt:{cmd:e(included)}}list of included regressors{p_end}
{synopt:{cmd:e(excluded)}}list of excluded regressors{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
For other choices of estimation algorithm, {cmd:ppml} saves the following output 
in {cmd:e()} (see glm for further details):

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_omitted)}}number of variables omitted due to collinearity {p_end}
{synopt:{cmd:e(k_excluded)}}number of variables excluded{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in model Wald test{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(k_autoCns)}}number of base, empty, and omitted constraints{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(phi)}}scale parameter{p_end}
{synopt:{cmd:e(aic)}}model AIC{p_end}
{synopt:{cmd:e(bic)}}model BIC{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(r2)}}R-squared, computed as the square of the correlation between the dependent variable and its fitted values{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(p)}}significance{p_end}
{synopt:{cmd:e(deviance)}}deviance{p_end}
{synopt:{cmd:e(deviance_s)}}scaled deviance{p_end}
{synopt:{cmd:e(deviance_p)}}Pearson deviance{p_end}
{synopt:{cmd:e(deviance_ps)}}scaled Pearson deviance{p_end}
{synopt:{cmd:e(dispers)}}dispersion{p_end}
{synopt:{cmd:e(dispers_s)}}scaled dispersion{p_end}
{synopt:{cmd:e(dispers_p)}}Pearson dispersion{p_end}
{synopt:{cmd:e(dispers_ps)}}scaled Pearson dispersion{p_end}
{synopt:{cmd:e(nbml)}}{cmd:1} if negative binomial parameter estimated via ML,
	{cmd:0} otherwise{p_end}
{synopt:{cmd:e(vf)}}factor set by {cmd:vfactor()}, {cmd:1} if not set{p_end}
{synopt:{cmd:e(power)}}power set by {cmd:power()}, {cmd:opower()}{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ppml}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(varfunc)}}name of variance function used{p_end}
{synopt:{cmd:e(varfunct)}}{cmd:Poisson}{p_end}
{synopt:{cmd:e(varfuncf)}}variance function{p_end}
{synopt:{cmd:e(link)}}name of link function used{p_end}
{synopt:{cmd:e(linkt)}}link title{p_end}
{synopt:{cmd:e(linkf)}}link form{p_end}
{synopt:{cmd:e(m)}}number of binomial trials{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:Wald} or {cmd:LR}; type of model chi-squared
	test{p_end}
{synopt:{cmd:e(hac_kernel)}}HAC kernel{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(opt)}}{cmd:ml} or {cmd:irls}{p_end}
{synopt:{cmd:e(opt1)}}optimization title, line 1{p_end}
{synopt:{cmd:e(opt2)}}optimization title, line 2{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                         maximization or minimization{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(singularHmethod)}}{cmd:m-marquardt} or {cmd:hybrid}; method used
                          when Hessian is singular{p_end}
{synopt:{cmd:e(crittype)}}optimization criterion{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(marginsnotok)}}predictions disallowed by {cmd:margins}{p_end}
{synopt:{cmd:e(included)}}list of included regressors{p_end}
{synopt:{cmd:e(excluded)}}list of excluded regressors{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
When the option {opt check:only} is used, {cmd:ppml} only saves the following output 
in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of variables kept (including the intercept, if there is one){p_end}
{synopt:{cmd:e(k_omitted)}}number of variables omitted due to collinearity {p_end}
{synopt:{cmd:e(k_excluded)}}number of variables excluded{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ppml}{p_end}
{synopt:{cmd:e(included)}}list of included regressors{p_end}
{synopt:{cmd:e(excluded)}}list of excluded regressors{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Reference}

{phang}
Santos Silva, J.M.C. and Tenreyro, Silvana (2010), "{browse "http://dx.doi.org/10.1016/j.econlet.2010.02.020":On the Existence of the Maximum Likelihood Estimates in Poisson Regression}," {it:Economics Letters}, 
107(2), pp. 310-312. 


{title:Also see}

{psee}
Manual:  {manlink R glm}  {manlink R poisson}




{center: Last modified on 20 October 2015}

