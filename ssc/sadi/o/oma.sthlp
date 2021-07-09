{smcl}
{* Copyright 2007-2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 19April2012}{...}
{cmd:help oma}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:oma} {hline 2}}Calculate inter-sequence distances using Needleman--Wunsch algorithm{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:oma} {it: varlist} {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Cost structure}
{synopt :{opt subs:mat(matname)}} use {it:matname} as the substitution cost matrix{p_end}
{synopt :{opt ind:el(#)}} use {it:#} as the indel cost{p_end}

{syntab:Sequence length} {synopt :{opt len:gth(var)}} sequence
length, a variable or a constant if sequence length is fixed{p_end}

{syntab:Distances} {synopt :{opt pwd:ist(matname)}} store the
pairwise distances in {it:matname}, as a symmetric matrix. Will be
created or overwritten. {p_end}

{syntab:Work-space} {synopt :{opt wor:kspace}} (Optional) Causes the internal
workspace matrices to be shown for each sequence comparison. {p_end}

{syntab:Duplicates} {synopt :{opt DU:ps}} (Optional) Force calculation of duplicate distances. {p_end}

{syntab:Normalisation} {synopt :{opt STA:ndard}} (Optional) If "longer", normalise by the length of the longer sequence, if "none" do no normalisation. Defaults to "longer". {p_end}


{synoptline} {p2colreset}{...}



{title:Description}

{pstd}{cmd:oma} calculates Optimal Matching distances between all
pairs of sequences in the data, where {it:varlist} is a consecutive
set of variables describing the elements of the sequence. It uses a
Stata plugin implementation of the Needleman--Wunsch algorithm.

{pstd}States must be numbered as consecutive integers from 1 up, and the
substitution cost matrix must be square, with dimension equal to the
number of states. States must not be missing.

{pstd}

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. matrix scost = (0,1,2,3\1,0,1,2\2,1,0,1\3,2,1,0)}{p_end}
{phang}{cmd:. oma mon1-mon36, subsmat(scost) indel(2) pwdist(dist) len(36)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

{phang}{cmd:. oma mon1-mon72, subsmat(scost) indel(2) pwdist(dist) len(dur)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

