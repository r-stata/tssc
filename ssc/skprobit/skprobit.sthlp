{smcl}
{* *! version 1.0.0  // A METTRE}{...}
{cmd:help skprobit}
{hline}

{title:Title}

    {hi: Performs Lagrange Multiplier Test for Normality for Probit model}



{title:Syntax}

{p 8 17 2}
{cmd:skprobit}
{depvar}
{indepvars}
{ifin}



{title:Description}

{pstd}
{cmd:skprobit} Performs a Lagrange Multiplier Test for the Normality of the residuals of
a Probit model of depvar on indepvars.



{title:Citation}

{pstd}
{hi:skprobit} is not an official Stata command. The usual disclimers apply: all errors
and imperfections in this package are mine and all comments are very welcome.



{title:Return values}

{col 4}Scalars
{col 8}{cmd:r(N)}{col 27}Number of observations used
{col 8}{cmd:r(chi2_p)}{col 27}p value of the chi-squared statistic
{col 8}{cmd:r(chi2)}{col 27}Chi-squared statistic



{title:Examples}

{p 4 8 2}{stata "sysuse auto"}{p_end}

{p 4 8 2}{stata "probit foreign weight mpg"}{p_end}

{p 4 8 2}{stata "skprobit foreign weight mpg"}{p_end}

{p 4 8 2} The result shows that the Ho (Normality) hypothesis of the residuals is rejected
in this example. The residuals are not normal in this case.

{p 4 8 2}{stata "webuse lbw"}{p_end}

{p 4 8 2}{stata "probit low age lwt race smoke ptl ht ui"}{p_end}

{p 4 8 2}{stata "skprobit low age lwt race smoke ptl ht ui"}{p_end}

{p 4 8 2} The result shows that the Ho (Normality) hypothesis of the residuals is not rejected
in this example. Hence the residuals are normal in this case.

{p 4 8 2}{stata "webuse union"}{p_end}

{p 4 8 2}{stata "probit union age grade not_smsa"}{p_end}

{p 4 8 2}{stata "skprobit union age grade not_smsa"}{p_end}

{p 4 8 2} The result shows that the Ho (Normality) hypothesis of the residuals is rejected
in this example. The residuals are not normal in this case.



{title:Author}

{p 4}Diallo Ibrahima Amadou, {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online:  help for  {bf:{help sktest}}
{p_end}
