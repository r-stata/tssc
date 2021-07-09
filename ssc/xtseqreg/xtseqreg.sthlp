{smcl}
{* *! version 1.1.2  04jun2017}{...}
{* *! Sebastian Kripfganz, www.kripfganz.de}{...}
{vieweralsosee "xtsegreg postestimation" "help xtseqreg_postestimation"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] ivregress" "help ivregress"}{...}
{vieweralsosee "[R] gmm" "help gmm"}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}
{vieweralsosee "[XT] xtivreg" "help xtivreg"}{...}
{vieweralsosee "[XT] xthtaylor" "help xthtaylor"}{...}
{vieweralsosee "[XT] xtabond" "help xtabond"}{...}
{vieweralsosee "[XT] xtdpd" "help xtdpd"}{...}
{vieweralsosee "[XT] xtdpdsys" "help xtdpdsys"}{...}
{vieweralsosee "[XT] xtset" "help xtset"}{...}
{viewerjumpto "Syntax" "xtseqreg##syntax"}{...}
{viewerjumpto "Description" "xtseqreg##description"}{...}
{viewerjumpto "Options" "xtseqreg##options"}{...}
{viewerjumpto "Remarks" "xtseqreg##remarks"}{...}
{viewerjumpto "Example" "xtseqreg##example"}{...}
{viewerjumpto "Saved results" "xtseqreg##results"}{...}
{viewerjumpto "Author" "xtseqreg##author"}{...}
{viewerjumpto "References" "xtseqreg##references"}{...}
{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{bf:xtseqreg} {hline 2}}Sequential linear panel data estimation{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}{cmd:xtseqreg} {depvar} [{cmd:(}{it:{help indepvars:varlist1}}{cmd:)}] [{it:{help indepvars:varlist2}}] {ifin} [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{synopt:{opt f:irst(first_spec)}}specify first-stage estimation results{p_end}
{synopt:{opt b:oth}}estimate both stages{p_end}
{synopt:{opt nocommon:esample}}do not restrict estimation samples to be the same{p_end}
{synopt:{opt iv(iv_spec)}}standard instruments; can be specified more than once{p_end}
{synopt:{opt gmm:iv(gmmiv_spec)}}GMM-type instruments; can be specified more than once{p_end}
{synopt:{opt w:matrix(wmat_spec)}}specify initial weighting matrix{p_end}
{synopt:{opt two:step}}compute two-step instead of one-step estimator{p_end}
{synopt:{opt te:ffects}}add time effects to the model{p_end}
{synopt:{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt conventional}, {opt ec}, or {opt r:obust}{p_end}

{syntab:Reporting}
{synopt:{opt c:ombine}}combine the estimation results for both equations{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt nohe:ader}}suppress output header{p_end}
{synopt:{opt notab:le}}suppress coefficient table{p_end}
{synopt:{opt noomit:ted}}supress omitted variables{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
{it:first_spec} is

{p 8 8 2}
[{it:name}] [{cmd:,} {opt nocons:tant} {opt eq:uation(eqno|eqname)} {opt copy}]

{p 4 6 2}
{it:iv_spec} is

{p 8 8 2}
{varlist} [{cmd:,} {it:iv_options}]

{p 4 6 2}
{it:gmmiv_spec} is

{p 8 8 2}
{varlist} [{cmd:,} {opt l:agrange(#_1 [#_2])} {opt ec} {opt c:ollapse} {it:iv_options}]

{pmore}
where {it:iv_options} are {opt d:ifference}, {opt m:odel(model)}, and {opt eq:uation(eqno|eqname)},
and where {it:model} is either {opt l:evel} or {opt d:ifference}, and {it:eqno} is either {cmd:#1} or {cmd:#2}.

{p 4 6 2}
{it:wmat_spec} is

{p 8 8 2}
[{it:wmat_type}] [{cmd:,} {opt r:atio(#)}]

{pmore}
and {it:wmat_type} is either {opt un:adjusted}, {opt ind:ependent}, or {opt sep:arate}.

{p 4 6 2}
You must {cmd:xtset} your data before using {cmd:xtseqreg}; see {helpb xtset:[XT] xtset}.{p_end}
{p 4 6 2}
{it:depvar} and all {it:varlists} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
See {helpb xtseqreg postestimation} for features available after estimation.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:xtseqreg} implements sequential estimators for linear panel models with the analytical second-stage standard error correction of Kripfganz and Schwarz (2015).

{pstd}
{cmd:xtseqreg} estimates the coefficients b2 and the corresponding standard errors for the linear panel model

{pmore2}
y - x1' b1 = x2' b2 + e

{pstd}
where x1 and x2 are the variables in {it:varlist1} and {it:varlist2}, respectively. The coefficients b1 are taken from a first-stage regression of y on x1 (and potentially additional independent variables).
At the second stage, the standard errors for the coefficients b2 need to be corrected to account for the first-stage estimation error.

{pstd}
{cmd:xtseqreg} estimates a standard linear panel model if {it:varlist1} is not specified. Ordinary least squares and two-stage least squares estimation are supported,
as well as generalized method of moments estimation in the spirit of Arellano and Bond (1991), Arellano and Bover (1995), and Blundell and Bond (1998) with flexible choice of the instruments.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{cmd:first(}[{it:name}] [{cmd:,} {it:suboptions}]{cmd:)} specifies the first-stage estimation results. By default, the last estimation results currently active in memory are used.
Specifying {it:name} is equivalent to typing {cmd:estimates restore} {it:name} prior to executing {cmd:xtseqreg}; see {helpb estimates_store:[R] estimates restore}.
Allowed {it:suboptions} are {opt nocons:tant}, {opt eq:uation(eqno|eqname)}, and {opt copy}.

{pmore}
{opt noconstant} specifies that the estimated first-stage constant term, if any, should not be included in {it:varlist1} and that an overall regression constant is estimated at the second stage.

{pmore}
{opt equation(eqno|eqname)} is relevant only when you have previously fit a multiple-equation model. It specifies the equation to which you are referring. You can refer to the equation by its equation number, {cmd:#}{it:#}, or equation name.
By default, the first equation is used.

{pmore}
{opt copy} specifies that the first-stage coefficients shall be copied from the prior estimation results by position rather than by name. Equation names are ignored when you have previously fit a multiple-equation model.
The number of coefficients must equal the number of variables in {it:varlist1}. A constant term is added to {it:varlist1} unless the suboption {cmd:noconstant} is also specified.

{phang}
{opt both} requests that both the first and the second stage are estimated. By default, the estimation results specified with the option {opt first(first_spec)} are used as first-stage estimates and only stage two is estimated.

{phang}
{opt nocommonesample} requests that the estimation sample is not restricted to be the same for both equations.

{phang}
{cmd:iv(}{varlist} [{cmd:,} {it:suboptions}]{cmd:)} specifies standard instruments. You may specify as many sets of standard instruments as you need.
Allowed {it:suboptions} are {opt d:ifference}, {opt m:odel}{cmd:(}{opt l:evel}|{opt d:ifference}{cmd:)}, and {opt eq:uation(eqno|eqname)}.

{pmore}
{opt difference} requests a first-difference transformation of {it:varlist}. This is equivalent to specifying {cmd:iv(D.(}{it:varlist}{cmd:))}; see {help tsvarlist}.

{pmore}
{opt model(model)} specifies if the instruments apply to the model in levels, {cmd:model(level)}, or in first differences, {cmd:model(difference)}. The default is {cmd:model(level)}.

{pmore}
{opt equation(eqno|eqname)} is relevant only in combination with option {cmd:both}. It specifies the equation to which you are referring and {it:eqno} should be either {cmd:#1} or {cmd:#2}.

{phang}
{cmd:gmmiv(}{varlist} [{cmd:,} {it:suboptions}]{cmd:)} specifies GMM-type instruments. These are separate instruments for each time period. You may specify as many sets of GMM-type instruments as you need.
Allowed {it:suboptions} are {opt l:agrange(#_1 [#_2])}, {opt ec}, {opt c:ollapse}, {opt d:ifference}, {opt m:odel}{cmd:(}{opt l:evel}|{opt d:ifference}{cmd:)}, and {opt eq:uation(eqno|eqname)}.

{pmore}
{opt lagrange(#_1 [#_2])} specifies the lags of {it:varlist} to be used as instruments. Negative integers are allowed to include leads. A missing value for {it:#_1} requests all available leads to be used until {it:#_2},
while a missing value for {it:#_2} requests all available lags to be used starting with {it:#_1}. Thus, {cmd:lagrange(. .)} uses all available observations. The default is {cmd:lagrange(1 .)}.

{pmore}
{opt ec} specifies instruments valid under an error-components structure with an independent and identically distributed idiosyncratic component.
These are the additional instruments implied by the linear moment conditions derived by Ahn and Schmidt (1995) under the assumption of homoskedastic errors if {it:varlist} is specified as {cmd:L.}{it:depvar}.
This suboption is seldom used and it implies the other suboptions {cmd:model(difference)} and {cmd:lagrange(0 0)}.

{pmore}
{opt collapse} requests to collapse the GMM-type instruments into standard instruments. This option is useful to reduce the number of instruments, in particular if all available lags are used.
With a limited number of lags, {cmd:lagrange(}{it:#_1 #_2}{cmd:)}, this is equivalent to specifying {cmd:iv(L(}{it:#_1}{cmd:/}{it:#_2}{cmd:).}{it:varlist}{cmd:)}.

{pmore}
{opt difference} requests a first-difference transformation of {it:varlist}. This is equivalent to specifying {cmd:gmmiv(D.(}{it:varlist}{cmd:))}; see {help tsvarlist}.

{pmore}
{opt model(model)} specifies if the instruments apply to the model in levels, {cmd:model(level)}, or in first differences, {cmd:model(difference)}. The default is {cmd:model(level)}.

{pmore}
{opt equation(eqno|eqname)} is relevant only in combination with option {cmd:both}. It specifies the equation to which you are referring and {it:eqno} should be either {cmd:#1} or {cmd:#2}.

{phang}
{cmd:wmatrix(}[{it:wmat_type}] [{cmd:,} {opt r:atio(#)}]{cmd:)} specifies the weighting matrix to be used to obtain one-step GMM estimates or initial estimates for two-step GMM estimation.
{it:wmat_type} is either {opt un:adjusted}, {opt ind:ependent}, or {opt sep:arate}.

{pmore}
{cmd:wmatrix(unadjusted)}, the default, is optimal for an error-components structure with a unit-specific component and an independent and identically distributed idiosyncratic component
if all instruments refer to the model in first differences or if the variance ratio of the unit-specific error component to the idiosyncratic error component is known.
This ratio can be specified with the suboption {opt ratio(#)}. The default is {cmd:ratio(0)}.

{pmore}
{cmd:wmatrix(independent)} is the same as {cmd:wmatrix(unadjusted)} but treats the models in levels and first differences as independent, thus ignoring the covariance between the respective error terms.

{pmore}
{cmd:wmatrix(separate)} is the same as {cmd:wmatrix(unadjusted)} but treats the models in levels and first differences as separate models with an independent and identically distributed error term for the model in first differences,
thus ignoring the covariance between the respective error terms and the first-order serial correlation of the first-differenced error term.

{phang}
{opt twostep} requests the two-step GMM estimator to be computed that is based on an optimal weighting matrix.  The optimal weighting matrix is computed using one-step GMM estimates based on the initial weighting matrix.
An unrestricted estimate of the optimal weighting matrix is computed unless {cmd:vce(ec)} is specified in which case a restricted estimate based on an error-components structure is computed.
By default, the one-step GMM estimator is used based on the initial weighting matrix specified with option {opt wmatrix(wmat_spec)}.

{phang}
{opt teffects} requests that time-specific effects are added to the model. The first time period in the estimation sample is treated as the base period.
If {it:varlist1} is specified, the time effects are added to the first-stage regression if option {cmd:both} is also specified and otherwise to the second-stage regression.

{phang}
{opt noconstant}; see {helpb estimation options##noconstant:[R] estimation options}.

{dlgtab:SE/Robust}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory ({opt conventional}, {opt ec}) and that are robust to some kinds of misspecification ({opt robust}).

{pmore}
{cmd:vce(conventional} [{cmd:,} {opt d:ifference}]{cmd:)} uses the conventionally derived variance estimator. It is robust to some kinds of misspecification if the two-step GMM estimator is used.
The suboption {cmd:difference} requests the error variance to be computed from the first-differenced residuals. {cmd:vce(conventional)} is the default, although in most cases {cmd:vce(robust)} would be recommended.

{pmore}
{cmd:vce(ec)} assumes an error-components structure with a unit-specific component and an independent and identically distributed idiosyncratic component.

{pmore}
{cmd:vce(robust)} uses the sandwich estimator for one-step GMM estimation. For two-step GMM estimation, it computes the conventional estimator with the Windmeijer (2005) correction.

{dlgtab:Reporting}

{phang}
{opt combine} combines the estimation results for both equations if {it:varlist1} is specified instead of displaying them as separate equations.
This option implies the options {opt noheader} and {opt noomitted} and affects the behavior of postestimation commands that compute equation-specific statistics; see {helpb xtseqreg postestimation}.

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt noheader} suppresses display of the header above the coefficient table that displays the number of observations and instruments.

{phang}
{opt notable} suppresses display of the coefficient table.

{phang}
{opt noomitted}; see {helpb estimation options##display_options:[R] estimation options}.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:xtseqreg} can be used to fit both stages of a sequential regression. At the first stage,

{pmore}
{cmd:xtseqreg} {it:depvar} {it:varlist1} {ifin} [{cmd:,} {it:options}]

{pstd}
fits a linear panel model of {it:depvar} on {it:varlist1}. At the second stage,

{pmore}
{cmd:xtseqreg} {it:depvar} {cmd:(}{it:varlist1}{cmd:)} {it:varlist2} {ifin} [{cmd:,} {it:options}]

{pstd}
fits a linear panel model of {it:depvar}, adjusted for the impact of {it:varlist1}, on {it:varlist2}.
It is often the case that {it:varlist1} constitutes time-varying independent variables and {it:varlist2} time-invariant independent variables.

{pstd}
See Kripfganz and Schwarz (2015) for background information about the analytical standard error correction in the context of sequential GMM estimation of linear dynamic panel models with time-invariant regressors.


{marker example}{...}
{title:Example}

{pstd}Setup{p_end}
{phang2}{stata webuse psidextract:. webuse psidextract}{p_end}

{pstd}Fit a first-stage model for time-varying indepvars with OLS{p_end}
{phang2}{stata xtseqreg lwage wks south smsa ms exp exp2 occ ind union:. xtseqreg lwage wks south smsa ms exp exp2 occ ind union}{p_end}

{pstd}Fit a second-stage model for time-invariant indepvars with OLS{p_end}
{phang2}{stata xtseqreg lwage (wks south smsa ms exp exp2 occ ind union) fem blk ed:. xtseqreg lwage (wks south smsa ms exp exp2 occ ind union) fem blk ed}{p_end}


{marker results}{...}
{title:Saved results}

{pstd}
{cmd:xtseqreg} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(sigma2e)}}estimate of sigma_e^2; not always saved{p_end}
{synopt:{cmd:e(sigma2u)}}estimate of sigma_u^2; not always saved{p_end}
{synopt:{cmd:e(twostep)}}= {cmd:1} if the two-step GMM estimator is computed{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtseqreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:e(tvar)}}variable denoting time{p_end}
{synopt:{cmd:e(estat_cmd)}}{cmd:xtseqreg_estat}{p_end}
{synopt:{cmd:e(predict)}}{cmd:xtseqreg_p}{p_end}
{synopt:{cmd:e(teffects)}}time effects created with option {cmd:teffects}{p_end}
{synopt:{cmd:e(ivvars_1)}}standard instruments for equation #1{p_end}
{synopt:{cmd:e(gmmivvars_1)}}GMM-type instruments for equation #1{p_end}
{synopt:{cmd:e(divvars_1)}}standard instruments for differenced equation #1{p_end}
{synopt:{cmd:e(dgmmivvars_1)}}GMM-type instruments for differenced equation #1{p_end}
{synopt:{cmd:e(ecivvars_1)}}collapsed EC instruments for differenced equation #1{p_end}
{synopt:{cmd:e(ecgmmivvars_1)}}GMM-type EC instruments for differenced equation #1{p_end}
{synopt:{cmd:e(ivvars_2)}}standard instruments for equation #2{p_end}
{synopt:{cmd:e(gmmivvars_2)}}GMM-type instruments for equation #2{p_end}
{synopt:{cmd:e(divvars_2)}}standard instruments for differenced equation #2{p_end}
{synopt:{cmd:e(dgmmivvars_2)}}GMM-type instruments for differenced equation #2{p_end}
{synopt:{cmd:e(ecivvars_2)}}collapsed EC instruments for differenced equation #2{p_end}
{synopt:{cmd:e(ecgmmivvars_2)}}GMM-type EC instruments for differenced equation #2{p_end}
{synopt:{cmd:e(wmatrix)}}{it:wmat_spec} specified with option {cmd:wmatrix()}{p_end}
{synopt:{cmd:e(vce)}}{cmd:conventional}, {cmd:ec}, or {cmd:robust}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance; not always saved{p_end}
{synopt:{cmd:e(W)}}weighting matrix{p_end}
{synopt:{cmd:e(b_onestep)}}one-step GMM coefficients; not always saved{p_end}
{synopt:{cmd:e(V_onestep)}}one-step GMM variance; not always saved{p_end}
{synopt:{cmd:e(W_onestep)}}one-step GMM weighting matrix; not always saved{p_end}
{synopt:{cmd:e(stats)}}equation-specific statistics{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{marker author}{...}
{title:Author}

{pstd}
Sebastian Kripfganz, University of Exeter, {browse "http://www.kripfganz.de"}


{marker references}{...}
{title:References}

{phang}
Ahn, S. C., and P. Schmidt. 1995.
Efficient estimation of models for dynamic panel data.
{it:Journal of Econometrics} 68: 5-27.

{phang}
Arellano, M., and S. R. Bond. 1991.
Some tests of specification for panel data: Monte Carlo evidence and an application to employment equations.
{it:Review of Economic Studies} 58: 277-297.

{phang}
Arellano, M., and O. Bover. 1995.
Another look at the instrumental variable estimation of error-components models.
{it:Journal of Econometrics} 68: 29-51.

{phang}
Blundell, R., and S. R. Bond. 1998.
Initial conditions and moment restrictions in dynamic panel data models.
{it:Review of Economic Studies} 87: 115-143.

{phang}
Kripfganz, S., and C. Schwarz. 2015.
Estimation of linear dynamic panel data models with time-invariant regressors.
{it:ECB Working Paper} 1838. European Central Bank.

{phang}
Windmeijer, F. 2005.
A finite sample correction for the variance of linear efficient two-step GMM estimators.
{it:Journal of Econometrics} 126: 25-51.
