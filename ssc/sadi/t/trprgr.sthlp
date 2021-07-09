{smcl}
{* Copyright 2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 10Jun2012}{...}
{cmd:help trprgr}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:trprgr} {hline 2}}Graphically present transition rates from sequences{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:trprgr} {it: varlist} (min=2) {cmd:,} {it:options} [option] 

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:ID}
{synopt :{opt ID(varname)}} A unique case-id variable. Required. {p_end}
{syntab:Optional}
{synopt :{opt FL:oor(real)}} Lowest transition rate for diagonal graphs. {p_end}
{synopt :{opt CEI:ling(real)}} Highest transition rate for off-diagonal graphs. {p_end}
{synopt :{opt GM:ax(int)}} Highest number of cases in any state at any time. {p_end}
{synopt :{opt MOV:ingaverage(int)}} Look-back and look-ahead for moving average, default 3. {p_end}
{synopt :{opt TEX:tsize(string)}} Text size of labels. {p_end}
{synoptline} {p2colreset}{...}



{title:Description}

{pstd}{cmd:trprgr} takes a set of sequences described by {it:varlist} in
wide format and graphs the time-dependent transition rate structure. The
graphic consists of m rows and m+1 columns, where m is the number of
states. The first column displays the time-dependent distribution of
states, and the remaining m by m structure reproduces an m by m
transition table but with graphs of time-series of transition rates
instead of single values.

{pstd}Time series on the diagonal are plotted on the y-axis with a range
of FLOOR to 1, those off the diagonal on the range 0 to CEILING. This
assumes that retention in a state is more common than transitions
between states, but setting FLOOR and CEILING respectively to 0 and 1
will give a common y-axis. The option GMAX sets the range for the
state-distribution graphs, and should be set slightly greater than the
maximum to make the state distribution graphs comparable.

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. trprgr mon1-mon36, id(id)}{p_end}
