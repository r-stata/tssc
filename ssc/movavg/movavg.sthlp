{smcl}
{* *! version 0.12.06 19jun2012}{...}
{cmd:help movavg}
{hline}

{title:Title}

{phang}
{bf:movavg} {hline 2} MATA based Moving Average generator

{title:Syntax}

{p 8 17 2}
{cmdab:movavg}
{newvar} {cmd:=}{it:{help varname}} [if]
[, {opt la:gs}(#)
{opt r:eplace}]

{phang}
{opt by} is allowed for 1 varname.

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt la:gs(#)}}Number of time periods (observations) to be considered in the window.{p_end}
{synopt:{opt r:eplace}}Same behavior as in {cmd:generate}.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:movavg} performs high speed Moving Average calculation using MATA base computations.

{pstd}
In the case of "by", efficiency gains are very high, in terms of computation speed, 
as a contrast of loop based algorithms as this implementations uses matrix algebra instead.
{p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}
{p_end}
{phang2}{cmd:. sort rep78}

{pstd}Computes the moving average of {it:price} over a 3 period window{p_end}
{phang2}{cmd:. movavg ma3lags = price, lags(3)}

{pstd}Computes the moving average of {it:price} by {it:rep78} over a 3 period window{p_end}
{phang2}{cmd:. by rep78: movavg ma3lags_by = price, lags(3)}
{p_end}

{title:Author}

{pstd}
George Vega Yon, Superindentencia de Pensiones. {browse "mailto:gvega@spensiones.cl"}
{p_end}
