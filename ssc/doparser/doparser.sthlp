{smcl}
{* *! version 0.12.06 19jun2012}{...}
{cmd:help doparser}
{hline}

{title:Title}

{phang}
{bf:doparser} {hline 2} Look for dta-files used in do-files|ado-files (plain-text)

{title:Syntax}

{p 8 17 2}
{cmdab:doparser}
{it:{help filename}}
[, {opt t:ype(calltype)}
{opt e:xport(filename)}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt t:ype(calltype)}}Filters the results acording to the calltype, where calltype can be use|sysuse|webuse|merge|save|append.{p_end}
{synopt:{opt e:xport(filename)}}Export the results to a dta-file.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
Using regular expressions, {cmd:doparser} reads plain-text files and analize them
looking for dta-files used in them (whatever form of how are used) and builds a
summary table pointing every dta-files including name, type (usage), line number
and location (directory).

{pstd}
This command was programmed as an exercise on Stata's regular expressions
capabilities.

{pstd}
{cmd:doparser} preserves data.
{p_end}

{title:Examples}

{pstd}Basic usage{p_end}
{phang2}{cmd:. doparser "C:/research/miscrip.do"}

{pstd}Using the same file but keeping only "save" files. Results are save in "myresults.dta"{p_end}
{phang2}{cmd:. doparser "C:/research/miscrip.do", t(save) e(myresults)}
{p_end}

{title:Author}

{pstd}
George Vega Yon, Superindentencia de Pensiones. {browse "mailto:gvega@spensiones.cl"}
{p_end}
