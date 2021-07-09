{smcl}
{* *! version 1.0.2 January 21, 2012 @ 12:30:00 DE}{...}
{hi:help meresc}
{hline}

{title:Title}

{phang}
{cmd:meresc} Rescaled results for nonlinear mixed models
{p_end}

{title:Syntax}
{p 8 17 2}
   {cmd: meresc}
   [ {cmd:,}
   {opt v:erbose}
   ]
{p_end}

{title:Description}

{pstd} {cmd:meresc} rescales the results of mixed nonlinear
probability models such as {help xtmelogit}, {help xtlogit}, or
{help xtprobit} to the same scale as the intercept-only model.
The technique applied is described in chapter 6.5 of Hox (2010: 133--139).
{p_end}

{pstd}The technique rescales all random and fixed effects of a
multilevel model. The {it: variance scale correction factor} for random
effect parameters is the total variance of the intercept only model
devided by the total variance of the model with lowest level variables
only. The fixed effects are rescaled using the square root of the
variance scale correction factor (i.e. using
the {it: scale correction factor}).{p_end}

{title:Options}

{phang}{opt verbose} displays the results of the intercept-only model
that corresponds to the user specified mixed model and a model with
level-1 variables only. These models are internally used by
{cmd:meresc} for ascertaining the rescaling factor.{p_end}

{title:Example(s)}

{phang}{cmd:. webuse bangladesh, clear}{p_end}
{phang}{cmd:. xtmelogit c_use urban age child* || district: urban}{p_end}
{phang}{cmd:. meresc}{p_end}

{title:Saved Results}

{pstd} {cmd:meresc} keeps most returned results of the user defined
estimation command in memory. However, it stores the rescaled
coefficient vector in e(b), and the rescaled variance-covariance
matrix in e(V). Moreover it adds the follwing results to the stored
results: {p_end}

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(SCF)}}Scale correction factor{p_end}
{synopt:{cmd:e(VCF)}}Variance scale correction factor{p_end}
{synopt:{cmd:e(Var_Flevel1)}}Linear Predictor Variance using first level vars only{p_end}
{synopt:{cmd:e(Var_u#)}}Variance of Level-# random effect{p_end}
{synopt:{cmd:e(Var_R)}}Variance of residuals{p_end}
{synopt:{cmd:e(Var_u0)}}Variance of random effects of constant only model{p_end}
{synopt:{cmd:e(Var_u#resc)}}Variance of Level-# random effect, rescaled{p_end}
{synopt:{cmd:e(Var_Rresc)}}Variance of residuals, rescaled{p_end}
{synopt:{cmd:e(r2_mz)}}McKelvy & Zavoina's R2{p_end}
{synopt:{cmd:e(deviance)}}Model Deviance{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:meresc}{p_end}
{synopt:{cmd:e(cmdline)}}command-line of previous estimation{p_end}

{title:References}

{pstd} Hox, J. J. (2010), Multilevel Analysis: Techniques and
Applications. New York (2nd ed.): Routledge.

{title:Also see}

{psee}
Manual: {hi:[R] xtmelogit, xtlogit, xtprobit }
{p_end}

{psee}
Online: Help for {help xtmelogit}, {help xtlogit}, {help xtprobit}; ssc package {cmd:nlcorr} ({net "describe nlcorr, from(http://fmwww.bc.edu/RePEc/bocode/n)":click here})
{p_end}

{psee}
Web:   {browse "http://stata.com":Stata's Home}
{p_end}

{title:Authors}

Dirk Enzmann
Institute of Criminal Sciences, Hamburg
email: {browse "mailto:dirk.enzmann@uni-hamburg.de"}

Ulrich Kohler
Wissenschaftszentrum Berlin
email: {browse "mailto:kohler@wzb.eu"}
