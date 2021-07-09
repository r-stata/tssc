{smcl}
{* *! version 0  18jan2017}{...}

{title:Title}

{phang}
{bf:reg_sandwich} {hline 2}  Linear regression with small-sample corrections for cluster-robust standard errors and t-tests

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: reg_sandwich}
{depvar} [{indepvars}] {ifin} [{it:{help weight:weight}}]{cmd:,}
cluster({varname}) 
[absorb({varname}) | {cmdab:nocon:stant}] 
[level({#})]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Mandatory}

{synopt :{opth cluster:(varname)}} {varname} for clustered sandwich estimator. {p_end}

{syntab:Optional}

{synopt :{opth absorb:(varname)}} categorical variable to be absorbed. {p_end}
{synopt :{cmdab:nocon:stant}} suppress constant term. {p_end}
{synopt :*} {it:absorb and noconstant cannot be used simultaneously}. {p_end}
{synopt : level(#)} set confidence level; default is level(95). {p_end}

{synoptline}

{p 4 6 2}
{cmd:aweight}s and {cmd:pweight}s are
allowed; see {help weight}.{p_end}

{p 4 6 2}
{cmd:reg_sandwich} uses the supporting mata function
reg_sandwich_ttests.mo{p_end}
{p 4 6 2}
{it:* please note that {cmd:reg_sandwich} uses the mata workspace for intermediate calculations and to store large matrices for F-testing.}
{it:This can potentially cause conflict with existing matrices. This affects matrices named }
{it:W, Wj, X, Xj,  ej, sq_inv_Bj, Bj, Tj, evals, evecs, Aj, Pj_Theta_Pj_relevant, Pj_relevant, Dj, PPj, XWAeeAWX, M }
{it:and names of the form X*, PP*, P*_relevant, where * can be any real integer.}{p_end}

{p 4 6 2}
see also {help test_sandwich}{p_end}

{title:Description}

{pstd}
{cmd: reg_sandwich} fits a linear regression using {help regress}, optionally passing aweights or pweights (see {help weight}). If {it:absorb} is provided, the regression are fitted using {help areg}. Standard errors are based on a version of the bias-reduced linearization estimator proposed by Bell and McCaffrey (2002) and further developed by Tipton and Pustejovsky (2015) and Pustejovsky and Tipton (2016). t-tests for each coefficient in the model are calculated based on a Satterthwaite-type approximation, as described in Pustejovsky and Tipton (2016). 

{pstd}
Note that if {it:absorb} is provided, the absorbed fixed effects are NOT taken into account when calculating the bias-reduced linearization estimator. That is, the small-sample corrections are calculated based on the matrix of covariates after absorbing the fixed effects. This can create (typically very small) differences in the cluster-robust standard errors and hypothesis tests depending on whether fixed effects are absorbed or are included as dummy variables. 

{title:Arguments}

{dlgtab:Mandatory}

{pmore}
{opth cluster:(varname)} {varname} for clustered sandwich estimator. See {helpb vce_option:[R] {it:vce_option}}.
{p_end}

{dlgtab:Optional}
{pmore}
({it:These two optional cannot be used simultaneously})

{pmore}
{opth absorb:(varname)}} specifies the categorical variable, which is to be included in the regression as if it were specified by dummy variables. See {help areg}. {p_end}

{pmore}
{cmdab:nocon:stant} suppresses the constant term (intercept) in the model.{p_end}

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{title:Examples}

{phang}{cmd:. use http://masteringmetrics.com/wp-content/uploads/2015/01/deaths.dta}{p_end}
{phang}{cmd:. keep if dtype == 2 & agegr == 2} {p_end}
{phang}{cmd:. xi, noomit: reg_sandwich mrate legal beertaxa beerpercap winepercap i.year, nocon cluster(state)}{p_end}
{phang}{cmd:. xi, noomit: reg_sandwich mrate legal beertaxa beerpercap winepercap i.year [aweight=pop], nocon cluster(state)}{p_end}
{phang}{cmd:. xi, noomit: reg_sandwich mrate legal beertaxa beerpercap winepercap i.year [pweight=pop], nocon cluster(state)}{p_end}
{phang}{cmd:. xi: reg_sandwich mrate legal beertaxa beerpercap winepercap i.year, cluster(state) absorb(state)}{p_end}
{phang}{cmd:. xi, noomit: reg_sandwich mrate legal beertaxa beerpercap winepercap i.year [aweight=pop], cluster(state) absorb(state)}{p_end}
{phang}{cmd:. xi, noomit: reg_sandwich mrate legal beertaxa beerpercap winepercap i.year [pweight=pop], cluster(state) absorb(state)}{p_end}

{title:Saved results}

{pstd}
{cmd:re_sandwich} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}

{synopt:{cmd:e(r2)}}R-squared{p_end}
{synopt:{cmd:e(r2_a)}}adjusted R-squared{p_end}

{synopt:{cmd:e(rss)}}residual sum of squares{p_end}
{synopt:{cmd:e(mss)}}model sum of squares{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:reg_sanfwich}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}

{synopt:{cmd:e(depvar)}}{depvar}{p_end}
{synopt:{cmd:e(indepvar)}}expanded list of depvars, after correcting for multicolinerity{p_end}
{synopt:{cmd:e(constant_used)}}0 if false, 1 if true{p_end}

{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}

{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(absvar)}}name of absorb variable (if absorb option is used){p_end}

{synopt:{cmd:e(vce)}}cluster{p_end}
{synopt:{cmd:e(vcetype)}}Robust{p_end}

{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(type_VCE)}}OLS if unweighetd, WLSa if using aweigths and WLSp if using pweights {p_end}


{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(dfs)}}Degrees of freedom for effects{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{pstd}
{it:{cmd:re_sandwich} saves the following in the mata workspace}:

{synopt:{cmd:e(MXWTWXM)}}auxiliary matrix used for F-testing{p_end}
{synopt:{cmd:e(PThetaP_relevant)}}auxiliary matrix used for F-testing{p_end}
{synopt:{cmd:e(P_relevant)}}auxiliary matrix used for F-testing{p_end}
{synopt:{cmd:e(PP)}}auxiliary matrix used for F-testing (used for p-weights only){p_end}


{title:Citation}
{phang}
{cmd:reg_sandwich} is not an official Stata command. It is a free contribution to the research community, like a paper.
Please cite it as such:{p_end}

{phang}
Tyszler, M., Pustejovsky, J. E., & Tipton, E. 2017. REG_SANDWICH: Stata module to compute cluster-robust (sandwich) variance estimators with small-sample corrections for linear regression, Statistical Software Components S458352, Boston College Department of Economics. URL: {browse "https://ideas.repec.org/c/boc/bocode/s458352.html"}
{p_end}

{title:Authors}
{phang} Marcelo Tyszler. Sustainable Economic Development and Gender, Royal Tropical Institute, Netherlands. {browse "mailto:m.tyszler@kit.nl":m.tyszler@kit.nl} {p_end}

{phang} James E. Pustejovsky {bf:{it: (Package maintainer)}}. Department of Education Psychology, University of Texas at Austin. {browse "mailto:pusto@austin.utexas.edu":pusto@austin.utexas.edu}{p_end}

{phang} Elizabeth Tipton. Department of Human Development, Teachers College, Columbia University. {browse "mailto:tipton@tc.columbia.edu":tipton@tc.columbia.edu} {p_end}


{title:References}
{phang}
Pustejovsky, James E. & Elizabeth Tipton (2016). 
Small sample methods for cluster-robust variance estimation and hypothesis testing in fixed effects models. 
Journal of Business and Economic Statistics. In Press. DOI: 10.1080/07350015.2016.1247004
{p_end}

{phang}
Tipton, Elizabeth and James E. Pustejovsky (2015). Small-sample adjustments for tests of moderators and model fit 
using robust variance estimation in meta-regression. Journal of Educational and Behavioral Statistics December 2015 vol. 40 no. 6 604-634. 
DOI: 10.3102/1076998615606099
{p_end}

{phang}
Bell, R. M., & Daniel M. McCaffrey (2002). Bias reduction in standard errors for linear regression with multi-stage samples. 
Survey Methodology, 28(2), 169–181. 
Retrieved from {browse "http://www.statcan.gc.ca/pub/12-001-x/2002002/article/9058-eng.pdf"}
{p_end}

