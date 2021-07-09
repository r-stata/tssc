{smcl}
{* *! version 1.0  3July2014 James J Feigenbaum}{...}
{cmd:help keeporder}
{hline}

{title:Title}

{phang}
{cmd:keeporder} {hline 2} Keep and reorder variables in dataset

{title:Syntax}

{p 8 17 2}
{cmd:keeporder}
{varlist}


{title:Description}

{pstd}
{cmd:keeporder} keeps and then orders the specified variables, eliminating the need to run {cmd:keep} {varlist} and then {cmd:order} {varlist}.

{title:Examples}

{phang}{cmd:. sysuse auto} 

{phang}{cmd:. keeporder make price gear_ratio trunk} 

{title:Author}

{pstd} James Feigenbaum {p_end}
{pstd} Harvard University {p_end}
{pstd} jfeigenb@fas.harvard.edu {p_end}
{pstd} http://scholar.harvard.edu/jfeigenbaum {p_end}

{title:Also see}

{pstd}
{help keep:keep},
{help order:order},
{help keepvar:keepvar}

