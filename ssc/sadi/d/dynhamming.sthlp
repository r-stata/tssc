{smcl}
{* Copyright 2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 20Apr2012}{...}
{cmd:help dynhamming}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:dynhamming} {hline 2}}Calculate inter-sequence distances using dynamic Hamming distance{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:dynhamming} {it: varlist} {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Distances}
{synopt :{opt pwd:ist(matname)}} store the
pairwise distances in {it:matname}, as a symmetric matrix. Will be
created or overwritten. {p_end}
{synoptline} {p2colreset}{...}



{title:Description}

{pstd}{cmd:dynhamming} calculates Lesnard's dynamic Hamming distances
between all pairs of sequences in the data, where {it:varlist} is a
consecutive set of variables describing the elements of the sequence.
Dynamic Hamming distances compare sequences element by element such that
the inter-sequence distance is the sum of the element-wise distances.
The element-wise distances are dynamic, based on the time-dependent
structure of transition rates. The procedure uses {help maketrpr} to
calculate the transition rates, smoothing over a rolling seven (3+1+3)
observations. See also {help trprgr} which uses {cmd:maketrpr} to graph
the time-dependent transition structure.

{pstd}States must be numbered as integers from 1 up.

{pstd}

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. dynhamming mon1-mon36, pwdist(dist)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

