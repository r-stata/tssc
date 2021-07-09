{smcl}
{* 24feb2005}{...}
{hline}
help for {hi:wtddiag}
{hline}

{title:Diagnostic plots for Waiting Time Distribution data}

{p 8 16 2}{cmd:wtddiag},
	{cmd:barsize(}{it:#}{cmd:)}
        [{cmd:cutpt(}{it:date}{cmd:)}
	{cmd:frmodels(}{it:fr_mods}{cmd:)}
        {cmd:hdmodels(}{it:rate_mods}{cmd:)}
        {cmd:cens(}{it:cens_type}{cmd:)}
	{cmd:noiest}
	{it:twoway_opts}]

{p 4 4 2} 
{cmd:wtddiag} is for use with Waiting Time Distribution data; see help 
{help wtd}. You must {cmd:wtdset} your data before using this
command; see help {help wtdset}.


{title:Notes on syntax}

{p 4 8 2}
{it:fr_mods} is a string consisting of one or more of the letters 'e',
'l', and 'w' in arbitrary order.

{p 4 8 2}
{it:rate_mods} is a string consisting of one or more of the letters
'e' and 'u' in arbitrary order.

{p 4 8 2}
{it:cens_type} is one of

{p 12 12 2}
{cmd:depphi} | {cmd:dep} | {cmd:indep} | {cmd:none}


{p 4 8 2}
{it:twoway_opts} are options for {cmd:twoway}, see help {help twoway}.

{title:Description}

{p 4 4 2}
{cmd:wtddiag} makes a histogram of the observed Waiting Time
Distribution and allows adding both an ad-hoc estimate based on a
chosen cut-point as well as parametrically fitted density/ies based on
{cmd:wtdml}, see help {help wtdml}.


{title:Options for {cmd:wtddiag}}

{p 4 8 2} 
{cmd:barsize(}{it:#}{cmd:)} specifies the width of bars in the
histogram. The unit of {cmd:barsize()} is days.

{p 4 8 2}
{cmd:cutpt(}{it:date}{cmd:)} specifies the cut-point after which all
observed events are considered to arise from incident subjects. A
vertical line is added to the plot at the cut-point, together with a
horizontal line indicating the estimated incidence level. Finally, a
table is displayed with information on estimates of prevalence and
incidence based on the chosen cut-point. The date must be specified
with syntax acceptable by the {cmd:d() function}, see help {help dfcn}.

{p 4 8 2}
{cmd:frmodels(}{it:fr_mods}{cmd:)} specifies the forward recurrence
densities used in defining the models to be fitted. 'e' denotes
Exponential, 'l' Log-Normal, and 'w' Weibull, see help {help wtdml}.

{p 4 8 2} 
{cmd:hdmodels(}{it:rate_mods}{cmd:)} specifies the densities used for
incidence and exit rates in defining the models to be fitted. 'e'
denotes Exponential and 'u' Uniform, see help {help wtdml}.

{p 4 8 2} 
{cmd:cens(}{it:cens_type}{cmd:)} specifies the dependency structure
between event and exit times and follows the syntax for {cmd:wtdml},
see help  {help wtdml}.

{p 4 8 2}
{cmd:noiest} requests display of maximization process(es) and
output(s).

{title:Examples}

{p 4 8 2}
{cmd:. wtdset event exit, i(id) start(31dec1996) end(31dec1997) scale(365)}

{p 4 8 2}
{cmd:. wtddiag, barsize(14) cutpt(1oct1997)}

{p 4 8 2}
{cmd:. wtddiag, barsize(14) frmodels(ew) hdmodels(e) cens(depphi)}

{p 4 8 2}
{cmd:. wtddiag, barsize(14) saving(diagplot.gph)}     /* save copy of plot   */


{title:Also see}

{p 4 13 2}Online:  help for {help wtd}, {help wtdml}, {help wtdq}
