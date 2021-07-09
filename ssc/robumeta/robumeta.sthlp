{smcl}
{* *! version 0.7  07jul2010}{...}
{cmd:help robumeta}

{title:Title}
{phang}
{bf:robumeta} {hline 2} Robust variance estimation in meta-regression with dependent effect size 
estimates

{title:Syntax}

{p 5 10 2}
{cmd:robumeta} {depvar} [{indepvars}] {ifin}{cmd:,} {{opth variance:(varname:variancevar)}| 
{opth uweights:(varname:userweights)}}
[{it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}

{synopt :{opth study:(varname:studyid)}}use {it:studyid} as the study id variable {p_end}

{synopt :{opth weighttype:(string:weighting_scheme)}}use {it:weighting_scheme} 
as the method to calculate weights{p_end}

{synopt :{opth variance:(varname:variancevar)}}use {it:variancevar} as the sampling 
variance of the effect size{p_end}

{synopt :{opth uweights:(varname:userweights)}}use {it:userweights} as weights in a 
fixed effect model{p_end}

{synopt :{opth rho:(numlist:icc)}}use {it:icc} in calculating variance components
in the random effects model {p_end}

{synoptline}

{syntab:where elements of {it:weighting_scheme} may be}

{synopt:{opt random}} a random effects model weighting scheme that assumes the observed 
effect size estimates within each study are correlated with one another. 
In this model, the correlation arises from sampling error which occurs when, 
for example, multiple outcome measures are collected on the same units. 
This is the default.  {p_end}

{synopt:{opt fixed}} a fixed effects model weighting scheme that can be used when generalizations 
are limited to those effect sizes in the meta-analysis. This is useful when weights other 
than inverse-variance weights are used.  {p_end}

{synopt:{opt hierarchical}} a hierarchical model weighting scheme that is used when 
there is an additional level of nesting. This model assumes that the observed effect 
size estimates are nested within studies which are nested within clusters. For example, 
studies from the same research group may have something in common with one another. {p_end}

{title:Description}

{pstd}
{cmd:robumeta} provides a robust method for estimating standard errors in meta-regression, 
particularly when there are dependent effects. Dependent effects occur in two basic models: 
(1) correlated effects and (2) hierarchical meta-regression. In (1), the dependency arises 
as a result of correlated estimation errors; for example, a study collects two outcome measures 
on each participant and then summarizes these as two effect size measures. In (2), the dependency 
arises as a result of correlated parameters; for example, the same research group may publish 
several studies and there may be elements of these studies that are similar to one another. 
Importantly, the robust standard error procedure used here does not require the underlying 
correlation structure to be known; additionally, it works for any weights and can be used to 
estimate the mean effect size as well as meta-regression models. Finally, note that the procedure 
also can be used with independent effects, particularly when distributional assumptions might be 
violated. For more information on the underlying theory, see the references at the end of this help 
file. {p_end}

{title:Options}

{dlgtab:Model}

{phang}
{opth study:(varname:studyid)} specified that {it:studyid} be used as the study-level identifier.  
If this option is not specified, then the effect sizes are assumed to be independent. 

{phang}
{opth weighttype:(string:weighting_scheme)} specifies the weights to be used for combining the 
effect size estimates. The default is {opth weighttype:(string:fixed)}.

{phang}
{opth variance:(varname:variancevar)} specifies the variable {it:variancevar} that is the 
sampling variance of the effect size estimates. This must be specified for any random effects 
model. For fixed effects models, {opth variance:(varname:variancevar)} 
or {opth uweights:(varname:userweights)} can be specified instead.

{phang}
{opth uweights:(varname:userweights)} specified the user created weights for use with a fixed effects model.

{phang}
{opth rho:(numlist:icc)} for the correlated effects model, specifies the value of the 
correlation rho to be used, which must be < 1.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt nosmallsample}; Do not employ the new small sample correction.

{title:Examples}

{phang}{cmd:. use hedgesexample.dta}{p_end}
{phang}{cmd:. robumeta effectsize k1, study(study) variance(vareffsize) weighttype(random) rho(.8)}{p_end}
{phang}{cmd:. robumeta effectsize k1, study(study) variance(vareffsize) weighttype(hierarchical)}{p_end}

{title:Saved results}

{pstd}
{cmd:robumeta} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of studies{p_end}
{synopt:{cmd:e(df_r)}}model degrees of freedom{p_end}

{synopt:{cmd:e(tau2)}} method-of-moments tau-square estimate {p_end}
{synopt:{cmd:e(tau2o)}} observed tau-square if estimate is negative{p_end}

{synopt:{cmd:e(omega2)}} method-of-moments omega-square estimate (used in hierarchical model) {p_end}
{synopt:{cmd:e(omega2o)}} observed omega-square if estimate is negative{p_end}

{synopt:{cmd:e(QE)}}QE used for estimating tau-square {p_end}
{synopt:{cmd:e(QR)}}QR used for estimating omega-square {p_end}

{synopt:{cmd:e(rho)}} in correlated effects models, use specified ICC{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:robumeta}{p_end}
{synopt:{cmd:e(depvar)}}{depvar}{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(dfs)}}Degrees of freedom for effects{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:References}

{phang}
Hedges, Larry V., Elizabeth Tipton, and Matthew C. Johnson. 2010. Robust variance 
estimation in meta-regression with dependent effect size estimates. Research Synthesis Methods. 
(www.interscience.wiley.com) DOI: 10.1002/jrsm.5
{p_end}

{phang}
Tipton, E. (in press) Small sample adjustments for robust variance estimation with meta-regression. Forthcoming in Psychological Methods.
{p_end}

{phang}
Websites for further information: http://www.northwestern.edu/ipr/qcenter/RVE-meta-analysis.html
and
http://blogs.cuit.columbia.edu/let2119/
{p_end}





