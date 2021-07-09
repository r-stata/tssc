{smcl}
{* *! version 1.0.2 13jul2012}{...}
{hline}
{cmd:help stmix} {right:also see: {helpb stmix postestimation}}
{hline}

{title:Title}

{p2colset 5 14 25 2}{...}
{p2col :{cmd:stmix} {hline 2}}Parametric mixture survival models{p_end}
{p2colreset}{...}

{title:Syntax}

{phang2}
{cmd: stmix} [{varlist}] {ifin} [{cmd:,} {it:options}]

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{cmdab:dist:ribution(}{cmdab:weibe:xp)}}Weibull-exponential survival distribution{p_end}
{synopt:{cmdab:dist:ribution(}{cmdab:we)}}synonym for {cmd:distribution(weibexp)}{p_end}
{synopt:{cmdab:dist:ribution(}{cmdab:weibw:eib)}}Weibull-Weibull survival distribution{p_end}
{synopt:{cmdab:dist:ribution(}{cmdab:ww)}}synonym for {cmd:distribution(weibweib)}{p_end}
{synopt:{opt lambda1(varlist)}}covariates for the scale parameter of the first component distribution{p_end}
{synopt:{opt gamma1(varlist)}}covariates for the shape parameter of the first component distribution{p_end}
{synopt:{opt lambda2(varlist)}}covariates for the scale parameter of the second component distribution{p_end}
{synopt:{opt gamma2(varlist)}}covariates for the shape parameter of the second component distribution{p_end}
{synopt:{opt pmix(varlist)}}covariates for the mixture parameter{p_end}

{syntab:Reporting}
{synopt:{opt nohr}}do not report hazard ratios{p_end}
{synopt:{opt showinit}}display output from initial value model fits{p_end}
{synopt:{opt showc:ons}}list constraints in output{p_end}
{synopt:{opt keepc:ons}}do not drop constraints used in ml routine{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}

{syntab:Maximization options}
{synopt :{opt initmat({it:matrix_name})}}pass a matrix of initial values}{p_end}
{synopt :{opt noinit}}do not fit the initial value model}{p_end}
{synopt:{opt pmixc:onstraint(#)}}gives the value of which logit(pmix) is contrained to when obtaining initial values; default is 0{p_end}
{synopt :{it:{help stmix##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stmix}; see {manhelp stset ST}. {p_end}
{p 4 6 2}
Weights are not currently supported.{p_end}
{p 4 6 2}
Factor variables are not currently supported.{p_end}


{title:Description}

{pstd}
{cmd:stmix} fits 2-component parametric mixture survival models. Distribution choices include Weibull-Weibull or Weibull-exponential. {cmd:stmix} can be 
used with single- or multiple-record or single- or multiple-failure st data.{p_end}

{pstd}
The component parametric models are additive on the survival scale, so for example, under a 2-component mixture Weibull-Weibull model:

{pin}
		S_0(t) = pmix * exp(-lambda1 * t ^ gamma1) + (1 - pmix) * exp(-lambda2 * t ^ gamma2)

{pstd}
Proportional hazards can be induced via:

{pin}
		h(t) = -d(ln(S_0(t))/dt * exp(XB)


{title:Options}

{dlgtab:Model}

{phang}
{opt distribution(string)} specifies the parametric mixture distribution. Choices include a Weibull-exponential, {cmd:weibexp}/{cmd:we}, or a Weibull-Weibull, 
{cmd:weibweib}/{cmd:ww}.

{phang}
{opt lambda1(varlist)} covariates to include in the linear predictor of the scale parameter of the first component distribution. This is ln(lambda1) for all 
models.

{phang}
{opt gamma1(varlist)} covariates to include in the linear predictor of the shape parameter of the first component distribution. This is ln(gamma1) for all 
models.

{phang}
{opt lambda2(varlist)} covariates to include in the linear predictor of the scale parameter of the second component distribution. This is ln(lambda2) for all models.

{phang}
{opt gamma2(varlist)} covariates to include in the linear predictor of the shape parameter of the second component distribution. This is ln(gamma2) and is only allowed under a mixture 
{cmd:weibweib} model.

{phang}
{opt pmix(varlist)} covariates to include in the linear predictor of the mixture parameter.

{dlgtab:Reporting}

{phang}
{opt nohr} may be specified at estimation or upon redisplaying results, specifies that coefficients rather than exponentiated coefficients be displayed, 
i.e., that coefficients rather than hazard ratios be displayed. This option affects only how coefficients are displayed, not how they are estimated.

{phang}
{opt showinit} displays the output from the inital value model fit, whereby the mixture parameter is constrained to 0 (on the logit scale).

{phang}
{opt showcons} displays the constraints used by {help stmix}.

{phang}
{opt keepcons} do not drop the constraints used in the ml routine.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.

{dlgtab:Maximization}

{phang}
{opt initmat(matrix_name)} pass a matrix of initial values to the full model.

{phang}
{opt noinit} do not fit the initial value model.

{phang}
{opt pmixconstraint(#)} gives the value of the contraint on the mixture parameter when obtaining initial values. Default is 0 (on the logistic scale).

{marker maximize_options}{...}
{phang}
{it:maximize_options}; {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, 
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient}, 
{opt showstep}, {opt hess:ian}, {opt shownr:tolerance}, {opt tol:erance(#)}, 
{opt ltol:erance(#)} {opt gtol:erance(#)}, {opt nrtol:erance(#)}, 
{opt nonrtol:erance}, {opt from(init_specs)}; see {manhelp maximize R}.  These 
options are seldom used, but the {opt difficult} option may be useful if there
are convergence problems.


{title:Remark}

{pstd}Note: Covariate effects can be interpreted as hazard ratios only if {cmd:lambda1}, {cmd:gamma1}, {cmd:lambda2}, {cmd:gamma2} and {cmd:pmix} are left empty.{p_end}


{title:Example}

{pstd}Setup{p_end}
{phang2}{stata "webuse brcancer"}{p_end}
{phang2}{stata "stset rectime, failure(censrec = 1) scale(365.25)"}{p_end}

{pstd}Mixture Weibull-Weibull proportional hazards model{p_end}
{phang2}{stata "stmix hormon, dist(ww)"}{p_end}


{title:Authors}

{pstd}Michael J. Crowther, University of Leicester, UK. E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}.{p_end}

{pstd}Paul C. Lambert, University of Leicester, UK. E-mail: {browse "mailto:paul.lambert@le.ac.uk":paul.lambert@le.ac.uk}.{p_end}

{phang}
Please report any errors you may find.{p_end}


{title:References}

{phang}
McLachlan, G. J. & McGiffin, D. C. On the role of finite mixture models in survival analysis. Stat Methods Med Res, 1994, 3, 211-226.{p_end}

{phang}
Gelfand, A. E.; Ghosh, S. K.; Christiansen, C.; Soumerai, S. B. & McLaughlin, T. J. Proportional hazards models: a latent competing risk approach Journal of the Royal Statistical Society: Series C (Applied Statistics), 2000, 49, 385-397.{p_end}


{title:Also see}

{psee}
Online: {helpb stmix postestimation}
{p_end}
