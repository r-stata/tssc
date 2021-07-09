{smcl}
{* Copyright 2007-2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 16June2012}{...}
{cmd:help combinadd}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:combinadd} {hline 2}}Calculate inter-sequence distances using Elzinga's duration-weighted subsequence counting{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:combinadd} {it: varlist} {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Required}
{synopt :{opt nsp:ells(string)}} Name the variable which stores the number of spells{p_end}
{synopt :{opt nst:ates(string)}} Name the variable which stores the number of states{p_end}
{synopt :{opt pws:im(string)}} Name the matrix which will store the similarities or distances{p_end}

{syntab:Optional}
{synopt :{opt rt:ype(string)}} Generate similarities or distances: "s"
for similarities, "d" for distances, "r" for raw SXY values. Defaults to
similarities. {p_end}
{synopt :{opt wor:kspace}} Show workings{p_end}
{synopt :{opt maxt:uples(integer)}} Maximum number of tuples (subsequences) to count in one sequence (default 40000){p_end}


{synoptline} {p2colreset}{...}



{title:Description}

{pstd}{cmd:combinadd} calculates a version of Elzinga's
duration-weighted number of common subsequences measure for
spell-structured data. The variable list must identify the spell
structure in the form state-1, duration-1, state-2, duration-2, ...
state-X, duration-X where X is the maximum number of spells observed.
The nspells option identifies the variable that stores the case-specific number of spells.

{pstd}States must be numbered as integers from 1 up.

{pstd} The measure counts the number of spell sub-sequences common to
each pair of sequences, weighted by the combined duration of the
subsequence. The number of subsequences in a sequence increases very
rapidly with the length of the sequence, with major consequences for
memory demands. This implementation can handle sequences with of the
order of 15 spells without too much difficulty. The maxtuples limit
causes the command to stop if too many subsequences are observed, in
order to avoid running out of memory. The maxtuples option can be used
to judiciously raise this limit.

{pstd} It uses a Stata plugin implementation.{p_end}

{pstd} See {help combinprep} for a way of converting calendar
representations to spell representations.{p_end}

{title:References}

{p 4 4 2}
Elzinga, C. H. (2003).
Sequence similarity: A non-aligning technique.
{it:Sociological Methods and Research}, 32(1):3--29.

{p 4 4 2}
Elzinga, C. H. (2005).
Combinatorial representations of token sequences.
{it:Journal of Classification}, 22(1):87--118.

{p 4 4 2}
Elzinga, C. H. (2006).
Sequence analysis: Metric representations of categorical time series.
Technical report, Free University of Amsterdam.

{p 4 4 2} Halpin, Brendan. (2014). Three narratives of sequence
analysis, Bühlmann et al (eds), {it: Advances in Sequence Analysis.
Beyond the Core Program}, Springer

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. combinprep, state(m) length(l) idvar(id) nsp(nspells) }{p_end}

{phang}{cmd:. local nsp = r(maxspells)}{p_end}
{phang}{cmd:. local nel = r(nels)}{p_end}

{phang}{cmd:. combinadd m1-l`nsp', pwsim(xtd) nspells(nspells) nstates(`nel') rtype(d)}{p_end}
