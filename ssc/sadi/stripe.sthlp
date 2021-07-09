{smcl}
{* Copyright 2011 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 29October2011}{...}
{cmd:help stripe}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:stripe} {hline 2}}Create a single string variable representing the sequence {p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:stripe} {it:varlist}, GENerate(newvarname) [SYMbols(string) XT XTSPellsep(string) XTDursep(string)]

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Required}
{synopt :{opt gen:erate(varname)}} names the variable in which to store the representation{p_end}
{syntab:Optional}
{synopt :{opt sym:bols(string)}} String containing symbols to use (defaults to "ABC...") {p_end}
{synopt :{opt xt}} Use condensed format (state/duration pairs){p_end}
{synopt :{opt xtsp:ellsep(string)}} Separator between spells in condensed format, defaults to "".{p_end}
{synopt :{opt xtd:ursep(string)}} Separator between state and duration in condensed format, defaults to "".{p_end}

{title:Description}

{pstd}{cmd:stripe} Create a single string variable representing a
sequence. Option {cmd:symbols} allows replacement of the default symbol
series (the uppercase alphabet). This makes sequences easier to view,
and enables one to use regular expressions to group sequences {manhelp mf_regex M-5:regexm()}.{p_end}

{pstd}{bf:Note}: Assumes sequences are represented by consecutive variables containing numeric values.{p_end}


{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. stripe state1-state40, gen(seqstr)}{p_end}
{phang}{cmd:. stripe state1-state40, gen(seqstr) symbols("FPun")}{p_end}
{phang}{cmd:. stripe state1-state40, gen(xtstr) xt xtsp("/") xtdur(":")}{p_end}
{phang}{cmd:. list seqstr if regexm(seqstr,"FFFF+.+nnnn")}{p_end}
{phang}{cmd:. list seqstr if regexm(seqstr,"^F+n+$")}{p_end}


