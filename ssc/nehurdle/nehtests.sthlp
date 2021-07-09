{smcl}
{* *! Version 1.0.0 09 August 2017}{...}

{title:Title}

{p2colset 5 35 37 2}{...}
{p2col :{helpb nehtests} {hline 4} Postestimation command for {helpb nehurdle}.}{p_end}
{p2colreset}{...}

{title:Syntax}
{pstd} {cmd:nehtests}

{marker description}{...}
{title:Description}

{pstd}
{cmd:nehtests} displays Wald test of joint significance for the parameters of each
of the equations you are estimating, and for the overall model. The number of tests
will depend on the specification of your model you are estimating.

{pstd}
These tests are not valid if you are using {cmd:nehurdle} with {cmd:svy} estimation
results.

{marker examples}{...}
{title:Examples}

{pstd}Data Setup{p_end}
{phang2}. {stata "webuse womenwk, clear"}{p_end}
{phang2}. {stata "replace wage = 0 if missing(wage)"}{p_end}
{phang2}. {stata "global xvars i.married children educ age"}{p_end}

{pstd}Homoskedastic Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, tobit nolog"}{p_end}
{phang2}. {stata "nehtests"}{p_end}

{pstd}Heteroskedastic Exponential Truncated Hurdle{p_end}
{phang2}. {stata "nehurdle wage $xvars, expon het($xvars) nolog"}{p_end}
{phang2}. {stata "nehtests"}{p_end}

{pstd}Heteroskedastic Exponential Type II Tobit{p_end}
{phang2}. {stata "nehurdle wage $xvars, heckman expon het($xvars) nolog"}{p_end}
{phang2}. {stata "nehtests"}{p_end}

