{smcl}
{* 24feb2005}{...}
{hline}
help for {hi:wtdq}
{hline}

{title:Q-Q plot for Waiting Time Distribution data}

{p 8 16 2}{cmd:wtdq}[,
	{cmd:reest}
        {cmd:prevd(}{it:fr_dens}{cmd:)}
        {cmd:hdens(}{it:inc_dens}{cmd:)}
        {cmd:ddens(}{it:exit_dens}{cmd:)}
        {cmd:cens(}{it:cens_type}{cmd:)}
	{it:twoway_opts}]

{p 4 4 2} 
{cmd:wtdq} is for use with Waiting Time Distribution data; see help 
{help wtd}. You must {cmd:wtdset} your data before using this
command; see help {help wtdset}.


{title:Notes on syntax}

{p 4 8 2}
Unless {cmd:reest} is specified, all other options are ignored.
{it:twoway_opts} are options for {cmd:twoway}, see help {help twoway}.
All remaining options are options for {cmd:wtdml}, see help
{help wtdml}. 

{title:Description}

{p 4 4 2} {cmd:wtdq} makes a Q-Q-plot of the last fitted model
(default) - or the model specified in the options, if {cmd:reest} is
given.

{title:Options for {cmd:wtdq}}

{p 4 8 2}
{cmd:reest} specifies that a new model should be estimated based
on the specifications in the remaining options, see help
{help wtdml}.

{p 4 8 2}
For help on the remaining options see help {help wtdml} and {help twoway}.

{title:Examples}

{p 4 8 2}
{cmd:. wtdset event exit, i(id) start(31dec1996) end(31dec1997) scale(365)}

{p 4 8 2}
{cmd:. wtdml, prevd(wei) cens(depphi)}

{p 4 8 2}
{cmd:. wtdq}

{p 4 8 2}
{cmd:. wtdq, saving(qqplot.gph)}         /* save copy of plot   */

{p 4 8 2}
{cmd:. wtdq, prevd(wei) cens(depphi)}   /* same model as above */

{title:Also see}

{p 4 13 2}Online:  help for {help wtd}, {help wtdml}, {help diagplots}
