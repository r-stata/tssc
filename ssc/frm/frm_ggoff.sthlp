{smcl}
{* *! version 1.1.0 - 18 Feb 2013}{...}
help for {cmd:frm_ggoff}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd: frm_ggoff} {hline 2}}GGOFF, GOFF1 and GOOFF2 tests for fractional regression models
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:frm_ggoff} [{it:anything}]
[{cmd:,} {it:options}]

{synoptset 26}{...}
{synopthdr}
{synoptline}
{synopt:{opt lm}}specify the LM version of the tests to be performed{p_end}
{synopt:{opt w:ald}}specify the Wald version of the tests to be performed{p_end}
{synopt:{opt lr}}specify the LR version of the tests to be performed{p_end}
{synopt:{cmd:ml}}use maximum likelihood optimization{p_end}
{synopt:{cmd:irls}}iterated, reweighted least-squares optimization of the deviance{p_end}
{synopt:{it:{help frm##maximize_options:maximize_options}}}control the maximization
process of the estimations required to perform Wald and LR tests{p_end}
{synopt:{opt fisher(#)}}use the Fisher scoring Hessian or expected information matrix (EIM){p_end}
{synopt:{cmd:search}}search for good starting values{p_end}
{synoptline}

{pstd} where {it:anything}, if provided, is the name under which estimation results were saved via {help estimates_store:estimates store}. Otherwise, 
{cmd:frm_ggoff} is applied to the last estimation results, even if these were not already stored.


{title:Description}

{pstd} {cmd:frm_ggoff} applies the GGOFF, GOFF1 and GOOFF2 test statistics to fractional regression
models estimated via {help frm:frm}. {cmd:frm_ggoff} may be used to test the link
specification of: (i) one-part fractional regression models; (ii) the binary
component of two-part fractional regression models; and (iii) the fractional
component of two-part fractional regression models. See Ramalho, Ramalho
and Murteira (2014) for details on the application of the GGOFF, GOFF1 and GOOFF2 tests in the
fractional regression framework.


{title:Options}

{phang} {opt lm} specifies that the LM versions of the tests are to be
performed. Unless the model to be tested is the binary component of a
two-part fractional regression model, a robust version is implemented. This
is the default option.

{phang} {opt wald} specifies that the Wald versions of the tests are to
be performed. It is implemented taking into account the option chosen for
computing standard errors in the estimation of the model under evaluation.
The alternative model is approximatted by the null model with
additional regressors; see Section 3 of Ramalho, Ramalho and Murteira (2013).

{phang} {opt lr} specifies that the LR versions of the tests are to be
performed. This option is only available for the binary component of a
two-part fractional regression model. The alternative model is approximatted
by the null model with additional regressors; see Section 3 of Ramalho, Ramalho
and Murteira (2013).

{phang} {cmd:ml} requests that optimization of the alternative model is
carried out using Stata's {cmd:ml} commands and is the default. All
{it:maximize_options} are available. Only useful for Wald and LR tests.

{phang} {cmd:irls} requests iterated, reweighted least-squares (IRLS) optimization
of the deviance of the alternative model. The only available {it:maximize_options} are {opt iterate(#)},
{opt trace} and {opt ltolerance(#)}. Only useful for the Wald test.

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
only be used in association with {cmd:ml} and not with {cmd:irls}. Only useful for Wald and LR tests.

{phang} {cmd:search} specifies that the command search for good starting values.
This option is useful only for Newton-Raphson optimization and can
only be used in association with {cmd:ml} and not with {cmd:irls}. Only useful for Wald and LR tests.


{title:Examples}

{pstd}Setup - data used in Ramalho, Ramalho and Henriques (2010){p_end}
{phang2}{cmd:. use http://evunix.uevora.pt/~jsr/stata/JPA-2010.dta}{p_end}

{pstd}Testing the logit specification of a standard fractional regression
model{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO}{p_end}
{phang2}{cmd:. frm_ggoff}{p_end}

{pstd}Testing probit and cloglog specifications of binary regression models using
LR-based tests{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, m(2Pbin) linkb(probit) inf(1)}{p_end}
{phang2}{cmd:. estimates store a1}{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, m(2Pbin) linkb(cloglog) inf(1)}{p_end}
{phang2}{cmd:. estimates store a2}{p_end}
{phang2}{cmd:. frm_ggoff a1, lr}{p_end}
{phang2}{cmd:. frm_ggoff a2, lr}{p_end}


{title:Saved results}

{pstd}
{cmd:frm_reset} saves results of the following type in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 6 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(GGOFF_LM)}}LM-based GGOFF statistic{p_end}
{synopt:{cmd:r(GGOFF_LMp)}}p-value for the statistic {cmd:r(GGOFF_LM)}{p_end}
{synopt:{cmd:r(GOFF1_LM)}}LM-based GOFF1 statistic{p_end}
{synopt:{cmd:r(GOFF1_LMp)}}p-value for the GOFF1 statistic {cmd:r(GOFF1_LM)}{p_end}
{synopt:{cmd:r(GOFF2_LM)}}LM-based GOFF2 statistic{p_end}
{synopt:{cmd:r(GOFF2_LMp)}}p-value for the GOFF2 statistic {cmd:r(GOFF2_LM)}{p_end}
{p2colreset}{...}

{pstd} If Wald and LR versions of the tests are computed, then
{cmd:r(GGOFF_W)}, {cmd:r(GGOFF_LR)}, etc. are also saved.


{title:Author}

{pstd}Joaquim J.S. Ramalho{p_end}
{pstd}Department of Economics{p_end}
{pstd}University of Evora{p_end}
{pstd}Portugal{p_end}
{pstd}jsr@uevora.pt{p_end}


{title:Remarks}

{pstd} {cmd:frm_ggoff} is not an official Stata command. For further help and
support, please contact the author. Please notice that this software
is provided as is, without warranty of any kind, expressed or implied,
including but not limited to the warranties of merchantability, fitness
for a particular purpose, and noninfringement. In no event shall the
author be liable for any claim, damages, or other liability, whether in
an action of contract, tort, or otherwise, arising from, out of, or
in connection with the software or the use or other dealings in the
software.


{title:References}

{phang}
Ramalho, E.A., J.J.S. Ramalho and J.M.R. Murteira (2014), "A generalized
goodness-of-functional form test for binary and fractional regression models",
Manchester School, forthcoming.

{phang}
Ramalho, E.A., J.J.S. Ramalho and P.D. Henriques (2010), "Fractional
regression models for second stage DEA efficiency analyses", Journal of
Productivity Analysis, 34(3), 239-255.


{title:Also see}

{pstd} Online: help for {help frm:frm}
