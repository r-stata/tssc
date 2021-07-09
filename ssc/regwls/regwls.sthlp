{smcl}
{.-}
help for {cmd:regwls} {right:()}
{.-}
 
{title:Title}

regwls - Estimates Weighted Least Squares, making use of the {help wls0} and {help areg} command, incorporating support for factor variables and the possibility to absorb one fixed effect variable.

{title:Syntax}

{p 8 15}
{cmd:regwls} {help depvar} {help indepvars} [{help if}] [{help in}],  wvar(varlist) type(wlstype)  [noconst robust hc2 hc3 graph Absorb({help varname}]

{p}

{title:Description}

{p} This command incorporates support for factor variables for the command {help wls0}. 
It also allows for the absorbtion of one fixed effects using the algorithm of the command {help areg}. 
This is particularly useful when in the need of running a Weighted-Least Squares (WLS) model that requires a large number of dummy variables.

{title:Options}

{bf: wvar({help varlist})}: Variables in the weightling equation.

{bf: type(wlstype)}: The wls type.  The choices are: 
    abse  - absolute value of residual
    e2    - residual squared
    loge2 - log residual squared
    xb2   - fitted value squared

{bf: noconst}: do not include a constant in the weighting equation.

{bf: robust}: using robust standard errors in the final regression.

{bf: graph}: plots the wls residuals vs fitted.

{bf: absorb({help varname})}: categorical variable to be absorbed

{title:Author}

{p}
Dany Bahar, Harvard University

{p}
Email: {browse "mailto:dbaharc@gmail.com":dbaharc@gmail.com}

Comments welcome!

{title:Acknowledgements}
This program uses the code of {help wls0} and makes use of the {help areg} command when required.
{p}

{title:Also see}

{p 0 21}
{help wls0} (if installed), {help areg}
{p_end}
