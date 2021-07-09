{smcl}
{* *! version 1.0 14 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "est_fixed##syntax"}{...}
{viewerjumpto "Description" "est_fixed##description"}{...}
{viewerjumpto "Options" "est_fixed##options"}{...}
{viewerjumpto "Remarks" "est_fixed##remarks"}{...}
{viewerjumpto "Examples" "est_fixed##examples"}{...}
{title:Title}
{phang}
{bf:est_fixed} {hline 2} Determine point estimates in a single-stage single-arm
trial design for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:est_fixed}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt n(#)}} Sample size of the considered design. Defaults to 25.{p_end}
{synopt:{opt pi(numlist)}} Numlist of response probabilities to evaluate the expected performance of the point estimation procedures at. This will internally default to 0,0.01,...,1.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates that the RMSE curve of the estimation procedure should be plotted.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

Determines all possible point estimates (the MLEs) at the end of a single-stage
single-arm trial for a single binary endpoint, as determined using des_fixed.

In addition, the performance of the point estimation procedure (including its
expected value, bias, and variance) for each value of pi in the supplied numlist
pi, will also be evaluated.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt n(#)} Sample size of the considered design. Defaults to 25.

{phang}
{opt pi(numlist)} Numlist of response probabilities to evaluate the expected performance of the point estimation procedures at. This will internally default to 0,0.01,...,1.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates that the RMSE curve of the estimation procedure should be plotted.

{phang}
{opt *} Additional options to use during plotting.

{marker examples}{...}
{title:Examples}

{phang}
{stata est_fixed}

{phang}
{stata est_fixed, n(30)}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

Related commands:

{help des_fixed} (if installed)
{help opchar_fixed} (if installed)
{help ci_fixed} (if installed)
{help pval_fixed} (if installed)
