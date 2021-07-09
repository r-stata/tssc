{smcl}
{* *! version 1.0.10  23apr2007}{...}
{cmd:help ci_marg_mu}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:ci_marg_mu} {hline 2}}Simulation-based confidence intervals for 
predicted marginal probabilities, etc., using gllapred{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:ci_marg_mu} {it:lower} {it:upper} {ifin} [{cmd:,} {it:options}]

{synoptset 10}{...}
{synopthdr}
{synoptline}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt r:eps(#)}}set number of simulations (must be multiple of 200); default is 1000{p_end}
{synopt :{opt d:ots}}display a dot for each simulation{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}where {it:lower} and {it:upper} are the names of new variables in which
th lower and upper confidence limits will be stored.


{title:Description}

{pstd}
{cmd:ci_marg_mu} produces simulation-based confidence intervals for 
predictions using {cmd:gllapred {it:varname}, mu marg} after estimation
using {cmd:gllamm}. It repeatedly draws a sample of model parameter values from
the estimated asymptotic sampling distribution (i.e., a multivariate
normal distribution with mean given by the etimates in e(b) and covariance
matrix in e(V)) and obtains predictions using these simulated parameters. 
It returns the appropriate percentiles in {it:lower} and {it: upper}. For
example, with the {cmd:level(95)} and {cmd:reps(1000)} options, the
25th largest prediction is returned in {it:lower} and the 976th largest 
prediction is returned in {it:upper}.


{title:Options}

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
{opt reps(#)} specifies the number of simulations to be used. This must be a
multiple of 200. The default is 1000.

{phang}
{opt dots} specifies that a dot should be displayed after each simulation to
help guage how long the program will run. 

{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse bangladesh}{p_end}

{pstd}Random-intercept model, analogous to {cmd:xtlogit}{p_end}
{phang2}{cmd:. gllamm c_use urban age child*, i(district)}{p_end}

{pstd}Predict marginal probability for observations where urban = 1{p_end}
{phang2}{cmd:. gllapred prob if urban==1, marg mu} {p_end}

{pstd}Obtain 95% confidence limits for probability{p_end}
{phang2}{cmd:. ci_marg_mu lower95 upper95 if urban==1, level(95) reps(1000) dots} {p_end}

{pstd}Random-intercept and random coefficient model, correlated random
effects, analogous to {cmd:xtmelogit}{p_end}
{phang2}{cmd:. generate cons=1}{p_end}
{phang2}{cmd:. eq inter: cons}{p_end}
{phang2}{cmd:. eq slope: urban}{p_end}
{phang2}{cmd:. gllamm c_use urban age child*, i(district) nrf(2) eqs(inter slope)}
        {cmd: link(logit) family(binom) adapt ip(m) nip(11)}{p_end}
       
{pstd}Predict marginal probability for observations where urban = 1{p_end}
{phang2}{cmd:. gllapred prob_rc if urban==1, marg mu} {p_end}

{pstd}Obtain 95% approximate confidence limits for prediction{p_end}
{phang2}{cmd:. ci_marg_mu lower_rc upper_rc if urban==1, level(95) reps(1000) dots} {p_end}
             
    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse lowbirth}{p_end}
{phang2}{cmd:. generate id = _n}{p_end}

{pstd}Ordinary logistic regression, analogous to {cmd:logit}{p_end}
{phang2}{cmd:. gllamm low age lwt race2 race3 smoke ptd ht ui,}
       {cmd: i(id) link(logit) family(binom) init}{p_end}

{pstd}Predicted probabilities, analogous to {cmd:predict, pr} after {cmd:logit}{p_end}
{phang2}{cmd:. gllapred prob, marg mu}{p_end}

{pstd}Obtain approximate 95% confidence limits for probability{p_end}
{phang2}{cmd:. ci_marg_mu l u}{p_end}
    {hline}

{title:Webpage}
{pstd}
http://www.gllamm.org

{title:Autor}
{pstd}
Sophia Rabe-Hesketh

{title:References}

{phang}
Rabe-Hesketh, S., Skrondal, A. and Pickles, A. (2002).  Reliable estimation of generalized linear mixed models
using adaptive quadrature.  The Stata Journal 2 (1), 1-21.{p_end}

{phang}
Rabe-Hesketh, S., Skrondal, A. and Pickles, A. (2004).  GLLAMM Manual. U.C. Berkeley Division of Biostatistics
Working Paper Series. Working Paper 160.{p_end}

{phang}             
Rabe-Hesketh, S., Skrondal, A. and Pickles, A. (2005).  Maximum likelihood estimation of limited and discrete
dependent variable models with nested random effects. Journal of Econometrics 128 (2), 301-323.{p_end}

{phang}
Rabe-Hesketh, S., Skrondal, A. (2008). Multilevel and Longidutinal Modeling Using Stata (Second Edition).
College Station, TX: Stata Press.{p_end}

{title:Saved results}

{pstd}
There are no saved results

{title:Also see}

{psee}
Online:  {help gllamm}, {help gllapred}
{p_end}
