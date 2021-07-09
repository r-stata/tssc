{smcl}
{* Copyright 2007-2011 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 24August2007}{...}
{cmd:help omav}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:omav} {hline 2}}Calculate inter-sequence distances using duration-compensated Needleman--Wunsch algorithm{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:omav} {it: varlist} {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Cost structure}
{synopt :{opt subs:mat(matname)}} use {it:matname} as the substitution cost matrix{p_end}
{synopt :{opt ind:el(#)}} use {it:#} as the cost for insertions/deletions{p_end}
{syntab:Sequence length} {synopt :{opt len:gth(var)}} sequence
length, a variable or a constant if sequence length is fixed{p_end}
{syntab:Distances} {synopt :{opt pwd:ist(matname)}} store the
pairwise distances in {it:matname}, as a symmetric matrix. Will be
created or overwritten. {p_end}
{syntab:Duration adjustment} {synopt :{opt fac:exp(real)}}
(Optional) Exponent by which to adjust costs for duration (defaults to 0.5)

{syntab:Work-space} {synopt :{opt wor:kspace}} (Optional) Causes the internal
workspace matrices to be shown for each sequence comparison. {p_end}
{synoptline} {p2colreset}{...}



{title:Description}

{pstd}{cmd:omav} calculates duration-adjusted Optimal Matching
distances between all pairs of sequences in the data, where
{it:varlist} is a consecutive set of variables describing the
elements of the sequence. It uses a Stata plugin implementation of
an adapted Needleman{c -}Wunsch algorithm. It differs from the
standard {cmd:oma} command in that the costs of elementary
operations are reduced for tokens that are elements of runs of the
same value. By default, the cost of an operation on an element of
an n-element sequence is changed by a factor of 1/n^f where f is
given by the {opt:fac:exp} option. The value of f defaults to 0.5.
A value of f of zero produces the same result as {cmd:oma} and a
value of f of 1.0 weights all spells the same regardless of length. 

{pstd}Note: this measure is not guaranteed to be metric. 

{pstd}States must be numbered as consecutive integers from 1 up, and the
substitution cost matrix must be square, with dimension equal to the
number of states. States must not be missing.


{title:References}

{p 4 4 2}
Halpin, Brendan. (2010).
Optimal Matching Analysis and Life
Course Data: the importance of duration
{it:Sociological Methods and Research}, 38(3)

{p 4 4 2} Halpin, Brendan. (2014). Three narratives of sequence
analysis, Bühlmann et al (eds), {it: Advances in Sequence Analysis.
Beyond the Core Program}, Springer

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. matrix scost = (0,1,2,3\1,0,1,2\2,1,0,1\3,2,1,0)}{p_end}
{phang}{cmd:. omav mon1-mon36, subsmat(scost) indel(2) pwdist(dist) len(36)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

{phang}{cmd:. omav mon1-mon72, subsmat(scost) indel(2) pwdist(dist) len(dur) facexp(0.75)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

