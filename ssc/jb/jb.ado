*! Jarque-Bera normality test 
* Orignally written by Gregorio Impavido
* GI gimpavido@worldbank.or
* Formula and code slightly modified by J. Sky David 
* See C.M. Jarque and A.K. Bera. 1987. "A Test for Normality 
* of Observations and Regression Residuals."  International 
* Statistical Review 55:163-172.;
* In Gujarati 1995 Basic Econometrics pp. 143-144
* there was an error found on the sixth line of the code.
* some parentheses were missing on that line.
* the problem was corrected (9-12-00).

program define jb
version 5.0

local varlist "required existing max(1)"

parse "`*'"
qui summ `varlist', det
local JB = (_result(1)/6)*((_result(14)^2)+[(1/4)*(_result(15)-3)^2]) 
local JBsig = chiprob(2, `JB')
noi di in gr "Jarque-Bera normality test: " /*
*/in ye %6.5g `JB' , in gr /*
*/ "Chi(" in ye "2" in gr ")" , in ye %6.5g (`JBsig')

noi di in gr "Jarque-Bera test for Ho: normality:

end 
exit


