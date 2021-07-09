{smcl}
{* September 2013}{...}
{cmd:help singleb}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:singleb} {hline 2}} Contingent Valuation using Single-Bounded Dichotomous Choice {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:singleb} {varlist}  {ifin} {weight} [{cmd:,} {opt level(#)} {opt noconstant}]


{title:Description}

{pstd} 
This command uses maximum likelihood (under the assumption of normality) to estimate the single-bounded dichotomous choice model 
for contingent valuation (Cameron and James, 1987). This command provides an alternative to the estimation via {cmd:probit}. 
The main advantage of this procedure is that we directly obtain point estimates (and standard errors) of the marginal effect that  
a change in the explanatory variable has on WTP.{p_end}

{pstd} 
For more details on the use of the command see Lopez-Feldman (2012) or Lopez-Feldman(2013). {p_end}


{title:Remarks}

{pstd} 
The first variable in {varlist} should be the bid variable. The second variable should be the dummy for the response to the
dichotomous choice question. The remaining variables will be interpreted as covariates or control variables.{p_end}

{pstd} 
For the constant only model the constant represents the mean WTP. For the model with explanatory variables the mean WTP can be obtained by 
multiplying the mean vector of explanatory variables by the vector of estimated coefficients.{p_end}

{title:Examples}

{phang2}{cmd:. singleb bid response}

{phang2}{cmd:. singleb bid response x1 x2}

{pstd}Use file singleb.dta to do the examples {p_end}


{title:Author}

{p 4 8 2}Alejandro Lopez-Feldman{p_end}
{p 4 8 2}Centro de Investigacion y Docencia Economicas, CIDE{p_end}
{p 4 8 2}Email: {browse "mailto:lopezfeldman@gmail.com": lopezfeldman@gmail.com}

{title:Conditions of use}

{pstd}
    {cmd:singleb} is not an official Stata command. There is no warranty and the author cannot accept any responsability for the use of this software.{p_end}

{pstd}
	Software should be cited at all times. {p_end}

{title:Suggested citation}

    Please cite as:

{phang}Lopez-Feldman, A. 2011. singleb: Stata module to estimate contingent valuation using Single-Bounded Dichotomous Choice Model. Available at {browse "http://ideas.repec.org/c/boc/bocode/s457298.html"}


{title:References}

{phang}Cameron, T. and M. James. 1987. Estimation Methods for "Closed-Ended" 
Contingent Valuation Surveys. {it:Review of Economics and Statistics} 69: 269-276.

{phang}Lopez-Feldman, A., 2012 {it:Introduction to contingent valuation using Stata} MPRA paper 41018. Available at {browse "http://ideas.repec.org/p/pra/mprapa/41018.html"}

{phang}Lopez-Feldman, A., 2013 {it:Introduccion a la valoracion contingente utilizando Stata} en Mendoza, A. {it:Aplicaciones en economia y ciencias sociales con Stata.} Stata Press.



{title:Acknowledgments}

{pstd} 
I thank Brett Day for sharing the Stata code that helped me to get started writing this command. 
