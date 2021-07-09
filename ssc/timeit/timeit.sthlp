{smcl}
{* *! version 1.1.2 14jan19}{...}
{findalias asfradohelp}{...}
{title:timeit}

{phang}
{bf:timeit} {hline 2} Easy to use single line version of timer on/off, supports incremental timing


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: timeit }
{it:integer}
[{it:name}]
{cmd: :}
{it:cmd}

{marker description}{...}
{title:Description}


{tab}{cmd:timeit} {it:#} {cmd::} {it:cmd} {col 30} will store the runtime of {it:cmd} in timer {it:#} and r(t{it:#}) 

{tab}{cmd:timeit} {it:#} {it:name} {cmd::} {it:cmd} {col 30} will store the runtime of {it:cmd} in timer {it:#} and r(t{it:#}) and r({it:name}) 


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:timeit} {it:#} {cmd::} {it:cmd} is functionally equivalent to{p_end}
{tab}{cmd:. timer on} {it:#}
{tab}{it:. cmd}
{tab}{cmd:. timer off} {it:#}

{pstd}
If your {it: cmd} leads to an error, the timer will stop running. Hitting break will also stop the timer.

{pstd}The time stored in timer #, r(t{it:#}) and/or r({it:name}) will always be total accumulated time of that timer. {p_end} 
{tab}E.g. if timer 1 was at 5s before and ran for 2s during the -timeit 1 name:-, then timer 1 will be 7s and {it:name} = 7

{pstd}The time stored in r(delta_t{it:#}) will be the time spent in this run. {p_end} 
{tab}E.g. if timer 1 was at 5s before and ran for 2s during the -timeit 1 name:-, then r(delta_t{it:1}) = 2

{pstd}
Any mistakes are my own.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. timer clear}{p_end}

{phang}** Run first timer{p_end}
{phang}{cmd:. timeit 1: reg price mpg}{p_end}
{phang}{cmd:. di r(t1)}{p_end}
{phang}{cmd:. local firstRun = r(t1)}{p_end}

{phang}** Run second timer (same number though){p_end}
{phang}{cmd:. timeit 1 fullRunTime: reg price mpg trunk weight length, r}{p_end}

{phang}** Show total, named and incremental runtime (plus actual r-results from reg){p_end}
{phang}{cmd:. return list}{p_end}

{phang}** Verify incremental runtime{p_end}
{phang}{cmd:. di r(fullRunTime) - `firstRun'}{p_end}

{phang}** Verify we get same outcome with timer list{p_end}
{phang}{cmd:. timer list}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:timeit} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(t{it:#})}} Current value of timer{p_end}
{synopt:{cmd:r(delta_t{it:#})}} Incremental value of timer{p_end}
{synopt:{cmd:r({it:name})}} Current value of timer{p_end}
{p2colreset}{...}



{title:Author}
Jesse Wursten
Faculty of Economics and Business
KU Leuven
{browse "mailto:jesse.wursten@kuleuven.be":jesse.wursten@kuleuven.be} 

Special thanks go to Daniel Klein for his suggestions and code snippets that vastly improved this command.
