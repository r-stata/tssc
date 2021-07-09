{smcl}
{* documented: April 14, 2009}{...}
{* revised: July 10, 2009}{...}
{cmd:help mtreatreg postestimation}{right:also see:  {helpb mtreatreg}}
{hline}

{title:Title}

{p2colset 5 36 38 2}{...}
{p2col:{hi:mtreatreg postestimation} {hline 2}}Postestimation
tools for mtreatreg{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following postestimation commands are available for {opt mtreatreg}:

{synoptset 13 tabbed}{...}
{synopt:command}description{p_end}
{synoptline}
{p2col :{helpb mtreatreg postestimation##predict:predict}}predictions{p_end}
INCLUDE help post_estat
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_mfx
INCLUDE help post_nlcom
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict}
{dtype}
{newvar}
{ifin}
[{cmd:,} {it:options}]

{marker options}{...}
{synoptset 13 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt:{opt mu}}E(y), the fitted values (the default){p_end}
{synopt:{opt xb}}linear prediction for outcome{p_end}
{synopt:{opt at(#)}}specifies the values of the latent factors at which to
	evaluate predictions.  The default is a 0 vector.{p_end}
{synoptline}
{p2colreset}{...}
INCLUDE help esample


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt mu} calculates the the expected value of the dependent
variable; the default.

{phang}
{opt xb} calculates the linear predictions for the dependent
variable.

{phang}
{opt at(#)} specifies the value of the latent factor at which predictions
	are evaluated.  The default is 0.


{title:Examples}

{phang}{cmd:. mtreatreg y x1 x2, mtreat(d=x1 x2 z) sim(200) dens(gamma)}{p_end}
{phang}{cmd:. predict yhat}{p_end}
{phang}{cmd:. predict yhat, xb}{p_end}
{phang}{cmd:. predict yhat, at(1 1)}{p_end}


{title:Author}

{phang}Partha Deb, Hunter College and The Graduate Center, City University of New York, 
and NBER, USA.{p_end}
{phang}partha.deb@hunter.cuny.edu{p_end}


{title:Also see}

{psee}
Online:  
{helpb mtreatreg}{break}
{helpb estat},
{helpb estimates},
{helpb lincom},
{helpb lrtest},
{helpb mfx},
{helpb nlcom},
{helpb predictnl},
{helpb test},
{helpb testnl}
{p_end}
