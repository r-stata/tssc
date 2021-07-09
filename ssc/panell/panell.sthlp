{smcl}
{* 14oct2016}{...}
{hi:help panell}
{hline}

{title:Title}

{phang}
{bf:panell} {hline 2} Display panel length for a given set of variables


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:panell}
[{varlist}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt su:ppress}}suppress display of panel-specific characteristics{p_end}
{synopt:{opth g:enerate(newvar)}}create marker variable {it:newvar}{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:panell} displays individual and overall panel length of a given set of variables 
of a rectangular longitudinal/panel dataset (also known as time-series cross-section 
(TSCS) dataset). The output shows how many observations 
are non-missing for one variable or even a certain combination of multiple variables. 
This helps the user in getting a detailed overview of the availabilty of 
observations for models incorporating a single/multiple exogenous variable(s).
Additionally, the range of the time frame of each panel is displayed and 
when panels exhibits gaps (i.e. missing observations that are encased by non-missing 
observations within a panel) then those gaps are reported. 
Furthermore, overall characteristics of all panels (e.g. the number of panels, range of 
time frame, number of panels with observations, etc.) are displayed. 


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt suppress} suppresses the output of panel-specific characteristics. You may want to use this 
option if the dataset contains a large number of panels.

{phang}
{opt generate(newvar)} creates a dichotomous marker variable 
{it:newvar} that marks all observations with available information for 
all variables in {it:varlist} with 1 (otherwise 0, if missing).
{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
1. Since {cmd: panell} is exclusively written for use with TSCS
datasets, it is necessary to run the {help xtset} command before executing.
{p_end}

{pstd}
2. The {help datetime display formats} (e.g. yearly, 
quarterly, monthly) of the time variable assigned in {cmd: xtset}  
are automatically detected and displayed. If the time variable has no datetime display 
format assigned, then the integer values of the time variable are shown 
in the output.
{p_end}

{pstd}
3. If {it: varlist} contains no variables, all variables within the dataset are taken into account (same as 
typing {cmd: panell _all}), albeit all string variables will automatically be removed from {it: varlist}.
{p_end}

{pstd}
4. If the panel identifying variable has value {help labels} assigned, then these labels automatically
appear in the output. 
{p_end}

{marker examples}{...}
{title:Examples}

Setup

{phang}{cmd:. use "http://www.stata-press.com/data/r12/union.dta", clear}

{phang}{cmd:. xtset idcode year}


Single variable with univariate statistics

{phang}{cmd:. panell age}


Multiple variables, additional generation of a marker variable

{phang}{cmd:. panell age grade not_smsa south union black, gen(markervar)}


Entire Dataset without details on individual panels

{phang}{cmd:. panell, su}


{title:Author}

{pstd}
Jan Helmdag, Department of Political Science, University of Greifswald, Germany



