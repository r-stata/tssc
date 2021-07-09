{smcl}
{* version 1.0  28Feb2011}{...}
{cmd:help betaprior}
{hline}

{title:Title}

    {hi: Calculates the parameters of a Beta distribution given the mean and variance}

{title:Syntax}

{p 8 17 2}
{cmdab:betaprior} 
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt m:ean}(#)} specifies the mean of the required Beta distribution.{p_end}
{synopt:{opt v:ariance}(#)} specifies the variance of the required Beta distribution.{p_end}
{synopt:{opt g:raph}} specifies that a graph of the distribution be produced.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
The command betaprior calculates the two parameters for a Beta distribution given specified values for the
mean and variance.

{title:Options}

{dlgtab:Main}

{phang}
{opt m:ean}(#) specifies the mean of the required Beta distribution. The default value is 0.2.

{phang}
{opt v:ariance}(#) specifies the variance of the required Beta distribution. The default value is 0.1.

{phang}
{opt g:raph} specifies that a graph of the distribution be produced.

{title:Examples}

{pstd}
To find the parameters of the Beta distribution with a mean 0.4 and variance of 0.2

{phang}{stata betaprior, m(0.4) v(0.2) g}


{title:Author}

{p}
Adrian Mander, MRC Biostatistics Unit, Cambridge, UK.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}
