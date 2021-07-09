{smcl}
{* 27apr2010}{...}
{cmd:help frontier_teci}
{hline}

{title:Title}

    {hi: frontier_teci -  Confidence Intervals for Technical Efficiency Estimates }



{title:Syntax}

{p 8 17 2}
{cmd: frontier_teci} stub
{ifin}
{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt l:evel(#)}}set confidence level; default is level(95){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:frontier_teci} generates the confidence intervals for technical efficiency estimates following 
{cmd: frontier} or {cmd: xtfrontier}.  Two new variables are creates:  {it:stub}_l and {it:stub}_u for 
the lower and upper confidence intervals.


{title:Examples}
{cmd}
    webuse xtfrontier1, clear
    frontier lnwidgets lnworkers lnmachines, ti
    predict te, te
    frontier_teci te
{txt}
{cmd}
    webuse frontier1, clear
    frontier lnoutput lncapital lnlabor, d(t)
    predict te, te
    frontier_teci te
{txt}

{title:Author}
{p 4 4}
Scott Merryman{break}
Risk Management Agency/USDA{break}
scott.merryman@gmail.com
{p_end}


{title:References}

{phang}
Horrace, William and Peter Schmidt (1996) "Confidence Statements for
Efficiency Estimates from Stochastic Frontier Models" 
{it:The Journal of Productivity Analysis}, 7, 257-282.


{title:Also see:}

Estimation commands:
{p 4 4}
{help frontier}, {help xtfrontier}
