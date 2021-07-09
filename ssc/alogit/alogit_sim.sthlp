{smcl}
{* *! version 1.0.0 03May2017}{...}
{cmd:help alogit_sim}
{hline}

{title:Title}

{pstd}
{hi:alogit_sim} {hline 2} Simulate data for {opt alogit}
{p_end}

{marker syntax}{title:Syntax}

{pstd}
{cmd:alogit_sim}
{cmd:,}
{opt b0(numlist)}
{c -(}{opt g0(numlist)}{c |}{opt d0(numlist)}{c )-}
[{it:{help alogit_sim##sim_options:sim_options}}]

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Model parameters}
{synopt:{opth b0(numlist)}}Parameters for utility. {p_end}
{synopt:{opth g0(numlist)}}Parameters for attention. {p_end}
{synopt:{opth d0(numlist)}}Parameters for extra attention variables. {p_end}

{syntab:Simulation parameters}
{synopt:{opth N(int)}}Number of individuals.{p_end}
{synopt:{opth j(numlist)}}Number of goods or range of goods.{p_end}
{synopt:{opth xs(real)}}Variance for normal or range for uniform (utility).{p_end}
{synopt:{opth zs(real)}}Variance for normal or range for uniform (attention).{p_end}
{synopt:{opth xmu(real)}}Mean for normal or lower bound for uniform (utility).{p_end}
{synopt:{opth zmu(real)}}Mean for normal or lower bound for uniform (attention).{p_end}
{synopt:{opt cons:tant}}Value of constant term in attention equation. {p_end}

{syntab:Simulation Options}
{synopt:{opt debug}}Print parameters and save utility, attention variables.{p_end}
{synopt:{opt dsc}}Simulate for DSC instead of alogit.{p_end}
{synopt:{opt normal}}Utility and attention variables are random normal.{p_end}
{synopt:{opt uniform}}Utility and attention variables are random uniform.{p_end}

{marker desc}{title:Description}

{pstd} {cmd:alogit_sim} is a very simple wrapper simulate data for {opt alogit}{p_end}

{marker examples}{...}
{title:Examples}

{pstd}Basic use{p_end}
{phang2}{cmd:. alogit_sim, n(200) j(4 8) b0(3.8 1.5) g0(0.6 -0.1) d0(-2.3 -1.1) zs(2)}{p_end}
{phang2}{cmd:. alogit_sim, n(200) j(4 8) b0(3.8 1.5) g0(0.6 -0.1) d0(-2.3 -1.1) zs(2) dsc}{p_end}
