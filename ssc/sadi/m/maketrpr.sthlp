{smcl}
{* Copyright 2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 10June2012}{...}
{cmd:help dynhamming}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:maketrpr} {hline 2}}Create a matrix containing transition rates from sequences{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:maketrpr} {it: varlist} (min=2) {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Matrix}
{synopt :{opt MAT:rix(matname)}} store the
transition rates in {it:matname}. Will be
created or overwritten. {p_end}
{syntab:Moving average}
{synopt :{opt MA(int)}} Calculate a moving average over int+1+int periods. Defaults to 3. {p_end}
{synoptline} {p2colreset}{...}



{title:Description}

{pstd}{cmd:maketrpr} takes a set of sequences described by {it:varlist}
in wide format and creates an n by (n times t) matrix where each n by n
section contains the smoothed transition rates for the corresponding
time period. It uses {help tssmooth} to create the smoothed rates, defaulting
to a 3-unit look-head and look-back (i.e., a 7-wide moving average).
If the number of states is 4 and there are 10 periods, it
generates a (4x(10-1))x4 or 36x4 matrix, where T[1..4,1..4] contains the transition
rates for time 1-2, T[5..8,1..4] for time 2-3 and so on. 

{pstd}This is essentially a utility program, and is used by {help dynhamming} and
{help trprgr}.

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. maketrpr mon1-mon36, mat(trp)}{p_end}
{phang}{cmd:. matrix list trp}{p_end}

