{smcl}
{version 1.1 september 5 2015}
{cmd:help xtcenter}{...}
{hline}

{title:Title}

{cmd :xtcenter} {hline 2} Disaggregate within and between-person effects by centering variables for mixed and melogit models


{title:Syntax}

{p 8 12 2}
{cmd:xtcenter} {it:timevarcovar} , {opt i(panel_var)} [{cmd:} {it:{help xtcenter##options:options}}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{opt i(panel_var)}}nested group id, default is panel_var from xtset{p_end}
{synopt :{opt interaction}}forces centering of binary time-varying covariates{p_end}
{synopt :{opt replace}}replaces existing variables written in the data set{p_end}


{synoptline}
{p2colreset}{...}
{p 4 6 2}
{opt weight}s, {opt if}, {opt in}, and {opt by} are not allowed. 


{title:Description}
{phang}
{cmd:xtcenter} 
This program centers and parses multi-level variance for use with melogit and mixed commands. 
The program takes one time-varying covariate  and one nesting variable in options. The program will automatically center continuous variables, but will only center binary variables if {opt interaction} is specified.{p_end}


{title:Results}

{cmd:xtcenter} writes the following two variables to your data set:
{phang}{it:timevarcovar}_zti - within-person centered mean (or proportion) of the time-varying covariate {p_end}
{phang}{it:timevarcovar}_zbari - grand mean (or proportion) centered of the time-varying covariate{p_end}


{title:Author}

{pstd}Eldin Dzubur, MS{p_end}
{pstd}Department of Preventive Medicine{p_end}
{pstd}University of Southern California{p_end}
{pstd}Los Aneles, CA{p_end}
{pstd}dzubur@usc.edu{p_end}

{title:Reference}
{phang}
Curran, P. J., & Bauer, D. J. (2011). The disaggregation of within-person and between-person effects in longitudinal models of change. Annual review of psychology, 62, 583.
