{smcl}
{* *! version 1.1.2  04jun2017}{...}
{* *! Sebastian Kripfganz, www.kripfganz.de}{...}
{vieweralsosee "xtseqreg" "help xtseqreg"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] predict" "help predict"}{...}
{vieweralsosee "[R] gmm postestimation" "help gmm_postestimation"}{...}
{vieweralsosee "[XT] xtreg postestimation" "help xtreg_postestimation"}{...}
{vieweralsosee "[XT] xtdpd postestimation" "help xtdpd_postestimation"}{...}
{viewerjumpto "Postestimation commands" "xtseqreg_postestimation##description"}{...}
{viewerjumpto "predict" "xtseqreg_postestimation##predict"}{...}
{viewerjumpto "estat serial" "xtseqreg_postestimation##estat_serial"}{...}
{viewerjumpto "estat overid" "xtseqreg_postestimation##estat_overid"}{...}
{viewerjumpto "estat hausman" "xtseqreg_postestimation##estat_hausman"}{...}
{viewerjumpto "Example" "xtseqreg_postestimation##example"}{...}
{viewerjumpto "Author" "xtseqreg_postestimation##author"}{...}
{viewerjumpto "References" "xtseqreg_postestimation##references"}{...}
{title:Title}

{p2colset 5 32 34 2}{...}
{p2col :{bf:xtseqreg postestimation} {hline 2}}Postestimation tools for xtseqreg{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Postestimation commands}

{pstd}
The following postestimation commands are of special interest after {cmd:xtseqreg}:

{synoptset 13}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt:{helpb xtseqreg postestimation##estat_serial:estat serial}}perform test for autocorrelated residuals{p_end}
{synopt:{helpb xtseqreg postestimation##estat_overid:estat overid}}perform test of overidentifying restrictions{p_end}
{synopt:{helpb xtseqreg postestimation##estat_hausman:estat hausman}}perform generalized Hausman test{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
The following standard postestimation commands are available:

{synoptset 13}{...}
{p2coldent:Command}Description{p_end}
{synoptline}
{p2col:{helpb estat}}VCE and estimation sample summary{p_end}
INCLUDE help post_estimates
INCLUDE help post_hausman
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{synopt:{helpb xtseqreg postestimation##predict:predict}}predictions, residuals, influence statistics, and other diagnostic measures{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:{help xtseqreg_postestimation##predict_statistics:statistic}} {it:{help xtseqreg_postestimation##predict_options:options}}]

{p 8 16 2}
{cmd:predict} {dtype} {c -(}{it:stub*}{c |}{it:{help newvar:newvar1}} ... {it:{help newvar:newvarq}}{c )-} {ifin} {cmd:,} {opt sc:ores}


{marker predict_statistics}{...}
{synoptset 13 tabbed}{...}
{synopthdr:statistic}
{synoptline}
{syntab:Main}
{synopt:{opt xb}}calculate linear prediction; the default{p_end}
{synopt:{opt stdp}}calculate standard error of the prediction{p_end}
{synopt:{opt ue}}calculate the combined residual{p_end}
{p2coldent:* {opt xbu}}calculate prediction including unit-specific error component{p_end}
{p2coldent:* {opt u}}calculate the the unit-specific error component{p_end}
{p2coldent:* {opt e}}calculate the idiosyncratic error component{p_end}
{p2coldent:* {opt sc:ores}}calculate parameter-level scores{p_end}
{synoptline}
{p2colreset}{...}
INCLUDE help unstarred
{p 4 6 2}
{opt scores} is not available after {cmd:xtseqreg} with two equations.{p_end}

{marker predict_options}{...}
{synoptset 16 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Options}
{synopt :{opt eq:uation}{cmd:(}{it:eqno}{cmd:)}}specify equation{p_end}
{synoptline}
{p2colreset}{...}


{title:Description for predict}

{pstd}
{cmd:predict} creates a new variable containing predictions such as fitted values, standard errors, and residuals.


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt xb} calculates the linear prediction from the fitted model; see {helpb predict##options:[R] predict}. This is the default.

{phang}
{opt stdp} calculates the standard error of the linear prediction; see {helpb predict##options:[R] predict}.

{phang}
{opt ue} calculates the prediction of u_i + e_it, the combined residual; see {helpb xtreg postestimation##options_predict:[XT] xtreg postestimation}.

{phang}
{opt xbu} calculates the linear prediction including the unit-specific error component; see {helpb xtreg postestimation##options_predict:[XT] xtreg postestimation}.

{phang}
{opt u} calculates the prediction of u_i, the estimated unit-specific error component; see {helpb xtreg postestimation##options_predict:[XT] xtreg postestimation}.

{phang}
{opt e} calculates the prediction of e_it; see {helpb xtreg postestimation##options_predict:[XT] xtreg postestimation}.

{phang}
{opt scores} calculates the parameter-level scores for each independent variable, the first derivatives of the criterion function with respect to the coefficients (multiplied by -1);
see {helpb gmm postestimation##option_predict:[R] gmm postestimation}. This option requires that the length of the new variable list be equal to the number of independent variables including the constant term, if any.
A finite-sample correction term is added after two-step GMM estimation with the Windmeijer (2005) correction. This option is not available after {cmd:xtseqreg} with two equations.

{dlgtab:Options}

{phang}
{opt equation}{cmd:(}{it:eqno}{cmd:)} specifies the equation to which you are referring; see {helpb predict##options:[R] predict}.


{marker estat_serial}{...}
{title:Syntax for estat serial}

{p 8 16 2}
{cmd:estat} {cmdab:ser:ial} [, {opth ar(numlist)}]


{title:Description for estat serial}

{pstd}
{cmd:estat serial} reports the Arellano and Bond (1991) test for autocorrelation of the first-differenced residuals.


{title:Options for estat serial}

{phang}
{opth ar(numlist)} specifies the orders of serial correlation to be tested. The default is {cmd:ar(1 2)}.


{marker estat_overid}{...}
{title:Syntax for estat overid}

{p 8 16 2}
{cmd:estat} {cmdab:over:id} [{it:name}]

{p 4 6 2}
where {it:name} is a name under which estimation results were stored via {helpb estimates store:estimates store}.


{title:Description for estat overid}

{pstd}
{cmd:estat overid} reports the Hansen (1982) J-statistic, which is used to determine the validity of the overidentifying restrictions.
The moment conditions are evaluated at the two-step estimates after {cmd:xtseqreg} with option {cmd:twostep}, and at the one-step estimates otherwise.
An optimal weighting matrix based on the one-step estimates is used, irrespective of whether the two-step GMM estimator is computed or not.

{pstd}
{cmd:estat overid} {it:name} reports a difference-in-Hansen statistic, which is used to determine the validity of a subset of overidentifying restrictions.
It is computed as the difference between the respective J-statistics from the most recent {cmd:xtdpdgmm} estimation results and the estimation results stored as {it:name} by using {helpb estimates store:estimates store}.
For the resulting test statistic to be valid, the two estimators need to be nested in terms of the moment conditions they employ.


{marker estat_hausman}{...}
{title:Syntax for estat hausman}

{p 8 16 2}
{cmd:estat} {cmdab:haus:man} {it:name} [{cmd:(}{varlist}{cmd:)}] [, {opt df(#)} {opt none:sted}]

{p 4 6 2}
where {it:name} is a name under which estimation results were stored via {helpb estimates store:estimates store}.


{title:Description for estat hausman}

{pstd}
{cmd:estat hausman} reports a generalized Hausman (1978) test for model misspecification by comparing the coefficient estimates of {it:varlist} from the most recent {cmd:xtseqreg} estimation results
to the corresponding coefficient estimation results stored as {it:name} by using {helpb estimates store:estimates store}. By default, the coefficients of all {it:indepvars} are contrasted,
excluding deterministic model components such as the constant term and time dummies, if specified with option {opt teffects} of {cmd:xtseqreg}. This generalized test does not require one of the estimators to be efficient.
It uses the robust variance-covariance estimator for the test statistic suggested by White (1982) that is computed using the parameter-level scores; see {helpb suest:[R] suest}.


{title:Options for estat hausman}

{phang}
{opt df(#)} specifies the degrees of freedom for the test. The default is the difference in the number of overidentifying restrictions from the two estimations or the number of contrasted coefficients, whichever is smaller.

{phang}
{opt nonested} specifies that the two estimators are not nested in terms of the moment conditions they employ. This option implies that the degrees of freedom for the test equal the number of contrasted coefficients.


{marker example}{...}
{title:Example}

{pstd}Setup{p_end}
{phang2}{stata webuse abdata:. webuse abdata}{p_end}

{pstd}Two-step difference-GMM estimator with strictly exogenous covariates{p_end}
{phang2}{stata xtseqreg L(0/1).n w k, gmmiv(L.n, c m(d)) iv(w k, d m(d)) teffects twostep vce(robust):. xtseqreg L(0/1).n w k, gmmiv(L.n, c m(d)) iv(w k, d m(d)) teffects twostep vce(robust)}{p_end}
{phang2}{stata estimates store ab:. estimates store ab}{p_end}

{pstd}Arellano-Bond test for autocorrelation of the first-differenced residuals{p_end}
{phang2}{stata estat serial:. estat serial}{p_end}

{pstd}Hansen's J-test for the validity of the overidentifying restrictions{p_end}
{phang2}{stata estat overid:. estat overid}{p_end}

{pstd}Two-step system-GMM estimator with strictly exogenous covariates{p_end}
{phang2}{stata xtseqreg L(0/1).n w k, gmmiv(L.n, c m(d)) iv(w k, d m(d)) iv(L.n, d m(l)) teffects twostep vce(robust):. xtseqreg L(0/1).n w k, gmmiv(L.n, c m(d)) iv(w k, d m(d)) iv(L.n, d m(l)) teffects twostep vce(robust)}{p_end}

{pstd}Generalized Hausman test for the additional level moment condition{p_end}
{phang2}{stata estat hausman ab:. estat hausman ab}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Sebastian Kripfganz, University of Exeter, {browse "http://www.kripfganz.de"}


{marker references}{...}
{title:References}

{phang}
Arellano, M., and S. R. Bond. 1991.
Some tests of specification for panel data: Monte Carlo evidence and an application to employment equations.
{it:Review of Economic Studies} 58: 277-297.

{phang}
Hansen, L. P. 1982.
Large sample properties of generalized method of moments estimators.
{it:Econometrica} 50: 1029-1054.

{phang}
Hausman, J. A. 1978.
Specification tests in econometrics.
{it:Econometrica} 46: 1251-1271.

{phang}
White, H. L. 1982.
Maximum likelihood estimation of misspecified models.
{it:Econometrica} 50: 1-25.

{phang}
Windmeijer, F. 2005.
A finite sample correction for the variance of linear efficient two-step GMM estimators.
{it:Journal of Econometrics} 126: 25-51.
