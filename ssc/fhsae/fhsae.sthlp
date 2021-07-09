{smcl}
{* *! version 1.0.0  30April2018}{...}
{cmd:help fhsae}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col :{cmd:fhsae} {hline 1} Fits area level Fay-Herriot model. Translated into Stata from R's SAE package by Molina and Marhuenda.}{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 23 2}
{opt fhsae} {varlist} {ifin} {cmd:,}
{opt RE:var(varname)}
{opt method(string)}
[{opt precision(real)}
{opt maxiter(integer)}
{opt FH:predict(newvarname)}
{opt FHSE:predict(newvarname)}
{opt FHCV:predict(newvarname)}
{opt DSE:predict(newvarname)}
{opt DCV:predict(newvarname)}
{opt AREA:predict(newvarname)}
{opt GAMMA:predict(newvarname)}
{opt OUT:sample}
{opt NONEG:ative}]

{title:Description}

{pstd}
{cmd:fhsae} Supports Fay-Herriot's EBLUP small area estimation methods. Translated from R's SAE package from Molina and Marhuenda. 

{title:Options}

{phang}
{opt RE:var(varname)} Variable containing dependent variable's design-based sampling variance

{phang}
{opt method(string)} Chosen fitting method. Allowed methods: ML (Max. likelihood); FH (Fay Herriot's moment's method); REML (Restricted max. likelihood); CHANDRA (FGLS)

{phang}
{opt precision(real)} Fitting method's precision, default value is 1e-15

{phang}
{opt maxiter(integer)} Number of iterations before command gives up on estimation, default is 100

{phang}
{opt FH:predict(newvarname)} New variable name for predicted Fay Herriot small area estimate

{phang}
{opt FHSE:predict(newvarname)} New variable name for predicted Fay Herriot small area estimate standard error

{phang}
{opt FHCV:predict(newvarname)} New variable name for predicted Fay Herriot small area estimate coefficient of variation

{phang}
{opt DSE:predict(newvarname)} New variable name for predicted Fay Herriot direct estimate standard error 

{phang}
{opt DCV:predict(newvarname)} New variable name for predicted Fay Herriot direct estimate coefficient of variation

{phang}
{opt AREA:predict(newvarname)} New variable name for predicted Fay Herriot area effects (Only for chandra method)

{phang}
{opt OUT:sample} Requests that predictions be made for out of sample observations (requires any of the options fhpredict, fhsepredict, fhcvpredict to be specified )

{phang}
{opt NONEG:ative} Requests that negative predictions be set to 0.

{title:Example}
fhsae yield hh_f hh_size, revar(vd) method(FH) fhpredict(fh) fhse(fhse) outsample


{title:Translated into Stata by:}

{pstd}
Paul Corral{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
pcorralrodas@worldbank.org{p_end}

{pstd}
William Seitz{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
wseitz@worldbank.org{p_end}

{pstd}
Joao Pedro de Azevedo{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
jazevedo@worldbank.org{p_end}

{pstd}
Minh Cong Nguyen{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
mnguyen3@worldbank.org{p_end}


{pstd}
Any error or omission is the authors’ responsibility alone.





{title:References}

{pstd}
Molina, I., Marhuenda, Y. (2015). R package sae: Methodology.

{pstd}
Chandra, H., Sud, U. C., & Gupta, V. K. (2013). Small Area Estimation under Area Level Model Using R Software.

{pstd}
Molina, I., & Marhuenda, Y. (2015). sae: An R package for small area estimation. The R Journal, 7(1), 81-98.

{pstd}
Fay III, R. E., & Herriot, R. A. (1979). Estimates of income for small places: an application of James-Stein procedures to census data. Journal of the American Statistical Association, 74(366a), 269-277.

