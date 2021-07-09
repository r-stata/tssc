{smcl}
{* *! version 1.1 27may2015}{...}
{vieweralsosee "Main network help page" "network"}{...}
{viewerjumpto "Syntax" "network_pattern##syntax"}{...}
{viewerjumpto "Description" "network_pattern##description"}{...}
{title:Title}

{phang}
{bf:network pattern} {hline 2} Graph showing network meta-analysis as a missing data pattern


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network pattern} {ifin}
[, {cmdab:trtc:odes}
{it:misspattern_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt trtc:odes}}makes the display use the treatment codes A, B, C etc. rather than the full treatment names.{p_end}
{synopt:{it:misspattern_options}}are options for {help misspattern}, 
though {cmd:network pattern} chooses some sensible options.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}



{marker description}{...}
{title:Description}

{pstd}
{cmd:network pattern} shows which treatments are used in which studies.
This is done using a utility {help misspattern} which can display general patterns of missing data.
The data must be in {cmd:network} format.


{p}{helpb network: Return to main help page for network}

