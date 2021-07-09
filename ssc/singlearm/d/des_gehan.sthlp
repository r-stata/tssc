{smcl}
{* *! version 1.0 14 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "des_gehan##syntax"}{...}
{viewerjumpto "Description" "des_gehan##description"}{...}
{viewerjumpto "Options" "des_gehan##options"}{...}
{viewerjumpto "Remarks" "des_gehan##remarks"}{...}
{viewerjumpto "Examples" "des_gehan##examples"}{...}
{title:Title}
{phang}
{bf:des_gehan} {hline 2} Design a two-stage Gehan single-arm trial for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:des_gehan}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt pi1(#)}} The (desirable) response probability. Defaults to 0.3.{p_end}
{synopt:{opt b:eta1(#)}} The desired maximal type-II error-rate for stage one. Defaults to 0.1.{p_end}
{synopt:{opt g:amma(#)}} The desired standard error for the estimate of the response probability by the end of stage two. Defaults to 0.05.{p_end}
{synopt:{opt a:lpha(#)}} The confidence level to use in the formula for computing the second stage sample sizes. Defaults to 0.05.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates that a plot of the second stage sample sizes should be produced.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
Supports the determination of two-stage Gehan single-arm clinical trial designs
for a single binary primary endpoint.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt pi1(#)} The (desirable) response probability. Defaults to 0.3.

{phang}
{opt b:eta1(#)} The desired maximal type-II error-rate for stage one. Defaults to 0.1.

{phang}
{opt g:amma(#)} The desired standard error for the estimate of the response probability by the end of stage two. Defaults to 0.05.

{phang}
{opt a:lpha(#)} The confidence level to use in the formula for computing the second stage sample sizes. Defaults to 0.05.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates that a plot of the second stage sample sizes should be produced.

{phang}
{opt *} Additional options to use during plotting.

{marker examples}{...}
{title:Examples}

{phang}
{stata des_gehan}

{phang}
{stata des_gehan, beta1(0.2) plot}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}
