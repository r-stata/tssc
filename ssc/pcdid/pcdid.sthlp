{smcl}

{title:Title}

{phang}
{bf:pcdid} {hline 2} Principal components difference-in-differences


{title:Description}

{pstd}
{bf:pcdid} implements factor-augmented difference-in-differences (DID) estimation. It is useful in situations where the user suspects that trends may be unparallel and/or stochastic among control and treated units. 
The data structure is similar to that in a DID setup. The estimation method is regression-based and can be considered as an extension of conventional DID regressions. 
{p_end}

{pstd}
{bf:pcdid} also implements a parallel trend alpha test (based on an interactive effects structure) and a recursive procedure that determines the number of factors automatically.
{p_end}

{pstd}
For further details, please see {help pcdid##ck:Chan and Kwok (2016, 2020)} who developed the {bf:pcdid} approach and the alpha test.
{p_end}


{title:Quick start}

{pstd}
Consider the following list of variables in a long-form panel data set:

{synopthdr:variable}
{synoptline}
{synoptset 20 tabbed}{...}
{synopt:{opt id}}     unit identifier {p_end }
{synopt:{opt time}}   time variable {p_end }
{synopt:{opt y}}      dependent variable {p_end }
{synopt:{opt treated}} =1 for treated units; =0 for control (never-treated) units {p_end }
{synopt:{opt treated_post}} =1 for all observations from treated units after policy intervention; =0 otherwise {p_end }
{synopt:{opt x1, x2, ...}} other covariates {p_end }
{synoptline}
{p2colreset}{...}

{pstd}You must declare your data as panel data before using {cmd:pcdid}: {p_end}
{phang2} {cmd: xtset id time} {p_end}

{pstd} PCDID model with the number of factors determined automatically: {p_end}
{phang2} {cmd: pcdid y treated treated_post x1 x2} {p_end}

{pstd}Create {bf:yhat} containing the prediction from the previous {cmd:pcdid} command: {p_end}
{phang2} {cmd: pdd yhat} {p_end}

{pstd}Create {bf:yhat0} containing the counterfactual outcomes: {p_end}
{phang2} {cmd: replace treated_post=0} {p_end}
{phang2} {cmd: pdd yhat0} {p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:pcdid}
{it:depvar treatvar}
[{it:didvars indepvars}] [{it:if}]
[{cmd:,}
{it:options}]


{synopthdr: Object}
{synoptline}
{synoptset 20 tabbed}{...}
{syntab:Variable}
{synopt:{it:depvar}} dependent variable{p_end }
{synopt:{it:treatvar}} control/treated unit indicator variable (=0,1){p_end }
{synopt:{it:didvars}} treatment variable(s) (discrete or continuous){p_end }
{synopt:{it:indepvar}} other covariate(s){p_end }


{syntab:Options}
{synopt:{opt a:lpha}} 	perform the parallel trend alpha test. {it:(Note: irrelevant if there is only one treated unit.)} {p_end }
{synopt:{opt f:proxy(#)}} set number of factors used. If this option is not specified, the number of factors will be automatically determined by the recursive factor number test.{p_end }
{synopt:{opt s:tationary}} advanced option: assume all factors are stationary in the recursive factor number test. {it:(Note: irrelevant if fproxy(#) is specified.)}{p_end }
{synopt:{opt k:max(#)}} advanced option: set maximum number of factors in the recursive factor number test; default is 10. {it:(Note: irrelevant if fproxy(#) is specified.)}{p_end }
{synopt:{opt tr:eatlist(string)}} restrict the treated unit(s) to the one(s) specified in the string expression{p_end }
{synopt:{opt nw:lag(#)}} set maximum lag order of autocorrelation in computing Newey-West standard errors; default is int(T^0.25). {it:(Note: irrelevant if there is more than one treated unit.)}{p_end }
{synopt:{opt pd:all}} compute coefficients needed for predicting control unit outcomes. If this option is not specified, the postestimation {cmd:pdd} command will set all predicted control unit outcomes to zero{p_end }
{synoptline}
{p2colreset}{...}

{pstd}The postestimation command for generating predictions is

{p 8 17 2}
{cmdab:pdd}
{it:newvar}

{pstd}(Note: you must use {cmd:pdd} instead of {cmd:predict}, which is invalid in this setting.){p_end}


{title:Remarks and Examples}

{pstd} {cmd:pcdid} first uses a data-driven method (based on principal component analysis) on the control panel to compute factor proxies, which capture the unobserved trends. 
Then, among treated unit(s), it runs regression(s) using the factor proxies as extra covariates. 
Analogous to a control function approach, these extra covariates capture the endogeneity arising from potentially unparallel trends. {p_end}

{pstd}{cmd:pcdid} also allows for inclusion of other observed time-varying covariates. (Time-invariant covariates are subsumed by fixed effects.) 
{cmd:pcdid} is robust to the specification of trends, e.g., it encompasses nonstationary trends. {p_end}

{pstd} When there are multiple treated units in the data, {cmd:pcdid} computes the mean-group (PCDID-MG) estimator for the treated units. 
This estimator targets the ATET casual parameter. Standard errors are obtained from a nonparametric mean-group variance formula. {p_end}

{pstd} When there is only one treated unit in the data, {cmd:pcdid} computes a basic (PCDID-basic) estimator for that treated unit. 
This estimator targets the ITET casual parameter. Standard errors are obtained from the Newey-West variance formula. {p_end}

{pstd} For more details about the properties of these estimators, their target causal parameters, and the parallel trend alpha test, 
see {help pcdid##ck:Chan and Kwok (2016, 2020)} in the reference list. The paper also contains a recursive procedure to factor extraction, adapted from Ahn and Horenstein (2013)’s growth-ratio (GR) test. {p_end}

{pstd} The latest version of the materials, paper and additional remarks/examples can be found at {browse "https://sites.google.com/site/marcchanecon/"}. {p_end}


{pstd}{ul: Additional example 1:} {p_end}

{pstd} The following command implements pcdid estimation with 3 factor proxies and performs the parallel trend alpha test. {p_end}

{phang2} {cmd: pcdid y treated treated_post x1 x2, alpha fp(3)} {p_end}


{pstd}{ul: Additional example 2:} {p_end}

{pstd} We can have more than one treatment variable. For example, suppose {bf:treated_post2} =1 for all observations from treated units that are at least 3 periods after policy intervention, =0 otherwise. {p_end}

{pstd} The following command captures a step function of treatment effects over time. {p_end}

{phang2} {cmd: pcdid y treated treated_post treated_post2 x1 x2} {p_end}


{pstd}{ul: Additional example 3:} {p_end}

{pstd}Suppose {bf:id==1} is a treated unit. The following command implements pcdid-basic estimation on this treated unit, using a NW lag order of 3:{p_end}

{phang2} {cmd: pcdid y treated treated_post x1 x2, tr(id==1) nwlag(3)} {p_end}


{pstd}{ul: Additional example 4:} {p_end}

{pstd}Generate predicted outcomes and residuals for all control and treated units:{p_end}

{phang2} {cmd: pcdid y treated treated_post x1 x2, pdall} {p_end}
{phang2} {cmd: pdd yhat} {p_end}
{phang2} {cmd: gen resid = y - yhat} {p_end}

{pstd}Generate counterfactual outcomes assuming no treatment:{p_end}

{phang2} {cmd: replace treated_post = 0} {p_end}
{phang2} {cmd: pdd yhat0} {p_end}

{pstd}Generate counterfactual outcomes assuming no treatment and {bf:x1=1}:{p_end}

{phang2} {cmd: replace treated_post = 0} {p_end}
{phang2} {cmd: replace x1 = 1} {p_end}
{phang2} {cmd: pdd yhat01} {p_end}

{pstd}Then plot the outcomes for {bf:id==1}:{p_end}

{phang2} {cmd: line y yhat yhat0 yhat01 time if id==1} {p_end}


{title:Stored results}

{pstd} {cmd:pcdid} saves the factor proxies in a separate data file called {cmd:fproxy.dta} (variables: {bf: fproxy1, fproxy2, ...}). Make sure that there are no naming conflicts with your other data sets and variables.{p_end}

{pstd} {cmd:pcdid} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(Ne)}} number of treated units{p_end}
{synopt:{cmd:e(Nc)}} number of control units{p_end}
{synopt:{cmd:e(T)}} number of time periods{p_end}
{synopt:{cmd:e(nobs)}} number of observations{p_end}
{synopt:{cmd:e(factnum)}} number of factors used{p_end}
{synopt:{cmd:e(factnum0)}} number of I(0) factors determined by the recursive procedure{p_end}
{synopt:{cmd:e(factnum1)}} number of I(1) factors determined by the recursive procedure{p_end}
{synopt:{cmd:e(alphastat)}} alpha statistic{p_end}
{synopt:{cmd:e(alphastatse)}} alpha statistic standard error{p_end}
{synopt:{cmd:e(alphastatz)}} alpha statistic z-score{p_end}
{synopt:{cmd:e(alphastatp)}} alpha statistic p-value{p_end}
{synopt:{cmd:e(kmax)}} maximum number of factors set by user{p_end}
{synopt:{cmd:e(nwlag)}} maximum lag order for Newey-West standard error{p_end}
{synopt:{cmd:e(treatlistnum)}} =0 if e(treatlist) is empty, =1 otherwise{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}} "pcdid"{p_end}
{synopt:{cmd:e(id)}} id variable in xtset{p_end}
{synopt:{cmd:e(time)}} time variable in xtset{p_end}
{synopt:{cmd:e(depvar)}} dependent variable{p_end}
{synopt:{cmd:e(treatvar)}} control/treated unit indicator variable{p_end}
{synopt:{cmd:e(indeps)}} treatment variable(s) and other covariates{p_end}
{synopt:{cmd:e(treatlist)}} string expression specified by the treatlist option{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}} coefficient{p_end}
{synopt:{cmd:e(V)}} variance{p_end}
{synopt:{cmd:e(mata)}} unit-specific coefficients for the alpha test{p_end}
{synopt:{cmd:e(matb)}} unit-specific coefficients (treated units) for the pcdid estimator{p_end}
{synopt:{cmd:e(matc)}} unit-specific coefficients (control units; for predictions only){p_end}
{synopt:{cmd:e(bmgc)}} number of treated units used in computing each MG coefficient{p_end}


{title:References}{marker ck}

{pstd}Ahn, S. and A. Horenstein (2013): Eigenvalue Ratio Test for the Number of Factors. Econometrica, 81, 1203-1227.{p_end}

{pstd}Chan, M.K. and S. Kwok (2020): The PCDID Approach: Difference-in-Differences when Trends are Potentially Unparallel and Stochastic. {p_end}
{pstd}({it:Previously circulated as: Policy Evaluation with Interactive Fixed Effects. University of Sydney working paper, 2016.}) {p_end}


{title:Compatibility and known issues}
{p 8 8 8}

{pstd} This is version 1.0 of the program (date: Feb 09, 2021). {p_end}

{pstd}The following are required to run the program: {p_end}
{phang2} . Stata 14.0 or higher by default, although users may modify the {help version} line in the ado file such that it can be run under an earlier version of Stata {p_end}
{phang2} . The data must be recognized as panel data by Stata with the command {help xtset} {p_end}

{pstd}In the PCDID-basic estimator (one treated unit), the command uses the {help newey} package to estimate the variance matrix. It may be sensitive to issues inherent to the {help newey} command.{p_end}

{pstd} The latest version of the materials, paper and additional remarks/examples can be found at {browse "https://sites.google.com/site/marcchanecon/"}. {p_end}
