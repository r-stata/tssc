{smcl}
{* *! version 1.0 30 Jul 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "pipe##syntax"}{...}
{viewerjumpto "Description" "pipe##description"}{...}
{viewerjumpto "Options" "pipe##options"}{...}
{viewerjumpto "Remarks" "pipe##remarks"}{...}
{viewerjumpto "Examples" "pipe##examples"}{...}
{title:Title}
{phang}
{bf:pipe} {hline 2} A curve-free dual-agent dose-escalation design

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:pipe}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt maxs:ims(#)}}  specifies the maximum number of simulations to perform.

{pstd}
{p_end}
{synopt:{opt maxn(#)}}  specifies the maximum sample size per trial.

{pstd}
{p_end}
{synopt:{opt c:ohortsize(#)}}  specifies the size of the cohort per dose administration.

{pstd}
{p_end}
{synopt:{opt g:raph(string)}}  specifies that graphs of the simulation outputs are produced.

{pstd}
{p_end}
{synopt:{opt s:aving(string)}}  specifies that the simulation output graphs are saved.

{pstd}
{p_end}
{synopt:{opt t:heta(#)}}  specifies the target toxicity limit.

{pstd}
{p_end}
{synopt:{opt pwt(#)}}  specifies the total prior sample size, this can be very low and often 1 is sufficient

{pstd}
{p_end}
{synopt:{opt prior(string)}}  specifies the prior matrix of DLT probabilities.

{pstd}
{p_end}
{synopt:{opt true(string)}}  specifies the true matrix of DLT probabilities. 

{pstd}
{p_end}
{synopt:{opt nxz:one(string)}}  specifies the which doses to escalate to.

{pstd}
{p_end}
{synopt:{opt nxc:ons(#)}}  specifies whether there are any constraints of the dose escalation.

{pstd}
{p_end}
{synopt:{opt nxsafe(#)}}  specifies the safety limit on administering a dose combination.

{pstd}
{p_end}
{synopt:{opt nxs:el(string)}}  specifies the dose escalation rule. 

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:pipe} either takes a dataset and suggests the next dose combination and reports
various outputs or it performs simulations.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt maxs:ims(#)}     specifies the maximum number of simulations to perform.

{pstd}
{p_end}
{phang}
{opt maxn(#)}     specifies the maximum sample size per trial.

{pstd}
{p_end}
{phang}
{opt c:ohortsize(#)}     specifies the size of the cohort per dose administration.

{pstd}
{p_end}
{phang}
{opt g:raph(string)}     specifies that graphs of the simulation outputs are produced.

{pstd}
{p_end}
{phang}
{opt s:aving(string)}     specifies that the simulation output graphs are saved.

{pstd}
{p_end}
{phang}
{opt t:heta(#)}     specifies the target toxicity limit.

{pstd}
{p_end}
{phang}
{opt pwt(#)}     specifies the total prior sample size, this can be very low and often 1 is sufficient

{pstd}
{p_end}
{phang}
{opt prior(string)}     specifies the prior matrix of DLT probabilities.

{pstd}
{p_end}
{phang}
{opt true(string)}     specifies the true matrix of DLT probabilities. 

{pstd}
{p_end}
{phang}
{opt nxz:one(string)}     specifies the which doses to escalate to.

{pstd}
{p_end}
{phang}
{opt nxc:ons(#)}  specifies whether there are any constraints of the dose escalation. There are 3 different options either: 0 no constraint; 1 escalation is to neighbours of the current dose and does not allow dose skipping; or 2 escalation is allowed anywhere but no dose skipping is allowed.
{p_end}
{phang}
{opt nxsafe(#)}     specifies the safety limit on administering a dose combination.

{pstd}
{p_end}
{phang}
{opt nxs:el(string)}     specifies the dose escalation rule. 

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
 {stata pipe}

{title:Stored results}

{synoptset 15 tabbed}{...}


{title:References}
{pstd}

{pstd}
AP Mander and MJ Sweeting (2015) A product of independent beta probabilities dose escalation design for dual‐agent phase I trials. SiM 34:1261-1276.

{pstd}

{pstd}


{title:Author}
{p}

Prof Adrian Mander, Cardiff University.

Email {browse "mailto:mandera@cardiff.ac.uk":mandera@cardiff.ac.uk}



{title:See Also}
Related commands:

{help crm} (if installed)   {stata ssc install crm} (to install this command)

{help mtpi} (if installed)  {stata ssc install mtpi} (to install this command)

