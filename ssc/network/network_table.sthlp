{smcl}
{* *! version 1.1 27may2015}{...}
{vieweralsosee "Main network help page" "network"}{...}
{viewerjumpto "Syntax" "network_table##syntax"}{...}
{viewerjumpto "Description" "network_table##description"}{...}
{title:Title}

{phang}
{bf:network table} {hline 2} Tabulate network meta-analysis data


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network table} {ifin}, [{cmdab:trtc:odes} {it:tabdisp_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt trtc:odes}}makes the display use the treatment codes A, B, C etc. rather than the full treatment names.{p_end}
{synopt:{it:tabdisp_options}}are any options for {help tabdisp} except {cmd:cellvar()}.
For example, {cmd:cellwidth(#)} may be useful to increase column width to accommodate treatment names,
and {cmd:stubwidth(#)} may be useful to increase the width of the study name column.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}



{marker description}{...}
{title:Description}

{pstd}
{cmd:network table} tabulates network meta-analysis data. 
Data are reformatted and displayed using {help tabdisp}.



{p}{helpb network: Return to main help page for network}

