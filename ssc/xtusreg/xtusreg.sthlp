{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:xtusreg} {hline 2} Executes estimation and inference for fixed-effect dynamic panel data models when panel data consist of unequally spaced time periods.

{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:xtusreg}
{it:depvar}
[{it:indepvars}]
{ifin}

{marker description}{...}
{title:Description}

{phang}
{cmd:xtusreg} estimates coefficients of fixed-effect linear dynamic panel models under unequal spacing of time periods in data, based on the identification and estimation theories developed in 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407616301932":Sasaki and Xin (2017)}. 
The admissible pattern of unequal spacing is the {it:US Spacing} -- see Definition 2 and Example 2 in 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407616301932":Sasaki and Xin (2017)}. 
This spacing pattern is characterized by the availability of {it:two pairs of two consecutive time gaps}. For example, a data set that includes observations from surveys in years 1966, 1967, and 1970 is unequally spaced. However, it exhibits the {it:US Spacing} with two pairs, (0,1) and (3,4), of two consecutive time gaps, as there are 0-year gap between 1966 and 1966, 1-year gap between 1966 and 1967, 3-year gap between 1967 and 1970, and 4-year gap between 1966 and 1970. One may simply run the fixed-effect dynamic panel autoregression of the dependent variable alone. Alternatively, one may run the fixed-effect dynamic panel autoregression with {it:time-varying} covariate(s). The estimator is based on the normalization (see 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407616301932":Sasaki and Xin, 2017, Appendix C.1}) for robustness.

{marker examples}{...}
{title:Examples}

{phang}
({bf:y} dependent variable, {bf:x} {it:time-varying} independent variable(s))

{phang}Estimation of the AR(1) coefficient of {bf:y}:

{phang}{cmd:. xtset id year}{p_end}
{phang}{cmd:. xtusreg y}{p_end}

{phang}Estimation of the AR(1) coefficient of {bf:y} and the coefficient(s) of {bf:x}:

{phang}{cmd:. xtset id year}{p_end}
{phang}{cmd:. xtusreg y x}{p_end}

{title:Reference}

{p 4 8}Sasaki, Y. and Y. Xin 2017. Unequal Spacing in Dynamic Panel Data: Identification and Estimation. {it:Journal of Econometrics}, 196 (2), pp. 320-330.
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407616301932":Link to Paper}.
{p_end}

{title:Authors}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}

{p 4 8}Yi Xin, California Institute of Technology, Pasadena, CA.{p_end}



