{smcl}
{* *! version 1.0  1dec2008}{...}
{cmd:help mregress} 
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:mregress} {hline 2}}Huber regression M-estimator{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:mregress} {depvar} [{indepvars}] {ifin} 
[{cmd:,} {it:options}] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{synopt :{opt noc:onstant}}suppress constant term{p_end}
{synopt :{opt tu:ne(#)}}use {it:#} as Huber M-tuning constant; default is
{cmd:tune(7)}{p_end}

{syntab:Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
{p_end}


{title:Description}

{pstd}
{opt mregress} performs a Huber M-estimator of regression of {depvar} on
{indepvars}. The command is a slight modification of rreg where only Huber's
iterations are considered

{pstd}
Also see {bf:[R] regress} for standard regression with robust variance
estimates and {bf:[R] qreg} for quantile (including median or
least-absolute-residual) regression.


{title:Options}

{dlgtab:Model}

{phang}
{opt tune(#)} is the Huber tuning constant.  Lower tuning constants downweight 
outliers rapidly but may lead to unstable estimates (less than 6 is not recommended).  
Higher tuning constants produce milder downweighting. See {manhelp rreg R} for further details.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}. 



{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. generate weightd = weight*(foreign==0)}{p_end}
{phang2}{cmd:. generate weightf = weight*(foreign==1)}

{pstd}Robust regression{p_end}
{phang2}{cmd:. mregress mpg weightd weightf foreign}


{title:Saved results}

{pstd}
{cmd:mmregress} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(mss)}}model sum of squares{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(rss)}}residual sum of squares{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(r2)}}R-squared{p_end}
{synopt:{cmd:e(r2_a)}}adjusted R-squared{p_end}
{synopt:{cmd:e(F)}}F statistic{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:rreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(model)}}{cmd:ols}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Also see}

{psee}
Online:  {manhelp qreg R}, {manhelp regress R};{break}
{manhelp rreg R}, {help mmregress}, {help sregress}, {help msregress}, {help mcd}
{p_end}
