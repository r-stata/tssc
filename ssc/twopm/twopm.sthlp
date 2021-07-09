{smcl}
{* documented: 10oct2010}{...}
{* revised: 14nov2010}{...}
{* revised: 8nov2011}{...}
{* revised: 25oct2012}{...}
{* revised: 08aug2013}{...}
{* revised: 21oct2014}{...}
{cmd:help twopm}{right: ({browse "http://www.stata-journal.com/article.html?article=st0368":SJ15-1: st0368})}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:twopm} {hline 2}}Two-part models{p_end}
{p2colreset}{...}


{title:Syntax}

{pstd}Same regressors in first and second parts

{p 8 17 2}
{cmd:twopm}
{it:{help depvar:depvar}}
[{indepvars}]
{ifin}
{weight}{cmd:,} {opt f:irstpart(f_options)} {opt s:econdpart(s_options)}
[{it:{help twopm##twopmoptions:twopm_options}}]


{pstd}Different regressors in first and second parts (caution: see {it:{help twopm##remarks:Remarks}} below)

{p 8 17 2}
{cmd:twopm}
{it:equation1} {it:equation2}
{ifin}
{weight}{cmd:,} {opt f:irstpart(f_options)} {opt s:econdpart(s_options)}
[{it:{help twopm##twopmoptions:twopm_options}}]

{pstd}where {it:equation1} and {it:equation2} are specified as

{p 8 12 2}{cmd:(}{depvar} [{cmd:=}] [{indepvars}]{cmd:)}

{marker twopmoptions}{...}
{synoptset 27 tabbed}{...}
{synopthdr :twopm_options}
{synoptline}
{p2coldent:* {opt f:irstpart}({it:{help twopm##foptions:f_options}})}specify the model 
for the first part{p_end}
{p2coldent:* {opt s:econdpart}({it:{help twopm##soptions:s_options}})}specify the model 
for the second part{p_end}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt conventional},
    {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or
    {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster} {it:clustvar}{cmd:)}{p_end}
{synopt :{opt suest}}combine the estimation results of first and second parts to derive
a simultaneous (co)variance matrix of the sandwich or robust type{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{it:display_options}}control spacing
           and display of omitted variables and base and empty cells{p_end}
{synoptline}
{pstd}
* {opt firstpart(f_options)} and {opt secondpart(s_options)} are required.{p_end}
{p 4 6 2}{it:indepvars} may contain factor variables; see {helpb fvvarlist}.{p_end}
{p 4 6 2}{it:depvar} and {it:indepvars} may
contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{opt bootstrap}, {opt by}, {opt jackknife}, {opt nestreg},
{opt rolling}, {opt statsby}, {opt stepwise}, and {opt svy}
are allowed; see {help prefix}.{p_end}
{p 4 6 2}Weights are not allowed with the {helpb bootstrap} prefix.{p_end}
{p 4 6 2}{cmd:aweight}s are not allowed with the {helpb jackknife} prefix.{p_end}
{p 4 6 2}
{opt vce()} and weights are not allowed with the {helpb svy} prefix.{p_end}
{p 4 6 2}{opt iweight}s, {opt aweight}s, and {opt pweight}s
are allowed; see {help weight}.{p_end}
{p 4 6 2}See {help twopm postestimation} for features available after estimation.{p_end}

{marker foptions}{...}
{synoptset 26}{...}
{synopthdr :f_options}
{synoptline}
{synopt :{helpb logit} [{cmd:,} {it:{help twopm##logit_options:logit_options}}]} specify 
the model for the binary, first-part outcome as a logistic regression{p_end}
{synopt :{helpb probit} [{cmd:,} {it:{help twopm##probit_options:probit_options}}]} specify 
the model for the binary, first-part outcome as a probit regression{p_end}
{synoptline}
{p2colreset}{...}

{marker soptions}{...}
{synoptset 26}{...}
{synopthdr :s_options}
{synoptline}
{synopt :{helpb glm} [{cmd:,} {it:{help twopm##glm_options:glm_options}}]} specify the 
model for the second-part outcome as a generalized linear model{p_end}
{synopt :{helpb regress} [{cmd:,} {it:{help twopm##regress_options:regress_options}}]} 
specify the model for the continuous, second-part outcome as a linear regression estimated using ordinary least squares{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:twopm} fits a two-part regression model of {it:depvar} on {it:indepvars}.
The first part models the probability that {it:depvar}>0 using a binary choice
model ({cmd:logit} or {cmd:probit}).  The second part models the distribution
of {it:depvar} | {it:depvar}>0 using linear ({cmd:regress}) and generalized
linear models ({cmd:glm}).


{title:Options}

{phang}
{opt firstpart(f_options)} specifies the first part of the model for a binary
outcome.  It should be {cmd:logit} or {cmd:probit}.  Each can be specified
with its options except {cmd:vce()}, which should be specified as a
{cmd:twopm} option.  {cmd:firstpart()} is required.

{phang}
{opt secondpart(s_options)} specifies the second part of the model for a
positive outcome.  It should be {cmd:regress} or {cmd:glm}.  Each can be
specified with its options except {opt vce()}, which should be specified as a
{cmd:twopm} option.  {cmd:secondpart()} is required.

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, including
types that are derived from asymptotic theory, that are robust to some kinds
of misspecification, that allow for intragroup correlation, and that use
bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{pmore}
{cmd:vce(conventional)}, the default, uses the conventionally derived variance
estimators for the first and second parts of the model.

{pmore}
Note that options related to the variance estimators for both parts must be
specified using {cmd:vce(}{it:vcetype}{cmd:)} in the {cmd:twopm} syntax.
Specifying {cmd:vce(robust)} is equivalent to specifying {cmd:vce(cluster}
{it:clustvar}{cmd:)}.

{phang}
{cmd:robust} is the synonym for {cmd:vce(robust)}.

{phang}
{opt cluster(clustvar)} is the synonym for {cmd:vce(cluster}
{it:clustvar}{cmd:)}.

{phang}
{cmd:suest} combines the estimation results of the first and second parts of
the model to derive a simultaneous (co)variance matrix of the sandwich or
robust type.  Typical applications of {opt suest} are tests for cross-part
hypotheses using {helpb test} or {helpb testnl}.

{phang}
{opt level(#)}; see 
{helpb estimation options##level():[R] estimation options}.

{phang}
{cmd:nocnsreport}; see 
{helpb estimation options##nocnsreport:[R] estimation options}

{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
see {helpb estimation options##display_options:[R] estimation options}.


{marker logit_options}{...}
{title:Options for the first part: logit}

{phang}
{opt nocon:stant}, {opth off:set(varname)},
{opt const:raints(constraints)}, {opt col:linear}; see
{helpb estimation options:[R] estimation options}.

{phang}
{opt asis} forces retention of perfect predictor variables and their
associated perfectly predicted observations and may produce instabilities in
maximization; see {manhelp probit R}.

{phang}
{it:maximize_options}:
{opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{cmd:{ul:no}}]{opt lo:g}, {opt tr:ace}, 
{opt grad:ient}, {opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance},
{opt from(init_specs)}; see {manhelp maximize R}.  These options are seldom
used.


{marker probit_options}{...}
{title:Options for the first part: probit}

{phang}
{opt nocon:stant}, {opth off:set(varname)},
{opt const:raints(constraints)}, {opt col:linear}; see
{helpb estimation options:[R] estimation options}.

{phang}
{marker asis}
{opt asis} specifies that all specified variables and observations be retained
in the maximization process.  This option is typically not specified and may
introduce numerical instability.  Normally, {cmd:probit} drops variables that
perfectly predict success or failure in the dependent variable along with
their associated observations.  In those cases, the effective coefficient on
the dropped variables is infinity (negative infinity) for variables that
completely determine a success (failure).  Dropping the variable and perfectly
predicted observations does not affect the likelihood or estimates of the
remaining coefficients and increases the numerical stability of the
optimization process.  Specifying this option forces retention of perfect
predictor variables and their associated observations.

{phang}
{it:maximize_options}:
{opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{cmd:{ul:no}}]{opt lo:g}, {opt tr:ace}, 
{opt grad:ient}, {opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance},
{opt from(init_specs)}; see {manhelp maximize R}.  These options are seldom
used.


{marker glm_options}{...}
{title:Options for the second part: glm}

{phang}
{opth f:amily(twopm##familyname:familyname)} specifies the
distribution of {depvar}. The default is {cmd:family(gaussian)}.

{marker familyname}{...}
{p2colset 11 36 38 25}{...}
{p2col:{it:familyname}}Description{p_end}
{p2line}
{p2col:{opt gau:ssian}}Gaussian (normal){p_end}
{p2col:{opt ig:aussian}}inverse Gaussian{p_end}
{p2col:{opt b:inomial}[{it:{help varname:varnameN}}|{it:#N}]}Bernoulli/binomial{p_end}
{p2col:{opt p:oisson}}Poisson{p_end}
{p2col:{opt nb:inomial}[{it:#k}|{cmd:ml}]}negative binomial{p_end}
{p2col:{opt gam:ma}}gamma{p_end}
{p2line}

{phang}
{opth l:ink(twopm##linkname:linkname)} specifies the link function; the
default is the canonical link for the {cmd:family()} specified.

{marker linkname}{...}
{p2colset 11 30 32 30}{...}
{p2col:{it:linkname}}Description{p_end}
{p2line}
{p2col:{opt i:dentity}}identity{p_end}
{p2col:{opt log}}log{p_end}
{p2col:{opt l:ogit}}logit{p_end}
{p2col:{opt p:robit}}probit{p_end}
{p2col:{opt c:loglog}}cloglog{p_end}
{p2col:{opt pow:er} {it:#}}power{p_end}
{p2col:{opt opo:wer} {it:#}}odds power{p_end}
{p2col:{opt nb:inomial}}negative binomial{p_end}
{p2col:{opt logl:og}}log-log{p_end}
{p2col:{opt logc}}log-complement{p_end}
{p2line}

{phang}
{opt nocon:stant}, {opth exp:osure(varname)}, {opt off:set(varname)},
{opt const:raints(constraints)}, {opt col:linear}; see 
{helpb estimation options:[R] estimation options}.
{opt constraints(constraints)} and {opt collinear} are not allowed with 
{opt irls}.

{phang}
{opth mu(varname)} specifies {it:varname} as the initial estimate for the mean
of {depvar}.  This option can be useful with models that experience
convergence difficulties, such as {cmd:family(binomial)} models with power or
odds-power links.  {opt init(varname)} is a synonym.

{phang}
{opt disp(#)} multiplies the variance of {depvar} by {it:#} and divides the
deviance by {it:#}.  The resulting distributions are members of the
quasilikelihood family.

{phang}
{cmd:scale(x2}|{cmd:dev}|{it:#}{cmd:)} overrides the default scale parameter.
This option is allowed only with Hessian (information matrix) variance
estimates.

{pmore}
The default is {cmd:scale(1)} for the discrete distributions (binomial,
Poisson, and negative binomial), and {cmd:scale(x2)} is assumed for the
continuous distributions (Gaussian, gamma, and inverse Gaussian).

{pmore}
{cmd:scale(x2)} specifies that the scale parameter be set to Pearson's
chi-squared (or generalized chi-squared) statistic divided by the residual
degrees of freedom, which is recommended by McCullagh and Nelder (1989) as a
good general choice for continuous distributions.

{pmore}
{cmd:scale(dev)} sets the scale parameter to the deviance divided by the
residual degrees of freedom.  This option provides an alternative to
{cmd:scale(x2)} for continuous distributions and overdispersed or
underdispersed discrete distributions.

{pmore}
{opt scale(#)} sets the scale parameter to {it:#}.  For example, using
{cmd:scale(1)} in {cmd:family(gamma)} models results in exponential-errors
regression.  Additional use of {cmd:link(log)} rather than the default
{cmd:link(power -1)} for {cmd:family(gamma)} reproduces Stata's {opt streg},
{cmd:dist(exp) nohr} command (see {manhelp streg ST}) if all the observations
are uncensored.

{phang}
{opt ml} requests that optimization be performed using Stata's {opt ml}
commands and is the default.

{phang}
{opt irls} requests iterated, reweighted least-squares optimization of the
deviance instead of Newton-Raphson optimization of the log likelihood.  If the
{opt irls} option is not specified, the optimization is performed using
Stata's {opt ml} commands, in which case all options of {opt ml maximize} are
also available.

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
{opt nonrtol:erance},
{opt from(init_specs)}; see {manhelp maximize R}.
These options are seldom used.

{pmore}
Setting the optimization type to {cmd:technique(bhhh)} resets the default
{it:vcetype} to {cmd:vce(opg)}.

{phang}
{opt fisher(#)} specifies the number of Newton-Raphson steps that should use
the Fisher-scoring Hessian or expected information matrix before switching to
the observed information matrix.  This option is useful only for
Newton-Raphson optimization (and not when using {cmd:irls}).

{phang}
{opt search} specifies that the command search for good starting values.  This
option is useful only for Newton-Raphson optimization (and not when using
{cmd:irls}).


{marker regress_options}{...}
{title:Options for the second part: regress}

{phang}
{opt log} specifies that the linear regression be estimated on the logarithm
of the second-part, continuous outcome.

{phang}
{opt nocon:stant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:twopm} is designed to estimate models in which the positive outcome is
continuous.  It does not deal with discrete or count outcomes.  It also does
not allow {helpb boxcox} or other models that may be appropriate for
continuous outcomes.

{pstd}
The statistical logic of the two-part model is that there is a vector of
variables, {it:indepvars}, that explain {it:depvar}.  Therefore, variables
that enter the specification for the first part should, in general, also enter
the specification for the second part.  In some situations, there may be
legitimate theoretical (conceptual) or statistical reasons that lead to
different lists of independent variables.  For completeness, {cmd:twopm} has a
syntax that allows for different covariates in each equation, but we do not
recommend the use of this.  There is typically no justification for different
regressors in each of the two parts.  Moreover, the two equations' syntax
cannot be used when the {helpb svy} prefix is specified.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse womenwk}{p_end}
{phang2}{cmd:. replace wage = 0 if wage==.}{p_end}

{pstd}Two-part model with logit and glm with Gaussian family and identity link{p_end}
{phang2}{cmd:. twopm wage educ age married children, firstpart(logit) secondpart(glm)}{p_end}
  
{pstd}Two-part model with probit and glm with gamma family and log link{p_end}
{phang2}{cmd:. twopm wage educ age married children, firstpart(probit) secondpart(glm, family(gamma) link(log))}{p_end}

{pstd}Two-part model with probit and linear regression{p_end}
{phang2}{cmd:. twopm wage educ age married children, firstpart(probit) secondpart(regress)}{p_end}

{pstd}Two-part model with probit and linear regression of log({it:depvar>0}){p_end}
{phang2}{cmd:. twopm wage educ age married children, firstpart(probit) secondpart(regress, log)}{p_end}

{pstd}Two-part model with different covariates in first and second parts{p_end}
{phang2}{cmd:. twopm (wage = educ age children) (wage = educ age married), firstpart(probit) secondpart(glm, family(gamma) link(log))}{p_end}


{title:Stored results}

{pstd}
If {cmd:probit} is specified as the first part, {cmd:twopm} stores the
following in {cmd:e()}:

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N_probit)}}number of observations{p_end}
{synopt:{cmd:e(N_cds_probit)}}number of completely determined successes{p_end}
{synopt:{cmd:e(N_cdf_probit)}}number of completely determined failures{p_end}
{synopt:{cmd:e(k_probit)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq_probit)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model_probit)}}number of equations in model (Wald test){p_end}
{synopt:{cmd:e(k_dv_probit)}}number of dependent variables{p_end}
{synopt:{cmd:e(k_autoCns_probit)}}number of base, empty, and omitted constraints{p_end}
{synopt:{cmd:e(df_m_probit)}}model degrees of freedom{p_end}
{synopt:{cmd:e(r2_p_probit)}}pseudo-R-squared{p_end}
{synopt:{cmd:e(ll_probit)}}log likelihood{p_end}
{synopt:{cmd:e(ll_0_probit)}}log likelihood, contant-only model{p_end}
{synopt:{cmd:e(N_clust_probit)}}number of clusters{p_end}
{synopt:{cmd:e(chi2_probit)}}chi-squared{p_end}
{synopt:{cmd:e(p_probit)}}significance{p_end}
{synopt:{cmd:e(rank_probit)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic_probit)}}number of iterations{p_end}
{synopt:{cmd:e(rc_probit)}}return code{p_end}
{synopt:{cmd:e(converged_probit)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(offset_probit)}}offset{p_end}
{synopt:{cmd:e(chi2type_probit)}}{cmd:Wald} or {cmd:LR}; type of model chi-squared test{p_end}
{synopt:{cmd:e(opt_probit)}}type of optimization{p_end}
{synopt:{cmd:e(which_probit)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                     maximization or minimization{p_end}
{synopt:{cmd:e(ml_method_probit)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user_probit)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique_probit)}}maximization technique{p_end}
{synopt:{cmd:e(singularHmethod_probit)}}{cmd:m-marquardt} or {cmd:hybrid}; method
                      used when Hessian is singular{p_end}
{synopt:{cmd:e(crittype_probit)}}optimization criterion{p_end}
{synopt:{cmd:e(asbalanced_probit)}}factor variables {cmd:fvset} as {cmd:asbalanced}{p_end}
{synopt:{cmd:e(asobserved_probit)}}factor variables {cmd:fvset} as {cmd:asobserved}{p_end}

{pstd}
If {cmd:logit} is specified as the first part, {cmd:twopm} stores the
following in {cmd:e()}:

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N_logit)}}number of observations{p_end}
{synopt:{cmd:e(N_cds_logit)}}number of completely determined successes{p_end}
{synopt:{cmd:e(N_cdf_logit)}}number of completely determined failures{p_end}
{synopt:{cmd:e(k_logit)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq_logit)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model_logit)}}number of equations in model (Wald test){p_end}
{synopt:{cmd:e(k_dv_logit)}}number of dependent variables{p_end}
{synopt:{cmd:e(k_autoCns_logit)}}number of base, empty, and omitted constraints{p_end}
{synopt:{cmd:e(df_m_logit)}}model degrees of freedom{p_end}
{synopt:{cmd:e(r2_p_logit)}}pseudo-R-squared{p_end}
{synopt:{cmd:e(ll_logit)}}log likelihood{p_end}
{synopt:{cmd:e(ll_0_logit)}}log likelihood, contant-only model{p_end}
{synopt:{cmd:e(N_clust_logit)}}number of clusters{p_end}
{synopt:{cmd:e(chi2_logit)}}chi-squared{p_end}
{synopt:{cmd:e(p_logit)}}significance{p_end}
{synopt:{cmd:e(rank_logit)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic_logit)}}number of iterations{p_end}
{synopt:{cmd:e(rc_logit)}}return code{p_end}
{synopt:{cmd:e(converged_logit)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(offset_logit)}}offset{p_end}
{synopt:{cmd:e(chi2type_logit)}}{cmd:Wald} or {cmd:LR}; type of model chi-squared test{p_end}
{synopt:{cmd:e(opt_logit)}}type of optimization{p_end}
{synopt:{cmd:e(which_logit)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
       maximization or minimization{p_end}
{synopt:{cmd:e(ml_method_logit)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user_logit)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique_logit)}}maximization technique{p_end}
{synopt:{cmd:e(singularHmethod_logit)}}{cmd:m-marquardt} or {cmd:hybrid}; method
                      used when Hessian is singular{p_end}
{synopt:{cmd:e(crittype_logit)}}optimization criterion{p_end}
{synopt:{cmd:e(asbalanced_logit)}}factor variables {cmd:fvset} as {cmd:asbalanced}{p_end}
{synopt:{cmd:e(asobserved_logit)}}factor variables {cmd:fvset} as {cmd:asobserved}{p_end}

{pstd}
If {cmd:glm} is specified as the second part, {cmd:twopm} stores the following
in {cmd:e()}:

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N_glm)}}number of observations{p_end}
{synopt:{cmd:e(k_glm)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq_glm)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model_glm)}}number of equations in model (Wald test){p_end}
{synopt:{cmd:e(k_dv_glm)}}number of dependent variables{p_end}
{synopt:{cmd:e(k_autoCns_glm)}}number of base, empty, and omitted constraints{p_end}
{synopt:{cmd:e(df_m_glm)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df_glm)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(phi_glm)}}scale parameter{p_end}
{synopt:{cmd:e(aic_glm)}}model AIC{p_end}
{synopt:{cmd:e(bic_glm)}}model BIC{p_end}
{synopt:{cmd:e(ll_glm)}}log likelihood, if NR{p_end}
{synopt:{cmd:e(N_clust_glm)}}number of clusters{p_end}
{synopt:{cmd:e(chi2_glm)}}chi-squared{p_end}
{synopt:{cmd:e(p_glm)}}significance{p_end}
{synopt:{cmd:e(deviance_glm)}}deviance{p_end}
{synopt:{cmd:e(deviance_s_glm)}}scaled deviance{p_end}
{synopt:{cmd:e(deviance_p_glm)}}Pearson deviance{p_end}
{synopt:{cmd:e(deviance_ps_glm)}}scaled Pearson deviance{p_end}
{synopt:{cmd:e(dispers_glm)}}dispersion{p_end}
{synopt:{cmd:e(dispers_s_glm)}}scaled dispersion{p_end}
{synopt:{cmd:e(dispers_p_glm)}}Pearson dispersion{p_end}
{synopt:{cmd:e(dispers_ps_glm)}}scaled Pearson dispersion{p_end}
{synopt:{cmd:e(nbml_glm)}}{cmd:1} if negative binomial parameter estimated via ML,
	{cmd:0} otherwise{p_end}
{synopt:{cmd:e(vf_glm)}}factor set by {cmd:vfactor()}, {cmd:1} if not set{p_end}
{synopt:{cmd:e(power_glm)}}power set by {cmd:power()}, {cmd:opower()}{p_end}
{synopt:{cmd:e(rank_glm)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic_glm)}}number of iterations{p_end}
{synopt:{cmd:e(rc_glm)}}return code{p_end}
{synopt:{cmd:e(converged_glm)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(varfunc_glm)}}name of variance function used{p_end}
{synopt:{cmd:e(varfunct_glm)}}{cmd:Gaussian}, {cmd:Inverse Gaussian},
                 {cmd:Binomial}, {cmd:Poisson}, {cmd:Neg. Binomial},
		 {cmd:Bernoulli}, {cmd:Power}, or {cmd:Gamma}{p_end}
{synopt:{cmd:e(varfuncf_glm)}}variance function{p_end}
{synopt:{cmd:e(link_glm)}}name of link function used{p_end}
{synopt:{cmd:e(linkt_glm)}}link title{p_end}
{synopt:{cmd:e(linkf_glm)}}link form{p_end}
{synopt:{cmd:e(m_glm)}}number of binomial trials{p_end}
{synopt:{cmd:e(offset_glm)}}offset{p_end}
{synopt:{cmd:e(chi2type_glm)}}{cmd:Wald} or {cmd:LR}; type of model chi-squared
	test{p_end}
{synopt:{cmd:e(cons_glm)}}set if {cmd:noconstant} specified{p_end}
{synopt:{cmd:e(hac_kernel_glm)}}HAC kernel{p_end}
{synopt:{cmd:e(hac_lag_glm)}}HAC lag{p_end}
{synopt:{cmd:e(opt_glm)}}{cmd:ml} or {cmd:irls}{p_end}
{synopt:{cmd:e(opt1_glm)}}optimization title, line 1{p_end}
{synopt:{cmd:e(opt2_glm)}}optimization title, line 2{p_end}
{synopt:{cmd:e(which_glm)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                         maximization or minimization{p_end}
{synopt:{cmd:e(ml_method_glm)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user_glm)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique_glm)}}maximization technique{p_end}
{synopt:{cmd:e(singularHmethod_glm)}}{cmd:m-marquardt} or {cmd:hybrid}; method used
                          when Hessian is singular{p_end}
{synopt:{cmd:e(crittype_glm)}}optimization criterion{p_end}
{synopt:{cmd:e(asbalanced_glm)}}factor variables {cmd:fvset} as {cmd:asbalanced}{p_end}
{synopt:{cmd:e(asobserved_glm)}}factor variables {cmd:fvset} as {cmd:asobserved}{p_end}

{pstd}
{cmd:twopm} stores the following in {cmd:e()}:

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:twopm}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement {cmd:estat}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample (first part){p_end}
{p2colreset}{...}


{title:Reference}

{phang}
McCullagh, P., and J. A. Nelder. 1989. {it:Generalized Linear Models} 2nd ed.
London: Chapman & Hall/CRC.


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Centre for Economic and International Studies{p_end}
{pstd}University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Partha Deb{p_end}
{pstd}Hunter College and Graduate Center, CUNY{p_end}
{pstd}New York, NY{p_end}
{pstd}and National Bureau of Economic Research{p_end}
{pstd}Cambridge, MA{p_end}
{pstd}partha.deb@hunter.cuny.edu{p_end}

{pstd}Willard G. Manning{p_end}
{pstd}University of Chicago{p_end}
{pstd}Chicago, IL{p_end}
{pstd}w-manning@uchicago.edu{p_end}

{pstd}Edward C. Norton{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}and National Bureau of Economic Research{p_end}
{pstd}Cambridge, MA{p_end}
{pstd}ecnorton@umich.edu{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 1: {browse "http://www.stata-journal.com/article.html?article=st0368":st0368}{p_end}

{p 7 14 2}Help:  {help twopm postestimation} (if installed){p_end}
