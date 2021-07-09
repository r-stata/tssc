{smcl}
{* *! version 1.0  01dec2012}{...}

{title:Title}

{phang}
{bf:sls postestimation} {hline 2} Postestimation tools for sls 


{marker description}{...}
{title:Description}

{pstd}
The following postestimation commands are available after {cmd:sls}: 

{synoptset 17}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt :{helpb regress postestimation##predict:predict}}predictions,
residuals, and other diagnostic measures{p_end}


{marker predict}{...}
{marker syntax_predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,}
 {it:{help predict##multiple_options:multiple_options}}] 

{p 8 16 2}
{cmd:predict} {dtype}
 {c -(}{it:stub*}{c |}{it:{help newvar:newvar1}} ... {it:{help newvar:newvarq}}{c )-}
{ifin} {cmd:,} {opt deydb}

{marker statistic}{...}
{synoptset 19 tabbed}{...}
{synopthdr:statistic}
{synoptline}
{syntab:Main}
{synopt :{opt tr:im}}trimming vector: 0 for trimmed observations{p_end}
{synopt :{opt xb}}index values; the default{p_end}
{synopt :{opt r:esiduals}}residuals, y-E[y|xb]{p_end}
{synopt :{opt ey}}Expected value of y, conditional on xb, E[y|xb]{p_end}
{synopt :{opt sc:ore}}score; derivative of objective function (y-E[y|xb])^2 w.r.t. index, xb{p_end}
{synopt :{opt deydi}}derivative of E[y|xb] w.r.t. index, xb{p_end}
{synopt :{opt deydb}}derivative of E[y|xb] w.r.t. coefficients, b{p_end}
{synoptline}


{title:Examples}

{phang}{cmd:. sls y1 x1 x2 x3}

{phang}{cmd:. predict expy , ey}

{phang}{cmd:. predict db*, deydb}


{title:Author}

{pstd} Michael Barker {p_end}
{pstd} Georgetown University {p_end}
{pstd} mdb96@georgetown.edu {p_end}


{title:Also see}

{pstd}
{help sls:sls}



