{smcl}
{* *! version 1.0.3  12feb2021}{...}
{* *! Sebastian Kripfganz, www.kripfganz.de}{...}
{* *! Vasilis Sarafidis, sites.google.com/view/vsarafidis}{...}
{vieweralsosee "xtivdfreg" "help xtivdfreg"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] predict" "help predict"}{...}
{vieweralsosee "[R] ivregress postestimation" "help ivregress_postestimation"}{...}
{viewerjumpto "Postestimation commands" "xtivdfreg_postestimation##description"}{...}
{viewerjumpto "estat" "xtivdfreg_postestimation##estat"}{...}
{viewerjumpto "Author" "xtivdfreg_postestimation##authors"}{...}
{viewerjumpto "References" "xtivdfreg_postestimation##references"}{...}
{title:Title}

{p2colset 5 35 37 2}{...}
{p2col :{bf:xtivdfreg postestimation} {hline 2}}Postestimation tools for xtivdfreg{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Postestimation commands}

{pstd}
The following postestimation commands are of special interest after {cmd:xtivdfreg}:

{synoptset 13}{...}
{p2coldent:Command}Description{p_end}
{synoptline}
{synopt:{helpb xtivdfreg postestimation##estat:estat overid}}perform test of overidentifying restrictions{p_end}
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
INCLUDE help post_margins
INCLUDE help post_marginsplot
INCLUDE help post_nlcom
{synopt:{helpb xtivdfreg postestimation##predict:predict}}predictions, residuals, and other diagnostic measures{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:{help xtivdfreg_postestimation##predict_statistics:statistic}}]


{marker predict_statistics}{...}
{synoptset 13 tabbed}{...}
{synopthdr:statistic}
{synoptline}
{syntab:Main}
{synopt:{opt xb}}calculate linear prediction; the default{p_end}
{synopt:{opt r:esiduals}}calculate residuals{p_end}
{synopt:{opt stdp}}calculate standard error of the prediction{p_end}
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
{opt residuals} calculates the residuals, i.e. the linear prediction subtracted from {it:depvar}.

{phang}
{opt stdp} calculates the standard error of the linear prediction; see {helpb predict##options:[R] predict}.


{marker estat}{...}
{title:Syntax for estat}

{phang}
Hansen tests of overidentifying restrictions

{p 8 16 2}
{cmd:estat} {cmdab:over:id}


{title:Description for estat}

{pstd}
{cmd:estat overid} reports the Hansen (1982) J-statistic which is used to determine the validity of the overidentifying restrictions.


{title:Remarks for estat}

{pstd}
The overidentification test statistic is constructed as a quadratic form of the moment functions with an asymptotically optimal weighting matrix. The latter is based on the first-stage residuals.
The test is not valid and therefore not reported for a model with heterogeneous slopes that is estimated with the mean-group estimator.


{marker authors}{...}
{title:Author}

{pstd}
Sebastian Kripfganz, University of Exeter, {browse "http://www.kripfganz.de"}

{pstd}
Vasilis Sarafidis, BI Norwegian Business School, {browse "https://sites.google.com/view/vsarafidis"}


{marker references}{...}
{title:References}

{phang}
Hansen, L. P. 1982.
Large sample properties of generalized method of moments estimators.
{it:Econometrica} 50: 1029-1054.
