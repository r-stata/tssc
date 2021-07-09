{smcl}
{* *! version 1.1.0  12jul2012}{...}

{title:Title}

{p2colset 5 13 15 2}{...}
{p2col :{hi:xmfp} {hline 2}}Multivariable fractional polynomial models with extensions{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:xmfp}
	[{cmd:,}
		{it:options}]
        {cmd::} {it:{help mfp##reg_cmd:regression_cmd}}
	[{it:{help mfp##reg_cmd:yvar1}} [{it:{help mfp##reg_cmd:yvar2}}]]
	{it:{help mfp##reg_cmd:xvarlist}}
	{ifin}
	{weight}
	[{cmd:,} {it:regression_cmd_options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model 2}
{synopt :{opt seq:uential}}use the Royston and Altman model-selection algorithm;
default uses closed-test procedure{p_end}
{synopt :{opt cyc:les(#)}}maximum number of iteration cycles; default is
{cmd:cycles(5)}{p_end}
{synopt :{opt dfd:efault(#)}}default maximum degrees of freedom; default is
{cmd:dfdefault(4)}{p_end}
{synopt :{opt cent:er(cent_list)}}specification of centering for the
independent variables{p_end}
{synopt :{opt al:pha(alpha_list)}}p-values for testing between FP models;
default is {cmd:alpha(0.05)}{p_end}
{synopt :{opt df(df_list)}}degrees of freedom for each predictor{p_end}
{synopt :{opth po:wers(numlist:numlist)}}list of FP powers to use;
default is {bind:{cmd:powers(-2 -1(.5)1 2 3)}}{p_end}
{synopt :{opt lin:adj(varlist)}}list of variables to be included
as untransformed linear terms in all MFP models{p_end}

{syntab :Adv. model}
{synopt :{cmdab:xo:rder(+}|{cmd:-}|{cmd:n)}}order of entry into model-selection
algorithm; default is {cmd:xorder(+)}{p_end}
{synopt :{opt sel:ect(select_list)}}nominal p-values for selection on each
predictor{p_end}
{synopt :{opt xp:owers(xp_list)}}FP powers for each
predictor{p_end}
{synopt :{opth zer:o(varlist)}}treat nonpositive values of specified predictors
as zero when FP is transformed{p_end}
{synopt :{opth cat:zero(varlist)}}add indicator variable for specified
predictors{p_end}
{synopt :{opt all}}include
	out-of-sample observations in generated variables{p_end}

{syntab :Reporting}
{synopt :{opt lev:el(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{it:{help mfp##display_options:display_options}}}control column
        formats and line width{p_end}
{synoptline}

{synopthdr :regression_cmd_options}
{synoptline}
{syntab :Adv. model}
{synopt :{it:regression_cmd_options}}options appropriate to the regression command in use{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
All weight types supported by {it:regression_cmd} are allowed; see
{help weight}.{p_end}
{p 4 6 2}
See {helpb mfp postestimation:[R] mfp postestimation} for features available
after estimation.{p_end}
{p 4 6 2}
{opt fracgen} may be used to create new variables containing fractional
polynomial powers.  See {helpb fracpoly:[R] fracpoly}.{p_end}

{pstd}
{marker reg_cmd}where

{pin}
{it:regression_cmd} may be
{helpb clogit},
{helpb glm},
{helpb intreg}, 
{helpb logistic},
{helpb logit},
{helpb mlogit},
{helpb nbreg},
{helpb ologit},
{helpb oprobit},
{helpb poisson},
{helpb probit},
{helpb qreg},
{helpb regress},
{helpb rreg},
{helpb stcox},
{helpb stcrreg},
{helpb streg},
or
{helpb xtgee}.

{pin}
{it:yvar1} is not allowed for {opt streg}, {opt stcrreg}, and {opt stcox}.
For these commands, you must first {helpb stset} your data.

{pin}
{it:yvar1} and {it:yvar2} must both be specified when {it:regression_cmd} is
{opt intreg}.

{pin}
{it:xvarlist} has elements of type {varlist} and/or {opt (varlist)};
for example,

{pin2}
{cmd:x1 x2 (x3 x4 x5)}

{pin}
Elements enclosed in parentheses are tested jointly for inclusion in the
model and are not eligible for fractional polynomial transformation.


{marker description}{...}
{title:Description}

{pstd}
{opt xmfp} selects the multivariable fractional polynomial (MFP) model that best
predicts the outcome variable from the right-hand-side variables in
{it:{help varlist:xvarlist}}.

{pstd}
{cmd:xmfp} provides some extensions to the factory-standard {cmd:mfp} command,
namely

    1. {cmd:xmfp} supports factor variables
    2. {cmd:xmfp} has a {opt linadj(varlist)} option to adjust linearly for variables in {it:varlist}.

{pstd}
Note also that the {cmd:mfp} post-estimation commands {helpb fracplot} and 
{helpb fracpred} are replaced with {cmd:xfracplot} and {cmd:xfracpred},
respectively. The syntax is unchanged, except that {cmd:xfracplot} has
an additional option {opt nopts} which suppresses plotting of partial
residuals.

{title:Author}

{phang}Patrick Royston{p_end}
{phang}MRC Clinical Trials Unit{p_end}
{phang}London, UK{p_end}
{phang}pr@ctu.mrc.ac.uk{p_end}


{title:Also see}

{psee}
Manual:  {hi:[R] fracpoly}, {hi:[R] mfp}{p_end}

{psee}
Online:  {helpb mfp}{p_end}
