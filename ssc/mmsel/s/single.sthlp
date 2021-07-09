{smcl}
{* 1apr2008}{...}
{cmd:help single}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:machado} {hline 2}}Single index estimation method from Ichimura (1993){p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt single} {depvar} [{indepvars}] {if} 
   [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt h}} Bandwidth of the single estimation method{p_end}
{synopt :{opt m}} Number of iterations {p_end}
{synopt :{opt q}} Number of quantiles computed for Machado-Mata method{p_end}
{synopt :{opt variance}} Estimation of variance (1 = yes){p_end}
{synopt :{opt method}} Method of estimation (see below){p_end}

{title:Description}

{pstd}
{cmd:machado} Estimates the beta-coefficients of the single index method from Ichimura. The
method is fit for probit estimation and estimates the probit model for normalization. The coefficient
of the first regresor and the constant arre normalized. Note that the first regressor need to be a
continuous variable. 

{title:Options}

{dlgtab:Model}

{phang}
{opt h} The bandwidth. The default is 0.2


{title:Examples}

{phang2}{cmd:. single y x1 x2 x3 x4, h(0.4)}{p_end}

