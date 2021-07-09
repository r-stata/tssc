{smcl}
{* *! version 1.0.0 Sam Brilleman 04feb2011}{...}
{cmd:help devr2}
{hline}

{title:Title}

{phang}
{bf:devr2} {hline 2} Calculates a deviance based R-squared measure for models 
estimated using the {manhelp glm R} command. The measure is based on Cameron 
and Windmeijer, 1997.

{title:Description}

{pstd}
{cmd:devr2} calculates a deviance based R-squared measure for regression models in the 
exponential family with known scale parameter. This is equal to

{pmore}
1-[(deviance of the fitted model)/(deviance of the constant only model)]

{pstd}
It measures the proportionate reduction in recoverable information due to the inclusion
of regressors, where information is measured by the estimated Kullback-Leibler divergence,
and may be loosely interpreted as the fraction of uncertainty explained by the fitted model.

{pstd}
Further details are given in Cameron and Windmeijer, 1997. 

{pstd}
Currently, the command can only be used following model estimation using the {manhelp glm R} 
command. 

{title:Saved results}

{pstd}
{cmd:devr2} saves the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(dev_model)}}Deviance of the fitted model{p_end}
{synopt:{cmd:r(dev_null)}}Deviance of the constant only model{p_end}
{synopt:{cmd:r(devr2)}}Deviance based R-squared value{p_end}

{title:Author}

{p 4 4 2}
Brilleman, S. email: louis-george@hotmail.com

{title:Reference}

{p 4 4 2}
Cameron, A. C. & Windmeijer, F. A. G. (1997). An R-squared measure of goodness of fit for some 
common nonlinear regression models. {it: Journal of Econometrics} 77:329-342.

{title:Also see}

{psee}
Online:  {manhelp glm R}

