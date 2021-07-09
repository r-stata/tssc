{smcl}
{* *! version 1.0.0  10jul2015}{...}
{viewerjumpto "Syntax" "svarsirf##syntax"}{...}
{viewerjumpto "Description" "svarsirf##description"}{...}
{viewerjumpto "Options" "svarsirf##options"}{...}
{viewerjumpto "Examples" "svarsirf##examples"}{...}
{viewerjumpto "Stored results" "svarsirf##results"}{...}
{viewerjumpto "Authors" "svarsirf##authors"}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col:svarsirf {hline 2}}SVAR structural impulse response function{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmdab:svarsirf:} 
[{cmd:,}
{it:options}]

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt st:eps(#)}}number of steps {it:#} for SIRF and standard errors; default is 
{cmd:steps(12)}{p_end}
{synopt:{opt nose: }}do not calculate standard errors{p_end}

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmdab: svarsirf} can only be used after {cmdab: svar}. It calculates the SVAR structural 
impulse response function (SIRF) and its asymptotic standard errors (SE). 
It produces the same results as {cmdab:irf create} but it is much faster! NB: it will
calculate the wrong sirf and se if lags in {cmdab: svar} are defined differently 
from {cmdab: lag(1/n)}. 

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt st:eps(#)} defines the number of steps for the calculations of the SIRF and
SE. This number excludes the contemporaneus impulse response so that {cmd:steps(5)} 
(say) will produce 6 values.

{phang}
{opt nose: } forces the program not to calculate the asymptotic standard errors.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. webuse lutkepohl2.dta, clear}{p_end}
{phang}{cmd:. mat A0=(1,-0.317934,-.217459\ .,1,-0.888381\ .,.,1)}{p_end}
{phang}{cmd:. mat B=(.,0,0 \ 0,.,0 \ 0,0,.)}{p_end}
{phang}{cmd:. quietly svar dln_c dln_inv dln_inc, aeq(A0) beq(B) lags(1/2) dfk}{p_end}
{phang}{cmd:. svarsirf}{p_end}
{phang}{cmd:. svarsirf, steps(50)}{p_end}
{phang}{cmd:. svarsirf, steps(50) nose}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:svarsirf} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(head)}}The list of impulse_response{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(SIRFSE)}}The matrix of the asymptotic standard errors if option 
{cmd: nose}  is not selected{p_end}
{synopt:{cmd:r(SIRF)}}The matrix of the structural impulse response functions{p_end}

{marker authors}{...}
{title:Authors}

{pstd}
Gregorio Impavido (gimpavido@imf.org)

{pstd}
Li Tang (ltang@imf.org)

{p2colreset}{...}
