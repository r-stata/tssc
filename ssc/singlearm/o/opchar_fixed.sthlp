{smcl}
{* *! version 1.0 15 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "opchar_fixed##syntax"}{...}
{viewerjumpto "Description" "opchar_fixed##description"}{...}
{viewerjumpto "Options" "opchar_fixed##options"}{...}
{viewerjumpto "Remarks" "opchar_fixed##remarks"}{...}
{viewerjumpto "Examples" "opchar_fixed##examples"}{...}
{title:Title}
{phang}
{bf:opchar_fixed} {hline 2} Determine the operating characteristics of single stage single-arm trial designs for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:opchar_fixed}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt n(#)}} Sample size of the considered design. Defaults to 25.{p_end}
{synopt:{opt a(#)}} Acceptance boundary of the considered design. Defaults to 5.{p_end}
{synopt:{opt pi(numlist)}} Numlist of response probabilities to evaluate the operating characteristics of the design at. Internally defaults to 0,0.01,...,1.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates that the power curve should be plotted.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

For each value of pi in the supplied numlist pi, opchar_fixed evaluates the power
of each of the supplied designs. Additional operating characteristics are also
returned for convenience.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt n(#)} Sample size of the considered design. Defaults to 25.

{phang}
{opt a(#)} Acceptance boundary of the considered design. Defaults to 5.

{phang}
{opt pi(numlist)} Numlist of response probabilities to evaluate the operating characteristics of the design at. Internally defaults to 0,0.01,...,1..

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates that the power curve should be plotted.

{phang}
{opt *} Additional options to use during plotting.


{marker examples}{...}
{title:Examples}

{phang}
{stata opchar_fixed}

{phang}
{stata opchar_fixed, n(30)}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

Related commands:

{help des_fixed} (if installed)
{help est_fixed} (if installed)
{help ci_fixed} (if installed)
{help pval_fixed} (if installed)
