{smcl}
{* Copyright 2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 17June2012}{...}
{cmd:help corrsqm}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:corrsqm} {hline 2}}Calculate the correlation between the lower triangle of two symmetric matrices{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:corrsqm} {it: var1 var2} [if] [in] [,NODiag]

{title:Description}

{pstd}{cmd:corrsqm} takes two symmetric matrices of the same dimension
(e.g., distance matrices) and returns their correlation. More
specifically, it returns the correlation between their lower triangles,
including the diagonal by default. It fails if one or both matrix is not symmetric,
or if the matrices are not the same size. It prints the correlation but
also returns it in r(rho).{p_end}

{pstd}The option {cmd:nodiag} suppresses the diagonal, so that the
correlation is between the lower triangles excluding the main
diagonal.{p_end}

{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. corrsqm dist1 dist2}{p_end}

