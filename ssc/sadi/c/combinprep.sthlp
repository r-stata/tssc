{smcl}
{* Copyright 2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 16June2012}{...}
{cmd:help combinprep}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:combinprep} {hline 2}}Transform sequences from wide calendar format to wide spell format{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:combinprep}, options


{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Options}
{synopt :{opt st:ate(string)}} Stub of state variable name, in {help reshape} fashion{p_end}
{synopt :{opt length(string)}} Stub of spell-length variable name (will be created){p_end}
{synopt :{opt id:var(varname)}} ID variable{p_end}
{synopt :{opt nsp:ells(varname)}} number-of-spells variable (will be created){p_end}

{title:Description}

{pstd}{cmd:combinprep} takes sequence data in wide calendar format
(i.e., a consecutive string of numbered state variables representing
state in each time unit, with one case per sequence) and turns it into
wide spell format (consecutive pairs of numbered state and duration
variables) with a separate variable indicating the number of spells.
{p_end}

{pstd} It returns the maximum number of spells observed in r(maxspells)
and the range of the state variable in r(nels).{p_end}

{pstd} This can be used to prepare the data for {help:combinadd} and
other techniques that focus on spell history rather than state history.


{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{pstd} Given sequences represented as consecutive variables s1-s40:{p_end}

{phang}{cmd:. combinprep, state(s) length(dur) nspells(nsp)}{p_end}

{pstd} will generate a new structures with variable pairs s1,
dur1 to sX, durX where X is the maximum number of
spells observed. The spells are defined as consecutive runs in the same
state, and their duration is recorded in the dur variable. The
observed number of spells in each case is recorded in nsp.{p_end}
