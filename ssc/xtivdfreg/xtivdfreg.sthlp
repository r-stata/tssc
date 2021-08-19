{smcl}
{* *! version 1.0.3  12feb2021}{...}
{* *! Sebastian Kripfganz, www.kripfganz.de}{...}
{* *! Vasilis Sarafidis, sites.google.com/view/vsarafidis}{...}
{vieweralsosee "xtivdfreg postestimation" "help xtivdfreg_postestimation"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] ivregress" "help ivregress"}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}
{vieweralsosee "[XT] xtivreg" "help xtivreg"}{...}
{vieweralsosee "[XT] xtset" "help xtset"}{...}
{viewerjumpto "Syntax" "xtivdfreg##syntax"}{...}
{viewerjumpto "Description" "xtivdfreg##description"}{...}
{viewerjumpto "Options" "xtivdfreg##options"}{...}
{viewerjumpto "Remarks" "xtivdfreg##remarks"}{...}
{viewerjumpto "Example" "xtivdfreg##example"}{...}
{viewerjumpto "Saved results" "xtivdfreg##results"}{...}
{viewerjumpto "Version history and updates" "xtivdfreg##update"}{...}
{viewerjumpto "Authors" "xtivdfreg##authors"}{...}
{viewerjumpto "References" "xtivdfreg##references"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{bf:xtivdfreg} {hline 2}}Defactored IV estimation of large panel data models{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}{cmd:xtivdfreg} {depvar} [{indepvars}] {ifin} [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{p2coldent :* {opt a:bsorb}{cmd:(}{it:{help xtivdfreg##absvars:absvars}}{cmd:)}}categorical variables that identify the fixed effects to be absorbed{p_end}
{synopt:{opt iv}{cmd:(}{it:{help xtivdfreg##options_spec:iv_spec}}{cmd:)}}instruments; can be specified more than once{p_end}
{synopt:{opt fact:max(#)}}specify the maximum number of factors{p_end}
{synopt:[{cmdab:no:}]{opt double:defact}}implement a further defactorization stage of the entire model for the first-stage estimator{p_end}
{synopt:{opt fstage}}use the first-stage instead of the second-stage estimator{p_end}
{synopt:{opt mg}}compute the mean-group estimator{p_end}
{synopt:{opt nocons:tant}}suppress constant term{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
INCLUDE help shortdes-coeflegend
{synopt:{opt nohe:ader}}suppress output header{p_end}
{synopt:{opt notab:le}}suppress coefficient table{p_end}
{synopt:{it:{help xtivdfreg##display_options:display_options}}}control
INCLUDE help shortdes-displayoptall

{syntab:Optimization}
{synopt:{opt noeig:ratio}}do not use the eigenvalue ratio test to determine the number of factors{p_end}
{p2coldent :# {opt iter:ate(#)}}specifies maximum {it:#} of iterations{p_end}
{p2coldent :# {opt ltol:erance(#)}}tolerance for the objective function{p_end}
{p2coldent :# {opt nodot:s}}do not display dots for the iteration steps{p_end}
{synoptline}
{p2colreset}{...}
{marker absvars}{...}
{p 4 6 2}* This option requires the community-contributed packages {cmd:reghdfe} and {cmd:ftools} to be installed; see {helpb reghdfe} and {helpb ftools}. {it:{help reghdfe##absvar:absvars}} is a list of categorical variables to be absorbed.
Typical use is {cmd:absorb(}{it:{help xtset:panelvar}}{cmd:)} or {cmd:absorb(}{it:{help xtset:panelvar}} {it:{help xtset:timevar}}{cmd:)} for one-way or two-way fixed effects, respectively.{p_end}
{p 4 6 2}# These options are only relevant for unbalanced panel data.

{marker options_spec}{...}
{p 4 6 2}
{it:iv_spec} is

{p 8 8 2}
{varlist} [{cmd:,} {opt fvar(fvars)} {opt l:ags(#)} {opt fact:max(#)} [{cmdab:no:}]{opt eig:ratio} [{cmdab:no:}]{opt double:defact}]

{p 4 6 2}
You must {cmd:xtset} your data before using {cmd:xtivdfreg}; see {helpb xtset:[XT] xtset}.{p_end}
{p 4 6 2}
All {it:varlists} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{it:depvar} and all {it:varlists} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
See {helpb xtivdfreg postestimation} for features available after estimation.{p_end}
{p 4 6 2}
{cmd:xtivdfreg} is a community-contributed program. The current version requires Stata version 13 or higher; see {help xtivdfreg##update:version history and updates}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:xtivdfreg} implements the instrumental variables (IV) estimator for large panel data models, as developed by Norkute, Sarafidis, Yamagata, and Cui (2020) and Cui, Norkute, Sarafidis, and Yamagata (2020).
The instruments are defactored to control for a multifactor error structure. Heterogeneous slope coefficients can be allowed using a mean-group (MG) estimator.
The command accommodates unbalanced panel data and permits highly flexible instrumentation strategies. Examples in Kripfganz and Sarafidis (2021) illustrate several features of {cmd:xtivdfreg}.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{cmd:absorb(}{it:{help reghdfe##absvar:absvars}}{cmd:)} specifies categorical variables that identify the fixed effects to be absorbed; see {helpb reghdfe:reghdfe} (if installed).

{phang}
{cmd:iv(}{varlist} [{cmd:,} {opt fvar(fvars)} {opt l:ags(#)} {opt fact:max(#)} [{cmdab:no:}]{opt eig:ratio} [{cmdab:no:}]{opt double:defact}]{cmd:)} specifies instrumental variables. One can specify as many sets of instruments as required.
Variables in the same set are defactored jointly. External variables that are not part of the regression model can also be used as instruments in {it:varlist}.

{pmore}
{opt fvar(fvars)} specifies that factors are extracted from the variables in {it:fvars}. The default is to extract factors from all variables in {it:varlist}.

{pmore}
{opt lags(#)} specifies the {it:#} of lags of {it:varlist} to be added to the set of instruments.
The variables at each lag order are defactored separately with factors extracted from the corresponding lag of {it:fvars}. The default is {cmd:lags(0)}.

{pmore}
{opt factmax(#)} specifies the maximum number of factors to be extracted from {it:fvars}. The default is set by the global option {opt factmax(#)}.

{pmore}
{opt noeigratio} and {opt eigratio} request to either use a fixed number of factors as specified with suboption {opt factmax(#)} or to use the Ahn and Horenstein (2013) eigenvalue ratio test to compute the number of factors.
{cmd:eigratio} is the default unless otherwise specified with the global option {cmd:noeigratio}.

{pmore}
{opt doubledefact} requests to include {it:fvars} in a further defactorization stage of the entire model for the first-stage estimator. All sets of instruments that are included in this defactorization stage are jointly defactored,
excluding lags of {it:fvars} specified with suboption {opt lags(#)}. {opt nodoubledefact} requests to avoid implementing a further defactorization stage of the entire model for the first-stage estimator.
The default is set by the global option [{cmd:no}]{cmd:doubledefact}.

{phang}
{opt factmax(#)} specifies the maximum number of factors for each estimation stage and each set of instruments. The default is {cmd:factmax(4)}.

{phang}
{opt doubledefact} requests to implement a further defactorization stage of the entire model for the first-stage estimator. {opt nodoubledefact} requests to avoid implementing this further defactorization stage.
{cmd:doubledefact} is the default when option {cmd:mg} is specified, and {cmd:nodoubledefact} is the default when option {cmd:mg} is omitted.

{phang}
{opt fstage} requests the first-stage IV estimator to be computed instead of the second-stage estimator.

{phang}
{opt mg} requests the mean-group estimator to be computed that allows for heterogeneous slopes.

{phang}
{opt noconstant}; see {helpb estimation options##noconstant:[R] estimation options}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt coeflegend}; see {helpb estimation options##coeflegend:[R] estimation options}.

{phang}
{opt noheader} suppresses display of the header above the coefficient table that displays the number of observations and moment conditions.

{phang}
{opt notable} suppresses display of the coefficient table.

{marker display_options}{...}
{phang}
{it:display_options}: {opt noci}, {opt nopv:alues}, {opt noomit:ted}, {opt vsquish}, {opt noempty:cells}, {opt base:levels}, {opt allbase:levels}, {opt nofvlab:el}, {opt fvwrap(#)}, {opt fvwrapon(style)}, {opth cformat(%fmt)},
{opt pformat(%fmt)}, {opt sformat(%fmt)}, and {opt nolstretch}; see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Optimization}

{phang}
{opt noeigratio} requests to use a fixed number of factors as specified with option {opt factmax(#)}.
By default, the eigenvalue ratio test of Ahn and Horenstein (2013) is used to compute the number of factors for each estimation stage and each set of instruments.

{phang}
{opt iterate(#)} specifies the maximum number of iterations for the extraction of factors. If convergence is declared before this threshold is reached, it will stop when convergence is declared.
The default is the number set using {helpb set maxiter}. This option has no effect with strongly balanced panel data, in which case any iterations are redundant.

{phang}
{opt ltolerance(#)} specifies the convergence tolerance for the objective function; see {helpb maximize:[R] maximize}. The default is {cmd:ltolerance(1e-4)}. This option has no effect with strongly balanced panel data.

{phang}
{opt nodots} requests not to display dots for the iteration steps. By default, one dot character is displayed for each iteration step. This option has no effect with strongly balanced panel data.

{marker remarks}{...}
{title:Remarks}

{pstd}
For the model with homogeneous slopes, the first-stage IV estimator is asymptotically biased and therefore not recommended.
For the model with heterogeneous slopes, only the first-stage MG estimator is available because estimating factors based on residuals may be very inefficient; see the discussion below Theorem 4 in Norkute, Sarafidis, Yamagata, and Cui (2020)
and footnote 10 in Kripfganz and Sarafidis (2021).

{pstd}
Factors are extracted jointly from the matrix of all variables in {it:fvars} for any {cmd:iv(}{it:varlist}{cmd:, fvar(}{it:fvars}{cmd:))} option. By default, {it:fvars} equals {it:varlist}.
To extract factors separately for different subsets of variables, multiple options should be specified, e.g. {opt iv(varlist1)} {opt iv(varlist2)}.

{pstd}
For the model with heterogeneous slopes, the MG estimator applies a second defactorization stage for which factors are extracted jointly from the matrix of all {it:fvars} previously used in the first defactorization stage,
excluding lags specified with the {opt lags(#)} suboption. Variable sets can be excluded from this second defactorization stage with suboption {cmd:nodoubledefact}.

{pstd}
For the model with homogeneous slopes, by default only one defactorization stage is applied in the first estimation stage because the additional defactorization stage is asymptotically redundant when the second-stage IV estimator is used;
see footnote 20 in Norkute, Sarafidis, Yamagata, and Cui (2020) and footnote 7 in Kripfganz and Sarafidis (2021).
The additional defactorization stage can still be applied by specifying suboption {cmd:doubledefact} for at least one set of instruments.

{pstd}
Factors for the first defactorization stage are extracted separately for each lag number of a specified set of instruments if specified with the {opt lags(#)} suboption.
For example, {cmd:iv(}{it:varlist}{cmd:, fvar(}{it:fvars}{cmd:) lags(2))} specifies that for each lag order {it:#} from 0 to 2,
{cmd:L}{it:#}{cmd:.(}{it:varlist}{cmd:)} is defactored with factors extracted from {cmd:L}{it:#}{cmd:.(}{it:fvars}{cmd:)}.
However, the number of factors is restricted to be the same and, if different based on the Ahn and Horenstein (2013) algorithm, is chosen as the maximum of the numbers that are obtained separately for each lag.
The number of factors can differ across different sets of instruments if multiple {cmd:iv()} options are specified.

{pstd}
When the estimation sample is not strongly balanced, an iterative EM algorithm is applied to extract the factors, following Stock and Watson (1998) and Bai, Liao, and Yang (2015).
Separate iteration loops are performed for each factor extraction, highlighted by an iteration log with a dot character for each iteration step unless the option {opt nodots} is specified.
For example, the option {cmd:iv(}{it:varlist}{cmd:, lags(2))} results in 3 separate iteration loops for {it:varlist}, {cmd:L.(}{it:varlist}{cmd:)}, and {cmd:L2.(}{it:varlist}{cmd:)} (with an iteration log in that order).
If another option {cmd:iv(}{it:varlist2}{cmd:, lags(2))} is specified, the same iteration procedure is repeated for {it:varlist2}.

{pstd}
When the additional defactorization stage is applied for the model with heterogeneous slopes, or this defactorization stage is requested with suboption {cmd:doubledefact} for the model with homogeneous slopes,
an additional iteration loop is performed jointly for {it:varlist} and {it:varlist2}, excluding lags specified with the {opt lags(#)} suboption.
Similarly, an additional iteration loop is performed for the factor extraction from the first-stage residuals when the second-stage IV estimator for the model with homogeneous slopes is computed.

{pstd}
The constant term is estimated as the mean of the residuals in a separate stage after computing the slope coefficients. For the model with heterogeneous slopes, the intercept is also treated as heterogeneous.
Whether a constant term is estimated or not has no effect on the computation of the slope coefficients because the latter are computed for the demeaned model, with or without the absorption of fixed effects.
The standard error of the constant term is computed using the influence-function approach of Kripfganz and Schwarz (2019).


{marker example}{...}
{title:Example}

{pstd}Setup for balanced panel data set, dynamic model{p_end}
{pstd}(The data set is available as an ancillary file for the {cmd:xtivdfreg} package.){p_end}
{phang2}. {stata "use http://www.kripfganz.de/stata/xtivdfreg_example"}{p_end}

{pstd}Defactored IV estimation with two-way fixed effects, homogeneous slopes{p_end}
{phang2}. {stata xtivdfreg L(0/1).CAR size ROA liquidity, absorb(id t) iv(size ROA liquidity, lags(2)) factmax(3)}{p_end}

{pstd}Defactored IV estimation with two-way fixed effects, heterogeneous slopes{p_end}
{phang2}. {stata xtivdfreg L(0/1).CAR size ROA liquidity, absorb(id t) iv(size ROA liquidity, lags(2)) factmax(3) mg}{p_end}

{pstd}Replication of a 2SLS estimation without common shocks{p_end}
{phang2}. {stata ivregress 2sls CAR size ROA liquidity (L.CAR = L(0/2).(size ROA liquidity)) i.id i.t, vce(cluster id)}{p_end}
{phang2}. {stata xtivdfreg L(0/1).CAR size ROA liquidity, absorb(id t) iv(size ROA liquidity, lags(2)) factmax(0) fstage}{p_end}

{pstd}Setup for unbalanced panel data set, static model{p_end}
{phang2}. {stata "use http://www.stata-journal.com/software/sj12-1/st0246/manu_prod"}{p_end}

{pstd}Defactored IV estimation with two-way fixed effects, homogeneous slopes{p_end}
{phang2}. {stata xtivdfreg ly lk, absorb(list year) iv(lk, lags(2)) factmax(3)}{p_end}

{pstd}Defactored IV estimation with two-way fixed effects, heterogeneous slopes{p_end}
{phang2}. {stata xtivdfreg ly lk, absorb(list year) iv(lk, lags(2)) factmax(3) mg}{p_end}

{pstd}See Kripfganz and Sarafidis (2021) for a detailed discussion of these examples.{p_end}


{marker results}{...}
{title:Saved results}

{pstd}
{cmd:xtivdfreg} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(g_min)}}smallest group size{p_end}
{synopt:{cmd:e(g_avg)}}average group size{p_end}
{synopt:{cmd:e(g_max)}}largest group size{p_end}
{synopt:{cmd:e(sigma2u)}}variance of error term u_it = f_it + e_it{p_end}
{synopt:{cmd:e(sigma2f)}}variance of factor error component f_it{p_end}
{synopt:{cmd:e(rho)}}fraction of variance due to factor component{p_end}
{synopt:{cmd:e(chi2_J)}}Hansen's J-statistic{p_end}
{synopt:{cmd:e(df_J)}}degrees of freedom of Hansen's J-test{p_end}
{synopt:{cmd:e(p_J)}}p-value of Hansen's J-test{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(zrank)}}number of instruments{p_end}
{synopt:{cmd:e(fact1)}}number of factors in the first stage{p_end}
{synopt:{cmd:e(fact2)}}number of factors in the second stage{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtivdfreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:e(tvar)}}variable denoting time{p_end}
{synopt:{cmd:e(estat_cmd)}}{cmd:xtivdfreg_estat}{p_end}
{synopt:{cmd:e(predict)}}{cmd:xtivdfreg_p}{p_end}
{synopt:{cmd:e(marginsok)}}predictions allowed by {cmd:margins}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(estimator)}}{cmd:fstage}, {cmd:sstage}, or {cmd:mg}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(factnum)}}variable-specific number of factors in the first stage{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{marker update}{...}
{title:Version history and updates}

{pstd}{cmd:xtivdfreg} is a community-contributed program. To determine the currently installed version, type{p_end}
{phang2}. {stata which xtivdfreg, all}{p_end}

{pstd}To update the {cmd:xtivdfreg} package to the latest version, type{p_end}
{phang2}. {stata `"net install xtivdfreg, from("http://www.kripfganz.de/stata/") replace"'}{p_end}


{marker authors}{...}
{title:Authors}

{pstd}
Sebastian Kripfganz, University of Exeter, {browse "http://www.kripfganz.de"}

{pstd}
Vasilis Sarafidis, BI Norwegian Business School, {browse "https://sites.google.com/view/vsarafidis"}


{marker references}{...}
{title:References}

{phang}
Ahn, S. C., and A. R. Horenstein. 2013.
Eigenvalue ratio test for the number of factors.
{it:Econometrica} 81: 1203-1227.

{phang}
Bai, J., Y. Liao, and J. Yang. 2015.
Unbalanced panel data models with interactive effects.
In: {it:The Oxford Handbook of Panel Data}, ed. B. H. Baltagi. Oxford University Press: 149-170.

{phang}
Cui, G., M. Norkute, V. Sarafidis, and T. Yamagata. 2020.
Two-stage instrumental variable estimation of linear panel data models with interactive effects.
{it:ISER Discussion Paper} 1101.

{phang}
Kripfganz, S., and V. Sarafidis. 2021.
Instrumental variable estimation of large-T panel data models with common factors.
{it:Accepted for publication in the Stata Journal}.

{phang}
Kripfganz, S., and C. Schwarz. 2019.
Estimation of linear dynamic panel data models with time-invariant regressors.
{it:Journal of Applied Econometrics} 34: 526-546.

{phang}
Norkute, M., V. Sarafidis, T. Yamagata, and G. Cui. 2021.
Instrumental variable estimation of dynamic linear panel data models with defactored regressors and a multifactor error structure.
{it:Journal of Econometrics} 220: 416-446.

{phang}
Stock, J. H., and M. W. Watson. 1998.
Diffusion indexes.
{it:NBER Working Paper} 6702.


{title:Acknowledgements}

{pstd}
{cmd:xtivdfreg} is not an official Stata command. It is a free contribution to the research community. Please cite Kripfganz and Sarafidis (2020), as provided in the references list just above.
