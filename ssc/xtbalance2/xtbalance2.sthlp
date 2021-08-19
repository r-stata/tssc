{smcl}
{hline}
{hi:help xtbalance2}{right: v. 1.0 - 29. January 2021}
{hline}
{title:Title}

{p 4 4}{cmd:xtbalance2} - Create a balanced subsample from unbalanced panel data.{p_end}

{title:Syntax}

{p 4 13}{cmd:xtbalance2} [{varlist}] [if] [in] {cmd:,}
{cmdab:gen:erate(newvarname)}
[{cmdab:o:ptimisation(string)}
]{p_end}

{p 4 4}Data has to be {cmd:xtset} before using {cmd:xtbalance2}; see {help xtset}.
{it:varlist} may contain time-series operators, see {help tsvarlist}. 
If {it:varlist} is empty, {cmd:xtbalance2} uses all variables in the dataset.{p_end}

{title:Contents}

{p 4}{help xtbalance2##description:Description}{p_end}
{p 4}{help xtbalance2##options:Options}{p_end}
{p 4}{help xtbalance2##saved_vales:Saved Values}{p_end}
{p 4}{help xtbalance2##examples:Examples}{p_end}
{p 4}{help xtbalance2##about:About}{p_end}

{marker description}{title:Description}

{p 4 8}{cmd:xtbalance2} creates a balanced subsample from an unbalanced dataset.
{cmd:xtbalance2} does not drop any observations, it creates a variable indicating if 
an observations (or row) is part of the balanced subsample.{p_end}

{p 4 8}{cmd:xtbalance2} tries to maximise either the number of cross-sectional units (ids),
time periods or total number of observations. 
To do so it uses a simple algorithm which finds the largest subsquare in a matrix.
Theoretically it is possible to obtain more than one solution to the maximisation problem.
In this case {cmd:xtbalance2} creates an indicator variable for each solution.{p_end}

{marker options}{title:Options}

{p 4 8}{cmdab:gen:erate(}{it:newvarname}{cmd:)} Name of the indicator variable.{p_end}

{p 4 8}{cmdab:o:ptimisation(}{it:T|N|NT}{cmd:)} which dimension to be optimised/maximised. Default is length of the time series (T). 
{it:N} maximises the number of cross-section units and {it:NT} uses the maximum number of observations 
from {it:N} and {it:T}.{p_end}

{marker saved_vales}{title:Saved Values}

{col 4} Scalars
{col 8}{cmd: r(NumMax)}{col 27} Number of possible solutions for maximum number of N|T|NT. If larger than 1, potential problems can arise.

{marker examples}{title:Examples}

{p 8}{stata "use http://www.stata-journal.com/software/sj12-1/st0246/manu_prod, clear"}.{p_end}

{p 4 8}To maximise the observations with respect to the number of cross-sectional units (N_g):{p_end}

{p 8}{stata xtbalance2 , generate(balanceN) optimisation(N) }{p_end}

{p 4 8}{cmd:xtbalance2} creates a new variable called {cmd:balanceN} which takes the value 1 
if the observations is included in the new balanced panel and 0 otherwise.{p_end}

{p 4 8}We can do the same but maximise the observations with respect to the number of 
time periods:{p_end}

{p 8}{stata xtbalance2 , generate(balanceT) optimisation(T) }{p_end}

{p 4 8}To restrict optimisation to a specific set of variables:{p_end}

{p 8}{stata xtbalance2 lO lL lY, generate(balanceT2) optimisation(T) }{p_end}


{marker about}{title:Author}

{p 4}Jan Ditzen (Free University of Bozen-Bolzano){p_end}
{p 4}Email: {browse "mailto:jan.ditzen@unibz.it":jan.ditzen@unibz.it}{p_end}
{p 4}Web: {browse "www.jan.ditzen.net":www.jan.ditzen.net}{p_end}

{p 4 8}{cmd:xtbalance2} was created for the use in {help xtcse2}. 
All remaining errors are my own.{p_end}

{p 4 8}Please cite as follows:{break}
Ditzen, J. 2021. xtbalance2:  Create a balanced subsample from unbalanced panel data.
{p_end}

{p 4 8}The latest versions can be obtained via {stata "net from https://github.com/JanDitzen/xtbalance2"} 
.{p_end}

{marker ChangLog}{title:Changelog}
{p 4 8}This version: 1.0 - 29 January 2021{p_end}

{title:Also see}
{p 4 4}See also: {help xtset}{p_end} 
