{smcl}
{* *! version 1.1.0 - 18 Feb 2013}{...}
help for {cmd:frm_ptest}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd: frm_ptest} {hline 2}}P test for non-nested one-part and two-part fractional regression models
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:frm_ptest,}
{cmd:mod1}({it:name_model1a} [{it:name_model1b}])
{cmd:mod2}({it:name_model2a} [{it:name_model2b}])
[{it:options}]

{synoptset 26}{...}
{synopthdr}
{synoptline}
{synopt:{opt lm}}specify the LM version of the P test to be performed{p_end}
{synopt:{opt w:ald}}specify the t version of the P test to be performed{p_end}
{synoptline}

{pstd} where {it:name_mod1a}, {it:name_mod1b}, {it:name_mod2a} and {it:name_mod2b}
are names under which estimation results were saved via {help estimates_store:estimates store}.
The second name in {cmd:mod1} and {cmd:mod2} is only to be provided when testing the full specification of two-part
models.


{title:Description}

{pstd} {cmd:frm_ptest} applies the P test statistic proposed by Davidson and
MacKinnon (1981) to fractional regression models estimated via
{help frm:frm}. {cmd:frm_ptest} may be used to test against each other two alternative
specifications for the link function  in: (i) one-part fractional regression models;
(ii) the binary component of two-part fractional regression models; (iii) the
fractional component of two-part fractional regression models; and (iv) two-part
fractional regression models. In addition, {cmd:frm_ptest} may be used to test
one-part models against two-part models and in cases where the link functions are the
same but the regressors are non-nested. See Ramalho, Ramalho and Murteira (2011)
for details on the application of the P test in the fractional regression framework.


{title:Options}

{phang} {opt lm} specifies that the LM version of the P test is to be
performed. Unless the competing models are alternative specifications for
the binary component of a two-part fractional regression model, a robust LM
test is implemented.

{phang} {opt wald} specifies that the robust t version of the P test is to
be performed. This is the default option.


{title:Examples}

{pstd}Setup - data used in Ramalho, Ramalho and Henriques (2010){p_end}
{phang2}{cmd:. use http://evunix.uevora.pt/~jsr/stata/JPA-2010.dta}{p_end}

{pstd}Testing logit versus loglog specifications for standard fractional regression
models{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO}{p_end}
{phang2}{cmd:. estimates store a1}{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, linkf(loglog)}{p_end}
{phang2}{cmd:. estimates store a2}{p_end}
{phang2}{cmd:. frm_ptest, mod1(a1) mod2(a2)}{p_end}

{pstd}Testing a logit one-part fractional regression model versus a binary logit
+ fractional probit two-part model{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO}{p_end}
{phang2}{cmd:. estimates store a1}{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, m(2Pbin) inf(1)}{p_end}
{phang2}{cmd:. estimates store a2}{p_end}
{phang2}{cmd:. frm SCORE LANDLORD LIVESTOCK CROP SIZE SUBSIDIES ALTO CENTRAL BAIXO, m(2Pfrac) linkf(probit) inf(1)}{p_end}
{phang2}{cmd:. estimates store a3}{p_end}
{phang2}{cmd:. frm_ptest, mod1(a1) mod2(a2 a3)}{p_end}


{title:Saved results}

{pstd}
{cmd:frm_ptest} saves the following in {cmd:r()} if both LM and Wald versions
of the P test are performed:

{synoptset 20 tabbed}{...}
{p2col 6 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(t1)}}t statistic for testing {cmd:mod1} against model {cmd:mod2}{p_end}
{synopt:{cmd:r(t1p)}}p-value for the statistic {cmd:r(t1)}{p_end}
{synopt:{cmd:r(t2)}}t statistic for testing {cmd:mod2} against model {cmd:mod1}{p_end}
{synopt:{cmd:r(t2p)}}p-value for the statistic {cmd:r(t2)}{p_end}
{synopt:{cmd:r(LM1)}}LM statistic for testing {cmd:mod1} against model {cmd:mod2}{p_end}
{synopt:{cmd:r(LM1p)}}p-value for the statistic {cmd:r(LM1)}{p_end}
{synopt:{cmd:r(LM2)}}LM statistic for testing {cmd:mod2} against model {cmd:mod1}{p_end}
{synopt:{cmd:r(LM2p)}}p-value for the statistic {cmd:r(LM2)}{p_end}
{p2colreset}{...}


{title:Author}

{pstd}Joaquim J.S. Ramalho{p_end}
{pstd}Department of Economics{p_end}
{pstd}University of Evora{p_end}
{pstd}Portugal{p_end}
{pstd}jsr@uevora.pt{p_end}


{title:Remarks}

{pstd} {cmd:frm_ptest} is not an official Stata command. For further help and
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
Davidson, R. and J.G. MacKinnon (1981), "Several tests for model specification
on the presence of alternative hypotheses", Econometrica, 49(3), 781-793.

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
