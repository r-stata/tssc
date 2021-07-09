{smcl}
{* *! version 1.4.3  26feb2017}{...}
{* *! Sebastian Kripfganz, www.kripfganz.de}{...}
{vieweralsosee "xtdpdqml" "help xtdpdqml"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] predict" "help predict"}{...}
{vieweralsosee "[XT] xtreg postestimation" "help xtreg_postestimation"}{...}
{viewerjumpto "Description" "xtdpdqml_postestimation##description"}{...}
{viewerjumpto "Syntax for predict" "xtdpdqml_postestimation##syntax_predict"}{...}
{viewerjumpto "Options for predict" "xtdpdqml_postestimation##options_predict"}{...}
{viewerjumpto "estat serial" "xtdpdqml_postestimation##estat_serial"}{...}
{viewerjumpto "Example" "xtdpdqml_postestimation##example"}{...}
{viewerjumpto "Author" "xtdpdqml_postestimation##author"}{...}
{viewerjumpto "References" "xtdpdqml_postestimation##references"}{...}
{title:Title}

{p2colset 5 32 34 2}{...}
{p2col :{bf:xtdpdqml postestimation} {hline 2}}Postestimation tools for xtdpdqml{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
The following postestimation command is of special interest after {cmd:xtdpdqml}:

{synoptset 13}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt:{helpb xtdpdqml postestimation##estat_serial:estat serial}}perform test for autocorrelated residuals{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
The following standard postestimation commands are available:

{synoptset 13 tabbed}{...}
{p2coldent:Command}Description{p_end}
{synoptline}
{synopt:{helpb estat}}AIC, BIC, VCE, and estimation sample summary{p_end}
INCLUDE help post_estimates
INCLUDE help post_hausman
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{synopt:{helpb xtdpdqml postestimation##syntax_predict:predict}}predictions, residuals, influence statistics, and other diagnostic measures{p_end}
INCLUDE help post_predictnl
{p2coldent:* {helpb suest}}seemingly unrelated estimation{p_end}
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}
{phang}
* {cmd:suest} is available only after {cmd:xtdpdqml, mlparams} without option {cmd:stationary}. It is appropriate only with option {cmd:vce(cluster} {it:panelvar}{cmd:)}.{p_end}


{marker syntax_predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:{help xtdpdqml_postestimation##predict_statistics:statistic}} {it:{help xtdpdqml_postestimation##predict_options:options}}]

{p 8 16 2}
{cmd:predict} {dtype} {c -(}{it:stub*}{c |}{it:{help newvar:newvar1}} ... {it:{help newvar:newvarq}}{c )-} {ifin} {cmd:,} {opt sc:ores} [{it:{help xtdpdqml_postestimation##predict_options:options}}]


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
{p2coldent:* {opt sc:ores}}calculate the equation-level scores{p_end}
{synoptline}
{p2colreset}{...}
INCLUDE help unstarred
{p 4 6 2}
{opt ue}, {opt xbu}, and {opt u} are not available after {cmd:xtdpdqml, fe mlparams}.
{opt scores} is available only after {cmd:xtdpdqml, mlparams} without option {cmd:stationary}.{p_end}

{marker predict_options}{...}
{synoptset 16 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Options}
{synopt :{opt eq:uation}{cmd:(}{it:eqno}{cmd:)}}specify equation{p_end}
{synoptline}
{p2colreset}{...}


{marker options_predict}{...}
{title:Options for predict}

{dlgtab:Main}

{phang}
{opt xb} calculates the linear prediction from the fitted model; see {helpb predict##options:[R] predict}. This is the default.
After {cmd:xtdpdqml, fe mlparams} it calculates the linear prediction from the first-differenced model.

{phang}
{opt stdp} calculates the standard error of the linear prediction; see {helpb predict##options:[R] predict}.

{phang}
{opt ue} calculates the prediction of u_i + e_it, the combined residual; see {helpb xtreg postestimation##options_predict:[XT] xtreg postestimation}.
This option is not available after {cmd:xtdpdqml, fe mlparams}.

{phang}
{opt xbu} calculates the linear prediction including the unit-specific error component; see {helpb xtreg postestimation##options_predict:[XT] xtreg postestimation}.
This option is not available after {cmd:xtdpdqml, fe mlparams}.

{phang}
{opt u} calculates the prediction of u_i, the estimated unit-specific error component; see {helpb xtreg postestimation##options_predict:[XT] xtreg postestimation}.
This option is not available after {cmd:xtdpdqml, fe mlparams}.

{phang}
{opt e} calculates the prediction of e_it; see {helpb xtreg postestimation##options_predict:[XT] xtreg postestimation}.
After {cmd:xtdpdqml, fe mlparams} it calculates the prediction of D.e_it, the first-differenced residual.

{phang}
{opt scores} calculates the equation-level score variables; see {helpb predict##options:[R] predict}. This is the derivative of the log-likelihood function with respect to the linear prediction.
Ancillary parameters make up separate equations. This option is available only after {cmd:xtdpdqml, mlparams} without option {cmd:stationary}.

{dlgtab:Options}

{phang}
{opt equation}{cmd:(}{it:eqno}{cmd:)} specifies the equation to which you are referring; see {helpb predict##options:[R] predict}.


{marker estat_serial}{...}
{title:Syntax for estat serial}

{p 8 16 2}
{cmd:estat} {cmdab:ser:ial} [, {opth ar(numlist)}]


{title:Description for estat serial}

{pstd}
{cmd:estat serial} reports the Arellano and Bond (1991) test for autocorrelation of the first-differenced residuals. {cmd:estat serial} is available only after {cmd: xtdpdqml, mlparams} without option {cmd:stationary}.


{title:Options for estat serial}

{phang}
{opth ar(numlist)} specifies the orders of serial correlation to be tested. The default is {cmd:ar(1 2)}.


{marker example}{...}
{title:Example}

{pstd}Setup{p_end}
{phang2}{stata webuse abdata:. webuse abdata}{p_end}

{pstd}Hausman specification test{p_end}
{phang2}{stata xtdpdqml n w k:. xtdpdqml n w k}{p_end}
{phang2}{stata estimates store fe:. estimates store fe}{p_end}
{phang2}{stata xtdpdqml n w k, re initval(.1 .2 .2 .3):. xtdpdqml n w k, re initval(.1 .2 .2 .3)}{p_end}
{phang2}{stata estimates store re:. estimates store re}{p_end}
{phang2}{stata hausman fe re:. hausman fe re}{p_end}

{pstd}Likelihood-ratio and Wald tests for joint significance of time dummies{p_end}
{phang2}{stata xtdpdqml n w k yr1978-yr1984:. xtdpdqml n w k yr1978-yr1984}{p_end}
{phang2}{stata lrtest fe:. lrtest fe}{p_end}
{phang2}{stata testparm yr*:. testparm yr*}{p_end}

{pstd}Compute long-run effects{p_end}
{phang2}{stata nlcom (_b[w] / (1 - _b[L.n])) (_b[k] / (1 - _b[L.n])):. nlcom (_b[w] / (1 - _b[L.n])) (_b[k] / (1 - _b[L.n]))}{p_end}

{pstd}Generalized (robust) Hausman specification test{p_end}
{phang2}{stata xtdpdqml n w k yr1978-yr1984, mlparams:. xtdpdqml n w k yr1978-yr1984, mlparams}{p_end}
{phang2}{stata estimates store fe:. estimates store fe}{p_end}
{phang2}{stata xtdpdqml n w k yr1978-yr1984, re initval(.1 .2 .2 .3) mlparams:. xtdpdqml n w k yr1978-yr1984, re initval(.1 .2 .2 .3) mlparams}{p_end}
{phang2}{stata estimates store re:. estimates store re}{p_end}
{phang2}{stata suest fe re, vce(cluster id):. suest fe re, vce(cluster id)}{p_end}
{phang2}{stata test ([fe__model]LD.n = [re__model]L.n) ([fe__model]D.w = [re__model]w) ([fe__model]D.k = [re__model]k):. test ([fe__model]LD.n = [re__model]L.n) ([fe__model]D.w = [re__model]w) ([fe__model]D.k = [re__model]k)}{p_end}

{pstd}Arellano-Bond test for autocorrelation of the first-differenced residuals{p_end}
{phang2}{stata estimates restore fe:. estimates restore fe}{p_end}
{phang2}{stata estat serial:. estat serial}{p_end}
{phang2}{stata estimates restore re:. estimates restore re}{p_end}
{phang2}{stata estat serial:. estat serial}{p_end}


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
