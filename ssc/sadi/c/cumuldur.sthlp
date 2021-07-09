{smcl}
{* Copyright 2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* $Id: cumuldur.hlp,v 1.1 2012/06/28 23:13:01 brendan Exp $}
{* 23June2012}{...}
{cmd:help cumuldur}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:cumuldur} {hline 2}}Calculate cumulated duration in states of a sequence{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:cumuldur} {it: varlist} , {opt cd:stub(string)}  {opt nst:ates(int)}

{title:Description}

{pstd}{cmd:cumuldur} creates variables holding the cumulative duration
in each state in a sequence described by the {it:varlist}. The
{cmd:cdstub} option gives the prefix of the new variables, and
{cmd:nstates} enumerates how many states there are. States must be
numbered from 1 up. A warning is issued if the total duration is less
than the sequence length (e.g., if the number of states is actually
larger than that given in the option, or if there are missing values or
values less than or equal to zero). {p_end}


{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. cumuldur m1-m40, cd(dur) nstates(3)}{p_end}
