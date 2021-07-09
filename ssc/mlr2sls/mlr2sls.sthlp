{smcl}
{viewerjumpto "Syntax" "mlr2sls##syntax"}{...}
{viewerjumpto "Description" "mlr2sls##description"}{...}
{viewerjumpto "Options" "mlr2sls##options"}{...}
{viewerjumpto "Examples" "mlr2sls##examples"}{...}
{viewerjumpto "Saved results" "mlr2sls##saved_results"}{...}
{viewerjumpto "References" "mlr2sls##references"}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :mlr2sls {hline 2}}Multiple-LATEs-robust standard error for 2SLS{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:mlr2sls} {depvar} [{it:{help varlist:varlist1}}]
{cmd:(}{it:{help varlist:varlist2}} {cmd:=}
        {it:{help varlist:varlist_iv}}{cmd:)} {ifin}
[{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be
   {opt mlcr:obust} {it:clustvar}, {opt conv:entional}, or {opt ccl:uster} {it:clustvar}; default is {opt mlr:obust} {p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}{it:varlist1} and {it:varlist_iv} may 
contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}{it:depvar}, {it:varlist1}, {it:varlist2}, and {it:varlist_iv} may 
contain time-series operators; see {help tsvarlist}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:mlr2sls} fits a linear regression of {depvar} on 
{it:{help varlist:varlist1}} and {it:varlist2}, using {it:varlist_iv} 
(along with {it:varlist1}) as instruments for {it:varlist2}.  

{pstd}
{cmd:mlr2sls} supports estimation of standard errors robust to multiple
local average treatment effects (LATEs).

{pstd}
In the language of instrumental variables, {it:varlist1} are the included exogenous variables
and {it:varlist_iv} are the excluded exogenous variables, and {it:varlist2} are the endogenous variables.

{marker options}{...}
{title:Options}

{dlgtab:SE/Robust}

{marker vce}{...}
{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are
robust to multiple-LATEs and heteroscedasticity as default ({cmd:mlrobust}),
that are robust to intragroup correlation as well ({cmd:mlcrobust} {it:clustvar}),
that are robust to heteroskedasticity but not to multiple-LATEs ({cmd:conventional}), 
and that are robust to intragroup correlation ({cmd:ccluster} {it:clustvar}).

{pmore}
At most two cluster variables are allowed after {cmd:mlcrobust} or {cmd:ccluster}.
When two cluster variables are specified, two-way clustering standard errors will be calculated.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see 
{helpb estimation options##level():[R] estimation options}.

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse hsng2}{p_end}

{pstd}Fit a regression via 2SLS, requesting multiple-LATEs-robust standard errors{p_end}
{phang2}{cmd:. mlr2sls rent pcturban (hsngval = faminc i.region), vce(mlrobust)}{p_end}

{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:mlr2sls} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mlr2sls}{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(exogr)}}exogenous regressors{p_end}
{synopt:{cmd:e(insts)}}instruments{p_end}
{synopt:{cmd:e(instd)}}instrumented variable{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{marker references}{...}
{title:References}

{marker A1991}{...}
{phang}
Lee S. (2017) Consistent Variance Estimator for 2SLS When Instruments Identify Different LATEs. {it:Journal of Business & Economic Statistics}.{p_end}
