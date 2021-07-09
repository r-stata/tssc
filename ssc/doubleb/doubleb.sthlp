{smcl}
{* September 2013}{...}
{cmd:help doubleb}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:doubleb} {hline 2}} Contingent Valuation using Double-Bounded Dichotomous Choice {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:doubleb} {varlist}  {ifin} {weight} [{cmd:,} {opt level(#)} {opt noconstant} ]


{title:Description}

{pstd} 
This command uses maximum likelihood (under the assumption of normality) to estimate the double-bounded dichotomous choice model for contingent valuation proposed by Hanemann, Loomis and Kanninen (1991). Haab and McConnell (2002, pp. 123-125) refer to this as the Interval Data Model. {p_end}

{pstd} 
For more details on the use of the command see Lopez-Feldman (2012) or Lopez-Feldman(2013). {p_end}

{title:Remarks}

{pstd} 
The first and second variables in {varlist} should be the first and second bid variables, respectively. The third and fourth variables should be the dummies for the response to the first and second
dichotomous choice questions, respectively. The remaining variables will be interpreted as covariates or control variables.{p_end}

{pstd} 
Note that the second bid variable refers to the actual bid offered after the individual has answered to the first bid.{p_end}

{title:Examples}

{phang2}{cmd:. doubleb bid1 bid2 response1 response2}

{phang2}{cmd:. doubleb bid1 bid2 response1 response2 x1 x2}

{pstd}Use file doubleb.dta to do the examples {p_end}


{title:Author}

{p 4 8 2}Alejandro Lopez-Feldman{p_end}
{p 4 8 2}Centro de Investigacion y Docencia Economicas, CIDE{p_end}
{p 4 8 2}Email: {browse "mailto:lopezfeldman@gmail.com": lopezfeldman@gmail.com}

{title:Conditions of use}

{pstd}
    {cmd:doubleb} is not an official Stata command. There is no warranty and the author cannot accept any responsability for the use of this software.{p_end}

{pstd}
	Software should be cited at all times. {p_end}

{title:Suggested citation}

    Please cite as:

{phang}Lopez-Feldman, A. 2010. doubleb: Stata module to estimate contingent valuation using Double-Bounded Dichotomous Choice Model. Available at {browse "http://ideas.repec.org/c/boc/bocode/s457168.html"}

{title:References}

{phang}Hanemann, M., Loomis, J and B. Kanninen. 1991. Statistical Efficiency of Double-Bounded Dichotomous 
Choice Contingent Valuation. {it:American Journal of Agricultural Economics} 73: 1255-63.

{phang}Lopez-Feldman, A., 2012 {it:Introduction to contingent valuation using Stata} MPRA paper 41018. Available at {browse "http://ideas.repec.org/p/pra/mprapa/41018.html"}

{phang}Lopez-Feldman, A., 2013 {it:Introduccion a la valoracion contingente utilizando Stata} en Mendoza, A. {it:Aplicaciones en economia y ciencias sociales con Stata.} Stata Press.

{phang}Haab, T. and K, McConnell. 2002. {it:Valuing Environmental and Natural Resources. The Econometrics of Non-Market Valuation.} 
Edward Elgar, Massachusetts.


{title:Acknowledgments}

{pstd} 
I thank Brett Day for sharing the Stata code that helped me to get started writing this command. 
