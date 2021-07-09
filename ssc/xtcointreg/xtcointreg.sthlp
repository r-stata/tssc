{smcl}
{* *! version 1.1  27feb2011}{...}
{cmd:help xtcointreg} {}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:xtcointreg} {hline 2}}Panel dataset generalization of cointegration regression using fully modified ordinary least squares, dynamic ordinary least squares, and canonical correlation regression methods{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2} {cmd:xtcointreg} {depvar} {indepvars} {ifin} [{cmd:,}
        {opt est(method)} {opt nocons:tant}  
	{opt eqt:rend(#)} {opt eqd:et(varlist)} {opt xt:rend(#)}
        {opt xd:et(varlist)} 
	{opt diff} {opt stage(#)} {opt nodivn} 
	{opt dlead(#)} {opt dlag(#)} {opt dic(string)} {opt dmax:order(#)} 
	{opt dvar(varlist)} {opt dvce(string)} {opt l:evel(#)} {opt full}
{it:{help lrcov:lrcov_options}}]

{pstd}{it:depvar} may contain time-series operators.{p_end}
{pstd}{it:indepvars} may contain time-series operators and factor variables.


{title:Description}

{pstd}{hi:xtcointreg} generalizes Qunyong Wang and Na Wu's {hi:cointreg} command to panel data. It does Panel Dynamic OLS (PDOLS) and Panel Fully Modified OLS (FMOLS). The main option {cmd:est} and a new option {cmd: full} is included in this documentation. For other questions consult the original {hi: cointreg}'s documentation.

{title:Options}

{phang}{cmd:est(}{it:method}{cmd:)} specifies the estimation method,
which can be {cmd:fmols}, {cmd:dols}, or {cmd:ccr}.  The default is
{cmd:est(fmols)}.

{phang}{cmd:full} shows results for all individual panels.


{title:Author}

{pstd}Ravshanbek Khodzhimatov{p_end}
{pstd}rsk@ravshansk.com{p_end}
