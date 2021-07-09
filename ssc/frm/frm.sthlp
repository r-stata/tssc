{smcl}
{* *! version 1.1.0 - 18 Feb 2013}{...}
help for {cmd:frm}
{hline}

{title:Title}

{p2colset 5 13 15 2}{...}
{p2col :{cmd: frm} {hline 2}}Estimation of one-part and two-part fractional regression models
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:frm}
{depvar}
{indepvars}
{ifin}
[{cmd:,} {it:options}]

{synoptset 26}{...}
{synopthdr}
{synoptline}
{synopt:{opt m:odel(mod_type)}}specify the fractional regression model to be estimated{p_end}
{synopt:{opt linkb:in(binary_linkname)}}specify the link function for the binary component
of a two-part regression model{p_end}
{synopt:{opt linkf:rac(frac_linkname)}}specify the link function for a one-part fractional
regression model or the fractional component of a two-part fractional regression model{p_end}
{synopt:{opt vceb:in(vcetype)}}specify the type of standard error
to compute in the binary component of a two-part regression model{p_end}
{synopt:{opt vcef:rac(vcetype)}}specify the type of standard error
to compute in a one-part fractional regression model or the fractional component of a two-part
regression model{p_end}
{synopt:{opt inf:lation(2P_indicator)}}specify which of the extreme values of 0 or 1 is the
relevant boundary value for defining two-part fractional regression models{p_end}
{synopt:{opth y2P(newvar)}}save the predicted values of the dependent variable of a two-part
fractional regression model{p_end}
{synopt:{opt dropb:in(varlist)}}drops variables in {it:varlist} when estimating the binary component a two-part
fractional regression model{p_end}
{synopt:{opt dropf:rac(varlist)}}drops variables in {it:varlist} when estimating the fractional component a two-part
fractional regression model{p_end}
{synopt:{cmd:ml}}use maximum likelihood optimization{p_end}
{synopt:{cmd:irls}}iterated, reweighted least-squares optimization of the deviance{p_end}
{synopt:{it:{help frm##maximize_options:maximize_options}}}control the maximization process{p_end}
{synopt:{opt fisher(#)}}use the Fisher scoring Hessian or expected information matrix (EIM){p_end}
{synopt:{cmd:search}}search for good starting values{p_end}
{synoptline}


{title:Description}

{pstd} {cmd:frm} estimates one- and two-part fractional regression models; see
Ramalho, Ramalho and Murteira (2011) for details on those models. The one-part
models and the fractional component of two-part models are estimated by
Bernoulli-based quasi-maximum likelihood, while the binary component of
two-part models is estimated by maximum likelihood. {cmd:frm} uses the standard
{cmd:glm} command to perform the estimations. Therefore,
{cmd:frm} is essentially a convenience command, allowing estimation of several
alternative fractional regression models using the same command. In addition,
{cmd:frm} provides an R-squared measure for all models (calculated as the square
of the correlation coefficient between the actual and fitted values of the
dependent variable), calculates the fitted values of the dependent variable in
two-part models and stores the information needed to implement some very useful
commands for fractional regression models: {help frm_reset:frm_reset} (RESET test),
{help frm_ptest:frm_ptest} (P test), {help frm_ggoff:frm_ggoff} (GGOFF tests)
and {help frm_pe:frm_pe} (partial effects).


{title:Options}

{phang}
{opt model(mod_type)} specifies which kind of fractional regression model is to be
estimated; the following models are allowed:

{pmore} {cmd:model(1P)} specifies to estimate a one-part fractional regression
model.

{pmore} {cmd:model(2Pbin)} specifies to estimate the binary component of a
two-part fractional regression model.

{pmore} {cmd:model(2Pfrac)} specifies to estimate the fractional component of a
two-part fractional regression model.

{pmore} {cmd:model(2P)} specifies to estimate both components of a two-part
fractional regression model. In this case {it:indepvars} must include all explanatory
variables, even those that appear in only one component of the two-part model.

{pmore} The default is {cmd:model(1P)}.

{phang}
{opt linkbin(binary_linkname)} specifies the link function to use in the binary
component of the two-part fractional regression model; the following links are
allowed:

{pmore} {cmd:linkbin(cauchit)} specifies to use a cauchit link function.

{pmore} {cmd:linkbin(logit)} specifies to use a logit link function.

{pmore} {cmd:linkbin(probit)} specifies to use a probit link function.

{pmore} {cmd:linkbin(loglog)} specifies to use a loglog link function.

{pmore} {cmd:linkbin(cloglog)} specifies to use a cloglog link function.

{pmore} The default is {cmd:linkbin(logit)}.

{phang}
{opt linkfrac(frac_linkname)} specifies the link function to use in a one-part
fractional regression model or in the fractional component of the two-part
fractional regression model; the following links are allowed:

{pmore} {cmd:linkfrac(cauchit)} specifies to use a cauchit link function.

{pmore} {cmd:linkfrac(logit)} specifies to use a logit link function.

{pmore} {cmd:linkfrac(probit)} specifies to use a probit link function.

{pmore} {cmd:linkfrac(loglog)} specifies to use a loglog link function.

{pmore} {cmd:linkfrac(cloglog)} specifies to use a cloglog link function.

{pmore} The default is {cmd:linkfrac(logit)}.

{phang} {opt vcebin(vcetype)}specifies the type of standard error reported for the
binary component of two-part fractional regression models, which
includes types that are derived from asymptotic theory, that are robust to some
kinds of misspecification, that allow for intragroup correlation, and that use
bootstrap or jackknife methods; as in {help glm:glm}, {it:vcetype} may be {opt oim},
{opt r:obust}, {opt cl:uster} {it:clustvar}, {opt eim}, {opt opg}, {opt boot:strap},
{opt jack:knife}, {opt hac} {it:kernel}, {opt jackknife1},
or {opt unb:iased}; see {help glm##vcetype:{it:glm_vcetype}} for details. The default
is {cmd:eim}. {opt vcebin(vcetype)} affects the standard errors and
variance-covariance matrix of the estimators but not the estimated coefficients.{p_end}

{phang} {opt vcefrac(vcetype)}specifies the type of standard error reported for one-part
models and the fractional component of two-part models, which
includes types that are derived from asymptotic theory, that are robust to some
kinds of misspecification, that allow for intragroup correlation, and that use
bootstrap or jackknife methods; as in {help glm:glm}, {it:vcetype} may be {opt oim},
{opt r:obust}, {opt cl:uster} {it:clustvar}, {opt eim}, {opt opg}, {opt boot:strap},
{opt jack:knife}, {opt hac} {it:kernel}, {opt jackknife1},
or {opt unb:iased}; see {help glm##vcetype:{it:glm_vcetype}} for details. The default
is {cmd:robust}. {opt vce(vcetype)} affects the standard errors and variance-covariance
matrix of the estimators but not the estimated coefficients.{p_end}

{phang}
{opt inflation(2P_indicator)} specifies which of the extreme values of 0 or 1
is the relevant boundary value for defining two-part fractional regression
models; the following options are allowed:

{pmore} {cmd:inflation(0)} specifies that the relevant boundary value is 0.

{pmore} {cmd:inflation(1)} specifies that the relevant boundary value is 1.

{pmore} The default is {cmd:inflation(0)}.

{phang} {opt y2P(newvar)} specifies that the fitted values of the dependent
variable in two-part fractional regression models is to be saved under the name
{it:newvar}.  This option can be used only with option {cmd:model(2P)}.

{phang} {opt dropbin(varlist)} specifies that the variables in {it:varlist} are not
to be used in the binary component of the two-part fractional regression model.
This option can be used only with option {cmd:model(2P)}.

{phang} {opt dropfrac(varlist)} specifies that the variables in {it:varlist} are not
to be used in the fractional component of the two-part fractional regression model.
This option can be used only with option {cmd:model(2P)}.

{phang} {cmd:ml} requests that optimization be carried out using Stata's {cmd:ml}
commands and is the default. All {it:maximize_options} are available.

{phang} {cmd:irls} requests iterated, reweighted least-squares (IRLS) optimization
of the deviance. The only available {it:maximize_options} are {opt iterate(#)},
{opt trace} and {opt ltolerance(#)}.

{marker maximize_options}{...}
{phang}
{it:maximize_options}:
{opt tech:nique(algorithm_spec)},
{opt iter:ate(#)},
{opt tr:ace},
{opt dif:ficult},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance},
{opt from(init_specs)}; see {manhelp maximize R} for details.

{phang} {opt fisher(#)} specifies the number of Newton-Raphson steps that should
use the Fisher scoring Hessian or EIM before switching to the observed information
matrix (OIM). This option is useful only for Newton-Raphson optimization and can
only be used in association with {cmd:ml} and not with {cmd:irls}.

{phang} {cmd:search} specifies that the command search for good starting values.
This option is useful only for Newton-Raphson optimization and can
only be used in association with {cmd:ml} and not with {cmd:irls}.


{title:Examples}

{pstd}Setup - data used in Ramalho, Ramalho and Henriques (2010){p_end}
{phang2}{cmd:. use http://evunix.uevora.pt/~jsr/stata/JPA-2010.dta}{p_end}

{pstd}{cmd:frm} estimation of a logit fractional regression model{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO}{p_end}

{pstd}{cmd:frm} estimation of the binary logit component of the two-part fractional
regression model with {cmd:SCORE}=1 as the relevant boundary value{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, model(2Pbin) inf(1)}{p_end}

{pstd}{cmd:frm} estimation of the fractional component of the two-part fractional
regression model with {cmd:SCORE}=1 as the relevant boundary value and using a
probit link function{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, model(2Pfrac) linkf(probit) inf(1)}{p_end}

{pstd}{cmd:frm} estimation of both components of a two-part fractional
regression model with {cmd:SCORE}=1 as the relevant boundary value and using a
cloglog binary link function and a logit fractional link function{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, model(2P) linkb(cloglog) inf(1)}{p_end}

{pstd}{cmd:frm} estimation of both components of a two-part fractional
regression model with {cmd:SCORE}=1 as the relevant boundary value, using a
cloglog binary link function and a logit fractional link function and using
the variables CENTRAL and BAIXO only in the binary component of the model{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, model(2P) linkb(cloglog) inf(1) dropf(CENTRAL BAIXO)}{p_end}


{title:Saved results}

{pstd}
The results saved by {cmd:frm} depends on {opt model(mod_type)}, as follows:

{pstd} {cmd:model(2P)}: no results are saved.

{pstd} {cmd:model(1P)}: in addition to the usual results saved after {cmd:glm},
with {cmd:e(cmd)} and {cmd:e(cmdline)} changed as appropriate, {cmd:frm} also saves the following:

{synoptset 20 tabbed}{...}
{p2col 6 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(R2)}}R squared{p_end}
{p2colreset}{...}

{synoptset 20 tabbed}{...}
{p2col 6 20 24 2: Macros}{p_end}
{synopt:{cmd:e(model)}}model type{p_end}
{synopt:{cmd:e(linkfrac)}}fractional link function{p_end}
{p2colreset}{...}

{pstd} {cmd:model(2Pbin)}: in addition to the usual results saved after {cmd:glm}, with {cmd:e(cmd)} and {cmd:e(cmdline)}
changed as appropriate, {cmd:frm} also saves the following:

{synoptset 20 tabbed}{...}
{p2col 6 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(inflation)}}boundary value defining two-part models{p_end}
{synopt:{cmd:e(R2)}}R squared{p_end}

{synoptset 20 tabbed}{...}
{p2col 6 20 24 2: Macros}{p_end}
{synopt:{cmd:e(model)}}model type{p_end}
{synopt:{cmd:e(linkbin)}}binary link function{p_end}
{p2colreset}{...}

{pstd} {cmd:model(2Pfrac)}: in addition to the usual results saved after {cmd:glm},
with {cmd:e(cmd)} and {cmd:e(cmdline)} changed as appropriate,
{cmd:frm} also saves the following:

{synoptset 20 tabbed}{...}
{p2col 6 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(inflation)}}boundary value defining two-part models{p_end}
{synopt:{cmd:e(R2)}}R squared{p_end}

{synoptset 20 tabbed}{...}
{p2col 6 20 24 2: Macros}{p_end}
{synopt:{cmd:e(model)}}model type{p_end}
{synopt:{cmd:e(linkfrac)}}fractional link function{p_end}
{p2colreset}{...}


{title:Author}

{pstd}Joaquim J.S. Ramalho{p_end}
{pstd}Department of Economics{p_end}
{pstd}University of Evora{p_end}
{pstd}Portugal{p_end}
{pstd}jsr@uevora.pt{p_end}


{title:Remarks}

{pstd} {cmd:frm} is not an official Stata command. For further help and
support, please contact the author. Please notice that this software
is provided as is, without warranty of any kind, expressed or implied,
including but not limited to the warranties of merchantability, fitness
for a particular purpose, and noninfringement. In no event shall the
author be liable for any claim, damages, or other liability, whether in
an action of contract, tort, or otherwise, arising from, out of, or
in connection with the software or the use or other dealings in the
software.


{title:Reference}

{phang}
Ramalho, E.A., J.J.S. Ramalho and J.M.R. Murteira (2011), "Alternative
estimating and testing empirical strategies for fractional regression models",
Journal of Economic Surveys, 25(1), 19-68.

{phang}
Ramalho, E.A., J.J.S. Ramalho and P.D. Henriques (2010), "Fractional
regression models for second stage DEA efficiency analyses", Journal of
Productivity Analysis, 34(3), 239-255.


{title:Also see}

{pstd} Online: help for {help frm_reset:frm_reset}, {help frm_ggoff:frm_ggoff},
{help frm_ptest:frm_ptest} and {help frm_pe:frm_pe}

{pstd} Manual: {manlink R glm}{p_end}
