{smcl}
{* Copyright 2007-2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 16June2012}{...}
{cmd:help hollister}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:hollister} {hline 2}}Calculate inter-sequence distances using Hollister's Localized OM{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:hollister} {it: varlist} {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Cost structure}
{synopt :{opt subs:mat(matname)}} use {it:matname} as the substitution cost matrix{p_end}
{synopt :{opt TIME:cost(#)}} use {it:#} as the time cost{p_end}
{synopt :{opt LOC:alcost(#)}} use {it:#} as the local cost{p_end}

{syntab:Sequence length} {synopt :{opt len:gth(var)}} sequence
length, a variable or a constant if sequence length is fixed{p_end}

{syntab:Distances} {synopt :{opt pwd:ist(matname)}} store the
pairwise distances in {it:matname}, as a symmetric matrix. Will be
created or overwritten. {p_end}

{syntab:Work-space} {synopt :{opt wor:kspace}} (Optional) Causes the internal
workspace matrices to be shown for each sequence comparison. {p_end}

{syntab:Normalisation} {synopt :{opt STA:ndard}} (Optional) If "longer",
normalise by the length of the longer sequence, if "none" do no normalisation. Defaults to "longer". {p_end}

{synoptline} {p2colreset}{...}



{title:Description}

{pstd}{cmd:hollister} calculates localised Optimal Matching distances
between all pairs of sequences in the data, where {it:varlist} is a
consecutive set of variables describing the elements of the sequence. It
uses a Stata plugin implementation of Mattissa Hollister's adaptation of
the Needleman--Wunsch algorithm. Thanks to Mattissa for help in figuring
out to code it, but if I have introduced any errors they are my own.

{pstd}Hollister's measure differs from conventional OM by taking account
of the neighbours of tokens involved in OM's elementary operations.
While this is attractive from a sociological point of view, it means the
dissimilarity measure is not guaranteed to be metric. This is also true
of {help omav}.

{pstd}States must be numbered as consecutive integers from 1 up, and the
substitution cost matrix must be square, with dimension equal to the
number of states. States must not be missing.

{title:References}

{p 4 4 2} Halpin, Brendan. (2014). Three narratives of sequence
analysis, Bühlmann et al (eds), {it: Advances in Sequence Analysis.
Beyond the Core Program}, Springer

{p 4 4 2}
Hollister, M. (2009).
Is optimal matching suboptimal?
{it:Sociological Methods and Research}, 38(2):235--264.


{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. matrix scost = (0,1,2,3\1,0,1,2\2,1,0,1\3,2,1,0)}{p_end}
{phang}{cmd:. hollister mon1-mon36, subsmat(scost) time(0.5) local(0.5) pwdist(dist) len(36)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

{phang}{cmd:. hollister mon1-mon36, subsmat(scost) time(0.5) local(0.5) pwdist(dist) len(dur)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

