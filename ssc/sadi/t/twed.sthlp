{smcl}
{* Copyright 2007-2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 16June2012}{...}
{cmd:help twed}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:twed} {hline 2}}Calculate inter-sequence distances using Time-Warp Edit Distance{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:twed} {it: varlist} {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Cost structure}
{synopt :{opt subs:mat(matname)}} use {it:matname} as the substitution cost matrix{p_end}
{synopt :{opt lam:bda(#)}} use {it:#} as the lambda parameter{p_end}
{synopt :{opt nu(#)}} use {it:#} as the nu parameter{p_end}

{syntab:Sequence length} {synopt :{opt len:gth(var)}} sequence
length, a variable or a constant if sequence length is fixed{p_end}

{syntab:Distances} {synopt :{opt pwd:ist(matname)}} store the
pairwise distances in {it:matname}, as a symmetric matrix. Will be
created or overwritten. {p_end}

{syntab:Work-space} {synopt :{opt wor:kspace}} (Optional) Causes the internal
workspace matrices to be shown for each sequence comparison. {p_end}

{syntab:Normalisation} {synopt :{opt STA:ndard}} (Optional) If "longer", normalise by the length of the longer sequence, if "none" do no normalisation. Defaults to "longer". {p_end}


{synoptline} {p2colreset}{...}



{title:Description}

{pstd}{cmd:twed} calculates Marteau's Time-Warp Edit Distance (TWED)
between all pairs of sequences in the data, where {it:varlist} is a
consecutive set of variables describing the elements of the sequence.
Time-warping stretches and compresses the time dimension to achieve
alignment in a manner similar but not identical to {help oma}'s
insertion and deletion. Marteau (2007) describes a time-warping
algorithm with a stiffness parameter (nu) and a gap penalty (lambda)
which is metric as long as nu>0 (many time-warping distances are not
metric). Because it uses compression instead of deletion, it respects
the spell structure of the trajectory more than {help oma} does. It uses
a matching cost operation that is very close to OMA's substitution
operation. The algorithm also differs by comparing adjacent pairs of
elements in each sequence, rather than single elements.

{pstd}
It uses a Stata plugin implementation.

{pstd}States must be numbered as consecutive integers from 1 up, and the
substitution cost matrix must be square, with dimension equal to the
number of states. States must not be missing.

{title:References}

{p 4 4 2} Halpin, Brendan. (2014). Three narratives of sequence
analysis, Bühlmann et al (eds), {it: Advances in Sequence Analysis.
Beyond the Core Program}, Springer

{p 4 4 2}
Marteau, P.-F. (2007).
 Time Warp Edit Distance with Stiffness Adjustment for Time Series
  Matching.
 {it:ArXiv Computer Science e-prints}.

{p 4 4 2}
Marteau, P.-F. (2008).
Time Warp Edit Distance.
{it:ArXiv e-prints}, 802.


{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. matrix scost = (0,1,2,3\1,0,1,2\2,1,0,1\3,2,1,0)}{p_end}
{phang}{cmd:. twed m1-m36, subsmat(scost) lambda(0.5) nu(0.15) pwdist(dist) len(36)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

{phang}{cmd:. twed m1-m72, subsmat(scost) lambda(0.5) nu(0.15) pwdist(dist) len(dur)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

