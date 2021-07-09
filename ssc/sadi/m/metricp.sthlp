{smcl}
{* Copyright 2011 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 29Oct2011}{...}
{* $Id: metricp.hlp,v 1.7 2012/06/28 23:07:08 brendan Exp $}

{cmd:help metricp}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:metricp} {hline 2}}Test a symmetric matrix of pairwise distances for the triangle inequality{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:metricp} {it: matname} [,{opt cou:ntlimit(int)} {opt det:ailed}]

{synopthdr:Options}
{synoptline}
{syntab:Count limit}
{synopt :{opt cou:ntlimit(int)}} Number of triangle-inequality infringements to report (defaults to 10, 0 means no limit){p_end}
{synopt :{opt det:ailed}} Slowly identify the problem cases, not just the fact they exist. {p_end}

{title:Description}

{pstd}{cmd:metricp} takes a matrix of pairwise distances and tests that
the triangle inequality is observed. If it finds triads infringing on
the inequality it reports at most 10 before stopping (this is changed
with the option {cmd:countlimit}; set that to zero for no limit). If
there are no infringing cases and the matrix is large, it can be a
little slow (tens of seconds). It is even slower with the {cmd:detailed}
option (minutes), which identifies the infringing trio of sequences;
without this option only the fact that there is a shorter route between
sequence i and sequence j is reported. {p_end}



{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. metricp pwd}{p_end}


{title:Version}

