{smcl}
{* Copyright 2007-2011 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 27August2007}{...}
{cmd:help permtab, permtabga}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:permtab} {hline 2}}Rearrange columns of square table to maximise kappa{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:permtab} {it: rowvar colvar} [if] [in] [, gen(newvarname)]

{p 8 17 2}
{cmd:permtabga} {it: rowvar colvar} [if] [in] [, gen(newvarname)]

{title:Description}

{pstd}{cmd:permtab} permutes the columns of the square
crosstabulation of rowvar by colvar to maximise kappa. It is
intended for use in comparing cluster solutions where the identity
of categories from one solution to the other is only defined in
terms of membership. Kappa measures the excess of observed over
expected on the diagonal. Kappa_max is the Kappa of the best
solution, and is reported.{p_end}

{pstd}A permuted version of {it:colvar} is created by the {cmd:gen} option.{p_end}

{pstd}Returns kappa_max as r(kappa).{p_end}

{pstd}{bf:Note}: For numbers of categories much above 8 this procedure
is slow and inefficient. For such cases {cmd:permtabga} uses a genetic
algorithm approach to find an approximate solution.{p_end}


{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. permtab a8 b8}{p_end}

