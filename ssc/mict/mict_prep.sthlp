{smcl}
{* Copyright 2015 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 17July2015}{...}
{cmd:help mict_prep}
{hline}

{title:Title}

{phang}
{hi:mict_prep} {hline 2} Prepare categorical time-series data for {cmd:mict_impute}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mict_prep} {it:stubnames} {cmd:,} {it:options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt id:var}}ID variable{p_end}

{marker description}{...}
{title:Description}

{pstd} {cmd:mict_prep} prepares data for {help mict_impute}. The data
are assumed to be in wide format. The main argument is one or more
variable stubs, given in the form required by {help reshape long}. The
first indicates the main state variable (to be imputed), but stubs
indicating other parallel time-series can also be included. The {cmd:ID} option indicates the case-ID variable to use.
The program calculates a number of
variables with a prefix {cmd:_mct_} that will be used by {cmd:mict_impute}.{p_end}

{pstd} {cmd:mict_prep} is presented as a separate command from
{cmd:mict_impute} because the data can be saved and used repeatedly (or
by separate processes) with different random seeds.{p_end}

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. use mvadmar}{p_end}
{phang}{cmd:. mict_prep state, id(id)}{p_end}
{phang}{cmd:. mict_impute, nimp(10)}{p_end}
