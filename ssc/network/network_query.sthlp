{smcl}
{* *! version 1.1 27may2015}{...}
{vieweralsosee "Main network help page" "network"}{...}
{title:Title}

{phang}
{bf:network query} {hline 2} display network settings


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:network} {cmdab:q:uery}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt t:rtnames}}Display only the names 
which correspond to the treatment codes.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:network query} displays the current network settings.
These include the format of the data, 
the treatment codes and names, etc.

{pstd}
The network settings are stored as characteristics of the data set 
and can also be viewed using {help char list}.



{p}{helpb network: Return to main help page for network}


