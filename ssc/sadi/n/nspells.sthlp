{smcl}
{* Copyright 2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 23June2012}{...}
{cmd:help nspells}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:nspells} {hline 2}}Calculate number of spells in  a sequence{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:nspells} {it: varlist} , {opt gen:erate(string)}

{title:Description}

{pstd}{cmd:nspells} creates a variable holding the number of spells in a sequence described by the {it:varlist}. The
{cmd:generate} option names the variable, which will be created. Spells are defined as consecutive runs of the same value. Runs of missing values are counted as spells. {p_end}


{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. nspells m1-m40, gen(nsp)}{p_end}
