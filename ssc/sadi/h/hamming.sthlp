{smcl}
{* Copyright 2007-2011 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 17July2015}{...}
{cmd:help hamming}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:hamming} {hline 2}}Calculate inter-sequence distances using Hamming distance{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:hamming} {it: varlist} {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Cost structure}
{synopt :{opt subs:mat(matname)}} use {it:matname} as the substitution cost matrix{p_end}

{syntab:Distances}
{synopt :{opt pwd:ist(matname)}} store the pairwise distances in {it:matname}, as a symmetric matrix. Will be created or overwritten. {p_end}

{syntab:Normalisation}
{synopt :{opt STA:ndard}} (Optional) If "longer", normalise by the length of the sequences, if "none" do no normalisation. Defaults to "longer". {p_end}

{synoptline} {p2colreset}{...}

{title:Description}

{pstd}{cmd:hamming} calculates Hamming distances between all pairs
of sequences in the data, where {it:varlist} is a consecutive set
of variables describing the elements of the sequence. Hamming
distances compare sequences element by element such that the
inter-sequence distance is the sum of the element-wise distances.
The element-wise distances are given in the {it:subsmat()}
substitution matrix. 

{pstd}States must be numbered as consecutive integers from 1 up, and the
substitution cost matrix must be square, with dimension equal to the
number of states. States must not be missing.

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. matrix scost = (0,1,2,3\1,0,1,2\2,1,0,1\3,2,1,0)}{p_end}
{phang}{cmd:. hamming mon1-mon36, subsmat(scost) pwdist(dist)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

{phang}{cmd:. hamming mon1-mon72, subsmat(scost) pwdist(dist)}{p_end}
{phang}{cmd:. matrix list dist}{p_end}

