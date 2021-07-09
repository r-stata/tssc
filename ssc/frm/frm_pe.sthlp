{smcl}
{* *! version 1.1.0 - 19 Feb 2013}{...}
help for {cmd:frm_pe}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{cmd: frm_pe} {hline 2}}Partial effects for one-part and two-part fractional regression models
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:frm_pe} {it:anything}
[{cmd:,} {it:options}]

{synoptset 26}{...}
{synopthdr}
{synoptline}
{synopt:{opt ape(varlist)}}estimate average partial effects of variables in {it:varlist}{p_end}
{synopt:{opt cpe(varlist)}}estimate conditional partial effects of variables in {it:varlist}{p_end}
{synopt:{opt at(atspec)}}estimate partial effects at specified values of covariates{p_end}
{synoptline}

{pstd} where {it:anything}, if provided, is the name or, for two-part models, names under which
estimation results were saved via {help estimates_store:estimates store}. Otherwise, {cmd:frm_pe}
is applied to the last estimation results, even if these were not already stored. In the case of
two-part models the first name should index the binary model and the second the fractional model.


{title:Description}

{pstd} {cmd:frm_pe} calculates partial effects for fractional regression models estimated via
{help frm:frm}. {cmd:frm_pe} may be used to compute average or conditional partial effects for:
(i) one-part fractional regression models; (ii) the binary component of two-part fractional
regression models; (iii) the fractional component of two-part fractional regression
models; and (iv) two-part fractional regression models. For two-part models only the value of
the partial effects is computed, while in the other cases standard errors and confidence
intervals calculated using the delta method are also provided. See Ramalho, Ramalho
and Murteira (2011) for details on the computation of partial effects in the fractional
regression framework.


{title:Options}

{phang} {opt ape(varlist)} specifies that average partial effects are to be computed for
the variables in {it:varlist}.

{phang} {opt cpe(varlist)} specifies that conditional partial effects are to be computed for
the variables in {it:varlist}. All variables are evaluated at their mean values except if
specified otherwise in {cmd:at(}{it:atspec}{cmd:)}.

{phang} {opt at(atspec)} indicates the specific values at which some of the explanatory
variables are to be evaluated.


{title:Examples}

{pstd}Setup - data used in Ramalho, Ramalho and Henriques (2010){p_end}
{phang2}{cmd:. use http://evunix.uevora.pt/~jsr/stata/JPA-2010.dta}{p_end}

{pstd}Computing average partial effects for a logit fractional regression model{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO}{p_end}
{phang2}{cmd:. frm_pe, ape(LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO)}{p_end}

{pstd}Computing average partial effects for a binary logit + fractional probit
two-part model, with ALTO=1{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, m(2Pbin) inf(1)}{p_end}
{phang2}{cmd:. estimates store a1}{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, m(2Pfrac) linkf(probit) inf(1)}{p_end}
{phang2}{cmd:. estimates store a2}{p_end}
{phang2}{cmd:. frm_pe a1 a2, ape(LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO) at(ALTO=1)}{p_end}

{pstd}Computing conditional partial effects for LIVESTOCK in the logit component of a
two-part fractional regression model, with all explanatory variables evaluated at
their mean values except the dummies ALTO=1, CENTRAL=0 and BAIXO=0{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, m(2Pfrac) inf(1)}{p_end}
{phang2}{cmd:. frm_pe, cpe(LIVESTOCK) at(ALTO=1 CENTRAL=0 BAIXO=0)}{p_end}


{title:Saved results}

{pstd}
For one-part models and the individual components of two-part models, {cmd:frm_pe} saves in {cmd:r()}
the same results as {help margins:margins}. For two part-models, no results are saved.


{title:Author}

{pstd}Joaquim J.S. Ramalho{p_end}
{pstd}Department of Economics{p_end}
{pstd}University of Evora{p_end}
{pstd}Portugal{p_end}
{pstd}jsr@uevora.pt{p_end}


{title:Remarks}

{pstd} {cmd:frm_pe} is not an official Stata command. For further help and
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
Ramalho, E.A., J.J.S. Ramalho and J.M.R. Murteira (2011), "Alternative
estimating and testing empirical strategies for fractional regression models",
Journal of Economic Surveys, 25(1), 19-68.

{phang}
Ramalho, E.A., J.J.S. Ramalho and P.D. Henriques (2010), "Fractional
regression models for second stage DEA efficiency analyses", Journal of
Productivity Analysis, 34(3), 239-255.


{title:Also see}

{pstd} Online: help for {help frm:frm}

{pstd} Manual: {manlink R margins}{p_end}
