{smcl}
{* 28apr19 Orsini N}{...}
{cmd:help drmeta}
{hline}

{title:Title}

{p2colset 6 16 18 2}{...}
{p2col :{hi: drmeta} {hline 2}}Dose-response meta-analysis of summarized data{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 24 2}
{cmd:drmeta} {depvar} {it:dose_vars} {ifin} {cmd:,} [ {it:options} ]

        
{synoptset 24 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{synopt :{opth s:e(varname)}} standard error of {depvar}{p_end}
{synopt :{opt d:ata(varname1 varname2)}} crude data{p_end} 
{synopt :{opt i:d(varname)}} study-specific contrasts{p_end} 
{synopt :{opt t:ype(varname)}} type of {depvar}{p_end} 
{synopt :{opt or}} odds ratio{p_end}
{synopt :{opt rr}} risk ratio{p_end}
{synopt :{opt hr}} hazard ratio{p_end}
{synopt :{opt md}} mean difference{p_end}
{synopt :{opt smd}} standardized mean difference{p_end}
{synopt :{opt vwls}} variance-weighted least squares estimation{p_end}
{synopt :{opt 2stage}} two-stage dose-response meta-analysis{p_end} 
{synopt :{opt ml}} maximum likelihood method{p_end}
{synopt :{opt reml}} restricted maximum likelihood method{p_end}
{synopt :{opt fixed}} fixed-effects method{p_end}
{synopt :{opt h:amling}} Hamling's method for the covariances{p_end}
{synopt :{opt ac:ov(varname)}} passes average covariance as variable{p_end}
{synopt :{opt mc:ov(matrix_list)}} passes var/cov as matrices{p_end}

{synoptset 24 tabbed}{...}
{syntab:Reporting}
{synopt :{opt l:evel(#)}} set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt ef:orm}} generic label; {cmd:exp(b)}; the default{p_end}
{synopt :{opt noret:able}} suppress random-effects table{p_end}
{synopt :{opt stddev:iations}} show random-effects and residual-error parameter estimates as standard deviations and correlations{p_end}
{synopt :{opt nolr:t}} suppress likelihood-ratio test for random-effects{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2} where {depvar} contains empirical estimates of contrasts in responses;
{it:dose_vars} specifies what are the variables to model the dose (polynomials, splines).{p_end}  
{p 4 6 2}After {cmd:drmeta}, the command {helpb drmeta_graph:drmeta_graph} can be useful to plot the estimated dose-response model. 
The {helpb drmeta_predict:predict} command saves different types of predicted values (fixed, random, fixed plus random).
The {helpb drmeta_gof:drmeta_gof} provides tools to evaluate the goodness-of-fit of the model.
Standard post-estimation commands such as {helpb testparm:testparm} and {helpb predictnl:predictnl} can be used.

{title:Description}

{pstd}

{p 4 8 2}{cmd:drmeta} estimates parametric dose-response models based on summarized data. It can be used to investigate linear and non-linear 
dose-response relationships. It fits fixed-effects and random-effects model using 
a one-stage or a two-stage approach. Effect measures include odds ratios, risk ratios, hazard ratios, mean differences, and standardized mean differences. 

{title:Options}

{dlgtab:Model}

{phang}
{opth s:e(varname)} specifies an estimate of the standard error of {depvar}. It is a required option.

{phang}
{opt d:ata(varname1 varname2)} specifies variables containing the information required to reconstruct the covariances of {depvar}.  
It is a required option. At each exposure level, {it:varname1} is the number of subjects (controls plus cases) for case-control data (or); 
or the total person-time for incidence rate data (hr); the total number of persons (cases plus non-cases) for cumulative incidence data (rr). 
The variable {it:varname2} contains the number of cases at each exposure level. 
In case {depvar} are mean differences and standardized mean differences total, the variable {it:varname1} indicates the total number of persons 
and the variable {it:varname2} contains the standard deviation of the outcome at each exposure level.
Any missing values in either of the two variables set to zero the covariances. 
{p_end}

{phang}
{opt or} specifies odds ratio data. It's required for trend estimation of a single study unless the option {opt type(varname)} is specified.{p_end}

{phang}
{opt hr} specifies hazard ratio data. It's required for trend estimation of a single study unless the option {opt type(varname)} is specified.{p_end}

{phang}
{opt rr} specifies risk ratio data. It's required for trend estimation of a single study unless the option {opt type(varname)} is specified.{p_end}

{phang}
{opt md} specifies mean difference data. It's required for trend estimation of a single study unless the option {opt type(varname)} is specified.{p_end}

{phang}
{opt smd} specifies standardized mean difference data. It's required for trend estimation of a single study unless the option {opt type(varname)} is specified.{p_end}

{phang}
{opt vwls} sets to zero the covariances of {depvar} within each study.{p_end}

{phang}
{opt h:amling} specifies the Hamling's method to estimate the covariances in case {depvar} is a log relative risk (Stat Med. 2008. 27(7):954-70). 
The default is the Greenland and Longnecker's method (AJE. 1992. 135(11), pp.1301-1309). In case {depvar} is a mean difference or a standardized mean
difference, the method used for the covariance is described by Crippa and Orsini (BMC Med Res Methodol. 2016 Aug 2;16:91).{p_end}

{phang}
{opt 2stage} specifies the two-stage approach for dose-response meta-analysis. It is calling the 
{cmd:mvmeta} command. The default is the one-stage approach.{p_end}

{phang}
{opt i:d(varname)} specifies the variable identyfing study-specific contrasts. The reference dose is the row with a value of 0 for the standard error. 
This option is required with multiple studies.{p_end}

{phang}
{opt t:ype(varname)} specifies the variable indicating the type of measure used to contrast dose levels. It can take on value 1 for odds ratio, 
2 for hazard ratio, 3 for risk ratio, 4 for mean difference, and 5 for standardized mean difference.{p_end}

{phang}
{opt ac:ov(varname)} passes average covariance as variable.{p_end}

{phang}{opt mc:ov(matrix_list)} passes a list of variance/covariance matrices, one for each study. It is an advanced option where the order of the matrix list matters. 
The first matrix is supposed to be related to the first set of contrasts and so on. It can be useful when empirical contrasts and related variance/covariance
matrices are available directly from fitting a model on primary data. So this option allows the user to skip the specification of the {opt d:ata()} option.{p_end}

{phang}{opt ml} fit random-effects model via maximum likelihood (ML); the default. All variances and covariances of the random-effects are allowed to be distinct.
So if {it:dose_vars} includes {it:p} variables, then an additional {it:p}({it:p}+1)/2 random-effects parameters are estimated.{p_end}

{phang}{opt reml} fit random-effects model via restricted maximum likelihood (REML). All variances and covariances of the random-effects are allowed to be distinct.
So if {it:dose_vars} includes {it:p} variables, then an additional {it:p}({it:p}+1)/2 random-effects parameters are estimated.{p_end}

{dlgtab:Reporting}
 
{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
{opt eform} reports coefficient estimates as exp(b) rather than b.  Standard errors and confidence
intervals are similarly transformed. 

{phang}
{opt noret:able} suppress the random-effects parameter estimates.

{phang}
{opt stddev:iations} displays the random-effects parameter estimates as standard deviations and correlations. 

{phang}
{opt nolr:t} suppress the likelihood-ratio test for the unstructured variance/covariance components. It assesses whether all random-effects parameters 
of the dose-response model are simultaneously zero. Of note, the likelihood-ratio test is {help j_mixedlr##|_new:conservative}.

{title:Example 1 - Observational cohort studies on alcohol consumption and colorectal cancer risk}

* Read data described by Orsini et al. AJE 2012
 
    {stata "use http://www.stats4life.se/data/ex_alcohol_crc.dta, clear"}
 
* Model 1. One-stage random-effects dose-response model assuming a linear trend

    {stata "drmeta logrr dose , data(peryears cases) id(study) type(type) se(se) reml"} 
	{stata "lincom dose*12, eform"}
	{stata "drmeta_graph , dose(0(1)60) ref(10) equation(d) eform"}

* Model 2. One-stage random-effects dose-response model using restricted cubic splines
	
    {stata "mkspline doses = dose, nk(3) cubic"}  
	{stata "mat knots = r(knots)"}
	{stata "drmeta logrr doses1 doses2 , data(peryears cases) id(study) type(type) se(se) reml"} 
	{stata "drmeta_graph , dose(0(1)60) ref(10) matk(knots) eform"}

* Model 3. Two-stage random-effects dose-response model using restricted cubic splines

    {stata "drmeta logrr doses1 doses2 , data(peryears cases) id(study) type(type) se(se) reml 2stage"} 
    {stata `"drmeta_graph , dose(0(1)60) ref(10) matk(knots) eform ytitle("Relative Risk") xtitle("Alcohol consumption (g/day)")"'}

{title:Example 2 - Randomized trials on effectiveness of aripiprazole in schizoaffective patients} 

* Read data described by Crippa & Orsini. BMC Med Res Methodol. 2016 Aug 2;16:91.
 
    {stata "use http://www.stats4life.se/data/aripanss, clear"}

* Model 1. One-stage random-effects dose-response model assuming a quadratic trend

    {stata "drmeta md dose dosesq , se(se_md) data(n sd) id(id) type(type_md)"} 
    {stata `"drmeta_graph ,  d(0(1)30) ref(0) eq(d d^2) ytitle("Mean difference") xtitle("Ariprazole (mg/day)") "'}
	
{title:References}

{p 4 8 2}Crippa A, Discacciati A, Bottai M, Spiegelman D, and Orsini N. One-stage dose–response meta-analysis for aggregated data. {it:Stat Methods Med Res}. 2019 May;28(5):1579-1596.{p_end}

{p 4 8 2}Crippa A, Orsini N. Dose-response meta-analysis of differences in means. {it:BMC Med Res Methodol}. 2016 Aug 2;16(1):91.{p_end}

{p 4 8 2}Orsini N, Ruifeng L, Wolk A, Khudyakov P, Spiegelman D. Meta-analysis for linear and non-linear dose-response relationships: examples, an evaluation of approximations, and software. {it:American Journal Epidemiology}. 2012 Jan 1;175(1):66-73.

{p 4 8 2}Hamling J, Lee P, Weitkunat R, Ambühl M. Facilitating meta-analyses by deriving relative effect and precision estimates for alternative comparisons from a set of estimates presented by exposure level or disease category.
 {it:Statistics in Medicine}. 2008 Mar 30;27(7):954-70.{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:drmeta} stores the following in {cmd:e()}:

{synoptset 23 tabbed}{...}
{p2col 5 23 25 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_f)}}number of fixed-effects parameters{p_end}
{synopt:{cmd:e(k_r)}}number of random-effects parameters{p_end}
{synopt:{cmd:e(N_s)}}number of sets of contrasts{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(p)}}p-value for model test{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(ll_c)}}log likelihood, comparison model{p_end}
{synopt:{cmd:e(lrt_c)}}likelihood ratio test, comparison test{p_end}
{synopt:{cmd:e(df_c)}}degrees of freedom, comparison test{p_end}
{synopt:{cmd:e(p_c)}}p-value for comparison test{p_end}
{synopt:{cmd:e(r2)}}overall coefficient of determination (R-squared){p_end}
{synopt:{cmd:e(D)}}overall deviance statistic{p_end}
{synopt:{cmd:e(p_D)}}p-value of the overall deviance statistic{p_end}
{synopt:{cmd:e(Q)}}Cochran Q-test for heterogeneity ({cmd:Two-stage}){p_end}
{synopt:{cmd:e(Q_df)}}degrees of freedom of the Q-test{p_end}
{synopt:{cmd:e(Q_p)}}p-value of the Q-test{p_end}

{synoptset 23 tabbed}{...}
{p2col 5 23 25 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:drmeta}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(idname)}}name of sets of contrasts{p_end}
{synopt:{cmd:e(id)}}values of the sets of contrasts{p_end}
{synopt:{cmd:e(se)}}name of standard errors of contrasts{p_end}
{synopt:{cmd:e(dm)}}names specified in {it:dose_vars}{p_end}
{synopt:{cmd:e(method)}}{cmd:ml} or {cmd:reml}{p_end}
{synopt:{cmd:e(mtype)}}{cmd:fixed} or {cmd:random}{p_end}
{synopt:{cmd:e(proc)}}{cmd:One-stage} or {cmd:Two-stage}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 23 tabbed}{...}
{p2col 5 23 25 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector of fixed effects{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of fixed effects{p_end}
{synopt:{cmd:e(Psi)}}variance-covariance matrix of random effects{p_end}
{synopt:{cmd:e(PsiC)}}correlation matrix of random effects{p_end}
{synopt:{cmd:e(Sigma)}}variance-covariance matrices of all sets of contrasts{p_end}
{synopt:{cmd:e(bs#)}}coefficient vector for the # set of contrasts (GLS) in e(id){p_end}
{synopt:{cmd:e(vs#)}}variance-covariance matrix for the # set of contrasts (GLS) in e(id){p_end}
{synopt:{cmd:e(X#)}}design matrix used for the # set of contrasts in e(id){p_end}
{synopt:{cmd:e(Sigma#)}}variance-covariance matrix for the # set of contrasts in e(id){p_end}
{synopt:{cmd:e(xbu#)}}coefficient vector (fixed+BLUP) for the # set of contrasts in e(id){p_end}
{synopt:{cmd:e(blup#)}}predicted random-effects (BLUP) for the # set of contrasts in e(id){p_end}

{synoptset 23 tabbed}{...}
{p2col 5 23 25 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{title:Author}

{p 4 8 2}Nicola Orsini, Biostatistics Team,
Department of Public Health Sciences, Karolinska Institutet, Sweden{p_end}

{title:Support}

{p 4 8 2}{browse "http://www.stats4life.se"}{p_end}
{p 4 8 2}{browse "mailto:nicola.orsini@ki.se?subject=drmeta":nicola.orsini@ki.se}{p_end}

{title:Also see}

{p 10 14}{helpb glst:glst}, {helpb drmeta_graph:drmeta_graph}, {helpb drmeta_predict:predict}, {helpb drmeta_gof:drmeta_gof}{p_end}

